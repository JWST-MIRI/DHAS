#// miri_cube.cpp
#include <time.h>
#include <cstdlib> // EXIT_FAILURE   , EXIT_SUCCESS
#include <iostream>
#include "miri_cube.h"
#include "miri_constants.h"
using namespace std;
/**********************************************************************/
/**********************************************************************/
int main(int argc, char* argv[]){

  cout << " Start Building" << endl;
  // **********************************************************************
  // tell the user how to use the program if it was not called with enough
  // parameters

  if (argc < 2) {
        mrs_usage();
   exit(EXIT_FAILURE);
  }

  // **********************************************************************
  // declare the structure which contains the information on how to control
  // the program - determined from the command line options
  // Defaults set in the preferences file.

  time_t t0 ; 
  t0 = time(NULL);
  int status= 0;

  mrs_control control;
  mrs_preference  preference;
  mrs_data_info data_info;

  // **********************************************************************
  // parse the commandline for all the joyous switches as well as the 
  // name of the FITS files to read in 

  mrs_initialize_control(control);
  
  mrs_parse_commandline(argc,argv,control);
  if(control.do_verbose ==1) cout << " done parsing commandline" << endl;

  mrs_read_preferences(control,preference,data_info);

  if(control.do_verbose == 1) cout << " done reading preferences file" << endl;
  mrs_update_control(control,preference);
  if(control.do_verbose == 1) cout << " done updating control" << endl;

  // read in the cube pixel dimensions
  string infile = control.miri_dir + "Preferences/" + preference.cube_plate_scale_file;
  data_info.scale_file = preference.cube_plate_scale_file;
  mrs_get_cube_size(infile,preference);
  if(control.do_verbose == 1) cout << " done with mrs_get_cube_size" << endl;

  //_______________________________________________________________________

  // read in the input list of files
  // Found what what SCA and exposure they are for. For now we have to read
  // in telemetry data for this.

  status = mrs_read_input_list(control,data_info);
  if(status !=0 ) exit(EXIT_FAILURE);


  //-----------------------------------------------------------------------  
  // Determining which subchannel of data working with:
  int  status_subchannel = 0;

  // If the user supplied the subchannel 

  if(control.flag_subchannel ==1) { // user set the subchannel 
    for (int k = 0;k<data_info.nfiles;k++){
      data_info.Use_File[k] = 1;
      data_info.WAVE_ID[k] = control.subchannel;
    }
  }

  // FM data and no subchannel provided- read header for DGAA_POS & DGAB_POS

  if (control.flag_subchannel==0) { // This is the default mode
    status = 0;
    status = mrs_DGPOS(data_info);

    if(status !=0){
      status_subchannel = 1;
      cout << " _____________________________________________________________________________" << endl;
      cout << " Problem reading DGPOS information" << endl;
      cout << " _____________________________________________________________________________" << endl;
      cout << " " << endl;
    } else {
      if(data_info.DGAB_POS_FLAG == 1 && data_info.DGAA_POS_FLAG == 1) {
	cout <<" Determined subchannel of data by reading DGAA_POS and DGAB_POS in FITS Header of Science Data" << endl; 
      }

      if(data_info.DGAB_POS_FLAG == 2 && data_info.DGAA_POS_FLAG == 2) {
	cout <<" Determined subchannel of data by readinng BAND in FITS Header of Science Data" << endl; 
      }
    }
  }


  if(status_subchannel !=0 ){
    cout << " Can not determine the subchannel of the data" << endl;
    cout << " Please provide using command line options -A, -B, -C" << endl;
    cout << " -A = sub-channel A (Short)" << endl;
    cout << " -B = sub-channel B (Medium)" << endl;
    cout << " -C = sub-channel C (Long.)" << endl;

    exit(EXIT_FAILURE);
  }
  //-----------------------------------------------------------------------

  status = mrs_check_files(data_info); // check that files are from same
                                       // sub channel and from  channel 1-2 or 
                                       //  channel 3-4
                                       // And they have the same NSample values

  if(status !=0) exit(EXIT_FAILURE);

  // Read in the calibration files to correct for distortion and to map alpha,beta -> V2,V3

  status = 0;
  status =  mrs_read_calibration_file_new(control,preference,data_info);
  if(control.do_verbose == 1) cout << " done reading Channel Information data" << endl;


  status = 0;
  status =  mrs_sizes(control,preference,data_info);
  if(control.do_verbose == 1) cout << " done with sizes" << endl;

  
  // **********************************************************************
  // _______________________________________________________________________
  // Loop Over a Possible of 2 channels (1 and 2) or (3 and 4)
  // ***********************************************************************
  // channel_type = 0 or 1


  int channel_type_end = 1;
  int channel_type = 0;
  while(channel_type <= channel_type_end)  {
    CubeHeader cubeHead; // class to hold Cube Header

    
    mrs_determine_geometry(channel_type,control,preference,data_info,cubeHead);
    int channel = cubeHead.GetChannel();

  // **********************************************************************
  // Define Classes  to hold cube data and input reduced file header data
    cout << "________________________________________________________________" << endl;
    cout << " Building Cube for Channel " << channel<< endl;
    cout << "________________________________________________________________" << endl;


    // Loop over the reduced slope files and fill in the Cubeheader with
    // the descriptive  values of that file (filename, exp_id, sca_id, channel) 
    //cout << " number of data files " << data_info.nfiles << endl;

    int NumFiles = data_info.nfiles;
    int nfiles = 0;

    for (int j = 0 ; j < NumFiles; j++) {
      if(data_info.Use_File[j]  == 1) {
	cout << " Filename " << data_info.input_filenames[j] << endl;
	    
	// read in the number of extensions 
	int status = 0;
	string ifile = control.scidata_dir + data_info.input_filenames[j] ;   
	fitsfile *file_ptr;
	fits_open_file(&file_ptr,ifile.c_str(), READONLY, &status);   // open the file
	if(status !=0) {
	  cout << " Failed to open fits file: " << ifile<< endl;
	  cout << " Reason for failure, status = " << status << endl;
	  exit(EXIT_FAILURE);
	}

	cubeHead.SetInputFilename(ifile);
	if(control.flag_integration_no != 0) {
	  cubeHead.SetExtensionNum(control.integration_no+1);

	} else {
	  cubeHead.SetExtensionNum(1);
	}
	nfiles = nfiles + 1;


	//cout << "number of exposures " << nfiles << endl;
	fits_close_file(file_ptr,&status);
      }
    } // end looping over files
    
    //cout << "# of data sets for current channel  " << nfiles << endl;

    cubeHead.SetNumFiles(nfiles);

    // _______________________________________________________________________
    // If there are files for this channel continue;

    if(nfiles == 0) {
      cout << " No input data for channel " << channel << endl;

    }else{

    // _______________________________________________________________________
      // set up the class that will hold the input file information
      // at this point the ReducedHeader does not contain much information.
      // More information will probably be placed in this header
      // that we will need to make the spectral cubes. 

      ReducedHeader *ReducedHead;
      ReducedHead = new ReducedHeader[nfiles];
  // **********************************************************************
      status = 0;
      status = mrs_read_header(ReducedHead,cubeHead,control);

      if (control.do_verbose == 1) cout << "finished mrs_read_header" << endl;
  // **********************************************************************
	// Set up the Geometry of the Cube, size in each axis, pixel size (etc)

      //cout << " starting mrs_Setup_Cube " << endl;
      mrs_Setup_Cube(data_info,cubeHead,control.do_verbose); 


      // split the Cube into sections
      

      long ngridz = cubeHead.GetNgridZ();
      long ngridx = cubeHead.GetNgridX();
      long ngridy = cubeHead.GetNgridY();

      long numpixels = ngridz * ngridx * ngridy;
      cubeHead.SetNumPixels(numpixels);
      //      mrs_Cube_Tile(control,cubeHead);
      
      // _______________________________________________________________________
      // setup output FITS files
      mrs_filenames(cubeHead,data_info,control);

      string output_fits = cubeHead.GetOutFitsFile();


      // get pointer to fits file
      int status =0;

      fitsfile *file_ptr;
      fits_create_file(&file_ptr,output_fits.c_str(), &status);

      if(status !=0){
	cout << "******************************" << endl;
	cout << " Problem creating file " << output_fits << endl;
	cout << " Check if directory exists or if the file already exists" <<endl;
	cout << " You must use the command -OW to overwrite an existing spectral cube " << endl;
	exit(EXIT_FAILURE);
      }

      mrs_setup_output_cube(file_ptr,cubeHead,control,data_info);

      int NumTiles = 1;  // removed Tiling cube so just set it = 1

      data_info.Actual_Max_Overlap_Planes = 0;
      //-----------------------------------------------------------------------
      for (int it = 0; it <NumTiles; it++){ // set NumTiles = 1 (removed tiling from cube building) 
	cout << " Starting Tile " << it+1 << endl;
	Tile       tile    ; // class to hold Tile (part of a cube) 

	long nelements = cubeHead.GetNumPixels();

	// subpixel holds overlapping information for a tile (section of the cube)
	vector<SubPixel> subpixel(nelements);

	if(control.write_mapping) mrs_SetIndex(it,cubeHead,subpixel);
	
	//cout << " Making Subpixel (Cube Pixels) with " << nelements << " elements " <<  endl;

	mrs_Setup_Tile(it,data_info,cubeHead,tile,control.do_verbose); 

	for (int j = 0 ; j < nfiles ; j ++){
	if(control.do_verbose) cout << "Going to work on file " << j << endl;
	  long numpixels = 0;	  
	  int NSample = ReducedHead[j].GetNSample();
	  mrs_data_size(channel_type,it,cubeHead,data_info,NSample,numpixels,control.do_verbose);
	  if(control.do_verbose) cout << "done mrs_data_size " << endl;
	  vector<ReducedData>  Data(numpixels);

	  status = 0;
	  long numpixels_read=0;
	  
	  // read in data - only keep data for the slices we are interested in  

	  status= mrs_read_data(channel_type,j,it,
				control.V2V3,
				control.Interpolate,
				control.Interpolate_distance, 
	  			numpixels_read,
	  			data_info,
	  			cubeHead,
				ReducedHead[j],
				Data,
				control.do_verbose);
	  //cout << " Number of pixels read in " << numpixels_read << endl;
          if(control.do_verbose) cout<< "done mrs_read_data " << endl;

	  mrs_overlap(it,control.V2V3,numpixels_read,cubeHead,tile,Data,subpixel,
			data_info.Actual_Max_Overlap_Planes,
			control.write_mapping,control.do_verbose);

          if(control.do_verbose) cout<< "done mrs_overlap " << endl;


	  if(control.write_mapping) status = mrs_write_mapping_file(channel_type,it,numpixels_read,
	  						   data_info,cubeHead,Data,
							   control.do_verbose);



	  Data.clear();
	  vector<ReducedData> TB(1);
	  Data.swap(TB);
	} // end j < nfiles
	mrs_aveflux(nelements,cubeHead,tile,subpixel);
	if(control.do_verbose) cout << " done with ave flux " << endl;
	subpixel.clear();
	vector<SubPixel> TA(1);
	subpixel.swap(TA);

	mrs_write_tile(file_ptr,it,cubeHead,tile,control,data_info);
	if(control.do_verbose) cout << "done writing tile" << endl;


      }// end it< NumTiles
      //-----------------------------------------------------------------------
      //cout << " end looping over Tiles " << endl;


      delete [] ReducedHead;

      fits_close_file(file_ptr,&status);    
      if(control.write_mapping){
	cout << "Trimming Mapping file to " << data_info.Actual_Max_Overlap_Planes << " from " <<
	  data_info.Max_Overlap_Planes << " planes " << endl;

	status = 0;
	status = mrs_trim_mapping_file(data_info);
	cout << "done mrs_trim_mapping_file" << endl;
      }


    }// end if nfiles > 0


      
    cout << "finished channel " << endl;
    channel_type++;
    if(control.channel_flag ==1) channel_type = channel_type_end+1 ;// jump out only doing 1 channel cube 


    //   fitsfile *file_ptr;
    //string output_fits = cubeHead.GetOutFitsFile();
    //fits_create_file(&file_ptr,output_fits.c_str(), &status);
    //status = 0;
    //fits_write_chksum(file_ptr,&status);

  }// end while loop
 


  cout << " Done Building cube" << endl;
  // **********************************************************************
  // close all open fits files



  time_t t1; 
  t1 = time(NULL);
  cout << "Elapsed time " << t1 - t0 << endl;



}
