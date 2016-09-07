#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <sys/time.h> 
#include <math.h>
#include <omp.h>
#include <string.h>
#include <malloc.h>
#include <ini_config.h>

#include "memo_acc.h"
#include "hpc_utils.h"
#ifndef __USE_GNU
#define __USE_GNU 
#endif 
#include <sched.h>
/*scatter threads pinning, each thread is executed on a unique core
	thread i is executed on core i
	it may happen that two CPU sockets are running simultaneously */
void parallel_add_pin1(double *__restrict a,double *__restrict b,double *__restrict c,int num_threads, struct config_type* config, double *__restrict performance, double *__restrict begin_t, double *__restrict end_t){
	/*declare variables*/
	int iam;
	cpu_set_t processor_mask;
	/*threads pinning*/
	omp_set_num_threads(num_threads);
	#pragma omp parallel default(shared) private(iam, processor_mask)
	{
		iam = omp_get_thread_num();	/*get the thread id*/
		CPU_ZERO(&processor_mask); 
		//this macro initializes the cpu set "processor_mask" to be the empty set.
		CPU_SET(iam,&processor_mask);
		//this macro adds cpu "core_id" to the cpu set "processor_mask"
		sched_setaffinity(0, sizeof(cpu_set_t), &processor_mask );
		//this function call asigns the thread with pid "0" to the cpu set "processor_mask"
	}/*end of parallel omp*/
	parallel_addition(a,b,c,num_threads,config,performance,begin_t,end_t);
}

/*compact threads pinning. This function pins the first half threads to the core: 0 (virtual core id) 
				and the sencond half threads to the core : 20 (virtual core id)
	because the processor 0 and 20 reside on the same physical core */
void parallel_add_pin2(double *__restrict a,double *__restrict b,double *__restrict c,int num_threads, struct config_type* config, double *__restrict performance, double *__restrict begin_t, double *__restrict end_t){
	/*declare variables*/
	int iam;
	cpu_set_t processor_mask;
	/*threads pinning*/
	omp_set_num_threads(num_threads);
	#pragma omp parallel default(shared) private(iam, processor_mask)
	{
		iam = omp_get_thread_num();	/*get the thread id*/	
		if(iam < (num_threads/2)){
			CPU_ZERO(&processor_mask); 
			//this macro initializes the cpu set "processor_mask" to be the empty set.
			CPU_SET(0,&processor_mask);
			//this macro adds cpu "core_id" to the cpu set "processor_mask"
			sched_setaffinity(0, sizeof(cpu_set_t), &processor_mask );
			//this function call asigns the thread with pid "0" to the cpu set "processor_mask"
		}
		else {
			CPU_ZERO(&processor_mask); 
			//this macro initializes the cpu set "processor_mask" to be the empty set.
			CPU_SET(20,&processor_mask);
			//this macro adds cpu "core_id" to the cpu set "processor_mask"
			sched_setaffinity(0, sizeof(cpu_set_t), &processor_mask );
			//this function call asigns the thread with pid "0" to the cpu set "processor_mask"
		}
	}/*end of parallel omp*/
	parallel_addition(a,b,c,num_threads,config,performance,begin_t,end_t);
}
/*hyper-threads pinning.
	pin the first half threads to the cores from 0-9 (virtual core id) 
	pin the second half threads to the cores from 20-29 (virtual core id)
	hence, only one cpu socket is used */ 
void parallel_add_pin3(double *__restrict a,double *__restrict b,double *__restrict c,int num_threads, struct config_type* config, double *__restrict performance, double *__restrict begin_t, double *__restrict end_t){
	/*declare variables*/
	int iam;
	cpu_set_t processor_mask;
	/*threads pinning*/
	omp_set_num_threads(num_threads);
	#pragma omp parallel default(shared) private(iam, processor_mask)
	{
		iam = omp_get_thread_num();	/*get the thread id*/	
		if(iam < (num_threads/2)){
			CPU_ZERO(&processor_mask); 
			//this macro initializes the cpu set "processor_mask" to be the empty set.
			CPU_SET(iam,&processor_mask);
			//this macro adds cpu "core_id" to the cpu set "processor_mask"
			sched_setaffinity(0, sizeof(cpu_set_t), &processor_mask );
			//this function call asigns the thread with pid "0" to the cpu set "processor_mask"
		}
		else {
			CPU_ZERO(&processor_mask); 
			//this macro initializes the cpu set "processor_mask" to be the empty set.
			CPU_SET(iam+20-(num_threads/2),&processor_mask);
			//this macro adds cpu "core_id" to the cpu set "processor_mask"
			sched_setaffinity(0, sizeof(cpu_set_t), &processor_mask );
			//this function call asigns the thread with pid "0" to the cpu set "processor_mask"
		}
	}/*end of parallel omp*/
	parallel_addition(a,b,c,num_threads,config,performance,begin_t,end_t);
	
}
/*omp parallel set in the repetition loop
void parallel_addition(double *__restrict a,double *__restrict b,double *__restrict c,int num_threads, struct config_type* config, double *__restrict performance, double *__restrict begin_t, double *__restrict end_t){
	int i, n, length;
	int iam, ilen, istart, k;
	long j, test_times;
	length = config->LENGTH_MIN;
	n=0;
	for(i = 0; i<config->num_steps; i++){
		while (length <= *((config->arrays->length_conf)+i)){ //get length
			test_times = parallel_get_repeat_times(a,b,c, length,num_threads); //get the repeat times
			//start time recording
			*(begin_t+n)=timer_get_time();
			for (j=0; j < test_times; j++){
				omp_set_num_threads(num_threads);
				#pragma omp parallel default(shared) private(iam, ilen, istart, k)
				{
					iam = omp_get_thread_num();	//get the thread id
					ilen = length / num_threads;		//get the length for each thread
					istart = iam * ilen;		//get the start point for each thread
					if (iam == num_threads -1) 
						ilen = length - istart;	//last thread may do more
					for (k=0; k<ilen; k++)
						*(a+istart+k)=*(b+istart+k)+*(c+istart+k);
				}
				//end of parallel omp	
			}
			*(end_t+n)=timer_get_time();
			//end time recording
			*(performance+n) = (test_times * length) / (*(end_t+n) - *(begin_t+n));
			length = length + *((config->arrays->steps)+i); //new length
			n++;
			sleep(1);	//pause time for CPU to cool down
		}
	}
}*/
/*omp parallel set outside the repetition loop*/
void parallel_addition(double *__restrict a,double *__restrict b,double *__restrict c,int num_threads, struct config_type* config, double *__restrict performance, double *__restrict begin_t, double *__restrict end_t){
	int i, n, length;
	int iam, ilen, istart, k;
	long long int j, test_times;
	length = config->LENGTH_MIN;
	n=0;
	for(i = 0; i<config->num_steps; i++){
		while (length <= *((config->arrays->length_conf)+i)){ //get the length
			test_times = parallel_get_repeat_times(a,b,c, length,num_threads); //get the repeat times
			/*start time recording*/
			*(begin_t+n)=timer_get_time();
			omp_set_num_threads(num_threads);
			#pragma omp parallel default(shared) private(iam, ilen, istart, j, k)
			{
				iam = omp_get_thread_num();	//get the thread id
				ilen = length / num_threads;		//get the length for each thread
				istart = iam * ilen;		//get the start point for each thread
				if (iam == num_threads -1) 
					ilen = length - istart;	//last thread may do more
				for (j=0; j < test_times; j++){
					for (k=0; k<ilen; k++)
						*(a+istart+k)=*(b+istart+k)+*(c+istart+k);
				}
			}
			//end of parallel omp
			*(end_t+n)=timer_get_time();
			/*end of time recording*/
			*(performance+n) = (test_times * length) / (*(end_t+n) - *(begin_t+n));
			length = length + *((config->arrays->steps)+i);	//get new length
			n++;
			sleep(1);	//pause time for CPU to cool down
		}
	}
}
/*calculate the repeat times for each lenght of the array addition, fixing the operation time to be 2s */
long long int parallel_get_repeat_times(double *__restrict a,double *__restrict b,double *__restrict c, int length, int num_threads)
{
	int iam, ilen, istart, k;
	long long int j,repetition_times;
	double begin_t, end_t;

	begin_t=timer_get_time();
	omp_set_num_threads(num_threads);
	#pragma omp parallel default(shared) private(iam, ilen, istart, j, k)
	{
		iam = omp_get_thread_num();	//get the thread id
		ilen = length / num_threads;		//get the length for each thread
		istart = iam * ilen;		//get the start point for each thread
		if (iam == num_threads -1) 
			ilen = length - istart;	//last thread may do more
		for (j=0; j < 1000000; j++){
			for (k=0; k<ilen; k++)
				*(a+istart+k)=*(b+istart+k)+*(c+istart+k);
		}
	}
	//end of parallel omp
	end_t=timer_get_time();
	repetition_times=(long long int)(1000000*2)/(end_t-begin_t);
	printf("length: %10d repeat_times: %lld\n", length, repetition_times);
	return repetition_times;
}
