;_______________________________________________________________________

pro read_cube,filename,cube,status,error_message,$
              w1=w1,w2=w2,$
              iw1=iw1,iw2 = iw2,$
              nwave=nwave

print,' Reading cube ',filename              

read_cube_header,filename,cube,status,error_message
if(status eq 1) then begin

    print,'Problem reading cube header', error_message
    return
endif


 ;_______________________________________________________________________
; initialize varibles
full_cube = 1
istarting_wavelength = 0 
starting_wavelength = (*cube.pwavelength)[istarting_wavelength]
iending_wavelength = cube.naxis3-1

ending_wavelength = (*cube.pwavelength)[iending_wavelength]

num_wave_bins  = 0

;

 ;_______________________________________________________________________
; Check to see which options are set 
if(keyword_set(w1)) then begin
    starting_wavelength = w1
    wavelength = (*cube.wavelength)
    find_wavelength_index,wavelength,starting_wavelength,istarting_wavelength
    if(istarting_wavelength eq -1) then begin
        serror = 'Could not find the wavelength in the cube: ' + $
                 strcompress(strin(starting_wavelength),/remove_all)
        return
    endif

endif

if(keyword_set(w2)) then begin
    ending_wavelength = w2
    wavelength = (*cube.wavelength)
    find_wavelength_index,wavelength,ending_wavelength,iending_wavelength
    if(iending_wavelength eq -1) then begin
        serror = 'Could not find the wavelength in the cube: ' + $
                 strcompress(strin(ending_wavelength),/remove_all)
        return
    endif
endif

if(keyword_set(iw1)) then begin
    istarting_wavelength = iw1
    starting_wavelength = (*cube.pwavelength)[istarting_wavelength]
endif

if(keyword_set(iw2)) then begin
    iending_wavelength = iw2
    if(iending_wavelength ge cube.naxis3) then iending_wavelength = cube.naxis3 - 1
    ending_wavelength = (*cube.pwavelength)[iending_wavelength]
endif

if(keyword_set(nwave)) then begin
    iending_wavelength = istarting_wavelength + nwave
    if(iending_wavelength ge cube.naxis3) then iending_wavelength = cube.naxis3 - 1
    ending_wavelength = (*cube.pwavelength)[iending_wavelength]
endif

; if reading in part of wavelength - then redefine wavelength planes
 ;                                   of cube and naxis3
if(istarting_wavelength ne 0 or iending_wavelength ne cube.naxis3-1) then begin

    naxis3 = iending_wavelength - istarting_wavelength + 1
    wavelength = fltarr(naxis3)
    wavelength = (*cube.pwavelength)[istarting_wavelength: iending_wavelength]
    if ptr_valid(cube.pwavelength) then ptr_free,cube.pwavelength
    cube.pwavelength = ptr_new(wavelength)
    wavelength = 0
    cube.naxis3 = naxis3
    full_cube = 0
endif


 ;_______________________________________________________________________

file_exist1 = file_test(filename,/regular,/read)

if(file_exist1 ne 1 ) then begin
    print,' The file does not exist ',filename
    status = 1
    error_message = " The file does not exist " + filename
    cube.exist = 0
    return
endif

fits_open,filename,fcb




if(full_cube eq 1) then begin 
    print,' Reading all of cube' 
    fits_read,fcb,cubedata,header,exten_no = 0
    fits_read,fcb,uncertainty,header,exten_no = 1
endif else begin

    widget_control,/hourglass
    progressBar = Obj_New("ShowProgress", color = 150, $
                      message = " Reading in CUBE Data",$
                          xsize = 250, ysize = 40)
    progressBar -> Start


    nplanes = iending_wavelength - istarting_wavelength + 1
    cubedata = fltarr(cube.naxis1,cube.naxis2,nplanes)
    Uncertainty = fltarr(cube.naxis1,cube.naxis2,nplanes)
    print, 'Reading Wavelength planes ',    (*cube.pwavelength)[0],$
           (*cube.pwavelength)[iending_wavelength-istarting_wavelength]

    
    wavelength = fltarr(iending_wavelength - istarting_wavelength + 1)
    j = 0
    for i = istarting_wavelength,iending_wavelength do begin
        percent = (float(j)/float(nplanes) * 100)
        progressBar -> Update,percent
;        image = readfits_miri(filename,nslice = i,/silent) 
        image = readfits(filename,nslice = i,/silent) 
        cubedata[*,*,j] = image

;        image = readfits_miri(filename,nslice = i,/silent,exten=1) 
        image = readfits(filename,nslice = i,/silent,exten=1) 
        uncertainty[*,*,j] = image
        
        wavelength[j] = (*cube.pwavelength)[j]


        j = j + 1
        image = 0 
    endfor

    if ptr_valid(cube.pwavelength) then ptr_free,cube.pwavelength
    cube.pwavelength = ptr_new(wavelength)

    progressBar -> Destroy
    obj_destroy, progressBar

    iending_wavelength = iending_wavelength - istarting_wavelength
    istarting_wavelength = 0

endelse

; redefine wavelength range

cube.istart_wavelength = istarting_wavelength
cube.iend_wavelength =iending_wavelength
cube.start_wavelength = starting_wavelength 
cube.end_wavelength = ending_wavelength 

if ptr_valid(cube.pcubedata) then ptr_free,cube.pcubedata
cube.pcubedata = ptr_new(cubedata)

if ptr_valid(cube.puncertainty) then ptr_free,cube.puncertainty
cube.puncertainty = ptr_new(uncertainty)


cubedata = 0
header = 0
uncertainty = 0
end


;_______________________________________________________________________
