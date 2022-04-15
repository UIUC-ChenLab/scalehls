        # target = treelib.Tree(tree_list[3].subtree(tree_list[3][tree_list[3].root].identifier), deep=True)
    # target.show()
    # DPAT.cull_function_by_pattern(tar_dir, tar_dir + "/ML_in.cpp", func_list, removed_function_calls, dse_target, 1, target)  
    
    
    # merge_ops = 0
    # t0 = time.time()
    # buffer, mo = combine_two_spaces(pareto_space_list, "Loop4", "Loop6")
    # merge_ops += mo
    # buffer, mo = combine_two_spaces(pareto_space_list, buffer, "Loop8")
    # merge_ops += mo
    # buffer, mo = combine_two_spaces(pareto_space_list, buffer, "Loop0")
    # merge_ops += mo
    # buffer, mo = combine_two_spaces(pareto_space_list, buffer, "Loop1")
    # merge_ops += mo
    # buffer.to_csv(tar_dir + '/blue.csv')

    # buffer, mo = combine_two_spaces(pareto_space_list, "Loop10", "Loop11")
    # merge_ops += mo
    # buffer, mo = combine_two_spaces(pareto_space_list, buffer, "Loop13")
    # merge_ops += mo
    # buffer, mo = combine_two_spaces(pareto_space_list, buffer, "Loop15")
    # merge_ops += mo
    # buffer, mo = combine_two_spaces(pareto_space_list, buffer, "Loop17")
    # merge_ops += mo
    # buffer, mo = combine_two_spaces(pareto_space_list, buffer, "Loop19")
    # merge_ops += mo
    # buffer.to_csv(tar_dir + '/orange.csv')
    # buffer, mo = combine_two_spaces(pareto_space_list, "Loop21", "Loop23")
    # merge_ops += mo
    # buffer, mo = combine_two_spaces(pareto_space_list, buffer, "Loop24")
    # merge_ops += mo
    # buffer, mo = combine_two_spaces(pareto_space_list, buffer, "Loop26")
    # merge_ops += mo
    # buffer, mo = combine_two_spaces(pareto_space_list, buffer, "Loop27")
    # merge_ops += mo
    # buffer, mo = combine_two_spaces(pareto_space_list, buffer, "Loop29")
    # merge_ops += mo
    # buffer, mo = combine_two_spaces(pareto_space_list, buffer, "Loop30")
    # merge_ops += mo
    # buffer, mo = combine_two_spaces(pareto_space_list, buffer, "Loop32")
    # merge_ops += mo
    # buffer, mo = combine_two_spaces(pareto_space_list, buffer, "Loop33")
    # merge_ops += mo
    # buffer, mo = combine_two_spaces(pareto_space_list, buffer, "Loop35")
    # merge_ops += mo
    # buffer, mo = combine_two_spaces(pareto_space_list, buffer, "Loop36")
    # merge_ops += mo
    # buffer, mo = combine_two_spaces(pareto_space_list, buffer, "Loop38")
    # merge_ops += mo
    # buffer.to_csv(tar_dir + '/red.csv')
    # t1 = time.time()

    total = t1-t0
    print("Time to execute ROI merging", total, " merge opts:", merge_ops)


    # pspace = pd.read_csv(tar_dir + '/combspace.csv', index_col=0)
    # print(pspace)
    # print(pspace.iloc[0]['b4l0'])

    # shutil.copy2(tar_dir + "/ref_design.c", tar_dir + "/ML_in.cpp")
    # DPAT.apply_loop_ops(tar_dir, tree_list[12], var_forlist, removed_function_calls, [[1, 16], [8], [1, 16], [8], [8, 16], [8], [1, 16], [8], [4, 3], [1], [8, 3], [1]])
    # DPAT.apply_loop_ops(tar_dir, tree_list[3], var_forlist, removed_function_calls, [[13, 8]])

    # shutil.copy2(tar_dir + "/ref_design.c", tar_dir + "/ML_in.cpp")
    # apply_loop_ops(tar_dir, tree_list[0], var_forlist, removed_function_calls, np.array([[1], [1]]))
    # apply_loop_ops(tar_dir, tree_list[3], var_forlist, removed_function_calls, np.array([[13, 8]]))
    # apply_loop_ops(tar_dir, tree_list[4], var_forlist, removed_function_calls, np.array([[8, 1]]))
    # apply_loop_ops(tar_dir, tree_list[5], var_forlist, removed_function_calls, np.array([[8, 3]]))
    # apply_loop_ops(tar_dir, tree_list[6], var_forlist, removed_function_calls, np.array([[1]]))
    # apply_loop_ops(tar_dir, tree_list[7], var_forlist, removed_function_calls, np.array([[8, 3]]))
    # apply_loop_ops(tar_dir, tree_list[8], var_forlist, removed_function_calls, np.array([[3, 8]]))
    # apply_loop_ops(tar_dir, tree_list[9], var_forlist, removed_function_calls, np.array([[1, 16]]))
    # apply_loop_ops(tar_dir, tree_list[10], var_forlist, removed_function_calls, np.array([[16, 1]]))
    # apply_loop_ops(tar_dir, tree_list[11], var_forlist, removed_function_calls, np.array([[1, 16]]))
    # apply_loop_ops(tar_dir, tree_list[12], var_forlist, removed_function_calls, [[1, 16], [8], [1, 16], [8], [8, 16], [8], [1, 16], [8], [4, 3], [1], [8, 3], [1]])
#                                                                             # 21     23      24    26     27    29    30     32    33    35      36    38

   # starting ROI
    # todo: case for when starting ROI is not unique
    # print("\nStarting ROI")
    # number_of_ROI = 3
    # starting_ROI = []
    # for i in range(0, number_of_ROI):
    #     starting_ROI.append("Loop" + str(sortedarray[i][1]))
    # print(starting_ROI)

    # # DFS traversal for master tree
    # mastertree = tree_list[-1]
    # DFS_list = [mastertree[node] for node in mastertree.expand_tree(mode=treelib.Tree.DEPTH, sorting=False)]

    # #mark starting ROI
    # roi_count = 0
    # for node in DFS_list:
    #     if node.tag in starting_ROI:
    #          # mark starting node with c
    #         node.data.group = str(roi_count)+"-c"
    #         mark_subsequent_node(mastertree, node, roi_count)
    #         roi_count += 1

    # # print("\n")
    # # mastertree.show(idhidden = True, data_property="group")

    # print("hey")
    # for node in DFS_list:
    #     # start expansion from core node
    #     if re.findall(r'(\d+)-c', node.data.group):
    #         print(node.data.group)
    #         next_mark(mastertree, node, starting_ROI)
    #         # for sib in siblings:
    #         #     if 

    # Expand ROI by one


def next_mark(mastertree, start_node, ROI_seed):

    siblings = mastertree.siblings(start_node.identifier)

    start_lnub = re.findall(r'Loop(\d+)', start_node.tag)
    

    # Loop siblings
    # clos_sib_Loop = []
    # for sib in sibling_list:
    #     if re.findall(r'Loop', sib.tag):
    #         clos_sib_Loop.append(sib)

    # # function siblings
    # clos_sib_func = []
    # for sib in sibling_list:
    #     if re.findall(r'([a-z]*)-.*', sib.tag):
    #         clos_sib_func.append(sib)

    # if re.findall(r'Loop', ref_node.tag):
    #     ref_lnub = re.findall(r'Loop(\d+)', ref_node.tag)
    #     distancefromref = []
    #     for node in clos_sib_Loop:
    #         node_lnub = re.findall(r'Loop(\d+)', node.tag)
    #         ref2node_dis = int(node_lnub[0]) - int(ref_lnub[0])
    #         distancefromref.append(str(ref2node_dis) + "_" + node.tag)
    #     print(distancefromref)


####################################################################################################
    # for i in range(1, len(inputarray)): 
    #     j = i-1
    #     key = inputarray[i]
    #     key_raw = re.findall(sortkeystring, inputarray[i])
    #     inputarray_raw = re.findall(sortkeystring, inputarray[j])
    #     while j >= 0 and int(key_raw[0]) < int(inputarray_raw[0]):
    #             inputarray[j + 1] = inputarray[j]
    #             j -= 1
    #             if j >= 0:
    #                 inputarray_raw = re.findall(sortkeystring, inputarray[j])
    #     inputarray[j + 1] = key    
