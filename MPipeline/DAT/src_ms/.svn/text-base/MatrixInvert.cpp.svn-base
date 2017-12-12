#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <cmath>
#include <vector>
#include <numeric>
#include <algorithm>
using namespace std;

vector< vector<double> >  MatrixInvert( vector< vector<double> > A, const int N )
{

  vector< vector<double> > b(N, vector<double>(N,0));
  vector< vector<double> >  Ainv = A;

  vector <double> scale(N);
  vector <int> index(N+1);     
  for (int i=0;i<N;i++) { 
    b[i][i]=1.0;
    index[i]=i;
    double scalemax=0.0;
    for (int j=0;j<N;j++) scalemax = (scalemax > fabs(A[i][j])) ? scalemax : fabs(A[i][j]);
    scale[i] = scalemax; 
  }
  int signDet=1;
  for (int k=0;k<N-1;k++) { 
    double ratiomax=0.0;
    int jPivot=k;
    for (int i=k;i<N;i++) { 
      double ratio=fabs(A[index[i]][k])/scale[index[i]]; 
      if (ratio > ratiomax) { 
	jPivot=i; 
	ratiomax=ratio; 
      }
    }int indexJ=index[k]; 
    if (jPivot != k) { 
      indexJ = index[jPivot];
      index[jPivot] = index[k]; 
      index[k] = indexJ;
      signDet *= -1; 
    }
    for (int i=k+1;i<N;i++) {
      double coeff=A[index[i]][k]/A[indexJ][k];
      for (int j=k+1;j<N;j++) A[index[i]][j] -= coeff*A[indexJ][j];
      A[index[i]][k]=coeff; 
      for (int j=0;j<N;j++) b[index[i]][j] -= A[index[i]][k]*b[indexJ][j];
    }
  }
  for (int k=0;k<N;k++) { 
    Ainv[N-1][k] = b[index[N-1]][k]/A[index[N-1]][N-1];
    for (int i=N-2;i>=0;i--) { 
      double sum=b[index[i]][k];
      for (int j=i+1;j<N;j++) sum -= A[index[i]][j]*Ainv[j][k];
      Ainv[i][k] = sum/A[index[i]][i]; 

    }
  }
  return Ainv; 
}

