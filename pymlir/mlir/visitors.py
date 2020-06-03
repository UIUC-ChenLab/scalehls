""" Classes containing MLIR AST traversal and transformation functionality. """

from mlir import astnodes


def iter_fields(node: astnodes.Node):
    """
    Iterates over the fields of an MLIR AST node. Yields a two-tuple of
    (name, value).
    :param node: The AST node to iterate over.
    """
    for field in node._fields_:
        yield field, getattr(node, field)


class NodeVisitor(object):
    """
    A node visitor class that follows the API and features of ast.NodeVisitor.
    The visitor walks the MLIR AST and calls a visitor function for every node
    type. The visit function may return a value which is forwarded by internal
    calls.

    To create a node visitor, implement a sub-class of this class by adding
    methods called ``visit_NODETYPE``, where ``NODETYPE`` is the class name
    of an MLIR AST (or dialect) node type. For example, to implement a hook when
    an operation (``mlir.astnodes.Operation``) is encountered, create a method
    called ``visit_Operation``.

    See ``ast.NodeVisitor`` for more information.
    """

    def visit(self, node: astnodes.Node):
        """ Visit a node. """
        method = 'visit_' + node.__class__.__name__
        visitor = getattr(self, method, self.generic_visit)
        return visitor(node)

    def generic_visit(self, node: astnodes.Node):
        """ Called if no explicit visitor function exists for a node. """
        for field, value in iter_fields(node):
            if isinstance(value, list):
                for item in value:
                    if isinstance(item, astnodes.Node):
                        self.visit(item)
            elif isinstance(value, astnodes.Node):
                self.visit(value)


class NodeTransformer(NodeVisitor):
    """
    A ``NodeVisitor`` subclass that can modify and remove AST nodes.
    The interface and usage of this class follows ``ast.NodeTransformer``. See
    its documentation for more information.
    """

    def generic_visit(self, node: astnodes.Node):
        """
        Called if no explicit visitor function exists for a node.
        Implements modification and removal of list elements in fields.
        """
        for field, old_value in iter_fields(node):
            if isinstance(old_value, list):
                new_values = []
                for value in old_value:
                    if isinstance(value, astnodes.Node):
                        value = self.visit(value)
                        if value is None:
                            continue
                        elif not isinstance(value, astnodes.Node):
                            new_values.extend(value)
                            continue
                    new_values.append(value)
                old_value[:] = new_values
            elif isinstance(old_value, astnodes.Node):
                new_node = self.visit(old_value)
                if new_node is None:
                    delattr(node, field)
                else:
                    setattr(node, field, new_node)
        return node
