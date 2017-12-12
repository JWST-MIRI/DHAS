//me_SubPixel. h Header file which defines SubPixel class 

#ifndef SUBPIXEL_H
#define SUBPIXEL_H

#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <fstream>
#include <ctype.h>
#include <vector>

using namespace std;
 
class SubPixel{
 public:
  SubPixel();       //default constructor
  ~SubPixel();      //deconstructor



  inline void SetIndex(const long INDEX){index = INDEX;}
  inline long GetIndex()const {return index;}


  void SetTies(const long, const int, 
	       const int, const int,
	       const double , 
	       const float,  
	       const float,
	       const int);



  void SetBadPixelFlag(vector <int> , const int);

  int AverageValues(const long,
		    float& ,
		    float &, 
		    float&,
		    int& );


  int FindMedianUncertainty(float& ,float &,  int);
  int FindMedianSTDEV(float& ,float &,  int);

  int FindMeanSTDEV(float& ,float &,  int);

  int FindMinMaxFlux(float &, float &);
  
  int GetSize()const;

  void PrintValues()const;


  //***********************************************************************
      // Inline functions
 //***********************************************************************
 //_______________________________________________________________________
 // copy flux
 //_______________________________________________________________________
     inline  void CopyFlux(vector <float>& FLUX){
    copy(Flux.begin(),Flux.end(),back_inserter(FLUX)); // uses push_back
  }
 //_______________________________________________________________________
 // copy uncertainty
 //_______________________________________________________________________
 inline void CopyUncertainty(vector <float>& UNCERTAINTY){
    copy(Uncertainty.begin(),Uncertainty.end(),
	 back_inserter(UNCERTAINTY)); // uses push_back
  }

 //_______________________________________________________________________
 // copy Bad Pixel
 //_______________________________________________________________________

     inline void CopyBadPixel(vector <int>& BADPIXEL){

    copy(BadPixelFlag.begin(),BadPixelFlag.end(),
	 back_inserter(BADPIXEL)); // uses push_back
  }

 //_______________________________________________________________________
 // copy  Overlap
 //_______________________________________________________________________

     inline void CopyOverlap(vector <double>& OVERLAP){
    copy(Overlap.begin(),Overlap.end(),
	 back_inserter(OVERLAP)); // uses push_back
  }

 //_______________________________________________________________________
 //_______________________________________________________________________*
      // copy Reduced File NO
 //_______________________________________________________________________

     inline void CopyReducedNo(vector <int>& FILENO){
    copy(FileNo.begin(),FileNo.end(),back_inserter(FILENO)); // uses push_back
  }

 //_______________________________________________________________________
 // copy Reduced Pixelno
 //_______________________________________________________________________

     inline void CopyPixelNo(vector <int>& PIXELNO){
    copy(PixelNo.begin(),PixelNo.end(),back_inserter(PIXELNO)); // uses push_back
  }


 //_______________________________________________________________________

     // Get Functions
 //***********************************************************************
     inline int GetFileNo(const int j)const {return FileNo[j];}
     inline long GetPixelNo(const long j)const {return PixelNo[j];}
     inline int GetFlag(const int j)const {return BadPixelFlag[j];}
     inline float GetFlux(const int j)const {return Flux[j];}
     inline float GetUncer(const int j)const {return Uncertainty[j];}
     inline double GetOverlap(const int j)const {return Overlap[j];}




  private:

  long index;
  vector <int> FileNo;
  vector <long> PixelNo;
  vector <int> Slice;
  vector <int> IntNo;
  vector <float> Flux;
  vector <float> Uncertainty;
  vector <double> Overlap; // percent overlap on subpixel
  vector <int>  BadPixelFlag;




}; 

#endif







