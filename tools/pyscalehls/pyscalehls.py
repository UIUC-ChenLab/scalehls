#!/usr/bin/env python3


import argparse
import shutil
import io
from subprocess import PIPE, run
import scalehls
import mlir.ir
from mlir.dialects import builtin
import numpy as np


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
    fin = do_run(['mlir-clang', '-S',
                  '-function=' + opts.function,
                  '-memref-fullrank',
                  '-raise-scf-to-affine',
                  opts.input])

    # Parse MLIR into memory.
    ctx = mlir.ir.Context()
    scalehls.register_dialects(ctx)
    mod = mlir.ir.Module.parse(fin, ctx)

    # Traverse all functions in the MLIR module.
    for func in mod.body:
        if not isinstance(func, builtin.FuncOp):
            pass
        func.__class__ = builtin.FuncOp

        # Collect all suitable loop bands in the function.
        bands = scalehls.LoopBandList(func)
        for band in bands:
            # Attempt to erfectize the loop band.
            scalehls.apply_loop_perfection(band)

            # Maximize the distance of loop-carried dependencies through loop permutation.
            scalehls.apply_loop_order_opt(band)

            # Apply loop permutation based on the provided map.
            # Note: This example permMap will keep the loop order unchanged.
            permMap = np.arange(band.size)
            scalehls.apply_loop_permutation(band, permMap)

            # Attempt to remove variable loop bounds if possible.
            scalehls.apply_remove_variable_bound(band)

            # Apply loop tiling. Tile sizes are defined from the outermost loop to the innermost.
            tileList = np.ones(band.size, dtype=int)
            tileList[-1] = 2
            loc = scalehls.apply_loop_tiling(band, tileList)

            # Apply loop pipelining. All loops inside of the pipelined loop are fully unrolled.
            scalehls.apply_loop_pipelining(band, loc, 3)  # targetII

        # Legalize the IR to make it emittable.
        scalehls.apply_legalize_to_hlscpp(
            func, func.sym_name.value == opts.function)

        # Optimize memory accesses through store forwarding, etc.
        scalehls.apply_memory_access_opt(func)

        # Apply suitable array partition strategies through analyzing the array access pattern.
        scalehls.apply_array_partition(func)

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
