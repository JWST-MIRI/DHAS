# Makefile for MIRI Sloper
#   Part 2 of the MIRI data pipeline
#
# October 2007 - J. Morrison 



MC_SRCS = miri_caler.cpp \
	../src_gen/miri_fits.cpp \
	../src_gen/StringToLower.cpp \
	../src_gen/miri_parse_param.cpp \
	../src_gen/PixelXY_PixelIndex.cpp \
	../src_gen/PixelIndex_PixelXY.cpp \
	../src_gen/Check_CDPfile.cpp \
	mc_search_keys.cpp \
	mc_usage.cpp \
	mc_initialize_control.cpp \
	mc_parse_commandline.cpp \
	mc_screen_info.cpp \
	mc_update_control.cpp \
	mc_initialize_data_info.cpp \
	mc_filenames.cpp \
	mc_read_preferences.cpp \
	mc_get_param2.cpp \
	mc_DGPOS.cpp \
	mc_read_calibration_files.cpp\
	mc_read_header.cpp \
	mc_read_data.cpp \
	mc_write_processing_to_header.cpp\
	mc_apply_calibration_data.cpp\
	mc_write_calibrated_file.cpp

MC_OBJS = ${MC_SRCS:.cpp=.o}
RM = rm -f

#CC = g++ -ansi   -Wall 
CC = g++
MAKE = make
DIFLAGS = -Y./include

#for linux
#LDFLAGS = -L../lib/cfitsio -lcfitsio  
#CCFLAGS = -O2 -funroll-loops -Iinclude -I../src_gen/include -I../lib/cfitsio -Wno-deprecated  -D_FILE_OFFSET_BITS=64 -DHAVE_LONGLONG=1 -D_LARGEFILE_SOURCE=1
#for solaris
#LDFLAGS = -L../lib/cfitsio -lcfitsio -lsocket -lnsl -L /usr/local/lib -R /usr/local/lib
#CCFLAGS = -O2 -Iinclude -I../src_gen/include -I../lib/cfitsio -I /usr/local/include -Wno-deprecated -D_FILE_OFFSET_BITS=64 -DHAVE_LONGLONG=1 -D_LARGEFILE_SOURCE=1 -DSOLARIS

all: miri_fitsio miri_caler

miri_caler: miri_fitsio $(MC_OBJS) $(MC_HDS)
	$(CC) -o ${@} $(MC_OBJS) $(CCFLAGS) $(LDFLAGS)
	cp miri_caler ../.

miri_fitsio:
	cd ../lib/cfitsio; $(MAKE)

depend: 
	makedepend -- $(DIFLAGS) -- $(MC_SRCS)

# ----------
# cleaning targets
# ----------

clean_all: clean clean_lfitsio

clean: 
	$(RM) *.o
	$(RM) miri_caler

clean_lfitsio:
	cd lib/cfitsio; $(MAKE) clean

# ----------
# suffixes
# ----------

.SUFFIXES : .o .cpp

.cpp.o : $(HDS)
	$(CC) -o ${*}.o $(CCFLAGS) -c $<

# DO NOT DELETE

miri_caler.o: ./include/miri_caler.h ./include/mc_control.h ./include/mc_preference.h .
miri_caler.o: ./include/mc_data_info.h ../src_gen/include/miri_constants.h
mc_parse_commandline.o: ./include/miri_caler.h ./include/mc_control.h
mc_read_preferences.o:  ./include/mc_control.h ./include/mc_preference.h ./include/miri_caler.h
mc_update_control.o:  ./include/mc_control.h ./include/mc_preference.h ./include/miri_caler.h
mc_get_param.o: ./include/miri_caler.h  ./include/mc_preference.h
mc_write_processing_to_header.o: ./include/miri_caler.h ./include/mc_control.h ./include/mc_data_info.h
mc_DGPOS.o: ./include/miri_caler.h  ./include/mc_data_info.h
mc_initialize_control.o: ./include/mc_control.h 
mc_initialize_data_info.o: ./include/miri_caler.h ./include/mc_data_info.h 
mc_read_header.o:  ./include/mc_data_info.h ./include/mc_control.h ../src_gen/include/miri_constants.h 
mc_read_data.o:   ./include/mc_data_info.h ./include/miri_caler.h ../src_gen/include/miri_constants.h
mc_filenames.o:  ./include/mc_data_info.h ./include/mc_control.h
mc_screen_info.o: ./include/mc_control.h ./include/mc_data_info.h
mc_read_calibration_files.o : ./include/mc_data_info.h  ./include/mc_control.h ../src_gen/include/miri_constants.h 
mc_read_calibration_files.o : ./include/mc_preference.h 
mc_apply_calibration_data.o : ./include/mc_data_info.h  ./include/mc_control.h 
mc_write_calibrated_file.o: ./include/miri_caler.h ./include/mc_control.h ./include/mc_data_info.h



