;_______________________________________________________________________
; extract the data from the file
;***********************************************************************
pro extract_spectrum_from_cube,x1,x2,y1,y2,cube,spectrum,status,w1=w1,w2=w2,nwave=nwave
;***********************************************************************
status = 0
input_filename = ' ' 
filename =cube.filename


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
    wavelength = (*cube.pwavelength)
    find_wavelength_index,wavelength,starting_wavelength,istarting_wavelength
    if(istarting_wavelength eq -1) then begin
        serror = 'Could not find the wavelength in the cube: ' + $
                 strcompress(string(starting_wavelength),/remove_all)
        return
    endif
endif

if(keyword_set(w2)) then begin
    ending_wavelength = w2
    wavelength = (*cube.pwavelength)
    find_wavelength_index,wavelength,ending_wavelength,iending_wavelength
    if(iending_wavelength eq -1) then begin
        serror = 'Could not find the wavelength in the cube: ' + $
                 strcompress(string(ending_wavelength),/remove_all)
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
    iending_wavelength = istart_wavelength + nwave
    if(iending_wavelength ge cube.naxis3) then iending_wavelength = cube.naxis3 - 1
    ending_wavelength = (*cube.pwavelength)[iending_wavelength]
endif

;_______________________________________________________________________
nplanes = iending_wavelength - istarting_wavelength + 1

spectrum_data = fltarr(nplanes)
uncertainty = fltarr(nplanes)
if(istarting_wavelength ne 0) then full_cube = 0
if(iending_wavelength ne cube.naxis3 - 1) then full_cube = 0
; 

;_______________________________________________________________________
; all of the cube has been read in, pull out the part we want

if(full_cube eq 1) then begin

    for i = 0,cube.naxis3 -1 do begin
        region = (*cube.pcubedata)[x1:x2,y1:y2,i]
        uregion = (*cube.puncertainty)[x1:x2,y1:y2,i]

        indx = where(finite(region),num)
        if(num gt 0) then begin
            ave = mean(region,/nan)
            ave_uncer = (uregion*uregion)
            ave_uncer = mean(ave_uncer,/nan)
            ave_uncer = sqrt(ave_uncer)

        endif else begin
            ave = !values.F_NaN
            ave_uncer = !values.F_NaN 
        endelse
        spectrum_data[i] = ave
        uncertainty[i] = ave_uncer
    endfor
endif else begin

    widget_control,/hourglass
    progressBar = Obj_New("ShowProgress", color = 150, $
                      message = " Reading in CUBE Data",$
                          xsize = 250, ysize = 40)
    progressBar -> Start


    j = 0
    for i = istarting_wavelength,iending_wavelength do begin
        percent = (float(j)/float(nplanes) * 100)
        progressBar -> Update,percent
        image = readfits(filename,nslice = i,/silent) 
        uimage = readfits(filename,nslice = i,/silent,exten=1)

;        image = readfits_miri(filename,nslice = i,/silent) 
;        uimage = readfits_miri(filename,nslice = i,/silent,exten=1)

        region = image[x1:x2,y1:y2]
        uregion =uimage [x1:x2,y1:y2]

        indx = where(finite(region),num)
        if(num gt 0) then begin
            ave = mean(region,/nan)
            ave_uncer = (uregion*uregion)
            ave_uncer = mean(ave_uncer,/nan)
            ave_uncer = sqrt(ave_uncer)
        endif else begin
            ave = !values.F_NaN 
            ave_uncer = !values.F_NaN    
        endelse
        spectrum_data[j] = ave
        uncertainty[j] = ave_uncer

        j = j + 1
        image = 0
        region = 0
        uregion = 0
    endfor
    progressBar -> Destroy
    obj_destroy, progressBar
endelse





index = where(finite(spectrum_data),num)
if(num eq 0) then begin
    ok = dialog_message(" There are not valid data points in selected region, select region again",/info)
    status = 2
    return
endif

mflux = mean(spectrum_data[index])
st = stddev(spectrum_data[index])
spectrum.flux_range[0] = min(spectrum_data[index])
spectrum.flux_range[1]  = mflux + st*5

if(full_cube) then spectrum.flux_range[1]  = mflux + st*3


spectrum.wavelength_range[0] = starting_wavelength
spectrum.wavelength_range[1] = ending_wavelength

if ptr_valid(spectrum.pspectrum) then ptr_free,spectrum.pspectrum
spectrum.pspectrum = ptr_new(spectrum_data)

if ptr_valid(spectrum.puncertainty) then ptr_free,spectrum.puncertainty
spectrum.puncertainty = ptr_new(uncertainty)

spectrum_data = 0
uncertainty = 0
end
