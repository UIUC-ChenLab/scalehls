from pickle import FALSE
import re
import copy
import treelib

def add_node(tree, input):
    try:
        tree.create_node("Loop" + str(input[1]), int(input[1]), parent=input[0])
    except:
        pass

    sub_l0 = re.findall(r'\d+', str(input[2]))
    # test for single loop
    if int(sub_l0[0]) != int(input[1]):
        try:
            tree.create_node("Loop" + str(sub_l0[0]), int(sub_l0[0]), parent=int(input[1]))
        except:
            pass
        for i in range(1, len(sub_l0)):
            try:
                tree.create_node("Loop" + str(sub_l0[i]), int(sub_l0[i]), parent=int(sub_l0[i-1]))
            except:
                pass

def read_user_input():
    default_file_flag = False
    inputfiles = []
    with open("ML_userinput.txt", 'r') as file:
        for line in file:
            if re.findall(r'^(\s)*#', line):
                None
            elif re.findall(r'target_source_file_location', line):
                source_file_raw = re.findall(r'=(.+)', line)
                source_file = source_file_raw[0].strip()
                #print(source_file)
            elif re.findall(r'top_function', line):
                inputtop_raw = re.findall(r'=(.+)', line)
                inputtop = inputtop_raw[0].strip()
                #print(inputtop)
            elif re.findall(r'part(\s)?=', line):
                inputpart_raw = re.findall(r'=(.+)', line)
                inputpart = inputpart_raw[0].strip()
                #print(inputpart)
            elif re.findall(r'add_files', line):
                if line.strip() == "add_files default":
                    inputfiles = ["add_files ../ML_in.cpp\n"]
                    default_file_flag = True
                else:
                    if default_file_flag == False:
                        inputfiles.append(line)
    file.close()    
    template = read_template()
    return source_file, inputtop, inputpart, inputfiles, template

def read_template():
    template = []
    tempstart = False
    with open("ML_userinput.txt", 'r') as file:
        for line in file:
            if tempstart:
                template.append(line)
            if re.findall(r'#template', line):
                tempstart = True
    file.close()
    return template

def create_params(dir, var_forlist, var_arraylist_sized):
    paramfile = open (dir + "/ML_params.csv", 'w')
    paramfile.write("type,name,scope,range,dim\n")
    for item in var_forlist :
        if item == "":
            None
        elif re.findall(r'U+', item[0]):
            paramfile.write("loopU,"+str(item[0])+','+str(item[2])+','+str(item[3])+"\n")
        else:
            paramfile.write("loop,"+str(item[0])+','+str(item[2])+','+str(item[3])+"\n")
    #array
    for item in var_arraylist_sized :
        if item:
            name0 = re.findall(r'(.+?)\[', item[1])
            if item[4] > 1:
                for i in range(int(item[4])):
                    paramfile.write("array,"+str(item[2])+','+str(item[3])+','+str(item[5+i])+','+str(1+i)+"\n")
            else:
                paramfile.write("array,"+str(item[2])+','+str(item[3])+','+str(item[5])+','+str(item[4])+"\n")
    paramfile.close()
    return 0

def create_template(dir, sourcefile, inputfiles, template):
    templatefile = open (dir + "/ML_template.txt", 'w')
    templatefile.write("open_project {{ project_name }}\n")
    templatefile.write("set_top {{ top_function }}\n")
    if inputfiles:
        for item in inputfiles:
            templatefile.write(item)
    else:
        templatefile.write("add_files "+str(sourcefile)+"\n")
    for item in template:
        templatefile.write(item)
    return 0

def process_source_file(dir, inputfile, sdse=False):
    
    var_forlist_tree = []
    var_forlist_tree_popped = []
    loopnum = 0
    arraynum = 0
    brace_cout = 0
    loopband_hotness = 0
    popped = False
    is_brace = False
    scope = None

    var_forlist = []
    var_arraylist_sized = []
    var_list = []
    var_forlist_scoped = []

    newfile = open (dir + "/ML_in.cpp", 'w')
    with open(inputfile, 'r') as file:        
        for line in file:
            is_brace = False
            #scope finder
            if brace_cout == 0: 
                raw_scope = re.findall(r'((void|int|float))\s([A-Za-z_]+[A-Za-z_\d]*)(\s)?(\()', line)
                if raw_scope:
                    scope = raw_scope[0][2]
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
                    var_forlist.append("")
                    var_arraylist_sized.append("")
                    var_forlist_scoped.append("")
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

                    var_forlist_scoped.append((scope, var_forlist_tree_popped[-1][0], subtree, loopband_hotness))
                    # var_forlist_scoped.append((scope, var_forlist_tree_popped[-1][0], var_forlist_tree_popped[0][0], loopband_hotness))
                    var_forlist_tree = []
                    var_forlist_tree_popped = []
                    loopband_hotness = 0
                    popped = False

            # temp measure
            if(re.findall(r'^(\s)*#include', line)): #ignore #include
                None
                newfile.write(line)
            elif(re.findall(r'^(\s)*#pragma', line)): #ignore #pragma
                if ((re.findall(r'^(\s)*#pragma HLS pipeline II', line)) and (sdse)):
                    newfile.write("#pragma HLS pipeline\n")
                else: 
                    None
            elif(re.findall(r'using namespace std;', line)): #ignore #pragma
                None
            # todo: temp measure -> implement using MLIR IR
            # change int32_t to int
            elif(re.findall('int32_t', line)):
                newfile.write(re.sub('int32_t', 'int', line))
            elif(re.findall('for', line)): #find loops // only supports one forloop per line
                if not(re.findall(r'(.)*(//)(.)*(for)(.)*', line)): # ignore for in comment
                    #save scoped list if start new for loop band
                    if popped:
                        subtree = ""
                        for i in range(len(var_forlist_tree) - 1, 0, -1):
                            var_forlist_tree_popped.append(var_forlist_tree[i])
                        for i in range(len(var_forlist_tree_popped) - 1, -1, -1):
                            subtree = subtree + "-" + str(var_forlist_tree_popped[i][0])

                        var_forlist_scoped.append((scope, var_forlist_tree[0][0], subtree, loopband_hotness))
                        # var_forlist_scoped.append((scope, var_forlist_tree[0][0], var_forlist_tree_popped[0][0], loopband_hotness))                        
                        var_forlist_tree_popped = []
                        loopband_hotness = 0
                        popped = False

                    if is_brace:
                        var_forlist_tree.append((loopnum, brace_cout - 1))
                    else:
                        var_forlist_tree.append((loopnum, brace_cout))

                    findbound = re.findall(r'(<|>|<=|>=)(.+?);', line) #find bound
                    testint = findbound[0][1].strip().isnumeric()
                    if testint: # test if variable bound
                        forbound = findbound[0][1].strip()
                    else:                        
                        forbound = 'Variable'
                    var_forlist.append(list(("loop"+str(loopnum), line.strip(), scope, forbound)))
                    newfile.write(line.replace("for", "loop" + str(loopnum)  + ": " + "for"))
                    loopnum += 1
                else: # copy other
                    newfile.write(line)
            else: # copy other
                newfile.write(line)

            #find array
            #only upto six dimentions
            arr2part = re.findall(r'(int|float)\s([A-Za-z_]+[A-Za-z_\d]*)\s?(\[[\dA-Z]+\])?\s?(\[[\dA-Z]+\])?\s?(\[[\dA-Z]+\])?\s?(\[[\dA-Z]+\])?\s?(\[[\dA-Z]+\])?\s?(\[[\dA-Z]+\])+(,|;|\)|' ')', line)
            if(arr2part):
                for item in arr2part:
                    current_array = "".join(item[1:-1])
                    array_sizeofdim = re.findall(r'(\[)(.+?)(\])', current_array)
                    array_dim = len(array_sizeofdim)
                    list_buffer = list(("array"+str(arraynum), current_array, item[1], scope, array_dim))
                    for cdim in array_sizeofdim:
                        list_buffer.append(cdim[1])
                    list_buffer.append("dependencies")
                    var_arraylist_sized.append(list_buffer)
                    arraynum += 1

            #dependency search
            if len(var_forlist_tree) > 0: 
                line_array_list = re.findall(r'\s([A-Za-z_]+[A-Za-z_\d]*)\s?\[', line)
                if var_arraylist_sized and line_array_list:
                    for item_list_array in var_arraylist_sized :
                        if item_list_array == "":
                            None
                        else:
                            for item_line_array in line_array_list:
                                if item_list_array[2] == item_line_array:
                                    #ignore if already in list    
                                    # dep_state = re.findall(r'(\d)array', item_list_array[0])
                                    if(type(item_list_array[-1]) ==  "dependencies"): # if first entry
                                        item_list_array.append(var_forlist_tree[0][0])
                                    elif item_list_array[-1] == var_forlist_tree[0][0]: #check for conflicts
                                        None
                                    else:
                                        item_list_array.append(var_forlist_tree[0][0])

            #hotloop counter
            if len(var_forlist_tree) > 0:
                num_mul = 0
                num_add = 0
                if not(re.findall('for', line)):
                    #do not count address calculations as calculations
                    remove_address_cal = re.findall(r'([^[\]]+)(?:$|\[)', line)
                    clean_line = " ".join(remove_address_cal)

                    nub_mul_raw = re.findall(r'\*', clean_line)
                    nub_add_raw = re.findall(r'\+', clean_line)
                    num_mul = len(nub_mul_raw)
                    num_add = len(nub_add_raw)

                line_trip_count = 1
                if(num_mul + num_add) > 0:
                    for asso_loop in var_forlist_tree:
                        for loopdirectory in var_forlist:
                            if loopdirectory == "":
                                None
                            else:
                                if loopdirectory[-1] == 'Variable':
                                    line_trip_count = 0
                                    break
                                else:
                                    loc_loopnum = re.findall(r'\d+', loopdirectory[0])
                                    if int(loc_loopnum[0]) == asso_loop[0]:
                                        line_trip_count *= int(loopdirectory[-1])

                    loopband_hotness += line_trip_count * (4 * num_mul + num_add) #weight for mul and addition
    file.close()
    newfile.close()

    #add outer most loop for loops with more than one nested loop band
    if sdse:
        var_forlist_buffer = []
        for i in range(len(var_forlist_scoped) - 2):
            if var_forlist_scoped[i][1] == var_forlist_scoped[i+1][1]:
                imm_parent = var_forlist_scoped[i][1]
                #find immidiate parent
                a = re.findall(r'\d+', var_forlist_scoped[i][2])
                b = re.findall(r'\d+', var_forlist_scoped[i+1][2])
                try:
                    for i in range(len(a) - 2, -1, -1):
                        for j in range(len(b) - 2, -1, -1):
                            if int(a[i]) == int(b[j]):
                                imm_parent = int(b[j])
                                raise StopIteration
                except StopIteration: 
                    pass
                
                #find parent loop in for list
                for loopdirectory in var_forlist:
                    if loopdirectory != "":
                        loc_loopnum = re.findall(r'\d+', loopdirectory[0])
                        if int(loc_loopnum[0]) == int(imm_parent):
                            if len(var_forlist_buffer) > 0:
                                if var_forlist_buffer[-1][0] != loopdirectory[0]:
                                    var_forlist_buffer.append(loopdirectory)
                            else:
                                var_forlist_buffer.append(loopdirectory)
        var_forlist = copy.deepcopy(var_forlist_buffer)
        # mark loop
        # for item in var_forlist:
        #     item[0] = item[0] + "U"

    # create tree
    tree_list = []
    if len(var_forlist_scoped) > 1: 
        StartofTree = True
        tree = None
        for i in range(len(var_forlist_scoped)):
            if var_forlist_scoped[i] == "":
                StartofTree = True
                tree_list.append(tree)
            else:
                if StartofTree:
                    tree = treelib.Tree()                    
                    tree.create_node(str(var_forlist_scoped[i][0]), str(var_forlist_scoped[i][0]))  # root node
                    add_node(tree, var_forlist_scoped[i])
                    StartofTree = False
                else:
                    add_node(tree, var_forlist_scoped[i])        
    
    return var_forlist, var_arraylist_sized, var_list, var_forlist_scoped, tree_list