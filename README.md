# HLS Large Design Project (HLSLD)

## High Level Description of Project
Hanchen and Jack aim to create a framework that ultimately converts an algorithm written in a high level language into an efficient hardware implementation. Out of all of the existing deep learning compiler related projects, TVM and MLIR present existing tools that we can leverage in our proposed framework. With multiple levels of intermediate representations (IRs), MLIR appears to be the ideal tool for exploring ways to optimize the eventual design at various levels of abstraction (e.g. various levels of parallelism). Our framework will be based on MLIR, but it will incorporate a frontend for Sitao's powerful domain specific language (DSL) and a backend for high level synthesis (HLS) C/C++ code. However, the key contribution will be our parametrization and optimization of a tremendously large design space. So far, we are familiarizing ourselves with the existing MLIR flow using a toy example (simple neural network for MNIST digit classification) and figure out how to do this parametrization and optimization. 

## Hanchen TODO List
At a high level, Hanchen aims to leverage existing IPs within our framework based on MLIR. This necessitates the creation of a so-called fpgakrnl dialect in the context of MLIR.
1. Create an fpgakrnl dialect --> `include/fpgakrnl/Dialect.h`
2. Create conv and pool operations in fpgakrnl dialect --> `include/fpgakrnl/Ops.td`
3. Create pass for lowering conv and pool operations in ONNX dialect to fpgakrnl dialect

## Jack TODO List
At a high level, Jack aims to figure out what kind of transformations and lower passes are available within the most mature MLIR dialects so that he can set up the parametrization and optimization of the design space.
1. Find out how to do transformation and lowering passes within Affine, LinAlg, Loop dialects for the same two operations (conv, pool)

## References
1. [Toy Tutorial Chapter2: Emitting Basic MLIR](https://mlir.llvm.org/docs/Tutorials/Toy/Ch-2/#interfacing-with-mlir)
2. [ONNX-MLIR](https://github.com/onnx/onnx-mlir)
3. [DNNBuilder](https://github.com/IBM/AccDNN)


