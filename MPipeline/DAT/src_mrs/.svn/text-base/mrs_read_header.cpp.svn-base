// mrs_read_header.cpp
#include <iostream>
#include <string>
#include "fitsio.h"
#include "mrs_CubeHeader.h"
#include "mrs_ReducedHeader.h"
#include "mrs_control.h"


// program to parse the raw data file and determine the details of how the data
// was taken.  
// Keywords needed which describe the MRS data for Cube building
// SCA_ID : 1 (channel 1 and 2), 2 (channel 3 and 4)
// Get the size of the data

int mrs_read_header(ReducedHeader ReducedHead[],
		    CubeHeader &cubeHead, const mrs_control control)

{

  // **********************************************************************
    // open the data file and get various useful bits of info from the header

  // 

  int nfiles = cubeHead.GetNumFiles();

  int Channel = cubeHead.GetChannel();
  int SubChannel = cubeHead.GetSubChannel();

  

  for(int ij = 0; ij < nfiles ; ij++){
    string filename = cubeHead.GetInputFilename(ij);
    int extension_num = cubeHead.GetExtensionNum(ij);


    fitsfile *file_ptr;
    ReducedHead[ij].SetFileName(filename);
    
    int status = 0;   
    fits_open_file(&file_ptr,filename.c_str(), READONLY, &status);   // open the file
    if(status !=0) {
      cout << " Failed to open fits file: " << filename << endl;
      cout << " Reason for failure, status = " << status << endl;
      exit(EXIT_FAILURE);
    }

    char comment[72];
    status = 0;
    // get the size of the data 
    int naxis =0;
    int hdutype = 0;
    fits_movabs_hdu(file_ptr,1,&hdutype,&status);
    int nint;
    fits_read_key(file_ptr, TLONG, "NPINT", &nint, comment, &status); 
    if(status !=0 ){
      cout << "mrs_read_header:  Problem reading NPINT " << status << endl;
      cout << "      filename : " << filename << endl;
      cout << "       ext #   : " << extension_num << endl;
    }

    //cout << "extension_num nint " << extension_num << " " << nint << endl;

    if(extension_num-1 > nint){
      cout << " Requested integration " << extension_num-1 <<  " is beyond extension number " << nint <<  endl;
      exit(EXIT_FAILURE);
    }

    status = 0; 
    int nsample = 10;  //  1 for fast, 10 for slow
    fits_read_key(file_ptr, TINT, "NSAMPLE", &nsample, comment, &status); 
    if(status !=0 ){
      status = 0;
      fits_read_key(file_ptr, TINT, "NSAMPLES", &nsample, comment, &status); 

      if(status !=0 ){
	cout << " Information: mrs_read_header:  Could not find NSAMPLE or NSAMPLES in the header " << status << endl;
	cout << "      filename : " << filename << endl;
	cout << "       ext #   : " << extension_num << endl;
	cout << " setting NSAMPLE to 10" << endl;
      }
    }


    fits_movabs_hdu(file_ptr,extension_num,&hdutype,&status);
    fits_read_key(file_ptr, TLONG, "NAXIS", &naxis, comment, &status); 
    if(status !=0 ) cout << "mrs_read_header:  Problem reading NAXIS " << endl;
    
    long naxes[3]={0};
    fits_read_key(file_ptr, TLONG, "NAXIS1", &naxes[0], comment, &status); 
    if(status !=0 ) {
      cout << "mrs_read_header:  Problem reading NAXIS1 " << status << endl;
      cout << "      filename : " << filename << endl;
      cout << "       ext #   : " << extension_num << endl;
    }
    fits_read_key(file_ptr, TLONG, "NAXIS2", &naxes[1], comment, &status); 
    if(status !=0 ){
      cout << "mrs_read_header:  Problem reading NAXIS2 " << status << endl;
      cout << "      filename : " << filename << endl;
      cout << "       ext #   : " << extension_num << endl;
    }

    fits_read_key(file_ptr, TLONG, "NAXIS3", &naxes[2], comment, &status); 
    if(status !=0 ){
      cout << "mrs_read_header:  Problem reading NAXIS3 " << status << endl;
      cout << "      filename : " << filename << endl;
      cout << "       ext #   : " << extension_num << endl;
    }




    ReducedHead[ij].SetNSample(nsample);
    ReducedHead[ij].SetNaxis(naxis);
    ReducedHead[ij].SetNaxes0(naxes[0]);
    ReducedHead[ij].SetNaxes1(naxes[1]);
    ReducedHead[ij].SetNaxes2(naxes[2]);


    ReducedHead[ij].SetChannel(Channel);
    ReducedHead[ij].SetSubChannel(SubChannel);
  }

  // **********************************************************************
    return 0; // ifstream destructor closes the file
  

}














