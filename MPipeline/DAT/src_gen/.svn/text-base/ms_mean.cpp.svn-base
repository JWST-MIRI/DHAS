#include <vector>
#include <algorithm>
#include <cmath>
// namespaces

using namespace std;
// Find the mean of a vector

double  ms_mean(vector<double>::iterator first, vector<double>::iterator last, 
		vector<double>::iterator wfirst) 
{
  
		
  double value = 0.0;
  double weight = 0.0;
  for(; first != last; ++first, ++wfirst){
    if( *wfirst !=0) {
      value  += (*first) * (*wfirst);
      weight += (*wfirst);
    }
  }
  if(weight == 0){
    value = 0;
  }else{
    value = value/weight;
  }
  return value;

}

//_______________________________________________________________________
// Find the standard deviation of a vector

double  ms_stdev(double mean ,
		vector<double>::iterator first, vector<double>::iterator last, 
		vector<double>::iterator wfirst) 
{
  
		
  double stdev = 0.0;
  double weight = 0.0;
  for(; first != last; ++first, ++wfirst){
    if( *wfirst !=0) {
      double diff = (*first) - mean; 
      stdev += diff*diff;
      weight += (*wfirst);
    }
  }
  if(weight < 1){
    stdev = 0;
  }else{
    stdev = stdev/(weight-1);
    stdev = sqrt(stdev);
  }
  return stdev;
}

  
