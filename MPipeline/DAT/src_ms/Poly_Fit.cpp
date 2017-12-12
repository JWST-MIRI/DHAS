#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <cmath>
#include <vector>
#include <numeric>
#include <algorithm>
using namespace std;

vector< vector<double> >  MatrixInvert( vector< vector<double> > A, const int N );

int Poly_Fit(vector<double> x, vector<double> y, const int ndegree,
	     vector<double> &result, vector<double> &yfit,
	     vector<double> &sigma, double &chisq, double &yerr,const int debug ) {
  
  // Re-write of IDL Poly_FIT
  // x: independent variable
  // y: dependent variable
  // Ndegree: the degree of polynomial
  // Result - return of vector of coefficients
  // Sigma: 1-sigma error estimates of the returned coefficients
  // chisq is reduced chi square;
  // yfit: contains calculated Y values
  // yerror: standard error between Yfit and Y

  int status = 0;
  int m = ndegree +1;
  int n = x.size();
  double zero = 0.0;
  
  
  if(x.size() != y.size() ) {
    cout << " X and Y must have the same number of elements" << endl;
    exit(EXIT_FAILURE);
  }

  vector< vector<double> > covar(m, vector<double>(m,0));


  vector<double> b(m);
  vector <double> z(n,1.0);
  
  vector<double> wy = y;


  covar[0][0] = double(n);
  b[0] = accumulate(wy.begin(),wy.end(),zero);

  int iw = wy.size();
  if(debug ==1) {
    cout << "value of wy " << endl;
    for (int ip = 0; ip < iw ; ip++) cout << wy[ip] << endl;
  }

  if(debug ==1) cout << "b[0]" << b[0] << endl;
  
  for (long p = 1; p<= 2*ndegree;p++){
    // z = z*x
    transform(z.begin(),z.end(),x.begin(),z.begin(),multiplies <double> ());

    // b[p] = total(wy*z)
    if(p < m) b[p] = inner_product(wy.begin(),wy.end(),z.begin(),zero);

    //sum = total(z)
    double sum = accumulate(z.begin(),z.end(),zero);

    if(debug ==1) {
      cout<< "p" << p << endl;
      cout << "z" << endl;
      for (int ik = 0; ik< n; ik++) cout << z[ik] << endl;
      if(p < m ) cout << "b[p] " << b[p] << endl;
      cout << "sum" << sum << endl;
    }
    //            if( 0 > (p-ndegree) then j = 0, else 
    for (int j =( (0>(p-ndegree)) ? 0: (p-ndegree) ); 
	 j <= ( (ndegree<p) ? ndegree:p); j++) covar[j][p-j] = sum;
    
  }
  

  if(debug==1) {
    cout << " results for debug pixel" << m << " " << m << endl;
    for(int j = 0; j<m; j++)
      for (int i = 0; i< m; i++) cout << "covar before " << i<< " " << j << " " << covar[i][j] << endl;;
  }
  covar = MatrixInvert(covar,m);

  if(debug == 1) {
    for(int j = 0; j<m; j++)
      for (int i = 0; i< m; i++) cout << "covar " << i<< " " << j <<  " " << covar[i][j] << endl;;
  }

  
  for(int j = 0; j<m; j++)
    for (int i = 0; i< m; i++) result[j] +=b[i]*covar[i][j];

  
  if(debug == 1) for(int j = 0; j<m; j++) cout << " result " << result[j] << endl;  
  // Done finding result
  // _______________________________________________________________________
  // Compute other Output parameters
  // example: y = a0 + a1 * x + a2 * x^2 + a3 * x^3 
  // result = a0,a1,a2,a3
  // initialize y = a3
  
  for (int i = 0; i<n;i++) yfit[i] = result[ndegree];
  
  // loop 1: y = a3 * x + a2
  // loop 2: y = a3* x^2 + a2 * x + a1
  // loop 3: y = a3* x^3 + a2 * x^2 + a1*x + a0

  for (int k = ndegree-1;k>=0;k--) {
    // yfit = yfit * x
    transform(yfit.begin(),yfit.end(),x.begin(),yfit.begin(),multiplies<double>());
    // yfit = result + yfit
    transform(yfit.begin(),yfit.end(),yfit.begin(),bind2nd( plus<double>(),result[k]));
  }



  // sigma = sqrt(abs(covar(lindgen(m) * (m+1)])) <- this is the diagonal of covar;
  for (int i = 0; i<m ; i++) sigma[i] = (sqrt(abs(covar[i][i])));
  

  vector<float> diff;

  transform(yfit.begin(),yfit.end(),y.begin(),back_inserter(diff),minus<double>());
  int ndiff = int(diff.size());
  vector<float> diff2(ndiff);
  transform(diff.begin(),diff.end(),diff.begin(),diff2.begin(),multiplies<double>());

  // No weigthing so no need to divide by errors of observations

  chisq = accumulate(diff2.begin(),diff2.end(),zero);					       
  if(chisq ==0 ) {
    cout << "chisq ==0" << endl;
    for(int j = 0; j<m; j++) cout << " result " << result[j] << endl;  
    for (int kk = 0 ; kk< int(yfit.size()); kk++){
      cout << yfit[kk] << " " << y[kk] << endl;
    }
    status = 1;

  }
  double nm = double(n-m);
  double var = (n>m) ? chisq/nm : 0.0;
  // if n>m var = chisq/nm
  // if n>m not true var = 0

  transform(sigma.begin(),sigma.end(),sigma.begin(),bind2nd(multiplies<double>(),
							    sqrt(chisq/nm)));
  yerr = sqrt(var);

  chisq = chisq/(nm-1);  // now change chisq to reduced chi square by dividing by # degrees of freedom

  return status;
}
