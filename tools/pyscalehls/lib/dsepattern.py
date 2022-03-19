import treelib
import re
import math 
import os
import subprocess
import json
import copy
import pandas as pd

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
                            newfile.write(re.sub('Loop'+ str(loopnum[0]) + ': ', '', line))
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

    sdse_target(None, dsespec, resource, root, snipfile, root)

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


def combine_two_spaces(pareto_space_list, combined_list, input1, input2):

    print("combinespace")


    space1 = None
    space2 = None

    for loop_space in pareto_space_list:
        if loop_space[0] == input1:
            space1 = loop_space[1]
        if loop_space[0] == input2:
            space2 = loop_space[1]

    print(space1)
    print(space1.columns)
    print(space2.columns)
    print(space1.columns[1])
    print(space1["l0"][0])






