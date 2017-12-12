; read in a single science frame and get the stat on the science
; data. (1024 X 1024) no reference pixels or reference output.
; If applying bad pixels, then the bad pixel mask must already
; be read in . 

pro get_stat_single_image,info,this_integration,this_frame,$
                         image_mean,stdev_pixel,image_min,image_max,$
                          irange_min,irange_max,image_median,stdev_mean,skew,ngood,nbad

filename= info.control.filename_raw

nbad = 0
m = (this_integration*info.data.nramps)  +   this_frame

;im_raw = readfits_miri(filename,nslice = m,/silent)        
im_raw = readfits(filename,nslice = m,/silent)        
xsize = info.data.image_xsize
ysize = info.data.image_ysize

frame_image = fltarr(xsize,ysize)
frame_image[*,*] = im_raw[0:xsize-1,0:ysize-1]

if(info.data.colstart eq 1) then     frame_image[0:3,*] =  !values.F_NaN
if(info.data.subarray eq 0) then frame_image[1028:1031,*] =  !values.F_NaN


numbad = 0
if(info.control.display_apply_bad) then begin
    index = where( (*info.badpixel.pmask) and 1,numbad)
    if(numbad gt 0) then frame_image(index) = !values.F_NaN
endif
;_______________________________________________________________________
;
; stats on images, image_stat[mean,sigma,min,max]
;                  image_range[min,max] starting values for min,max dsplay range

get_image_stat,frame_image,image_mean,stdev_pixel,image_min,image_max,$
               irange_min,irange_max,image_median,stdev_mean,skew,ngood,nbad

frame_image = 0


end
