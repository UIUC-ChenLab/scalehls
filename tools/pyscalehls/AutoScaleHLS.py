#this assumes that input C file uses output from scalehls

import numpy as np
import pandas as pd
import argparse

#AutoHLS dependencies
from lib import RandInit as RT
from lib import DSEinputparse as INPAR
from lib import pyScaleHLS as PYSHLS
from lib import DSE_main as DMain

def print_optknobs(opt_knobs, opt_knob_names):
    for i in range(len(opt_knobs) - 1):
        print("{0}: {1}".format(opt_knob_names[i+1], opt_knobs[i+1]))

def print_variables(var_forlist, var_arraylist_sized):
    print("Loops")
    for item in var_forlist :
        print(item)
    
    print("Arrays")
    for item in var_arraylist_sized :
        print(item)      

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
    val = ""
    while val == "":
        # val = input("Do you want ScaleHLS optimizations? (Y / N)\n")
        val = "y"
        if((val == "Y") or (val == "y") or (val == "yes")):
            opt_knobs, opt_knob_names = PYSHLS.ScaleHLSopt(source_file, inputtop, "generated_files/ScaleHLS_opted.c")        
            
            #print
            print_optknobs(opt_knobs, opt_knob_names)

            var_forlist, var_arraylist_sized = INPAR.process_source_file("generated_files/ScaleHLS_opted.c")
            #print
            print_variables(var_forlist, var_arraylist_sized)

        elif((val == "N") or (val == "n") or (val == "no")):
            var_forlist, var_arraylist_sized = INPAR.process_source_file(source_file)
            #print
            print_variables(var_forlist, var_arraylist_sized)   
    
    #create paramfile
    INPAR.create_params(var_forlist, var_arraylist_sized)

    #create template
    INPAR.create_template(source_file, inputfiles, template)

    #Create Random Training Set
    val = ""
    while val == "":
        # val = input("Generate Random Training Set? (Y / N)\n")
        val = "n"
        if((val == "Y") or (val == "y") or (val == "yes")):
            dataset, feature_columns = RT.random_train_RFML(inputtop, inputpart, nub_of_init = 1)
        elif((val == "N") or (val == "n") or (val == "no")):
            parameter_file = 'generated_files/ML_params.csv'
            dataset, feature_columns, label_columns = RT.dataframe_create(parameter_file)
            # dataset = pd.read_csv('generated_files/ML_train.csv', index_col=0)
            dataset = pd.read_csv('generated_files/ML_train(test).csv', index_col=0)
            print(dataset)


    DMain.DSE_start(dataset, 50, inputtop, inputpart, feature_columns)
    















if __name__ == '__main__':
    main()
