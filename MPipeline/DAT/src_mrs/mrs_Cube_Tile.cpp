// mrs_Cube_Tile
#include "mrs_CubeHeader.h"
#include "mrs_control.h"
#include "mrs_constants.h"

/**********************************************************************/
// This routine:
//  Sets up the parameters necessary to split the cube into sections, called tiles)


/**********************************************************************/


void mrs_Cube_Tile(const mrs_control control,CubeHeader  &cubeHead)
  
{
  int channel = cubeHead.GetChannel();
  if(control.do_verbose)   cout << " On channel " << channel << endl;
  int nslicesNTile = control.numSlicesNTile;

  cout << nslicesNTile << endl;


  int total_rows = cubeHead.GetNgridY();  
  if(nslicesNTile ==0) nslicesNTile = total_rows;

  long subX = total_rows/nslicesNTile;
  long xextra = (total_rows%nslicesNTile);
  if(xextra !=0) subX++;

  int nTiles = subX;
  cubeHead.SetNumTiles(nTiles);

  cout << "number of Tiles " << nTiles << endl; 

  cout << "number slices in each  Tile " << nslicesNTile <<  endl;



  long kk =0;
  for( kk =0; kk<nTiles ; kk++){
    cubeHead.Initialize_TileNgridY(0);
    cubeHead.Initialize_TileStartValue(0);
    cubeHead.Initialize_TileNumPixels(0);
    cubeHead.Initialize_TileNSlices(0);
  }
  
  vector<int> ystart;

  int ngridY = total_rows; // Total number of slices
  // find the starting slice for each Tile
  int ix =1;
  ystart.push_back(0);
  long ic = 0;
  for ( ic = 0; ic < ngridY;ic++){
    if(ix == nslicesNTile && ic+1 < ngridY){
      ystart.push_back(ic+1);
      if(control.do_verbose) cout << "ystart " << ic << endl;
      ix = 1;
    }else
      ix++;
  }

  //_______________________________________________________________________


  long ngridz = cubeHead.GetNgridZ();
  long ngridx = cubeHead.GetNgridX();


  unsigned int j = 0;
  for ( j =0; j<ystart.size();j++){
  
    long tngridy=0;
    if(j+1 < ystart.size()) {
      tngridy = ystart[j+1] - ystart[j];
    }else{
      tngridy = ngridY - ystart[j];
    }



    cubeHead.Set_TileNgridY(j,tngridy);
    cubeHead.Set_TileStartValue(j,ystart[j]);
    

    cout << tngridy << " " << ystart[j] << endl;

    long numpixels = ngridz * ngridx * tngridy;
    cubeHead.Set_TileNumPixels(j,numpixels);

     cout << " Tile: " << j+1 << " Row start: " << ystart[j] << " nslices: " << tngridy << endl;

  }

  exit(0);

}














