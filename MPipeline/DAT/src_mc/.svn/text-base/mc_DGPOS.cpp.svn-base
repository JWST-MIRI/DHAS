// mc_DGPOS
#include <iostream>
#include <string>
#include <iomanip>
#include <fstream>
#include <math.h>
#include <cstdlib>
#include "fitsio.h"
#include "miri_constants.h"
#include "mc_data_info.h"


/**********************************************************************/
// Description of program:
// Read in the list of reduced files to build a spectrall cube with
// Varibles filled in by this program: 
// 1. File names read into varible data_info.input_filenames
// 2. number of files read in: data_info.num_files 
/**********************************************************************/
// Read in list of input image filenames

int mc_DGPOS(mc_data_info &data_info)
  
{

  //  cout << " read in input files " << endl;
  int status = 0;



  if(data_info.DGAA_POS_FLAG ==0){
    status =1;
    cout << " The Grating Wheel assembly for Channel 1 and 4 not found in Header"<< endl;
  }

  if(data_info.DGAB_POS_FLAG ==0){
    status =1;
    cout << " The Grating Wheel assembly for Channel 2 and 3 not found in Header"<< endl;
  }
  if(status ==1) return status;
  
  

  int FILTER_ID = -1;
  if(data_info.DGAA_POS == 0 && data_info.DGAB_POS ==0) FILTER_ID = SUBCHANNEL_A;
  if(data_info.DGAA_POS == 1 && data_info.DGAB_POS ==1) FILTER_ID = SUBCHANNEL_B;
  if(data_info.DGAA_POS == 2 && data_info.DGAB_POS ==2) FILTER_ID = SUBCHANNEL_C;

   
  if(FILTER_ID ==-1) {
    cout << " Filter Wheel positions not of correct set  (DGAA_POS, DGAB_POS) " << data_info.DGAA_POS 
	 << " " <<  data_info.DGAB_POS << endl;
    status = 1;
    return status;
  }

   data_info.FILTER = FILTER_ID;



    return 0; // ifstream destructor closes the file
}

