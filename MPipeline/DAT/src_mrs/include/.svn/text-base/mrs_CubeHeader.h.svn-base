
// mrsCubeHeader.h 
// Header for the Mosaic Class
//_______________________________________________________________________
#ifndef CUBEHEADER_H
#define CUBEHEADER_H

#include <iostream>
#include <iomanip>
#include <strstream>
#include <fstream>
#include <math.h>
#include <string>
#include <vector>
#include  "fitsio.h"
using namespace std;

//_______________________________________________________________________

//_______________________________________________________________________
// Constants

//_______________________________________________________________________
// Class description
//______________________________________________________________________
class CubeHeader{

 public:
  CubeHeader();
  ~CubeHeader();
//_______________________________________________________________________

// inline functions
  inline void SetChannel(int CH){Channel= CH;}
  inline void SetSubChannel(int SCH){SubChannel= SCH;}
  inline void SetNumFiles(const int NUM){num_files = NUM;}

  inline void SetInputFilename(const string FILENAME) {input_filenames.push_back(FILENAME);}

  inline void SetExtensionNum(const int NUM) {extension_num.push_back(NUM);}

  inline void SetCdelt1(const double CDELT){cdelt1 = CDELT;}
  inline void SetCdelt2(const double CDELT){cdelt2 = CDELT;}
  inline void SetCdelt3(const double CDELT){cdelt3 = CDELT;}

  inline void SetCrpix1(const double CRPIX){crpix1 = CRPIX;}
  inline void SetCrval1(const double CRVAL){crval1 = CRVAL;}

  inline void SetCrpix2(const double CRPIX){crpix2 = CRPIX;}
  inline void SetCrval2(const double CRVAL){crval2 = CRVAL;}

  inline void SetCrpix3(const double CRPIX){crpix3 = CRPIX;}
  inline void SetCrval3(const double CRVAL){crval3 = CRVAL;}


  inline void SetNgridX(const long N){ngridx = N;}
  inline void SetNgridY(const long N){ngridy = N;}
  inline void SetNgridZ(const long N){ngridz = N;}

  inline void SetNumTiles(const int N){numTiles = N;}

  inline void SetNumSlices(const int N){NumSlices = N;}


  inline void SetNumPixels(const long I){NumPixels = I;}

  inline void SetZCoord(double Z){ZCoord.push_back(Z);}
  inline void SetXCoord(double X){XCoord.push_back(X);}
  inline void SetYCoord(double Y){YCoord.push_back(Y);}

  inline void SetNSample(const int N){NSample = N;}


  inline void SetXMinMax(const double MIN, const double MAX){
    xmin = MIN;
    xmax = MAX;
  }

  inline void SetYMinMax(const double MIN, const double MAX){
    ymin = MIN;
    ymax = MAX;
  }
 
  inline void SetZMinMax(const double MIN, const double MAX){
    zmin =MIN;
    zmax = MAX;
  }



  inline void SetOutFitsFile(const string FILENAME){outputfits = FILENAME;}
  inline void SetSliceNo(const int I){SliceNo.push_back(I);}
//_______________________________________________________________________
 inline string GetInputFilename (int i)const {return input_filenames[i];}

 inline int GetChannel()const{return Channel;}
 inline int GetSubChannel()const {return SubChannel;}
 inline int GetNumFiles()const {return num_files;}


 inline double GetZCoord(const int i)const {return ZCoord[i];}
 inline double GetXCoord(const int i)const {return XCoord[i];}
 inline double GetYCoord(const int i)const {return YCoord[i];}

 inline int GetSliceNo(int I) {return SliceNo[I];}
 inline int GetExtensionNum (int i)const {return extension_num[i];}

 inline long GetNgridX()const {return ngridx;}
 inline long GetNgridY()const {return ngridy;}
 inline long GetNgridZ()const {return ngridz;}
 inline int GetNumSlices()const {return NumSlices;}
 inline long GetNumPixels()const {return NumPixels;}

 inline double GetCdelt1()const {return cdelt1;}
 inline double GetCdelt2()const {return cdelt2;}
 inline double GetCdelt3()const {return cdelt3;}

 inline double GetCrpix1()const {return crpix1;}
 inline double GetCrval1()const {return crval1;}
 inline double GetCrpix2()const {return crpix2;}
 inline double GetCrval2()const {return crval2;}
 inline double GetCrpix3()const {return crpix3;}
 inline double GetCrval3()const {return crval3;}

 inline double GetXmin()const {return xmin;}
 inline double GetXmax()const {return xmax;}
 inline double GetYmax()const {return ymax;}
 inline double GetYmin()const {return ymin;}
 inline double GetZmax()const {return zmax;}
 inline double GetZmin()const {return zmin;}

 inline int GetNSample()const {return NSample;}

 inline int GetNumTiles()const {return numTiles;}
 // inline int GetTile_NgridY(int i) const{return TileNgridY[i];}
 //inline int GetTile_NSlices(int i) const{return TileNSlices[i];}
 //inline long GetTile_StartValue(int i) const{return TileStartValue[i];}
 //inline int GetTile_NumPixels(int i) const{return TileNumPixels[i];}

 inline string GetOutFitsFile()const{return outputfits;}

//_______________________________________________________________________
 inline void PrintNumFiles()const{cout<<"Number of input files to cube: " << num_files << endl;}
 inline void PrintOutFitsName()const{cout << " Cube  fits file name: " << outputfits << endl;}
//_______________________________________________________________________



//_______________________________________________________________________
  // Functions allowed
  int OutFitsExist();

//_______________________________________________________________________

//_______________________________________________________________________
  //Print/Write  functions
  void PrintCubeInfo()const;
  void PrintCubeInfoToFile(bool,ofstream&)const;


//_______________________________________________________________________
 private:

  int Channel; 
  int SubChannel;

  // files 
  vector<string>  input_filenames;   // input list of Slope fits files
  vector<int> extension_num;         // extension number of data set in input_filename 



  string outputfits;                       // final cube 


//_______________________________________________________________________
  int num_files;


  long ngridx;             // 
  long ngridy;             // 
  long ngridz;
  int NumSlices;

  long NumPixels;

  int numTiles;

  double xmin;
  double xmax;
  double ymin;
  double ymax;
  double zmin;
  double zmax;

  double cdelt1;           // cube pixel size in x direction (across slice)
  double cdelt2;           // cube pixel size in y direction (along slice)
  double cdelt3;           // cube pixel size in y direction (wavelength)

  double crpix1;
  double crpix2;
  double crpix3;          // reference wavelength pixel value

  double crval1;
  double crval2;
  double crval3;          // reference wavelength at crpix3

  int NSample; 
  // 1-d vector of cube coordinates for 3 axes.

  vector <double> ZCoord;  // vector holding the location of z centers (1-d)
  vector <double> XCoord;  // vector holding the location of X centers (1-d)
  vector <double> YCoord;  // vector holding the location of Y centers (1-d)


 vector <int>  SliceNo;

};

#endif



