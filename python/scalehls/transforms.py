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
from .dialects import hls, linalg, tensor, func, hls_transform, transform
from .ir import IntegerType, IntegerAttr, StringAttr, ArrayAttr, Value, InsertionPoint, UnitAttr, DenseI64ArrayAttr, Block, Operation, Type, Location, Module, Context
from .dialects.transform import structured as linalg_transform
from .dialects.transform import tensor as tensor_transform
from .passmanager import PassManager
from typing import List, Optional, Union


def transform_sequence(module: Module, name: str = "__transform_main"):
    module.operation.attributes[
        "transform.with_named_sequence"] = UnitAttr.get()
    with InsertionPoint.at_block_begin(module.body):
        sequence = transform.NamedSequenceOp(
            name,
            [transform.any_op_t()],
            [],
            arg_attrs=[{"transform.readonly": UnitAttr.get()}])
    with InsertionPoint.at_block_begin(sequence.body):
        transform.YieldOp()
    return sequence, sequence.body.arguments[0]  # type: ignore


def match(target: Value, op_names: List[str] = [], op_attrs={}):
    result = transform.OperationType.get(op_names[0]) if len(
        op_names) == 1 else transform.any_op_t()
    ops = ArrayAttr.get(
        [StringAttr.get(op_name)
         for op_name in op_names]) if len(op_names) != 0 else None
    return linalg_transform.MatchOp(result, target, ops=ops, op_attrs=op_attrs)


def match_container(taget: Value, op_name: str, num_results: int = 1):
    match = Operation.create(
        "transform.match.structured",
        [transform.OperationType.get(op_name)] * num_results,
        [taget],
        {"failure_propagation_mode": IntegerAttr.get(
            IntegerType.get_signless(32), 2)},
        regions=1)
    match_block = Block.create_at_start(match.regions[0], [taget.type])
    return match, match_block


def foreach_containuer(target: Value):
    foreach = transform.ForeachOp([], target)
    foreach_block = Block.create_at_start(
        foreach.body, [target.type])
    return foreach, foreach_block


def match_linalg_operand(linalg_op: Value, operand_name: str, op_name: str):
    """
    "name" could be "input" or "init".
    """
    match_input, match_input_block = match_container(linalg_op, op_name)
    with InsertionPoint.at_block_begin(match_input_block):
        input = Operation.create(
            "transform.match.structured." + operand_name,
            [transform.OperationType.get(op_name)],
            [match_input_block.arguments[0]],  # type: ignore
            {"raw_position_list": DenseI64ArrayAttr.get([]),
             "is_all": UnitAttr.get()})
        Operation.create(
            "transform.match.structured.yield",
            [],
            [input.results[0]])

    _, foreach_input_block = foreach_containuer(
        match_input.results[0])
    input_handle = foreach_input_block.arguments[0]  # type: ignore
    return foreach_input_block, input_handle


def match_linalg_result(linalg_op: Value, op_name: str):
    match_result, match_result_block = match_container(linalg_op, op_name)
    with InsertionPoint.at_block_begin(match_result_block):
        result = Operation.create(
            "transform.match.structured.result",
            [transform.OperationType.get(op_name)],
            [match_result_block.arguments[0]],  # type: ignore
            {"position": i64_attr(0),
             "single": UnitAttr.get()})
        Operation.create(
            "transform.match.structured.yield",
            [],
            [result.results[0]])
    return match_result.results[0]


def interchange(target: Value, permutation: List[int]):
    return linalg_transform.InterchangeOp(
        target,
        iterator_interchange=permutation)


def tile(target: Value, sizes: List[int], has_input: bool = True):
    tile_op = linalg_transform.TileUsingForOp(target, sizes=sizes)
    return tile_op


def tile_reduction(target: Value, sizes: List[int], has_input: bool = True):
    tile_reduction_op = linalg_transform.TileReductionUsingForOp(
        transform.OperationType.get("linalg.fill"),
        transform.OperationType.get("linalg.generic"),
        transform.OperationType.get("linalg.generic"),
        transform.OperationType.get("scf.for"),
        target,
        tile_sizes=sizes)
    return tile_reduction_op


def convert_generic_op_to_stream(target: Value, parallel_tile_sizes: List[int], reduction_tile_sizes: List[int], permutation: List[int], has_input: bool = True, combine_split_reduction=False):
    tile_op = tile(target, parallel_tile_sizes, has_input)
    target = tile_op.tiled_linalg_op

    transform_init_block, match_init = match_linalg_operand(
        tile_op.tiled_linalg_op, "init", "tensor.extract_slice")
    with InsertionPoint.at_block_begin(transform_init_block):
        hls_transform.HLSConvertExtractSliceToTensorInitOp(
            transform.OperationType.get("hls.tensor_init"),
            match_init)
        transform.YieldOp()

    match_result = match_linalg_result(
        tile_op.tiled_linalg_op, "tensor.insert_slice")
    hls_transform.HLSConvertInsertSliceToStreamOp(
        transform.OperationType.get("hls.itensor_init"),
        transform.OperationType.get("hls.itensor_write"),
        transform.OperationType.get("hls.itensor_to_tensor"),
        match_result)

    if any(size > 0 for size in reduction_tile_sizes):
        if (combine_split_reduction):
            tile_reduction_op = tile_reduction(
                target, reduction_tile_sizes, has_input)
            target = tile_reduction_op.split_linalg_op

            hls_transform.HLSConvertFillToTensorInitOp(
                transform.OperationType.get("hls.tensor_init"),
                tile_reduction_op.fill_op)
        else:
            tile_reduction_op = tile(
                target, reduction_tile_sizes, has_input)
            target = tile_reduction_op.tiled_linalg_op

    if has_input:
        transform_input_block, match_input = match_linalg_operand(
            target, "input", "tensor.extract_slice")
        with InsertionPoint.at_block_begin(transform_input_block):
            merge_op = hls_transform.HLSMergeConsecutiveExtractSliceOp(
                transform.OperationType.get("tensor.extract_slice"),
                match_input)
            convert_op = hls_transform.HLSConvertExtractSliceToStreamOp(
                transform.OperationType.get("hls.tensor_to_itensor"),
                transform.OperationType.get("hls.itensor_read"),
                merge_op.result)
            transform.YieldOp()

    interchange_op = interchange(target, permutation)
    target = interchange_op.transformed
    return target


def convert_expand_shape_op_to_stream(target: Value, source_tile_sizes: List[int], result_tile_sizes: List[int]):
    stream_op = hls_transform.HLSConvertExpandShapeToStreamOp(
        transform.OperationType.get("hls.tensor_to_itensor"),
        transform.OperationType.get("hls.itensor_reassociate"),
        transform.OperationType.get("hls.itensor_to_tensor"),
        target,
        source_tile_sizes,
        result_tile_sizes)
    return stream_op.itensor_reassociate


def convert_collapse_shape_op_to_stream(target: Value, source_tile_sizes: List[int], result_tile_sizes: List[int]):
    stream_op = hls_transform.HLSConvertCollapseShapeToStreamOp(
        transform.OperationType.get("hls.tensor_to_itensor"),
        transform.OperationType.get("hls.itensor_reassociate"),
        transform.OperationType.get("hls.itensor_to_tensor"),
        target,
        source_tile_sizes,
        result_tile_sizes)
    return stream_op.itensor_reassociate


# def pack(target: Value, sizes: List[int]):
#     return linalg_transform.PackOp(
#         transform.any_op_t(),
#         target,
#         [],
#         static_packed_sizes=DenseI64ArrayAttr.get(sizes))


# def lower_pack(target: Value):
#     return linalg_transform.LowerPackOp(
#         transform.OperationType.get("tensor.pad"),
#         transform.OperationType.get("tensor.expand_shape"),
#         transform.OperationType.get("linalg.transpose"),
#         target)


# def lower_unpack(target: Value):
#     return linalg_transform.LowerUnPackOp(
#         transform.OperationType.get("tensor.empty"),
#         transform.OperationType.get("linalg.transpose"),
#         transform.OperationType.get("tensor.collapse_shape"),
#         transform.OperationType.get("tensor.extract_slice"),
#         target)


def annotate(target: Value, annotation: str, param=None):
    return transform.AnnotateOp(target, annotation, param=param)


def i64_attr(value: int):
    return IntegerAttr.get(IntegerType.get_signless(64), value)


def i64_param(value: int):
    return transform.ParamConstantOp(
        Type.parse("!transform.any_param"), i64_attr(value))


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
    def should_print(name: str):
        return name != "arith.constant" and name != "hls.tensor_init" and name != "tensor.empty"

    dot = Digraph()
    for node, data in g.nodes(data=True):
        if should_print(data["name"]):
            dot.node(data["name"] + str(data["id"]))
    for prev, next, data in g.edges(data=True):
        prev_data = g.nodes[prev]
        next_data = g.nodes[next]
        if should_print(prev_data["name"]) and should_print(next_data["name"]):
            dot.edge(prev_data["name"] + str(prev_data["id"]),
                     next_data["name"] + str(next_data["id"]))

    dot.render(name, format='png', cleanup=True)


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


def get_generic_op_naive_tile_sizes(node: linalg.GenericOp, default_tile_size: int = 16):
    loop_properties = extract_loop_properties(node)

    parallel_tile_sizes = []
    reduction_tile_sizes = []
    for range, type in loop_properties:
        tile_size = default_tile_size if range > default_tile_size else 0  # 1
        if type == "parallel":
            parallel_tile_sizes.append(tile_size)
            reduction_tile_sizes.append(0)
        elif type == "reduction":
            parallel_tile_sizes.append(0)
            reduction_tile_sizes.append(tile_size)
    return parallel_tile_sizes, reduction_tile_sizes


def get_reshape_op_naive_tile_sizes(node: Union[tensor.ExpandShapeOp, tensor.CollapseShapeOp], default_tile_size: int = 16):
    source_tile_sizes = []
    result_tile_sizes = []
    for source_dim_size in node.src.type.shape:
        tile_size = default_tile_size if source_dim_size > default_tile_size else 1
        source_tile_sizes.append(tile_size)
    for result_dim_size in node.result.type.shape:
        tile_size = default_tile_size if result_dim_size > default_tile_size else 1
        result_tile_sizes.append(tile_size)

    # Support more flexible tile sizes.
    if (functools.reduce(operator.mul, source_tile_sizes, 1) != functools.reduce(operator.mul, result_tile_sizes, 1)):
        raise ValueError("Source tile sizes do not match result tile sizes")
    return source_tile_sizes, result_tile_sizes


def apply_linalg_transform_passes(module: Module):
    pm = PassManager()
    add_linalg_transform_passes(pm)
    pm.run(module.operation)


def construct_tiling_and_streaming_transform_sequence(module: Module, graph: nx.Graph):
    sequence, target = transform_sequence(module)
    with InsertionPoint.at_block_begin(sequence.body):
        for node, data in graph.nodes(data=True):
            node_handle = match(target, [data["name"]], {
                "id":  i64_attr(data["id"])}).result

            if isinstance(node, linalg.GenericOp):
                permutation = get_generic_op_naive_permutation(node)
                parallel_tile_sizes, reduction_tile_sizes = get_generic_op_naive_tile_sizes(
                    node, default_tile_size=16)

                stream_node_handle = convert_generic_op_to_stream(
                    node_handle, parallel_tile_sizes, reduction_tile_sizes, permutation, len(node.inputs) > 0)
                annotate(stream_node_handle, "id", i64_param(data["id"]))

            if isinstance(node, tensor.ExpandShapeOp):
                source_tile_sizes, result_tile_sizes = get_reshape_op_naive_tile_sizes(
                    node, default_tile_size=16)

                stream_node_handle = convert_expand_shape_op_to_stream(
                    node_handle, source_tile_sizes, result_tile_sizes)
                annotate(stream_node_handle, "id", i64_param(data["id"]))

            if isinstance(node, tensor.CollapseShapeOp):
                source_tile_sizes, result_tile_sizes = get_reshape_op_naive_tile_sizes(
                    node, default_tile_size=16)

                stream_node_handle = convert_collapse_shape_op_to_stream(
                    node_handle, source_tile_sizes, result_tile_sizes)
                annotate(stream_node_handle, "id", i64_param(data["id"]))
    return sequence


def apply_transform_sequence(module: Module, sequence: transform.NamedSequenceOp):
    pm = PassManager.parse(
        "builtin.module("
        "transform-interpreter{entry-point=" + sequence.sym_name.value + "},"
        "cse, canonicalize)")
    pm.run(module.operation)


def apply_reduce_tensor_to_stream(module: Module):
    pm = PassManager.parse(
        "builtin.module(func.func(scalehls-reduce-tensor-to-stream), cse, canonicalize)")
    pm.run(module.operation)


def apply_materialize_stream(module: Module, enable_packing: bool = False):
    enable_packing_str = "true" if enable_packing else "false"
    pm = PassManager.parse(
        "builtin.module(func.func(scalehls-materialize-stream{enable-packing=" + enable_packing_str + "}), cse, canonicalize)")
    pm.run(module.operation)


def apply_scalarize_stream(module: Module):
    pm = PassManager.parse(
        "builtin.module(func.func(scalehls-scalarize-stream), cse, canonicalize)")
    pm.run(module.operation)


def apply_comprehensive_bufferize_passes(module: Module):
    pm = PassManager()
    add_comprehensive_bufferize_passes(pm)
    pm.run(module.operation)


def apply_schedule_dataflow(module: Module):
    pm = PassManager.parse(
        "builtin.module(func.func(scalehls-schedule-dataflow), cse, canonicalize)")
    pm.run(module.operation)


def apply_convert_dataflow_to_func_passes(module: Module):
    pm = PassManager()
    add_convert_dataflow_to_func_passes(pm)
    pm.run(module.operation)


def get_module_cpp_str(module: Module):
    buf = io.StringIO()
    emit_hlscpp(module, buf)
    return buf.getvalue()
