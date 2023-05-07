//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLS_HLSOPSUIP_TD
#define SCALEHLS_DIALECT_HLS_HLSOPSUIP_TD

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

def DeclareOp : HLSOp<"uip.declare", [IsolatedFromAbove, Symbol, NoTerminator,
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
}

def InstanceOp : HLSOp<"uip.instance", [AttrSizedOperandSegments,
      DeclareOpInterfaceMethods<SymbolUserOpInterface>]> {
  let summary = "Instantiate an IP declared by DeclareOp";

  let arguments = (ins Variadic<AnyType>:$inputs, Variadic<AnyType>:$outputs,
      Variadic<AnyType>:$params, SymbolRefAttr:$ip);
  let results = (outs Variadic<AnyType>:$results);
  let assemblyFormat = [{
    $ip `(` $inputs `)` `->` `(` $outputs `)` (`[` $params^ `]`)? attr-dict `:`
    functional-type($inputs, $outputs) (`[` type($params)^ `]`)?
    (`->` type($results)^)?
  }];
}

def TypeParamOp : HLSOp<"uip.type_param", [HasParent<"DeclareOp">]> {
  let summary = "Declare a type parameter of an IP";

  let arguments = (ins OptionalAttr<TypeArrayAttr>:$candidates, StrAttr:$name);
  let results = (outs TypeParamType:$result);

  let assemblyFormat = [{
    $name (`candidates` $candidates^)? attr-dict `:` type($result)
  }];

  let builders = [
    // Parameter builder constrained by candidates.
    OpBuilder<(ins "mlir::ArrayRef<Type>":$candidates, "std::string":$name), [{
          build($_builder, $_state, TypeParamType::get($_builder.getContext()),
              $_builder.getTypeArrayAttr(candidates),
              $_builder.getStringAttr(name));
        }]>,

    // Parameter builder without constraints.
    OpBuilder<(ins "std::string":$name), "build($_builder, $_state, {}, name);">
  ];
}

def ValueParamOp : HLSOp<"uip.value_param", [HasParent<"DeclareOp">]> {
  let summary = "Declare a value parameter of an IP";

  let arguments = (ins Variadic<Index>:$args, OptionalAttr<IndexAttr>:$step,
      OptionalAttr<AffineMapAttr>:$bounds, OptionalAttr<ArrayAttr>:$candidates,
      ValueParamKindAttr:$kind, StrAttr:$name);
  let results = (outs ValueParamType:$result);

  let assemblyFormat = [{
    $kind $name (`candidates` $candidates^)?
    (`range` `(` $args `)` $bounds `step` $step^)? attr-dict `:` type($result)
  }];

  let builders = [
    // Parameter builder constrained by candidates.
    OpBuilder<(ins "mlir::ArrayAttr":$candidates, "ValueParamKind":$kind,
        "std::string":$name), [{
          build($_builder, $_state, ValueParamType::get($_builder.getContext()),
              {}, nullptr, nullptr, candidates,
              ValueParamKindAttr::get($_builder.getContext(), kind),
              $_builder.getStringAttr(name));
        }]>,

    // Parameter builder constrained by affine lower and upper bounds.
    OpBuilder<(ins "mlir::ValueRange":$args, "unsigned":$step,
        "mlir::AffineMap":$bounds, "ValueParamKind":$kind, "std::string":$name),
        [{
          build($_builder, $_state, ValueParamType::get($_builder.getContext()),
              args, $_builder.getIndexAttr(step),
              mlir::AffineMapAttr::get(bounds), nullptr,
              ValueParamKindAttr::get($_builder.getContext(), kind),
              $_builder.getStringAttr(name));
        }]>,
    OpBuilder<(ins "mlir::ValueRange":$args, "mlir::AffineMap":$bounds,
        "ValueParamKind":$kind, "std::string":$name),
        "build($_builder, $_state, args, 1, bounds, kind, name);">,

    // Parameter builder without constraints.
    OpBuilder<(ins "ValueParamKind":$kind, "std::string":$name),
        "build($_builder, $_state, nullptr, kind, name);">
  ];

  let extraClassDeclaration = [{
    /// Check the parameter's constraint type.
    bool isRangeConstrained() {
      return getBounds().has_value() && getStep().has_value();
    }
    bool isCandidateConstrained() { return getCandidates().has_value(); }
    bool isUnconstrained() {
      return !isRangeConstrained() && !isCandidateConstrained();
    }
  }];
}

def PortOp : HLSOp<"uip.port", [HasParent<"DeclareOp">]> {
  let summary = "Declare a port of an IP";

  let arguments = (ins PortDirectionAttr:$direction, TypeParamType:$type,
      Variadic<ValueParamType>:$indices, MemRefLayoutAttrInterface:$layout,
      StrAttr:$name);
  let results = (outs PortType:$result);

  let assemblyFormat = [{
    $direction $name `type` $type `indices` `(` $indices `)` $layout attr-dict
    `:` type($result)
  }];
}

def IncludeOp : HLSOp<"uip.include", [HasParent<"DeclareOp">]> {
  let summary = "Declare a dependency of an IP";

  let arguments = (ins StrAttr:$name);
  let assemblyFormat = "$name attr-dict";
}

def SemanticsOp : HLSOp<"uip.semantics", [HasParent<"DeclareOp">, NoTerminator,
    SingleBlock]> {
  let summary = "Declare the semantics of an IP";

  let regions = (region SizedRegion<1>:$body);
  let assemblyFormat = "attr-dict-with-keyword $body";
}

#endif // SCALEHLS_DIALECT_HLS_HLSOPSUIP_TD
