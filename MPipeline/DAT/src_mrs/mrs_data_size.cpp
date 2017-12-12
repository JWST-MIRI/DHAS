#include <iostream>
#include <string>
#include <vector>
#include <math.h>
#include <algorithm>
#include <cstdlib> // EXIT_FAILURE   , EXIT_SUCCESS
#include "fitsio.h"
#include "mrs_CubeHeader.h"
#include "mrs_data_info.h"
/**********************************************************************/

void mrs_data_size(const int channel_type,
		   const int ntile,
		   CubeHeader cubeHead,
		   const mrs_data_info data_info,
		   const int NSample,
		   long &num,
		   const int verbose)
                    

  
{

  num = 0; 

  int ymin = 1;
  int ymax = 1024;

  int nSlices = cubeHead.GetNumSlices();
  
  long telements = 0;
  for (int i = 0 ; i < nSlices; i++){

    vector <int> num;
    int inum = cubeHead.GetSliceNo(i);

    int xmin =    data_info.slice_range_min[channel_type][inum-1] ;
    int xmax = data_info.slice_range_max[channel_type][inum-1];

      
    if(verbose) cout<< " xmin  xmax " << xmin << " " << xmax << endl;
    long nelements =  (xmax -xmin +1) * (ymax -ymin +1);
    telements =telements + nelements;    
  }

  num = telements;


}


