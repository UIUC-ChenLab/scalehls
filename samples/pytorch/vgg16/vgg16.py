import torch
import torch.nn as nn
import torch.nn.functional as F
import torch_mlir


def make_layers(cfg):
    layers = []
    in_channels = 3
    for v in cfg:
        if v == 'M':
            layers += [nn.MaxPool2d(kernel_size=2, stride=2)]
        else:
            conv2d = nn.Conv2d(in_channels, v, kernel_size=3, padding=1)
            layers += [conv2d, nn.ReLU(inplace=True)]
            in_channels = v
    return nn.Sequential(*layers)


class VGG(nn.Module):
    def __init__(self, features, num_conv_channels=512, num_fc_channels=2048, num_classes=1000):
        super(VGG, self).__init__()
        self.features = features
        self.conv = nn.Conv2d(
            num_conv_channels, num_fc_channels, kernel_size=7)
        self.classifier = nn.Sequential(
            # nn.Linear(num_conv_channels*7*7, num_fc_channels),
            # nn.ReLU(True),
            nn.Linear(num_fc_channels, num_fc_channels),
            nn.ReLU(True),
            nn.Linear(num_fc_channels, num_classes),
        )

    def forward(self, x):
        x = self.features(x)
        x = F.relu(self.conv(x))
        x = x.view(x.size(0), -1)
        x = self.classifier(x)
        return x


cfg = [32, 32, 'M', 64, 64, 'M', 128, 128, 128,
       'M', 256, 256, 256, 'M', 512, 512, 512, 'M']


module = torch_mlir.compile(VGG(make_layers(cfg)), torch.ones(1, 3, 224, 224),
                            output_type=torch_mlir.OutputType.LINALG_ON_TENSORS)
print(module)

# traced_script_module = torch.jit.trace(
#     VGG(make_layers(cfg)), torch.ones(1, 3, 224, 224))
# traced_script_module.save("vgg16.pt")
