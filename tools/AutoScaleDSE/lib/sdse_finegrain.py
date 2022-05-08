import os
import shutil
import io
import json
import copy
import re
import subprocess
import scalehls
import mlir.ir
from mlir.dialects import builtin

def preproccess(tar_dir, source_file, dsespec, inputtop):

    #scalehls dse temp directory
    sdse_dir = tar_dir + "/scalehls_dse_temp/"
    if not(os.path.exists(sdse_dir)):
        os.makedirs(sdse_dir)

    # copy due to linux ownership
    inputfile = "scalehls_in.c"
    sdse_input_file_loc = sdse_dir + inputfile
    if not(os.path.exists(sdse_input_file_loc)):        
        shutil.copy(source_file, sdse_input_file_loc)

    os.chdir(sdse_dir)

    p1 = subprocess.Popen(['mlir-clang', inputfile, '-function=' + inputtop, '-memref-fullrank', '-raise-scf-to-affine', '-S'],
                            stdout=subprocess.PIPE)                           

    with open('preprocessing.cpp', 'wb') as fout:
        subprocess.run(['scalehls-translate', '-emit-hlscpp'], stdin=p1.stdout, stdout=fout)

    var_forlist_tree = []
    var_forlist_tree_popped = []
    var_func_names = []
    function_depend = []
    loopnum = 0
    brace_cout = 0
    popped = False
    is_brace = False
    scope = None

    var_forlist = []

    #get loop bounds
    with open('preprocessing.cpp', 'r') as file:        
        for line in file:
            is_brace = False

            #find function calls
            if brace_cout >= 1:
                functioncall = re.findall(r'\s([A-Za-z_]+[A-Za-z_\d]*)\s?\(', line)
                if functioncall:
                    for item in functioncall:
                        if item in var_func_names:
                            if len(var_forlist_tree) > 0:
                                function_depend.append((item, "Loop" + str(var_forlist_tree[-1][0])))
                            else:
                                function_depend.append((item, scope))

            #scope finder
            if brace_cout == 0: 
                raw_scope = re.findall(r'((void|int|float))\s([A-Za-z_]+[A-Za-z_\d]*)(\s)?(\()', line)
                if raw_scope:
                    scope = raw_scope[0][2]
                    var_func_names.append(scope)

            if(re.findall('{', line)):
                is_brace = True
                if brace_cout == 0:
                    brace_cout += 1
                else:
                    brace_cout += 1
                
                #for band
                if len(var_forlist_tree) > 0 and var_forlist_tree[-1][1] == None:
                    var_forlist_tree[-1][1] = brace_cout

            if(re.findall('}', line)):
                #function scope
                if brace_cout == 1:
                    scope = None
                    brace_cout -= 1
                else:
                    brace_cout -= 1

                if len(var_forlist_tree) > 0 and var_forlist_tree[-1][1] == brace_cout:
                    var_forlist_tree_popped.append(var_forlist_tree.pop())
                    popped = True
                
                if len(var_forlist_tree) == 0 and len(var_forlist_tree_popped) > 0:
                    subtree = ""
                    if len(var_forlist_tree_popped) == 1:
                        subtree = "-" + str(var_forlist_tree_popped[0][0])
                    else:
                        for i in range(len(var_forlist_tree_popped) - 2, -1, -1):
                            subtree = subtree + "-" + str(var_forlist_tree_popped[i][0])

                    var_forlist_tree = []
                    var_forlist_tree_popped = []
                    popped = False

            # todo: temp measure -> implement using MLIR IR
            # change int32_t to int
            elif(re.findall('for', line)): #find loops // only supports one forloop per line
                if not(re.findall(r'(.)*(//)(.)*(for)(.)*', line)): # ignore for in comment
                    #save scoped list if start new for loop band
                    if popped:
                        subtree = ""
                        for i in range(len(var_forlist_tree) - 1, 0, -1):
                            var_forlist_tree_popped.append(var_forlist_tree[i])
                        for i in range(len(var_forlist_tree_popped) - 1, -1, -1):
                            subtree = subtree + "-" + str(var_forlist_tree_popped[i][0])

                        var_forlist_tree_popped = []
                        popped = False

                    if is_brace:
                        var_forlist_tree.append((loopnum, brace_cout - 1))
                    else:
                        var_forlist_tree.append((loopnum, brace_cout))

                    
                    findbound = re.findall(r'(<|>|<=|>=)(.+?);', line) #find bound
                    findbound = findbound[0][1].strip()                    
                    #cheak if bound is evaluable
                    evaluable_chars = ['+', '-', '*', '/', '(', ')', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9']
                    can_eval = False
                    for char in findbound:
                        if char in evaluable_chars:
                            can_eval = True
                        else:
                            can_eval = False
                    
                    if can_eval: # test if variable bound
                        forbound = str(eval(findbound))
                    else:                        
                        forbound = 'Variable'
                    var_forlist.append(list(("Loop"+str(loopnum), line.strip(), scope, forbound)))
                    loopnum += 1

    max_loop_bound = -1
    for item in var_forlist :
        if item[-1].isnumeric and max_loop_bound < int(item[-1]):
            max_loop_bound = int(item[-1]) 

    # unrolling loops beyond 256 leads to non-viable designs
    if max_loop_bound > 256:
        max_loop_bound = 256

    refactored_config = copy.deepcopy(dsespec) 
    refactored_config['max_init_parallel'] = max_loop_bound / 2
    refactored_config['max_expl_parallel'] = max_loop_bound 
    refactored_config['max_loop_parallel'] = max_loop_bound / 4
    refactored_config['max_iter_num'] = int(refactored_config['max_iter_num'])
    refactored_config['max_distance'] = int(refactored_config['max_distance'])
    # with open('config.json', 'w') as f:
    #     json.dump(refactored_config, f)

    os.chdir("../..")

    return refactored_config