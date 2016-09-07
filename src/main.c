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

/*main: the first argument is "xxx.ini" used as the name of the configuration file 
        the sencond argument is the number of the operation mode   */
int main (int argc, char *argv[])
{
	struct config_type* config = NULL;	
	int i, j, length, operation, perf_size, string_len, num_cores;
	double *__restrict a, *__restrict b, *__restrict c;
	double *__restrict performance, *__restrict begin_t,  *__restrict end_t;
	struct node *b_first, *c_first;	
	int *__restrict index;
	char config_file[64];
	char data_dir[64];
	cpu_set_t processor_mask;

	strcpy(config_file, argv[1]); //1st input argument: name of config file
	operation=atoi(argv[2]);      //2nd input argument: kind of operation
	num_cores=atoi(argv[3]);      //3nd input argument: number of parallel execution cores
	strcpy(data_dir, argv[4]); //1st input argument: directory of output performance files
	string_len=strlen(config_file);
	if ((config_file[string_len-1]!='i') || (config_file[string_len-2]!='n') || (config_file[string_len-3]!='i') || (config_file[string_len-4]!='.')){
		printf("error of input parameter for config_file.\n");
		return 1;
	}
	if (operation <=0 || num_cores <=0 || strlen(data_dir) <=0) {
	         printf("error of input parameters.\n");
                return 1;
	}
	config = (struct config_type*) malloc(sizeof(struct config_type)*1);
	/*read from file "config_file" the configuration parameters*/
	read_config_file(config_file, config, operation);
	/*get the output data file directory*/
	config->file_path->dir = (char *)malloc(64*sizeof(char));
        strcpy(config->file_path->dir, data_dir);
	printf("file_name.dir: %s\n", config->file_path->dir);
	/*allocate memory*/
	a =(double *)malloc(config->LENGTH_MAX * sizeof(double));
	b =(double *)malloc(config->LENGTH_MAX * sizeof(double));
	c =(double *)malloc(config->LENGTH_MAX * sizeof(double));
	/*generate random numbers for arrays b & c */
	double_rand_gen(b, 0, 500, config->LENGTH_MAX);
	double_rand_gen(c, 0, 500, config->LENGTH_MAX);
	/*get the number of phases of the performance measurements */
	for(j=0, length=config->LENGTH_MIN, i=0; i < config->num_steps; i++){ /*length is divided into "num_steps" ranges*/
		for ( ;length <= *((config->arrays->length_conf)+i); j++){
			length = length + *((config->arrays->steps)+i);
		}
	}
	j++;
	perf_size = j; /*j is the number of points measured*/
	/*initialization calculation to warm up the machine*/
	performance=(double *)malloc(perf_size* sizeof(double));
	begin_t=(double *)malloc(perf_size* sizeof(double));
	end_t=(double *)malloc(perf_size* sizeof(double));
	/*thread pinning: pin the current working thread to core 0 */
	CPU_ZERO(&processor_mask); 
	CPU_SET(0,&processor_mask);
	sched_setaffinity(0, sizeof(cpu_set_t), &processor_mask);
	/*execution the associated operation*/
	switch(operation)
   	{
   		case 1 :
			seq_add(a, b, c, config, performance, begin_t, end_t); /*sequential data access*/
			performance_write_to_file(num_cores, config, performance, begin_t, end_t);
			break;
   		case 2 :
			fixed_index_incre(a, b, c, config, performance, begin_t, end_t); /*un-sequential data access: with "increment" */
			performance_write_to_file(num_cores, config, performance, begin_t, end_t);
			break;
   		case 3 :
			/*generate b_list and c_list with length LENGTH_MAX*/
			b_first = list_generate(0, 500, config->LENGTH_MAX);
			c_first = list_generate(0, 500, config->LENGTH_MAX);
			list(a, b_first, c_first, config, performance, begin_t, end_t); /* uncontinously data access: data structure is linked-list */
			performance_write_to_file(num_cores, config, performance, begin_t, end_t);
			list_free(b_first);
			list_free(c_first);
			break;
   		case 4 :
			/*generate non-reapeating random numbers as the index for arrays. Index range from 0 to LENGTH_MAX */
			index =(int *)malloc(config->LENGTH_MAX * sizeof(int));			
			rand_index_gen(index, 0, (config->LENGTH_MAX)-1); /*sencond var must be 0 */
			rand_index(a, b, c, index, config, performance, begin_t, end_t); /*non-repeating random index, random memeory access*/
			performance_write_to_file(num_cores, config, performance, begin_t, end_t);
			free(index);
			break;
   		case 5 :
			/* multi-threads */
			/*parallel: scatter pinning*/
			parallel_add_pin1(a, b, c, num_cores, config, performance, begin_t, end_t);
			performance_write_to_file(num_cores, config, performance, begin_t, end_t);
			break;
   		case 6 :
			/* multi-threads */
			/*paralle2: compact pinning*/
			parallel_add_pin2(a, b, c, num_cores, config, performance, begin_t, end_t);
			performance_write_to_file(num_cores, config, performance, begin_t, end_t);
			break;
   		case 7 :
			/* multi-threads */
			/*paralle3: hyper-threads pinning*/
			parallel_add_pin3(a, b, c, num_cores, config, performance, begin_t, end_t);
			performance_write_to_file(num_cores, config, performance, begin_t, end_t);
			break;
		default :
      			printf("Invalid operation mode\n" );
	}
	
	/*free memory*/
	free(a);
	free(b);
	free(c);
	free(performance);
	free(begin_t);
	free(end_t);
	return 0;
}
