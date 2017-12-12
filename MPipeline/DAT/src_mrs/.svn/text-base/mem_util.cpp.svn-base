#include <iostream>
#include <memory>

using namespace std;

/******************************** <UERROR> **********************************/
/* Note on memory errors - Newer versions of C++ will throw an exception    */
/* and abort program when you attempt to allocate too much memory using     */
/* 'new' while older versions return a null pointer.  If the former applies */
/* to your version, you will not call uerror from any of the  allocation    */
/* routines.  When I figure out how to handle the exceptions, I'll try to   */
/* get a meaningful error message out.                                      */
void uerror(char error_text[])
{
  cerr << endl;
  cerr << "******************************************" << endl;
  cerr << "****          RUN TIME ERROR!         ****" << endl;
  cerr << endl;
  cerr << error_text << endl;
  cerr << endl;
  cerr << "****      TERMINATING EXECUTION!      ****" << endl;
  cerr << "******************************************" << endl;
  cerr << endl;
  exit (8);
}
/****************************************************************************/

/************************ <SVECTOR/FREE_SVECTOR> ****************************/
short *svector(int npts)
{
  short *vector = new short[npts];

  if (!vector) uerror("allocation failure in svector()");
  memset(vector,0,npts*sizeof(short));  //Initialize!

  return vector;
}

void free_svector(short *vector)
{
  delete [] vector;
} 

/************************ <SMATRIX/FREE_SMATRIX> ****************************/

short **smatrix(int nrow, int ncol)
{
  int i;
  int n_elements=nrow*ncol;
  short **matrix;

  matrix = new short *[nrow+1];
  if (!matrix) uerror("allocation failure 1 in smatrix()");

  matrix[0] = new short[n_elements+1];
  if (!matrix) uerror("allocation failure 2 in smatrix()");

  memset(matrix[0],0,(n_elements+1)*sizeof(short));  //Initialize!
  
  matrix[1]=matrix[0]+ncol;

  for (i=2; i<=nrow; i++)
    matrix[i]=matrix[i-1]+ncol;

  return matrix;
}

void free_smatrix(short **matrix)
{
  if (matrix==0) return;
  delete matrix[0];
  delete matrix;
}

/************************ <SVECTOR/FREE_SVECTOR> ****************************/
unsigned short *usvector(int npts)
{
  unsigned short *vector = new unsigned short[npts];

  if (!vector) uerror("allocation failure in svector()");
  memset(vector,0,npts*sizeof(unsigned short));  //Initialize!

  return vector;
}

void free_svector(unsigned short *vector)
{
  delete [] vector;
} 

/************************ <FVECTOR/FREE_FVECTOR> ****************************/
float *fvector(int npts)
{
  int n_elements=npts;
  float *vector = new float[npts];

  if (!vector) uerror("allocation failure in fvector()");
  memset(vector,0,npts*sizeof(float));  //Initialize!

  return vector;
}

void free_fvector(float *vector)
{
  delete [] vector;
} 

/*********************** <F3MATRIX/FREE_F3MATRIX> ***************************/
float ***f3matrix(int nrow, int ncol, int ndep)
{
  int i,j,k,n_elements=nrow*ncol*ndep;
  float ***t;

  t = new float **[nrow];
  if (!t) uerror("Allocation failure 1 in f3matrix()");

  t[0] = new float *[nrow*ncol];
  if (!t[0]) uerror("Allocation failure 2 in f3matrix()");

  t[0][0] = new float [n_elements+1];
  if (!t[0][0]) uerror ("Allocation failure 3 in f3matrix()");

  memset(t[0][0],0,(n_elements+1)*sizeof(float)); //Initialize!

  for (j=1;j<ncol;j++) t[0][j]=t[0][j-1] + ndep;

  for (i=1;i<nrow;i++){
    t[i]=t[i-1]+ncol;
    t[i][0]=t[i-1][0]+ncol*ndep;
    for (j=1;j<ncol;j++) t[i][j] = t[i][j-1]+ndep;
  }

  return t;
}

void free_f3matrix(float ***t)
{
  if (t==0) return;
  delete t[0][0];
  delete t[0];
  delete t;
}

/*********************** <F4MATRIX/FREE_F4MATRIX> ***************************/
float ****f4matrix(int n1, int n2, int n3, int n4)
{
  int i,j,k,m,n_elements=n1*n2*n3*n4;
  float ****t;

  t=new float ***[n1];
  if (!t) uerror("Allocation failure 1 in f4matrix()");

  t[0]=new float **[n1*n2];
  if (!t) uerror("Allocation failure 2 in f4matris()");

  t[0][0]=new float *[n1*n2*n3];
  if (!t) uerror("Allocation failure 3 in f4matrix()");

  t[0][0][0]=new float [n_elements+1];
  if (!t) uerror("Allocation failure 4 in f4matrix()");

  memset(t[0][0][0],0,(n_elements+1)*sizeof(float)); //Initialize!

  for (k=1;k<n3;k++) t[0][0][k]=t[0][0][k-1]+n4;
  for (j=1;j<n2;j++){
    t[0][j]=t[0][j-1]+n3;
    t[0][j][0]=t[0][j-1][0]+n3*n4;
    for (k=1;k<n3;k++) t[0][j][k]=t[0][j][k-1]+n4;
  }

  for (i=1;i<n1;i++){
    t[i]=t[i-1]+n2;
    t[i][0]=t[i-1][0]+n2*n3;
    t[i][0][0]=t[i-1][0][0]+n2*n3*n4;
    for (k=1;k<n3;k++) t[i][0][k]=t[i][0][k-1]+n4;

    for (j=1;j<n2;j++){
      t[i][j]=t[i][j-1]+n3;
      t[i][j][0]=t[i][j-1][0]+n3*n4;

      for (k=1;k<n3;k++) t[i][j][k]=t[i][j][k-1]+n4;
    }

  }
  return t;
}

void free_f4matrix(float ****t)
{
  if (t==0) return;
  delete t[0][0][0];
  delete t[0][0];
  delete t[0];
  delete t;
}
/****************************************************************************/

