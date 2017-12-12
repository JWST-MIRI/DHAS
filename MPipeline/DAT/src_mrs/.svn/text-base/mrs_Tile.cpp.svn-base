// mrs_Tile.cpp
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <vector>
#include <algorithm>
#include <string>
#include "mrs_Tile.h"
#include "miri_constants.h"
 

// Default constructor to set initial values
//*********************************************************************** 
Tile::Tile():ngridx(0),ngridy(0),ngridz(0),NumSlices(0),
	     TileNo(0),NumPixels(0)
{
}




//Default destructor
Tile::~Tile()
{ 
  AveFlux.clear();
  TotalOverlap.clear();
  BadPixelFlag.clear();
  AveUncertainty.clear();
  XValue.clear();
  YValue.clear();
  ZValue.clear();
  ZCoord.clear();
  YCoord.clear();
  XCoord.clear();

  
}
//***********************************************************************
// set functions
//***********************************************************************

    
//_______________________________________________________________________



void Tile::Reserve_Grid(const long NUM){
  

  AveFlux.reserve(NUM);
  AveUncertainty.reserve(NUM);
  BadPixelFlag.reserve(NUM);
  TotalOverlap.reserve(NUM);
}



void Tile::Initialize_Elements(double XX, double YY, double ZZ){
			       

  float Value = 0;
  AveFlux.push_back(Value);
  AveUncertainty.push_back(Value);
  TotalOverlap.push_back(Value);
  BadPixelFlag.push_back(0);
  XValue.push_back(XX);
  YValue.push_back(YY);
  ZValue.push_back(ZZ);
}


void Tile::PrintXCoords(){
  int nx = XCoord.size();
  for (int i = 0; i < nx ; i++){
    cout << " X value, pixel " << XCoord[i] << "  " << i + 1 << endl;
  }
}

void Tile::PrintYCoords(){
  int ny = YCoord.size();
  for (int i = 0; i < ny ; i++){
    cout << " Y value, pixel " << YCoord[i] << "  " << i + 1 << endl;
  }
}


void Tile::PrintZCoords(){
  int nz = ZCoord.size();
  for (int i = 0; i < nz ; i++){
    cout << " Z value, pixel " << ZCoord[i] << "  " << i + 1 << endl;
  }
}

//***********************************************************************
// Print functions
//***********************************************************************
void Tile::PrintTileElements(long i)const{
  cout << "Values  for Tile Point:  (x,y,z),FluxValue,Overlap " << XValue[i] <<  
    " " << YValue[i] << " " << ZValue[i] << " " << AveFlux[i] << " " <<  
    " " << TotalOverlap[i]  << endl;
}
//***********************************************************************



