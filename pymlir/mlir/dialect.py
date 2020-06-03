""" MLIR Dialect representation. """

import inspect
from lark import Token
from mlir import astnodes
import parse
from typing import Any, Callable, Dict, List, Optional, Tuple, Type, Union


def _get_fields(syntax: str):
    return [
        tuple(name.split('.'))
        for name in parse.compile(syntax)._name_types.keys()
    ]


class DialectElement(astnodes.Node):
    """
    A class that can be extended by a dialect to define an MLIR AST node.
    In the simple case, the subclass only needs to implement a list of syntax
    rules (in ``_syntax_``) for parsing. See examples for use cases. In more
    complicated nodes (i.e., with optional or variable-length parameters), a
    new parsing (as ``__init__``) and dumping (``dump``) methods have to be
    implemented, along with the node field names (stored in ``_fields_``).
    """

    # A Python string-format syntax for matching this operation, using a
    # "{name.type}" syntax. The types can either be provided in the dialect
    # preamble, or using the definitions in "mlir.lark". If multiple formats
    # may match, a list can be provided. For example:
    # ['return', 'return {values.ssa_use_list} : {types.type_list_no_parens}']
    # will implement the return operation in the Standard dialect.
    _syntax_: Optional[Union[str, List[str]]] = None

    # If custom behavior is defined through the dialect preamble, define rule
    # name on this variable to match this class
    _rule_: Optional[str] = None

    # Internal fields to be filled by make_rules
    _syntax_fields_: Optional[List[List[Tuple[str, str]]]] = None
    _lark_: Optional[List[str]] = None

    @classmethod
    def make_rules(cls):
        if cls._syntax_ is None:
            return

        # Set _fields_ according to _syntax_
        if isinstance(cls._syntax_, str):
            cls._syntax_ = [cls._syntax_]
        if not isinstance(cls._syntax_, (list, tuple)):
            raise ValueError('Invalid syntax expression (can only be a string '
                             'or a list of strings')
        # Collect fields and create lark expressions
        fields = set()
        lark_exprs = []
        compiled_fields = []
        for syntax in cls._syntax_:
            sfields = _get_fields(syntax)
            compiled_fields.append(sfields)
            if any(len(field) != 2 for field in sfields):
                raise ValueError(
                    'Syntax matches must provide exactly one name '
                    'and one type')
            fields |= set(f[0] for f in sfields)

            # Create Lark expression
            # Replace {{ and }}
            syntax = syntax.replace('{{', '{LBRACE}').replace('}}', '{RBRACE}')
            # Replace words with strings
            syntax = ' '.join(
                (('"%s"' % word) if not word.startswith('{') else word)
                for word in syntax.split())
            # Replace back {field.type} with types
            for fname, ftype in sfields:
                syntax = syntax.replace('{%s.%s}' % (fname, ftype), ftype)
            # Replace back braces
            syntax = syntax.replace('{LBRACE}', '{')
            syntax = syntax.replace('{RBRACE}', '}')
            lark_exprs.append(syntax)

        cls._fields_ = list(fields)
        cls._syntax_fields_ = compiled_fields
        cls._lark_ = lark_exprs

    def __init__(self, match: int, node: Token = None, **fields):
        if self._syntax_ is None and node is not None:
            raise NotImplementedError('Dialect element must either use '
                                      '"_syntax_" or implement its own '
                                      'constructor')
        if node is None:
            super().__init__(None, **fields)
            return

        # Get syntax expression
        self._match = match
        sfields = self._syntax_fields_[match]
        other_fields = set(self._fields_) - set(f[0] for f in sfields)

        # Set each field according to defined names
        if node is not None and isinstance(node, list):
            for fname, fval in zip(sfields, node):
                setattr(self, fname[0], fval)

        # Set other fields to None
        for fname in other_fields:
            setattr(self, fname, None)

        super().__init__(None, **fields)

    def dump(self, indent: int = 0) -> str:
        if self._syntax_ is None:
            raise NotImplementedError('Dialect element must either use '
                                      '"_syntax_" or implement its own '
                                      '"dump" method')

        sfields = self._syntax_fields_[self._match]
        dump_str = self._syntax_[self._match]
        for fname, ftype in sfields:
            dump_str = dump_str.replace('{%s.%s}' % (fname, ftype),
                                        '{%s}' % fname)
        return dump_str.format_map({
            f[0]: astnodes.dump_or_value(getattr(self, f[0]), indent)
            for f in sfields
        })


class DialectOp(DialectElement):
    """ A class that can be extended by a dialect to define an MLIR AST node
        for an operation. See DialectElement for more details. """
    pass


class DialectType(DialectElement):
    """ A class that can be extended by a dialect to define an MLIR AST node
        for a data type. See DialectElement for more details. """

    def dump(self, indent: int = 0) -> str:
        return '!' + super().dump(indent)


class Dialect(object):
    def __init__(
            self,
            name: str,
            ops: Optional[List[Type[DialectOp]]] = None,
            types: Optional[List[Type[DialectType]]] = None,
            preamble: Optional[str] = None,
            transformers: Optional[Dict[str, Union[Callable, Type]]] = None):
        """

        :param name: Dialect name (should be unique).
        :param ops: A list of dialect AST nodes for operations.
        :param types: A list of dialect AST nodes for types.
        :param preamble: Preamble in Lark syntax for the dialect.
        :param transformers: A dictionary that maps between rule names in the
                             Lark preamble to Python classes or AST node types.
        """
        self.contents = preamble or ''
        self.name = name
        self.ops = ops or []
        self.types = types or []
        self.transformers = transformers or {}

        # Make syntactic rules for each operation and type
        for op in self.ops:
            op.make_rules()
        for typ in self.types:
            typ.make_rules()


def add_dialect_rules(dialect: Dialect, elements: List[Type[DialectElement]],
                      typename: str, rule_dict: Dict[str, Callable]) -> str:
    """
    Add dialect rules in Lark form to an MLIR parser.
    :param dialect: The dialect object to use.
    :param elements: A list of dialect elements (e.g. ops, types) to add.
    :param typename: A prefix to add to the new element rules.
    :param rule_dict: An existing rule dictionary (intended for a Lark
                      Transformer) to add the elements to.
    :return: Lark source code containing new rules as necessary.
    """
    parser_src = ''
    for elem in elements:
        if elem._rule_ is not None:  # Custom rules defined in dialect
            rule_dict[elem._rule_] = elem
            continue
        if elem._lark_ is None:
            raise SyntaxError('Either a "_rule_" or "_syntax_" must '
                              'be defined for dialect element '
                              '%s' % elem.__name__)

        # Fill contents with procedurally-generated rules
        for i, rule in enumerate(elem._lark_):
            rule_name = '%s_%s_%s_%d' % (dialect.name, typename,
                                         elem.__name__.lower(), i)
            parser_src += '%s: %s\n' % (rule_name, rule)

            # Add rule to transformer
            def create_rule(elem, i):
                return lambda *value: elem(i, *value)

            rule_dict[rule_name] = create_rule(elem, i)

    return parser_src


def is_op(member: Any, module: str) -> bool:
    """ Returns true if an object is a Dialect operation subclass. """
    return (inspect.isclass(member) and issubclass(member, DialectOp)
            and member.__module__ == module)


def is_type(member: Any, module: str) -> bool:
    """ Returns true if an object is a Dialect type subclass. """
    return (inspect.isclass(member) and issubclass(member, DialectType)
            and member.__module__ == module)


#################################################################
# Helper classes for dialects


class UnaryOperation(DialectOp):
    """ Helper class to create unary operations in dialects. """
    _opname_ = 'UNDEF'

    @classmethod
    def make_rules(cls):
        cls._syntax_ = '%s {operand.ssa_use} : {type.type}' % cls._opname_
        super().make_rules()


class BinaryOperation(DialectOp):
    """ Helper class to create binary operations in dialects. """
    _opname_ = 'UNDEF'

    @classmethod
    def make_rules(cls):
        cls._syntax_ = (
            '%s {operand_a.ssa_use} , {operand_b.ssa_use} : {type.type}' %
            cls._opname_)
        super().make_rules()
