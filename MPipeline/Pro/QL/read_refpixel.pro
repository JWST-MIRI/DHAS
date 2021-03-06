;***********************************************************************
; program to read in the reference border pixels

pro read_refpixel,info

widget_control,/hourglass
progressBar = Obj_New("ShowProgress", color = 150, $
                      message = " Reading in Reference Pixels ",$
                      xsize = 250, ysize = 40)
progressBar -> Start

refpixel_dataL2 = fltarr(info.data.nints,info.data.nramps,4,info.data.image_ysize)
refpixel_dataL = fltarr(info.data.nints,info.data.nramps,4,info.data.image_ysize)

refpixel_dataR = fltarr(info.data.nints,info.data.nramps,4,info.data.image_ysize)

ref_stat = fltarr(info.data.nints,info.data.nramps,7)
ref_range = fltarr(info.data.nints,info.data.nramps,2)

ref_stat_left = fltarr(info.data.nints,info.data.nramps,7)
ref_stat_left2 = fltarr(info.data.nints,info.data.nramps,7)
ref_stat_right = fltarr(info.data.nints,info.data.nramps,7)


ref_stat2 = fltarr(info.data.nints,info.data.nramps,7)
ref_range2 = fltarr(info.data.nints,info.data.nramps,2)

total_reads = info.data.nints * info.data.nramps
ireads  = 0 
frame = 0


for i = 0, info.data.nints -1 do begin
   nramps = info.data.nramps


    for j = 0, nramps -1 do begin

        percent = 95.0 * float(ireads)/float(total_reads)
        ireads = ireads + 1
        progressBar -> Update,percent

;        im_raw = readfits_miri(info.control.filename_raw,nslice = frame,/silent)
        im_raw = readfits(info.control.filename_raw,nslice = frame,/silent)

        
	dataL = im_raw[0:3,0:info.data.image_ysize-1]
        refpixel_dataL[i,j,*,*] = dataL[*,*]
        if(info.data.subarray eq 0) then begin ; full array 
            dataR = im_raw[1028:1031,0:1023]
        endif else begin
            dataR = fltarr(4,info.data.image_ysize) 
            dataR[*,*] =  !values.F_NaN
        endelse
        refpixel_dataR[i,j,*,*] = dataR[*,*]        
        total_data = fltarr(8,info.data.image_ysize)
        total_data[0:3,*] = dataL
        total_data[4:7,*] = dataR
        get_image_stat,total_data,ref_mean,stdev_pixel,ref_min,ref_max,$
          irange_min,irange_max,ref_median,stdev_mean,skew,ngood,nbad
        ref_stat[i,j,0] = ref_mean
        ref_stat[i,j,1] = stdev_pixel
        ref_stat[i,j,2] = ref_min
        ref_stat[i,j,3] = ref_max
        ref_stat[i,j,4] = ref_median
        ref_stat[i,j,5] = stdev_mean
        ref_stat[i,j,6] = skew
        
        ref_range[i,j,0] = irange_min
        ref_range[i,j,1] = irange_max


        get_image_stat,dataL,ref_mean,stdev_pixel,ref_min,ref_max,$
          irange_min,irange_max,ref_median,stdev_mean,skew,ngood,nbad
        ref_stat_left[i,j,0] = ref_mean
        ref_stat_left[i,j,1] = stdev_pixel
        ref_stat_left[i,j,2] = ref_min
        ref_stat_left[i,j,3] = ref_max
        ref_stat_left[i,j,4] = ref_median
        ref_stat_left[i,j,5] = stdev_mean
        ref_stat_left[i,j,6] = skew

        get_image_stat,dataR,ref_mean,stdev_pixel,ref_min,ref_max,$
          irange_min,irange_max,ref_median,stdev_mean,skew,ngood,nbad
        ref_stat_right[i,j,0] = ref_mean
        ref_stat_right[i,j,1] = stdev_pixel
        ref_stat_right[i,j,2] = ref_min
        ref_stat_right[i,j,3] = ref_max
        ref_stat_right[i,j,4] = ref_median
        ref_stat_right[i,j,5] = stdev_mean
        ref_stat_right[i,j,6] = skew


        frame = frame + 1
    endfor
endfor
;_______________________________________________________________________

percent = 99.0 
progressBar -> Update,percent


if ptr_valid (info.refpixel_data.prefpixelL) then ptr_free,info.refpixel_data.prefpixelL
info.refpixel_data.prefpixelL = ptr_new(refpixel_dataL)

if ptr_valid (info.refpixel_data.prefpixelL2) then ptr_free,info.refpixel_data.prefpixelL2
info.refpixel_data.prefpixelL2 = ptr_new(refpixel_dataL2)

if ptr_valid (info.refpixel_data.prefpixelR) then ptr_free,info.refpixel_data.prefpixelR
info.refpixel_data.prefpixelR = ptr_new(refpixel_dataR)

if ptr_valid (info.refpixel_data.pstatR) then ptr_free,info.refpixel_data.pstatR
info.refpixel_data.pstatR = ptr_new(ref_stat_right)

if ptr_valid (info.refpixel_data.pstatL) then ptr_free,info.refpixel_data.pstatL
info.refpixel_data.pstatL = ptr_new(ref_stat_left)

if ptr_valid (info.refpixel_data.pstatL2) then ptr_free,info.refpixel_data.pstatL2
info.refpixel_data.pstatL2 = ptr_new(ref_stat_left2)


if ptr_valid (info.refpixel_data.pstat) then ptr_free,info.refpixel_data.pstat
info.refpixel_data.pstat = ptr_new(ref_stat)

if ptr_valid (info.refpixel_data.prange) then ptr_free,info.refpixel_data.prange
info.refpixel_data.prange= ptr_new(ref_range)

if ptr_valid (info.refpixel_data.pstat2) then ptr_free,info.refpixel_data.pstat2
info.refpixel_data.pstat2 = ptr_new(ref_stat2)

if ptr_valid (info.refpixel_data.prange2) then ptr_free,info.refpixel_data.prange2
info.refpixel_data.prange2= ptr_new(ref_range2)

dataL = 0
dataL2 = 0
dataR = 0
ref_stat_left = 0
ref_stat_right = 0
ref_stat_left2 = 0
total_data = 0
ref_stat = 0
ref_range = 0
ref_stat2 = 0
ref_range2 = 0
refpixel_dataL = 0
refpixel_dataL2 = 0
refpixel_dataR = 0

percent = 100.0
progressBar -> Update,percent

progressBar -> Destroy
obj_destroy, progressBar


end
