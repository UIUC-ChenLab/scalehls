//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLS_HLSATTRIBUTES_TD
#define SCALEHLS_DIALECT_HLS_HLSATTRIBUTES_TD

include "scalehls/Dialect/HLS/IR/HLSDialect.td"
include "mlir/IR/AttrTypeBase.td"
include "mlir/IR/BuiltinAttributeInterfaces.td"
include "mlir/IR/EnumAttr.td"

class HLSAttr<string name, list<Trait> traits = []> :
    AttrDef<HLSDialect, name, traits>;

def IndexArrayAttr : TypedArrayAttrBase<IndexAttr, "index array attribute"> {
  let constBuilderCall = "$_builder.getIndexArrayAttr($0)";
}

//===----------------------------------------------------------------------===//
// MemoryKind Attribute
//===----------------------------------------------------------------------===//

def MemoryKind: I32EnumAttr<"MemoryKind", "Kind of memory", [
    I32EnumAttrCase<"UNKNOWN", 0, "unknown">,  
    I32EnumAttrCase<"LUTRAM_1P", 1, "lutram_1p">,
    I32EnumAttrCase<"LUTRAM_2P", 2, "lutram_2p">,
    I32EnumAttrCase<"LUTRAM_S2P", 3, "lutram_s2p">,
    I32EnumAttrCase<"BRAM_1P", 4, "bram_1p">,
    I32EnumAttrCase<"BRAM_2P", 5, "bram_2p">,
    I32EnumAttrCase<"BRAM_S2P", 6, "bram_s2p">,
    I32EnumAttrCase<"BRAM_T2P", 7, "bram_t2p">,
    I32EnumAttrCase<"URAM_1P", 8, "uram_1p">,
    I32EnumAttrCase<"URAM_2P", 9, "uram_2p">,
    I32EnumAttrCase<"URAM_S2P", 10, "uram_s2p">,
    I32EnumAttrCase<"URAM_T2P", 11, "uram_t2p">,
    I32EnumAttrCase<"DRAM", 12, "dram">]> {
  let cppNamespace = "mlir::scalehls::hls";
  let genSpecializedAttr = 0;
}
def MemoryKindParam: EnumParameter<MemoryKind>;
def MemoryKindAttr: EnumAttr<HLSDialect, MemoryKind> {
  let mnemonic = "memory";
  let assemblyFormat = "`<` $value `>`";
}

//===----------------------------------------------------------------------===//
// PartitionLayout Attribute
//===----------------------------------------------------------------------===//

def PartitionKind: I32EnumAttr<"PartitionKind", "Kind of array partition", [
    I32EnumAttrCase<"NONE", 0, "none">,
    I32EnumAttrCase<"CYCLIC", 1, "cyclic">,
    I32EnumAttrCase<"BLOCK", 2, "block">,
    I32EnumAttrCase<"COMPLETE", 3, "complete">]> {
  let cppNamespace = "mlir::scalehls::hls";
  let genSpecializedAttr = 0;
}
def PartitionKindParam: EnumParameter<PartitionKind>;

def PartitionLayoutAttr : HLSAttr<"PartitionLayout",
    [DeclareAttrInterfaceMethods<MemRefLayoutAttrInterface,
                                 ["verifyLayout"]>]> {
  let summary = "Layout of array partition";
  let parameters = (ins
    ArrayRefParameter<"hls::PartitionKind">:$kinds,
    ArrayRefParameter<"int64_t">:$factors
  );

  let genVerifyDecl = 1;
  let mnemonic = "partition";
  let assemblyFormat = "`<` `[` $kinds `]` `,` `[` $factors `]` `>`";

  let extraClassDeclaration = [{
    /// The affine map of "block" partition needs array shape to be inferenced.
    /// For example, if the partition factor is [2] and the shape of the array
    /// is [16], the affine map should be (d0) -> (d0 / 8, d0 % 8), where 8 is
    /// equal to 16 / 2. However, as the shape information is not known at the
    /// time of attribute construction, we can only encode factor [8] in the
    /// attribute instead of the actual factor [2]. This method returns the
    /// actual partition factor with the given array shape.
    SmallVector<int64_t> getActualFactors(ArrayRef<int64_t> shape);

    /// This method construct a PartitionLayoutAttr with the given partition
    /// kinds, actual partition factors, and array shape.
    static PartitionLayoutAttr getWithActualFactors(MLIRContext *context,
        ArrayRef<PartitionKind> kinds, ArrayRef<int64_t> actualFactors,
        ArrayRef<int64_t> shape);
  }];
}

#endif // SCALEHLS_DIALECT_HLS_HLSATTRIBUTES_TD
