#include <iostream>
#include <stdio.h>
#include <string.h>
#include <vector>
#include "fitsio.h"
#include "miri_caler.h"
#include "dhas_version.h"
#include "miri_constants.h"


// open and setup the header for the reduced FITS file: control.raw_bitsbase + ".LVL2.fits";
// If option to write reduced reference image is set (control.write_output_refslope)- 
// the create that file and write header. 

void mc_write_processing_to_header(fitsfile *file_ptr,
				   mc_control control,
				   string preference_filename,
				   mc_data_info& data_info)

{


  char yes_str[4] = "Yes"; // string for the yes answer
  char no_str[3] = "No";   // string for the no answer

  char version[strlen(dhas_version)+1];
  strcpy(version,dhas_version);
  int status = 0;



  fits_write_comment(file_ptr, 
		     "**==============================================================**",&status);

  fits_write_comment(file_ptr, "**--------------------------------------------------------------**",&status);
  fits_write_comment(file_ptr, "file created by miri_sloper program",&status);
  fits_write_comment(file_ptr, "MIRI Team Pipeline",&status);
  fits_write_comment(file_ptr, "Jane Morrison",&status);
  fits_write_comment(file_ptr, "email morrison@as.arizona.edu for info",&status);
  fits_write_comment(file_ptr, "**--------------------------------------------------------------**",&status);
  fits_write_comment(file_ptr, "Calibrated Data",&status);
  fits_write_comment(file_ptr, "plane 1: signal (DN/s)",&status);
  fits_write_comment(file_ptr, "plane 2: uncertainty (DN/s)",&status);
      
  fits_write_comment(file_ptr, "plane 3: data flag (1 = Bad Pixel, 2/4 high/low global saturated ",&status);
  fits_write_comment(file_ptr, "   8 = pixel saturated, 16 = noise spike, 32 = cosmic ray,",&status);
  fits_write_comment(file_ptr, "   64 = no electronic linearity correction, 128 = Missing Data",&status);



  fits_write_comment(file_ptr, "**--------------------------------------------------------------**",&status);
  fits_write_comment(file_ptr, "**-miri_sloper processing info----------------------------------**",&status);

  
  char array_type_char_string[MAX_FILENAME_LENGTH];  // necessary as fits_write_key does not support C++ strings
  ostrstream array_type_stream(array_type_char_string,MAX_FILENAME_LENGTH);
  array_type_stream << "MIRI"  << '\0';
  fits_write_key(file_ptr, TSTRING, "ARYTYPE", &array_type_char_string, "Array type (char,flight,spare)", &status);
  
  fits_write_key(file_ptr, TSTRING, "MC_VER", &version, "miri_caler version", &status);
    //_______________________________________________________________________
    //convert from a string class to character string
    // see page 957 How to Program in c++ (Deitel and Deitel)
  int len = control.miri_dir.length();
  char *ptr1 = new char[len+1];
  control.miri_dir.copy(ptr1,len,0);
  ptr1[len] = 0;

  status = 0 ;
  fits_write_key(file_ptr, TSTRING, "MIRI_DIR", ptr1, "Default Preferences Location", &status);
  if(status !=0) cout << " Problem MIRI_DIR" << status << " " << control.miri_dir << endl;
  delete [] ptr1;

  int SET1 = 1;

  fits_write_key(file_ptr, TINT, "CALIBR", &SET1, " This file has been run through miri_caler", &status);


  len = preference_filename.length();
  char *ptr = new char[len+1];
  preference_filename.copy(ptr,len,0);
  ptr[len] = 0;

  status = 0 ;
  fits_write_key(file_ptr, TSTRING, "PREFFILE", ptr, "Preferences Filename Used", &status);
  if(status !=0) cout << " Problem writing Preferences Filename " << status << " " << preference_filename << endl;
  delete [] ptr;

  //len = control.calib_dir.length();
  //char *ptr4 = new char[len+1];
  //control.calib_dir.copy(ptr4,len,0);
  //ptr4[len] = 0;

  //  status = 0 ;
  //fits_write_key(file_ptr, TSTRING, "CALIDIR", ptr4, "Calibration Directory", &status);
  //if(status !=0) cout << " Problem writing calibration directory " << status << " " <<
  //			control.calib_dir<< endl;
			//delete [] ptr4;
    //_______________________________________________________________________

  fits_write_key(file_ptr, TINT, "NCINT", &data_info.NInt_org,
		 "Number of Integrations processed", &status);

  fits_write_key(file_ptr, TINT, "NCGROUP", &data_info.NFrames_org,
		 "Number of Frames/Int", &status);

  //_______________________________________________________________________
  if (control.apply_background ==1){
    fits_write_key(file_ptr, TSTRING, "BKG", yes_str, "Perform background subtraction?", &status);

    string backgroundfile = control.background_file;
    size_t dir = backgroundfile.find_last_of("/");

    string dfile = backgroundfile;
    //    string ddir = control.calib_dir;
    string ddir;
    if(dir !=string::npos){
      dfile = backgroundfile.substr(dir+1,backgroundfile.size());
      ddir = backgroundfile.substr(0,dir);
    }

    len = dfile.length();
    char *ptr4 = new char[len+1];
    dfile.copy(ptr4,len,0);
    ptr4[len] = 0;
    status = 0 ;
    fits_write_key(file_ptr, TSTRING, "BKGFILE", ptr4, "Background File", &status);
    delete [] ptr4;

    len = ddir.length();
    char *ptr41 = new char[len+1];
    ddir.copy(ptr41,len,0);
    ptr41[len] = 0;
    status = 0 ;
    fits_write_key(file_ptr, TSTRING, "BKGDIR", ptr41, "Background DIR", &status);
    delete [] ptr41;
  }
  else
    fits_write_key(file_ptr, TSTRING, "BKG", no_str, "Perform background subtraction?", &status);
  
  //_______________________________________________________________________
  if (control.apply_flat ==1){
    fits_write_key(file_ptr, TSTRING, "FLAT", yes_str, "Perform Flat normalization?", &status);

    string flatfile = control.flat_file;
    size_t dir = flatfile.find_last_of("/");

    string ffile = flatfile;
    //    string fdir = control.calib_dir;
    string fdir;
    if(dir !=string::npos){
      ffile = flatfile.substr(dir+1,flatfile.size());
      fdir = flatfile.substr(0,dir);
    }

    len = ffile.length();
    char *ptr5 = new char[len+1];
    ffile.copy(ptr5,len,0);
    ptr5[len] = 0;
    status = 0 ;
    fits_write_key(file_ptr, TSTRING, "FLATFILE", ptr5, "FLAT Calibration File", &status);
    delete [] ptr5;

    len = fdir.length();
    char *ptr51 = new char[len+1];
    fdir.copy(ptr51,len,0);
    ptr51[len] = 0;
    status = 0 ;
    fits_write_key(file_ptr, TSTRING, "FLATDIR", ptr51, "FLAT Calibration DIR", &status);
    delete [] ptr51;

  }
  




  else
    fits_write_key(file_ptr, TSTRING, "FLAT", no_str, "Perform flat normalization?", &status);

  //_______________________________________________________________________


  //_______________________________________________________________________
  if (control.apply_fringe_flat ==1){
    fits_write_key(file_ptr, TSTRING, "FRFLAT", yes_str, "Perform Fringe Flat normalization?", &status);

    string fringefile = control.fringe_file;
    size_t dir = fringefile.find_last_of("/");

    string frfile = fringefile;
    //   string frdir = control.calib_dir;
    string frdir;
    if(dir !=string::npos){
      frfile = fringefile.substr(dir+1,fringefile.size());
      frdir = fringefile.substr(0,dir);
    }

    len = frfile.length();
    char *ptr6 = new char[len+1];
    frfile.copy(ptr6,len,0);
    ptr6[len] = 0;
    status = 0 ;
    fits_write_key(file_ptr, TSTRING, "FRFLFILE", ptr6, "Fringe FLAT Calibration File", &status);
    delete [] ptr6;

    len = frdir.length();
    char *ptr61 = new char[len+1];
    frdir.copy(ptr61,len,0);
    ptr61[len] = 0;
    status = 0 ;
    fits_write_key(file_ptr, TSTRING, "FRFLDIR", ptr61, "Fringe FLAT Calibration DIR", &status);
    delete [] ptr61;

  }

  else
    fits_write_key(file_ptr, TSTRING, "FRFLAT", no_str, "Perform Fringe flat normalization?", &status);

  //_______________________________________________________________________


}



