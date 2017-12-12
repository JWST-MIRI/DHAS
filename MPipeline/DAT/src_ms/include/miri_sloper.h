#include <vector>
#include <string>
#include "fitsio.h"
#include "miri_data_info.h"
#include "miri_control.h"
#include "miri_preference.h"
#include "miri_segment.h"
#include "miri_refcorrection.h"
#include "miri_constants.h"
#include "miri_dark.h"
#include "miri_lin.h"
#include "miri_CDP.h"
#include "miri_pixel.h"
#include "miri_reset.h"

// namespaces
using namespace std;

// external procedures/functions

// outputs how to use miri_sloper (command line options)
extern void ms_usage();

// parse the commandline
extern void ms_parse_commandline(int& argc, 
				 char* argv[],
				 miri_control &);

extern void ms_initialize_control(miri_control &);

// checks the return status of a cfitsio call
extern void miri_check_fits(int status,
			   char text[100]);


extern void  ms_get_CDP_names(miri_CDP &CDP, miri_control control, 
			      miri_data_info &);

extern void ms_initialize_data_info(miri_data_info &);

extern void ms_filenames(miri_data_info &, miri_control);
extern int Poly_Fit(vector<double> x, vector<double> y, const int ndegree,
		    vector<double> &poly_fit, vector<double> &yfit, vector<double> &sigma,
		    double &chisq, double &yerror,const int debug); 


extern vector< vector<double> >  MatrixInvert( vector< vector<double> > A, const int N );

extern void ms_read_frame_from_int(miri_data_info &data_info,
				   const int i,
				   int iframe, 
				   vector<float> &lastframe);

extern int ms_determine_CAL_Subarray(const int, miri_data_info & , miri_control ,miri_CDP&);
extern void ms_read_CAL_header(string, long&, long&, long&, long&, int&, int&);


extern void ms_determine_linearity_filename(miri_data_info &, miri_control &,const int);
// parse the raw fits header to learn the details of the data
extern void ms_read_header(miri_data_info &, miri_control);


extern void ms_calculate_frame_time(miri_control,miri_data_info &);


extern void ms_read_dark_reference_pixels(const int, 
				   miri_control &,
				   miri_data_info &,
				   miri_CDP CDP,
				   vector<miri_refcorrection> &);

extern void ms_find_refcorrection( const int,
				   miri_control &, 
				   miri_data_info &,
				   miri_CDP,
				   vector<miri_refcorrection> &);


extern void ms_read_data( const int,
			  const int,
			  const int,
			  const int, 
			  const int,
			  const float,
			  const int,
			  miri_data_info &,
			  vector<miri_pixel> &);

extern void ms_read_process_data(const int iter,
				 const int isubset,
				 const int this_nrow,
				 const int refimage,  // = 0 if science data, = 1 if ref output 
				 vector<miri_reset> &reset,
				 vector<float> &lastframe,
				 vector<float> &lastframe_corr,
				 vector<float> lastframe_rscd,
				 vector<miri_dark> &dark,
				 vector<miri_lin> &linearity,
				 miri_control &control,
				 miri_data_info &data_info,
				 miri_CDP CDP,
				 vector<int> FrameBad,
				 const int NFramesBad,
				 vector<miri_pixel> &pixel,
				 vector<miri_refcorrection> &refcorrection,
				 vector<float> &Slope,
				 vector<float> &SlopeUnc,
				 vector<float> &SlopeID,
				 vector<float> &ZeroPt,
				 vector<float> &NumGood,
				 vector<float> &ReadNumFirstSat,
				 vector<float> &NumGoodSeg,
				 vector<float> &RMS,
				 vector<float> &Max2ptDiff,
				 vector<float> &IMax2ptDiff,
				 vector<float> &StdDev2pt,
				 vector<float> &Slope2ptDiff);



extern void ms_QuickerSlope( const int iter,
			     const int isubset,
			     const int this_nrow,
			     miri_control &control,
			     miri_data_info &data_info,
			     vector<float> &Slope,
			     vector<float> &ZeroPt,
			     vector<float> &RMS);

extern void ms_PulseMode ( const int iter,
			   const int isubset,
			   const int this_nrow,
			   miri_control &control,
			   miri_data_info &data_info,
			   vector<float> &Slope);


extern void ms_setup_dark( const int integ,
			   const int isubset,
			   const int this_nrow,
			   miri_control &control,
			   miri_data_info &data_info,
			   miri_CDP &CDP,
			   vector<miri_dark> &);

extern void ms_read_reset_file( const int iter,
			   miri_control &control,
			   miri_data_info &data_info,
			   miri_CDP &CDP,
			   vector<miri_reset> &);


extern int ms_read_lastframe_file( miri_control &control,
				    miri_data_info &data_info,
				    miri_CDP &CDP);

extern int ms_read_RSCD_file( miri_data_info &data_info,
			      miri_control &control,
			      miri_CDP &CDP);

extern void ms_read_refdata(const int,
			    const int,
			    const int,
			    const int,
			    const float,
			    const float,
			    const float,
			    miri_data_info &,
			    vector<miri_pixel> &); 

extern void ms_setBad_id_flags( const int, const int,
				miri_data_info &,
				vector<miri_pixel> &);

extern void ms_set_id_flags_refimage( miri_control ,
				      miri_data_info &,
				      vector<miri_pixel> &);


extern void ms_subtract_refdata( const int,
				 const int,
				 const int,
				 const int,
				 miri_control &,
				 miri_data_info &,
				 vector<miri_pixel>&,
				 vector<miri_refcorrection> &);
// read the preferences file
extern void ms_read_preferences( miri_control&, miri_preference&);

extern void ms_update_control( miri_control&, miri_preference&);

// setup the processing
extern void ms_setup_processing(miri_control&,
				miri_data_info&,
				miri_preference &preference,
				miri_CDP &CDP);

// gets various user set parameters
extern int ms_get_param(string param_filename,miri_preference& );
extern int ms_get_param2(string param_filename,miri_preference& );


extern int Check_CDPfile(string filename);
// converting 1-d vector to 2-d array 
extern void  ms_PixelIndex_PixelXY(const int, const long, int&, int &);



// copies the current header in ifptr to ofptr
extern int miri_copy_header(fitsfile *ifptr,
			    fitsfile *ofptr,
			    int status);

// setup the output files
extern void ms_setup_output_files(miri_control, miri_data_info&);
extern void ms_setup_reduced_refimage_file(miri_control, miri_data_info&);


// output info to screen

extern void ms_screen_info(miri_control, miri_data_info&);

// update the output files (move and create new extensions)
//extern void ms_update_output_files(miri_control,miri_data_info& );


// process the  data ramps
extern void ms_process_data (
			       miri_control,
			       miri_data_info&,
			       vector<miri_pixel>&,
			       vector<float>&,
			       vector<float>&,
			       vector<float>&,
			       vector<float>&,
			       vector<float>&,
			       vector<float>&,
			       vector<float>&,
			       vector<float>&,
			       vector<float>&,
			       vector<float>&,
			       vector<float>&,
			       vector<float>&);

extern void ms_process_refimage_data (
			       miri_control,
			       miri_data_info&,
			       vector<int> FramesBad,
			       const int NFramesBad,
			       vector<miri_pixel>&,
			       vector<float>&,
			       vector<float>&,
			       vector<float>&,
			       vector<float>&,
			       vector<float>&,
			       vector<float>&,
			       vector<float>&);


// setup the output reduced file
extern void ms_write_reduced_header(miri_control,string, miri_data_info&,miri_CDP);

extern void ms_write_processing_to_header(fitsfile *fptr,
					  const int,
					  const int, 
					  miri_control ,
					  int,
					  vector<int>,
					  string ,
					  miri_data_info&,
					  miri_CDP CDP,
					  int);

int ms_read_badpixel_fits(string, miri_data_info&, miri_CDP&,const int );
void ms_adjust_caldata(const int, const int,miri_data_info&,   miri_CDP& );

int ms_read_linearity_file( miri_data_info &,
			   miri_control &control,
			   miri_CDP &CDP,
			   vector<miri_lin> &linearity);


int ms_read_mean_dark_correction(string, const int, 
				 miri_data_info&, const int );

extern void ms_write_reduced_file(const int,
				  miri_data_info&,
				  miri_control,
				  miri_CDP,
				  string,
				  const int,
				  vector<int>,
				  vector<float>&,
				  vector<float>&,
				  vector<float>&,
				  vector<float>&,
				  vector<float>&,
				  vector<float>&,
				  vector<float>&,
				  vector<float>&,
				  vector<float>&,
				  vector<float>&,
				  vector<float>&,
				  vector<float>&);


extern void ms_write_reduced_refimage(const int,
				      miri_data_info&,
				      miri_control,
				      miri_CDP,
				      string,
				      const int NFramesBad,
				      vector<int> FrameBad,
				      vector<float>&,
				      vector<float>&,
				      vector<float>&,
				      vector<float>&,
				      vector<float>&,
				      vector<float>&,
				      vector<float>&);



extern void ms_2pt_diff_quick(const int,
			      const int,
			      const int,
			      const int,
			      miri_pixel &,
			      const float,
			      const int,
			      const int,
			      const int,
			      const float,
			      long &,
			      long &,
			      long &,
			      long &);


extern void ms_final_slope( const int,
			    miri_control,
			    const int, 
			    vector<float> Slope, 
			    vector<float> SlopeUnc, 
			    vector<float> SlopeID, 
			    vector<float> &Final_Slope, 
			    vector<float> &Final_SlopeUnc, 
			    vector<float> &Final_SlopeID);

extern void ms_write_final_data(int type,
				fitsfile *ifptr,
				const long[3],
				const int, 
				const int, 
				miri_data_info& data_info,
				vector<float> &Final_Slope,
				vector<float> &Final_SlopeUnc,
				vector<float> &Final_SlopeID) ;


extern void ms_write_refcorrected_data( const int iter,
					const int isubset,
					const int this_nrow,
					const int ramp_start,
					miri_data_info &data_info,
					vector<miri_pixel> &pixel);

extern void ms_write_ids( const int iter,
					const int isubset,
					const int this_nrow,
					const int ramp_start,
					const int ramp_end,
					miri_data_info &data_info,
					vector<miri_pixel> &pixel);

extern void ms_write_intermediate_data( const int write_output_refpixel_corrections,
					const int write_output_ids,
					const int write_output_lc_correction,
					const int write_output_dark_correction,
					const int subtract_dark,
					const int write_output_reset_correction,
					const int write_output_lastframe_correction,
					const int write_output_rscd_correction,
					const int iter,
					const int isubset,
					const int this_nrow,
					const int ramp_start,
					miri_data_info &data_info,
					vector<miri_pixel> &pixel);


extern void ms_write_segments( const int iter,
			       miri_data_info &data_info,
			       vector<miri_segment> &segment);


extern void ms_fillin_segments(const int isubset,
			       const int this_nrow,
			       const int nframe_start_fit,
			       miri_data_info &data_info,
			       vector<miri_pixel> &pixel,
			       vector<miri_segment> &segment);

extern void ms_adjust_control(miri_data_info & , miri_control &);
extern void ms_adjust_control_end(miri_data_info &,miri_control &);


extern int ms_ScreenFrames( const int iter,
			    miri_control &control,
			    miri_data_info &data_info,
			    vector<int> &FrameBad,
			    int &nBad);


