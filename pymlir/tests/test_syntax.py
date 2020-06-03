""" Tests pyMLIR on different syntactic edge-cases. """

from mlir import Parser
from typing import Optional


def test_attributes(parser: Optional[Parser] = None):
    code = '''
module {
  func @myfunc(%tensor: tensor<256x?xf64>) -> tensor<*xf64> {
    %t_tensor = "with_attributes"(%tensor) { inplace = true, abc = -123, bla = unit, hello_world = "hey", value=@this::@is::@hierarchical, somelist = ["of", "values"], last = {butnot = "least", dictionaries = 0xabc} } : (tensor<2x3xf64>) -> tuple<vector<3xi33>,tensor<2x3xf64>> 
    return %t_tensor : tensor<3x2xf64>
  }
  func @toy_func(%arg0: tensor<2x3xf64>) -> tensor<3x2xf64> {
    %0:2 = "toy.split"(%arg0) : (tensor<2x3xf64>) -> (tensor<3x2xf64>, f32)
    return %0#50 : tensor<3x2xf64>
  }
}
    '''
    parser = parser or Parser()
    module = parser.parse(code)
    print(module.pretty())


def test_memrefs(parser: Optional[Parser] = None):
    code = '''
module {
  func @myfunc() {
        %a, %b = "tensor_replicator"(%tensor, %tensor) : (memref<?xbf16, 2>, 
          memref<?xf32, offset: 5, strides: [6, 7]>,
          memref<*xf32, 8>)
  }
}
    '''
    parser = parser or Parser()
    module = parser.parse(code)
    print(module.pretty())


def test_trailing_loc(parser: Optional[Parser] = None):
    code = '''
    module {
      func @myfunc() {
        %c:2 = addf %a, %b : f32 loc("test_syntax.py":36:59)
      }
    } loc("hi.mlir":30:1)
    '''
    parser = parser or Parser()
    module = parser.parse(code)
    print(module.pretty())


def test_modules(parser: Optional[Parser] = None):
    code = '''
module {
  module {
  }
  module {
  }
  module attributes {foo.attr = true} {
  }
  module {
    %1 = "foo.result_op"() : () -> i32
  }
  module {
  }
  %0 = "op"() : () -> i32
  module @foo {
    module {
      module @bar attributes {foo.bar} {
      }
    }
  }
}'''
    parser = parser or Parser()
    module = parser.parse(code)
    print(module.pretty())


def test_functions(parser: Optional[Parser] = None):
    code = '''
    module {
      func @myfunc_a() {
        %c:2 = addf %a, %b : f32
      }
      func @myfunc_b() {
        %d:2 = addf %a, %b : f64
        ^e:
        %f:2 = addf %d, %d : f64
      }
    }'''
    parser = parser or Parser()
    module = parser.parse(code)
    print(module.pretty())


def test_toplevel_function(parser: Optional[Parser] = None):
    code = '''
    func @toy_func(%tensor: tensor<2x3xf64>) -> tensor<3x2xf64> {
      %t_tensor = "toy.transpose"(%tensor) { inplace = true } : (tensor<2x3xf64>) -> tensor<3x2xf64>
      return %t_tensor : tensor<3x2xf64>
    }'''

    parser = parser or Parser()
    module = parser.parse(code)
    print(module.pretty())


def test_toplevel_functions(parser: Optional[Parser] = None):
    code = '''
    func @toy_func(%tensor: tensor<2x3xf64>) -> tensor<3x2xf64> {
      %t_tensor = "toy.transpose"(%tensor) { inplace = true } : (tensor<2x3xf64>) -> tensor<3x2xf64>
      return %t_tensor : tensor<3x2xf64>
    }
    func @toy_func(%tensor: tensor<2x3xf64>) -> tensor<3x2xf64> {
      %t_tensor = "toy.transpose"(%tensor) { inplace = true } : (tensor<2x3xf64>) -> tensor<3x2xf64>
      return %t_tensor : tensor<3x2xf64>
    }'''

    parser = parser or Parser()
    module = parser.parse(code)
    print(module.pretty())


def test_affine(parser: Optional[Parser] = None):
    code = '''
func @empty() {
  affine.for %i = 0 to 10 {
  } {some_attr = true}
  %0 = affine.min (d0)[s0] -> (1000, d0 + 512, s0) (%arg0)[%arg1]
}
func @valid_symbols(%arg0: index, %arg1: index, %arg2: index) {
  %c0 = constant 1 : index
  %c1 = constant 0 : index
  %b = alloc()[%N] : memref<4x4xf32, (d0, d1)[s0] -> (d0, d0 + d1 + s0 floordiv 2)>
  %0 = alloc(%arg0, %arg1) : memref<?x?xf32>
  affine.for %arg3 = %arg1 to %arg2 step 768 {
    %13 = dim %0, 1 : memref<?x?xf32>
    affine.for %arg4 = 0 to %13 step 264 {
      %18 = dim %0, 0 : memref<?x?xf32>
      %20 = subview %0[%c0, %c0][%18,%arg4][%c1,%c1] : memref<?x?xf32>
                          to memref<?x?xf32, (d0, d1)[s0, s1, s2] -> (d0 * s1 + d1 * s2 + s0)>
      %24 = dim %20, 0 : memref<?x?xf32, (d0, d1)[s0, s1, s2] -> (d0 * s1 + d1 * s2 + s0)>
      affine.for %arg5 = 0 to %24 step 768 {
        "foo"() : () -> ()
      }
    }
  }
  return
}
    '''
    parser = parser or Parser()
    module = parser.parse(code)
    print(module.pretty())


def test_definitions(parser: Optional[Parser] = None):
    code = '''
#map0 = (d0, d1) -> (d0, d1)
#map1 = (d0) -> (d0)
#map2 = () -> (0)
#map3 = () -> (10)
#map4 = (d0, d1, d2) -> (d0, d1 + d2 + 5)
#map5 = (d0, d1, d2) -> (d0 + d1, d2)
#map6 = (d0, d1)[s0] -> (d0, d1 + s0 + 7)
#map7 = (d0, d1)[s0] -> (d0 + s0, d1)
#map8 = (d0, d1) -> (d0 + d1 + 11)
#map9 = (d0, d1)[s0] -> (d0, (d1 + s0) mod 9 + 7)
#map10 = (d0, d1)[s0] -> ((d0 + s0) floordiv 3, d1)
#samap0 = (d0)[s0] -> (d0 floordiv (s0 + 1))
#samap1 = (d0)[s0] -> (d0 floordiv s0)
#samap2 = (d0, d1)[s0, s1] -> (d0*s0 + d1*s1)
#set0 = (d0) : (1 == 0)
#set1 = (d0, d1)[s0] : ()
#set2 = (d0, d1)[s0, s1] : (d0 >= 0, -d0 + s0 - 1 >= 0, d1 >= 0, -d1 + s1 - 1 >= 0)
#set3 = (d0, d1, d2) : (d0 - d2 * 4 == 0, d0 + d1 * 8 - 9 >= 0, -d0 - d1 * 8 + 11 >= 0)
#set4 = (d0, d1, d2, d3, d4, d5) : (d0 * 1089234 + d1 * 203472 + 82342 >= 0, d0 * -55 + d1 * 24 + d2 * 238 - d3 * 234 - 9743 >= 0, d0 * -5445 - d1 * 284 + d2 * 23 + d3 * 34 - 5943 >= 0, d0 * -5445 + d1 * 284 + d2 * 238 - d3 * 34 >= 0, d0 * 445 + d1 * 284 + d2 * 238 + d3 * 39 >= 0, d0 * -545 + d1 * 214 + d2 * 218 - d3 * 94 >= 0, d0 * 44 - d1 * 184 - d2 * 231 + d3 * 14 >= 0, d0 * -45 + d1 * 284 + d2 * 138 - d3 * 39 >= 0, d0 * 154 - d1 * 84 + d2 * 238 - d3 * 34 >= 0, d0 * 54 - d1 * 284 - d2 * 223 + d3 * 384 >= 0, d0 * -55 + d1 * 284 + d2 * 23 + d3 * 34 >= 0, d0 * 54 - d1 * 84 + d2 * 28 - d3 * 34 >= 0, d0 * 54 - d1 * 24 - d2 * 23 + d3 * 34 >= 0, d0 * -55 + d1 * 24 + d2 * 23 + d3 * 4 >= 0, d0 * 15 - d1 * 84 + d2 * 238 - d3 * 3 >= 0, d0 * 5 - d1 * 24 - d2 * 223 + d3 * 84 >= 0, d0 * -5 + d1 * 284 + d2 * 23 - d3 * 4 >= 0, d0 * 14 + d2 * 4 + 7234 >= 0, d0 * -174 - d2 * 534 + 9834 >= 0, d0 * 194 - d2 * 954 + 9234 >= 0, d0 * 47 - d2 * 534 + 9734 >= 0, d0 * -194 - d2 * 934 + 984 >= 0, d0 * -947 - d2 * 953 + 234 >= 0, d0 * 184 - d2 * 884 + 884 >= 0, d0 * -174 + d2 * 834 + 234 >= 0, d0 * 844 + d2 * 634 + 9874 >= 0, d2 * -797 - d3 * 79 + 257 >= 0, d0 * 2039 + d2 * 793 - d3 * 99 - d4 * 24 + d5 * 234 >= 0, d2 * 78 - d5 * 788 + 257 >= 0, d3 - (d5 + d0 * 97) floordiv 423 >= 0, ((d0 + (d3 mod 5) floordiv 2342) * 234) mod 2309 + (d0 + d3 * 2038) floordiv 208 >= 0, ((((d0 + d3 * 2300) * 239) floordiv 2342) mod 2309) mod 239423 == 0, d0 + d3 mod 2642 + (((((d3 + d0 * 2) mod 1247) mod 2038) mod 2390) mod 2039) floordiv 55 >= 0)
#matmul_accesses = [
  (m, n, k) -> (m, k),
  (m, n, k) -> (k, n),
  (m, n, k) -> (m, n)
]
#matmul_trait = {
  args_in = 2,
  args_out = 1,
  iterator_types = ["parallel", "parallel", "reduction"],
  indexing_maps = #matmul_accesses,
  library_call = "external_outerproduct_matmul"
}

!vector_type_A = type vector<4xf32>
!vector_type_B = type vector<4xf32>
!vector_type_C = type vector<4x4xf32>

!matrix_type_A = type memref<?x?x!vector_type_A>
!matrix_type_B = type memref<?x?x!vector_type_B>
!matrix_type_C = type memref<?x?x!vector_type_C>
    '''
    parser = parser or Parser()
    module = parser.parse(code)
    print(module.pretty())


if __name__ == '__main__':
    p = Parser()
    print("MLIR parser created")
    test_attributes(p)
    test_memrefs(p)
    test_trailing_loc(p)
    test_modules(p)
    test_functions(p)
    test_toplevel_function(p)
    test_toplevel_functions(p)
    test_affine(p)
    test_definitions(p)
