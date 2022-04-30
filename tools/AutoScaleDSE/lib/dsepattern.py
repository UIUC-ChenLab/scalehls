from distutils.archive_util import make_archive
from gettext import find
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
import time

import scalehls
import mlir.ir
from mlir.dialects import func as func_dialect

c_keywords = ["auto", "break", "case", "char", "const", "continue", "default", "do", "double", "else", "enum", "extern", "float", "for", "goto", "if", "inline", "int", "long", "register", "restrict", "return", "short", "signed", "sizeof", "static", "struct", "switch", "typedef", "union", "unsigned", "void", "volatile", "while"]
c_vars = ["char", "double", "float", "int", "short"]

class ROI(object):
    def __init__(self, input):
        self.group = input

def alpha_to_int(input):
    intfromalpha = 0
    for abc in input:
        intfromalpha += (ord(abc) - 96)

    return intfromalpha

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
    p2 = subprocess.Popen(['scalehls-opt', '-scalehls-dse-pipeline=top-func='+ inputtop + " " + targetspec, '-debug-only=scalehls'], 
                            stdin=p1.stdout, stdout=subprocess.PIPE)

    with open("snip_" + tag + "_sdse.cpp", 'wb') as fout:
        subprocess.run(['scalehls-translate', '-emit-hlscpp'], stdin=p2.stdout, stdout=fout)    

    if new_dir != None:
        os.chdir("../../..")

def mark_subsequent_node(mastertree, startingnode, roi_num):

    children = mastertree.children(startingnode.identifier)
    if children:
        for child in children:
            child.data.group = str(roi_num)
            mark_subsequent_node(mastertree, child, roi_num)

def get_UnmarkedNodeCount(mastertree, initial_pspace, target_node):

    siblings_list = mastertree.children(target_node.identifier)

    top_loop_count = 0
    for sib in siblings_list:
        if (re.findall('Loop', sib.tag)) and (sib.data.group == "None") and (sib.tag in initial_pspace):
            top_loop_count += 1
        else:
            top_loop_count += get_UnmarkedNodeCount(mastertree, initial_pspace, sib)

    return top_loop_count    

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

def apply_p_point(tar_dir, tree_list, var_forlist, removed_function_calls, pspace, target):
    
    # copy ref file
    shutil.copy2(tar_dir + "/ref_design.c", tar_dir + "/ML_in.cpp")

    print("")

    # find loop bands that are to be optimized
    pspace_columns = pspace.columns
    Loop_bands2opt = []
    for col in pspace_columns:
        loopband = re.findall(r'b(\d+)', col)
        if (loopband != []) and not(("Loop"+loopband[0]) in Loop_bands2opt):
            Loop_bands2opt.append("Loop"+loopband[0])
    universal_low_insertionsort(Loop_bands2opt, r'Loop(\d+)')
    # print(Loop_bands2opt)

    # functions that are to be optimized
    opt_func = []
    for loop in Loop_bands2opt:
        for i in range(len(tree_list) - 1):
            DFS_list = [tree_list[i][node].tag for node in tree_list[i].expand_tree(mode=treelib.Tree.DEPTH, sorting=False)]
            if loop in DFS_list and not(tree_list[i][tree_list[i].root].tag in opt_func):
                opt_func.append(tree_list[i][tree_list[i].root].tag)
    # print(opt_func)

    # get tiling stratergy and apply
    for i in range(len(tree_list) - 1):
        if tree_list[i][tree_list[i].root].tag in opt_func:
            #get tile map of function
            tile_map = []
            children = tree_list[i].children(tree_list[i].root)
            for child in children:
                # find number of loops in loop band
                child_DFS_list = [tree_list[i][node] for node in tree_list[i].expand_tree(child.identifier, mode=treelib.Tree.DEPTH, sorting=False)]
                loop_band = []
                for j in range(len(child_DFS_list)):
                    colname = 'b' + str(child.identifier) + 'l' + str(j) #pandas index by name
                    loop_band.append(pspace.iloc[target][colname])
                tile_map.append(loop_band)
            print("Applying Loop Optimizations to:", tree_list[i].root)
            print("Using the following tiling stratergy:", tile_map)

            #apply tiling stratergy to functions
            apply_loop_ops(tar_dir, tree_list[i], var_forlist, removed_function_calls, tile_map)

def cull_function_by_pattern(dir, inputfile, func_list, removed_function_calls, dsespec, resource, pattern):
    
    root = pattern[pattern.root].tag
    
    new_dir = dir + "/snips/snip_" + root
    snipfile_raw = "snip_" + root
    inputfile =  "../../../" + inputfile

    if not(os.path.exists(new_dir)):
        os.makedirs(new_dir)

    os.chdir(new_dir)
    
    brace_count = 0
    brace_count_cut = math.inf

    functioncall_list = []

    infunction = False
    in_pattern = False
    is_brace = False
    functioncall = False
    scope = None

    newfile = open (snipfile_raw + ".c", 'w')
    with open(inputfile, 'r') as file:
        for line in file:
            is_brace = False

            #find function calls
            if brace_count >= 1 and in_pattern:
                line_function_call = re.findall(r'\s?([A-Za-z_]+[A-Za-z_\d]*)\s?\(', line)
                if line_function_call:
                    for keyword in line_function_call:
                        if not(keyword.strip() in c_keywords): #ignore c keywords
                            if keyword in func_list:
                                functioncall = True
                                functioncall_list.append(keyword)

            #scope finder
            if brace_count == 0: 
                raw_scope = re.findall(r'(void|char|double|float|int|short)\s([A-Za-z_]+[A-Za-z_\d]*)(\s)?(\()', line)
                if raw_scope:
                    scope = raw_scope[0][1]
                    infunction = True
                    if scope == root:
                        in_pattern = True
                        

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
            elif in_pattern:
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

    snipfile_target = snipfile_raw + ".c"

    # edit file if there exists private subfunction calls
    # Idea: uses a placeholder value to store function call location
    if functioncall:
        # Change sdse input name
        snipfile_target = snipfile_raw + "_funrem" + ".c"
        
        end_of_decl = False
        var_list = []
        numb_of_funcalls = len(functioncall_list)
        func_call_written = 0
        brace_count = 0
        variable_count = 0
        
        newfile = open (snipfile_target, 'w')
        with open(snipfile_raw + ".c", 'r') as file:
            for line in file:
                # infunction = False
                end_of_decl = False
                functioncall = False

                #keep track of variable order
                if brace_count == 0:
                    variables = re.findall(r'(char|double|float|int|short)\s\*?([A-Za-z_]+[A-Za-z_\d]*)\s?(,|;|\)|' ')+', line)
                    if variables:
                        for mytuple in variables:
                            buf_list = list(mytuple)
                            buf_list.remove('')
                            for item in buf_list:
                                if not(item in c_keywords):
                                    var_list.append((item, variable_count))
                                    variable_count += 1

                #find function calls
                if brace_count >= 1:
                    line_function_call = re.findall(r'\s?([A-Za-z_]+[A-Za-z_\d]*\s?\(.*\))', line)
                    if line_function_call:
                        for raw_out in line_function_call:
                            keyword = re.findall(r'([A-Za-z_]+[A-Za-z_\d]*)\s?\(', raw_out)
                            keyword = keyword[0].strip()
                            if not(keyword in c_keywords): #ignore c keywords
                                if keyword in func_list:
                                    if re.search(r'=\s?' + keyword, line): #error catch
                                        print("Error: Function Calls has return value")
                                    else:
                                        functioncall = True
                                        newfile.write("pla_hold[" + str(func_call_written) +"] = " + "42.42424242" + ";\n")
                                        func_call_written += 1

                                        transformed_call = re.findall(r'(\(.*\))', raw_out)
                                        transformed_call = transformed_call[0]
                                        variable_names = re.findall(r'([A-Za-z_]+[A-Za-z_\d]*)', raw_out)
                                        variable_names.remove(keyword)
                                        for fun_var in variable_names: #get new name
                                            for var in var_list:
                                                if fun_var == var[0]:
                                                    transformed_call = re.sub(var[0], "v" + str(var[1]), transformed_call)

                                        removed_function_calls.append((root , keyword + transformed_call))

                if(re.findall('{', line)):
                    if brace_count == 0:
                        end_of_decl = True
                        brace_count += 1
                        newfile.write(re.sub(r'\)\s?{', ',', line))
                        # place holder to track function call locations
                        newfile.write("double " + "pla_hold[" + str(numb_of_funcalls) + "] ) {\n")
                    else:
                        brace_count += 1
                
                if(re.findall('}', line)):
                    brace_count -= 1


                if not(end_of_decl or functioncall):
                    newfile.write(line)
    file.close()
    newfile.close()

########################################################################################################
    # sdse_target(None, dsespec, resource, root, snipfile_target, root)
#########################################################################################################    

    #load pareto space
    #mark csv files with individual loop pareto spaces
    raw_loopparetospace_list = []        
    for var in os.listdir():
        if var.endswith(".csv"):
            if re.findall(r'(loop_\d+)', var):
                raw_loopparetospace_list.append(var)
    #sort list
    universal_low_insertionsort(raw_loopparetospace_list, r'loop_(\d+)')
    
    #if sdse failed
    if len(raw_loopparetospace_list) == 0:
        os.chdir("../../..")
        return False, [], removed_function_calls, []

    #corresponding loops in graph
    toploops = []
    get_highest_singlechildloops(pattern, toploops, pattern.root)
    universal_low_insertionsort(toploops, r'Loop(\d+)')
    
    # get loop csv file
    loopparetospace_list = []
    for i in range(len(raw_loopparetospace_list)):
        loop_pareto_space = pd.read_csv(raw_loopparetospace_list[i])
        loopparetospace_list.append((toploops[i], loop_pareto_space))
        # print((toploops[i], raw_loopparetospace_list[i]))
   
    sdse_var_part = get_sdes_array_partition(root, removed_function_calls)

    os.chdir("../../..")

    return True, loopparetospace_list, removed_function_calls, sdse_var_part

def get_sdes_array_partition(root, removed_function_calls):
    in_pattern = False
    brace_count = 0

    function_passed_val = []
    function_declared_val = []
    # get local array partition scheme
    with open("snip_" + root + "_sdse.cpp", 'r') as file:
        for line in file:

            #scope finder
            if brace_count == 0: 
                raw_scope = re.findall(r'(void|char|double|float|int|short)\s([A-Za-z_]+[A-Za-z_\d]*)(\s)?(\()', line)
                if raw_scope:
                    scope = raw_scope[0][1]
                    if scope == root:
                        in_pattern = True                        

            if(re.findall('{', line)):
                brace_count += 1

            if(re.findall('}', line)):
                if brace_count == 1:
                    in_pattern = False
                    brace_count -= 1
                else:
                    brace_count -= 1

            # get sdse array partition scheme
            if re.findall("#pragma HLS array_partition", line):
                part_var = re.findall(r'variable\s?=\s?([A-Za-z_]+[A-Za-z_\d]*)\s', line)
                part_scheme = re.findall(r'(cyclic|block|complete)', line)
                part_factor = re.findall(r'factor\s?=\s?(\d+)\s', line)
                part_dim = re.findall(r'dim\s?=\s?(\d+)\s?', line)
                
                # store scheme in list
                for item in function_passed_val:
                    if part_var[0] == item[1]:
                        item.append(part_scheme[0])
                        item.append(part_factor[0])
                        item.append(part_dim[0])
                for item in function_declared_val:
                    if part_var[0] == item[1]:
                        item.append(part_scheme[0])
                        item.append(part_factor[0])
                        item.append(part_dim[0])

            # if in_pattern and brace_count > 0:
            if in_pattern and brace_count == 0:
                arr2part = re.findall(r'(int|float|double)\s([A-Za-z_]+[A-Za-z_\d]*)\s?(\[.+\])?\s?(\[.+\])?\s?(\[.+\])?\s?(\[.+\])?\s?(\[.+\])?\s?(\[.+\])+(,|;|\)|' ')', line)
                if(arr2part):
                    for item in arr2part:
                        function_passed_val.append([scope, item[1]])                            
            elif in_pattern and brace_count > 0:
                arr2part = re.findall(r'(int|float|double)\s([A-Za-z_]+[A-Za-z_\d]*)\s?(\[.+\])?\s?(\[.+\])?\s?(\[.+\])?\s?(\[.+\])?\s?(\[.+\])?\s?(\[.+\])+(,|;|\)|' ')', line)
                if(arr2part):
                    for item in arr2part:
                        current_array = "".join(item[1:-1])
                        array_sizeofdim = re.findall(r'\[(.+?)\]', current_array)
                        array_dim = len(array_sizeofdim)
                        # do not capture scalehls auto gen arrays which are a dummy array of dim1 size1
                        if not(array_dim < 2 and int(array_sizeofdim[0]) < 2):
                            function_declared_val.append([scope, item[1]])
    file.close()

    # remove dummy variable
    sub_function_call = False
    for item in removed_function_calls:
        if item[0] == root:
            sub_function_call = True
    if sub_function_call:
        function_passed_val.pop()

    # 1st dim stores passed values second dim stores non passed values
    sdse_var_part = [root, function_passed_val, function_declared_val]

    return sdse_var_part

def combine_two_spaces(pareto_space_list, input1, input2):

    space1 = None
    space2 = None

    if not(isinstance(input1, str)):
        space1 = input1
    if not(isinstance(input2, str)):
        space2 = input2

    for loop_space in pareto_space_list:
        if isinstance(input1, str) and loop_space[0] == input1:
            space1 = loop_space[1]
        if isinstance(input2, str) and loop_space[0] == input2:
            space2 = loop_space[1]

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
            loopbandnumb = re.findall(r'Loop(\d+)', input1)
            combined_columns.append('b' + loopbandnumb[0] + loopvariable)
        elif re.findall(r'(ii)', loopvariable):
            loopbandnumb = re.findall(r'Loop(\d+)', input1)
            combined_columns.append('b' + loopbandnumb[0] + loopvariable)
    for loopvariable in space2_looplables:
        if re.findall(r'(b\d+l\d+)', loopvariable):
            combined_columns.append(loopvariable)
        elif re.findall(r'(b\d+ii)', loopvariable):
            combined_columns.append(loopvariable)
        elif re.findall(r'(l\d+)', loopvariable):
            loopbandnumb = re.findall(r'Loop(\d+)', input2)
            combined_columns.append('b' + loopbandnumb[0] + loopvariable)
        elif re.findall(r'(ii)', loopvariable):
            loopbandnumb = re.findall(r'Loop(\d+)', input2)
            combined_columns.append('b' + loopbandnumb[0] + loopvariable)
    combined_columns.append("cycle")
    combined_columns.append("dsp")
    combined_columns.append("type")

    # print(combined_columns)

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

    #remove unwanted points
    pareto_combinedspace = pareto_combinedspace.loc[pareto_combinedspace['type'] == 'pareto']

    return pareto_combinedspace, merge_ops

def expand_by_factor(mastertree, initial_pspace, current_node, factor):

    roi_tag = re.findall(r'ROI(\d+)_', current_node.data.group)
    roi_tag = roi_tag[0]
    roi_count = re.findall(r'_LC(\d+)', current_node.data.group) # get number of counts to 
    roi_count = int(roi_count[0])

    if roi_count == 0:
        progress = mark_next_roi(mastertree, initial_pspace, current_node, roi_tag, None)
        if progress == "Done":
            return "Done", factor        
        factor -=1
        return "complete exit", factor

    # decrement counter
    roi_count -= 1
    buffer = re.findall(r'(.*)_LC', current_node.data.group)
    current_node.data.group = buffer[0] + '_LC' + str(roi_count)   # Type(Name)_ExpansionFactor-UnmarkedNodeCount
    factor -=1

    if factor > 0:
        progress, factor = expand_by_factor(mastertree, initial_pspace, current_node, factor)
        if progress == "Done":
            return "Done", factor  

    if factor == 0:
        return "count exit", factor

    return "Loop Function Boundary", factor

def mark_next_roi(mastertree, initial_pspace, current_node, roi_tag, recursive):

    found_new_roi = False

    #if recursive pass data
    if recursive == None:
        roi_ef = re.findall(r'_EF(\d+)_', current_node.data.group)
        roi_ef = roi_ef[0]
    else:
        roi_ef = recursive

    is_root = False
    parent = mastertree.parent(current_node.identifier)
    if parent.identifier == mastertree.root:
        is_root = True

    siblings_list = mastertree.children(parent.identifier)

    # Loop siblings
    loop_siblings = []
    for sib in siblings_list:
        if re.findall(r'Loop', sib.tag):
            loop_siblings.append(sib)

    # function siblings
    func_siblings = []
    for sib in siblings_list:
        if re.findall(r'([a-z]*)-.*', sib.tag):
            func_siblings.append(sib)

    # try expanding loop siblings
    for lsib in loop_siblings:
        if lsib.data.group == "None" and not(found_new_roi):
            if lsib.tag in initial_pspace and recursive == None:
                top_loop_count = get_UnmarkedNodeCount(mastertree, initial_pspace, lsib)
                lsib.data.group = 'ROI' + roi_tag + '_EF' + roi_ef + '_LC' + str(top_loop_count)   # Type(Name)_ExpansionFactor-UnmarkedNodeCount
                current_node.data.group = str(roi_tag)
                mark_subsequent_node(mastertree, current_node, roi_tag)
                found_new_roi = True
            elif recursive == None:
                # if not in initial pspace ignore
                lsib.data.group = roi_tag
                mark_subsequent_node(mastertree, lsib, roi_tag)
            else:
                lsib.data.group = roi_tag

    # exit if found valid node
    if found_new_roi:
        return "marked loop"

    # get closest node that is not a loop
    true_sibs = False
    for sib in func_siblings: # test if sibling 
        if sib.identifier == current_node.identifier:
            true_sibs = True

    if true_sibs:
        # The following code aims to find the node that is closest 
        # from the current node and furthest from other maked nodes

        # get nodes that is marked by current roi_tag and remove other marked nodes
        free_siblings = []
        marked_sibs = []
        current_roi_fam = []        
        # remove current node
        current_roi_fam.append(current_node)        
        func_siblings.remove(current_node)
        for sib in func_siblings:
            if sib.data.group == roi_tag:
                current_roi_fam.append(sib)
            elif sib.data.group != "None":
                marked_sibs.append(sib)
            else:
                free_siblings.append(sib)

        # print("func_sibs", free_siblings)
        # print("curr_sibs", current_roi_fam)
        # print("marked_sibs", marked_sibs)

        candidate_sibs = []
        for roi_sib in current_roi_fam:
            for fun_sib in free_siblings:
                roi_sib_ortag = re.findall(r'([a-z]+)-.*', roi_sib.tag)
                fun_sib_ortag = re.findall(r'([a-z]+)-.*', fun_sib.tag)
                distance = abs(alpha_to_int(roi_sib_ortag[0]) - alpha_to_int(fun_sib_ortag[0]))
                if distance == 1:
                    candidate_sibs.append(fun_sib)

        final_candidate = None

        # sort candidate nodes and choose final candidate if 2 candidates
        if len(candidate_sibs) > 1:        
            candidate_sibs0 = re.findall(r'([a-z]+)-.*', candidate_sibs[0].tag)
            candidate_sibs1 = re.findall(r'([a-z]+)-.*', candidate_sibs[1].tag)
            candidate_sibs0 = alpha_to_int(candidate_sibs0[0])
            candidate_sibs1 = alpha_to_int(candidate_sibs1[0])
            if candidate_sibs0 > candidate_sibs1:
                buf = candidate_sibs[0]
                candidate_sibs[0] = candidate_sibs[1]
                candidate_sibs[1] = buf
            
            # upper candidate
            upper_can = re.findall(r'([a-z]+)-.*', candidate_sibs[0].tag)
            upper_can = alpha_to_int(upper_can[0])
            upper_min_distance = float("inf")
            for sib in marked_sibs:
                mrk_sib_ortag = re.findall(r'([a-z]+)-.*', sib.tag)
                distance = upper_can - alpha_to_int(mrk_sib_ortag[0])
                if distance > 0 and distance < upper_min_distance:
                    upper_min_distance = distance

            # lower candidate
            lower_can = re.findall(r'([a-z]+)-.*', candidate_sibs[1].tag)
            lower_can = alpha_to_int(lower_can[0])
            lower_min_distance = float("inf")
            for sib in marked_sibs:
                mrk_sib_ortag = re.findall(r'([a-z]+)-.*', sib.tag)
                distance = alpha_to_int(mrk_sib_ortag[0]) - lower_can
                if distance > 0 and distance < lower_min_distance:
                    lower_min_distance = distance

            # print("candidate_sibs", candidate_sibs)
            # print(upper_min_distance, lower_min_distance)

            if upper_min_distance > lower_min_distance:
                final_candidate = candidate_sibs[0]
            else:
                final_candidate = candidate_sibs[1]
        elif len(candidate_sibs) == 1:
            final_candidate = candidate_sibs[0]

        # print("final candidate", final_candidate)

        if final_candidate:
            top_loop_count = get_UnmarkedNodeCount(mastertree, initial_pspace, final_candidate)
            final_candidate.data.group = 'ROI' + roi_tag + '_EF' + roi_ef + '_LC' + str(top_loop_count)   # Type(Name)_ExpansionFactor-UnmarkedNodeCount
            current_node.data.group = str(roi_tag)
            mark_subsequent_node(mastertree, current_node, roi_tag)
            found_new_roi = True
    
    # exit if found valid node
    if found_new_roi:
        return "marked Function"

    if not(is_root):
        current_node.data.group = str(roi_tag)
        mark_subsequent_node(mastertree, current_node, roi_tag)
        progress = mark_next_roi(mastertree, initial_pspace, mastertree.parent(current_node.identifier), roi_tag, roi_ef)
        if progress == "Done":
            return "Done"    
    else:
        DFS_list = [mastertree[node] for node in mastertree.expand_tree(mode=treelib.Tree.DEPTH, sorting=False)]
        # do not check root node if it has been explored as it is never explored
        DFS_list.remove(parent)
        completed_roi_expansion = True
        # check if all nodes have been explored
        for node in DFS_list:
            if node.data.group == "None":
                completed_roi_expansion = False

        # only return if everything has been explored
        if completed_roi_expansion:
            parent.data.group = parent.tag
            return "Done"

def apply_loop_ops(dir, pattern, var_forlist, removed_function_calls, loop_tile_array):    
    topfunction = pattern[pattern.root].tag
    input_dir = dir + "/snips/snip_" + topfunction
    outputfile = input_dir + "/snip_" + topfunction + "_adse.cpp"

    ML_in_main = dir + "/ML_in.cpp"

    for_bounds = []
    removed_functions_list = []
    removed_functions = False
    # test if function removal was done
    for item in removed_function_calls:
        if item[0] == pattern.root:
            removed_functions = True
            removed_functions_list.append(item)  
    #get file location
    if removed_functions:
        inputfile = "snip_" + topfunction + "_funrem.c"
    else:
        inputfile = "snip_" + topfunction + ".c"
    # get for bounds
    for item in var_forlist:
        if item != '' and item[2] == pattern.root:
            for_bounds.append(item[int(3)])      

    #apply scaleHLS optimizations    
    p1 = subprocess.Popen(['mlir-clang', input_dir + "/" + inputfile, '-function=' + topfunction, '-memref-fullrank', '-raise-scf-to-affine', '-S'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)                          
    p2 = subprocess.run(['scalehls-opt', '-allow-unregistered-dialect'], stdin=p1.stdout, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)                  
    fin = p2.stdout

    ctx = mlir.ir.Context()
    scalehls.register_dialects(ctx)
    mod = mlir.ir.Module.parse(fin, ctx)

    pipeline_loc = []
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
            
            np_array = np.array(loop_tile_array[loopband_count])
            loc = scalehls.loop_tiling(band, np_array)

            #keep track of number of loops
            pipeline_loc.append(loop_count + loc + 1)
            for l in np_array:
                cur_bound = for_bounds.pop(0)
                if l == 1 or l == int(cur_bound):
                    loop_count += 1              
                else:
                    loop_count += 2            
            
            loopband_count += 1

        # Apply memory optimizations.
        scalehls.memory_opts(func)
    
    buf = io.StringIO()
    scalehls.emit_hlscpp(mod, buf)
    buf.seek(0)
    # print(buf.read())

    fout = open(outputfile, 'w+')
    shutil.copyfileobj(buf, fout)
    fout.close()

    brace_count = 0
    for_count = 0
    infunction = False
    in_pattern = False
    done_copy = False
    scope = None
    func_decl = False
    global_write = False

    #find place holder location
    ph_loc = []
    if removed_functions:
        with open(outputfile, 'r+') as file:        
            lines = file.readlines()
            for i in range(len(lines)):
                if brace_count == 0:
                    if re.findall(r'(void|int|float)\s([A-Za-z_]+[A-Za-z_\d]*)(\s)?(\()', lines[i]):
                        func_decl = True

                if func_decl:
                    if re.findall(r'\)\s?{', lines[i]):
                        ph_pre = re.findall(r'(int|float|double)\s(v\d+)', lines[i-2])
                        ph_loc.append([ph_pre[0][0] + ' ' + ph_pre[0][1]]) # remove start
                        ph = re.findall(r'(double\sv\d+)', lines[i-1])
                        ph_loc.append(ph)
                        func_decl = False
        file.close()
        ph_new_name = re.findall(r'(v\d+)', ph_loc[1][0])
        trigger_string = ph_new_name[0] + r'\[\d+\] = 42.424242;'

    #copy scalehls dse to combined file
    newfile = open (dir + "/buffer.c", 'w')
    with open(ML_in_main, 'r') as file:        
        for line in file:


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
###########################subfunciton while loop###########################
                    with open(outputfile, 'r') as adse:
                        for subline in adse:
                            global_write = True
                            #detect function
                            if subfunc_brace_count == 0:
                                if re.findall(r'(void|int|float)\s([A-Za-z_]+[A-Za-z_\d]*)(\s)?(\()', subline):
                                    insubfunction = True
                            #write subfuntion to buffer
                            if insubfunction:
                                #place holder finder
                                if removed_functions:
                                    if re.findall(ph_loc[0][0], subline):
                                        global_write = False
                                        newfile.write(re.sub(',', '', subline))
                                    elif re.findall(ph_loc[1][0], subline):
                                        global_write = False
                                    elif re.findall(trigger_string, subline):
                                        global_write = False
                                        leading_space = re.findall(r'(\s*).*', subline)
                                        correct_func_call = removed_functions_list.pop(0)                                        
                                        newfile.write(leading_space[0] + correct_func_call[1] + ';\n')
                                
                                #main write
                                if re.findall(r'#pragma', subline): #remove pragma
                                    None
                                elif re.findall(r'for', subline): #add pipeline pragma
                                    for_count += 1
                                    if for_count in pipeline_loc:
                                        newfile.write(subline)
                                        newfile.write("#pragma HLS pipeline\n")
                                    else:
                                        newfile.write(subline)
                                elif global_write:
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
###########################subfunciton while loop###########################
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

    shutil.copy2(dir + "/buffer.c", ML_in_main)
    os.remove(dir + "/buffer.c")

def graph_algorithm(tar_dir, dse_target, sortedarray, func_list, var_forlist, var_arraylist_sized, var_forlist_scoped, tree_list):

    #scalehls dse initial pareto space creation
    removed_function_calls = []
    pareto_space_list = []
    sdse_var_part_list = []
    for i in range(0, len(tree_list) - 1):
        target = treelib.Tree(tree_list[i].subtree(tree_list[i][tree_list[i].root].identifier), deep=True)
        DFS_list = [target[node] for node in target.expand_tree(mode=treelib.Tree.DEPTH, sorting=False)]
        do_SDSE = True
        has_loops = False
        for DFS_node in DFS_list: 
            if re.findall(r'(Loop)', DFS_node.tag):
                has_loops = True
            for item in var_forlist:
                if (item != ''): 
                    #check if variable loops are at top level of loop band
                    if (target.level(DFS_node.identifier) == 1) and (DFS_node.tag == item[0]) and (item[-1] == "Variable"):
                        do_SDSE = False
        if do_SDSE and has_loops:
            suc_fail, buffer, removed_function_calls, sdse_var_part = cull_function_by_pattern(tar_dir, tar_dir + "/ref_design.c", func_list, removed_function_calls, dse_target, 1, target)            
            if suc_fail:
                pareto_space_list = pareto_space_list + buffer
                sdse_var_part_list.append(sdse_var_part)
    
    print("removed calls")
    print(removed_function_calls)
    print("\nInitial Pareto Space")
    initial_pspace = []
    for i in range(0, len(pareto_space_list)):
        # print(pareto_space_list[i][0])
        initial_pspace.append(pareto_space_list[i][0])
    print(initial_pspace)

    # starting ROI
    # todo: case for when starting ROI is not unique
    print("\nStarting ROI")
    number_of_ROI = 4
    starting_ROI = []
    sibling_ROI = -1
    for i in range(len(sortedarray)):
        sibling_ROI = -1
        # cheak if ROIs are siblings
        for j in range(len(starting_ROI)):
            if sortedarray[i][0] == starting_ROI[j][0]:
                sibling_ROI = j
        # if first entry
        if sibling_ROI == -1:
            starting_ROI.append([sortedarray[i][0], "Loop" + str(sortedarray[i][1]), 1])
        # if not first entry increase expansion factor by 1
        else:
            starting_ROI[j][2] = int(starting_ROI[j][2]) + 1
        # number of ROIs
        number_of_ROI -= 1
        if number_of_ROI == 0:
            break
    print(starting_ROI)

    # DFS traversal for master tree
    mastertree = tree_list[-1]
    DFS_list = [mastertree[node] for node in mastertree.expand_tree(mode=treelib.Tree.DEPTH, sorting=False)]

    # mark starting ROI
    roi_count = 0
    seed_roi = -1
    starting_ROI_nodes = []
    for node in DFS_list:
        # cheak if node is seed roi
        seed_roi = -1
        for i in range(len(starting_ROI)):
            if node.tag == starting_ROI[i][1]:
                seed_roi = i
        # mark starting ROI
        if seed_roi != -1:
            # mark starting node with c
            starting_ROI_nodes.append(node)
            # node.data.group = str(roi_count) + "-c" + str(starting_ROI[seed_roi][2])
            parent = mastertree.parent(node.identifier)
            top_loop_count = get_UnmarkedNodeCount(mastertree, initial_pspace, parent)
            parent.data.group = 'ROI' + str(roi_count) + '_EF' + str(starting_ROI[seed_roi][2]) + '_LC' + str(top_loop_count)   # Type(Name)_ExpansionFactor-UnmarkedNodeCount
            # mark_subsequent_node(mastertree, node, roi_count)
            roi_count += 1

    # Expansion of ROIs
    while_count = 0
    while True:
        for node in DFS_list:
            # start expansion from core node
            if re.findall('(ROI)', node.data.group):
                roi_ef = re.findall(r'_EF(\d+)_', node.data.group)
                roi_ef = int(roi_ef[0]) #expansion factor              
                progress, _ = expand_by_factor(mastertree, initial_pspace, node, roi_ef)
        # break loop when finised
        if progress == "Done":
            break
        # in case
        if while_count > 1000:
            print("Something is wrong, more than 1000 loops")
        # print("\nwhile_count", i)
        # mastertree.show(idhidden = True, data_property="group")
        # isbreak = input("\n\nExpand\n")
        while_count += 1

    print("\nFinal_Tree")
    mastertree.show(idhidden = True, data_property="group")

    # Initial naive combination of individual spaces
    # print("comb")
    # merge_ops = 0    
    # t0 = time.time()
    # buffer, mo = combine_two_spaces(pareto_space_list, "Loop0", "Loop6")
    # merge_ops += mo
    # for i in range(2, len(pareto_space_list)):
    #     print(pareto_space_list[i][0])
    #     buffer, mo = combine_two_spaces(pareto_space_list, buffer, pareto_space_list[i][0])
    #     merge_ops += mo
    # t1 = time.time()
    # buffer.to_csv(tar_dir + '/combspace.csv')
    # total = t1-t0
    # print("Time to execute naive merging", total, " merge opts:", merge_ops)

    # pspace = pd.read_csv(tar_dir + '/combspace.csv', index_col=0)

    # apply_p_point(tar_dir, tree_list, var_forlist, removed_function_calls, pspace, 500)

    return sdse_var_part_list




