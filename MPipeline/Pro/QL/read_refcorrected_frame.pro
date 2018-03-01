; 
pro read_refcorrected_frame,$
  filename,this_integration,this_frame,$
  subarray,imagedata,image_xsize,image_ysize,stats_image,$
  status,error_message

status = 0
error_message = ''
imagedata = 0
refdata = 0
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

nramps = fxpar(header_raw,'NGROUPS',count=count)
if(count eq 0) then nramps = fxpar(header_raw,'NGROUP',count = count)
if(count eq 0) then nramps = naxis3  
nints = fxpar(header_raw,'NINTS',count = count)
if(count eq 0) then nints = fxpar(header_raw,'NINT',count = count)
if(count eq 0) then nints = 1
if(nints eq 0) then nints = 1

framediv = 1
framediv = fxpar(header_raw,'FRMDIVSR',count=count)
if(framediv ne 1 and count ne 0) then begin
   print,' FRMDIVSR is not 1, this is FASTGRPAVG data, adjusting NGroups for QL tool'
   nramps = nramps/framediv
endif

if(naxis1 eq 1290 and naxis2 eq 1024) then begin
    status = 1
    print = 'This data is in the old format, reference data is imbedded in the image' + $
    ' This format is not supported by this version - see 2.5.2'
    stop

endif

colstart = fxpar(header_raw,'COLSTART',count = count) ; For JPL data this value is not correct for values > 1
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

print,' Reading Reference corrected  data ',filename
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
if(naxis2 eq 1024) then image_ysize = 1024

;_______________________________________________________________________
print,'size of science image',image_xsize,image_ysize

imagedata = fltarr(image_xsize,image_ysize)
;_______________________________________________________________________

m = this_integration *  nramps

print,'Reading integration #',this_integration+1
print,'Reading frame       #',this_frame+1


;im_raw = readfits_miri(filename,nslice = m+this_frame,/silent)        
im_raw = readfits(filename,nslice = m+this_frame,/silent)        


imagedata[*,*] = im_raw[*,0:image_ysize-1]
im_raw = 0

if(subarray eq 0) then image_noref_data = imagedata[4:1027,*]
if(subarray eq 1) then  begin
    if(colstart eq 1) then begin
        imageno_ref_data = imagedata[4:*,*]
    endif else begin 

        imageno_ref_data = imagedata[*,*]
    endelse
endif
;_______________________________________________________________________
;
; stats on images, image_stat[mean,sigma,min,max]
;                  image_range[min,max] starting values for min,max dsplay range

;print,' Finding stats on images'
get_image_stat,image_noref_data,image_mean,stdev_pixel,image_min,image_max,$
               irange_min,irange_max,image_median,stdev_mean,skew,ngood,nbad



stats_image = fltarr(9)

stats_image[0] = image_mean
stats_image[1] = image_median
stats_image[2] = stdev_pixel
stats_image[3]  = image_min
stats_image[4] = image_max
stats_image[5] = irange_min
stats_image[6] = irange_max
stats_image[7] = stdev_mean
stats_image[8] = skew
image_noref_data = 0

;_______________________________________________________________________
;

end

