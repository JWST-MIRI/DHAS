// This software is part of the MIRI Data Handling and Analysis Software (DHAS)
// This routine belongs to the miri_sloper package which processes raw science data.

// Name:
//      ms_usage.cpp
//
// Purpose:
//   This program prints to the screen the command line options for miri_sloper.cpp
//   This program is called if the user just type 'miri_sloper' or if an incorrect
//   commandline option was used. 	
//
//
// Author:
//
//	Jane Morrison
//      University of Arizona
//      email: morrison@as.arizona.edu
//      phone: 520-626-3181
// 
// Calling Sequence:
//  void ms_usage()
//
//
// Arugments:
//
// none   
//
// Return Value/ Variables modified:
//      No return value.  
// 
//
// History:
//
//	Written by Jane Morrison 2005
//      Changes to code are found on the MIRI DHAS web site:exit

//      http://tiamat.as.arizona.edu/dhas/

#include <iostream>
#include "dhas_version.h"

using namespace std;

/**********************************************************************/
// Program which describes how to use miri_sloper/


void ms_usage()

{

  cout << "MIRI DHAS Pipeline " << dhas_version << endl;
  cout << "usage: miri_sloper filename [options]" << endl;

  cout << " -DI <directory>  [default = set in preferences file]" << endl;
  cout << "     <directory> = directory where to find science data" << endl;
  cout << "     Use . to specific the current directory" << endl;

  cout << " -DO <directory>  [default = set in preferences file]" << endl;
  cout << "     <directory> = directory to write SLOPE/LVL2 output data" << endl;
  cout << "     Use . to specific the current directory" << endl;


  cout << " -DC <directory>  [default = set in preferences file]" << endl;
  cout << "     <directory> = directory where calibration files live" << endl;
  cout << "     Use . to specific the current directory" << endl;

  cout << " -o  <filename> user provided Slope output file name " << endl;
  cout << "     The default is to use the Raw Level 1 filename and add a LVL2 onto it" << endl;
  
  cout << " -p  <directory+filename> of the preferences file to use " << endl;
  cout << "     default is to use the MIRI_DHAS_v#.#.FM_preferences located in the Preference directory below where the environmental variable  MIRI_DIR points to.  " << endl;
   cout << " -Q quick processing. Produce a slope and a zero pt image. Only processing allowed is rejecting of initial and final frames " << endl;

   //  cout << " -FM This is FM data. The default is set in the preference file and is FM"<< endl;
   //cout << " -JPL This is JPL test data. The default is set in the preference file and is FM"<< endl;

  cout << "     " << endl;  
  cout << " ------> Processing Options: " << endl;


  cout << " -a # <integer>  Frame number to start fitting slope (default set in preference file)" << endl;
  cout << " -z # <integer>  Frame number to end fitting slope  (default set in preferences file) Do use both -z and -n options" << endl;
  cout << " -n # <integer>  Stop the fit on the # of frames before the last frame number (default set in preferences file). Do not use both -z and -n options" << endl;


  cout << " -h # <float>  High DN value, frame values greater than this value are rejected" << endl;
  cout << " -g # <float> Gain to use (e/DN). Default is found in preferences file " << endl;
  cout << " -rn # <float> Read Noise. This value is only used if -UU or -UC is also used. Default in preferences file" << endl;
  cout << " -t # <float>  Frame time to use to convert to (seconds/frame). " << endl;
  cout << " +/- e convert (do not convert) to electrons/second (From DN/frame)" << endl;

    cout << " -i # or -i #1 #2 #3 <integer> The # are the integration numbers NOT to use in calculating the Average Slope given in the Primary image." << endl;
  cout << "  You can give more than 1 integration to exclude (just list the int numbers. DO not seperate the # by commas"  << endl;

  cout << "   " << endl;
  cout << " ------> Bad Pixel File options: " << endl;
  cout << " +/- b apply (do not apply) bad pixel list [Default: Apply]" << endl;
  cout << " -bf filename  Bad pixel file to use. (Default provided in MIRI_CDP list found in preference file) " << endl;
  cout << "     ATTENTION: miri_sloper will figure out the correct bad pixel file to use" << endl;
  cout << "     ONLY provide the filename if you are using a  modified file & you are an ADVANCED DHAS user" << endl;
  cout << "   " << endl;


  cout << "   " << endl;
  cout << " ------> Subtracting Reset Switch Charge Decay (RSCD) Correction: " << endl;
  cout << " +/- rd apply (do not apply) Reset switch charge Decay correction  [Default: do not] " << endl;
  cout << " -rdf filename rscd file to use. (Default provided in MIRI_CDP list found preferences file" << endl;
  cout << "     ATTENTION: miri_sloper will figure out the correct  file to use that is found in the calibration directory" << endl;
  cout << "     ONLY provide the filename if you are using a special user modified file" << endl;


  cout << "   " << endl;
  cout << " ------> Subtracting Reset Correction: " << endl;
  cout << " +/- r apply (do not apply) reset correction file  [Default: do not] " << endl;
  cout << " -rf filename reset correction file to use. (Default provided in MIRI_CDP list found preferences file" << endl;
  cout << "     ATTENTION: miri_sloper will figure out the correct  file to use that is found in the calibration directory" << endl;
  cout << "     ONLY provide the filename if you are using a special user modified file" << endl;





  cout << "   " << endl;
  cout << " ------> Last frame  Correction: " << endl;
  cout << " +/- l apply last frame correction  [Default: do not] " << endl;
  cout << " -lf filename lastframe file to use. (Default provided in MIRI_CDP list found preferences file" << endl;
  cout << "     ATTENTION: miri_sloper will figure out the correct  file to use that is found in the calibration directory" << endl;
  cout << "     ONLY provide the filename if you are using a special user modified file" << endl;


  cout << "   " << endl;
  cout << " ------> Subtracting Dark Frame by Frame Options: " << endl;
  cout << " +/- D apply (do not apply) dark correction file  [Default: do not] " << endl;
  cout << " -Df filename  Dark correction file to use. (Default provided in MIRI_CDP list found in preferences file" << endl;
  cout << "     ATTENTION: miri_sloper will figure out the correct  file to use that is found in the calibration directory" << endl;
  cout << "     ONLY provide the filename if you are using a special user modified file" << endl;


  cout << "   " << endl;
  cout << " ------> Pixel Saturation File options: " << endl;
  cout << " +/-s apply (do not apply) pixel saturation mask [Default: do not] " << endl;
  cout << " -sf <filename>  Pixel saturation mask file  use. (Default provided in MIRI_CDP list found preferences file)" << endl;
  cout << "     ATTENTION: miri_sloper will figure out the correct pixel saturation file to use. " << endl;
  cout << "     ONLY provide the filename if you are using a modified file & you are an ADVANCED DHAS user" << endl;

  cout << "   " << endl;
  cout << " ------> Linearity Correction Options: " << endl;
  cout << " +/- L apply (do not apply) linearity correction file  [Default: do not] " << endl;
  cout << " -Lf filename  Linearity correction file to use. (Default provided in MIRI_CDP list found  preferences file" << endl;
  cout << "     ATTENTION: miri_sloper will figure out the correct  file to use that is found in the calibration directory" << endl;
  cout << "     ONLY provide the filename if you are using a special user modified file" << endl;



  cout << "   " << endl;
  cout << " ------> Using uncertainty of measurements and calculating error plane of slope Options: " << endl;
  cout << " -U1 Set the measurement uncertainties = 1. This option does not used the measurement uncertainties in the slope determination" << endl;
  cout << " -UU Use the measurement uncertainties to determine the slope. See User's guide for more information" <<endl;
  cout << " -UC Use random and correlated  measurement uncertainties to determine the slope. See User's guide for more information" <<endl;
	

  cout << "   " << endl;
  cout << " ------> Search for Corrupt Frames (Electronics) " << endl;
  cout << " +/-S do (do not) Search for Bad Frames " << endl;

  cout << "   " << endl;
  cout << " ------> Cosmic Ray Identification Options: " << endl;
  cout << " +/-C do (not do) identify large jumps in data (possible cosmic rays) " << endl;
  cout << " -cs # <float> Cosmic Ray sigma rejection value (default in preference file)" << endl;
  cout << " -cd # <integer> Minimum number of two point differences needed for cosmic ray/noise identifications (Default in preference file" << endl;
  cout << " -cf # <integer> Number of frames to reject after a cosmic ray/noise identifications (Default in preferences file) " << endl;

  cout << " -cn # <integer> Dn value which is lower limit on jumps in sample-up-the-ramp caused by cosmic rays or noise spikes (Default in preferences file) " << endl;

  cout <<" -ci # <integer> Maximum number of iterations to do for cosmic ray/noise identification (Default in preferences file " << endl;

  cout <<" -cr # <float> Cosmic ray slope segment sigma rejection value (default given in preferences file) " << endl;
  cout <<" -cv  Flag to print more information to screen on cosmic rays detected. (More for debugging and optimizing parameters " << endl;




  cout << "     " << endl;  
  cout << " ------> Reference Pixel correction options: " << endl;

  cout << " +/-r6  do(not do)  reference pixel correction option 6 [Default: do not]" << endl;  
  cout << "        subtract the reference pixels on frame 1 from all the other frames " << endl;
  cout << "        correction based on mean of this difference per frame/channel split into even/odd rows. 8 correction values/frame " << endl;
  cout << "        similar to r3 but frame 1 reference pixels are subtracted first" <<endl;


  cout << " +/-r7  do(not do)  reference pixel correction option 7 [Default: do not]" << endl;  
  cout << "        solve for temperature dependence of reference pixels" <<endl;
  cout << "        remove temperature dependence of the reference pixels from the data" << endl;

  cout << " -rs #  <integer> sigma clipping # for reference pixel outlier rejection [default 3]" << endl;
  cout << " -rb #  <integer> filter box size for reference pixel outlier rejection [default 128 rows]" << endl;
  cout << "         Seperately for each channel and even and odd rows" << endl;


  //  cout << " +/-r1  do(not do)  reference pixel correction option 1 [Default: do not]" << endl;  
  // cout << "        subtract the reference pixels on frame 1 from all the other frames " << endl;
  // cout << "        correction/frame/channel based on Moving mean this difference." << endl;
  //cout << "        The mean is determined for each row & amplifier, usinga  box filter of size defined by parameter -rd "<< endl;
  //cout << "        The moving mean filter is done using either even or odd rows based on row in question" << endl;
  //cout << "        The Final Mean for the row is an average  left and right moving mean." << endl;

  //cout << " +/-r2  do(not do)  reference pixel correction option 2 [Default: do not]" << endl;  
  //cout << "        find a correction for each frame and each channel on a row by row basis interpolating " << endl;
  //cout << "        between the left and right reference pixels (see -rd for averaging rows)" << endl;
  //cout << " -r2d #  <integer> number of (even/odd) rows to average in determining the reference pixel correction" << endl;
  //cout <<  "        based on option -r2. The value provided = # of even/odd rows +/- the current row  (default = in preference file) " << endl;
  //cout << "        even/odd status  determined by even/odd nature of the row in question" << endl;



  cout << " "  << endl; 
  cout << "  ------> Options to write output files: " << endl; 
  cout << " -d  Write diagnostic information to the LVL2 file. An additional 5 planes of data. " << endl;
  cout << "     Plane 8: Empirical RMS and Plane 9-12 deal with 2 pt differences " << endl;
  cout << " -OR Write an intermediate FITS file with each frame of data corrected by the reference data " << endl;
  cout << " -OL Write an intermediate FITS file with each frame of data corrected by linearity correction " << endl;
  cout << " -OD Write an intermediate FITS file with each frame of data corrected by mean dark  correction " << endl;
  cout << " -Or Write an intermediate FITS file with each frame of data corrected by Reset anomaly  correction " << endl;
  cout << " -Ord Write an intermediate FITS file with each frame of data corrected by RSCD correction " << endl;
  cout << " -OI output the individual frame identifications" << endl;
  cout << " -OC Output detailed cosmic ray information to a txt file " << endl;
  cout << " +Os Determine and write out the reference image slope fits file. " << endl;
  cout << " -Os DO NOT Determine and write out the reference image slope fits file [default]"<< endl;

  // cout << " -Oa write all major intermediate/analysis files ( same as -OR, -OI, -OC, -OL) " << endl;

  cout << " -OS Write an intermediate FITS file containing segment information for each pixel " << endl;
  cout << " -Op Write the reference pixel corrections to an ascii file (if +r1, +r2, +r3,r7 or r6  is set)" << endl;

  cout << "   " << endl;
  cout << " ------> Pulse Mode Options " << endl;
  cout << " -Pi  #. Pulse mode, # is the first frame to use in determining Amplitude f-i. " << endl;
  cout << "          f is defaulted to be n-1 frame or can be provided by the user with -Pf # option. " << endl;
  cout << " -Pf  #. Pulse mode, # is the last frame to use in determining Amplitude f-i. " << endl;


  cout << "   " << endl;
  cout << " ------> Misc : " << endl;

  cout << " -v output very detailed information to the screen" << endl;


  cout << " -FL # <integer>  limit on number of frames per integration for reading in full array." << endl;
  cout << "     If number of frames is larger than limit then the data in and processed in subsets "<< endl;
  cout << "     A reasonable number is 40" << endl;

  cout << " -R # <integer> Number of rows of the science image to read in and process " << endl;
  cout << "      This number must be a multiple of 4, if it is not the program will convert it to the closest number that is a multiple of 4" << endl;
  cout << "      This is used if number of frames is over the -FL limit (see above) " << endl;


  cout << " -run # <integer> JPL Run #, valid values are 1-8" << endl;
  cout << " -jdet # string  Detector to use for JPL Run 8, valid values are 101, 106 or 124" << endl;




}
