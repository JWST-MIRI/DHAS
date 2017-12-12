pro cv_find_image_file,cinfo,cfile,status 

status = 0
sfile = 'Unknown'

;_______________________________________________________________________
; first look at the information on the cube header for the location
; and name of the d2c file
;_______________________________________________________________________
slope_file = cinfo.cube.dirsci + '/' + cinfo.cube.sci_filename
print,' Looking for Slope file',slope_file


file_exist1 = file_test(slope_file,/regular,/read)


;_______________________________________________________________________
; maybe it was created on a different machine - use the calibration
; directory read in from the preferences file   
;_______________________________________________________________________
if(file_exist1 ne 1) then begin
    ; already added '/' to control.miri_dir in cv.pro
    ; check what control.dirred starts with

    dirsci = cinfo.control.dirred

    print,'looing in Science Directory:',dirsci
    dirsci = strcompress(dirsci,/remove_all)

    ; test ending of dirsci
    len = strlen(dirsci)
    test = strmid(dirsci,len-1,len-1)
    if(test eq '/') then dirsci = strmid(dirsci,0,len-1)


    slope_file =  dirsci + $
                       '/' + cinfo.cube.sci_filename

    file_exist2 = file_test(slope_file,/regular,/read)

    print,' Still Looking for slope file ',slope_file
;_______________________________________________________________________
    ; if it still does not exists ask the user where the blazes it is
;_______________________________________________________________________
    if(file_exist2 ne 1) then begin
        

        c_file = dialog_pickfile(/read,$
                                 get_path=realpath,Path=cinfo.control.dirCube,$
                                 filter = '*.fits',title='Select Slope Image Cube was created from')
        cfile = c_file

        print,'the slope file is now',c_file 
    endif else begin
        cfile = slope_file
    endelse
endif else begin
    cfile = slope_file
endelse


file_exist = file_test(cfile,/regular,/read)
if(file_exist ne 1) then begin 
    result = dialog_message('Can not find the slope images the cube was created from  ',/error)
    status = 1
    return
endif





end
