
module power_hpc_config_interface

use power_type
use power_hpc_config

interface

function hpc_read_power_config_file(configfile_path, iniPowerConfig, components) result(error_code) &
   bind(c, name = 'hpc_read_power_config_file_fortran')
   use, intrinsic :: iso_c_binding
   use :: power_hpc_config
   character(kind=c_char), dimension(*)  :: configfile_path
   type(iniPowerConfig_t) :: iniPowerConfig
   type(components_t), dimension(*)  :: components
   integer(kind = C_INT)                 :: error_code
end function hpc_read_power_config_file

end interface

end module power_hpc_config_interface
