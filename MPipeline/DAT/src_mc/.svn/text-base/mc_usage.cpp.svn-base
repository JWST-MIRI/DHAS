#include <iostream>
#include "dhas_version.h"

using namespace std;

/**********************************************************************/
// Progam which describes how to use miri_sloper

void mc_usage()

{

  cout << "MIRI DHAS Pipeline " << dhas_version << endl;
  cout << "usage: miri_caler filename [options]" << endl;

  cout << " -DI <directory>  [default = set in preferences file]" << endl;
  cout << "     <directory> = directory where to find science data" << endl;
  cout << "      Use . to specific the current directory" << endl;

  cout << " -DO <directory>  [default = set in preferences file]" << endl;
  cout << "     <directory> = directory where to write out LVL3 science data" << endl;
  cout << "      Use . to specific the current directory" << endl;

  // User gives calibration directory with calibration file 
  //  cout << " -DC <directory>  [default = set in preferences file]" << endl;
  // cout << "     <directory> = directory where calibration files live" << endl;
  //cout << "     ONLY change this if you are testing new calibration files and know what you are doing" << endl;
  //cout << "      Use . to specific the current directory" << endl;



  cout << " -o <filename> user provided Slope output file name " << endl;
  cout << "       The default is to use the Raw Level 1 filename and add a LVL2 onto it" << endl;
  
  cout << " -p  <directory+filename> of the preferences file to use " << endl;
  cout << "     default is to use the MIRI_DHAS_v#.#.FM_preferences located in the Preference directory below where the environmental variable  MIRI_DIR points to.  " << endl;


  cout << " -v output very detailed information to the screen" << endl;

  cout << " -bf filename  background file to  use, include directory. " << endl;
  cout << " -ff filename  flat calibration file to  use, include directory. " << endl;
  cout << " -rf filename  fringe flat calibration file to  use, include directory." << endl;

  cout << "===> Options for Calibrating steps (- turn off, + turn on)" << endl;
  cout << " +/- b apply (do not apply) background image" << endl;
  cout << " +/- f apply (do not apply) flat calibration file" << endl;
  cout << " +/- r apply (do not apply) fringe flat calibration file" << endl;


}
