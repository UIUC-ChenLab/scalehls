import sys
import torch.nn.functional as F
import torch.nn as nn
import torch

sys.path.append("../../models")
from mobilenet import MobileNet


input_random = torch.randn((1, 3, 32, 32))
torch.onnx.export(MobileNet(), input_random, 'mobilenet.onnx', opset_version=7)
