/** @file hpc_power_config.c
 *
 *
 * @author D. Khabi
 *
 * @par LICENCE
 * @verbatim


 * @endverbatim
 *
 */

#include <errno.h>
#include <stdint.h>
#include <signal.h>
#include <syslog.h>
#include <unistd.h>
#include <string.h>
#include <malloc.h>
#include <ini_config.h>

#include "hpc_power_config.h"
#include "hpc_power_utils.h"

//---------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------

int hpc_read_power_config_file (const char * config_file, struct iniPowerConfig_t * config, struct components_t * config_components)
{
	struct collection_item * ini_config = NULL;
	struct collection_item * error_list = NULL;
	struct collection_item * item = NULL;
	uint32_t ui32val = 0;
	int ret = 0;

	ret = config_from_file ("hpc_power_measure", config_file, &ini_config, 0, &error_list);
	if (ret)
	{
		loginfo_error ("config_from_file error %i (%s)", ret, parsing_error_str (ret));
		goto error;
	}

	/* Read the config file channel informations */
	{
		char section[255] = {'0'};
		char name[255] = {'0'};
		uint32_t nPowerComponents = 0;
	    uint32_t component = 0;
	    double doubleval;

		ret = get_config_item ("GLOBAL", "nPowerComponents", ini_config, &item);
		if (ret)
		{
			loginfo_error ("get_config_item [GLOBAL] nPowerComponents, error %i (%s)", ret, parsing_error_str (ret));
			goto error;
		}

		ui32val = get_uint32_config_value (item, 0, 0, &ret);
		if (ret)
		{
			loginfo_error ("get_uint32_config_value [GLOBAL] nPowerComponents, error %i (%s)", ret, parsing_error_str (ret));
			goto error;
		}
		config->nPowerComponents = ui32val;
		nPowerComponents = config->nPowerComponents;
		loginfo_debug ("nPowerComponents\t= %i",config->nPowerComponents);
		ret = get_config_item ("GLOBAL", "mf_url", ini_config, &item);
		if (ret)
		{
			loginfo_error ("get_config_item [GLOBAL] mf_url, error %i (%s)", ret, parsing_error_str (ret));
			goto error;
		}

		{
			const char *buff = get_const_string_config_value (item, &ret);
			strcpy (config->mf_url, buff);
		}

		if (ret)
		{
			loginfo_error ("get_const_string_config_value [GLOBAL] mf_url, error %i (%s)", ret, parsing_error_str (ret));
			goto error;
		}

		loginfo_debug ("mf_url\t= %s",config->mf_url);

		if(nPowerComponents	> 0 )
		{
			config_components = (struct components_t*) malloc(sizeof(struct components_t)*nPowerComponents);
			for (component=0; (component<nPowerComponents) && stop; component++)
		    {
			  sprintf (section, "COMPONENT_%i", component);

              /* New component */
              loginfo_debug ("[COMPONENT_%i]", component);
              sprintf (name, "id");

			  ret = get_config_item (section, name, ini_config, &item);
			  if (ret)
			  {
			  	loginfo_error ("get_config_item [COMPONENT_%i] id, error %i (%s)", component, ret, parsing_error_str (ret));
				goto error;
			  }
              ui32val = get_uint32_config_value (item, 0, 0, &ret);
			  if (ret)
			  {
				loginfo_error ("get_uint32_config_value [COMPONENT_%i] id, error %i (%s)", component, ret, parsing_error_str (ret));
				goto error;
			  }
			  config_components[component].id= ui32val;
			  loginfo_debug ("id\t= %i",config_components[component].id);
			  /* Read other values only if the channel is to be used */
			  if (ui32val<0)
				continue;

			  sprintf (name, "current_channel_id");

			  ret = get_config_item (section, name, ini_config, &item);
			  if (ret)
			  {
			  	loginfo_error ("get_config_item [COMPONENT_%i] current_channel_id, error %i (%s)", component, ret, parsing_error_str (ret));
				goto error;
			  }
              ui32val = get_uint32_config_value (item, 0, 0, &ret);
			  if (ret)
			  {
				loginfo_error ("get_uint32_config_value [COMPONENT_%i] current_channel_id, error %i (%s)", component, ret, parsing_error_str (ret));
				goto error;
			  }
			  config_components[component].current_channel_id= ui32val;
			  loginfo_debug ("current_channel_id\t= %i",config_components[component].current_channel_id);

			  
 			  sprintf (name, "current_board_id");

			  ret = get_config_item (section, name, ini_config, &item);
			  if (ret)
			  {
			  	loginfo_error ("get_config_item [COMPONENT_%i] current_board_id, error %i (%s)", component, ret, parsing_error_str (ret));
				goto error;
			  }
              ui32val = get_uint32_config_value (item, 0, 0, &ret);
			  if (ret)
			  {
				loginfo_error ("get_uint32_config_value [COMPONENT_%i] current_board_id, error %i (%s)", component, ret, parsing_error_str (ret));
				goto error;
			  }
			  config_components[component].current_board_id= ui32val;
			  loginfo_debug ("current_board_id\t= %i",config_components[component].current_board_id);

			  sprintf (name, "voltage_channel_id");

			  ret = get_config_item (section, name, ini_config, &item);
			  if (ret)
			  {
			  	loginfo_error ("get_config_item [COMPONENT_%i] voltage_channel_id, error %i (%s)", component, ret, parsing_error_str (ret));
				goto error;
			  }
              ui32val = get_uint32_config_value (item, 0, 0, &ret);
			  if (ret)
			  {
				loginfo_error ("get_uint32_config_value [COMPONENT_%i] voltage_channel_id, error %i (%s)", component, ret, parsing_error_str (ret));
				goto error;
			  }
			  config_components[component].voltage_channel_id= ui32val;
			  loginfo_debug ("voltage_channel_id\t= %i",config_components[component].voltage_channel_id);
   
             
             sprintf (name, "voltage_board_id");

			 ret = get_config_item (section, name, ini_config, &item);
			 if (ret)
			 {
			 	loginfo_error ("get_config_item [COMPONENT_%i] voltage_board_id, error %i (%s)", component, ret, parsing_error_str (ret));
			    goto error;
			 }
             ui32val = get_uint32_config_value (item, 0, 0, &ret);
			 if (ret)
			 {
			   loginfo_error ("get_uint32_config_value [COMPONENT_%i] voltage_board_id, error %i (%s)", component, ret, parsing_error_str (ret));
			   goto error;
			 }
			 config_components[component].voltage_channel_id= ui32val;
			 loginfo_debug ("voltage_board_id\t= %i",config_components[component].voltage_board_id);
			 
			 sprintf (name, "coeff1");

			 ret = get_config_item (section, name, ini_config, &item);
			 if (ret)
			 {
			 	loginfo_error ("get_config_item [COMPONENT_%i] coeff1, error %i (%s)", component, ret, parsing_error_str (ret));
				goto error;
			 }

			 doubleval = get_double_config_value (item, 0, 0, &ret);
			 if (ret)
			 {
			 	loginfo_error ("get_double_config_value [COMPONENT_%i] coeff1, error %i (%s)", component, ret, parsing_error_str (ret));
			 	goto error;
			 }
             config_components[component].coeff1 = doubleval;
             loginfo_debug ("coeff1\t= %lf", doubleval);
             
             sprintf (name, "coeff2");

			 ret = get_config_item (section, name, ini_config, &item);
			 if (ret)
			 {
			 	loginfo_error ("get_config_item [COMPONENT_%i] coeff2, error %i (%s)", component, ret, parsing_error_str (ret));
				goto error;
			 }

			 doubleval = get_double_config_value (item, 0, 0, &ret);
			 if (ret)
			 {
			 	loginfo_error ("get_double_config_value [COMPONENT_%i] coeff2, error %i (%s)", component, ret, parsing_error_str (ret));
			 	goto error;
			 }
             config_components[component].coeff2 = doubleval;
             loginfo_debug ("coeff2\t= %lf", doubleval);

			}
		   }
         }

	error:

	if (ini_config)
		free_ini_config (ini_config);

	if (error_list)
		free_ini_config_errors (error_list);

	return ret;
}
