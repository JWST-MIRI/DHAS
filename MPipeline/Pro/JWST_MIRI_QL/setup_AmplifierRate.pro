;***********************************************************************
pro setup_AmplifierRate,info,IntNo,status,error_message
status = 0
error_message = ' ' 
this_integration = IntNO

subarray = info.jwst_data.subarray
jwst_read_single_slope,info.jwst_control.filename_slope,exists,this_integration,$
                       subarray,slope_image,$
                       slope_xsize, slope_ysize,stats_slope,$
                       status,error_message

info.jwst_data.subarray = subarray
info.Jwst_data.slope_xsize = slope_xsize
info.jwst_data.slope_ysize = slope_ysize

if(status ne 0) then begin
   result = dialog_message(error_message,/error )
   status = 1
   return
endif
;_____________________________________________________________________
; 
for i = 0,3 do begin 
    info.jwst_AmpRate_image[i].xsize = slope_xsize/4  
    info.jwst_AmpRate_image[i].ysize = slope_ysize
    info.jwst_AmpRate_image[i].jintegration = this_integration
    
    channel_image = fltarr(slope_xsize/4,info.jwst_data.slope_ysize)
    m =0 
    for j = i,slope_xsize-1,4  do begin
        channel_image[m,*] = slope_image[j,*]
        m = m + 1
    endfor
    
    if ptr_valid ( info.jwst_AmpRate_image[i].pdata) then ptr_free,$
      info.jwst_AmpRate_image[i].pdata
    info.jwst_AmpRate_image[i].pdata = ptr_new(channel_image)

    channel_image_noref = channel_image
    xstart = 0
    xend = (slope_xsize/4) -1
    
    if(info.jwst_data.colstart eq 1) then xstart = 1
    if(info.jwst_data.subarray eq 0) then xend = (slope_xsize/4) -2
 
    channel_image_noref = channel_image[xstart:xend,*]
    jwst_get_image_stat,channel_image_noref,image_mean,stdev_pixel,image_min,$
                   image_max,irange_min,irange_max,image_median,$
                   stdev_mean
    channel_image_noref = 0

    info.jwst_AmpRate_image[i].mean = image_mean
    info.jwst_AmpRate_image[i].median = image_median
    info.jwst_AmpRate_image[i].stdev = stdev_pixel
    info.jwst_AmpRate_image[i].min = image_min
    info.jwst_AmpRate_image[i].max = image_max
    info.jwst_AmpRate_image[i].range_min = irange_min
    info.jwst_AmpRate_image[i].range_max = irange_max

    info.jwst_AmpRate_image[i].stdev_mean = stdev_mean
    info.jwst_AmpRate_image[i].ximage_range[0] = 1
    info.jwst_AmpRate_image[i].ximage_range[1] = slope_xsize/4
    info.jwst_AmpRate_image[i].yimage_range[0] = 1
    info.jwst_AmpRate_image[i].yimage_range[1] = slope_ysize
    channel_image = 0
endfor

ref_image = 0
slope_image = 0
widget_control,info.jwst_QuickLook,Set_Uvalue = info

end


