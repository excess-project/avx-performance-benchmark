module power_rawdata

use power_type
use power_timestep
use power_input_parameter
implicit none
type power_rawdata_type
 real(kind=rdk),allocatable, dimension(:) :: rawdata
 integer(kind=ik)                         :: rawdata_seq_num
end type
contains

subroutine power_power_rawdata_read(power_rawdata,timesteps,input_parameters,err_code)
 type(power_rawdata_type), intent(out)                       :: power_rawdata
 type(power_timestep_type), dimension(:), intent(in)         :: timesteps
 type(power_input_parameter_type)                            :: input_parameters
 integer(kind=ik),intent(out)                                :: err_code
 integer(kind=ik) :: unit_nr, record_length, file_size
 integer(kind=ik) :: ii, timesteps_num,rawdata_num, rawdata_seq_num
 character(len=str_length)    :: filepath_channel
 integer(kind=ik) :: start_record, end_record
 unit_nr = 1010_ik
 err_code = 0_ik
 timesteps_num = size(timesteps)
 rawdata_num = -1_ik
 
 do ii=1_ik,timesteps_num
   write(filepath_channel,'(A,A,A,I0,A,I0,A,I0,A,A)') trim(input_parameters%topdir),&
    trim(input_parameters%prefixchannel),&
    "_",input_parameters%channel_id,&
    "_",timesteps(ii)%tv_sec,&
    "_",timesteps(ii)%tv_nsec,&
    ".",trim(input_parameters%extension)
    if (input_parameters%verbosity) then
     write(power_output_unit,"(A,A)") "power_power_rawdata_read open file:", trim(filepath_channel)
    end if
    if(ii .eq. 1_ik) then
      inquire(FILE=trim(filepath_channel), SIZE=file_size, iostat = err_code)
      if(err_code .ne. 0_ik) write(*,'(A,I0)') "Error power_power_rawdata_read inquire:",err_code
      record_length = file_size
      rawdata_seq_num = file_size / rdk
      power_rawdata%rawdata_seq_num = rawdata_seq_num
      rawdata_num = rawdata_seq_num * timesteps_num
      allocate(power_rawdata%rawdata(rawdata_num))
      if (input_parameters%verbosity) then
        write(power_output_unit,"(A,I0,A)") &
          "power_power_rawdata_read file size is ", file_size, " bytes"
      end if
    end if
    open(unit = unit_nr, file = filepath_channel, status = 'old', action = 'read', access = 'direct',&
     recl = record_length / IO_RECORD_UNIT_LENGTH , iostat = err_code)
    if(err_code .ne. 0_ik) write(*,'(A,I0)') "Error power_power_rawdata_read open:",err_code
    start_record = (ii-1_ik)*rawdata_seq_num+1_ik
    end_record = start_record+rawdata_seq_num-1_ik
    if (input_parameters%verbosity) then
      write(power_output_unit,"(A,I10,A,I10)") "read raw data:",start_record,"-",end_record
    end if
    read(unit=unit_nr, rec=1_ik, iostat = err_code) power_rawdata%rawdata(start_record:end_record)
    if(err_code .ne. 0_ik) write(*,'(A,I0)') "Error power_power_rawdata_read read:",err_code
    close(unit_nr)
 end do

end subroutine power_power_rawdata_read

subroutine power_power_rawdata_print(power_rawdata,err_code)
 type(power_rawdata_type), intent(in)                 :: power_rawdata
 integer(kind=ik),intent(out)                         :: err_code
 integer(kind=ik) :: ii, length
 err_code = 0_itk
 
 length = size(power_rawdata%rawdata)
 do ii=1, length
  write(*,'(I10,A,E16.6)')ii,": ", power_rawdata%rawdata(ii)
 end do
 
end subroutine power_power_rawdata_print

subroutine power_power_rawdata_average(average,power_rawdata,err_code)
 real(kind=rk), intent(out)                           :: average
 type(power_rawdata_type), intent(in)                 :: power_rawdata
 integer(kind=ik),intent(out)                         :: err_code
 integer(kind=ik) :: ii, length

 err_code = 0_itk
 average = 0_rk
 length = size(power_rawdata%rawdata)
 do ii=1, length
  average = average + power_rawdata%rawdata(ii)
 end do
 average = average / length
end subroutine power_power_rawdata_average

subroutine power_power_rawdata_write(power_rawdata,num_records,file_prefix,input_parameters,err_code)
 type(power_rawdata_type), intent(in)                        :: power_rawdata
 integer(kind=ik), intent(in)                                :: num_records
 character(len=*) , intent(in)                               :: file_prefix
 type(power_input_parameter_type)                            :: input_parameters
 integer(kind=ik),intent(out)                                :: err_code
 character(len=str_length)    :: filename
 integer(kind=ik) :: length, rec_length
 integer(kind=ik) :: unit_nr, ii, start_idx, end_idx
 
 unit_nr = 1020
 write(filename,'(A,A,A,I0,A,A)') trim(input_parameters%out_topdir),&
    trim(file_prefix),&
    "_",input_parameters%channel_id,&
    ".",trim(input_parameters%out_extension)
 length = size(power_rawdata%rawdata) / num_records
 rec_length = length*rdk/ IO_RECORD_UNIT_LENGTH
 if (input_parameters%verbosity) then
   write(power_output_unit,'(A,A)') "power_power_rawdata_write file:" , trim(filename)
   write(power_output_unit,'(A,I0)') "power_power_rawdata_write rec_length:" , rec_length
   write(power_output_unit,'(A,I0)') "power_power_rawdata_write num_records:" , num_records
 end if
 open(unit = unit_nr, file = trim(filename), status = 'replace', action = 'write', access = 'direct', &
  &recl = rec_length , iostat = err_code)
 if(err_code .ne. 0_ik) write(*,'(A,I0)') "Error power_power_rawdata_write open:",err_code
 do ii=1,num_records
  start_idx = (ii-1_ik)*length + 1_ik
  end_idx = ii*length
  write(unit_nr, rec = ii) power_rawdata%rawdata(start_idx:end_idx)
 end do
 close(unit_nr)
 
end subroutine power_power_rawdata_write

end module power_rawdata
