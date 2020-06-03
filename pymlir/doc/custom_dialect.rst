Creating a Custom Dialect
=========================

One of MLIR's most powerful features is being able to define custom dialects. While the
opaque syntax is always supported by pyMLIR, parsing "pretty" definitions of custom dialects
is done by adding them to the ``dialects`` field of the MLIR parser, as in the following
snippet:

.. code-block:: python

  import mlir

  # Load dialect from Python file
  import mydialect

  # Add dialect to the parser
  m = mlir.parse_path('/path/to/file.mlir', dialects=[mydialect.dialect])

A dialect is represented by a ``Dialect`` class, which is composed of custom types and
operations. In this document, we use ``toy`` as the dialect's name.

The structure of a dialect file is usually as follows::

    # Imports
    # Dialect type AST node classes
    # Dialect operation AST node classes
    # Dialect class definition

Simple Dialect Syntax API
-------------------------

To make dialect definition as simple as possible, pyMLIR provides a Syntax API based on
Python's ``str.format`` grammar. Defining a dialect type or operation using the Syntax API
is then performed as follows:

.. code-block:: python

    from mlir.dialect import DialectOp, DialectType

    class RaggedTensorType(DialectType):
        """ AST node class for the example "toy" dialect representing a ragged tensor. """
        _syntax_ = ('toy.ragged < {implementation.string_literal} , {dims.dimension_list_ranked} '
                    '{type.tensor_memref_element_type} >')

The syntax format parses any ``{name.type}`` token as an AST node field ``name`` with
type ``type``. The types that can be used either come from ``mlir.lark``, or from the
``preamble`` argument to the ``Dialect`` class (see below). Note the spaces between
tokens - they represent the fact that whitespace can be inserted between them.

pyMLIR will then detect the three fields (``implementation``, ``dims``, and ``type``) and
inject them into the AST node type. You can specify more than one match for your type
or operation, and if fields are not defined they will be set as ``None``. Example:

.. code-block:: python

    class DensifyOp(DialectOp):
        """ AST node for an operation with an optional value. """
        _syntax_ = ['toy.densify {arg.ssa_id} : {type.tensor_type}',
                    'toy.densify {arg.ssa_id} , {pad.constant_literal} : {type.tensor_type}']

When dumping the code back to MLIR, pyMLIR remembers which match created the AST node and
will create the appropriate code.

Constructing the dialect itself follows creating the object with a unique dialect name, and
all the operations and types.

.. code-block:: python

    from mlir.dialect import Dialect
    from mlir import parse_path

    # Define dialect
    my_dialect = Dialect('toy', ops=[DensifyOp], types=[RaggedTensorType])

    # Use dialect to parse file
    module = parse_path('/path/to/toy_file.mlir', dialects=[my_dialect])

Advanced Dialect Behavior
-------------------------

In order to extend custom behavior in the dialect (e.g., to change how a node is read
or written), you can extend the ``DialectOp`` or ``DialectType`` classes.
In addition, there are two mechanisms that can be used in the ``Dialect`` class in order
to parse concepts beyond nodes for types and operations: ``preamble`` and ``transformers``.

Writing a new AST node has four implementation requirements:

1. Populating the ``_fields_`` static class member
2. Implementing an ``__init__`` function to parse Lark syntax trees
3. Implementing a ``dump`` function to output a string with the MLIR syntax
4. Either implementing a Lark rule in the ``Dialect`` preamble with and mapping the rule
   name to the class using the ``_rule_`` static class member, or defining the Lark
   rules directly in the ``_lark_`` static class member

For example, if we wanted to be strict with how we dump the ``RaggedTensorType``, and use
our custom rule for parsing, we would implement the class in the following way:

.. code-block:: python

    from mlir.dialect import DialectType
    from mlir.astnodes import Node, dump_or_value
    from lark import Tree
    from typing import Union, List

    class RaggedTensorType(DialectType):
        _fields_ = ['implementation', 'dims', 'type']
        # Notice that the first argument is optional
        _lark_ = ['"toy.ragged" "<" (string_literal ",")? dimension_list_ranked '
                  'tensor_memref_element_type ">"']

        def __init__(self, match: int, node: List[Union[Tree, Node]], **fields):
            # Note that since _lark_ has only one element, "match" will always be 0
            if len(node) == 2:  # Only dims and type were defined
                self.implementation = None
                self.dims = node[0]
                self.type = node[1]
            elif len(node) == 3:  # All three fields were defined
                self.implementation = node[0]
                self.dims = node[1]
                self.type = node[2]
            super().__init__(None, **fields)

        def dump(self, indent: int = 0) -> str:
            # Note the exclamation mark denoting a dialect type
            result = '!toy.ragged<'
            if self.implementation:
                result += dump_or_value(self.implementation, indent)
            result += '%sx%s>' % ('x'.join(dump_or_value(d, indent) for d in self.dims),
                                  dump_or_value(self.type, indent))
            return result

``dump_or_value`` is a helper function in ``mlir.astnodes`` to either write out the value,
a list/dict/tuple of values, or literals into MLIR format. For most cases, though, the
``_syntax_`` format will suffice (and creates shorter code than above).

As for extensions to the dialect itself, ``preamble`` and ``transformers`` are keyword
arguments that can be given to the ``Dialect`` class. The former allows arbitrary Lark
syntax to be parsed as part of the dialect, and the latter is a dictionary that maps
rule names to node-constructing callable functions/classes. This gives a custom dialect
full control over the syntax parsing and tree construction.

For example, we can create rules for a new kind of list structure in our toy dialect:

.. code-block:: python

    my_dialect = Dialect('toy', ops=[DensifyOp], types=[RaggedTensorType],
                         preamble='''
    // Exclamation mark in Lark means that string tokens will be preserved upon parsing
    !toy_impl_type : "coo" | "csr" | "csc" | "ell"
    toy_impl_list   : toy_impl_type ("+" toy_impl_type)*
                         ''',
                         transformers=dict(
                            toy_impl_list=list  # Will construct a list from parsed values
                         ))

Now we can parse lists of specific implementation types for our ragged tensor, e.g.,
``toy.ragged<coo+csr,32x14xf64>`` rather than one string literal. Note that
the type ``_lark_`` or ``_syntax_`` has to change accordingly.
