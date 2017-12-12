#include <iostream>
#include <string>
#include <vector>
#include <cmath>
#include <algorithm>
#include <cstdlib> // EXIT_FAILURE   , EXIT_SUCCESS
#include "fitsio.h"
#include "mrs_CubeHeader.h"
#include "mrs_ReducedData.h"
#include "mrs_ReducedHeader.h"
#include "mrs_data_info.h"
#include "mrs_constants.h"
/**********************************************************************/
void mrs_PixelXY_PixelIndex(const int,const int , const int ,long &);

void mrs_xy2abl(int slice_no,float beta_zero,float beta_delta,float xas, vector<float>kalpha,
		  float xls,vector<float>klambda,float ix,float iy,float &alpha,float &beta,float &lambda);

void mrs_ab2v2v3(float alpha,float beta,float v2coeff[2][2], float v3coeff[2][2],float &v2, float &v3);

int mrs_read_data(const int channel_type,
		  const int j, 
		  const int ntile,
		  const int V2V3, 
		  const int Interpolate,
		  const int Interpolate_distance, 
		  long &numpixels_read,
		  mrs_data_info &data_info,
		  CubeHeader cubeHead,
		  ReducedHeader ReducedHead,
		  vector<ReducedData> &Data,
		  int verbose)
                    
  
{

  int STATUS = 0;


  numpixels_read = 0;
  int status =0;

  int naxis0 = ReducedHead.GetNaxes0();
  int naxis1 = ReducedHead.GetNaxes1();
  int naxis2 = ReducedHead.GetNaxes2();


  string filename = cubeHead.GetInputFilename(j);
  int extension_num = cubeHead.GetExtensionNum(j);

  fitsfile *fptr;


/**********************************************************************/

  status = 0; // set for cfitio call
  fits_open_file(&fptr,filename.c_str(),READONLY,&status);
  if(status !=0) {
    cout << " mrs_read_data: Could not open file " << filename << " " << status << endl;
    exit(EXIT_FAILURE);
  }
/**********************************************************************/

  int hdutype = 0;

  cout << " Creating the cube from extension " << extension_num << endl;

  fits_movabs_hdu(fptr,extension_num,&hdutype,&status);
  int anynul = 0; // null values
  long n = 0;
  
  int ymin = 1;
  int ymax = 1024;
  int nSlices = cubeHead.GetNumSlices();

  // each slice has about 1024 pixels in the y direction (wavelength) and 
  // 18 to 25 pixel in the x direction (along the slice)
  // But on the detector the x values go from 1 to 1024, so we need to find the starting
  // x value of the slice and keep this value for reference.


  for (int i = 0 ; i <  nSlices; i++){ 


    
      int slice = cubeHead.GetSliceNo(i);
      int xmin = 0;
      int xmax = 0;

      xmin = data_info.slice_range_min[channel_type][slice-1] ;  // referenced from 1
      xmax = data_info.slice_range_max[channel_type][slice-1];   // referenced from 1
      if(verbose ==1) cout << xmin << " " << xmax  << endl;

      long xrange = long(xmax - xmin) + 1;
      long yrange = long(ymax - ymin) + 1;

      long num = xrange*yrange;

      vector <float> data(num);    
      vector <float> dataflag(num);    
      vector <float> dataunc(num);    

      long numI = 1;
      if(Interpolate ==1)  numI = num;
      vector <float> dataI(num);
      vector <float> dataflagI(num);
      vector <float> datauncI(num);
      
      int naxis = 3;
      long naxes[3];
      naxes[0] = naxis0;
      naxes[1] = naxis1;
      naxes[2] = naxis2;
      long inc[3] = {1,1,1};
      long fpixel[3];
      long lpixel[3];

    // lower left corner of subset
      fpixel[0]= long(xmin);
      fpixel[1]= long(ymin);
      fpixel[2]= 1;

      lpixel[0] = long(xmax);
      lpixel[1] = long(ymax);
      lpixel[2] = 1;
      if(verbose){ 
	cout << " mrs_read_data:reading first pixel " << fpixel[0] << " " << fpixel[1] << endl;
	cout << " mrs_read_data:reading last  pixel " << lpixel[0] << " " << lpixel[1] << endl;
      }


  // read in the slice - flux value

      fits_read_subset_flt(fptr, 0, naxis, naxes,
			   fpixel,lpixel,
			   inc,0,&data[0],&anynul,&status);

      if(status != 0 ) {
	cout << "mrs_read_data: fits_read_img: error reading in flux " << endl;
	cout << " Error status " << status << endl;
	cout << " File name " << filename << endl;
      }

  // read in the slice - data uncertainity
      fpixel[2]= 2;
      lpixel[2]= 2;
      fits_read_subset_flt(fptr, 0, naxis, naxes,
			   fpixel,lpixel,
			   inc,0,&dataunc[0],&anynul,&status);

      if(status != 0 ) {
	cout << "mrs_read_data: fits_read_img: error reading uncertainty" << endl;
	cout << " Error status " << status << endl;
	cout << " File name " << filename << endl;
      }


  // read in the slice - data quality flag value
      fpixel[2]= 3;
      lpixel[2]= 3;
      fits_read_subset_flt(fptr, 0, naxis, naxes,
			   fpixel,lpixel,
			   inc,0,&dataflag[0],&anynul,&status);

      if(status != 0 ) {
	cout << "mrs_read_data: fits_read_img: error reading data quality flag" << endl;
	cout << " Error status " << status << endl;
	cout << " File name " << filename << endl;
      }
      // _______________________________________________________________________
      if(Interpolate ==1) {
	long jj = 0;

	for (int iy = 0 ; iy < yrange; iy ++){
	  for (int ix = 0; ix < xrange; ix ++){
	    if(isnan(data[jj])){
	      int xstart = ix -Interpolate_distance;
	      int xend = ix + Interpolate_distance ;
	      int ystart = iy - Interpolate_distance;
	      int yend = iy + Interpolate_distance;
	      if(xstart < 0) xstart = 0;
	      if(ystart < 0) ystart =0;
	      if(xend > xrange-1) xend = xrange-1;
	      if(yend > yrange-1) yend  = yrange-1;
	      float flux = 0.0;
	      float flux_unc = 0.0;
	      float weight = 0.0;
	      float weight_unc = 0.0;
	      if(verbose) cout << " data is nan "  << ix+xmin << " " << iy+1 << endl;
	      for (int yy = ystart; yy<yend+1; yy++){
		for (int xx = xstart; xx<xend+1; xx++){
		  int newj = yy*xrange + xx;

		  if( ! isnan(data[newj]) ){ 

		    float xdist = ix - xx;
		    float ydist = iy - yy;
		    float dist= sqrt(  (xdist*xdist) + (ydist*ydist));
		    flux = flux + (data[newj] * dist);
		    flux_unc = flux_unc + (dataunc[newj] * dataunc[newj] * dist*dist); 
		    weight = weight + dist;
		    weight_unc = weight_unc + (dist*dist);
		    if(verbose) 
		      cout << " Getting " << xx << " " << yy << " " << xx+xmin << " " << yy+ymin <<  " " << 
			data[newj] << " " << dataunc[newj] << " " << dist << endl;

		  }
		} // end xx
	      } // end yy
	      
	      flux = flux/weight;
	      flux_unc = sqrt(flux_unc/weight_unc); 

	      if(verbose) cout << "combined flux: " << flux << " " << flux_unc << endl;

	      dataI[jj] = flux;
	      datauncI[jj] = flux_unc;
	      dataflagI[jj] = 1024;
	      

	    } else{
	      dataI[jj] = data[jj];
	      datauncI[jj] = dataunc[jj];
	      dataflagI[jj] = dataflag[jj];
	    }

	    jj++;

	  }// end loop over ix

	} // end loop over iy

	data.erase(data.begin(),data.end());
	dataunc.erase(dataunc.begin(),dataunc.end());
	dataflag.erase(dataflag.begin(),dataflag.end());
	copy(dataI.begin(),dataI.end(),data.begin());
	copy(datauncI.begin(),datauncI.end(),dataunc.begin());
	copy(dataflagI.begin(),dataflagI.end(),dataflag.begin());
	  
	
      } // end Interpolate == 1


      // _______________________________________________________________________
      // find the x and y value on the detector for each pixel read in.
      // These values are used to locate the correct wavelength, alpha and beta 
      // slice values from the calibration files
      long jj = 0;
      int y = 0;

      for (int iy = 0 ; iy < yrange; iy ++){
	int x =0; 
	for (int ix = 0; ix < xrange; ix ++){
	  x = ix + xmin;  // xmin indexed wrt 1
	  y = iy + ymin;  // ymin indexed wrt 1

	  float xc[4] = {float(x)-0.5,float(x)+0.5,float(x)+0.5,float(x)-0.5};
	  float yc[4] = {float(y)-0.5,float(y)-0.5,float(y)+0.5,float(y)+0.5};

	  double wavelength[4]= {0.0};
	  double alpha[4]= {0.0};

	  // get the slice number 
	  long index_detector= 0;	  
	  mrs_PixelXY_PixelIndex(naxis0,int(x),int(y),index_detector);  //
	  int slicenum = data_info.slice_number[index_detector];


	  //slicenum = 8;

	  if(slicenum == slice && slice !=0) { 
	    float beta_zero = data_info.beta_zero[channel_type];
	    float beta_delta = data_info.beta_delta[channel_type];
	    float xas = data_info.xas[channel_type][slicenum-1];
	    float xls = data_info.xls[channel_type][slicenum-1];
	    vector <float> kalpha;
	    vector <float> klambda;
	    for (int k = 0; k< NUM_COEFF; k++){
	      kalpha.push_back(data_info.kalpha[channel_type][slicenum-1][k]);
	      klambda.push_back(data_info.klambda[channel_type][slicenum-1][k]);

	    }

	    // cout << beta_zero << " " << beta_delta << endl;
	    //cout << xas << " " << xls << endl;
	    //int k = 0;
	    //for (int ii = 0 ; ii< 5; ii++){
	    // for (int jj = 0 ; jj< 5; jj++){
	    //		cout  << k << " " << kalpha[k] << " " << klambda[k] << endl;
	    //		k = k + 1;
	    // }
	    //}
	  ///________________________________________________________________________________	  

	    float alpha_center = 0.0;
	    float beta_center = 0.0;
	    float lambda_center = 0.0;

	    //float xx = 574.26012;
	    //float yy = 512;


	    mrs_xy2abl(slicenum-1,beta_zero,beta_delta,xas,kalpha,xls,klambda,float(x),float(y),alpha_center,beta_center,lambda_center);

	    //	    cout << alpha_center << " " << beta_center << " " << lambda_center << endl;
	    //exit(0);
	    float v3_center = 0.0;
	    float v2_center = 0.0;

	    float v2coeff[NUM_V2V3_COEFF][NUM_V2V3_COEFF];
	    float v3coeff[NUM_V2V3_COEFF][NUM_V2V3_COEFF];

	    if(V2V3 ==1){
	      for (int k = 0; k< NUM_V2V3_COEFF; k++){
		for (int m = 0; m< NUM_V2V3_COEFF; m++){
		  v2coeff[k][m] = data_info.v2coeff[channel_type][k][m];
		  v3coeff[k][m] = data_info.v3coeff[channel_type][k][m];
		}
	      }

	      mrs_ab2v2v3(alpha_center,beta_center,v2coeff,v3coeff,v2_center,v3_center);
	      v2_center = v2_center * 60.0; // convert to arc seconds
	      v3_center = v3_center * 60.0;
	    }


	    for (int ij = 0; ij< 4; ij++){

	      float alpha1 = 0.0;
	      float beta1 = 0.0;
	      float lambda1 = 0.0;
	      

	      mrs_xy2abl(slicenum-1,beta_zero,beta_delta,xas,kalpha,xls,klambda,xc[ij],yc[ij],alpha1,beta1,lambda1);

	      wavelength[ij] = lambda1;
	      alpha[ij] = alpha1;

	      float v2 = 0.0;
	      float v3 = 0.0;
	      if(V2V3 ==1){
		mrs_ab2v2v3(alpha1,beta1,v2coeff,v3coeff,v2,v3);
		v2 = v2 * 60.0;
		v3 = v3 * 60.0;
		alpha[ij] = v2;
	      }


	    }//end looping over  corners
	    
//_______________________________________________________________________
	  // Fill in the reduced data class
	  

	    bool this_is_a_nan = false;
	    if( isnan(data[jj])) {
	      this_is_a_nan = true;
	    }

	    
	    Data[n].SetWaveCorners(wavelength);
	    Data[n].SetAlphaCorners(alpha);

	    Data[n].SetSlice(slice);
	    if(V2V3 ==0){
	      Data[n].SetYcenter(beta_center);
	    }else {
	      Data[n].SetYcenter(v3_center);

	      }

	    Data[n].SetFlux(data[jj]);
	    Data[n].SetFileNo(j);
	    Data[n].SetIntNo(extension_num);
	    Data[n].SetPixelNo(index_detector);
	    Data[n].SetPixelX(x);
	    Data[n].SetPixelY(y);
	    Data[n].InitializeNOverlap();
	  
	    Data[n].SetInputFlag(int(dataflag[jj]));
	    Data[n].SetUncertainty(dataunc[jj]);
	  
	    if(this_is_a_nan) {
	      Data[n].SetBadPixelFlag(BAD_INPUT);
	    }else{
	      Data[n].SetBadPixelFlag(0);
	    }
	    
	    n++;
	  } // slicenum = slice

	  jj++;
	} // end loop over ix
      }// end loop over iy

  } // end loop of slices
  if(verbose) cout << " Number of pixels read in " << n << endl;
    numpixels_read = n;
  status = 0;
  fits_close_file(fptr,&status);


/**********************************************************************/


  return STATUS;

}



