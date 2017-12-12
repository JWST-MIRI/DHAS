// mrs_Tile.h 
// Header for the Tile Class
//_______________________________________________________________________
#ifndef TILE_H
#define TILE_H

#include <iostream>
#include <iomanip>
#include <strstream>
#include <fstream>
#include <math.h>
#include <string>
#include <vector>
#include  "fitsio.h"
#include "mrs_control.h"
using namespace std;

//_______________________________________________________________________

//_______________________________________________________________________
// Constants
                               // SED mode observations
//_______________________________________________________________________
// Class description
//______________________________________________________________________
class Tile{

 public:
  Tile();
  ~Tile();

//_______________________________________________________________________

  inline void SetNumSlices(int I){NumSlices = I;}
  inline void SetTileNo(int I ){TileNo = I;}
  inline void SetNumPixels(long NUM ){NumPixels = NUM;}

  inline void SetAveFlux(int i,const float VALUE){AveFlux[i] = VALUE;}
  inline void SetAveUncertainty(int i,const float VALUE){AveUncertainty[i] = VALUE;}
  inline void SetTotalOverlap(int i,const float VALUE){TotalOverlap[i] = VALUE;}
  inline void SetBadPixelFlag(int i,const int VALUE){BadPixelFlag[i] = VALUE;}

  
  inline double GetXValue(const long i )const { return XValue[i];}
  inline double GetYValue(const long i )const { return YValue[i];}
  inline double GetZValue(const long i )const { return ZValue[i];}

  inline void SetZCoord(double Z){ZCoord.push_back(Z);}
  inline void SetXCoord(double X){XCoord.push_back(X);}
  inline void SetYCoord(double Y){YCoord.push_back(Y);}
  

  inline float GetAveFlux(const long i)const{return AveFlux[i];}
  inline float GetAveUncertainty(const long i)const{return AveUncertainty[i];}
  inline float GetTotalOverlap(const long i)const{return TotalOverlap[i];}
  inline int GetBadPixelFlag(const long i)const{return BadPixelFlag[i];}
  

//_______________________________________________________________________
  // Functions allowed
  void SetTileSize(const long,const long, const long);
  void Reserve_Grid(const long);
  void Initialize_Elements(double,double,double);

//_______________________________________________________________________
  //Print/Write  functions
  void PrintTileElements(long) const;
  void PrintXCoords();
  void PrintYCoords();
  void PrintZCoords();

//_______________________________________________________________________
 private:
  // files 
  // information on current Tile

  long ngridx;             // 
  long ngridy;             // 
  long ngridz;
  int NumSlices;

  int TileNo;
  long NumPixels;

  // size of number of tile pixels

  vector <float> AveFlux; // final averaged value
  vector <float> TotalOverlap;
  vector <int>   BadPixelFlag;
  vector <float> AveUncertainty;

  vector <double> XValue;   // cube element centers in x dim 1 to ngridx
  vector <double> YValue;   // cube element centers in y dim 1 to ngridy
  vector <double> ZValue;   // cube element centers in z dim 1 to ngridz

  vector <double> ZCoord;  // vector holding the location of z centers (1-d)
  vector <double> XCoord;  // vector holding the location of X centers (1-d)
  vector <double> YCoord;  // vector holding the location of Y centers (1-d)
  
};

#endif



