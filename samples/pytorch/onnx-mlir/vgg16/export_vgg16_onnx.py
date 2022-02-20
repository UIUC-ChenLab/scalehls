import sys
import torch.nn.functional as F
import torch.nn as nn
import torch

sys.path.append("../../models")
from vgg16 import VGG16


input_random = torch.randn((1, 3, 32, 32))
torch.onnx.export(VGG16(), input_random, 'vgg16.onnx', opset_version=7)
