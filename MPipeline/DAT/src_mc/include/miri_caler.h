#include <string>
#include <strstream>
#include <iostream>
#include <iomanip>
#include <fstream>
#include <cmath>
#include <vector>
#include "fitsio.h"
#include "mc_control.h"
#include "mc_data_info.h"
#include "mc_preference.h"
#include "miri_constants.h"



// namespaces
using namespace std;

// external procedures/functions

// outputs how to use miri_sloper (command line options)
extern void mc_usage();


// copies the current header in ifptr to ofptr
extern int miri_copy_header(fitsfile *ifptr,
                            fitsfile *ofptr,
                            int status);

extern int mc_read_filterid(const mc_control control,mc_data_info &data_info);
extern int mc_DGPOS(mc_data_info &data_info);

// parse the commandline
extern void mc_parse_commandline(int& argc, 
				 char* argv[],
				 mc_control &);

extern void mc_initialize_control(mc_control &);

// output info to screen
extern void mc_screen_info(mc_control, mc_data_info&);


extern void mc_initialize_data_info(mc_data_info &);

extern void mc_filenames(mc_data_info &, mc_control);

// read the preferences file
extern void mc_read_preferences( mc_control&, mc_preference&);

extern void mc_update_control( mc_control&, mc_preference&);


// gets various user set parameters
extern int mc_get_param2(string param_filename,mc_preference& );

// parse the reduced fits header to learn the details of the data
extern void mc_read_header(mc_data_info &, mc_control &);

extern void mc_read_data( const int,
			  mc_data_info &,
			  vector<float>&,
			  vector<float>&,
			  vector<float>& );


// copies the current header in ifptr to ofptr
extern int miri_copy_header(fitsfile *ifptr,
			    fitsfile *ofptr,
			    int status);

extern void mc_get_dark(mc_control,
			vector<int> &,
			const long,
			const int);



extern void mc_write_processing_to_header(fitsfile *fptr,
					  mc_control ,
					  string ,
					  mc_data_info& );
extern int mc_read_calibration_files(mc_preference,mc_control&,mc_data_info&);

extern void mc_apply_calibration_data(mc_control,mc_data_info&,
				      vector<float>&,vector<float>&,vector<float>&);
extern void mc_write_calibrated_file(int , mc_control,mc_data_info&,string,
				      vector<float>&,vector<float>&,vector<float>&);






