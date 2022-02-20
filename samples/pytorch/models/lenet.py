'''LeNet in PyTorch.
Modified based on (https://github.com/kuangliu/pytorch-cifar/blob/master/models/lenet.py)
'''

import torch
import torch.nn as nn
import torch.nn.functional as F


class LeNet(nn.Module):
    def __init__(self):
        super(LeNet, self).__init__()
        self.conv1 = nn.Conv2d(3, 6, 5, stride=2, bias=False)
        # self.pool1 = nn.MaxPool2d(2, 2)
        self.conv2 = nn.Conv2d(6, 16, 5, stride=2, bias=False)
        # self.pool2 = nn.MaxPool2d(2, 2)
        self.fc1 = nn.Linear(16*5*5, 120)
        self.fc2 = nn.Linear(120, 84)
        self.fc3 = nn.Linear(84, 10)

    def forward(self, x):
        out = F.relu(self.conv1(x))
        # out = self.pool1(out)
        out = F.relu(self.conv2(out))
        # out = self.pool2(out)
        out = torch.flatten(out, 1)  # out.view(out.size(0), -1)
        out = F.relu(self.fc1(out))
        out = F.relu(self.fc2(out))
        out = self.fc3(out)
        return out
