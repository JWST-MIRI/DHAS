; 
pro jwst_read_image_info,filename,nints,ngroups,subarray,image_xsize,image_ysize,colstart,status,error_message

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
fits_read,fcb,cube_raw,header0,/header_only,exten_no = 0
fits_read,fcb,cube_raw,header1,/header_only,exten_no = 1
fits_close,fcb

image_xsize = fxpar(header1,'NAXIS1',count = count)
image_ysize = fxpar(header1,'NAXIS2',count = count)

ngroups = fxpar(header0,'NGROUPS',count=count)
nints = fxpar(header0,'NINTS',count = count)

colstart = fxpar(header0,'SUBSTRT2',count = count)
if(count eq 0) then colstart = 1
rowstart = fxpar(header0,'SUBSTRT1',count = count)
if(count eq 0) then rowstart = 1


if(image_xsize ne 1032) then begin
    subarray = 1
endif




end

