# HLS Large Design Project

## Hanchen TODO List
1. Create an fpgakrnl dialect --> `include/fpgakrnl/Dialect.h`
2. Create conv and pool operations in fpgakrnl dialect --> `include/fpgakrnl/Ops.td`
3. Create pass for lowering conv and pool operations in ONNX dialect to fpgakrnl dialect

## Jack TODO List
1. Extract the first conv and pool operations in the MNIST model in ONNX
2. Emit the Affine (MLIR dialect) IR for these operations using onnx-mlir
3. Find out how to do transformation and lowering passes within Affine, LinAlg, Loop dialects for those operations

## References
1. [Toy Tutorial Chapter2: Emitting Basic MLIR](https://mlir.llvm.org/docs/Tutorials/Toy/Ch-2/#interfacing-with-mlir)
2. [ONNX-MLIR](https://github.com/onnx/onnx-mlir)
3. [DNNBuilder](https://github.com/IBM/AccDNN)


