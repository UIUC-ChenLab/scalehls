//===-------------------------------------------------------*- tablegen -*-===//
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLSCPP_ATTRIBUTES_TD
#define SCALEHLS_DIALECT_HLSCPP_ATTRIBUTES_TD

//===----------------------------------------------------------------------===//
// Customized ui32 Attributes
//===----------------------------------------------------------------------===//

def PositiveUI32Attr : Confined<UI32Attr, [IntPositive]> {}

def UI32ArrayAttr : TypedArrayAttrBase<UI32Attr, ""> {}
def PositiveUI32ArrayAttr : TypedArrayAttrBase<PositiveUI32Attr, ""> {}

//===----------------------------------------------------------------------===//
// Pragma array_partition Attributes
//===----------------------------------------------------------------------===//

def PartitionTypeAttr : StrEnumAttr<"PartitionType", "", [
  StrEnumAttrCase<"cyclic", 0>,
  StrEnumAttrCase<"block", 1>,
  StrEnumAttrCase<"complete", 2>,
  StrEnumAttrCase<"none", 3>
]> {
  let cppNamespace = "::mlir::scalehls::hlscpp";
}

def PartitionTypeArrayAttr : TypedArrayAttrBase<PartitionTypeAttr, ""> {}

//===----------------------------------------------------------------------===//
// Pragma bind_storage Attributes
//===----------------------------------------------------------------------===//

// def StorageImplAttr : StrEnumAttr<"StorageImpl", "", [
//   StrEnumAttrCase<"bram", 0>,
//   StrEnumAttrCase<"lutram", 1>,
//   StrEnumAttrCase<"uram", 2>,
//   StrEnumAttrCase<"srl", 3>
// ]> {
//   let cppNamespace = "::mlir::scalehls::hlscpp";
// }

// def StorageTypeAttr : StrEnumAttr<"StorageType", "", [
//   StrEnumAttrCase<"fifo", 0>,
//   StrEnumAttrCase<"ram_1p", 1>,
//   StrEnumAttrCase<"ram_1wnr", 2>,
//   StrEnumAttrCase<"ram_2p", 3>,
//   StrEnumAttrCase<"ram_s2p", 4>,
//   StrEnumAttrCase<"ram_t2p", 5>
// ]> {
//   let cppNamespace = "::mlir::scalehls::hlscpp";
// }

// Currently we only support bram/lut based memory instance.
def StorageTypeAttr : StrEnumAttr<"StorageType", "", [
  StrEnumAttrCase<"ram_1p_bram", 0>,
  StrEnumAttrCase<"ram_2p_bram", 1>,
  StrEnumAttrCase<"ram_s2p_bram", 2>,
  StrEnumAttrCase<"ram_t2p_bram", 3>
]> {
  let cppNamespace = "::mlir::scalehls::hlscpp";
}

//===----------------------------------------------------------------------===//
// Pragma Interface Attributes (for array rather than scalar ports)
//===----------------------------------------------------------------------===//

def InterfaceModeAttr : StrEnumAttr<"InterfaceMode", "", [
  StrEnumAttrCase<"bram", 0>,
  StrEnumAttrCase<"m_axi", 1>
]> {
  let cppNamespace = "::mlir::scalehls::hlscpp";
}

#endif // SCALEHLS_DIALECT_HLSCPP_ATTRIBUTES_TD
