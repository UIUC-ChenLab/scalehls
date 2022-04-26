import sys
import torch.nn.functional as F
import torch.nn as nn
import torch
from torch_mlir.dialects.torch.importer.jit_ir import ClassAnnotator, ModuleBuilder
from lenet import LeNet


script_module = torch.jit.script(LeNet())

ca = ClassAnnotator()
ca.exportNone(script_module._c._type())
ca.exportPath(script_module._c._type(), ["forward"])
ca.annotateArgs(
    script_module._c._type(),
    ["forward"],
    [
        None,
        ([1, 3, 32, 32], torch.float32, True),
    ],
)

mb = ModuleBuilder()
mb.import_module(script_module._c, ca)
mb.module.operation.print()
