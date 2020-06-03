[![Build Status](https://travis-ci.org/spcl/pymlir.svg?branch=master)](https://travis-ci.org/spcl/pymlir)
[![codecov](https://codecov.io/gh/spcl/pymlir/branch/master/graph/badge.svg)](https://codecov.io/gh/spcl/pymlir)


# pyMLIR: Python Interface for the Multi-Level Intermediate Representation

pyMLIR is a full Python interface to parse, process, and output [MLIR](https://mlir.llvm.org/) files according to the
syntax described in the [MLIR documentation](https://github.com/llvm/llvm-project/tree/master/mlir/docs). pyMLIR 
supports the basic dialects and can be extended with other dialects. It uses [Lark](https://github.com/lark-parser/lark)
to parse the MLIR syntax, and mirrors the classes into Python classes. Custom dialects can also be implemented with a
Python string-format-like syntax, or via direct parsing.

Note that the tool *does not depend on LLVM or MLIR*. It can be installed and invoked directly from Python. 

## Instructions 

**How to install:** `pip install pymlir`

**Requirements:** Python 3.6 or newer, and the requirements in `setup.py` or `requirements.txt`. To manually install the
requirements, use `pip install -r requirements.txt`

**Problem parsing MLIR files?** Run the file through LLVM's `mlir-opt --mlir-print-op-generic` to get the generic form
of the IR (instructions on how to build/install MLIR can be found [here](https://mlir.llvm.org/getting_started/)):
```
$ mlir-opt file.mlir --mlir-print-op-generic > output.mlir
```

**Found other problems parsing files?** Not all dialects and modes are supported. Feel free to send us an issue or
create a pull request! This is a community project and we welcome any contribution.

## Usage examples

### Parsing MLIR files into Python

```python
import mlir

# Read a file path, file handle (stream), or a string
ast1 = mlir.parse_path('/path/to/file.mlir')
ast2 = mlir.parse_file(open('/path/to/file.mlir', 'r'))
ast3 = mlir.parse_string('''
module {
  func @toy_func(%tensor: tensor<2x3xf64>) -> tensor<3x2xf64> {
    %t_tensor = "toy.transpose"(%tensor) { inplace = true } : (tensor<2x3xf64>) -> tensor<3x2xf64>
    return %t_tensor : tensor<3x2xf64>
  }
}
''')
```

### Inspecting MLIR files in Python

MLIR files can be inspected by dumping their contents (which will print standard MLIR code), or by using the same tools
as you would with Python's [ast](https://docs.python.org/3/library/ast.html) module.

```python
import mlir

# Dump valid MLIR files
m = mlir.parse_path('/path/to/file.mlir')
print(m.dump())

print('---')

# Dump the AST directly
print(m.dump_ast())

print('---')

# Or visit each node type by implementing visitor functions
class MyVisitor(mlir.NodeVisitor):
    def visit_Function(self, node: mlir.astnodes.Function):
        print('Function detected:', node.name.value)
        
MyVisitor().visit(m)
```

### Transforming MLIR files

MLIR files can also be transformed with a Python-like 
[NodeTransformer](https://docs.python.org/3/library/ast.html#ast.NodeTransformer) object.

```python
import mlir

m = mlir.parse_path('/path/to/file.mlir')

# Simple node transformer that removes all operations with a result
class RemoveAllResultOps(mlir.NodeTransformer):
    def visit_Operation(self, node: mlir.astnodes.Operation):
        # There are one or more outputs, return None to remove from AST
        if len(node.result_list) > 0:
            return None
            
        # No outputs, no need to do anything
        return self.generic_visit(node)
        
m = RemoveAllResultOps().visit(m)

# Write back to file
with open('output.mlir', 'w') as fp:
    fp.write(m.dump())
```

### Using custom dialects

Custom dialects can be written and loaded as part of the pyMLIR parser. [See full tutorial here](doc/custom_dialect.rst).

```python
import mlir
from lark import UnexpectedCharacters
from .mydialect import dialect

# Try to parse as-is
try:
    m = mlir.parse_path('/path/to/matrixfile.mlir')
except UnexpectedCharacters:  # MyMatrix dialect not recognized
    pass
    
# Add dialect to the parser
m = mlir.parse_path('/path/to/matrixfile.mlir', 
                    dialects=[dialect])

# Print output back
print(m.dump_ast())
```

### Built-in dialect implementations and more examples

All dialect implementations can be found in the [dialects](mlir/dialects) subfolder. Additional uses
of the library, including a custom dialect implementation, can be found in the [tests](tests)
subfolder.
