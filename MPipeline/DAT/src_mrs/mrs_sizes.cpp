// mrs_read_pixel_mask.cpp
#include <iostream>
#include <sstream>
#include <stdio.h>
#include <stdlib.h>
#include <string>
#include <iomanip>
#include <fstream>
#include <math.h>
#include <cstdlib>
#include "fitsio.h"
#include "mrs_preference.h"
#include "mrs_data_info.h"
#include "mrs_control.h"
#include "mrs_constants.h"

/**********************************************************************/
// Description of program:
// 
/**********************************************************************/
// Read in list of input image filenames
void mrs_PixelXY_PixelIndex(const int,const int , const int ,long &);

void mrs_xy2abl(int slice_no,float beta_zero,float beta_delta,float xas, vector<float>kalpha,
		  float xls,vector<float>klambda,float ix,float iy,float &alpha,float &beta,float &lambda);


void mrs_ab2v2v3(float alpha,float beta,float v2coeff[2][2], float v3coeff[2][2],float &v2, float &v3);

int mrs_sizes(const mrs_control control,
	      const mrs_preference preference,
	      mrs_data_info &data_info)


{

  // Determine xmin and xmax 

  float alpha_min[2];
  float alpha_max[2]; 
  float lambda_min[2]; 
  float lambda_max[2]; 


  float v2_min[2];
  float v2_max[2]; 
  float v3_min[2]; 
  float v3_max[2]; 

  for (int i = 0; i < 2; i++){
    alpha_min[i] = 3000;
    alpha_max[i] = -3000;
    lambda_min[i] = 3000;
    lambda_max[i] = -3000;

    v2_min[i] = 3000;
    v2_max[i] = -3000;
    v3_min[i] = 3000;
    v3_max[i] = -3000;
  }
  // initialize slice_range_max and slice_range_min
  for (int i = 0; i < 20; i++){
    data_info.slice_range_min[0][i] = 3000.0;
    data_info.slice_range_min[1][i] = 3000.0;
   

    data_info.slice_range_max[0][i] = -3000.0;
    data_info.slice_range_max[1][i] = -3000.0;
  }
      

  long nelements = (data_info.cal_naxes[0] )  * (data_info.cal_naxes[1] ) ;
  vector<int>  channelMap(nelements); 

  if(data_info.SCA_CUBE == 0) { // ch 1 & 2

    int nslice[2];
    nslice[0] = SLICENO[0]; 
    nslice[1] = SLICENO[1];
    int channel = 0; 

    int xx1 =0;
    int xx2 = 0;
   
    for (int j = 0; j< 2; j ++){ //loop over two channels on detector
      if(j ==0) {
	xx1 = 0;
	xx2 = XMIDDLE;
	channel = 1;
      } else {
	xx1 = XMIDDLE+1;
	xx2 = 1031;
	channel = 2;
      }
      
      for (int iy = 0 ; iy< 1024; iy++){
	for (int ix = xx1; ix<= xx2; ix++){

	  long index = 0;
	  mrs_PixelXY_PixelIndex(data_info.cal_naxes[0],ix+1,iy+1,index);
	  channelMap[index] = channel-1;
	  int slice_no = data_info.slice_number[index];
	  if(slice_no !=0) data_info.slice_number[index] = data_info.slice_number[index] - channel*100;
	  slice_no = data_info.slice_number[index] - 1;

	  if(slice_no >= 0) { 
	    if(ix < data_info.slice_range_min[channel-1][slice_no] ) data_info.slice_range_min[channel-1][slice_no] = ix;
	    if(ix > data_info.slice_range_max[channel-1][slice_no] ) data_info.slice_range_max[channel-1][slice_no] = ix;
	  }
	}
      }
    }

  } else if (data_info.SCA_CUBE == 1) {
    int nslice[2];
    nslice[0] = SLICENO[2];
    nslice[1] = SLICENO[3];
    int channel = 0; 
    int xx1 =0;
    int xx2 = 0;
   
    for (int j = 0; j< 2; j ++){ //loop over two channels on detector
      if(j ==0) { //channel3
	xx1 = XMIDDLE+1;
	xx2 = 1032;
	channel = 3;
	
      } else {// channel4
	xx1 = 0;
	xx2 = XMIDDLE;
	channel =4;
      }
      
      for (int iy = 0 ; iy< 1024; iy++){
	for (int ix = xx1; ix<= xx2; ix++){
	  long index = 0;
	  mrs_PixelXY_PixelIndex(data_info.cal_naxes[0],ix+1,iy+1,index);
	  channelMap[index] = channel-3;
	  int slice_no = data_info.slice_number[index];
	  if(slice_no !=0) data_info.slice_number[index] = data_info.slice_number[index] - channel*100;
	  slice_no = data_info.slice_number[index] - 1;

	  if(slice_no >= 0) { 
	    if(ix < data_info.slice_range_min[channel-3][slice_no]) data_info.slice_range_min[channel-3][slice_no] = ix;
	    if(ix > data_info.slice_range_max[channel-3][slice_no] ) data_info.slice_range_max[channel-3][slice_no] = ix;
	  }
	}
      }
    }
  
  }

  // slice min and max referenced to 1

  for (int i = 0; i< 21 ; i++){
    data_info.slice_range_min[0][i]++;
    data_info.slice_range_max[0][i]++;
    //cout << "min & max 0 ch 3 " << i << " " << data_info.slice_range_min[0][i] << " " << data_info.slice_range_max[0][i] << endl;
   
  }

  for (int i = 0; i< 21 ; i++){
    data_info.slice_range_min[1][i]++;
    data_info.slice_range_max[1][i]++;
    //cout << "min & max 1 ch 4 " << i << " " << data_info.slice_range_min[1][i] << " " << data_info.slice_range_max[1][i] << endl;
   
  }

  

  // find min and max of alpha, lambda
  // map all the x,y values to find maximum and min

  for (int iy = 0; iy < data_info.cal_naxes[1]+1; iy++){
    for (int ix = 0; ix< data_info.cal_naxes[0]; ix++) {
      long index = 0;

      mrs_PixelXY_PixelIndex(data_info.cal_naxes[0],ix+1,iy+1,index);
      int channel = channelMap[index];
      int slice_no = data_info.slice_number[index] - 1;
      
      if(slice_no >= 0) {

	float beta_zero = data_info.beta_zero[channel];
	float beta_delta = data_info.beta_delta[channel];
	float xas = data_info.xas[channel][slice_no];
	float xls = data_info.xls[channel][slice_no];

	vector <float> kalpha;
	vector <float> klambda;
	for (int k = 0; k< NUM_COEFF; k++){
	  kalpha.push_back(data_info.kalpha[channel][slice_no][k]);
	  klambda.push_back(data_info.klambda[channel][slice_no][k]);
	}

	
	float alpha = 0.0;
	float beta = 0.0;
	float lambda = 0.0;
	float v2 = 0.0;
	float v3 = 0.0;

	float ixx = float(ix) + 1;
	float iyy = float(iy) + 1;


	mrs_xy2abl(slice_no,beta_zero,beta_delta,xas,kalpha,xls,klambda,ixx,iyy,alpha,beta,lambda);

	float xtest = 28.310396;
	float ytest = 512;
	int slice_test = 11-1;
	int ch_test = 0;

	//	xtest = 41.282537;
	//ytest = 900;
	//	slice_test = 21-1;

	//xtest = 493.977;
	//ytest = 100;
	//slice_test = 0;
	float alpha_test = 0.0;
	float beta_test = 0.0;
	float lambda_test = 0.0;


	if(slice_no == -slice_test && channel == ch_test){
	 mrs_xy2abl(slice_test,beta_zero,beta_delta,xas,kalpha,xls,klambda,xtest,ytest,alpha_test,beta_test,lambda_test);
	 cout << " Testing " << xtest << " " << ytest << " " << alpha_test << " " << beta_test << " " << lambda_test << endl;
	 cout <<  xas << endl;
	 cout << data_info.xas[0][0] << " " << data_info.kalpha[0][0][0] << endl; 
	 //for (int k = 0; k< NUM_COEFF; k++){
	 //  cout << "ch sl# k " <<  channel << " " << slice_no << " " << k <<  " " << klambda[k] << " " << kalpha[k] << endl;
	 //}
	}
	
	if(channel ==0  && ix == -59 && iy == 15){ 
	  cout << " alpha beta " << alpha << " " << beta << " " << lambda <<  " " << ix << " " <<
	    iy << " " << slice_no << " " << channel << endl;
	}
	  
	if(control.V2V3 ==1){
	  float v2coeff[NUM_V2V3_COEFF][NUM_V2V3_COEFF];
	  float v3coeff[NUM_V2V3_COEFF][NUM_V2V3_COEFF];
	  for (int k = 0; k< NUM_V2V3_COEFF; k++){
	    for (int m = 0; m< NUM_V2V3_COEFF; m++){
	      v2coeff[k][m] = data_info.v2coeff[channel][k][m];
	      v3coeff[k][m] = data_info.v3coeff[channel][k][m];
	    }
	  }
	  mrs_ab2v2v3(alpha,beta,v2coeff,v3coeff,v2,v3);


	  if(v2 < v2_min[channel]) v2_min[channel] = v2; 
	  if(v2 > v2_max[channel]) v2_max[channel] = v2; 
	  if(v3 < v3_min[channel]) v3_min[channel] = v3; 
	  if(v3 > v3_max[channel]) v3_max[channel] = v3; 
	}
	
	if(alpha < alpha_min[channel]) alpha_min[channel] = alpha; 
	if(alpha > alpha_max[channel]) alpha_max[channel] = alpha; 
	if(lambda < lambda_min[channel]) lambda_min[channel] = lambda; 
	if(lambda > lambda_max[channel]) lambda_max[channel] = lambda; 


      } // slice_no >=0
    }
  }

  //  cout << " alpha min and max 0 " << alpha_min[0] << " " << alpha_max[0] << endl;
  // cout << " alpha min and max 1 " << alpha_min[1] << " " << alpha_max[1] << endl;

  for (int i = 0; i< 2; i++){
    data_info.alpha_min[i] = alpha_min[i];
    data_info.alpha_max[i] = alpha_max[i];

    data_info.wave_min[i] = lambda_min[i];
    data_info.wave_max[i] = lambda_max[i];
    
    data_info.beta_min[i] = data_info.beta_zero[i];

    data_info.v2_min[i] = v2_min[i]*60.0;
    data_info.v2_max[i] = v2_max[i]*60.0;

    data_info.v3_min[i] = v3_min[i]*60.0;
    data_info.v3_max[i] = v3_max[i]*60.0;

    //cout << "Wavelength range  " << data_info.wave_min[i] << " " << data_info.wave_max[i] << endl;
    //cout << "Alpha range  " << data_info.alpha_min[i] << " " << data_info.alpha_max[i] << endl;
    //cout << "Beta parameters " <<data_info.beta_min[i] << " " << data_info.beta_delta[i] << endl;


      
    if(control.V2V3 ==1){
      cout << "v2 range  " << data_info.v2_min[i] << " " << data_info.v2_max[i] << endl;
      cout << "v3 range " <<data_info.v3_min[i] << " " << data_info.v3_max[i] << endl;


    }

    
  }



  return 0; // ifstream destructor closes the file
}





