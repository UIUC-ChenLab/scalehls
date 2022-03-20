#!/usr/bin/env python3


import argparse
import shutil
import io
from subprocess import PIPE, run
import scalehls
import mlir.ir
from mlir.dialects import builtin
import numpy as np
import subprocess


def do_run(command):
    ret = run(command, stdout=PIPE, stderr=PIPE, universal_newlines=True)
    return ret.stdout


def main():
    parser = argparse.ArgumentParser(prog='pyscalehls')
    parser.add_argument('input',
                        metavar="input",
                        help='HLS C/C++ input file')
    parser.add_argument('-o', dest='output',
                        metavar="output",
                        help='HLS C++ output file')
    parser.add_argument('-f', dest='function',
                        metavar="function",
                        required=True,
                        help='Top function')

    # Parse command line arguments.
    opts = parser.parse_args()

    # Call `mlir-clang` to parse HLS C/C++ into MLIR.
    p1 = subprocess.Popen(['mlir-clang', opts.input, '-function=' + opts.function, '-memref-fullrank', '-raise-scf-to-affine', '-S'], stdout=subprocess.PIPE, stderr=PIPE, universal_newlines=True)                          
    p2 = subprocess.run(['scalehls-opt', '-allow-unregistered-dialect', '-materialize-reduction'], stdin=p1.stdout, stdout=subprocess.PIPE, stderr=PIPE, universal_newlines=True)                  
    fin = p2.stdout

    # Parse MLIR into memory.
    ctx = mlir.ir.Context()
    scalehls.register_dialects(ctx)
    mod = mlir.ir.Module.parse(fin, ctx)

    print(mod)

    # Traverse all functions in the MLIR module.
    for func in mod.body:
        if not isinstance(func, builtin.FuncOp):
            pass
        func.__class__ = builtin.FuncOp

        # Traverse all suitable loop bands in the function.
        bands = scalehls.LoopBandList(func)
        for band in bands:

            print(band)

            # Attempt to perfectize the loop band.
            scalehls.loop_perfectization(band)

            # Maximize the distance of loop-carried dependencies through loop permutation.
            scalehls.loop_order_opt(band)

            # Apply loop permutation based on the provided map.
            # Note: This example "permMap" keeps the loop order unchanged.
            permMap = np.arange(band.depth)
            scalehls.loop_permutation(band, permMap)

            # Attempt to remove variable loop bounds if possible.
            scalehls.loop_var_bound_removal(band)

            # Apply loop tiling. Tile sizes are defined from the outermost loop to the innermost.
            # Note: We use the trip count to generate this example "factors".
            print("test")
            factors = np.ones(band.depth, dtype=int)
            print(factors)
            factors[-1] = band.get_trip_count(band.depth - 1) / 4
            print(factors)
            loc = scalehls.loop_tiling(band, factors, True) # simplify = True
            print(loc)

            # Apply loop pipelining. All loops inside of the pipelined loop are fully unrolled.
            scalehls.loop_pipelining(band, 0, 3)  # targetII = 3

        # Traverse all arrays in the function.
        arrays = scalehls.ArrayList(func)
        for array in arrays:
            type = array.type
            type.__class__ = mlir.ir.MemRefType
            if not type.has_rank:
                pass
            # Apply specified factors and partition kind to the array.
            # Note: We use the dimension size to generate this example "factors".
            factors = np.ones(type.rank, dtype=int)
            factors[-1] = type.get_dim_size(type.rank - 1) / 4
            scalehls.array_partition(array, factors, "cyclic")

        # Legalize the IR to make it emittable.
        scalehls.legalize_to_hlscpp(
            func, func.sym_name.value == opts.function)

        # Optimize memory accesses through store forwarding, etc.
        scalehls.memory_access_opt(func)

        # Apply suitable array partition strategies through analyzing the array access pattern.
        # scalehls.auto_array_partition(func)

    # Emit optimized MLIR to HLS C++.
    buf = io.StringIO()
    scalehls.emit_hlscpp(mod, buf)
    buf.seek(0)
    if opts.output:
        fout = open(opts.output, 'w+')
        shutil.copyfileobj(buf, fout)
        fout.close()
    else:
        print(buf.read())


if __name__ == '__main__':
    main()