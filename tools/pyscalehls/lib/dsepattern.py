import treelib
import re
import math 
import os
import subprocess
import json
import copy

def sdse_target(new_dir, dsespec, resource, tag, inputfile, inputtop):

    os.chdir(new_dir)

    print("statrt")
    print(new_dir)
    print(tag)
    print(inputfile)
    print(inputtop)

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

    os.chdir("../..")

def cull_function_by_pattern(dir, inputfile, dsespec, resource, tag, pattern):
    
    new_dir = dir + "/snip_" + tag
    snipfile = "snip_" + tag + ".c"

    if not(os.path.exists(new_dir)):
        os.makedirs(new_dir)

    root = pattern.root

    in_pattern = False

    brace_count = 0
    brace_count_cut = math.inf

    is_brace = False
    scope = None

    newfile = open (new_dir + "/" + snipfile, 'w')
    with open(inputfile, 'r') as file:        
        for line in file:
            is_brace = False
            #scope finder
            if brace_count == 0: 
                raw_scope = re.findall(r'(void|int|float)\s([A-Za-z_]+[A-Za-z_\d]*)(\s)?(\()', line)
                if raw_scope:
                    scope = raw_scope[0][1]
                    if scope == root:
                        in_pattern = True

            if(re.findall('{', line)):
                is_brace = True
                brace_count += 1

            if(re.findall('for', line)): #find loops // only supports one forloop per line
                if not(re.findall(r'(.)*(//)(.)*(for)(.)*', line)): # ignore for in comment
                    loopnum = re.findall('loop(\d):', line)
                    if pattern.get_node(int(loopnum[0])) != None:
                        if in_pattern:
                            newfile.write(re.sub('loop'+ str(loopnum[0]) + ': ', '', line))
                    else:
                        if is_brace:
                            brace_count_cut = brace_count
                        else:
                            brace_count_cut = brace_count + 1
            elif brace_count == 0:
                newfile.write(line)
            elif in_pattern:
                if brace_count < brace_count_cut:
                    newfile.write(line)

            if(re.findall('}', line)):
                if brace_count == 1:
                    brace_count -= 1
                    scope = None
                    in_pattern = False            
                elif brace_count == brace_count_cut:
                    brace_count_cut = math.inf
                    brace_count -= 1
                else:
                    brace_count -= 1
    file.close()
    newfile.close()

    sdse_target(new_dir, dsespec, resource, tag, snipfile, pattern.root)
    
    return 0

