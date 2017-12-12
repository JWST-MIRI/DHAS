; This program takes image ia and image ib and subtracts them

pro difference_images,info,ia,ib,ic
; _______________________________________________________________________
info.compare_image[ic].filename = 'Difference image: Image1 - Image 2
info.compare_image[ic].subarray = info.compare_image[ia].subarray 
info.compare_image[ic].colstart = info.compare_image[ia].colstart 
info.compare_image[ic].xsize = info.compare_image[ia].xsize 
info.compare_image[ic].ysize = info.compare_image[ia].ysize 

ximage_size = info.compare_image[ia].xsize
yimage_size = info.compare_image[ia].ysize

frame_image1 = fltarr(ximage_size,yimage_size)
frame_image1[*,*] = (*info.compare_image[ia].pdata)

frame_image2 = fltarr(ximage_size,yimage_size)
frame_image2[*,*] = (*info.compare_image[ib].pdata)

frame_image3 = fltarr(ximage_size,yimage_size)
frame_image3[*,*] = frame_image1 - frame_image2




if ptr_valid (info.compare_image[ic].pdata) then ptr_free,$
  info.compare_image[ic].pdata
info.compare_image[ic].pdata= ptr_new(frame_image3)

;
; stats on images, image_stat[mean,sigma,min,max]
;                  image_range[min,max] starting values for min,max dsplay range

image_stat = fltarr(4)
image_range = fltarr(2)

subarray = info.compare_image[ic].subarray 
colstart = info.compare_image[ic].colstart
image_noref_data = frame_image3
if(subarray eq 0) then image_noref_data = frame_image3[4:1027,*]
if(subarray eq 1 and colstart eq 1 ) then image_noref_data = frame_image3[4:*,*]


get_image_stat,image_noref_data,image_mean,stdev_pixel,image_min,image_max,$
               irange_min,irange_max,image_median,stdev_mean,skew,numgood

info.compare_image[ic].mean = image_mean
info.compare_image[ic].median = image_median
info.compare_image[ic].stdev = stdev_pixel
info.compare_image[ic].min = image_min
info.compare_image[ic].max = image_max
info.compare_image[ic].range_min = irange_min
info.compare_image[ic].range_max = irange_max
frame_image3 = 0
frame_image2 = 0
frame_image1 = 0
Widget_Control,info.QuickLook,Set_UValue=info

end

;_______________________________________________________________________  
pro ratio_images,info,ia,ib,ic

info.compare_image[ic].filename = 'Ratio image: Image 1/Image 2'

info.compare_image[ic].subarray =info.compare_image[ia].subarray 
info.compare_image[ic].colstart = info.compare_image[ia].colstart 
info.compare_image[ic].xsize = info.compare_image[ia].xsize 
info.compare_image[ic].ysize = info.compare_image[ia].ysize 
; _______________________________________________________________________
ximage_size = info.compare_image[ia].xsize
yimage_size = info.compare_image[ia].ysize

frame_image1 = fltarr(ximage_size,yimage_size)
frame_image1[*,*] = (*info.compare_image[ia].pdata)

frame_image2 = fltarr(ximage_size,yimage_size)
frame_image2[*,*] = (*info.compare_image[ib].pdata)
index = where (frame_image2 ne 0,n)
index0 = where (frame_image2 eq 0,n0)  
frame_image3 = fltarr(ximage_size,yimage_size)
if(n gt 0) then frame_image3[index] = frame_image1[index]/frame_image2[index]
if(n0 gt 0) then frame_image3[index0] = !values.F_NaN

if ptr_valid (info.compare_image[ic].pdata) then ptr_free,$
  info.compare_image[ic].pdata
info.compare_image[ic].pdata= ptr_new(frame_image3)


;
; stats on images, image_stat[mean,sigma,min,max]
;                  image_range[min,max] starting values for min,max dsplay range


image_stat = fltarr(4)
image_range = fltarr(2)

subarray = info.compare_image[ic].subarray 
colstart = info.compare_image[ic].colstart
image_noref_data = frame_image3
if(subarray eq 0) then image_noref_data = frame_image3[4:1027,*]
if(subarray eq 1 and colstart eq 1 ) then image_noref_data = frame_image3[4:*,*]

get_image_stat,image_noref_data,image_mean,stdev_pixel,image_min,image_max,$
               irange_min,irange_max,image_median,stdev_mean,skew,ngood,nbad


info.compare_image[ic].mean = image_mean
info.compare_image[ic].median = image_median
info.compare_image[ic].stdev = stdev_pixel
info.compare_image[ic].min = image_min
info.compare_image[ic].max = image_max
info.compare_image[ic].range_min = irange_min
info.compare_image[ic].range_max= irange_max


frame_image3 = 0
frame_image2 = 0
frame_image1 = 0
Widget_Control,info.QuickLook,Set_UValue=info

end


;_______________________________________________________________________  
pro add_images,info,ia,ib,ic

info.compare_image[ic].filename = 'Add images: Image 1 + Image 2'
info.compare_image[ic].subarray =info.compare_image[ia].subarray 
info.compare_image[ic].colstart = info.compare_image[ia].colstart 
info.compare_image[ic].xsize = info.compare_image[ia].xsize 
info.compare_image[ic].ysize = info.compare_image[ia].ysize 

; ______________________________________________________________________
ximage_size = info.compare_image[ia].xsize
yimage_size = info.compare_image[ia].ysize

frame_image1 = fltarr(ximage_size,yimage_size)
frame_image1[*,*] = (*info.compare_image[ia].pdata)

frame_image2 = fltarr(ximage_size,yimage_size)
frame_image2[*,*] = (*info.compare_image[ib].pdata)


frame_image3 = fltarr(ximage_size,yimage_size)
frame_image3[*,*] = frame_image1 + frame_image2

if ptr_valid (info.compare_image[ic].pdata) then ptr_free,$
  info.compare_image[ic].pdata
info.compare_image[ic].pdata= ptr_new(frame_image3)


;
; stats on images, image_stat[mean,sigma,min,max]
;                  image_range[min,max] starting values for min,max dsplay range


image_stat = fltarr(4)
image_range = fltarr(2)

subarray = info.compare_image[ic].subarray 
colstart = info.compare_image[ic].colstart
image_noref_data = frame_image3
if(subarray eq 0) then image_noref_data = frame_image3[4:1027,*]
if(subarray eq 1 and colstart eq 1 ) then image_noref_data = frame_image3[4:*,*]

get_image_stat,image_noref_data,image_mean,stdev_pixel,image_min,image_max,$
               irange_min,irange_max,image_median,stdev_mean,skew,ngood,nbad




info.compare_image[ic].mean = image_mean
info.compare_image[ic].median = image_median
info.compare_image[ic].stdev = stdev_pixel
info.compare_image[ic].min = image_min
info.compare_image[ic].max = image_max
info.compare_image[ic].range_min = irange_min
info.compare_image[ic].range_max = irange_max
frame_image3 = 0
frame_image2 = 0
frame_image1 = 0
;_______________________________________________________________________
Widget_Control,info.QuickLook,Set_UValue=info

end









;***********************************************************************



; This program takes image ia and image ib and subtracts them

pro difference_reduced_images,info,ia,ib,ic
; _______________________________________________________________________
info.rcompare_image[ic].filename = 'Difference image: Image1 - Image 2'
info.rcompare_image[ic].subarray = info.rcompare_image[ia].subarray 
info.rcompare_image[ic].colstart = info.rcompare_image[ia].colstart 
info.rcompare_image[ic].xsize = info.rcompare_image[ia].xsize 
info.rcompare_image[ic].ysize = info.rcompare_image[ia].ysize 

ximage_size = info.rcompare_image[ia].xsize
yimage_size = info.rcompare_image[ia].ysize

frame_image1 = fltarr(ximage_size,yimage_size)
frame_image1[*,*] = (*info.rcompare_image[ia].pdata)

frame_image2 = fltarr(ximage_size,yimage_size)
frame_image2[*,*] = (*info.rcompare_image[ib].pdata)

frame_image3 = fltarr(ximage_size,yimage_size)
frame_image3[*,*] = frame_image1 - frame_image2


if ptr_valid (info.rcompare_image[ic].pdata) then ptr_free,$
  info.rcompare_image[ic].pdata
info.rcompare_image[ic].pdata= ptr_new(frame_image3)

;
; stats on images, image_stat[mean,sigma,min,max]
;                  image_range[min,max] starting values for min,max dsplay range

image_stat = fltarr(4)
image_range = fltarr(2)

subarray = info.rcompare_image[ic].subarray 
colstart = info.rcompare_image[ic].colstart
image_noref_data = frame_image3
if(subarray eq 0) then image_noref_data = frame_image3[4:1027,*]
if(subarray eq 1 and colstart eq 1 ) then image_noref_data = frame_image3[4:*,*]

get_image_stat,image_noref_data,image_mean,stdev_pixel,image_min,image_max,$
               irange_min,irange_max,image_median,stdev_mean,skew,numgood

info.rcompare_image[ic].mean = image_mean
info.rcompare_image[ic].median = image_median
info.rcompare_image[ic].stdev = stdev_pixel
info.rcompare_image[ic].min = image_min
info.rcompare_image[ic].max = image_max
info.rcompare_image[ic].range_min = irange_min
info.rcompare_image[ic].range_max = irange_max
frame_image3 = 0
frame_image2 = 0
frame_image1 = 0
Widget_Control,info.QuickLook,Set_UValue=info

end

;_______________________________________________________________________  
pro ratio_reduced_images,info,ia,ib,ic

info.rcompare_image[ic].filename = 'Ratio image: Image 1/Image 2'

info.rcompare_image[ic].subarray =info.rcompare_image[ia].subarray 
info.rcompare_image[ic].colstart = info.rcompare_image[ia].colstart 
info.rcompare_image[ic].xsize = info.rcompare_image[ia].xsize 
info.rcompare_image[ic].ysize = info.rcompare_image[ia].ysize 
; _______________________________________________________________________
ximage_size = info.rcompare_image[ia].xsize
yimage_size = info.rcompare_image[ia].ysize

frame_image1 = fltarr(ximage_size,yimage_size)
frame_image1[*,*] = (*info.rcompare_image[ia].pdata)

frame_image2 = fltarr(ximage_size,yimage_size)
frame_image2[*,*] = (*info.rcompare_image[ib].pdata)
index = where (frame_image2 ne 0,n)
index0 = where (frame_image2 eq 0,n0)  
frame_image3 = fltarr(ximage_size,yimage_size)
if(n gt 0) then frame_image3[index] = frame_image1[index]/frame_image2[index]
if(n0 gt 0) then frame_image3[index0] = !values.F_NaN

if ptr_valid (info.rcompare_image[ic].pdata) then ptr_free,$
  info.rcompare_image[ic].pdata
info.rcompare_image[ic].pdata= ptr_new(frame_image3)


;
; stats on images, image_stat[mean,sigma,min,max]
;                  image_range[min,max] starting values for min,max dsplay range


image_stat = fltarr(4)
image_range = fltarr(2)
subarray = info.rcompare_image[ic].subarray 
colstart = info.rcompare_image[ic].colstart
image_noref_data = frame_image3
if(subarray eq 0) then image_noref_data = frame_image3[4:1027,*]
if(subarray eq 1 and colstart eq 1 ) then image_noref_data = frame_image3[4:*,*]

get_image_stat,image_noref_data,image_mean,stdev_pixel,image_min,image_max,$
               irange_min,irange_max,image_median,stdev_mean,skew,ngood,nbad


info.rcompare_image[ic].mean = image_mean
info.rcompare_image[ic].median = image_median
info.rcompare_image[ic].stdev = stdev_pixel
info.rcompare_image[ic].min = image_min
info.rcompare_image[ic].max = image_max
info.rcompare_image[ic].range_min = irange_min
info.rcompare_image[ic].range_max= irange_max


frame_image3 = 0
frame_image2 = 0
frame_image1 = 0
Widget_Control,info.QuickLook,Set_UValue=info

end


;_______________________________________________________________________  
pro add_reduced_images,info,ia,ib,ic

info.rcompare_image[ic].filename = 'Add images: Image 1 + Image 2'
info.rcompare_image[ic].subarray =info.rcompare_image[ia].subarray 
info.rcompare_image[ic].colstart = info.rcompare_image[ia].colstart 
info.rcompare_image[ic].xsize = info.rcompare_image[ia].xsize 
info.rcompare_image[ic].ysize = info.rcompare_image[ia].ysize 

; ______________________________________________________________________
ximage_size = info.rcompare_image[ia].xsize
yimage_size = info.rcompare_image[ia].ysize

frame_image1 = fltarr(ximage_size,yimage_size)
frame_image1[*,*] = (*info.rcompare_image[ia].pdata)

frame_image2 = fltarr(ximage_size,yimage_size)
frame_image2[*,*] = (*info.rcompare_image[ib].pdata)


frame_image3 = fltarr(ximage_size,yimage_size)
frame_image3[*,*] = frame_image1 + frame_image2

if ptr_valid (info.rcompare_image[ic].pdata) then ptr_free,$
  info.rcompare_image[ic].pdata
info.rcompare_image[ic].pdata= ptr_new(frame_image3)


;
; stats on images, image_stat[mean,sigma,min,max]
;                  image_range[min,max] starting values for min,max dsplay range


image_stat = fltarr(4)
image_range = fltarr(2)

subarray = info.rcompare_image[ic].subarray 
colstart = info.rcompare_image[ic].colstart
image_noref_data = frame_image3
if(subarray eq 0) then image_noref_data = frame_image3[4:1027,*]
if(subarray eq 1 and colstart eq 1 ) then image_noref_data = frame_image3[4:*,*]

get_image_stat,image_noref_data,image_mean,stdev_pixel,image_min,image_max,$
               irange_min,irange_max,image_median,stdev_mean,skew,ngood,nbad




info.rcompare_image[ic].mean = image_mean
info.rcompare_image[ic].median = image_median
info.rcompare_image[ic].stdev = stdev_pixel
info.rcompare_image[ic].min = image_min
info.rcompare_image[ic].max = image_max
info.rcompare_image[ic].range_min = irange_min
info.rcompare_image[ic].range_max = irange_max
frame_image3 = 0
frame_image2 = 0
frame_image1 = 0
;_______________________________________________________________________
Widget_Control,info.QuickLook,Set_UValue=info

end
