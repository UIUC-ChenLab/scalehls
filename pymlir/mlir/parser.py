""" Contains classes that parse MLIR files """

import itertools
from lark import Lark, Tree
import os
import sys
from typing import List, Optional, TextIO
import runpy

from mlir.parser_transformer import TreeToMlir
from mlir.dialect import Dialect, add_dialect_rules
from mlir.dialects import STANDARD_DIALECTS
from mlir import astnodes as mast


class Parser(object):
    """
    A reusable pyMLIR parser. Parses multiple strings faster than repeatedly
    calling ``mlir.parse_*``.
    """

    def __init__(self, dialects: Optional[List[Dialect]] = None):
        """
        Initializes a reusable pyMLIR parser.
        :param dialects: An optional list of additional dialects to load (in
                         addition to the built-in dialects).
        """
        self.dialects = dialects or []

        # Lazy-load (if necessary) the Lark files
        _lazy_load()

        # Initialize EBNF source for parser
        parser_src = _MLIR_LARK + '\n'

        # Check validity of given dialects
        dialects = dialects or []
        builtin_names = [dialect.name for dialect in STANDARD_DIALECTS]
        additional_names = [dialect.name for dialect in dialects]
        dialect_set = set(builtin_names) | set(additional_names)
        if len(dialect_set) != (len(dialects) + len(STANDARD_DIALECTS)):
            raise NameError(
                'Additional dialect already exists (built-in dialects: %s, '
                'given dialects: %s)' % (builtin_names, additional_names))

        # Add dialect contents to parser
        rule_dict_ops = {}
        rule_dict_types = {}
        for dialect in itertools.chain(STANDARD_DIALECTS, dialects):
            # Add preamble for dialect
            parser_src += dialect.contents
            # Add rules for operations and types
            parser_src += add_dialect_rules(dialect, dialect.ops, 'op',
                                            rule_dict_ops)
            parser_src += add_dialect_rules(dialect, dialect.types, 'type',
                                            rule_dict_types)

        # Create a parser from the MLIR EBNF file, default dialects, and
        # additional dialects if exist
        op_expr = '?pymlir_dialect_ops: ' + '|'.join(rule_dict_ops.keys())
        type_expr = '?pymlir_dialect_types: ' + '|'.join(
            rule_dict_types.keys())
        parser_src += op_expr + '\n' + type_expr

        # Create parser and tree transformer
        self.parser = Lark(parser_src, parser='earley')
        self.transformer = TreeToMlir()

        # Add dialect rules to transformer
        for rule_name, ctor in itertools.chain(rule_dict_ops.items(),
                                               rule_dict_types.items()):
            setattr(self.transformer, rule_name, ctor)
        for dialect in itertools.chain(STANDARD_DIALECTS, dialects):
            for rule_name, rule in dialect.transformers.items():
                setattr(self.transformer, rule_name, rule)

    def parse(self, code: str) -> mast.Module:
        """
        Parses a string representing code in MLIR, returning the top-level
        AST node.
            :param code: A code string in MLIR format.
            :return: A module node representing the root of the AST.
        """

        # Pre-transform code to avoid parsing issues with ceildiv/floordiv/mod,
        # in which two symbols could be parsed as one legal symbol (due to
        # ignoring whitespace): "d0floordivs0"
        code = code.replace(' floordiv ', '&floordiv&')
        code = code.replace(' ceildiv ', '&ceildiv&')
        code = code.replace(' mod ', '&mod&')

        # Parse the code using Lark
        tree = self.parser.parse(code)

        # Transform the tree to our AST node classes
        root_node = self.transformer.transform(tree)

        # If the root node is a function/definition or a list thereof, return
        # a top-level module
        if not isinstance(root_node, mast.Module):
            if isinstance(root_node, Tree) and root_node.data == 'start':
                return mast.Module([root_node])
            return mast.Module(root_node)
        return root_node


# Load the MLIR EBNF syntax to memory once
_MLIR_LARK = None


def _lazy_load():
    """
    Loads the Lark EBNF files (MLIR and default dialects) into memory upon
    first use.
    """
    global _MLIR_LARK

    # Lazily load the MLIR EBNF file and the dialects
    if _MLIR_LARK is None:
        # Find path to files
        mlir_path = os.path.join(
            os.path.abspath(os.path.dirname(__file__)), 'lark')

        with open(os.path.join(mlir_path, 'mlir.lark'), 'r') as fp:
            _MLIR_LARK = fp.read()


def parse_string(code: str,
                 dialects: Optional[List[Dialect]] = None) -> mast.Module:
    """
    Parses a string representing code in MLIR, returning the top-level AST node.
    :param code: A code string in MLIR format.
    :param dialects: An optional list of additional dialects to load (in
                     addition to the built-in dialects).
    :return: A module node representing the root of the AST.
    """
    parser = Parser(dialects)
    return parser.parse(code)


def parse_file(file: TextIO,
               dialects: Optional[List[Dialect]] = None) -> mast.Node:
    """
    Parses an MLIR file from a given Python file-like object, returning the
    top-level AST node.
    :param file: Python file-like I/O object in text mode.
    :param dialects: An optional list of additional dialects to load (in
                     addition to the built-in dialects).
    :return: A module node representing the root of the AST.
    """
    return parse_string(file.read(), dialects)


def parse_path(file_path: str,
               dialects: Optional[List[Dialect]] = None) -> mast.Node:
    """
    Parses an MLIR file from a given filename, returning the top-level AST node.
    :param file_path: Path to file to parse.
    :param dialects: An optional list of additional dialects to load (in
                     addition to the built-in dialects).
    :return: A module node representing the root of the AST.
    """
    with open(file_path, 'r') as fp:
        return parse_file(fp, dialects)


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print('USAGE: python -m mlir.parser <MLIR FILE> [DIALECT PATHS...]')
        exit(1)

    additional_dialects = []
    for dialect_path in sys.argv[2:]:
        # Load Python file with dialect
        global_vars = runpy.run_path(dialect_path)

        additional_dialects.extend(
            v for v in global_vars.values() if isinstance(v, Dialect))

    print(parse_path(sys.argv[1], dialects=additional_dialects).pretty())
