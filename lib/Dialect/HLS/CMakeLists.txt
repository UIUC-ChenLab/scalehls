add_mlir_dialect_library(MLIRHLS
  Analysis/Analysis.cpp
  IR/HLS.cpp
  IR/HLSAttributes.cpp
  IR/HLSOps.cpp
  Transforms/BufferizableOpInterfaceImpl.cpp
  Utils/Utils.cpp

  DEPENDS
  MLIRHLSOpsIncGen
  MLIRHLSEnumsIncGen
  MLIRHLSAttributesIncGen
  MLIRHLSInterfacesIncGen
  )
