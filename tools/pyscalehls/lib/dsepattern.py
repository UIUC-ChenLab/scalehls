import treelib
import re
import math 

def cull_function_by_pattern(dir, inputfile, tag, pattern):
    
    root = pattern.root

    in_pattern = False

    brace_count = 0
    brace_count_cut = math.inf

    is_brace = False
    scope = None

    var_forlist = []
    var_arraylist_sized = []
    var_list = []
    var_forlist_scoped = []

    newfile = open (dir + "/" + tag + "snip.cpp", 'w')
    with open(inputfile, 'r') as file:        
        for line in file:
            is_brace = False
            #scope finder
            if brace_count == 0: 
                raw_scope = re.findall(r'(void|int|float)\s([A-Za-z_]+[A-Za-z_\d]*)(\s)?(\()', line)
                if raw_scope:
                    scope = raw_scope[0][1]
                    print(scope)
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
    
    return 0