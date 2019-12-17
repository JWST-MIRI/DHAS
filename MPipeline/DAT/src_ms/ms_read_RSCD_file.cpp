#include <string>
#include <string.h>
#include "miri_sloper.h"
using namespace std;
// ----------------------------------------------------------------------
// Helper procedure


void ms_RSCD_readtable(fitsfile *fptr, string name,const int num_elements, const int nrows, string col_name[], 
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
    int colnum = col_num[ifound];

    fits_read_col(fptr,TFLOAT,colnum,1L,1L,
		  nrows,
		  &fnull,&col[0],
		  &anynul,&status);
  } else{
    lstatus = 0;
  }
}


// ----------------------------------------------------------------------
void ms_RSCD_readtable(fitsfile *fptr, string name,const int num_elements, const int nrows, string col_name[], 
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
    int colnum = col_num[ifound]; 
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



// This software is part of the MIRI Data Handling and Analysis Software (DHAS)
// This routine belongs to the miri_sloper package which processes raw science data.

// Name:
//   ms_read_RSCD_file.cpp
//
// Purpose:
// Option to apply the RSCD correction is set
// Read in the file and find the correct entry in the table for the data
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
//int ms_read_RSCD_file(miri_data_info &data_info, 
//		      miri_control &control,
//		      miri_CDP &CDP)
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
// Created 01/03/16

#include <iostream>
#include <sstream> 
#include <vector>
#include <string>
#include <cstdlib>
#include <algorithm>
#include "fitsio.h"
#include "miri_CDP.h"
#include "miri_rscd.h"
#include "miri_data_info.h"
#include "miri_sloper.h"

int ms_read_RSCD_file(miri_data_info &data_info, 
		      miri_control &control,
		      miri_CDP &CDP,
		      miri_rscd &RSCD)
{
  int status = 0;

  string RSCD_file = "null";
  if(control.flag_rscd_cor_file ==1) { // user proved file
    RSCD_file = control.rscd_cor_file;
  }
  if(control.flag_rscd_cor_file == 0){ // not set by the user               
    control.rscd_cor_file = CDP.GetRSCDName();
    RSCD_file =  control.calib_dir+ control.rscd_cor_file;   
  }

  string subarray;
  string readpatt;
  // Figure out what type of data we have

  // RSCD to use is Fast mode
  if(data_info.Mode == 0 && data_info.subarray_mode ==0 ) { 
    subarray = "FULL";
    readpatt = "FAST";
  }

  // RSCD to use is Slow  mode
  if( data_info.Mode == 1 && data_info.subarray_mode ==0) { 
    subarray= "FULL";
    readpatt= "SLOW";
  }

  if(data_info.subarray_mode !=0) {
    readpatt ="FAST";
    //cout << " Setting RSCD Subarray " << endl;
    // below method does not work for RSCD because the CAL file does not contain
    // a header to match it with. So for now just set to first subarray in table
    // all the values in the table are the same so it does not matter right now.
    //int status = ms_determine_CAL_Subarray(0,data_info,control,CDP); 

    subarray = "BRIGHTSKY";
    status = 0;
    if(status !=0) { 
      cout << "Subarray rscd not found " << endl;
      cout << " The Calibration directory co ldark subarray " << endl;
      cout << " To continue you can remove -rd option " << endl;
      exit(EXIT_FAILURE);
    }
  }// end searching over subarray
  
  fitsfile *fptr;
  int hdutype = 0 ; 
  fits_open_file(&fptr,RSCD_file.c_str(),READONLY,&status);

  if(status != 0 ) {
    cout << " Problem opening RSCD  file " << RSCD_file << " " << status << endl;
    cout << " Run again and either correct RSCD filename or run with -rd option (no RSCD correction)" << endl;

    exit(EXIT_FAILURE);
    status = 1;
    
  } else {

    // Read 1st extension - General Values
    fits_movabs_hdu(fptr,2,&hdutype,&status); // General Values (lower cutoff, alpha_even,alpha_odd) 
    long nrows=0;
    int ncols=0;
    status = fits_get_num_rows(fptr,&nrows,&status);
    status = fits_get_num_cols(fptr,&ncols,&status);
    cout << " Reading RSCD file" << RSCD_file << endl;

    //cout << "number of rows and cols in RSCD table RSCD_GEN " << nrows <<" " << ncols << endl;

    string col_name[] = {"SUBARRAY","READPATT","LOWER_CUTOFF","ALPHA_EVEN", "ALPHA_ODD"};
    int col_num[] = {0,0,0,0,0};
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
      if(status !=0 ) cout << "ms_read_RSCD:  Problem reading " <<  name << endl;

      //convert keyname char to string
      string skeyname(keyname);

      for (int k = 0; k<num_elements;k++){
	if(skeyname == col_name[k]){
	  col_num[k] = i+1;
	  // cout << "found match " << keyname << " " << col_name[k]<< " " << "col = " <<  col_num[k] << " "   << k << endl;
	}
      }
    }

    vector<string> readpatt_table(nrows);
    string name_search = "READPATT";    
    status = 0; 
    ms_RSCD_readtable(fptr,name_search,num_elements,nrows, col_name,col_num,readpatt_table,status);

    vector<string> subarray_table(nrows);
    name_search = "SUBARRAY";
    status = 0; 
    ms_RSCD_readtable(fptr,name_search,num_elements,nrows, col_name,col_num,subarray_table,status);

    vector<float> lower_cutoff(nrows);
    name_search = "LOWER_CUTOFF";
    status = 0; 
    ms_RSCD_readtable(fptr, name_search,num_elements,nrows, col_name,col_num,lower_cutoff,status);

    vector<float> alpha_even(nrows);
    name_search= "ALPHA_EVEN";
    status = 0; 
    ms_RSCD_readtable(fptr, name_search,num_elements,nrows, col_name,col_num,alpha_even,status);
    
    vector<float> alpha_odd(nrows);
    name_search= "ALPHA_ODD";
    status = 0; 
    ms_RSCD_readtable(fptr, name_search,num_elements,nrows, col_name,col_num,alpha_odd,status);


    int ifound = -1;      
    // find the row for the readpatt and subarray that Exposure is for
    for (int i = 0 ;i < nrows; i++){
      int ifound_sub = -1;
      int ifound_read = -1;
      ifound_sub = subarray.compare(subarray_table[i]);
      ifound_read = readpatt.compare(readpatt_table[i]);
      if(ifound_sub == 0 && ifound_read ==0 ) ifound = i ;
    }

    if(ifound != -1) {
      RSCD.SetParametersGen(lower_cutoff[ifound],alpha_even[ifound],alpha_odd[ifound]);
      //cout << "RSCD parameters Gen: "<< lower_cutoff[ifound] << " " << alpha_even[ifound]
      //	   << " " << alpha_odd[ifound] <<  endl; 
    } else{
      cout << " Could not find the correct row in the RSCD table " << endl;
      cout << " searching for " << subarray << " " << readpatt << " " << 
      cout << " Turning off apply rscd correction " << endl;
      control.apply_rscd_cor = 0;
    }

    //______________________________________________________________________
    // Read  Second extension - First integration
    status = 0;
    fits_movabs_hdu(fptr,3,&hdutype,&status); 
    nrows=0;
    ncols=0;
    status = 0;
    
    status = fits_get_num_rows(fptr,&nrows,&status);
    status = 0;
    status = fits_get_num_cols(fptr,&ncols,&status);
    //cout << " first int numbers " << ncols << " " << nrows << endl;
    string col_name2[] = {"SUBARRAY","READPATT","ROWS","A0", "A1", "A2", "A3"};
    int col_num2[] = {0,0,0,0,0,0,0};

    num_elements = sizeof(col_name2)/sizeof(col_name2[0]);
    for (int i = 0; i< ncols;i++){
      string coln;             // string which will contain the column number
      ostringstream convert;   // stream used for the conversion
      convert << (i+1);        // insert the textual representation of 'i+1' in the characters in the stream
      coln = convert.str();    // set 'coln' to the contents of the stream 

      string name = "TTYPE" + coln;
      status = 0; 

      char keyname[FLEN_VALUE];
      const char* cname = name.c_str();
      status = 0;
      fits_read_key(fptr, TSTRING, cname, &keyname, comment, &status); 
      
      if(status !=0 ) cout << "ms_read_RSCD:  Problem reading " <<  name << endl;

      //convert keyname char to string
      string skeyname(keyname);

      for (int k = 0; k<num_elements;k++){
	if(skeyname == col_name2[k]){
	  col_num2[k] = i+1;
	  //cout << "found match " << keyname << " " << col_name2[k]<< " " << "col = " <<  col_num2[k] << " "   << k << endl;
	}
      }
    }vector<string> rowtype2(nrows);
    name_search = "ROWS";    
    status = 0; 
    ms_RSCD_readtable(fptr,name_search,num_elements,nrows, col_name2,col_num2,rowtype2,status);

    vector<string> readpatt_table2(nrows);
    name_search = "READPATT";    
    status = 0; 
    ms_RSCD_readtable(fptr,name_search,num_elements,nrows, col_name2,col_num2,readpatt_table2,status);

    vector<string> subarray_table2(nrows);
    name_search = "SUBARRAY";
    status = 0; 
    ms_RSCD_readtable(fptr,name_search,num_elements,nrows, col_name2,col_num2,subarray_table2,status);

    vector<float> a0_1(nrows);
    name_search = "A0";
    status = 0; 
    ms_RSCD_readtable(fptr, name_search,num_elements,nrows, col_name2,col_num2,a0_1,status);

    vector<float> a1_1(nrows);
    name_search= "A1";
    status = 0; 
    ms_RSCD_readtable(fptr, name_search,num_elements,nrows, col_name2,col_num2,a1_1,status);
    
    vector<float> a2_1(nrows);
    name_search= "A2";
    status = 0; 
    ms_RSCD_readtable(fptr, name_search,num_elements,nrows, col_name2,col_num2,a2_1,status);

    vector<float> a3_1(nrows);
    name_search= "A3";
    status = 0; 
    ms_RSCD_readtable(fptr, name_search,num_elements,nrows, col_name2,col_num2,a3_1,status);

    int ifound_even = -1;      
    string even = "EVEN";
    // find the row for the readpatt and subarray that Exposure is for
    for (int i = 0 ;i < nrows; i++){
      int ifound_sub = -1;
      int ifound_read = -1;
      int ifound_row = -1;

      //compare subarray_table to subarray
      ifound_sub = subarray.compare(subarray_table2[i]);
      ifound_read = readpatt.compare(readpatt_table2[i]);
      ifound_row = even.compare(rowtype2[i]);
      if(ifound_sub == 0 && ifound_read ==0 && ifound_row == 0 ) ifound_even = i ;
    }

    int ifound_odd = -1;      
    string odd = "ODD";
    // find the row for the readpatt and subarray that Exposure is for
    for (int i = 0 ;i < nrows; i++){
      int ifound_sub = -1;
      int ifound_read = -1;
      int ifound_row = -1;

      //compare subarray_table to subarray
      ifound_sub = subarray.compare(subarray_table2[i]);
      ifound_read = readpatt.compare(readpatt_table2[i]);
      ifound_row = odd.compare(rowtype2[i]);
      if(ifound_sub == 0 && ifound_read ==0 && ifound_row == 0 ) ifound_odd = i ;
    }

    if(ifound_odd != -1 && ifound_even !=-1) {
      RSCD.SetParameters(a0_1[ifound_even],a1_1[ifound_even],a2_1[ifound_even],
			     a3_1[ifound_even],
			     a0_1[ifound_odd],a1_1[ifound_odd],a2_1[ifound_odd],
			     a3_1[ifound_odd]);

      //cout << "RSCD Int 1 parameters even : "<< a0_1[ifound_even] << " " << a1_1[ifound_even]
      //	   << " " << a2_1[ifound_even] << " " << a3_1[ifound_even]  << endl; 

      //cout << "RSCD Int 1 parameters odd : "<< a0_1[ifound_odd] << " " << a1_1[ifound_odd]
      //   << " " << a2_1[ifound_odd] << " " << a3_1[ifound_odd]  << endl;
	   
    } else{
      cout << " Could not find the correct row in the RSCD table " << endl;
      cout << " Turning off apply rscd correction " << endl;
      control.apply_rscd_cor = 0;
    }
    //_______________________________________________________________________

    // Read  third extension - 2nd integration
    status = 0;
    fits_movabs_hdu(fptr,4,&hdutype,&status); 
    nrows=0;
    ncols=0;
    status = 0;
    status = fits_get_num_rows(fptr,&nrows,&status);
    status = fits_get_num_cols(fptr,&ncols,&status);
    status   = 0;

    string col_name3[] = {"SUBARRAY","READPATT","ROWS","B0", "B1", "B2", "B3"};
    int col_num3[] = {0,0,0,0,0,0,0};

    num_elements = sizeof(col_name3)/sizeof(col_name3[0]);

    for (int i = 0; i< ncols;i++){

      string coln;             // string which will contain the column number
      ostringstream convert;   // stream used for the conversion
      convert << (i+1);        // insert the textual representation of 'i+1' in the characters in the stream
      coln = convert.str();    // set 'coln' to the contents of the stream 

      string name = "TTYPE" + coln;
      status = 0; 

      char keyname[FLEN_VALUE];
      const char* cname = name.c_str();
      status = 0;
      fits_read_key(fptr, TSTRING, cname, &keyname, comment, &status); 
      if(status !=0 ) cout << "ms_read_RSCD:  Problem reading " <<  name << endl;

      //convert keyname char to string
      string skeyname(keyname);

      for (int k = 0; k<num_elements;k++){
	if(skeyname == col_name3[k]){
	  col_num3[k] = i+1;
	}
      }
    }vector<string> rowtype3(nrows);
    name_search = "ROWS";    
    status = 0; 
    ms_RSCD_readtable(fptr,name_search,num_elements,nrows, col_name3,col_num3,rowtype3,status);

    vector<string> readpatt_table3(nrows);
    name_search = "READPATT";    
    status = 0; 
    ms_RSCD_readtable(fptr,name_search,num_elements,nrows, col_name3,col_num3,readpatt_table3,status);


    vector<string> subarray_table3(nrows);
    name_search = "SUBARRAY";
    status = 0; 
    ms_RSCD_readtable(fptr,name_search,num_elements,nrows, col_name3,col_num3,subarray_table3,status);

    vector<float> a0_2(nrows);
    name_search = "B0";
    status = 0; 
    ms_RSCD_readtable(fptr, name_search,num_elements,nrows, col_name3,col_num3,a0_2,status);

    vector<float> a1_2(nrows);
    name_search= "B1";
    status = 0; 
    ms_RSCD_readtable(fptr, name_search,num_elements,nrows, col_name3,col_num3,a1_2,status);
    
    vector<float> a2_2(nrows);
    name_search= "B2";
    status = 0; 
    ms_RSCD_readtable(fptr, name_search,num_elements,nrows, col_name3,col_num3,a2_2,status);

    vector<float> a3_2(nrows);
    name_search= "B3";
    status = 0; 
    ms_RSCD_readtable(fptr, name_search,num_elements,nrows, col_name3,col_num3,a3_2,status);

    ifound_even = -1;      
    // find the row for the readpatt and subarray that Exposure is for
    for (int i = 0 ;i < nrows; i++){
      int ifound_sub = -1;
      int ifound_read = -1;
      int ifound_row = -1;

      //compare subarray_table to subarray
      ifound_sub = subarray.compare(subarray_table3[i]);
      ifound_read = readpatt.compare(readpatt_table3[i]);
      ifound_row = even.compare(rowtype3[i]);
      if(ifound_sub == 0 && ifound_read ==0 && ifound_row == 0 ) ifound_even = i ;
    }

    ifound_odd = -1;      
    // find the row for the readpatt and subarray that Exposure is for
    for (int i = 0 ;i < nrows; i++){
      int ifound_sub = -1;
      int ifound_read = -1;
      int ifound_row = -1;

      //compare subarray_table to subarray
      ifound_sub = subarray.compare(subarray_table3[i]);
      ifound_read = readpatt.compare(readpatt_table3[i]);
      ifound_row = odd.compare(rowtype3[i]);
      if(ifound_sub == 0 && ifound_read ==0 && ifound_row == 0 ) ifound_odd = i ;
    }

    if(ifound_odd != -1 && ifound_even !=-1) {
      RSCD.SetParameters(a0_2[ifound_even],a1_2[ifound_even],a2_2[ifound_even],
			 a3_2[ifound_even],
			 a0_2[ifound_odd],a1_2[ifound_odd],a2_2[ifound_odd],
			 a3_2[ifound_odd]);

      //cout << "RSCD Int 2 parameters even : "<< a0_2[ifound_even] << " " << a1_2[ifound_even]
      //	   << " " << a2_2[ifound_even] << " " << a3_2[ifound_even]  << endl; 

      //cout << "RSCD Int 2 parameters odd : "<< a0_2[ifound_odd] << " " << a1_2[ifound_odd]
      //   << " " << a2_2[ifound_odd] << " " << a3_2[ifound_odd]  << endl;
	   
    } else{
      cout << " Could not find the correct row in the RSCD table " << endl;
      cout << " Turning off apply rscd correction " << endl;
      control.apply_rscd_cor = 0;
    }

    //______________________________________________________________________
    // Read  third extension - 2rd integration

    status = 0;
    fits_movabs_hdu(fptr,5,&hdutype,&status); 
    nrows=0;
    ncols=0;
    status = 0;
    status = fits_get_num_rows(fptr,&nrows,&status);
    status = 0;
    status = fits_get_num_cols(fptr,&ncols,&status);

    string col_name4[] = {"SUBARRAY","READPATT","ROWS","C0", "C1", "C2", "C3"};
    int col_num4[] = {0,0,0,0,0,0,0};

    num_elements = sizeof(col_name4)/sizeof(col_name4[0]);

    for (int i = 0; i< ncols;i++){

      string coln;             // string which will contain the column number
      ostringstream convert;   // stream used for the conversion
      convert << (i+1);        // insert the textual representation of 'i+1' in the characters in the stream
      coln = convert.str();    // set 'coln' to the contents of the stream 

      string name = "TTYPE" + coln;
      status = 0; 

      char keyname[FLEN_VALUE];
      const char* cname = name.c_str();
      status = 0;
      fits_read_key(fptr, TSTRING, cname, &keyname, comment, &status); 
      if(status !=0 ) cout << "ms_read_RSCD:  Problem reading " <<  name << endl;

      //convert keyname char to string
      string skeyname(keyname);
      for (int k = 0; k<num_elements;k++){
	if(skeyname == col_name4[k]){
	  col_num4[k] = i+1;
	  //	  cout << "found match " << keyname << " " << col_name4[k]<< " " << "col = " <<  col_num4[k] << " "   << k << endl;
	}
      }
    }vector<string> rowtype4(nrows);
    name_search = "ROWS";    
    status = 0; 
    ms_RSCD_readtable(fptr,name_search,num_elements,nrows, col_name4,col_num4,rowtype4,status);

    vector<string> readpatt_table4(nrows);
    name_search = "READPATT";    
    status = 0; 
    ms_RSCD_readtable(fptr,name_search,num_elements,nrows, col_name4,col_num4,readpatt_table4,status);


    vector<string> subarray_table4(nrows);
    name_search = "SUBARRAY";
    status = 0; 
    ms_RSCD_readtable(fptr,name_search,num_elements,nrows, col_name4,col_num4,subarray_table4,status);

    vector<float> a0_3(nrows);
    name_search = "C0";
    status = 0; 
    ms_RSCD_readtable(fptr, name_search,num_elements,nrows, col_name4,col_num4,a0_3,status);

    vector<float> a1_3(nrows);
    name_search= "C1";
    status = 0; 
    ms_RSCD_readtable(fptr, name_search,num_elements,nrows, col_name4,col_num4,a1_3,status);
    
    vector<float> a2_3(nrows);
    name_search= "C2";
    status = 0; 
    ms_RSCD_readtable(fptr, name_search,num_elements,nrows, col_name4,col_num4,a2_3,status);

    vector<float> a3_3(nrows);
    name_search= "C3";
    status = 0; 
    ms_RSCD_readtable(fptr, name_search,num_elements,nrows, col_name4,col_num4,a3_3,status);

    ifound_even = -1;      

    // find the row for the readpatt and subarray that Exposure is for
    for (int i = 0 ;i < nrows; i++){
      int ifound_sub = -1;
      int ifound_read = -1;
      int ifound_row = -1;

      //compare subarray_table to subarray
      ifound_sub = subarray.compare(subarray_table4[i]);
      ifound_read = readpatt.compare(readpatt_table4[i]);
      ifound_row = even.compare(rowtype4[i]);
      if(ifound_sub == 0 && ifound_read ==0 && ifound_row == 0 ) ifound_even = i ;
    }

    ifound_odd = -1;      

    // find the row for the readpatt and subarray that Exposure is for
    for (int i = 0 ;i < nrows; i++){
      int ifound_sub = -1;
      int ifound_read = -1;
      int ifound_row = -1;

      //compare subarray_table to subarray
      ifound_sub = subarray.compare(subarray_table4[i]);
      ifound_read = readpatt.compare(readpatt_table4[i]);
      ifound_row = odd.compare(rowtype4[i]);
      if(ifound_sub == 0 && ifound_read ==0 && ifound_row == 0 ) ifound_odd = i ;
    }

    if(ifound_odd != -1 && ifound_even !=-1) {
      RSCD.SetParameters(a0_3[ifound_even],a1_3[ifound_even],a2_3[ifound_even],
			 a3_3[ifound_even],
			 a0_3[ifound_odd],a1_3[ifound_odd],a2_3[ifound_odd],
			 a3_3[ifound_odd]);

      //cout << "RSCD Int 3 parameters even : "<< a0_3[ifound_even] << " " << a1_3[ifound_even]
      //   << " " << a2_3[ifound_even] << " " << a3_3[ifound_even]  << endl; 

      //cout << "RSCD Int 3 parameters odd : "<< a0_3[ifound_odd] << " " << a1_3[ifound_odd]
      //   << " " << a2_3[ifound_odd] << " " << a3_3[ifound_odd]  << endl;
	   
    } else{
      cout << " Could not find the correct row in the RSCD table " << endl;
      cout << " Turning off apply rscd correction " << endl;
      control.apply_rscd_cor = 0;
    }

    fits_close_file(fptr,&status);

    //_______________________________________________________________________  
  }


  return status;
}







