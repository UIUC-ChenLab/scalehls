//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLS_HLSUIPOPS_TD
#define SCALEHLS_DIALECT_HLS_HLSUIPOPS_TD

//===----------------------------------------------------------------------===//
// Unified IP (UIP) Operations
//===----------------------------------------------------------------------===//

def LibraryOp : HLSOp<"uip.library", [IsolatedFromAbove, SymbolTable, Symbol,
      NoTerminator, SingleBlock, HasParent<"mlir::ModuleOp">]> {
  let summary = "Declare a library of IPs";

  let arguments = (ins SymbolNameAttr:$sym_name);
  let regions = (region SizedRegion<1>:$body);
  let assemblyFormat = "$sym_name attr-dict-with-keyword $body";
}

def DeclareOp : HLSOp<"uip.declare", [IsolatedFromAbove, SymbolTable, Symbol,
      SingleBlock, HasParent<"LibraryOp">]> {
  let summary = "Declare an IP";
  let description = [{
    DeclareOp declares an IP in the parent library. DeclareOp contains an region
    to hold the meta data of the IP, including parameter/input/output, includes,
    and the IP semantics.
  }];

  let arguments = (ins SymbolNameAttr:$sym_name);
  let regions = (region SizedRegion<1>:$meta);
  let assemblyFormat = "$sym_name attr-dict-with-keyword $meta";

  let extraClassDeclaration = [{
    LibraryOp getLibraryOp();
    SemanticsOp getSemanticsOp();
  }];
}

def InstanceOp : HLSOp<"uip.instance", [
      DeclareOpInterfaceMethods<SymbolUserOpInterface>]> {
  let summary = "Instantiate an IP declared by DeclareOp";

  let arguments = (ins Variadic<AnyType>:$ports, ArrayAttr:$templates,
      SymbolRefAttr:$name);
  let results = (outs Variadic<AnyType>:$results);

  let assemblyFormat = [{
    $name `<` $templates `>` `(` $ports `)` attr-dict `:`
    functional-type($ports, $results)
  }];

  let extraClassDeclaration = [{
    /// Get the type of operand: input, output, or param.
    PortKind getPortKind(OpOperand &operand);
    PortKind getPortKind(unsigned operandIdx);

    /// Get the tied op result of an output operand. Assert if the given operand
    /// is not an output.
    OpResult getTiedOpResult(OpOperand &operand);

    DeclareOp getDeclareOp();
  }];
}

def PortOp : HLSOp<"uip.port", [AttrSizedOperandSegments, Symbol, HasParent<"DeclareOp">]> {
  let summary = "Declare a port of an IP";

  let arguments = (ins TypeType:$type, Variadic<AnyType>:$sizes,
      MemRefLayoutAttrInterface:$layout, PortKindAttr:$kind, Variadic<AnyType>:$symbol_ref,
      OptionalAttr<TypedAttrInterface>:$value, SymbolNameAttr:$sym_name);
  let results = (outs PortType:$result);

  let assemblyFormat = [{
    $sym_name $kind `type` $type `sizes` `(` $sizes `)` `symbol_ref` `(` $symbol_ref `)` `(` type($symbol_ref) `)` $layout attr-dict
    `:` functional-type($sizes, $result) 
  }];
}

def IncludeOp : HLSOp<"uip.include", [HasParent<"DeclareOp">]> {
  let summary = "Declare the dependencies of an IP";

  let arguments = (ins StrArrayAttr:$paths);
  let assemblyFormat = "$paths attr-dict";
}

def IndexArrayAttr : TypedArrayAttrBase<IndexAttr, "index array attribute"> {
  let constBuilderCall = "$_builder.getIndexArrayAttr($0)";
}

def SemanticsOp : HLSOp<"uip.semantics", [Terminator, IsolatedFromAbove,
      AttrSizedOperandSegments, HasParent<"DeclareOp">,
      SingleBlockImplicitTerminator<"SemanticsOutputOp">]> {
  let summary = "Declare the semantics of an IP";

  let arguments = (ins Variadic<PortType>:$ports, Variadic<AnyType>:$templates,
      IndexArrayAttr:$args_map);
  let regions = (region SizedRegion<1>:$body);
  let assemblyFormat = [{
    (`<` $templates^ `>`)? `(` $ports `)` $args_map attr-dict `:`
    (`<` type($templates)^ `>`)? `(` type($ports) `)` $body
  }];

  let extraClassDeclaration = [{
    /// Initialize the block arguments. We create a tensor for each input and
    /// output. The tensor type is determined by the corresponding port type.
    void initializeBlockArguments(const SmallVectorImpl<Value> &ports);

    /// Get the immediate included linalg op. Will return nullptr if there is no
    /// such linalg op or more than one linalg op.
    linalg::LinalgOp getSemanticsLinalgOp();

    unsigned mapArgIndexToOperandIndex(unsigned argIndex);
    std::optional<unsigned> mapOperandIndexToArgIndex(unsigned operandIndex);

    DeclareOp getDeclareOp();
    SemanticsOutputOp getSemanticsOutputOp();

    PortKind getPortKind(OpOperand &operand);
    PortKind getPortKind(unsigned operandIdx);
  }];
}

def SemanticsOutputOp : HLSOp<"uip.semantics.output", [Terminator,
      AttrSizedOperandSegments, HasParent<"SemanticsOp">]> {
  let summary = "Terminate and yield results of a semantics op";

  let arguments = (ins Variadic<AnyType>:$sources, Variadic<AnyType>:$targets);
  let assemblyFormat = [{
    $sources `->` $targets attr-dict `:` functional-type($sources, $targets)
  }];

  let builders = [
    OpBuilder<(ins), [{
      build($_builder, $_state, ValueRange({}), ValueRange({}));
    }]>
  ];
  let extraClassDeclaration = [{
    SemanticsOp getSemanticsOp();
  }];
}

#endif // SCALEHLS_DIALECT_HLS_HLSUIPOPS_TD
