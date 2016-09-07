#include <errno.h>
#include <stdint.h>
#include <signal.h>
#include <syslog.h>
#include <unistd.h>
#include <string.h>
#include <malloc.h>
#include <ini_config.h>

#include "memo_acc.h"
#include "hpc_utils.h"
#define parsing_error_str(a) ""
/*function that reads the integer value*/
long read_long_value(const char *section,const char *name,struct collection_item * ini_config){
	struct collection_item * error_list = NULL;
	struct collection_item * item = NULL;	
	long value = 0;
	int ret = get_config_item (section, name, ini_config, &item);
	if(ret)
	{
		loginfo_error ("get_config_item [%s] %s, error %i (%s)",section, name, ret, parsing_error_str(ret));
		goto error;
	}
	value = get_long_config_value(item, 0, 0, &ret);
	if(ret)
	{
		loginfo_error ("get_long_config_value [%s] %s, error %i (%s)",section, name, ret, parsing_error_str(ret));
		goto error;
	}
	error:
	if(error_list)
		free_ini_config_errors (error_list);
	return value;
}
/*function that reads a string */
char *read_string_value(const char *section,const char *name,struct collection_item * ini_config){
	struct collection_item * error_list = NULL;
	struct collection_item * item = NULL;
	char *buff = NULL;
	int ret = get_config_item (section, name, ini_config, &item);
	if(ret)
	{
		loginfo_error ("get_config_item [%s] %s, error %i (%s)",section, name, ret, parsing_error_str(ret));
		goto error;
	}
	buff = (char *)get_string_config_value(item, &ret);
	if(ret)
	{
		loginfo_error ("get_string_config_value [%s] %s, error %i (%s)",section, name, ret, parsing_error_str(ret));
		goto error;
	}
	error:
	if(error_list)
		free_ini_config_errors (error_list);
	return buff;
}
/*function that reads a long integer array*/
long int *read_long_array(const char *section,const char *name,struct collection_item * ini_config, int array_size){
	struct collection_item * error_list = NULL;
	struct collection_item * item = NULL;	
	long int *array_buff = NULL;
	int ret = get_config_item (section, name, ini_config, &item);
	if(ret)
	{
		loginfo_error ("get_config_item [%s] %s, error %i (%s)",section, name, ret, parsing_error_str(ret));
		goto error;
	}
	array_buff = (long int *)get_long_config_array(item, &array_size, &ret);
	if(ret)
	{
		loginfo_error ("get_string_config_value [%s] %s, error %i (%s)",section, name, ret, parsing_error_str(ret));
		goto error;
	}
	error:
	if(error_list)
		free_ini_config_errors (error_list);
	return array_buff;
}
/*reference with google "ini_config.h" 
	function reads from the config_file, all parameters
	config_file: (in)
	config:      (out) */
int read_config_file(char *config_file, struct config_type *config, int operation){
	struct collection_item * ini_config = NULL;
	struct collection_item * error_list = NULL;
	int i = 0;	
	int ret =0;
	
	ret = config_from_file("configuration", config_file, &ini_config, 0, &error_list);
	if(ret)
	{
		loginfo_error ("config_from_file, error %i (%s)", ret, parsing_error_str(ret));
		goto error;
	}
	config->arrays = (struct array_t*) malloc(sizeof(struct array_t)*1);
	config->file_path = (struct file_path_t*) malloc(sizeof(struct file_path_t)*1);
	/*read the config_file channel informations */
	/*1. read GLOBAL value: **********************************************************************************************/
	{
	/*cpu_cores*/
	config->cpu_cores = read_long_value("GLOBAL", "cpu_cores", ini_config);
	printf("cpu_cores : %ld\n", config->cpu_cores);
	/*LENGTH_MIN*/
	config->LENGTH_MIN = read_long_value("GLOBAL", "LENGTH_MIN", ini_config);
	printf("LENGTH_MIN : %ld\n", config->LENGTH_MIN);
	/*LENGTH_MAX*/
	config->LENGTH_MAX = read_long_value("GLOBAL", "LENGTH_MAX", ini_config);
	printf("LENGTH_MAX : %ld\n", config->LENGTH_MAX);
	/*num_steps*/
	config->num_steps = read_long_value("GLOBAL", "num_steps", ini_config);
	printf("num_steps : %ld\n", config->num_steps);
	/*length_conf*/	
	config->arrays->length_conf = read_long_array("GLOBAL","length_conf", ini_config, config->num_steps);
	printf("array length_conf:\t\t");
	for (i=0; i< config->num_steps; i++)
		printf("%ld\t", *((config->arrays->length_conf)+i));
	/*steps*/	
	config->arrays->steps = read_long_array("GLOBAL","steps", ini_config, config->num_steps);
	printf("\narray steps:\t\t\t");
	for (i=0; i< config->num_steps; i++)
		printf("%ld\t", *((config->arrays->steps)+i));
	/*DATA_TYPE*/
	config->file_path->DATA_TYPE = read_string_value("GLOBAL", "DATA_TYPE", ini_config);
	printf("\nfile_name.DATA_TYPE : %s\n", config->file_path->DATA_TYPE);
	}
	/*2. read COMPONENT_x value: ***********************************************************************************************/
	switch(operation)
   	{
   		case 1 :
			/*FILE_NAME*/
      			config->file_path->FILE_NAME = read_string_value("COMPONENT_1", "FILE_NAME", ini_config);
			printf("CASE 1: file_name is %s\n", config->file_path->FILE_NAME);
      			break;
   		case 2 :
			/*increment*/
			config->increment = read_long_value("COMPONENT_2", "increment", ini_config);;
			printf("increment : %ld\n", config->increment);
			/*FILE_NAME*/
      			config->file_path->FILE_NAME = read_string_value("COMPONENT_2", "FILE_NAME", ini_config);
			printf("CASE 2: file_name is %s\n", config->file_path->FILE_NAME);
			break;
   		case 3 :
      			/*FILE_NAME*/
      			config->file_path->FILE_NAME = read_string_value("COMPONENT_3", "FILE_NAME", ini_config);
			printf("CASE 3: file_name is %s\n", config->file_path->FILE_NAME);
      			break;
   		case 4 :
			/*FILE_NAME*/
      			config->file_path->FILE_NAME = read_string_value("COMPONENT_4", "FILE_NAME", ini_config);
			printf("CASE 4: file_name is %s\n", config->file_path->FILE_NAME);
			break;

   		case 5 :
			/*FILE_NAME*/
      			config->file_path->FILE_NAME = read_string_value("COMPONENT_5", "FILE_NAME", ini_config);
			printf("CASE 5: file_name is %s\n", config->file_path->FILE_NAME);
			break;
   		case 6 :
			/*FILE_NAME*/
      			config->file_path->FILE_NAME = read_string_value("COMPONENT_6", "FILE_NAME", ini_config);
			printf("CASE 6: file_name is %s\n", config->file_path->FILE_NAME);
			break;
   		case 7 :
			/*FILE_NAME*/
      			config->file_path->FILE_NAME = read_string_value("COMPONENT_7", "FILE_NAME", ini_config);
			printf("CASE 7: file_name is %s\n", config->file_path->FILE_NAME);
			break;
   		default :
      			printf("Invalid operation mode\n" );
	}
	printf("\n");
	/*********************************************************************************************************************************/
	error:
	if(ini_config)
		free_ini_config(ini_config);
	if(error_list)
		free_ini_config_errors (error_list);
	return ret;
}

