

module {
  func @main_graph(%arg0: tensor<1x3x227x227xf32>) -> tensor<1x3x113x113xf32> {
    %0 = "onnx.MaxPoolSingleOut"(%arg0) {auto_pad = "NOTSET", dilations = [1, 1], kernel_shape = [2, 2], pads = [0, 0, 0, 0], strides = [2, 2]} : (tensor<1x3x227x227xf32>) -> tensor<1x3x113x113xf32>
    return %0 : tensor<1x3x113x113xf32>
  }
  "onnx.EntryPoint"() {func = @main_graph, numInputs = 1 : i32, numOutputs = 1 : i32} : () -> ()
}