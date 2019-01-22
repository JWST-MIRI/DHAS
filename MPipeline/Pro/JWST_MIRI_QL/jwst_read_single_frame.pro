; read in  headers of the 
pro jwst_read_single_frame,filename,this_integration,this_frame,$
  subarray,imagedata,image_xsize,image_ysize,stats_image,status,error_message

status = 0
imagedata = 0
refdata = 0
subarray = 0
error_message = '' 
file_exist1 = file_test(filename,/regular,/read)

if(file_exist1 ne 1 ) then begin
    print,' The file does not exist ',filename
    status = 1
    error_message = " The file does not exist " + filename
    return
endif
;_______________________________________________________________________
; read in raw data
;_______________________________________________________________________
;
;print,'Opening fits file and reading in data'
fits_open,filename,fcb
fits_read,fcb,cube_raw,header0,/header_only,exten_no = 0
fits_read,fcb,cube_raw,header1,exten_no = 1
fits_close,fcb

image_xsize = fxpar(header1,'NAXIS1',count = count)
image_ysize = fxpar(header1,'NAXIS2',count = count)
ngroups = fxpar(header1,'NAXIS3',count = count)
nints= fxpar(header1,'NAXIS3',count = count)

ngroups = fxpar(header0,'NGROUPS',count=count)
nints = fxpar(header0,'NINTS',count = count)

colstart = fxpar(header0,'SUBSTRT2',count = count)
if(count eq 0) then colstart = 1
rowstart = fxpar(header0,'SUBSTRT1',count = count)
if(count eq 0) then rowstart = 1


if(image_xsize ne 1032) then begin
    subarray = 1
endif

header0 = 0
header1 = 0 
print,' Reading Science Frame Image data ',filename


if(this_integration+1 gt nints) then begin
    sint = strcompress(string(this_integration+1),/remove_all)
    error_message = "The requested integration (" + sint+ ") for file" + filename + $
             " is out of bounds" 
    status = 1
    return
endif
if(this_frame+1 gt ngroups) then begin
    sframe = strcompress(string(this_frame+1),/remove_all)
    error_message = "The requested frame (" + sframe + ") for file" + filename + $
             " is out of bounds" 
    status = 1
    return
endif
;_______________________________________________________________________

print,'size of science image',image_xsize,image_ysize
imagedata = fltarr(image_xsize,image_ysize)

print,'Reading integration #',this_integration+1
print,'Reading frame       #',this_frame+1
imagedata[*,*] = cube_raw[*,*,this_frame,this_integration]

cube_raw = 0

if(subarray eq 0) then image_noref_data = imagedata[4:1027,*]
if(subarray eq 1 and colstart eq 1) then image_noref_data = imagedata[4:*,*]
;_______________________________________________________________________
;print,' Finding stats on images'
jwst_get_image_stat,image_noref_data,image_mean,stdev_pixel,image_min,image_max,$
               irange_min,irange_max,image_median,stdev_mean

image_noref_data = 0

stats_image = fltarr(8)

stats_image[0] = image_mean
stats_image[1] = image_median
stats_image[2] = stdev_pixel
stats_image[3]  = image_min
stats_image[4] = image_max
stats_image[5] = irange_min
stats_image[6] = irange_max
stats_image[7] = stdev_mean


;_______________________________________________________________________
header_raw = 0

end

