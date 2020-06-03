""" Implementation of the Standard dialect. """

import inspect
import sys
from mlir.dialect import (Dialect, DialectOp, UnaryOperation, BinaryOperation,
                          is_op)


# Terminator Operations
class BrOperation(DialectOp):
    _syntax_ = ['br {block.block_id}',
                'br {block.block_id} {args.block_arg_list}']
class CondBrOperation(DialectOp):
    _syntax_ = ['cond_br {cond.ssa_use} , {block_true.block_id} , {block_false.block_id}']
class ReturnOperation(DialectOp):
    _syntax_ = ['return',
                'return {values.ssa_use_list} : {types.type_list_no_parens}']

# Core Operations
class CallOperation(DialectOp):
    _syntax_ = ['call {func.symbol_ref_id} () : {type.function_type}',
                'call {func.symbol_ref_id} ( {args.ssa_use_list} ) : {type.function_type}']
class CallIndirectOperation(DialectOp):
    _syntax_ = ['call_indirect {func.symbol_ref_id} () : {type.function_type}',
                'call_indirect {func.symbol_ref_id} ( {args.ssa_use_list} ) : {type.function_type}']
class DimOperation(DialectOp):
    _syntax_ = 'dim {operand.ssa_id} , {index.integer_literal} : {type.type}'

# Memory Operations
class AllocOperation(DialectOp):
    _syntax_ = 'alloc {args.dim_and_symbol_use_list} : {type.memref_type}'
class AllocStaticOperation(DialectOp):
    _syntax_ = 'alloc_static ( {base.integer_literal} ) : {type.memref_type}'
class DeallocOperation(DialectOp):
    _syntax_ = 'dealloc {arg.ssa_use} : {type.memref_type}'
class DmaStartOperation(DialectOp):
    _syntax_ = [
        'dma_start {src.ssa_use} [ {src_index.ssa_use_list} ] , {dst.ssa_use} [ {dst_index.ssa_use_list} ] , {size.ssa_use} , {tag.ssa_use} [ {tag_index.ssa_use_list} ] : {src_type.memref_type} , {dst_type.memref_type} , {tag_type.memref_type}',
        'dma_start {src.ssa_use} [ {src_index.ssa_use_list} ] , {dst.ssa_use} [ {dst_index.ssa_use_list} ] , {size.ssa_use} , {tag.ssa_use} [ {tag_index.ssa_use_list} ] , {stride.ssa_use} , {transfer_per_stride.ssa_use} : {src_type.memref_type} , {dst_type.memref_type} , {tag_type.memref_type}'
    ]
class DmaWaitOperation(DialectOp):
    _syntax_ = 'dma_wait {tag.ssa_use} [ {tag_index.ssa_use_list} ] , {size.ssa_use} : {type.memref_type}'
class ExtractElementOperation(DialectOp):
    _syntax_ = 'extract_element {arg.ssa_use} [ {index.ssa_use_list} ] : {type.type}'
class LoadOperation(DialectOp):
    _syntax_ = 'load {arg.ssa_use} [ {index.ssa_use_list} ] : {type.memref_type}'
class SplatOperation(DialectOp):
    _syntax_ = 'splat {arg.ssa_use} : {type.type}'  # (vector_type | tensor_type)
class StoreOperation(DialectOp):
    _syntax_ = 'store {addr.ssa_use} , {ref.ssa_use} [  {index.ssa_use_list} ] : {type.memref_type}'
class TensorLoadOperation(DialectOp):
    _syntax_ = 'tensor_load {arg.ssa_use} : {type.type}'
class TensorLoadOperation(DialectOp):
    _syntax_ = 'tensor_store {src.ssa_use} , {dst.ssa_use} : {type.memref_type}'

# Unary Operations
class AbsfOperation(UnaryOperation): _opname_ = 'absf'
class CeilfOperation(UnaryOperation): _opname_ = 'ceilf'
class CosOperation(UnaryOperation): _opname_ = 'cos'
class ExpOperation(UnaryOperation): _opname_ = 'exp'
class NegfOperation(UnaryOperation): _opname_ = 'negf'
class TanhOperation(UnaryOperation): _opname_ = 'tanh'
class CopysignOperation(UnaryOperation): _opname_ = 'copysign'

# Arithmetic Operations
class AddiOperation(BinaryOperation): _opname_ = 'addi'
class AddfOperation(BinaryOperation): _opname_ = 'addf'
class AndOperation(BinaryOperation): _opname_ = 'and'
class DivisOperation(BinaryOperation): _opname_ = 'divis'
class DiviuOperation(BinaryOperation): _opname_ = 'diviu'
class RemisOperation(BinaryOperation): _opname_ = 'remis'
class RemiuOperation(BinaryOperation): _opname_ = 'remiu'
class DivfOperation(BinaryOperation): _opname_ = 'divf'
class MulfOperation(BinaryOperation): _opname_ = 'mulf'
class SubiOperation(BinaryOperation): _opname_ = 'subi'
class SubfOperation(BinaryOperation): _opname_ = 'subf'
class OrOperation(BinaryOperation): _opname_ = 'or'
class XorOperation(BinaryOperation): _opname_ = 'xor'


class CmpiOperation(DialectOp):
    _syntax_ = 'cmpi {comptype.string_literal} , {operand_a.ssa_id} , {operand_b.ssa_id} : {type.type}'
class CmpfOperation(DialectOp):
    _syntax_ = 'cmpf {comptype.string_literal} , {operand_a.ssa_id} , {operand_b.ssa_id} : {type.type}'
class ConstantOperation(DialectOp):
    _syntax_ = 'constant {value.attribute_value} : {type.type}'
class MemrefCastOperation(DialectOp):
    _syntax_ = 'memref_cast {arg.ssa_use} : {src_type.type} to {dst_type.type}'
class TensorCastOperation(DialectOp):
    _syntax_ = 'tensor_cast {arg.ssa_use} : {src_type.type} to {dst_type.type}'
class SelectOperation(DialectOp):
    _syntax_ = 'select {cond.ssa_use} , {arg_true.ssa_use} , {arg_false.ssa_use} : {type.type}'
class SubviewOperation(DialectOp):
    _syntax_ = 'subview {operand.ssa_use} [ {offsets.ssa_use_list} ] [ {sizes.ssa_use_list} ] [ {strides.ssa_use_list} ] : {src_type.type} to {dst_type.type}'

# Inspect current module to get all classes defined above
standard = Dialect('standard', ops=[m[1] for m in inspect.getmembers(
    sys.modules[__name__], lambda obj: is_op(obj, __name__))])
