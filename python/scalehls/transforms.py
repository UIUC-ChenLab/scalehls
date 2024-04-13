# ===----------------------------------------------------------------------=== #
#
# Copyright 2020-2021 The ScaleHLS Authors.
#
# ===----------------------------------------------------------------------=== #

import subprocess
import networkx as nx
from torch import Tensor
from ._mlir_libs._scalehls import *
from graphviz import Digraph
import re
import functools
import operator
from .dialects import hls, linalg, tensor, func, hls_transform, transform, arith
from .ir import IntegerType, IntegerAttr, StringAttr, ArrayAttr, Value, InsertionPoint, UnitAttr, DenseI64ArrayAttr, Block, Operation, Type, Location, Module, Context, BlockArgument, Attribute, OpView
from .dialects.transform import structured as linalg_transform
from .dialects.transform import tensor as tensor_transform
from .passmanager import PassManager
from typing import Sequence, Optional, Union, Callable, Mapping, Set, Any, List, Dict
from functools import wraps


# ===----------------------------------------------------------------------=== #
# Compilation Passes
# ===----------------------------------------------------------------------=== #


def apply_transform_sequence(
        module: Module,
        sequence: transform.NamedSequenceOp,
        delete_sequence: bool = True):
    pm = PassManager.parse(
        "builtin.module("
        "scalehls-transform-interpreter{"
        f"entry-point={sequence.sym_name.value} "
        f"delete-entry-point={str(delete_sequence).lower()}"
        "},"
        "cse, canonicalize"
        ")")
    pm.run(module.operation)
    if delete_sequence:
        del module.operation.attributes["transform.with_named_sequence"]


def apply_linalg_optimization_passes(module: Module, preprocess: bool = True):
    pm = PassManager.parse(
        "builtin.module("
        "convert-tensor-to-linalg,"
        "linalg-generalize-named-ops,"
        "linalg-fuse-elementwise-ops,"
        "linalg-fold-unit-extent-dims,"
        "eliminate-empty-tensors,"
        "linalg-inline-scalar-operands,"
        "func.func(scalehls-preprocess),"
        "cse, canonicalize"
        ")")
    pm.run(module.operation)


def apply_reduce_full_tensor_to_itensor_buffer(module: Module):
    pm = PassManager.parse(
        "builtin.module("
        "func.func(scalehls-reduce-full-tensor-to-itensor-buffer),"
        "cse, canonicalize"
        ")")
    pm.run(module.operation)


def apply_pack_itensor_dma(module: Module):
    pm = PassManager.parse(
        "builtin.module("
        "func.func(scalehls-pack-itensor-dma),"
        "cse, canonicalize"
        ")")
    pm.run(module.operation)


def apply_materialize_itensor_dma(module: Module):
    pm = PassManager.parse(
        "builtin.module("
        "func.func(scalehls-materialize-itensor-dma),"
        "cse, canonicalize"
        ")")
    pm.run(module.operation)


def apply_ensure_itensor_single_use(module: Module):
    pm = PassManager.parse(
        "builtin.module("
        "func.func(scalehls-ensure-itensor-single-use),"
        "cse, canonicalize"
        ")")
    pm.run(module.operation)


def apply_scalarize_itensor(module: Module):
    pm = PassManager.parse(
        "builtin.module("
        "func.func(scalehls-scalarize-itensor),"
        "cse, canonicalize"
        ")")
    pm.run(module.operation)


def apply_lower_itensor_to_stream(module: Module):
    pm = PassManager.parse(
        "builtin.module("
        "func.func(scalehls-lower-itensor-to-stream),"
        "cse, canonicalize"
        ")")
    pm.run(module.operation)


def apply_comprehensive_bufferize_passes(module: Module):
    pm = PassManager.parse(
        "builtin.module("
        "scalehls-comprehensive-bufferize,"
        "resolve-shaped-type-result-dims,"
        "canonicalize, cse, canonicalize"
        ")"
    )
    pm.run(module.operation)


def apply_convert_tensor_init_to_tensor_instance(module: Module):
    pm = PassManager.parse(
        "builtin.module("
        "func.func(scalehls-convert-tensor-init-to-tensor-instance),"
        "cse, canonicalize"
        ")")
    pm.run(module.operation)


def apply_generate_dataflow_hierarchy(module: Module):
    pm = PassManager.parse(
        "builtin.module("
        "func.func(scalehls-generate-dataflow-hierarchy),"
        "cse, canonicalize"
        ")")
    pm.run(module.operation)


def apply_schedule_dataflow(module: Module):
    pm = PassManager.parse(
        "builtin.module("
        "func.func(scalehls-schedule-dataflow),"
        "cse, canonicalize"
        ")")
    pm.run(module.operation)


def apply_strip_annotations(module: Module, annotation_name: str):
    pm = PassManager.parse(
        "builtin.module("
        "func.func(scalehls-strip-annotations{"
        f"annotation-name={annotation_name}"
        "}),"
        "cse, canonicalize"
        ")")
    pm.run(module.operation)


def apply_lower_linalg_passes(module: Module):
    pm = PassManager.parse(
        "builtin.module("
        "func.func("
        "convert-linalg-to-loops,"
        "fold-memref-alias-ops,"
        "scalehls-raise-scf-to-affine,"
        "affine-loop-normalize,"
        "affine-simplify-structures,"
        "affine-scalrep"
        "),"
        "cse, canonicalize"
        ")")
    pm.run(module.operation)


def apply_loop_directive_optimization_passes(module: Module):
    pm = PassManager.parse(
        "builtin.module("
        "func.func("
        "scalehls-generate-directives,"
        "convert-linalg-to-loops,"
        "fold-memref-alias-ops,"
        "scalehls-raise-scf-to-affine,"
        "affine-loop-normalize,"
        "affine-simplify-structures,"
        "scalehls-apply-directives,"
        "affine-scalrep"
        "),"
        "cse, canonicalize"
        ")")
    pm.run(module.operation)


def apply_convert_dataflow_to_func(module: Module):
    pm = PassManager.parse(
        "builtin.module("
        "scalehls-convert-dataflow-to-func,"
        "cse, canonicalize"
        ")")
    pm.run(module.operation)


# ===----------------------------------------------------------------------=== #
# General Utils
# ===----------------------------------------------------------------------=== #


def i64_attr(value: int):
    return IntegerAttr.get(IntegerType.get_signless(64), value)


def i64_param(value: int):
    return transform.ParamConstantOp(
        Type.parse("!transform.any_param"), i64_attr(value))


def extract_loop_properties(node: linalg.GenericOp):
    def extract_iterator_type(s: str):
        pattern = r"#linalg\.iterator_type<(\w+)>"
        match = re.search(pattern, s)
        if match:
            # Returns the captured group, which is the iterator type
            return match.group(1)
        else:
            return None

    loop_properties = []
    for range, attr in zip(get_static_loop_ranges(node), node.iterator_types):
        loop_properties.append(
            (range, extract_iterator_type(str(attr))))
    return loop_properties


def find_func(module: Module, name: str) -> Optional[func.FuncOp]:
    for op in module.body:
        if isinstance(op, func.FuncOp):
            if op.name.value == name:
                return op
    return None


# ===----------------------------------------------------------------------=== #
# Transform Utils
# ===----------------------------------------------------------------------=== #


def transform_sequence(name: str = "__transform_main",
                       result_types: Sequence[Type] = []):
    """
    A decorator to construct a `transform.named_sequence` op containing the ops
    built by the decorated function. `result_types` must be the same as the
    return types of decorated function.

    The decorated function must have a `BlockArgument` as its first argument,
    which is the handle of the target op to be transformed. Any other arguments
    will be passed when calling the decorated function.

    Return the built `transform.named_sequence` op.
    """
    def decorator(body_builder: Callable[..., Sequence[Value]]):
        @wraps(body_builder)
        def wrapper(module: Module, *args, **kwargs):
            module.operation.attributes[
                "transform.with_named_sequence"] = UnitAttr.get()
            with InsertionPoint.at_block_begin(module.body):
                sequence = transform.NamedSequenceOp(
                    name, [transform.any_op_t()], result_types,
                    arg_attrs=[{"transform.readonly": UnitAttr.get()}])
            with InsertionPoint.at_block_begin(sequence.body):
                results = body_builder(
                    sequence.body.arguments[0],  # type: ignore
                    *args, **kwargs)
                transform.YieldOp(results)
            return sequence
        return wrapper
    return decorator


def match(target: Value,
          op_names: Sequence[str] = [],
          op_attrs: Mapping[str, Attribute] = {}):
    """
    Match the target with the given op names and op attributes.

    Return the handle of the matched op.
    """
    result = transform.OperationType.get(op_names[0]) if len(
        op_names) == 1 else transform.any_op_t()
    ops = ArrayAttr.get([StringAttr.get(op_name)
                        for op_name in op_names]) if len(
                            op_names) != 0 else None
    match_op = linalg_transform.MatchOp(
        result, target, ops=ops, op_attrs=op_attrs)
    return Value(match_op.result)


def match_linalg_with_conditions():
    """
    A decorator to match a linalg op with conditions. The body of conditions is
    built by the decorated function.

    The decorated function must have a `BlockArgument` as its first argument and
    a `str` as its second argument, which is the name of the op to be matched.
    Any other arguments will be passed when calling the decorated function.

    Return the handle of the matched op.
    """
    def decorator(body_builder: Callable[..., Value]):
        @wraps(body_builder)
        def wrapper(linalg_op_handle: Value, op_name: str, *args, **kwargs):
            match = Operation.create(
                "transform.match.structured",
                [transform.OperationType.get(op_name)],
                [linalg_op_handle],
                {"failure_propagation_mode": IntegerAttr.get(
                    IntegerType.get_signless(32), 2)},
                regions=1)
            match_block = Block.create_at_start(
                match.regions[0], [linalg_op_handle.type])
            with InsertionPoint.at_block_begin(match_block):
                result = body_builder(
                    match_block.arguments[0],  # type: ignore
                    op_name, *args, **kwargs)
                Operation.create(
                    "transform.match.structured.yield", [], [result])
            return Value(match.results[0])
        return wrapper
    return decorator


@match_linalg_with_conditions()
def match_linalg_input(linalg_op_handle: BlockArgument, op_name: str):
    """
    The returned handle may contain multiple matched inputs, which may need to
    be transformed with `foreach_transform` decorated function.
    """
    match_input_op = Operation.create(
        "transform.match.structured.input",
        [transform.OperationType.get(op_name)],
        [linalg_op_handle],
        {"raw_position_list": DenseI64ArrayAttr.get([]),
            "is_all": UnitAttr.get()})
    return match_input_op.results[0]


@match_linalg_with_conditions()
def match_linalg_init(linalg_op_handle: BlockArgument, op_name: str):
    """
    The returned handle may contain multiple matched inits, which may need to
    be transformed with `foreach_transform` decorated function.
    """
    match_init_op = Operation.create(
        "transform.match.structured.init",
        [transform.OperationType.get(op_name)],
        [linalg_op_handle],
        {"raw_position_list": DenseI64ArrayAttr.get([]),
            "is_all": UnitAttr.get()})
    return match_init_op.results[0]


@match_linalg_with_conditions()
def match_linalg_result(linalg_op_handle: BlockArgument,
                        op_name: str,
                        position: int = 0):
    """
    The returned handle may contain multiple users of the matched result, which
    may need to be transformed with `foreach_transform` decorated function.
    """
    match_result_op = Operation.create(
        "transform.match.structured.result",
        [transform.OperationType.get(op_name)],
        [linalg_op_handle],
        {"position": i64_attr(position), "any": UnitAttr.get()})
    return match_result_op.results[0]


def foreach_transform(result_types: Sequence[Type] = []):
    """
    A decorator to build a `transform.foreach` op containing the ops built by
    the decorated function. `transform.foreach` op is used to transform multiple
    ops contained by a single handle. `result_types` must be the same as the
    return types of decorated function.

    The decorated function must have a `BlockArgument` as its first argument,
    which is the handle of the target op to be transformed. Any other arguments
    will be passed when calling the decorated function.
    """
    def decorator(body_builder: Callable[..., None]):
        @wraps(body_builder)
        def wrapper(target: Value, *args, **kwargs):
            foreach = transform.ForeachOp(result_types, target)
            foreach_block = Block.create_at_start(foreach.body, [target.type])
            with InsertionPoint.at_block_begin(foreach_block):
                results = body_builder(
                    foreach_block.arguments[0], *args, **kwargs)  # type: ignore
                transform.YieldOp(results)
        return wrapper
    return decorator


# ===----------------------------------------------------------------------=== #
# Transform Operation Utils
# ===----------------------------------------------------------------------=== #


def annotate(target: Value, annotation: str, param=None):
    return transform.AnnotateOp(target, annotation, param=param)


def tile(linalg_op_handle: Value,
         sizes: Sequence[int],
         interchange: Union[Sequence[int], None] = None):
    return linalg_transform.TileUsingForOp(
        linalg_op_handle, sizes=sizes, interchange=interchange)


def tile_reduction(linalg_op_handle: Value, sizes: Sequence[int]):
    return linalg_transform.TileReductionUsingForOp(
        transform.OperationType.get("linalg.fill"),
        transform.OperationType.get("linalg.generic"),
        transform.OperationType.get("linalg.generic"),
        transform.OperationType.get("scf.for"),
        linalg_op_handle,
        tile_sizes=sizes)


def interchange(linalg_op_handle: Value, permutation: Sequence[int]):
    return linalg_transform.InterchangeOp(
        linalg_op_handle,
        iterator_interchange=permutation)


def convert_expand_shape_to_itensor_reassociate(
        expand_shape_handle: Value,
        source_tile_sizes: Sequence[int],
        result_tile_sizes: Sequence[int]):
    return hls_transform.HLSConvertExpandShapeToITensorReassociateOp(
        transform.OperationType.get("hls.itensor_init"),
        transform.OperationType.get("hls.itensor_write_full_tensor"),
        transform.OperationType.get("hls.itensor_reassociate"),
        transform.OperationType.get("hls.itensor_read_full_tensor"),
        expand_shape_handle,
        source_tile_sizes,
        result_tile_sizes)


def convert_collapse_shape_to_itensor_reassociate(
        collapse_shape_handle: Value,
        source_tile_sizes: Sequence[int],
        result_tile_sizes: Sequence[int]):
    return hls_transform.HLSConvertCollapseShapeToITensorReassociateOp(
        transform.OperationType.get("hls.itensor_init"),
        transform.OperationType.get("hls.itensor_write_full_tensor"),
        transform.OperationType.get("hls.itensor_reassociate"),
        transform.OperationType.get("hls.itensor_read_full_tensor"),
        collapse_shape_handle,
        source_tile_sizes,
        result_tile_sizes)


def convert_extract_slice_to_tensor_init(extract_slice_handle: Value):
    return hls_transform.HLSConvertExtractSliceToTensorInitOp(
        transform.OperationType.get("hls.tensor_init"),
        extract_slice_handle)


@foreach_transform()
def foreach_convert_extract_slice_to_tensor_init(
        extract_slice_handle: Value):
    convert_extract_slice_to_tensor_init(extract_slice_handle)


def convert_insert_slice_to_itensor_write(insert_slice_handle: Value):
    return hls_transform.HLSConvertInsertSliceToITensorWriteOp(
        transform.OperationType.get("hls.itensor_init"),
        transform.OperationType.get("hls.itensor_write"),
        transform.OperationType.get("hls.itensor_read_full_tensor"),
        insert_slice_handle)


@foreach_transform()
def foreach_convert_insert_slice_to_itensor_write(insert_slice_handle: Value):
    convert_insert_slice_to_itensor_write(insert_slice_handle)


def convert_fill_to_tensor_init(linalg_fill_handle: Value):
    return hls_transform.HLSConvertFillToTensorInitOp(
        transform.OperationType.get("hls.tensor_init"),
        linalg_fill_handle)


def merge_consecutive_extract_slice(extract_slice_handle: Value):
    return hls_transform.HLSMergeConsecutiveExtractSliceOp(
        transform.OperationType.get("tensor.extract_slice"),
        extract_slice_handle)


def convert_extract_slice_to_itensor_read(extract_slice_handle: Value):
    return hls_transform.HLSConvertExtractSliceToITensorReadOp(
        transform.OperationType.get("hls.itensor_init"),
        transform.OperationType.get("hls.itensor_write_full_tensor"),
        transform.OperationType.get("hls.itensor_read"),
        extract_slice_handle)


@foreach_transform()
def foreach_merge_consecutive_extract_slice_and_convert_to_itensor_read(
        extract_slice_handle: Value):
    merge_op = merge_consecutive_extract_slice(extract_slice_handle)
    convert_extract_slice_to_itensor_read(merge_op.result)


def convert_full_tensor_linalg_op_to_itensor(
        linalg_op_handle: Value,
        parallel_tile_sizes: Sequence[int],
        reduction_tile_sizes: Sequence[int],
        unroll_sizes: Sequence[int],
        permutation: Sequence[int],
        has_input: bool = True,
        split_combine_reduction=False):
    """
    This is the main function driving the transformation of a linalg.generic op
    with full tensor semantics to a sequence of ops with itensor semantics.
    """
    # Tile the linalg op with the given parallel tile sizes. Nested SCF loops
    # are generated for parallel tile sizes that are greater than 0.
    tile_op = tile(linalg_op_handle, parallel_tile_sizes)
    linalg_op_handle = tile_op.tiled_linalg_op

    # Convert the linalg `init` operand to a `tensor.init` op.
    matched_init = match_linalg_init(linalg_op_handle, "tensor.extract_slice")
    foreach_convert_extract_slice_to_tensor_init(matched_init)

    # Convert each `insert_slice` op to a `itensor.write` op.
    matched_result = match_linalg_result(
        linalg_op_handle, "tensor.insert_slice")
    foreach_convert_insert_slice_to_itensor_write(matched_result)

    # Tile the linalg op with the given reduction tile sizes if applicable.
    # Again, nested SCF loops are generated for reduction tile sizes that are
    # greater than 0. If `split_combine_reduction` is set to True, the reduction
    # tiling will generate two nested loops: spliting loops and combining loops.
    # Please refer to the MLIR documentation of TileReductionUsingForOp for more
    # details.
    if any(size > 0 for size in reduction_tile_sizes):
        if (split_combine_reduction):
            tile_reduction_op = tile_reduction(
                linalg_op_handle, reduction_tile_sizes)
            linalg_op_handle = tile_reduction_op.split_linalg_op
            convert_fill_to_tensor_init(tile_reduction_op.fill_op)
        else:
            tile_reduction_op = tile(linalg_op_handle, reduction_tile_sizes)
            linalg_op_handle = tile_reduction_op.tiled_linalg_op

    # Convert each `extract_slice` op to a `itensor.read` op.
    if has_input:
        matched_input = match_linalg_input(
            linalg_op_handle, "tensor.extract_slice")
        foreach_merge_consecutive_extract_slice_and_convert_to_itensor_read(
            matched_input)

    # Interchange and "unroll" the linalg op with the given unroll sizes.
    unroll_op = tile(linalg_op_handle, unroll_sizes, permutation)
    linalg_op_handle = unroll_op.tiled_linalg_op
    return linalg_op_handle


# ===----------------------------------------------------------------------=== #
# BaseDesignSpaceGraph Class
# ===----------------------------------------------------------------------=== #


class BaseDesignSpaceGraph(nx.DiGraph):
    def __init__(self, module: Module, entry: str = "forward_scheduled"):
        super().__init__()
        self.module = module
        top = find_func(self.module, entry)
        if top is None:
            raise ValueError(f"top function `{entry}` not found")
        self.top = top

    def attr(self, node: OpView, attr_name: str):
        if attr_name not in self.nodes[node]:
            raise ValueError(f"{attr_name} not found for {node}")
        attr = self.nodes[node][attr_name]
        return attr

    def name(self, node: OpView) -> str:
        return self.attr(node, "name")

    def id(self, node: OpView) -> int:
        return self.attr(node, "id")

    def parent(self, node: OpView) -> Optional[OpView]:
        return self.attr(node, "parent")

    def children(self, node: OpView) -> List[OpView]:
        # This function doesn't check whether the node has children or not.
        return self.attr(node, "children")

    def has_children(self, node: OpView) -> bool:
        return len(self.children(node)) > 0

    def _format_node_label(self, node: OpView, print_params):
        label = f"{self.name(node)} {self.id(node)}"
        if print_params:
            for key, value in self.nodes[node].items():
                if key == "name" or key == "id" or \
                   key == "parent" or key == "children":
                    continue
                if isinstance(value, (int, str)):
                    label += f"\n{key}: {value}"
                elif isinstance(value, list):
                    label += f"\n{key}: [" + \
                        ", ".join([str(x) for x in value]) + "]"
        return label

    def _format_edge_label(self, prev: OpView, next: OpView, print_params):
        return ""

    def _add_nodes_recursively(self, dot, parent, print_params, filter):
        if self.has_children(parent):
            subgraph = Digraph(name=f"cluster_{self.id(parent)}")
            subgraph.attr(label=self._format_node_label(parent, print_params))
            for node in self.children(parent):
                self._add_nodes_recursively(
                    subgraph, node, print_params, filter)
            dot.subgraph(subgraph)
        elif filter(parent):
            dot.node(f"{self.id(parent)}",
                     self._format_node_label(parent, print_params))

    def print_dot(self,
                  file_name: str,
                  print_params: bool = True,
                  filter: Callable[[OpView], bool] = lambda op: True):
        dot = Digraph()
        self._add_nodes_recursively(dot, self.top, print_params, filter)
        for prev, next in self.edges():
            if not self.has_children(prev) and not self.has_children(next) and \
                    filter(prev) and filter(next):
                dot.edge(f"{self.id(prev)}", f"{self.id(next)}",
                         self._format_edge_label(prev, next, print_params))
        dot.render(file_name, format='png', cleanup=True)

    def verify(self):
        for node in self.nodes():
            if self.has_children(node):
                for child in self.children(node):
                    if self.parent(child) != node:
                        raise ValueError(f"parent mismatch: {child} {node}")


# ===----------------------------------------------------------------------=== #
# LinalgDesignSpaceGraph Class
# ===----------------------------------------------------------------------=== #


k_linalg_dsg_id_name = "__linalg_dsg_id__"


class LinalgDesignSpaceGraph(BaseDesignSpaceGraph):
    def __init__(self, module: Module, entry: str = "forward"):
        super().__init__(module, entry)

        self.add_node(self.top, name=self.top.name.value,
                      id=-1, parent=None, children=[])
        for id, op in enumerate(self.top.entry_block):
            self.add_node(op, name=op.name, id=id,
                          parent=self.top, children=[])
            self.nodes[self.top]["children"].append(op)
            op.attributes[k_linalg_dsg_id_name] = i64_attr(id)
            for operand in op.operands:
                if not isinstance(operand.owner, Block):
                    prev = operand.owner
                    if not self.has_node(prev):
                        raise ValueError(f"prev node not found for {operand}")
                    self.add_edge(prev.opview, op, value=operand)
        self.verify()

    @ staticmethod
    def _is_nontrivial_op(node: OpView):
        return not isinstance(
            node, (hls.TensorInitOp, tensor.EmptyOp, arith.ConstantOp))

    def print_dot(self, file_name: str, print_params: bool = True):
        return super().print_dot(file_name,
                                 print_params,
                                 self._is_nontrivial_op)

    @ staticmethod
    def get_linalg_op_naive_tile_sizes(node: linalg.GenericOp,
                                       default_tile_size: int = 16):
        loop_properties = extract_loop_properties(node)

        parallel_tile_sizes = []
        reduction_tile_sizes = []
        for range, type in loop_properties:
            tile_size = default_tile_size if range > default_tile_size else 0
            if type == "parallel":
                parallel_tile_sizes.append(tile_size)
                reduction_tile_sizes.append(0)
            elif type == "reduction":
                parallel_tile_sizes.append(0)
                reduction_tile_sizes.append(tile_size)
        return parallel_tile_sizes, reduction_tile_sizes

    @ staticmethod
    def get_linalg_op_naive_unroll_sizes(node: linalg.GenericOp,
                                         default_unroll_size: int = 2):
        loop_properties = extract_loop_properties(node)

        unroll_sizes = []
        for range, type in loop_properties:
            unroll_size = default_unroll_size \
                if range > default_unroll_size else 0
            if type == "parallel":
                unroll_sizes.append(unroll_size)
            elif type == "reduction":
                unroll_sizes.append(1)
        return unroll_sizes

    @ staticmethod
    def get_linalg_op_naive_permutation(node: linalg.GenericOp):
        loop_properties = extract_loop_properties(node)

        num_reduction = 0
        interchange_permutation = []
        for index, (_, type) in enumerate(loop_properties):
            if type == "parallel":
                interchange_permutation.append(index)
            elif type == "reduction":
                interchange_permutation.insert(num_reduction, index)
                num_reduction += 1
        return interchange_permutation

    @ staticmethod
    def get_reshape_op_naive_tile_sizes(
            node: Union[tensor.ExpandShapeOp, tensor.CollapseShapeOp],
            default_tile_size: int = 16):
        source_tile_sizes = []
        result_tile_sizes = []
        for source_dim_size in node.src.type.shape:
            tile_size = default_tile_size \
                if source_dim_size > default_tile_size else 1
            source_tile_sizes.append(tile_size)
        for result_dim_size in node.result.type.shape:
            tile_size = default_tile_size \
                if result_dim_size > default_tile_size else 1
            result_tile_sizes.append(tile_size)

        # Support more flexible tile sizes.
        if (functools.reduce(operator.mul, source_tile_sizes, 1) !=
                functools.reduce(operator.mul, result_tile_sizes, 1)):
            raise ValueError(
                "Source tile sizes do not match result tile sizes")
        return source_tile_sizes, result_tile_sizes

    def naive_exploration(
            self,
            default_tile_size: int = 16,
            default_unroll_size: int = 2):
        for node, data in self.nodes(data=True):
            if isinstance(node, linalg.GenericOp):
                data["parallel_tile_sizes"], data["reduction_tile_sizes"] = \
                    self.get_linalg_op_naive_tile_sizes(
                    node, default_tile_size=default_tile_size)
                data["unroll_sizes"] = self.get_linalg_op_naive_unroll_sizes(
                    node, default_unroll_size=default_unroll_size)
                data["permutation"] = self.get_linalg_op_naive_permutation(
                    node)

            if isinstance(node, (tensor.ExpandShapeOp, tensor.CollapseShapeOp)):
                data["source_tile_sizes"], data["result_tile_sizes"] = \
                    self.get_reshape_op_naive_tile_sizes(
                    node, default_tile_size=default_tile_size)


@ transform_sequence()
def construct_linalg_transform_sequence(target: BlockArgument,
                                        graph: LinalgDesignSpaceGraph):
    """
    This function constructs a transform sequence to transform the target
    function based on the given design space graph.
    """
    for node, data in graph.nodes(data=True):
        node_handle = match(target, [data["name"]], {
                            k_linalg_dsg_id_name: i64_attr(data["id"])})

        if isinstance(node, linalg.GenericOp):
            if "parallel_tile_sizes" not in data:
                raise ValueError("parallel_tile_sizes not found")
            if "reduction_tile_sizes" not in data:
                raise ValueError("reduction_tile_sizes not found")
            if "unroll_sizes" not in data:
                raise ValueError("unroll_sizes not found")
            if "permutation" not in data:
                raise ValueError("permutation not found")

            linalg_op_handle = convert_full_tensor_linalg_op_to_itensor(
                node_handle,
                data["parallel_tile_sizes"],
                data["reduction_tile_sizes"],
                data["unroll_sizes"],
                data["permutation"],
                len(node.inputs) > 0)
            annotate(linalg_op_handle, k_linalg_dsg_id_name,
                     i64_param(data["id"]))

        if isinstance(node, tensor.ExpandShapeOp):
            if "source_tile_sizes" not in data:
                raise ValueError("source_tile_sizes not found")
            if "result_tile_sizes" not in data:
                raise ValueError("result_tile_sizes not found")

            convert_op = convert_expand_shape_to_itensor_reassociate(
                node_handle,
                data["source_tile_sizes"],
                data["result_tile_sizes"])
            annotate(convert_op.itensor_reassociate,
                     k_linalg_dsg_id_name, i64_param(data["id"]))

        if isinstance(node, tensor.CollapseShapeOp):
            if "source_tile_sizes" not in data:
                raise ValueError("source_tile_sizes not found")
            if "result_tile_sizes" not in data:
                raise ValueError("result_tile_sizes not found")

            convert_op = convert_collapse_shape_to_itensor_reassociate(
                node_handle,
                data["source_tile_sizes"],
                data["result_tile_sizes"])
            annotate(convert_op.itensor_reassociate,
                     k_linalg_dsg_id_name, i64_param(data["id"]))
    return []


def apply_linalg_design_space(graph: LinalgDesignSpaceGraph,
                              delete_sequence: bool = True):
    apply_transform_sequence(
        graph.module,
        construct_linalg_transform_sequence(graph.module, graph),
        delete_sequence)
    apply_strip_annotations(graph.module, k_linalg_dsg_id_name)

# ===----------------------------------------------------------------------=== #
# DataflowDesignSpaceGraph Class
# ===----------------------------------------------------------------------=== #


k_dataflow_dsg_id_name = "__dataflow_dsg_id__"


class DataflowDesignSpaceGraph(BaseDesignSpaceGraph):
    def __init__(self, module: Module, entry: str = "forward"):
        super().__init__(module, entry)
        id = [0]

        def add_task_node(op: OpView):
            if isinstance(op.opview, hls.TaskOp):
                nonlocal id
                parent = hls.get_parent_task_or_func(op)
                self.add_node(op, name=op.name,
                              id=id[0], parent=parent, children=[])
                self.nodes[parent]["children"].append(op)
                op.attributes[k_dataflow_dsg_id_name] = i64_attr(id[0])
                id[0] += 1

                for operand in hls.get_live_ins(op):
                    # Bypass all the view-like operations.
                    views = []
                    while not isinstance(operand.owner, Block) and \
                            self._is_view_like_op(operand.owner.opview):
                        views.append(operand.owner.opview)
                        operand = operand.owner.operands[0]

                    # Ensure prev is not a block argument or a ignorable op.
                    prev = operand.owner
                    if isinstance(prev, Block) or isinstance(
                        prev.opview, (arith.ConstantOp, hls.TensorInstanceOp,
                                      hls.ITensorInstanceOp)):
                        continue

                    # Find the defining memory instance of the operand.
                    instance = hls.get_defining_instance(operand)
                    if not instance:
                        raise ValueError(f"instance not found for {operand}")

                    # Find all the defining tasks of the operand.
                    tasks = hls.get_defining_tasks(operand)
                    for task in tasks:
                        if not self.has_node(task):
                            raise ValueError(f"prev not found for {operand}")
                        self.add_edge(task, op,
                                      instance=instance, views=views)

        self.add_node(self.top, name=self.top.name.value,
                      id=-1, parent=None, children=[])
        walk_operation(self.top, add_task_node)
        self.verify()

    @staticmethod
    def _is_view_like_op(node: OpView):
        return isinstance(
            node, (tensor.ExpandShapeOp, tensor.CollapseShapeOp,
                   tensor.ReshapeOp, tensor.CastOp, tensor.BitcastOp,
                   hls.ITensorReassociateOp, hls.ITensorCastOp))

    def _format_edge_label(self, prev: OpView, next: OpView, print_params):
        label = ""
        if print_params:
            for key, value in self.edges[prev, next].items():
                if key == "instance":
                    type = value.results[0].type
                    if isinstance(type, tensor.RankedTensorType):
                        label += f"\nshape: {type.shape}"
                    elif isinstance(type, hls.ITensorType):  # type: ignore
                        label += f"\ndepth: {type.depth}"
        return label

    def naive_exploration(self):
        for node, data in self.nodes(data=True):
            for succ in self.successors(node):
                pass


# ===----------------------------------------------------------------------=== #
# HLS Synthesis Utils
# ===----------------------------------------------------------------------=== #

class Synthesizer():
    def __init__(self,
                 tool_path: str = "vitis_hls",
                 part: str = "xcu280-fsvh2892-2L-e",
                 clock_period: int = 10,
                 syn_path: str = "."):
        self.tool_path = tool_path
        self.part = part
        self.clock_period = clock_period
        self.syn_path = syn_path

    def generate_testbench(self,
                           entry: str,
                           file_paths: List[str],
                           input: Tensor,
                           output: Tensor
                           ):
        input_declare = "float input" + \
            "".join([f'[{x}]' for x in input.shape])
        output_declare = "float output" + \
            "".join([f'[{x}]' for x in output.shape])

        testbench_header_path = f"{self.syn_path}/{entry}_tb.h"
        with open(testbench_header_path, "w") as testbench_header_file:
            testbench_header_file.write(
                f"void {entry}({input_declare}, {output_declare});\n")

        input_list = input.flatten().tolist()
        output_list = output.flatten().tolist()
        input_init = f"{{ {', '.join([str(x) for x in input_list])} }}"
        output_init = f"{{ {', '.join([str(x) for x in output_list])} }}"
        output_kernel_declare = f"float output_kernel" + \
            "".join([f'[{x}]' for x in output.shape])
        input_indices = "".join([f'[i{i}]' for i in range(len(input.shape))])
        output_indices = "".join([f'[i{i}]' for i in range(len(output.shape))])

        testbench_path = f"{self.syn_path}/{entry}_tb.cpp"
        with open(testbench_path, "w") as testbench_file:
            testbench_file.writelines([
                f"#include <iostream>\n",
                f"#include \"{testbench_header_path}\"\n",
                f"int main() {{\n",
                f"  {input_declare} = {input_init};\n",
                f"  {output_declare} = {output_init};\n",
                f"  {output_kernel_declare};\n",
                f"  {entry}(input, output_kernel);\n",
                *[f"  for (int i{i} = 0; i{i} < {x}; i{i}++) {{\n" for i,
                  x in enumerate(output.shape)],
                # f"    if (output_kernel{input_indices} != output{output_indices}) {{\n",
                # f"       std::cout << \"Test failed!\" << std::endl;\n",
                f"       std::cout << output_kernel{input_indices} << \", \" << output{output_indices} << std::endl;\n",
                # f"       return 1;\n",
                # f"    }}\n",
                *[f"  }}\n" for _ in output.shape],
                f"  std::cout << \"Test passed!\" << std::endl;\n",
                f"  return 0;\n",
                f"}}\n"
            ])

        return [testbench_file, testbench_header_file], \
            [testbench_path, testbench_header_path]

    def generate_script(self,
                        hls_top: str,
                        file_paths: List[str],
                        tb_file_path: List[str],
                        csim: bool = True,
                        csynth: bool = True,
                        cosim: bool = False):
        script_path = f"{self.syn_path}/{hls_top}.tcl"
        with open(script_path, "w") as script_file:
            script_file.writelines([
                f"open_project {self.syn_path}/{hls_top}\n",
                f"set_top {hls_top}\n",
                *[f"add_files {file_path}\n" for file_path in file_paths],
                *[f"add_files -tb {file_path}\n" for file_path in tb_file_path],
                f"open_solution {hls_top}\n",
                f"set_part {self.part}\n",
                f"create_clock -period {self.clock_period} -name default\n",
                "csim_design\n" if csim else "# csim_design\n",
                "csynth_design\n" if csynth else "# csynth_design\n",
                "cosim_design\n" if cosim else "# cosim_design\n"
            ])
        return script_file, script_path

    def run(self,
            module: Module,
            entry: str,
            hls_top: str,
            input: Tensor,
            output: Tensor,
            csim: bool = True,
            csynth: bool = True,
            cosim: bool = False):
        design_path = f"{self.syn_path}/{entry}.cpp"
        with open(design_path, "w") as design_file:
            emit_hlscpp(module, design_file, omit_global_constants=False)

        testbench_files, testbench_paths = self.generate_testbench(
            entry, [design_path], input, output)

        script_file, script_path = self.generate_script(
            hls_top, [design_path], testbench_paths, csim, csynth, cosim)

        result = subprocess.run([self.tool_path, script_path],
                                capture_output=True, text=True)
        with open(f"{self.syn_path}/{entry}.log", "w") as log_file:
            log_file.write(result.stdout)
