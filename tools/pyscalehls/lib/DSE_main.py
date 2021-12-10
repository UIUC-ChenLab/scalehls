import numpy as np
import pandas as pd
import time
from sklearn.model_selection import KFold
from timeit import default_timer as timer
from sklearn.preprocessing import OneHotEncoder
from sklearn.tree import DecisionTreeRegressor
from sklearn.ensemble import RandomForestRegressor, RandomForestClassifier
from sklearn.model_selection import train_test_split
from scipy.special import beta
from math import factorial as fact
from multiprocessing import Process
import re
import random
import scipy
import pprint
import pickle

from lib import run_hls 
from lib import pareto 
from lib import generate_directives

def preprocessing(features, columns):
    # define the categories and encoders
    # the reason to use predefined categories is to avoid special cases, where some of the input features
    # only have one category present in the current dataset
    loop_directive_types = ['pipeline','unroll','none']
    array_directive_types = ['cyclic','block','complete','none']
    #enc_loop = OneHotEncoder(categories=[loop_directive_types], drop='first', sparse=False)
    #enc_array = OneHotEncoder(categories=[array_directive_types], drop='first', sparse=False)
    # for now, we do not drop the category
    enc_loop = OneHotEncoder(categories=[loop_directive_types], sparse=False)
    enc_array = OneHotEncoder(categories=[array_directive_types], sparse=False)
    
    #
    list_features_encoded = []
    #for i in range(features.shape[1]):
    for i,col in enumerate(columns):
        feature = features[:,i].reshape(1,-1).transpose()
        
        # detect data type of a feature
        if isinstance(feature[0][0], str):
            # identify the type of feature
            if (re.match('^loop_.+_type$' ,col)):
                encoder = enc_loop
            elif (re.match('^array_.+_type$' ,col)):
                encoder = enc_array
            else:
                raise AssertionError('unknown directive types')
            
            # encode the feature
            encoded = encoder.fit_transform(feature).astype('int')
            list_features_encoded.append(encoded)
        else:
            list_features_encoded.append(feature)

    encoded_features = np.concatenate(list_features_encoded, axis=1)
    return encoded_features

class BetaDistCounter():
    def __init__(self):
        self.n = 0
        self.a = 1  # the number of times this socket returned a charge        
        self.b = 1  # the number of times no charge was returned     
    
    def reset(self):
        self.__init__()
    
    def update(self,R):
        self.n += 1    
        self.a += R
        self.b += (1-R)
        
    def sample(self):
        return np.random.beta(self.a,self.b)
    
def selectMethod(method_records, view_boundary=30):
    # initialize the beta distributions of them
    random_beta = BetaDistCounter()
    evo_beta = BetaDistCounter()
    mut_beta = BetaDistCounter()
    records_in_view = method_records[-view_boundary:]
    for method, result in records_in_view:
        if(method == 'rand'):
            random_beta.update(result)
        elif(method == 'evo'):
            evo_beta.update(result)
        elif(method == 'mut'):
            mut_beta.update(result)
        else:
            raise(AssertionError('Unknown proposing method'))
    
    rand_beta_sample = random_beta.sample()
    evo_beta_sample = evo_beta.sample()
    mut_beta_sample = mut_beta.sample()
    print('Rand beta sample: '+str(rand_beta_sample))
    print('Evo beta sample: '+str(evo_beta_sample))
    print('Mut beta sample: '+str(mut_beta_sample))

    select = np.argmax([rand_beta_sample, evo_beta_sample, mut_beta_sample])
    print([rand_beta_sample, evo_beta_sample, mut_beta_sample])
    methods = ['rand', 'evo', 'mut']
    print(methods[select])
    return methods[select]

def predict_perf(parameters, models, feature_columns):
    regr_lat, regr_dsp, regr_ff, regr_lut, regr_bram, clss_timeout = models
    
    encoded_features = preprocessing(pd.Series(parameters).to_frame().T.to_numpy(), feature_columns)

    pred_lat = regr_lat.predict(encoded_features)
    pred_dsp = regr_dsp.predict(encoded_features)
    pred_ff = regr_ff.predict(encoded_features)
    pred_lut = regr_lut.predict(encoded_features)
    pred_bram = regr_bram.predict(encoded_features)
    proba_timeout = clss_timeout.predict_proba(encoded_features)[0,0]

    predicted_perf = {'latency':pred_lat,
                      'dsp_perc':pred_dsp,
                      'ff_perc':pred_ff, 
                      'lut_perc':pred_lut,
                      'bram_perc':pred_bram}
    return predicted_perf, proba_timeout

def randProposal(directives_path, no_partitioning, dir_gen):
    _, parameters = dir_gen.generate_directives(out_file_path=None, no_partitioning=no_partitioning)

    return parameters

def evoProposal(no_partitioning, importances, gamma, dataset, feature_columns, models, crossover, mutator, pareto_frontier, n_families=3, n_offsprings=3, threshold=1.0, exclude_infeasible=True):
    pareto_set = getPopulation(dataset, threshold=1.0, exclude_infeasible=exclude_infeasible).sort_values('latency')
    
    # select only 1 point for each unique latency randomly
    unique_latencies = pareto_set['latency'].unique()
    unique_pareto_points_idx = []
    for lat in unique_latencies:
        eq_lat_points = pareto_set[pareto_set['latency'] == lat]
        rand_idx = random.randint(0, len(eq_lat_points)-1)
        selected = eq_lat_points.index[rand_idx]
        unique_pareto_points_idx.append(selected)
    pareto_points = pareto_set.loc[unique_pareto_points_idx]
    
    latency = pareto_frontier['latency']
    min_lat = min(latency)
    max_lat = max(latency)

    # get the population
    population = getPopulation(dataset, threshold=1.2, exclude_infeasible=exclude_infeasible)

    list_params = []
    list_probs = []

    for i in range(n_families):
        parent_idx = np.random.randint(0, len(population),size=1)
        parent_rand = population.iloc[parent_idx]
        latency_ranking = latency.append(parent_rand['latency'])
        ranking = latency_ranking.rank(method='min')
        rank = int(ranking.iloc[-1])

        parent_lat = parent_rand['latency'].to_numpy()[0]
        
        if(parent_lat <= min_lat): # unlikely to happen, just in case
            print('case 1: selected the fastest')
            if(len(pareto_points) == 1): # edge case, only 1 in pareto set
                parent_pareto = pareto_points.iloc[0] # other parent is the next fastest one
            else:
                parent_pareto = pareto_points.iloc[1] # other parent is the next fastest one
        elif(parent_lat >= max_lat): # it's worse than the pareto points
            print('case 2: selected the slowest')
            parent_pareto = pareto_points.iloc[-2] # other parent is the second from the last
        else:
            print('case 3: selected a middle one')
            if(parent_lat in list(latency)): # in this case rank-1 will be the point it self
                print('selected does have pareto_latency')
                upper = pareto_points.iloc[rank] # neighboring point on the frontier with higher latency
                lower = pareto_points.iloc[rank-2] # neighboring point on the frontier with lower latency
            else:
                print('selected does not have pareto_latency')
                upper = pareto_points.iloc[rank-1] # neighboring point on the frontier with higher latency
                lower = pareto_points.iloc[rank-2] # neighboring point on the frontier with lower latency
            parent_pareto = random.choice([upper, lower])
        
        # parent_rand is a DF, parent pareto is a series
        parents = parent_rand.append(parent_pareto)

        for j in range(n_offsprings):
            _, offspring_parameters = crossover.generate_directives(out_file_path=None, 
                                                                    no_partitioning=no_partitioning, 
                                                                    context=parents)
            offspring_perf,_ = predict_perf(offspring_parameters, models, feature_columns)
            list_params.append(offspring_parameters)
            list_probs.append(pareto.getProbabilityOfEval(offspring_perf, pareto_frontier, threshold=threshold))

            _, mutant_parameters = mutator.generate_directives(out_file_path=None, 
                                                        no_partitioning=no_partitioning, 
                                                        context=(offspring_parameters, importances))
            mutant_perf,_ = predict_perf(mutant_parameters, models, feature_columns)
            list_params.append(mutant_parameters)
            list_probs.append(pareto.getProbabilityOfEval(mutant_perf, pareto_frontier, threshold=threshold))
            
    for i in range(1, len(list_params)+1):
        best = np.argsort(list_probs)[-i]
        proba_eval = list_probs[best]
        parameters = list_params[best]
        if (get_row(dataset, parameters).empty): 
            break
    return parameters, proba_eval

def mutProposal(no_partitioning, importances, gamma, dataset, feature_columns, models, mutator, pareto_frontier, n_mutants=3, threshold=1.2, exclude_infeasible=True):
    pareto_set = getPopulation(dataset, threshold=1.0, exclude_infeasible=exclude_infeasible)
    
    # select only 1 point for each unique latency randomly
    unique_latencies = pareto_set['latency'].unique()
    unique_pareto_points_idx = []
    for lat in unique_latencies:
        eq_lat_points = pareto_set[pareto_set['latency'] == lat]
        rand_idx = random.randint(0, len(eq_lat_points)-1)
        selected = eq_lat_points.index[rand_idx]
        unique_pareto_points_idx.append(selected)
    pareto_points = pareto_set.loc[unique_pareto_points_idx]

    rand_idx = random.randint(0, len(pareto_points)-1)
    _, mutant_parameters = mutator.generate_directives(out_file_path=None, 
                                            no_partitioning=no_partitioning, 
                                            context=(pareto_points.iloc[rand_idx], importances))
    mutant_perf,_ = predict_perf(mutant_parameters, models, feature_columns)
    prob_eval = pareto.getProbabilityOfEval(mutant_perf, pareto_frontier, threshold=threshold)
    return mutant_parameters, prob_eval

def update_models(models, dataset):
    regr_lat, regr_dsp, regr_ff, regr_lut, regr_bram, clss_timeout = models
    
    # extract features and labels from the feature set
    feature_columns = dataset.columns[:len(dataset.columns)-7]
    label_columns = dataset.columns[len(dataset.columns)-7:]
    features = dataset[feature_columns].to_numpy()
    labels = dataset[label_columns].to_numpy()
    features_encoded = preprocessing(features, feature_columns)

    # first determine the fesibility and timeout 
    timeout= labels[:,-1].astype('bool')

    lat = labels[:, 0]
    dsp_perc = labels[:, 1]
    ff_perc = labels[:, 2]
    lut_perc = labels[:, 3]
    bram_perc = labels[:, 4]

    not_timeout = np.logical_not(labels[:,-1].astype('bool'))
    
    # Notice that the regressions are trained only on points that do not timeout
    # Otherwise, these points will disturb the prediction 
    regr_lat.fit(features_encoded[not_timeout], lat[not_timeout])
    regr_dsp.fit(features_encoded[not_timeout], dsp_perc[not_timeout])
    regr_ff.fit(features_encoded[not_timeout], ff_perc[not_timeout])
    regr_lut.fit(features_encoded[not_timeout], lut_perc[not_timeout])
    regr_bram.fit(features_encoded[not_timeout], bram_perc[not_timeout])
    
    # timeout prediction will be trained on all points
    clss_timeout.fit(features_encoded, timeout)

def get_row(df, row):
    if len(df) == 0:
        # return empty if input is empty
        return pd.DataFrame()
    else:
        srs = pd.Series(np.full(len(df), True))
        for col in row.keys():
            val = row[col]
            srs = srs & (df[col] == val)
        return df[srs]
    
def getPopulation(dataset, threshold=1.05, exclude_infeasible=True):
    pareto_frontier = pareto.getParetoFrontier(dataset, exclude_infeasible=exclude_infeasible)
    population = pd.DataFrame(columns=dataset.columns)
    for i,row in enumerate(dataset.iloc):
        is_near_optimal = pareto.checkParetoOptimal(row, pareto_frontier, threshold)
        # 3/8 add this, since in some cases infeasible points can also provide useful information
        if exclude_infeasible:
            is_feasible = row.is_feasible
        else:
            is_feasible = True
        is_error = row.is_error
        if(is_near_optimal and is_feasible and (not is_error)):
            population = population.append(row)
    return population


def importanceAnalysis(models, dataset, regr_lat, weights=[1, 0.4, 0.1, 0.1, 0.4]):
    columns = dataset.columns[:-7]
    importances_raw = np.zeros_like(regr_lat.feature_importances_)
    
    for i, regr in enumerate(models):
        importances_raw = importances_raw + regr.feature_importances_ * weights[i]

    #get importance of encoded data
    importances_raw_named = {}
    pos = 0
    for i,variable_name in enumerate(columns):
        if (re.match('^loop_.+_type$' ,variable_name)):
            importances_raw_named[variable_name+'_pipeline'] = importances_raw[pos+0]
            importances_raw_named[variable_name+'_unroll'] = importances_raw[pos+1]
            importances_raw_named[variable_name+'_none'] = importances_raw[pos+2]
            pos = pos + 3
        elif (re.match('^loop_.+_factor$' ,variable_name)):
            importances_raw_named[variable_name] = importances_raw[pos+0]
            pos = pos + 1
        elif (re.match('^array_.+_type$' ,variable_name)):
            importances_raw_named[variable_name+'_cyclic'] = importances_raw[pos+0]
            importances_raw_named[variable_name+'_block'] = importances_raw[pos+1]
            importances_raw_named[variable_name+'_complete'] = importances_raw[pos+2]
            importances_raw_named[variable_name+'_none'] = importances_raw[pos+3]
            pos = pos + 4
        elif (re.match('^array_.+_factor$' ,variable_name)):
            importances_raw_named[variable_name] = importances_raw[pos+0]
            pos = pos + 1

    #get importance of cleaned data
    importances = {}
    pos = 0
    for i,variable_name in enumerate(columns):
        if (re.match('^loop_.+_type$' ,variable_name)):
            importances[variable_name] = np.sum(importances_raw[pos:pos+3])/np.sum(weights)
            pos = pos + 3
        elif (re.match('^loop_.+_factor$' ,variable_name)):
            importances[variable_name] = np.sum(importances_raw[pos:pos+1])/np.sum(weights)
            pos = pos + 1
        elif (re.match('^array_.+_type$' ,variable_name)):
            importances[variable_name] = np.sum(importances_raw[pos:pos+4])/np.sum(weights)
            pos = pos + 4
        elif (re.match('^array_.+_factor$' ,variable_name)):
            importances[variable_name] = np.sum(importances_raw[pos:pos+1])/np.sum(weights)
            pos = pos + 1

    return importances_raw_named, importances

def normalize_importance(importances):
    
    adjusted_importances = importances.copy()
    params = importances.keys()
 
    raw_importance_val = np.array([])
    
    for param in params:
        raw_importance_val = np.append(raw_importance_val, float(importances[param]))

    norm = np.linalg.norm(raw_importance_val)
    normed_importance_val = raw_importance_val / norm

    for i, param in enumerate(params):
        adjusted_importances.update({param: normed_importance_val[i]})

    return adjusted_importances


def DSE_searching(dataset, models, total_steps, top_function, part, parameter_file, directives_path, template_path, \
                                                                dir_gen, crossover, mutator, writer, feature_columns):

    no_partitioning = False    
    [regr_lat, regr_dsp, regr_ff, regr_lut, regr_bram, clss_timeout] = models

    ESCAPE_THRESHOLD = 1000 # after 1000 failed attempt to get a point worth evaluating, escape
    N_OFFSPRING = 20

    pareto_frontier = pareto.getParetoFrontier(dataset, exclude_infeasible=True)
    step = 4

    method_records = []

    # define a global step for easier management
    while True:
        print('Globa step: '+str(step))

        # select a point proposal method based on beta distribution
        method = selectMethod(method_records, view_boundary=30)

        if method == 'rand':
            print('Method: Random')
        elif method == 'evo':
            print('Method: Evolution')
        elif method == 'mut':
            print('Method: Mutation')
        else:
            raise(AssertionError('Unknown proposing method'))

        # gamma value go from 1 to 0
        gamma = min(1 - step / (100), 1)
        print('Gamma: '+str(gamma))

        # importance analyis
        encoded_importance, importances = importanceAnalysis([regr_lat, regr_dsp, regr_ff, regr_lut, regr_bram], dataset,  regr_lat)

        # adjust the importances for better exploration
        normalize_importances = normalize_importance(importances)

        # set a counter to detect if we are stuck and cannot find a good value
        escape_count = 0

        while (True):
            '''generate a new design point'''
            if method == 'rand':
                parameters = randProposal(directives_path, no_partitioning, dir_gen)

                # make predictions on the performance
                predicted_perf, _ = predict_perf(parameters, models, feature_columns)

                # calculate the probability of evaluating the point, based on it's quality (how close it is to the Pareto curve)
                # 1.5 seems to be a good value, however, 1.5 is also quite wide
                proba_eval = pareto.getProbabilityOfEval(predicted_perf, pareto_frontier, threshold=1.5)
            elif method == 'evo':
                parameters, proba_eval = evoProposal(no_partitioning, normalize_importances, gamma, dataset, feature_columns, models, crossover, mutator, pareto_frontier)
            elif method == 'mut':
                parameters, proba_eval = mutProposal(no_partitioning, normalize_importances, gamma, dataset, feature_columns, models, mutator, pareto_frontier)
            else:
                raise(AssertionError, 'None method selected')

            # make predictions on the performance
            predicted_perf, proba_timeout = predict_perf(parameters, models, feature_columns)

            # increment the escape count
            escape_count = escape_count + 1

            random_val = np.random.rand(1)[0]
            proba_total = proba_eval*proba_timeout
            print(predicted_perf)
            print('Design:')
            print(parameters)
            print('random value:'+str(random_val))
            print('probability from pareto: '+str(proba_eval))
            print('probability from timeout:'+str(proba_timeout))
            print('total probability of evaluation:'+str(proba_total))

            # todo: implement with simulated annealing
            if ((proba_timeout < 0.8) and (proba_eval > 0.1)
                and get_row(dataset, parameters).empty) \
                or escape_count > 20:
                    if(escape_count > 20): 
                        print('escape!!')
                    else: 
                        print('New design point found.')
                    break

        print(parameters)
        # output the directives
        writer.generate_directives(out_file_path=directives_path, no_partitioning=no_partitioning,context=parameters)

        # evaluate the design point
        project_ident = str(int(time.time()))+'_'+str(random.getrandbits(16))
        new_design_point = run_hls.get_perf(template_path, 
                                    directives_path, 
                                    top_function, 
                                    part, 
                                    parameters,
                                    project_ident,
                                    verbose=False,
                                    timelimit=800)

        print(new_design_point)

        is_pareto_optimal = pareto.checkParetoOptimal(new_design_point, pareto_frontier, threshold=1.0)
        
        # check if it's already an existing cost+latency combination
        # if so it's not pareto optimal, this will eliminate some bias on mutation and evo
        # gives random more space 
        latency = new_design_point['latency']
        cost = 0.4*new_design_point['dsp_perc'] \
            +0.1*new_design_point['ff_perc'] \
            +0.1*new_design_point['lut_perc'] \
            +0.4*new_design_point['bram_perc']
        existing_point = pareto_frontier[(pareto_frontier['latency'] == latency) & (pareto_frontier['cost'] == cost)]
        if (len(existing_point) != 0):
            print('Existing pareto point!')
            is_pareto_optimal = False
        
        if(is_pareto_optimal):
            method_records.append((method, 1))
            print('//////////////////////////////////////////////////////')
            print('!!!!!!!!!!!!!!!Success: New Pareto Point!!!!!!!!!!!!!!')
            print('//////////////////////////////////////////////////////')
        else:
            method_records.append((method, 0))
            print('//////////////////////////////////////////////////////')
            print('$$$$$$$$$$$$$$$Fail: BAD BAD BAD Point$$$$$$$$$$$$$$$$')
            print('//////////////////////////////////////////////////////')

        # add the evaluated design point to current dataset
        dataset = dataset.append(new_design_point, ignore_index=True)

        # update pareto frontier after getting a new point
        pareto_frontier = pareto.getParetoFrontier(dataset, exclude_infeasible=True)
        print('New Pareto Frontier:')
        print(pareto_frontier)

        # save data instantly for easier test running
        dataset.to_csv('DSE_out.csv')
        pareto_frontier.to_csv('DSE_out_pareto.csv')
        

        # increment the global step
        step = step + 1

        # train the models
        update_models(models, dataset)
        
        with open('DSE_method_records.pickle', 'wb') as f:
            pickle.dump(method_records, f)

        # break if needed
        if step >= total_steps: break



def DSE_start(dataset, total_steps, top_function, part, feature_columns):

    parameter_file = 'generated_files/ML_params.csv'
    directives_path = 'generated_files/ML_directive'
    template_path = 'generated_files/ML_template.txt'

    dir_gen = generate_directives.RandomDirectiveGenerator(parameter_file)
    crossover = generate_directives.DirectiveCrossover(parameter_file)
    mutator = generate_directives.DirectiveMutator(parameter_file)
    writer = generate_directives.DirectiveWriter(parameter_file)    

    regr_lat = RandomForestRegressor(random_state=42)
    regr_dsp = RandomForestRegressor(random_state=42)
    regr_ff = RandomForestRegressor(random_state=42)
    regr_lut = RandomForestRegressor(random_state=42)
    regr_bram = RandomForestRegressor(random_state=42)
    clss_timeout = RandomForestClassifier(random_state=42)
    models = [regr_lat, regr_dsp, regr_ff, regr_lut, regr_bram, clss_timeout]

    update_models(models, dataset)

    DSE_searching(dataset, models, total_steps, top_function, part, parameter_file, directives_path, template_path, dir_gen, crossover, mutator, writer, feature_columns)
    

