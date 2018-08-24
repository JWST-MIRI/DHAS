// Determine Dark or Lastframe  CDP filename if in subarray mode
       
// Author:
//
//	Jane Morrison
//      University of Arizona
//      email: morrison@as.arizona.edu
//      phone: 520-626-3181
// 
// Calling Sequence:
//

//
// Arguments:
//
// data_info: miri_data_info structure containing basic information on the file
//            to process.
// control: miri_control structure containing the processing options
//
//
// Return Value/ Variables modified:
//      No return value.
// The filenames contained in the data_info structure are filled in with the correct names
//
// History:
//
//	Written by Jane Morrison 2004
//      Changes to code are found on the MIRI DHAS web site:
//      http://tiamat.as.arizona.edu/dhas/

#include <iostream>
#include <vector>
#include <string>
#include <cstring>
#include <sstream>
#include "fitsio.h"
#include "miri_sloper.h"
#include "miri_data_info.h"
#include "miri_control.h"
#include "miri_CDP.h"
//  This routine is only called if dealing with subarray data

int ms_determine_CAL_Subarray(const int flag,miri_data_info &data_info, miri_control control,
			       miri_CDP &CDP)

{


  int final_status= 1; 
  long xsize=0;
  long ysize=0;
  long zsize=0;
  long isize=0;
  int colstart=0;
  int rowstart=0;
  // flag = 0 dark ; flag=1 reset 
  if (flag ==0) { 

  //________________________________________________________________________________
    if(control.jpl_run == "8" && control.jpl_detector == "106") {

  // JPL Run 8 SCA106 MASK4QPM
      if(data_info.raw_naxes[0] == 288){
	string dc_filename= control.calib_dir+CDP.GetDarkMask4QPMName() ;

	ms_read_CAL_header(dc_filename,xsize,ysize,zsize,isize,colstart,rowstart);
	if(data_info.ColStart == colstart && data_info.RowStart == rowstart && 
	   xsize == data_info.ramp_naxes[0] && ysize == data_info.ramp_naxes[1]) {  
	  final_status = 0;
	  CDP.SetDarkUseMask4QPM();
	  return final_status; 
	}
      }
  // JPL Run 8 SCA106 SUBLARGE
      if(data_info.raw_naxes[0] == 352){
	string dc_filename= control.calib_dir+ CDP.GetDarkSubLargeName(); 
	ms_read_CAL_header(dc_filename,xsize,ysize,zsize,isize,colstart,rowstart);
	if(data_info.ColStart == colstart && data_info.RowStart == rowstart && 
	   xsize == data_info.ramp_naxes[0] && ysize == data_info.ramp_naxes[1]) {  
	  final_status = 0;
	  CDP.SetDarkUseSubLarge();
	  return final_status; 
	}
      }
    }
  //________________________________________________________________________________
  // Search Bright Sky
    string dark = CDP.GetDarkBrightSkyName();
    string dc_filename= control.calib_dir+ dark;
    ms_read_CAL_header(dc_filename,xsize,ysize,zsize,isize,colstart,rowstart);
    if(data_info.ColStart == colstart && data_info.RowStart == rowstart && 
       xsize == data_info.ramp_naxes[0] && ysize == data_info.ramp_naxes[1]) {  
      final_status = 0;
      CDP.SetDarkUseBrightSky();
      return final_status; 
    }
  //________________________________________________________________________________
  // Search Mask1065
    dc_filename= control.calib_dir+ CDP.GetDarkMask1065Name(); 
    ms_read_CAL_header(dc_filename,xsize,ysize,zsize,isize,colstart,rowstart);
    if(data_info.ColStart == colstart && data_info.RowStart == rowstart && 
       xsize == data_info.ramp_naxes[0] && ysize == data_info.ramp_naxes[1]) {  
      final_status = 0;
      CDP.SetDarkUseMask1065();
      return final_status; 
    }
  //________________________________________________________________________________
  // Search Mask1140
    dc_filename= control.calib_dir+ CDP.GetDarkMask1140Name(); 
    ms_read_CAL_header(dc_filename,xsize,ysize,zsize,isize,colstart,rowstart);
    if(data_info.ColStart == colstart && data_info.RowStart == rowstart && 
       xsize == data_info.ramp_naxes[0] && ysize == data_info.ramp_naxes[1]) {  
      final_status = 0;
      CDP.SetDarkUseMask1140();
      return final_status; 
    }
  //________________________________________________________________________________
  // Search Mask1550
    dc_filename= control.calib_dir+ CDP.GetDarkMask1550Name(); 
    ms_read_CAL_header(dc_filename,xsize,ysize,zsize,isize,colstart,rowstart);
    if(data_info.ColStart == colstart && data_info.RowStart == rowstart && 
       xsize == data_info.ramp_naxes[0] && ysize == data_info.ramp_naxes[1]) {  
      final_status = 0;
      CDP.SetDarkUseMask1550();
      return final_status; 
    }
  //________________________________________________________________________________
  // Search MaskLYOT
    dc_filename= control.calib_dir+ CDP.GetDarkMaskLYOTName(); 
    ms_read_CAL_header(dc_filename,xsize,ysize,zsize,isize,colstart,rowstart);
    if(data_info.ColStart == colstart && data_info.RowStart == rowstart && 
       xsize == data_info.ramp_naxes[0] && ysize == data_info.ramp_naxes[1]) {  
      final_status = 0;
      CDP.SetDarkUseMaskLYOT();
      return final_status; 
    }
  //________________________________________________________________________________
  // Search MaskSub256
    dc_filename= control.calib_dir+ CDP.GetDarkMaskSub256Name();
    ms_read_CAL_header(dc_filename,xsize,ysize,zsize,isize,colstart,rowstart);
    if(data_info.ColStart == colstart && data_info.RowStart == rowstart && 
       xsize == data_info.ramp_naxes[0] && ysize == data_info.ramp_naxes[1]) {  
      final_status = 0;
      CDP.SetDarkUseMaskSub256();
      return final_status; 
    }
  //________________________________________________________________________________
  // Search MaskSub128
    dc_filename= control.calib_dir+ CDP.GetDarkMaskSub128Name(); 
    ms_read_CAL_header(dc_filename,xsize,ysize,zsize,isize,colstart,rowstart);
    if(data_info.ColStart == colstart && data_info.RowStart == rowstart && 
       xsize == data_info.ramp_naxes[0] && ysize == data_info.ramp_naxes[1]) {  
      final_status = 0;
      CDP.SetDarkUseMaskSub128();
      return final_status; 
    }
  //________________________________________________________________________________
  // Search MaskSub64
    dc_filename= control.calib_dir+ CDP.GetDarkMaskSub64Name(); 
    ms_read_CAL_header(dc_filename,xsize,ysize,zsize,isize,colstart,rowstart);
    if(data_info.ColStart == colstart && data_info.RowStart == rowstart && 
       xsize == data_info.ramp_naxes[0] && ysize == data_info.ramp_naxes[1]) {  
      final_status = 0;
      CDP.SetDarkUseMaskSub64();
      return final_status; 
    }
  //________________________________________________________________________________
  // Search SlitlessPrism
    dc_filename= control.calib_dir+ CDP.GetDarkSPrismName();
    ms_read_CAL_header(dc_filename,xsize,ysize,zsize,isize,colstart,rowstart);
    if(data_info.ColStart == colstart && data_info.RowStart == rowstart && 
       xsize == data_info.ramp_naxes[0] && ysize == data_info.ramp_naxes[1]) {  
      final_status = 0;
      CDP.SetDarkUseSPrism();
      return final_status; 
    }

  }

  //********************************************************************************

//********************************************************************************
      // Search for reset file name

  if (flag ==1) { 
  //________________________________________________________________________________
    if(control.jpl_run == "8" && control.jpl_detector == "106") {

  // JPL Run 8 SCA106 MASK4QPM
      if(data_info.raw_naxes[0] == 288){
	string dc_filename= control.calib_dir+CDP.GetResetMask4QPMName() ;

	ms_read_CAL_header(dc_filename,xsize,ysize,zsize,isize,colstart,rowstart);
	if(data_info.ColStart == colstart && data_info.RowStart == rowstart && 
	   xsize == data_info.ramp_naxes[0] && ysize == data_info.ramp_naxes[1]) {  
	  final_status = 0;
	  CDP.SetResetUseMask4QPM();
	  return final_status; 
	}
      }
  // JPL Run 8 SCA106 SUBLARGE
      if(data_info.raw_naxes[0] == 352){
	string dc_filename= control.calib_dir+ CDP.GetResetSubLargeName(); 
	ms_read_CAL_header(dc_filename,xsize,ysize,zsize,isize,colstart,rowstart);
	if(data_info.ColStart == colstart && data_info.RowStart == rowstart && 
	   xsize == data_info.ramp_naxes[0] && ysize == data_info.ramp_naxes[1]) {  
	  final_status = 0;
	  CDP.SetResetUseSubLarge();
	  return final_status; 
	}
      }
    }
  //________________________________________________________________________________
  // Search Bright Sky
    string reset = CDP.GetResetBrightSkyName(); string rc_filename= control.calib_dir+ reset;
    ms_read_CAL_header(rc_filename,xsize,ysize,zsize,isize,colstart,rowstart);
    if(data_info.ColStart == colstart && data_info.RowStart == rowstart && 
       xsize == data_info.ramp_naxes[0] && ysize == data_info.ramp_naxes[1]) {  
      final_status = 0;
      CDP.SetResetUseBrightSky();
      return final_status; 
    }
  //________________________________________________________________________________
  // Search Mask1065
    rc_filename= control.calib_dir+ CDP.GetResetMask1065Name(); 
    ms_read_CAL_header(rc_filename,xsize,ysize,zsize,isize,colstart,rowstart);
    if(data_info.ColStart == colstart && data_info.RowStart == rowstart && 
       xsize == data_info.ramp_naxes[0] && ysize == data_info.ramp_naxes[1]) {  
      final_status = 0;
      CDP.SetResetUseMask1065();
      return final_status; 
    }
  //________________________________________________________________________________
  // Search Mask1140
    rc_filename= control.calib_dir+ CDP.GetResetMask1140Name(); 
    ms_read_CAL_header(rc_filename,xsize,ysize,zsize,isize,colstart,rowstart);
    if(data_info.ColStart == colstart && data_info.RowStart == rowstart && 
       xsize == data_info.ramp_naxes[0] && ysize == data_info.ramp_naxes[1]) {  
      final_status = 0;
      CDP.SetResetUseMask1140();
      return final_status; 
    }
  //________________________________________________________________________________
  // Search Mask1550
    rc_filename= control.calib_dir+ CDP.GetResetMask1550Name(); 
    ms_read_CAL_header(rc_filename,xsize,ysize,zsize,isize,colstart,rowstart);
    if(data_info.ColStart == colstart && data_info.RowStart == rowstart && 
       xsize == data_info.ramp_naxes[0] && ysize == data_info.ramp_naxes[1]) {  
      final_status = 0;
      CDP.SetResetUseMask1550();
      return final_status; 
    }

//________________________________________________________________________________
  // Search MaskLYOT
    rc_filename= control.calib_dir+ CDP.GetResetMaskLYOTName(); 
    ms_read_CAL_header(rc_filename,xsize,ysize,zsize,isize,colstart,rowstart);
    if(data_info.ColStart == colstart && data_info.RowStart == rowstart && 
       xsize == data_info.ramp_naxes[0] && ysize == data_info.ramp_naxes[1]) {  
      final_status = 0;
      CDP.SetResetUseMaskLYOT();
      return final_status; 
    }
  //________________________________________________________________________________
  // Search MaskSub256
    rc_filename= control.calib_dir+ CDP.GetResetMaskSub256Name();
    ms_read_CAL_header(rc_filename,xsize,ysize,zsize,isize,colstart,rowstart);
    if(data_info.ColStart == colstart && data_info.RowStart == rowstart && 
       xsize == data_info.ramp_naxes[0] && ysize == data_info.ramp_naxes[1]) {  
      final_status = 0;
      CDP.SetResetUseMaskSub256();
      return final_status; 
    }
  //________________________________________________________________________________
  // Search MaskSub128
    rc_filename= control.calib_dir+ CDP.GetResetMaskSub128Name(); 
    ms_read_CAL_header(rc_filename,xsize,ysize,zsize,isize,colstart,rowstart);
    if(data_info.ColStart == colstart && data_info.RowStart == rowstart && 
       xsize == data_info.ramp_naxes[0] && ysize == data_info.ramp_naxes[1]) {  
      final_status = 0;
      CDP.SetResetUseMaskSub128();
      return final_status; 
    }
  //________________________________________________________________________________
  // Search MaskSub64
    rc_filename= control.calib_dir+ CDP.GetResetMaskSub64Name(); 
    ms_read_CAL_header(rc_filename,xsize,ysize,zsize,isize,colstart,rowstart);
    if(data_info.ColStart == colstart && data_info.RowStart == rowstart && 
       xsize == data_info.ramp_naxes[0] && ysize == data_info.ramp_naxes[1]) {  
      final_status = 0;
      CDP.SetResetUseMaskSub64();
      return final_status; 
    }
//________________________________________________________________________________
  // Search SlitlessPrism
    rc_filename= control.calib_dir+ CDP.GetResetSPrismName();
    ms_read_CAL_header(rc_filename,xsize,ysize,zsize,isize,colstart,rowstart);
    if(data_info.ColStart == colstart && data_info.RowStart == rowstart && 
       xsize == data_info.ramp_naxes[0] && ysize == data_info.ramp_naxes[1]) {  
      final_status = 0;
      CDP.SetResetUseSPrism();
      return final_status; 
    }


  }


  if(final_status != 0) cout << " No match for subarray Calibration  was found from the list" << endl;
  return final_status;   

}
