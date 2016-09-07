
module power_hpc_config

use power_type

type, bind(c) :: components_t
  integer(kind=c_ik)                   :: id
  integer(kind=c_ik)                   :: measure_interval_micro_sec
  integer(kind=c_ik)                   :: current_channel_id
  integer(kind=c_ik)                   :: current_board_id
  integer(kind=c_ik)                   :: voltage_channel_id
  integer(kind=c_ik)                   :: voltage_board_id
  real(kind=c_rdk)                     :: coeff1
  real(kind=c_rdk)                     :: coeff2
  character(kind=c_char), dimension(64) :: label
end type components_t


type, bind(c) :: iniPowerConfig_t
  integer(kind=c_ik)                   :: nPowerComponents
  character(kind=c_char), dimension(64):: mf_url
  type(c_ptr)                    :: components_t;
end type iniPowerConfig_t

contains

function c_to_f_string(s) result(str)
  use iso_c_binding
  character(kind=c_char,len=1), intent(in) :: s(*)
  character(len=:), allocatable :: str
  integer i, nchars
  i = 1
  do
     if (s(i) == c_null_char) exit
     i = i + 1
  end do
  nchars = i - 1  ! Exclude null character from Fortran string
  allocate(character(len=nchars) :: str)
  str = transfer(s(1:nchars), str)
end function c_to_f_string
     
subroutine pstr(s) bind(c,name='pstr')
  use iso_c_binding
  character(kind=c_char,len=1), intent(in) :: s(*)
  write(*,'(a)') c_to_f_string(s)
end subroutine pstr
    
end module power_hpc_config
