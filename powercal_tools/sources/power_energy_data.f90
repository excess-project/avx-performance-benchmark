module power_energy_data

use power_type
use power_timestep
use power_input_parameter
use power_hpc_config
use power_rawdata
implicit none

type power_energy_component_type
 character(len=str_length)               :: component_label
 real(kind=rk)                           :: power_watt
 real(kind=rk)                           :: power_by_average_watt
 real(kind=rk)                           :: energy_joule
 real(kind=rk)                           :: energy_by_average_joule
end type power_energy_component_type

type power_energy_phase_type
 character(len=str_length)                                       :: phase_label
 real(kind=rk)                                                   :: phase_start
 real(kind=rk)                                                   :: phase_end
 real(kind=rk)                                                   :: phase_duration
 integer(kind=ik)                                                :: phase_num_measures
 type(power_energy_component_type),allocatable, dimension(:)     :: energy_by_components
 logical(kind=lk)                                                :: relative_time
end type power_energy_phase_type

type power_energy_type
 integer(kind=ik)                                            :: num_phases
 type(power_energy_phase_type),allocatable, dimension(:)     :: energy_by_phases
end type power_energy_type
 
 
interface new
  module procedure power_energy_new
end interface new

interface del
  module procedure power_energy_del
end interface del

contains

subroutine power_energy_new(power_energy, num_phases, num_components)
 type(power_energy_type),intent(out) :: power_energy
 integer(kind=ik),intent(in)         :: num_phases
 integer(kind=ik),intent(in)         :: num_components
 integer(kind=ik) :: ii, jj
 

 allocate(power_energy%energy_by_phases(num_phases))
 do ii=1,num_phases
   allocate(power_energy%energy_by_phases(ii)%energy_by_components(num_components))
   do jj=1,num_components
     power_energy%energy_by_phases(ii)%energy_by_components(jj)%component_label="undef"
     power_energy%energy_by_phases(ii)%energy_by_components(jj)%energy_joule=0.0_rk
     power_energy%energy_by_phases(ii)%energy_by_components(jj)%energy_by_average_joule=0.0_rk
     power_energy%energy_by_phases(ii)%energy_by_components(jj)%power_watt=0.0_rk
     power_energy%energy_by_phases(ii)%energy_by_components(jj)%power_by_average_watt=0.0_rk
   end do
   power_energy%energy_by_phases(ii)%phase_start=0.0_rk
   power_energy%energy_by_phases(ii)%phase_end=0.0_rk
   power_energy%energy_by_phases(ii)%phase_duration=0.0_rk
   power_energy%energy_by_phases(ii)%phase_num_measures=0_ik
   power_energy%energy_by_phases(ii)%relative_time=.false._lk
 end do
end subroutine power_energy_new

subroutine power_energy_del(power_energy)
 type(power_energy_type),intent(out) :: power_energy
 integer(kind=ik) :: ii, num_phases
 
 if(allocated(power_energy%energy_by_phases)) then
   num_phases = size(power_energy%energy_by_phases)
   do ii=1,num_phases
     if(allocated(power_energy%energy_by_phases(ii)%energy_by_components)) then
       deallocate(power_energy%energy_by_phases(ii)%energy_by_components)
      end if
   end do
 end if
end subroutine power_energy_del

subroutine power_energy_print(power_energy)
  type(power_energy_type),intent(in) :: power_energy
  integer(kind=ik) :: ii, jj, num_phases, num_components
  
  num_phases = size(power_energy%energy_by_phases)
  do ii=1,num_phases
    num_components = size(power_energy%energy_by_phases(ii)%energy_by_components)
    write(power_output_unit,'(A,A,A)') "=====",&
      trim(power_energy%energy_by_phases(ii)%phase_label),"====="
    write(power_output_unit,'(A,L)') "relative_time:",&
      power_energy%energy_by_phases(ii)%relative_time
    write(power_output_unit,'(A,E13.6,A)') "phase_start:",&
      (power_energy%energy_by_phases(ii)%phase_start), " sec"
    write(power_output_unit,'(A,E13.6,A)') "phase_end:",&
      (power_energy%energy_by_phases(ii)%phase_end), " sec"
    write(power_output_unit,'(A,E13.6,A)') "phase_duration:",&
      (power_energy%energy_by_phases(ii)%phase_duration), " sec"
    write(power_output_unit,'(A,E13.6,A)') "phase_num_measures:",&
      real(power_energy%energy_by_phases(ii)%phase_num_measures,kind=rk), ""
    do jj=1,num_components
      write(power_output_unit,'(A,A,A)') char(9)//"==component:",&
       trim(power_energy%energy_by_phases(ii)%energy_by_components(jj)%component_label),&
       "=="
      write(power_output_unit,'(A,E13.6,A)') char(9)//"average power:",&
       (power_energy%energy_by_phases(ii)%energy_by_components(jj)%power_watt), " watt"
      write(power_output_unit,'(A,E13.6,A)') char(9)//"power_by_average_joule:",&
       (power_energy%energy_by_phases(ii)%energy_by_components(jj)%power_by_average_watt), " watt"
      write(power_output_unit,'(A,E13.6,A)') char(9)//"energy:",&
       (power_energy%energy_by_phases(ii)%energy_by_components(jj)%energy_joule), " J"
      write(power_output_unit,'(A,E13.6,A)') char(9)//"energy_by_average_joule:",&
       (power_energy%energy_by_phases(ii)%energy_by_components(jj)%energy_by_average_joule), " J"
      write(power_output_unit,'(A,A,A)') char(9)//"==",&
       "==",&
       "=="
    end do
    write(power_output_unit,'(A,A,A)') "=====",&
      "=====","====="
  end do

end subroutine power_energy_print

end module power_energy_data
