import sys
import torch.nn.functional as F
import torch.nn as nn
import torch

sys.path.append("../../models")
from resnet18 import ResNet18


input_random = torch.randn((1, 3, 32, 32))
torch.onnx.export(ResNet18(), input_random, 'resnet18.onnx', opset_version=7)
