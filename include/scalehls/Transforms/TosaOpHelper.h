//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_TOSA_OP_HELPER_H
#define SCALEHLS_TOSA_OP_HELPER_H

#include "scalehls/Transforms/TosaOpHelper.h"

namespace mlir {
namespace scalehls {

class OpHelper {
public:
  int64_t key = 0;

  OpHelper(){};
  OpHelper(int64_t _key) { key = _key; }

  bool operator==(const OpHelper &rhs) const { return this->key == rhs.key; }

  bool operator<(const OpHelper &rhs) const {
    if (*this == rhs) {
      return false;
    } else {
      return (this->key < rhs.key);
    }
  }

  bool isEmptyKey() const {
    int64_t emptyKey = (1UL << (sizeof(int64_t) * 8 - 1)) - 1UL;
    return key == emptyKey;
  }

  bool isTombstoneKey() const {
    int64_t tombstoneKey = (1UL << (sizeof(int64_t) * 8 - 1)) - 1UL - 1L;
    return key == tombstoneKey;
  }
};

class ConvOpHelper : public OpHelper {
public:
  int64_t batchSize;
  int64_t inCh;
  int64_t inWH;
  int64_t outCh;
  int64_t outWH;
  int64_t kernelSize;
  int64_t pad;
  int64_t stride;
  int64_t dilation;
  Type inputType;
  Type weightType;
  Type outputType;

  ConvOpHelper() {
    batchSize = 0;
    inCh = 0;
    inWH = 0;
    outCh = 0;
    outWH = 0;
    kernelSize = 0;
    pad = 0;
    stride = 0;
    dilation = 0;
  }

  ConvOpHelper(const ConvOpHelper &other) { *this = other; }

  ConvOpHelper(int64_t _batchSize, int64_t _inCh, int64_t _inWH, int64_t _outCh,
               int64_t _outWH, int64_t _kernelSize, int64_t _pad,
               int64_t _stride, int64_t _dilation)
      : OpHelper(getHashValue(_kernelSize, _pad, _stride, _dilation)) {
    batchSize = _batchSize;
    inCh = _inCh;
    inWH = _inWH;
    outCh = _outCh;
    outWH = _outWH;
    kernelSize = _kernelSize;
    pad = _pad;
    stride = _stride;
    dilation = _dilation;
  }

  ConvOpHelper(tosa::Conv2DOp op) : OpHelper(getHashValue(op)) {
    auto inType = op.input().getType().cast<RankedTensorType>();
    batchSize = inType.getShape()[0];
    inWH = inType.getShape()[1];
    inputType = inType.getElementType();
    auto wType = op.weight().getType().cast<RankedTensorType>();
    inCh = wType.getShape()[3];
    outCh = wType.getShape()[0];
    kernelSize = wType.getShape()[1];
    weightType = wType.getElementType();
    auto outType = op.output().getType().cast<RankedTensorType>();
    outWH = outType.getShape()[1];
    outputType = outType.getElementType();
    pad = op.pad()[0].dyn_cast<IntegerAttr>().getInt();
    stride = op.stride()[0].dyn_cast<IntegerAttr>().getInt();
    dilation = op.dilation()[0].dyn_cast<IntegerAttr>().getInt();
  }

  bool operator==(ConvOpHelper &rhs) { return this->equalAttr(rhs); }

  ConvOpHelper &operator=(const ConvOpHelper &other) {
    batchSize = other.batchSize;
    inCh = other.inCh;
    inWH = other.inWH;
    outCh = other.outCh;
    outWH = other.outWH;
    kernelSize = other.kernelSize;
    pad = other.pad;
    stride = other.stride;
    dilation = other.dilation;
    inputType = other.inputType;
    weightType = other.weightType;
    outputType = other.outputType;
    return *this;
  }

  bool equalAttr(ConvOpHelper &rhs) {
    return (pad == rhs.pad) && (stride == rhs.stride) &&
           (dilation == rhs.dilation) && (kernelSize == rhs.kernelSize);
  }

  void takeSmallerDim(ConvOpHelper &rhs) {
    if (inCh == 3)
      inCh = rhs.inCh;
    else if (rhs.inCh != 3)
      inCh = inCh < rhs.inCh ? inCh : rhs.inCh;
    outCh = outCh < rhs.outCh ? outCh : rhs.outCh;
    inWH = outWH < rhs.outWH ? inWH : rhs.inWH;
    outWH = outWH < rhs.outWH ? outWH : rhs.outWH;
  }

  unsigned getHashValue() const {
    auto hash = kernelSize * 37U;
    hash = (hash + pad) * 37U;
    hash = (hash + stride) * 37U;
    hash = (hash + dilation) * 37U;
    return hash;
  }

  static unsigned getHashValue(int64_t _kernelSize, int64_t _pad,
                               int64_t _stride, int64_t _dilation) {
    auto hash = _kernelSize * 37U;
    hash = (hash + _pad) * 37U;
    hash = (hash + _stride) * 37U;
    hash = (hash + _dilation) * 37U;
    return hash;
  }

  static unsigned getHashValue(tosa::Conv2DOp op) {
    int64_t _kernelSize =
        op.weight().getType().cast<RankedTensorType>().getShape()[1];
    int64_t _pad = op.pad()[0].dyn_cast<IntegerAttr>().getInt();
    int64_t _stride = op.stride()[0].dyn_cast<IntegerAttr>().getInt();
    int64_t _dilation = op.dilation()[0].dyn_cast<IntegerAttr>().getInt();
    auto hash = _kernelSize * 37U;
    hash = (hash + _pad) * 37U;
    hash = (hash + _stride) * 37U;
    hash = (hash + _dilation) * 37U;
    return hash;
  }

  static bool classof(const OpHelper *op) { return true; }
};

} // namespace scalehls
} // namespace mlir

namespace llvm {
template <> struct DenseMapInfo<mlir::scalehls::OpHelper> {
  static mlir::scalehls::OpHelper getEmptyKey() {
    int64_t emptyKey = (1UL << (sizeof(int64_t) * 8 - 1)) - 1UL;
    return mlir::scalehls::OpHelper(emptyKey);
  }
  static mlir::scalehls::OpHelper getTombstoneKey() {
    int64_t tombstoneKey = (1UL << (sizeof(int64_t) * 8 - 1)) - 1UL - 1L;
    return mlir::scalehls::OpHelper(tombstoneKey);
  }
  static unsigned getHashValue(mlir::scalehls::OpHelper Val) { return 0; }
  static bool isEqual(mlir::scalehls::OpHelper LHS,
                      mlir::scalehls::OpHelper RHS) {
    return LHS == RHS;
  }
};
} // namespace llvm

#endif // SCALEHLS_TOSA_OP_HELPER_H
