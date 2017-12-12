// piksrt.cpp - adapted from numerical recipes sorting routine
// sort the array arr
// return an indexing array of sorted elements in indx.
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

  indx.push_back(0); // set index of first element
  for(j=1;j<n;j++){

    indx.push_back(j);

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

//_______________________________________________________________________
void piksrt(vector <int> &arr, vector <long> &indx)
{
  long i,j,ia;
  int a;
  long n = arr.size();

  indx.push_back(0); // set index of first element
  for(j=1;j<n;j++){

    indx.push_back(j);

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
}

//_______________________________________________________________________

// piksrt.cpp - adapted from numerical recipes sorting routine
// sort the array arr. An array of initial indexing is given
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
void piksrt2(vector <float> &arr, vector <long> &indx)
{
  long i,j,ia;
  float a;
  long n = arr.size();

  
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
}




//_______________________________________________________________________
// piksrt.cpp - adapted from numerical recipes sorting routine
// sort the array arr. An array of initial indexing is given
// return an indexing arrary of sorted elements in indx.
// This indexing array can be used to sort other arrays that
// are in the same order as array arr
// Developer: J. Morrison 1/2003.
// piksrt3.cpp 3.7.2012 - needed adapt index may not be sequential, but
// skip some  (need to keep original indexing)
 
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <cmath>
#include <vector>

using namespace std;

// sort vector arr
// return index of orginal vector sorted
void piksrt3(vector <float> &arr, vector <long> &indx)
{
  long i,j,ia;
  float a;
  long n = arr.size();

  
  for(j=1;j<n;j++){

    a=arr[j];
    ia = indx[j];

    i = j - 1;
    while(i>=0 && arr[i] > a){
      arr[i+1] = arr[i];
      indx[i+1] = indx[i];
      i--;
    }
    arr[i+1] = a;
    indx[i+1] = ia;
  }
}
