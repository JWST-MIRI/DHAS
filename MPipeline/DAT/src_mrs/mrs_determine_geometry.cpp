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
#include "mrs_CubeHeader.h"

#include "mrs_constants.h"

/**********************************************************************/
/**********************************************************************/
// channel_type = 0 or 1 

void mrs_determine_geometry(int & channel_type, const mrs_control control,
			   const mrs_preference preference,
			   const mrs_data_info data_info,
			   CubeHeader &cubeHead)


{
  

  
  int channel = channel_type + 1;
  if(data_info.SCA_CUBE == 1) channel = channel + 2;

  if(control.channel_flag ==1) {
    channel = control.channel;
    channel_type = 0;
    if(channel ==2 || channel == 4) channel_type = 1;
  }
  double plate_scale_beta = data_info.beta_delta[channel_type];
  double scale_axis1 = preference.scale_axis1[channel-1][data_info.WAVE_CUBE];
  double dispersion = preference.dispersion[channel-1][data_info.WAVE_CUBE];


  int flag_incorrect = 0;
  if(control.dispersion_flag == 1 && control.channel_flag==0) flag_incorrect  =1;
  if(control.scale_axis1_flag == 1 && control.channel_flag==0) flag_incorrect  =1;
  if(flag_incorrect == 1) {
    if(control.dispersion_flag == 1) cout << " You set the cube dispersion, but you did not specify the channel" << endl;

    if(control.scale_axis1_flag == 1) cout << " You set the cube plate scale for axis 1, but you did not specify the channel" << endl;

    cout << " Run again, and specify the channel with the -CH channel_number option " << endl;
    exit(EXIT_FAILURE);
  }

  if(control.dispersion_flag ==1) dispersion = control.dispersion;
  if(control.scale_axis1_flag ==1)  scale_axis1 = control.scale_axis1;


  dispersion = dispersion* control.bin_wave;
  scale_axis1 = scale_axis1*control.bin_axis1; //in arc sec/pixel


  cubeHead.SetChannel(channel);
  cubeHead.SetSubChannel(data_info.WAVE_CUBE);

  cubeHead.SetCdelt1(scale_axis1); 
  cubeHead.SetCdelt2(plate_scale_beta); 
  cubeHead.SetCdelt3(dispersion); 
  cubeHead.SetNSample(data_info.NSample[0]); //

  //   ***********************************************************************		
  // Cube Dimensions
  //   ***********************************************************************		
  //_______________________________________________________________________
  // Wavelength dimension - z dimension of cube
  //_______________________________________________________________________

	
  double wavemin = data_info.wave_min[channel_type];
  double wavemax = data_info.wave_max[channel_type];
  double waverange = wavemax - wavemin;

  double num = waverange/dispersion;
  long nz = long(ceil(num)) ;
  

  // redefine wavemin and wavemax to be centered between old wavemin and wavemax
  // the pad value added extra grid points (rotation and distortion will overflow the
  // boundaries) need to account for this. 


  wavemax = wavemin + (nz)*dispersion;
	
  cubeHead.SetNgridZ(nz);
  cubeHead.SetZMinMax(wavemin,wavemax);
  cubeHead.SetCrval3(wavemin);
  cubeHead.SetCrpix3(0.5);
  if(control.do_verbose) cout << "Cube wave  min, wave max dispersion, nz " << wavemin << " " << wavemax << " " << 
    dispersion << " " << nz<< endl;
  
  //_______________________________________________________________________
  // Naxis1:
  // Alpha:  Along the slice - Plate scale can vary between slices X dimension 
  // V2 
  //_______________________________________________________________________
  
  // in arc seconds
  double axis1_min = data_info.alpha_min[channel_type] ;
  double axis1_max = data_info.alpha_max[channel_type];

  cout << " Axis 1 min and max" << axis1_min << " " << axis1_max << endl;

  // in arc minutes
  if(control.V2V3 ==1){
    axis1_min = data_info.v2_min[channel_type];//change to arc seconds
    axis1_max = data_info.v2_max[channel_type];  // change to arc seconds
  }

  double axis1_range = axis1_max - axis1_min;
  double axis1_center = (axis1_max+ axis1_min)/2.0;    

  num = axis1_range/scale_axis1;
  long nx = long(ceil(num)) ;
  axis1_min = axis1_center - (nx/2.0)* scale_axis1;
  axis1_max = axis1_center + (nx/2.0)* scale_axis1;


  cubeHead.SetNgridX(nx);
  cubeHead.SetCrval1(axis1_min);
  cubeHead.SetCrpix1(0.5);
  cubeHead.SetXMinMax(axis1_min,axis1_max);
  
  if(control.do_verbose) cout << "Cube axis1 min, alpha max, plate scale, nx " << axis1_min << " " << 
    axis1_max << " " << scale_axis1 << " " << nx<< endl;
  //_______________________________________________________________________
  // Beta:  Across the slice - Y dimension
  //_______________________________________________________________________
  //cout.setf(ios::scientific);
  //cout.precision(6);

  double axis2_min = data_info.beta_min[channel_type];
  long ny = SLICENO[channel-1];  // SLICENO[21,17,16,12] in mrs_constants.h
  double axis2_max = axis2_min + (ny+1)*plate_scale_beta;
 

  if(control.V2V3 ==1) {
    axis2_min = data_info.v3_min[channel_type] ;//change to arc seconds
    axis2_max = data_info.v3_max[channel_type] ; // change to arc seconds
    double axis2_range = axis2_max - axis2_min;
    double axis2_center = (axis2_max+ axis2_min)/2.0;
    num = axis2_range/plate_scale_beta;
    ny = long(ceil(num)) ;    

    axis2_min = axis2_center - (ny/2.0)* plate_scale_beta;
    axis2_max = axis2_center + (ny/2.0)* plate_scale_beta;
  }


  cubeHead.SetNgridY(ny);
  cubeHead.SetCrpix2(0.5);
  cubeHead.SetCrval2(axis2_min);
  cubeHead.SetYMinMax(axis2_min,axis2_max);
  //***
  cubeHead.SetNumSlices(SLICENO[channel-1]);
  //***
		       
  if(control.do_verbose) cout << "Cube beta min, beta max, plate scale, ny " << axis2_min << " " <<
    axis2_max << " " <<  plate_scale_beta  << " " << ny<< endl;

  

}
