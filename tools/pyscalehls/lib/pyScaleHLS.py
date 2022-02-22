import os
import shutil
import io
import subprocess
import scalehls
import mlir.ir
from mlir.dialects import builtin
import numpy as np

def opts_menu():
    
    opt_knob = np.array(['none', 'none', 'none', 'none', 'none', 'none'])
    opt_knob_names = np.array(["Auto ScaleHLS", "Loop perfectization", "Optimize loop order", "Optimize loop permutation", "Remove variable bound", "Memory access_opt"])

    val = ""
    while val == "":
        val = input("Automate ScaleHLS optimization? (Y / N)\n")
        # val = "y"
        if((val == "Y") or (val == "y") or (val == "yes")):
            opt_knob[0] = 'yes';
            return opt_knob, opt_knob_names
        elif((val == "N") or (val == "n") or (val == "no")):
            opt_knob[0] = 'no';
#individual selection
    val = ""
    while val == "":
        val = input("Do loop perfectization? (Y / N)\n")
        if((val == "Y") or (val == "y") or (val == "yes")):
            opt_knob[1] = 'yes';
        elif((val == "N") or (val == "n") or (val == "no")):
            opt_knob[1] = 'no';
    val = ""
    while val == "":
        val = input("Do loop order_opt? (Y / N)\n")
        if((val == "Y") or (val == "y") or (val == "yes")):
            opt_knob[2] = 'yes';
        elif((val == "N") or (val == "n") or (val == "no")):
            opt_knob[2] = 'no';
    val = ""
    while val == "":
        val = input("Do loop permutation? (Y / N)\n")
        if((val == "Y") or (val == "y") or (val == "yes")):
            opt_knob[3] = 'yes';
        elif((val == "N") or (val == "n") or (val == "no")):
            opt_knob[3] = 'no';
    val = ""
    while val == "":
        val = input("Do loop variable bound removal? (Y / N)\n")
        if((val == "Y") or (val == "y") or (val == "yes")):
            opt_knob[4] = 'yes';
        elif((val == "N") or (val == "n") or (val == "no")):
            opt_knob[4] = 'no';
    val = ""
    while val == "":
        val = input("Do loop memory access_opt? (Y / N)\n")
        if((val == "Y") or (val == "y") or (val == "yes")):
            opt_knob[5] = 'yes';
        elif((val == "N") or (val == "n") or (val == "no")):
            opt_knob[5] = 'no';

    return opt_knob, opt_knob_names                          


def do_run(command):
    ret = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
    return ret.stdout

def scalehls_dse(source_file, inputtop):
    print("Starting ScaleHLS DSE")

    #scalehls dse temp directory
    sdse_dir = "generated_files/scalehls_dse_temp/"

    if not(os.path.exists(sdse_dir)):
        os.makedirs(sdse_dir)

    targetspec = 'target-spec=scalehls_dse_config.json'

    p1 = subprocess.Popen(['mlir-clang', source_file, '-function=' + inputtop, '-memref-fullrank', '-raise-scf-to-affine', '-S'],
                            stdout=subprocess.PIPE)                           
    process = subprocess.run(['scalehls-opt', '-dse=top-func='+ inputtop + ' output-path=./' + sdse_dir + ' csv-path=./' + sdse_dir + ' ' + targetspec, '-debug-only=scalehls'], 
                            stdin=p1.stdout, stdout=subprocess.DEVNULL)

    fout = open('generated_files/'+ 'ScaleHLS_DSE_out.cpp', 'wb')
    subprocess.run(['scalehls-translate', '-emit-hlscpp', sdse_dir + inputtop + '_pareto_0.mlir'], stdout=fout)

    print("Finished ScaleHLS DSE")

def ScaleHLSopt(source_file, topfunction, outfile):
    opts_knobs, opts_knob_names = opts_menu()

    if (opts_knobs[0] == 'yes'):
        opts_knobs.fill('yes')

    fin = do_run(['mlir-clang', '-S',
                '-function=' + topfunction,
                '-memref-fullrank',
                '-raise-scf-to-affine',
                source_file])

    ctx = mlir.ir.Context()
    scalehls.register_dialects(ctx)
    mod = mlir.ir.Module.parse(fin, ctx)

    # Traverse all functions in the MLIR module.
    for func in mod.body:
        if not isinstance(func, builtin.FuncOp):
            pass
        func.__class__ = builtin.FuncOp

        # Traverse all suitable loop bands in the function.
        bands = scalehls.LoopBandList(func)
        for band in bands:
            # Attempt to perfectize the loop band
            if(opts_knobs[1] == 'yes'):
                scalehls.loop_perfectization(band)

            # Maximize the distance of loop-carried dependencies through loop permutation.
            if(opts_knobs[2] == 'yes'):
                scalehls.loop_order_opt(band)

            # Apply loop permutation based on the provided map.
            # Note: This example "permMap" keeps the loop order unchanged.
            if(opts_knobs[3] == 'yes'):
                permMap = np.arange(band.depth)
                scalehls.loop_permutation(band, permMap)

            # Attempt to remove variable loop bounds if possible.
            if(opts_knobs[4] == 'yes'):
                scalehls.loop_var_bound_removal(band)

        # Legalize the IR to make it emittable.
        scalehls.legalize_to_hlscpp(func, func.sym_name.value == topfunction)

        # Optimize memory accesses through store forwarding, etc.
        if(opts_knobs[5] == 'yes'):
            scalehls.memory_access_opt(func)

        # Apply suitable array partition strategies through analyzing the array access pattern.
        # scalehls.auto_array_partition(func)

    # Emit optimized MLIR to HLS C++.
    buf = io.StringIO()
    scalehls.emit_hlscpp(mod, buf)
    buf.seek(0)
    fout = open(outfile, 'w+')
    shutil.copyfileobj(buf, fout)
    fout.close()

    return opts_knobs, opts_knob_names