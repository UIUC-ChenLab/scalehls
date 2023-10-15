import torch
import torch.nn as nn
import torch.nn.functional as F
import torch_mlir


class ZF(nn.Module):
    def __init__(self):
        super(ZF, self).__init__()
        self.conv1 = nn.Conv2d(3, 96, kernel_size=7, padding=1, stride=2)
        self.pool1 = nn.MaxPool2d(kernel_size=3, stride=2)
        self.conv2 = nn.Conv2d(96, 256, kernel_size=5, padding=1, stride=2)
        self.pool2 = nn.MaxPool2d(kernel_size=3, stride=2)
        self.conv3 = nn.Conv2d(256, 384, kernel_size=3, padding=1, stride=1)
        self.conv4 = nn.Conv2d(384, 384, kernel_size=3, padding=1, stride=1)
        self.conv5 = nn.Conv2d(384, 256, kernel_size=3, padding=1, stride=1)
        self.pool5 = nn.MaxPool2d(kernel_size=3, stride=2)
        self.fc6 = nn.Conv2d(256, 4096, kernel_size=5)
        # self.fc6 = nn.Linear(256*5*5, 4096)
        self.fc7 = nn.Linear(4096, 4096)
        self.fc8 = nn.Linear(4096, 1000)

    def forward(self, x):
        x = F.relu(self.conv1(x))
        x = self.pool1(x)
        x = F.relu(self.conv2(x))
        x = self.pool2(x)
        x = F.relu(self.conv3(x))
        x = F.relu(self.conv4(x))
        x = F.relu(self.conv5(x))
        x = self.pool5(x)
        # x = x.view(x.size(0), -1)
        x = F.relu(self.fc6(x))
        x = x.view(x.size(0), -1)
        x = F.relu(self.fc7(x))
        x = self.fc8(x)
        return x


module = torch_mlir.compile(ZF(), torch.ones(1, 3, 224, 224),
                            output_type=torch_mlir.OutputType.LINALG_ON_TENSORS)
print(module)
