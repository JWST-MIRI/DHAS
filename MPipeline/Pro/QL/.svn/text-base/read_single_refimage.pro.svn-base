pro read_single_refimage,filename,this_integration,this_frame,subarray,$
  refdata,ref_xsize, ref_ysize,stats_ref,status,error_message



status = 0
error_message = ' '
refdata = 0
subarray = 0
file_exist1 = file_test(filename,/regular,/read)

if(file_exist1 ne 1 ) then begin
    status = 1
    error_message = ' The file does not exist ' + filename 
    return
endif
;_______________________________________________________________________
; read in raw data
;_______________________________________________________________________

fits_open,filename,fcb
fits_read,fcb,cube_raw,header_raw,/header_only,exten_no = 0
fits_close,fcb

naxis1 = fxpar(header_raw,'NAXIS1',count = count)
naxis2 = fxpar(header_raw,'NAXIS2',count = count)
naxis3 = fxpar(header_raw,'NAXIS3',count = count)

nramps = fxpar(header_raw,'NGROUPS',count=count)
if(count eq 0) then nramps = fxpar(header_raw,'NGROUP',count = count)
if(count eq 0) then nramps = naxis3
nints = fxpar(header_raw,'NINTS',count = count)
if(count eq 0) then nints = fxpar(header_raw,'NINT',count = count)
if(count eq 0) then nints = 1
if(nints eq 0) then nints = 1


if(naxis1 eq 1290 and naxis2 eq 1024) then begin
    status = 1
    error_message = 'This data is in the old format, reference data is imbedded in the image' + $
    ' This format is not supported by this version - see 2.5.2'
    return
endif

colstart = fxpar(header_raw,'COLSTART',count = count) ; For JPL data this value is not correction for colstart > 1
                                ; for this routine is does not matter
                                ; what the exact value of colstart is
                                ; for values > 1
if(count eq 0) then colstart = 1
rowstart = fxpar(header_raw,'ROWSTART',count = count)
if(count eq 0) then rowstart = 1
subarray = 0

if(naxis1 ne 1032) then begin
    subarray = 1
endif

; check if missing data
check_header,naxis3,nints,nramps

print,' Reading Reference Image of  Science Frame ',filename
print,' Number of Integrations:',nints
print,' Number of frames/int:  ',nramps

print,' Requested integration ',this_integration+1
print,' Requested frame ' ,this_frame+1

;_______________________________________________________________________
; test if selected integration or frame out of bounds of file.


if(this_integration+1 gt nints) then begin
    sint = strcompress(string(this_integration+1),/remove_all)
    error_message = "The requested integration (" + sint+ ") for file" + filename + $
             " is out of bounds"
    status = 1
    return
endif
if(this_frame+1 gt nramps) then begin
    sframe = strcompress(string(this_frame+1),/remove_all)
    error_message = "The requested frame (" + sframe + ") for file" + filename + $
             " is out of bounds"

    status = 1
    return
endif
;_______________________________________________________________________



image_xsize = naxis1
image_ysize = naxis2 - naxis2/5

ref_exist = 1
ref_xsize = naxis1/4
ref_ysize = image_ysize

if(naxis2 eq 1024) then begin
    image_ysize = 1024
    ref_exist = 0
endif



print,'reference image      ',ref_xsize,ref_ysize
refdata = fltarr(ref_xsize,ref_ysize)

m = this_integration *  nramps
;im_raw = readfits_miri(filename,nslice = m+this_frame,/silent)
im_raw = readfits(filename,nslice = m+this_frame,/silent)




if(ref_exist eq 1) then begin
    refdata[*,*] = im_raw[*,image_ysize:*]
endif
if(ref_exist eq 0) then begin
    refdata[*,*] = 0.0
    print,' Reference image does not exist, setting  image = 0'
endif

im_raw = 0

;_______________________________________________________________________
;
; stats on reference images, ref_stat[mean,sigma,min,max]
;                            ref_range[min,max] starting values for  min,max dsplay range

stats_ref = fltarr(9)
ref_range = fltarr(2)
if(ref_exist eq 1) then begin
; remove the boarder reference pixels

    if(subarray eq 0) then ref = refdata[1:ref_xsize-2,*]
    if(subarray eq 1) then begin 
        if(colstart eq 1) then ref = refdata[1:ref_xsize-1,*]
        if(colstart ne 1) then ref  = refdata
    endif

    get_image_stat,ref,image_mean,stdev_pixel,image_min,image_max,$
                   irange_min,irange_max,image_median,stdev_mean,skew,ngood,nbad

    stats_ref[0] = image_mean
    stats_ref[1] = image_median
    stats_ref[2] = stdev_pixel
    stats_ref[3] = image_min
    stats_ref[4] = image_max
    stats_ref[5] =  irange_min
    stats_ref[6] =  irange_max
    stats_ref[7] = stdev_mean
    stats_ref[8] = skew
    
endif else begin

    stats_ref[0] = 0.0
    stats_ref[1] = 0.0
    stats_ref[2] = 0.0
    stats_ref[3] = 0.0
    stats_ref[4] = 0.0
    stats_ref[5] = 0.0
    stats_ref[6] = 0.0
    stats_ref[7] = 0.0
    stats_ref[8] = 0.0
endelse

ref = 0
end
