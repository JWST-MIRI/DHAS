#include "mrs_CubeHeader.h"
#include "mrs_control.h"
#include "mrs_data_info.h"
#include "miri_constants.h"
#include "mrs_constants.h"
#include "dhas_version.h"
#include <iostream>
#include <vector>
#include <string.h>
#include <stdio.h>
#include "fitsio.h"

// program to define the filenames - input and outputcdme


void mrs_filenames(CubeHeader &cubeHead,
		   mrs_data_info &data_info,
		   mrs_control & control)

{

  string name[4] = {"_CH1", "_CH2", "_CH3", "_CH4"};
  string sname[3] = {"_A", "_B", "_C"};

  int channel = cubeHead.GetChannel();

  int subchannel = cubeHead.GetSubChannel();
    
  // get the base filename 

  //  char version[strlen(dhas_version)+1];
  char version[30];
  strcpy(version,dhas_version);

  string pre = "!";
  //  if(!control.OverWrite) pre = "";
  string filename = pre + control.output_dir;

  
  if(control.flag_output_name == 0 && data_info.nfiles ==1) 
    control.output_name = data_info.fitsbase+ "_CUBE" ;
  filename+= control.output_name;

  if(control.flag_integration_no !=0) {
    string extnum("_INT");
    ostringstream IName;
    int in_no = control.integration_no;
    IName << extnum << in_no ;
    extnum = IName.str();

    filename+= extnum;
  }
  
  string file = filename + name[channel-1] + sname[subchannel] + ".fits";

  cubeHead.SetOutFitsFile(file);
  cout << "**************************************************" << endl;
  cout << " Spectral Cube will be written to " << file<< endl;


  if(control.write_mapping) {
    string outfile;

    if(control.flag_mapping_name_output ==1) {
      string filebase = control.mapping_name_output;
      
      string::size_type  ffits = filebase.find(".fits");
      int found_fits = 0;

      if(ffits != string::npos)  found_fits = 1;
      if(found_fits ==0) { 
	ffits = filebase.find(".Fits");
	if(ffits != string::npos)  found_fits = 1;
      }
      if(found_fits ==0) { 
	ffits = filebase.find(".FITS");
	if(ffits != string::npos)  found_fits = 1;
      }

      if(found_fits ==0) {
	outfile = filebase;
      }else {
	outfile.assign(filebase,0,ffits);
	
      }
      cout << "coutfile" << outfile << endl;
      
    } else { // use default names

      if(control.flag_mapping_name_output == 0 && data_info.nfiles ==1) {
	outfile = data_info.fitsbase+ "_Mapping_Overlap" ;
      } else {
	outfile = "Mapping_Overlap";
      }
    }
      
    data_info.mapping_d2c_overlap_file = outfile + name[channel-1] + sname[subchannel] + ".fits";
    cout << " Writing the Mapping Overlap file " << data_info.mapping_d2c_overlap_file << endl;
    //_______________________________________________________________________

    double zcube = cubeHead.GetCdelt3() ; 
    double xcube = cubeHead.GetCdelt1() ;

    // get the dimensions of the first pixel - just to estimate the size
    // of the mapping file
    
    double wavelength[2];
    double alpha[2];
    int point = 45;
    if(channel == 1) point = 600;


    //    wavelength[0] = data_info.wavelength[point];
    //alpha[0] = data_info.alpha[point];
    //wavelength[1] = data_info.wavelength[point+1033];
    //alpha[1] = data_info.alpha[point+1];
  
    // temp values to compile code
    wavelength[0] = 1.0;
    wavelength[1] = 6.0;
    alpha[0] = 0.2;
    alpha[1] = 0.5;
    cout << " removed data_info.wavelength & data_info.alpha - determined from d2c files" << endl;
    cout << " Writing mapping files does not work correctly now " << endl;
    exit(EXIT_FAILURE);
    
    // cout << wavelength[0] << " " << wavelength[1] <<endl;
    //cout << alpha[0] << " " << alpha[1] << endl;
    double  wave = fabs(wavelength[0] - wavelength[1]);
    double a  = fabs(alpha[0] - alpha[1]);
    int nwave = int(ceil(wave/zcube));
    int nalpha =int( ceil(a/xcube));

    data_info.Max_Overlap_Planes = ((nwave+1) * (nalpha+1)) + 6; // 2 cushion
    cout << " Max Overlap Planes " << data_info.Max_Overlap_Planes << endl;


    int status= 0;

    fitsfile *file_ptr;
    string create_file = "!" + data_info.mapping_d2c_overlap_file;
    fits_create_file(&file_ptr,create_file.c_str(), &status);


    if(status !=0){
      cout << "******************************" << endl;
      cout << " Problem creating file mapping overlap file" <<  status<< endl;
      exit(EXIT_FAILURE);
    }


    // Get Primary image set up 
    int naxis = 2;
    long naxes[2];
    naxes[0] = MAPPING_LENGTH; // found in mrs_constants (one want to write mapping/channel)
    naxes[1] = 1024;


    int bitpix = -32;

    status = 0;
    fits_create_img(file_ptr, bitpix,naxis,naxes, &status);

    if(status !=0) {
      cout << " mrs_filenames: Problem creating mapping overlap image"<< endl;
      cout << " status " << status <<endl;
      exit(EXIT_FAILURE);
    }

    fits_write_comment(file_ptr, "file created by miri_cube program",&status);
    fits_write_comment(file_ptr, "MIRI DHAS  Team Pipeline",&status);
    fits_write_comment(file_ptr, "Jane Morrison",&status);
    fits_write_comment(file_ptr, "email morrison@as.arizona.edu for info",&status);
    fits_write_comment(file_ptr, "**--------------------------------------------------------------**",&status);

    fits_write_comment(file_ptr, "File contains the pixel coordinates on the cube",&status);
    fits_write_comment(file_ptr, "Primary image is number of overlaps ",&status);
    fits_write_comment(file_ptr, "Extension: Even Planes: index on cube pixel overlaps",&status);
    fits_write_comment(file_ptr, "Extension: Odd Planes: % overlap of detector pixel overlaps cube pixel",&status);

    fits_write_comment(file_ptr, "**--------------------------------------------------------------**",&status);

    fits_write_key(file_ptr, TSTRING, "MRS_VER", &version, "dhas cube build version", &status);


    double crpix1 = cubeHead.GetCrpix1();
    double crpix2 = cubeHead.GetCrpix2();
    double crpix3 = cubeHead.GetCrpix3();
    
    double crval1 = cubeHead.GetCrval1();
    double crval2 = cubeHead.GetCrval2();
    double crval3 = cubeHead.GetCrval3();

    double cdelt1 = cubeHead.GetCdelt1();
    double cdelt2 = cubeHead.GetCdelt2();
    double cdelt3 = cubeHead.GetCdelt3();

    long nx = cubeHead.GetNgridX();
    long ny = cubeHead.GetNgridY();
    long nz = cubeHead.GetNgridZ();


    int subchannel = cubeHead.GetSubChannel();

    int schannel = subchannel + 1;
    fits_write_key(file_ptr,TINT,"CHANNEL",&channel," Channel # ",&status);
    fits_write_key(file_ptr,TINT,"SUBCH",&schannel," SubChannel (1=a,2=b,3=c)",&status);
    

    fits_write_key(file_ptr,TDOUBLE,"CCRPIX1",&crpix1," Cube: X Pixel values at CRVAL1",&status);
    fits_write_key(file_ptr,TDOUBLE,"CCRPIX2",&crpix2," Cube: Y Pixel values at CRVAL2",&status);
    fits_write_key(file_ptr,TDOUBLE,"CCRPIX3",&crpix3," Cube: Z Pixel values at CRVAL3",&status);

    fits_write_key(file_ptr,TDOUBLE,"CCRVAL1",&crval1," Cube: Reference pt (arc seconds) at CRPIX1",&status);
    fits_write_key(file_ptr,TDOUBLE,"CCRVAL2",&crval2," Cube: Reference pt (arc seconds) at CRPIX2",&status);
    fits_write_key(file_ptr,TDOUBLE,"CCRVAL3",&crval3," Cube: Reference pt (microns) at CRPIX3",&status);
  
    fits_write_key(file_ptr,TDOUBLE,"CCDELT1",&cdelt1," cube:Plate Scale in X axis (arc seconds/pixel)",&status);
    fits_write_key(file_ptr,TDOUBLE,"CCDELT2",&cdelt2," cube:Plate Scale in Y axis (arc seconds/pixel)",&status);
    fits_write_key(file_ptr,TDOUBLE,"CCDELT3",&cdelt3," cube:Dispersion in Z axis (mircons/pixel)",&status);

    fits_write_key(file_ptr,TLONG,"NX",&nx," X dimension of cube",&status);
    fits_write_key(file_ptr,TLONG,"NY",&ny," Y dimension of cube",&status);
    fits_write_key(file_ptr,TLONG,"NZ",&nz," Z dimension of cube",&status);


    long XSHIFT = 0;
    if(channel == 2 || channel == 4) XSHIFT = MAPPING_LENGTH;

    fits_write_key(file_ptr,TLONG,"XSHIFT",&XSHIFT," Shift x pixels",&status);

    data_info.cube_overlap_file_ptr = file_ptr;

    //_______________________________________________________________________
    // write primary image - 
    int nx_map = MAPPING_LENGTH;
    int ny_map = 1024;
  
    long nelements = nx_map*ny_map;

    float *data = new float[nelements];


    for (register long iy = 0; iy< ny_map; iy++){
      for(register long ix = 0; ix< nx_map; ix++){
	long index = (iy*nx_map + ix) ;
	data[index] = 0.0;
      } // end ix
    } // end iy


    fits_write_img(file_ptr,TFLOAT,1,nelements,data,&status);
    delete [] data;
    //_______________________________________________________________________
    // Write extension = (index, overlap) * number of overlaps  

    naxis = 3;
    long naxes2[3];
    naxes2[0] = MAPPING_LENGTH; // found in mrs_constants (one want to write mapping/channel)
    naxes2[1] = 1024;
    naxes2[2] = data_info.Max_Overlap_Planes*2;

    nelements = nx_map*ny_map*data_info.Max_Overlap_Planes*2;

    float *data2 = new float[nelements];

    long nplane = nx_map * ny_map;

    for (register long iz = 0; iz< data_info.Max_Overlap_Planes*2; iz++){
      long zz = iz*nplane;
      for (register long iy = 0; iy< ny_map; iy++){
	for(register long ix = 0; ix< nx_map; ix++){
	  long index = (iy*nx_map + ix) + zz;
	  data2[index] = 0.0;
	} // end ix
      } // end iy
    } // end iz

    // write first extension
    status = 0;
    fits_create_img(file_ptr, bitpix,naxis,naxes2, &status);
    if(status != 0) cout << " mrs_filenames: Mapping File problem creating first extension " << status << endl;
    status = 0;


    fits_write_comment(file_ptr, "Extension: Even Planes: index on cube pixel overlaps",&status);
    fits_write_comment(file_ptr, "Extension: Odd Planes: % overlap of detector pixel overlaps cube pixel",&status);

    fits_write_img(file_ptr,TFLOAT,1,nelements,data2,&status);
    if(status != 0) cout << " mrs_filenames: Mapping File problem writing first extension " << status << endl;

    delete [] data2;



    if(status !=0) {
      cout << " mrs_filenames: Problem setting up mapping file, extension " << status<<  endl;
      exit(EXIT_FAILURE);
    }
    fits_close_file(data_info.cube_overlap_file_ptr,&status);


  }


}



