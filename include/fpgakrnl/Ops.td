include "mlir/IR/OpBase.td"
include "mlir/Interfaces/SideEffects.td"

def FpgaKrnl_Dialect : Dialect {
    let name = "fpgakrnl";
    let cppNamespace = "fpgakrnl";
}

class FpgaKrnl_Op<string mnemonic, list<OpTrait> traits = []> :
    Op<FpgaKrnl_Dialect, mnemonic, traits>;

def ConvOp : FpgaKrnl_Op<"conv", [NoSideEffect]> {
    let summary = "conv";

    let description = [{
        Convolution Operation.
    }];

    // hanchen is working here
    let arguments = ();

    let results = ();
    
}

def MaxPoolOp : FpgaKrnl_Op<"maxpool", [NoSideEffect]> {
    let summary = "maxpool";

    let description = [{
        Max Pooling Operation.
    }];

    // hanchen is working here
    let arguments = ();

    let results = ();
    
}