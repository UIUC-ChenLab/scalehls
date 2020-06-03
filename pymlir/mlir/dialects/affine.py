""" Implementation of the Affine dialect. """

import inspect
import sys
from mlir.dialect import Dialect, DialectOp, is_op


class AffineApplyOp(DialectOp):
    _syntax_ = 'affine.apply {map.affine_map} {args.dim_and_symbol_use_list}'


class AffineForOp(DialectOp):
    _syntax_ = [
        'affine.for {index.ssa_id} = {begin.symbol_or_const} to {end.symbol_or_const} {body.region}',
        'affine.for {index.ssa_id} = {begin.symbol_or_const} to {end.symbol_or_const} step {step.symbol_or_const} {body.region}',
        'affine.for {index.ssa_id} = {begin.symbol_or_const} to {end.symbol_or_const} {body.region} {attributes.attribute_dict}',
        'affine.for {index.ssa_id} = {begin.symbol_or_const} to {end.symbol_or_const} step {step.symbol_or_const} {body.region} {attributes.attribute_dict}'
    ]


class AffineIfOp(DialectOp):
    _syntax_ = ['affine.if {cond.map_or_set_id} ( {operands.ssa_use_list} ) {body.region}',
                'affine.if {cond.map_or_set_id} ( {operands.ssa_use_list} ) {body.region} else {elsebody.region}']


class AffineLoadOp(DialectOp):
    _syntax_ = 'affine.load {arg.ssa_use} [ {index.multi_dim_affine_expr_no_parens} ] : {type.memref_type}'


class AffineStoreOp(DialectOp):
    _syntax_ = 'affine.store {addr.ssa_use} , {ref.ssa_use} [ {index.multi_dim_affine_expr_no_parens} ] : {type.memref_type}'


class AffineMinOp(DialectOp):
    _syntax_ = 'affine.min {map.affine_map_inline} {operands.dim_and_symbol_use_list}'


class AffinePrefetchOp(DialectOp):
    _syntax_ = 'affine.prefetch {arg.ssa_use} [ {index.multi_dim_affine_expr_no_parens} ] , {specifier.bare_id} , locality < {locality.integer_literal} > , {cachetype.bare_id} : {type.type}'


class AffineDmaStartOperation(DialectOp):
    _syntax_ = [
        'affine.dma_start {src.ssa_use} [ {src_index.multi_dim_affine_expr_no_parens} ] , {dst.ssa_use} [ {dst_index.multi_dim_affine_expr_no_parens} ] , {tag.ssa_use} [ {tag_index.multi_dim_affine_expr_no_parens} ] , {size.ssa_use} : {src_type.memref_type} , {dst_type.memref_type} , {tag_type.memref_type}',
        'affine.dma_start {src.ssa_use} [ {src_index.multi_dim_affine_expr_no_parens} ] , {dst.ssa_use} [ {dst_index.multi_dim_affine_expr_no_parens} ] , {tag.ssa_use} [ {tag_index.multi_dim_affine_expr_no_parens} ] , {size.ssa_use} , {stride.ssa_use} , {transfer_per_stride.ssa_use} : {src_type.memref_type} , {dst_type.memref_type} , {tag_type.memref_type}'
    ]


class AffineDmaWaitOperation(DialectOp):
    _syntax_ = 'affine.dma_wait {tag.ssa_use} [ {tag_index.multi_dim_affine_expr_no_parens} ] , {size.ssa_use} : {type.memref_type}'


# Inspect current module to get all classes defined above
affine = Dialect('affine', ops=[m[1] for m in inspect.getmembers(
    sys.modules[__name__], lambda obj: is_op(obj, __name__))])
