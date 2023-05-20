//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLS_HLSOPSFDF_TD
#define SCALEHLS_DIALECT_HLS_HLSOPSFDF_TD

//===----------------------------------------------------------------------===//
// Functional Dataflow (FDF) Operations
//===----------------------------------------------------------------------===//

def DispatchOp : HLSOp<"fdf.dispatch", [RecursiveMemoryEffects,
      SingleBlockImplicitTerminator<"YieldOp">,
      ParentOneOf<["func::FuncOp", "affine::AffineForOp", "scf::ForOp"]>]> {
  let summary = "Represent a dataflow dispatch";
  let description = [{
    Dispatch op has a transparent region that contains a list of task ops to be
    dispatched. This op is designed to organize and manipulate task ops at a
    high level and will be lowered to schedule op for dataflow scheduling.
  }];

  let results = (outs Variadic<AnyType>:$results);
  let regions = (region SizedRegion<1>:$body);
  let assemblyFormat = "attr-dict-with-keyword (`:` type($results)^)? $body";

  let hasVerifier = 1;
  let hasCanonicalizer = 1;

  let extraClassDeclaration = [{
    YieldOp getYieldOp();
  }];
}

def TaskOp : HLSOp<"fdf.task", [
      DeclareOpInterfaceMethods<ContainerLikeInterface>, RecursiveMemoryEffects,
      AttrSizedOperandSegments, SingleBlockImplicitTerminator<"YieldOp">,
      HasParent<"DispatchOp">]> {
  let summary = "Represent a dataflow task";
  let description = [{
    Task op has a transparent region that contains a list of ops to be executed
    in the task. This op is designed to represent the task partition at a high
    level and will be lowered to node op for dataflow scheduling.
  }];

  let arguments = (ins Variadic<Index>:$tile_factors,
      Variadic<Index>:$parallel_factors,
      Optional<IPIdentifierType>:$ip_identifier);
  let results = (outs Variadic<AnyType>:$results);
  let regions = (region SizedRegion<1>:$body);

  let builders = [
    OpBuilder<(ins "mlir::TypeRange":$results),
        "build($_builder, $_state, results, {}, {}, nullptr);">,
    OpBuilder<(ins "mlir::TypeRange":$results, "mlir::ValueRange":$tileFactors,
        "mlir::ValueRange":$parallelFactors), [{
          build($_builder, $_state, results, tileFactors, parallelFactors,
          nullptr);
        }]>
  ];

  let assemblyFormat = [{
    (`tile` `(` $tile_factors^ `)`)? (`parallel` `(` $parallel_factors^ `)`)?
    (`ip` $ip_identifier^ `:` type($ip_identifier))? attr-dict-with-keyword
    (`:` type($results)^)? $body
  }];

  let hasVerifier = 1;
  let hasCanonicalizer = 1;

  let extraClassDeclaration = [{
    /// Return true if this task op contains nested sub-tasks.
    bool hasHierarchy() {
      return cast<ContainerLikeInterface>(this->getOperation()).hasHierarchy();
    }

    /// Get the immediate included linalg op. Will return nullptr if there is no
    /// such linalg op or more than one linalg op.
    linalg::LinalgOp getPayloadLinalgOp();

    DispatchOp getDispatchOp();
    YieldOp getYieldOp();
  }];
}

def YieldOp : HLSOp<"fdf.yield", [NoMemoryEffect, ReturnLike, Terminator,
      ParentOneOf<["DispatchOp", "TaskOp"]>]> {
  let summary = "Terminate and yield results of a dispatch or task op";

  let arguments = (ins Variadic<AnyType>:$results);
  let assemblyFormat = "$results attr-dict `:` type($results)";

  let builders = [OpBuilder<(ins), "build($_builder, $_state, std::nullopt);">];
}

def AllocTensorOp : HLSOp<"fdf.alloc_tensor", [NoMemoryEffect]> {
  let summary = "Allocate a tensor";

  let arguments = (ins Optional<AnyType>:$init_value);
  let results = (outs AnyRankedTensor:$result);
  let assemblyFormat = [{
    ($init_value^)? attr-dict `:` `(` type($init_value) `)` `->` type($result)
  }];

  let hasVerifier = 1;
  let builders = [
    OpBuilder<(ins "mlir::Type":$result),
        "build($_builder, $_state, result, nullptr);">
  ];
}

#endif // SCALEHLS_DIALECT_HLS_HLSOPSFDF_TD
