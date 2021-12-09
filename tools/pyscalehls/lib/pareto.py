#!/usr/bin/env python
# coding: utf-8

import numpy as np
import pandas as pd

def getParetoFrontier(dataset, exclude_infeasible=True):
    # find the feasible design points
    # 3/8 add option since infeasible points can also provide useful information
    if exclude_infeasible:
        dataset_feasible = dataset[dataset['is_feasible'] == True]
    else:
        dataset_feasible = dataset
    
    # find the latencies and combine the costs
    # TODO: the weighted sum should be tunable
    latencies = dataset_feasible['latency'].astype('float')
    costs = 0.4*dataset_feasible['dsp_perc'] \
            +0.1*dataset_feasible['ff_perc'] \
            +0.1*dataset_feasible['lut_perc'] \
            +0.4*dataset_feasible['bram_perc'] \
    
    # build the dataset with the inproved 
    pareto_dataset = pd.DataFrame()
    pareto_dataset['cost'] = costs
    pareto_dataset['latency'] = latencies
    
    # sort the dataset and find the pareto frontier
    # sort by latency then cost, will ensure that: for the points with the same latency
    # the point with minimal cost will be the first one, and therefore all the inferior point
    # with this latency will be removed automatically
    sorted_dataset = pareto_dataset.sort_values(by=['latency','cost'])

    #debug
    #sorted_dataset.plot.scatter(x='latency', y='cost')
    
    # create a list of interior points' index, to be dropped
    inferior_list = []
    cost = float('inf') # initialize with cost=1, which is the maximum possible value
    latency = 0.0 # initialize latency to 0 for safety
    for idx in sorted_dataset.index:
        design_point = sorted_dataset.loc[idx]

        # check if the cost is in a descending order
        if (design_point['cost'] >= cost):
            inferior_list.append(idx)
        else:
            cost = design_point['cost']
    pareto_frontier = sorted_dataset.drop(inferior_list).reset_index(drop=True)

    #debug
    #pareto_frontier.plot.scatter(x='latency', y='cost')

    return pareto_frontier

# the new version implement a "soft boundary" like the kmeans++,
# such that, the points that are further to the boundary get lower probability of being picked
# so the returned value is a probability 
def getProbabilityOfEval(design_point, pareto_frontier, threshold=1.5):
    if not (pareto_frontier.columns.to_list() == ['cost','latency']):
        print(pareto_frontier.columns.to_list())
        raise AssertionError('Incorrect dataframe format for pareto frontier')
    
    latency   = design_point['latency'][0]
    dsp_perc  = design_point['dsp_perc'][0]
    ff_perc   = design_point['ff_perc'][0]
    lut_perc  = design_point['lut_perc'][0]
    bram_perc = design_point['bram_perc'][0]
    
    # TODO: this should be the same as what we use in the pareto frontier function
    cost = 0.4*dsp_perc+0.1*ff_perc+0.1*lut_perc+0.4*bram_perc
    pareto_frontier = pareto_frontier.append({'cost':cost, 'latency':latency}, ignore_index=True)
    ranking = pareto_frontier['latency'].rank(method='min')
    rank = int(ranking.iloc[-1])

    # handle special cases
    # if it's the top points
    if (rank < 2): return 1.0
    
    upper = pareto_frontier.iloc[rank-1] # neighboring point on the frontier with higher latency
    lower = pareto_frontier.iloc[rank-2] # neighboring point on the frontier with lower latency
    
    # handle special cases
    if (rank == len(pareto_frontier)):
        cost = upper['cost']
        pareto_cost = lower['cost']
        # fix the threshold to 1.0 for this case
        cost_score = np.max([0, (cost - pareto_cost)/(pareto_cost)])
        return np.max([0, 1-cost_score])
    
    # projected cost of this point on the pareto frontier 
    pareto_cost = np.interp(latency, [lower['latency'], upper['latency']], [lower['cost'], upper['cost']])
    
    # check the resource usage, if it's above 1, then reduce the probability
    budget_score = np.max([0, dsp_perc -1]) + \
                   np.max([0, bram_perc-1]) + \
                   np.max([0, ff_perc  -1]) + \
                   np.max([0, lut_perc -1])
    budget_score = np.min([1, budget_score]) # limit the budget score to less than 1
    
    # check if the predicted performance is better, if it's slower, then reduce the probability
    cost_score = np.max([0, (cost - pareto_cost*threshold)/(pareto_cost)]) # threshold is the value that controls the range to acceptable 
    cost_score = np.min([1, cost_score]) # limit the budget score to less than 1
    
    # the probability of evaluating this point
    return  (1-budget_score)*(1-cost_score)


def checkParetoOptimal(design_point, pareto_frontier, threshold=1.5):
    if not (pareto_frontier.columns.to_list() == ['cost','latency']):
        print(pareto_frontier.columns.to_list())
        raise AssertionError('Incorrect dataframe format for pareto frontier')
        
    latency = design_point['latency']
    cost = 0.4*design_point['dsp_perc'] \
        +0.1*design_point['ff_perc'] \
        +0.1*design_point['lut_perc'] \
        +0.4*design_point['bram_perc']
    
    pareto_frontier = pareto_frontier.append({'cost':cost, 'latency':latency}, ignore_index=True)
    ranking = pareto_frontier['latency'].rank(method='min')
    rank = int(ranking.iloc[-1])
    
    # if it's the last one
    if (rank == len(pareto_frontier)):
        if cost < pareto_frontier['cost'][rank-2]: # if it saves resource then good
            return True
        else: # else it's not optimal
            return False
        
    if latency == pareto_frontier['latency'][rank-1]:
        if cost > pareto_frontier['cost'][rank-1]:
            return False
        else:
            return True
    
    # handle special cases
    if (rank == 1):
        return True
    
    upper = pareto_frontier.iloc[rank-1] # neighboring point on the frontier with higher latency
    lower = pareto_frontier.iloc[rank-2] # neighboring point on the frontier with lower latency
    
    # return true if it's near the pareto frontier within the threshold in percentage
    return  cost < (threshold * lower['cost'])

