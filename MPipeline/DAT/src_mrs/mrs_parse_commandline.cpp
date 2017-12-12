#include <iostream>
#include <string>
#include <fstream>
#include <iomanip>
#include <cstdlib> // EXIT_FAILURE   , EXIT_SUCCESS

#include "mrs_control.h"
#include "miri_cube.h"


/**********************************************************************/
// procedure to parse the command line 

void mrs_parse_commandline(int& argc, 
			  char* argv[],
			  mrs_control &control)

{

  // fill in command line parameters
  if ((argc > 1) && (argv[1][0] != '-') && (argv[1][0] != '+')){
    control.input_list = argv[1];
  }else {
    cout << "No file specified." << endl;
    mrs_usage();
    exit(EXIT_FAILURE);
  }
    cout << "Input file list  " << control.input_list << endl;

  --argc;
  ++argv;

  int vstart = 0;
  while (argc > 1) {

    bool minus = false;
    bool plus = false;
    string Cstring = argv[1];

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

    //    cout << " here argv " << argv[1][0] << " " << argv[1][1] << endl;
    //cout << " vstart " << vstart << endl;

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
	  mrs_usage();
	  exit(EXIT_FAILURE);
	}
	control.calib_dir = argv[2];
	control.flag_dircal = 1;
	 sz = control.calib_dir.size();
	if(control.calib_dir[sz-1] != '/') {
	  control.calib_dir = control.calib_dir + '/';
	}
	break;
      case 'I':
	if ( argc <= 2 || argv[2][0] == '-'    ) {
	  cout << "No Input Science Directory given" << endl;
	  cout << " Run again and provide directory value after -DI" << endl;
	  cout << " Printing Help screen" << endl;
	  mrs_usage();
	  exit(EXIT_FAILURE);
	}

	control.scidata_dir = argv[2];
	control.flag_dirsci = 1;
	 sz = control.scidata_dir.size();
	if(control.scidata_dir[sz-1] != '/') {
	  control.scidata_dir= control.scidata_dir + '/';
	}
	break;

      case 'T':
	if ( argc <= 2 || argv[2][0] == '-'    ) {
	  cout << "No Input Telemetry direcotry given" << endl;
	  cout << " Run again and provide directory value after -DT" << endl;
	  cout << " Printing Help screen" << endl;
	  mrs_usage();
	  exit(EXIT_FAILURE);
	}

	control.teldata_dir = argv[2];
	control.flag_dirtel = 1;
	sz = control.teldata_dir.size();
	if(control.teldata_dir[sz-1] != '/') {
	  control.teldata_dir= control.teldata_dir + '/';
	}
	break;


      case 'O':
	if ( argc <= 2 || argv[2][0] == '-'    ) {
	  cout << "No Output direcotry given" << endl;
	  cout << " Run again and provide directory value after -DO" << endl;
	  cout << " Printing Help screen" << endl;
	  mrs_usage();
	  exit(EXIT_FAILURE);
	}

	control.output_dir = argv[2];
	control.flag_dirout = 1;
	sz = control.teldata_dir.size();
	if(control.output_dir[sz-1] != '/') {
	  control.output_dir= control.output_dir + '/';
	}
	break;


      default:
	cerr<< " error unrecognized option after D " 
	  << argv[1][2] << endl;
        cout << "Aborting program, printing help screen" << endl;
        mrs_usage();
        exit(EXIT_FAILURE);
        break;
      }
      ++argv;
      --argc;
      ++argv;
      --argc;
      break;
//_______________________________________________________________________
 // p
      //_______________________________________________________________________
    case 'p':
        if ( argc <= 2 || argv[2][0] == '-'    ) {
          cout << "No Preferences files was given " << endl;
          cout << " Run again and provide directory value after -p" << endl;
          cout << " Printing Help screen" << endl;
          mrs_usage();
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
      // Cube built in V2V3
      //_______________________________________________________________________
    case 'V':
      if(plus) {
	control.V2V3 = 1;
	control.ABL = 0;
      }
      if(minus){
	control.V2V3 = 0;
	control.ABL = 1;
      }
      ++argv;
      --argc;
      break;


      //_______________________________________________________________________
      // Interpolate 
      //_______________________________________________________________________
    case 'I':
      if(plus) control.Interpolate = 1;
      if(minus) control.Interpolate = 0;
      ++argv;
      --argc;
      break;

      //_______________________________________________________________________
      // Interpolate - Distance to nearby pixel to use 
      //_______________________________________________________________________
    case 'N':
      if ( argc <= 2 || argv[2][0] == '-'    ) {
	cout << "Number of Near By Pixels to Use in Interpolation not given " << endl;
	cout << " Run again and provide a # value after -N" << endl;
	cout << " Printing Help screen" << endl;
	mrs_usage();
	exit(EXIT_FAILURE);
      }
      control.Interpolate_distance = atoi(argv[2]);


      ++argv;
      --argc;
      ++argv;
      --argc;
      break;


      //_______________________________________________________________________
      // integration number to make cube from
      //_______________________________________________________________________
    case 'i':
      if ( argc <= 2 || argv[2][0] == '-'    ) {
	cout << "Integration # to make sube from  not given " << endl;
	cout << " Run again and provide a # value after -i" << endl;
	cout << " Printing Help screen" << endl;
	mrs_usage();
	exit(EXIT_FAILURE);
      }
       control.integration_no = atoi(argv[2]);
       control.flag_integration_no = 1;
      ++argv;
      --argc;
      ++argv;
      --argc;
      break;


      //_______________________________________________________________________
      // Subchannel A
      //_______________________________________________________________________
    case 'A':
       control.subchannel = 0;
       control.flag_subchannel = 1;
      ++argv;
      --argc;
      break;

      //_______________________________________________________________________
      // Subchannel B
      //_______________________________________________________________________
    case 'B':
       control.subchannel = 1;
       control.flag_subchannel = 1;
      ++argv;
      --argc;
      break;

      //_______________________________________________________________________
      // Subchannel C
      //_______________________________________________________________________
    case 'C':
      if(Cstring.size() == 3 && argv[1][2] == 'H') {

	if(argc <=2 || !isdigit(argv[2][0]) ) {
	  cout << " Channel # not given after -CH option " << endl;
	  cout << " Run again and provide number after -CH " << endl;
	  cout << " You must have a space after the CH " << endl;
	  cout << " Printing Help Screen " << endl;
	  mrs_usage();
	  exit(EXIT_FAILURE);
	}
	control.channel = atoi(argv[2]);
	control.channel_flag = 1;
	++argv;
	--argc;
	++argv;
	--argc;
	break;
	
      }

      if(Cstring.size() == 2) {

	control.subchannel = 2;
	control.flag_subchannel = 1;
	++argv;
	--argc;
	break;
      }
//__________________________________________________________________________

    case 'b':  
      switch (argv[1][2]){
      case 'w' :
	if(argc <=2 || !isdigit(argv[2][0]) ) {
	cout << " Wavelength bin factor  not given after -bw option " << endl;
	cout << " Run again and provide number after -bw " << endl;
	cout << " You must have a space after the bw " << endl;
	cout << " Printing Help Screen " << endl;
	mrs_usage();
	exit(EXIT_FAILURE);
      }
      control.bin_wave = atof(argv[2]);
      control.bin_wave_flag = 1;
      break;

      case 'a' :
	if(argc <=2 || !isdigit(argv[2][0]) ) {
	cout << " Axis 1 bin factor  not given after -ba option " << endl;
	cout << " Run again and provide number after -ba " << endl;
	cout << " You must have a space after the ba " << endl;
	cout << " Printing Help Screen " << endl;
	mrs_usage();
	exit(EXIT_FAILURE);
      }
      control.bin_axis1 = atof(argv[2]);
      control.bin_axis1_flag = 1;
      break;


      default:
	cerr<< " error unrecognized option after b " 
	  << argv[1][2] << endl;
        cout << "Aborting program, printing help screen" << endl;
        mrs_usage();
        exit(EXIT_FAILURE);
        break;
      }

      ++argv;
      --argc;
      ++argv;
      --argc;
      break;
 //_______________________________________________________________________
    case 'm':  
      switch (argv[1][2]){

      case 'w' :
	control.write_mapping = 1;
	break;

      case 'o' :
	if ( argc <= 2 || argv[2][0] == '-'    ) {
	  cout << "No output mapping file name given" << endl;
	  cout << " Run again and provide filename value after -mo" << endl;
	  cout << " Printing Help screen" << endl;
	  mrs_usage();
	  exit(EXIT_FAILURE);
	}
	control.mapping_name_output = argv[2];

	control.flag_mapping_name_output= 1;
	control.write_mapping = 1;
	++argv;
	--argc;

	break;


      default:
	cerr<< " error unrecognized option after m " 
	    << argv[1][2] << endl;
        cout << "Aborting program, printing help screen" << endl;
        mrs_usage();
        exit(EXIT_FAILURE);
        break;
      }

      ++argv;
      --argc;
      break;

//_______________________________________________________________________

      //_______________________________________________________________________
      // Ouput options
      //_______________________________________________________________________

    case 'O':
      switch (argv[1][vstart+1]){
      case 'W':
	control.OverWrite = true;
	break;
	
      default:
	cerr << " error: unrecognized option after O"
	     << argv[1][vstart+1] << endl;
	cout << "Aborting program, printint help screen " << endl;
	mrs_usage();
	exit(EXIT_FAILURE);
	break;
      }
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
	  mrs_usage();
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
      // x number of slices contained in a tile 
    case 'x':
      if(argc <=2 || !isdigit(argv[2][0]) ) {
	cout << " Number of Slices to build the cube up in sections not given " << endl;
	cout << " Run again and provide number after -n " << endl;
	cout << " You must have a space after the x " << endl;
	cout << " Printing Help Screen " << endl;
	mrs_usage();
	exit(EXIT_FAILURE);
      }
      control.numSlicesNTile = atoi(argv[2]);
      ++argv;
      --argc;
      ++argv;
      --argc;
      break;
      //_______________________________________________________________________
      //_______________________________________________________________________
      // v
      //_______________________________________________________________________
    case 'v':
       control.do_verbose = 1;
      ++argv;
      --argc;
      break;
      //_______________________________________________________________________

      // dispersion, plate scale
      //_______________________________________________________________________

    case 'd':
      if(argc <=2 || !isdigit(argv[2][0]) ) {
	cout << " Dispersion not given after -d option " << endl;
	cout << " Run again and provide number after -d " << endl;
	cout << " You must have a space after the d " << endl;
	cout << " Printing Help Screen " << endl;
	mrs_usage();
	exit(EXIT_FAILURE);
      }
      control.dispersion = atof(argv[2]);
      control.dispersion_flag = 1;	
      ++argv;
      --argc;
      ++argv;
      --argc;
      break;
      //_______________________________________________________________________
    case 'a':
      if(argc <=2 || !isdigit(argv[2][0]) ) {
	cout << " Alpha Plate scale  not given after -a option " << endl;
	cout << " Run again and provide number after -a " << endl;
	cout << " You must have a space after the a " << endl;
	cout << " Printing Help Screen " << endl;
	mrs_usage();
	exit(EXIT_FAILURE);
      }
      control.scale_axis1 = atof(argv[2]);
      control.scale_axis1_flag = 1;	
      ++argv;
      --argc;
      ++argv;
      --argc;
      break;
      //_______________________________________________________________________

      //_______________________________________________________________________

    default :
      cout << "Bad Option " << argv[1] << endl;
      mrs_usage();
      exit(8);
    }
    
  }



  
}
