add_mlir_library(MLIRScaleHLSTransforms
  Dataflow/BufferizeDataflow.cpp
  Dataflow/ConvertDataflowToFunc.cpp
  Dataflow/CreateDataflowFromAffine.cpp
  Dataflow/CreateDataflowFromTosa.cpp
  Dataflow/CreateTokenStream.cpp
  Dataflow/LegalizeDataflow.cpp
  Dataflow/LowerDataflow.cpp
  Dataflow/PlaceDataflowBuffer.cpp
  Dataflow/StreamDataflow.cpp

  Directive/ArrayPartition.cpp
  Directive/CreateAxiInterface.cpp
  Directive/CreateHLSPrimitive.cpp
  Directive/FuncPipelining.cpp
  Directive/LoopPipelining.cpp
  Directive/QoREstimation.cpp

  Loop/AffineLoopFusion.cpp
  Loop/AffineLoopOrderOpt.cpp
  Loop/AffineLoopPerfection.cpp
  Loop/AffineLoopTile.cpp
  Loop/AffineLoopUnrollJam.cpp
  Loop/MaterializeReduction.cpp
  Loop/RemoveVariableBound.cpp
  Loop/SimplifyAffineIf.cpp

  Memory/AffineStoreForward.cpp
  Memory/CreateLocalBuffer.cpp
  Memory/CreateMemrefSubview.cpp
  Memory/FoldMemrefSubview.cpp
  Memory/LowerCopyToAffine.cpp
  Memory/RaiseAffineToCopy.cpp
  Memory/ReduceInitialInterval.cpp
  Memory/SimplifyCopy.cpp
  Memory/SimplifyMemrefAccess.cpp

  Tensor/TosaFakeQuantize.cpp
  Tensor/TosaSimplifyGraph.cpp
  Tensor/TosaToLinalgCleanup.cpp

  DesignSpaceExplore.cpp
  FuncDuplication.cpp
  FuncPreprocess.cpp
  Passes.cpp
  Utils.cpp

  DEPENDS
  MLIRScaleHLSTransformsIncGen

  LINK_LIBS PUBLIC
  MLIRHLS
  MLIRScaleHLSSupport
  )
