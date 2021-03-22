; Read a single science frame and reference output frame

pro jwst_read_single_frame_and_ref,$
  filename,this_integration,this_frame,$
  subarray,imagedata,image_xsize,image_ysize,stats_image,$
  refdata,ref_xsize,ref_ysize,stats_ref,status,error_message

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
fits_open,filename,fcb
fits_read,fcb,cube_raw,header_raw,/header_only,exten_no = 0


nframes = fxpar(header_raw,'NGROUPS',count=count)
if(count eq 0) then nframes = fxpar(header_raw,'NGROUP',count = count)
if(count eq 0) then nframes = naxis3  
nints = fxpar(header_raw,'NINTS',count = count)
if(count eq 0) then nints = fxpar(header_raw,'NINT',count = count)
if(count eq 0) then begin
    nints = fxpar(header_raw,'NINT',count = count)
    if(count eq 0) then nints = 1
endif
if (nints eq 0) then nints = 1

framediv = 1
framediv = fxpar(header_raw,'FRMDIVSR',count=count)
if(framediv ne 1 and count ne 0) then begin
   print,' FRMDIVSR is not 1, this is FASTGRPAVG data, adjusting NGroups for QL tool'
   nframes = nframes/framediv
endif
colstart = fxpar(header_raw,'SUBSTRT2',count = count)
if(count eq 0) then colstart = 1
rowstart = fxpar(header_raw,'SUBSTRT1',count = count)
if(count eq 0) then rowstart = 1

fits_read,fcb,cube_raw,header_raw,exten_no = 1
fits_close,fcb

subarray = 0
naxis1 = fxpar(header_raw,'NAXIS1',count = count)
naxis2 = fxpar(header_raw,'NAXIS2',count = count)
naxis3 = fxpar(header_raw,'NAXIS3',count = count)

if(naxis1 ne 1032) then begin
    subarray = 1
endif

; check if missing data
;check_header,naxis3,nints,nframes

print,' Reading Science Frame Image data ',filename
print,' Number of Integrations:',nints
print,' Number of frames/int:  ',nframes

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
if(this_frame+1 gt nframes) then begin
    sframe = strcompress(string(this_frame+1),/remove_all)
    error_message = "The requested frame (" + sframe + ") for file" + filename + $
             " is out of bounds" 
    status = 1
    return
endif
;_______________________________________________________________________
image_xsize = naxis1
image_ysize = naxis2
print,'size of science image',image_xsize,image_ysize
imagedata = fltarr(image_xsize,image_ysize)

m = this_integration *  nframes
print,'Reading integration #',this_integration+1
print,'Reading frame       #',this_frame+1
imagedata[*,*] = cube_raw[*,*,this_frame,this_integration]

;_______________________________________________________________________
fits_info,filename,extname=extname,/silent
ref_exist = -1

ref_xsize = naxis1/4
ref_ysize = image_ysize
refdata = fltarr(ref_xsize,ref_ysize)
for i =0, n_elements(extname)-1 do begin
   test = strcompress(extname[i],/remove_all)
   if (test eq 'REFOUT') then begin
      ref_exist = i
   endif
endfor
if(ref_exist ne -1) then begin 
   cube_ref  = mrdfits(filename,'REFOUT',/silent)
   ref_exist = 1
   print,'reference image      ',ref_xsize,ref_ysize
   refdata[*,*] = cube_ref[*,*, this_frame,this_integration]
endif else begin
   ref_exist = 0
endelse 
;_______________________________________________________________________
im_raw = 0
image_noref_data = imagedata
if(subarray eq 0) then image_noref_data = imagedata[4:1027,*]
if(subarray eq 1 and colstart eq 1 ) then image_noref_data = imagedata[4:*,*]
;_______________________________________________________________________
;
; stats on images, image_stat[mean,sigma,min,max]
;                  image_range[min,max] starting values for min,max dsplay range


jwst_get_image_stat,image_noref_data,image_mean,stdev_pixel,image_min,image_max,$
                    irange_min,irange_max,image_median,stdev_mean

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
;
; stats on reference images, ref_stat[mean,sigma,min,max]
;                            ref_range[min,max] starting values for  min,max dsplay range


stats_ref = fltarr(8)
if(ref_exist eq 1) then begin
    jwst_get_image_stat,refdata,image_mean,stdev_pixel,image_min,image_max,$
                   irange_min,irange_max,image_median,stdev_mean

    stats_ref[0] = image_mean
    stats_ref[1] = image_median
    stats_ref[2] = stdev_pixel
    stats_ref[3] = image_min
    stats_ref[4] = image_max
    stats_ref[5] =  irange_min
    stats_ref[6] =  irange_max
    stats_ref[7] = stdev_mean

endif 

end

