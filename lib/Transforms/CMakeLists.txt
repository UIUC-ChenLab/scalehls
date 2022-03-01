add_mlir_library(MLIRScaleHLSTransforms
  Directive/ArrayPartition.cpp
  Directive/CreateHLSCppPrimitive.cpp
  Directive/FuncPipelining.cpp
  Directive/LoopPipelining.cpp
  Graph/ConvertCopyToAffineLoops.cpp
  Graph/CreateRuntimeMain.cpp
  Graph/LegalizeDataflow.cpp
  Graph/ShareTensorOperation.cpp
  Graph/SimplifyTosaGraph.cpp
  Graph/SplitFunction.cpp
  Loop/AffineLoopOrderOpt.cpp
  Loop/AffineLoopPerfection.cpp
  Loop/AffineLoopUnrollAndPipeline.cpp
  Loop/MaterializeReduction.cpp
  Loop/RemoveVariableBound.cpp
  Simplification/AffineStoreForward.cpp
  Simplification/ReduceInitialInterval.cpp
  Simplification/SimplifyAffineIf.cpp
  Simplification/SimplifyMemrefAccess.cpp
  LegalizeToHLSCpp.cpp
  MultipleLevelDSE.cpp
  Passes.cpp
  PreserveUnoptimized.cpp
  QoREstimation.cpp
  Utils.cpp

  DEPENDS
  MLIRScaleHLSTransformsIncGen

  LINK_LIBS PUBLIC
  MLIRScaleHLSSupport
  )
