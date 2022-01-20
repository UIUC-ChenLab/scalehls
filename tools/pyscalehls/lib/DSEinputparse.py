import re

def read_user_input():
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

def process_source_file_array(inputfile):
    var_forlist = []
    var_forlist_scoped = []
    var_arraylist_raw = []
    var_arraylist_sized = []
    filebuf = []
    loopnum = 0
    arraynum = 0
    brace_cout = 0
    for_brace_cout = 0
    scope = None
    newfile = open ("generated_files/ML_in.c", 'w')
    with open(inputfile, 'r') as file:
        for line in file:
            #scope finder
            if brace_cout == 0: 
                #filebuf.append(line) # store file in buffer
                raw_scope = re.findall(r'((void|int|float))\s([A-Za-z_]+[A-Za-z_\d]*)(\s)?(\()', line)
                if raw_scope:
                    scope = raw_scope[0][2]
            if(re.findall('{', line)):
                if brace_cout == 0:
                    #scope = find_scope(filebuf)
                    brace_cout += 1
                else:
                    brace_cout += 1
                
                #for band
                if for_brace_cout > 0:
                    for_brace_cout += 1

            if(re.findall('}', line)):
                #function scope
                if brace_cout == 1:
                    filebuf.clear() #clear buf when brackets are matched
                    scope = None
                    var_forlist.append("")
                    var_arraylist_raw.append("")
                    brace_cout -= 1
                else:
                    brace_cout -= 1
                
                #for band
                if for_brace_cout == 1:
                    var_forlist_scoped.append(loopnum - 1)
                    for_brace_cout -= 1
                else:
                    for_brace_cout -= 1
            # cleanup code                       
#if re.findall(r'^(\s)*#', line):
            # temp measure
            if(re.findall(r'^(\s)*#include', line)): #ignore #include
                None
            elif(re.findall(r'^(\s)*#pragma', line)):
                if(re.findall(r'^(\s)*#pragma HLS pipeline II', line)): #keep pipeline
                    newfile.write(line)
                else: #ignore #pragma
                    None 
            elif(re.findall(r'using namespace std;', line)): #ignore #pragma
                None
            # todo: temp measure -> implement using MLIR IR
            # elif(re.findall('for', line)): #find loops // only supports one forloop per line
            #     if not(re.findall(r'(.)*(//)(.)*(for)(.)*', line)): # ignore for in comment
            #         #for band counter
            #         if for_brace_cout == 0: 
            #             var_forlist_scoped.append(loopnum)
            #             for_brace_cout += 1

            #         findbound = re.findall(r'(<|>|<=|>=)(.+?);', line) #find bound
            #         testint = findbound[0][1].strip().isnumeric()
            #         if testint: # test if variable bound
            #             forbound = findbound[0][1].strip()
            #         else:                        
            #             forbound = 'Variable'
            #         var_forlist.append(("loop"+str(loopnum), line.strip(), scope, forbound))
            #         newfile.write(line.replace("for", "loop" + str(loopnum)  + ": " + "for"))
            #         loopnum += 1
            #     else: # copy other
            #         newfile.write(line)    
            else: # copy other
                newfile.write(line)
            #find array
            arr2part = re.findall(r'(int|float)\s([A-Za-z_]+[A-Za-z_\d]*)\s?(\[[\d]+\])*\s?(\[[\d]+\])+(,|;|\)|' ')', line)
            if(arr2part):
                for item in arr2part:
                    var_arraylist_raw.append(("array"+str(arraynum), "".join(item[1:-1]), scope))
                    #var_arraylist_raw.append(("array"+str(arraynum), item[0] + " " + "".join(item[1:-1]), scope))
                    arraynum += 1
    file.close()
    newfile.close()
    
    #find dimension and size
    for item in var_arraylist_raw :
        if item: # not empty
            current = list(item)
            array_sizing = re.findall(r'(\[)(.+?)(\])', current[1])
            array_dim = len(array_sizing)
            current.append(array_dim)
            for cdim in array_sizing:
                current.append(cdim[1])
            var_arraylist_sized.append(tuple(current))
        else:
            var_arraylist_sized.append(item)
    
    return var_forlist, var_arraylist_sized, var_forlist_scoped

def process_source_file(inputfile):
    var_forlist = []
    var_forlist_scoped = []
    var_arraylist_raw = []
    var_arraylist_sized = []
    filebuf = []
    loopnum = 0
    arraynum = 0
    brace_cout = 0
    for_brace_cout = 0
    scope = None
    newfile = open ("generated_files/ML_in.c", 'w')
    with open(inputfile, 'r') as file:
        for line in file:
            #scope finder
            if brace_cout == 0: 
                #filebuf.append(line) # store file in buffer
                raw_scope = re.findall(r'((void|int|float))\s([A-Za-z_]+[A-Za-z_\d]*)(\s)?(\()', line)
                if raw_scope:
                    scope = raw_scope[0][2]
            if(re.findall('{', line)):
                if brace_cout == 0:
                    #scope = find_scope(filebuf)
                    brace_cout += 1
                else:
                    brace_cout += 1
                
                #for band
                if for_brace_cout > 0:
                    for_brace_cout += 1

            if(re.findall('}', line)):
                #function scope
                if brace_cout == 1:
                    filebuf.clear() #clear buf when brackets are matched
                    scope = None
                    var_forlist.append("")
                    var_arraylist_raw.append("")
                    brace_cout -= 1
                else:
                    brace_cout -= 1
                
                #for band
                if for_brace_cout == 1:
                    var_forlist_scoped.append(loopnum - 1)
                    for_brace_cout -= 1
                else:
                    for_brace_cout -= 1
            # cleanup code                       
#if re.findall(r'^(\s)*#', line):
            # temp measure
            if(re.findall(r'^(\s)*#include', line)): #ignore #include
                None
            elif(re.findall(r'^(\s)*#pragma', line)): #ignore #pragma
                None
            elif(re.findall(r'using namespace std;', line)): #ignore #pragma
                None
            # todo: temp measure -> implement using MLIR IR
            elif(re.findall('for', line)): #find loops // only supports one forloop per line
                if not(re.findall(r'(.)*(//)(.)*(for)(.)*', line)): # ignore for in comment
                    #for band counter
                    if for_brace_cout == 0: 
                        var_forlist_scoped.append(loopnum)
                        for_brace_cout += 1

                    findbound = re.findall(r'(<|>|<=|>=)(.+?);', line) #find bound
                    testint = findbound[0][1].strip().isnumeric()
                    if testint: # test if variable bound
                        forbound = findbound[0][1].strip()
                    else:                        
                        forbound = 'Variable'
                    var_forlist.append(("loop"+str(loopnum), line.strip(), scope, forbound))
                    newfile.write(line.replace("for", "loop" + str(loopnum)  + ": " + "for"))
                    loopnum += 1
                else: # copy other
                    newfile.write(line)    
            else: # copy other
                newfile.write(line)
            #find array
            arr2part = re.findall(r'(int|float)\s([A-Za-z_]+[A-Za-z_\d]*)\s?(\[[\d]+\])*\s?(\[[\d]+\])+(,|;|\)|' ')', line)
            if(arr2part):
                for item in arr2part:
                    var_arraylist_raw.append(("array"+str(arraynum), "".join(item[1:-1]), scope))
                    #var_arraylist_raw.append(("array"+str(arraynum), item[0] + " " + "".join(item[1:-1]), scope))
                    arraynum += 1
    file.close()
    newfile.close()
    
    #find dimension and size
    for item in var_arraylist_raw :
        if item: # not empty
            current = list(item)
            array_sizing = re.findall(r'(\[)(.+?)(\])', current[1])
            array_dim = len(array_sizing)
            current.append(array_dim)
            for cdim in array_sizing:
                current.append(cdim[1])
            var_arraylist_sized.append(tuple(current))
        else:
            var_arraylist_sized.append(item)
    
    return var_forlist, var_arraylist_sized, var_forlist_scoped

def create_params(var_forlist, var_arraylist_sized):
    paramfile = open ("generated_files/ML_params.csv", 'w')
    paramfile.write("type,name,scope,range,dim\n")
    for item in var_forlist :
        if item:
            paramfile.write("loop,"+str(item[0])+','+str(item[2])+','+str(item[3])+"\n")
    #array
    for item in var_arraylist_sized :
        if item:
            name0 = re.findall(r'(.+?)\[', item[1])
            if item[3] > 1:
                for i in range(int(item[3])):
                    paramfile.write("array,"+str(name0[0])+','+str(item[2])+','+str(item[4+i])+','+str(1+i)+"\n")
            else:
                paramfile.write("array,"+str(name0[0])+','+str(item[2])+','+str(item[4])+','+str(item[3])+"\n")
    paramfile.close()

def create_template(sourcefile, inputfiles, template):
    templatefile = open ("generated_files/ML_template.txt", 'w')
    templatefile.write("open_project {{ project_name }}\n")
    templatefile.write("set_top {{ top_function }}\n")
    if inputfiles:
        for item in inputfiles:
            templatefile.write(item)
    else:
        templatefile.write("add_files "+str(sourcefile)+"\n")
    for item in template:
        templatefile.write(item)