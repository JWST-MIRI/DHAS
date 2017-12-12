; 
pro read_image_info,filename,nints,nframes,subarray,image_xsize,image_ysize,colstart,status,error_message

status = 0
error_message = ''
subarray = 0
file_exist1 = file_test(filename,/regular,/read)

if(file_exist1 ne 1 ) then begin
    status = 1
    error_message = ' The file does not exists' + filename
    return
endif
;_______________________________________________________________________
; read in raw data
;_______________________________________________________________________
;
;print,'Opening fits file and reading in data'
fits_open,filename,fcb
fits_read,fcb,cube_raw,header_raw,/header_only,exten_no = 0
fits_close,fcb

naxis1 = fxpar(header_raw,'NAXIS1',count = count)
naxis2 = fxpar(header_raw,'NAXIS2',count = count)
naxis3 = fxpar(header_raw,'NAXIS3',count = count)

nframes = fxpar(header_raw,'NGROUPS',count=count)
if(count eq 0) then nframes = fxpar(header_raw,'NGROUP',count = count)
if(count eq 0) then nframes = naxis3  
nints = 0
nints = fxpar(header_raw,'NINTS',count = count)
if(count eq 0) then nints = fxpar(header_raw,'NINT',count = count)
if(count eq 0) then nints = 1
if(nints eq 0) then nints = 1



colstart = fxpar(header_raw,'COLSTART',count = count)
if(count eq 0) then colstart = 1
rowstart = fxpar(header_raw,'ROWSTART',count = count)
if(count eq 0) then rowstart = 1
subarray = 0

if(naxis1 ne 1032) then begin
    subarray = 1
endif

detector =  fxpar(header_raw,'DETECTOR',count = count)
origin = fxpar(header_raw,'ORIGIN',count = count)
detector_code = 0 
determine_detector,detector, origin,detector_code

fix_colstart, detector_code, colstart


image_xsize = naxis1
image_ysize = naxis2 - naxis2/5


if(naxis2 eq 1024) then begin
    image_ysize = 1024
endif
;_______________________________________________________________________



end

