# ===----------------------------------------------------------------------=== #
#
# Copyright 2020-2021 The ScaleHLS Authors.
#
# ===----------------------------------------------------------------------=== #

from typing import Callable, Any
from functools import wraps
from inspect import getsource
import ast

from mlir.ir import InsertionPoint, Value
from mlir.dialects import func as func_dialect, arith
from .context import get_context, get_location, get_module
from .type import convert_to_mlir_type


# ===----------------------------------------------------------------------=== #
# A DEMO of interpretation-based IR construction.
# ===----------------------------------------------------------------------=== #

class value(object):
    def __init__(self, impl: Value):
        self.impl = impl

    @property
    def mlir_value(self):
        return self.impl

    def __add__(self, other):
        return value(arith.AddIOp(self.mlir_value, other.mlir_value).result)

    def __radd__(self, other):
        return value(arith.AddIOp(other.mlir_value, self.mlir_value).result)


def pmlir_function_interp():
    """
    A decorator used for defining a pmlir function.
    """
    def decorator(func: Callable):
        @wraps(func)
        def wrapper(*inputs: value):
            if len(inputs) != 0:
                raise Exception('function call is not supported')

            annos = func.__annotations__

            input_types = map(lambda name: convert_to_mlir_type(
                annos[name]), filter(lambda name: name != 'return', annos))
            output_type = convert_to_mlir_type(annos['return'])

            with InsertionPoint.at_block_begin(get_module().body):
                func_op = func_dialect.FuncOp(
                    func.__name__, (list(input_types), [output_type]))

            entry_block = func_op.add_entry_block()
            mlir_inputs = map(lambda mlir_input: value(
                mlir_input), entry_block.arguments)

            with InsertionPoint.at_block_begin(entry_block):
                output = func(*tuple(mlir_inputs))
                func_dialect.ReturnOp([output.mlir_value])
        return wrapper
    return decorator


# ===----------------------------------------------------------------------=== #
# A DEMO of AST-based IR construction.
# ===----------------------------------------------------------------------=== #

class FuncBuilder(ast.NodeVisitor):
    def __init__(self, mlir_inputs):
        super().__init__()
        self.mlir_inputs = mlir_inputs
        self.mlir_value_map = {}

    def visit_FunctionDef(self, node: ast.FunctionDef) -> Any:
        args = node.args.args
        for (arg, mlir_input) in zip(args, self.mlir_inputs):
            self.mlir_value_map[arg.arg] = mlir_input
        for stmt in node.body:
            self.visit(stmt)

    def visit_Assign(self, node: ast.Assign) -> Any:
        if len(node.targets) > 1:
            raise Exception("multiple elements assign is not supported")
        mlir_value = self.visit(node.value)
        if (not mlir_value):
            raise Exception("value operand cannot be resolved")
        if (isinstance(node.targets[0], ast.Name)):
            self.mlir_value_map[node.targets[0].id] = mlir_value
        else:
            raise Exception("only scalar assignment is supported")

    def visit_Name(self, node: ast.Name) -> Any:
        mlir_value = self.mlir_value_map.get(node.id)
        if (not mlir_value):
            raise Exception(node.id + " cannot be resolved")
        return mlir_value

    def visit_BinOp(self, node: ast.BinOp) -> Any:
        mlir_lhs = self.visit(node.left)
        mlir_rhs = self.visit(node.right)
        if (not mlir_lhs or not mlir_rhs):
            raise Exception("lhs or rhs operand cannot be resolved")
        mlir_result = arith.AddIOp(mlir_lhs, mlir_rhs).result
        return mlir_result

    def visit_Return(self, node: ast.Return) -> Any:
        if (node.value):
            mlir_value = self.visit(node.value)
            if (not mlir_value):
                raise Exception("value operand cannot be resolved")
            func_dialect.ReturnOp([mlir_value])
        else:
            func_dialect.ReturnOp()


def pmlir_function_ast():
    """
    A decorator used for defining a pmlir function.
    """
    def decorator(func: Callable):
        @wraps(func)
        def wrapper(*inputs):
            if len(inputs) != 0:
                raise Exception('function call is not supported')

            annos = func.__annotations__

            input_types = map(lambda name: convert_to_mlir_type(
                annos[name]), filter(lambda name: name != 'return', annos))
            output_type = convert_to_mlir_type(annos['return'])

            with InsertionPoint.at_block_begin(get_module().body):
                func_op = func_dialect.FuncOp(
                    func.__name__, (list(input_types), [output_type]))

            entry_block = func_op.add_entry_block()

            func_ast = ast.parse(getsource(func))
            # print(ast.dump(func_ast))

            builder = FuncBuilder(entry_block.arguments)
            with InsertionPoint.at_block_begin(entry_block):
                builder.visit(func_ast)
        return wrapper
    return decorator


# ===----------------------------------------------------------------------=== #
# Compiler entry.
# ===----------------------------------------------------------------------=== #

def pmlir_compile(pmlir_func: Callable):
    with get_context(), get_location():
        pmlir_func()
    print(get_module())
