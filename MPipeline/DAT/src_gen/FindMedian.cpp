//FindMedian.cpp 
// developer: J Morrison, 2/14/2003
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <cmath>
#include <vector>
#include <algorithm>
// Routine to find the median value of an array
using namespace std;

// sort vector arr

void FindMedian(vector<float> flux, 
		  float& Median)
{

  Median = 0.0;
  sort(flux.begin(),flux.end());
  long num = flux.size();
  long even_odd = num%2;

  bool even =false;
  if(even_odd ==0)even=true;
  int imedian = -1;
  
  //  cout << "num " << num << endl;
  if(!even) {
    imedian = (num+1)/2;
    Median = flux[imedian-1];
    // cout << "odd : " << imedian << " " << Median << endl;
  }else{
    long k1 = num/2;
    long k2  = num/2 + 1;
    Median =(flux[k1-1] + flux[k2-1])/2.0;
    //cout << "even : " << k1 << " " << k2 << " " << Median << endl;
  }

}
//_______________________________________________________________________
void FindMedian2(vector<float> flux, // flux is already sorted 
		  float& Median)
{

  Median = 0.0;
  long num = flux.size();
  long even_odd = num%2;

  bool even =false;
  if(even_odd ==0)even=true;
  int imedian = -1;
  
  //  cout << "num " << num << endl;
  if(!even) {
    imedian = (num+1)/2;
    Median = flux[imedian-1];
    // cout << "odd : " << imedian << " " << Median << endl;
  }else{
    long k1 = num/2;
    long k2  = num/2 + 1;
    Median =(flux[k1-1] + flux[k2-1])/2.0;
    //cout << "even : " << k1 << " " << k2 << " " << Median << endl;
  }

}


//_______________________________________________________________________
void FindMedian3(vector<float> flux, // flux is already sorted - limit median to istart to iend 
		 int istart, int iend, float& Median)
{

  Median = 0.0;
  long num = iend - istart;
  long even_odd = num%2;

  bool even =false;
  if(even_odd ==0)even=true;
  int imedian = -1;
  
  //  cout << "num " << num << endl;
  if(!even) {
    imedian = (num+1)/2;
    Median = flux[imedian-1];
    // cout << "odd : " << imedian << " " << Median << endl;
  }else{
    long k1 = num/2;
    long k2  = num/2 + 1;
    Median =(flux[k1-1] + flux[k2-1])/2.0;
    //cout << "even : " << k1 << " " << k2 << " " << Median << endl;
  }

}
