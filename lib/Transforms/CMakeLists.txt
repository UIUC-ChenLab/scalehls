add_mlir_library(MLIRScaleHLSTransforms
  Directive/ArrayPartition.cpp
  Directive/CreateHLSCppPrimitive.cpp
  Directive/FuncPipelining.cpp
  Directive/LoopPipelining.cpp
  Graph/FakeQuantize.cpp
  Graph/LegalizeDataflow.cpp
  Graph/SimplifyTosaGraph.cpp
  Graph/SplitFunction.cpp
  Loop/AffineLoopOrderOpt.cpp
  Loop/AffineLoopPerfection.cpp
  Loop/AffineLoopTile.cpp
  Loop/AffineLoopUnrollJam.cpp
  Loop/ConvertCopyToAffineLoops.cpp
  Loop/MaterializeReduction.cpp
  Loop/RemoveVariableBound.cpp
  Loop/SimplifyAffineIf.cpp
  Memory/AffineStoreForward.cpp
  Memory/CreateMemrefSubview.cpp
  Memory/PromoteBuffer.cpp
  Memory/ReduceInitialInterval.cpp
  Memory/SimplifyMemrefAccess.cpp
  CreateRuntimeMain.cpp
  LegalizeToHLSCpp.cpp
  MultipleLevelDSE.cpp
  Passes.cpp
  QoREstimation.cpp
  Utils.cpp

  DEPENDS
  MLIRScaleHLSTransformsIncGen

  LINK_LIBS PUBLIC
  MLIRScaleHLSSupport
  )
