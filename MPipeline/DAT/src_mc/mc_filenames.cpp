#include <iostream>
#include <vector>
#include <string>
#include "fitsio.h"
#include "mc_data_info.h"
#include "mc_control.h"

// program to define the filenames - input and output

void mc_filenames(mc_data_info& data_info, mc_control control)

{
  // get the base file name of the raw data and get basic information about the dataset
  // making sure a file has actually been specified

  // remove the .fits if it exists


  string cal_name ="null";
  string slope_name = "null";

  int fitsexist = control.fitsbase.find(".fits");

  if (fitsexist == -1) {
    cout << " The file name must end it .fits, run again and provide the fill name of the slope file" << endl;
    exit(EXIT_FAILURE);
  }
  // _______________________________________________________________________
  // Figure out the name of the output file from the input file name
  // _______________________________________________________________________
  data_info.fitsbase = control.fitsbase.substr(0,control.fitsbase.size()-10);
  data_info.redbase = data_info.fitsbase;

  slope_name =control.fitsbase;
  cal_name = data_info.fitsbase +  "_LVL3.fits";
  // _______________________________________________________________________
  // Use the user provide output filename
  // _______________________________________________________________________
  if(control.flag_output_name ==1) {
    cal_name = control.output_name;
    string::size_type fitspos = control.output_name.find(".fits");

    if (fitspos != string::npos) {
      cal_name =cal_name.substr(0,cal_name.size()-5);
    }


    string::size_type lvl3 = cal_name.find("LVL3");
    if (lvl3 == string::npos) {
      cal_name = cal_name + "_LVL3.fits";
    }else{
      cal_name = cal_name.substr(0,cal_name.size()-5) + "_LVL3.fits";
    }
    data_info.fitsbase = cal_name.substr(0,cal_name.size()-10);
    

  }


  data_info.cal_filename = "!" + control.scidata_out_dir + cal_name;
  data_info.red_filename =  control.scidata_dir + slope_name;


  // _______________________________________________________________________
  // Work out the name of the other output file names

  // _______________________________________________________________________
  //cout << " Fits base              " << data_info.fitsbase << endl;
  cout << " Input filename            " << data_info.red_filename << endl;
  cout << " Calibrated filename       " << data_info.cal_filename << endl;

  // _______________________________________________________________________
  // test if reduced file exists

  int status = 0;
  int testfile = 0;
  fits_file_exists(data_info.red_filename.c_str(),&testfile,&status);
  if( testfile !=1) { // open failed
    cout << " Can not open the file: " << data_info.red_filename << endl;
    cout << " Is the directory correct ? " << endl;
    cout << "    If not either modify preference file or commandline option -DI" << endl;
    cout << " Is the filename correct ? "  << endl;
    cout << "    If not you provided an incorrect name (case senstive) " << endl;
     exit(EXIT_FAILURE);
  }


}
