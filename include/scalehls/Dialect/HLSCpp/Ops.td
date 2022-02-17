//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLSCPP_STRUCTUREOPS_TD
#define SCALEHLS_DIALECT_HLSCPP_STRUCTUREOPS_TD

include "mlir/Interfaces/SideEffectInterfaces.td"

def MulPrimOp : HLSCppOp<"mul_prim", [NoSideEffect]> {
  let summary = "Multiplication primitive operation";
  let description = [{
    This primitive performs C = A * B, where A and B are 8-bits integers, while
    C is 16-bits integer. If C/A/B is vector, the length of vector must be two.
    There are 4 different cases on this:

    1) vec(C) = vec(A) * vec(B)
    2) vec(C) = vec(A) * B
    3) vec(C) = A * vec(B)
    4) C = A * B

    Note that case 2/3 could use the double pumping technique such that we can
    packing the two multiplications into one DSP instance. Please refer to
    "Xilinx WP486: Deep Learning with INT8 Optimization on Xilinx Devices" for
    more information.
  }];

  let arguments = (ins AnyTypeOf<[I8, VectorOfLengthAndType<[2], [I8]>]>:$A,
                       AnyTypeOf<[I8, VectorOfLengthAndType<[2], [I8]>]>:$B);
  let results = (outs AnyTypeOf<[I16, VectorOfLengthAndType<[2], [I16]>]>:$C);

  let verifier = "return ::verify(*this);";
  let extraClassDeclaration = [{ bool isPackMul(); }];
}

def CastPrimOp : HLSCppOp<"cast_prim",
    [SameOperandsAndResultShape, NoSideEffect]> {
  let summary = "Cast primitive operation";

  let hasCanonicalizer = 1;
  let arguments = (ins 
    AnyTypeOf<[I8, I16, I32, VectorOfLengthAndType<[2], [I8, I16, I32]>]>:$in
  );
  let results = (outs
    AnyTypeOf<[I8, I16, I32, VectorOfLengthAndType<[2], [I8, I16, I32]>]>:$out
  );
}

def AssignOp : HLSCppOp<"assign",
    [SameOperandsAndResultElementType, NoSideEffect]> {
  let summary = "Assign the input value to the output";
  let description = [{
    This hlscpp.assign operation assigns the input value to the output, and can
    be inserted anywhere without changing the original semantics. This is useful
    for EmitHLSCpp to handle some corner cases (e.g., the operand of return
    operation is function argument, etc.).
  }];

  let arguments = (ins AnyType : $input);
  let results = (outs AnyType : $output);
}

def IncludeOp : HLSCppOp<"include", [NoSideEffect]> {
  let summary = "C include library operation";
  let description = [{}];

  let arguments = (ins
    StrArrayAttr:$libraries);
}

def IPOp : HLSCppOp<"ip", [NoSideEffect]> {
  let summary = "General IP";
  let description = [{}];

  let arguments = (ins
    Variadic<AnyType>:$inputs,
    StrAttr:$path,
    StrAttr:$name
  );
}

#endif // SCALEHLS_DIALECT_HLSCPP_STRUCTUREOPS_TD
