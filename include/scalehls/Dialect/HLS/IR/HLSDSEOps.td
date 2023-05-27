//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLS_HLSDSEOPS_TD
#define SCALEHLS_DIALECT_HLS_HLSDSEOPS_TD

//===----------------------------------------------------------------------===//
// Design Space Exploration (DSE) Operations
//===----------------------------------------------------------------------===//

def SpaceOp : HLSOp<"dse.space", [IsolatedFromAbove, SymbolTable, Symbol,
      SingleBlockImplicitTerminator<"SpacePackOp">,
      ParentOneOf<["mlir::ModuleOp", "SpaceOp"]>]> {
  let summary = "Declare a design space";
  let description = [{
    SpaceOp declares a design space. The space is a collection of parameters,
    constraints, and sub-spaces, declared with ParamOp, RequireOp, and nested
    SpaceOp, respectively. The space has a symbolic name that can be used to
    refer to by GetSpaceOp in the payload IR.
  }];

  let arguments = (ins Variadic<AnyType>:$hyper_params,
                       SymbolNameAttr:$sym_name);
  let results = (outs SpaceType:$result);
  let regions = (region SizedRegion<1>:$body);
  let assemblyFormat = [{
    $sym_name `(` $hyper_params `)` attr-dict `:`
    functional-type($hyper_params, $result) $body
  }];

  let builders = [
    OpBuilder<(ins "ValueRange":$hyperParams, "StringRef":$symName), [{
      build($_builder, $_state, SpaceType::get($_builder.getContext()),
          hyperParams, $_builder.getStringAttr(symName));
    }]>,
    OpBuilder<(ins "StringRef":$symName), [{
      build($_builder, $_state, {}, $_builder.getStringAttr(symName));
    }]>
  ];
}

def SpaceSelectOp : HLSOp<"dse.space_select", [NoMemoryEffect,
      HasParent<"SpaceOp">]> {
  let summary = "Select a design space based on conditions";
  let description = [{
    SpaceSelectOp takes a single value as argument, which is compared against
    the conditions. The first condition that evaluates to be equal to the
    argument determines the space to be selected.
  }];

  let arguments = (ins AnyType:$arg, Variadic<SpaceType>:$spaces,
                       ArrayAttr:$conditions);
  let results = (outs SpaceType:$result);
  let assemblyFormat = [{
    $arg $conditions $spaces attr-dict `:` type($arg) `,`
    functional-type($spaces, $result)
  }];

  let hasFolder = 1;
}

def SpacePackOp : HLSOp<"dse.space_pack", [Terminator, HasParent<"SpaceOp">]> {
  let summary = "Pack the parameters and sub-spaces of a design space";
  let description = [{
    SpacePackOp packs the parameters and sub-spaces of a design space and
    terminate the space. The packed parameters can optionally be named.
  }];

  let arguments = (ins Variadic<AnyType>:$args,
                       OptionalAttr<StrArrayAttr>:$names);
  let assemblyFormat = "$args ($names^)? attr-dict (`:` type($args)^)?";

  let builders = [
    OpBuilder<(ins "mlir::ValueRange":$args), [{
      build($_builder, $_state, args, nullptr);
    }]>,
    OpBuilder<(ins), "build($_builder, $_state, {});">
  ];
}

def SpaceUnpackOp : HLSOp<"dse.space_unpack", [NoMemoryEffect]> {
  let summary = "Unpack the parameters and sub-spaces of a design space";
  let description = [{
    SpaceUnpackOp unpacks the parameters and sub-spaces of a design space.
  }];

  let arguments = (ins SpaceType:$space);
  let results = (outs Variadic<AnyType>:$results);
  let assemblyFormat = [{
    $space attr-dict `:` functional-type($space, $results)
  }];
}

def GetSpaceOp : HLSOp<"dse.get_space", [NoMemoryEffect,
      DeclareOpInterfaceMethods<SymbolUserOpInterface>]> {
  let summary = "Get a design space with symbolic name";
  let description = [{
    GetSpaceOp gets a design space, which is identified by its symbolic name.
  }];

  let arguments = (ins SymbolRefAttr:$name);
  let results = (outs SpaceType:$space);
  let assemblyFormat = "$name attr-dict `:` type($space)";
}

def ParamOp : HLSOp<"dse.param", [Symbol, HasParent<"SpaceOp, DeclareOp">]> {
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
      OptionalAttr<AnyAttr>:$value, ParamKindAttr:$kind,
      SymbolNameAttr:$sym_name
  );
  let results = (outs AnyType:$result);

  let assemblyFormat = [{
    $sym_name $kind (`range` `(` $args `)` $bounds `step` $step^)?
    (`candidates` $candidates^)? attr-dict `:` type($result)
  }];

  let builders = [
    // Parameter builder constrained by candidates.
    OpBuilder<(ins "mlir::Type":$result, "mlir::ArrayAttr":$candidates,
        "ParamKind":$kind, "StringRef":$symName), [{
          build($_builder, $_state, result, {}, nullptr, nullptr, candidates,
              nullptr, ParamKindAttr::get($_builder.getContext(), kind),
              $_builder.getStringAttr(symName));
        }]>,

    // Parameter builder constrained by affine lower and upper bounds.
    OpBuilder<(ins "mlir::Type":$result, "mlir::ValueRange":$args,
        "unsigned":$step, "mlir::AffineMap":$bounds, "ParamKind":$kind,
        "StringRef":$symName), [{
          build($_builder, $_state, result, args, $_builder.getIndexAttr(step),
              mlir::AffineMapAttr::get(bounds), nullptr,
              nullptr, ParamKindAttr::get($_builder.getContext(), kind),
              $_builder.getStringAttr(symName));
        }]>,
    OpBuilder<(ins "mlir::Type":$result, "mlir::ValueRange":$args,
        "mlir::AffineMap":$bounds, "ParamKind":$kind, "StringRef":$symName),
          "build($_builder, $_state, result, args, 1, bounds, kind, symName);">,

    // Parameter builder without constraints.
    OpBuilder<(ins "mlir::Type":$result, "ParamKind":$kind,
        "StringRef":$symName),
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
    void assignValue(StringRef library, StringRef name) {
      assignValue(TaskImplAttr::get(getContext(), library, name));
    }

    SmallVector<GetParamOp, 8> getGetParamOps();
    SpaceOp getSpaceOp();
  }];
}

def ConstParamOp : HLSOp<"dse.const_param", [NoMemoryEffect, ConstantLike]> {
  let summary = "Declare a design space constant parameter";

  let arguments = (ins AnyAttr:$value, ParamKindAttr:$kind);
  let results = (outs AnyType:$result);
  let builders = [
    OpBuilder<(ins "mlir::Type":$result, "unsigned":$value, "ParamKind":$kind),
        [{
          build($_builder, $_state, result, $_builder.getIndexAttr(value),
              ParamKindAttr::get($_builder.getContext(), kind));
        }]>,
    OpBuilder<(ins "mlir::Type":$result, "MemoryKind":$mem_kind), [{
          build($_builder, $_state, result,
              MemoryKindAttr::get($_builder.getContext(), mem_kind),
              ParamKindAttr::get($_builder.getContext(), ParamKind::MEMORY_KIND));
        }]>,
    OpBuilder<(ins "mlir::Type":$result, "StringRef":$library,
        "StringRef":$name), [{
          build($_builder, $_state, result,
              TaskImplAttr::get($_builder.getContext(), library, name),
              ParamKindAttr::get($_builder.getContext(), ParamKind::TASK_IMPL));
        }]>
  ];

  let assemblyFormat = "$kind attr-dict `:` type($result)";
  let hasFolder = 1;
  let hasVerifier = 1;
}

def GetParamOp : HLSOp<"dse.get_param", [NoMemoryEffect,
      DeclareOpInterfaceMethods<SymbolUserOpInterface>]> {
  let summary = "Get the value of a design space parameter";
  let description = [{
    GetParamOp gets the value of a design space parameter. The parameter is
    identified by its symbolic name.
  }];

  let arguments = (ins SymbolRefAttr:$name);
  let results = (outs AnyType:$param);
  let assemblyFormat = "$name attr-dict `:` type($param)";

  let hasVerifier = 1;
}

def RequireOp : HLSOp<"dse.require", [IsolatedFromAbove, NoMemoryEffect,
      SingleBlockImplicitTerminator<"ConditionOp">, HasParent<"SpaceOp">]> {
  let summary = "Declare a design space requirement";
  let description = [{
    The design space requirement is represented by a single block terminated by
    ConditionOp, which can be deduced at runtime to prune the design space.
  }];

  let regions = (region SizedRegion<1>:$body);
  let assemblyFormat = "attr-dict-with-keyword $body";

  let hasVerifier = 1;
  let extraClassDeclaration = [{
    ConditionOp getConditionOp();
  }];
}

def ConditionOp : HLSOp<"dse.condition", [NoMemoryEffect, Terminator,
      AttrSizedOperandSegments, HasParent<"RequireOp">]> {
  let summary = "Terminate a constraint with requirement";
  let description = [{
    ConditionOp terminates a RequireOp. The condition can either be a boolean
    value (condition) or a list of affine parameters (args) with an integerset.
    The latter can enable trivial verification and canonicalization in some
    cases, so is preferred.
  }];

  let arguments = (ins Optional<I1>:$condition, Variadic<Index>:$args);
  let builders = [
    /// Condition builder with a boolean value.
    OpBuilder<(ins "mlir::Value":$condition), 
        "build($_builder, $_state, condition, {});">,

    /// Condition builder with no constraints.
    OpBuilder<(ins), "build($_builder, $_state, nullptr);">,

    /// Condition builder with integer set.
    OpBuilder<(ins "IntegerSet":$set, "ValueRange":$args)>
  ];

  // let hasCustomAssemblyFormat = 1;
  let hasVerifier = 1;
  let extraClassDeclaration = [{
    static StringRef getConditionAttrStrName() { return "condition"; }

    IntegerSet getIntegerSet();
    void setIntegerSet(IntegerSet newSet);

    /// Sets the integer set with its operands.
    void setConditional(IntegerSet set, ValueRange operands);

    RequireOp getRequireOp();
  }];
}

#endif // SCALEHLS_DIALECT_HLS_HLSDSEOPS_TD
