#!/usr/bin/env python
# coding: utf-8

from pycparser import parse_file, c_generator
from pycparser import c_ast
import pandas as pd
import numpy as np
import random

class DirectiveGenerator():
    def __init__(self, in_file_path):
        self.tunable_params = pd.read_csv(in_file_path)
        self.partition_schemes = {} # store the partitioning scheme of each array to them consistent

    def generate_directives(self, out_file_path=None, no_partitioning=False, context=None):
        # reinitialize the buffers every time we call this
        self.directives = [] # the list of directives to be written to the tcl script
        self.parameters = {} # the parameters to be stored in the training dataset 
        self.partition_schemes.clear() # reset the partitioning scheme
        
        #print(self.tunable_params)

        for i in range(len(self.tunable_params)):
            knob = self.tunable_params.iloc[i]
            boundary = knob.range

            #print(boundary)

            # check the it we need to skip partitioning
            # some times HLS will take a long time if partitioning is not done right
            if (knob.type == 'array') and (no_partitioning):
                pass
            else:
                directive, parameter = self.gen_single_dir(knob, context=context)

                # add the directive and parameter to the list/dict
                self.directives.append(directive)
                self.parameters.update(parameter)

        # if there's no output file, then don't write the tcl file
        if out_file_path is not None:
            with open(out_file_path, 'w') as file:
                file.write('\n'.join(self.directives))
        return self.directives, self.parameters

    def gen_single_dir(self, knob, context=None):
        ''' Stub return empty string'''
        print("was here")
        return ''

# class InitialDirectiveGenerator(DirectiveGenerator):
# a working process /////////////////////////////
# ///////////////////////////////////////////    
#     print("test")



class RandomDirectiveGenerator(DirectiveGenerator):
    def gen_single_dir(self, knob, context=None, clear_partition_scheme=False):
        directives_list = [] # list of components of a directive, to be combined to a string and export to a tcl file
        parameters_dict = {} # dictionary of parameters for this directive, to be converted to a pandas dataframe
        if clear_partition_scheme: # for mutation, we want a purely randomly generated, so enable this in that case
            self.partition_schemes.clear() # reset the partitioning scheme
        
        if (knob.type == 'loop'): # if the type of the tunable knob (directive) is a loop
            # Step 1: check the loop boundary -- if it is fixed or not
            boundary = knob['range']
            if (boundary != 'Variable'):
                boundary = int(boundary)
                if (boundary > 256): # if the boundary > 256, we treat it as variable loops
                                     # because unrolling is likely to cause big problems
                    boundary = 'Variable'
                
            # Step 2: pick a loop pragma scheme, depending on the boundary type
            if (boundary == 'Variable'): # for vairable boundary we do not consider the unrolling
                scheme = random.choice(['pipeline','none'])
            else: # for fixed boundary, all options are available
                scheme = random.choice(['pipeline','unroll','none'])
            
            # Step 3: generate the first part of the pragma, and add to the list of parameters
            pragma = 'set_directive_'+scheme
            directives_list.append(pragma)
            parameters_dict['loop_'+knob['name']+'_type'] = scheme
            
            # Step 4: generate the loop factor for the unrolling factor if needed
            factor = 2 # default case, fail safe
            if (scheme == 'unroll'):
                raw_divisors = []
                #get divisors
                for i in range(1, boundary + 1):
                    if boundary % i == 0:
                        raw_divisors.append(i)
                #remove 1 / minimum factor should be 2, required by HLS
                raw_divisors.remove(1)
                #do not partion past 256
                divisors = []
                for d in raw_divisors:
                    if d <= 256:
                        divisors.append(d)
                # print(divisors)

                factor = divisors[random.randrange(0, len(divisors))]

                directives_list.append('-factor '+str(factor))
                parameters_dict['loop_'+knob['name']+'_factor'] = factor
            else: # if not unroll then we set this factor to 0 for safety and debugging purpose
                parameters_dict['loop_'+knob['name']+'_factor'] = 0

            # Step 5: add the loop label to the pragma
            loop_label = '{0}/{1}'.format(knob['scope'], knob['name'])
            directives_list.append(loop_label)
            
            # Step 6: if choose to not have the pragma ('none') then empty the directives_list
            if (scheme == 'none'):
                directives_list = []

        elif (knob.type == 'loopU'):
            # Step 1: check the loop boundary -- if it is fixed or not
            boundary = knob['range']
            if (boundary != 'Variable'):
                boundary = int(boundary)
                if (boundary > 256): # if the boundary > 256, we treat it as variable loops
                                     # because unrolling is likely to cause big problems
                    boundary = 'Variable'
                
            # Step 2: pick a loop pragma scheme, depending on the boundary type
            if (boundary == 'Variable'): # for vairable boundary we do not consider the unrolling
                scheme = random.choice(['none'])
            else: # for fixed boundary, all options are available
                scheme = random.choice(['unroll','none'])
            
            # Step 3: generate the first part of the pragma, and add to the list of parameters
            pragma = 'set_directive_'+scheme
            directives_list.append(pragma)
            parameters_dict['loop_'+knob['name']+'_type'] = scheme
            
            # Step 4: generate the loop factor for the unrolling factor if needed
            factor = 2 # default case, fail safe
            if (scheme == 'unroll'):
                factor = random.randrange(2, min(boundary+1, 256)) # unrolling with factor 1 effectively is 'none'
                # pick a divisible unrolling factor
                # this is not required by HLS, but good practice in general
                # also reduces the possible options
                while (boundary % factor != 0): # limit the factor to 256, larger factor is useless in most cases anyway
                    factor = random.randrange(2, min(boundary+1, 256))
                directives_list.append('-factor '+str(factor))
                parameters_dict['loop_'+knob['name']+'_factor'] = factor
            else: # if not unroll then we set this factor to 0 for safety and debugging purpose
                parameters_dict['loop_'+knob['name']+'_factor'] = 0

            # Step 5: add the loop label to the pragma
            loop_label = '{0}/{1}'.format(knob['scope'], knob['name'])
            directives_list.append(loop_label)
            
            # Step 6: if choose to not have the pragma ('none') then empty the directives_list
            if (scheme == 'none'):
                directives_list = []
            
        elif (knob.type == 'array'): # if the type of the tunable knob (directive) is an array
            boundary = int(knob['range'])
            dim = int(knob['dim'])
            pragma='set_directive_array_partition'
            variable = '{0} {1}'.format(knob['scope'], knob['name'])
            factor = 2 # default case, just for fail safe

            if (boundary <= 32) and (dim == 0): # if dimension is small we go ahead and directly partition them
                available_schemes = ['complete']
            elif (boundary <= 256):
                available_schemes = ['none','cyclic','block','complete']
            else: # if boundary is over 256 there's almost no point to do complete partition
                available_schemes = ['none', 'cyclic', 'block']
            
            # to ensure that the partitioning scheme is consistent for an array
            # check if there is already a partitioning scheme picked for this array
            # if so, just use the same factor or no optimization
            if(variable not in self.partition_schemes.keys()):
                partition_scheme = random.choice(available_schemes)
                if (partition_scheme != 'none'): # if it's none then don't add the scheme to the dict
                    self.partition_schemes[variable] = partition_scheme
            else:
                prev_scheme = self.partition_schemes[variable]
                partition_scheme = random.choice(['none', prev_scheme])
                if (prev_scheme not in available_schemes): # catch the case when prev is complete and this dimension is more than 1024
                    partition_scheme = 'none'
            # only generate the partitioning directives when it's not 'none'
            parameters_dict['array_'+knob['name']+'_'+knob['scope']+'_dim'+str(int(dim))+'_type'] = partition_scheme
            if partition_scheme != 'none':
                # store the partition scheme to the list and dict
                directives_list = directives_list+[pragma, '-type '+partition_scheme]    
         
                if partition_scheme != 'complete':
                    raw_divisors = []
                    #get divisors
                    for i in range(1, boundary + 1):
                        if boundary % i == 0:
                            raw_divisors.append(i)
                    #remove 1 / minimum factor should be 2, required by HLS
                    raw_divisors.remove(1)
                    #do not partions past 256
                    divisors = []
                    for d in raw_divisors:
                        if d <= 256:
                            divisors.append(d)
                    # print(divisors)
                                        
                    factor = divisors[random.randrange(0, len(divisors))]

                    # dimensions start with 1 if we want to control the dimensions separately
                    directives_list = directives_list+['-factor '+str(factor), '-dim '+str(dim)] 
                else:
                    # if partitioning scheme is complete then we should set the factor to 0
                    directives_list = directives_list+['-dim '+str(dim)]
                    factor = 0

                # need to add a list like [factor] because pandas requires this to append a new row to existing dataframe
                directives_list.append(variable)
                parameters_dict['array_'+knob['name']+'_'+knob['scope']+'_dim'+str(int(dim))+'_factor'] = factor
            else: # if it is none, i.e. do not partition the array
                parameters_dict['array_'+knob['name']+'_'+knob['scope']+'_dim'+str(int(dim))+'_factor'] = 0 # set the factor to 0 for safety
        else:
            raise AssertionError('Invalid knob type')
            
        return ' '.join(directives_list), parameters_dict

class DirectiveCrossover(DirectiveGenerator):
    def __init__(self, in_file_path):
        super().__init__(in_file_path)
        
    # the context here is the set of parameters to be legalized
    def gen_single_dir(self, knob, context=None):
        parent = random.choice([context.iloc[0], context.iloc[1]]) # equal chance of selecting the parents

        directives_list = [] # list of components of a directive, to be combined to a string and export to a tcl file
        parameters_dict = {} # dictionary of parameters for this directive, to be converted to a pandas dataframe
        
        if (knob.type == 'loop' or knob.type == 'loopU'): # if the type of the tunable knob (directive) is a loop
            # Step 1: check the loop boundary -- if it is fixed or not
            # skip, since both parents of the current set will be legal
                
            # Step 2: pick a loop pragma scheme, depending on the boundary type
            # skip, since both parents of the current set will be legal
            
            # Step 3: generate the first part of the pragma, and add to the list of parameters
            # copy from the parameters dict
            scheme = parent['loop_'+knob['name']+'_type']
            pragma = 'set_directive_'+scheme
            directives_list.append(pragma)
            parameters_dict['loop_'+knob['name']+'_type'] = scheme
            
            # Step 4: generate the loop factor for the unrolling factor if needed
            factor = parent['loop_'+knob['name']+'_factor']
            if (scheme == 'unroll'):
                # if the scheme is unroll then keep the factor
                directives_list.append('-factor '+str(factor))
                parameters_dict['loop_'+knob['name']+'_factor'] = factor
            else: # if not unroll then we set this factor to 0 for safety and debugging purpose
                parameters_dict['loop_'+knob['name']+'_factor'] = 0

            # Step 5: add the loop label to the pragma
            loop_label = '{0}/{1}'.format(knob['scope'], knob['name'])
            directives_list.append(loop_label)
            
            # Step 6: if choose to not have the pragma ('none') then empty the directives_list
            if (scheme == 'none'):
                directives_list = []
            
        elif (knob.type == 'array'): # if the type of the tunable knob (directive) is an array
            boundary = int(knob['range'])
            dim = int(knob['dim'])
            pragma='set_directive_array_partition'
            variable = '{0} {1}'.format(knob['scope'], knob['name'])
            factor = 2 # default case, just for fail safe

            if (boundary <= 256):
                available_schemes = ['none','cyclic','block','complete']
            else:
                available_schemes = ['none', 'cyclic', 'block']
            
            # to ensure that the partitioning scheme is consistent for an array
            # check if there is already a partitioning scheme picked for this array
            # if so, just use the same factor
            if(variable not in self.partition_schemes.keys()):
                partition_scheme = parent['array_'+knob['name']+'_'+knob['scope']+'_dim'+str(int(dim))+'_type']
                if (partition_scheme != 'none'): # if it's none then don't add the scheme to the dict
                    self.partition_schemes[variable] = partition_scheme
            else:
                # if other dimensions has choose the scheme, but parent is none, we can still choose the parent
                if (parent['array_'+knob['name']+'_'+knob['scope']+'_dim'+str(int(dim))+'_type'] == 'none'):
                    partition_scheme = parent['array_'+knob['name']+'_'+knob['scope']+'_dim'+str(int(dim))+'_type']
                else: # else follow the previous scheme
                    partition_scheme = self.partition_schemes[variable]
                    
                if (partition_scheme not in available_schemes): # catch the case when prev is complete and is not available for this dim
                    partition_scheme = 'none'
            
            # only generate the partitioning directives when it's not 'none'
            parameters_dict['array_'+knob['name']+'_'+knob['scope']+'_dim'+str(int(dim))+'_type'] = partition_scheme
            if partition_scheme != 'none':
                # store the partition scheme to the list and dict
                directives_list = directives_list+[pragma, '-type '+partition_scheme]    
         
                if partition_scheme != 'complete':
                    # get the factor from input parameters
                    factor = parent['array_'+knob['name']+'_'+knob['scope']+'_dim'+str(int(dim))+'_factor']

                    # incases that we take the scheme from one side, and factor from other and the factor is 0
                    # then we need to reroll the factor
                    if (factor == 0):
                        factor = random.randrange(2, min(boundary+1, 256))
                        while (boundary % factor != 0):
                            factor = random.randrange(2, min(boundary+1, 256))
                    
                    # dimensions start with 1 if we want to control the dimensions separately
                    directives_list = directives_list+['-factor '+str(factor), '-dim '+str(dim)]
                else:
                    # if partitioning scheme is complete then we should set the factor to 0
                    directives_list = directives_list+['-dim '+str(dim)]
                    factor = 0

                # need to add a list like [factor] because pandas requires this to append a new row to existing dataframe
                directives_list.append(variable)
                parameters_dict['array_'+knob['name']+'_'+knob['scope']+'_dim'+str(int(dim))+'_factor'] = factor
            else: # if it is none, i.e. do not partition the array
                parameters_dict['array_'+knob['name']+'_'+knob['scope']+'_dim'+str(int(dim))+'_factor'] = 0 # set the factor to 0 for safety
        else:
            raise AssertionError('Invalid knob type')
            
        return ' '.join(directives_list), parameters_dict
    
class DirectiveMutator(DirectiveGenerator):
    def __init__(self, in_file_path):
        super().__init__(in_file_path)
        self.random_gen = RandomDirectiveGenerator(in_file_path)
        
    # the context here is the set of parameters to be legalized
    def gen_single_dir(self, knob, context=None):
        offspring, importances = context
        _, random_parameters = self.random_gen.gen_single_dir(knob, clear_partition_scheme=True)
        
        boundary = knob['range']
        if (boundary != 'Variable'):
            boundary = int(boundary)
        
        rand_val_type = np.random.random()
        rand_val_factor = np.random.random()

        directives_list = [] # list of components of a directive
        parameters_dict = {} # dictionary of parameters for this directive, to be converted to a pandas dataframe
        
        if (knob.type == 'loop' or knob.type == 'loopU'): # if the type of the tunable knob (directive) is a loop
            importance_type = importances['loop_'+knob['name']+'_type']
            importance_factor = importances['loop_'+knob['name']+'_factor']
                    
            # Step 1: check the loop boundary -- if it is fixed or not
            # skip
                
            # Step 2: pick a loop pragma scheme, depending on the boundary type
            if (rand_val_type < importance_type):
                scheme = random_parameters['loop_'+knob['name']+'_type']
            else:
                scheme = offspring['loop_'+knob['name']+'_type']
            
            # Step 3: generate the first part of the pragma, and add to the list of parameters
            # copy from the parameters dict

            pragma = 'set_directive_'+scheme
            directives_list.append(pragma)
            parameters_dict['loop_'+knob['name']+'_type'] = scheme
            
            # Step 4: generate the loop factor for the unrolling factor if needed
            factor = 1
            if (scheme == 'unroll'):
                # if the scheme is unroll then keep the factor
                if (rand_val_factor < importance_factor):
                    factor = random_parameters['loop_'+knob['name']+'_factor']
                else:
                    factor = offspring['loop_'+knob['name']+'_factor']
                    
                # incases that we take the scheme from one side, and factor from other and the factor is 0
                # then we need to reroll the factor
                if (factor == 0):
                    factor = random.randrange(2, min(boundary+1, 256))
                    while (boundary % factor != 0):
                        factor = random.randrange(2, min(boundary+1, 256))
                        
                directives_list.append('-factor '+str(factor))
                parameters_dict['loop_'+knob['name']+'_factor'] = factor
            else: # if not unroll then we set this factor to 0 for safety and debugging purpose
                parameters_dict['loop_'+knob['name']+'_factor'] = 0

            # Step 5: add the loop label to the pragma
            loop_label = '{0}/{1}'.format(knob['scope'], knob['name'])
            directives_list.append(loop_label)
            
            # Step 6: if choose to not have the pragma ('none') then empty the directives_list
            if (scheme == 'none'):
                directives_list = [] 
            
        elif (knob.type == 'array'): # if the type of the tunable knob (directive) is an array
            boundary = int(knob['range'])
            dim = int(knob['dim'])
            pragma='set_directive_array_partition'
            variable = '{0} {1}'.format(knob['scope'], knob['name'])
            factor = 2 # default case, just for fail safe
            
            if (boundary <= 256):
                available_schemes = ['none','cyclic','block','complete']
            else:
                available_schemes = ['none', 'cyclic', 'block']
            
            importance_type = importances['array_'+knob['name']+'_'+knob['scope']+'_dim'+str(int(dim))+'_type']
            importance_factor = importances['array_'+knob['name']+'_'+knob['scope']+'_dim'+str(int(dim))+'_factor']

            # to ensure that the partitioning scheme is consistent for an array
            # check if there is already a partitioning scheme picked for this array
            # if so, just use the same factor
            if (rand_val_type < importance_type):
                selected_scheme = random_parameters['array_'+knob['name']+'_'+knob['scope']+'_dim'+str(int(dim))+'_type']
            else:
                selected_scheme = offspring['array_'+knob['name']+'_'+knob['scope']+'_dim'+str(int(dim))+'_type']
                
            if(variable not in self.partition_schemes.keys()):
                partition_scheme = selected_scheme
                if (selected_scheme != 'none'): # if it's none then don't add the scheme to the dict
                    self.partition_schemes[variable] = selected_scheme
            else:
                # if other dimensions has choose the scheme, we can still choose none
                if (selected_scheme == 'none'):
                    partition_scheme = selected_scheme
                else: # else follow the previous scheme
                    partition_scheme = self.partition_schemes[variable]
                    
                if (partition_scheme not in available_schemes): # catch the case when prev is complete and is not available for this dim
                    partition_scheme = 'none'
            
            # only generate the partitioning directives when it's not 'none'
            parameters_dict['array_'+knob['name']+'_'+knob['scope']+'_dim'+str(int(dim))+'_type'] = partition_scheme
            if partition_scheme != 'none':
                # store the partition scheme to the list and dict
                directives_list = directives_list+[pragma, '-type '+partition_scheme]    
         
                if partition_scheme != 'complete':
                    # get the factor from input parameters
                    if (rand_val_factor < importance_factor):
                        factor = random_parameters['array_'+knob['name']+'_'+knob['scope']+'_dim'+str(int(dim))+'_factor']
                    else:
                        factor = offspring['array_'+knob['name']+'_'+knob['scope']+'_dim'+str(int(dim))+'_factor']
                        
                    # incases that we take the scheme from one side, and factor from other and the factor is 0
                    # then we need to reroll the factor
                    if (factor == 0):
                        factor = random.randrange(2, min(boundary+1, 256))
                        while (boundary % factor != 0): # hard code a partitioning limit to 256
                            factor = random.randrange(2, min(boundary+1, 256))
                     
                    # dimensions start with 1 if we want to control the dimensions separately
                    directives_list = directives_list+['-factor '+str(factor), '-dim '+str(dim)]
                else:
                    # if partitioning scheme is complete then we should set the factor to 0
                    directives_list = directives_list+['-dim '+str(dim)]
                    factor = 0

                directives_list.append(variable)
                parameters_dict['array_'+knob['name']+'_'+knob['scope']+'_dim'+str(int(dim))+'_factor'] = factor
            else: # if it is none, i.e. do not partition the array
                parameters_dict['array_'+knob['name']+'_'+knob['scope']+'_dim'+str(int(dim))+'_factor'] = 0
        else:
            raise AssertionError('Invalid knob type')
            
        return ' '.join(directives_list), parameters_dict
    
class DirectiveWriter():
    def __init__(self, in_file_path):
        self.tunable_params = pd.read_csv(in_file_path)
        self.partition_schemes = {} # store the partitioning scheme of each array to them consistent
        
    def generate_directives(self, out_file_path=None, no_partitioning=False, context=None):
        # reinitialize the buffer every time we call this
        self.directives = [] # the list of directives to be written to the tcl script
        self.parameters = {} # the parameters to be stored in the training dataset 
        self.partition_schemes.clear() # reset the partitioning scheme
        
        for i in range(len(self.tunable_params)):
            knob = self.tunable_params.iloc[i]
            boundary = knob.range

            # check the it we need to skip partitioning
            # some times HLS will take a long time if partitioning is not done right
            if (knob.type == 'array') and (no_partitioning):
                pass
            else:
                directive, parameter = self.gen_single_dir(knob, context=context)

                # add the directive and parameter to the list/dict
                self.directives.append(directive)
                self.parameters.update(parameter)

        # if there's no output file, then don't write the tcl file
        if out_file_path is not None:
            with open(out_file_path, 'w') as file:
                file.write('\n'.join(self.directives))
        return self.directives, self.parameters

    def gen_single_dir(self, knob, context):
        directives_list = [] # list of components of a directive, to be combined to a string and export to a tcl file
        parameters_dict = {} # dictionary of parameters for this directive, to be converted to a pandas dataframe
        
        if (knob.type == 'loop' or knob.type == 'loopU'): # if the type of the tunable knob (directive) is a loop
            #boundary = int(knob['range'])
            scheme = context['loop_'+knob['name']+'_type']
            pragma = 'set_directive_'+scheme
            directives_list.append(pragma)
            parameters_dict['loop_'+knob['name']+'_type'] = scheme
            
            factor = context['loop_'+knob['name']+'_factor']
            if (scheme == 'unroll'):
                directives_list.append('-factor '+str(factor))
                parameters_dict['loop_'+knob['name']+'_factor'] = factor
            else:
                parameters_dict['loop_'+knob['name']+'_factor'] = 0
            
            loop_label = '{0}/{1}'.format(knob['scope'], knob['name'])
            directives_list.append(loop_label)
            
            if (scheme == 'none'):
                directives_list = [] 
        
        elif (knob.type == 'array'): # if the type of the tunable knob (directive) is an array
            pragma='set_directive_array_partition'
            dim = int(knob['dim'])
            variable = '{0} {1}'.format(knob['scope'], knob['name'])
            factor = context['array_'+knob['name']+'_'+knob['scope']+'_dim'+str(int(dim))+'_factor']
            
            selected_scheme = context['array_'+knob['name']+'_'+knob['scope']+'_dim'+str(int(dim))+'_type']
            if(variable not in self.partition_schemes.keys()):
                partition_scheme = selected_scheme
                if (partition_scheme != 'none'):
                    self.partition_schemes[variable] = partition_scheme
            else:
                if (selected_scheme == 'none'):
                    partition_scheme = selected_scheme
                else:
                    partition_scheme = self.partition_schemes[variable]
            
            # only generate the partitioning directives when it's not 'none'
            parameters_dict['array_'+knob['name']+'_'+knob['scope']+'_dim'+str(int(dim))+'_type'] = partition_scheme
            if partition_scheme != 'none':
                # store the partition scheme to the list and dict
                directives_list = directives_list+[pragma, '-type '+partition_scheme]    

                if partition_scheme != 'complete':
                    # dimensions start with 1 if we want to control the dimensions separately
                    directives_list = directives_list+['-factor '+str(factor), '-dim '+str(dim)]
                else:
                    directives_list = directives_list+['-dim '+str(dim)]
                    factor = 0

                # need to add a list like [factor] because pandas requires this to append a new row to existing dataframe
                directives_list.append(variable)
                parameters_dict['array_'+knob['name']+'_'+knob['scope']+'_dim'+str(int(dim))+'_factor'] = factor
            else: # if it is none, i.e. do not partition the array
                parameters_dict['array_'+knob['name']+'_'+knob['scope']+'_dim'+str(int(dim))+'_factor'] = 0 # set the factor to 0 
        else:
            raise AssertionError('Invalid knob type')
            
        return ' '.join(directives_list), parameters_dict