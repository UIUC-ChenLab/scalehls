//===-------------------------------------------------------*- tablegen -*-===//
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLSCPP_OPS_TD
#define SCALEHLS_DIALECT_HLSCPP_OPS_TD

include "Interfaces.td"
include "mlir/Interfaces/SideEffectInterfaces.td"

def ApplyPragmasOp : HLSCppOp<"apply_pragmas", [
  PragmaOpInterface,
  SingleBlockImplicitTerminator<"EndOp">
]> {
  let summary = "hlscpp.apply_pragmas operation";
  let description = [{
    This hlscpp.apply_pragmas operation owns one region containing one or more
    concrete pragmas, and applies all of them to its parent operation (e.g.,
    functions, loops, or other regions). This operation should always be
    inserted to the front of its parent operation. For detailed description of
    each concrete pragma, please refer to:
    https://www.xilinx.com/html_docs/xilinx2020_1/vitis_doc/hlspragmas.html
  }];

  let regions = (region SizedRegion<1> : $pragmaRegion);

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
  let summary = "hlscpp.pragma_pipeline operation";
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
  let summary = "hlscpp.pragma_unroll operation";
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

def LegalPartitionType : AttrConstraint<Or<[
  CPred<"$_self.cast<StringAttr>().getValue() == \"cyclic\"">,
  CPred<"$_self.cast<StringAttr>().getValue() == \"block\"">,
  CPred<"$_self.cast<StringAttr>().getValue() == \"complete\"">
]>>;

def PragmaArrayPartitionOp : HLSCppOp<"pragma_array_partition", [
  PragmaOpInterface
]> {
  let summary = "hlscpp.pragma_array_partition operation";
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

def EndOp : HLSCppOp<"end", [Terminator]> {
  let summary = "hlscpp.end operation";
  let description = [{
    This hlscpp.end operation marks the end of a region in the HLSCpp dialect.
  }];
}

#endif // SCALEHLS_DIALECT_HLSCPP_OPS_TD
