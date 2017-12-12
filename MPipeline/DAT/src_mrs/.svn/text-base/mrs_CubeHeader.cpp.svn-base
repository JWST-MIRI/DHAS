// mrs_CubeHeader.cpp: defines the Mosaic Header class functions
#include <iostream>
#include <sstream>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <vector>
#include <algorithm>
#include <string>
#include  "fitsio.h"
#include "mrs_CubeHeader.h"
#include "miri_constants.h"
using namespace std;

 
// Default constructor to set initial values
//*********************************************************************** 
CubeHeader::CubeHeader()
{

}
//Default destructor
CubeHeader::~CubeHeader()
{

}
//***********************************************************************
// set functions
//***********************************************************************


//***********************************************************************
//***********************************************************************

int CubeHeader::OutFitsExist(){
  // if file does not exist status = 0
  int status = 0;
  ifstream FileExist(outputfits.c_str(),ios::in);
  if(!FileExist){
    status = 0;
  }else {
    status = 1;
  }
  return status;
}
//_______________________________________________________________________


//***********************************************************************
//Print functions
//***********************************************************************
void CubeHeader::PrintCubeInfo()const{

  cout << setiosflags(ios::fixed| ios::showpoint) << setprecision(8) << endl;
  cout << " CDELT1                       " << cdelt1 << endl; 
  cout << " CRVAL1 CRPIX1                " << crval1 << " " << crpix1 << endl;
  cout << " Alpha min,max         " << xmin << " " << xmax << endl;
  
  cout << " CDELT2                       " << cdelt2 << endl; 
  cout << " CRVAL2 CRPIX2                " << crval2 << " " << crpix2 << endl;
  cout << " Beta  slice min, max         " << ymin << " " << ymax << endl;
  cout << " CDELT3                       " << cdelt3 << endl;
  cout << " CRVAL3 CRPIX3                " << crval3 << " " << crpix3 << endl;
  cout << " Wavelength min, max          " << zmin << " " << zmax << endl;
  cout << " Size of cube                 " << ngridx << " X " << ngridy << " X " << ngridz << endl;
}

//_______________________________________________________________________
void CubeHeader::PrintCubeInfoToFile(bool WriteLog,
			 ofstream& statfile)const{


  cout << setiosflags(ios::fixed| ios::showpoint) <<setprecision(8) << endl;
  cout << "Cube Description:                    " << endl;
  if(WriteLog) statfile << "Cube Description:                    " << endl;

  cout << " Center X,Y,Z:  (CRPIX1,CRPIX2,CRPIX3)            " << 
    crpix1 << " " << crpix2 << " " << crpix3 << endl;

  if(WriteLog){
    statfile << " Center X,Y,Z:  (CRPIX1,CRPIX2,CRPIX3)            " 
	     << crpix1 << " " << crpix2 << " " << crpix3 <<endl;

  }

    cout << " Min and Max x corners:                " <<xmin << " " 
	 << xmax << endl;
    cout << " Min and Max y corners:               " <<ymin << " " 
	 <<ymax << endl;
    cout << " Min and Max z corners:               " <<zmin << " " 
	 <<zmax << endl;
    cout << " X range of Cube:            " << xmax - xmin << endl;
    cout << " Y range of Cube:            " << ymax - ymin<< endl;
    cout << " Z range of Cube:            " << zmax - zmin<< endl;

    


    cout << " Mosaic subpixel size:                   " << fabs(cdelt1)*3600.0 << " X " <<
      fabs(cdelt2)*3600.0 << endl;
    cout << " Mosaic grid size:                       " << ngridx << " X " <<
      ngridy << endl;
  
    cout << " Number of Reduced Integrations in Cube  " <<num_files << endl;


    
}



//***********************************************************************
