// me_BCDHeader
// Header structure for each BCD read in the Mosaicer
#include <iostream>
#include <iomanip>
#include <strstream>
#include <fstream>
#include <math.h>
#include <string>
#include <vector>
#include "fitsio.h"

using namespace std;

class ReducedHeader{

 public:
  ReducedHeader();
  ~ReducedHeader();
//***********************************************************************  
  //set routines

//*********************************************************************** 
  inline void SetChannel(int CH){Channel = CH;}
  inline void SetNSample(int S){NSample = S;}
  inline void SetSubChannel(int SCH){SubChannel = SCH;}
  inline void SetFileName(string FILEIN ){filename = FILEIN;}
  inline void SetFileNo(int FILENO ){fileno = FILENO;}
  inline void SetNaxis(int NAXIS){naxis = NAXIS;}
  inline void SetNaxes0(int NAXIS0){naxes[0] = NAXIS0;}
  inline void SetNaxes1(int NAXIS1){naxes[1] = NAXIS1;}
  inline void SetNaxes2(int NAXIS2){naxes[2] = NAXIS2;}
  inline void SetExpTime(float EXPTIME){exptime = EXPTIME;}
  
//***********************************************************************  
  //get routines

//*********************************************************************** 
  inline string GetFileName()const{return filename;}
  inline int GetFileNo()const{return fileno;}

  inline int GetNSample()const{return NSample;}
  inline int GetNaxis()const{return naxis;}
  inline int GetNaxes0()const{return naxes[0];}
  inline int GetNaxes1()const{return naxes[1];}
  inline int GetNaxes2()const{return naxes[2];}
  inline int GetChannel()const{return Channel;}
  inline int GetSubChannel() const {return SubChannel;}
  inline float GetExpTime()const{return exptime;}

/**********************************************************************/
// MISC
/**********************************************************************/

    void printHeader()const ;

 /**********************************************************************/

                        // following values read in with  me_read_header.cpp

 private:
  string filename;  // filename this BCD came from

  int NSample; 
  int fileno;
  int naxis;
  long naxes[3];  
  int Channel;
  int SubChannel;

  float exptime;                           // exposure 

  
};

