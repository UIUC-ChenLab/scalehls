from asyncio.subprocess import DEVNULL
import subprocess
import sys
#from subprocess import PIPE, run

#https://thomas-cokelaer.info/blog/2020/11/how-to-use-subprocess-with-pipes//

# mlir-clang ../../samples/AutoScaleHLS_tests/3mm.c -function=kernel_3mm -memref-fullrank -raise-scf-to-affine -S \
#     | scalehls-opt -dse="top-func=kernel_3mm target-spec=target-spec.ini" -debug-only=scalehls > /dev/null \
#     && scalehls-translate -emit-hlscpp kernel_3mm_pareto_0.mlir > kernel_3mm_pareto_0.cpp


def main():

    source_file = '../../samples/AutoScaleHLS_tests/3mm.c'
    inputtop = 'kernel_3mm'
    targetspec = 'target-spec=target-spec.ini'

    p1 = subprocess.Popen(['mlir-clang', source_file, '-function=' + inputtop, '-memref-fullrank', '-raise-scf-to-affine', '-S'],
                            stdout=subprocess.PIPE)                           
    process = subprocess.run(['scalehls-opt', '-dse=top-func='+ inputtop + ' output-path=./generated_files/ csv-path=./generated_files/ ' + targetspec, '-debug-only=scalehls'], 
                            stdin=p1.stdout, stdout=subprocess.DEVNULL)
    
    print(process.stdout)

    fout = open('generated_files/'+ inputtop + '_pareto_0.cpp', 'wb')
    subprocess.run(['scalehls-translate', '-emit-hlscpp', 'generated_files/'+ inputtop + '_pareto_0.mlir'], stdout=fout)

def hello():
    pro = subprocess.run(['./hello'], stdout=subprocess.PIPE)

    print(pro.stdout)



if __name__ == "__main__":
    main()
    # hello()