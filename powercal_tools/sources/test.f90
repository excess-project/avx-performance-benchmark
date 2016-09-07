module test
use power_type
use power_timestep
use power_energy_data

implicit none
type coresnum_type
 integer(kind=ik),allocatable,dimension(:)    :: num
end type

type performance_type
 real(kind=rk),allocatable,dimension(:)    :: perf
end type

type length_type
 integer(kind=ik),allocatable,dimension(:) :: len
end type

contains
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
subroutine read_timephases_from_file(filepath, num_lines, start_time, end_time)
 character(len=*),intent(in)                                 :: filepath
 type(power_timesteps_sec_type),intent(out)                   :: start_time
 type(power_timesteps_sec_type),intent(out)                   :: end_time
 integer(kind=ik),intent(out)                                 :: num_lines
 type(power_timesteps_sec_type)                   :: row
 integer(kind=ik)                                 :: num_colums, ii, unit_nr, error_code 
 character(len=150)                               :: line_read

 num_lines=0_ik
 num_colums=5_ik
 unit_nr = 1000_ik
 error_code = 0_ik
!to get the number of lines
 open(unit = unit_nr, file = filepath, status = 'old', action = 'read')
  do
   read(unit_nr,*, end=10) line_read
   num_lines=num_lines+1
  end do
10 close(unit_nr)
!the first line is ignored
 num_lines=num_lines-1
 allocate(start_time%sec(num_lines))
 allocate(end_time%sec(num_lines))
 allocate(row%sec(num_colums))

 open(unit = unit_nr, file = filepath, status = 'old', action = 'read', position= 'rewind', iostat = error_code)
  if(error_code .ne. 0_ik) then
    write(*,'(A,I0)')  "Error open:",error_code
    stop
  end if
!read line by line and get the start and end time
 do ii=1_ik, num_lines
  if(ii .eq. 1_ik) then
   read(unit_nr,*) line_read
  end if
  read(unit_nr,*) row%sec(1),row%sec(2),row%sec(3),row%sec(4),row%sec(5)
  start_time%sec(ii)=row%sec(4)
  end_time%sec(ii)=row%sec(5)
 end do
 close(unit_nr)
end subroutine read_timephases_from_file
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
subroutine read_performance_from_file(filepath, num_lines, cores_num, length, performance)
 character(len=*),intent(in)                                 :: filepath
 type(coresnum_type),intent(out)                  :: cores_num
 type(length_type),intent(out)                    :: length
 type(performance_type),intent(out)               :: performance
 integer(kind=ik),intent(out)                     :: num_lines
 real(kind=rk),allocatable,dimension(:)           :: row
 integer(kind=ik)                                 :: num_colums, ii, unit_nr, error_code 
 character(len=150)                               :: line_read

 num_lines=0_ik
 num_colums=5_ik
 unit_nr = 1000_ik
 error_code = 0_ik
!to get the number of lines
 open(unit = unit_nr, file = filepath, status = 'old', action = 'read')
  do
   read(unit_nr,*, end=10) line_read
   num_lines=num_lines+1
  end do
10 close(unit_nr)
 num_lines=num_lines-1
 allocate(cores_num%num(num_lines))
 allocate(length%len(num_lines))
 allocate(performance%perf(num_lines))
 allocate(row(num_colums))

 open(unit = unit_nr, file = filepath, status = 'old', action = 'read', position= 'rewind', iostat = error_code)
  if(error_code .ne. 0_ik) then
    write(*,'(A,I0)')  "Error open:",error_code
    stop
  end if
!read line by line and get the start and end time
 do ii=1_ik, num_lines
  !the first line is ignored
  if(ii .eq. 1_ik) then
   read(unit_nr,*) line_read
  end if
  read(unit_nr,*) row(1),row(2),row(3),row(4),row(5)
  cores_num%num(ii)=INT(row(1),ik)
  length%len(ii)=INT(row(2),ik)
  performance%perf(ii)=row(3)
 end do

 close(unit_nr)
end subroutine read_performance_from_file
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
subroutine power_write_to_file(filepath, cores_num, length, performance, power_energy)
 character(len=*),intent(in)                                 :: filepath
 type(coresnum_type),intent(in)                  :: cores_num
 type(length_type),intent(in)                    :: length
 type(performance_type),intent(in)               :: performance
 type(power_energy_type),intent(in)              :: power_energy
 integer(kind=ik)                                :: ii, jj, num_phases, num_components, unit_nr, error_code
 logical                                         :: exist

  unit_nr = 2000_ik
  error_code = 0_ik

  num_phases = size(power_energy%energy_by_phases)
  inquire(file=filepath, exist=exist)
  if(exist) then
  !open the existing file and append
    open(unit = unit_nr, file = filepath, status = 'old', action = 'write', access= 'append', iostat = error_code)
  else 
    open(unit = unit_nr, file = filepath, status = 'new', action = 'write', iostat = error_code)
    write(unit_nr,'(A7,A7,A14,A14,A14,A14,A14,A14)') "#cores", "length", "duration_sec", &
                 "performance", "watt_1", "avg_watt_1",&
                 "watt_2", "avg_watt_2"
  end if

  if(error_code .ne. 0_ik) then
     write(*,'(A,I0)')  "Error open:",error_code
     stop
  end if

  do ii=1,num_phases
    num_components = size(power_energy%energy_by_phases(ii)%energy_by_components)
    do jj=1_ik,num_components
      if(jj .eq. 1_ik) then
         write(unit_nr, '(I6,A1,I6,A1,E13.6,A1,E13.6,A1,E13.6,A1,E13.6,A1,E13.6,A1,E13.6)') (cores_num%num(ii)),";",&
           (length%len(ii)),";",&
           (power_energy%energy_by_phases(ii)%phase_duration),";",&
           (performance%perf(ii)),";",&
           (power_energy%energy_by_phases(ii)%energy_by_components(1)%power_watt),";",&
           (power_energy%energy_by_phases(ii)%energy_by_components(1)%power_by_average_watt),";",&
           (power_energy%energy_by_phases(ii)%energy_by_components(2)%power_watt),";",&
           (power_energy%energy_by_phases(ii)%energy_by_components(2)%power_by_average_watt)
      end if
    end do
  end do
  close(unit_nr)
end subroutine power_write_to_file
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
subroutine energy_write_to_file(filepath, cores_num, length, performance, power_energy)
 character(len=*),intent(in)                                 :: filepath
 type(coresnum_type),intent(in)                  :: cores_num
 type(length_type),intent(in)                    :: length
 type(performance_type),intent(in)               :: performance
 type(power_energy_type),intent(in)              :: power_energy
 integer(kind=ik)                                :: ii, jj, num_phases, num_components, unit_nr, error_code
 logical                                         :: exist

  unit_nr = 2000_ik
  error_code = 0_ik

  num_phases = size(power_energy%energy_by_phases)
  inquire(file=filepath, exist=exist)
  if(exist) then
  !open the existing file and append
    open(unit = unit_nr, file = filepath, status = 'old', action = 'write', access= 'append', iostat = error_code)
  else 
    open(unit = unit_nr, file = filepath, status = 'new', action = 'write', iostat = error_code)
    write(unit_nr,'(A7,A7,A14,A14,A14,A14,A14,A14)') "#cores", "length", "duration_sec", &
                 "performance",&
                 "joule_1", "avg_joule_1",&
                 "joule_2", "avg_joule_2"
  end if

  if(error_code .ne. 0_ik) then
     write(*,'(A,I0)')  "Error open:",error_code
     stop
  end if

  do ii=1,num_phases
    num_components = size(power_energy%energy_by_phases(ii)%energy_by_components)
    do jj=1_ik,num_components
      if(jj .eq. 1_ik) then
         write(unit_nr, '(I6,A1,I6,A1,E13.6,A1,E13.6,A1,E13.6,A1,E13.6,A1,E13.6,A1,E13.6)') (cores_num%num(ii)),";",&
           (length%len(ii)),";",&
           (power_energy%energy_by_phases(ii)%phase_duration),";",&
           (performance%perf(ii)),";",&
           (power_energy%energy_by_phases(ii)%energy_by_components(1)%energy_joule),";",&
           (power_energy%energy_by_phases(ii)%energy_by_components(1)%energy_by_average_joule),";",&
           (power_energy%energy_by_phases(ii)%energy_by_components(2)%energy_joule),";",&
           (power_energy%energy_by_phases(ii)%energy_by_components(2)%energy_by_average_joule)
      end if
    end do
  end do
  close(unit_nr)
end subroutine energy_write_to_file
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
subroutine joule_per_flop_write_to_file(filepath, cores_num, length, performance, power_energy)
 character(len=*),intent(in)                                 :: filepath
 type(coresnum_type),intent(in)                  :: cores_num
 type(length_type),intent(in)                    :: length
 type(performance_type),intent(in)               :: performance
 type(power_energy_type),intent(in)              :: power_energy
 integer(kind=ik)                                :: ii, jj, num_phases, num_components, unit_nr, error_code
 real(kind=rk)                                   :: joule_per_flop_1, avg_joule_per_flop_1, joule_per_flop_2, avg_joule_per_flop_2
 logical                                         :: exist

  unit_nr = 2000_ik
  error_code = 0_ik

  num_phases = size(power_energy%energy_by_phases)
  inquire(file=filepath, exist=exist)
  if(exist) then
  !open the existing file and append
    open(unit = unit_nr, file = filepath, status = 'old', action = 'write', access= 'append', iostat = error_code)
  else 
    open(unit = unit_nr, file = filepath, status = 'new', action = 'write', iostat = error_code)
    write(unit_nr,'(A7,A7,A14,A14,A20,A20,A20,A20)') "#cores", "length", "duration_sec", &
                 "performance",&
                 "joule_per_flop_1", "avg_joule_per_flop_1",&
                 "joule_per_flop_2", "avg_joule_per_flop_2"
  end if

  if(error_code .ne. 0_ik) then
     write(*,'(A,I0)')  "Error open:",error_code
     stop
  end if

  do ii=1,num_phases
    num_components = size(power_energy%energy_by_phases(ii)%energy_by_components)
    do jj=1_ik,num_components
      if(jj .eq. 1_ik) then
        joule_per_flop_1=power_energy%energy_by_phases(ii)%energy_by_components(1)%energy_joule /&
                         (performance%perf(ii)*power_energy%energy_by_phases(ii)%phase_duration)
        avg_joule_per_flop_1=power_energy%energy_by_phases(ii)%energy_by_components(1)%energy_by_average_joule /&
                         (performance%perf(ii)*power_energy%energy_by_phases(ii)%phase_duration)
        joule_per_flop_2=power_energy%energy_by_phases(ii)%energy_by_components(2)%energy_joule /&
                         (performance%perf(ii)*power_energy%energy_by_phases(ii)%phase_duration)
        avg_joule_per_flop_2=power_energy%energy_by_phases(ii)%energy_by_components(2)%energy_by_average_joule /&
                         (performance%perf(ii)*power_energy%energy_by_phases(ii)%phase_duration)
         write(unit_nr, '(I6,A1,I6,A1,E13.6,A1,E13.6,A1,E19.6,A1,E19.6,A1,E19.6,A1,E19.6)') (cores_num%num(ii)),";",&
           (length%len(ii)),";",&
           (power_energy%energy_by_phases(ii)%phase_duration),";",&
           (performance%perf(ii)),";",&
           (joule_per_flop_1),";",&
           (avg_joule_per_flop_1),";",&
           (joule_per_flop_2),";",&
           (avg_joule_per_flop_2)
      end if
    end do
  end do
  close(unit_nr)
end subroutine joule_per_flop_write_to_file

end module test
