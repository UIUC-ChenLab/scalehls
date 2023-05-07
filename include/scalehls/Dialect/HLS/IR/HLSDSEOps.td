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

def SpaceOp : HLSOp<"dse.space", [IsolatedFromAbove, NoTerminator, SymbolTable,
      Symbol, SingleBlock, ParentOneOf<["mlir::ModuleOp", "SpaceOp"]>]> {
  let summary = "Declare a design space";
  let description = [{
    SpaceOp declares a design space. The design space is a collection of
    parameters and constraints. The parameters are declared with ParamOp and
    the constraints are declared with RequireOp. The design space can be nested
    to form a hierarchy of design spaces.
  }];

  let arguments = (ins Variadic<AnyType>:$args, SymbolNameAttr:$sym_name);
  let regions = (region SizedRegion<1>:$body);
  let assemblyFormat = [{
    $sym_name `(` $args `)` attr-dict-with-keyword (`:` type($args)^)? $body
  }];

  let builders = [
    OpBuilder<(ins "std::string":$symName),
          "build($_builder, $_state, {}, $_builder.getStringAttr(symName));">
  ];

}

def ParamOp : HLSOp<"dse.param", [Symbol, HasParent<"SpaceOp">]> {
  let summary = "Declare a design space parameter";
  let description = [{
    ParamOp declares a design space parameter. The parameter can either be
    constrained by a range of values defined with affine lower and upper boundes
    or a list of candidates. The parameter has a symbolic name that can be used
    to refer to by GetParamOp in the payload IR. The parameter can optionally
    have a tentative value.
  }];

  let arguments = (ins Variadic<Index>:$args, OptionalAttr<IndexAttr>:$step,
      OptionalAttr<AffineMapAttr>:$bounds, OptionalAttr<ArrayAttr>:$candidates,
      ParamKindAttr:$kind, OptionalAttr<AnyAttr>:$value,
      SymbolNameAttr:$sym_name
  );
  let results = (outs AnyType:$result);

  let assemblyFormat = [{
    $sym_name $kind (`candidates` $candidates^)?
    (`range` `(` $args `)` $bounds `step` $step^)? attr-dict `:` type($result)
  }];

  let builders = [
    // Parameter builder constrained by candidates.
    OpBuilder<(ins "mlir::Type":$result, "mlir::ArrayAttr":$candidates,
        "ParamKind":$kind, "std::string":$symName), [{
          build($_builder, $_state, result, {}, nullptr, nullptr, candidates,
              ParamKindAttr::get($_builder.getContext(), kind), nullptr,
              $_builder.getStringAttr(symName));
        }]>,

    // Parameter builder constrained by affine lower and upper bounds.
    OpBuilder<(ins "mlir::Type":$result, "mlir::ValueRange":$args,
        "unsigned":$step, "mlir::AffineMap":$bounds, "ParamKind":$kind,
        "std::string":$symName), [{
          build($_builder, $_state, result, args, $_builder.getIndexAttr(step),
              mlir::AffineMapAttr::get(bounds), nullptr,
              ParamKindAttr::get($_builder.getContext(), kind), nullptr,
              $_builder.getStringAttr(symName));
        }]>,
    OpBuilder<(ins "mlir::Type":$result, "mlir::ValueRange":$args,
        "mlir::AffineMap":$bounds, "ParamKind":$kind, "std::string":$symName),
        "build($_builder, $_state, result, args, 1, bounds, kind, symName);">,

    // Parameter builder without constraints.
    OpBuilder<(ins "mlir::Type":$result, "ParamKind":$kind,
        "std::string":$symName),
        "build($_builder, $_state, result, nullptr, kind, symName);">
  ];

  let hasVerifier = 1;
  let hasCanonicalizer = 1;
  let hasFolder = 1;

  let extraClassDeclaration = [{
    /// Check the parameter's constraint type.
    bool isRangeConstrained() {
      return getBounds().has_value() && getStep().has_value();
    }
    bool isCandidateConstrained() { return getCandidates().has_value(); }
    bool isUnconstrained() {
      return !isRangeConstrained() && !isCandidateConstrained();
    }

    /// Get the upper or lower bound expression.
    mlir::AffineExpr getLowerBound() {
      assert(isRangeConstrained() && "parameter is not range constrained");
      return getBounds().value().getResult(0);
    }
    mlir::AffineExpr getUpperBound() {
      assert(isRangeConstrained() && "parameter is not range constrained");
      return getBounds().value().getResult(1);
    }

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

    SmallVector<GetParamOp, 8> getGetParamOps();
    SpaceOp getSpaceOp();
  }];
}

def GetParamOp : HLSOp<"dse.get_param", [NoMemoryEffect,
      DeclareOpInterfaceMethods<SymbolUserOpInterface>]> {
  let summary = "Get the value of a design space parameter";
  let description = [{
    GetParamOp gets the value of a design space parameter. The parameter is
    identified by its symbolic name.
  }];

  let arguments = (ins SymbolRefAttr:$param);
  let results = (outs AnyType:$result);
  let assemblyFormat = "$param attr-dict `:` type($result)";

  let hasVerifier = 1;
  let builders = [
    OpBuilder<(ins "mlir::Type":$result, "std::string":$spaceName,
        "std::string":$paramName), [{
          auto rootAttr = $_builder.getStringAttr(spaceName);
          auto leafAttr = $_builder.getStringAttr(paramName);
          build($_builder, $_state, result, mlir::SymbolRefAttr::get(
              rootAttr, {mlir::FlatSymbolRefAttr::get(leafAttr)}));
        }]>
  ];
}

def ConstParamOp : HLSOp<"dse.const_param", [NoMemoryEffect, ConstantLike]> {
  let summary = "Declare a design space constant parameter";

  let arguments = (ins ParamKindAttr:$kind, AnyAttr:$value);
  let results = (outs AnyType:$result);
  let builders = [
    OpBuilder<(ins "mlir::Type":$result, "ParamKind":$kind, "unsigned":$value),
        [{
          build($_builder, $_state, result, kind,
            $_builder.getIndexAttr(value));
        }]>,
    OpBuilder<(ins "mlir::Type":$result, "ParamKind":$kind,
        "MemoryKind":$mem_kind), [{
          build($_builder, $_state, result, kind,
              MemoryKindAttr::get($_builder.getContext(), mem_kind));
        }]>,
    OpBuilder<(ins "mlir::Type":$result, "ParamKind":$kind,
        "std::string":$library, "std::string":$name), [{
          build($_builder, $_state, result, kind,
              IPIdentifierAttr::get($_builder.getContext(), library, name));
        }]>
  ];

  let assemblyFormat = "$kind attr-dict `:` type($result)";
  let hasFolder = 1;
  let hasVerifier = 1;
}

def RequireOp : HLSOp<"dse.require", [NoMemoryEffect,
      SingleBlockImplicitTerminator<"RequireOp">, HasParent<"SpaceOp">]> {
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
