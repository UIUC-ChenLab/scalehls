module {
  func @multiply_transpose(%arg0: tensor<*xf64>, %arg1: tensor<*xf64>) -> tensor<*xf64> {
    %0 = "toy.transpose"(%arg0) : (tensor<*xf64>) -> tensor<*xf64> loc("test/codegen.toy":5:10)
    %1 = "toy.transpose"(%arg1) : (tensor<*xf64>) -> tensor<*xf64> loc("test/codegen.toy":5:25)
    %2 = "toy.mul"(%0, %1) : (tensor<*xf64>, tensor<*xf64>) -> tensor<*xf64> loc("test/codegen.toy":5:25)
    "toy.return"(%2) : (tensor<*xf64>) -> () loc("test/codegen.toy":5:3)
  } loc("test/codegen.toy":4:1)
  func @main() {
    %0 = "toy.constant"() {value = dense<[[1.000000e+00, 2.000000e+00, 3.000000e+00], [4.000000e+00, 5.000000e+00, 6.000000e+00]]> : tensor<2x3xf64>} : () -> tensor<2x3xf64> loc("test/codegen.toy":9:17)
    %1 = "toy.reshape"(%0) : (tensor<2x3xf64>) -> tensor<2x3xf64> loc("test/codegen.toy":9:3)
    %2 = "toy.constant"() {value = dense<[1.000000e+00, 2.000000e+00, 3.000000e+00, 4.000000e+00, 5.000000e+00, 6.000000e+00]> : tensor<6xf64>} : () -> tensor<6xf64> loc("test/codegen.toy":10:17)
    %3 = "toy.reshape"(%2) : (tensor<6xf64>) -> tensor<2x3xf64> loc("test/codegen.toy":10:3)
    %4 = "toy.generic_call"(%1, %3) {callee = @multiply_transpose} : (tensor<2x3xf64>, tensor<2x3xf64>) -> tensor<*xf64> loc("test/codegen.toy":11:11)
    %5 = "toy.generic_call"(%3, %1) {callee = @multiply_transpose} : (tensor<2x3xf64>, tensor<2x3xf64>) -> tensor<*xf64> loc("test/codegen.toy":12:11)
    "toy.print"(%5) : (tensor<*xf64>) -> () loc("test/codegen.toy":13:3)
    "toy.return"() : () -> () loc("test/codegen.toy":8:1)
  } loc("test/codegen.toy":8:1)
  
func @main() {
  %cst = constant 1.000000e+00 : f64
  %cst_0 = constant 2.000000e+00 : f64
  %cst_1 = constant 3.000000e+00 : f64
  %cst_2 = constant 4.000000e+00 : f64
  %cst_3 = constant 5.000000e+00 : f64
  %cst_4 = constant 6.000000e+00 : f64

  // Allocating buffers for the inputs and outputs.
  %0 = alloc() : memref<3x2xf64>
  %1 = alloc() : memref<3x2xf64>
  %2 = alloc() : memref<2x3xf64>

  // Initialize the input buffer with the constant values.
  affine.store %cst, %2[0, 0] : memref<2x3xf64>
  affine.store %cst_0, %2[0, 1] : memref<2x3xf64>
  affine.store %cst_1, %2[0, 2] : memref<2x3xf64>
  affine.store %cst_2, %2[1, 0] : memref<2x3xf64>
  affine.store %cst_3, %2[1, 1] : memref<2x3xf64>
  affine.store %cst_4, %2[1, 2] : memref<2x3xf64>

  // Load the transpose value from the input buffer and store it into the
  // next input buffer.
  affine.for %arg0 = 0 to 3 {
    affine.for %arg1 = 0 to 2 {
      %3 = affine.load %2[%arg1, %arg0] : memref<2x3xf64>
      affine.store %3, %1[%arg0, %arg1] : memref<3x2xf64>
    }
  }

  // Multiply and store into the output buffer.
  affine.for %arg0 = 0 to 2 {
    affine.for %arg1 = 0 to 3 {
      %3 = affine.load %1[%arg0, %arg1] : memref<3x2xf64>
      %4 = affine.load %1[%arg0, %arg1] : memref<3x2xf64>
      %5 = mulf %3, %4 : f64
      affine.store %5, %0[%arg0, %arg1] : memref<3x2xf64>
    }
  }

  // Print the value held by the buffer.
  "toy.print"(%0) : (memref<3x2xf64>) -> ()
  dealloc %2 : memref<2x3xf64>
  dealloc %1 : memref<3x2xf64>
  dealloc %0 : memref<3x2xf64>
  return
}

func @main() {
  %cst = constant 1.000000e+00 : f64
  %cst_0 = constant 2.000000e+00 : f64
  %cst_1 = constant 3.000000e+00 : f64
  %cst_2 = constant 4.000000e+00 : f64
  %cst_3 = constant 5.000000e+00 : f64
  %cst_4 = constant 6.000000e+00 : f64

  // Allocating buffers for the inputs and outputs.
  %0 = alloc() : memref<3x2xf64>
  %1 = alloc() : memref<2x3xf64>

  // Initialize the input buffer with the constant values.
  affine.store %cst, %1[0, 0] : memref<2x3xf64>
  affine.store %cst_0, %1[0, 1] : memref<2x3xf64>
  affine.store %cst_1, %1[0, 2] : memref<2x3xf64>
  affine.store %cst_2, %1[1, 0] : memref<2x3xf64>
  affine.store %cst_3, %1[1, 1] : memref<2x3xf64>
  affine.store %cst_4, %1[1, 2] : memref<2x3xf64>

  affine.for %arg0 = 0 to 3 {
    affine.for %arg1 = 0 to 2 {
      // Load the transpose value from the input buffer.
      %2 = affine.load %1[%arg1, %arg0] : memref<2x3xf64>

      // Multiply and store into the output buffer.
      %3 = mulf %2, %2 : f64
      affine.store %3, %0[%arg0, %arg1] : memref<3x2xf64>
    }
  }

  // Print the value held by the buffer.
  "toy.print"(%0) : (memref<3x2xf64>) -> ()
  dealloc %1 : memref<2x3xf64>
  dealloc %0 : memref<3x2xf64>
  return
}
} loc("test/codegen.toy":0:0)

module {
  func @multiply_transpose(%arg0: !toy.struct<tensor<*xf64>, tensor<*xf64>>) {
    "toy.return"() : () -> ()
  }
}