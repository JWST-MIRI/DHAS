#include <string>
#include <iostream>
#include <string.h>
#include <iomanip>
#include <fstream>
#include <math.h>
#include <cstdlib>
#include "fitsio.h"
#include "miri_constants.h"
#include "mc_data_info.h"
#include "mc_control.h"


// Keywords needed which describe the exposure:
// NPINTS:   # of integrations in the expospure processed by miri_sloper

void mc_read_header(mc_data_info& data_info, mc_control &control)

{
  char comment[72];
  // **********************************************************************
  // open the Slope data file and get various useful bits of info from the header
  //cout << " opening " << data_info.red_filename << endl;

  int status = 0;   // status of a cfitsio call
  fits_open_file(&data_info.red_file_ptr, data_info.red_filename.c_str(), READONLY, &status);   // open the file
  if(status !=0) {
    cout << " Failed to open fits Reduced file: " << data_info.red_filename << endl;
    cout << " Reason for failure, status = " << status << endl;
    exit(EXIT_FAILURE);
  }



  char msver[70];
  status = 0; 
  fits_read_key(data_info.red_file_ptr, TSTRING, "MS_VER", &msver, comment, &status); 
  if(status != 0){
    cout << " ******************************************************************************************" << endl;
    cout << " Problem reading MS_VER from Header " << endl;
    cout << " You are probably not running miri_caler over a reduced file (usually ending in LVL2.fits) " << endl;
    cout << " Check file and run again " << endl;
    cout << " ******************************************************************************************" << endl;
    exit(EXIT_FAILURE);
  }


  data_info.DGAA_POS_FLAG = 0;
  data_info.DGAB_POS_FLAG = 0;

  const char shorttype[] = "SHORT";
  const char mediumtype[] = "MEDIUM";
  const char longtype[] = "LONG";

  char dgaa_pos[10];
  char dgab_pos[10];

  int lstatus =0;
  int fstatus = 0;
  fits_read_key(data_info.red_file_ptr,TSTRING,"DGAA_POS", &dgaa_pos, comment,&lstatus); 


  if(lstatus == 0) { 
    int pstatus = -1;
    pstatus = strncmp(dgaa_pos,shorttype,5);
    if(pstatus ==0) {
      fstatus = 1; 
      //            cout <<" DGAA is short" << endl;
      data_info.DGAA_POS=0;
    }  else { // check if medium 

      pstatus = -1;
      pstatus = strncmp(dgaa_pos,mediumtype,6);
      if(pstatus ==0) {
	fstatus = 1; 
          //      cout <<" DGAA is medium" << endl;
	data_info.DGAA_POS=1;
      } else { // check if long

          pstatus = -1;
          pstatus = strncmp(dgaa_pos,longtype,4);
          if(pstatus ==0) {
            fstatus = 1; 
            //      cout <<" DGAA is long" << endl;
            data_info.DGAA_POS=2;
          }
        }
      }
    }


    if(fstatus ==0){
      //cout << " DGAA_POS not found" << endl; 
    }else{
      data_info.DGAA_POS_FLAG = 1;
    }


    lstatus =0;
    fstatus = 0;
    fits_read_key(data_info.red_file_ptr,TSTRING,"DGAB_POS", &dgab_pos, comment,&lstatus);

    if(lstatus == 0) { 
      int pstatus = -1;
      pstatus = strncmp(dgab_pos,shorttype,5);
      if(pstatus ==0) {
        fstatus = 1; 
	// cout <<" DGAB is short" << endl;
        data_info.DGAB_POS=0;
      }  else { // check if medium 
        pstatus = -1;
        pstatus = strncmp(dgab_pos,mediumtype,6);
        if(pstatus ==0) {
          fstatus = 1; 
          //      cout <<" DGAB is medium" << endl;
          data_info.DGAB_POS=1;
        } else { // check if long
          pstatus = -1;
          pstatus = strncmp(dgab_pos,longtype,4);
          if(pstatus ==0) {
            fstatus = 1; 
            //      cout <<" DGAB is long" << endl;
            data_info.DGAB_POS=2;
          }
        }
      }
    }

    if(fstatus ==0){
      //      cout << " DGAB_POS not found" << endl; 
    }else{
      data_info.DGAB_POS_FLAG = 1;
    }



// NSAMPLE: # (on board sampling factor) 1 = fast, 10 = slow
   fits_read_key(data_info.red_file_ptr, TINT, "NSAMPLE", &data_info.NSample, comment, &status); 



   //  status = 0; 
   //fits_read_key(data_info.red_file_ptr, TINT, "SCA_ID", &data_info.SCA, comment, &status); 
   //if(status != 0){
   // cout << " Problem reading SCAID from Header " << endl;
   // exit(EXIT_FAILURE);
   // }


   // if(data_info.SCA == SCA_IMAGER || data_info.SCA == SCA_IMAGER_B) {
   // data_info.Imager = 1;
   // control.subchannel = -1;
   //data_info.FILTER = IMAGER;
   //}
	

   //if(data_info.SCA == SCA_LW || data_info.SCA == SCA_LW_B) data_info.LW = 1;
   //if(data_info.SCA == SCA_SW || data_info.SCA == SCA_SW_B) data_info.SW = 1;
  
   //cout << "SCA " << data_info.SCA << endl;



  status = 0; 
  fits_read_key(data_info.red_file_ptr, TINT, "COLSTART", &data_info.ColStart, comment, &status); 

  if(status != 0) data_info.ColStart = 1;
  status = 0; 
  fits_read_key(data_info.red_file_ptr, TINT, "ROWSTART", &data_info.RowStart, comment, &status); 
  if(status != 0) data_info.RowStart = 1;

  if(data_info.ColStart != 1 || data_info.RowStart !=1) {
    cout << " Subarray Data: Col Start Row Start " << data_info.ColStart << " " << data_info.RowStart << endl;
  }






  status = 0;
  int hdutype = 0;

  fits_movabs_hdu(data_info.red_file_ptr,2,&hdutype,&status);
  if(status !=0) {
    cout << " Failed to move to first header in Slope Fits file " << data_info.red_filename << endl;
    cout << " Reason for failure, status = " << status << endl;
    exit(EXIT_FAILURE);
  }


  status = 0;
  // get the size of the data cube
  fits_read_key(data_info.red_file_ptr, TLONG, "NAXIS1", &data_info.red_naxes[0], comment, &status); 
  if(status !=0 ){
    cout << "mc_read_header:  Problem reading NAXIS1 " << endl;
    cout << " Reason for failure, status = " << status << endl;
    exit(EXIT_FAILURE);
  }
  fits_read_key(data_info.red_file_ptr, TLONG, "NAXIS2", &data_info.red_naxes[1], comment, &status); 
  if(status !=0 ) {
    cout << "mc_read_header:  Problem reading NAXIS2 " << endl;
    cout << " Reason for failure, status = " << status << endl;
    exit(EXIT_FAILURE);
  }


  fits_read_key(data_info.red_file_ptr, TLONG, "NAXIS3", &data_info.red_naxes[2], comment, &status); 
  if(status !=0 ) {
    cout << "mc_read_header:  Problem reading NAXIS3 " << endl;
    cout << " Reason for failure, status = " << status << endl;
    exit(EXIT_FAILURE);
  }
  int naxis3 = data_info.red_naxes[2];

  if(naxis3 == 2) {
    cout << " LVL2 image produced from miri_sloper -Q option, this type of data cannot used with miri_caler " <<endl;
    cout << " Run miri_sloper again and do not use the -Q option " << endl;
    exit(EXIT_FAILURE);
  }

  


  // **********************************************************************
  status = 0; 
  fits_read_key(data_info.red_file_ptr, TINT, "NPINT", &data_info.NInt, comment, &status); 
  if(status !=0 )   data_info.NInt = 1;

  status = 0; 
  fits_read_key(data_info.red_file_ptr, TINT, "NPGROUP", &data_info.NFrames, comment, &status); 
  if(status !=0 )   data_info.NFrames = 1;


  data_info.NInt_org = data_info.NInt;
  data_info.NFrames_org = data_info.NFrames;
  if(data_info.NFrames  == 1 && data_info.NInt > 1) {
    data_info.NInt = 1;
  }
    
  // **********************************************************************




  
  // **********************************************************************
  data_info.subarray_mode = -1; // full array
  if(data_info.red_naxes[0] < 1032 ) {
    cout << " This is subarray Data " << endl;
    
    data_info.subarray_mode = 1; // need to figure out which subarray
                                 // we are on- for now hard code to mode1
  }

  // **********************************************************************
  if(control.do_verbose == 10 ) {
    cout << " Number of Integrations  " << data_info.NInt << endl;
    cout << " Size of input data      " << data_info.red_naxes[0] << " " <<
      data_info.red_naxes[1] << " " <<data_info.red_naxes[2] << " " <<endl;
  }





}


