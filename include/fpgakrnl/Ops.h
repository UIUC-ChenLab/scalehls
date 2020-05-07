/*===- TableGen'erated file -------------------------------------*- C++ -*-===*\
|*                                                                            *|
|* Op Definitions                                                             *|
|*                                                                            *|
|* Automatically generated file, do not edit!                                 *|
|*                                                                            *|
\*===----------------------------------------------------------------------===*/

#ifdef GET_OP_LIST
#undef GET_OP_LIST

fpgakrnl::ConvOp,
fpgakrnl::MaxPoolOp
#endif  // GET_OP_LIST

#ifdef GET_OP_CLASSES
#undef GET_OP_CLASSES


//===----------------------------------------------------------------------===//
// fpgakrnl::ConvOp definitions
//===----------------------------------------------------------------------===//

ConvOpOperandAdaptor::ConvOpOperandAdaptor(ArrayRef<Value> values) {
  tblgen_operands = values;
}

ArrayRef<Value> ConvOpOperandAdaptor::getODSOperands(unsigned index) {
  return {std::next(tblgen_operands.begin(), index), std::next(tblgen_operands.begin(), index + 1)};
}

Value  ConvOpOperandAdaptor::ifmap() {
  return *getODSOperands(0).begin();
}

StringRef ConvOp::getOperationName() {
  return "fpgakrnl.conv";
}

Operation::operand_range ConvOp::getODSOperands(unsigned index) {
  return {std::next(getOperation()->operand_begin(), index), std::next(getOperation()->operand_begin(), index + 1)};
}

Value  ConvOp::ifmap() {
  return *getODSOperands(0).begin();
}

Operation::result_range ConvOp::getODSResults(unsigned index) {
  return {std::next(getOperation()->result_begin(), index), std::next(getOperation()->result_begin(), index + 1)};
}

Value  ConvOp::ofmap() {
  return *getODSResults(0).begin();
}

DenseIntElementsAttr ConvOp::kernel_valueAttr() {
  return this->getAttr("kernel_value").dyn_cast_or_null<DenseIntElementsAttr>();
}

DenseIntElementsAttr ConvOp::kernel_value() {
  auto attr = kernel_valueAttr();
    if (!attr)
      return ;
  return attr;
}

ArrayAttr ConvOp::kernel_shapeAttr() {
  return this->getAttr("kernel_shape").dyn_cast_or_null<ArrayAttr>();
}

ArrayAttr ConvOp::kernel_shape() {
  auto attr = kernel_shapeAttr();
    if (!attr)
      return mlir::Builder(this->getContext()).getI32ArrayAttr({});
  return attr;
}

ArrayAttr ConvOp::padsAttr() {
  return this->getAttr("pads").dyn_cast_or_null<ArrayAttr>();
}

ArrayAttr ConvOp::pads() {
  auto attr = padsAttr();
    if (!attr)
      return mlir::Builder(this->getContext()).getI32ArrayAttr({});
  return attr;
}

ArrayAttr ConvOp::dilationsAttr() {
  return this->getAttr("dilations").dyn_cast_or_null<ArrayAttr>();
}

Optional< ArrayAttr > ConvOp::dilations() {
  auto attr = dilationsAttr();
  return attr ? Optional< ArrayAttr >(attr) : (llvm::None);
}

ArrayAttr ConvOp::stridesAttr() {
  return this->getAttr("strides").dyn_cast_or_null<ArrayAttr>();
}

Optional< ArrayAttr > ConvOp::strides() {
  auto attr = stridesAttr();
  return attr ? Optional< ArrayAttr >(attr) : (llvm::None);
}

IntegerAttr ConvOp::groupAttr() {
  return this->getAttr("group").dyn_cast_or_null<IntegerAttr>();
}

Optional< APInt > ConvOp::group() {
  auto attr = groupAttr();
  return attr ? Optional< APInt >(attr.getValue()) : (llvm::None);
}

void ConvOp::kernel_valueAttr(DenseIntElementsAttr attr) {
  this->getOperation()->setAttr("kernel_value", attr);
}

void ConvOp::kernel_shapeAttr(ArrayAttr attr) {
  this->getOperation()->setAttr("kernel_shape", attr);
}

void ConvOp::padsAttr(ArrayAttr attr) {
  this->getOperation()->setAttr("pads", attr);
}

void ConvOp::dilationsAttr(ArrayAttr attr) {
  this->getOperation()->setAttr("dilations", attr);
}

void ConvOp::stridesAttr(ArrayAttr attr) {
  this->getOperation()->setAttr("strides", attr);
}

void ConvOp::groupAttr(IntegerAttr attr) {
  this->getOperation()->setAttr("group", attr);
}

void ConvOp::build(Builder *odsBuilder, OperationState &odsState, Type ofmap, Value ifmap, DenseIntElementsAttr kernel_value, ArrayAttr kernel_shape, ArrayAttr pads, /*optional*/ArrayAttr dilations, /*optional*/ArrayAttr strides, /*optional*/IntegerAttr group) {
  odsState.addOperands(ifmap);
  odsState.addAttribute("kernel_value", kernel_value);
  odsState.addAttribute("kernel_shape", kernel_shape);
  odsState.addAttribute("pads", pads);
  if (dilations) {
  odsState.addAttribute("dilations", dilations);
  }
  if (strides) {
  odsState.addAttribute("strides", strides);
  }
  if (group) {
  odsState.addAttribute("group", group);
  }
  odsState.addTypes(ofmap);
}

void ConvOp::build(Builder *odsBuilder, OperationState &odsState, ArrayRef<Type> resultTypes, Value ifmap, DenseIntElementsAttr kernel_value, ArrayAttr kernel_shape, ArrayAttr pads, /*optional*/ArrayAttr dilations, /*optional*/ArrayAttr strides, /*optional*/IntegerAttr group) {
  odsState.addOperands(ifmap);
  odsState.addAttribute("kernel_value", kernel_value);
  odsState.addAttribute("kernel_shape", kernel_shape);
  odsState.addAttribute("pads", pads);
  if (dilations) {
  odsState.addAttribute("dilations", dilations);
  }
  if (strides) {
  odsState.addAttribute("strides", strides);
  }
  if (group) {
  odsState.addAttribute("group", group);
  }
  assert(resultTypes.size() == 1u && "mismatched number of results");
  odsState.addTypes(resultTypes);
}

void ConvOp::build(Builder *, OperationState &odsState, ArrayRef<Type> resultTypes, ValueRange operands, ArrayRef<NamedAttribute> attributes) {
  assert(operands.size() == 1u && "mismatched number of parameters");
  odsState.addOperands(operands);

  odsState.addAttributes(attributes);
  assert(resultTypes.size() == 1u && "mismatched number of return types");
  odsState.addTypes(resultTypes);
}

LogicalResult ConvOp::verify() {
  auto tblgen_kernel_value = this->getAttr("kernel_value");
  if (tblgen_kernel_value) {
    if (!(((tblgen_kernel_value.isa<DenseIntElementsAttr>())) && ((tblgen_kernel_value.cast<DenseIntElementsAttr>().getType().getElementType().isInteger(32))))) return emitOpError("attribute 'kernel_value' failed to satisfy constraint: 32-bit integer elements attribute");
  }
  auto tblgen_kernel_shape = this->getAttr("kernel_shape");
  if (tblgen_kernel_shape) {
    if (!(((tblgen_kernel_shape.isa<ArrayAttr>())) && (llvm::all_of(tblgen_kernel_shape.cast<ArrayAttr>(), [](Attribute attr) { return ((attr.isa<IntegerAttr>())) && ((attr.cast<IntegerAttr>().getType().isSignlessInteger(32))); })))) return emitOpError("attribute 'kernel_shape' failed to satisfy constraint: 32-bit integer array attribute");
  }
  auto tblgen_pads = this->getAttr("pads");
  if (tblgen_pads) {
    if (!(((tblgen_pads.isa<ArrayAttr>())) && (llvm::all_of(tblgen_pads.cast<ArrayAttr>(), [](Attribute attr) { return ((attr.isa<IntegerAttr>())) && ((attr.cast<IntegerAttr>().getType().isSignlessInteger(32))); })))) return emitOpError("attribute 'pads' failed to satisfy constraint: 32-bit integer array attribute");
  }
  auto tblgen_dilations = this->getAttr("dilations");
  if (tblgen_dilations) {
    if (!(((tblgen_dilations.isa<ArrayAttr>())) && (llvm::all_of(tblgen_dilations.cast<ArrayAttr>(), [](Attribute attr) { return ((attr.isa<IntegerAttr>())) && ((attr.cast<IntegerAttr>().getType().isSignlessInteger(32))); })))) return emitOpError("attribute 'dilations' failed to satisfy constraint: 32-bit integer array attribute");
  }
  auto tblgen_strides = this->getAttr("strides");
  if (tblgen_strides) {
    if (!(((tblgen_strides.isa<ArrayAttr>())) && (llvm::all_of(tblgen_strides.cast<ArrayAttr>(), [](Attribute attr) { return ((attr.isa<IntegerAttr>())) && ((attr.cast<IntegerAttr>().getType().isSignlessInteger(32))); })))) return emitOpError("attribute 'strides' failed to satisfy constraint: 32-bit integer array attribute");
  }
  auto tblgen_group = this->getAttr("group");
  if (tblgen_group) {
    if (!(((tblgen_group.isa<IntegerAttr>())) && ((tblgen_group.cast<IntegerAttr>().getType().isSignlessInteger(32))))) return emitOpError("attribute 'group' failed to satisfy constraint: 32-bit signless integer attribute");
  }
  {
    unsigned index = 0; (void)index;
    for (Value v : getODSOperands(0)) {
      (void)v;
      if (!((((v.getType().isa<MemRefType>())) && ((true))) || (((v.getType().isa<TensorType>())) && ((true))))) {
        return emitOpError("operand #") << index << " must be memref of any type values or tensor of any type values, but got " << v.getType();
      }
      ++index;
    }
  }
  {
    unsigned index = 0; (void)index;
    for (Value v : getODSResults(0)) {
      (void)v;
      if (!((((v.getType().isa<MemRefType>())) && ((true))) || (((v.getType().isa<TensorType>())) && ((true))))) {
        return emitOpError("result #") << index << " must be memref of any type values or tensor of any type values, but got " << v.getType();
      }
      ++index;
    }
  }
  if (this->getOperation()->getNumRegions() != 0) {
    return emitOpError("has incorrect number of regions: expected 0 but found ") << this->getOperation()->getNumRegions();
  }
  return ::verify(*this);
}

void ConvOp::getEffects(SmallVectorImpl<SideEffects::EffectInstance<MemoryEffects::Effect>> &effects) {

}


//===----------------------------------------------------------------------===//
// fpgakrnl::MaxPoolOp definitions
//===----------------------------------------------------------------------===//

MaxPoolOpOperandAdaptor::MaxPoolOpOperandAdaptor(ArrayRef<Value> values) {
  tblgen_operands = values;
}

ArrayRef<Value> MaxPoolOpOperandAdaptor::getODSOperands(unsigned index) {
  return {std::next(tblgen_operands.begin(), index), std::next(tblgen_operands.begin(), index + 1)};
}

Value  MaxPoolOpOperandAdaptor::ifmap() {
  return *getODSOperands(0).begin();
}

StringRef MaxPoolOp::getOperationName() {
  return "fpgakrnl.maxpool";
}

Operation::operand_range MaxPoolOp::getODSOperands(unsigned index) {
  return {std::next(getOperation()->operand_begin(), index), std::next(getOperation()->operand_begin(), index + 1)};
}

Value  MaxPoolOp::ifmap() {
  return *getODSOperands(0).begin();
}

Operation::result_range MaxPoolOp::getODSResults(unsigned index) {
  return {std::next(getOperation()->result_begin(), index), std::next(getOperation()->result_begin(), index + 1)};
}

Value  MaxPoolOp::ofmap() {
  return *getODSResults(0).begin();
}

ArrayAttr MaxPoolOp::kernel_shapeAttr() {
  return this->getAttr("kernel_shape").dyn_cast_or_null<ArrayAttr>();
}

ArrayAttr MaxPoolOp::kernel_shape() {
  auto attr = kernel_shapeAttr();
    if (!attr)
      return mlir::Builder(this->getContext()).getI32ArrayAttr({});
  return attr;
}

ArrayAttr MaxPoolOp::padsAttr() {
  return this->getAttr("pads").dyn_cast_or_null<ArrayAttr>();
}

ArrayAttr MaxPoolOp::pads() {
  auto attr = padsAttr();
    if (!attr)
      return mlir::Builder(this->getContext()).getI32ArrayAttr({});
  return attr;
}

ArrayAttr MaxPoolOp::dilationsAttr() {
  return this->getAttr("dilations").dyn_cast_or_null<ArrayAttr>();
}

Optional< ArrayAttr > MaxPoolOp::dilations() {
  auto attr = dilationsAttr();
  return attr ? Optional< ArrayAttr >(attr) : (llvm::None);
}

ArrayAttr MaxPoolOp::stridesAttr() {
  return this->getAttr("strides").dyn_cast_or_null<ArrayAttr>();
}

Optional< ArrayAttr > MaxPoolOp::strides() {
  auto attr = stridesAttr();
  return attr ? Optional< ArrayAttr >(attr) : (llvm::None);
}

void MaxPoolOp::kernel_shapeAttr(ArrayAttr attr) {
  this->getOperation()->setAttr("kernel_shape", attr);
}

void MaxPoolOp::padsAttr(ArrayAttr attr) {
  this->getOperation()->setAttr("pads", attr);
}

void MaxPoolOp::dilationsAttr(ArrayAttr attr) {
  this->getOperation()->setAttr("dilations", attr);
}

void MaxPoolOp::stridesAttr(ArrayAttr attr) {
  this->getOperation()->setAttr("strides", attr);
}

void MaxPoolOp::build(Builder *odsBuilder, OperationState &odsState, Type ofmap, Value ifmap, ArrayAttr kernel_shape, ArrayAttr pads, /*optional*/ArrayAttr dilations, /*optional*/ArrayAttr strides) {
  odsState.addOperands(ifmap);
  odsState.addAttribute("kernel_shape", kernel_shape);
  odsState.addAttribute("pads", pads);
  if (dilations) {
  odsState.addAttribute("dilations", dilations);
  }
  if (strides) {
  odsState.addAttribute("strides", strides);
  }
  odsState.addTypes(ofmap);
}

void MaxPoolOp::build(Builder *odsBuilder, OperationState &odsState, ArrayRef<Type> resultTypes, Value ifmap, ArrayAttr kernel_shape, ArrayAttr pads, /*optional*/ArrayAttr dilations, /*optional*/ArrayAttr strides) {
  odsState.addOperands(ifmap);
  odsState.addAttribute("kernel_shape", kernel_shape);
  odsState.addAttribute("pads", pads);
  if (dilations) {
  odsState.addAttribute("dilations", dilations);
  }
  if (strides) {
  odsState.addAttribute("strides", strides);
  }
  assert(resultTypes.size() == 1u && "mismatched number of results");
  odsState.addTypes(resultTypes);
}

void MaxPoolOp::build(Builder *, OperationState &odsState, ArrayRef<Type> resultTypes, ValueRange operands, ArrayRef<NamedAttribute> attributes) {
  assert(operands.size() == 1u && "mismatched number of parameters");
  odsState.addOperands(operands);

  odsState.addAttributes(attributes);
  assert(resultTypes.size() == 1u && "mismatched number of return types");
  odsState.addTypes(resultTypes);
}

LogicalResult MaxPoolOp::verify() {
  auto tblgen_kernel_shape = this->getAttr("kernel_shape");
  if (tblgen_kernel_shape) {
    if (!(((tblgen_kernel_shape.isa<ArrayAttr>())) && (llvm::all_of(tblgen_kernel_shape.cast<ArrayAttr>(), [](Attribute attr) { return ((attr.isa<IntegerAttr>())) && ((attr.cast<IntegerAttr>().getType().isSignlessInteger(32))); })))) return emitOpError("attribute 'kernel_shape' failed to satisfy constraint: 32-bit integer array attribute");
  }
  auto tblgen_pads = this->getAttr("pads");
  if (tblgen_pads) {
    if (!(((tblgen_pads.isa<ArrayAttr>())) && (llvm::all_of(tblgen_pads.cast<ArrayAttr>(), [](Attribute attr) { return ((attr.isa<IntegerAttr>())) && ((attr.cast<IntegerAttr>().getType().isSignlessInteger(32))); })))) return emitOpError("attribute 'pads' failed to satisfy constraint: 32-bit integer array attribute");
  }
  auto tblgen_dilations = this->getAttr("dilations");
  if (tblgen_dilations) {
    if (!(((tblgen_dilations.isa<ArrayAttr>())) && (llvm::all_of(tblgen_dilations.cast<ArrayAttr>(), [](Attribute attr) { return ((attr.isa<IntegerAttr>())) && ((attr.cast<IntegerAttr>().getType().isSignlessInteger(32))); })))) return emitOpError("attribute 'dilations' failed to satisfy constraint: 32-bit integer array attribute");
  }
  auto tblgen_strides = this->getAttr("strides");
  if (tblgen_strides) {
    if (!(((tblgen_strides.isa<ArrayAttr>())) && (llvm::all_of(tblgen_strides.cast<ArrayAttr>(), [](Attribute attr) { return ((attr.isa<IntegerAttr>())) && ((attr.cast<IntegerAttr>().getType().isSignlessInteger(32))); })))) return emitOpError("attribute 'strides' failed to satisfy constraint: 32-bit integer array attribute");
  }
  {
    unsigned index = 0; (void)index;
    for (Value v : getODSOperands(0)) {
      (void)v;
      if (!((((v.getType().isa<MemRefType>())) && ((true))) || (((v.getType().isa<TensorType>())) && ((true))))) {
        return emitOpError("operand #") << index << " must be memref of any type values or tensor of any type values, but got " << v.getType();
      }
      ++index;
    }
  }
  {
    unsigned index = 0; (void)index;
    for (Value v : getODSResults(0)) {
      (void)v;
      if (!((((v.getType().isa<MemRefType>())) && ((true))) || (((v.getType().isa<TensorType>())) && ((true))))) {
        return emitOpError("result #") << index << " must be memref of any type values or tensor of any type values, but got " << v.getType();
      }
      ++index;
    }
  }
  if (this->getOperation()->getNumRegions() != 0) {
    return emitOpError("has incorrect number of regions: expected 0 but found ") << this->getOperation()->getNumRegions();
  }
  return ::verify(*this);
}

void MaxPoolOp::getEffects(SmallVectorImpl<SideEffects::EffectInstance<MemoryEffects::Effect>> &effects) {

}


#endif  // GET_OP_CLASSES

