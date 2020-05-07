struct LoweringToConvOp : public mlir::ConversionPattern {
    LoweringToConvOp(mlir::MLIRContext)
    
}

void OnnxToFpgaKrnlLoweringPass::runOnFunction() {
    mlir::ConversionTarget target(getContext());

    target.addLegalDialect<FpgaKrnlDialect>();

    target.addIllegalDialect<mlir::ONNXOpsDialect>();
}