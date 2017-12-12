// miri_caler.cpp
#include <time.h>
#include <iostream>
#include <cstdlib> // EXIT_FAILURE   , EXIT_SUCCESS

#include "miri_caler.h"
using namespace std;

/**********************************************************************/
/**********************************************************************/
// Part 2 of the MIRI Team  DATA Analysis Pipeline  (DHAS = Pipeline)
/// This software was modelled after the U of A MIPS team (DAT) pipeline,
// developed by Karl Gordon, James Muzerolle  and Karl Misselt for reducing 
// MIPS/SPITIZER data.
// Jane Morrison (U of A) modified it for the MIRI instrument.
//  
//
// written by Jane Morrison
// Oct 2007 - Removed the applying the dark and flat from miri_sloper. 
// August 2009- Added reading the ICE files to determine what subchannel the
//              that data is from (if SW or LW). And added a seperate option
//              to apply the fringe flats
// March 2013   Updated format for reaeing calibration data product to match CDP1 delivery
// May 2013     Changed subtracting dark to subtracting background image
//
/**********************************************************************/
/**********************************************************************/


int main(int argc, char* argv[])

{
  // **********************************************************************
  // tell the user how to use the program if it was not called with enough
  // parameters

  if (argc < 2) {
        mc_usage();
    exit(EXIT_FAILURE);
  }

  int status = 0;
  // **********************************************************************
  // declare the structure which contains the information on how to control
  // the program - determined from the command line options
  // Defaults set in the preferences file.

  time_t t0 ; 
  t0 = time(NULL);

  mc_control control;

  mc_preference  preference;
  // **********************************************************************
  // parse the commandline for all the joyous switches as well as the 
  // name of the FITS file to reduce

  mc_initialize_control(control);
  mc_parse_commandline(argc,argv,control);

  mc_read_preferences(control,preference);
  
  if(control.do_verbose == 1 )cout << " Done reading preferences file" << endl; 
  mc_update_control(control,preference);

  
  // **********************************************************************
  // open and parse the raw data FITS header to get the details of the data
  // and how it was taken

  mc_data_info data_info;

  mc_initialize_data_info(data_info);

  mc_filenames(data_info,control);
  mc_read_header(data_info,control);

  // Removed program figuring out calibration file to use. User has to supply one
  // **********************************************************************
  // We need to determine the sub channel

  int status_subchannel = 0;
  
  status = mc_read_calibration_files(preference,control,data_info);

  if (control.do_verbose == 1) cout << "finished mc_read_calibration_files" << endl;

  // **********************************************************************
  // output the details of the reduction
  mc_screen_info(control,data_info);							     


  // **********************************************************************
  // set up the name of the output header and the primary header

  status = 0;
  fits_create_file(&data_info.cal_file_ptr, data_info.cal_filename.c_str(), &status); 
  if(status !=0){
    cout << "******************************" << endl;
    cout << " Problem opening file " << data_info.cal_filename << endl;
    cout << " Check if directory exists " <<endl;
    exit(EXIT_FAILURE);
    cout << "******************************" << endl;
  }
  
  // ***********************************************************************


  int xsize = data_info.red_naxes[0];
  int ysize = data_info.red_naxes[1];
  long tsize = xsize*ysize;
  data_info.numpixels = tsize;
  for (int i=0;i<data_info.NInt+1; i++){

    // 3 output data types
    vector<float> Slope(tsize);
    vector<float> SlopeUnc(tsize);
    vector<float> SlopeID(tsize);

    if(i == 0) {
      cout << " Working on data in primary image (Average slope) " << endl;
    } else{
      cout << " Working on data in integration # " << i << endl; 
    }
    // **********************************************************************

    mc_read_data(i,data_info,Slope,SlopeUnc,SlopeID);

    if(control.do_verbose) cout << "done reading in" << endl;
    mc_apply_calibration_data(control,data_info,Slope,SlopeUnc,SlopeID);


    mc_write_calibrated_file(i,control,data_info,preference.preference_filename_used,
			     Slope,SlopeUnc,SlopeID);    

  }  // close the loop over the integrations
  

  status = 0;
  fits_close_file(data_info.cal_file_ptr, &status);


  cout << " " << endl;
  cout << " Done miri_caler" << endl;
  // **********************************************************************

  time_t t1; 
  t1 = time(NULL);

  cout << "Elapsed time " << t1 - t0 << endl;
  // **********************************************************************
  return 0;

}
