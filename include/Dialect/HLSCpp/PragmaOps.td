//===-------------------------------------------------------*- tablegen -*-===//
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLSCPP_PRAGMAOPS_TD
#define SCALEHLS_DIALECT_HLSCPP_PRAGMAOPS_TD

def ArrayPragmaOp : HLSCppOp<"array_pragma", [
  PragmaOpInterface
]> {
  let summary = "Apply array pragmas";
  let description = [{
    This hlscpp.func_pragma operation represent pragmas for arrays, such as
    array partition, interface, and bind storage pragma.
  }];

  let arguments = (ins
    // Targeted array.
    Type<IsShapedTypePred> : $variable,

    // Interface-related attributes.
    DefaultValuedAttr<BoolAttr, "false"> : $interface,
    DefaultValuedAttr<InterfaceModeAttr, "m_axi"> : $interface_mode,
    DefaultValuedAttr<PositiveUI32Attr, "1024"> : $interface_depth,

    // BindStorage-related attributes.
    DefaultValuedAttr<StorageTypeAttr, "ram_2p"> : $storage_type,
    DefaultValuedAttr<StorageImplAttr, "bram"> : $storage_impl,

    // ArrayPartition-related attributes.
    DefaultValuedAttr<BoolAttr, "false"> : $partition,
    DefaultValuedAttr<PartitionTypeArrayAttr, "{}"> : $partition_type,
    DefaultValuedAttr<PositiveUI32ArrayAttr, "{}"> : $partition_factor
  );

  let assemblyFormat = [{`(` $variable `)` attr-dict `:` type($variable)}];
  let extraClassDeclaration = [{}];
}

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
    // Pipeline-related attributes.
    DefaultValuedAttr<BoolAttr, "false"> : $pipeline,
    DefaultValuedAttr<PositiveUI32Attr, "1"> : $pipeline_II,

    // Unroll-related attributes.
    DefaultValuedAttr<PositiveUI32Attr, "1"> : $unroll_factor
  );

  let assemblyFormat = [{attr-dict}];
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
    DefaultValuedAttr<BoolAttr, "false"> : $dataflow
  );

  let assemblyFormat = [{attr-dict}];
  let extraClassDeclaration = [{}];
}

#endif // SCALEHLS_DIALECT_HLSCPP_PRAGMAOPS_TD
