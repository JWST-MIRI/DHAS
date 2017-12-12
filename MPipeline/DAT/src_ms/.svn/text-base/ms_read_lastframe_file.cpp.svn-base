// This software is part of the MIRI Data Handling and Analysis Software (DHAS)
// This routine belongs to the miri_sloper package which processes raw science data.
// 
// Name:
//   ms_read_lastframe_file.cpp
//
// Purpose:
// Read in last frame correction coefficients
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
//int ms_read_lastframe_file(miri_control &control,
//                           miri_data_info &data_info, 
//		             miri_CDP &CDP)
//
//
// Arugments:
//

//  data_info: miri_data_info structure containing basic information on the dataset
//  control: structure that holds parameters on running pipeline
//  CDP - holds the name of the bad pixel mask and the mask 
//
//
// Return Value/ Variables modified:
//     status = 0, no problems encountered.
//     status not equal 0 then an error was encountered.  
// 
//
// History:
//
//	Written by Jane Morrison 2016


#include <iostream>
#include <sstream> 
#include <vector>
#include <string>
#include <cstdlib>
#include <algorithm>
#include "fitsio.h"
#include "miri_CDP.h"
#include "miri_data_info.h"
#include "miri_sloper.h"


using namespace std;
// ----------------------------------------------------------------------
// Helper procedure

void ms_lastframe_readtable(fitsfile *fptr, string name,const int num_elements, const int nrows, string col_name[], 
		       int col_num[], vector<float> &col,int &lstatus){
  int anynul = 0;
  float fnull = 0;
  lstatus = 1;
  int found = 0;
  int ifound = 0; 

  int i = 0;
  while(i < num_elements && found ==0) {
    if (name == col_name[i]) {
      found = 1;
      ifound = i;
    }
    i++;
  }

  if(found ==1) {
    int status = 0;
    int colnum = col_num[ifound]; // read in Tau1

    fits_read_col(fptr,TFLOAT,colnum,1L,1L,
		  nrows,
		  &fnull,&col[0],
		  &anynul,&status);
  } else{
    lstatus = 0;
  }
}

// ----------------------------------------------------------------------
void ms_lastframe_readtable(fitsfile *fptr, string name,const int num_elements, const int nrows, string col_name[], 
		       int col_num[], vector<string> &col,int &lstatus){
  int anynul = 0;

  char null[] = "NULL";
  lstatus = 1;
  int found = 0;
  int ifound = 0; 
  int i = 0;
  while(i < num_elements && found ==0) {
    if (name == col_name[i]) {
      found = 1;
      ifound = i;
    }
    i++;
  }

  if(found ==1) {
    int status = 0;
    int colnum = col_num[ifound]; // read in Tau1
    string col_string;

    char *sub[nrows];
    for (int ii = 0; ii< nrows;ii++){
      sub[ii] = (char *) malloc(15);
    }

    fits_read_col(fptr,TSTRING,colnum,1L,1L,
     		  nrows,
     		  null,sub,
    		  &anynul,&status);

    
    for (int ii=0;ii< nrows; ii++){
      col[ii] = sub[ii];
    }
  } else{
  
    lstatus = 0;
  }
}
//


//________________________________________________________________________________

int ms_read_lastframe_file(miri_control &control,
			   miri_data_info &data_info, 
			   miri_CDP &CDP)
{
  int status = 0;

  string lastframe_file = "null";

  if(control.flag_lastframe_file ==1) { // user proved file
    lastframe_file = control.lastframe_file;
  }
  if(control.flag_lastframe_file == 0){ // not set by the user
    control.lastframe_file = CDP.GetLastFrameName();
    lastframe_file =  control.calib_dir+ control.lastframe_file;   
  }

  cout << " Reading in lastfile file " << lastframe_file << endl;

  string subarray;
  string readpatt;
  // Figure out what type of data we have

  // Mode to use is Fast mode
  if(data_info.Mode == 0 && data_info.subarray_mode ==0 ) { 
    subarray = "FULL";
    readpatt = "FAST";
  }

  // Mode to use is Slow  mode
  if( data_info.Mode == 1 && data_info.subarray_mode ==0) { 
    subarray= "FULL";
    readpatt= "SLOW";
  }

  if(data_info.subarray_mode !=0) {
    readpatt ="FAST";
    cout << " Setting  Subarray for lastframe " << endl;
    // below method does not work for lastframe because the CAL file does not contain
    // a header to match it with. So for now just set to first subarray in table
    // all the values in the table are the same so it does not matter right now.


    subarray = "BRIGHTSKY";
    status = 0;
    if(status !=0) { 
      cout << "Subarray lastframe not found " << endl;
      cout << " The Calibration directory could be incorrect or you do not have the dark subarray " << endl;
      cout << " To continue you can remove subtracting the dark with the -D option " << endl;
      exit(EXIT_FAILURE);
    }
  }// end searching over subarray
  
  fitsfile *fptr;
  int hdutype = 0 ; 
  fits_open_file(&fptr,lastframe_file.c_str(),READONLY,&status);
  if(status != 0 ) {
    cout << " Problem opening lastframe  file " << lastframe_file << " " << status << endl;
    cout << " Run again and either correct LastFrame filename or run with -l option (no last frame correction)" << endl;

    exit(EXIT_FAILURE);
    status = 1;
    
  } else {

    fits_movabs_hdu(fptr,2,&hdutype,&status); // for to first extension  
    long nrows=0;
    int ncols=0;
    status = fits_get_num_rows(fptr,&nrows,&status);
    status = fits_get_num_cols(fptr,&ncols,&status);

    //    cout << "number of rows and cols in lastframe table" << nrows <<" " << ncols << endl;

    string col_name[] = {"SUBARRAY","READPATT","ROWS","CHANNEL","A","B"};
    int col_num[] = {0,0,0,0,0,0};

    int num_elements = sizeof(col_name)/sizeof(col_name[0]);

    char comment[72];

    for (int i = 0; i< ncols;i++){


      string coln;             // string which will contain the column number
      ostringstream convert;   // stream used for the conversion
      convert << (i+1);        // insert the textual representation of 'i+1' in the characters in the stream
      coln = convert.str();    // set 'coln' to the contents of the stream 

      string name = "TTYPE" + coln;


      status = 0; 

      char keyname[FLEN_VALUE];
      const char* cname = name.c_str();
      fits_read_key(fptr, TSTRING, cname, &keyname, comment, &status); 
      if(status !=0 ) cout << "ms_read_lastframe:  Problem reading lastframe file " <<  name << endl;

      //convert keyname char to string
      string skeyname(keyname);

      for (int k = 0; k<num_elements;k++){
	if(skeyname == col_name[k]){
	  col_num[k] = i+1;
	  //cout << "found match " << keyname << " " << col_name[k]<< " " << "col = " <<  col_num[k]  << endl;
	}
      }
     

    }


    string name_search = "A";
    vector<float> A(nrows);
    status = 0; 
    ms_lastframe_readtable(fptr, name_search,num_elements,nrows, col_name,col_num,A,status);

    
    vector<float> B(nrows);
    name_search= "B";
    
    status = 0; 
    ms_lastframe_readtable(fptr, name_search,num_elements,nrows, col_name,col_num,B,status);

    vector<string> rowtype(nrows);
    name_search = "ROWS";
    
    status = 0; 
    ms_lastframe_readtable(fptr,name_search,num_elements,nrows, col_name,col_num,rowtype,status);

    vector<string> readpatt_table(nrows);
    name_search = "READPATT";
    
    status = 0; 
    ms_lastframe_readtable(fptr,name_search,num_elements,nrows, col_name,col_num,readpatt_table,status);


    vector<string> subarray_table(nrows);
    name_search = "SUBARRAY";
    
    status = 0; 
    ms_lastframe_readtable(fptr,name_search,num_elements,nrows, col_name,col_num,subarray_table,status);

    vector<string> channel_table(nrows);
    name_search = "CHANNEL";
    
    status = 0; 
    ms_lastframe_readtable(fptr,name_search,num_elements,nrows, col_name,col_num,channel_table,status);

    //    for(int i = 0 ; i< A.size(); i++){
    // cout << "" << readpatt_table[i] << " " << subarray_table[i] << " " << rowtype[i] << " " <<
    //	channel_table[i] <<  " " << A[i] << " " << B[i] <<  endl;
    //}

    fits_close_file(fptr,&status);


    // First loop over CHANNEL #
    // Second loop over EVEN or ODD ROW
    vector<string> CHNUM(4);
    CHNUM[0] = "CH1";
    CHNUM[1] = "CH2";
    CHNUM[2] = "CH3";
    CHNUM[3] = "CH4";
    
    CDP.InitializeLastFrameCoeff();

    for (int ic = 0; ic <4 ; ic++) {

      string channel = CHNUM[ic];

      int ifound_even = -1;      
      string even = "EVEN";
    // find the row for the channel, readpatt and subarray that Exposure is for
      for (int i = 0 ;i < nrows; i++){
	int ifound_sub = -1;
	int ifound_read = -1;
	int ifound_row = -1;
	int ifound_ch = -1;

      //compare subarray_table to subarray
	ifound_sub = subarray.compare(subarray_table[i]);
	ifound_read = readpatt.compare(readpatt_table[i]);
	ifound_row = even.compare(rowtype[i]);
	ifound_ch  = channel.compare(channel_table[i]);

	if(ifound_sub == 0 && ifound_read ==0 && ifound_row == 0  && ifound_ch == 0 ) ifound_even = i ;
      } // done looping over rows for Channel & even 

      //      cout << " For channel, row that matches even " << ic+1 << " " <<  ifound_even << endl;

      int ifound_odd = -1;      
      string odd = "ODD";
      // find the row for the readpatt and subarray that Exposure is for
      for (int i = 0 ;i < nrows; i++){
	int ifound_sub = -1;
	int ifound_read = -1;
	int ifound_row = -1;
	int ifound_ch = -1;

	//compare subarray_table to subarray
	ifound_sub = subarray.compare(subarray_table[i]);
	ifound_read = readpatt.compare(readpatt_table[i]);
	ifound_row = odd.compare(rowtype[i]);
	ifound_ch  = channel.compare(channel_table[i]);
	if(ifound_sub == 0 && ifound_read ==0 && ifound_row == 0 && ifound_ch ==0 ) ifound_odd = i ;
      } // Done looping over rows for Channel and odd 
      
      //      cout << " For channel, row that matches odd " <<  ic+1 << " " << ifound_odd << endl;

      if(ifound_odd != -1 && ifound_even !=-1) {
	CDP.SetLastFrameParameters(ic, A[ifound_even],B[ifound_even],
				   A[ifound_odd],B[ifound_odd]);

	//cout << "Channel, LastFrame parameters Even: " << ic+1 << " "  << A[ifound_even] << " " << B[ifound_even]
	//   << " " << A[ifound_even] << " " << B[ifound_even] << endl;

	//cout << "Channel, LastFrame parameters Odd:  " << ic+1 << " "  << A[ifound_odd] << " " << B[ifound_odd]
	//   << " " << A[ifound_odd] << " " << B[ifound_odd] << endl;
      } else{

	cout << " Could not find the correct row in the LastFrame table " << endl;
	cout << " Turning off apply lastframe correction " << endl;
	control.apply_lastframe_cor = 0;
      }
    }



    //_______________________________________________________________________

    
  }


  return status;
}




