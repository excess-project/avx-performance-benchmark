# AVX BENCHMARK

> AVX stands for Advanced Vector Extensions, an extension to the x86 instruction set of Intel and AMD CPUs. With the introduction of these extensions, the SIMD register size was double to 256 bit. The new instruction set allows to execute commands having three operands (e.g, c = a + b) to save copy operations.

## Motivation

The AVX benchmark is intended to help to sort the criteria, which may influence the efficiency of the numerical kernels, in particular in the aspect of cache and memory accesses. For the full utilization of the cache, a lot of things have to be considered, including cache lines, cache associativity, hardware and software prefecthing, vectorization, and so on.

## Configuration

The benchmark “AVX” source code can be found in the /src directory and can be compiled with GNU and Intel compilers with the command:

```bash
$cd src
$make avx
```

It performs arrays addition (like a[i]=b[i]+c[i]) through loops and compares the performance and energy efficient with regards to different data access modes. The execution of the program requires four input arguments:

```bash
$./avx config.ini 2 1 /home/data_file_dir 
```

The 1 st argument “config.ini” specifies the configuration file, where the program reads associated parameters in. Here is an example of the configuration file contents:

```bash
[GLOBAL]
cpu_cores=10;
LENGTH_MIN=300;
LENGTH_MAX=1000000;
num_steps=10;
length_conf    = 400 500 1000 2500 6000 12000 22000 30000  45948 1000000;
steps          = 15  30  50   70   150  250   300   500    500   15000;
DATA_TYPE      =.dat

[COMPONENT_1]
FILE_NAME=seq
[COMPONENT_2]
increment=4;
FILE_NAME=incre
[COMPONENT_3]
FILE_NAME=list
[COMPONENT_4]
FILE_NAME=randidx
[COMPONENT_5]
FILE_NAME=para_pin1
[COMPONENT_6]
FILE_NAME=para_pin2
[COMPONENT_7]
FILE_NAME=para_pin3
```

The 2nd argument is the number representing the type of the benchmark operation, where:

| 2nd argument      | Meaning                                           |
|------------------ |-------------------------------------------------- |
| 1                 | Sequential array data access. The index of the array is increased by 1 for eachloop. In this case, the addition is vectorized and the loop is unrolled by 8 times. |
| 2                 | Fixed increment data access. The index of the array is increased by a fixed number for each loop, while the increment number can be obtained from the configuration file. In this case, no data vectorization is fulfilled. And the loop-unrolling depends on the increment of the index and compiler option (For example by using the gcc 4.9.2 compiler with the option “-funroll-loops”: Loop is unrolled for index increased by 4, however for index increased by 5, there is no loop unrolling). |
| 3                 | Array “b” and “c” are changed to linked-list data structure. And for data alignment, each node in the list contains 1*8 byte address and 3*8 byte data. Hence, the size of one node is equal to the size of a half cache-line. In this case, neither the data vectorization nor the loop-unrolling is fulfilled. However it can be seen as that the loop is unrolled by 3 times manually for data alignment. |
| 4                 | Random array data access. The index of the array is obtained by another array, containing integers in the index range with random order. In this case, no data vectorization is fulfilled. However the loops are unrolled by 8 times. |
| 5                 | Parallel processing, fill cores strategy 1: Each thread is statically pinned to a core whose id is the same as the thread id (no hyper-threading is used). |
| 6                 | Parallel processing, fill first core strategy 2: Threads are all pinned to the first physical core (no hyper-threading is used). |
| 7                 | Parallel processing, fill hw-threads strategy 3: Because of hyper-threading technique, each physical core can be divided into two execution parts sharing the local caches and arithmetic units. Therefore, hyper-threads pinning method pins the first half threads one by one to hw-threads 0-9, and the other half threads are pinned to hw-threads 20-29, while each of them asides physically together with cores 0-9 respectively.|

The 3rd argument is the number of cores that will be used for the computation; and the 4th argument is data file directory, where you want to store the performance measurements.

## Execution
There is one PBS job script (pbs.sh in /src) provided showing how to execute the benchmark on EXCESS cluster. Users can just submit the job with a command:

```bash
$qsub pbs.sh
```

Besides the users can also execute the benchmark in an interactive way:

```bash
$qsub -I -l nodes=1:node02:ppn=20 -X
$./avx config.ini 1 1 & top -d .5
```

## Data analysis

### Power and performance data
After the execution of the test program, not only the performance data but also associated power and energy data are saved. Performance (execution time) data can be found in the directory as the users specifiy in the 4th argument. Power data will be collected if the users switch on the power measurements by the commands:

```bash
$mkdir /nas_home/your_username/.pwm//node0x/ -p
$touch /nas_home/your_username/.pwm//node0x/copy_raw_data
```
Then after the job is completed, the power data are stored in a directory and can be extracted by:

```bash
$tar xfz /nas_home/your_username/pwm//node0x/xxxx.fe.excess-project.eu.tar.gz
```

### Data analysis tool
To analyze the power data combined with the performance data, we provide a /powercal_tools directory, containing a power calculation tool: power_calculate_avx. The tool needs different input parameters:

| Option               | Argument                                           |
|--------------------- |--------------------------------------------------- |
| -verbosity           | 1 (fixed)                                          |
| -offset_sec          | 0.0 (fixed)                                        |
| -relative_time       | 0 (fixed)                                          |
| -board_id            | 1 (fixed)                                          |
| -config_file         | configuration file of the power measurement system |
| -topdir              | directory, where the power data are stored         |
| -performance_file    | performance data file, which is written by the AVX benchmark |
| -power_file          | calculated power file, output of the power calculation tool  |
| -energy_file         | calculated energy file, output of the power calculation tool |
| -joule_per_flop_file | calculated Joule/Flop data file, output of the power calculation tool |

The performance data file is generated by the execution of the AVX benchmark. The file contains the timestamps of the beginning and the end of each test. With the help of these timestamps and the power data, the tool is able to compute the power consumption for each test: The tool generates the set of the data, which contains power, energy and efficiency values for the further analysis and visualization.

There is one script in the directory /powercal_tools, showing how to use the power calculation tool.

## Acknowledgment

This project is realized through [EXCESS][excess]. EXCESS is funded by the EU 7th Framework Programme (FP7/2013-2016) under grant agreement number 611183.

## Main Contributors
**Fangli Pi, HLRS**
+ [github/hpcfapix](https://github.com/hpcfapix)


[excess]: http://www.excess-project.eu
