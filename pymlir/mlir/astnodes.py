""" Classes containing MLIR AST node types, fields, and conversion back to
    MLIR. """

from enum import Enum, auto
from typing import Any, List, Union
from lark import Token


class Node(object):
    """ Base MLIR AST node object. """

    # Static field defining which fields should be used in this node
    _fields_: List[str] = []

    def __init__(self, node: Token = None, **fields):
        # Set each field separately
        if node is not None and isinstance(node, list):
            for fname, fval in zip(self._fields_, node):
                setattr(self, fname, fval)

        # Set the defined fields
        for k, v in fields.items():
            setattr(self, k, v)

    def dump_ast(self) -> str:
        """ Dumps the AST node and its fields in raw AST format. For example:
            Module(name="example", body=[])

            :note: Due to the way objects are constructed, this format can be
                   parsed back by Python to the same AST.
            :return: String representing the AST in its raw format.
        """
        return (type(self).__name__ + '(' + ', '.join(
            f + '=' + _dump_ast_or_value(getattr(self, f))
            for f in self._fields_) + ')')

    def dump(self, indent: int = 0) -> str:
        """ Dumps the AST node and its children in MLIR format.
            :return: String representing the AST in MLIR.
        """
        return '<UNIMPLEMENTED>'

    def __repr__(self):
        return (type(self).__name__ + '(' + ', '.join(
            f + '=' + str(getattr(self, f)) for f in self._fields_) + ')')

    def pretty(self):
        return self.dump()
        # result = self.dump_ast()
        # lines = ['']
        # indent = 0
        # for char in result:
        #     if char == '[':
        #         indent += 1
        #     if char == ']':
        #         indent -= 1
        #     if char != '\n':
        #         lines[-1] += char
        #     if char in '[\n':
        #         lines.append(indent * '  ')
        #
        # return '\n'.join(lines)


class StringLiteral(object):
    def __init__(self, value: str):
        self.value = value

    def __str__(self):
        return '"%s"' % self.value

    def __repr__(self):
        return '"%s"' % self.value


##############################################################################
# Identifiers


class Identifier(Node):
    _fields_ = ['value']

    # Static field representing the prefix of this identifier. Used for ease
    # of MLIR output
    _prefix_: str = ''

    def dump(self, indent: int = 0) -> str:
        return self._prefix_ + self.value


class SsaId(Identifier):
    _fields_ = ['value', 'index']
    _prefix_ = '%'

    def __init__(self, node: Token = None, **fields):
        self.value = node[0]
        self.index = node[1] if len(node) > 1 else None
        super().__init__(None, **fields)

    def dump(self, indent: int = 0) -> str:
        if self.index:
            return self._prefix_ + self.value + ("#%s" % self.index)
        return self._prefix_ + self.value


class SymbolRefId(Identifier):
    _prefix_ = '@'


class BlockId(Identifier):
    _prefix_ = '^'


class TypeAlias(Identifier):
    _prefix_ = '!'


class AttrAlias(Identifier):
    _prefix_ = '#'


class MapOrSetId(Identifier):
    _prefix_ = '#'


##############################################################################
# Types


class Type(Node):
    pass


class Dimension(Type):
    _fields_ = ['value']

    def __init__(self, node: Token = None, **fields):
        self.value = None
        try:
            if isinstance(node[0], int):
                self.value = node[0]
        except (IndexError, TypeError):
            pass  # In case of an unknown size

        super().__init__(None, **fields)

    def dump(self, indent: int = 0) -> str:
        return str(self.value or '?')


class NoneType(Type):
    def dump(self, indent: int = 0) -> str:
        return 'none'


class FloatTypeEnum(Enum):
    f16 = auto()
    bf16 = auto()
    f32 = auto()
    f64 = auto()


class FloatType(Type):
    _fields_ = ['type']

    def __init__(self, node: Token = None, **fields):
        super().__init__(node, **fields)
        if 'type' not in fields:
            self.type = FloatTypeEnum[node[0]]

    def dump(self, indent: int = 0) -> str:
        return self.type.name


class IndexType(Type):
    def dump(self, indent: int = 0) -> str:
        return 'index'


class IntegerType(Type):
    _fields_ = ['width']

    def dump(self, indent: int = 0) -> str:
        return 'i' + str(self.width)


class ComplexType(Type):
    _fields_ = ['type']

    def dump(self, indent: int = 0) -> str:
        return 'complex<%s>' % self.type.dump(indent)


class TupleType(Type):
    _fields_ = ['types']

    def __init__(self, node: Token = None, **fields):
        self.types = node
        super().__init__(None, **fields)

    def dump(self, indent: int = 0) -> str:
        return 'tuple<%s>' % dump_or_value(self.types, indent)


class VectorType(Type):
    _fields_ = ['dimensions', 'element_type']

    def dump(self, indent: int = 0) -> str:
        return 'vector<%s>' % ('x'.join(
            dump_or_value(t, indent)
            for t in self.dimensions) + 'x' + self.element_type.dump(indent))


class RankedTensorType(Type):
    _fields_ = ['dimensions', 'element_type']

    def dump(self, indent: int = 0) -> str:
        return 'tensor<%s>' % ('x'.join(
            t.dump(indent)
            for t in self.dimensions) + 'x' + self.element_type.dump(indent))


class UnrankedTensorType(Type):
    _fields_ = ['element_type']

    def __init__(self, node: Token = None, **fields):
        # Ignore unranked dimension list
        super().__init__(node[1:], **fields)

    def dump(self, indent: int = 0) -> str:
        return 'tensor<*x%s>' % self.element_type.dump(indent)


class RankedMemRefType(Type):
    _fields_ = ['dimensions', 'element_type', 'layout', 'space']

    def __init__(self, node: Token = None, **fields):
        self.dimensions = node[0]
        self.element_type = node[1]
        self.layout = None
        self.space = None
        if len(node) > 2:
            if node[2].data == 'memory_space':
                self.space = node[2].children[0]
            elif node[2].data == 'layout_specification':
                self.layout = node[2].children[0]

        super().__init__(None, **fields)

    def dump(self, indent: int = 0) -> str:
        result = 'memref<%s' % ('x'.join(
            t.dump(indent)
            for t in self.dimensions) + 'x' + self.element_type.dump(indent))
        if self.layout is not None:
            result += ', ' + self.layout.dump(indent)
        if self.space is not None:
            result += ', ' + dump_or_value(self.space, indent)

        return result + '>'


class UnrankedMemRefType(Type):
    _fields_ = ['element_type', 'space']

    def __init__(self, node: Token = None, **fields):
        self.element_type = node[0]
        self.space = None
        if len(node) > 1:
            self.space = node[1].children[0]

        super().__init__(None, **fields)

    def dump(self, indent: int = 0) -> str:
        result = 'memref<%s' % ('*x' + self.element_type.dump(indent))
        if self.space is not None:
            result += ', ' + dump_or_value(self.space, indent)

        return result + '>'


class OpaqueDialectType(Type):
    _fields_ = ['dialect', 'contents']

    def dump(self, indent: int = 0) -> str:
        return '!%s<"%s">' % (self.dialect, self.contents)


class PrettyDialectType(Type):
    _fields_ = ['dialect', 'type', 'body']

    def dump(self, indent: int = 0) -> str:
        return '!%s.%s<%s>' % (self.dialect, self.type, ', '.join(
            dump_or_value(item, indent) for item in self.body))


class FunctionType(Type):
    _fields_ = ['argument_types', 'result_types']

    def dump(self, indent: int = 0) -> str:
        result = '(%s)' % ', '.join(
            dump_or_value(arg, indent) for arg in self.argument_types)
        result += ' -> '
        if not self.result_types:
            result += '()'
        elif len(self.result_types) == 1:
            result += dump_or_value(self.result_types[0], indent)
        else:
            result += '(%s)' % ', '.join(
                dump_or_value(res, indent) for res in self.result_types)
        return result


class StridedLayout(Node):
    _fields_ = ['offset', 'strides']

    def dump(self, indent: int = 0) -> str:
        return 'offset: %s, strides: %s' % (dump_or_value(
            self.offset, indent), dump_or_value(self.strides, indent))


##############################################################################
# Attributes


# Attribute entries
class AttributeEntry(Node):
    _fields_ = ['name', 'value']

    def __init__(self, node: Token = None, **fields):
        self.name = node[0]
        self.value = node[1] if len(node) > 1 else None
        super().__init__(None, **fields)

    def dump(self, indent: int = 0) -> str:
        if self.value:
            return '%s = %s' % (dump_or_value(self.name, indent),
                                dump_or_value(self.value, indent))
        return dump_or_value(self.name, indent)


class DialectAttributeEntry(Node):
    _fields_ = ['dialect', 'name', 'value']

    def __init__(self, node: Token = None, **fields):
        self.dialect = node[0]
        self.name = node[1]
        self.value = node[2] if len(node) > 2 else None
        super().__init__(None, **fields)

    def dump(self, indent: int = 0) -> str:
        if self.value:
            return '%s.%s = %s' % (dump_or_value(self.dialect, indent),
                                   dump_or_value(self.name, indent),
                                   dump_or_value(self.value, indent))
        return '%s.%s' % (dump_or_value(self.dialect, indent),
                          dump_or_value(self.name, indent))


class AttributeDict(Node):
    _fields_ = ['values']

    def __init__(self, node: Token = None, **fields):
        self.values = node
        super().__init__(None, **fields)

    def dump(self, indent: int = 0) -> str:
        return '{%s}' % ', '.join(
            dump_or_value(v, indent) for v in self.values)


# Default attribute implementation
class Attribute(Node):
    _fields_ = ['value']

    def dump(self, indent: int = 0) -> str:
        return dump_or_value(self.value, indent)


class ArrayAttr(Attribute):
    def __init__(self, node: Token = None, **fields):
        self.value = node
        super().__init__(None, **fields)

    def dump(self, indent: int = 0) -> str:
        return '[%s]' % dump_or_value(self.value, indent)


class BoolAttr(Attribute):
    pass


class DictionaryAttr(Attribute):
    def __init__(self, node: Token = None, **fields):
        self.value = node
        super().__init__(None, **fields)

    def dump(self, indent: int = 0) -> str:
        return '{%s}' % dump_or_value(self.value, indent)


class ElementsAttr(Attribute):
    pass


class DenseElementsAttr(ElementsAttr):
    _fields_ = ['attribute', 'type']

    def dump(self, indent: int = 0) -> str:
        return 'dense<%s> : %s' % (self.attribute.dump(indent),
                                   self.type.dump(indent))


class OpaqueElementsAttr(ElementsAttr):
    _fields_ = ['dialect', 'attribute', 'type']

    def dump(self, indent: int = 0) -> str:
        return 'opaque<%s, %s> : %s' % (self.dialect,
                                        dump_or_value(self.attribute, indent),
                                        self.type.dump(indent))


class SparseElementsAttr(ElementsAttr):
    _fields_ = ['indices', 'values', 'type']

    def dump(self, indent: int = 0) -> str:
        return 'sparse<%s, %s> : %s' % (dump_or_value(self.indices, indent),
                                        dump_or_value(self.values, indent),
                                        self.type.dump(indent))


class PrimitiveAttribute(Attribute):
    _fields_ = ['value', 'type']

    def __init__(self, node: Token = None, **fields):
        self.value = node[0]
        if len(node) > 1:
            self.type = node[1]
        else:
            self.type = None

        super().__init__(None, **fields)

    def dump(self, indent: int = 0) -> str:
        return dump_or_value(self.value, indent) + (
            ': %s' % self.type.dump(indent) if self.type is not None else '')


class FloatAttr(PrimitiveAttribute):
    pass


class IntegerAttr(PrimitiveAttribute):
    pass


class StringAttr(PrimitiveAttribute):
    pass


class IntSetAttr(Attribute):
    pass  # Use default implementation


class TypeAttr(Attribute):
    pass  # Use default implementation


class SymbolRefAttr(Attribute):
    _fields_ = ['path']

    def __init__(self, node: Token = None, **fields):
        self.path = node
        super().__init__(None, **fields)

    def dump(self, indent: int = 0) -> str:
        return '::'.join(dump_or_value(p, indent) for p in self.path)


class UnitAttr(Attribute):
    _fields_ = []

    def dump(self, indent: int = 0) -> str:
        return 'unit'


##############################################################################
# Operations


class OpResult(Node):
    _fields_ = ['value', 'count']

    def __init__(self, node: Token = None, **fields):
        self.value = node[0]
        if len(node) > 1:
            self.count = node[1]
        else:
            self.count = None
        super().__init__(None, **fields)

    def dump(self, indent: int = 0) -> str:
        return self.value.dump(indent) + (
            (':' + dump_or_value(self.count, indent)) if self.count else '')


class Operation(Node):
    _fields_ = ['result_list', 'op', 'location']

    def __init__(self, node: Token = None, **fields):
        index = 0
        if isinstance(node[0], list):
            self.result_list = node[index]
            index += 1
        else:
            self.result_list = []
        self.op = node[index]
        index += 1
        if len(node) > index:
            self.location = node[index]
        else:
            self.location = None

        super().__init__(None, **fields)

    def dump(self, indent: int = 0) -> str:
        result = ''
        if self.result_list:
            result += '%s = ' % (', '.join(
                dump_or_value(r, indent) for r in self.result_list))
        result += dump_or_value(self.op, indent)
        if self.location:
            result += ' ' + self.location.dump(indent)
        return result


class Op(Node):
    pass


class GenericOperation(Op):
    _fields_ = ['name', 'args', 'attributes', 'type']

    def __init__(self, node: Token = None, **fields):
        index = 0
        self.name = node[index]
        index += 1
        if len(node) > index and isinstance(node[index], list):
            self.args = node[index]
            index += 1
        else:
            self.args = []
        if len(node) > index and isinstance(node[index], AttributeDict):
            self.attributes = node[index]
            index += 1
        else:
            self.attributes = None
        if len(node) > index:
            self.type = node[index]
        else:
            self.type = None

        super().__init__(None, **fields)

    def dump(self, indent: int = 0) -> str:
        result = '%s' % self.name
        result += '(%s)' % ', '.join(
            dump_or_value(arg, indent) for arg in self.args)
        if self.attributes:
            result += ' ' + dump_or_value(self.attributes, indent)
        if isinstance(self.type, list):
            result += ' : ' + ', '.join(
                dump_or_value(t, indent) for t in self.type)
        else:
            result += ' : ' + dump_or_value(self.type, indent)
        return result


class CustomOperation(Op):
    _fields_ = ['namespace', 'name', 'args', 'type']

    def __init__(self, node: Token = None, **fields):
        self.namespace = node[0]
        self.name = node[1]
        if len(node) == 4:
            self.args = node[2]
            self.type = node[3]
        else:
            self.args = None
            self.type = node[2]

        super().__init__(None, **fields)

    def dump(self, indent: int = 0) -> str:
        result = '%s.%s' % (self.namespace, self.name)
        if self.args:
            result += ' %s' % ', '.join(
                dump_or_value(arg, indent) for arg in self.args)
        if isinstance(self.type, list):
            result += ' : ' + ', '.join(
                dump_or_value(t, indent) for t in self.type)
        else:
            result += ' : ' + dump_or_value(self.type, indent)

        return result


class Location(Node):
    _fields_ = ['value']

    def dump(self, indent: int = 0) -> str:
        return 'loc(%s)' % dump_or_value(self.value, indent)


class FileLineColLoc(Location):
    _fields_ = ['file', 'line', 'col']

    def dump(self, indent: int = 0) -> str:
        return 'loc(%s:%d:%d)' % (self.file, self.line, self.col)


##############################################################################
# Modules, functions, and blocks


class Module(Node):
    _fields_ = ['name', 'attributes', 'body', 'location']

    def __init__(self, node: Union[Token, Node] = None, **fields):
        index = 0
        if isinstance(node, Node):
            self.name = None
            self.attributes = None
            self.body = [node]
            self.location = None
        else:
            if len(node) > index and isinstance(node[index], SymbolRefId):
                self.name = node[index]
                index += 1
            else:
                self.name = None
            if len(node) > index and isinstance(node[index], AttributeDict):
                self.attributes = node[index]
                index += 1
            else:
                self.attributes = None
            self.body = node[index].children
            index += 1
            if len(node) > index:
                self.location = node[index]
            else:
                self.location = None

        super().__init__(None, **fields)

    def dump(self, indent=0) -> str:
        result = indent * '  ' + 'module'
        if self.name:
            result += ' %s' % self.name.dump(indent)
        if self.attributes:
            result += ' attributes ' + dump_or_value(self.attributes, indent)

        result += ' {\n'
        result += '\n'.join(block.dump(indent + 1) for block in self.body)
        result += '\n' + indent * '  ' + '}'
        if self.location:
            result += ' ' + self.location.dump(indent)
        return result


class Function(Node):
    _fields_ = [
        'name', 'args', 'result_types', 'attributes', 'body', 'location'
    ]

    def __init__(self, node: Token = None, **fields):
        signature = node[0].children
        # Parse signature
        index = 0
        self.name = signature[index]
        index += 1
        if len(signature) > index and signature[index].data == 'argument_list':
            self.args = signature[index].children
            index += 1
        else:
            self.args = []
        if (len(signature) > index
                and signature[index].data == 'function_result_list'):
            self.result_types = signature[index].children
            index += 1
        else:
            self.result_types = []

        # Parse rest of function
        index = 1
        if len(node) > index and isinstance(node[index], AttributeDict):
            self.attributes = node[index]
            index += 1
        else:
            self.attributes = None
        if len(node) > index and isinstance(node[index], Region):
            self.body = node[index]
            index += 1
        else:
            self.body = []
        if len(node) > index:
            self.location = node[index]
        else:
            self.location = None

        super().__init__(None, **fields)

    def dump(self, indent=0) -> str:
        result = indent * '  ' + 'func'
        result += ' %s' % self.name.dump(indent)
        result += '(%s)' % ', '.join(
            dump_or_value(arg, indent) for arg in self.args)
        if self.result_types:
            if len(self.result_types) == 1:
                result += ' -> ' + dump_or_value(self.result_types[0], indent)
            else:
                result += ' -> (%s)' % ', '.join(
                    dump_or_value(res, indent) for res in self.result_types)
        if self.attributes:
            result += ' attributes ' + dump_or_value(self.attributes, indent)

        result += ' %s' % (self.body.dump(indent) if self.body else '{\n%s}' %
                           (indent * '  '))
        if self.location:
            result += ' ' + self.location.dump(indent)
        return result


class Region(Node):
    _fields_ = ['body']

    def __init__(self, node: Token = None, **fields):
        self.body = node
        super().__init__(None, **fields)

    def dump(self, indent=0) -> str:
        return ('{\n' + '\n'.join(
            block.dump(indent + 1)
            for block in self.body) + '\n%s}' % (indent * '  '))


class Block(Node):
    _fields_ = ['label', 'body']

    def __init__(self, node: Token = None, **fields):
        index = 0
        if len(node) > index and isinstance(node[index], BlockLabel):
            self.label = node[index]
            index += 1
        else:
            self.label = None
        if len(node) > index:
            self.body = node[index:]
        else:
            self.body = []

        super().__init__(None, **fields)

    def dump(self, indent=0) -> str:
        result = ''
        if self.label:
            result += indent * '  ' + self.label.dump(indent)
        result += '\n'.join(
            indent * '  ' + stmt.dump(indent) for stmt in self.body)
        return result


class BlockLabel(Node):
    _fields_ = ['name', 'args']

    def __init__(self, node: Token = None, **fields):
        self.name = node[0]
        if len(node) > 1:
            self.args = node[1]
        else:
            self.args = []

        super().__init__(None, **fields)

    def dump(self, indent: int = 0) -> str:
        result = dump_or_value(self.name, indent)
        if self.args:
            result += ' (%s)' % (', '.join(
                dump_or_value(arg, indent) for arg in self.args))
        result += ':\n'
        return result


class NamedArgument(Node):
    _fields_ = ['name', 'type', 'attributes']

    def __init__(self, node: Token = None, **fields):
        self.name = node[0]
        self.type = node[1]
        self.attributes = node[2] if len(node) > 2 else None
        super().__init__(None, **fields)

    def dump(self, indent: int = 0) -> str:
        result = '%s: %s' % (dump_or_value(self.name, indent),
                             dump_or_value(self.type, indent))
        if self.attributes:
            result += ' %s' % dump_or_value(self.attributes, indent)
        return result


##############################################################################
# Affine and semi-affine expressions

# Types of affine expressions
class AffineExpr(Node):
    _fields_ = ['value']

    def dump(self, indent: int = 0) -> str:
        return dump_or_value(self.value, indent)


class SemiAffineExpr(Node):
    _fields_ = ['value']

    def dump(self, indent: int = 0) -> str:
        return dump_or_value(self.value, indent)


class MultiDimAffineExpr(Node):
    _fields_ = ['dims']

    def __init__(self, node: Token = None, **fields):
        if len(node) == 1 and isinstance(node[0], list):
            self.dims = node[0]
        else:
            self.dims = node
        super().__init__(None, **fields)

    def dump(self, indent: int = 0) -> str:
        return '%s : (%s)' % (dump_or_value(self.dims_and_symbols, indent),
                              dump_or_value(self.constraints, indent))

    def dump(self, indent: int = 0) -> str:
        return '(%s)' % dump_or_value(self.dims, indent)


class MultiDimSemiAffineExpr(Node):
    _fields_ = ['dims']

    def __init__(self, node: Token = None, **fields):
        if len(node) == 1 and isinstance(node[0], list):
            self.dims = node[0]
        else:
            self.dims = node
        super().__init__(None, **fields)

    def dump(self, indent: int = 0) -> str:
        return '(%s)' % dump_or_value(self.dims, indent)


# Contents of single/multi-dimensional (semi-)affine expressions
class AffineUnaryOp(Node):
    _fields_ = ['operand']
    _op_ = '<UNDEF %s>'

    def dump(self, indent: int = 0) -> str:
        return self._op_ % dump_or_value(self.operand, indent)


class AffineBinaryOp(Node):
    _fields_ = ['operand_a', 'operand_b']
    _op_ = '<UNDEF>'

    def dump(self, indent: int = 0) -> str:
        return '%s %s %s' % (dump_or_value(self.operand_a, indent), self._op_,
                             dump_or_value(self.operand_b, indent))

class AffineNeg(AffineUnaryOp): _op_ = '-%s'
class AffineParens(AffineUnaryOp): _op_ = '(%s)'
class AffineExplicitSymbol(AffineUnaryOp): _op_ = 'symbol(%s)'

class AffineAdd(AffineBinaryOp): _op_ = '+'
class AffineSub(AffineBinaryOp): _op_ = '-'
class AffineMul(AffineBinaryOp): _op_ = '*'
class AffineFloorDiv(AffineBinaryOp): _op_ = 'floordiv'
class AffineCeilDiv(AffineBinaryOp): _op_ = 'ceildiv'
class AffineMod(AffineBinaryOp): _op_ = 'mod'

##############################################################################
# (semi-)Affine maps, and integer sets

class DimAndSymbolList(Node):
    _fields_ = ['dims', 'symbols']

    def __init__(self, node: Token = None, **fields):
        index = 0
        if len(node) > index:
            self.dims = node[index]
            index += 1
        else:
            self.dims = []
        if len(node) > index:
            self.symbols = node[index]
            index += 1
        else:
            self.symbols = []

        super().__init__(None, **fields)

    def dump(self, indent: int = 0) -> str:
        if len(self.symbols) > 0:
            return '(%s)[%s]' % (dump_or_value(self.dims, indent),
                                 dump_or_value(self.symbols, indent))
        return '(%s)' % dump_or_value(self.dims, indent)


class AffineConstraint(Node):
    _fields_ = ['expr']


class AffineConstraintGreaterEqual(AffineConstraint):
    def dump(self, indent: int = 0) -> str:
        return '%s >= 0' % dump_or_value(self.expr, indent)


class AffineConstraintEqual(AffineConstraint):
    def dump(self, indent: int = 0) -> str:
        return '%s == 0' % dump_or_value(self.expr, indent)


class AffineMap(Node):
    _fields_ = ['dims_and_symbols', 'map']

    def dump(self, indent: int = 0) -> str:
        return '%s -> %s' % (dump_or_value(self.dims_and_symbols, indent),
                             dump_or_value(self.map, indent))


class SemiAffineMap(Node):
    _fields_ = ['dims_and_symbols', 'map']

    def dump(self, indent: int = 0) -> str:
        return '%s -> %s' % (dump_or_value(self.dims_and_symbols, indent),
                             dump_or_value(self.map, indent))


class IntSet(Node):
    _fields_ = ['dims_and_symbols', 'constraints']

    def __init__(self, node: Token = None, **fields):
        index = 0
        if len(node) > index:
            self.dims_and_symbols = node[index]
            index += 1
        else:
            self.dims_and_symbols = []
        if len(node) > index:
            self.constraints = node[index]
            index += 1
        else:
            self.constraints = []

        super().__init__(None, **fields)

    def dump(self, indent: int = 0) -> str:
        return '%s : (%s)' % (dump_or_value(self.dims_and_symbols, indent),
                              dump_or_value(self.constraints, indent))


##############################################################################
# Top-level definitions

class Definition(Node):
    _fields_ = ['name', 'value']

    def dump(self, indent: int = 0) -> str:
        return (indent * '  ' + dump_or_value(self.name, indent) + ' = ' +
                dump_or_value(self.value, indent))


class TypeAliasDef(Definition):
    def dump(self, indent: int = 0) -> str:
        return (indent * '  ' + dump_or_value(self.name, indent) + ' = type ' +
                dump_or_value(self.value, indent))


class AttrAliasDef(Definition):
    pass


class AffineMapDef(Definition):
    pass


class SemiAffineMapDef(Definition):
    pass


class IntSetDef(Definition):
    pass


##############################################################################
# Helpers


def _dump_ast_or_value(value: Any, python=True, indent: int = 0) -> str:
    """ Helper function to dump the AST node type or a reconstructible
        node value.
        :param python: Use Python syntax for output.
    """
    if python and hasattr(value, 'dump_ast'):
        return value.dump_ast()
    if not python and hasattr(value, 'dump'):
        return value.dump(indent=indent)

    # Literals
    if not python and isinstance(value, bool):
        return 'true' if value else 'false'
    if python and isinstance(value, str):
        return '"%s"' % value

    # Primitive types
    if isinstance(value, list):
        if not python:
            return ', '.join(_dump_ast_or_value(v, python) for v in value)
        return '[%s]' % ', '.join(_dump_ast_or_value(v, python) for v in value)
    if isinstance(value, tuple):
        return '(%s%s)' % (', '.join(
            _dump_ast_or_value(v, python)
            for v in value), ', ' if python else '')
    if isinstance(value, dict):
        sep = ': ' if python else ' = '
        return '{%s}' % ', '.join(
            '%s%s%s' %
            (_dump_ast_or_value(k, python), sep, _dump_ast_or_value(v, python))
            for k, v in value.items())
    return str(value)


def dump_or_value(value: Any, indent: int = 0) -> str:
    """ Helper function to dump the MLIR value or a reconstructible
        node value. """
    return _dump_ast_or_value(value, python=False, indent=indent)
