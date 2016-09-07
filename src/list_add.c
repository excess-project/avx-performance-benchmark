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
 
void list(double *__restrict a,struct node *b_first, struct node *c_first, struct config_type* config, double *__restrict performance, double *__restrict begin_t, double *__restrict end_t)
{ 
	/*declare variables*/
	int i, k, length, n;
	long long int j, test_times;
	struct node *b_current, *c_current;

	length = config->LENGTH_MIN;
	n=0;
	for(i = 0; i<config->num_steps; i++){
		while (length <= *((config->arrays->length_conf)+i)){	//get the length
			test_times = list_get_repeat_times(a,b_first, c_first,length);  //get the repeat times
			//start time recording
			*(begin_t+n)=timer_get_time();
			for (j=0; j < test_times; j++){
				b_current = b_first;
				c_current = c_first;
				for (k=0; k < length; k=k+3){
					*(a+k)=b_current->data[0] + c_current->data[0];
					*(a+k+1)=b_current->data[1] + c_current->data[1];
					*(a+k+2)=b_current->data[2] + c_current->data[2];
					b_current=b_current->next;
					c_current=c_current->next;
				}	
			}
			*(end_t+n)=timer_get_time();
			//end of time recording
			*(performance+n) = (test_times * length) / (*(end_t+n) - *(begin_t+n));
			length = length + *((config->arrays->steps)+i); /*new length*/
			n++;
			sleep(1);	//pause time for CPU to cool down
		}
	}
}

/*calculate the repeat times for each lenght of the array addition, fixing the operation time to be 2s */
long long int list_get_repeat_times(double *__restrict a,struct node *b_first, struct node *c_first, int length)
{
	int k;
	long long int i,repetition_times;
	double begin_t, end_t;
	struct node *b_current, *c_current;

	begin_t=timer_get_time();
	for (i=0; i < 1000000; i++){
		b_current = b_first;
		c_current = c_first;
		for (k=0; k < length; k=k+3){
			*(a+k)=b_current->data[0] + c_current->data[0];
			*(a+k+1)=b_current->data[1] + c_current->data[1];
			*(a+k+2)=b_current->data[2] + c_current->data[2];
			b_current=b_current->next;
			c_current=c_current->next;
		}	
	}	
	end_t=timer_get_time();
	repetition_times=(long long int)1000000*2/(end_t-begin_t);
	printf("length: %10d repeat_times: %lld\n", length, repetition_times);
	return repetition_times;
}
