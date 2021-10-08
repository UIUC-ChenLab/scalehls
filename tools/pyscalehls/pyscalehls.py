#!/usr/bin/env python


import argparse
import shutil
import sys
import io
import scalehls
from mlir.ir import *


def main():
    parser = argparse.ArgumentParser(prog='pyscalehls')
    parser.add_argument('input',
                        metavar="input",
                        help='MLIR input file')
    parser.add_argument('-o', dest='output',
                        metavar="output",
                        help='HLS C++ output file')
    parser.add_argument('-f', dest='function',
                        metavar="function",
                        help='Top function')

    opts = parser.parse_args()

    ctx = Context()
    ctx.allow_unregistered_dialects = True
    fin = open(opts.input, 'r')
    mod = Module.parse(fin.read(), ctx)
    fin.close()

    for op in mod.body:
        scalehls.apply_legalize_to_hlscpp(op.operation, True)
        scalehls.apply_array_partition(op.operation)

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
