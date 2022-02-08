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
    return
endif

info.jwst_data.colstart = fxpar(header_raw,'SUBSTRT2',count = count)
if(count eq 0) then info.jwst_data.colstart = 1
info.jwst_data.rowstart = fxpar(header_raw,'SUBSTRT1',count = count)
if(count eq 0) then info.jwst_data.rowstart = 1

info.jwst_data.frame_time = fxpar(header_raw,'TGROUP',count = count)
if(count eq 0) then info.jwst_data.frame_time = 0

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

nsample = fxpar(header_raw,'NSAMPLES',count = count)
if(count eq 0) then begin
   print,'NSAMPLES is missing from header'
   stop
endif

;  // Mode = 0, Fast, Mode= 1, Slow, Mode = 2 Fast Short mode.
if(nsample eq 1) then info.jwst_data.mode =0
if(nsample eq 10) then info.jwst_data.mode =1

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
   print,' NINTS and NAXIS4 do not match'
   stop
endif


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
pro jwst_reading_slope_header,info,status,error_message


info.jwst_data.subarray = 0
status = 0
error_message = ' ' 

file_exist1 = file_test(info.jwst_control.filename_slope,/regular,/read)
if(file_exist1 ne 1 ) then begin
    status = 1
    error_message = " The Reduced Science frame file does not exist "+ info.jwst_control.filename_slope
    return
endif

;_______________________________________________________________________
print,'Opening fits file and reading in data',info.jwst_control.filename_slope
fits_open,info.jwst_control.filename_slope,fcb
fits_read,fcb,cube,header_slope,exten_no=0,/header_only
fits_read,fcb,cube,header_slope_data,exten_no=1,/header_only
fits_close,fcb
cube=0

info.jwst_data.colstart = fxpar(header_slope,'COLSTART',count = count)
if(count eq 0) then info.jwst_data.colstart = 1
info.jwst_data.rowstart = fxpar(header_slope,'ROWSTART',count = count)
if(count eq 0) then info.jwst_data.rowstart = 1

info.jwst_data.frame_time = fxpar(header_slope,'TGROUP',count = count)
if(count eq 0) then info.jwst_data.frame_time = 0

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

fit_start = 1
fit_end  = info.jwst_data.ngroups
complete= 'COMPLETE'
last_frame_status = fxpar(header_slope,'S_LASTFR',count = count)
result = strcmp(last_frame_status,complete)
if(result eq 1) then fit_end = info.jwst_data.ngroups -1
info.jwst_data.end_fit = fit_end

first_frame_status = fxpar(header_slope,'S_FRSTFR',count = count)
result = strcmp(first_frame_status,complete)
if(result eq 1) then fit_start = 2
info.jwst_data.start_fit = fit_start

nsample = fxpar(header_slope,'NSAMPLES',count = count)
if(count eq 0) then  begin
   print,'NSAMPLES not found in header'
   stop
endif

;  // Mode = 0, Fast, Mode= 1, Slow, Mode = 2 Fast Short mode.
if(nsample eq 1) then info.jwst_data.mode =0
if(nsample eq 10) then info.jwst_data.mode =1

print,' Number of Integrations:',info.jwst_data.nints 
print,' Number of frames/int  :',info.jwst_data.ngroups 

naxis1 = fxpar(header_slope_data,'NAXIS1',count = count)
naxis2 = fxpar(header_slope_data,'NAXIS2',count = count)

info.jwst_data.num_frames = info.jwst_data.ngroups

info.jwst_data.image_xsize = naxis1
info.jwst_data.image_ysize = naxis2 

print,'size of science image',info.jwst_data.image_xsize,info.jwst_data.image_ysize

if(naxis1 ne 1032) then begin
    info.jwst_data.subarray = 99
    print,'This is subarray data'

; only need the types to read in the location of the default Tracking Pixels 
    if(naxis1 eq 256) then info.jwst_data.subarray = 1 
    if(naxis1 eq 320) then info.jwst_data.subarray = 2 
    if(naxis1 eq 512)then  info.jwst_data.subarray = 3
    if(naxis1 eq 128) then info.jwst_data.subarray = 4
    if(naxis1 eq 64) then info.jwst_data.subarray = 5 
    if(naxis1 eq 32) then info.jwst_data.subarray = 6 
    if(naxis1 eq 16) then info.jwst_data.subarray = 7
    ; take are of unknown subarray size (info.jwst_data.subarray = 99)
    print,' info.jwst_data.subarray code ', info.jwst_data.subarray
endif 

; _______________________________________________________________________
header_slope = 0 ; free memory
Widget_Control,info.jwst_QuickLook,Set_UValue=info

end

;_______________________________________________________________________  
