// mrs_Geometry_Cube.cpp
#include <iostream>
#include <string>
#include <iomanip>
#include <fstream>
#include <vector>
#include <math.h>
#include <cstdlib>
#include "mrs_CubeHeader.h"
#include "mrs_Tile.h"
#include "mrs_ReducedData.h"
#include "mrs_SubPixel.h"
#include "mrs_data_info.h"
// The detector pixels are actually parallelpipeds

double mrs_findAreaQuad(const double, const double,
			const double, const double, const double, const double, 
			const double, const double, const double, const double);


double mrs_SH_findOverlap(const double xcenter, const double ycenter, 
		       const double xlength, const double ylength,
			  double xPixelCorner[],double yPixelCorner[]);
double findAreaPoly(int nVertices,double xPixel[],double yPixel[]);

void mrs_overlap(const int it, const int V2V3,
		 const long numpixels_read,
		 CubeHeader cubeHead, 
		 Tile &tile,
		 vector<ReducedData> &Data,
		 vector<SubPixel> &subpixel,
		 int &Actual_Max_Overlap_Planes,
		 const int write_mapping,
		 const int verbose)

{




  double ATolerance = 0.0005;

  double cdelt1 = cubeHead.GetCdelt1();
  double cdelt3 = cubeHead.GetCdelt3();
  double crval1 = cubeHead.GetCrval1();
  double crval3 = cubeHead.GetCrval3();

  double crval2 = cubeHead.GetCrval2();
  double cdelt2 = cubeHead.GetCdelt2();

  float factor = 5.0;
  float add_factor = 5.0;

  // loop over all the pixels for the channel on the SCA
  // convert from pixel values to beta and alpha (arc seconds)
  //                               and  wavelength (microns)

  if(verbose) {
    tile.PrintXCoords();
    tile.PrintYCoords();
    tile.PrintZCoords();
  }
    
  if(verbose) cout << " # Pixels finding overlap for " << numpixels_read << endl;

  for (long i = 0 ; i < numpixels_read ; i++){ // loop over detector pixels to find overlap

    double total_area = 0;
    
    float percent = float(i)/float(numpixels_read) *100;
    int ipercent = int(percent);
    if(ipercent > factor) {
      cout << "   " << "working on determining overlap  \r";
      cout.flush();
      factor = factor + add_factor;
    }
    int debug = 0;
    if(i <- 300) debug = 1; 

    if(debug == 1) cout << "----------------------- Starting Pixel " << i << "-----------------" << endl;
    int slice = Data[i].GetSlice();

    if(debug ==1) cout << slice << endl;
    if(slice !=-1) {
      long  nfound = 0;
      double wavepixel[5] = {0.0};
      double alphapixel[5] = {0.0};

      Data[i].GetWaveCorners(wavepixel); // wavelength
      Data[i].GetAlphaCorners(alphapixel); // alpha

      int fileno= Data[i].GetFileNo();
      int intno= Data[i].GetIntNo();
      long index_detector = Data[i].GetPixelNo();
    
      // using cube pixel end points find all overlapping cube elements
    
      vector <long> xfound;
      vector <long> yfound;
      vector <long> zfound;

      // Find y axis values
      // y axis is just slice number (or the slice number wrt tile ( slice )
      int iy = (slice-1)  ; 
      double ycenter= Data[i].GetYcenter();
      double ypixel = fabs((ycenter- crval2)/cdelt2); // do not add crpix1 - in this case 
     
      int iy2 = int(ypixel);
      int iy3 = ceil(ypixel);
      float y2 = fabs ( ypixel - float(iy2));
      float y3  = fabs (ypixel - float(iy3));
      int iyclose = iy2;
      if(y3 < y2) iyclose = iy3; 
      
      yfound.push_back(iyclose);
      //yfound.push_back(iy);


      if(iy != iyclose && V2V3 == 0) {
	cout << setiosflags(ios::fixed| ios::showpoint) << setprecision(8) << endl;
	cout << "slice & y " << slice << " " << iy << " " << iy2  << " " << iy3 << " " << iyclose << endl;
	cout << ycenter << " " << ypixel << endl;
      }

      double MinWave = 10000.0;
      double MaxWave = -10000.0;

      double MinAlpha = 10000.0;
      double MaxAlpha = -10000.0;


      for (int ii = 0 ; ii< 5; ii++){
	if(wavepixel[ii] < MinWave) MinWave = wavepixel[ii]; 
	if(wavepixel[ii] > MaxWave) MaxWave = wavepixel[ii]; 

	if(alphapixel[ii] < MinAlpha) MinAlpha = alphapixel[ii]; 
	if(alphapixel[ii] > MaxAlpha) MaxAlpha = alphapixel[ii];
      }
  
    // Find x axis values
      double MINWAVE = MinWave;
      double MINALPHA = MinAlpha;
   
      MinAlpha = fabs((MinAlpha- crval1)/cdelt1); // do not add crpix1 - in this case 
      MaxAlpha = fabs((MaxAlpha- crval1)/cdelt1); // just assume pixel starts at 0

      int ix1 = int(floor(MinAlpha));
      int ix2 = int(floor(MaxAlpha));


      int ix_range  = ix2 - ix1 + 1;
      for (int ij = 0; ij< ix_range; ij++){
	xfound.push_back(ix1);
	ix1++;
      }


      // Find Z axis values
      MinWave = fabs((MinWave- crval3)/cdelt3) ; // Do not add crpix3, in this case assume 
                                           // pixel starts at 0
      MaxWave = fabs((MaxWave- crval3)/cdelt3) ;



      int iz1 = int(floor(MinWave));
      int iz2 = int(floor(MaxWave));
      int iz_range  = iz2 - iz1 + 1;
      for (int ij = 0; ij< iz_range; ij++){
	zfound.push_back(iz1);
	iz1++;
      }


      
      if(debug == 1 ) {
	for (unsigned int ij = 0; ij< yfound.size(); ij++){
	  cout << " Spatial Beta slice index " << yfound[ij] << endl;
	}
	
	for (unsigned int ij = 0; ij< xfound.size(); ij++){
	  cout << " Spatial alpha slice index " << xfound[ij] << endl;
	}
	
	for (unsigned int ij = 0; ij< zfound.size(); ij++){
	  cout << " Wave index " << zfound[ij] << endl;
	}
      }


    //_______________________________________________________________________

      int ngridy = cubeHead.GetNgridY();
      long ngridx = cubeHead.GetNgridX();
      vector <long> found_tile;

      long nplane_tile = ngridy * ngridx;

      //cout << "found " << xfound.size() << " " << yfound.size() << " " << zfound.size() << endl;

      for (unsigned int ij = 0; ij < zfound.size(); ij++){
	long istart_tile = (zfound[ij])*nplane_tile;
	for (unsigned int j = 0; j < xfound.size(); j++){
	  for (unsigned int k = 0; k < yfound.size(); k++){
	    long index_tile = (yfound[k])*ngridx + (xfound[j] );
	    index_tile = index_tile + istart_tile;
	    found_tile.push_back(index_tile);
	    //cout << xfound[j] <<  " " << yfound[k] << " " << zfound[ij] << " " << index_tile << endl;
	    if(debug == 1) 
	      cout << " *index in cube "  << index_tile  << " " << xfound[j]<< "  " << 
		yfound[k]<< " " <<zfound[ij] << endl;
	  }
	}
      }

      int nover = found_tile.size();

    //_______________________________________________________________________
    // no overlapping cube pixels found
      if(nover == 0) {
	cout << "mrs_overlap: No overlapping cube pixels found " << endl;
	Data[i].PrintPixelInfo();
	cout << yfound.size() << " " << xfound.size() << " " << zfound.size() << endl;
	for (unsigned int ij = 0; ij< yfound.size(); ij++){
	  cout << " Spatial Beta slice index " << yfound[ij] << endl;
	}
	
	for (unsigned int ij = 0; ij< xfound.size(); ij++){
	  cout << " Spatial alpha slice index " << xfound[ij] << endl;
	}
	
	for (unsigned int ij = 0; ij< zfound.size(); ij++){
	  cout << " Wave index " << zfound[ij] << endl;
	}

      }
      

      if(debug == 1) cout << " Number of overlapping cube pixels " << nover << endl;
      
      if(nover > 0) {


  // for this pixel find the area of the pixel in the wavelength- alpha dimensions
  // find the average length of the across slice dimension (area * length) = volumne 


	double areaPixelxz = mrs_findAreaQuad(
					      MINALPHA,MINWAVE,
					      alphapixel[0],wavepixel[0],alphapixel[1], wavepixel[1],
					      alphapixel[2],wavepixel[2],alphapixel[3], wavepixel[3]);
	// can use either one
	// double area2 = findAreaPoly(5,alphapixel,wavepixel);


	for(int p = 0 ; p < nover; p++){

	  long index_tile = found_tile[p];
	  double zcenter = tile.GetZValue(index_tile); // wavelength 
	  double xcenter = tile.GetXValue(index_tile); // alpha
	
	  double areaPixel = mrs_SH_findOverlap(xcenter,zcenter,cdelt1,cdelt3,alphapixel,wavepixel);

	  double area_weight = areaPixel/areaPixelxz;
	  if(area_weight*100 > 100) {
	    cout << " mrs_overlap: Overlap area greater than 100 " << endl;
	    debug = 1;
	  }



	  if(debug == 1) {
	    cout << " *****************************" << endl;
	    cout << " on pixel " << i << endl;
	    float tempx = Data[i].GetPixelX();
	    float tempy = Data[i].GetPixelY();
	    cout << " x & y " << tempx << " " << tempy << endl;
	    cout << "index " << index_tile<<  endl;
	    cout << " cube index " << subpixel[index_tile].GetIndex() << endl;
	    cout << "zcener " << zcenter << " " << cdelt3 << " " << cdelt3/2.0 << endl;
	    cout << " z cube pixel " << zcenter - cdelt3/2.0 << " " 
		 << zcenter + cdelt3/2.0  <<endl;
	    cout << " x cube pixel " << xcenter - cdelt1/2.0 << " " 
		 << xcenter + cdelt1/2.0  <<endl;
	    
	    cout << " wavepixel " << wavepixel[0] << " " << wavepixel[1] << " " 
		 << wavepixel[2] << " " << wavepixel[3] << endl; 
	    cout << " alpha " << alphapixel[0] << " " << alphapixel[1] << " " << alphapixel[2] 
		 << " " << alphapixel[3] << endl; 
	    cout << " Slice no " << slice << endl;
	    cout << " area detector (yz), area overlap, %overlap " << areaPixelxz << " " << areaPixel << " " <<
	      area_weight*100  << endl;
	  }
  
	  if(area_weight > ATolerance) {
	    nfound ++;
	    float flux = Data[i].GetFlux(); 
	    float uncertainty = Data[i].GetUncertainty();
	    int badpixel = Data[i].GetBadPixelFlag();

	    subpixel[index_tile].SetTies(index_detector, fileno,intno, slice,
					 area_weight,flux,uncertainty,badpixel);
	    
	    if(nfound > Actual_Max_Overlap_Planes) Actual_Max_Overlap_Planes = nfound;
	    
	    if(write_mapping){

	      long index_cube = subpixel[index_tile].GetIndex();
	      Data[i].SetCubeTies(index_cube,area_weight);

	    }
	    total_area = total_area + area_weight;
	  }

	} // end loop over p - overlaping cube pixels 
      } // nover > 0
    
      //cout << "Total area " << total_area << endl;
      if( fabs(total_area - 1.0) > 2 ) {
	cout << " The total area for the pixel covered by the cube pixels is above the tolerance " << endl;
	cout << " Total area " << total_area << endl;
	Data[i].PrintPixelInfo();
      }
      if(nfound ==0) {
	cout << "mrs_overlap: no overlap found for pixel" << endl;
	Data[i].PrintPixelInfo();
      }
    } // end islice = -1
  } // end looping over pixels i


  
}

    
