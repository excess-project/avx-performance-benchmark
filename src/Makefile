CC: gcc
CFLAGS1= "-O3" "-Wall" "-D__DO_INFO_SYSLOG_" "-D__DO_DEBUG_SYSLOG_" "-ffast-math" "-fstrict-aliasing" "-funroll-loops" "-msse2" "-fopenmp"
CFLAGS2= "-O3" "-Wall" "-D__DO_INFO_SYSLOG_" "-D__DO_DEBUG_SYSLOG_" "-ffast-math" "-fstrict-aliasing" "-funroll-loops" "-mavx"  "-fopenmp"
LIBRARY=/opt/power/power_tools/21/lib/
DEPS :memo_acc.h hpc_utils.h
LDIR :/usr/lib64

%_msse2.o: %.c $(DEPS)
	$(CC) $(CFLAGS1) -c $< -o $@ 

%.o: %.c $(DEPS)
	$(CC) $(CFLAGS2) -c $< -o $@ 

msse2: init_msse2.o seq_msse2.o fixed_incre_msse2.o list_add_msse2.o rand_index_add_msse2.o para_add_msse2.o config_msse2.o main_msse2.o 
	$(CC) $(CFLAGS1) init_msse2.o seq_msse2.o fixed_incre_msse2.o list_add_msse2.o rand_index_add_msse2.o para_add_msse2.o config_msse2.o main_msse2.o -o msse2 -lini_config -lrt

avx: init.o seq.o fixed_incre.o list_add.o rand_index_add.o para_add.o config.o main.o 
	$(CC) $(CFLAGS2) init.o seq.o fixed_incre.o list_add.o rand_index_add.o para_add.o config.o main.o -o avx -lini_config -lrt -lhpcpower -L${LIBRARY}

clean:
	rm -f *.o
	rm -f avx
	rm -f msse2
	rm -f *~
