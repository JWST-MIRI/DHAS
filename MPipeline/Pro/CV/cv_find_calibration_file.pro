pro cv_find_calibration_file,cinfo,cfile,status 

status = 0
cfile = 'Unknown'
;_______________________________________________________________________
; first look at the information on the cube header for the location
; and name of the d2c file
;_______________________________________________________________________

calibration_file = cinfo.cube.dircal + '/' + cinfo.cube.d2cfile
print,' looking for calibration file ',calibration_file

file_exist1 = file_test(calibration_file,/regular,/read)

;_______________________________________________________________________
; maybe it was created on a different machine - use the calibration
; directory read in from the preferences file   
;_______________________________________________________________________
if(file_exist1 ne 1) then begin
   print,'Could not find the file'
    ; check what control.dircal starts with

    dircal = cinfo.control.dircal
    print ,' Now looking in directory ',dircal
    dircal = strcompress(dircal,/remove_all)
    len = strlen(dircal) 
    test = strmid(dircal,0,1)
    if(test eq '/') then dircal = strmid(dircal,1,len)

    ; test ending of dircal 
    len = strlen(dircal)
    test = strmid(dircal,len-1,len-1)
    if(test eq '/') then dircal = strmid(dircal,0,len-1)
 

    calibration_file =  dircal + $
                       '/' + cinfo.cube.d2cfile

    file_exist2 = file_test(calibration_file,/regular,/read)
    print,' Looking for calibration file ',calibration_file
;_______________________________________________________________________
    ; if it still does not exists ask the user where the blazes it is
;_______________________________________________________________________
    if(file_exist2 ne 1) then begin
       print,' Did not find the calibration file'
       print,'Now searching in the Cube Directory ',cinfo.control.dirCube


        cfile = dialog_pickfile(/read,$
                                 get_path=realpath,Path=cinfo.control.dirCube,$
                                 filter = '*.fits',title='Select Calibration (d2c) file')
        print,'found calibration_file',cfile


    endif else begin
        cfile = calibration_file
    endelse
endif else begin
    cfile = calibration_file
endelse


file_exist = file_test(cfile,/regular,/read)
if(file_exist ne 1) then begin 
    result = dialog_message('Can not find the calibration files ',/error)
    status = 1
    return
endif





end
