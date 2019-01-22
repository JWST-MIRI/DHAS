; This program takes image ia and image ib and subtracts them

pro jwst_difference_images,info,ia,ib,ic
; _______________________________________________________________________
info.jwst_compare_image[ic].filename = 'Difference image: Image1 - Image 2
info.jwst_compare_image[ic].subarray = info.jwst_compare_image[ia].subarray 
info.jwst_compare_image[ic].colstart = info.jwst_compare_image[ia].colstart 
info.jwst_compare_image[ic].xsize = info.jwst_compare_image[ia].xsize 
info.jwst_compare_image[ic].ysize = info.jwst_compare_image[ia].ysize 

ximage_size = info.jwst_compare_image[ia].xsize
yimage_size = info.jwst_compare_image[ia].ysize

frame_image1 = fltarr(ximage_size,yimage_size)
frame_image1[*,*] = (*info.jwst_compare_image[ia].pdata)

frame_image2 = fltarr(ximage_size,yimage_size)
frame_image2[*,*] = (*info.jwst_compare_image[ib].pdata)

frame_image3 = fltarr(ximage_size,yimage_size)
frame_image3[*,*] = frame_image1 - frame_image2


if ptr_valid (info.jwst_compare_image[ic].pdata) then ptr_free,$
  info.jwst_compare_image[ic].pdata
info.jwst_compare_image[ic].pdata= ptr_new(frame_image3)

;
; stats on images, image_stat[mean,sigma,min,max]
;                  image_range[min,max] starting values for min,max dsplay range

image_stat = fltarr(4)
image_range = fltarr(2)

subarray = info.jwst_compare_image[ic].subarray 
colstart = info.jwst_compare_image[ic].colstart
image_noref_data = frame_image3
if(subarray eq 0) then image_noref_data = frame_image3[4:1027,*]
if(subarray eq 1 and colstart eq 1 ) then image_noref_data = frame_image3[4:*,*]


jwst_get_image_stat,image_noref_data,image_mean,stdev_pixel,image_min,image_max,$
               irange_min,irange_max,image_median,stdev_mean

info.jwst_compare_image[ic].mean = image_mean
info.jwst_compare_image[ic].median = image_median
info.jwst_compare_image[ic].stdev = stdev_pixel
info.jwst_compare_image[ic].min = image_min
info.jwst_compare_image[ic].max = image_max
info.jwst_compare_image[ic].range_min = irange_min
info.jwst_compare_image[ic].range_max = irange_max
frame_image3 = 0
frame_image2 = 0
frame_image1 = 0
Widget_Control,info.jwst_QuickLook,Set_UValue=info

end

;_______________________________________________________________________  
pro jwst_ratio_images,info,ia,ib,ic

info.jwst_compare_image[ic].filename = 'Ratio image: Image 1/Image 2'

info.jwst_compare_image[ic].subarray =info.jwst_compare_image[ia].subarray 
info.jwst_compare_image[ic].colstart = info.jwst_compare_image[ia].colstart 
info.jwst_compare_image[ic].xsize = info.jwst_compare_image[ia].xsize 
info.jwst_compare_image[ic].ysize = info.jwst_compare_image[ia].ysize 
; _______________________________________________________________________
ximage_size = info.jwst_compare_image[ia].xsize
yimage_size = info.jwst_compare_image[ia].ysize

frame_image1 = fltarr(ximage_size,yimage_size)
frame_image1[*,*] = (*info.jwst_compare_image[ia].pdata)

frame_image2 = fltarr(ximage_size,yimage_size)
frame_image2[*,*] = (*info.jwst_compare_image[ib].pdata)
index = where (frame_image2 ne 0,n)
index0 = where (frame_image2 eq 0,n0)  
frame_image3 = fltarr(ximage_size,yimage_size)
if(n gt 0) then frame_image3[index] = frame_image1[index]/frame_image2[index]
if(n0 gt 0) then frame_image3[index0] = !values.F_NaN

if ptr_valid (info.jwst_compare_image[ic].pdata) then ptr_free,$
  info.jwst_compare_image[ic].pdata
info.jwst_compare_image[ic].pdata= ptr_new(frame_image3)


;
; stats on images, image_stat[mean,sigma,min,max]
;                  image_range[min,max] starting values for min,max dsplay range


image_stat = fltarr(4)
image_range = fltarr(2)

subarray = info.jwst_compare_image[ic].subarray 
colstart = info.jwst_compare_image[ic].colstart
image_noref_data = frame_image3
if(subarray eq 0) then image_noref_data = frame_image3[4:1027,*]
if(subarray eq 1 and colstart eq 1 ) then image_noref_data = frame_image3[4:*,*]

jwst_get_image_stat,image_noref_data,image_mean,stdev_pixel,image_min,image_max,$
               irange_min,irange_max,image_median,stdev_mean


info.jwst_compare_image[ic].mean = image_mean
info.jwst_compare_image[ic].median = image_median
info.jwst_compare_image[ic].stdev = stdev_pixel
info.jwst_compare_image[ic].min = image_min
info.jwst_compare_image[ic].max = image_max
info.jwst_compare_image[ic].range_min = irange_min
info.jwst_compare_image[ic].range_max= irange_max


frame_image3 = 0
frame_image2 = 0
frame_image1 = 0
Widget_Control,info.jwst_QuickLook,Set_UValue=info

end


;_______________________________________________________________________  
pro jwst_add_images,info,ia,ib,ic

info.jwst_compare_image[ic].filename = 'Add images: Image 1 + Image 2'
info.jwst_compare_image[ic].subarray =info.jwst_compare_image[ia].subarray 
info.jwst_compare_image[ic].colstart = info.jwst_compare_image[ia].colstart 
info.jwst_compare_image[ic].xsize = info.jwst_compare_image[ia].xsize 
info.jwst_compare_image[ic].ysize = info.jwst_compare_image[ia].ysize 

; ______________________________________________________________________
ximage_size = info.jwst_compare_image[ia].xsize
yimage_size = info.jwst_compare_image[ia].ysize

frame_image1 = fltarr(ximage_size,yimage_size)
frame_image1[*,*] = (*info.jwst_compare_image[ia].pdata)

frame_image2 = fltarr(ximage_size,yimage_size)
frame_image2[*,*] = (*info.jwst_compare_image[ib].pdata)


frame_image3 = fltarr(ximage_size,yimage_size)
frame_image3[*,*] = frame_image1 + frame_image2

if ptr_valid (info.jwst_compare_image[ic].pdata) then ptr_free,$
  info.jwst_compare_image[ic].pdata
info.jwst_compare_image[ic].pdata= ptr_new(frame_image3)


;
; stats on images, image_stat[mean,sigma,min,max]
;                  image_range[min,max] starting values for min,max dsplay range


image_stat = fltarr(4)
image_range = fltarr(2)

subarray = info.jwst_compare_image[ic].subarray 
colstart = info.jwst_compare_image[ic].colstart
image_noref_data = frame_image3
if(subarray eq 0) then image_noref_data = frame_image3[4:1027,*]
if(subarray eq 1 and colstart eq 1 ) then image_noref_data = frame_image3[4:*,*]

jwst_get_image_stat,image_noref_data,image_mean,stdev_pixel,image_min,image_max,$
               irange_min,irange_max,image_median,stdev_mean

info.jwst_compare_image[ic].mean = image_mean
info.jwst_compare_image[ic].median = image_median
info.jwst_compare_image[ic].stdev = stdev_pixel
info.jwst_compare_image[ic].min = image_min
info.jwst_compare_image[ic].max = image_max
info.jwst_compare_image[ic].range_min = irange_min
info.jwst_compare_image[ic].range_max = irange_max
frame_image3 = 0
frame_image2 = 0
frame_image1 = 0
;_______________________________________________________________________
Widget_Control,info.jwst_QuickLook,Set_UValue=info

end

; This program takes image ia and image ib and subtracts them

pro jwst_difference_reduced_images,info,ia,ib,ic
; _______________________________________________________________________
info.jwst_rcompare_image[ic].filename = 'Difference image: Image1 - Image 2'
info.jwst_rcompare_image[ic].subarray = info.jwst_rcompare_image[ia].subarray 
info.jwst_rcompare_image[ic].colstart = info.jwst_rcompare_image[ia].colstart 
info.jwst_rcompare_image[ic].xsize = info.jwst_rcompare_image[ia].xsize 
info.jwst_rcompare_image[ic].ysize = info.jwst_rcompare_image[ia].ysize 

ximage_size = info.jwst_rcompare_image[ia].xsize
yimage_size = info.jwst_rcompare_image[ia].ysize

frame_image1 = fltarr(ximage_size,yimage_size)
frame_image1[*,*] = (*info.jwst_rcompare_image[ia].pdata)

frame_image2 = fltarr(ximage_size,yimage_size)
frame_image2[*,*] = (*info.jwst_rcompare_image[ib].pdata)

frame_image3 = fltarr(ximage_size,yimage_size)
frame_image3[*,*] = frame_image1 - frame_image2


if ptr_valid (info.jwst_rcompare_image[ic].pdata) then ptr_free,$
  info.jwst_rcompare_image[ic].pdata
info.jwst_rcompare_image[ic].pdata= ptr_new(frame_image3)

;
; stats on images, image_stat[mean,sigma,min,max]
;                  image_range[min,max] starting values for min,max dsplay range

image_stat = fltarr(4)
image_range = fltarr(2)

subarray = info.jwst_rcompare_image[ic].subarray 
colstart = info.jwst_rcompare_image[ic].colstart
image_noref_data = frame_image3
if(subarray eq 0) then image_noref_data = frame_image3[4:1027,*]
if(subarray eq 1 and colstart eq 1 ) then image_noref_data = frame_image3[4:*,*]

jwst_get_image_stat,image_noref_data,image_mean,stdev_pixel,image_min,image_max,$
               irange_min,irange_max,image_median,stdev_mean

info.jwst_rcompare_image[ic].mean = image_mean
info.jwst_rcompare_image[ic].median = image_median
info.jwst_rcompare_image[ic].stdev = stdev_pixel
info.jwst_rcompare_image[ic].min = image_min
info.jwst_rcompare_image[ic].max = image_max
info.jwst_rcompare_image[ic].range_min = irange_min
info.jwst_rcompare_image[ic].range_max = irange_max
frame_image3 = 0
frame_image2 = 0
frame_image1 = 0
Widget_Control,info.jwst_QuickLook,Set_UValue=info

end

;_______________________________________________________________________  
pro jwst_ratio_reduced_images,info,ia,ib,ic

info.jwst_rcompare_image[ic].filename = 'Ratio image: Image 1/Image 2'

info.jwst_rcompare_image[ic].subarray =info.jwst_rcompare_image[ia].subarray 
info.jwst_rcompare_image[ic].colstart = info.jwst_rcompare_image[ia].colstart 
info.jwst_rcompare_image[ic].xsize = info.jwst_rcompare_image[ia].xsize 
info.jwst_rcompare_image[ic].ysize = info.jwst_rcompare_image[ia].ysize 
; _______________________________________________________________________
ximage_size = info.jwst_rcompare_image[ia].xsize
yimage_size = info.jwst_rcompare_image[ia].ysize

frame_image1 = fltarr(ximage_size,yimage_size)
frame_image1[*,*] = (*info.jwst_rcompare_image[ia].pdata)

frame_image2 = fltarr(ximage_size,yimage_size)
frame_image2[*,*] = (*info.jwst_rcompare_image[ib].pdata)
index = where (frame_image2 ne 0,n)
index0 = where (frame_image2 eq 0,n0)  
frame_image3 = fltarr(ximage_size,yimage_size)
if(n gt 0) then frame_image3[index] = frame_image1[index]/frame_image2[index]
if(n0 gt 0) then frame_image3[index0] = !values.F_NaN

if ptr_valid (info.jwst_rcompare_image[ic].pdata) then ptr_free,$
  info.jwst_rcompare_image[ic].pdata
info.jwst_rcompare_image[ic].pdata= ptr_new(frame_image3)


;
; stats on images, image_stat[mean,sigma,min,max]
;                  image_range[min,max] starting values for min,max dsplay range


image_stat = fltarr(4)
image_range = fltarr(2)
subarray = info.jwst_rcompare_image[ic].subarray 
colstart = info.jwst_rcompare_image[ic].colstart
image_noref_data = frame_image3
if(subarray eq 0) then image_noref_data = frame_image3[4:1027,*]
if(subarray eq 1 and colstart eq 1 ) then image_noref_data = frame_image3[4:*,*]

jwst_get_image_stat,image_noref_data,image_mean,stdev_pixel,image_min,image_max,$
               irange_min,irange_max,image_median,stdev_mean


info.jwst_rcompare_image[ic].mean = image_mean
info.jwst_rcompare_image[ic].median = image_median
info.jwst_rcompare_image[ic].stdev = stdev_pixel
info.jwst_rcompare_image[ic].min = image_min
info.jwst_rcompare_image[ic].max = image_max
info.jwst_rcompare_image[ic].range_min = irange_min
info.jwst_rcompare_image[ic].range_max= irange_max


frame_image3 = 0
frame_image2 = 0
frame_image1 = 0
Widget_Control,info.jwst_QuickLook,Set_UValue=info

end


;_______________________________________________________________________  
pro jwst_add_reduced_images,info,ia,ib,ic

info.jwst_rcompare_image[ic].filename = 'Add images: Image 1 + Image 2'
info.jwst_rcompare_image[ic].subarray =info.jwst_rcompare_image[ia].subarray 
info.jwst_rcompare_image[ic].colstart = info.jwst_rcompare_image[ia].colstart 
info.jwst_rcompare_image[ic].xsize = info.jwst_rcompare_image[ia].xsize 
info.jwst_rcompare_image[ic].ysize = info.jwst_rcompare_image[ia].ysize 

; ______________________________________________________________________
ximage_size = info.jwst_rcompare_image[ia].xsize
yimage_size = info.jwst_rcompare_image[ia].ysize

frame_image1 = fltarr(ximage_size,yimage_size)
frame_image1[*,*] = (*info.jwst_rcompare_image[ia].pdata)

frame_image2 = fltarr(ximage_size,yimage_size)
frame_image2[*,*] = (*info.jwst_rcompare_image[ib].pdata)


frame_image3 = fltarr(ximage_size,yimage_size)
frame_image3[*,*] = frame_image1 + frame_image2

if ptr_valid (info.jwst_rcompare_image[ic].pdata) then ptr_free,$
  info.jwst_rcompare_image[ic].pdata
info.jwst_rcompare_image[ic].pdata= ptr_new(frame_image3)


;
; stats on images, image_stat[mean,sigma,min,max]
;                  image_range[min,max] starting values for min,max dsplay range


image_stat = fltarr(4)
image_range = fltarr(2)

subarray = info.jwst_rcompare_image[ic].subarray 
colstart = info.jwst_rcompare_image[ic].colstart
image_noref_data = frame_image3
if(subarray eq 0) then image_noref_data = frame_image3[4:1027,*]
if(subarray eq 1 and colstart eq 1 ) then image_noref_data = frame_image3[4:*,*]

jwst_get_image_stat,image_noref_data,image_mean,stdev_pixel,image_min,image_max,$
               irange_min,irange_max,image_median,stdev_mean




info.jwst_rcompare_image[ic].mean = image_mean
info.jwst_rcompare_image[ic].median = image_median
info.jwst_rcompare_image[ic].stdev = stdev_pixel
info.jwst_rcompare_image[ic].min = image_min
info.jwst_rcompare_image[ic].max = image_max
info.jwst_rcompare_image[ic].range_min = irange_min
info.jwst_rcompare_image[ic].range_max = irange_max
frame_image3 = 0
frame_image2 = 0
frame_image1 = 0
;_______________________________________________________________________
Widget_Control,info.jwst_QuickLook,Set_UValue=info

end
