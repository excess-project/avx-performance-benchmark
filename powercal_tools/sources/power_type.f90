module power_type

use, intrinsic :: ISO_C_BINDING
implicit none

  integer, parameter :: rk = 8 ! type for real
  integer, parameter :: ik = 8 ! type for index format
  integer, parameter :: itk = 8! type for timer
  integer, parameter :: rtk = 8! type for timer
  integer, parameter :: rdk = 4! type for channel's rawdata
  integer, parameter :: lk = 4 ! type for logical
  
  integer, parameter :: c_rdk = C_FLOAT !shoul be changed by changing of rdk
  integer, parameter :: c_ik = C_INT!C_INT!C_LONG !shoul be changed by changing of ik

  integer, parameter :: real_kind = rk
  doubleprecision ref_variable
  doubleprecision db_variable
  integer(kind=ik),parameter                         :: r_high=kind(db_variable)
  integer(kind=ik),parameter                         :: complex_kind=kind(ref_variable)
  integer(kind=ik),parameter                         :: str_length=1024
  real(kind=rk),parameter                            :: Pi=3.14159265358979323846264338328_rk
  complex(kind=complex_kind),parameter      :: imag=(0._real_kind,1._rk)
  integer(kind=ik),parameter                         :: integr=1
  integer(kind=ik),parameter                         :: infinity=huge(integr)
  character(len=53),parameter ::  &
&  alpha_chars='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_'
!!              123456789 123456789 123456789 123456789 123456789 123456789
  character(len=10),parameter  :: digits='0123456789'
  character(len=1),parameter  :: nonsignificant_chars=' '
  character(len=len(alpha_chars)+len(digits)),parameter  :: variable_chars=alpha_chars//digits

  integer:: power_output_unit=6
  integer:: power_error_unit=0
  
  integer :: IO_RECORD_UNIT_LENGTH = 1 !4 - Intel; 1 - GNU; 1 - CRAY
  
end module power_type

