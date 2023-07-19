//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLS_HLSINTERFACES_TD
#define SCALEHLS_DIALECT_HLS_HLSINTERFACES_TD

include "mlir/IR/OpBase.td"

def TemplatedOpInterface : OpInterface<"TemplatedOpInterface"> {
  let methods = [
    InterfaceMethod<"Return the composed templates",
      "mlir::SmallVector<OpFoldResult>", "getComposedTemplates", (ins), [{
        SmallVector<OpFoldResult> composedTemplates;
        unsigned dynIdx = 0;
        for (auto attr : $_op.getStaticTemplates()) {
          if (auto intAttr = attr.template dyn_cast<IntegerAttr>())
            if (intAttr.getInt() == ShapedType::kDynamic) {
              composedTemplates.push_back($_op.getTemplates()[dynIdx++]);
              continue;
            }
          composedTemplates.push_back(attr);
        }
        return composedTemplates;
      }]>
  ];
}

def ParamLikeInterface : OpInterface<"ParamLikeInterface"> {
  let methods = [
    InterfaceMethod<"Return the value of the parameter if it exists",
      "std::optional<mlir::Attribute>", "getValue", (ins), [{
        return $_op.getValue();
      }]
    >,
    InterfaceMethod<"Return the type of the parameter",
      "mlir::Type", "getType", (ins), [{ return $_op.getType(); }]
    >,
    InterfaceMethod<"Return the kind of the parameter",
      "ParamKind", "getKind", (ins), [{ return $_op.getKind(); }]
    >
  ];
}

def BufferLikeInterface : OpInterface<"BufferLikeInterface"> {
  let description = [{
    This interface is used to represent dataflow buffers.
  }];

  let methods = [
    InterfaceMethod<"Return the memref result of the buffer",
      "mlir::Value", "getMemref", (ins), [{ return $_op.getMemref(); }]
    >,
    InterfaceMethod<"Return the memref type of the buffer",
      "mlir::MemRefType", "getMemrefType", (ins), [{
        return $_op.getMemref().getType().template cast<mlir::MemRefType>();
      }]
    >,
    InterfaceMethod<"Return the depth of the buffer", "int32_t",
                    "getBufferDepth">,
    InterfaceMethod<"Return the initial value of the buffer",
                    "std::optional<mlir::TypedAttr>", "getBufferInitValue">,
  ];
}

def ContainerLikeInterface : OpInterface<"ContainerLikeInterface"> {
  let description = [{
    This interface is used to represent containers, including dispatch, task,
    schedule, and node.
  }];

  let methods = [    
    InterfaceMethod<"Return body region of the stage",
      "mlir::Region &", "getBody", (ins), "return $_op.getBody();">,
    InterfaceMethod<"Check whether the stage has hierarchy",
      "bool", "hasHierarchy", (ins), [{
        return $_op.walk([&](ContainerLikeInterface stage) {
          if (stage != $_op)
            return WalkResult::interrupt();
          return WalkResult::advance();
        }).wasInterrupted();
      }]>,
    InterfaceMethod<"Return whether the value is a stage livein",
                    "bool", "isLivein", (ins "mlir::Value":$value)>,
    InterfaceMethod<"Return the liveins of the stage",
                    "llvm::SmallVector<mlir::Value>", "getLiveins">,
    InterfaceMethod<"Return the internal users of a stage livein",
                    "llvm::SmallVector<mlir::Operation *>", "getLiveinUsers",
                    (ins "mlir::Value":$livein)>,
  ];
}

#endif // SCALEHLS_DIALECT_HLS_HLSINTERFACES_TD
