# Models (models)

## Overview
Here is a collection of algorithms that we experimented with in the course of the project.

### Toy Model (mnist)
This is a simple neural network used for MNIST digit classification. We successfully emitted the (affine dialect of) MLIR IR and TVM IR here. 

### Benchmarks (benchmarks)
Here are some benchmarks (3-mm, covariance, correlation, Alexnet) in the ICCAD paper we have attempted to replicate in MLIR without success. Actually, the Alexnet.onnx (Alexnet ONNX model) is too big so it is not here but one can just look it up online. In addition, we also include the first conv2d and maxpool2d operations from the toy model which obviously can be converted into MLIR currently.


