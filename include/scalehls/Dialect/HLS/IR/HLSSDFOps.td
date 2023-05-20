//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLS_HLSOPSSDF_TD
#define SCALEHLS_DIALECT_HLS_HLSOPSSDF_TD

//===----------------------------------------------------------------------===//
// Structural Dataflow (SDF) Operations
//===----------------------------------------------------------------------===//

def ScheduleOp : HLSOp<"sdf.schedule", [
      DeclareOpInterfaceMethods<MemoryEffectsOpInterface>, IsolatedFromAbove,
      AffineScope, SingleBlock, NoTerminator,
      ParentOneOf<["func::FuncOp", "affine::AffineForOp", "scf::ForOp"]>]> {
  let summary = "Represent a dataflow schedule";
  let description = [{
    Schedule op has an isolated region to contain a list of dataflow node ops to
    be scheduled. This op can be explicitly marked as legal when all the
    dataflow violations have been resolved and all the nodes has been scheduled.
  }];

  let arguments = (ins Variadic<AnyType>:$operands, UnitAttr:$isLegal);
  let regions = (region SizedRegion<1>:$body);
  let assemblyFormat = [{
    (`legal` $isLegal^)? (`(` $operands^ `)`)? attr-dict-with-keyword
    (`:` type($operands)^)? $body
  }];

  let hasVerifier = 1;
  let hasCanonicalizer = 1;

  let extraClassDeclaration = [{
    /// FIXME: Check whether the schedule is dependence free.
    bool isDependenceFree();

    /// Update the signature of the schedule op recursively.
    void updateSignatureRecursively();
  }];
}

def NodeOp : HLSOp<"sdf.node", [
      DeclareOpInterfaceMethods<MemoryEffectsOpInterface>,
      DeclareOpInterfaceMethods<ContainerLikeInterface>, IsolatedFromAbove,
      AffineScope, SingleBlock, NoTerminator, AttrSizedOperandSegments,
      HasParent<"ScheduleOp">]> {
  let summary = "Represent a dataflow node";
  let description = [{
    Node op has an isolated region to represent the ops contained by the node.
    The node can only take buffers or streams as inputs and outputs. Meanwhile,
    scalar values can be passed into a node as parameters, which will not be
    considered in the dataflow. An attribute "inputTaps" is used to represent
    the level of buffer or stream channel tap of each input.
  }];

  let arguments = (ins Variadic<AnyBufferOrStream>:$inputs,
      Variadic<AnyBufferOrStream>:$outputs, Variadic<AnyType>:$params,
      I32ArrayAttr:$inputTaps, OptionalAttr<I32Attr>:$level);
  let regions = (region SizedRegion<1>:$body);

  let assemblyFormat = [{
    `(` $inputs `)` `->` `(` $outputs `)` (`[` $params^ `]`)? attr-dict `:`
    functional-type($inputs, $outputs) (`[` type($params)^ `]`)? $body
  }];

  let hasVerifier = 1;
  let hasCanonicalizer = 1;
  let builders = [
    OpBuilder<(ins "mlir::ValueRange":$inputs, "mlir::ValueRange":$outputs,
        "mlir::ValueRange":$params, "ArrayRef<unsigned>":$inputTaps,
        "mlir::IntegerAttr":$level), [{
          auto newInputTaps = SmallVector<int32_t>(
            llvm::map_range(inputTaps, [](unsigned a) { return (int32_t)a; }));
          build($_builder, $_state, inputs, outputs, params,
                $_builder.getI32ArrayAttr(newInputTaps), level);
        }]>,

    OpBuilder<(ins "mlir::ValueRange":$inputs, "mlir::ValueRange":$outputs,
        "mlir::ValueRange":$params, "ArrayRef<unsigned>":$inputTaps), [{
          build($_builder, $_state, inputs, outputs, params, inputTaps, nullptr);
        }]>,
    OpBuilder<(ins "mlir::ValueRange":$inputs, "mlir::ValueRange":$outputs,
        "ArrayRef<unsigned>":$inputTaps), [{
          build($_builder, $_state, inputs, outputs, ValueRange(), inputTaps);
        }]>,

    OpBuilder<(ins "mlir::ValueRange":$inputs, "mlir::ValueRange":$outputs,
        "mlir::ValueRange":$params), [{
          build($_builder, $_state, inputs, outputs, params,
                SmallVector<unsigned>(inputs.size(), 0));
        }]>,
    OpBuilder<(ins "mlir::ValueRange":$inputs, "mlir::ValueRange":$outputs),
        "build($_builder, $_state, inputs, outputs, ValueRange());">
  ];

  let extraClassDeclaration = [{
    /// Get input taps.
    void setInputTap(unsigned idx, unsigned tap);
    unsigned getInputTap(unsigned idx);
    SmallVector<unsigned> getInputTapsAsInt();

    /// Get the number of inputs, outputs, and params.
    unsigned getNumInputs();
    unsigned getNumOutputs();
    unsigned getNumParams();

    /// Get the type of operand: input, output, or param.
    OperandKind getOperandKind(OpOperand &operand);
    OperandKind getOperandKind(unsigned operandIdx);

    /// Get the input, output, and param arguments.
    iterator_range<Block::args_iterator> getInputArgs();
    iterator_range<Block::args_iterator> getOutputArgs();
    iterator_range<Block::args_iterator> getParamArgs();

    bool hasHierarchy() {
      return cast<ContainerLikeInterface>(this->getOperation()).hasHierarchy();
    }

    /// Update the signature of the node op recursively.
    void updateSignatureRecursively();

    ScheduleOp getScheduleOp();
  }];
}

#endif // SCALEHLS_DIALECT_HLS_HLSOPSSDF_TD
