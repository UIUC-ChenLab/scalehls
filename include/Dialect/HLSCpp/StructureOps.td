//===-------------------------------------------------------*- tablegen -*-===//
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLSCPP_STRUCTUREOPS_TD
#define SCALEHLS_DIALECT_HLSCPP_STRUCTUREOPS_TD

def AssignOp : HLSCppOp<"assign", [SameOperandsAndResultType]> {
  let summary = "Assign input value to the output";
  let description = [{
    This hlscpp.assign operation assigns the input value to the output, and can
    be inserted anywhere without changing the original semantic. This is useful
    for EmitHLSCpp to handle some weird corner cases (e.g. the operand of return
    operation is function argument, and etc).
  }];

  let arguments = (ins AnyType : $input);
  let results = (outs AnyType : $output);
}

def ArrayOp : HLSCppOp<"array", [SameOperandsAndResultType]> {
  let summary = "A C++ array instance";
  let description = [{
    This hlscpp.array operation represent an array in C++. All shaped type value
    (e.g., memref, tensor, and vector) should be passed through this operation
    after declared by an allocation (e.g., Alloc, etc.) operation or in the
    signature of a function. This will help the compiler to easily manage the
    attributs and statistics of arrays.
  }];

  let arguments = (ins Type<IsShapedTypePred> : $input,

    // Interface-related attributes.
    DefaultValuedAttr<BoolAttr, "false"> : $interface,
    DefaultValuedAttr<InterfaceModeAttr, "bram"> : $interface_mode,
    DefaultValuedAttr<PositiveUI32Attr, "1024"> : $interface_depth,

    // BindStorage-related attributes.
    DefaultValuedAttr<BoolAttr, "false"> : $storage,
    DefaultValuedAttr<StorageTypeAttr, "ram_2p"> : $storage_type,
    DefaultValuedAttr<StorageImplAttr, "bram"> : $storage_impl,

    // ArrayPartition-related attributes.
    DefaultValuedAttr<BoolAttr, "false"> : $partition,
    DefaultValuedAttr<PartitionTypeArrayAttr, "{}"> : $partition_type,
    DefaultValuedAttr<PositiveUI32ArrayAttr, "{}"> : $partition_factor
  );

  let results = (outs Type<IsShapedTypePred> : $output);
}

def EndOp : HLSCppOp<"end", [Terminator]> {
  let summary = "Mark the end of a HLSCpp region";
  let description = [{
    This hlscpp.end operation marks the end of a region in the HLSCpp dialect.
  }];
}

#endif // SCALEHLS_DIALECT_HLSCPP_STRUCTUREOPS_TD
