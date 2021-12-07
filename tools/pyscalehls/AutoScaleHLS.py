#this assumes that input C file uses output from scalehls

import numpy as np
import argparse

#AutoHLS dependencies
from lib import RanTrainML as RTML
from lib import DSEinputparse as INPAR
from lib import pyScaleHLS as PYSHLS


def main():
    parser = argparse.ArgumentParser(prog='Cfor_lex')
    parser.add_argument('-i', dest='input',
                        metavar="input",
                        help='maunual input file')
    parser.add_argument('-t', dest='topfun',
                    metavar="topfun",
                    help='top_function')
    parser.add_argument('-p', dest='part',
                    metavar="part",
                    help='SoC part')                    
    opts = parser.parse_args()

    #cheak if manual input is given
    inputfiles = []
    if opts.input:
        source_file = opts.input
        inputtop = opts.topfun
        inputpart = opts.part
        template = INPAR.read_template()
    else:
        source_file, inputtop, inputpart, inputfiles, template = INPAR.read_user_input()

    #scaleHLS optimization
    PYSHLS.ScaleHLSopt(source_file, inputtop, "generated_files/ScaleHLS_opted.c")

    #process input
    #var_forlist, var_arraylist_sized = INPAR.process_source_file(source_file)

    #create paramfile
    #INPAR.create_params(var_forlist, var_arraylist_sized)

    #create template
    #INPAR.create_template(source_file, inputfiles, template)

    #RTML.random_train_RFML(inputtop, inputpart)
    















if __name__ == '__main__':
    main()
