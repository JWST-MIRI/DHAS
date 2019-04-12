// This software is part of the MIRI Data Handling and Analysis Software (DHAS)
// This routine belongs to the miri_sloper package which processes raw science data.

// Name:
//       ms_final_slope.cpp
//
// Purpose:
// This routine averages slopes from multiple integrations to produce an average slope that
// is stored in the primary image. The uncertainty plane is also averaged. The information in
// the data quality flag is merged with all the integrations. If a file one has one integration 
// then the values in the first integration and the primary (averaged) image are the
// same.   	
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
//
//void ms_final_slope(const int nint,
//		    vector<float> Slope, 
//		    vector<float> SlopeUnc, 
//		    vector<float> SlopeID, 
//		    vector<float> &Final_Slope, 
//		    vector<float> &Final_SlopeUnc, 
//		    vector<float> &Final_SlopeID, 
//		    vector<float> &Final_Num) //
//
// Arguments:
// nint: number of integrations in file
// Slope: vector of slopes for current integration 
// SlopeUnc: vector of slope uncertainties for current integration 
// SlopeID: vector ofdata quality flags for current integration 
// Final_Slope: vector of averaged of slopes 
// Final_SlopeUnc: vector of averaged slope uncertainties 
// Final_SlopeID: vector of final data quality flags 
// 
// Return Value/ Variables modified:
//      No return value.
//      Final_ vectors updated
//
// History:
//
//	Written by Jane Morrison 2007
//      Changes to code are found on the MIRI DHAS web site:
//      http://tiamat.as.arizona.edu/dhas/

#include "miri_sloper.h"
#include "miri_control.h"

void ms_final_slope(const int intnum,
		    miri_control control,
		    const int nint,
		    vector<float> Slope, 
		    vector<float> SlopeUnc, 
		    vector<float> SlopeID, 
		    vector<float> &Final_Slope, 
		    vector<float> &Final_SlopeUnc, 
		    vector<float> &Final_SlopeID) 
		    
{
 
    //***********************************************************************
  if(control.QuickMethod == 1) {
    if(nint > 1 ) {
      long num = Slope.size();
      for (long i = 0; i< num; i++){
	if (!isnan(Slope[i]) ){
	  Final_Slope[i] = Final_Slope[i] + Slope[i];
	  Final_SlopeUnc[i]+=1.0;
	}
      }

    }else{
      copy(Slope.begin(),Slope.end(),Final_Slope.begin());
    }
    //***********************************************************************
  } else { 
	if(nint > 1 ) {

	  long flag_test[10] = {1,2,4,8,16,32,64,128,256,512};
	  long flag_num = 0;
	  long num = Slope.size();
	  for (long i = 0; i< num; i++){
	    int use = 1;
	    if(control.num_ignore > 0) {
	      int found = 0;
	      int iv = 0;
	       while(found ==0 && iv < control.num_ignore ){
		if( (intnum+1) == control.ignore_int[iv]) found = 1;
		iv++;}
	      if(found ==1) use = 0;
	    }
	    //_______________________________________________________________________
	    if(use ==1) {
		
	      //cout << " using integration " << intnum+1 << endl;

	    for (int j = 0; j< 10; j++){
	      int flag = int(SlopeID[i]/flag_test[j]) % 2;
	      int flag_final = int(Final_SlopeID[i]/flag_test[j])% 2;
      
	      if(flag && !flag_final){
		Final_SlopeID[i] = Final_SlopeID[i] + SlopeID[i];
		flag_num++;
	      }
	    }

	    if (!isnan(Slope[i]) ){
	      float sigma = SlopeUnc[i]*SlopeUnc[i];
	      Final_Slope[i] = Final_Slope[i] + Slope[i]/sigma;
	      Final_SlopeUnc[i] = Final_SlopeUnc[i] + 1.0/sigma;
	    }

	    }//use integration for determining slope average

	  }

	  //cout << " Final number of non zero ID" << flag_num << endl;
	  // 1 Integration 
	}else{

    
	  copy(Slope.begin(),Slope.end(),Final_Slope.begin());
	  copy(SlopeUnc.begin(),SlopeUnc.end(),Final_SlopeUnc.begin());
	  copy(SlopeID.begin(),SlopeID.end(),Final_SlopeID.begin());
	}
    

  }
    

}
