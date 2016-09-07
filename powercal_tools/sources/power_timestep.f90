module power_timestep
use power_type
use power_input_parameter
implicit none
type power_timestep_type

 integer(kind=itk) tv_sec
 integer(kind=itk) tv_nsec

end type
type power_timesteps_sec_type
 real(kind=rk),allocatable,dimension(:) :: sec
end type

contains

subroutine power_timesteps_read(timesteps,input_parameters,err_code)
 type(power_timestep_type), dimension(:), allocatable,intent(out) :: timesteps
 type(power_input_parameter_type) ,intent(in)                     :: input_parameters !user input
 integer(kind=ik),intent(out)            :: err_code
 character(len=str_length) :: filepath
 integer(kind=ik) :: unit_nr, record_length, file_size, num_records
 integer(kind=ik) :: ii

 unit_nr = 1000_ik
 err_code = 0_ik
 write(filepath,'(A,A,A,I0,A,A)') trim(input_parameters%topdir),&
    trim(input_parameters%prefixtime),&
    "_",input_parameters%board_id,&
    ".",trim(input_parameters%extension)
 !-Direct access with record length = power_timestamp size * num_records
 record_length = 2_ik*itk
 if (input_parameters%verbosity) then
   write(power_output_unit,"(A,A)") "power_timesteps_read open file:", trim(filepath)
 endif
 inquire(FILE=trim(filepath), SIZE=file_size, iostat = err_code)
 if(err_code .ne. 0_ik) then
   write(*,'(A,I0)') "Error power_read_timesteps inquire:",err_code
   stop
 end if
 if (input_parameters%verbosity) then
  write(power_output_unit,"(A,I0,A)") "power_timesteps_read file size is ", file_size, " bytes"
 endif
 num_records = file_size / record_length
 if(num_records .le. 0_ik) then
  write(*,'(A,I0)') "Error power_read_timesteps num_records:",num_records
  stop
 end if
 allocate(timesteps(num_records))
 open(unit = unit_nr, file = filepath, status = 'old', action = 'read', access = 'direct',&
 RECL = record_length, iostat = err_code)
 if(err_code .ne. 0_ik) then
   write(*,'(A,I0)')  "Error power_read_timesteps open:",err_code
   stop
 end if
 do ii=1, num_records
   read(unit=unit_nr, rec=ii, iostat = err_code) timesteps(ii)
   if(err_code .ne. 0_ik)  then
     write(*,'(A,I0)') "Error power_read_timesteps read:",err_code
     stop
  end if
 end do
 close(unit_nr)
 if (input_parameters%verbosity) then
   write(power_output_unit,"(A,A)") "power_timesteps_read closed file:", trim(filepath)
 endif
end subroutine power_timesteps_read

subroutine power_timesteps_print(timesteps,err_code)
 type(power_timestep_type), dimension(:), intent(in) :: timesteps
 integer(kind=ik),intent(out)                    :: err_code
 integer(kind=ik) :: ii, length
 real(kind=rtk) :: first, current
 err_code = 0_itk
 first = real(timesteps(1)%tv_sec,kind=rtk)+real(timesteps(1)%tv_nsec,kind=rtk)*1.0e-9
 length = size(timesteps)
 do ii=1, length
  current = real(timesteps(ii)%tv_sec,kind=rtk)+real(timesteps(ii)%tv_nsec,kind=rtk)*1.0e-9
  current = current - first
  write(power_output_unit,'(I3,A,E16.6,A,I12,A,I12)')ii,": ", current,"; ",timesteps(ii)%tv_sec,&
   "; ",timesteps(ii)%tv_nsec
 end do
 
end subroutine power_timesteps_print

subroutine power_timesteps_to_timesteps_sec(timesteps,offset_sec,input_parameters,timesteps_sec,seq_interval_sec,err_code)
 type(power_timestep_type), dimension(:), intent(in)         :: timesteps
 real(kind=rk)                                               :: offset_sec
 type(power_input_parameter_type) ,intent(in)                :: input_parameters !user input
 type(power_timesteps_sec_type), intent(out)                 :: timesteps_sec
 real(kind=rk)     , intent(out)                             :: seq_interval_sec
 integer(kind=ik),intent(out)                                :: err_code
 
 integer(kind=ik) :: timesteps_num
 integer(kind=ik) :: ii
 real(kind=rk) :: interval_sum
 err_code = 0_ik
 timesteps_num = size(timesteps)
 allocate(timesteps_sec%sec(timesteps_num)) 
 
 do ii=1, timesteps_num
   timesteps_sec%sec(ii) = real(timesteps(ii)%tv_sec,kind=rtk)+&
    real(timesteps(ii)%tv_nsec,kind=rtk)*1.0e-9-&
    offset_sec
 end do
 interval_sum = 0.0
 do ii=1, timesteps_num - 1_ik
    interval_sum = interval_sum + timesteps_sec%sec(ii+1_ik)-timesteps_sec%sec(ii)
 end do

 seq_interval_sec = interval_sum / real(timesteps_num - 1_ik,kind=rk)
 if (input_parameters%verbosity) then
   write(power_output_unit,"(A,E15.9)")&
     "power_timesteps_to_timesteps_sec: average sequent duration:",seq_interval_sec
 endif
end subroutine power_timesteps_to_timesteps_sec

end module power_timestep
