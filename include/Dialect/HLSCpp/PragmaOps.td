//===-------------------------------------------------------*- tablegen -*-===//
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLSCPP_PRAGMAOPS_TD
#define SCALEHLS_DIALECT_HLSCPP_PRAGMAOPS_TD

def LoopPragmaOp : HLSCppOp<"loop_pragma", [
  PragmaOpInterface,
  HasParent<"AffineForOp">
]> {
  let summary = "Apply loop pragmas";
  let description = [{
    This hlscpp.loop_pragma operation represent pragmas for loops, such as
    pipeline, and unroll pragma.
  }];

  let arguments = (ins
    // Pipeline pragma-related attributes.
    Confined<UI32Attr, [IntPositive]> : $II,
    BoolAttr : $enable_flush,
    BoolAttr : $rewind,
    BoolAttr : $off,

    // Unroll pragma-related attributes.
    Confined<UI32Attr, [IntPositive]> : $factor,
    BoolAttr : $region,
    BoolAttr : $skip_exit_check
  );

  let extraClassDeclaration = [{
    // Pipeline pragma-related methods.
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

    // Unroll pragma-related methods.
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

def FuncPragmaOp : HLSCppOp<"func_pragma", [
  PragmaOpInterface,
  HasParent<"FuncOp">
]> {
  let summary = "Apply function pragmas";
  let description = [{
    This hlscpp.func_pragma operation represent pragmas for functions, such as
    pipeline, and dataflow pragma.
  }];

  let arguments = (ins
    // Pipeline pragma-related attributes.
    Confined<UI32Attr, [IntPositive]> : $II,
    BoolAttr : $enable_flush,
    BoolAttr : $rewind,
    BoolAttr : $off,

    // Dataflow pragma-related attributes.
    BoolAttr : $dataflow
  );

  let extraClassDeclaration = [{
    // Pipeline pragma-related methods.
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

    // Dataflow pragma-related methods.
    bool isDataflow() {
      return getAttrOfType<BoolAttr>("dataflow").getValue();
    }
  }];
}

def ArrayPragmaOp : HLSCppOp<"array_pragma", [
  PragmaOpInterface
]> {
  let summary = "Apply array pragmas";
  let description = [{
    This hlscpp.func_pragma operation represent pragmas for arrays, such as
    array partition, interface, and bind storage pragma.
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
