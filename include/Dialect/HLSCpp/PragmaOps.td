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

  let extraClassDeclaration = [{}];
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

  let extraClassDeclaration = [{}];
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

  let extraClassDeclaration = [{}];
}

#endif // SCALEHLS_DIALECT_HLSCPP_PRAGMAOPS_TD
