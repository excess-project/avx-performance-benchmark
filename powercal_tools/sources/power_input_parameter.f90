module power_input_parameter
use power_type
use power_extract_command

implicit none


type power_input_parameter_type
  logical(kind=lk)        :: verbosity
  integer(kind=ik)        :: verbosity_level
  integer(kind=ik)        :: channel_id
  integer(kind=ik)        :: board_id
  integer(kind=ik)        :: window_step_left
  integer(kind=ik)        :: window_step_right
  integer(kind=ik)        :: average_window
  character(len=str_length)     :: topdir
  character(len=str_length)     :: prefixtime
  character(len=str_length)     :: prefixchannel
  character(len=str_length)     :: extension
  character(len=str_length)     :: out_extension
  character(len=str_length)     :: out_topdir
  character(len=str_length)     :: out_prefixchannel
  character(len=str_length)     :: operation
  character(len=str_length)     :: out_diff_prefixchannel
  character(len=str_length)     :: config_file
  real(kind=rk)                :: alpha_min
  real(kind=rk)                :: alpha_max
  real(kind=rk)                :: alpha_step
  real(kind=rk)                 :: phase_start_sec
  real(kind=rk)                 :: phase_start_microsec
  real(kind=rk)                 :: phase_start_nanosec
  real(kind=rk)                 :: phase_end_sec
  real(kind=rk)                 :: phase_end_microsec
  real(kind=rk)                 :: phase_end_nanosec
  real(kind=rk)                 :: offset_sec
  real(kind=rk)                 :: offset_microsec
  real(kind=rk)                 :: offset_nanosec
  logical(kind=lk)              :: relative_time

  character(len=str_length)     :: performance_file !input file
  character(len=str_length)     :: power_file      !output file for power
  character(len=str_length)     :: energy_file      !output file for energy
  character(len=str_length)     :: joule_per_flop_file      !output file for joule/flop
end type power_input_parameter_type


contains 

subroutine power_input_parameter_print(input_parameters)
type(power_input_parameter_type),intent(in) :: input_parameters
  write(power_output_unit,*)"power consumption module parameters:"
  write(power_output_unit,*)"verbosity:", input_parameters%verbosity
  write(power_output_unit,*)"verbosity_level:", input_parameters%verbosity_level
  write(power_output_unit,*)"channel_id:",input_parameters%channel_id
  write(power_output_unit,*)"board_id:",input_parameters%board_id
  write(power_output_unit,*)"window_step_left:",input_parameters%window_step_left
  write(power_output_unit,*)"window_step_right:",input_parameters%window_step_right
  write(power_output_unit,*)"topdir:",trim(input_parameters%topdir)
  write(power_output_unit,*)"prefixtime:",trim(input_parameters%prefixtime)
  write(power_output_unit,*)"prefixchannel:",trim(input_parameters%prefixchannel)
  write(power_output_unit,*)"extension:",trim(input_parameters%extension)
  write(power_output_unit,*)"out_topdir:",trim(input_parameters%out_topdir)
  write(power_output_unit,*)"operation:",trim(input_parameters%operation)
  write(power_output_unit,*)"out_prefixchannel:",trim(input_parameters%out_prefixchannel)
  write(power_output_unit,*)"out_diff_prefixchannel:",trim(input_parameters%out_diff_prefixchannel)
  write(power_output_unit,*)"out_extension:",trim(input_parameters%out_extension)
  write(power_output_unit,*)"alpha_min:",input_parameters%alpha_min
  write(power_output_unit,*)"alpha_max:",input_parameters%alpha_max
  write(power_output_unit,*)"alpha_step:",input_parameters%alpha_step
  write(power_output_unit,*)"config_file:",trim(input_parameters%config_file)
  write(power_output_unit,*)"phase_start_sec:",input_parameters%phase_start_sec
  write(power_output_unit,*)"phase_start_microsec:",input_parameters%phase_start_microsec
  write(power_output_unit,*)"phase_start_nanosec:",input_parameters%phase_start_nanosec
  write(power_output_unit,*)"phase_end_sec:",input_parameters%phase_end_sec
  write(power_output_unit,*)"phase_end_microsec:",input_parameters%phase_end_microsec
  write(power_output_unit,*)"phase_end_nanosec:",input_parameters%phase_end_nanosec
  write(power_output_unit,*)"offset_sec:",input_parameters%offset_sec
  write(power_output_unit,*)"offset_microsec:",input_parameters%offset_microsec
  write(power_output_unit,*)"offset_nanosec:",input_parameters%offset_nanosec
  write(power_output_unit,*)"relative_time:",input_parameters%relative_time

  write(power_output_unit,*)"performance_file:",trim(input_parameters%performance_file)
  write(power_output_unit,*)"power_file:",trim(input_parameters%power_file)
  write(power_output_unit,*)"energy_file:",trim(input_parameters%energy_file)
  write(power_output_unit,*)"joule_per_flop_file:",trim(input_parameters%joule_per_flop_file)
  
 end subroutine power_input_parameter_print

subroutine power_input_parameter_def(input_parameters)
type(power_input_parameter_type),intent(inout) :: input_parameters

  input_parameters%verbosity = .FALSE._lk
  input_parameters%verbosity_level = 0_ik
  input_parameters%channel_id = 0_ik
  input_parameters%channel_id = 0_ik
  input_parameters%window_step_left = 3_ik
  input_parameters%window_step_right = 3_ik
  input_parameters%average_window = 10_ik
  input_parameters%alpha_min = 0.9_rdk
  input_parameters%alpha_max = 1.0_rdk
  input_parameters%alpha_step = .01_rdk
  write(input_parameters%topdir,'(A)') "./"
  write(input_parameters%prefixtime,'(A)') "Time"
  write(input_parameters%prefixchannel,'(A)') "Channel"
  write(input_parameters%extension,'(A)') "dat"
  write(input_parameters%out_extension,'(A)') "dat"
  write(input_parameters%out_topdir,'(A)') "./"
  write(input_parameters%out_prefixchannel,'(A)') "Channel_filter_median"
  write(input_parameters%out_diff_prefixchannel,'(A)') "Channel_diff"
  write(input_parameters%operation,'(A)') "mean"
  write(input_parameters%config_file,'(A)') "undef"
  
  input_parameters%phase_start_sec=0.0_rk
  input_parameters%phase_start_microsec=0.0_rk
  input_parameters%phase_start_nanosec=0.0_rk
  input_parameters%phase_end_sec=0.0_rk
  input_parameters%phase_end_microsec=0.0_rk
  input_parameters%phase_end_nanosec=0.0_rk
  input_parameters%offset_sec=0.0_rk
  input_parameters%offset_microsec=0.0_rk
  input_parameters%offset_nanosec=0.0_rk
  input_parameters%relative_time=.false._lk

  write(input_parameters%performance_file,'(A)') "unknown.dat"
  write(input_parameters%power_file,'(A)') "unknown_power.dat"
  write(input_parameters%energy_file,'(A)') "unknown_energy.dat"
  write(input_parameters%joule_per_flop_file,'(A)') "unknown_joule_per_flop_file.dat"
  
end subroutine power_input_parameter_def


subroutine power_input_parameter_check(input_parameters, err_code)
  type(power_input_parameter_type),intent(in) :: input_parameters
  integer(kind=ik),intent(out)            :: err_code

  err_code = 0_ik
  if(input_parameters%channel_id .lt. 0) err_code = 1_ik
end subroutine power_input_parameter_check

subroutine power_input_parameter_read(input_parameters, err_code)
  type(power_input_parameter_type),intent(out) :: input_parameters
  integer(kind=ik),intent(out)                 :: err_code
  character(len=2048) :: cmd
  character(len=2048) :: message
  character(len=256) :: config_file
  integer(kind=ik) :: help
  integer(kind=ik) :: int_temp
  
  err_code = 0_ik
  help = -1_ik
  int_temp = 0_ik
  call power_input_parameter_def(input_parameters)
  call get_command(cmd)
  !write(*,'(3a)') 'command_line is "',trim(cmd),'"'
  message='parameters of power consumption module' &
      &//' -verbosity <int> ' &
      &//' -topdir <filenames> ' &
      &//' -out_topdir <filenames> ' &
      &//' -operation <string> ' &
      &//' -prefixtime <string> ' &
      &//' -prefixchannel <string> ' &
      &//' -out_prefixchannel <string> ' &
      &//' -out_diff_prefixchannel <string> ' &
      &//' -extension <extension> ' &
      &//' -out_extension <extension> ' &
      &//' -channel_id <int>' &
      &//' -board_id <int>' &
      &//' -window_step_left <int>' &
      &//' -window_step_right <int>' &
      &//' -average_window <int>' &
      &//' -alpha_min <real>' &
      &//' -alpha_max <real>' &
      &//' -alpha_step <real>' &
      &//' -config_file <filenames>' &
      &//' -phase_start_sec<real>' &
      &//' -phase_start_microsec<real>' &
      &//' -phase_start_nanosec<real>' &
      &//' -phase_end_sec<real>' &
      &//' -phase_end_microsec<real>' &
      &//' -phase_end_nanosec<real>' &
      &//' -offset_sec<real>' &
      &//' -offset_microsec<real>' &
      &//' -offset_nanosec<real>' &
      &//' -relative_time<int>' &
      &//' -help <int>' &
      &//' -performance_file <filenames> '&
      &//' -power_file <filenames> '&
      &//' -energy_file <filenames> '&
      &//' -joule_per_flop_file <filenames> '
  if(power_extract_command_parameter(cmd,'-help',stop_on_error=.false.,&
                value=help, syntax=message) ==0) then
      if(help .GE. 0) then
        write (*,'(A)') trim(message)
        if(help .GT. 0) then
          stop
        endif
      end if
  endif
  
  if(power_extract_command_parameter(cmd,'-verbosity',stop_on_error=.false.,&
                value=input_parameters%verbosity_level,syntax=message) /=0) then
  endif
  if(power_extract_command_parameter(cmd,'-topdir',stop_on_error=.false.,&
                value=input_parameters%topdir,&
                syntax=message) /=0) then
  endif
  if(power_extract_command_parameter(cmd,'-config_file',stop_on_error=.true.,&
                value=config_file,&
                syntax=message) /=0) then
  endif
  if(power_extract_command_parameter(cmd,'-operation',stop_on_error=.false.,&
                value=input_parameters%operation,&
                syntax=message) /=0) then
  endif
  if(power_extract_command_parameter(cmd,'-out_topdir',stop_on_error=.false.,&
                value=input_parameters%out_topdir,&
                syntax=message) /=0) then
  endif
  if(power_extract_command_parameter(cmd,'-prefixtime',stop_on_error=.false.,&
                value=input_parameters%prefixtime,&
                syntax=message) /=0) then
  endif
  if(power_extract_command_parameter(cmd,'-prefixchannel',stop_on_error=.false.,&
                value=input_parameters%prefixchannel,&
                syntax=message) /=0) then
  endif
  if(power_extract_command_parameter(cmd,'-out_prefixchannel',stop_on_error=.false.,&
                value=input_parameters%out_prefixchannel,&
                syntax=message) /=0) then
  endif
  if(power_extract_command_parameter(cmd,'-out_diff_prefixchannel',stop_on_error=.false.,&
                value=input_parameters%out_diff_prefixchannel,&
                syntax=message) /=0) then
  endif
  if(power_extract_command_parameter(cmd,'-extension',stop_on_error=.false.,&
                value=input_parameters%extension,&
                syntax=message) /=0) then
  endif
  if(power_extract_command_parameter(cmd,'-out_extension',stop_on_error=.false.,&
                value=input_parameters%out_extension,&
                syntax=message) /=0) then
  endif
  if(power_extract_command_parameter(cmd,'-channel_id',stop_on_error=.false.,&
                value=input_parameters%channel_id,syntax=message) /=0) then
  endif
  if(power_extract_command_parameter(cmd,'-board_id',stop_on_error=.false.,&
                value=input_parameters%board_id,syntax=message) /=0) then
  endif
  if(power_extract_command_parameter(cmd,'-window_step_left',stop_on_error=.false.,&
                value=input_parameters%window_step_left,syntax=message) /=0) then
  endif
  if(power_extract_command_parameter(cmd,'-window_step_right',stop_on_error=.false.,&
                value=input_parameters%window_step_right,syntax=message) /=0) then
  endif
  if(power_extract_command_parameter(cmd,'-average_window',stop_on_error=.false.,&
                value=input_parameters%average_window,syntax=message) /=0) then
  endif
  if(power_extract_command_parameter(cmd,'-alpha_min',stop_on_error=.false.,&
                value=input_parameters%alpha_min,syntax=message) /=0) then
  endif
  if(power_extract_command_parameter(cmd,'-alpha_max',stop_on_error=.false.,&
                value=input_parameters%alpha_max,syntax=message) /=0) then
  endif
  if(power_extract_command_parameter(cmd,'-alpha_step',stop_on_error=.false.,&
                value=input_parameters%alpha_step,syntax=message) /=0) then
  endif
  if(power_extract_command_parameter(cmd,'-phase_start_sec',stop_on_error=.false.,&
                value=input_parameters%phase_start_sec,syntax=message) /=0) then
  endif
  if(power_extract_command_parameter(cmd,'-phase_start_microsec',stop_on_error=.false.,&
                value=input_parameters%phase_start_microsec,syntax=message) /=0) then
  endif
  if(power_extract_command_parameter(cmd,'-phase_start_nanosec',stop_on_error=.false.,&
                value=input_parameters%phase_start_nanosec,syntax=message) /=0) then
  endif
  if(power_extract_command_parameter(cmd,'-phase_end_sec',stop_on_error=.false.,&
                value=input_parameters%phase_end_sec,syntax=message) /=0) then
  endif
  if(power_extract_command_parameter(cmd,'-phase_end_microsec',stop_on_error=.false.,&
                value=input_parameters%phase_end_microsec,syntax=message) /=0) then
  endif
  if(power_extract_command_parameter(cmd,'-phase_end_nanosec',stop_on_error=.false.,&
                value=input_parameters%phase_end_nanosec,syntax=message) /=0) then
  endif  
  if(power_extract_command_parameter(cmd,'-offset_sec',stop_on_error=.false.,&
                value=input_parameters%offset_sec,syntax=message) /=0) then
  endif
  if(power_extract_command_parameter(cmd,'-offset_microsec',stop_on_error=.false.,&
                value=input_parameters%offset_microsec,syntax=message) /=0) then
  endif
  if(power_extract_command_parameter(cmd,'-offset_nanosec',stop_on_error=.false.,&
                value=input_parameters%offset_nanosec,syntax=message) /=0) then
  endif
  int_temp = 0_ik
  if(power_extract_command_parameter(cmd,'-relative_time',stop_on_error=.false.,&
                value=int_temp,syntax=message) /=0) then
  endif
  if(power_extract_command_parameter(cmd,'-performance_file',stop_on_error=.false.,&
                value=input_parameters%performance_file,&
                syntax=message) /=0) then
  endif
  if(power_extract_command_parameter(cmd,'-power_file',stop_on_error=.false.,&
                value=input_parameters%power_file,&
                syntax=message) /=0) then
  endif
  if(power_extract_command_parameter(cmd,'-energy_file',stop_on_error=.false.,&
                value=input_parameters%energy_file,&
                syntax=message) /=0) then
  endif
  if(power_extract_command_parameter(cmd,'-joule_per_flop_file',stop_on_error=.false.,&
                value=input_parameters%joule_per_flop_file,&
                syntax=message) /=0) then
  endif

  if(int_temp .gt. 0_ik) then
    input_parameters%relative_time = .true._lk
  end if
  input_parameters%config_file=trim(config_file)//char(0)
  if(input_parameters%verbosity_level .GT. 0_ik) input_parameters%verbosity = .TRUE._lk
  
  call power_input_parameter_check(input_parameters,err_code)
end subroutine power_input_parameter_read


end module power_input_parameter

