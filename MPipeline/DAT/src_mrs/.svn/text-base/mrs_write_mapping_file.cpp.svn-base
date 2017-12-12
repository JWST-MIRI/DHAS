#include <iostream>
#include <string>
#include <vector>
#include <cmath>
#include <algorithm>
#include <cstdlib> // EXIT_FAILURE   , EXIT_SUCCESS
#include "fitsio.h"
#include "mrs_CubeHeader.h"
#include "mrs_ReducedData.h"
#include "mrs_data_info.h"
#include "mrs_constants.h"
// The overlap mapping file is written out seperatly for each slice
// so 1 Tile contains the inforamtion for 1 slice
/**********************************************************************/
void mrs_PixelXY_PixelIndex(const int,const int , const int ,long &);
void mrs_PixelIndex_PixelXY(const int xsize, const long Index, int&x, int &y);

int mrs_write_mapping_file(const int channel_type,
		  const int islice,
		  const long numpixels_read,
		  mrs_data_info &data_info,
		  CubeHeader cubeHead,
		  vector<ReducedData> &RData,
		  int verbose)
                    
  
{

  int STATUS = 0;
  int status =0;
  long naxis0 = MAPPING_LENGTH;
  long naxis1 = 1024;
  long naxis2 = data_info.Max_Overlap_Planes*2;

/**********************************************************************/
  long XSHIFT = 0;
  if(channel_type == 1) XSHIFT = MAPPING_LENGTH;
  
  int slice = cubeHead.GetSliceNo(islice);
  int xmin = 0;
  int xmax = 0;
  int ymin = 1;
  int ymax = 1024;

  //  xmin =     int(floor(data_info.slice_range_min[channel_type][slice-1])) ;
  // xmax = int(floor(data_info.slice_range_max[channel_type][slice-1]));
  xmin =     data_info.slice_range_min[channel_type][slice-1] ;
  xmax =       data_info.slice_range_max[channel_type][slice-1];

  //if(verbose) 
    cout << " mapping reading data from  slice # " << slice << " " << xmin << " " << xmax << endl;


  long xrange = long(xmax - xmin) + 1;
  long yrange = long(ymax - ymin) + 1; 
  long xyplane = xrange*yrange; 

  long num = xrange*yrange*data_info.Max_Overlap_Planes*2;

  vector <float> ndata(xrange*yrange);
  vector <float> data_map(num);    
  //_______________________________________________________________________
  // read in primary image = since it is written slice by slice - read in edge values
  // from earlier processed slices
  status = 0;
  fitsfile *file_ptr;
  fits_open_file(&file_ptr,data_info.mapping_d2c_overlap_file.c_str(),
		 READWRITE,&status);
  if(status != 0 ) {
    cout << "mrs_write_mapping_file: problem opening mapping file" << endl;
    cout << " Error status " << status << endl;
    cout << " You might trying running program with out writing the Cube mapping overlap file" << endl;
    exit(EXIT_FAILURE);

  }


  int hdutype = 0;
  fits_movabs_hdu(file_ptr,1,&hdutype,&status);

  long inc[2] = {1,1};
  int anynul = 0; // null values
  int naxis = 2;
  long naxes[2];
  naxes[0] = naxis0;
  naxes[1] = naxis1;

  long fpixel[2];
  long lpixel[2];

  // lower left corner of subset
  fpixel[0]= long(xmin) - XSHIFT;
  fpixel[1]= long(ymin);

  lpixel[0] = long(xmax)- XSHIFT;
  lpixel[1] = long(ymax);
    
  if(verbose){ 
    cout << " reading first pixel " << fpixel[0] << " " << fpixel[1] << endl;
    cout << " reading last  pixel " << lpixel[0] << " " << lpixel[1] << endl;
  }


  fits_read_subset_flt(file_ptr, 0, naxis, naxes,
		       fpixel,lpixel,inc,0,
		       &ndata[0],&anynul, &status);

  //_______________________________________________________________________
  // read in first extension
 
  // write Index Extension - 1 (index, overlap) 
  fits_movabs_hdu(file_ptr,2,&hdutype,&status);


  naxis2 = 3;
  long naxes2[3];
  naxes2[0] = naxis0;
  naxes2[1] = naxis1;
  naxes2[2] = naxis2;
  long inc2[3] = {1,1,1};

  long fpixel2[3];
  long lpixel2[3];

  // lower left corner of subset
  fpixel2[0]= long(xmin) - XSHIFT;
  fpixel2[1]= 1;
  fpixel2[2]= 1;

  lpixel2[0] = long(xmax)- XSHIFT;
  lpixel2[1] = 1024;
  lpixel2[2] = data_info.Max_Overlap_Planes*2;
  if(verbose){ 
    cout << " read mapping first pixel " << fpixel2[0] << " " << fpixel2[1] << endl;
    cout << " read mapping  last  pixel " << lpixel2[0] << " " << lpixel2[1] << endl;
  }



  fits_read_subset_flt(file_ptr, 0, naxis2, naxes2,
		       fpixel2,lpixel2,inc2,0,
		       &data_map[0],&anynul, &status);



  
  // _______________________________________________________________________


  for (long i = 0 ; i < numpixels_read ; i++){ // loop over detector pixels to find overlap

    int noverlap = RData[i].GetNOverlap();
    

    int x = RData[i].GetPixelX();
    int y = RData[i].GetPixelY();
    

    long this_x = x - xmin;
    long ij = 0;
    
    
    ij = ((y-1)*xrange+this_x);
    if(ij != i) {
      cout << " Problem " << endl;
      exit(-1);
    }
    if(ndata[i] == 0) { // continue and fill in new values
      ndata[i] = noverlap;



      for (int p = 0; p< data_info.Max_Overlap_Planes; p++){

	long ij2 = (p*2)*xyplane + i;
	long ij3 = (p*2+1)*xyplane + i;
	long CubeIndex = 0;
	float Overlap = 0.0;
	if(p < noverlap) {
	  CubeIndex = RData[i].GetCubeIndex(p);
	  Overlap =  RData[i].GetOverlap(p);
	}
      
	data_map[ij2] = float(CubeIndex);
	data_map[ij3] = Overlap;

	if(i < -2) cout <<"results " <<  p<< " " <<slice << " " << x << " " << y << " " << 
	  ij << " " <<
	  ij2 << " " << ij3 << " " << ndata[ij] << " " << noverlap << " " <<CubeIndex  << endl;
      }
    }// ndata == 0
  }

  //_______________________________________________________________________
  // Write primary

  fits_movabs_hdu(file_ptr,1,&hdutype,&status);



  //  fits_write_key(file_ptr,TLONG,"XSHIFT",&XSHIFT," Shift x pixels",&status);
  if(verbose){ 
    cout << " mapping first pixel " << fpixel[0] << " " << fpixel[1] << endl;
    cout << " mapping last  pixel " << lpixel[0] << " " << lpixel[1] << endl;
  }


  fits_write_subset_flt(file_ptr, 0, naxis, naxes,
			fpixel,lpixel,
			&ndata[0],&status);
		

  if(status != 0 ) {
    cout << "mrs_write_mapping_file: problem writing mapping file, primary image " << endl;
    cout << " Error status " << status << endl;
  }

  //_______________________________________________________________________
  // write Index Extension - 1 (index, overlap) 
  fits_movabs_hdu(file_ptr,2,&hdutype,&status);

  if(verbose){ 
    cout << " mapping first pixel " << fpixel2[0] << " " << fpixel2[1] << endl;
    cout << " mapping last  pixel " << lpixel2[0] << " " << lpixel2[1] << endl;
  }



  fits_write_subset_flt(file_ptr, 0, naxis2, naxes2,
			fpixel2,lpixel2,
			&data_map[0],&status);
		

  if(status != 0 ) {
    cout << "mrs_write_mapping_file: problem writing mapping file: Index extension: 2 " << endl;
    cout << " Error status " << status << endl;
  }

    fits_close_file(file_ptr,&status);


    //if(slice == 17) {
    //      exit(-1);

    //}
  //_______________________________________________________________________
  return STATUS;

}




