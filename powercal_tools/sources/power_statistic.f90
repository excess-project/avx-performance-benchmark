module power_statistic

use power_type
use power_timestep
use power_rawdata
use power_input_parameter
implicit none

contains 

subroutine power_statistic_rawdata_filter_median(power_average_rawdata,power_rawdata,input_parameter,err_code)
  type(power_rawdata_type), intent(out)                      :: power_average_rawdata
  type(power_rawdata_type), intent(in)                       :: power_rawdata
  type(power_input_parameter_type), intent(in)               :: input_parameter
  integer(kind=ik),intent(out)                               :: err_code
  integer(kind=ik) :: rawdata_length, ii, jj, length, step_left,step_right
  real(kind=rk) :: average,sum_right, sum_left, sum
  
  err_code = 0_ik
  rawdata_length = size(power_rawdata%rawdata)
  allocate(power_average_rawdata%rawdata(rawdata_length))
  step_left = input_parameter%window_step_left
  step_right = input_parameter%window_step_right
  do ii=1_ik,step_left
    sum_right = 0_rk
    sum_left = 0_rk
    length = 1_ik
    do jj=ii+1_ik,ii+step_right
      sum_right = sum_right + real(power_rawdata%rawdata(jj),kind=rk)
      length = length+ 1_ik
    end do
    do jj=1_ik,ii-1_ik
      sum_left = sum_left + real(power_rawdata%rawdata(jj),kind=rk)
     length = length+ 1_ik
    end do
    sum = sum_right + sum_left + power_rawdata%rawdata(ii)
    average = sum / length
    power_average_rawdata%rawdata(ii) = real(average,kind=rdk)
  end do
  
  do ii=step_left+1_ik,rawdata_length-step_right
    sum_right = 0_rk
    sum_left = 0_rk
    length = 1_ik
     do jj=ii+1_ik,ii+step_right
      sum_right = sum_right + real(power_rawdata%rawdata(jj),kind=rk)
      length = length+ 1_ik
    end do
    do jj=ii-step_left,ii-1_ik
      sum_left = sum_left + real(power_rawdata%rawdata(jj),kind=rk)
     length = length+ 1_ik
    end do
    sum = sum_right + sum_left + power_rawdata%rawdata(ii)
    average = sum / length
    power_average_rawdata%rawdata(ii) = real(average,kind=rdk)
  end do 
  
  do ii=rawdata_length-step_right + 1_ik, rawdata_length
    sum_right = 0_rk
    sum_left = 0_rk
    length = 1_ik
    do jj=ii-step_left,ii-1_ik
      sum_left = sum_left + real(power_rawdata%rawdata(jj),kind=rk)
      length = length+ 1_ik
    end do
    do jj=ii+1_ik,rawdata_length
      sum_right = sum_right + real(power_rawdata%rawdata(jj),kind=rk)
      length = length+ 1_ik
    end do
    sum = sum_right + sum_left + power_rawdata%rawdata(ii)
    average = sum / length
    power_average_rawdata%rawdata(ii) = real(average,kind=rdk)
  end do
 
 end subroutine power_statistic_rawdata_filter_median
 
 subroutine power_statistic_rawdata_filter_average(power_average_rawdata,power_rawdata,input_parameter,err_code)
  type(power_rawdata_type), intent(out)                      :: power_average_rawdata
  type(power_rawdata_type), intent(in)                       :: power_rawdata
  type(power_input_parameter_type), intent(in)               :: input_parameter
  integer(kind=ik),intent(out)                               :: err_code
  integer(kind=ik) :: rawdata_length, ii, jj, rawdata_rest_length, average_window, num_windows
  integer(kind=ik) :: start_idx, end_idx
  real(kind=rk) :: sum
  real(kind=rdk) :: average
  err_code = 0_ik
  rawdata_length = size(power_rawdata%rawdata)
  allocate(power_average_rawdata%rawdata(rawdata_length))
  average_window = input_parameter%window_step_left+input_parameter%window_step_right
  num_windows = rawdata_length / average_window
  rawdata_rest_length = rawdata_length - num_windows * average_window
  do ii=1_ik,num_windows
    sum = 0.0
    start_idx = (ii-1_ik)*average_window + 1_ik
    end_idx = (ii)*average_window
    do jj=start_idx,end_idx
      sum = sum + real(power_rawdata%rawdata(jj),kind=rk)
    end do
    average = real(sum / (end_idx-start_idx+1_ik),kind=rdk)
    power_average_rawdata%rawdata(start_idx:end_idx) = average
  end do
  sum = 0.0
  start_idx = average_window*num_windows+1_ik
  end_idx = rawdata_length
  do ii=start_idx,end_idx
    sum = sum + real(power_rawdata%rawdata(ii),kind=rk)
  end do
  average = real(sum / (end_idx-start_idx+1_ik),kind=rdk)
  power_average_rawdata%rawdata(start_idx:end_idx) = average
 end subroutine power_statistic_rawdata_filter_average

end module power_statistic
