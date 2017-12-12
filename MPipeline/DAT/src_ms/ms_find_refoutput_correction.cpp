// This software is part of the MIRI Data Handling and Analysis Software (DHAS)
// This routine belongs to the miri_sloper package which processes raw science data.

// Name:
//     ms_find_refoutput_correction.cpp
//
// Purpose:
// This program finds the reference output (channel 5)  corrections. The reference output
// corrections are found for the cases +ro2  before the science data is read in.
// A linear fit is performed on each row of reference output data.
// The slope and y-intercept are stored for later use.  In the case of +ro3 an additional
// mean value is stored for each row. 
// if +roc (do_refoutput_median_column) subtract from each reference output column the
//          median of the column
// if +ro2: correction = raw_refoutput - linear_fit_value

// 	
//
//
// Author:
//
//	Jane Morrison
//      University of Arizona
//      email: morrison@as.arizona.edu
//      phone: 520-626-3181
// 
// Additional routines called
// 
// void FindMedian(vector<float> flux,float& Median);
//     A routine from the DHAS general library:DHAS/MPipeline/DAT/src_gen
//    This program finds the median value from a vector. 
// Calling Sequence:
//
//void ms_find_refoutput_correction( const int iter,
//				   miri_control control,
//				   miri_data_info &data_info,
//				   vector<miri_refoutput> &refoutput)
//
// Arguments:
//  iter: current iteration number
//  control: miri_control structure containing the processing options
//  data_info: miri_data_info structure containing basic information on the dataset
//  refoutput: a miri_refoutput class vector holding the reference output slope, yintercepts
//              and mean value/row
//
//
// Return Value/ Variables modified:
//      No return value.  
// refouput class filled in with reference output correction values for each row
//
// refoutput is updated with the correction information
// History:
//
//	Written by Jane Morrison November 2008
//      Changes to code are found on the MIRI DHAS web site:
//      http://tiamat.as.arizona.edu/dhas/


#include <vector>
#include <algorithm>
#include <iostream>
#include "miri_data_info.h"
#include "miri_control.h"
#include "miri_refoutput.h"
# include "miri_sloper.h"
#include "fitsio.h"

void FindMedian(vector<float> flux,float& Median);
void linfit(vector<float> &, float &, float &, int &);

void ms_find_refoutput_correction( const int iter,
				   miri_control control,
				   miri_data_info &data_info,
				   vector<miri_refoutput> &refoutput)
{

  int naxis = 3;
  long naxes[3];
  naxes[0] = data_info.raw_naxes[0];
  naxes[1] = data_info.raw_naxes[1];
  naxes[2] = data_info.raw_naxes[2];
  int ramp_start = control.n_reads_start_fit;
  long inc[3]={1,1,1};
  int anynul = 0;  // null values
  int status = 0;
  long fpixel[3] ;
  long lpixel[3];

  int xsize = data_info.ref_naxes[0]; 
  int xsizefull = data_info.raw_naxes[0];
  int istart = iter*data_info.NRamps + ramp_start;

  // for each frame - read the entire reference output
  
  for(int i =0;i<data_info.NRampsRead;i++){

    fpixel[0]=1;
    lpixel[0] = xsizefull ;


    fpixel[1]= data_info.ref_naxes[1] + 1;
    lpixel[1] = data_info.raw_naxes[1] ;

    fpixel[2]=istart +i+1;
    lpixel[2]=istart +i+1;    

    long ixyz =data_info.ref_naxes[0] * data_info.ref_naxes[1];
    
    cout << " reading in reference output " << endl;
    cout << " reading in reference output " << fpixel[0] << " " << lpixel[0] << endl;
    cout << " reading in reference output " << fpixel[1] << " " << lpixel[1] << endl;
    

    vector<int>  data(ixyz);

    status = 0;
    fits_read_subset_int(data_info.raw_file_ptr, 0, naxis, naxes, 
			 fpixel,lpixel,
			 inc,0, 
			 &data[0], &anynul, &status);
    if(status != 0) {
      cout << " Problem reading reference output " << endl;
      cout << " status " << status << endl;
      exit(-1);
    }


    int nr = data_info.raw_naxes[1] - data_info.ref_naxes[1];

    //_______________________________________________________________________
    // pull out reference output from image (4 rows folded into 1 row)
    int ik = 0;
    int irow = 0;
    // reformat the reference output and store the variables in rouput. 

    //    float routput[258][1024];
    float routput[data_info.ref_naxes[0]][data_info.ref_naxes[1]];
 
    for ( int k = 0; k < nr ; k++){ // loop over rows
      for (register int p =0 ; p< 4; p++){ // there are 4 reference rows/row

	for (register int j = 0; j< xsize ; j++){
	  routput[j][irow] =  data[ik];
	  
	  ik++;
	} // end j to xsize
	irow++;
      } // end loop over p or 4 rows
    } // loop over row (k)
    //_______________________________________________________________________
    // initialize refoutput row variables to zero


    refoutput[i].InitializeLine(data_info.ref_naxes[1]) ;
    
    //_______________________________________________________________________
    // removing median of each column from data 
    if(control.do_refoutput_median_column) {
      for (int j = 0; j< xsize; j++){ // loop over rows
	vector <float> median;
	float MedianValue;
	for (int k = 0; k < data_info.ref_naxes[1]; k++){ // push the col values in
                                                    // vector median
	  median.push_back(routput[j][k]);
	}
	FindMedian(median,MedianValue);          // for each col find the median
	//cout << MedianValue << " " << j << endl;
	for (int k = 0; k < data_info.ref_naxes[1]; k++){
	  routput[j][k] = routput[j][k] - MedianValue;  // subtract median from
	                                                // each pixel in the col
	}
      }
    }



    // Loop over the rows with the row data make a linear fit - store slope, yintercept
    for (int k = 0; k < data_info.ref_naxes[1]; k++){
      vector<float> rowdata;

      // push row values into vector rowdata
      for (register int j = 0; j< xsize ; j++)rowdata.push_back( routput[j][k]); 
   

      float slope = 0.0;
      float yintercept = 0.0;
      int flag = 0;
      linfit(rowdata,slope,yintercept, flag);
      refoutput[i].SetSlope(k,slope);
      refoutput[i].SetYintercept(k,yintercept);


    }// end looping over k (nrows)

  } // end looping over frames

}
