"""
Script intended to convert JPL data to JWST datamodel format.

"""
from  jwst.pipeline import Detector1Pipeline
import os
from os import path
import sys
import getopt
from astropy.io import fits


def run_pipeline(list_of_jwst_files, jpl_det, path_reffiles):

    """ Run the jwst pipeline on JPL data, using appropriate reference files'
        We need to know the jpl_det and FR value to set up the reference files
    """

    for file in list_of_jwst_files:
        hdulist = fits.open(file)
        header = hdulist[0].header
        fr = header['FRMRSTS']
        hdulist.close()
        # Run 10 FPM 101, FR = 0
        if jpl_det == '101':
            bad_pixel_mask = 'MIRI_JPL_MASK_04.02.00.fits'                  
            pixel_sat = 'MIRI_JPL_RUN10_FPM101_SATURATION_MIN_8B.00.02.fits'
            if fr ==0: 
                lin_cor = 'MIRI_JPL_RUN10_FPM101_FR0_PIXEL_JPL_LINEARITY_8B.00.02.fits'
                reset_cor = 'MIRI_JPL_RUN9_FPM101_FAST_RESET_RESIDUAL_8B.00.01.fits'
            elif fr ==1: 
                lin_cor = 'MIRI_JPL_RUN10_FPM101_FR1_PIXEL_JPL_LINEARITY_8B.00.02.fits'
                reset_cor = 'MIRI_JPL_RUN10_FPM101_FR1_FAST_RESET_RESIDUAL_8B.00.01.fits'
            else:
                raise Exception('Invalid FR value',fr)
        else:
            bad_pixel_mask = 'MIRI_JPL_RUN6_MASK_07.02.00.fits'
            pixel_sat = 'MIRI_JPL_RUN10_SCA106_SATURATION_MIN_8B.00.02.fits'
            if fr == 0:
                lin_cor = 'MIRI_JPL_RUN10_SCA106_FR0_JPL_LINEARITY_8B.00.00.fits'
                reset_cor = 'MIRI_JPL_RUN8_SCA106_FAST_RESET_RESIDUAL_07.00.01.fits'
            elif fr == 1:
                lin_cor = 'MIRI_JPL_RUN10_SCA106_FR1_JPL_LINEARITY_8B.00.00.fits'
                reset_cor = 'MIRI_JPL_RUN10_SCA106_FR1_FAST_RESET_RESIDUAL_8B.00.01.fits'
            else:
                raise Exception('Invalid FR value',fr)
                
        pipe = Detector1Pipeline()
        pipe.dq_init.override = path_reffiles + '/'+ bad_pixel_mask
        pipe.saturation.override_saturation = path_reffiles + '/'+ pixel_sat
        pipe.linearity.override_linearity = path_reffiles + '/'+ lin_cor
        pipe.linearity.save_results = True
        pipe.reset.override_reset = path_reffiles + '/'+ reset_cor
        pipe.reset.save_results = True
        pipe.refpix.skip = True
        pipe.dark_current.skip = True
        pipe.rscd.skip = True
        pipe.ipc.skip = True
        pipe.save_results = True
        result = pipe.run(file)
    

def  rename_and_move_files(list_jwst, list_fw, temp_path, prop_num, clean):
    """
    Rename the files created by the create_data routine, found in temp_path to
    the ones in list.
    If clean = True and delete the temporary directory (temp_path) and the files in the directory

    Parameters:
    -----------

    list_jwst : list 
        List of final JWST converted uncal file names
    list_fw : list
        List of temporary files names used to read in FRMRSTS. This value is not copied in create_data script
    temp_path : directory
        Temporary directory to convert jpl data to data the JWST pipeline can read
    prop_num: string
        Prop number used in create_data. It forms part of the output name
    clean: bool
       if True then remove the temporary directory temp_path

    """
    
    for ifile, file in enumerate(list_jwst):

        hdulist = fits.open(temp_path+list_fw[ifile])
        header = hdulist[0].header
        fr = header['FRMRSTS']
        hdulist.close
        
        if(ifile < 10): 
            prop_name = 'jw'+str(prop_num)+'001001_01101_0000'+str(ifile+1)+'_MIRIMAGE_uncal.fits'
        elif( ifile > 10 and ifile < 100):
            prop_name = 'jw'+str(prop_num)+'001001_01101_000'+str(ifile+1)+'_MIRIMAGE_uncal.fits'
        else:
            prop_name = 'jw'+str(prop_num)+'001001_01101_00'+str(ifile+1)+'_MIRIMAGE_uncal.fits'
        jwst_prop = temp_path+prop_name
        #print(file,prop_name)
        os.rename(jwst_prop,file)
        
        hdulist = fits.open(file)
        header = hdulist[0].header
        header['FRMRSTS'] = fr
        hdulist[0].header = header
        hdulist.writeto(file,overwrite=True)
        hdulist.close()

        
    if clean:
         print('Deleting directory',temp_path)
         os.system("rm -rf " + temp_path)
        
def create_conversion_prop(path, list, prop_num):
    """
    Create a .prop file needed by conversion function (convert_data) to convert from JPL to datamodel
    convert_data doc:https://jwst-pipeline.readthedocs.io/en/stable/jwst/fits_generator/scripts.html?highlight=create_data
    
    for JPL data we will make it MIR_IMAGE for the exp_type

    Parameters:
    ----------
    path : directory
       Location of the temporary files created by create_data script
    list: list
       List of input files to convert
    prop_num : string
       Prop number used prop_num.prop used by create data
    
    """


    prop_name = prop_num + '.prop'
    prop_name = os.path.join(path,prop_name)
    print('Creating prop file',prop_name)
    name = 'JPL Run 10 data'

    text = f'<Proposal title="{name}">\n'
    text += "  <Observation>\n"
    text += "    <Visit>\n"
    text += "      <VisitGroup>\n"
    text += "        <ParallelSequenceID>\n"
    text += "          <Activity>\n"

    for file in list:
        #print(file)
        text += f"              <Exposure>\n"
        text += f"                <Detector>\n"
        text += f"                  <base>{file}</base>\n"
        text += f"                  <subarray></subarray>\n"
        text += f"                  <exp_type>MIR_IMAGE</exp_type>\n"
        text += f"                </Detector>\n"
        text += f"              </Exposure>\n"

    text += "          </Activity>\n"
    text += "        </ParallelSequenceID>\n"
    text += "      </VisitGroup>\n"
    text += "    </Visit>\n"
    text += "  </Observation>\n"
    text += "</Proposal>\n"

    
    file_obj = open(prop_name, "w")
    file_obj.write(text)
    file_obj.close()



def convert_to_fitswriter(filein, fileout):
    """
    convert the JPL files to temporary files that will be used by the create_data script
    For JPL data  set DETECTOR = MIRIMAGE and FILTER+ F1500W
    Set other header keywords that are needed by the create_data script
    """

    hdulist = fits.open(filein)
    header = hdulist[0].header

    ngroups = header['NGROUPS']
    nints = header['NINT']
    print('Number of ints',nints)
    print('Number of frames',ngroups)
    
    data = hdulist[0].data
    dataout = data[:,0:1024,:]
    
    if "OLD_SCA_ID" not in header:
        header["OLDSCAID"] = header["SCA_ID"]
        header["SCA_ID"] = 493 #  JPL = Imager

    header['HISTORY'] ='Science data extracted by FITSWriter'
    header['DETECTOR']='MIRIMAGE'
    header['NGROUP'] = header['NGROUPS']
    header['GROUPGAP'] = 0
    header['DRPFRMS1'] = 0
    header['READOUT'] = 'FAST'
    header['SUBARRAY'] = 'F'
    header['FRMDIVSR'] =0
    header['DATE-OBS'] = header['DATE_OBS']
    header['TIME-OBS'] = header['TIME_OBS']
    header['DATE-END'] = header['DATE_END']
    header['TIME-END'] = header['TIME_END']
    del header['DATE_OBS']
    del header['TIME_OBS']
    del header['DATE_END']
    del header['TIME_END']
    header['OBS_ID'] = str(header['OBS_ID'])
    header['FWA_POS'] = 'F1500W'  #  JPL data is closest to F1500W
    header['DGAA_POS'] = 'LONG'   #  Just needs value it does not mean anything
    header['DGAB_POS'] = 'LONG'
    header['CCC_POS'] = 'OPEN'
    hdulist[0].header = header
    hdulist.writeto(fileout,overwrite=True)
    hdulist.close()

def main(argv):
    input_file = ''

    clean = False
    try:
        opts, args = getopt.getopt(argv, "hi:j:p:", ['clean'])
    except getopt.GetoptError:
        print('run_jpl_pipeline -i <input_file> -j <106 or 101> -p <path to ref files> --clean')
        sys.exit(2)
    prop_num = None
    jpl_det = None
    enter_path = False
    for opt, args in opts:
        if opt in ("-h", "--help"):
            print('run_jpl_pipeline.py -i <input_file> -j <106 or 101> -p <path ref files> --clean')
            sys.exit()
        elif opt in ("-i"):
            input_file = args
        elif opt in ("-j"):
            jpl_det = args
        elif opt in ("--clean"):
            clean = True
        elif opt in ("-p"):
            path_reffiles = args
            enter_path = True

    # Path to reference files, default used MIRI DHAS CDP_DIR
    if not enter_path:
        path_reffiles = os.environ.get("CDP_DIR")

    print("Location of the JPL reference files", path_reffiles)
    if(jpl_det == '106' or jpl_det == '101'):
        print(' Data is for JPL detetector', jpl_det)
    else:
        print('Entered wrong JPL detector', jpl_det)
        print('Only values allowed 101 or 106')
        raise Exception('Entered from JPL detector type')

    if clean:
        print('Clean up and remove temp directory')
    # check if we have a single fits file or a list of fits files
    slen = len(input_file)
    check_fits = input_file[slen-5:slen]
    list_of_files = []

    if check_fits == ".fits":
        list_of_files.append(input_file)
    else:
        file = open(input_file, 'r')
        for line in file:
            this_file = line.split()
            list_of_files.append(this_file[0])
    print('Number of JPL files to convert format and run JWST pipeline',
          len(list_of_files))
    list_of_outfiles = []
    list_of_jwst_files = []
    output_dir = 'temp/'
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    for file in list_of_files:
        # temp output file to set up needed Header keywords
        output_file = file
        output_file = output_file.replace(".fits", "_FW.fits")
        list_of_outfiles.append(output_file)
        out_file = os.path.join(output_dir, output_file)
        # name of final file name created
        jwst_file = file.replace(".fits", "_jwst.fits")
        list_of_jwst_files.append(jwst_file)
        # add needed values to the header for each file
        convert_to_fitswriter(file, out_file)

    # create a prop file used by create_data to convert to JWST datamodel
    prop_num = '00001'

    create_conversion_prop(output_dir, list_of_outfiles, prop_num)
    # create_data on temp directory
    os.system('create_data temp')

    # the files in temp directory have been renamed based on prop number
    # rename to reflect input names
    rename_and_move_files(list_of_jwst_files, list_of_outfiles,
                          output_dir, prop_num, clean)

    # run cal detector 1 on the files, using the override function
    # to use the JPL reference files
    run_pipeline(list_of_jwst_files, jpl_det, path_reffiles)


if __name__ == '__main__':

    main(sys.argv[1:])
