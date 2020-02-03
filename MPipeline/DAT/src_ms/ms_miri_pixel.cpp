// This software is part of the MIRI Data Handling and Analysis Software (DHAS)
// This routine belongs to the miri_sloper package which processes raw science data.

// Name:
//      ms_miri_pixel.cpp
//
// Purpose:
// 	This programs defines the miri_pixel class functions. 
//      The miri_pixel class holds all the information for a pixel, the DN values, 2 pt differences,
//      data quality flags and final processed results (slope,uncertainty). 
//      see include/miri_pixel.h for a complete definition.
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
//  no calling sequence: describes class functions. 
//
// Arguments:
//
//
// Return Value/ Variables modified:
//      No return value.  
// 
//
// History:
//
//	Written by Jane Morrison 2006
//      Changes to code are found on the MIRI DHAS web site:
//      http://tiamat.as.arizona.edu/dhas/



#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <cmath>
#include <vector>
#include <algorithm>
#include "miri_pixel.h"
#include "miri_constants.h"
#include "lin_constants.h"

int Poly_Fit(vector<double> x, vector<double> y, const int ndegree, 
	     vector<double> &result, vector<double> &yfit, vector<double> &sigma,
	     double &chisq, double &yerror, const int);

void piksrt(vector <int> &arr, vector <long> &indx);


// Default constructor to set initial values

miri_pixel::miri_pixel(): quality_flag(), is_ref(),signal(0), signal_unc(0),zero_pt(0),num_good_reads(0),
			 read_num_first_saturated(0),rms(0),max_2pt_diff(0),
			 read_num_max_2pt_diff(0),std_dev_2pt_diff(0),  slope_2pt_diff(0),
			 num_good_segments(0),num_segments(0){}

//Default destructor
miri_pixel::~miri_pixel() {}

//_______________________________________________________________________
//_______________________________________________________________________

void miri_pixel::SetPixel(int X, int Y, const int ColStart,int  IREAD,int BADPIXEL){

    //-----------------------------------------------------------------------
  // find channel number and correct X, Y
  int chan = (X-1) /4;
  channel = short(  (X) - (chan*4));

  pix_x = X;
  pix_y =Y;
  quality_flag = 0;

  process_flag = 1; 
  is_ref = 0; 
  bad_pixel_flag = 0; 
  lastframe_cor_data = 0;
 
  is_even = 0;
  if( Y %2 ==0){
    is_even = 1;
  }else{
    is_even = 0;
  }

    // If reference pixels exist - redefine where X starts
    // X = 1,2,3,4 & 1029,1030,1031,1032 are reference pixels,
  if(ColStart ==1) {  
    if(X < 5) is_ref = 1;
    if(X>1028) is_ref = 1; 
  }
    //-----------------------------------------------------------------------

  read_num_first_saturated = IREAD;
    
  if(BADPIXEL & CDP_DONOT_USE) { //(add back in the end to quality flag NaN output data) 
    bad_pixel_flag = 1; 
    process_flag = 0;
  } 

    //-----------------------------------------------------------------------
    // See if data is a Bad Pixel 
  
  if(process_flag ==0){
    vector<int>::iterator iter = id_data.begin();
    vector<int>::iterator iter_end = id_data.end();
    for(; iter != iter_end; ++iter)
      *iter = BAD_PIXEL_ID;
    
    signal = strtod("NaN",NULL);
    signal_unc = strtod("NaN",NULL);
    zero_pt = strtod("NaN",NULL);
    read_num_first_saturated = 0;
    num_good_reads = 0;
    quality_flag = quality_flag + BAD_PIXEL_ID;
  }
}

//_______________________________________________________________________
void miri_pixel::InitializeLinCorData(){
  for (unsigned int i = 0 ; i < raw_data.size() ; i++){
    lin_cor_data.push_back(raw_data[i]); // initialize 
  }
}

void miri_pixel::InitializeDarkCorData(){
  if(process_flag ==0){
    float nan = strtod("NaN",NULL);
    for (unsigned int i = 0 ; i < raw_data.size() ; i++){
      dark_cor_data.push_back(nan); // initialize 
    }
  }
  for (unsigned int i = 0 ; i < raw_data.size() ; i++){
    dark_cor_data.push_back(raw_data[i]); // initialize 
  }
}


void miri_pixel::InitializeRSCDCorData(){
  if(process_flag ==0){
    float nan = strtod("NaN",NULL);
    for (unsigned int i = 0 ; i < raw_data.size() ; i++){
      rscd_cor_data.push_back(nan); // initialize 
    }
  }
  for (unsigned int i = 0 ; i < raw_data.size() ; i++){
    rscd_cor_data.push_back(raw_data[i]); // initialize 
  }
 
}

void miri_pixel::InitializeResetCorData(){
  if(process_flag ==0){
    float nan = strtod("NaN",NULL);
    for (unsigned int i = 0 ; i < raw_data.size() ; i++){
      reset_cor_data.push_back(nan); // initialize 
    }
  }
  for (unsigned int i = 0 ; i < raw_data.size() ; i++){
    reset_cor_data.push_back(raw_data[i]); // initialize 
  }
 
}

void miri_pixel::InitializeRefCorData(){
  if(process_flag ==0){
    float nan = strtod("NaN",NULL);
   for (unsigned int i = 0 ; i < raw_data.size() ; i++){
      ref_cor_data.push_back(nan); // initialize 
    }
  }
  for (unsigned int i = 0 ; i < raw_data.size() ; i++){
    ref_cor_data.push_back(raw_data[i]); // initialize 
  }
}

//_______________________________________________________________________
void miri_pixel::GetLast2Frames(const int isecond, const int ithird,
			       float &lastframe_second, float  &lastframe_third){
  lastframe_second = lin_cor_data[isecond];
  lastframe_third = lin_cor_data[ithird];

  //for (unsigned int i = 0 ; i < raw_data.size() ; i++){
  //  cout<< i<< " " << lin_cor_data[i] << endl;; // initialize 
  // }
}

//_______________________________________________________________________
// in a pixel's sample up the ramp values = find the 2 point difference
// between adjacent frame values-
// Also find the max_2pt_difference value and frame # that goes with it
//
void miri_pixel::Get2ptDiff(const int start_fit,
			    vector<float> &diff, 
			    vector<float> &weight, int &ngood){
  int num = raw_data.size();
  max_2pt_diff = 0.0;
  read_num_max_2pt_diff =0;
  for (int i =0; i< num-1; i++){
    diff[i] = raw_data[i+1] - raw_data[i];
    if(fabs(diff[i]) > fabs(max_2pt_diff)) {
      max_2pt_diff = diff[i];
      read_num_max_2pt_diff = i +start_fit + 1 ;
    }
    
    diff[i] = fabs(diff[i]);
    if( (id_data[i] + id_data[i+1]) == 0){
      weight[i] = 1.0;
      ngood++;
    }
  }
}


//_______________________________________________________________________
// in a pixel's sample up the ramp values = find the 2 point difference
// between adjacent frame values.
// This function also stores the index of the 2 pt difference
// Also find the max_2pt_difference value and frame # that goes with it
// - ngood - number values where id_data of both frames  = 0

void miri_pixel::Get2ptDiffIndex(const int start_fit,
				 vector<float> &diff,
				 vector<float> &true_diff, 
				 vector<long> &index, int &ngood){
  long num = raw_data.size();
  max_2pt_diff = 0.0;
  read_num_max_2pt_diff =0;
  ngood = 0;
  for (long i =0; i< num-1; i++){
    if( (id_data[i] + id_data[i+1]) == 0){
      diff.push_back( raw_data[i+1] - raw_data[i]);
      index.push_back(i);

      if(fabs(diff[ngood]) > fabs(max_2pt_diff)) {
	max_2pt_diff = diff[ngood];
	read_num_max_2pt_diff = int(i) +start_fit + 1 ;
      }
      true_diff.push_back(diff[ngood]);
      diff[ngood] = fabs(diff[ngood]);

      ngood++;
    } else {

    }
  }
}


//_______________________________________________________________________
// in a pixel's sample up the ramp values = find the 2 point difference
// between adjacent frame values.
// This function also stores the index of the 2 pt difference
// Also find the max_2pt_difference value and frame # that goes with it
// - ngood - number values where id_data of both frames  = 0

void miri_pixel::Get2ptDiffIndexP(const int start_fit,
				  vector<float> &diff,
				  vector<float> &true_diff, 
				  vector<long> &index, 
				  vector<long> &ipixel, 
				  int &ngood){
  long num = raw_data.size();
  max_2pt_diff = 0.0;
  read_num_max_2pt_diff =0;
  ngood = 0;
  long  j = 0;
  for (long i =0; i< num-1; i++){
    if( (id_data[i] + id_data[i+1]) == 0){
      diff.push_back( raw_data[i+1] - raw_data[i]);
      index.push_back(j);

      ipixel.push_back(i); 

      true_diff.push_back(diff[ngood]);
      diff[ngood] = fabs(diff[ngood]);

      if(fabs(diff[ngood]) > fabs(max_2pt_diff)) {
	max_2pt_diff = diff[ngood];
	read_num_max_2pt_diff = int(i) +start_fit + 1 ;
      }

      j++;
      ngood++;
    } else {


    }
  }
}
       


// 

void miri_pixel::RejectAfterEvent(const int frame, const int FLAG, const int nreject_noise, const int nreject_cr){

 
  int num = raw_data.size(); 
  int iframe = frame; 


    //-----------------------------------------------------------------------

  if(FLAG == NOISE_SPIKE_UP_ID || FLAG == NOISE_SPIKE_DOWN_ID) {
    int j = 0;
    while(j < nreject_noise && (iframe+1) < num) {
      id_data[iframe+1] = REJECT_AFTER_NOISE_SPIKE;
      iframe++;
      j++;
    }
  }

    //-----------------------------------------------------------------------
  if(FLAG == COSMICRAY_ID || FLAG == COSMICRAY_NEG_ID ) {
    int j = 0;
    while(j < nreject_cr && (iframe+1) < num) {
      id_data[iframe+1] = REJECT_AFTER_CR;
      iframe++;
      j++;
    }
  }

}
        

//_______________________________________________________________________
void miri_pixel::CorrectNonLinearityOld(const int write_corrected_data,
				     const int apply_lin_offset,
				     const int istart_fit,
				     int linflag,
				     int lin_order,vector<float> lin){



  //-----------------------------------------------------------------------
  if(is_ref) { //Reference Pixe (no  correction determined)

    if(write_corrected_data==1) {
      for (unsigned int i = 0 ; i < raw_data.size() ; i++){
	lin_cor_data[i]= raw_data[i]; // initialize 
      }
    }
    return;
  } 

  //-----------------------------------------------------------------------
  if(linflag & CDP_NOLINEARITY    ) { //  no linearity correction

    signal = strtod("NaN",NULL);
    signal_unc = strtod("NaN",NULL);
    zero_pt = strtod("NaN",NULL);
    read_num_first_saturated = 0;
    num_good_reads = 0; 

    quality_flag = quality_flag + UNRELIABLE_LIN ;

    if(write_corrected_data==1) { // pixel either is a bad pixel or has no non-linearity correction
      for (unsigned int i = 0 ; i < raw_data.size() ; i++){
	lin_cor_data[i] = (strtod("NaN",NULL)); //  
      }
    }

    return;
  }
  //-----------------------------------------------------------------------
  // determine Starting Value

  double startVal = 0.0;

  unsigned int nsize = raw_data.size();
  if (nsize < 4) {
    startVal = raw_data[0];
  } else { 

  //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    // Estimate the DN_zero, DN at time = 0 = startVal
    int min_num = 8; // enough points to do a decent 3rd order poly
    double startVal_fit = 0.0;
    double startVal_estimate  = 0.0;

    int iflag_fit = 0;
    int iflag_estimate = 0; 
  // first estimate the starting value based on 2,3,4 ramp values
 
    float rate = 0.0;
    int estimate_linrate = 1; // do not use first one
    int num_lin_frames = 3;
    int n = 0;
    for (int i = estimate_linrate; i< num_lin_frames; i++){
      if(id_data[i] ==0 && id_data[i+1] ==0 && raw_data[i] !=0 && raw_data[i+1] !=0){
	rate = rate  + float(raw_data[i+1] - raw_data[i]);
	n = n + 1;
      }
    }
    // rate ==0 can occur when raw data = 0 in multiple integration data after bright previous exposure
    if(n > 0  && rate !=0){ 
      rate = rate/n;
      startVal_estimate = raw_data[0] - rate*(istart_fit+1);
      iflag_estimate = 1; 
    }
  //-----------------------------------------------------------------------
    int order = 3;
    // now do a third order fit (if there are enough points) to determine starting value
    vector<double> yobs;
    vector<double>xobs;
    int igood = 0; 
   
    for (unsigned int ii = 0; ii < raw_data.size(); ii++){
      if(id_data[ii] == 0 && raw_data[ii] !=0) { 
	yobs.push_back(double(raw_data[ii]));
	xobs.push_back(double(ii + istart_fit+1));
	igood++;
      }
    }
    vector<double> cresult(order+1);
    if(igood > min_num) {
      int  status = 0;
      int debug = 0;
      double yerror = 0;
      double chisq = 0; 
      vector<double> ycorrected(igood);
      vector<double> sigma(order+1);
      
      status = Poly_Fit(xobs,yobs,3,cresult,ycorrected,sigma,chisq,yerror,debug);
      startVal_fit = cresult[0];
      iflag_fit = 1; 
    }
    //-----------------------------------------------------------------------		
    if(iflag_fit ==1 && iflag_estimate ==1){ 
      if(startVal_fit > raw_data[0] ){
	startVal = startVal_estimate;
      } else {
	startVal = startVal_fit;
      }
    }
    if(iflag_fit ==0 and iflag_estimate ==1) startVal = startVal_estimate; 
    if(iflag_fit ==1 and iflag_estimate ==0) startVal = startVal_fit;
  }
  //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  float startCorFac = 0.0;
  float coorFactor = 1.0;  
  float startVal3 = startVal*startVal*startVal;

  if(lin_order ==2) startCorFac =  lin[1] + (lin[2]*startVal) ;
  if(lin_order ==3) startCorFac =  lin[1] + (lin[2]*startVal) + (lin[3]*startVal*startVal) ;
  if(lin_order ==4) startCorFac =  lin[1] + (lin[2]*startVal) + (lin[3]*startVal*startVal) + (lin[4]*startVal3) ;
  if(lin_order ==5) startCorFac =  lin[1] + (lin[2]*startVal) + (lin[3]*startVal*startVal)+ (lin[4]*startVal3) +  (lin[5]*startVal3*startVal);

  for (unsigned int i = 0 ; i < raw_data.size() ; i++){
    if(id_data[i] == 0){

      float data3 = raw_data[i]*raw_data[i] *raw_data[i];      

      if(lin_order ==2) coorFactor =  lin[1] + (lin[2]*raw_data[i]);
      if(lin_order ==3) coorFactor =  lin[1] + (lin[2]*raw_data[i])+  (lin[3]*raw_data[i]*raw_data[i]) ;
      if(lin_order ==4) coorFactor =  lin[1] + (lin[2]*raw_data[i]) + (lin[3]*raw_data[i]*raw_data[i])  + (lin[4]*data3) ;
      if(lin_order ==5) coorFactor =  lin[1] + (lin[2]*raw_data[i]) + (lin[3]*raw_data[i]*raw_data[i]) +  (lin[4]*data3) + (lin[5]*data3*raw_data[i]) ;


      float DN_0 = (startVal*startCorFac + lin[0])  ;
      if(apply_lin_offset == 0){
	DN_0 = 0;
	startVal = 0.0;
      }
      raw_data[i] = (raw_data[i]*coorFactor + lin[0])  - DN_0 + startVal;
      

      if(write_corrected_data) lin_cor_data[i] = raw_data[i]; 
	//_______________________________________________________________________
    } else {
      if(write_corrected_data) lin_cor_data[i] = strtod("NaN",NULL); //  
    }
  }// end loop over raw_data

  if(linflag & CDP_NOLINEARITY)     quality_flag = quality_flag + UNRELIABLE_LIN ;
}


  //-----------------------------------------------------------------------
void miri_pixel::CorrectNonLinearity(const int write_corrected_data,
				     const int apply_rscd_cor,
				     int linflag,
				     int lin_order,
				     vector<float> lin){


  if(is_ref) { //Reference Pixe (no  correction determined)
    if(write_corrected_data==1 || apply_rscd_cor == 1) {
      for (unsigned int i = 0 ; i < raw_data.size() ; i++){
	lin_cor_data[i]= raw_data[i]; // initialize 
      }
    }
    return;
  }

  if (pix_x == -144 && pix_y == 133) {
    cout << "linflag " << linflag << endl;
  } 
  //-----------------------------------------------------------------------
  if(linflag & CDP_NOLINEARITY    ) { //  no linearity correction

    signal = strtod("NaN",NULL);
    signal_unc = strtod("NaN",NULL);
    zero_pt = strtod("NaN",NULL);
    read_num_first_saturated = 0;
    num_good_reads = 0; 

    quality_flag = quality_flag + UNRELIABLE_LIN ;

    if(write_corrected_data==1 || apply_rscd_cor == 1) { // pixel either is a bad pixel or has no non-linearity correction
      for (unsigned int i = 0 ; i < raw_data.size() ; i++){
	lin_cor_data[i] = (strtod("NaN",NULL)); //  
      }
    }

    return;
  }
  //-----------------------------------------------------------------------
  // Lin order = 3 only solution now, 
  //  lin[0] = 1

  vector <float> coeff;
  coeff.push_back(lin[1]);
  coeff.push_back(lin[2]);
  coeff.push_back(lin[3]);

  if(pix_x == -144 && pix_y == 133) {
    cout << coeff[0] << " " << coeff[1] <<  " " << coeff[2] << endl;
  }

  vector<float> lin_cor(raw_data.size());
  lin_cor[0] = raw_data[0];
  
  for (unsigned int i = 1 ; i < raw_data.size() ; i++){
    if(id_data[i] == 0){
      float aveqe = poly_ave(raw_data[i-1], raw_data[i],coeff);
      lin_cor[i] = lin_cor[i-1] + (raw_data[i] - raw_data[i-1]) /aveqe;

      if(pix_x == -144 && pix_y == 133) {
	cout << "raw " << i << " " << raw_data[i] << " " << lin_cor[i] << endl;
      }
    }
  }// end loop over raw_data
  for (unsigned int i = 1 ; i < raw_data.size() ; i++){
    if(id_data[i] == 0){
      raw_data[i] = lin_cor[i];
      if(write_corrected_data || apply_rscd_cor == 1 ) lin_cor_data[i] = lin_cor[i];
    } else {
      if(write_corrected_data || apply_rscd_cor == 1) lin_cor_data[i] = strtod("NaN",NULL); //  
    }
  }
}


float miri_pixel::poly_ave(float a, float b, vector<float> coeff){
  float outavg = 0;
  if( b ==  a) {
    outavg = 1;
  } else {
    outavg = (1.0/(b-a)) * ((b + 
				coeff[0] * b*b/2.0 + 
				coeff[1] * b*b*b/3.0 +
				 coeff[2] * b*b*b*b/4.0) -
				(a +
				 coeff[0] * a*a/2.0 +
				 coeff[1] * a*a*a/3.0 +
				 coeff[2] * a*a*a*a/4.0));

    if(pix_x == -144 && pix_y == 133){
      cout << "a b " << a << " " << b <<endl;
      
      cout << "coeff" << coeff[0] <<  " " << coeff[1] << " " << coeff[2] << endl;
    }
  }

  return outavg;
}


//_______________________________________________________________________
void miri_pixel::SubtractResetCorrection(const int write_corrected_data,
					 short dq_flag, 
					 vector<float> areset){
						  

  if(is_ref) { //Reference Pixel (no  correction determined)
    if(write_corrected_data==1) {
      for (unsigned int i = 0 ; i < raw_data.size() ; i++){
	reset_cor_data[i]= raw_data[i]; // initialize 
      }
    }
    return;
  } 

  //-----------------------------------------------------------------------
  if(dq_flag & CDP_DONOT_USE) { // pixel does not have a valid reset  correction
    if(write_corrected_data==1) { 
      for (unsigned int i = 0 ; i < raw_data.size() ; i++){
	reset_cor_data[i] = (strtod("NaN",NULL)); //

      }
    }

    signal = strtod("NaN",NULL);
    signal_unc = strtod("NaN",NULL);
    zero_pt = strtod("NaN",NULL);
    read_num_first_saturated = 0;
    num_good_reads = 0;
    
    process_flag = 0; 
    // If no reset exists then Stop processing this pixel (Something wrong with pixel) 
    quality_flag = quality_flag + UNRELIABLE_RESET ;
    return;
  }
//-----------------------------------------------------------------------
  // Valid data to correct
  unsigned int dsize =  areset.size(); // planes of reset read in 
    for (unsigned int i = 0 ; i < raw_data.size() ; i++){
      // Do not check id_data because we use the reset corrected
      // data to derive the linearity correction - only step
      // that we need all the data corrected. 
      //      if(id_data[i] == 0){
	float ycorr = 0;
	if(i < dsize ) ycorr = areset[i];
	if(i >= dsize) {
	  ycorr = areset[dsize-1];
	}

	raw_data[i] = raw_data[i] - ycorr;

	if(write_corrected_data) reset_cor_data[i] = raw_data[i];
	//      } else {
	//if(write_corrected_data) reset_cor_data[i] = strtod("NaN",NULL); //  
	// }

    }// end loop over raw_data
    if(dq_flag & CDP_NORESET)     quality_flag = quality_flag + UNRELIABLE_RESET ;
}
//_______________________________________________________________________

void miri_pixel::ApplyMULTRSCD(const int write_corrected_data,
			       int n_reads_start_fit,
			       int nframes,
			       int video_offset_rscd,
			       float lastframeDN,
			       float lastframeDN_sat,
			       float sat,
			       float mult_alpha,
			       float mult_min_tol,
			       vector<float> mult_a,
			       vector<float> mult_b,
			       vector<float> mult_c,
			       vector<float> mult_d,
			       float rscd_alpha,
			       float rscd_min_tol,
			       float rscd_a0,
			       float rscd_a1,
			       float rscd_a2,
			       float rscd_a3){


  lastframeDN = lastframeDN - video_offset_rscd;
  lastframeDN_sat = lastframeDN_sat - video_offset_rscd;

  if(is_ref) { //Reference Pixel (no  correction determined)
    if(write_corrected_data==1) {
      for (unsigned int i = 0 ; i < raw_data.size() ; i++){
	rscd_cor_data[i]= raw_data[i]; // initialize 
      }
    }
    return;
  } 

  if(lastframeDN == NO_SLOPE_FOUND) {
    cout << " Can not use last frame to make correction for MULT/RSCD " << endl;
    process_flag = 0;
    quality_flag = quality_flag + NO_RSCD_CORRECTION ;
    return;
  }

  int debug = 0;
  if(pix_x == 181 && pix_y == -161) debug = 1;
  
  // ______________________________________________________________________
  // mult correction (secondard correction) 
  vector<float> mult_correct(raw_data.size(),0);
  if(lastframeDN > mult_min_tol){ // only correct data if lastframe last in > minimum tolerance
    float A = 0;
    float B = 0;

    if(lastframeDN < (sat - video_offset_rscd)) { 
      A = (mult_a[1] * lastframeDN + mult_a[0])/(nframes);
      B = (mult_b[1] * lastframeDN + mult_b[0])/(nframes);
    } else {
      A = (mult_c[1] * lastframeDN_sat + mult_c[0])/(nframes);
      B = (mult_d[1] * lastframeDN_sat + mult_d[0])/(nframes);
    }

    if(debug == 1) cout << "Terms" << A << " " <<B <<  " " << mult_a[0] << " " << mult_a[1] << " " <<
		     mult_b[0] << " " << mult_b[1] << " " << mult_alpha << endl;

    for (unsigned int i = 0 ; i < raw_data.size()  ; i++){ // loop over the number of frames 
      float eterm = exp(0.0001 * mult_alpha *  (raw_data[i]-video_offset_rscd));
      float corr =  A*eterm + B;
      mult_correct[i]= corr;
      if(debug == 1) cout << "Mult corr" << i+1 << " " << mult_correct[i] << " " <<
		       A << " " << B << " " << eterm << " " << mult_alpha << " " <<
		       raw_data[i] - video_offset_rscd << endl;
    }

    if(debug == 1) cout  << " mult corr" << lastframeDN << " " << sat-video_offset_rscd <<  " " 
			 << mult_min_tol << " " << nframes <<  endl;

  }
  // ______________________________________________________________________
  // rscd correction   
  vector<float> rscd_correct(raw_data.size(),0);

  if(debug == 1) cout<< "rscd int 1 parms" << rscd_min_tol << " " << video_offset_rscd << " " << lastframeDN << endl;
  
  if(lastframeDN >(rscd_min_tol)){ // only correct data if lastframe last in > minimum tolerance

    float scale = 0;
    float lastframeDN2 = lastframeDN * lastframeDN;
    scale = rscd_a0 + rscd_a1*lastframeDN + rscd_a2*lastframeDN2 + rscd_a3* lastframeDN2*lastframeDN;
    if(debug == 1) {
      cout << "scale " << scale << endl;
      cout << rscd_alpha << " " << rscd_a0 << " " << rscd_a1 << " " << rscd_a2 << " " << rscd_a3 << endl;      
    }
    for (unsigned int i = 0 ; i < raw_data.size()  ; i++){ // loop over the number of frames 
      float eterm = exp(rscd_alpha * (n_reads_start_fit+ i + 1)) ;
      float corr = 0;
      if(scale > 0){ 
	corr =  scale*eterm;
      }
      rscd_correct[i]= corr;
      if(debug == 1) cout << " rscd_correct " << scale << " " << eterm << " " << rscd_correct[i] << endl;
    }
    
    vector<float> total_correct(raw_data.size(),0.0);
    for (unsigned int i = 0 ; i < raw_data.size()  ; i++){ // loop over the number of frames
      total_correct[i] = rscd_correct[i] + mult_correct[i];
      if(debug ==1) {
	cout << "total" << i << " " << total_correct[i] << " " << rscd_correct[i] << " " << mult_correct[i]  << endl; 
      }
    }
    vector<float> new_correct(raw_data.size(),0.0);
    new_correct[raw_data.size()-1] = -total_correct[raw_data.size()-1];
    if(debug == 1) cout << "set up" << raw_data.size() -1 << " " << new_correct[raw_data.size()-1] << endl;
    for (unsigned int i = 0 ; i < raw_data.size() -1 ; i++){ // loop over the number of frames 
      new_correct[raw_data.size()-2-i] = new_correct[raw_data.size()-1-i]- total_correct[raw_data.size()-2-i];
      if(debug == 1) cout << "applying " << raw_data.size() << " " << raw_data.size()-2-i << " " <<  raw_data.size()-1-i << endl;
    }
    // for (unsigned int i = 0 ; i < raw_data.size()  ; i++){ // loop over the number of frames 
    //  new_correct[raw_data.size()-1-i] = new_correct[raw_data.size()-i]- total_correct[raw_data.size()-1-i];
    //}

    for (unsigned int i = 0 ; i < raw_data.size()  ; i++){ // loop over the number of frames 
      if(debug == 1 || fabs(new_correct[i]) > 5000 ) {
	cout << " RSCD correction " << pix_x << " " << pix_y << " " << i << " " <<  
	  raw_data[i] << " " << new_correct[i]  << " " <<
	  raw_data[i] - new_correct[i]  << endl;
	cout << rscd_correct[i] << " "  << mult_correct[i] << endl;
	debug = 1;
	
      }
      raw_data[i] = raw_data[i] - new_correct[i];
      if(write_corrected_data) rscd_cor_data[i] = raw_data[i];
    }// end loop over raw_data.size: number of frames in integration

  } else {  //end loop datamult > min_tol

    if(write_corrected_data==1) {
      for (unsigned int i = 0 ; i < raw_data.size() ; i++){
	rscd_cor_data[i]= raw_data[i]; // initialize 
      }
    }
  }
}

//_______________________________________________________________________
void miri_pixel::ApplyLastFrameCorrection(const int write_corrected_data,
					  float data_row_below,
					  int dq_row_below,
					  vector<float> a_even, vector<float> b_even,
					  vector<float> a_odd, vector<float> b_odd){


  // frame to correct						  
  int iframe = raw_data.size() -1 ;
  lastframe_cor_data = raw_data[iframe]; // initialize to raw data

  //-----------------------------------------------------------------------
  if(is_ref || pix_y <= 2) { //Reference Pixe (no  correction determined)
    return;
  } 

  //-----------------------------------------------------------------------
  if(dq_row_below !=0  ) { // pixel does not have a valid lastframe correction

      // set quality flag
      quality_flag = quality_flag + NOLASTFRAME ;
      return;
  }
  //-----------------------------------------------------------------------
  // Valid data to correct

  if(id_data[iframe] == 0){

    if(is_even ==1){
      //cout << " even data " <<  a_even[channel-1] << " " << b_even[channel-1] << endl;
      raw_data[iframe] = raw_data[iframe] + data_row_below*a_even[channel-1] + b_even[channel-1];
    } else {
      //    cout << " odd data " << a_odd[channel-1] << " " << b_odd[channel-1] << endl;
      raw_data[iframe] = raw_data[iframe] + data_row_below*a_odd[channel-1] + b_odd[channel-1];
    }


    lastframe_cor_data = raw_data[iframe];      


  } 



}

//_______________________________________________________________________

//_______________________________________________________________________

void miri_pixel::SubtractDarkCorrection(const int write_corrected_data,
					short dq_flag, 
					vector<float> adark){

  //-----------------------------------------------------------------------
  if(dq_flag & CDP_DONOT_USE ) { // pixel does not have a dark correction
    if(write_corrected_data==1) { 
      for (unsigned int i = 0 ; i < raw_data.size() ; i++){
	dark_cor_data[i] = (strtod("NaN",NULL)); //
      }
    }

    signal = strtod("NaN",NULL);
    signal_unc = strtod("NaN",NULL);
    zero_pt = strtod("NaN",NULL);
    read_num_first_saturated = 0;
    num_good_reads = 0;
    
    process_flag = 0; 
    // If no dark exists then Stop proceSssing this pixel (Something wrong with pixel) 
    quality_flag = quality_flag + UNRELIABLE_DARK ;
    return;
  }


  //-----------------------------------------------------------------------
  // Valid data to correct

  //-----------------------------------------------------------------------
  
  unsigned int dsize =  adark.size(); // planes of dark read in 
    for (unsigned int i = 0 ; i < raw_data.size() ; i++){
      if(id_data[i] == 0){
	float ycorr = 0;
	if(i < dsize ) ycorr = adark[i];

	raw_data[i] = raw_data[i] - ycorr;
	if(write_corrected_data) dark_cor_data[i] = raw_data[i]; 
      } else {
	if(write_corrected_data) dark_cor_data[i] = strtod("NaN",NULL); 
      } 
    }// end loop over raw_data
    if(dq_flag & CDP_NODARK)     quality_flag = quality_flag + UNRELIABLE_DARK ;

}

//*****************************************************************************************


void miri_pixel::PrintData(){
  cout << " Data for pixel (1032 X 1024) " << pix_x << " " << pix_y << endl;
  cout << " quality flag    " << quality_flag << endl;
  cout << " number of ramps " << raw_data.size() << endl;
  cout << " number of  segments " << num_segments << endl;
  cout << " number of good segments " << num_good_segments << endl;
  cout << " number of good reads " << num_good_reads << endl;
  for (unsigned int i = 0 ; i < raw_data.size() ; i++){
    cout << " ramp,raw data,id " << i << " " << raw_data[i] <<
      " " << id_data[i] <<endl;
  }
  for (int i = 0; i< num_segments; i++){

    cout << " Start, End of Segment " << seg_begin[i] << " " << seg_end[i] << endl;
  }
  for (unsigned int i = 0; i < seg_slope.size(); i++){
    cout << " Segment Flag " << seg_flag[i] << endl;
    cout << " Segment Slope " << seg_slope[i] << endl;
  }


}

//_______________________________________________________________________
void miri_pixel::PrintPixel(){
  cout << " Data for pixel (1032 X 1024)   " << pix_x << " " << pix_y << endl;
  cout << " quality flag    " << quality_flag << endl;

}

void miri_pixel::PrintResults(){
  cout << " Data for pixel (1032 X 1024)   " << pix_x << " " << pix_y << endl;
  cout << " Slope   " << signal<< endl;

}

//_______________________________________________________________________
vector<int> miri_pixel::GetFlags(int &flag_pos, int &flag_neg){
  vector<int> flags;
  flag_pos = 0;
  flag_neg = 0; 
  int nid = id_data.size();
  for (int i = 0; i< nid; i++){
    if(id_data[i] !=0 ){
      flags.push_back(id_data[i]);
      if(id_data[i] == COSMICRAY_ID) flag_pos = 1;
      if(id_data[i] == COSMICRAY_NEG_ID) flag_neg = 1;
    }
  }
  return flags;
}
				   

//_______________________________________________________________________
// in a pixel's sample up the ramp values = find all the segments making
// up the integration. 
// 7-27-09 changed finding segments so that noise spikes are not counted in
// finding the segments (they are later ignored when finding the slope).

void miri_pixel::FindSegments(){

  num_segments  =0;
  int limit = 0; 

  // ignore the cases where id_data = NOISE_SPIKE_UP_ID, REJECT_AFTER_NOISE_SPIKE or BadFrame (corrupt data)  (noise jump)
  long n = id_data.size();
  vector<int> id_temp(n);
  copy(id_data.begin(),id_data.end(),id_temp.begin());
  replace(id_temp.begin(),id_temp.end(),NOISE_SPIKE_UP_ID,0);
  replace(id_temp.begin(),id_temp.end(),NOISE_SPIKE_DOWN_ID,0);
  replace(id_temp.begin(),id_temp.end(),REJECT_AFTER_NOISE_SPIKE,0);
  replace(id_temp.begin(),id_temp.end(),BADFRAME,0);


  vector<int>::iterator iter = id_temp.begin();
  vector<int>::iterator iter_start = id_temp.begin();
  vector<int>::iterator iter_end = id_temp.end();


  while ( iter  < iter_end) {
    // find the beginning of the current segment
    while (  (iter < iter_end) && (*iter != 0)) iter++;
    int istart = iter - iter_start;
    while (  (iter < iter_end) && (*iter == 0)) iter++;
    int iend = iter - iter_start ;

    iend = iend -1; // really it is one less

    
    if( (iend - istart) > limit ) { // segment has to have more than 1 point
      seg_end.push_back(iend);
      seg_begin.push_back(istart);
      num_segments++;
      
    }else if( (iend - istart) == limit )   {
      if(id_data[istart] ==0)id_data[istart] = SEG_MIN_FAILURE;
      //cout << " segment 1 point " << iend << " " << istart << " " << pix_x << " " << pix_y << endl;
    }

  } 
}


//_______________________________________________________________________
// Calculate the slope of each segment
//
void miri_pixel::CalculateSlopeNoErrors(int start_fit,int xdebug, int ydebug){
  // case where uncertainties are unknown but  equal


  rms = 0;
  num_good_reads = 0;
  // loop over all the segments and find the slope, unc and zero_pt for each segment

  int debug = 0;
  if(pix_x == xdebug && pix_y == ydebug) debug = 1;
 
  for (int i = 0; i< num_segments ; i++){
    float s(0.0);
    float sx(0.0);
    float sxx(0.0);
    float sy(0.0);
    
    vector<int>::iterator iter_id = id_data.begin();
    vector<float>::iterator iter_data = raw_data.begin();

    for (int k = seg_begin[i] ; k <= seg_end[i]; k++){
     if( *(iter_id+k)  ==0) {
       float x  = float(k - seg_begin[i]);
       s+= 1.0;
       sx += x ;
       sxx += (x)*(x);
       sy += *(iter_data +k);

       if(debug == 1) cout << " CalculateSlopeNoErrors (x,sx,sy,data value)  " << s << " " << sx << " " << sy 
			   << " " << *(iter_data+k) << endl;

     }   
    }

    float SxS = sx/s;

    float stt(0.0);
    float ty(0.0);
    for (int k = seg_begin[i] ; k <= seg_end[i]; k++){
     if( *(iter_id+k)  ==0) {
       float x  = float(k - seg_begin[i]);
       float t = x - SxS;
       stt += t*t;
       ty += *(iter_data+k) * t;
     }   
    }
   

    int flag = 1;
    float intercept = NO_SLOPE_FOUND;
    float Slope = NO_SLOPE_FOUND;
    float Slope_unc = NO_SLOPE_FOUND;
    float Zero_pt = NO_SLOPE_FOUND;
    float RMS = NO_SLOPE_FOUND;

    
  // when you don't know the individual measurement errors - need to adjust
  // how we find the variance in the slope measurement - see Numerical Recipes
  // in C, page 664. 

    if(s >= 2) {

      flag = 0;
      Slope  = ty/stt;

      intercept = (sy - (sx*Slope))/s;

      float var(0.0);
      float vari(0.0);

      for (int k = seg_begin[i] ; k <= seg_end[i]; k++){
	if( *(iter_id+k) ==0) {
	  int x =k -seg_begin[i];
	  vari = *(iter_data+k) - intercept - Slope*x;
	  var += vari * vari;
	}
      }


      float delta = s*sxx - sx*sx;
      var = var/(s-2);                     // See Bevington pg 106
      RMS= sqrt(var);
      Slope_unc = sqrt ((s * var)/delta); // see Bevington pg 109, eq 6.23 
      if(debug == 1) cout << " CalculateNoErrors: s var delta: "  << s << " " << var << " " << delta << endl;


      // 
      if(s ==2 || Slope_unc == 0.0) { // Slope_unc can = 0 if slope fit and data point equal. 
	Slope_unc = 1.0;
      }
	  

      int z_pt = seg_begin[i]+start_fit +1; // +1 because data from frame 1 occurs frame time=1 
      //      cout << z_pt << " " << start_fit << " " << seg_begin[i] << endl;

      
                                            // we want zero pt at x = 0  
      // y = mx + b (zero pt where x  = -z_pt zero point of entire ramps 

      Zero_pt = intercept - z_pt*Slope;    

    }
    

    if(debug ==1)  cout << " CalculateNoErrors Slope, Slope unc, flag: "  <<  Slope <<  " " << Slope_unc << " " << 
      flag << endl;
    seg_flag.push_back(flag);
    seg_slope.push_back(Slope);
    seg_slope_unc.push_back(Slope_unc);
    seg_y_intercept.push_back(intercept);
    seg_zero_pt.push_back(Zero_pt);
    seg_num_good_reads.push_back(int(s));
    seg_rms.push_back(RMS);

  } // end looping over segments

}



//_______________________________________________________________________
// Calculate the slope of each segment
//
void miri_pixel::CalculateSlope(int start_fit, float gain, int find_correlated, int xdebug, int ydebug){

  rms = 0;
  num_good_reads = 0;
  // loop over all the segments and find the slope, unc and zero_pt for each segment

  int debug = 0;
  if(pix_x == xdebug && pix_y == ydebug) debug = 1; 

  for (int i = 0; i< num_segments ; i++){
    float s(0.0);
    float sx(0.0);
    float sxx(0.0);
    float sxy(0.0);
    float sy(0.0);
    int n(0);
    
    vector<int>::iterator iter_id = id_data.begin();
    vector<float>::iterator iter_data = raw_data.begin();


    for (int k = seg_begin[i] ; k <= seg_end[i]; k++){
     if( id_data[k]  ==0) {
       float x  = float(k - seg_begin[i]);



       float tmp_s = 1.0/(raw_data_var[k]);
       s+= tmp_s;
       sx += x*tmp_s ;
       sxx += (x)*(x)*tmp_s;
       sy += raw_data[k] * tmp_s;
       sxy += raw_data[k]*x*tmp_s;

       if(debug ==1) cout << " CalculateSlope: " << k << " " << x << " " << raw_data[k] <<  " " << raw_data_var[k]<<
	 " " << s << " " << sx << " " << sxx << endl;

       n++;
     }   
    }

    int flag = 1;
    float intercept = NO_SLOPE_FOUND;
    float Slope = NO_SLOPE_FOUND;
    float Slope_unc = NO_SLOPE_FOUND;
    float Zero_pt = NO_SLOPE_FOUND;
    float RMS = NO_SLOPE_FOUND;
    
    if(n >= 2) {

      flag = 0;
      float delta = s*sxx - (sx*sx);
      intercept = (sxx*sy - sx*sxy)/delta;
      Slope  =( (s*sxy) - (sx*sy) )/delta;
      Slope_unc = s/delta;

      if(debug ==1) cout << " CalculateSlope (slope, slope unc)  " << Slope << " " << Slope_unc << endl;
      
      if(n > 2) { 

	float var(0.0);
	float vari(0.0);

	for (int k = seg_begin[i] ; k <= seg_end[i]; k++){
	  if( *(iter_id+k) ==0) {
	    int x =k -seg_begin[i];
	    vari = *(iter_data+k) - intercept - Slope*x;
	    var += vari * vari;
	  }
	}
	var = var/(n-2);                     // See Bevington pg 106
	RMS= sqrt(var);

      }

     float unc_correlated = 0.0;
     if(find_correlated && Slope > 0.0){
	  unc_correlated = CalculateCorrelatedUncertainty(i,s, sx,  gain, Slope, intercept, delta);
	  Slope_unc = unc_correlated + Slope_unc;
	  if(debug ==1) cout << " Calculate Slope unc_correlated: " << unc_correlated << " " << Slope_unc << endl;
     } 
                  
      if(n ==2) {
	RMS = 1.0;
      }
	  	
      Slope_unc = sqrt (Slope_unc); 

      int z_pt = seg_begin[i]+start_fit +1; // +1 because data from frame 1 occurs frame time=1 
                                            // we want zero pt at x = 0

      //cout << z_pt << " " << start_fit << " " << seg_begin[i] << endl;

      // y = mx + b (zero pt where x  = -z_pt zero point of entire ramps 

      Zero_pt = intercept - z_pt*Slope;    

    }

    if(debug == 1) cout <<" Calculate Slope (Slope, Slope unc,flag ): " <<  Slope << " " << Slope_unc << " " << flag <<  endl;
    seg_flag.push_back(flag);
    seg_slope.push_back(Slope);
    seg_slope_unc.push_back(Slope_unc);
    seg_y_intercept.push_back(intercept);
    seg_zero_pt.push_back(Zero_pt);
    seg_num_good_reads.push_back(int(n));
    seg_rms.push_back(RMS);
    


  } // end looping over segments

}


//_______________________________________________________________________
// Calculate the Error plane on the slope with correlated reads
// Need to already have slope and y-intercept figured out y = a + bx
// Using the slope, intecept determine simga_p = [sqrt(y_i - y_i-1) * gain]/gain


//
float miri_pixel::CalculateCorrelatedUncertainty(int iseg, float S, float SX, float gain, float Slope, float y_int, float Delta){

  rms = 0;
  num_good_reads = 0;

  float delta2 = Delta*Delta;

  float new_s(0.0);
  float new_sx(0.0);
  float sigma_b(0.0);
 
  for (int k = seg_end[iseg]; k >seg_begin[iseg];k--){
      
       float x  = float(k - seg_begin[iseg]);
       float new_y = x*Slope + y_int;
       float new_y_1 = (x-1)*Slope + y_int;
       float p_var = (new_y - new_y_1)/gain;
       float tmp_s = 1.0/(raw_data_var[k]);

       new_s+= tmp_s;
       new_sx += x*tmp_s ;
       float sum_val = 	S*new_sx - SX*tmp_s;
       sigma_b = (p_var/delta2) * (sum_val*sum_val);
 }

	return sigma_b;

}


//_______________________________________________________________________


//_______________________________________________________________________
// Find the average slope of all the segments. Only include those segments
// the met certain requirements
// 
void miri_pixel::FinalSlope(float slope_seg_cr_sigma_reject,
			    int start_fit, 
			    int n_frames_reject_after_cr,
			    int cr_min_good_diffs,
			    int write_detailed_cr,
			    int UncertaintyMethod,
			    ofstream& output_cr,
			    int xdebug, int ydebug){

  num_good_segments = 0;
  num_good_reads = 0;
  signal = 0.0;
  signal_unc = 0.0;
  float weight = 0.0;       //  weigthing factor for slope
  float weight_unc = 0.0;   // weighting factor for uncertainty
  float weight_unc2 = 0.0; 
  int good = 0;
  int first_i  = -1;
  int previous_i = -1;


  int debug = 0;
  if(pix_x == xdebug && pix_y == ydebug) debug = 1;

  if(debug ==1) cout << " Final Slope: Number of Segments: " << num_segments << endl;
  //_______________________________________________________________________

  // CHECK 1:  
  // check for pixels with more than 1 segment. If a  segment
  // has  # frames less than (cr_min_good_diffs)/2 point call this noise. 
  // This becomes a problem when the first segment has 2-3 frames
  // and the seconds frame has many more. 
  //  
  // The test on the checking
  // for consistent slopes can fail and the final slope is not well determined. 
  
  int limit_frames = cr_min_good_diffs/2;

  
  if(num_segments > 1) {
    for (int i = 0; i < num_segments ; i ++){
      if(debug ==1) cout << limit_frames << " " << seg_num_good_reads[i] << endl;
      if(seg_flag[i]==0 && seg_slope_unc[i] > 0.0){

	if(seg_num_good_reads[i] < limit_frames){
	  seg_flag[i] =3;

	  for (int k = seg_begin[i]; k<=seg_end[i]; k++){
	    id_data[k] = SEG_MIN_FAILURE;
	  }

	  if(write_detailed_cr == 1) {
	    output_cr << " " << endl;
	    output_cr << " The slope segment failed minimum # points: " << pix_x << " " << pix_y << endl;
	    output_cr << " Begin segment, end segment " << seg_begin[i] << " " << seg_end[i] << endl;
	    output_cr << " Point Limit, segment number: " << limit_frames << " " << seg_num_good_reads[i] << endl;
	  } 

	}// less than limit_frames
      }  
    }// end for
  }
  //_______________________________________________________________________

  // CHECK 2:
  // check that all the slopes for the segments are statistically 
  // close enough to each other. If not then are are going to call them noise
  // There may only we a few point in the first segment and many more in the second segment,
  // in that case always average then - we just can not trust first segment
  for (int i = 0; i < num_segments ; i ++){
    int this_seg_num_good_reads = seg_num_good_reads[i];
    if(UncertaintyMethod !=0) this_seg_num_good_reads =1;

    if(debug ==1) cout << " Final Slope,seg good reads, seg slope, seg flag, seg unc:  " << 
      this_seg_num_good_reads << " " << seg_slope[i] << 
      seg_flag[i] << " " << seg_slope_unc[i] << endl;
    seg_dn_jump.push_back(0.0);
    if(seg_flag[i] == 0 && seg_slope_unc[i] > 0.0) {
      good++;
      if(good == 1) { // found first good segment
	weight_unc = this_seg_num_good_reads; 
	weight =this_seg_num_good_reads *(1.0/(seg_slope_unc[i] * seg_slope_unc[i]));
	weight_unc2 = (seg_slope_unc[i] * seg_slope_unc[i]);

	signal = seg_slope[i]* weight;
	num_good_reads += seg_num_good_reads[i];  // seg_num_good_reads - set in CalculateSlope
	rms = (seg_rms[i]*seg_rms[i]) *    seg_num_good_reads[i]; 
	num_good_segments++;
	first_i = i;
	previous_i = i; 

      }

      // if there is more than 1 good  segment (cosmic ray encountered)
      if(good > 1) {
	float test_slope = signal/weight;
	float test_slope_unc =  sqrt(weight_unc/weight);

	float total_unc = weight_unc2 + (seg_slope_unc[i] * seg_slope_unc[i]);
	total_unc = sqrt(total_unc);

	float test = test_slope - seg_slope[i];
	float test_num = num_good_reads/seg_num_good_reads[i];
	
	// if the slope test is below the tolerance, slopes consistent
	// or if there are many more good read in the testing segment (first segment only 25% or less
        // point compared to testing segment
        // --- > average slopes
	if(fabs(test) <  (total_unc * slope_seg_cr_sigma_reject) || test_num < 0.25 ) {

	  float this_weight_unc = this_seg_num_good_reads; 
	  float this_weight = this_seg_num_good_reads *(1.0/(seg_slope_unc[i] * seg_slope_unc[i])); 

	  signal += seg_slope[i]*this_weight;

	  rms +=( seg_rms[i] * seg_rms[i]) * seg_num_good_reads[i];
	  weight += this_weight;
	  weight_unc += this_weight_unc;

	  //cout << seg_num_good_reads[i] << " " << seg_slope[i] << " " << this_weight << " " << weight << endl; 
	  //  cout << " # reads, unc " << seg_num_good_reads[i] << " " << seg_slope_unc[i] << " " << this_weight << " " << weight<< endl; 

	  num_good_segments++;
	  num_good_reads += seg_num_good_reads[i];
	  
	  float previous_end_pt = seg_y_intercept[previous_i] + seg_slope[previous_i]*seg_end[previous_i];
	  
	  //cout << "previous end pt " << previous_end_pt << " " << previous_i << " " <<
	  // seg_y_intercept[previous_i] << " " <<
	  // seg_slope[previous_i] <<  " " <<  seg_end[previous_i] << endl;

	  float start_pt = seg_y_intercept[i] + seg_slope[i]*(seg_end[previous_i]-seg_begin[i]);
	  float dn_jump = start_pt - previous_end_pt;
	  seg_dn_jump[i] = dn_jump;

	  previous_i = i;
	} else { // flag as unsed segment

	  seg_flag[i] = 2;

	  // adjust the starting point to be where the cosmic ray was ided
	  int istart = seg_begin[i] - 1 - n_frames_reject_after_cr;
	  if(istart < 0) istart = 0;
	  for (int k = istart; k<=seg_end[i]; k++){
	    id_data[k] = COSMICRAY_SLOPE_FAILURE;
	  }
	  if(write_detailed_cr == 1) {
	    output_cr << " " << endl;
	    output_cr << " The slope segment failed slope sigma test: " << pix_x << " " << pix_y << endl;
	    output_cr << " previous endpts " << seg_begin[previous_i] << " " << seg_end[previous_i] << endl;
	    output_cr << " Current endpts: " << seg_begin[i] << " " << seg_end[i] << endl;
	    output_cr << " Current Slope, uncertainty: " <<  test_slope << " " << test_slope_unc << endl;
	    output_cr << " Segment Slope, uncertainty: " << seg_slope[i] << " " << seg_slope_unc[i] << endl; 
	    output_cr << " Total uncertainty, slope diff, unc*sigma: "  << total_unc << " " << test << " " << total_unc * slope_seg_cr_sigma_reject << endl;
	  }
	}	
      } // end good > 1 (more than 1 segment) 


    }
  }


  if(num_good_segments >=1 ){
    signal = signal/weight;
    signal_unc = sqrt(weight_unc/weight);
    if(UncertaintyMethod !=0) signal_unc = sqrt(1.0/weight);

    rms = sqrt(rms/num_good_reads);
    zero_pt = seg_zero_pt[first_i];
  }else {
    signal = NO_SLOPE_FOUND;
    signal_unc = NO_SLOPE_FOUND;
    rms = NO_SLOPE_FOUND;
    zero_pt = NO_SLOPE_FOUND;
  }
    
  if(debug ==1) cout << " Final Slope, slope,unc, # good segs, # good reads: " <<   signal << " " << 
    signal_unc  << " " << num_good_reads << endl;
  

}

//_______________________________________________________________________
/**********************************************************************/
void miri_pixel::CalculatePixelFlag()
{
  // Quality flag already has if Bad Pixel, , No lastframe, NO DARK correction, 
  // NO linearity correciton &  Linearity out of range
  
  //  int bad_flag = 0;
  int sat_flag = 0;
  int cr_flag = 0;
  int cr_neg_flag = 0;
  int noise_jump_flag = 0;
  int lf_flag = 0;

  //  if(bad_pixel_flag ==1) bad_flag =BAD_PIXEL_ID;


  vector<int>::iterator iter = id_data.begin();

 for( ; iter!=id_data.end();++iter){

   if (*iter != 0) {

     if (*iter == HIGHSAT_ID) sat_flag = HIGHSAT_ID;
     if (*iter == COSMICRAY_ID)cr_flag = COSMICRAY_ID;
     if (*iter == COSMICRAY_NEG_ID)cr_neg_flag = COSMICRAY_NEG_ID;
     if (*iter == NOISE_SPIKE_DOWN_ID)noise_jump_flag = NOISE_SPIKE_DOWN_ID;
     if ( *iter == COSMICRAY_SLOPE_FAILURE) cr_flag = COSMICRAY_ID;

     if ( *iter == SEG_MIN_FAILURE) {
       if(num_segments >1){
	 cr_flag = COSMICRAY_ID;
       } else{
	 cr_flag = MIN_FRAME_FAILURE;
       }
     }

   }
 }// done looping over flags


  quality_flag = quality_flag + sat_flag + cr_flag + cr_neg_flag + noise_jump_flag + lf_flag  ;


 

}
