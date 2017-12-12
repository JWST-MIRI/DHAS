// mrs_DGPOS
#include <iostream>
#include <string>
#include <iomanip>
#include <fstream>
#include <math.h>
#include <cstdlib>
#include "fitsio.h"
#include "mrs_data_info.h"


/**********************************************************************/
// Description of program:
// Read in the list of reduced files to build a spectrall cube with
// Varibles filled in by this program: 
// 1. File names read into varible data_info.input_filenames
// 2. number of files read in: data_info.num_files 
/**********************************************************************/
// Read in list of input image filenames

int mrs_DGPOS(mrs_data_info &data_info)
  
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
  
  
  int sa = data_info.DGAA_POS.size();
  int sb = data_info.DGAB_POS.size();

  if(sa != sb) {
    status = 1;
    cout << " The number of files with the DGAA keyword in the FITS header does not equal the number of files with the DBAB keyword in the header " << endl;
    return status;
  }

  for (int k = 0;k<data_info.nfiles;k++){

    data_info.Use_File[k] = 1;
    data_info.WAVE_ID[k] = data_info.DGAA_POS[k];
      

  }



    return 0; // ifstream destructor closes the file
}

