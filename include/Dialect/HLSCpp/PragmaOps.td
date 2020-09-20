//===-------------------------------------------------------*- tablegen -*-===//
//
//===----------------------------------------------------------------------===//

/// This file is deprecated and will be removed in the future.

#ifndef SCALEHLS_DIALECT_HLSCPP_PRAGMAOPS_TD
#define SCALEHLS_DIALECT_HLSCPP_PRAGMAOPS_TD

def ApplyPragmasOp : HLSCppOp<"apply_pragmas", [
  PragmaOpInterface,
  SingleBlockImplicitTerminator<"EndOp">
]> {
  let summary = "Apply pragmas to the parent operation";
  let description = [{
    This hlscpp.apply_pragmas operation owns one region containing one or more
    concrete pragmas, and applies all of them to its parent operation (e.g.,
    functions, loops, or other regions). This operation should always be
    inserted to the front of its parent operation. For detailed description of
    each concrete pragma, please refer to:
    https://www.xilinx.com/html_docs/xilinx2020_1/vitis_doc/hlspragmas.html
  }];

  let regions = (region SizedRegion<1> : $pragmaRegion);

  let skipDefaultBuilders = 1;
  let builders = [OpBuilder<"OpBuilder &builder, OperationState &state", [{
    auto &pragmaRegion = *state.addRegion();
    ApplyPragmasOp::ensureTerminator(pragmaRegion, builder, state.location);
  }]>];

  // TODO: verifier for this op:
  // (1) is in the front of its parent operation.
  // (2) only contains hlscpp pragma operation.

  let extraClassDeclaration = [{
    OpBuilder getBodyBuilder() {
      assert(!pragmaRegion().empty() && "Unexpected empty pragma region.");
      Block &body = pragmaRegion().front();
      return OpBuilder(&body, std::prev(body.end()));
    }
  }];
}

def PragmaPipelineOp : HLSCppOp<"pragma_pipeline", [
  PragmaOpInterface,
  HasParent<"ApplyPragmasOp">
]> {
  let summary = "Apply PIPELINE HLS pragma";
  let description = [{
    This hlscpp.pragma_pipeline operation represent the "#pragma HLS PIPELINE"
    directive in HLS C++.
  }];

  let arguments = (ins
    Confined<UI32Attr, [IntPositive]> : $II,
    BoolAttr : $enable_flush,
    BoolAttr : $rewind,
    BoolAttr : $off
  );

  let extraClassDeclaration = [{
    unsigned getII() {
      return getAttrOfType<IntegerAttr>("II").getUInt();
    }

    bool isEnableFlush() {
      return getAttrOfType<BoolAttr>("enable_flush").getValue();
    }

    bool isRewind() {
      return getAttrOfType<BoolAttr>("rewind").getValue();
    }

    bool isOff() {
      return getAttrOfType<BoolAttr>("off").getValue();
    }
  }];
}

def PragmaUnrollOp : HLSCppOp<"pragma_unroll", [
  PragmaOpInterface,
  HasParent<"ApplyPragmasOp">
]> {
  let summary = "Apply UNROLL HLS pragma";
  let description = [{
    This hlscpp.pragma_unroll operation represent the "#pragma HLS UNROLL"
    directive in HLS C++.
  }];

  let arguments = (ins
    Confined<UI32Attr, [IntPositive]> : $factor,
    BoolAttr : $region,
    BoolAttr : $skip_exit_check
  );

  let extraClassDeclaration = [{
    unsigned getFactor() {
      return getAttrOfType<IntegerAttr>("factor").getUInt();
    }

    bool isRegion() {
      return getAttrOfType<BoolAttr>("region").getValue();
    }

    bool isSkipExitCheck() {
      return getAttrOfType<BoolAttr>("skip_exit_check").getValue();
    }
  }];
}

def PragmaArrayPartitionOp : HLSCppOp<"pragma_array_partition", [
  PragmaOpInterface
]> {
  let summary = "Apply ARRAY_PARTITION HLS pragma to the input value";
  let description = [{
    This hlscpp.pragma_array_partition operation represent the "#pragma HLS 
    ARRAY_PARTITION" directive in HLS C++.
  }];

  let arguments = (ins 
    Type<IsShapedTypePred> : $variable,
    Confined<StrAttr, [LegalPartitionType]> : $type,
    Confined<UI32Attr, [IntPositive]> : $factor,
    Confined<UI32Attr, [IntNonNegative]> : $dim
  );

  // TODO: verifier for this op:
  // (1) dim is not larger than variable's dim.
  // (2) factor is not larger than variable's shape of the corresponding dim.

  let extraClassDeclaration = [{
    StringRef getPartitionType() {
      return getAttrOfType<StringAttr>("type").getValue();
    }

    unsigned getFactor() {
      return getAttrOfType<IntegerAttr>("factor").getUInt();
    }

    unsigned getDim() {
      return getAttrOfType<IntegerAttr>("dim").getUInt();
    }
  }];
}

#endif // SCALEHLS_DIALECT_HLSCPP_PRAGMAOPS_TD
