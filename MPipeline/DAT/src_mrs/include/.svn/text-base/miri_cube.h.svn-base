#ifndef CB
#define CB

#include <sstream>
#include <cstdlib>
#include <strstream>
#include <vector>
#include <string>
#include <iostream>
#include "fitsio.h"
#include "mrs_control.h"
#include "mrs_preference.h"
#include "mrs_data_info.h"
#include "mrs_CubeHeader.h"
#include "mrs_ReducedHeader.h"
#include "mrs_ReducedData.h"
#include "mrs_SubPixel.h"
#include "mrs_Tile.h"

// namespaces

using namespace std;




// external procedures/functions

// outputs how to use cube_builder (command line options)
extern void mrs_usage();

// copies the current header in ifptr to ofptr
extern int miri_copy_slope_header(fitsfile *ifptr,
			    fitsfile *ofptr,
			    int status);

// parse the commandline
extern void mrs_parse_commandline(int& argc, 
				 char* argv[],
				 mrs_control &);

extern void mrs_initialize_control(mrs_control &);

// read the preferences file
extern void mrs_read_preferences( mrs_control&, mrs_preference&,mrs_data_info&);

extern void mrs_update_control( mrs_control&, mrs_preference&);

// gets various user set parameters
extern int mrs_get_param(string param_filename,mrs_preference& );

extern int mrs_get_cube_size(string cubedim_filename,
			 mrs_preference& preference);


extern int mrs_check_files(mrs_data_info &data_info);



extern int mrs_read_input_list(const mrs_control, mrs_data_info&);
extern int mrs_read_waveid(const mrs_control, mrs_data_info&);

extern int mrs_DGPOS(mrs_data_info &data_info);

extern int mrs_read_calibration_file(const mrs_control,
				     const mrs_preference,
				     mrs_data_info &);

extern int mrs_read_calibration_file_new(const mrs_control,
				     const mrs_preference,
				     mrs_data_info &);

extern int mrs_sizes(const mrs_control,
		     const mrs_preference,
		     mrs_data_info &);

extern void   mrs_xy2abl(int slice_no,float beta_zero,float beta_delta,float xas, vector<float>kalpha,
		  float xls,vector<float>klambda,float ix,float iy,float &alpha,float &beta,float &lambda);


extern void   mrs_ab2v2v3( float alpha,float beta,float v2coeff, float v3coeff,float &v2, float &v3);

extern void mrs_write_header(fitsfile *, CubeHeader, mrs_control,mrs_data_info);

extern void mrs_filenames(CubeHeader &,mrs_data_info&,mrs_control &);
extern int mrs_read_header(ReducedHeader [],CubeHeader& , const mrs_control);


extern void mrs_determine_geometry(int & i, const mrs_control control,
				   const mrs_preference preference,
				   const mrs_data_info data_info,
				   CubeHeader &cubeHead);

extern void mrs_Setup_Cube(mrs_data_info, CubeHeader& ,const int);
extern void mrs_Setup_Tile(const int,  mrs_data_info, CubeHeader& ,Tile&,const int);
extern void mrs_Cube_Tile(const mrs_control,CubeHeader &);

extern int mrs_read_data(const int, const int, const int,
			 const int, 
			 const int, const int,
			 long &,
			 mrs_data_info&,
			 CubeHeader, 
			 ReducedHeader,
			 vector<ReducedData> &,
			  int );

extern void mrs_data_size(const int, const int, CubeHeader, mrs_data_info, const int,
			  long &, const int);


extern void mrs_FindMedian(const vector<float>, float&);

extern void mrs_FindMedianUncertainty(const vector<float>, const vector<float>, float&, float&);

extern void piksrt (vector <float> &, vector<long>&);


extern void  mrs_overlap(const int, const int, const long,
			 CubeHeader , 
			 Tile &,
			 vector<ReducedData>&,
			 vector<SubPixel>&,
			 int&,
			 const int,
			 const int);



extern int mrs_write_mapping_file(const int channel_type,
				  const int islice,
				  const long numpixels_read,
				  mrs_data_info &data_info,
				  CubeHeader cubeHead,
				  vector<ReducedData> &RData,
				  int verbose);


extern int mrs_trim_mapping_file(mrs_data_info &data_info);



extern void mrs_SetIndex(const int,CubeHeader,
			 vector<SubPixel> &);


void mrs_aveflux(const long,
		 CubeHeader, 
		 Tile &,
		 vector<SubPixel> &);

// converting 1-d vector to 2-d array 
extern void  mrs_PixelIndex_PixelXY(const int, const long, int&, int &);

// converting 2-d  array to 1-d vector 
extern void mrs_PixelXY_PixelIndex(const int,const int , const int ,long &);


// converting 1-d vector to 3-d array 
extern void  mrs_CubeIndex_CubeXYZ(const int, const int, const long, int&, int &, int&);

// converting 3-d  array to 1-d vector 
extern void mrs_CubeXYZ_CubeIndex(const int,const int , 
				  const int , const int, const int,
				  long &);


void mrs_write_tile(fitsfile *, const int,  CubeHeader &,Tile &, mrs_control, mrs_data_info);
void mrs_setup_output_cube(fitsfile *, CubeHeader &, mrs_control, mrs_data_info);






#endif
