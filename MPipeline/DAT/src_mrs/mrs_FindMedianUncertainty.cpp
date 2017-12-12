// mrs_FindMedianUncertainty.cpp - mips_enhancer routine
// developer : J. Morrison 2/14/2003
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <cmath>
#include <vector>
// Routine to find the median of an array and find the
// corresponding value in similarily sorted array.
// For example: Find Median flux and find uncertainty
// corresponding to this value.

using namespace std;

// sort vector arr
// return index of orginal vector sorted
void piksrt(vector <float> &arr, vector <long> &indx);

void mrs_FindMedianUncertainty( vector<float> flux, 
				vector<float> uncertainty,
				float& Median,
				float& Uncertainty)

{
  //___________________________________________________________  
  // 
  Median = 0.0;
  Uncertainty = 0.0;

  //for(long i = 0; i< flux.size();i++){
  //  cout << "unsorted flux " << flux[i] << " " << uncertainty[i] << endl;
  //}
  vector<long> iindex;
  piksrt(flux,iindex);

  //for(long i = 0; i< flux.size();i++){
  // cout << "sorted flux " << flux[i] << endl;
  //}

  long num = flux.size();
  long even_odd = num%2;

  bool even =false;
  if(even_odd ==0)even=true;
  int imedian = -1;
  
  if(!even) {
    imedian = (num+1)/2;
    Median = flux[imedian-1];
    Uncertainty = uncertainty[iindex[imedian-1]];
  }else{
    long k1 = num/2;
    long k2  = num/2 + 1;
    Median =(flux[k1-1] + flux[k2-1])/2.0;

    Uncertainty =(uncertainty[iindex[k1-1]]*uncertainty[iindex[k1-1]] +
		  uncertainty[iindex[k2-1]]*uncertainty[iindex[k2-1]]);
    Uncertainty= sqrt(Uncertainty)/2.0;
      
		  

  }
  //cout <<" Median " << Median << " " << Uncertainty << endl;
}
