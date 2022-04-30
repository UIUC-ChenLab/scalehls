def get_parent(mastertree, level, start_node):

    # return False if no more nodes to mark

    is_root = False
    find_parent = start_node
    for i in range(level):
        parent = mastertree.parent(find_parent.identifier)
        if parent == mastertree.root:
            is_root = True
            break
        else:
            find_parent = parent

    return is_root, parent

    siblings_list = mastertree.children(parent.identifier)

    # check if there are free siblings
    have_free_sibs = False
    for sib in siblings_list:
        if sib.data.group == "None":
            have_free_sibs = True

    if have_free_sibs:        
        return True, parent, siblings_list    
    else:
        if parent == mastertree.root:
            return False, parent, siblings_list
        else:
            mark_subsequent_node(mastertree, start_node, roi_tag)
            return get_free_parent(mastertree, parent, roi_tag)



        # calculate distance between siblings
        
        distance_cal_list = []
        min_distance = float("inf")
        for sib in func_siblings:
            ordertag = re.findall(r'([a-z]+)-.*', sib.tag)
            distance = abs(alpha_to_int(ordertag[0]) - current_node_ordernumb)
            # update min distance
            if distance < min_distance:
                min_distance = distance
            # store distance data
            distance_cal_list.append([distance, sib])
        
        # get candidate nodes
        candidate_sibs = []
        for sib_pair in distance_cal_list:
            if sib_pair[0] == min_distance:
                candidate_sibs.append(sib_pair)

        # calculate closest marked node from current node                
        min_distance = float("inf")
        closest_marked_node = None
        for mksib in marked_sibs:
            mksib_ortag = re.findall(r'([a-z]+)-.*', mksib.tag)
            distance = abs(alpha_to_int(mksib_ortag[0]) - current_node_ordernumb)
            if distance < min_distance:
                closest_marked_node = mksib
                min_distance = distance

        # get candidate node distance from closest marked node
        clomksib_ortag = re.findall(r'([a-z]+)-.*', closest_marked_node.tag)
        for cansib in candidate_sibs:
            cansib_ortag = re.findall(r'([a-z]+)-.*', cansib[1].tag)
            distance = abs(alpha_to_int(clomksib_ortag[0]) - alpha_to_int(cansib_ortag[0]))
            cansib[0] = cansib[0] + distance

        # get final candidate node
        max_distance = -1
        final_candidate = None
        for cansib in candidate_sibs:
            if cansib[0] > max_distance:
                max_distance = cansib[0]
                final_candidate = cansib

        print("fin can", final_candidate)

        # finally make the node!
        if final_candidate != None:
            top_loop_count = get_UnmarkedNodeCount(mastertree, initial_pspace, final_candidate[1])
            final_candidate[1].data.group = 'ROI' + roi_tag + '_EF' + roi_ef + '_LC' + str(top_loop_count)   # Type(Name)_ExpansionFactor-UnmarkedNodeCount
            return "marked function"
                

    return found_new_roi






def expand_by_factor(mastertree, initial_pspace, starting_ROI_node, start_node, factor):

    roi_tag = re.findall(r'(\d+)-c', start_node.data.group)

    freeparent = get_free_parent(mastertree, start_node)
    print(freeparent)
    siblings_list = mastertree.children(freeparent.identifier)
    # print(siblings_list)

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
    level_complete = True
    for lsib in loop_siblings:
        if lsib.data.group == "None" and factor > 0:
            lsib.data.group = str(roi_tag[0])
            mark_subsequent_node(mastertree, lsib, roi_tag[0])
            # do not mark loops that are not design space
            if lsib.tag in initial_pspace:
                factor -= 1
        # check if siblings have been marked
        if lsib.data.group == "None":
            level_complete = False

    # return if expanded
    if factor == 0:
        return "loopexit"



    
    # print(alpha_to_int('ab'))
    
    # mark parent node if complete -> has cost
    if level_complete and (freeparent.data.group != "Complete"):
        freeparent.data.group = "Complete"
        factor -= 1

    # return if expanded(marking function boundaries is a step)
    if factor == 0:
        return "completeexit"
    

    # print("test")
    # print(clos_sib_Loop)
    # print(clos_sib_func)


    # if re.findall(r'Loop', ref_node.tag):
    #     ref_lnub = re.findall(r'Loop(\d+)', ref_node.tag)
    #     distancefromref = []
    #     for node in clos_sib_Loop:
    #         node_lnub = re.findall(r'Loop(\d+)', node.tag)
    #         ref2node_dis = int(node_lnub[0]) - int(ref_lnub[0])
    #         distancefromref.append(str(ref2node_dis) + "_" + node.tag)
    #     print(distancefromref)

    return 0
    

    
    # find sibling that is the ancestor of start node
    for sib in func_siblings:
        if mastertree.is_ancestor(sib.identifier, start_node.identifier):
            sibling_acncestor_startnode = sib
    # get sibling list based on distance to starting node
    distance = 1
    siblings_by_distance = []
    while func_siblings != []:
        for sib in func_siblings:
            ordertag = re.findall(r'([a-z]+)-.*', sib.tag)
            print(ordertag)

def get_free_parent(mastertree, start_node):
    parent = mastertree.parent(start_node.identifier)

    if parent.data.group == "None" or parent.data.group == "Seed":
        return parent
    elif parent == mastertree.root:
        return parent
    else:
         return get_free_parent(mastertree, parent)



def expand_by_factor(mastertree, initial_pspace, starting_ROI_node, start_node, factor):

    roi_tag = re.findall(r'(\d+)-c', start_node.data.group)

    freeparent = get_free_parent(mastertree, start_node)
    print(freeparent)
    siblings_list = mastertree.children(freeparent.identifier)
    # print(siblings_list)

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
    level_complete = True
    for lsib in loop_siblings:
        if lsib.data.group == "None" and factor > 0:
            lsib.data.group = str(roi_tag[0])
            mark_subsequent_node(mastertree, lsib, roi_tag[0])
            # do not mark loops that are not design space
            if lsib.tag in initial_pspace:
                factor -= 1
        # check if siblings have been marked
        if lsib.data.group == "None":
            level_complete = False

    # return if expanded
    if factor == 0:
        return 1

    # find sibling that is the ancestor of start node
    for sib in func_siblings:
        if mastertree.is_ancestor(sib.identifier, start_node.identifier):
            sibling_acncestor_startnode = sib
    # get sibling list based on distance to starting node
    distance = 1
    siblings_by_distance = []
    while func_siblings != []:
        for sib in func_siblings:
            ordertag = re.findall(r'([a-z]+)-.*', sib.tag)
            print(ordertag)

    
    # print(alpha_to_int('ab'))
    
    # mark parent node if complete -> has cost
    if level_complete and (freeparent.data.group != "Complete"):
        freeparent.data.group = "Complete"
        factor -= 1

    # return if expanded(marking function boundaries is a step)
    if factor == 0:
        return 3
    

    # print("test")
    # print(clos_sib_Loop)
    # print(clos_sib_func)


    # if re.findall(r'Loop', ref_node.tag):
    #     ref_lnub = re.findall(r'Loop(\d+)', ref_node.tag)
    #     distancefromref = []
    #     for node in clos_sib_Loop:
    #         node_lnub = re.findall(r'Loop(\d+)', node.tag)
    #         ref2node_dis = int(node_lnub[0]) - int(ref_lnub[0])
    #         distancefromref.append(str(ref2node_dis) + "_" + node.tag)
    #     print(distancefromref)

    return 0

def get_free_parent(mastertree, start_node):
    parent = mastertree.parent(start_node.identifier)

    if parent.data.group == "None" or parent.data.group == "Expanding":
        return parent
    elif parent == mastertree.root:
        return parent
    else:
         return get_free_parent(mastertree, parent)

def expand_by_factor(mastertree, DFS_list, initial_pspace, starting_ROI_nodes, start_node, factor):

    roi_tag = re.findall(r'(\d+)-c', start_node.data.group)

    # get currently expanding parent
    for item in DFS_list:
        expan_num = re.findall(r'Expanding-(\d+)', item.data.group)
        if expan_num and expan_num[0] == roi_tag[0]:
            parent_of_interest = item

    print(parent_of_interest)
    siblings_list = mastertree.children(parent_of_interest.identifier)
    # print(siblings_list)

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
    level_complete = True
    for lsib in loop_siblings:
        if lsib.data.group == "None" and factor > 0:
            lsib.data.group = str(roi_tag[0])
            mark_subsequent_node(mastertree, lsib, roi_tag[0])
            # do not mark loops that are not design space
            if lsib.tag in initial_pspace:
                factor -= 1
        # check if siblings have been marked
        if lsib.data.group == "None":
            level_complete = False

    # return if expanded
    if factor == 0:
        return "loopexit"

        # mark parent node if complete -> has cost
    if level_complete and (parent_of_interest.data.group != "Complete"):
        parent_of_interest.data.group = "Complete"
        factor -= 1

    # return if expanded(marking function boundaries is a step)
    if factor == 0:
        return "completeexit"

    return "stilldev"         


