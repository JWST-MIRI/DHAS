#include <iostream>
#include <string.h>
#include <stdlib.h>
#include "fitsio.h"

using namespace std;

/**********************************************************************/

void miri_check_fits(int status,
		     char text[100])

{

  char errtxt[FLEN_ERRMSG];

  if (status != 0) {
    fits_get_errstatus(status, errtxt);
    cout << text;
    cout << " status = " << status;
    cout << " : " << errtxt << endl;
    cout.flush();
    exit(8);
  }

}

/**********************************************************************/

int miri_copy_header(fitsfile *ifptr,
		     fitsfile *ofptr,
		     int status)

{
  int n_morekeys;
  int n_keys;
  char card[100];

  // add keywords describing the miri_sloper program

  status = 0;
  //  fits_write_date(ofptr,&status);
  char txt[100] = "miri_copy_header: fits_write_data";
//  miri_check_fits(status,"miri_copy_header: fits_write_date");
  miri_check_fits(status,txt);

  // get the number of keywords in the raw data

  fits_get_hdrspace(ifptr, &n_keys, &n_morekeys, &status);
   char txt1[100] = "miri_copy_header: fits_get_hdrspace";
//  miri_check_fits(status,"miri_copy_header: fits_get_hdrspace");
  miri_check_fits(status,txt1);

  fits_read_record(ifptr, 0, card, &status);  // puts file pointer at top of header
  for (int l = 0; l < n_keys; l++) {
    fits_read_record(ifptr, l+1, card, &status);
    if ((strncmp(card,"XTENSION",8) != 0) && (strncmp(card,"BITPIX",6) != 0) &&
	(strncmp(card,"NAXIS",5) != 0) && (strncmp(card,"PCOUNT",5) != 0) &&
	(strncmp(card,"GCOUNT",5) != 0) && (strncmp(card,"BZERO",5) != 0) &&
	(strncmp(card,"BSCALE",5) != 0) && (strncmp(card,"SIMPLE",6) != 0) &&
	(strncmp(card,"EXTEND",6) != 0) && (strncmp(card,"REDUCED",7) != 0) &&
	(strncmp(card,"EXTNAME",7) != 0) && (strncmp(card,"CALDIR",6) != 0) &&
	(strncmp(card,"MIRI_DIR",8) != 0) && (strncmp(card,"PREFFILE",8) != 0) ) {
      fits_write_record(ofptr, card, &status);
      char txt2[100] = "miri_copy_header: fits_write_record";
//      miri_check_fits(status,"miri_copy_header: fits_write_record");
      miri_check_fits(status,txt2);
    }
  }

  return 0;
}

/**********************************************************************/


int miri_copy_slope_header(fitsfile *ifptr,
		     fitsfile *ofptr,
		     int status)

{
  int n_morekeys;
  int n_keys;
  char card[100];

  // add keywords describing the miri_sloper program

  status = 0;
  //  fits_write_date(ofptr,&status);
  char txt[100] = "miri_copy_header: fits_write_data";
//  miri_check_fits(status,"miri_copy_header: fits_write_date");
  miri_check_fits(status,txt);

  // get the number of keywords in the raw data

  fits_get_hdrspace(ifptr, &n_keys, &n_morekeys, &status);
   char txt1[100] = "miri_copy_header: fits_get_hdrspace";
//  miri_check_fits(status,"miri_copy_header: fits_get_hdrspace");
  miri_check_fits(status,txt1);

  fits_read_record(ifptr, 0, card, &status);  // puts file pointer at top of header
  for (int l = 0; l < n_keys; l++) {
    fits_read_record(ifptr, l+1, card, &status);
    if ((strncmp(card,"XTENSION",8) != 0) && (strncmp(card,"BITPIX",6) != 0) &&
	(strncmp(card,"NAXIS",5) != 0) && (strncmp(card,"PCOUNT",5) != 0) &&
	(strncmp(card,"GCOUNT",5) != 0) && (strncmp(card,"BZERO",5) != 0) &&
	(strncmp(card,"BSCALE",5) != 0) && (strncmp(card,"SIMPLE",6) != 0) &&
	(strncmp(card,"EXTEND",6) != 0) && (strncmp(card,"REDUCED",7) != 0) &&
	(strncmp(card,"EXTNAME",7) != 0) && (strncmp(card,"CALDIR",6) != 0) &&
	(strncmp(card,"MIRI_DIR",8) != 0) && (strncmp(card,"PREFFILE",8) != 0) &&
	(strncmp(card,"FILENAME",8) !=0)     ) {
      fits_write_record(ofptr, card, &status);
      char txt2[100] = "miri_copy_header: fits_write_record";
//      miri_check_fits(status,"miri_copy_header: fits_write_record");
      miri_check_fits(status,txt2);
    }
  }

  return 0;
}

/**********************************************************************/
