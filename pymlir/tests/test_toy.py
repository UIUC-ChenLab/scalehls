""" Tests pyMLIR on examples that use the Toy dialect. """

from mlir import parse_string, parse_path
import os


def test_toy_simple():
    code = '''
module {
  func @toy_func(%tensor: tensor<2x3xf64>) -> tensor<3x2xf64> {
    %t_tensor = "toy.transpose"(%tensor) { inplace = true } : (tensor<2x3xf64>) -> tensor<3x2xf64>
    return %t_tensor : tensor<3x2xf64>
  }
}
    '''

    module = parse_string(code)
    print(module.pretty())


def test_toy_advanced():
    module = parse_path(os.path.join(os.path.dirname(__file__), 'toy.mlir'))
    print(module.pretty())


if __name__ == '__main__':
    test_toy_simple()
    test_toy_advanced()