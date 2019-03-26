// This software is part of the MIRI Data Handling and Analysis Software (DHAS)
// This routine belongs to the miri_sloper package which processes raw science data.

// Name:
//    ms_parse_commandline.cpp
//
// Purpose:
//  The control structure  holds the parameters that control how the data is processed
//  The program : ms_parse_commandline.cpp parses the command line options the user has
//  used and sets to control structure to these user set values. 
//
// Author:
//
//	Jane Morrison
//      University of Arizona
//      email: morrison@as.arizona.edu
//      phone: 520-626-3181
// 
// Calling Sequence:
//
//void ms_parse_commandline(int& argc, 
//			  char* argv[],
//			  miri_control &control)
//
// Arguments:
//
//  argc: number of command line arguments
//  argv: holds the values of the command line options
//  control: miri_control structure containing the processing options
//
// Return Value/ Variables modified:
//      No return value.  
//  control structure updated with commandline options
//
// History:
//
//	Written by Jane Morrison 2005
//      Changes to code are found on the MIRI DHAS web site:
//      http://tiamat.as.arizona.edu/dhas/
#include <iostream>
#include <string>
#include "miri_control.h"
#include "miri_sloper.h"
#include <cstdlib> // EXIT_FAILURE   , EXIT_SUCCESS

/**********************************************************************/
// procedure to parse the command line 

void ms_parse_commandline(int& argc, 
			  char* argv[],
			  miri_control &control)

{

  
  // fill in command line parameters
  if ((argc > 1) && (argv[1][0] != '-') && (argv[1][0] != '+')){
    control.raw_fitsbase = argv[1];
  }else {
    cout << "No file specified." << endl;
    ms_usage();
    exit(EXIT_FAILURE);
  }
  //  cout << "File name " << control.raw_fitsbase << endl;

  int cont = 1;
  --argc;
  ++argv;

  int vstart = 0;
  while (argc > 1) {

    bool minus = false;
    bool plus = false;
    string Cstring = argv[1];
    //    cout << "cstring" << Cstring <<  " " << Cstring.size() << endl;
    //cout << " argv " << argv[1][0] << " " << argv[1][1] << endl;
    //cout << " argc " << argc << endl;

    if(argv[1][0] == '-' || argv[1][0] == '+' ){
      vstart = 1;
      if(argv[1][0] == '-'){
        minus = true;
      }
      if(argv[1][0] == '+'){
        plus = true;
      }
    }

    if(Cstring.size() == 1 && argv[1][0] == '-'){
      minus = true;
      --argc;
      ++argv;
      vstart = 0;
    }
    if(Cstring.size() == 1 && argv[1][0] == '+' ){
        plus = true;
      --argc;
      ++argv;
      vstart= 0;
    }


    int sz = 0;
    switch (argv[1][1]) {
      //_______________________________________________________________________
      // DC  DI (calibration directory, input directory) 
      //_______________________________________________________________________
    case 'D':  
      switch (argv[1][2]){
      case 'C' :
	if ( argc <= 2 || argv[2][0] == '-'    ) {
	  cout << "No Calibration Science Directory given" << endl;
	  cout << " Run again and provide directory value after -DC" << endl;
	  cout << " Printing Help screen" << endl;
	  ms_usage();
	  exit(EXIT_FAILURE);
	}
	control.calib_dir = argv[2];
	control.flag_dircal = 1;
	 sz = control.calib_dir.size();
	if(control.calib_dir[sz-1] != '/') {
	  control.calib_dir = control.calib_dir + '/';
	}
	++argv;
	--argc;
	++argv;
	--argc;
	break;
      case 'I':
	if ( argc <= 2 || argv[2][0] == '-'    ) {
	  cout << "No Input Science Directory given" << endl;
	  cout << " Run again and provide directory value after -DI" << endl;
	  cout << " Printing Help screen" << endl;
	  ms_usage();
	  exit(EXIT_FAILURE);
	}

	control.scidata_dir = argv[2];
	control.flag_dir = 1;
	 sz = control.scidata_dir.size();
	if(control.scidata_dir[sz-1] != '/') {
	  control.scidata_dir= control.scidata_dir + '/';
	}
	++argv;
	--argc;
	++argv;
	--argc;
	break;

      case 'O':
	if ( argc <= 2 || argv[2][0] == '-'    ) {
	  cout << "No Output Science Directory given" << endl;
	  cout << " Run again and provide directory value after -DO" << endl;
	  cout << " Printing Help screen" << endl;
	  ms_usage();
	  exit(EXIT_FAILURE);
	}

	control.scidata_out_dir = argv[2];
	control.flag_dirout = 1;
	sz = control.scidata_out_dir.size();
	if(control.scidata_out_dir[sz-1] != '/') {
	  control.scidata_out_dir= control.scidata_out_dir + '/';
	}
	++argv;
	--argc;
	++argv;
	--argc;

	break;

	// debug x 
      case 'X':
	if ( argc <= 2 || argv[2][0] == '-'    ) {
	  cout << "No X pixel debug value given " << endl;
	  cout << " Run again and provide pixel number  after -DX" << endl;
	  cout << " Printing Help screen" << endl;
	  ms_usage();
	  exit(EXIT_FAILURE);
	}

	control.xdebug = atoi(argv[2]);
	++argv;
	--argc;
	++argv;
	--argc;
	break;

	// debug Y 
      case 'Y':
	if ( argc <= 2 || argv[2][0] == '-'    ) {
	  cout << "No Y pixel debug value given " << endl;
	  cout << " Run again and provide pixel number  after -DY" << endl;
	  cout << " Printing Help screen" << endl;
	  ms_usage();
	  exit(EXIT_FAILURE);
	}
	control.ydebug = atoi(argv[2]);
	++argv;
	--argc;
	++argv;
	--argc;
	break;
	
      case 'f':

	if ( argc <= 2 || argv[2][0] == '-'    ) {
	  cout << "No Mean Dark correction  file was given " << endl;
	  cout << " Run again and provide  file name after -Mf" << endl;
	  cout << " Printing Help screen" << endl;
	  ms_usage();
	  exit(EXIT_FAILURE);
	}
	control.flag_dark_cor_file = 1;
	control.dark_cor_file = argv[2];
	control.apply_dark_cor = 1;
	control.flag_apply_dark_cor = 1;
	++argv;
	--argc;
	++argv;
	--argc;
	break;

      default:
	if(plus) control.apply_dark_cor = 1;
	if(minus) control.apply_dark_cor = 0;
	control.flag_apply_dark_cor = 1;
	++argv;
	--argc;
	break;
      }
      break;

      //_______________________________________________________________________
      // 
      //_______________________________________________________________________
    case 'p':
	if ( argc <= 2 || argv[2][0] == '-'    ) {
	  cout << "No Preferences files was given " << endl;
	  cout << " Run again and provide directory value after -p" << endl;
	  cout << " Printing Help screen" << endl;
	  ms_usage();
	  exit(EXIT_FAILURE);
	}
	control.preferences_file = argv[2];
	control.flag_pfile = 1;
	++argv;
	--argc;
	++argv;
	--argc;
	break;
      //_______________________________________________________________________
      // o
      //_______________________________________________________________________
    case 'o':
	if ( argc <= 2 || argv[2][0] == '-'    ) {
	  cout << "No output file name given " << endl;
	  cout << " Run again and provide filename value after -o" << endl;
	  cout << " Printing Help screen" << endl;
	  ms_usage();
	  exit(EXIT_FAILURE);
	}
	control.output_name = argv[2];
	control.flag_output_name = 1;
	cout << " name of output file " << control.output_name << endl;
	++argv;
	--argc;
	++argv;
	--argc;
	break;



      //_______________________________________________________________________
	// -U use uncertainity in determining slope measurement
      //_______________________________________________________________________
    case 'U': // Uncertainty = 1 

      switch (argv[1][2]){
      case '1' :
	control.NoUncertainty= 1;
	control.flag_Uncertainty = 1;
	break;

      case 'U' :  // Uncertainity un correlated
	control.UseUncertainty= 1;
	control.flag_Uncertainty = 1;
	break;

      case 'C' :
	control.UseCorrelatedUnc= 1;
	control.flag_Uncertainty = 1;
	break;

      default:
	cerr<< " error unrecognized option after U " 
	    << argv[1][2] << endl;
        cout << "Aborting program, printing help screen" << endl;
        ms_usage();
	exit(EXIT_FAILURE);
        break;
      }

      ++argv;
      --argc;
      break;

      //_______________________________________________________________________
      // VM old option
      //_______________________________________________________________________
    case 'V':
       cout << " -VM is an old command line option" << endl;
       	cout << " You can not apply any calibration data products to VM data" << endl;
	cout << " If you want to apply calibration data products you must use version 6.1.1" << endl;
	cout << " You can use this version to process the data but run again and remove -VM, and remove applying any calibration products " << endl;
	cout << " To turn off apply calibration products use -b, -D, -p, -L" << endl;
      	exit(EXIT_FAILURE);
      break;

      //_______________________________________________________________________

      // v
      //_______________________________________________________________________
    case 'v':
       control.do_verbose = 1;
      ++argv;
      --argc;
      break;

      //_______________________________________________________________________
      // T
      //_______________________________________________________________________
    case 'T':
       control.do_verbose_time = 1;
      ++argv;
      --argc;
      break;

    case 'Q':
       control.QuickMethod = 1;
      ++argv;
      --argc;
      break;

      //_______________________________________________________________________
      // d - diagnostic planes to output FITS file
      //_______________________________________________________________________
    case 'd':
      control.do_diagnostic = 1;
      ++argv;
      --argc;
      cout << " Setting do_diagnostics " << endl;
      break;

    case 'j':
	if ( argc <= 2   ) {
	  cout << "parameter value not given after jdet" << endl;
	  cout << " Run again and provide  number after jdet" << endl;
	}
	control.jpl_detector = argv[2];
	control.jpl_detector_flag = 1;
	++argv;
	--argc;
	++argv;
	--argc;
	break;


      //_______________________________________________________________________

      //_______________________________________________________________________
      // -h (high dn value)
      //_______________________________________________________________________

    case 'h':
	if ( argc <= 2   ) {
	  cout << "High DN value not given after h" << endl;
	  cout << " Run again and provide  number after h" << endl;
	  cout << " Printing Help screen" << endl;
	  ms_usage();
	  exit(EXIT_FAILURE);
	}
	control.dn_high_sat = atof(argv[2]);
	control.flag_dn_high_sat = 1;
	++argv;
	--argc;
	++argv;
	--argc;
	break;

      //_______________________________________________________________________
      // -g gain 
      //_______________________________________________________________________

    case 'g':
	if ( argc <= 2   ) {
	  cout << "Gain value not given after g" << endl;
	  cout << " Run again and provide  number after g" << endl;
	  cout << " Printing Help screen" << endl;
	  ms_usage();
	  exit(EXIT_FAILURE);
	}
	control.gain = atof(argv[2]);
	control.flag_gain = 1;
	++argv;
	--argc;
	++argv;
	--argc;
	break;

      //_______________________________________________________________________
      // -t frametime (might need to use with sub array) 
      //_______________________________________________________________________

    case 't':
	if ( argc <= 2   ) {
	  cout << "Frametime value not given after t" << endl;
	  cout << " Run again and provide  number after t" << endl;
	  cout << " Printing Help screen" << endl;
	  ms_usage();
	  exit(EXIT_FAILURE);
	}
	control.frametime = atof(argv[2]);
	control.flag_frametime = 1;
	++argv;
	--argc;
	++argv;
	--argc;
	break;

      //_______________________________________________________________________
      // a
      //_______________________________________________________________________

    case 'a':
	if ( argc <= 2 || !isdigit(argv[2][0])  ) {
	  cout << "Frame number to start slope fit not given after  a" << endl;
	  cout << " Run again and provide  number after a" << endl;
	  cout << " Printing Help screen" << endl;
	  ms_usage();
	  exit(EXIT_FAILURE);
	}
	control.n_reads_start_fit = atoi(argv[2]);
	control.flag_n_reads_start_fit = 1;

	++argv;
	--argc;
	++argv;
	--argc;
	break;
      //_______________________________________________________________________
      // z
      //_______________________________________________________________________
    case 'z':
	if ( argc <= 2 || !isdigit(argv[2][0])  ) {
	  cout << " Frame number to stop slope fit not given after z" << endl;
	  cout << " Run again and provide  number after z" << endl;
	  cout << " Printing Help screen" << endl;
	  ms_usage();
	  exit(EXIT_FAILURE);
	}
	control.n_reads_end_fit = atoi(argv[2]);
	control.flag_n_reads_end_fit = 1;

	cout << "nreads " << control.n_reads_end_fit << endl;

	++argv;
	--argc;
	++argv;
	--argc;
	break;

      // z
      //_______________________________________________________________________
    case 'n':
	if ( argc <= 2 || !isdigit(argv[2][0])  ) {
	  cout << " Number of reads before last frame to stop fit on not given after n" << endl;
	  cout << " Run again and provide  number after n" << endl;
	  cout << " Printing Help screen" << endl;
	  ms_usage();
	  exit(EXIT_FAILURE);
	}
	control.n_frames_end_fit = atoi(argv[2]);
	control.flag_n_frames_end_fit = 1;
	++argv;
	--argc;
	++argv;
	--argc;
	break;

      //_______________________________________________________________________
      //_______________________________________________________________________
      // R
      //_______________________________________________________________________
    case 'R':
	if ( argc <= 2 || !isdigit(argv[2][0])  ) {
	  cout << "Number  of rows not given after R" << endl;
	  cout << " Run again and provide number after R" << endl;
	  cout << " Printing Help screen" << endl;
	  ms_usage();
	  exit(EXIT_FAILURE);
	}
	control.subset_nrow = atoi(argv[2]);
	if(control.subset_nrow < 4) control.subset_nrow = 4; 
	control.flag_subset_nrow = 1;

	++argv;
	--argc;
	++argv;
	--argc;
	break;
      //_______________________________________________________________________
      // FL
      //_______________________________________________________________________
    case 'F':  
      switch (argv[1][2]){
      case 'L' :
	if ( argc <= 2 || !isdigit(argv[2][0])  ) {
	  cout << "Frame limit number not given after FL" << endl;
	  cout << " Run again and provide limit number after FL" << endl;
	  cout << " Printing Help screen" << endl;
	  ms_usage();
	  exit(EXIT_FAILURE);
	}
	control.frame_limit = atoi(argv[2]);
	control.flag_frame_limit = 1;
      ++argv;	
      --argc;
      ++argv;
      --argc;
	break;

      default:
	cerr<< " error unrecognized option after F " 
	  << argv[1][2] << endl;
        cout << "Aborting program, printing help screen" << endl;
        ms_usage();
        exit(EXIT_FAILURE);
        break;
      }
      break;

      //_______________________________________________________________________
      // Pulse mode 
      //_______________________________________________________________________
    case 'P':

      switch (argv[1][2]){
      case 'i' :
	if ( argc <= 2 || !isdigit(argv[2][0])  ) {
	  cout << " Frame number not given after Pi" << endl;
	  cout << " Run again and provide number after Pi" << endl;
	  cout << " Printing Help screen" << endl;
	  ms_usage();
	  exit(EXIT_FAILURE);
	}
	control.do_Pulse_Mode = 1;
	control.Pulse_Frame_i = atoi(argv[2]);


      ++argv;	
      --argc;
      ++argv;
      --argc;
	break;


      case 'f' :
	if ( argc <= 2 || !isdigit(argv[2][0])  ) {
	  cout << " Frame number not given after Pf" << endl;
	  cout << " Run again and provide number after Pf" << endl;
	  cout << " Printing Help screen" << endl;
	  ms_usage();
	  exit(EXIT_FAILURE);
	}
	control.Pulse_Frame_f = atoi(argv[2]);
	control.flag_Pulse_Frame_f = 1;
      ++argv;	
      --argc;
      ++argv;
      --argc;
	break;

      default:
	cerr<< " error unrecognized option after P " 
	  << argv[1][2] << endl;
        cout << "Aborting program, printing help screen" << endl;
        ms_usage();
        exit(EXIT_FAILURE);
        break;
      }

      break;

      // following options are either true or false

      //_______________________________________________________________________
      // rn, rx, rc rd, rdf, rs, rb,r6,r7
      //_______________________________________________________________________
    case 'r':

      switch (argv[1][2]){

	//**********************************************************************
      case 'n' :
	if ( argc <= 2   ) {
	  cout << "Read noise in electrons not given after -rn " << endl;
	  cout << " Run again and provide number after rn" << endl;
	  cout << " Printing Help screen" << endl;
	  ms_usage();
	  exit(EXIT_FAILURE);
		}
	control.read_noise_electrons = atof(argv[2]);
	control.flag_read_noise= 1;
	++argv;
	--argc;
	break;
	//**********************************************************************
      case 'c':
	  control.rscd_lastframe_corrected = 1;
	  control.rscd_lastframe_extrap = 0;
	  control.apply_rscd_cor = 1;	  
	  break;	
      case 'x':
	control.rscd_lastframe_corrected = 0;
	control.rscd_lastframe_extrap = 1;
	control.apply_rscd_cor = 1;
	break;

      case 'd' :  // RSCD parameters 
	if(plus) control.apply_rscd_cor = 1;
	if(minus) control.apply_rscd_cor = 0;
	control.flag_apply_rscd_cor= 1;

	switch (argv[1][3]){
	// RSCD file
	case 'f':
	  if ( argc <= 2 || argv[2][0] == '-'    ) {
	    cout << "No rscd correction  file was given " << endl;
	    cout << " Run again and provide  file name after -rdf" << endl;
	    cout << " Printing Help screen" << endl;
	    ms_usage();
	    exit(EXIT_FAILURE);
	  }
	  control.flag_rscd_cor_file = 1;
	  control.rscd_cor_file = argv[2];
	  control.apply_rscd_cor = 1;
	  control.flag_apply_rscd_cor = 1;
	  ++argv;
	  --argc;
	  //break;
	}
	break;
	
	//**********************************************************************
      case 's' :
	if ( argc <= 2   ) {
	  cout << "Reference Pixel standard deviation not given after -rs " << endl;
	  cout << " Run again and provide number after rs" << endl;
	  cout << " Printing Help screen" << endl;
	  ms_usage();
	  exit(EXIT_FAILURE);
		}
	control.refpixel_sigma_clip = atof(argv[2]);
	++argv;
	--argc;
	break;
	//**********************************************************************
      case 'b' :
	if ( argc <= 2   ) {
	  cout << "Reference Pixel filter box size not given after -rb " << endl;
	  cout << " Run again and provide number after rb" << endl;
	  cout << " Only possible options are 1024, 512, 256, 128, 64, 32 " << endl;
	  cout << " Printing Help screen" << endl;
	  ms_usage();
	  exit(EXIT_FAILURE);
	}
	control.refpixel_filter_size= atoi(argv[2]);
	++argv;
	--argc;
	break;


      case '6' :
	control.flag_do_refpixel_option = 1;
	if(plus){
	  control.do_refpixel_options[0] = 1;
	  control.do_refpixel_option = 6;
	}
	if(minus) control.do_refpixel_options[0]= 0;
	
	break;


      case '7' :
	control.flag_do_refpixel_option = 1;
	if(plus){
	  control.do_refpixel_options[1] = 1;
	  control.do_refpixel_option = 7;
	}
	if(minus) control.do_refpixel_options[1]= 0;
	
	break;



	// JPL run#
      case 'u' :
	if ( argc <= 2 || !isdigit(argv[2][0])  ) {
	  cout << "JPL Run # not given after run" << endl;
	  cout << " Run again and provide number after run" << endl;
	  cout << " Printing Help screen" << endl;
	  ms_usage();
	  exit(EXIT_FAILURE);
	}

	control.jpl_run = argv[2];
	control.flag_jpl_run = 1;
	++argv;
	--argc;
	break;
// Reset Correction file
      case 'f':

	if ( argc <= 2 || argv[2][0] == '-'    ) {
	  cout << "No reset correction  file was given " << endl;
	  cout << " Run again and provide  file name after -rf" << endl;
	  cout << " Printing Help screen" << endl;
	  ms_usage();
	  exit(EXIT_FAILURE);
	}
	control.flag_reset_cor_file = 1;
	control.reset_cor_file = argv[2];
	control.apply_reset_cor = 1;
	control.flag_apply_reset_cor = 1;
	++argv;
	--argc;
	//++argv;
	//--argc;
	break;

      default:
	if(plus) control.apply_reset_cor = 1;
	if(minus) control.apply_reset_cor = 0;
	control.flag_apply_reset_cor= 1; 
	break;
    }	


      ++argv;
      --argc;

      break;
	
      //_______________________________________________________________________

    case 'i':
	if ( argc <= 2   ) {
	  cout << "Integration to ignore in final image not given after -i" << endl;
	  cout << " Run again and provide  number after k" << endl;
	  cout << " Printing Help screen" << endl;
	  ms_usage();
	  exit(EXIT_FAILURE);
	}


	++argv;
	++argv;
	--argc;
	--argc;

      while(cont ==1 && argc > 0) {
	int ignore = atoi(argv[0]);
	control.ignore_int.push_back(ignore);
	control.num_ignore++;
	--argc;
	++argv;
	if(argc ==0) break;

	if(argc > 0) {
	  if(argv[0][0] == '-' || argv[0][0] == '+' ){
	    argv--;
	    argc++;
	    cont = 0;

	  }
	}


      }// end while
      

	break;

      //_______________________________________________________________________
      //Screen frames for bad frame
    case 'S':
      if(plus) control.ScreenFrames = 1;
      if(minus) control.ScreenFrames = 0;
      ++argv;
      --argc;
      break;

      //_______________________________________________________________________
      // Cosmic Ray Identification - Capital +C 
      //_______________________________________________________________________
    case 'C':
      if(Cstring.size() == 2) {
	if(plus) control.do_cr_id = 1;
	if(minus) control.do_cr_id = 0;
	++argv;
	--argc;
	break;
      }
      
      if(Cstring.size() == 4 && argv[1][2] == 'D' && argv[1][3] == 'P' ) {

	if ( argc <= 2 || argv[2][0] == '-'    ) {
	  cout << "No Calibration Data Product File was given" << endl;
	  cout << " Run again and provide  file name after -CDP filename" << endl;
	  cout << " Printing Help screen" << endl;
	  ms_usage();
	  exit(EXIT_FAILURE);
	}
	control.flag_CDP_file = 1;
	control.CDP_file = argv[2];
	++argv;
	--argc;
	++argv;
	--argc;
	break;
      }



      //_______________________________________________________________________
      // cosmic ray parameters 

    case 'c':  // lower case c
      switch (argv[1][2]){
      case 's' :
	if ( argc <= 2 || !isdigit(argv[2][0])  ) {
	  cout << "Sigma rejection number not given" << endl;
	  cout << " Run again and provide number after cs" << endl;
	  cout << " Printing Help screen" << endl;
	  ms_usage();
	  exit(EXIT_FAILURE);
	}
	control.cr_sigma_reject = atof(argv[2]);
	control.flag_cr_sigma_reject = 1;
	control.do_cr_id = 1;
	++argv;
	--argc;
	break;

      case 'f' :
	if ( argc <= 2 || !isdigit(argv[2][0])  ) {
	  cout << "Number of frames to reject after cosmic ray detection not given" << endl;
	  cout << " Run again and provide number after cf" << endl;
	  cout << " Printing Help screen" << endl;
	  ms_usage();
	  exit(EXIT_FAILURE);
	}
	control.n_frames_reject_after_cr = atoi(argv[2]);
	control.flag_n_frames_reject_after_cr = 1;
	control.do_cr_id = 1;
	++argv;
	--argc;
	break;

      case 'd' :
	if ( argc <= 2 || !isdigit(argv[2][0])  ) {
	  cout << "Minimum number of good differences for cosmic ray identification not given" << endl;
	  cout << " Run again and provide number after cd" << endl;
	  cout << " Printing Help screen" << endl;
	  ms_usage();
	  exit(EXIT_FAILURE);
	}
	control.cr_min_good_diffs = atoi(argv[2]);
	control.flag_cr_min_good_diffs= 1;
	control.do_cr_id = 1;
	++argv;
	--argc;
	break;

      case 'i' :
	if ( argc <= 2 || !isdigit(argv[2][0])  ) {
	  cout << " Maximum number of iterations in cosmic ray/noise id not given" << endl;
	  cout << " Run again and provide number after ci" << endl;
	  cout << " Printing Help screen" << endl;
	  ms_usage();
	  exit(EXIT_FAILURE);
	}
	control.max_iterations_cr = atoi(argv[2]);
	control.flag_max_iterations_cr= 1;
	control.do_cr_id = 1;
	++argv;
	--argc;
	break;

      case 'n' :
	if ( argc <= 2 || !isdigit(argv[2][0])  ) {
	  cout << " Cosmic Ray noise level limit not given after -cn" << endl;
	  cout << " Run again and provide number after cn" << endl;
	  cout << " Printing Help screen" << endl;
	  ms_usage();
	  exit(EXIT_FAILURE);
	}
	control.cosmic_ray_noise_level = atof(argv[2]);
	control.flag_cosmic_ray_noise_level= 1;
	control.do_cr_id = 1;
	++argv;
	--argc;
	break;

      case 'r' :
	if ( argc <= 2 || !isdigit(argv[2][0])  ) {
	  cout << " # sigmas for cosmic ray slope segment rejection not given" << endl;
	  cout << " Run again and provide number after cr" << endl;
	  cout << " Printing Help screen" << endl;
	  ms_usage();
	  exit(EXIT_FAILURE);
	}
	control.slope_seg_cr_sigma_reject = atof(argv[2]);
	control.flag_slope_seg_cr_sigma_reject = 1 ;     
	control.do_cr_id = 1;
	++argv;
	--argc;
	break;

      case 'v' :
	control.do_verbose_jump = 1;
	control.do_cr_id = 1;
	break;

      default :
	cout << "Bad Option " << argv[1] << endl;
	ms_usage();
	exit(8);
      }

      ++argv;
      --argc;
      break;

      //_______________________________________________________________________
      // b = apply bad pixel mask
      //_______________________________________________________________________
    case 'b':
      if(Cstring.size() == 3 && argv[1][2] == 'f') {

	if ( argc <= 2 || argv[2][0] == '-'    ) {
	  cout << "No bad pixel file was given " << endl;
	  cout << " Run again and provide bad pixel file value after -bf" << endl;
	  cout << " Printing Help screen" << endl;
	  ms_usage();
	  exit(EXIT_FAILURE);
	}
	control.flag_badpix_file = 1;
	control.badpix_file = argv[2];
	control.apply_badpix = 1;
	control.flag_apply_badpix = 1;
	++argv;
	--argc;
	++argv;
	--argc;
	break;
      }
      if(Cstring.size() == 2) {
	if(plus) control.apply_badpix = 1;
	if(minus) control.apply_badpix = 0;
	control.flag_apply_badpix = 1;
	++argv;
	--argc;
	break;
      }

      //_______________________________________________________________________
      // l = apply last frame correction
      //_______________________________________________________________________
    case 'l':

	if(Cstring.size() == 3 && argv[1][2] == 'f') {
	  if ( argc <= 2 || argv[2][0] == '-'    ) {
	    cout << "No last frame file was given " << endl;
	    cout << " Run again and provide bad pixel file value after -lf" << endl;
	    cout << " Printing Help screen" << endl;
	    ms_usage();
	    exit(EXIT_FAILURE);
	  }
	  control.flag_lastframe_file = 1;
	  control.lastframe_file = argv[2];
	  control.apply_lastframe_cor = 1;
	  control.flag_apply_lastframe_cor = 1;
	  ++argv;
	  --argc;
	  ++argv;
	  --argc;
	  break;
	}
	if(Cstring.size() == 2) {

	  if(plus) control.apply_lastframe_cor = 1;
	  if(minus) control.apply_lastframe_cor = 0;
	  control.flag_apply_lastframe_cor = 1;

	  ++argv;
	  --argc;
	  break;
	}
    


      //_______________________________________________________________________
      // s - pixel saturation mask
      //_______________________________________________________________________
    case 's':
      if(Cstring.size() == 3 && argv[1][2] == 'f') {

	if ( argc <= 2 || argv[2][0] == '-'    ) {
	  cout << "No pixel saturation file was given " << endl;
	  cout << " Run again and provide filename value after -sf" << endl;
	  cout << " Printing Help screen" << endl;
	  ms_usage();
	  exit(EXIT_FAILURE);
	}
	control.flag_pixel_saturation_file = 1;
	control.pixel_saturation_file = argv[2];
	control.apply_pixel_saturation = 1;
	control.flag_apply_pixel_saturation = 1;
	++argv;
	--argc;
	++argv;
	--argc;
	break;
      }
      if(Cstring.size() == 2) {

	if(plus) control.apply_pixel_saturation = 1;
	if(minus) control.apply_pixel_saturation = 0;
	control.flag_apply_pixel_saturation = 1;
	//cout << " Pixel saturation correction " << control.apply_pixel_saturation<< endl;
	++argv;
	--argc;
	break;
      }


      //_______________________________________________________________________
    case 'm': // multiple integration effect (secondary effect)

      if(Cstring.size() == 2) {

	if(plus) control.apply_mult_cor = 1;
	if(minus) control.apply_mult_cor = 0;
	control.flag_apply_mult_cor = 1;
	++argv;
	--argc;
	break;
      }
      //_______________________________________________________________________
      // L - Linearity &  Correction file
      //_______________________________________________________________________
     case 'L':

      if(Cstring.size() == 2) {

	if(plus) control.apply_lin_cor = 1;
	if(minus) control.apply_lin_cor = 0;
	control.flag_apply_lin_cor = 1;
	++argv;
	--argc;
	break;
      }
      
      if(Cstring.size() == 3 && argv[1][2] == 'f') {

	if ( argc <= 2 || argv[2][0] == '-'    ) {
	  cout << "No linearity correction  file was given " << endl;
	  cout << " Run again and provide  file name after -Lf" << endl;
	  cout << " Printing Help screen" << endl;
	  ms_usage();
	  exit(EXIT_FAILURE);
	}
	control.flag_lin_cor_file = 1;
	control.lin_cor_file = argv[2];
	control.apply_lin_cor = 1;
	control.flag_apply_lin_cor = 1;
	++argv;
	--argc;
	++argv;
	--argc;
	break;
      }
      if(Cstring.size() == 3 && argv[1][2] == 'o') {
	if(plus) control.apply_lin_offset = 1;
	if(minus) control.apply_lin_offset = 0;

	++argv;
	--argc;
	break;
      }

      //_______________________________________________________________________
      // convert units from DN/frame to e/s
      //_______________________________________________________________________
    case 'e':
      if(plus) control.convert_to_electrons_per_second = 1;
      if(minus) control.convert_to_electrons_per_second = 0;
      ++argv;
      --argc;
      break;

     

      //_______________________________________________________________________
      // Op - write pixel correction file to ascii file
      // Or - output reduced reference image file (default to yes)
      //_______________________________________________________________________
      // output options - if invokes then print output
    case 'O':
      switch (argv[1][2]) {
      case 'p' :
	control.write_output_refpixel = 1;
	break;
      case 'R' :
	control.write_output_refpixel_corrections = 1;
	control.flag_write_output_refpixel_corrections = 1;
	break;
      case 'a' :
	control.write_all = 1;
	break;
      case 'L' :
	control.write_output_lc_correction = 1;
	control.flag_write_output_lc_correction = 1;
	break;

      case 'l' :
	control.write_output_lastframe_correction = 1;
	control.flag_write_output_lastframe_correction = 1;
	break;
      case 'r' :
	if (  argv[1][3] == 'd'    ) {
	case 'd' :
	  control.write_output_rscd_correction = 1;
	  control.flag_write_output_rscd_correction = 1;
	  break;
	} else{
	  control.write_output_reset_correction = 1;
	  control.flag_write_output_reset_correction = 1;
	  break;

	}
	  

      case 'D' :
	control.write_output_dark_correction = 1;
	control.flag_write_output_dark_correction = 1;
	break;
      case 'I' :
	control.write_output_ids = 1;
	control.flag_write_output_ids = 1;
	break;
      case 's' :
	if(plus) {control.write_output_refslope = 1;
	  control.flag_write_output_refslope = 1;}

	if(minus) control.write_output_refslope = 0;
	break;
      case 'C':
	control.write_detailed_cr = 1;
        control.flag_write_detailed_cr = 1;
	break;
      case 'S' :
	control.write_segment_output = 1;
	break;
      default :
	cout << "Bad Option " << argv[1] << endl;
	ms_usage();
	exit(8);
      }

      ++argv;
      --argc;
      break;
    default :
      cout << "Bad Option " << argv[1] << endl;
      ms_usage();
      exit(8);
    }

    
  }

  // turn off output of ids if do_diagnostic = 0



  // ***********************************************************************
  // Perform checks on control options
  int test = 0;
  for(int i = 0; i< 2; i++){
    if(control.do_refpixel_options[i] ==1){

      test++;
     control.flag_do_refpixel_option = 1;
    }
  }
  if(test > 1) {
    cout<< " You have selected at least 2 ways to use the reference pixels to correct the data, pick 1" << endl;
    cout << " choose 1 (+r6 +r7) " << endl;
    exit(EXIT_FAILURE);
  }
  if(test ==0){
    control.do_refpixel_option =0;
  }
    

  if(control.write_output_refpixel && control.do_refpixel_option == 0  ){
      cout << " You did not set the reference pixel correction " 
	"but you did set the option to write the corrections to a file" << endl;
      cout << " Run again, and set +r6 or +r7  if you want to correct the science data"
	" using the reference pixels" << endl;
      exit(EXIT_FAILURE);
    
  }

  if(control.flag_n_reads_end_fit == 1 && control.flag_n_frames_end_fit ==1) {
    cout << " You have used the -z and -n options. Chose one of them" << endl;
    cout << " -z # is the frame number to end the slope fit on" << endl;
    cout << " -n # is the number of frames BEFORE the last frame where the fits will stop " << endl;
    exit(EXIT_FAILURE);
  }


  if(control.num_ignore !=0) {
    cout << " Number of iterations to ignore " << control.num_ignore << endl;
    for (int ip = 0; ip < control.num_ignore; ip++){
      cout << "When determining Average Slope ignoring integration " << control.ignore_int[ip] << endl;
    }
  }
  
  if(control.xdebug !=0) {
    if(control.ydebug ==0) {
      cout << " You need to provide both and X and Y debug pixel value, you only provided a X value" << endl;
      cout << " Run again and provide Y value with -DY # " << endl;
      exit(EXIT_FAILURE);
    }
  }

  if(control.ydebug !=0) {
    if(control.xdebug ==0) {
      cout << " You need to provide both and X and Y debug pixel value, you only provided a Y value" << endl;
      cout << " Run again and provide X value with -DX # " << endl;
      exit(EXIT_FAILURE);
    }
  }


  
}
