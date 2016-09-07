module power_operations

use power_type
use power_timestep
use power_rawdata
use power_input_parameter
implicit none

contains 
!power_data = power_data1 - alpha*power_data2
subroutine power_operation_sub(power_data,norm_2,power_data1,alpha,power_data2,input_parameter,err_code)
  type(power_rawdata_type), intent(out)                      :: power_data
  real(kind=rk), intent(out)                                 :: norm_2
  type(power_rawdata_type), intent(in)                       :: power_data1
  real(kind=rk), intent(in)                                  :: alpha
  type(power_rawdata_type), intent(in)                       :: power_data2
  type(power_input_parameter_type), intent(in)               :: input_parameter
  integer(kind=ik),intent(out)                               :: err_code
  integer(kind=ik) :: rawdata_length
  
  err_code = 0_ik
  rawdata_length = size(power_data1%rawdata)
  allocate(power_data%rawdata(rawdata_length))
  power_data%rawdata(1:rawdata_length) = real( real(power_data1%rawdata(1:rawdata_length),kind=rk) - &
   alpha*real(power_data2%rawdata(1:rawdata_length),kind=rk) ,kind=rdk)
  norm_2 = NORM2(power_data%rawdata(1:rawdata_length))
  !if(input_parameter%verbosity ) then
  !  ;
  !end if
 end subroutine power_operation_sub
 
!alpha for min of norm2 of power_data = power_data1 - alpha*power_data2
subroutine power_operation_find_min_alpha(alpha, norm_2, power_data,power_data1,power_data2,input_parameter,err_code)
  real(kind=rk), intent(out)                                 :: alpha
  type(power_rawdata_type), intent(out)                      :: power_data
  real(kind=rk), intent(out)                                 :: norm_2
  type(power_rawdata_type), intent(in)                       :: power_data1
  type(power_rawdata_type), intent(in)                       :: power_data2
  type(power_input_parameter_type), intent(in)               :: input_parameter
  integer(kind=ik),intent(out)                               :: err_code
  integer(kind=ik) :: rawdata_length, ii, num_tests
  real(kind=rdk) :: norm2_data1, norm2_data2
  real(kind=rk) :: current_aplha
  real(kind=rk), allocatable, dimension(:) :: norm2_difference
  integer(kind=ik),  dimension(1) :: min_index
  err_code = 0
  rawdata_length = size(power_data1%rawdata)
  num_tests = int((input_parameter%alpha_max-input_parameter%alpha_min)/input_parameter%alpha_step + 1_ik,kind=ik)
  if(num_tests .lt. 1) then
    write(power_output_unit,'(A,I0)'  ) "Error power_operation_find_min_alpha: no alpha steps:",num_tests
  end if
  allocate(norm2_difference(num_tests))
  norm2_data1 = NORM2(power_data1%rawdata(1:rawdata_length))
  norm2_data2 = NORM2(power_data2%rawdata(1:rawdata_length))
  current_aplha = input_parameter%alpha_min
  ii = 1_ik
  write(power_output_unit,'(A,I0)'  ) "num_tests begin:", num_tests
  do while(ii .le. num_tests)
    write(power_output_unit,'(A,I0)'  ) "ii:",ii
    call power_operation_sub(power_data,norm2_difference(ii),power_data1,current_aplha,power_data2,input_parameter,err_code)
    ii = ii + 1_ik
    current_aplha = current_aplha + input_parameter%alpha_step
  end do
  
  write(power_output_unit,'(A,I0)'  ) "num_tests end:", num_tests
  write(power_output_unit,*  ) norm2_difference(1:num_tests)
  norm_2 = MINVAL(norm2_difference(1:num_tests))
  min_index = MINLOC(norm2_difference(1:num_tests))
  alpha = input_parameter%alpha_min + REAL(min_index(1)-1_ik,kind=rdk)*input_parameter%alpha_step
  call power_operation_sub(power_data,norm_2,power_data1,alpha,power_data2,input_parameter,err_code)
  !if(input_parameter%verbosity ) then
  !  ;
  !end if
end subroutine power_operation_find_min_alpha

end module power_operations
