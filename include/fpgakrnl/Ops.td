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

    let arguments = (ins AnyTypeOf<[AnyMemRef, AnyTensor]>:$ifmap,
                     DefaultValuedAttr<AnyI32ElementsAttr, "0">:$kernel_value,
                     DefaultValuedAttr<I32ArrayAttr, "{}">:$kernel_shape,
                     DefaultValuedAttr<I32ArrayAttr, "{}">:$pads,
                     OptionalAttr<I32ArrayAttr>:$dilations,
                     OptionalAttr<I32ArrayAttr>:$strides,
                     OptionalAttr<I32Attr>:$group);

    let results = (outs AnyTypeOf<[AnyMemRef, AnyTensor]>:$ofmap);

    let verifier = [{ return ::verify(*this); }];
}

def MaxPoolOp : FpgaKrnl_Op<"maxpool", [NoSideEffect]> {
    let summary = "maxpool";

    let description = [{
        Max Pooling Operation.
    }];

    // hanchen is working here
    let arguments = (ins AnyTypeOf<[AnyMemRef, AnyTensor]>:$ifmap,
                     DefaultValuedAttr<I32ArrayAttr, "{}">:$kernel_shape,
                     DefaultValuedAttr<I32ArrayAttr, "{}">:$pads,
                     OptionalAttr<I32ArrayAttr>:$dilations,
                     OptionalAttr<I32ArrayAttr>:$strides);

    let results = (outs AnyTypeOf<[AnyMemRef, AnyTensor]>:$ofmap);
    
    let verifier = [{ return ::verify(*this); }];
}