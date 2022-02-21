import sys
import torch.nn.functional as F
import torch.nn as nn
import torch

sys.path.append("../../models")
from lenet import LeNet


input_random = torch.randn((1, 3, 32, 32))
torch.onnx.export(LeNet(), input_random, 'lenet.onnx', opset_version=7)
