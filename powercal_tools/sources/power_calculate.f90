program power_calculate
use power_type
use power_timestep
use power_input_parameter
use power_rawdata
use power_statistic
use power_operations
use power_hpc_config
use power_hpc_config_interface
use power_energy_data
use test

implicit none
  type(power_input_parameter_type)                   :: input_parameters !user input
  integer(kind=ik)                                   :: err_code
  type(power_timestep_type),allocatable,dimension(:) :: volt_timesteps
  type(power_timestep_type),allocatable,dimension(:) :: current_timesteps
  type(power_rawdata_type)                           :: current_channel_rawdata
  type(power_rawdata_type)                           :: volt_channel_rawdata
  logical(kind=lk)                                   :: write_out
  integer(kind=ik)                                   :: error_code
  type(iniPowerConfig_t)                             :: config
  type(components_t),dimension(100)                  :: components
  integer(kind=ik)                                   :: current_board_id
  integer(kind=ik)                                   :: volt_board_id
  real(kind=rk)                                      :: phase_start_sec
  real(kind=rk)                                      :: phase_end_sec
  real(kind=rk)                                      :: offset_sec
  real(kind=rk)                                      :: offset_microsec
  real(kind=rk)                                      :: offset_nanosec
  integer(kind=ik)                                   :: volt_start_indx
  integer(kind=ik)                                   :: volt_end_indx
  integer(kind=ik)                                   :: current_start_indx
  integer(kind=ik)                                   :: current_end_indx
  real(kind=rk)                                      :: volt_seq_interval_sec
  real(kind=rk)                                      :: current_seq_interval_sec
  real(kind=rk)                                      :: volt_measure_interval_sec
  real(kind=rk)                                      :: current_measure_interval_sec
  real(kind=rk)                                      :: current_first_measurement_sec
  real(kind=rk)                                      :: volt_first_measurement_sec
  real(kind=rk)                                      :: current_last_measurement_sec
  real(kind=rk)                                      :: volt_last_measurement_sec
  type(power_timesteps_sec_type)                     :: volt_timesteps_sec
  type(power_timesteps_sec_type)                     :: current_timesteps_sec
  integer(kind=ik)                                   :: length_tmp
  integer(kind=ik)                                   :: current_num_measures
  integer(kind=ik)                                   :: volt_num_measures
  integer(kind=ik)                                   :: num_phases
  type(power_energy_type)                            :: energy
  real(kind=rk)                                      :: energy_tmp
  real(kind=rk)                                      :: energy_by_average_tmp
  real(kind=rk)                                      :: coeff1_tmp
  real(kind=rk)                                      :: coeff2_tmp
  real(kind=rk)                                      :: current_average_tmp
  real(kind=rk)                                      :: volt_average_tmp
  integer(kind=ik)                                   :: ii,jj,kk
  integer(kind=ik)                                   :: num_components

  type(power_timesteps_sec_type)                   :: start_time
  type(power_timesteps_sec_type)                   :: end_time
  type(coresnum_type)                              :: cores_num
  type(length_type)                                :: length
  type(performance_type)                           :: performance
  integer(kind=ik)                                 :: num_lines

  write_out = .false._lk
  call power_input_parameter_read(input_parameters,err_code)!read user input parameters from command line
  if (input_parameters%verbosity) then
    call power_input_parameter_print(input_parameters)!print user input parameters from command line
  end if
  error_code = hpc_read_power_config_file(input_parameters%config_file, config,components ) 
  num_components = int(config%nPowerComponents,kind=ik)

  offset_sec=input_parameters%offset_sec
  offset_microsec=input_parameters%offset_microsec
  offset_nanosec=input_parameters%offset_nanosec
  
  call read_timephases_from_file(input_parameters%performance_file, num_phases, start_time, end_time)
  call power_energy_new(energy,num_phases,num_components)

  current_board_id = -1_ik
  volt_board_id = -1_ik
  do ii=1_ik,num_components
    if(input_parameters%verbosity) then
         write(power_output_unit,'(A,A)') "Check power data for the componetent:",&
           c_to_f_string(components(ii)%label)
    end if
    if(current_board_id .ne. components(ii)%current_board_id) then
       current_board_id = components(ii)%current_board_id
       if(input_parameters%verbosity) then
         write(power_output_unit,'(A,I0)') "Read current timesteps for board:",current_board_id
       end if
       input_parameters%board_id=components(ii)%current_board_id
       call power_timesteps_read(current_timesteps,input_parameters,err_code)
       if(err_code .ne. 0_ik) then
         write(power_output_unit,'(A,I0)') &
          "Error power_timesteps_read executed with error:",err_code
         stop
        end if
        call power_timesteps_to_timesteps_sec(current_timesteps,offset_sec,input_parameters,&
          current_timesteps_sec,current_seq_interval_sec,err_code)
        if(err_code .ne. 0_ik) then
         write(power_output_unit,'(A,I0)') &
          "Error power_timesteps_read executed with error:",err_code
         stop
        end if
     end if
     if(volt_board_id .ne. components(ii)%voltage_board_id) then
       volt_board_id = components(ii)%voltage_board_id
       if(input_parameters%verbosity) then
         write(power_output_unit,'(A,I0)') "Read voltage timesteps for board:",current_board_id
       end if
       call power_timesteps_read(volt_timesteps,input_parameters,err_code)
       if(err_code .ne. 0_ik) then
         write(power_output_unit,'(A,I0)') &
          "Error power_timesteps_read executed with error:",err_code
         stop
        end if
        call power_timesteps_to_timesteps_sec(volt_timesteps,offset_sec,input_parameters,&
          volt_timesteps_sec,volt_seq_interval_sec,err_code)
        if(err_code .ne. 0_ik) then
         write(power_output_unit,'(A,I0)') &
          "Error power_timesteps_read executed with error:",err_code
         stop
        end if
     end if

    if(input_parameters%verbosity) then
      write(power_output_unit,'(A,A)') "Read power current data for the componetent:",&
           c_to_f_string(components(ii)%label)
    end if
    input_parameters%channel_id=components(ii)%current_channel_id
    input_parameters%board_id=components(ii)%current_board_id
    call power_power_rawdata_read(current_channel_rawdata,current_timesteps,input_parameters,err_code)
    if(err_code .ne. 0_ik) then
       write(power_output_unit,'(A,I0)') &
         "Error power_power_rawdata_read(curren) executed with error:",err_code
       stop
    end if
    if(input_parameters%verbosity) then
      write(power_output_unit,'(A,A)') "Read power voltage data for the componetent:",&
           c_to_f_string(components(ii)%label)
    end if
    input_parameters%channel_id = components(ii)%voltage_channel_id
    input_parameters%board_id = components(ii)%voltage_board_id
    if(input_parameters%channel_id .lt. 0) then
      if(allocated(volt_channel_rawdata%rawdata)) deallocate(volt_channel_rawdata%rawdata)
      length_tmp = size(current_channel_rawdata%rawdata)
      allocate(volt_channel_rawdata%rawdata(length_tmp))
      volt_channel_rawdata%rawdata_seq_num=current_channel_rawdata%rawdata_seq_num
      volt_channel_rawdata%rawdata=12.0_rk
    else
      call power_power_rawdata_read(volt_channel_rawdata,volt_timesteps,input_parameters,err_code)
      if(err_code .ne. 0_ik) then
         write(power_output_unit,'(A,I0)') &
          "Error power_power_rawdata_read(curren) executed with error:",err_code
         stop
       end if
    end if

    !find indx_start and indx_end
    current_measure_interval_sec = current_seq_interval_sec / real(current_channel_rawdata%rawdata_seq_num,kind=rk)
    volt_measure_interval_sec = volt_seq_interval_sec / real(volt_channel_rawdata%rawdata_seq_num,kind=rk)
    if(input_parameters%verbosity) then
      write(power_output_unit,'(2(A,E13.6))') "current_measure_interval_sec:",&
          current_measure_interval_sec,&
          "; volt_measure_interval_sec:",  volt_measure_interval_sec
    end if
    current_first_measurement_sec = current_timesteps_sec%sec(1_ik) - &
                                    current_measure_interval_sec*current_channel_rawdata%rawdata_seq_num
    volt_first_measurement_sec = volt_timesteps_sec%sec(1_ik) - &
                                 volt_measure_interval_sec*volt_channel_rawdata%rawdata_seq_num
    length_tmp = size(current_timesteps_sec%sec)
    current_last_measurement_sec = current_timesteps_sec%sec(length_tmp)
    length_tmp = size(volt_timesteps_sec%sec)
    volt_last_measurement_sec = volt_timesteps_sec%sec(length_tmp)
    current_num_measures = size(current_channel_rawdata%rawdata)
    volt_num_measures = size(volt_channel_rawdata%rawdata)
    do jj=1_ik,num_phases
        phase_start_sec = start_time%sec(jj)
        phase_end_sec = end_time%sec(jj)
        offset_sec = offset_sec + offset_microsec*1.0e-6 + offset_nanosec*1.0e-9

        if(phase_start_sec .gt. phase_end_sec) then
           write(power_output_unit,'(A,E13.6,A,E13.6)')  "Error: The phase_start_time is later than phase_end_time: ",&
           phase_start_sec, " > ", phase_end_sec

           stop
        end if

        if(input_parameters%relative_time) then
            current_start_indx = int(&
              (phase_start_sec+&
              current_measure_interval_sec)/current_measure_interval_sec,kind=ik)
            volt_start_indx = int(&
              (phase_start_sec+&
              volt_measure_interval_sec)/volt_measure_interval_sec,kind=ik)
            current_end_indx = int(&
              (phase_end_sec+&
              current_measure_interval_sec)/current_measure_interval_sec,kind=ik)
            volt_end_indx = int(&
              (phase_end_sec+&
              volt_measure_interval_sec)/volt_measure_interval_sec,kind=ik)
        else
            current_start_indx = int(&
              (phase_start_sec-current_first_measurement_sec+&
              current_measure_interval_sec)/current_measure_interval_sec,kind=ik)
            volt_start_indx = int(&
              (phase_start_sec-volt_first_measurement_sec+&
              volt_measure_interval_sec)/volt_measure_interval_sec,kind=ik)
            current_end_indx = int(&
              (phase_end_sec-current_first_measurement_sec+&
              current_measure_interval_sec)/current_measure_interval_sec,kind=ik)
            volt_end_indx = int(&
              (phase_end_sec-volt_first_measurement_sec+&
              volt_measure_interval_sec)/volt_measure_interval_sec,kind=ik)
        end if
        if(input_parameters%verbosity) then
          write(power_output_unit,'(2(A,I0,A,I0))')"current_indx:",&
              current_start_indx,"-",current_end_indx ,&
               "; volt_indx:",&
              volt_start_indx,"-",volt_end_indx
        end if  
        !calculate power consumption from voltage and current data during the jj-th phase
        coeff1_tmp = components(ii)%coeff1
        coeff2_tmp = components(ii)%coeff2
        if(volt_start_indx .eq. current_start_indx .and. &
          current_end_indx .eq. volt_end_indx) then
          energy_tmp=0.0
          do kk=volt_start_indx, volt_end_indx
            energy_tmp = energy_tmp + &
            (current_channel_rawdata%rawdata(kk))*&
            volt_channel_rawdata%rawdata(kk)
          end do
          energy_tmp = energy_tmp / real(((volt_end_indx-volt_start_indx)+1_ik),kind=rk)
          energy_tmp= energy_tmp*coeff1_tmp+coeff2_tmp
        end if
        current_average_tmp = 0.0_rk
        volt_average_tmp = 0.0_rk
        do kk=current_start_indx, current_end_indx
          current_average_tmp = current_average_tmp + &
            (current_channel_rawdata%rawdata(kk))
        end do
        current_average_tmp = current_average_tmp / real(((current_end_indx-current_start_indx)+1_ik),kind=rk)
        do kk=volt_start_indx, volt_end_indx
          volt_average_tmp = volt_average_tmp + &
            volt_channel_rawdata%rawdata(kk)
        end do
        volt_average_tmp = volt_average_tmp / real(((volt_end_indx-volt_start_indx)+1_ik),kind=rk)
        energy_by_average_tmp= coeff1_tmp*(volt_average_tmp*current_average_tmp)+coeff2_tmp
        write(energy%energy_by_phases(jj)%phase_label,'(A,I0)')"phase:",jj
        energy%energy_by_phases(jj)%phase_start=phase_start_sec
        energy%energy_by_phases(jj)%phase_end=phase_end_sec
        energy%energy_by_phases(jj)%phase_duration=phase_end_sec-phase_start_sec
        energy%energy_by_phases(jj)%phase_num_measures=(volt_end_indx-volt_start_indx)+1_ik
        energy%energy_by_phases(jj)%relative_time=input_parameters%relative_time          
        
        energy%energy_by_phases(jj)%energy_by_components(ii)%component_label=&
          c_to_f_string(components(ii)%label)
        energy%energy_by_phases(jj)%energy_by_components(ii)%power_watt=energy_tmp
        energy%energy_by_phases(jj)%energy_by_components(ii)%power_by_average_watt=energy_by_average_tmp
        energy%energy_by_phases(jj)%energy_by_components(ii)%energy_joule=&
          energy_tmp*(phase_end_sec-phase_start_sec)
        energy%energy_by_phases(jj)%energy_by_components(ii)%energy_by_average_joule=&
          energy_by_average_tmp*(phase_end_sec-phase_start_sec)
    end do
    
  end do

  call read_performance_from_file(input_parameters%performance_file, num_lines, cores_num, length, performance)
  call power_write_to_file(input_parameters%power_file, cores_num, length, performance, energy)
  call energy_write_to_file(input_parameters%energy_file, cores_num, length, performance, energy)
  call joule_per_flop_write_to_file(input_parameters%joule_per_flop_file, cores_num, length, performance, energy)
 
end program power_calculate
