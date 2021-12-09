pro jwst_read_cube_header,filename,jwst_cube,status,error_message
status = 0
error_message = ' ' 

file_exist1 = file_test(filename,/regular,/read)

if(file_exist1 ne 1 ) then begin
    print,' The file does not exist ',filename
    status = 1
    error_message = " The file does not exist " + filename
    jwst_cube.exist = 0
    return
endif

fits_open,filename,fcb
fits_read,fcb,cubedata,header,exten_no = 0,/header_only

sfilename = fxpar(header,'FILENAME',count = count)
channel = fxpar(header,'CHANNEL',count = count)
subchannel = fxpar(header,'SUBCH',count = count)

jwst_cube.channel = channel
jwst_cube.subchannel = subchannel
jwst_cube.filename = filename

fits_read,fcb,cubedata,header,exten_no = 1,/header_only

naxis1 = fxpar(header,'NAXIS1',count = count)
naxis2 = fxpar(header,'NAXIS2',count = count)
naxis3 = fxpar(header,'NAXIS3',count = count)

crval1 = fxpar(header,'CRVAL1',count = count)
crval2 = fxpar(header,'CRVAL2',count = count)
crval3 = fxpar(header,'CRVAL3',count = count)

cdelt1 = fxpar(header,'CDELT1',count = count)
cdelt2 = fxpar(header,'CDELT2',count = count)
cdelt3 = fxpar(header,'CDELT3',count = count)

crpix1 = fxpar(header,'CRPIX1',count = count)
crpix2 = fxpar(header,'CRPIX2',count = count)
crpix3 = fxpar(header,'CRPIX3',count = count)

ctype3 = strcompress(fxpar(header,'CTYPE3',count = count),/remove_all)
jwst_cube.naxis1 = naxis1
jwst_cube.naxis2 = naxis2
jwst_cube.naxis3 = naxis3

jwst_cube.crval1 = crval1
jwst_cube.crval2 = crval2
jwst_cube.crval3 = crval3

jwst_cube.crpix1 = crpix1
jwst_cube.crpix2 = crpix2
jwst_cube.crpix3 = crpix3

jwst_cube.cdelt1 = cdelt1
jwst_cube.cdelt2 = cdelt2
jwst_cube.cdelt3 = cdelt3


; set defaults for x and y ranges of jwst_cube
jwst_cube.x1 = 0
jwst_cube.x2 = naxis1-1

jwst_cube.y1 = 0
jwst_cube.y2 = naxis2-1

wavelength = fltarr(naxis3)
if(ctype3 eq 'WAVE') then begin 
   wavelength[0] = crval3 + cdelt3/2.0 ; crval3 is at 0.5 pixels
   for i = 1, naxis3 -1 do begin
      wavelength[i] = wavelength[i-1] + cdelt3
   endfor
endif

if(ctype3 eq 'WAVE-TAB') then begin
   ftab_ext,filename,1,w1,exten_no=5
   wavelength = w1
endif

dec = fltarr(naxis2)
dec[0] = crval2 + cdelt2/2.0 ; crval2  is at 0.5 pixels
for i = 1, naxis2 -1 do begin
    dec[i] = dec[i-1] + cdelt2
endfor

ra = fltarr(naxis1)
ra[0] = crval1 + cdelt1/2.0 ; crval1 is at 0.5 pixels
for i = 1, naxis1 -1 do begin
    ra[i] = ra[i-1] + cdelt1
endfor

if ptr_valid(jwst_cube.pwavelength) then ptr_free,jwst_cube.pwavelength
jwst_cube.pwavelength = ptr_new(wavelength)

if ptr_valid(jwst_cube.pdec) then ptr_free,jwst_cube.pdec
jwst_cube.pdec = ptr_new(dec)

if ptr_valid(jwst_cube.pra) then ptr_free,jwst_cube.pra
jwst_cube.pra = ptr_new(ra)

wavelength = 0
ra =0 
dec = 0
header = 0
cubedata = 0
end


;_______________________________________________________________________
