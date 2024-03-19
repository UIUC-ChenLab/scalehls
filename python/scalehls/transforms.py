# ===----------------------------------------------------------------------=== #
#
# Copyright 2020-2021 The ScaleHLS Authors.
#
# ===----------------------------------------------------------------------=== #

import io
from ._mlir_libs._scalehls import *
import networkx as nx
from graphviz import Digraph
import re
import functools
import operator
from .dialects import hls, linalg, tensor, func, hls_transform, transform, arith
from .ir import IntegerType, IntegerAttr, StringAttr, ArrayAttr, Value, InsertionPoint, UnitAttr, DenseI64ArrayAttr, Block, Operation, Type, Location, Module, Context, BlockArgument, Attribute
from .dialects.transform import structured as linalg_transform
from .dialects.transform import tensor as tensor_transform
from .passmanager import PassManager
from typing import Sequence, Optional, Union, Callable, Mapping
from functools import wraps

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


# ===----------------------------------------------------------------------=== #
# Transform Utils
# ===----------------------------------------------------------------------=== #


def transform_sequence(
        name: str = "__transform_main",
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
def match_linalg_result(
        linalg_op_handle: BlockArgument,
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
# Transform Utils
# ===----------------------------------------------------------------------=== #


def annotate(target: Value, annotation: str, param=None):
    return transform.AnnotateOp(target, annotation, param=param)


def tile(linalg_op_handle: Value, sizes: Sequence[int]):
    return linalg_transform.TileUsingForOp(linalg_op_handle, sizes=sizes)


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
        transform.OperationType.get("hls.itensor_write_full_tensor"),
        transform.OperationType.get("hls.itensor_read"),
        extract_slice_handle)


@foreach_transform()
def foreach_merge_consecutive_extract_slice_and_convert_to_itensor_read(
        extract_slice_handle: Value):
    merge_op = merge_consecutive_extract_slice(extract_slice_handle)
    convert_extract_slice_to_itensor_read(merge_op.result)


def convert_full_tensor_linalg_generic_to_itensor(
        target: Value,
        parallel_tile_sizes: Sequence[int],
        reduction_tile_sizes: Sequence[int],
        permutation: Sequence[int],
        has_input: bool = True,
        combine_split_reduction=False):
    tile_op = tile(target, parallel_tile_sizes)
    target = tile_op.tiled_linalg_op

    matched_init = match_linalg_init(target, "tensor.extract_slice")
    foreach_convert_extract_slice_to_tensor_init(matched_init)

    matched_result = match_linalg_result(target, "tensor.insert_slice")
    foreach_convert_insert_slice_to_itensor_write(matched_result)

    if any(size > 0 for size in reduction_tile_sizes):
        if (combine_split_reduction):
            tile_reduction_op = tile_reduction(target, reduction_tile_sizes)
            target = tile_reduction_op.split_linalg_op
            convert_fill_to_tensor_init(tile_reduction_op.fill_op)
        else:
            tile_reduction_op = tile(target, reduction_tile_sizes)
            target = tile_reduction_op.tiled_linalg_op

    if has_input:
        matched_input = match_linalg_input(target, "tensor.extract_slice")
        foreach_merge_consecutive_extract_slice_and_convert_to_itensor_read(
            matched_input)

    interchange_op = interchange(target, permutation)
    target = interchange_op.transformed
    return target


# ===----------------------------------------------------------------------=== #
# Computation Graph Utils
# ===----------------------------------------------------------------------=== #


def is_nontrivial_node(node: Operation):
    return not isinstance(node, (arith.ConstantOp, hls.TensorInitOp, tensor.EmptyOp))


def construct_graph(module: Module, ):
    def find_func(module: Module, name: str) -> Optional[func.FuncOp]:
        for op in module.body:
            if isinstance(op, func.FuncOp):
                if op.name.value == name:
                    return op
        return None

    g = nx.Graph()
    f = find_func(module, "forward")
    if f is None:
        raise ValueError("forward function not found")

    g.add_node(f, name=f.OPERATION_NAME, id=-1)
    for id, op in enumerate(f.entry_block):
        g.add_node(op, name=op.OPERATION_NAME, id=id)
        op.attributes["id"] = i64_attr(id)
        for operand in op.operands:
            parent = operand.owner.owner if isinstance(
                operand.owner, Block) else operand.owner
            if not g.has_node(parent):
                raise ValueError("parent node not found")
            g.add_edge(parent, op, value=operand)

    return g


def print_graph(g: nx.Graph, name: str):
    dot = Digraph()
    for node, data in g.nodes(data=True):
        if is_nontrivial_node(data["name"]):
            dot.node(data["name"] + str(data["id"]))
    for prev, next, data in g.edges(data=True):
        prev_data = g.nodes[prev]
        next_data = g.nodes[next]
        if is_nontrivial_node(prev) and is_nontrivial_node(next):
            dot.edge(prev_data["name"] + str(prev_data["id"]),
                     next_data["name"] + str(next_data["id"]))

    dot.render(name, format='png', cleanup=True)


# ===----------------------------------------------------------------------=== #
# Design Space Exploration Utils
# ===----------------------------------------------------------------------=== #


def get_generic_op_naive_permutation(node: linalg.GenericOp):
    loop_properties = extract_loop_properties(node)
    numReduction = 0
    interchange_permutation = []
    for index, (_, type) in enumerate(loop_properties):
        if type == "parallel":
            interchange_permutation.append(index)
        elif type == "reduction":
            interchange_permutation.insert(numReduction, index)
            numReduction += 1
    return interchange_permutation


def get_generic_op_naive_tile_sizes(
        node: linalg.GenericOp,
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


def get_reshape_op_naive_tile_sizes(
        node: Union[tensor.ExpandShapeOp, tensor.CollapseShapeOp],
        default_tile_size: int = 16):
    source_tile_sizes = []
    result_tile_sizes = []
    for source_dim_size in node.src.type.shape:
        tile_size = default_tile_size if source_dim_size > default_tile_size else 1
        source_tile_sizes.append(tile_size)
    for result_dim_size in node.result.type.shape:
        tile_size = default_tile_size if result_dim_size > default_tile_size else 1
        result_tile_sizes.append(tile_size)

    # Support more flexible tile sizes.
    if (functools.reduce(operator.mul, source_tile_sizes, 1) !=
            functools.reduce(operator.mul, result_tile_sizes, 1)):
        raise ValueError("Source tile sizes do not match result tile sizes")
    return source_tile_sizes, result_tile_sizes


@transform_sequence()
def construct_design_space_exploration_transform_sequence(
        target: BlockArgument, module_graph: nx.Graph):
    for node, data in module_graph.nodes(data=True):
        node_handle = match(target, [data["name"]], {
            "id":  i64_attr(data["id"])})

        if isinstance(node, linalg.GenericOp):
            permutation = get_generic_op_naive_permutation(node)
            parallel_tile_sizes, reduction_tile_sizes = get_generic_op_naive_tile_sizes(
                node, default_tile_size=16)

            stream_node_handle = convert_full_tensor_linalg_generic_to_itensor(
                node_handle, parallel_tile_sizes, reduction_tile_sizes, permutation, len(node.inputs) > 0)
            annotate(stream_node_handle, "id", i64_param(data["id"]))

        if isinstance(node, tensor.ExpandShapeOp):
            source_tile_sizes, result_tile_sizes = get_reshape_op_naive_tile_sizes(
                node, default_tile_size=16)

            convert_op = convert_expand_shape_to_itensor_reassociate(
                node_handle, source_tile_sizes, result_tile_sizes)
            annotate(convert_op.itensor_reassociate,
                     "id", i64_param(data["id"]))

        if isinstance(node, tensor.CollapseShapeOp):
            source_tile_sizes, result_tile_sizes = get_reshape_op_naive_tile_sizes(
                node, default_tile_size=16)

            convert_op = convert_collapse_shape_to_itensor_reassociate(
                node_handle, source_tile_sizes, result_tile_sizes)
            annotate(convert_op.itensor_reassociate,
                     "id", i64_param(data["id"]))
    return []

# ===----------------------------------------------------------------------=== #
# Transform Passes
# ===----------------------------------------------------------------------=== #


def apply_linalg_transform_passes(module: Module):
    pm = PassManager()
    add_linalg_transform_passes(pm)
    pm.run(module.operation)


def apply_transform_sequence(
        module: Module,
        sequence: transform.NamedSequenceOp):
    pm = PassManager.parse(
        "builtin.module("
        "transform-interpreter{entry-point=" + sequence.sym_name.value + "},"
        "cse, canonicalize)")
    pm.run(module.operation)


def apply_reduce_full_tensor_to_itensor(module: Module):
    pm = PassManager.parse(
        "builtin.module(func.func(scalehls-reduce-full-tensor-to-itensor),"
        "cse, canonicalize)")
    pm.run(module.operation)


def apply_materialize_itensor(module: Module, enable_packing: bool = False):
    enable_packing_str = "true" if enable_packing else "false"
    pm = PassManager.parse(
        "builtin.module(func.func(scalehls-materialize-itensor{"
        "enable-packing=" + enable_packing_str + "}),"
        "cse, canonicalize)")
    pm.run(module.operation)


def apply_scalarize_itensor(module: Module):
    pm = PassManager.parse(
        "builtin.module(func.func(scalehls-scalarize-itensor),"
        "cse, canonicalize)")
    pm.run(module.operation)


def apply_lower_itensor_to_stream(module: Module):
    pm = PassManager.parse(
        "builtin.module(func.func(scalehls-lower-itensor-to-stream),"
        "cse, canonicalize)")
    pm.run(module.operation)


def apply_comprehensive_bufferize_passes(module: Module):
    pm = PassManager()
    add_comprehensive_bufferize_passes(pm)
    pm.run(module.operation)


def apply_schedule_dataflow(module: Module):
    pm = PassManager.parse(
        "builtin.module(func.func(scalehls-schedule-dataflow),"
        "cse, canonicalize)")
    pm.run(module.operation)


def apply_convert_dataflow_to_func_passes(module: Module):
    pm = PassManager()
    add_convert_dataflow_to_func_passes(pm)
    pm.run(module.operation)


def get_module_cpp_str(module: Module):
    buf = io.StringIO()
    emit_hlscpp(module, buf)
    return buf.getvalue()
