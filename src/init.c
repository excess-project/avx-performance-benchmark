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

/*write the performance and time value into the associated files*/
void performance_write_to_file(int num_threads, struct config_type* config, double *__restrict performance, double *__restrict begin_t, double *__restrict end_t){
	int length, i, j;
	char fname[100];
	FILE *fp;
	sprintf(fname, "%s%s_%dcores%s", config->file_path->dir, config->file_path->FILE_NAME,num_threads, config->file_path->DATA_TYPE);
	if(access(fname, F_OK)!=-1){
	//file exists
	fp = fopen (fname, "a");
	}
	else {
	//file does not exist
	fp = fopen (fname, "w+");
	fprintf(fp, "%s\n", "#cores;length;performance   ;begin_t(s)    ;end_t(s)       ");
	}	
	for(length=config->LENGTH_MIN, j=0, i=0; i<config->num_steps; i++){
		for (; length <= *((config->arrays->length_conf)+i); j++){
   			fprintf(fp, "%6d;%6d;%.15f;%.15f;%.15f\n", num_threads, length, *(performance+j), *(begin_t+j), *(end_t+j));
			length = length + *((config->arrays->steps)+i);
		}
	}
	fclose(fp);
}
/*functions to get sys time*/
double timer_get_time(void)
{
	struct timespec time_now;
	double result_sec_now;
	
	clock_gettime(CLOCK_REALTIME, &time_now);
	result_sec_now=(time_now.tv_sec)+(time_now.tv_nsec)*1e-9;
	return result_sec_now;
}

/*function to generate random number*/
void double_rand_gen(double *__restrict r, double min, double max, long int len)
{
	int i;
	double range= max - min;
	double div= RAND_MAX /range;
	for (i=0; i<len; i++){
		*(r+i)=min+(rand()/div);
	}
} 
struct node *list_generate(double min, double max, long int len)
{
	int i;
	double range= max - min;
	double div= RAND_MAX /range;
	struct node *first, *current;
	void* temp_alloc;
	size_t align_offset=32;
	size_t el_num=4;

	posix_memalign(&temp_alloc, align_offset, el_num*sizeof(double));  /*aligned memory allocate*/
	first = (struct node *) temp_alloc;
	current=first;
	for (i=0; i<len-1; i=i+3){
		if(current==0)
			printf("not enough memory when generating list!\n\n");
		else{
			current->data[0]=min+(rand()/div);
			current->data[1]=min+(rand()/div);
			current->data[2]=min+(rand()/div);
			posix_memalign(&temp_alloc, align_offset, el_num*sizeof(double));
			current->next= (struct node *) temp_alloc;
			current=current->next;
		}
	}
	current->data[0]=min+(rand()/div);
	current->data[1]=min+(rand()/div);
	current->data[2]=min+(rand()/div);
	current->next=0;
	return first;
}

void list_free(struct node *first){
	struct node *current=first;
	struct node *nextnode;
	while(current->next != 0){
		nextnode=current->next;
		free(current);
		current=nextnode;
	}
	free(current);
}
void rand_index_gen(int *__restrict index, int min, long int max)   /*min must be 0*/
{
 	int i, rand_index, temp;
 
 	for (i=min; i<=max; i++)  /*generate a array which value is the index*/
 	{
   		index[i]=i;
 	}
 
 	for (i=min; i<=max; i++) /*shuffle the index array*/
 	{
  		rand_index=(rand() % (max+1));
  		temp = index[i];
  		index[i] = index[rand_index];
  		index[rand_index] = temp;
 	}
}

