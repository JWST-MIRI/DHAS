// mrs_SubPixel.cpp - defines the SubPixel class functions. 

#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <cmath>
#include <vector>
#include <algorithm>
#include "mrs_SubPixel.h"
#include "mrs_constants.h"


void mrs_FindMedianUncertainty(const vector<float>,
			     const vector <float>,
			     float&,float&);

void mrs_FindMedian(const vector<float>,
			     float&);




// Default constructor to set initial values

SubPixel::SubPixel()
{

}

//Default destructor
SubPixel::~SubPixel()
{
  // cout <<  " Cleaning up Subpixel" << endl;
  FileNo.clear();
  PixelNo.clear();
  Slice.clear();
  IntNo.clear();
  Flux.clear();
  Uncertainty.clear();
  Overlap.clear(); // percent overlap on subpixel
  BadPixelFlag.clear();

}

//set functions:
//_______________________________________________________________________

  
void SubPixel::SetTies(const long PIXELNO, const int FILENO,
		       const int INTNO, const int SLICE,
		       const double OVER,
		       const float FLUX, const float UNCER, const int BADPIXEL)

{
  FileNo.push_back(FILENO);
  PixelNo.push_back(PIXELNO);
  Flux.push_back(FLUX);
  Uncertainty.push_back(UNCER);
  Overlap.push_back(OVER);
  IntNo.push_back(INTNO);
  Slice.push_back(SLICE);
  
  BadPixelFlag.push_back(BADPIXEL);

}

//***********************************************************************
// based on flag = decide whether to reset bad pixel flag
//***********************************************************************
void SubPixel::SetBadPixelFlag(vector <int> flag, const int BADPT)
{
  int num= flag.size();
  for(int i=0;i<num;i++){
    if(flag[i] != 0) BadPixelFlag[i] = BAD_OUTLIER;
  }
}


//***********************************************************************
int SubPixel::GetSize()const{
  int number =0;
  if(Flux.empty()) {
    number = 0;
  }
  else{
    number = Flux.size();
  }
  return number;
}

//***********************************************************************
// Average subpixel values
//***********************************************************************
int SubPixel::AverageValues(const long index, // index of subpixel for debugging
			    float &MFlux, 
			    float &MUncertainty,
			    float &TotalOverlap,
			    int &MFlag)

{
  int numberFlux = Flux.size();
  int status = 0;
  //___________________________________________________________  
  // check if the subpixel has information contained in it
  // It could be an edge pixel and has no overlap information

  MFlux = 0.0;
  MUncertainty = 0;
  TotalOverlap = 0.0;
  MFlag = 0;
    
  if(Flux.empty() || Uncertainty.empty() || Overlap.empty() ){
    // can not determine
    // just return
    MFlux = strtod("NaN",NULL);
    MUncertainty = strtod("NaN",NULL);
    MFlag = -1;
    TotalOverlap = 0;
    status = 1;
    return status;
  }

  //___________________________________________________________  
  // ave flux and uncertainty

  // check the number of badpixels 
  int numBadFlag = 0;
  int num= BadPixelFlag.size();
  for(int i=0;i<num;i++){
    if(BadPixelFlag[i] != 0 ) numBadFlag++;
  }


  // debugging 

  int debug_flag = 0;
  if(index == -298  ) {
    debug_flag = 1;
  }


  if(debug_flag ==1){
    cout << "on subpixel # " << index << " " << numberFlux << " " <<  numBadFlag << endl;

    cout << "mrs_SubPixel: AverageValues: index, flux, uncertainty, bad flag,overlap, File #, Pixel # " << endl;
    for (unsigned  int i = 0;i<Flux.size();i++){
      int y = (PixelNo[i]/1032) ;
      int x = (PixelNo[i] - (y*1032));
	
      cout << index << " " << Flux[i] << " " << Uncertainty[i] << " " <<
	BadPixelFlag[i] << " " << 
	Overlap[i]  << " " << 
	FileNo[i] << " " << PixelNo[i]  << " " << x+1 << " " << y+1 <<  endl;
    }
  }



  // if number of badpixels = number of points
  if(numBadFlag == numberFlux) {
    // can not determine - all bad
    MFlux = strtod("NaN",NULL);
    MUncertainty = strtod("NaN",NULL);
    MFlag = -1;
    TotalOverlap = 0;
    status = 0;
    return status;
  }


  // find total overlap
  for(int j = 0; j<numberFlux;j++){
    //    if(BadPixelFlag[j] == 0 )TotalOverlap  = TotalOverlap + Overlap[j];
    if(BadPixelFlag[j] == 0 )TotalOverlap++;
  }

  //_______________________________________________________________________
  // Mean based on weighting by overlap coverage
  
  status = 0;
  int iu = 0;

  for(int i = 0; i<numberFlux;i++){
    if(debug_flag ==1){ 
      cout << "mrs_SubPixel: number, badflag, flux " 
	   << numberFlux << " " << BadPixelFlag[i] << " " << Flux[i] << endl;
    }


    if(BadPixelFlag[i] == 0 && Flux[i] != 0){   // good data

      MFlux         = MFlux +(Flux[i]* Overlap[i]);
      float Uncer  = Uncertainty[i] * Overlap[i];
      MUncertainty = MUncertainty + (Uncer* Uncer);
      
      iu++ ;

      if(debug_flag == 1) {
	cout << "mrs_SubPixel " << i << " " <<Flux[i] <<  " " << Uncertainty[i] << 
	  " "  <<Overlap[i] <<  " " << MFlux << endl;
      }

    }// end good data
  } // end loop over number of fluxes
// _______________________________________________________________________
// Uncertainty = sqrt(variance)


    MUncertainty = sqrt(MUncertainty);

// _______________________________________________________________________

    if(debug_flag == 1){
      cout << "MFlux" << " " << MFlux << endl;
      cout << iu << endl;
      cout << "MUncertainty" << MUncertainty << endl;
      cout << " Total Overlap" << TotalOverlap << endl;
    }



  return status;
}

//***********************************************************************
// 

//***********************************************************************
//***********************************************************************
int SubPixel::FindMinMaxFlux(float &Min, float &Max)
{
  int numberFlux = Flux.size();
  int status = 0;

  //___________________________________________________________  
  // 


  // Find the min and max
  status = 0;
  vector<float> flux;    
  for(int i = 0; i<numberFlux;i++){
    if(BadPixelFlag[i] ==0) {
      flux.push_back(Flux[i]);
    }
  }
  status = 0;

  vector<float>::iterator maxiter;
  maxiter = max_element(flux.begin(),flux.end());
  Max = *maxiter;

  vector<float>::iterator miniter;
  miniter = min_element(flux.begin(),flux.end());
  Min = *miniter;
  return status;
}



    
//_______________________________________________________________________
//_______________________________________________________________________
//get functions:  
//_______________________________________________________________________
// print function:
void SubPixel::PrintValues() const
{
  if( FileNo.empty() ) 
    {
      cout << "No overlapping BCD pixels " << endl;
    }else{ 
    
    cout << "Number of overlapping Reduced pixels " << FileNo.size() << endl; 
    unsigned int j =0;
    for(j=0;j<FileNo.size();j++){
      cout << "   Reduced File No:   " << FileNo[j] << endl
	   << "   Reduced Pixel No:  " << PixelNo[j] <<endl
	   << "   Flux:              " << Flux[j] << endl
	   << "   Uncertainty:       " << Uncertainty[j] << endl
	   << "   Bad Pixel:         " << BadPixelFlag[j]<<endl
	   << "   overlap:           " << Overlap[j]<<endl;

    }
  }
}











