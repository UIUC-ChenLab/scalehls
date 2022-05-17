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
import pickle
import multiprocessing
import random
import time

from lib import run_hls

import scalehls
import mlir.ir
from mlir.dialects import func as func_dialect


def eval_p_point(pspace, cols, opt_row_loc, part, topfunction):
    
    #scalehls dse temp directory
    project_ident = str(int(time.time()))+'_'+str(random.getrandbits(16))
    # project_ident = 'test'
    eval_dir = "samplepspace/" + project_ident
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

    print("Evaluating Point:", opt_row_loc, tile_map)
    # print("pipe_map", pipe_map)

    pspace_row_buf = copy.deepcopy(pspace.iloc[opt_row_loc].values.tolist()) 

    os.chdir(eval_dir)

    # print(cols)
    # print(pspace_row_buf)

    apply_loop_ops_small(topfunction, tile_map, pipe_map)

    results = run_hls.get_perf('../template.txt', None, topfunction, part, None, 'eval', verbose=False, timelimit=1000)
    # print('Vivado Results:', "Latency", results['latency'], 'DSP_util:', results['dsp_perc'])

    for key in results:
        pspace_row_buf.append(results[key])

    os.chdir("../..")

    # remove the directory
    try:
        shutil.rmtree(eval_dir)
    except OSError as e:
        print("Error: %s : %s" % (os.dir_path, e.strerror))

    return pspace_row_buf

def apply_loop_ops_small(topfunction, tile_map, pipe_map):

    #apply scaleHLS optimizations    
    p1 = subprocess.Popen(['mlir-clang', "../scalehls_in.c", '-function=' + topfunction, '-memref-fullrank', '-raise-scf-to-affine', '-S'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)                          
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
    with open("inter.mlir", "w") as f:
        print(mod, file = f)
    f.close()

    # get auto array partition using command line
    p1 = subprocess.Popen(['scalehls-opt', 'inter.mlir', '-scalehls-func-preprocess=top-func=' + topfunction, '-scalehls-array-partition'], 
                            stdout=subprocess.PIPE)
    with open('inter.cpp', 'wb') as fout:
        subprocess.run(['scalehls-translate', '-emit-hlscpp'], stdin=p1.stdout, stdout=fout)

    # recover lost pipeline pragmas
    loopband_loc = 0
    loop_count = 0
    newfile = open ('tiled_target.cpp', 'w')
    with open('inter.cpp', 'r') as file:        
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

def record_dataframe(result):
    global dataset

    series_pspace_row_buf = pd.Series(result, index = dataset.columns)
    dataset = dataset.append(series_pspace_row_buf, ignore_index=True)

    dataset.to_csv('samplepspace/TruePspace.csv')

def main():
    pspace = pd.read_csv('samplepspace/combspace.csv', index_col=False)
    cols = list(pspace.columns.values)
    cols = cols + ['latency', 'dsp_perc', 'ff_perc', 'lut_perc', 'bram_perc', 'is_feasible', 'is_error']
    
    global dataset
    dataset = pd.DataFrame(columns=cols)

    print("Generating True Pareto Space")
    with multiprocessing.Pool(processes=6) as pool:
        for i in range(len(pspace)):
            pool.apply_async(eval_p_point, args = (pspace, cols, i, 'xc7z045-ffg900-2', 'kernel_3mm'), callback = record_dataframe)
        pool.close()
        pool.join()        
    print("Finished Generating True Pareto Space")
if __name__ == '__main__':
    main()