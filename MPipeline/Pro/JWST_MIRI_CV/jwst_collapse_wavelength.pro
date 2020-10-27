
;_______________________________________________________________________
; collapse the data along wavelength
;***********************************************************************
pro jwst_collapse_wavelength,x1,x2,y1,y2,cubes,image2d,status,w1=w1, w2=w2, nwave= nwave,$
  iw1 = iw1, iw2=iw2

;***********************************************************************
status = 0
status = 0
input_filename = ' ' 

filename =cubes.filename
 ;_______________________________________________________________________
; initialize varibles
full_cube = 1
istarting_wavelength = 0 
starting_wavelength = (*cubes.pwavelength)[istarting_wavelength]
iending_wavelength = cubes.naxis3-1
ending_wavelength = (*cubes.pwavelength)[iending_wavelength]
num_wave_bins  = 0
;_______________________________________________________________________
; Check to see which options are set 
if(keyword_set(w1)) then begin
    starting_wavelength = w1
    wavelength = (*cubes.pwavelength)
    jwst_find_wavelength_index,wavelength,starting_wavelength,istarting_wavelength
    if(istarting_wavelength eq -1) then begin
        serror = 'Could not find the wavelength in the cube: ' + $
                 strcompress(strin(starting_wavelength),/remove_all)
        return
    endif
endif

if(keyword_set(w2)) then begin
    ending_wavelength = w2
    wavelength = (*cubes.pwavelength)
    jwst_find_wavelength_index,wavelength,ending_wavelength,iending_wavelength
    if(iending_wavelength eq -1) then begin
        serror = 'Could not find the wavelength in the cube: ' + $
                 strcompress(strin(ending_wavelength),/remove_all)
        return
    endif
endif

if(keyword_set(iw1)) then begin
    istarting_wavelength = iw1
    if(istarting_wavelength lt 0) then begin 
        serror= ' Starting Wavelength for spectrum plot not set, setting = first wavelength slice'
        istarting_wavelength = 0 
        print,serror
    endif
    starting_wavelength = (*cubes.pwavelength)[istarting_wavelength]
endif

if(keyword_set(iw2)) then begin
    iending_wavelength = iw2
    if(iending_wavelength lt 0) then begin 
        serror= ' Ending Wavelength for spectrum plot not set, setting = last wavelength slice'
        iending_wavelength = cubes.naxis3-1
        print,serror
    endif
    if(iending_wavelength ge cubes.naxis3) then iending_wavelength = cubes.naxis3 - 1
    ending_wavelength = (*cubes.pwavelength)[iending_wavelength]
endif

if(keyword_set(nwave)) then begin
    iending_wavelength = istart_wavelength + nwave
    if(iending_wavelength ge cubes.naxis3) then iending_wavelength = cubes.naxis3 - 1
    ending_wavelength = (*cubes.pwavelength)[iending_wavelength]
endif

;_______________________________________________________________________
nplanes = iending_wavelength - istarting_wavelength + 1
xsize = x2 - x1 + 1
ysize = y2 - y1 + 1

image = fltarr(xsize,ysize)
uimage = fltarr(xsize,ysize)
isum = intarr(xsize,ysize)

z1 = istarting_wavelength
z2 = iending_wavelength
if(istarting_wavelength ne 0) then full_cube = 0
if(iending_wavelength ne cubes.naxis3 - 1) then full_cube = 0

image2d.x1 = x1
image2d.x2 = x2
image2d.y1 = y1
image2d.y2 = y2
image2d.z1 = z1
image2d.z2 = z2
;_______________________________________________________________________
; all of the cube has been read in, pull out the part we want

for i = istarting_wavelength,iending_wavelength do begin
;    print,' 2-d image plane ', i
    region = (*cubes.pcubedata)[x1:x2,y1:y2,i]
    uregion = (*cubes.puncertainty)[x1:x2,y1:y2,i]
    indx = where(finite(region),num)
    
    if(num gt 0) then begin 
        image[indx]  = image[indx] + region[indx]
        uimage[indx]  = uimage[indx] + uregion[indx]
        isum[indx] = isum[indx] + 1
        region = 0
        uregion = 0
    endif 
endfor

index = where(isum ne 0,num)
if(num eq 0) then begin
    ok = dialog_message(" There are not valid data points in selected region, select region again",/info)
    status = 2
    return
endif else begin
    image[index] = image[index]/isum[index]
    uimage[index] = uimage[index]/isum[index]
endelse

image2d.image_min = min(image[index])
image2d.image_max  = max(image[index])


if ptr_valid(image2d.pimage) then ptr_free,image2d.pimage
image2d.pimage = ptr_new(image)

if ptr_valid(image2d.puimage) then ptr_free,image2d.puimage
image2d.puimage = ptr_new(uimage)

if ptr_valid(image2d.pisum) then ptr_free,image2d.pisum
image2d.pisum = ptr_new(isum)


image = 0
isum = 0
uimage = 0


end
