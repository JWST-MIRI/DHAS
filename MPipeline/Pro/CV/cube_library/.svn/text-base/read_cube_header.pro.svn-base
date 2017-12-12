pro read_cube_header,filename,cube,status,error_message
status = 0
error_message = ' ' 

file_exist1 = file_test(filename,/regular,/read)

if(file_exist1 ne 1 ) then begin
    print,' The file does not exist ',filename
    status = 1
    error_message = " The file does not exist " + filename
    cube.exist = 0
    return
endif

fits_open,filename,fcb
fits_read,fcb,cubedata,header,exten_no = 0,/header_only

mrs_ver = fxpar(header,'MRS_VER',count = count)
if(count eq 0) then begin
    error_message = " This is not a cube file created with mrs_cube: "+filename
    cube.exist = 0
    status = 1
    return
endif

cube.d2cfile = 'null'
cube.dircal = 'null'
cube.sci_filename = 'null'
cube.dirsci = 'null'

d2cfile = fxpar(header,'D2CFILE',count = count)
if(count eq 1) then cube.d2cfile = d2cfile

dirsci = fxpar(header,'SCIDIR',count = count)

if(count eq 1) then begin 
    cube.dirsci = dirsci
    dirsci = strcompress(cube.dirsci,/remove_all)
    len = strlen(dirsci) 
    test = strmid(dirsci,len-1,len-1)
    if(test eq '/') then dirsci = strmid(dirsci,0,len-1)
    cube.dirsci  =  dirsci
endif

sfilename = fxpar(header,'FILENAME',count = count)
if(count eq 1) then cube.sci_filename = sfilename


dircal = fxpar(header,'CALDIR',count = count)
if(count eq 1) then begin 
    cube.dircal = dircal
    dircal = strcompress(cube.dircal,/remove_all)
    len = strlen(dircal) 
    test = strmid(dircal,len-1,len-1)
    if(test eq '/') then dircal = strmid(dircal,0,len-1)
    cube.dircal  =  dircal
endif

channel = fxpar(header,'CHANNEL',count = count)
subchannel = fxpar(header,'SUBCH',count = count)
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


intno = fxpar(header,'INTNO',count = count)
if(count eq 0) then intno = 0

testmodel = 0
testmodel  = fxpar(header,'TMODEL',count = count)
if(count eq 0) then testmodel = -1
cube.testmodel = testmodel

cube.naxis1 = naxis1
cube.naxis2 = naxis2
cube.naxis3 = naxis3

cube.crval1 = crval1
cube.crval2 = crval2
cube.crval3 = crval3

cube.crpix1 = crpix1
cube.crpix2 = crpix2
cube.crpix3 = crpix3

cube.cdelt1 = cdelt1
cube.cdelt2 = cdelt2
cube.cdelt3 = cdelt3

cube.extno = intno
cube.channel = channel
cube.subchannel = subchannel
cube.filename = filename


; set defaults for x and y ranges of cube

cube.x1 = 0
cube.x2 = naxis1-1

cube.y1 = 0
cube.y2 = naxis2-1


wavelength = fltarr(naxis3)
wavelength[0] = crval3 + cdelt3/2.0 ; crval3 is at 0.5 pixels
for i = 1, naxis3 -1 do begin
    wavelength[i] = wavelength[i-1] + cdelt3
endfor

beta = fltarr(naxis2)
beta[0] = crval2 + cdelt2/2.0 ; crval2  is at 0.5 pixels
for i = 1, naxis2 -1 do begin
    beta[i] = beta[i-1] + cdelt2
endfor

alpha = fltarr(naxis1)
alpha[0] = crval1 + cdelt1/2.0 ; crval1 is at 0.5 pixels
for i = 1, naxis1 -1 do begin
    alpha[i] = alpha[i-1] + cdelt1
endfor


if ptr_valid(cube.pwavelength) then ptr_free,cube.pwavelength
cube.pwavelength = ptr_new(wavelength)


if ptr_valid(cube.pbeta) then ptr_free,cube.pbeta
cube.pbeta = ptr_new(beta)

if ptr_valid(cube.palpha) then ptr_free,cube.palpha
cube.palpha = ptr_new(alpha)

wavelength = 0
alpha =0 
beta = 0
header = 0
cubedata = 0
end


;_______________________________________________________________________
