module power_extract_command
use power_type


implicit none

logical(kind=lk) :: power_extract_comm_output_on = .false._lk

character(len=*),parameter :: power_digits='0123456789'
character(len=*),parameter :: power_alpha= 'abcdefghijklmnopqrstuvwxyz' &
                                   //'ABCDEFGHIJKLMNOPQRSTUVWXYZ' &
                                   //'_'
character(len=*),parameter :: power_alpha_num=power_digits//power_alpha

interface power_extract_command_parameter
   module procedure power_extract_command_parameter_string
   module procedure power_extract_command_parameter_integer
   module procedure power_extract_command_parameter_real
end interface

contains

subroutine power_test_all_keywords(command_line,syntax)
character(len=*)                  :: command_line
character(len=*)                  :: syntax
character(len=32),dimension(256)   :: keywords
character(len=32),dimension(64)   :: cmd_keywords
integer(kind=ik)                           :: nn,nmax
integer(kind=ik)                           :: cmd_nn,cmd_nmax

 call power_find_command_keywords(syntax,keywords,nmax) 
 call power_find_command_keywords(command_line,cmd_keywords,cmd_nmax) 

 command_loop: do cmd_nn=1,cmd_nmax
 do nn=1,nmax
   if(cmd_keywords(cmd_nn)==keywords(nn)) cycle command_loop
 enddo
  if(power_extract_comm_output_on) then
       write(*,'(a,a,a)') 'power_test_all_keywords: "',&
        trim(cmd_keywords(cmd_nn)),'" is not an allowed keyword in the command line '
       write(*,'(3a)') '"',trim(command_line),'"'
       write(*,'(a)') 'The syntax of the command line is'
       write(*,'(3a)') '"',trim(syntax),'"'
       write(*,'(a)') 'The allowed keywords are'
       do nn=1,nmax
       write(*,*) trim(keywords(nn))
       enddo
  end if
       stop 'cmd_keywords(nn): wrong switch in command line'

 enddo command_loop

end subroutine power_test_all_keywords

!*****************************************************************************************************
subroutine power_find_command_keywords(syntax,keywords,nmax)
character(len=*)               :: syntax
character(len=*),dimension(:)  :: keywords
integer(kind=ik)                        :: nn,nmax
integer(kind=ik)                        :: ind,ind_old,ind2,ind3
integer(kind=ik)                        :: len_syntax

 len_syntax=len(syntax)


 nmax=0
 ind_old=1
 do  nn=1,size(keywords)                         ! loop must be left by 'exit'
    ind=index(syntax(ind_old:),' -')+ind_old-1   ! we search for ' -' in front of a keyword
    if(ind==ind_old-1) then                      ! in this case there is no other keyword
            !!write(*,*) 'exit 2'
            exit
    else

      ind2=scan(syntax(ind+2:ind+2),power_alpha)+ind+1

      if(ind2>ind+1) then                       ! the first character of the string is a letter
         ind3=verify(syntax(ind+2:),power_alpha_num)+ind+1
         if(ind3==ind+1) then                    ! the remaining string is a keyword
                 keywords(nn)=syntax(ind+1:len_syntax)
                 nmax=nn
                 !!write(*,*) 'exit 1'
                 exit                            ! this will be the last keyword
         else                                    ! the string up to ind3-1 is a keyword
                 keywords(nn)=syntax(ind+1:ind3-1)
                 nmax=nn
                 ind_old=ind3
         endif

      endif
    endif
 enddo
    if(nmax== size(keywords)) then
        if(power_extract_comm_output_on) then
            write(*,*) 'power_find_command_keywords: size(keywords) "',size(keywords),'" is too small'
        end if
            stop       'power_find_command_keywords: size keywords is too small'
    endif
   !!    do nn=1,nmax
   !!    write(*,*) nn,trim(keywords(nn))
   !!    enddo

end subroutine power_find_command_keywords

!*****************************************************************************************************
function power_extract_command_parameter_string(command_line,switch,stop_on_error,value,syntax) result(result_value)
integer(kind=ik)           :: result_value
logical(kind=lk),optional  :: stop_on_error
logical(kind=lk)           :: loc_stop_on_error
character(len=*)  :: command_line,syntax
character(len=*)  :: switch
character(len=*)  :: value
integer(kind=ik)           :: ind
integer(kind=ik)           :: ind_end
integer(kind=ik)           :: lensw
integer(kind=ik),save      :: nmax=0
integer(kind=ik)           :: nn,nn_switch,nn_next
character(len=32),dimension(64),save   :: keywords

  loc_stop_on_error=.false.
if(present(stop_on_error)) then
  loc_stop_on_error=stop_on_error
endif


if(nmax==0) call power_find_command_keywords(syntax,keywords,nmax) ! called only the first time

 call power_scan_for_keyword(switch,keywords,nmax,nn_switch,1_ik,ind_end)
       !!  write(*,'(a,i0,a,a,a)') ' found keyword(',nn_switch,') "',trim(keywords(nn_switch)),'"'
if(nn_switch==0) then
  if(power_extract_comm_output_on) then
       write(*,'(a,a,a)') 'extract_command_parameter: "',&
        trim(switch),'" is not an allowed keyword '
       write(*,'(a)') trim(command_line)
       write(*,'(a)') 'syntax of command line is'
       write(*,'(a)') trim(syntax)
       write(*,'(a)') ' allowed keywords are'
       do nn=1,nmax
       write(*,*) trim(keywords(nn))
       enddo
  end if
       stop 'extract_command_parameter: wrong switch in command line'
endif



 ind=index(command_line,trim(keywords(nn_switch)))
 lensw=len_trim(keywords(nn_switch))

 ! we scan now the begin of all potential keywords to find the end of the string after the switch
 call power_scan_for_keyword(command_line,keywords,nmax,nn_next,ind+lensw,ind_end)

 if(ind==0) then
    if(loc_stop_on_error) then
      if(power_extract_comm_output_on) then
       print*,'extract_command_parameter: did not found "',&
        trim(switch),'" in command line'
       print*,trim(command_line)
       write(*,'(a)') 'syntax of command line is'
       write(*,'(a)') trim(syntax)
       stop 'extract_command_parameter: parameter not found in command line'
      endif
    end if
    result_value=1
 else
    result_value=0
    value=adjustl(command_line(ind+lensw:ind_end-1))
    if(power_extract_comm_output_on) then
      write(*,'(a,a,a,a,a)') 'extract_command_parameter: found "',&
        trim(value),'" for "',trim(switch),'"'
    endif
 endif


end function power_extract_command_parameter_string
!*****************************************************************************************************
subroutine power_scan_for_keyword(string,keywords,nmax,nn_switch,start,end)
character(len=*)              :: string
character(len=*),dimension(:) :: keywords
integer(kind=ik)                       :: start
integer(kind=ik)                       :: temp_end
integer(kind=ik)                       :: end
integer(kind=ik)                       :: nmax
integer(kind=ik)                       :: nn,nn_switch      

 nn_switch=0
 end=huge(end)
 !! We look for the first keyword to appear
 do nn=1,nmax
          !!  write(*,*) 'power_scan_for_keyword: testing for ',trim(keywords(nn))
    temp_end=index(string(start:),trim(keywords(nn)))+start-1
    if(temp_end>start-1) then
            if(temp_end < end) then
               end=temp_end
             !!  write(*,*) 'power_scan_for_keyword: found ',trim(keywords(nn))
               nn_switch=nn
            endif
    endif
 enddo
 if(nn_switch==0 ) then
         end=len(string)
 !!else
       !!  write(*,'(a,i0,a,a,a)') ' found next keyword(',nn_switch,') "',trim(keywords(nn_switch)),'"'
 endif
 end subroutine power_scan_for_keyword
!*****************************************************************************************************
function power_extract_command_parameter_real(command_line,switch,stop_on_error,value,syntax) &
  result(result_value)
integer(kind=ik)           :: result_value
logical(kind=lk),optional  :: stop_on_error
logical(kind=lk)           :: loc_stop_on_error
character(len=*)  :: command_line,syntax
character(len=*)  :: switch
real(kind=rk)     :: value
integer(kind=ik)           :: ind,ind_end
integer(kind=ik)           :: lensw
character(len=32),dimension(64),save   :: keywords
integer(kind=ik),save      :: nmax=0
integer(kind=ik)           :: nn
integer(kind=ik)           :: nn_switch,nn_next
integer(kind=ik)           :: status

  loc_stop_on_error=.false.
if(present(stop_on_error)) then
  loc_stop_on_error=stop_on_error
endif


if(nmax==0) call power_find_command_keywords(syntax,keywords,nmax) ! called only the first time

 call power_scan_for_keyword(switch,keywords,nmax,nn_switch,1_ik,ind_end)

  ! first test if switch is allowed
if(nn_switch==0) then
  if(power_extract_comm_output_on) then
       write(*,'(a,a,a)') 'extract_command_parameter_real: "',trim(switch),&
        '" is not an allowed keyword '
       write(*,'(a)') trim(command_line)
       write(*,'(a)') 'syntax of command line is'
       write(*,'(a)') trim(syntax)
       write(*,'(a)') ' allowed keywords are'
       do nn=1,nmax
       write(*,*) trim(keywords(nn))
       enddo
  end if
       stop 'extract_command_parameter_real: wrong switch in command line'
endif

 ind=index(command_line,trim(keywords(nn_switch)))
 lensw=len_trim(keywords(nn_switch))

 ! we scan now the begin of all potential keywords to find the end of the string after the switch
 call power_scan_for_keyword(command_line,keywords,nmax,nn_next,ind+lensw,ind_end)

 if(ind==0) then
    if(loc_stop_on_error) then
      if(power_extract_comm_output_on) then
       write(*,'(a,a,a)') 'power_extract_command_parameter_real: did not found "',&
        trim(switch),'" in command line'
       write(*,'(a)') trim(command_line)
       write(*,'(a)') 'syntax of command line is'
       write(*,'(a)') trim(syntax)
      end if
       stop 'extract_command_parameter_real: parameter not found in command line'
    endif
    result_value=1
 else
    result_value=0
    read(command_line(ind+lensw:ind_end),*,iostat=status) value
    if(status/=0) then
       if(loc_stop_on_error) then
        if(power_extract_comm_output_on) then
            write(*,'(3a)') &
              'extract_command_parameter_real: error reading integer(kind=ik) parameter for switch "',&
              trim(switch),'"'
            write(*,'(3a)') 'found no integer(kind=ik) in "',command_line(ind+lensw:ind_end),'"'
            stop 'extract_command_parameter_real: error reading integer(kind=ik) parameter for switch'
       endif
      endif
    endif
    if(power_extract_comm_output_on) then
      write(*,'(a,g0.3,a,a,a)') 'extract_command_parameter: found real(kind=rk) "',&
        value,'" for switch "',trim(switch),'"'
    endif
 endif


end function power_extract_command_parameter_real
!*****************************************************************************************************
function power_extract_command_parameter_integer(command_line,switch,stop_on_error,value,syntax) &
  result(result_value)
integer(kind=ik)           :: result_value
logical(kind=lk),optional  :: stop_on_error
logical(kind=lk)           :: loc_stop_on_error
character(len=*)  :: command_line,syntax
character(len=*)  :: switch
integer(kind=ik)           :: value
integer(kind=ik)           :: ind,ind_end
integer(kind=ik)           :: lensw
character(len=32),dimension(64),save   :: keywords
integer(kind=ik),save      :: nmax=0
integer(kind=ik)           :: nn
integer(kind=ik)           :: nn_switch,nn_next
integer(kind=ik)           :: status

  loc_stop_on_error=.false.
if(present(stop_on_error)) then
  loc_stop_on_error=stop_on_error
endif


if(nmax==0) call power_find_command_keywords(syntax,keywords,nmax) ! called only the first time

 call power_scan_for_keyword(switch,keywords,nmax,nn_switch,1_ik,ind_end)

  ! first test if switch is allowed
if(nn_switch==0) then
    if(power_extract_comm_output_on) then
       write(*,'(a,a,a)') 'extract_command_parameter: "',trim(switch),&
        '" is not an allowed keyword '
       write(*,'(a)') trim(command_line)
       write(*,'(a)') 'syntax of command line is'
       write(*,'(a)') trim(syntax)
       write(*,'(a)') ' allowed keywords are'
       do nn=1,nmax
       write(*,*) trim(keywords(nn))
       enddo
    end if
       stop 'extract_command_parameter: wrong switch in command line'
endif

 ind=index(command_line,trim(keywords(nn_switch)))
 lensw=len_trim(keywords(nn_switch))

 ! we scan now the begin of all potential keywords to find the end of the string after the switch
 call power_scan_for_keyword(command_line,keywords,nmax,nn_next,ind+lensw,ind_end)

 if(ind==0) then
    if(loc_stop_on_error) then
      if(power_extract_comm_output_on) then
       write(*,'(a,a,a)') 'extract_command_parameter: did not found "',&
        trim(switch),'" in command line'
       write(*,'(a)') trim(command_line)
       write(*,'(a)') 'syntax of command line is'
       write(*,'(a)') trim(syntax)
    end if
       stop 'extract_command_parameter: parameter not found in command line'
    endif
    result_value=1
 else
    result_value=0
         !!   write(*,'(3a)') 'try to read integer(kind=ik) from  "',command_line(ind+lensw:ind_end),'"'
    read(command_line(ind+lensw:ind_end),*,iostat=status) value
    if(status/=0) then
       if(loc_stop_on_error) then
        if(power_extract_comm_output_on) then
            write(*,'(3a)') &
              'power_extract_command_parameter_integer: error reading integer(kind=ik) parameter for switch "'&
              ,trim(switch),'"'
            write(*,'(3a)') 'found no integer(kind=ik) in "',command_line(ind+lensw:ind_end),'"'
          end if
          stop 'power_extract_command_parameter_integer: error reading integer(kind=ik) parameter for switch'
       endif
    endif
    if(power_extract_comm_output_on) then
      write(*,'(a,i0,a,a,a)') 'extract_command_parameter: found integer(kind=ik) "',&
        value,'" for switch "',trim(switch),'"'
    endif
 endif


end function power_extract_command_parameter_integer

end module power_extract_command

