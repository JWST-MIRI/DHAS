// me_ReducedBCD.cpp : defines reduced data 
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <algorithm>
#include "mrs_ReducedData.h"

// Default constructor to set initial values
//_______________________________________________________________________
ReducedData::ReducedData(): FileNo(0),waveid(0),PixelNo(0),x(0),y(0),IntNo(0),slice(0),
			    flux(0.0),uncertainty(0.0), InputFlag(0), BadPixelFlag(0)
			    
{

}
//_______________________________________________________________________
//Default destructor
ReducedData::~ReducedData()
{
  //  cout << " In BCD Pixel destructor, cleaning up" << endl;
  //  SubPixelIndex.clear();
}


void ReducedData::PrintPixelInfo()
{
  cout << " FileNo: " << FileNo << endl;
  cout << " x ,y " << x << " " << y << endl;
  cout << " Pixel No " << PixelNo << endl;
  cout << " Slice No " << slice << endl;
  cout << " Corner Wavelength " << wavecorner[0] <<  " " << wavecorner[1] << " " << wavecorner[2] <<
    " " << wavecorner[3] << endl;
  cout << " Corner  Alpha" << alphacorner[0] <<  " " << alphacorner[1] << " " << alphacorner[2] <<
    " " << alphacorner[3] << endl;

}
//_______________________________________________________________________


















