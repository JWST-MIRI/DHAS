#include <iostream>
#include <string>
#include "mc_control.h"
#include "miri_caler.h"
#include <cstdlib> // EXIT_FAILURE   , EXIT_SUCCESS

/**********************************************************************/
// procedure to parse the command line 

void mc_parse_commandline(int& argc, 
			  char* argv[],
			  mc_control &control)

{

  
  // fill in command line parameters
  if ((argc > 1) && (argv[1][0] != '-') && (argv[1][0] != '+')){
    control.fitsbase = argv[1];
  }else {
    cout << "No file specified." << endl;
    mc_usage();
    exit(EXIT_FAILURE);
  }
  //  cout << "File name " << control.fitsbase << endl;

  --argc;
  ++argv;

  int vstart = 0;
  while (argc > 1) {

    bool minus = false;
    bool plus = false;
    string Cstring = argv[1];
    //cout << "cstring" << Cstring <<  " " << Cstring.size() << endl;
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
	//	if ( argc <= 2 || argv[2][0] == '-'    ) {
	//  cout << "No Calibration Science Directory given" << endl;
	//  cout << " Run again and provide directory value after -DC" << endl;
	//  cout << " Printing Help screen" << endl;
	//  mc_usage();
	//  exit(EXIT_FAILURE);
	//}
	//control.calib_dir = argv[2];
	//control.flag_dircal = 1;
	// sz = control.calib_dir.size();
	//if(control.calib_dir[sz-1] != '/') {
	//  control.calib_dir = control.calib_dir + '/';
	//	}
	break;
      case 'I':
	if ( argc <= 2 || argv[2][0] == '-'    ) {
	  cout << "No Input Science Directory given" << endl;
	  cout << " Run again and provide directory value after -DI" << endl;
	  cout << " Printing Help screen" << endl;
	  mc_usage();
	  exit(EXIT_FAILURE);
	}

	control.scidata_dir = argv[2];
	control.flag_dirsci = 1;
	 sz = control.scidata_dir.size();
	if(control.scidata_dir[sz-1] != '/') {
	  control.scidata_dir= control.scidata_dir + '/';
	}
	break;

      case 'O':
	if ( argc <= 2 || argv[2][0] == '-'    ) {
	  cout << "No Output Science Directory given" << endl;
	  cout << " Run again and provide directory value after -DO" << endl;
	  cout << " Printing Help screen" << endl;
	  mc_usage();
	  exit(EXIT_FAILURE);
	}

	control.scidata_out_dir = argv[2];
	control.flag_dirout = 1;
	 sz = control.scidata_out_dir.size();
	if(control.scidata_out_dir[sz-1] != '/') {
	  control.scidata_out_dir= control.scidata_out_dir + '/';
	}
	break;



      case 'T':

	cout << " -DT is not a valid option anymore. The program will not work out the correct calibration file to use" << endl;
	cout << " You have to provide the name of the calibration to use " << endl;
	exit(EXIT_FAILURE);

	if ( argc <= 2 || argv[2][0] == '-'    ) {
	  cout << "No Input Telemetry Directory given" << endl;
	  cout << " Run again and provide directory value after -DT" << endl;
	  cout << " Printing Help screen" << endl;
	  mc_usage();
	  exit(EXIT_FAILURE);
	}

	control.teldata_dir = argv[2];
	control.flag_dirtel = 1;
	sz = control.teldata_dir.size();
	if(control.teldata_dir[sz-1] != '/') {
	  control.teldata_dir= control.teldata_dir + '/';
	}
	break;

      default:
	cerr<< " error unrecognized option after D " 
	  << argv[1][2] << endl;
        cout << "Aborting program, printing help screen" << endl;
        mc_usage();
        exit(EXIT_FAILURE);
        break;
      }
      ++argv;
      --argc;
      ++argv;
      --argc;
      break;

  //_______________________________________________________________________
      // old option
    case 'V':
      ++argv;
      --argc;
      cout << " -VM option is an un-supported option. Run version 6.1.1" << endl;
      exit(EXIT_FAILURE);
      break;

  //_______________________________________________________________________
      // old option
    case 'F':
      ++argv;
      --argc;
      break;

    case 'J':
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
	  mc_usage();
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
	  mc_usage();
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
      // v
      //_______________________________________________________________________
    case 'v':
       control.do_verbose = 1;
      ++argv;
      --argc;
      break;

      //_______________________________________________________________________
      // Subchannel A
      //_______________________________________________________________________
    case 'A':
	cout << " -A is not a valid option anymore. The program will not work out the correct calibration file to use" << endl;
	cout << " You have to provide the name of the calibration to use " << endl;
	exit(EXIT_FAILURE);
       control.subchannel = 0;
       control.flag_subchannel = 1;
      ++argv;
      --argc;
      break;

      //_______________________________________________________________________
      // Subchannel B
      //_______________________________________________________________________
    case 'B':
	cout << " -B is not a valid option anymore. The program will not work out the correct calibration file to use" << endl;
	cout << " You have to provide the name of the calibration to use " << endl;
	exit(EXIT_FAILURE);
       control.subchannel = 1;
       control.flag_subchannel = 1;
      ++argv;
      --argc;
      break;

      //_______________________________________________________________________
      // Subchannel A
      //_______________________________________________________________________
    case 'C':
	cout << " -C is not a valid option anymore. The program will not work out the correct calibration file to use" << endl;
	cout << " You have to provide the name of the calibration to use " << endl;
	exit(EXIT_FAILURE);
       control.subchannel = 2;
       control.flag_subchannel = 1;
      ++argv;
      --argc;
      break;

      //_______________________________________________________________________
      // Imager
      //_______________________________________________________________________
    case 'I':
	cout << " -I is not a valid option anymore. The program will not work out the correct calibration file to use" << endl;
	cout << " You have to provide the name of the calibration to use " << endl;
	exit(EXIT_FAILURE);
       control.subchannel = -1;
       control.flag_subchannel = 1;
      ++argv;
      --argc;
      break;
      //_______________________________________________________________________
      // b subtract background calibration file
      //_______________________________________________________________________
     case 'b':
      if(Cstring.size() == 3 && argv[1][2] == 'f') {

	if ( argc <= 2 || argv[2][0] == '-'    ) {
	  cout << "No back ground LVL2   file was given " << endl;
	  cout << " Run again and provide  file name after -bf" << endl;
	  cout << " Printing Help screen" << endl;
	  mc_usage();
	  exit(EXIT_FAILURE);
	}
	control.flag_background_file = 1;
	control.background_file = argv[2];
	control.apply_background = 1;
	++argv;
	--argc;
	++argv;
	--argc;
	break;
      }
      if(Cstring.size() == 2) {
	if(plus) control.apply_background = 1;
	if(minus) control.apply_background = 0;
	++argv;
	--argc;
	break;
      }

      //_______________________________________________________________________
      // f - flat calibration file
      //_______________________________________________________________________
     case 'f':
      if(Cstring.size() == 3 && argv[1][2] == 'f') {

	if ( argc <= 2 || argv[2][0] == '-'    ) {
	  cout << "No flat calibration  file was given " << endl;
	  cout << " Run again and provide  file name after -ff" << endl;
	  cout << " Printing Help screen" << endl;
	  mc_usage();
	  exit(EXIT_FAILURE);
	}
	control.flag_flat_file = 1;
	control.flat_file = argv[2];
	control.apply_flat = 1;
	++argv;
	--argc;
	++argv;
	--argc;
	break;
      }
      if(Cstring.size() == 2) {
	if(plus) control.apply_flat = 1;
	if(minus) control.apply_flat = 0;
	//cout << " Apply flat calibration file" << control.apply_flat<< endl;
	++argv;
	--argc;
	break;
      }

      //_______________________________________________________________________
      // r - fringe flat calibration file
      //_______________________________________________________________________
     case 'r':
      if(Cstring.size() == 3 && argv[1][2] == 'f') {

	if ( argc <= 2 || argv[2][0] == '-'    ) {
	  cout << "No fringe flat calibration  file was given " << endl;
	  cout << " Run again and provide  file name after -rf" << endl;
	  cout << " Printing Help screen" << endl;
	  mc_usage();
	  exit(EXIT_FAILURE);
	}
	control.flag_fringe_file = 1;
	control.fringe_file = argv[2];
	control.apply_fringe_flat = 1;
	++argv;
	--argc;
	++argv;
	--argc;
	break;
      }
      if(Cstring.size() == 2) {
	if(plus) control.apply_fringe_flat = 1;
	if(minus) control.apply_fringe_flat = 0;
	//cout << " Apply fringe flat calibration file" << control.apply_fringe_flat<< endl;
	++argv;
	--argc;
	break;
      }

      //_______________________________________________________________________

    default :
      cout << "Bad Option " << argv[1] << endl;
      mc_usage();
      exit(8);
    }
    
  }


  // ***********************************************************************
  

  if(control.do_verbose ==1) {
    if( control.apply_flat ==1 )cout << " Applying a flat"  << endl;
    if( control.apply_background ==1) cout << " Apply a background" << endl;
      }
    
  
}
