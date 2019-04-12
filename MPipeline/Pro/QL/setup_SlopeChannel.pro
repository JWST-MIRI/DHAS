;***********************************************************************
pro setup_SlopeChannel,info,IntNo,status,error_message
status = 0
error_message = ' ' 


this_integration = IntNO
if(info.data.coadd eq 1)  then begin
   print,'This data is not supported by the DHAS, single frame data'
   return
endif

subarray = info.data.subarray
read_single_slope,info.control.filename_slope,exists,this_integration,subarray,slope_image,$
slope_xsize, slope_ysize, slope_zsize,stats_slope,do_bad,bad_file,status,error_message

info.data.subarray = subarray
info.data.slope_xsize = slope_xsize
info.data.slope_ysize = slope_ysize
info.data.slope_zsize = slope_zsize

info.data.slope_exist = exists
if(status ne 0) then begin
        result = dialog_message(error_message,/error )
        status = 1
        return
    endif
;_____________________________________________________________________

if(info.data.nslopes lt this_integration+1) then begin
     error_message = " Partial Integration, no slope for this integration"
     status = 1
     return
 endif
    
;_______________________________________________________________________
read_single_ref_slope,info.control.filename_slope_refimage,exists,this_integration, subarray,$
  ref_image,ref_xsize,ref_ysize,ref_zsize,stats_image,status,error_message
if (exists eq 0) then begin
	ref_xsize = slope_xsize/4
	ref_ysize = slope_ysize
	ref_zsize = 3
    	ref_image = fltarr(ref_xsize,ref_ysize)
        ref_image[*,*] = 0
endif
info.data.sloperef_exist =exists
info.data.sloperef_xsize = ref_xsize
info.data.sloperef_ysize = ref_ysize
info.data.sloperef_zsize = ref_zsize

; 
for i = 0,3 do begin 
    info.channelS[i].xsize = slope_xsize/4  
    info.channelS[i].ysize = slope_ysize
    info.channelS[i].jintegration = this_integration
    
    channel_image = fltarr(slope_xsize/4,info.data.slope_ysize)
    m =0 
    for j = i,slope_xsize-1,4  do begin
        channel_image[m,*] = slope_image[j,*]
        m = m + 1
    endfor
    
    if ptr_valid ( info.channelS[i].pdata) then ptr_free,$
      info.channelS[i].pdata
    info.channelS[i].pdata = ptr_new(channel_image)

    channel_image_noref = channel_image
    xstart = 0
    xend = (slope_xsize/4) -1
    
    if(info.data.colstart eq 1) then xstart = 1
    if(info.data.subarray eq 0) then xend = (slope_xsize/4) -2
 
    channel_image_noref = channel_image[xstart:xend,*]
    get_image_stat,channel_image_noref,image_mean,stdev_pixel,image_min,$
                   image_max,irange_min,irange_max,image_median,$
                   stdev_mean,skew,ngood,nbad
    channel_image_noref = 0

    info.channelS[i].mean = image_mean
    info.channelS[i].median = image_median
    info.channelS[i].stdev = stdev_pixel
    info.channelS[i].min = image_min
    info.channelS[i].max = image_max
    info.channelS[i].range_min = irange_min
    info.channelS[i].range_max = irange_max
    info.channelS[i].skew = skew
    info.channelS[i].ngood = ngood
    info.channelS[i].nbad = nbad

    info.channelS[i].stdev_mean = stdev_mean
    info.channelS[i].ximage_range[0] = 1
    info.channelS[i].ximage_range[1] = slope_xsize/4
    info.channelS[i].yimage_range[0] = 1
    info.channelS[i].yimage_range[1] = slope_ysize


    channel_image = 0

endfor

; 5th channel = reference image


if ptr_valid ( info.channelS[4].pdata) then ptr_free,info.channelS[4].pdata
info.channelS[4].pdata = ptr_new(ref_image)

frame_image_noref = ref_image
if(info.data.subarray eq 0) then frame_image_noref = ref_image[1:(ref_xsize)-2,*]
get_image_stat,frame_image_noref,image_mean,stdev_pixel,image_min,$
               image_max,irange_min,irange_max,image_median,stdev_mean,skew,$
               ngood,nbad
print,'Nbad for reference output',nbad
frame_image_noref = 0
info.channelS[4].xsize = slope_xsize/4  
info.channelS[4].ysize = slope_ysize
    
info.channelS[4].mean = image_mean
info.channelS[4].median = image_median
info.channelS[4].stdev = stdev_pixel
info.channelS[4].min = image_min
info.channelS[4].max = image_max
info.channelS[4].range_min = irange_min
info.channelS[4].range_max = irange_max
info.channelS[4].skew = skew
info.channelS[4].ngood = ngood
info.channelS[4].nbad = nbad
info.channelS[4].stdev_mean = stdev_mean
info.channelS[4].ximage_range[0] = 1
info.channelS[4].ximage_range[1] = slope_xsize/4
info.channelS[4].yimage_range[0] = 1
info.channelS[4].yimage_range[1] = slope_ysize



ref_image = 0
slope_image = 0



widget_control,info.QuickLook,Set_Uvalue = info

end


