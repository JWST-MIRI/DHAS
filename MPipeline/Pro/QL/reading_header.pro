pro reading_header,info,status,error_message

info.data.subarray = 0
status = 0
error_message = ' ' 
;print,'reading header ', info.control.filename_raw

file_exist1 = file_test(info.control.filename_raw,/regular,/read)
if(file_exist1 ne 1 ) then begin
    status = 1
    error_message = " The Science frame file does not exist "+ info.control.filename_raw
    return
endif

;_______________________________________________________________________
; read in raw data
;_______________________________________________________________________
;

print,'Opening fits file and reading in data',info.control.filename_raw
fits_open,info.control.filename_raw,fcb
fits_read,fcb,cube_raw,header_raw,/header_only

fits_close,fcb

check = fxpar(header_raw,'CAL_VER',count = count)
if(count eq 0) then begin
   result = dialog_message(" You need need to use 'miri_ql' not 'ql' for this data",/error)
   stop
endif

check = fxpar(header_raw,'MS_VER',count = count)
if(count ne 0) then begin
    print,' You Opened a Slope File instead of the Science Frame Image File'
    print,' Try again'
    status = 1
    error_message =" You opened a Slope file instead of Science frame image file, try again"
    ;return
endif
naxis1 = fxpar(header_raw,'NAXIS1',count = count)
naxis2 = fxpar(header_raw,'NAXIS2',count = count)
naxis3 = fxpar(header_raw,'NAXIS3',count = count)
info.data.naxis1 = naxis1
info.data.naxis2 = naxis2
info.data.naxis3 = naxis3
info.data.colstart = fxpar(header_raw,'COLSTART',count = count)
if(count eq 0) then info.data.colstart = 1
info.data.rowstart = fxpar(header_raw,'ROWSTART',count = count)
if(count eq 0) then info.data.rowstart = 1

rowstart = info.data.rowstart

info.data.colstop = (naxis1/4) + info.data.colstart + 1

bzero = fxpar(header_raw,'BZERO',count = count)
if(count lt 1) then bzero = 1
info.data.bzero = bzero

detector =  fxpar(header_raw,'DETECTOR',count = count)
info.data.detector= strcompress(detector,/remove_all)
origin = fxpar(header_raw,'ORIGIN',count = count)
info.data.origin= strcompress(origin,/remove_all)
determine_detector,info.data.detector, info.data.origin,detector_code
info.data.detector_code = detector_code

colstart = info.data.colstart
fix_colstart, detector_code, colstart
info.data.colstart = colstart

print,'value of colstart',info.data.colstart

if(naxis1 eq 1290 and naxis2 eq 1024) then begin
   print,'Unsupported image size',naxis1,naxis2
    stop
endif

info.data.nramps = fxpar(header_raw,'NGROUPS',count=count)
if(count eq 0) then info.data.nramps = fxpar(header_raw,'NGROUP',count = count)
if(count eq 0) then info.data.nramps = naxis3

info.data.nints = fxpar(header_raw,'NINTS',count = count)
if(count eq 0) then begin
    info.data.nints = fxpar(header_raw,'NINT',count = count)
    if(count eq 0) then info.data.nints = 1
    if(info.data.nints eq 0) then begin
        print,' **********************************'
        print,' NINT in header did not contain a value value, setting = 1'
        info.data.nints = 1
        print,' **********************************'
    endif
endif

info.data.framediv = 1
info.data.framediv = fxpar(header_raw,'FRMDIVSR',count=count)
if(info.data.framediv ne 1 and count ne 0) then begin
   print,' FRMDIVSR is not 1, this is FASTGRPAVG data, adjusting NGroups for QL tool',info.data.framediv
   info.data.nramps = info.data.nramps/info.data.framediv
endif

info.data.coadd = 0
;if(info.data.nramps eq 1 and info.data.nints gt 1) then begin
;    info.data.coadd = 1
;    status = 1
;    error_message = " The DHAS does not support NGROUP =1 data "+ info.control.filename_raw
;    return 
;endif


nsample = fxpar(header_raw,'NSAMPLE',count = count)
if(count eq 0) then begin
    nsample = fxpar(header_raw,'NSAMPLES',count = count)
    if(count eq 0) then nsample =1
endif
;  // Mode = 0, Fast, Mode= 1, Slow, Mode = 2 Fast Short mode.
if(nsample eq 1) then info.data.mode =0
if(nsample eq 10) then info.data.mode =1

nints = info.data.nints
nramps = info.data.nramps
check_header, naxis3,nints,nramps
info.data.nints = nints
info.data.nramps = nramps

info.data.nslopes = info.data.nints

print,' Reading Science Frame Image data ',info.control.filename_raw
print,' Number of Integrations:',info.data.nints 
print,' Number of frames/int  :',info.data.nramps



ncube = info.data.nints * info.data.nramps
info.data.num_frames = info.data.nramps
print,'info.data.num_frames', info.data.num_frames
if(ncube gt info.control.read_limit) then begin
    info.data.read_all = 0
    if(info.control.read_limit gt info.data.nramps) then info.control.read_limit= info.data.nramps
    info.data.num_frames = info.control.read_limit
endif else begin
    info.data.read_all = 1
endelse

info.data.ref_xsize = naxis1/4
info.data.ref_ysize = naxis2 - naxis2/5

info.data.image_xsize = naxis1 
info.data.image_ysize = naxis2 - naxis2/5
info.data.ref_exist = 1

print,'value of image_xsize',info.data.image_xsize

if (naxis2  eq 1024 ) then begin
    print,' No reference image exists'
    info.data.image_ysize = naxis2
    info.data.ref_exist = 0
endif

print,'size of science image',info.data.image_xsize,info.data.image_ysize
print,'reference image      ',info.data.ref_xsize,info.data.ref_ysize

if(naxis1 ne 1032) then begin
    info.data.subarray = 99
    print,'This is subarray data'

    if(naxis1 eq 256 ) then info.data.subarray = 1 
    if(naxis1 eq 320) then info.data.subarray = 2
    if(naxis1 eq 512)then  info.data.subarray = 3
    if(naxis1 eq 128) then info.data.subarray = 4
    if(naxis1 eq 64) then info.data.subarray = 5
    if(naxis1 eq 32) then info.data.subarray = 6 
    if(naxis1 eq 16) then info.data.subarray = 7
    ; take are of unknown subarray size (info.data.subarray = 99)
                                
endif 

; set up the size of arrays based on how many integrations to read in 
; _______________________________________________________________________
header_raw = 0 ; free memory

Widget_Control,info.QuickLook,Set_UValue=info

end

;_______________________________________________________________________  
;***********************************************************************

pro reading_slope_header,info,status,error_message

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

fits_close,fcb
cube=0

check = fxpar(header_slope,'CAL_VER',count = count)
if(count eq 0) then begin
   result = dialog_message(" You need need to use 'miri_ql' not 'ql' for this data",/error)
   stop
endif

naxis1 = fxpar(header_slope,'NAXIS1',count = count)
naxis2 = fxpar(header_slope,'NAXIS2',count = count)


info.data.colstart = fxpar(header_slope,'COLSTART',count = count)
if(count eq 0) then info.data.colstart = 1
info.data.rowstart = fxpar(header_slope,'ROWSTART',count = count)
if(count eq 0) then info.data.rowstart = 1

rowstart = info.data.rowstart
bzero = fxpar(header_slope,'BZERO',count = count)
if(count lt 1) then bzero = 1
info.data.bzero = bzero


detector =  fxpar(header_slope,'DETECTOR',count = count)
info.data.detector= strcompress(detector,/remove_all)
origin = fxpar(header_slope,'ORIGIN',count = count)
info.data.origin= strcompress(origin,/remove_all)
determine_detector,info.data.detector, info.data.origin,detector_code
info.data.detector_code = detector_code

colstart = info.data.colstart
fix_colstart, detector_code, colstart
info.data.colstart = colstart
 

info.data.nramps = fxpar(header_slope,'NGROUPS',count=count)
if(count eq 0) then info.data.nramps = fxpar(header_slope,'NGROUP',count = count)
if(count eq 0) then info.data.nramps = 1

info.data.nints = fxpar(header_slope,'NINTS',count = count)
if(count eq 0) then info.data.nints = fxpar(header_slope,'NINT',count = count)
if(count eq 0) then info.data.nints = 1
if(info.data.nints eq 0) then info.data.nints = 1

info.data.framediv = 1
info.data.framediv = fxpar(header_slope,'FRMDIVSR',count=count)
if(info.data.framediv ne 1 and count ne 0) then begin
   print,' FRMDIVSR is not 1, this is FASTGRPAVG data, adjusting NGroups for QL tool'
   info.data.nramps = info.data.nramps/info.data.framediv
endif

info.data.coadd = 0
if(info.data.nramps eq 1 and info.data.nints gt 1) then begin
    info.data.coadd = 1
    status = 1
    error_message = " The DHAS does not support NGROUP =1 data "+ info.control.filename_raw
    return 
endif

nsample = fxpar(header_slope,'NSAMPLE',count = count)
if(count eq 0) then begin
    nsample = fxpar(header_slope,'NSAMPLES',count = count)
    if(count eq 0) then nsample =1
endif
;  // Mode = 0, Fast, Mode= 1, Slow, Mode = 2 Fast Short mode.
if(nsample eq 1) then info.data.mode =0
if(nsample eq 10) then info.data.mode =1

nints = info.data.nints

info.data.nslopes = info.data.nints
print,' Reading Science Frame Image data ',info.control.filename_slope
print,' Number of Integrations:',info.data.nints 
print,' Number of frames/int  :',info.data.nramps

info.data.num_frames = info.data.nramps

info.data.image_xsize = naxis1
info.data.image_ysize = naxis2 - naxis2/5

    
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

Widget_Control,info.QuickLook,Set_UValue=info

end

;_______________________________________________________________________  
