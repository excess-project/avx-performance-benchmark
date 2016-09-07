/** @file hpc_config.h
 *
 *
 * @author D. Khabi
 *
 * @par LICENCE
 * @verbatim



 * @endverbatim
 *
 */

#ifndef HPC_CONFIG_H_
#define HPC_CONFIG_H_

//---------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------

/**@struct board_t
 * power channel configuration informations.
 */
struct components_t
{
	int id;
	int current_channel_id;
	int current_board_id;
	int voltage_channel_id;
	int voltage_board_id;
	float coeff1;
	float coeff2;
    char label[64];
};
//---------------------------------------------------------------------------------------

/**@struct iniPowerConfig_t
 * - Global informations about the measured cluster components.
 * - Cluster components informations.
 */
struct iniPowerConfig_t
{
	int nPowerComponents;
	char mf_url[1024];
};
//---------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------
/** Read configuration informations about measured cluster components from the config file.
 *
 * @param [in] power_config_file: Path to the configuration file.
 * @param [in,out] iniPowerConfig_t: Configuration structure.
 * @retval 0 No error.
 * @retval != 0 Error.
 */
int hpc_read_power_config_file (const char * config_file, struct iniPowerConfig_t * config);
//---------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------

#endif /* HPC_CONFIG_H_ */
