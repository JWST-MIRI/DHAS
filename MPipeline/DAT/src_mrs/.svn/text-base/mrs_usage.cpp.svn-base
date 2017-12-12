#include <iostream>
#include "dhas_version.h"

using namespace std;

/**********************************************************************/
// Progam which describes how to use miri_sloper

void mrs_usage()

{

  cout << "MIRI MRS DHAS Pipeline " << dhas_version << endl;
  cout << "usage: miri_cube filelist [options] " << endl;

  cout << "   -DI <directory>  [default = set in preferences file]" << endl;
  cout << "      <directory> = directory where to find science data" << endl;
  cout << "       Use . to specific the current directory" << endl;

  cout << "   -DC <directory>  [default = set in preferences file]" << endl;
  cout << "      <directory> = directory where calibration files live" << endl;
  cout << "       Use . to specific the current directory" << endl;

  cout << "   -DO <directory>  [default = set in preferences file]" << endl;
  cout << "      <directory> = directory where to write output Cubes" << endl;
  cout << "       Use . to specific the current directory" << endl;

  cout << "   -DT <directory>  [default = set in preferences file]" << endl;
  cout << "      <directory> = directory where to find telemetry ICE FITS data" << endl;
  cout << "       Use . to specific the current directory" << endl;
 cout << "        The telemetry data (ICE file) is needed if running on VM SW data to find the filter combination" << endl;
  cout << "       If you know the subchannel of the data, then you can use the options -A, -B or -C to speficy the sub-channel" << endl;

  cout << "   -A to flag this data as coming from sub-channel A. The telemetry file reading is bypassed" << endl;
  cout << "   -B to flag this data as coming from sub-channel B. The telemetry file reading is bypassed" << endl;
  cout << "   -C to flag this data as coming from sub-channel C. The telemetry file reading is bypassed" << endl;
  cout << " " << endl;

  cout << "-/+ I (do not/do) Interpolation for Nanned slope pixels using the near-by non-nanned pixels. By default this is not done. " << endl;
  cout << "   -N #  # is the number of near-by pixels to use for interpolating a slope value for Nanned slope pixels. The default is 2. " << endl;

  cout << "   -o <filename> user provided  output prefix file name " << endl;
  cout << "       The default is to use the  filename and add CUBE_CH#" << endl;

  cout << " -p  <directory+filename> of the preferences file to use " << endl;
  cout << "     default is to use the MIRI_DHAS_v#.#.FM_preferences located in the Preference directory below where the environmental variable  MIRI_DIR points to.  " << endl;
  
  cout << "   +V  Output coordinate system V2-V3 " << endl;
  cout << "   -V  Output coordinate system alpha-beta" << endl;


  
  cout << "   -bw # wavelength bin factor. # greater than 0 results in a cube with less wavelength bins. " << endl; 
  cout << "   -ba # Alpha bin factor. # greater than 0 results in a cube with less alpha bins. " << endl;

  cout << "   -x # where # is the number of slices t to work with at one time " << endl;
  cout << "   -CH # where # is the channel number the cube is going to be built for. " << endl;
  cout << "         By default two cubes are built per run, since each input file contains two channels" << endl;
  cout << "         By using this option the user limits only 1 channel cube to be built" << endl;
  cout << "   -d #, where # is the disperion to be used when building the cube. The user must also specify the " <<endl;
  cout << "         channel this is for with the -CH # option. Only the channel cube will be built " << endl;
  cout << "   -a #, where # is the alpha plate scale (in arc seconds) to be used when building the cube." << endl;
  cout << "         The user must also specify the channel this is for with the -CH # option. " << endl;
  cout << "         Only the channel cube will be built " << endl;
  cout << "   -i #, where # is the integration number of the slope image to make the cube from " << endl;

  //  cout << "   -OW  overwrite an existing spectral cube  with the one produced with this run " << endl;
  cout << "   -v output very detailed information to the screen" << endl;
  cout << " -----------The following options relate to the mapping overlap file----------" << endl;
   cout << "   -mw  Write the mapping overlap file out (if -mo is not used then the name of the file will be the default name " << endl;
  cout << "   -mo <string> The base name of the output mapping file (do not include .fits,  channel, or subchannel information to the name, the program will add this information to the filename " << endl;


}
