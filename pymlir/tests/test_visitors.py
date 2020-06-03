""" Tests pyMLIR's node visitor and transformer. """

from mlir import NodeVisitor, NodeTransformer, Parser, astnodes
from typing import Optional


# Sample code to use for visitors
_code = '''
module {
  func @test0(%arg0: index, %arg1: index) {
    %0 = alloc() : memref<100x100xf32>
    %1 = alloc() : memref<100x100xf32, 2>
    %2 = alloc() : memref<1xi32>
    %c0 = constant 0 : index
    %c64 = constant 64 : index
    affine.for %arg2 = 0 to 10 {
      affine.for %arg3 = 0 to 10 {
        affine.dma_start %0[%arg2, %arg3], %1[%arg2, %arg3], %2[%c0], %c64 : memref<100x100xf32>, memref<100x100xf32, 2>, memref<1xi32>
        affine.dma_wait %2[%c0], %c64 : memref<1xi32>
      }
    }
    return
  }
  func @test1(%arg0: index, %arg1: index) {
    affine.for %arg2 = 0 to 10 {
      affine.for %arg3 = 0 to 10 {
        %c0 = constant 0 : index
        %c64 = constant 64 : index
        %c128 = constant 128 : index
        %c256 = constant 256 : index
        affine.dma_start %0[%arg2, %arg3], %1[%arg2, %arg3], %2[%c0], %c64, %c128, %c256 : memref<100x100xf32>, memref<100x100xf32, 2>, memref<1xi32>
        affine.dma_wait %2[%c0], %c64 : memref<1xi32>
      }
    }
    return
  }
  func @test2(%arg0: index, %arg1: index) {
    %0 = alloc() : memref<100x100xf32>
  }
}
'''


def test_visitor(parser: Optional[Parser] = None):
    class MyVisitor(NodeVisitor):
        def __init__(self):
            self.functions = 0

        def visit_Function(self, node: astnodes.Function):
            self.functions += 1
            print('Function detected:', node.name.value)

    parser = parser or Parser()
    m = parser.parse(_code)
    visitor = MyVisitor()
    visitor.visit(m)

    assert visitor.functions == 3


def test_transformer(parser: Optional[Parser] = None):
    # Simple node transformer that removes all operations with a result
    class RemoveAllResultOps(NodeTransformer):
        def visit_Operation(self, node: astnodes.Operation):
            # There are one or more outputs, return None to remove from AST
            if len(node.result_list) > 0:
                return None

            # No outputs, no need to do anything
            return self.generic_visit(node)

    parser = parser or Parser()
    m = parser.parse(_code)
    m = RemoveAllResultOps().visit(m)
    print(m.pretty())

    # Verify that there are no operations with results
    class Tester(NodeVisitor):
        def __init__(self):
            self.fail = False

        def visit_Operation(self, node: astnodes.Operation):
            if len(node.result_list) > 0:
                self.fail = True
            return self.generic_visit(node)

    t = Tester()
    t.visit(m)
    assert t.fail is False


if __name__ == '__main__':
    p = Parser()
    print("MLIR parser created")
    test_visitor(p)
    test_transformer(p)
