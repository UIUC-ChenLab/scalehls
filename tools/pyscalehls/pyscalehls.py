#!/usr/bin/env python


import argparse
import shutil
import io
from subprocess import PIPE, run
import scalehls
import mlir.ir
from mlir.dialects import builtin


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

        # Apply loop optimizations to all suitable loop bands.
        bands = scalehls.LoopBandList(func)
        for band in bands:
            scalehls.apply_affine_loop_perfection(band)
            scalehls.apply_affine_loop_order_opt(band)
            scalehls.apply_remove_variable_bound(band)
            scalehls.apply_loop_pipelining(band, band.size - 1, 3)  # targetII

        # Apply function optimizations.
        scalehls.apply_legalize_to_hlscpp(
            func, func.sym_name.value == opts.function)
        scalehls.apply_memory_access_opt(func)
        scalehls.apply_array_partition(func)

    # Emit MLIR to HLS C++.
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
