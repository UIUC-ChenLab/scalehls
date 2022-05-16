import os
import shutil
import io
import re
import json
import copy
import subprocess
import numpy as np
import pandas as pd
import math

from lib import run_hls

import scalehls
import mlir.ir
from mlir.dialects import func as func_dialect

from lib import large_AutoScaleDSE as lASDSE

def universal_low_insertionsort(inputarray, sortkeystring):  #insertion sort    
    for i in range(1, len(inputarray)): 
        j = i-1
        key = inputarray[i]
        key_raw = re.findall(sortkeystring, inputarray[i])
        inputarray_raw = re.findall(sortkeystring, inputarray[j])
        while j >= 0 and int(key_raw[0]) < int(inputarray_raw[0]):
                inputarray[j + 1] = inputarray[j]
                j -= 1
                if j >= 0:
                    inputarray_raw = re.findall(sortkeystring, inputarray[j])
        inputarray[j + 1] = key

def run_scalehls_dse(inputfile, inputtop):

    targetspec = 'target-spec=config.json'

    p1 = subprocess.Popen(['mlir-clang', inputfile, '-function=' + inputtop, '-memref-fullrank', '-raise-scf-to-affine', '-S'],
                            stdout=subprocess.PIPE)                           
    p2 = subprocess.Popen(['scalehls-opt', '-scalehls-dse-pipeline=top-func='+ inputtop + " " + targetspec, '-debug-only=scalehls'], 
                            stdin=p1.stdout, stdout=subprocess.PIPE)

    with open('ScaleHLS_DSE_out.cpp', 'wb') as fout:
        subprocess.run(['scalehls-translate', '-emit-hlscpp'], stdin=p2.stdout, stdout=fout)

def combine_two_spaces_coprime(input1, input2, c1, c2):

    space1 = input1
    space2 = input2

    space1_looplables = re.findall(r'(l\d+|ii|b\d+l\d+|b\d+ii)', "--".join(space1.columns))
    space2_looplables = re.findall(r'(l\d+|ii|b\d+l\d+|b\d+ii)', "--".join(space2.columns))
    # print(space1_looplables)
    # print(space2_looplables)

    print("Merging :", len(space1), len(space2))

    combined_columns = []
    for loopvariable in space1_looplables:
        if re.findall(r'(b\d+l\d+)', loopvariable):
            combined_columns.append(loopvariable)
        elif re.findall(r'(b\d+ii)', loopvariable):
            combined_columns.append(loopvariable)
        elif re.findall(r'(l\d+)', loopvariable):
            combined_columns.append('b' + str(c1) + loopvariable)
        elif re.findall(r'(ii)', loopvariable):
            combined_columns.append('b' + str(c1) + loopvariable)
    for loopvariable in space2_looplables:
        if re.findall(r'(b\d+l\d+)', loopvariable):
            combined_columns.append(loopvariable)
        elif re.findall(r'(b\d+ii)', loopvariable):
            combined_columns.append(loopvariable)
        elif re.findall(r'(l\d+)', loopvariable):
            combined_columns.append('b' + str(c2) + loopvariable)
        elif re.findall(r'(ii)', loopvariable):
            combined_columns.append('b' + str(c2) + loopvariable)
    combined_columns.append("cycle")
    combined_columns.append("dsp")
    combined_columns.append("type")

    print(combined_columns)

    combinedbuffer = []
    for i in range(len(space1)):
    # for i in range(1):
        buffer_space1 = []
        # only combine pareto points
        if space1.iloc[i]['type'] == 'pareto':

            # get multiple of loop tiling stratergy
            productoftiles_space1 = 1
            for lcols in range(len(space1.iloc[i]) - 3):
                if re.findall('l', space1.columns[lcols]):
                    productoftiles_space1 *= int(space1.iloc[i][lcols])

            #extract data from space 1
            for s1l in space1_looplables:                 
                buffer_space1.append(space1.iloc[i][s1l])
            buffer_cycle = space1.iloc[i]["cycle"]
            buffer_dsp = space1.iloc[i]["dsp"]

            for j in range(len(space2)):
                row_buffer = []
                if space2.iloc[j]['type'] == 'pareto':
                    # get multiple of loop tiling stratergy
                    productoftiles_space2 = 1
                    for lcols in range(len(space2.iloc[j]) - 3): #-3 for cycle/dsp/pare
                        if re.findall('l', space2.columns[lcols]):
                            productoftiles_space2 *= int(space2.iloc[j][lcols])

                    coprime_custom = False
                    if math.gcd(60,48) in [1, 2]:
                        coprime_custom = True
                    
                    if coprime_custom == False:
                        row_buffer = copy.deepcopy(buffer_space1) 
                        for s2l in space2_looplables: #extract data from space 1
                            row_buffer.append(space2.iloc[j][s2l])
                        #copy combined cycle
                        row_buffer.append(buffer_cycle + space2.iloc[j]["cycle"])
                        row_buffer.append(buffer_dsp + space2.iloc[j]["dsp"])
                        row_buffer.append("Null")
                        row_deepcopy = copy.deepcopy(row_buffer)
                        combinedbuffer.append(row_deepcopy)
                elif space2.iloc[j]['type'] == 'non-pareto':
                    break
        elif space1.iloc[i]['type'] == 'non-pareto':
            break

    raw_combineddataspace = pd.DataFrame(combinedbuffer, columns=combined_columns)
    merge_ops = len(raw_combineddataspace)
    # print(raw_combineddataspace)
    
    #mark pareto points
    sorted_dataset = raw_combineddataspace.sort_values(by=['cycle','dsp'])
    sorted_dataset = sorted_dataset.reset_index(drop=True) #reset index after sorting
    cost = float('inf') # initialize with cost=1, which is the maximum possible value
    cycle = 0 # initialize latency to 0 for safety
    for i in range(len(sorted_dataset)):
        # check if the cost is in a descending order
        if (sorted_dataset.iloc[i]['dsp'] >= cost):
            sorted_dataset.at[i,'type'] = "unnecessary"
        else:
            cost = sorted_dataset.iloc[i]['dsp']
            sorted_dataset.at[i,'type'] = "pareto"    
    # bring pareto points to top of list
    pareto_combinedspace = sorted_dataset.sort_values(by=['type', 'cycle'])
    pareto_combinedspace = pareto_combinedspace.reset_index(drop=True)

    # remove unwanted points
    pareto_combinedspace = pareto_combinedspace.loc[pareto_combinedspace['type'] == 'pareto']

    return pareto_combinedspace, merge_ops

def find_opt_target(pspace, dsp_target):

    for i in range(len(pspace)):
        if pspace.iloc[i]["dsp"] <= dsp_target:
            return i, pspace.iloc[i]["dsp"]    
    
def eval_p_point(pspace, opt_row_loc, part, topfunction, genfile = False):
    
    #scalehls dse temp directory
    eval_dir = "scalehls_dse_eval"
    if not(os.path.exists(eval_dir)):
        os.makedirs(eval_dir)

    # get tiling stratergy
    tile_map = []
    pipe_map = []
    loop_band_tile = []
    for pcol in range(len(pspace.iloc[opt_row_loc]) - 3):
        if re.findall(r'l(\d+)', pspace.columns[pcol]):
            loop_band_tile.append(pspace.iloc[opt_row_loc][pcol])
        elif re.findall('ii', pspace.columns[pcol]):
            pipe_map.append(pspace.iloc[opt_row_loc][pcol])
            # store tiling stratergy
            tile_map.append(loop_band_tile)
            loop_band_tile = []

    print("Evaluating Tile_strat", tile_map)
    # print("pipe_map", pipe_map)

    apply_loop_ops_small(eval_dir, topfunction, tile_map, pipe_map)

    if genfile:
        return
    
    # generate template
    newfile = open (eval_dir + '/template.txt', 'w')
    with open('../ML_template.txt', 'r') as file:        
        for line in file:
            if re.findall('add_files', line):
                newfile.write('add_files tiled_target.cpp\n')
            elif re.findall('source', line): # no additional directives
                None 
            else: 
                newfile.write(line)
    newfile.close()

    os.chdir(eval_dir)

    results = run_hls.get_perf('template.txt', None, topfunction, part, None, 'eval', verbose=False, timelimit=1000)
    print('Vivado Results:', "Latency", results['latency'], 'DSP_util:', results['dsp_perc'])

    os.chdir("../")

    return results

def apply_loop_ops_small(eval_dir, topfunction, tile_map, pipe_map):

    #apply scaleHLS optimizations    
    p1 = subprocess.Popen(['mlir-clang', "scalehls_in.c", '-function=' + topfunction, '-memref-fullrank', '-raise-scf-to-affine', '-S'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)                          
    p2 = subprocess.run(['scalehls-opt', '-allow-unregistered-dialect'], stdin=p1.stdout, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)                  
    fin = p2.stdout

    ctx = mlir.ir.Context()
    scalehls.register_dialects(ctx)
    mod = mlir.ir.Module.parse(fin, ctx)

    loop_count = 0
    for func in mod.body:
        if not isinstance(func, func_dialect.FuncOp):
            pass
        func.__class__ = func_dialect.FuncOp

        # index so that corrent loop tiling can be applied
        loopband_count = 0
        # Traverse all suitable loop bands in the function.
        bands = scalehls.LoopBandList(func)
        for band in bands:
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
            
            np_array = np.array(tile_map[loopband_count])
            loc = scalehls.loop_tiling(band, np_array)
            
            scalehls.loop_pipelining(band, loc+1, pipe_map[loopband_count])        
            
            loopband_count += 1

        # Apply memory optimizations.
        scalehls.memory_opts(func)
    
    # Write mlir
    with open(eval_dir + "/inter.mlir", "w") as f:
        print(mod, file = f)
    f.close()

    # get auto array partition using command line
    p1 = subprocess.Popen(['scalehls-opt', eval_dir + '/inter.mlir', '-scalehls-func-preprocess=top-func=' + topfunction, '-scalehls-array-partition'], 
                            stdout=subprocess.PIPE)
    with open(eval_dir + '/inter.cpp', 'wb') as fout:
        subprocess.run(['scalehls-translate', '-emit-hlscpp'], stdin=p1.stdout, stdout=fout)

    # recover lost pipeline pragmas
    loopband_loc = 0
    loop_count = 0
    newfile = open (eval_dir + '/tiled_target.cpp', 'w')
    with open(eval_dir + '/inter.cpp', 'r') as file:        
        for line in file:
            newfile.write(line)
            
            #count number of loops
            if re.findall('//', line): # remove comments
                line_buffer = re.findall('(.*)//', line)
                if re.findall('for', line_buffer[0]):
                    loop_count += 1

            # if at lowest level of the nest add pipeline
            if loopband_loc < len(tile_map) and loop_count == len(tile_map[loopband_loc]):
                newfile.write('#pragma HLS pipeline II=' + str(pipe_map[loopband_loc]) + '\n')
                loopband_loc += 1
                loop_count = 0
    newfile.close()

def scalehls_dse_top(dir, source_file, dsespec, part, inputtop):
    print("Starting Small_AScaleDSE DSE")

    #scalehls dse temp directory
    sdse_dir = dir + "/scalehls_dse_temp/"
    if not(os.path.exists(sdse_dir)):
        os.makedirs(sdse_dir)

    inputfile = "scalehls_in.c"
    sdse_input_file_loc = sdse_dir + inputfile
    if not(os.path.exists(sdse_input_file_loc)):        
        shutil.copy(source_file, sdse_input_file_loc)

    os.chdir(sdse_dir)

    snip_target = copy.deepcopy(dsespec)
    with open('config.json', 'w') as f:
        json.dump(snip_target, f)

########################################################################################################
    # run_scalehls_dse(inputfile, inputtop)
########################################################################################################    

    # mark csv files with individual loop pareto spaces
    raw_loopparetospace_list = []        
    for var in os.listdir():
        if var.endswith(".csv"):
            if re.findall(r'(loop_\d+)', var):
                raw_loopparetospace_list.append(var)
    #sort list
    lASDSE.universal_low_insertionsort(raw_loopparetospace_list, r'loop_(\d+)')
    
    print("loop bands", raw_loopparetospace_list)

    loop_pareto_space = []
    for i in range(len(raw_loopparetospace_list)):
        buffer = pd.read_csv(raw_loopparetospace_list[i])
        loop_pareto_space.append(buffer)

    # print(loop_pareto_space)

    #combine individual pareto space
    merge_count = 0
    if len(loop_pareto_space) > 1:
        buffer, merge_count = combine_two_spaces_coprime(loop_pareto_space[0], loop_pareto_space[1], 0, 1)
        for i in range(2, len(loop_pareto_space)):
            buffer, merge_count_buf = combine_two_spaces_coprime(buffer, loop_pareto_space[i], 0, i)
            merge_count += merge_count_buf
        buffer.to_csv('combspace.csv')
        print("Numb of Merge Opts", merge_count)

    pspace = buffer
    # pspace = pd.read_csv('combspace.csv', index_col=0)    

    # find true tiling stratergy that is true
    opt_row_loc = -1
    oscillating = False

    pspace_dsp_history = []
    valid_result_history = []
    
    dsp_target = dsespec['dsp']   
    oscillating_threashold = dsespec['dsp'] * 0.1
    while True:
        opt_row_loc_buf, pspace_dsp = find_opt_target(pspace, dsp_target)
        print("Target dsp:", dsp_target, "Found Pspace DSP:", pspace_dsp)
        
        # break if new tile strat is oscillating
        oscillating = False
        for tileloc in pspace_dsp_history:
            if (tileloc - oscillating_threashold < pspace_dsp) and (pspace_dsp < tileloc + oscillating_threashold):
                oscillating = True
        if oscillating:
            print('Vivado Point: Exit Oscillating')
            break

        pspace_dsp_history.append(pspace_dsp)
        opt_row_loc = opt_row_loc_buf

        result = eval_p_point(pspace, opt_row_loc, part, inputtop)

        # attempt at getting a better tiling stratergy
        if result['is_feasible'] == True:
            valid_result_history.append((opt_row_loc, pspace_dsp, result))
            
            if result['dsp_perc'] >= 0.9:
                print('Vivado Point: Exit 0.9>')
                break
            else:
                dsp_target = pspace_dsp * (0.95 / result['dsp_perc'])
        # if not feasible revert back to old
        elif result['is_feasible'] == False:
            # if desing is not vaild revert
            if result['is_error'] == True:
                print('Vivado Point: Exit is_error')
                break
            # new target is the arithmatic mean
            dsp_target = (pspace_dsp + valid_result_history[-1][1]) / 2

    # get best
    min_laten = float('inf')
    final_tile_opts = -1
    for i in range(len(valid_result_history)):
        lat = valid_result_history[i][2]['latency']
        if lat < min_laten:
            final_tile_opts = valid_result_history[i][0]

    eval_p_point(pspace, final_tile_opts, part, inputtop, genfile = True)
    shutil.copyfile("scalehls_dse_eval/tiled_target.cpp", '../Small_AScaleDSE_out.cpp')
    
    os.chdir("../..")
    print("Finished Small_AScaleDSE DSE")