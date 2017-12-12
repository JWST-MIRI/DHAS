#include <vector>
#include <string>
#include <string.h>
#include "miri_caler.h"
#include "mc_preference.h"

using namespace std;
// ----------------------------------------------------------------------
// Helper procedure
void mc_search_keys(string keyname,mc_preference &preference, int& val, int &status)

{
  status = 1;
  int k = 0; 
  while(status ==1 && k< preference.keys_found){
    if(keyname == preference.key[k]) {
      status = 0;
      const char* cvalue = preference.value[k].c_str();
      val = atoi(cvalue);
    }
    k++;
  }

}
// ----------------------------------------------------------------------
// Helper procedure
void mc_search_keys(string keyname,mc_preference &preference, string& val, int &status)

{
  status = 1;
  int k = 0; 
  while(status ==1 && k< preference.keys_found){
    if(keyname == preference.key[k]) {
      status = 0;
      val = preference.value[k];
    }
    k++;
  }

}


// ----------------------------------------------------------------------
// Helper procedure
void mc_search_keys(string keyname,mc_preference &preference, float& val, int &status)

{
  status = 1;
  int k = 0; 
  while(status ==1 && k< preference.keys_found){
    if(keyname == preference.key[k]) {
      status = 0;
      const char* cvalue = preference.value[k].c_str();
      val = atof(cvalue);
    }
    k++;
  }
}

// ----------------------------------------------------------------------
