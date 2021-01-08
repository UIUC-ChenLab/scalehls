//===-------------------------------------------------------*- tablegen -*-===//
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLSCPP_ATTRIBUTES_TD
#define SCALEHLS_DIALECT_HLSCPP_ATTRIBUTES_TD

//===----------------------------------------------------------------------===//
// Pragma Interface Attributes (for array ports)
//===----------------------------------------------------------------------===//

def InterfaceModeAttr : StrEnumAttr<"InterfaceMode", "", [
  StrEnumAttrCase<"bram", 0>,
  StrEnumAttrCase<"m_axi", 1>
]> {
  let cppNamespace = "::mlir::scalehls::hlscpp";
}

//===----------------------------------------------------------------------===//
// Pragma bind_storage Attributes
//===----------------------------------------------------------------------===//

// Currently we only support bram/lut based memory instance.
def StorageTypeAttr : StrEnumAttr<"StorageType", "", [
  StrEnumAttrCase<"ram_1p_bram", 0>,
  StrEnumAttrCase<"ram_2p_bram", 1>,
  StrEnumAttrCase<"ram_s2p_bram", 2>,
  StrEnumAttrCase<"ram_t2p_bram", 3>
]> {
  let cppNamespace = "::mlir::scalehls::hlscpp";
}

#endif // SCALEHLS_DIALECT_HLSCPP_ATTRIBUTES_TD
