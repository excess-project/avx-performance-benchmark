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
void seq_add(double *__restrict a,double *__restrict b,double *__restrict c, struct config_type* config, double *__restrict performance, double *__restrict begin_t, double *__restrict end_t)  
{
	/*declare variables*/
	int i, k, length, n;
	long long int j, test_times;
	length = config->LENGTH_MIN;
	n=0;
	for(i = 0; i<config->num_steps; i++){
		while (length <= *((config->arrays->length_conf)+i)){ //get the array length
			test_times = seq_get_repeat_times(a, b, c, length);  //get the repeat times
			/*start recording time*/
			*(begin_t+n)=timer_get_time();
			for (j=0; j < test_times; j++){
				for (k=0; k < length; k++)
					*(a+k)=*(b+k)+*(c+k);	
			}
			*(end_t+n)=timer_get_time();
			/*end of recording time*/
			*(performance+n) = (test_times * length) / (*(end_t+n) - *(begin_t+n));
			length = length + *((config->arrays->steps)+i); /*new length*/
			n++;
			sleep(1);	//pause time for CPU to cool down
		}
	}
}
/*calculate the repeat times for each lenght of the array addition, fixing the operation time to be 2s */
long long int seq_get_repeat_times(double *__restrict a,double *__restrict b,double *__restrict c, int length)
{
	int k;
	long long int i, repetition_times;
	double begin_t, end_t;
	begin_t=timer_get_time();
	for (i=0; i < 1000000; i++){
		for (k=0; k < length; k++)
			*(a+k)=*(b+k)+*(c+k);	
	}
	end_t=timer_get_time();
	repetition_times = (long long int)1000000*2/(end_t-begin_t);
	printf("length: %10d repeat_times: %lld\n", length, repetition_times);
	return repetition_times;
}
