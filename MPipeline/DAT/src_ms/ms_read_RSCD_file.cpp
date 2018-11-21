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

    fits_movabs_hdu(fptr,2,&hdutype,&status); // for to first extension  
    long nrows=0;
    int ncols=0;
    status = fits_get_num_rows(fptr,&nrows,&status);
    status = fits_get_num_cols(fptr,&ncols,&status);
    cout << " Reading RSCD file" << RSCD_file << endl;

    //    cout << "number of rows and cols in RSCD table " << nrows <<" " << ncols << endl;

    string col_name[] = {"SUBARRAY","READPATT","ROWS","TAU",
			 "ASCALE", "POW", "ILLUM_ZP","ILLUM_SLOPE","ILLUM2",
			 "PARAM3","CROSSOPT","SAT_ZP","SAT_SLOPE","SAT_2","SAT_MZP",
			 "SAT_ROWTERM","SAT_SCALE"};
    int col_num[] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

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
	  //	  cout << "found match " << keyname << " " << col_name[k]<< " " << "col = " <<  col_num[k] << " "   << k << endl;
	}
      }
     

    }


    vector<string> rowtype(nrows);
    string name_search = "ROWS";    
    status = 0; 
    ms_RSCD_readtable(fptr,name_search,num_elements,nrows, col_name,col_num,rowtype,status);

    vector<string> readpatt_table(nrows);
    name_search = "READPATT";    
    status = 0; 
    ms_RSCD_readtable(fptr,name_search,num_elements,nrows, col_name,col_num,readpatt_table,status);


    vector<string> subarray_table(nrows);
    name_search = "SUBARRAY";
    status = 0; 
    ms_RSCD_readtable(fptr,name_search,num_elements,nrows, col_name,col_num,subarray_table,status);

    vector<float> tau(nrows);
    name_search = "TAU";
    status = 0; 
    ms_RSCD_readtable(fptr, name_search,num_elements,nrows, col_name,col_num,tau,status);

    vector<float> ascale(nrows);
    name_search= "ASCALE";
    status = 0; 
    ms_RSCD_readtable(fptr, name_search,num_elements,nrows, col_name,col_num,ascale,status);
    
    vector<float> rpow(nrows);
    name_search= "POW";
    status = 0; 
    ms_RSCD_readtable(fptr, name_search,num_elements,nrows, col_name,col_num,rpow,status);

    vector<float> illum_zp(nrows);
    name_search= "ILLUM_ZP";
    status = 0; 
    ms_RSCD_readtable(fptr, name_search,num_elements,nrows, col_name,col_num,illum_zp,status);

    vector<float> illum_slope(nrows);
    name_search= "ILLUM_SLOPE";
    status = 0; 
    ms_RSCD_readtable(fptr, name_search,num_elements,nrows, col_name,col_num,illum_slope,status);

    vector<float> illum2(nrows);
    name_search = "ILLUM2";
    status = 0; 
    ms_RSCD_readtable(fptr,name_search,num_elements,nrows, col_name,col_num,illum2,status);

    vector<float> param3(nrows);
    name_search = "PARAM3";
    status = 0; 
    ms_RSCD_readtable(fptr,name_search,num_elements,nrows, col_name,col_num,param3,status);

    vector<float> cross(nrows);
    name_search = "CROSSOPT";
    status = 0; 
    ms_RSCD_readtable(fptr,name_search,num_elements,nrows, col_name,col_num,cross,status);

    vector<float> sat_zp(nrows);
    name_search = "SAT_ZP";
    status = 0; 
    ms_RSCD_readtable(fptr,name_search,num_elements,nrows, col_name,col_num,sat_zp,status);

    vector<float> sat_slope(nrows);
    name_search = "SAT_SLOPE";
    status = 0; 
    ms_RSCD_readtable(fptr,name_search,num_elements,nrows, col_name,col_num,sat_slope,status);

    vector<float> sat_2(nrows);
    name_search = "SAT_2";
    status = 0; 
    ms_RSCD_readtable(fptr,name_search,num_elements,nrows, col_name,col_num,sat_2,status);
    

    vector<float> sat_mzp(nrows);
    name_search = "SAT_MZP";
    status = 0; 
    ms_RSCD_readtable(fptr,name_search,num_elements,nrows, col_name,col_num,sat_mzp,status);

    vector<float> sat_rowterm(nrows);
    name_search = "SAT_ROWTERM";
    status = 0; 
    ms_RSCD_readtable(fptr,name_search,num_elements,nrows, col_name,col_num,sat_rowterm,status);

    vector<float> sat_scale(nrows);
    name_search = "SAT_SCALE";
    status = 0; 
    ms_RSCD_readtable(fptr,name_search,num_elements,nrows, col_name,col_num,sat_scale,status);


    fits_close_file(fptr,&status);

    int ifound_even = -1;      
    string even = "EVEN";
    // find the row for the readpatt and subarray that Exposure is for
    for (int i = 0 ;i < nrows; i++){
      int ifound_sub = -1;
      int ifound_read = -1;
      int ifound_row = -1;

      //compare subarray_table to subarray
      ifound_sub = subarray.compare(subarray_table[i]);
      ifound_read = readpatt.compare(readpatt_table[i]);
      ifound_row = even.compare(rowtype[i]);
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
      ifound_sub = subarray.compare(subarray_table[i]);
      ifound_read = readpatt.compare(readpatt_table[i]);
      ifound_row = odd.compare(rowtype[i]);
      if(ifound_sub == 0 && ifound_read ==0 && ifound_row == 0 ) ifound_odd = i ;
    }


    if(ifound_odd != -1 && ifound_even !=-1) {
      RSCD.SetParameters(data_info.NRamps,
			 tau[ifound_even],ascale[ifound_even],rpow[ifound_even],
			 illum_zp[ifound_even],illum_slope[ifound_even],illum2[ifound_even],
			 param3[ifound_even],cross[ifound_even],
			 tau[ifound_odd],ascale[ifound_odd],rpow[ifound_odd],
			 illum_zp[ifound_odd],illum_slope[ifound_odd],illum2[ifound_odd],
			 param3[ifound_odd],cross[ifound_odd]);

      sat_rowterm[ifound_odd]= 0.0;
      sat_rowterm[ifound_even]= 0.0;
      sat_mzp[ifound_even] = 3.6;
      sat_mzp[ifound_odd]=  3.0;
		  
      RSCD.SetSATParameters(data_info.NRamps,
			    sat_zp[ifound_even],sat_slope[ifound_even],sat_2[ifound_even],
			    sat_mzp[ifound_even],sat_rowterm[ifound_even],
			    sat_scale[ifound_even],
			    sat_zp[ifound_odd],sat_slope[ifound_odd],sat_2[ifound_odd],
			    sat_mzp[ifound_odd],sat_rowterm[ifound_odd],
			    sat_scale[ifound_odd]);

      cout << "RSCD parameters even : "<< tau[ifound_even] << " " << ascale[ifound_even]
	   << " " << rpow[ifound_even] << " " << illum_zp[ifound_even] 
	   << " " << illum_slope[ifound_even] << " " << illum2[ifound_even] 
	   << " " << param3[ifound_even] << " " << cross[ifound_even] << endl;


      cout << "RSCD parameters odd : "<< tau[ifound_odd] << " " <<ascale[ifound_odd]
	   << " " << rpow[ifound_odd] << " " << illum_zp[ifound_odd] 
	   << " " << illum_slope[ifound_odd] << " " << illum2[ifound_odd] 
	   << " " << param3[ifound_odd] << " " << cross[ifound_odd] << endl;

      cout << "RSCD SAT parameters even : "<< sat_zp[ifound_even] << " " << sat_slope[ifound_even]
	   << " " << sat_2[ifound_even] << " " << sat_mzp[ifound_even] 
	   << " " << sat_rowterm[ifound_even] << " " << sat_scale[ifound_even] << endl;

      cout << "RSCD SAT parameters odd : "<< sat_zp[ifound_odd] << " " << sat_slope[ifound_odd]
	   << " " << sat_2[ifound_odd] << " " << sat_mzp[ifound_odd] 
	   << " " << sat_rowterm[ifound_odd] << " " << sat_scale[ifound_odd] << endl;


	   
    } else{

      cout << " Could not find the correct row in the RSCD table " << endl;
      cout << " Turning off apply rscd correction " << endl;
      control.apply_rscd_cor = 0;
    }

    //_______________________________________________________________________
    
  }


  return status;
}







