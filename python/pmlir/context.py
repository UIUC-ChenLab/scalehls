# ===----------------------------------------------------------------------=== #
#
# Copyright 2020-2021 The ScaleHLS Authors.
#
# ===----------------------------------------------------------------------=== #

import scalehls
from mlir.ir import Context, Module, Location


class GlobalContext(object):
    def __init__(self):
        self.ctx = Context()
        self.loc = Location.unknown(self.ctx)
        self.mod = Module.create(self.loc)
        scalehls.register_dialects(self.ctx)
        self.ctx.load_all_available_dialects()

    def get_context(self):
        return self.ctx

    def get_location(self):
        return self.loc

    def get_module(self):
        return self.mod


global_context = GlobalContext()
get_context = global_context.get_context
get_location = global_context.get_location
get_module = global_context.get_module
