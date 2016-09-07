#ifndef MEMO_ACC_H_
#define MEMO_ACC_H_

struct file_path_t
{
	char *dir;
	char *DATA_TYPE;
	char *FILE_NAME;
};
struct array_t
{
	long int *length_conf;
	long int *steps;
};
struct config_type
{
	long cpu_cores;
	long LENGTH_MIN;
	long LENGTH_MAX;
	long num_steps;
	long increment;
	struct file_path_t* file_path;
	struct array_t* arrays;
};

struct node{
	double data[3];  /* 3*8 bytes*/
	struct node *next;  /* address is 8 bytes*/
};   /* so one node(32 bytes) is one cache block in cache */

/*functions for read config values */
long read_long_value(const char *section,const char *name,struct collection_item * ini_config);
char *read_string_value(const char *section,const char *name,struct collection_item * ini_config);
long int *read_long_array(const char *section,const char *name,struct collection_item * ini_config, int array_size);
int read_config_file(char * config_file, struct config_type * config, int operation);

/*functions to get sys time in second*/
double timer_get_time(void);

/*write the performance and time value into the associated files*/
void performance_write_to_file(int num_threads, struct config_type* config, double *__restrict performance, double *__restrict begin_t, double *__restrict end_t);
/*function to generate random number*/
void double_rand_gen(double *__restrict r, double min, double max, long int len);

/*function to generate a linked-list*/
struct node *list_generate(double min, double max, long int len);

/*function to free a linked-list with the first node*/
void list_free(struct node *first);

/*function to generate a non-repeating random index for arrays*/
void rand_index_gen(int *__restrict index, int min, long int max);

/*sequential data access*/
void seq_add(double *__restrict a,double *__restrict b,double *__restrict c, struct config_type* config, double *__restrict performance, double *__restrict begin_t, double *__restrict end_t);
/*calculate the repeat times for each lenght of the array addition, fixing the operation time to be 2s */
long long int seq_get_repeat_times(double *__restrict a,double *__restrict b,double *__restrict c, int length);

/*un-sequential data access: with "increment"*/
void fixed_index_incre(double *__restrict a,double *__restrict b,double *__restrict c, struct config_type* config, double *__restrict performance, double *__restrict begin_t, double *__restrict end_t);
/*calculate the repeat times for each lenght of the array addition, fixing the operation time to be 2s */
long long int fixed_get_repeat_times(double *__restrict a,double *__restrict b,double *__restrict c, int length, int increment);

/* uncontinously data access: data structure is linked-list */
void list(double *__restrict a,struct node *b_first, struct node *c_first, struct config_type* config, double *__restrict performance, double *__restrict begin_t, double *__restrict end_t);
/*calculate the repeat times for each lenght of the array addition, fixing the operation time to be 2s */
long long int list_get_repeat_times(double *__restrict a,struct node *b_first, struct node *c_first, int length);

/*non-repeating random index, random memeory access*/
void rand_index(double *__restrict a,double *__restrict b,double *__restrict c, int *__restrict index, struct config_type* config, double *__restrict performance, double *__restrict begin_t, double *__restrict end_t);
/*calculate the repeat times for each lenght of the array addition, fixing the operation time to be 2s */
long long int rand_get_repeat_times(double *__restrict a,double *__restrict b,double *__restrict c, int *__restrict index, int length);

/*parallel addition using openmp multiple threads, pinning to differnent cores, scatter pinning*/
void parallel_add_pin1(double *__restrict a,double *__restrict b,double *__restrict c,int num_threads, struct config_type* config, double *__restrict performance, double *__restrict begin_t, double *__restrict end_t);

/*parallel addition using openmp multiple threads, pinning to a same core, compact pinning*/
void parallel_add_pin2(double *__restrict a,double *__restrict b,double *__restrict c,int num_threads, struct config_type* config, double *__restrict performance, double *__restrict begin_t, double *__restrict end_t);

/*parallel addition using openmp multiple threads, hyper-threads pinning */
void parallel_add_pin3(double *__restrict a,double *__restrict b,double *__restrict c,int num_threads, struct config_type* config, double *__restrict performance, double *__restrict begin_t, double *__restrict end_t);
/*do addition without pinning*/
void parallel_addition(double *__restrict a,double *__restrict b,double *__restrict c,int num_threads, struct config_type* config, double *__restrict performance, double *__restrict begin_t, double *__restrict end_t);
/*calculate the repeat times for each lenght of the array addition, fixing the operation time to be 2s */
long long int parallel_get_repeat_times(double *__restrict a,double *__restrict b,double *__restrict c, int length, int num_threads);
#endif
