import numpy as np
import pandas as pd
import os
import logging
import math
from sklearn.model_selection import KFold
from timeit import default_timer as timer
from sklearn.preprocessing import OneHotEncoder
from sklearn.tree import DecisionTreeRegressor
from sklearn.ensemble import RandomForestRegressor, RandomForestClassifier
from sklearn.model_selection import train_test_split
from scipy.special import beta
from math import factorial as fact
from multiprocessing import Process
import re
import random
import scipy
import pprint
import pickle

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
        
        # to fix the NaN problem for dim, since dim doesn't exist for loops
        try:
            knob.at['dim']=int(dim)
        except ValueError:
            knob.at['dim']=int(0)
        
        # parse the file and find the column names, the naming MUST be consistent with generate_directives.py
        if(knob['type'] == 'loop'):
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

def generate_random_training_set(dataset, parameter_file, directives_path, template_path, top_function, part, num_initial):
    # generate random training sets
    dir_gen = gen_dir.RandomDirectiveGenerator(parameter_file)
    for i in range(num_initial):
        print('Generate design points: {0}/{1}'.format(i, num_initial ))
        # generate a new design point that doesn't exist in the dataset0 
        while (True):
            # generate a new design point
            _, parameters = dir_gen.generate_directives(out_file_path=directives_path, no_partitioning=False)

            # check if the design point is valid
            if (get_row(dataset, parameters).empty): 
                break

        print(parameters)
                
        # evaluate the design point
        new_design_point = run_hls.get_perf(template_path, directives_path, top_function, part, parameters, verbose=False, timelimit=600)

        print("new design point found")
        #new_design_point = pd.DataFrame.from_dict(parameters, orient='columns')

        # add the evaluated design point to current dataset
        dataset = dataset.append(new_design_point, ignore_index=True)
        #dataset = dataset.append(parameters, ignore_index=True)
        dataset.to_csv('generated_files/ML_train.csv')
        
    # make sure the is_error column is boolean type
    dataset.is_error = dataset.is_error.astype('bool')

def random_train_RFML(top_function, part):
    parameter_file = 'generated_files/ML_params.csv'
    directives_path = 'generated_files/ML_directive.csv'
    template_path = 'generated_files/ML_template.txt'

    dataset, feature_columns, label_columns = dataframe_create(parameter_file)

    generate_random_training_set(dataset, parameter_file, directives_path, template_path, top_function, part, num_initial = 2)

    






