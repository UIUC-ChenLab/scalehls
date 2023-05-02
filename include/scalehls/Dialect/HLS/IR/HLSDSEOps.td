//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLS_HLSOPSDSE_TD
#define SCALEHLS_DIALECT_HLS_HLSOPSDSE_TD

//===----------------------------------------------------------------------===//
// Design Space Exploration (DSE) Operations
//===----------------------------------------------------------------------===//

def ParamOp : HLSOp<"dse.param", [NoMemoryEffect,
      DeclareOpInterfaceMethods<Symbol>]> {
  let summary = "Declare a design space parameter";
  let description = [{
    ParamOp declares a design space parameter. The parameter can be used in
    other operations to represent a design space variable. The parameter can
    optionally have a default value, whose presence indicates that this
    operation can be considered as a constant. The parameter can either
    constrained by a range of values defined with affine lower and upper boundes
    or a list of candidates. The parameter has a symbolic name that can be used
    to refer to through GetParamOp for constructing additional constraints.
  }];

  let arguments = (ins Variadic<Index>:$args,
      OptionalAttr<AffineMapAttr>:$lower_bound,
      OptionalAttr<AffineMapAttr>:$upper_bound,
      OptionalAttr<ArrayAttr>:$candidates,
      ParamKindAttr:$kind, OptionalAttr<AnyAttr>:$value,
      OptionalAttr<SymbolNameAttr>:$sym_name
  );
  let results = (outs AnyType:$result);

  let assemblyFormat = [{
    $kind $sym_name (`candidates` $candidates^)?
    (`range` `(` $args `)` `from` $lower_bound^ `to` $upper_bound)?
    (`<` $value^ `>`)? attr-dict `:` type($result)
  }];

  let hasVerifier = 1;
  let builders = [
    // Parameter builder constrained by candidates.
    OpBuilder<(ins "mlir::Type":$result, "mlir::ArrayAttr":$candidates,
        "ParamKind":$kind, "mlir::StringAttr":$symName), [{
          build($_builder, $_state, result, {}, nullptr, nullptr, candidates,
            ParamKindAttr::get($_builder.getContext(), kind), nullptr, symName);
        }]>,

    // Parameter builder constrained by affine lower and upper bounds.
    OpBuilder<(ins "mlir::Type":$result, "mlir::ValueRange":$args,
        "mlir::AffineMap":$lowerBound, "mlir::AffineMap":$upperBound,
        "ParamKind":$kind, "mlir::StringAttr":$symName), [{
          build($_builder, $_state, result, args,
            mlir::AffineMapAttr::get(lowerBound),
            mlir::AffineMapAttr::get(upperBound), nullptr,
            ParamKindAttr::get($_builder.getContext(), kind), nullptr, symName);
        }]>,

    // Parameter builder without constraints.
    OpBuilder<(ins "mlir::Type":$result, "ParamKind":$kind,
        "mlir::StringAttr":$symName), [{
          build($_builder, $_state, result, nullptr, kind, symName);
        }]>
  ];

  let extraClassDeclaration = [{
    /// Assign a value to the parameter.
    void assignValue(Attribute value) { setValueAttr(value); }
    void assignValue(unsigned value) {
      assignValue(Builder(getContext()).getIndexAttr(value));
    }
    void assignValue(MemoryKind kind) {
      assignValue(MemoryKindAttr::get(getContext(), kind));
    }
    void assignValue(std::string library, std::string name) {
      assignValue(IPIdentifierAttr::get(getContext(), library, name));
    }

    /// Get all constraints of the parameter.
    SmallVector<Operation *> getConstraints();
  }];
}

def RequireOp : HLSOp<"dse.require", [NoMemoryEffect, IsolatedFromAbove,
      SingleBlockImplicitTerminator<"RequireOp">, HasParent<"ModuleOp">]> {
  let summary = "Declare a design space constraint";
  let description = [{
    RequireOp declares a design space constraint. The constraint is represented
    by a single block terminated by RequireOp. The constraint can be deduced at
    runtime to prune the design space.
  }];

  let regions = (region SizedRegion<1>:$body);
  let assemblyFormat = "attr-dict-with-keyword $body";

  let hasVerifier = 1;
  let extraClassDeclaration = [{
    /// Get the terminator condition op.
    ConditionOp getConditionOp();
  }];
}

def GetParamOp : HLSOp<"dse.get_param", [NoMemoryEffect,
      DeclareOpInterfaceMethods<SymbolUserOpInterface>,
      HasParent<"RequireOp">]> {
  let summary = "Get the value of a design space parameter";
  let description = [{
    GetParamOp gets the value of a design space parameter. The parameter is
    identified by its symbolic name.
  }];

  let arguments = (ins FlatSymbolRefAttr:$param);
  let results = (outs AnyType:$result);
  let assemblyFormat = "$param attr-dict `:` type($result)";

  let hasVerifier = 1;
  let extraClassDeclaration = [{
    /// Get the parent require op.
    RequireOp getRequireOp();
  }];
}

def ConditionOp : HLSOp<"dse.condition", [NoMemoryEffect, Terminator,
      AttrSizedOperandSegments, HasParent<"ConditionOp">]> {
  let summary = "Terminate a constraint with requirement";
  let description = [{
    ConditionOp terminates a ConstaintOp with a requirement. The requirement can
    either be a boolean value (condition) or a list of affine parameters (args)
    with an integerset. The latter can enable trivial verification and
    canonicalization in some cases, so is preferred.
  }];

  let arguments = (ins Optional<I1>:$condition, Variadic<Index>:$args);
  let builders = [
    /// Condition builder with a boolean value.
    OpBuilder<(ins "mlir::Value":$condition), 
        "build($_builder, $_state, condition, {});">,

    /// Condition builder with integer set.
    OpBuilder<(ins "IntegerSet":$set, "ValueRange":$args)>
  ];

  // let hasCustomAssemblyFormat = 1;
  let hasVerifier = 1;
  let extraClassDeclaration = [{
    /// Get the parent require op.
    RequireOp getRequireOp();
    
    static StringRef getConditionAttrStrName() { return "condition"; }

    IntegerSet getIntegerSet();
    void setIntegerSet(IntegerSet newSet);

    /// Sets the integer set with its operands.
    void setConditional(IntegerSet set, ValueRange operands);
  }];
}

#endif // SCALEHLS_DIALECT_HLS_HLSOPSDSE_TD
