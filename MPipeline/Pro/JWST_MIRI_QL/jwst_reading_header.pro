pro jwst_reading_header,info,status,error_message

info.jwst_data.subarray = 0
status = 0
error_message = ' ' 

file_exist1 = file_test(info.jwst_control.filename_raw,/regular,/read)
if(file_exist1 ne 1 ) then begin
    status = 1
    error_message = " The Science frame file does not exist "+ info.jwst_control.filename_raw
    return
endif

;_______________________________________________________________________
; read in raw data
;_______________________________________________________________________
;

print,'Opening fits file and reading in data',info.jwst_control.filename_raw
fits_open,info.jwst_control.filename_raw,fcb
fits_read,fcb,cube_raw,header_raw,exten_no=0,/header_only
fits_read,fcb,cube_raw,header_first,exten_no=1,/header_only
fits_read,fcb,cube_raw,header_ref,exten_no=2,/header_only
fits_close,fcb

check = fxpar(header_raw,'S_RAMP',count = count)
if(count ne 0) then begin
    print,' You Opened a Rate File instead of the Raw Science Frame Image File'
    print,' Try again'
    status = 1
    error_message =" You opened a Rate file instead of Science frame image file, try again"
    ;return
endif

info.jwst_data.colstart = fxpar(header_raw,'SUBSTRT2',count = count)
if(count eq 0) then info.jwst_data.colstart = 1
info.jwst_data.rowstart = fxpar(header_raw,'SUBSTRT1',count = count)
if(count eq 0) then info.jwst_data.rowstart = 1

rowstart = info.jwst_data.rowstart

detector =  fxpar(header_raw,'DETECTOR',count = count)
info.jwst_data.detector= strcompress(detector,/remove_all)
origin = fxpar(header_raw,'ORIGIN',count = count)
info.jwst_data.origin= strcompress(origin,/remove_all)

info.jwst_data.ngroups = fxpar(header_raw,'NGROUPS',count=count)
if(count eq 0) then info.jwst_data.ngroups = fxpar(header_raw,'NGROUP',count = count)
if(count eq 0) then begin
   print,'NGROUPS is missing from header'
   stop
endif

info.jwst_data.nints = fxpar(header_raw,'NINTS',count = count)
if(count eq 0) then begin
   print,'NINTS is missing from header'
   stop
endif

info.jwst_data.coadd = 0
if(info.jwst_data.ngroups eq 1 and info.jwst_data.nints gt 1) then begin
    info.jwst_data.coadd = 1
    print,'This tool does not support Co-Added data'
    stop
endif


nsample = fxpar(header_raw,'NSAMPLES',count = count)
if(count eq 0) then begin
   print,'NSAMPLES is missing from header'
   stop
endif

;  // Mode = 0, Fast, Mode= 1, Slow, Mode = 2 Fast Short mode.
if(nsample eq 1) then info.jwst_data.mode =0
if(nsample eq 10) then info.jwst_data.mode =1



check = fxpar(header_raw,'S_RAMP',count = count)
if(count ne 0) then begin
    print,' You Opened a Rate File instead of the Raw Science Frame Image File'
    print,' Try again'
    status = 1
    error_message =" You opened a Rate file instead of Science frame image file, try again"
    ;return
endif
naxis1 = fxpar(header_first,'NAXIS1',count = count)
naxis2 = fxpar(header_first,'NAXIS2',count = count)
naxis3 = fxpar(header_first,'NAXIS3',count = count)
naxis4 = fxpar(header_first,'NAXIS4',count = count)
info.jwst_data.naxis1 = naxis1
info.jwst_data.naxis2 = naxis2
info.jwst_data.naxis3 = naxis3
info.jwst_data.naxis4 = naxis4


if(info.jwst_data.ngroups ne info.jwst_data.naxis3) then begin
   print,' NGROUPS and NAXIS3 do not match'
   stop
endif

if(info.jwst_data.nints ne info.jwst_data.naxis4) then begin
   print,' NINTSS and NAXIS4 do not match'
   stop
endif

info.jwst_data.nslopes = info.jwst_data.nints



print,' Reading Science Frame Image data ',info.jwst_control.filename_raw
print,' Number of Integrations:',info.jwst_data.nints 
print,' Number of frames/int  :',info.jwst_data.ngroups



ncube = info.jwst_data.nints * info.jwst_data.ngroups
info.jwst_data.num_frames = info.jwst_data.ngroups
if(ncube gt info.jwst_control.read_limit) then begin
    info.jwst_data.read_all = 0
    if(info.jwst_control.read_limit gt info.jwst_data.ngroups) then info.jwst_control.read_limit= info.jwst_data.ngroups
    info.jwst_data.num_frames = info.jwst_control.read_limit
endif else begin
    info.jwst_data.read_all = 1
endelse


info.jwst_data.image_xsize = naxis1 
info.jwst_data.image_ysize = naxis2 


info.jwst_data.ref_xsize   = fxpar(header_ref,'NAXIS1',count = count)
info.jwst_data.ref_ysize   = fxpar(header_ref,'NAXIS2',count = count)
info.jwst_data.ref_exist = 1


print,'size of science image',info.jwst_data.image_xsize,info.jwst_data.image_ysize
print,'reference image      ',info.jwst_data.ref_xsize,info.jwst_data.ref_ysize

if(naxis1 ne 1032) then begin
    info.jwst_data.subarray = 99
    print,'This is subarray data'

    if(naxis1 eq 256 ) then info.jwst_data.subarray = 1 
    if(naxis1 eq 320) then info.jwst_data.subarray = 2
    if(naxis1 eq 512)then  info.jwst_data.subarray = 3
    if(naxis1 eq 128) then info.jwst_data.subarray = 4
    if(naxis1 eq 64) then info.jwst_data.subarray = 5
    if(naxis1 eq 32) then info.jwst_data.subarray = 6 
    if(naxis1 eq 16) then info.jwst_data.subarray = 7
                                
endif 

; set up the size of arrays based on how many integrations to read in 
; _______________________________________________________________________
header_raw = 0 ; free memory
header_ref = 0 ; free memory
header_first = 0 ; free memory


Widget_Control,info.jwst_QuickLook,Set_UValue=info

end

;_______________________________________________________________________  
;***********************************************************************

pro not_converted_reading_slope_header,info,status,error_message

info.data.subarray = 0
status = 0
error_message = ' ' 
file_exist1 = file_test(info.control.filename_slope,/regular,/read)
if(file_exist1 ne 1 ) then begin
    status = 1
    error_message = " The Reduced Science frame file does not exist "+ info.control.filename_slope
    return
endif

;_______________________________________________________________________


print,'Opening fits file and reading in data',info.control.filename_slope
fits_open,info.control.filename_slope,fcb
fits_read,fcb,cube,header_slope,/header_only
fits_read,fcb,cube,header_slope,exten_no=1,/header_only

fits_close,fcb
cube=0

info.data.colstart = fxpar(header_slope,'COLSTART',count = count)
if(count eq 0) then info.data.colstart = 1
info.data.rowstart = fxpar(header_slope,'ROWSTART',count = count)
if(count eq 0) then info.data.rowstart = 1

detector =  fxpar(header_slope,'DETECTOR',count = count)
info.jwst_data.detector= strcompress(detector,/remove_all)
origin = fxpar(header_slope,'ORIGIN',count = count)
info.jwst_data.origin= strcompress(origin,/remove_all)


info.jwst_data.ngroups = fxpar(header_slope,'NGROUPS',count=count)
if(count eq 0) then  begin
   print,'NGROUPS not found in header'
   stop
endif

info.jwst_data.nints = fxpar(header_slope,'NINTS',count = count)
if(count eq 0) then  begin
   print,'NINTS not found in header'
   stop
endif

info.jwst_data.coadd = 0
if(info.jwst_data.ngroups eq 1 and info.jwst_data.nints gt 1) then begin
    info.jwst_data.coadd = 1
    print,' This tool does not support Co-added data'
    stop
endif

nsample = fxpar(header_slope,'NSAMPLES',count = count)
if(count eq 0) then  begin
   print,'NSAMPLES not found in header'
   stop
endif

;  // Mode = 0, Fast, Mode= 1, Slow, Mode = 2 Fast Short mode.
if(nsample eq 1) then info.jwst_data.mode =0
if(nsample eq 10) then info.jwst_data.mode =1


info.jwst_data.nslopes = info.jwst_data.nints


print,' Reading Science Frame Image data ',info.jwst_control.filename_slope
print,' Number of Integrations:',info.jwst_data.nints 
print,' Number of frames/int  :',info.jwst_data.ngroups 


naxis1 = fxpar(header_slope,'NAXIS1',count = count)
naxis2 = fxpar(header_slope,'NAXIS2',count = count)
naxis3 = fxpar(header_slope,'NAXIS3',count = count)
naxis4 = fxpar(header_slope,'NAXIS4',count = count)

info.data.num_frames = info.data.nramps

info.data.image_xsize = naxis1
info.data.image_ysize = naxis2 

    
info.data.ref_exist = 1
info.data.ref_xsize = naxis1/4
info.data.ref_ysize = info.data.image_ysize
info.data.ref_exist = 1

if(naxis2 eq 1024) then begin
    info.data.image_ysize = 1024
    info.data.ref_exist = 0
endif

print,'size of science image',info.data.image_xsize,info.data.image_ysize
print,'reference image      ',info.data.ref_xsize,info.data.ref_ysize

if(naxis1 ne 1032) then begin
    info.data.subarray = 99

    print,'This is subarray data'

; only need the types to read in the location of the default Tracking Pixels 
    if(naxis1 eq 256) then info.data.subarray = 1 
    if(naxis1 eq 320) then info.data.subarray = 2 
    if(naxis1 eq 512)then  info.data.subarray = 3
    if(naxis1 eq 128) then info.data.subarray = 4
    if(naxis1 eq 64) then info.data.subarray = 5 
    if(naxis1 eq 32) then info.data.subarray = 6 
    if(naxis1 eq 16) then info.data.subarray = 7
    ; take are of unknown subarray size (info.data.subarray = 99)
    print,' info.data.subarray code ', info.data.subarray
endif 



file_exist = file_test(info.control.filename_slope_refimage,/regular,/read)
if(file_exist eq 0) then begin
    print,' No Slope image exist for reference output'
    info.data.sloperef_exist = 0
endif


; set up the size of arrays based on how many integrations to read in 
; _______________________________________________________________________
header_slope = 0 ; free memory

Widget_Control,info.jwst_QuickLook,Set_UValue=info

end

;_______________________________________________________________________  
