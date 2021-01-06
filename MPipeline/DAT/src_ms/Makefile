# Makefile for MIRI Sloper
#   Part 1 of the MIRI data pipeline
#
# August 2007 - J. Morrison 




MS_SRCS = miri_sloper.cpp \
	../src_gen/miri_fits.cpp \
	../src_gen/StringToLower.cpp \
	../src_gen/FindMedian.cpp \
	../src_gen/piksrt.cpp \
	../src_gen/linfit.cpp \
	../src_gen/PixelXY_PixelIndex.cpp \
	../src_gen/PixelIndex_PixelXY.cpp \
	../src_gen/Check_CDPfile.cpp \
	miri_search_keys.cpp \
	miri_search_CDP.cpp \
	ms_get_CDP_names.cpp \
	ms_usage.cpp \
	ms_initialize_control.cpp \
	ms_parse_commandline.cpp \
	ms_update_control.cpp \
	ms_initialize_data_info.cpp \
	ms_setup_output_files.cpp \
	ms_read_header.cpp \
	ms_read_process_data.cpp \
	ms_2pt_diff_quick.cpp\
	ms_subtract_refdata.cpp \
	ms_read_refdata.cpp \
	ms_filenames.cpp \
	ms_read_preferences.cpp \
	ms_miri_pixel.cpp \
	ms_miri_refcorrection.cpp \
	ms_miri_segment.cpp \
	ms_miri_dark.cpp \
	ms_miri_lin.cpp \
	ms_miri_CDP.cpp \
	ms_miri_rscd.cpp \
	ms_miri_mult.cpp \
	ms_setup_processing.cpp \
	ms_get_param2.cpp \
	ms_screen_info.cpp \
	ms_find_refcorrection.cpp \
	ms_read_dark_reference_pixels.cpp\
	ms_process_refimage_data.cpp\
	ms_write_reduced_refimage.cpp \
	ms_write_reduced_file.cpp \
	ms_write_reduced_header.cpp\
	ms_write_processing_to_header.cpp\
	ms_read_badpixel_fits.cpp  \
	ms_read_RSCD_file.cpp  \
	ms_read_MULT_file.cpp  \
	ms_read_linearity_file.cpp  \
	ms_adjust_caldata.cpp \
	ms_final_slope.cpp \
	ms_write_final_data.cpp \
	ms_adjust_control.cpp \
	ms_adjust_control_end.cpp \
	ms_write_intermediate_data.cpp \
	ms_write_segments.cpp \
	ms_QuickerSlope.cpp \
	ms_lin_apply_correction.cpp \
	ms_ScreenFrames.cpp \
	ms_determine_CAL_Subarray.cpp \
	FindCleanMean.cpp \
	FilterRefPixel.cpp \
	FindMovingMean.cpp \
	ms_setup_dark.cpp \
	ms_read_frame_from_int.cpp \
	ms_read_lastframe_file.cpp \
	ms_read_CAL_header.cpp \
	MatrixInvert.cpp \
	Poly_Fit.cpp \
	ms_miri_reset.cpp \
	ms_read_reset_file.cpp \
	ms_fillin_segments.cpp 




MS_OBJS = ${MS_SRCS:.cpp=.o}


RM = rm -f

CC = llvm-g++   -g -Wall 
#CC = g++
MAKE = make
DIFLAGS = -Y./include

#for linux
LDFLAGS = -L../lib/cfitsio -lcfitsio -lcurl  
CCFLAGS = -O2 -funroll-loops -Iinclude -I../src_gen/include -I../lib/cfitsio -Wno-deprecated  -D_FILE_OFFSET_BITS=64 -DHAVE_LONGLONG=1 -D_LARGEFILE_SOURCE=1
#for solaris
#LDFLAGS = -L../lib/cfitsio -lcfitsio -lsocket -lnsl -L /usr/local/lib -R /usr/local/lib
#CCFLAGS = -O2 -Iinclude -I../src_gen/include -I../lib/cfitsio -I /usr/local/include -Wno-deprecated -D_FILE_OFFSET_BITS=64 -DHAVE_LONGLONG=1 -D_LARGEFILE_SOURCE=1 -DSOLARIS

all: miri_fitsio miri_sloper

miri_sloper: miri_fitsio $(MS_OBJS) $(MS_HDS)
	$(CC) -o ${@} $(MS_OBJS) $(CCFLAGS) $(LDFLAGS)
	cp miri_sloper ../.

miri_fitsio:
	cd ../lib/cfitsio; $(MAKE)

depend: 
	makedepend -- $(DIFLAGS) -- $(MS_SRCS)

# ----------
# cleaning targets
# ----------

clean_all: clean clean_lfitsio

clean: 
	$(RM) *.o
	$(RM) miri_sloper

clean_lfitsio:
	cd ../lib/cfitsio; $(MAKE) clean

# ----------
# suffixes
# ----------

.SUFFIXES : .o .cpp

.cpp.o : $(HDS)
	$(CC) -o ${*}.o $(CCFLAGS) -c $<

# DO NOT DELETE

miri_sloper.o: ./include/miri_sloper.h ./include/miri_control.h ./include/miri_pixel.h
miri_sloper.o: ./include/miri_data_info.h ./include/miri_preference.h  
miri_sloper.o: ./include/miri_refcorrection.h ../src_gen/include/miri_constants.h
miri_sloper.o:  ./include/miri_CDP.h ./include/miri_reset.h  
ms_miri_pixel.o: ./include/miri_pixel.h   ../src_gen/include/lin_constants.h
ms_miri_segment.o: ./include/miri_segment.h
ms_miri_refcorrection.o: ./include/miri_refcorrection.h
ms_miri_dark.o: ./include/miri_dark.h
ms_miri_lin.o: ./include/miri_lin.h
ms_parse_commandline.o: ./include/miri_sloper.h ./include/miri_control.h
ms_read_preferences.o:  ./include/miri_control.h ./include/miri_preference.h ./include/miri_sloper.h
miri_search_keys.o:   ./include/miri_preference.h 
miri_search_CDP.o:  
ms_update_control.o:  ./include/miri_control.h ./include/miri_preference.h
ms_get_CDP_names.o:  ./include/miri_control.h ./include/miri_data_info.h ./include/miri_CDP.h
ms_parse_raw_header.o: ./include/miri_sloper.h ./include/miri_data_info.h ./include/miri_control.h
ms_parse_raw_header.o: ../src_gen/include/miri_constants.h
ms_setup_processing.o: ./include/miri_sloper.h  ./include/miri_pixel.h ./include/miri_control.h
ms_setup_processing.o: ./include/miri_data_info.h  ../src_gen/include/miri_constants.h ./include/miri_CDP.h
ms_get_param2.o: ./include/miri_sloper.h 
ms_write_reduced_file.o: ./include/miri_sloper.h ./include/miri_control.h ./include/miri_data_info.h
ms_write_intermediate_data.o: ./include/miri_sloper.h ./include/miri_pixel.h ./include/miri_data_info.h
ms_refcorrection.o:  ./include/miri_control.h ./include/miri_data_info.h
ms_refcorrection.o:  ./include/miri_refcorrection.h
ms_find_refcorrection.o:  ./include/miri_control.h ./include/miri_data_info.h
ms_find_refcorrection.o:  ./include/miri_refcorrection.h ./include/miri_CDP.h
ms_read_reset_file.o: ./include/miri_data_info.h  ./include/miri_control.h   ./include/miri_CDP.h  ./include/miri_reset.h
ms_read_dark_reference_pixels.o:  ./include/miri_control.h ./include/miri_data_info.h
ms_read_dark_reference_pixels.o:  ./include/miri_refcorrection.h ./include/miri_CDP.h
ms_write_reduced_refimage.o: ./include/miri_sloper.h ./include/miri_control.h ./include/miri_data_info.h
ms_write_reduced_header.o: ./include/miri_sloper.h ./include/miri_control.h ./include/miri_data_info.h
ms_write_reduced_header.o: ../src_gen/include/dhas_version.h ./include/miri_CDP.h
ms_write_segments.o: ./include/miri_sloper.h ./include/miri_data_info.h ./include/miri_pixel.h
ms_fillin_segments.o: ./include/miri_sloper.h ./include/miri_data_info.h ./include/miri_pixel.h ./include/miri_segment.h
ms_write_processing_to_header.o: ./include/miri_sloper.h ./include/miri_control.h ./include/miri_data_info.h
ms_write_processing_to_header.o: ../src_gen/include/dhas_version.h
ms_initialize_control.o: ./include/miri_control.h 
ms_initialize_data_info.o: ./include/miri_sloper.h ./include/miri_data_info.h 
ms_read_header.o:  ./include/miri_data_info.h ./include/miri_control.h ../src_gen/include/miri_constants.h
ms_setup_output_files.o: ./include/miri_data_info.h  ./include/miri_control.h 
ms_ScreenFrames.o:   ./include/miri_data_info.h ./include/miri_control.h
ms_read_process_data.o:  ./include/miri_pixel.h ./include/miri_data_info.h 
ms_read_process_data.o:  ../src_gen/include/miri_constants.h ./include/miri_sloper.h
ms_read_process_data.o:  ./include/miri_refcorrection.h ./include/miri_rscd.h ./include/miri_mult.h    
ms_miri_reset.o: ./include/miri_reset.h
ms_read_refdata.o:   ./include/miri_pixel.h ./include/miri_data_info.h  
ms_subtract_refdata.o:  ./include/miri_pixel.h ./include/miri_data_info.h ./include/miri_control.h
ms_subtract_refdata.o:  ./include/miri_refcorrection.h 
ms_set_id_flags_refimage.o: ./include/miri_pixel.h 
ms_set_id_flags_refimage.o: ./include/miri_data_info.h ./include/miri_control.h 
ms_determine_CAL_Subarray.o: ./include/miri_data_info.h ./include/miri_control.h ./include/miri_CDP.h 
ms_read_CAL_header.o: ./include/miri_sloper.h 
ms_2pt_diff.o: ./include/miri_pixel.h  ../src_gen/include/miri_constants.h
ms_filenames.o:  ./include/miri_data_info.h ./include/miri_control.h
ms_screen_info.o: ./include/miri_control.h ./include/miri_data_info.h
ms_process_refimage_data.o : ./include/miri_pixel.h ./include/miri_control.h 
ms_process_refimage_data.o : ./include/miri_data_info.h ../src_gen/include/miri_constants.h
ms_read_badpix_fits.o : ./include/miri_data_info.h 
ms_read_linearity_file.o : ./include/miri_data_info.h  ./include/miri_control.h  ./include/miri_CDP.h  
ms_read_linearity_file.o : ./include/miri_lin.h  
ms_read_RSCD_file.o : ./include/miri_data_info.h  ./include/miri_CDP.h  ./include/miri_control.h ./include/miri_rscd.h
ms_read_MULT_file.o : ./include/miri_data_info.h  ./include/miri_CDP.h  ./include/miri_control.h ./include/miri_mult.h
ms_read_lastframe_file.o : ./include/miri_data_info.h  ./include/miri_CDP.h  ./include/miri_control.h 
ms_read_frame_from_int.o: ./include/miri_data_info.h  
ms_adjust_caldata.o : ./include/miri_CDP.h 
ms_calculate_frame_time.o: ./include/miri_data_info.h  ./include/miri_control.h 
ms_QuickerSlope.o: ./include/miri_data_info.h  ./include/miri_control.h 
ms_setup_dark.o: ./include/miri_data_info.h  ./include/miri_control.h   ./include/miri_CDP.h  ./include/miri_dark.h
ms_final_slope.o:  ./include/miri_control.h 
ms_adjust_control.o: ./include/miri_data_info.h  ./include/miri_control.h 
ms_adjust_control_end.o: ./include/miri_data_info.h  ./include/miri_control.h 


