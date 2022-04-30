import subprocess
import xmltodict
import shutil
import time
import logging
import psutil, os # psutil used to kill the whole process tree of HLS
from jinja2 import Template
import re
import pandas as pd
import random

# run Jinja2 renderer to creat the tcl scripts
def generate_script(script_path, template_path, template_params):
    template = Template(open(template_path,'r').read())
    script_string = template.render(**template_params)
    open(script_path,'w').write(script_string)
    return
    
# this is borrowed from psutil's author's answer on stackoverflow
def kill_proc_tree(pid, including_parent=False):    
    parent = psutil.Process(pid)
    children = parent.children(recursive=True)
    for child in children:
        child.kill()
    gone, still_alive = psutil.wait_procs(children, timeout=5)
    if including_parent:
        parent.kill()
        parent.wait(5)
        
def parse_cosim_report(report_path):
    latency = None
    with open(report_path, 'r') as file:
        for line in file:
            if(re.findall('Verilog', line)): # if we can find the line for cosim result
                results = line.replace(' ','').split('|')[2:6]
                if (results[0] == 'Pass'): # if the cosim passed
                    latency = results[2]
    return latency

def parse_synth_report(report_path):
    with open(report_path) as fd:
        # read the report in xml format
        doc = xmltodict.parse(fd.read())

        # old implementation, using number of cycles only
        #avg_latency = int(doc['profile']['PerformanceEstimates']['SummaryOfOverallLatency']['Average-caseLatency'])

        # parse the result to find the percentage usage of the resources
        dsp = int(doc['profile']['AreaEstimates']['Resources']['DSP48E'])
        ff = int(doc['profile']['AreaEstimates']['Resources']['FF'])
        lut = int(doc['profile']['AreaEstimates']['Resources']['LUT'])
        bram = int(doc['profile']['AreaEstimates']['Resources']['BRAM_18K'])

        dsp_avail = int(doc['profile']['AreaEstimates']['AvailableResources']['DSP48E'])
        ff_avail = int(doc['profile']['AreaEstimates']['AvailableResources']['FF'])
        lut_avail = int(doc['profile']['AreaEstimates']['AvailableResources']['LUT'])
        bram_avail = int(doc['profile']['AreaEstimates']['AvailableResources']['BRAM_18K'])

        dsp_perc = dsp / dsp_avail
        ff_perc = ff / ff_avail
        lut_perc = lut / lut_avail
        bram_perc = bram / bram_avail

        # extract the estimated period/frequency, for now, we assume the unit is always ns
        period = float(doc['profile']['PerformanceEstimates']['SummaryOfTimingAnalysis']['EstimatedClockPeriod'])

        # parse the report to find the latency
        # new implementation, using the real-time latency
        result = doc['profile']['PerformanceEstimates']['SummaryOfOverallLatency']['Worst-caseRealTimeLatency'].split()
        # result = doc['profile']['PerformanceEstimates']['SummaryOfOverallLatency']['Worst-caseRealTimeLatency'].split()
        avg_latency = result[0]

        # check if the synth was able to determine the latency, if not, we should run the cosim
        if(avg_latency == 'undef'):
            return None, period, dsp_perc, ff_perc, lut_perc, bram_perc # if it is undef, then synth cannot estimate the latency
        else:
            unit = result[1]
            if unit == 'ms':
                avg_latency = float(avg_latency)*1000
            elif unit == 'sec':
                avg_latency = float(avg_latency)*1000000
            else:
                avg_latency = float(avg_latency)
        return avg_latency, period, dsp_perc, ff_perc, lut_perc, bram_perc # this is the normal case return
    return None # catch the defualt case
        
def execute_hls(script_path, verbose=False, timelimit=300):
    # invoke the HLS program
    process = subprocess.Popen(['/tools/Xilinx/Vivado/2019.2/bin/vivado_hls','-f', script_path], shell=False, stdout=subprocess.PIPE)
    start = time.perf_counter()
    
    # monitor the output from HLS check for timeout
    if verbose:
        # to monitor the output from Vivado HLS
        # notice that the timeout doesn't work in this case
        while True:
            output = process.stdout.readline()
            if process.poll() is not None:
                break
            if output:
                print(output.decode('utf-8').strip())
    else:
        # this is silent mode, but the timeout works in this case
        try:
            output, error = process.communicate(timeout=timelimit)
            #print(output.decode('utf-8').strip())
        except subprocess.TimeoutExpired:
            kill_proc_tree(process.pid)
            #process.terminate()
    
    # calculate and record the total time used for HLS
    time_elapsed = time.perf_counter() - start
    if time_elapsed >= timelimit:
        print('HLS time elapsed: {0}/{1}'.format(time_elapsed, timelimit))
        return True
    else:
        return False

def get_perf (template_path, directives_path, top_function, part, parameters, project_ident, verbose=False, timelimit=500):
    # print("Hey Vivado")
    
    project_name = top_function+'_'+project_ident
    script_path = os.path.join(project_name+'.tcl')

    # 2: generate a new script using Jinja for synthesis
    template_params = {
        'project_name':project_name,
        'directives_path':directives_path,
        'top_function':top_function,
        'part':part,
        'synth':True,
        'cosim':False
    }
    generate_script(script_path, template_path, template_params)

    # 3: run HLS for synthesis
    is_error = execute_hls(project_name+'.tcl', verbose=verbose, timelimit=timelimit)
    if is_error:
        print('HLS Synthesis Error.')

    # 4: check the synth report, if not exist or HLS timeout, directly return
    solution_path = os.path.join(project_name, 'solution1')
    report_path = os.path.join(solution_path, 'syn', 'report', top_function+'_csynth.xml')
    is_feasible = False # this is the default case, if anything failed it is definitely not feasible
    if os.path.exists(report_path) and not is_error: # check if the file exists, also if it timed out

        # if the report exists, parse it
        avg_latency, period, dsp_perc, ff_perc, lut_perc, bram_perc = parse_synth_report(report_path)

        # set is_feasible to false if we blow up the resource limit
        if (dsp_perc > 1.0) or (ff_perc > 1.0) or (lut_perc > 1.0) or (bram_perc > 1.0):
            is_feasible = False
        else:
            is_feasible = True
        
        # 5: if synth finished but latency cannot be determined, generate script for cosim
        if avg_latency == None:
            print('Latency undefined from synthesis report, launching cosim')

            # 6: generate script for C-RTL co-simulation
            template_params.update({'synth':False, 'cosim':True}) # flip the switch for cosim
            generate_script(script_path, template_path, template_params)

            # 6: run cosim 
            is_error = execute_hls(script_path, verbose=verbose, timelimit=timelimit)
            if is_error:
                print('HLS Co-sim Error.')
            
            # 7: parse the cosim report and determine the final latency then return
            report_path = os.path.join(solution_path, 'sim', 'report', 'rendering_cosim.rpt')
            if os.path.exists(report_path) and not is_error: # check if the file exists, also if it timed out
                # latency is number of cycles * period, we divide by 1000 because the period is in ns
                cycles = parse_cosim_report(report_path)
                if cycles == None: # if something went wrong, like cosim didn't pass
                    avg_latency = float('inf')
                    raise(AssertionError, 'Co-sim failed, check code correctness')
                else:
                    avg_latency = (float(cycles) * period)/1000.0
            else: # if it does not exist, then the cosim must have failed, we should return infinity
                print('Cannot find cosim report')
                avg_latency = float('inf')
                is_error = True

    else: # if it does not exist, then the synth must have failed
        print('Cannot find synthesis report')
        avg_latency, period, dsp_perc, ff_perc, lut_perc, bram_perc = float('inf'),float('inf'),1,1,1,1
        is_error = True
    
    # if avg_latency > 100000 and avg_latency < float('inf'):
    #     try:
    #         os.rename(project_name, "Error_file" + project_name)
    #     except OSError as e:
    #         print("Error rname")
        
    #     # remove the tcl file
    #     try:
    #         os.rename(script_path, "Error_script" + project_name)
    #     except OSError as e:
    #         print("Error rname")
    # else:
    # remove the directory
    try:
        shutil.rmtree(project_name)
    except OSError as e:
        print("Error: %s : %s" % (os.dir_path, e.strerror))
    
    # remove the tcl file
    try:
        os.remove(script_path)
    except OSError as e:
        print("Error: %s : %s" % (os.file_path, e.strerror))
       

    # remove the log file // if enabled conflict with multiprocessor 
    # try:
    #     os.remove("vivado_hls.log")
    # except OSError as e:
    #     print("Error: %s : %s" % (os.file_path, e.strerror))
    
    # put the data into the dictionary to be converted to a dataframe (with a single row)
    parameters.update({'latency':avg_latency, 
                       'dsp_perc':dsp_perc, 
                       'ff_perc':ff_perc, 
                       'lut_perc':lut_perc, 
                       'bram_perc':bram_perc,
                       'is_feasible':is_feasible,
                       'is_error':is_error})
                       
    return parameters