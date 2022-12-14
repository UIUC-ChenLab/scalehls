# ===----------------------------------------------------------------------=== #
#
# Copyright 2020-2021 The ScaleHLS Authors.
#
# ===----------------------------------------------------------------------=== #

from typing import Callable, Any
from functools import wraps
from inspect import getsource
import ast

from mlir.ir import InsertionPoint, Value, IntegerType, F32Type, IntegerAttr, FloatAttr, MemRefType
from mlir.dialects import func as func_dialect, arith, memref
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
            # working here...
            self.mlir_value_map[node.targets[0].id] = mlir_value
        else:
            raise Exception("only scalar assignment is supported")

    def visit_Name(self, node: ast.Name) -> Any:
        if (isinstance(node.ctx, ast.Load)):
            mlir_value = self.mlir_value_map.get(node.id)
            if (not mlir_value):
                raise Exception(node.id + " cannot be resolved")
            memref_type = MemRefType(mlir_value.type)
            if (memref_type.rank is 0):
                return memref.LoadOp(mlir_value).result
            else:
                raise Exception("only scalar is supported")
        else:
            raise Exception("only load context is supported")

    def visit_BinOp(self, node: ast.BinOp) -> Any:
        mlir_lhs = self.visit(node.left)
        mlir_rhs = self.visit(node.right)
        #print (str(mlir_lhs.type))
        if (not mlir_lhs or not mlir_rhs):
            raise Exception("lhs or rhs operand cannot be resolved")
        elif (isinstance(node.op, ast.Add)):
            if (str(mlir_lhs.type) == 'i32' == str(mlir_rhs.type)):
                mlir_result = arith.AddIOp(mlir_lhs, mlir_rhs).result
            elif (str(mlir_lhs.type) == 'f32' == str(mlir_rhs.type)):
                mlir_result = arith.AddFOp(mlir_lhs, mlir_rhs).result
            else:
                raise Exception(
                    "Combination of data types currently not supported")
        elif (isinstance(node.op, ast.Sub)):
            if (str(mlir_lhs.type) == 'i32' == str(mlir_rhs.type)):
                mlir_result = arith.SubIOp(mlir_lhs, mlir_rhs).result
            elif (str(mlir_lhs.type) == 'f32' == str(mlir_rhs.type)):
                mlir_result = arith.SubFOp(mlir_lhs, mlir_rhs).result
            else:
                raise Exception(
                    "Combination of data types currently not supported")
        elif (isinstance(node.op, ast.Mult)):
            if (str(mlir_lhs.type) == 'i32' == str(mlir_rhs.type)):
                mlir_result = arith.MulIOp(mlir_lhs, mlir_rhs).result
            elif (str(mlir_lhs.type) == 'f32' == str(mlir_rhs.type)):
                mlir_result = arith.MulFOp(mlir_lhs, mlir_rhs).result
            else:
                raise Exception(
                    "Combination of data types currently not supported")
        elif (isinstance(node.op, ast.Div)):
            if (str(mlir_lhs.type) == 'i32' == str(mlir_rhs.type)):
                mlir_result = arith.DivSIOp(mlir_lhs, mlir_rhs).result
            elif (str(mlir_lhs.type) == 'f32' == str(mlir_rhs.type)):
                mlir_result = arith.DivFOp(mlir_lhs, mlir_rhs).result
            else:
                raise Exception(
                    "Combination of data types currently not supported")
        elif (isinstance(node.op, ast.LShift)):
            if (str(mlir_lhs.type) == 'i32' == str(mlir_rhs.type)):
                mlir_result = arith.ShLIOp(mlir_lhs, mlir_rhs).result
            elif (str(mlir_lhs.type) == 'f32' == str(mlir_rhs.type)):
                raise Exception("Shift operation on float not supported")
            else:
                raise Exception(
                    "Combination of data types currently not supported")
        elif (isinstance(node.op, ast.RShift)):
            if (str(mlir_lhs.type) == 'i32' == str(mlir_rhs.type)):
                mlir_result = arith.ShRSIOp(mlir_lhs, mlir_rhs).result
            elif (str(mlir_lhs.type) == 'f32' == str(mlir_rhs.type)):
                raise Exception("Shift operation on float not supported")
            else:
                raise Exception(
                    "Combination of data types currently not supported")
        elif (isinstance(node.op, ast.BitAnd)):
            if (str(mlir_lhs.type) == 'i32' == str(mlir_rhs.type)):
                mlir_result = arith.AndIOp(mlir_lhs, mlir_rhs).result
            elif (str(mlir_lhs.type) == 'f32' == str(mlir_rhs.type)):
                raise Exception("And operation on float not supported")
            else:
                raise Exception(
                    "Combination of data types currently not supported")
        elif (isinstance(node.op, ast.BitOr)):
            if (str(mlir_lhs.type) == 'i32' == str(mlir_rhs.type)):
                mlir_result = arith.OrIOp(mlir_lhs, mlir_rhs).result
            elif (str(mlir_lhs.type) == 'f32' == str(mlir_rhs.type)):
                raise Exception("Or operation on float not supported")
            else:
                raise Exception(
                    "Combination of data types currently not supported")
        elif (isinstance(node.op, ast.BitXor)):
            if (str(mlir_lhs.type) == 'i32' == str(mlir_rhs.type)):
                mlir_result = arith.XOrIOp(mlir_lhs, mlir_rhs).result
            elif (str(mlir_lhs.type) == 'f32' == str(mlir_rhs.type)):
                raise Exception("Xor operation on float not supported")
            else:
                raise Exception(
                    "Combination of data types currently not supported")
        elif (isinstance(node.op, ast.FloorDiv)):
            if (str(mlir_lhs.type) == 'i32' == str(mlir_rhs.type)):
                mlir_result = arith.FloorDivSIOp(mlir_lhs, mlir_rhs).result
            elif (str(mlir_lhs.type) == 'f32' == str(mlir_rhs.type)):
                raise Exception("Floor operation on float not supported")
            else:
                raise Exception(
                    "Combination of data types currently not supported")
        elif (isinstance(node.op, ast.Mod)):
            if (str(mlir_lhs.type) == 'i32' == str(mlir_rhs.type)):
                mlir_result = arith.RemSIOp(mlir_lhs, mlir_rhs).result
            elif (str(mlir_lhs.type) == 'f32' == str(mlir_rhs.type)):
                mlir_result = arith.RemFOp(mlir_lhs, mlir_rhs).result
            else:
                raise Exception(
                    "Combination of data types currently not supported")
        else:
            raise Exception("does not support this operation at this time")
        return mlir_result

    def visit_Compare(self, node: ast.Compare) -> Any:
        mlir_lhs = self.visit(node.left)
        mlir_ops = node.ops[0]
        mlir_comparators = self.visit(node.comparators[0])
        if (len(node.ops) > 1):
            raise Exception("Only support one compare operator")
        elif (len(node.comparators) > 1):
            raise Exception("Only support one comparator")
        elif (not mlir_lhs or not mlir_ops or not mlir_comparators):
            raise Exception("lhs or rhs operand cannot be resolved")
        elif (isinstance(mlir_ops, ast.Gt)):
            if (str(mlir_lhs.type) == 'i32' == str(mlir_comparators.type)):
                mlir_result = arith.CmpIOp(IntegerType.get_signless(1), IntegerAttr.get(
                    IntegerType.get_signless(64), 4), lhs=mlir_lhs, rhs=mlir_comparators).result
            elif (str(mlir_lhs.type) == 'f32' == str(mlir_comparators.type)):
                mlir_result = arith.CmpFOp(IntegerType.get_signless(1), IntegerAttr.get(
                    IntegerType.get_signless(64), 4), lhs=mlir_lhs, rhs=mlir_comparators).result
            else:
                raise Exception(
                    'Combination of data types not currently supported')
        elif (isinstance(mlir_ops, ast.Lt)):
            if (str(mlir_lhs.type) == 'i32' == str(mlir_comparators.type)):
                mlir_result = arith.CmpIOp(IntegerType.get_signless(1), IntegerAttr.get(
                    IntegerType.get_signless(64), 2), lhs=mlir_lhs, rhs=mlir_comparators).result
            elif (str(mlir_lhs.type) == 'f32' == str(mlir_comparators.type)):
                mlir_result = arith.CmpFOp(IntegerType.get_signless(1), IntegerAttr.get(
                    IntegerType.get_signless(64), 2), lhs=mlir_lhs, rhs=mlir_comparators).result
            else:
                raise Exception(
                    'Combination of data types not currently supported')
        elif (isinstance(mlir_ops, ast.Eq)):
            if (str(mlir_lhs.type) == 'i32' == str(mlir_comparators.type)):
                mlir_result = arith.CmpIOp(IntegerType.get_signless(1), IntegerAttr.get(
                    IntegerType.get_signless(64), 0), lhs=mlir_lhs, rhs=mlir_comparators).result
            elif (str(mlir_lhs.type) == 'f32' == str(mlir_comparators.type)):
                mlir_result = arith.CmpFOp(IntegerType.get_signless(1), IntegerAttr.get(
                    IntegerType.get_signless(64), 0), lhs=mlir_lhs, rhs=mlir_comparators).result
            else:
                raise Exception(
                    'Combination of data types not currently supported')
        elif (isinstance(mlir_ops, ast.NotEq)):
            if (str(mlir_lhs.type) == 'i32' == str(mlir_comparators.type)):
                mlir_result = arith.CmpIOp(IntegerType.get_signless(1), IntegerAttr.get(
                    IntegerType.get_signless(64), 1), lhs=mlir_lhs, rhs=mlir_comparators).result
            elif (str(mlir_lhs.type) == 'f32' == str(mlir_comparators.type)):
                mlir_result = arith.CmpFOp(IntegerType.get_signless(1), IntegerAttr.get(
                    IntegerType.get_signless(64), 1), lhs=mlir_lhs, rhs=mlir_comparators).result
            else:
                raise Exception(
                    'Combination of data types not currently supported')
        elif (isinstance(mlir_ops, ast.LtE)):
            if (str(mlir_lhs.type) == 'i32' == str(mlir_comparators.type)):
                mlir_result = arith.CmpIOp(IntegerType.get_signless(1), IntegerAttr.get(
                    IntegerType.get_signless(64), 3), lhs=mlir_lhs, rhs=mlir_comparators).result
            elif (str(mlir_lhs.type) == 'f32' == str(mlir_comparators.type)):
                mlir_result = arith.CmpFOp(IntegerType.get_signless(1), IntegerAttr.get(
                    IntegerType.get_signless(64), 3), lhs=mlir_lhs, rhs=mlir_comparators).result
            else:
                raise Exception(
                    'Combination of data types not currently supported')
        elif (isinstance(mlir_ops, ast.GtE)):
            if (str(mlir_lhs.type) == 'i32' == str(mlir_comparators.type)):
                mlir_result = arith.CmpIOp(IntegerType.get_signless(1), IntegerAttr.get(
                    IntegerType.get_signless(64), 5), lhs=mlir_lhs, rhs=mlir_comparators).result
            elif (str(mlir_lhs.type) == 'f32' == str(mlir_comparators.type)):
                mlir_result = arith.CmpFOp(IntegerType.get_signless(1), IntegerAttr.get(
                    IntegerType.get_signless(64), 5), lhs=mlir_lhs, rhs=mlir_comparators).result
            else:
                raise Exception(
                    'Combination of data types not currently supported')
        else:
            raise Exception("does not support this operation at this time")
        return mlir_result

    def visit_Constant(self, node: ast.Constant) -> Any:
        mlir_value = node.value
        if (isinstance(mlir_value, int)):
            mlir_result = arith.ConstantOp(IntegerType.get_signless(32), IntegerAttr.get(IntegerType.get_signless(32), mlir_value)).result
        elif (isinstance(mlir_value, float)):
            mlir_result = arith.ConstantOp(
                F32Type.get(), FloatAttr.get(F32Type.get(), mlir_value)).result
        else:
            raise Exception('Unsupported data type')
        return mlir_result

    def visit_BoolOp(self, node: ast.BoolOp) -> Any:
        mlir_lhs = self.visit(node.values[0])
        mlir_rhs = self.visit(node.values[1])
        if (not mlir_lhs or not mlir_rhs):
            raise Exception("lhs or rhs operand cannot be resolved")
        elif (len(node.values) > 2):
            raise Exception(
                "Please use parentheses to separate chained boolean operators")
        elif (isinstance(node.op, ast.And)):
            if (str(mlir_lhs.type) == 'i1' == str(mlir_rhs.type)):
                mlir_result = arith.AndIOp(mlir_lhs, mlir_rhs).result
            else:
                raise Exception("Only accepts boolean types for And operator")
        elif (isinstance(node.op, ast.Or)):
            if (str(mlir_lhs.type) == 'i1' == str(mlir_rhs.type)):
                mlir_result = arith.OrIOp(mlir_lhs, mlir_rhs).result
            else:
                raise Exception("Only accepts boolean types for Or operator")
        else:
            raise Exception('Unsupported boolean operation')
        return mlir_result

    def visit_UnaryOp(self, node: ast.UnaryOp) -> Any:
        mlir_value = self.visit(node.operand)
        if (not mlir_value):
            raise Exception('Operand expression cannot be resolved')
        elif (isinstance(node.op, ast.Invert)):
            if (str(mlir_value.type) == 'i32'):
                all_ones = self.visit(ast.Constant(2 ** 32 - 1))
                mlir_result = arith.XOrIOp(mlir_value, all_ones).result
            else:
                raise Exception('Only support 32 bit ints for invert operation')
        elif (isinstance(node.op, ast.Not)):
            if (str(mlir_value.type) == 'i1'):
                bool_one = self.visit(ast.Constant(True))
                mlir_result = arith.XOrIOp(mlir_value, bool_one).result
            else:
                raise Exception("only support Not operation on boolean expressions")
        elif (isinstance(node.op, ast.USub)):
            if (str(mlir_value.type) == 'i32'):
                int_zero = self.visit(ast.Constant(0))
                mlir_result = arith.SubIOp(int_zero, mlir_value).result
            elif (str(mlir_value.type) == 'f32'):
                float_zero = self.visit(ast.Constant(0.0))
                mlir_result = arith.SubFOp(float_zero, mlir_value).result
            else:
                raise Exception("Only support Unary Sub operation on float and int expressions")
        else:
            raise Exception("Unary Add operation currently unsupported")
        return mlir_result


    def visit_For(self, node: ast.For) -> Any:
        if (isinstance(node.iter, ast.Call)):
            if (isinstance(node.iter.func, ast.Name)):
                if (node.iter.func.id == 'range'):
                    step = arith.ConstantOp(
                        IndexType.get(), IntegerAttr.get(IndexType.get(), 1)).result
                    lb, ub = None, None
                    if (isinstance(node.iter.args[0], ast.Constant)):
                        lb = arith.ConstantOp(
                            IndexType.get(), IntegerAttr.get(IndexType.get(), node.iter.args[0].value)).result
                    if (isinstance(node.iter.args[1], ast.Constant)):
                        ub = arith.ConstantOp(
                            IndexType.get(), IntegerAttr.get(IndexType.get(), node.iter.args[1].value)).result
                    if (not lb or not ub):
                        raise Exception("lower or upper bound not found")

                    scf_for = scf.ForOp(lb, ub, step)
                    if (isinstance(node.target, ast.Name)):
                        self.mlir_value_map[node.target.id] = scf_for.induction_variable
                    else:
                        Exception("Only scalar iv is supported")
                    with InsertionPoint.at_block_begin(scf_for.body):
                        for stmt in node.body:
                            self.visit(stmt)
                        scf.YieldOp([])
                    return
        raise Exception("Only range function is supported")

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
            print(ast.dump(func_ast, indent=4))

            with InsertionPoint.at_block_begin(entry_block):
                new_args = []
                for arg in entry_block.arguments:
                    if (isinstance(arg.type, MemRefType)):
                        new_args.append(arg)
                    else:
                        memref_type = MemRefType.get([], arg.type)
                        memref_arg = memref.AllocOp(memref_type, [], []).memref
                        memref.StoreOp(arg, memref_arg, [])
                        new_args.append(memref_arg)
                builder = FuncBuilder(new_args)
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
