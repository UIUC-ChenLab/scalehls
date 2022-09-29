import sys
import torch
import torchvision.models as models
import torch_mlir

resnet18 = models.resnet18(weights=models.ResNet18_Weights.DEFAULT)
resnet18.train(False)
module = torch_mlir.compile(resnet18, torch.ones(
    1, 3, 32, 32), output_type=torch_mlir.OutputType.LINALG_ON_TENSORS)

print(module)
