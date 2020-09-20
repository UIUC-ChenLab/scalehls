//===-------------------------------------------------------*- tablegen -*-===//
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLSCPP_ATTRIBUTES_TD
#define SCALEHLS_DIALECT_HLSCPP_ATTRIBUTES_TD

//===----------------------------------------------------------------------===//
// Customized Attributes
//===----------------------------------------------------------------------===//

def PositiveUI32Attr : Confined<UI32Attr, [IntPositive]> {}
def PositiveUI32ArrayAttr : TypedArrayAttrBase<PositiveUI32Attr, ""> {}

def UI32ArrayAttr : TypedArrayAttrBase<UI32Attr, ""> {}

//===----------------------------------------------------------------------===//
// Pragma bind_storage Constraints
//===----------------------------------------------------------------------===//

def LegalStorageType : AttrConstraint<Or<[
  CPred<"$_self.cast<StringAttr>().getValue() == \"fifo\"">,
  CPred<"$_self.cast<StringAttr>().getValue() == \"ram_1p\"">,
  CPred<"$_self.cast<StringAttr>().getValue() == \"ram_1wnr\"">,
  CPred<"$_self.cast<StringAttr>().getValue() == \"ram_2p\"">,
  CPred<"$_self.cast<StringAttr>().getValue() == \"ram_s2p\"">,
  CPred<"$_self.cast<StringAttr>().getValue() == \"ram_t2p\"">
]>>;

def LegalStorageImpl : AttrConstraint<Or<[
  CPred<"$_self.cast<StringAttr>().getValue() == \"bram\"">,
  CPred<"$_self.cast<StringAttr>().getValue() == \"lutram\"">,
  CPred<"$_self.cast<StringAttr>().getValue() == \"uram\"">,
  CPred<"$_self.cast<StringAttr>().getValue() == \"srl\"">
]>>;

//===----------------------------------------------------------------------===//
// Pragma array_partition Constraints
//===----------------------------------------------------------------------===//

def LegalPartitionType : AttrConstraint<Or<[
  CPred<"$_self.cast<StringAttr>().getValue() == \"cyclic\"">,
  CPred<"$_self.cast<StringAttr>().getValue() == \"block\"">,
  CPred<"$_self.cast<StringAttr>().getValue() == \"complete\"">
]>>;

//===----------------------------------------------------------------------===//
// Pragma bind_op Constraints
//===----------------------------------------------------------------------===//

def LegalOpImpl : AttrConstraint<Or<[
  CPred<"$_self.cast<StringAttr>().getValue() == \"dsp\"">,
  CPred<"$_self.cast<StringAttr>().getValue() == \"fabric\"">,
  CPred<"$_self.cast<StringAttr>().getValue() == \"meddsp\"">,
  CPred<"$_self.cast<StringAttr>().getValue() == \"fulldsp\"">,
  CPred<"$_self.cast<StringAttr>().getValue() == \"maxdsp\"">,
  CPred<"$_self.cast<StringAttr>().getValue() == \"primitivedsp\"">
]>>;

#endif // SCALEHLS_DIALECT_HLSCPP_ATTRIBUTES_TD
