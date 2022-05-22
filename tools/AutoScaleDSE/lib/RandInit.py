import numpy as np
import pandas as pd
import os
import multiprocessing
import time
import random

# import logging
# import math
# from sklearn.model_selection import KFold
# from timeit import default_timer as timer
# from sklearn.preprocessing import OneHotEncoder
# from sklearn.tree import DecisionTreeRegressor
# from sklearn.ensemble import RandomForestRegressor, RandomForestClassifier
# from sklearn.model_selection import train_test_split
# from scipy.special import beta
# from math import factorial as fact
# from multiprocessing import Process
# import re
# import scipy
# import pprint
# import pickle


from lib import run_hls
from lib import generate_directives as gen_dir

def dataframe_create(parafile, no_partitioning = False):
    dataframe_columns = []
    tunable_params = pd.read_csv(parafile)
    list_columns = []
    for i in range(len(tunable_params)):
        knob = tunable_params.iloc[i]
        name=knob['name']
        scope=knob['scope']
        boundary = knob['range']
        dim = knob.at['dim']
        
        
        #removed due to 
        # A value is trying to be set on a copy of a slice from a DataFrame
        # See the caveats in the documentation: https://pandas.pydata.org/pandas-docs/stable/user_guide/indexing.html#returning-a-view-versus-a-copy
        # self._set_values(loc, value)
        
        # to fix the NaN problem for dim, since dim doesn't exist for loops 
        # try:
        #     knob.at['dim']=int(dim)
        # except ValueError:
        #     knob.at['dim']=int(0)
        
        # parse the file and find the column names, the naming MUST be consistent with generate_directives.py
        if(knob['type'] == 'loop' or knob['type'] == 'loopU'):
            list_columns.append('loop_'+name+'_type')
            list_columns.append('loop_'+name+'_factor')
        elif(knob['type'] == 'array'):
            if not no_partitioning:
                name=name+'_'+scope+'_dim'+str(int(dim))
                list_columns.append('array_'+name+'_type')
                list_columns.append('array_'+name+'_factor')
            else:
                pass
        else:
            raise AssertionError('Unknow knob type')
            
    # add the columns for HLS result
    list_columns = list_columns+['latency', 'dsp_perc', 'ff_perc', 'lut_perc', 'bram_perc', 'is_feasible', 'is_error']

    # initialize the datset to be empty (always)
    # made global for multiprocessing -> todo using class
    global dataset
    dataset = pd.DataFrame(columns=list_columns)

    # set the feature columns and label columns
    feature_columns = dataset.columns[:len(dataset.columns)-7]
    label_columns = dataset.columns[len(dataset.columns)-7:]
    return dataset, feature_columns, label_columns

def get_row(df, row):
    if len(df) == 0:
        # return empty if input is empty
        return pd.DataFrame()
    else:
        srs = pd.Series(np.full(len(df), True))
        for col in row.keys():            
            val = row[col]
            srs = srs & (df[col] == val)
        return df[srs]

def threaded_generate_random_training_set(parameter_file, directives_path, template_path, top_function, part):
    global dataset

    #generate unique name
    project_ident = str(int(time.time()))+'_'+str(random.getrandbits(16))
    directive_project_ident = directives_path + '_' + project_ident

    print("Evaluating point "+project_ident)

    # generate random training sets
    dir_gen = gen_dir.RandomDirectiveGenerator(parameter_file)

    while (True):
        # generate a new design point

        _, parameters = dir_gen.generate_directives(out_file_path=directive_project_ident, no_partitioning=False)

        # check if the design point is valid
        if (get_row(dataset, parameters).empty):
            break

    new_design_point = run_hls.get_perf(template_path, directive_project_ident, top_function, part, parameters, project_ident, verbose=False, timelimit=10000)

    # remove the tcl file
    try:
        os.remove(directive_project_ident)
    except OSError as e:
        print("Error: %s : %s" % (os.file_path, e.strerror))

    # print("Finishing point "+project_ident)

    return new_design_point

def record_dataframe(result):
    global dataset
    # dataset = pd.read_csv('../ML_train.csv', index_col=0)

    # add the evaluated design point to current dataset
    dataset = dataset.append(result, ignore_index=True)
    #dataset = dataset.append(parameters, ignore_index=True)
    dataset.to_csv('../ML_train.csv')
        
    # make sure the is_error column is boolean type
    dataset.is_error = dataset.is_error.astype('bool')


def random_train_RFML(dir, top_function, part, multiprocess = 2, nub_of_init = 20):
    global dataset

    parameter_file = '../ML_params.csv'
    directives_path = 'ML_directive'
    template_path = '../ML_template.txt'

    #run hls in temp folder
    vhls_dir = dir + "/vhls_dse_temp"
    if not(os.path.exists(vhls_dir)):
        os.makedirs(vhls_dir)    
    os.chdir(vhls_dir)

    # print("randomtranin start")
    # print(os.getcwd())
    
    nub_pro = multiprocessing.cpu_count() - multiprocess
    # print(nub_pro)

    dataset, feature_columns, label_columns = dataframe_create(parameter_file)
    # dataset.to_csv('../ML_train.csv')

    print("\n")
    print("Starting Evaluation of {0} Randomly Generated Design Points".format(nub_of_init))
    with multiprocessing.Pool(processes=nub_pro) as pool:
        for i in range(nub_of_init):
            pool.apply_async(threaded_generate_random_training_set, args = (parameter_file, directives_path, template_path, 
                                                                            top_function, part), callback = record_dataframe)
        pool.close()
        pool.join()        
    print("Finished Evaluation of {0} Randomly Generated Design Points".format(nub_of_init))

    #return to main working directory
    os.chdir("../..")

    # print("randomtranin end")
    # print(os.getcwd())

    return dataset, feature_columns

    






