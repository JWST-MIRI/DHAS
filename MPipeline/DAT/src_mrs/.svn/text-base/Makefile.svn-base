# Make file for Building Spectral Cube
MRS_SRCS = miri_cube.cpp \
	../src_gen/Check_CDPfile.cpp \
	../src_gen/miri_fits.cpp \
	mrs_usage.cpp \
	mrs_check_files.cpp \
	mrs_initialize_control.cpp \
	mrs_parse_commandline.cpp \
	mrs_update_control.cpp \
	mrs_read_preferences.cpp \
	mrs_get_param.cpp \
	mrs_read_input_list.cpp \
	mrs_read_calibration_file_new.cpp \
	mrs_sizes.cpp \
	mrs_xy2abl.cpp \
	mrs_ab2v2v3.cpp \
	mrs_CubeHeader.cpp\
	mrs_SetIndex.cpp\
	mrs_determine_geometry.cpp \
	mrs_Setup_Cube.cpp \
	mrs_Setup_Tile.cpp \
	mrs_FindMedian.cpp\
	mrs_FindMedianUncertainty.cpp \
	piksrt.cpp\
	mrs_ReducedHeader.cpp \
	mrs_Tile.cpp\
	mrs_SubPixel.cpp\
	mrs_read_waveid.cpp \
	mrs_DGPOS.cpp\
	mrs_filenames.cpp \
	mrs_read_header.cpp \
	mrs_ReducedData.cpp \
	mrs_data_size.cpp \
	mrs_read_data.cpp \
	mrs_findAreaQuad.cpp \
	mrs_findAreaPoly.cpp \
	mrs_SH_findOverlap.cpp\
	mrs_PixelIndex_PixelXY.cpp \
	mrs_PixelXY_PixelIndex.cpp \
	mrs_CubeIndex_CubeXYZ.cpp \
	mrs_CubeXYZ_CubeIndex.cpp \
	mrs_write_tile.cpp \
	mrs_setup_output_cube.cpp \
	mrs_aveflux.cpp \
	mrs_overlap.cpp \
	mrs_write_mapping_file.cpp\
	mrs_trim_mapping_file.cpp\
	mrs_write_header.cpp 


#	mrs_Cube_Tile.cpp \

MRS_OBJS = ${MRS_SRCS:.cpp=.o}

RM = rm -f

CC = g++ -ansi  -g -Wall -Wno-long-long -pedantic 
#CC = g++
MAKE = make
DIFLAGS = -Y./include

#for linux
LDFLAGS = -L../lib/cfitsio -lcfitsio  
CCFLAGS = -O2 -funroll-loops -Iinclude -I../src_gen/include -I../lib/cfitsio -Wno-deprecated -D_FILE_OFFSET_BITS=64  -D_LARGEFILE_SOURCE=1
#for solaris
#LDFLAGS = -L../lib/cfitsio -lcfitsio -lsocket -lnsl -L /usr/local/lib -R /usr/local/lib
#CCFLAGS = -O2 -Iinclude -I../src_gen/include -I../lib/cfitsio -I /usr/local/include -Wno-deprecated -DSOLARIS -D_FILE_OFFSET_BITS=64  -D_LARGEFILE_SOURCE=1


all: miri_fitsio miri_cube

miri_cube: miri_fitsio $(MRS_OBJS) $(MRS_HDS)
	$(CC) -o ${@} $(MRS_OBJS) $(CCFLAGS) $(LDFLAGS)
	cp miri_cube ../.

miri_fitsio:
	cd ../lib/cfitsio; $(MAKE)

depend: 
	makedepend -- $(DIFLAGS) -- $(MRS_SRCS)

# ----------
# cleaning targets
# ----------
clean_all: clean clean_lfitsio

clean: 
	$(RM) *.o
	$(RM) miri_cube

clean_lfitsio:
	cd lib/cfitsio; $(MAKE) clean

# ----------
# suffixes
# ----------

.SUFFIXES : .o .cpp

.cpp.o : $(HDS)
	$(CC) -o ${*}.o $(CCFLAGS) -c $<

# DO NOT DELETE

miri_cube.o: ./include/miri_cube.h ./include/mrs_control.h ./include/mrs_CubeHeader.h 
miri_cube.o: ./include/mrs_preference.h ./include/mrs_data_info.h 
miri_cube.o: ./include/mrs_ReducedData.h ./include/mrs_Tile.h ./include/mrs_SubPixel.h
mrs_CubeHeader.o: ./include/mrs_CubeHeader.h
mrs_Tile.o: ./include/mrs_Tile.h
mrs_SubPixel.o: ./include/mrs_SubPixel.h ./include/mrs_constants.h
mrs_ReducedHeader.o : ./include/mrs_ReducedHeader.h
mrs_ReducedData.o : ./include/mrs_ReducedData.h
mrs_initialize_control.o: ./include/mrs_control.h 
mrs_parse_commandline.o: ./include/mrs_control.h
mrs_read_preferences.o:  ./include/mrs_control.h ./include/mrs_preference.h 
mrs_read_preferences.o:  ./include/mrs_data_info.h
mrs_update_control.o:  ./include/mrs_control.h ./include/mrs_preference.h
mrs_read_input_list.o : ./include/mrs_control.h ./include/mrs_data_info.h
mrs_check_files.o:  ./include/mrs_data_info.h ./include/mrs_constants.h  ../src_gen/include/miri_constants.h
mrs_get_param.o: ./include/miri_cube.h ./include/mrs_preference.h 
mrs_read_waveid.o : ./include/mrs_control.h ./include/mrs_data_info.h ./include/mrs_constants.h
mrs_read_waveid.o : ../src_gen/include/miri_constants.h 
mrs_read_DGPOS.o : ./include/mrs_data_info.h 
mrs_read_calibration_file.o : ./include/mrs_preference.h  ./include/mrs_control.h
mrs_read_calibration_file.o : ./include/mrs_data_info.h  ./include/mrs_constants.h
mrs_read_calibration_file_new.o : ./include/mrs_preference.h  ./include/mrs_control.h
mrs_read_calibration_file_new.o : ./include/mrs_data_info.h  ./include/mrs_constants.h
mrs_sizes.o : ./include/mrs_preference.h  ./include/mrs_control.h
mrs_sizes.o : ./include/mrs_data_info.h  ./include/mrs_constants.h
mrs_Setup_Cube.o : ./include/mrs_CubeHeader.h   ./include/mrs_constants.h ./include/mrs_data_info.h
mrs_Setup_Tile.o : ./include/mrs_CubeHeader.h  ./include/mrs_constants.h
mrs_Setup_Tile.o : ./include/mrs_data_info.h ./include/mrs_Tile.h
mrs_determine_geometry.o : ./include/mrs_CubeHeader.h ./include/mrs_control.h ./include/mrs_data_info.h
mrs_determine_geometry.o : ./include/mrs_constants.h ./include/mrs_preference.h 
mrs_Cube_Tile.o : ./include/mrs_CubeHeader.h  ./include/mrs_control.h 
mrs_data_size.o : ./include/mrs_CubeHeader.h  ./include/mrs_data_info.h 
mrs_read_header.o : ./include/mrs_ReducedHeader.h ./include/mrs_CubeHeader.h ./include/mrs_control.h
mrs_read_data.o :	./include/mrs_CubeHeader.h ./include/mrs_ReducedData.h 
mrs_read_data.o :	./include/mrs_data_info.h  ./include/mrs_constants.h ./include/mrs_ReducedHeader.h
mrs_overlap.o:	./include/mrs_Tile.h  ./include/mrs_data_info.h
mrs_overlap.o:	./include/mrs_CubeHeader.h ./include/mrs_ReducedData.h  ./include/mrs_SubPixel.h 
mrs_setup_output_cube.o:./include/mrs_CubeHeader.h  ./include/mrs_control.h ./include/mrs_data_info.h
mrs_write_tile.o:./include/mrs_CubeHeader.h ./include/mrs_Tile.h ./include/mrs_data_info.h
mrs_write_tile.o:./include/mrs_control.h
mrs_write_mapping_file.o:./include/mrs_CubeHeader.h ./include/mrs_data_info.h ./include/mrs_ReducedData.h
mrs_write_mapping_file.o:./include/mrs_constants.h
mrs_trim_mapping_file.o: ./include/mrs_data_info.h 
mrs_ab2v2v3.o: ./include/mrs_data_info.h 
mrs_write_header.o : ./include/mrs_control.h ./include/mrs_CubeHeader.h
mrs_filenames.o : ./include/mrs_control.h ./include/mrs_CubeHeader.h 
mrs_filenames.o : ../src_gen/include/miri_constants.h ./include/mrs_constants.h ../src_gen/include/dhas_version.h
mrs_SetIndex.o:  ./include/mrs_SubPixel.h ./include/mrs_CubeHeader.h
mrs_aveflux.o:	./include/mrs_CubeHeader.h ./include/mrs_Tile.h  ./include/mrs_SubPixel.h 
//mrs_read_mapping_file.o : ./include/mrs_control.h ./include/mrs_preference.h ./include/mrs_map_info.h
//mrs_select_mapping_file.o : ./include/mrs_control.h ./include/mrs_preference.h ./include/mrs_map_info.h
//mrs_overlap_mapping.o:	./include/mrs_Tile.h  ./include/mrs_map_info.h ./include/mrs_data_info.h
//mrs_overlap_mapping.o:	./include/mrs_CubeHeader.h ./include/mrs_ReducedData.h  ./include/mrs_SubPixel.h 




