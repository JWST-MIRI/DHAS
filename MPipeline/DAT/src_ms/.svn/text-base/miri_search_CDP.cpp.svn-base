#include <string>
#include <string.h>
#include "miri_sloper.h"


using namespace std;
// ----------------------------------------------------------------------
// Helper procedure
void miri_search_CDP(string key,vector<string> keyname, vector<string> value,  int& val, int &status)

{
  int n = keyname.size(); 
  status = 1;
  int k = 0; 
  while(status ==1 && k< n){
    if(key == keyname[k]) {
      status = 0;
      const char* cvalue = value[k].c_str();
      val = atoi(cvalue);
    }
    k++;
  }
}
// ----------------------------------------------------------------------

// ----------------------------------------------------------------------
// Helper procedure
void miri_search_CDP(string key,vector<string> keyname, vector<string> value,  string& val, int &status)

{
  int n = keyname.size(); 
  status = 1;
  int k = 0; 
  while(status ==1 && k< n){
    if(key == keyname[k]) {
      status = 0;
      val = value[k];
    }
    k++;
  }
}
// ----------------------------------------------------------------------

// ----------------------------------------------------------------------
// Helper procedure
void miri_search_CDP(string key,vector<string> keyname, vector<string> value,  float& val, int &status)

{
  int n = keyname.size();
  status = 1;
  int k = 0; 
  while(status ==1 && k< n){
    if(key == keyname[k]) {
      status = 0;
      const char* cvalue = value[k].c_str();
      val = atof(cvalue);
    }
    k++;
  }
}
// ----------------------------------------------------------------------
