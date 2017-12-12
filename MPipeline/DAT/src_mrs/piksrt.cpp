// piksrt.cpp - adapted from numerical recipes sorting routine
// sort the array arr
// return an indexing arrary of sorted elements in indx.
// This indexing array can be used to sort other arrays that
// are in the same order as array arr
// Developer: J. Morrison 1/2003.
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <cmath>
#include <vector>

using namespace std;

// sort vector arr
// return index of orginal vector sorted
void piksrt(vector <float> &arr, vector <long> &indx)
{
  long i,j,ia;
  float a;
  long n = arr.size();

  
  for(i=0;i<n;i++){
    indx.push_back(i);
  }

  for(j=1;j<n;j++){

    a=arr[j];
    ia = j;

    i = j - 1;
    while(i>=0 && arr[i] > a){
      arr[i+1] = arr[i];
      indx[i+1] = indx[i];
      i--;
    }
    arr[i+1] = a;
    indx[i+1] = ia;
  }


  //  cout << "number of elements " << arr.size() << endl;
  //  for(i=0;i<arr.size();i++){
  //    cout << "sorted " << arr[i] << " " << indx[i] << " " << i <<  endl;
  //}
  //  cout << " " << endl;
}
