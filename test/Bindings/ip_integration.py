import scalehls
from mlir.ir import *

import networkx as nx
import networkx.algorithms.isomorphism as iso

test_name = "gemm_32"
mlir_path = "scalehls/samples/polybench/gemm/gemm_32.mlir"
f = open(mlir_path, 'r')
mlir = f.read()

ctx = Context()
mod = Module.parse(mlir, ctx)

for op in mod.body:
    print(op)

G1 = nx.DiGraph()
G2 = nx.DiGraph()
nx.add_path(G1, [1, 2, 3, 4], weight=1)
nx.add_path(G2, [10, 20, 30, 40], weight=2)
em = iso.numerical_edge_match("weight", 1)
print(nx.is_isomorphic(G1, G2))  # no weights considered
print(nx.is_isomorphic(G1, G2, edge_match=em))  # match weights

#f = open(test_name + ".cpp", 'w+')
#scalehls.emit_hlscpp(mod, f)