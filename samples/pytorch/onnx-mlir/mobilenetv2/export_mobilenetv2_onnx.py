import sys
import torch.nn.functional as F
import torch.nn as nn
import torch

sys.path.append("../../models")
from mobilenetv2 import MobileNetV2


input_random = torch.randn((1, 3, 32, 32))
torch.onnx.export(MobileNetV2(), input_random,
                  'mobilenetv2.onnx', opset_version=7)
