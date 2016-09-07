#!/bin/sh -f

#the job name is "avx"
#PBS -N avx
#PBS -q night

#use the complite path to the standard output files
#PBS -o /nas_home/hpcfapix/$PBS_JOBID.out
#PBS -e /nas_home/hpcfapix/$PBS_JOBID.err
#PBS -l walltime=00:60:00

#set the number of nodes is 1
#set the number of processor in each node is 20
#PBS -l nodes=1:node01:ppn=20
AVX_BIN=/nas_home/hpcfapix/avx-performance-benchmark/src
DATA_FILE_DIR=/nas_home/hpcfapix/avx-performance-benchmark/data/
cd ${AVX_BIN}

#start run program
echo "Time begin:" $(date +%T) "sequential address access, number of cores is 1"
${AVX_BIN}/avx config.ini 1 1 ${DATA_FILE_DIR}
echo "Time end:" $(date +%T)

echo "Time begin:" $(date +%T) "fixed-increment address access, number of cores is 1"
${AVX_BIN}/avx config.ini 2 1 ${DATA_FILE_DIR}
echo "Time end:" $(date +%T)

echo "Time begin:" $(date +%T) "linked-list address access, number of cores is 1"
${AVX_BIN}/avx config.ini 3 1 ${DATA_FILE_DIR}
echo "Time end:" $(date +%T)

echo "Time begin:" $(date +%T) "random address access, number of cores is 1"
${AVX_BIN}/avx config.ini 4 1 ${DATA_FILE_DIR}
echo "Time end:" $(date +%T)

echo ""
echo "Time begin:" $(date +%T) "parallel execution: scatter pinning, number of cores is 1"
${AVX_BIN}/avx config.ini 5 1 ${DATA_FILE_DIR}
echo "Time begin:" $(date +%T) "parallel execution: scatter pinning, number of cores is 2"
${AVX_BIN}/avx config.ini 5 2 ${DATA_FILE_DIR}
echo "Time begin:" $(date +%T) "parallel execution: scatter pinning, number of cores is 4"
${AVX_BIN}/avx config.ini 5 4 ${DATA_FILE_DIR}
echo "Time begin:" $(date +%T) "parallel execution: scatter pinning, number of cores is 8"
${AVX_BIN}/avx config.ini 5 8 ${DATA_FILE_DIR}
echo "Time begin:" $(date +%T) "parallel execution: scatter pinning, number of cores is 10"
${AVX_BIN}/avx config.ini 5 10 ${DATA_FILE_DIR}
echo "Time end:" $(date +%T)

echo ""
echo "Time begin:" $(date +%T) "parallel execution: compact pinning, number of cores is 1"
${AVX_BIN}/avx config.ini 6 1 ${DATA_FILE_DIR}
echo "Time begin:" $(date +%T) "parallel execution: compact pinning, number of cores is 2"
${AVX_BIN}/avx config.ini 6 2 ${DATA_FILE_DIR}
echo "Time begin:" $(date +%T) "parallel execution: compact pinning, number of cores is 4"
${AVX_BIN}/avx config.ini 6 4 ${DATA_FILE_DIR}
echo "Time begin:" $(date +%T) "parallel execution: compact pinning, number of cores is 8"
${AVX_BIN}/avx config.ini 6 8 ${DATA_FILE_DIR}
echo "Time begin:" $(date +%T) "parallel execution: compact pinning, number of cores is 10"
${AVX_BIN}/avx config.ini 6 10 ${DATA_FILE_DIR}
echo "Time end:" $(date +%T)

echo ""
echo "Time begin:" $(date +%T) "parallel execution: hyper-threads pinning, number of cores is 1"
${AVX_BIN}/avx config.ini 7 1 ${DATA_FILE_DIR}
echo "Time begin:" $(date +%T) "parallel execution: hyper-threads pinning, number of cores is 2"
${AVX_BIN}/avx config.ini 7 2 ${DATA_FILE_DIR}
echo "Time begin:" $(date +%T) "parallel execution: hyper-threads pinning, number of cores is 4"
${AVX_BIN}/avx config.ini 7 4 ${DATA_FILE_DIR}
echo "Time begin:" $(date +%T) "parallel execution: hyper-threads pinning, number of cores is 8"
${AVX_BIN}/avx config.ini 7 8 ${DATA_FILE_DIR}
echo "Time begin:" $(date +%T) "parallel execution: hyper-threads pinning, number of cores is 10"
${AVX_BIN}/avx config.ini 7 10 ${DATA_FILE_DIR}
echo "Time end:" $(date +%T)

#end

