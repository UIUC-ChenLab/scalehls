""" Implementation of the Loop dialect. """

import inspect
import sys
from mlir.dialect import Dialect, DialectOp, is_op


class LoopForOp(DialectOp):
    _syntax_ = ['loop.for {index.ssa_id} = {begin.ssa_id} to {end.ssa_id} {body.region}',
                'loop.for {index.ssa_id} = {begin.ssa_id} to {end.ssa_id} step {step.ssa_id} {body.region}']


class LoopIfOp(DialectOp):
    _syntax_ = ['loop.if {cond.ssa_id} {body.region}',
                'loop.if {cond.ssa_id} {body.region} else {elsebody.region}']


# Inspect current module to get all classes defined above
loop = Dialect('loop', ops=[m[1] for m in inspect.getmembers(
               sys.modules[__name__], lambda obj: is_op(obj, __name__))])
