import treelib
import re
import math 
import os
import subprocess
import json
import copy
import pandas as pd
import subprocess
import numpy as np
import io
import shutil

import scalehls
import mlir.ir
from mlir.dialects import builtin

def sdse_target(new_dir, dsespec, resource, tag, inputfile, inputtop):

    if new_dir != None:
        os.chdir(new_dir)

    snip_target = copy.deepcopy(dsespec) 
    snip_target['dsp'] = int(snip_target['dsp'] * resource)
    snip_target['bram'] = int(snip_target['bram'] * resource)
    with open('config.json', 'w') as f:
        json.dump(snip_target, f)

    targetspec = 'target-spec=config.json'

    p1 = subprocess.Popen(['mlir-clang', inputfile, '-function=' + inputtop, '-memref-fullrank', '-raise-scf-to-affine', '-S'],
                            stdout=subprocess.PIPE)                           
    process = subprocess.run(['scalehls-opt', '-materialize-reduction', '-dse=top-func='+ inputtop + ' output-path=./ csv-path=./ ' + targetspec, '-debug-only=scalehls'], 
                            stdin=p1.stdout, stdout=subprocess.DEVNULL)

    fout = open("snip_" + tag + "_sdse.cpp", 'wb')
    subprocess.run(['scalehls-translate', '-emit-hlscpp', "./" + inputtop + '_pareto_0.mlir'], stdout=fout)

    if new_dir != None:
        os.chdir("../../..")

def get_highest_singlechildloops(pattern, storedlist, node_UID):
    next_iteration = []
    children = pattern.children(node_UID)
    for child in children:
        if issinglechild(pattern, child.identifier):
            storedlist.append(child.tag)
        else:
            next_iteration.append(child.identifier)
    for child in next_iteration:
        get_highest_singlechildloops(pattern, storedlist, child)
    return 0

def issinglechild(pattern, node_UID):
    node_children = pattern.children(node_UID)
    if len(node_children) > 1:
        return False
    else:
        for child in node_children:
            if not(issinglechild(pattern, child.identifier)):
                return False
    return True

def loop_insertionsort(inputarray):  #insertion sort    
    for i in range(1, len(inputarray)): 
        j = i-1
        key = inputarray[i]
        key_raw = re.findall(r'Loop(\d+)', inputarray[i])
        inputarray_raw = re.findall(r'Loop(\d+)', inputarray[j])
        while j >= 0 and int(key_raw[0]) < int(inputarray_raw[0]):
                inputarray[j + 1] = inputarray[j]
                j -= 1
                if j >= 0:
                    inputarray_raw = re.findall(r'Loop(\d+)', inputarray[j])
        inputarray[j + 1] = key

def cull_function_by_pattern(dir, inputfile, dsespec, resource, pattern):
    
    root = pattern[pattern.root].tag
    
    new_dir = dir + "/snips/snip_" + root
    snipfile = "snip_" + root + ".c"
    inputfile =  "../../../" + inputfile

    if not(os.path.exists(new_dir)):
        os.makedirs(new_dir)

    os.chdir(new_dir)
    
    brace_count = 0
    brace_count_cut = math.inf

    infunction = False
    in_pattern = False
    bracefound = False
    is_brace = False
    functioncall = False
    scope = None

    newfile = open (snipfile, 'w')
    with open(inputfile, 'r') as file:        
        for line in file:
            bracefound = False
            is_brace = False
            functioncall = False

            #find function calls
            if brace_count >= 1:
                functioncall = re.findall(r'\s([A-Za-z_]+[A-Za-z_\d]*)\s?\(', line)
                if functioncall:
                    functioncall = True

            #scope finder
            if brace_count == 0: 
                raw_scope = re.findall(r'(void|int|float)\s([A-Za-z_]+[A-Za-z_\d]*)(\s)?(\()', line)
                if raw_scope:
                    scope = raw_scope[0][1]
                    infunction = True
                    if scope == root:
                        in_pattern = True
                    if re.findall('{', line): #multiline function
                        bracefound = True

            if(re.findall('{', line)):
                is_brace = True
                brace_count += 1

            if(re.findall('for', line)): #find loops // only supports one forloop per line
                if not(re.findall(r'(.)*(//)(.)*(for)(.)*', line)): # ignore for in comment
                    loopnum = re.findall('Loop(\d+):', line)
                    if pattern.get_node(int(loopnum[0])) != None:
                        if in_pattern:
                            # newfile.write(re.sub('Loop'+ str(loopnum[0]) + ': ', '', line))
                            newfile.write(line)
                    else:
                        if is_brace:
                            brace_count_cut = brace_count
                        else:
                            brace_count_cut = brace_count + 1
            elif brace_count == 0 and not(infunction):
                newfile.write(line)
            elif in_pattern and not(functioncall):
                if brace_count < brace_count_cut:
                    newfile.write(line)

            if(re.findall('}', line)):
                if brace_count == 1:
                    brace_count -= 1
                    scope = None
                    in_pattern = False
                    infunction = False           
                elif brace_count == brace_count_cut:
                    brace_count_cut = math.inf
                    brace_count -= 1
                else:
                    brace_count -= 1
    file.close()
    newfile.close()

    # sdse_target(None, dsespec, resource, root, snipfile, root)

    #load pareto space
    #mark csv files with individual loop pareto spaces
    raw_loopparetospace_list = []        
    for var in os.listdir():
        if var.endswith(".csv"):
            if re.findall(r'(loop_\d+)', var):
                raw_loopparetospace_list.append(var)
    
    #if sdse failed
    if len(raw_loopparetospace_list) == 0:
        os.chdir("../../..")
        return False, []

    #corresponding loops in graph
    toploops = []
    get_highest_singlechildloops(pattern, toploops, pattern.root)
    loop_insertionsort(toploops)
    
    # get loop csv file
    loopparetospace_list = []
    for i in range(len(raw_loopparetospace_list)):
        loop_pareto_space = pd.read_csv(raw_loopparetospace_list[i])
        loopparetospace_list.append((toploops[i], loop_pareto_space))

    os.chdir("../../..")

    return True, loopparetospace_list


def combine_two_spaces(pareto_space_list, input1, input2):

    space1 = None
    space2 = None

    if not(isinstance(input1, str)):
        space1 = input1
    if not(isinstance(input2, str)):
        space1 = input2

    for loop_space in pareto_space_list:
        if isinstance(input1, str) and loop_space[0] == input1:
            space1 = loop_space[1]
        if isinstance(input2, str) and loop_space[0] == input2:
            space2 = loop_space[1]

    space1_looplables = re.findall(r'(l\d+|b\d+l\d+)', "--".join(space1.columns))
    space2_looplables = re.findall(r'(l\d+|b\d+l\d+)', "--".join(space2.columns))

    combined_columns = []
    for loopvariable in space1_looplables:
        if re.findall(r'(b\d+l\d+)', loopvariable):
            combined_columns.append(loopvariable)
        elif re.findall(r'(l\d+)', loopvariable):
            loopbandnumb = re.findall(r'Loop(\d+)', input1)
            combined_columns.append('b' + loopbandnumb[0] + loopvariable)
    for loopvariable in space2_looplables:
        if re.findall(r'(b\d+l\d+)', loopvariable):
            combined_columns.append(loopvariable)
        elif re.findall(r'(l\d+)', loopvariable):
            loopbandnumb = re.findall(r'Loop(\d+)', input2)
            combined_columns.append('b' + loopbandnumb[0] + loopvariable)
    combined_columns.append("cycle")
    combined_columns.append("dsp")
    combined_columns.append("type")

    combinedbuffer = []
    for i in range(len(space1)):
        buffer_space1 = []
        # only combine pareto points
        if space1.iloc[i]['type'] == 'pareto':
            for s1l in space1_looplables: #extract data from space 1
                buffer_space1.append(space1.iloc[i][s1l])
            buffer_cycle = space1.iloc[i]["cycle"]
            buffer_dsp = space1.iloc[i]["dsp"]

            for j in range(len(space2)):
                row_buffer = []
                if space2.iloc[j]['type'] == 'pareto':
                    row_buffer = copy.deepcopy(buffer_space1) 
                    for s2l in space2_looplables: #extract data from space 1
                        row_buffer.append(space2.iloc[j][s2l])
                    #copy combined cycle
                    row_buffer.append(buffer_cycle + space2.iloc[j]["cycle"])
                    row_buffer.append(buffer_dsp + space2.iloc[j]["dsp"])
                    row_buffer.append("Null")
                    row_deepcopy = copy.deepcopy(row_buffer)
                    combinedbuffer.append(row_deepcopy)

    raw_combineddataspace = pd.DataFrame(combinedbuffer, columns=combined_columns)
    
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

    #remove unwanted points
    pareto_combinedspace = pareto_combinedspace.loc[pareto_combinedspace['type'] == 'pareto']

    return pareto_combinedspace

def apply_loop_ops(dir, pattern, loop_tile_array):
    
    topfunction = pattern[pattern.root].tag
    input_dir = dir + "/snips/snip_" + topfunction
    inputfile = "snip_" + topfunction + ".c"
    outputfile = input_dir + "/snip_" + topfunction + "_adse.cpp"

    ML_in_main = dir + "/ML_in.cpp"
    
    p1 = subprocess.Popen(['mlir-clang', input_dir + "/" + inputfile, '-function=' + topfunction, '-memref-fullrank', '-raise-scf-to-affine', '-S'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)                          
    p2 = subprocess.run(['scalehls-opt', '-allow-unregistered-dialect', '-materialize-reduction'], stdin=p1.stdout, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)                  
    fin = p2.stdout

    ctx = mlir.ir.Context()
    scalehls.register_dialects(ctx)
    mod = mlir.ir.Module.parse(fin, ctx)

    for func in mod.body:
        if not isinstance(func, builtin.FuncOp):
            pass
        func.__class__ = builtin.FuncOp

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
            loc = scalehls.loop_tiling(band, loop_tile_array[loopband_count], True) # simplify = True
            print(loc)
            
            loopband_count += 1
    
        # Legalize the IR to make it emittable.
        scalehls.legalize_to_hlscpp(
            func, func.sym_name.value == topfunction)

        # Optimize memory accesses through store forwarding, etc.
        # scalehls.memory_access_opt(func)
    
    buf = io.StringIO()
    scalehls.emit_hlscpp(mod, buf)
    buf.seek(0)
    # print(buf.read())

    fout = open(outputfile, 'w+')
    shutil.copyfileobj(buf, fout)
    fout.close()

    brace_count = 0
    infunction = False
    in_pattern = False
    functioncall = False
    done_copy = False
    scope = None

    newfile = open ("buffer.c", 'w')
    with open(ML_in_main, 'r') as file:        
        for line in file:
            is_brace = False
            functioncall = False

            #find function calls
            if brace_count >= 1:
                functioncall = re.findall(r'\s([A-Za-z_]+[A-Za-z_\d]*)\s?\(', line)
                if functioncall:
                    functioncall = True

            #scope finder
            if brace_count == 0: 
                raw_scope = re.findall(r'(void|int|float)\s([A-Za-z_]+[A-Za-z_\d]*)(\s)?(\()', line)
                if raw_scope:
                    scope = raw_scope[0][1]
                    infunction = True
                    if scope == topfunction:
                        in_pattern = True

            #open brackets
            if(re.findall('{', line)):
                brace_count += 1

            if in_pattern: #copy subfunction to buffer
                if not(done_copy):
                    insubfunction = False
                    subfunc_brace_count = 0
                    with open(outputfile, 'r') as adse:
                        for subline in adse:
                            #detect function
                            if subfunc_brace_count == 0:
                                if re.findall(r'(void|int|float)\s([A-Za-z_]+[A-Za-z_\d]*)(\s)?(\()', subline):
                                    insubfunction = True
                            #write subfuntion to buffer
                            if insubfunction:
                                if re.findall(r'#pragma', subline): #remove pragma
                                    None
                                else:
                                    newfile.write(subline)
                            # open brackets
                            if(re.findall('{', subline)):
                                subfunc_brace_count += 1
                            # close brackets
                            if(re.findall('}', subline)):
                                if subfunc_brace_count == 1:
                                    subfunc_brace_count -= 1
                                    insubfunction = False           
                                else:
                                    subfunc_brace_count -= 1
                    adse.close()
                    done_copy = True
            elif brace_count == 0 and not(infunction):
                newfile.write(line)
            else:
                newfile.write(line)

            #close brackets
            if(re.findall('}', line)):
                if brace_count == 1:
                    brace_count -= 1
                    scope = None
                    in_pattern = False
                    infunction = False           
                else:
                    brace_count -= 1
    file.close()
    newfile.close()


