// me_Tile.cpp : defines the Tile class functions
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <vector>
#include <algorithm>
#include "mrs_ReducedHeader.h"

// Default constructor to set initial values

ReducedHeader::ReducedHeader()
{
  filename = "null";
  fileno = 0;
  naxis = 0;
  naxes[0] = 0;
  naxes[1] = 0;
  naxes[2] = 0;

  

}

//Default destructor
ReducedHeader::~ReducedHeader()
{

}
//***********************************************************************
//misc functions:
//***********************************************************************


// Print the current values in the header

void ReducedHeader::printHeader()const 
  
{ 
  setiosflags(ios::left); 
  cout << "Printing current  Header Values" << endl;
  cout << setw(10) << "KeyWord" << setw(20) << "Value" << setw(20) 
       << "Found" << setw(10)  << endl; 
  cout << setw(10) << "NAXIS:" << setw(20) << naxis << endl;
  for (int jj= 0;jj<naxis; jj++) {
    cout<< setw(8) << "NAXES" << jj <<":" << setw(20) << naxes[jj] << endl;
  }
  cout<< setw(10) << "EXP TIME:"<< setw(20) << exptime << endl;

  cout<< setw(10) << "Channel"  << setw(20) << Channel <<endl;
  cout<< setw(10) << "SubChannel"  << setw(20) << SubChannel <<endl;
 

}





