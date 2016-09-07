module power_read_files
use power_type
use power_timestep
use power_energy_data

implicit none

type performance_type
 real(kind=rk),allocatable,dimension(:)    :: perf
end type

type length_type
 integer(kind=ik),allocatable,dimension(:) :: len
end type

contains
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
subroutine power_read_timephases_from_file(filepath, num_lines, start_time, end_time)
 character(len=*),intent(in)                                 :: filepath
 type(power_timesteps_sec_type),intent(out)                   :: start_time
 type(power_timesteps_sec_type),intent(out)                   :: end_time
 integer(kind=ik),intent(out)                                 :: num_lines
 type(power_timesteps_sec_type)                   :: row
 integer(kind=ik)                                 :: num_colums, ii, unit_nr, error_code 
 character(len=150)                               :: line_read

 num_lines=0_ik
 num_colums=4_ik
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
  read(unit_nr,*) row%sec(1),row%sec(2),row%sec(3),row%sec(4)
  start_time%sec(ii)=row%sec(3)
  end_time%sec(ii)=row%sec(4)
 end do
 close(unit_nr)
end subroutine power_read_timephases_from_file
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
subroutine power_read_performance_from_file(filepath, num_lines, length, performance)
 character(len=*),intent(in)                                 :: filepath
 type(length_type),intent(out)                    :: length
 type(performance_type),intent(out)               :: performance
 integer(kind=ik),intent(out)                     :: num_lines
 real(kind=rk),allocatable,dimension(:)           :: row
 integer(kind=ik)                                 :: num_colums, ii, unit_nr, error_code 
 character(len=150)                               :: line_read

 num_lines=0_ik
 num_colums=4_ik
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
  read(unit_nr,*) row(1),row(2),row(3),row(4)
  length%len(ii)=INT(row(1),ik)
  performance%perf(ii)=row(2)
 end do

 close(unit_nr)
end subroutine power_read_performance_from_file
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
subroutine power_energy_write_to_file(filepath, length, performance, power_energy)
 character(len=*),intent(in)                                 :: filepath
 type(length_type),intent(in)                    :: length
 type(performance_type),intent(in)               :: performance
 type(power_energy_type),intent(in)              :: power_energy
 integer(kind=ik)                                :: ii, jj, num_phases, num_components, unit_nr, error_code

  unit_nr = 2000_ik
  error_code = 0_ik

  num_phases = size(power_energy%energy_by_phases)
  !open the file for write
  open(unit = unit_nr, file = filepath, status = 'replace', action = 'write', access= 'append', iostat = error_code)
  if(error_code .ne. 0_ik) then
     write(*,'(A,I0)')  "Error open:",error_code
     stop
  end if
  write(unit_nr,'(A8, A15, A15, A17, A17, A17, A17)') "length", "duration_sec", &
                 "performance", "power_watt", "power_avg_watt",&
                 "energy_joule", "energy_avg_joule" 
  do ii=1,num_phases
    num_components = size(power_energy%energy_by_phases(ii)%energy_by_components)
    do jj=1_ik,num_components
      if(jj .eq. 1_ik) then
         write(unit_nr, '(I8, E15.6, E15.6, E17.6, E17.6, E17.6, E17.6)') (length%len(ii)),&
           (power_energy%energy_by_phases(ii)%phase_duration),&
           (performance%perf(ii)), &
           (power_energy%energy_by_phases(ii)%energy_by_components(jj)%power_watt),&
           (power_energy%energy_by_phases(ii)%energy_by_components(jj)%power_by_average_watt),&
           (power_energy%energy_by_phases(ii)%energy_by_components(jj)%energy_joule),&
           (power_energy%energy_by_phases(ii)%energy_by_components(jj)%energy_by_average_joule)
      else
         write(unit_nr, '(A38, E17.6, E17.6, E17.6, E17.6)') " ",&
           (power_energy%energy_by_phases(ii)%energy_by_components(jj)%power_watt),&
           (power_energy%energy_by_phases(ii)%energy_by_components(jj)%power_by_average_watt),&
           (power_energy%energy_by_phases(ii)%energy_by_components(jj)%energy_joule),&
           (power_energy%energy_by_phases(ii)%energy_by_components(jj)%energy_by_average_joule)
      end if
    end do
  end do
  close(unit_nr)
end subroutine power_energy_write_to_file

end module power_read_files
