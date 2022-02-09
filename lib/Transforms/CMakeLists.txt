add_mlir_library(MLIRScaleHLSTransforms
  Directive/ArrayPartition.cpp
  Directive/FuncPipelining.cpp
  Directive/LoopPipelining.cpp
  Graph/LegalizeDataflow.cpp
  Graph/SplitFunction.cpp
  Loop/AffineLoopOrderOpt.cpp
  Loop/AffineLoopPerfection.cpp
  Loop/MaterializeReduction.cpp
  Loop/PartialAffineLoopTile.cpp
  Loop/RemoveVariableBound.cpp
  Simplification/AffineStoreForward.cpp
  Simplification/ReduceInitialInterval.cpp
  Simplification/SimplifyAffineIf.cpp
  Simplification/SimplifyMemrefAccess.cpp
  MultipleLevelDSE.cpp
  Passes.cpp
  QoREstimation.cpp
  Utils.cpp

  DEPENDS
  MLIRScaleHLSTransformsIncGen

  LINK_LIBS PUBLIC
  MLIRScaleHLSSupport
  )
