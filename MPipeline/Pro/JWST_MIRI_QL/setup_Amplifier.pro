;***********************************************************************
; Seperate the data for each channel from the entire image
; Pull out the reference pixels for the purposes of determining
; statistics and putting the data in time order
; When the data is put in time order - at the end of each row - 13
; values have to be inserted to fill the time it takes to get to the
; next row
pro setup_Amplifier,info,IntNo,FrameNo


jwst_read_single_frame_and_ref,info.jwst_control.filename_raw,IntNo,FrameNo,$
  info.jwst_data.subarray,imagedata,image_xsize,image_ysize,stats_image,$
  refdata,ref_xsize,ref_ysize,stats_ref,status,error_message


if(status ne 0) then begin
   result = dialog_message(error_message,/error )
    return
endif


extract_amplifier,imagedata,image_xsize,image_ysize,$
                  info.jwst_data.subarray,refdata,ref_xsize,ref_ysize,$
                  channel_data,$
                  channel_ximage_range,channel_yimage_range

for i = 0, 4 do begin 
    info.jwst_AmpFrame_image[i].xsize = image_xsize  
    info.jwst_AmpFrame_image[i].ysize = image_ysize
    
    info.jwst_AmpFrame_image[i].igroup = frameNO
    info.jwst_AmpFrame_image[i].jintegration = intNO
    if ptr_valid ( info.jwst_AmpFrame_image[i].pdata) then ptr_free,$
      info.jwst_AmpFrame_image[i].pdata
    info.jwst_AmpFrame_image[i].pdata = ptr_new(channel_data[i,*,*])
    
    info.jwst_AmpFrame_image[i].ximage_range[0] = channel_ximage_range[i,0]
    info.jwst_AmpFrame_image[i].ximage_range[1] = channel_ximage_range[i,1]
    info.jwst_AmpFrame_image[i].yimage_range[0] = channel_yimage_range[i,0]
    info.jwst_AmpFrame_image[i].yimage_range[1] = channel_yimage_range[i,1]
endfor

stat_channel = 0
channel_ximage_range = 0
channel_yimage_range = 0
channel_data = 0
channel_badpixel = 0
timedata = 0
widget_control,info.jwst_QuickLook,Set_Uvalue = info
end



;_______________________________________________________________________
pro setup_ChannelTime,info,IntNo,FrameNo



read_single_frame_and_ref,info.control.filename_raw,IntNo,FrameNo,$
  info.data.subarray,imagedata,image_xsize,image_ysize,stats_image,$
  refdata,ref_xsize,ref_ysize,stats_ref,status,error_message

if(status ne 0) then begin
    result = dialog_message(error_message,/error )
    return
endif

extract_channels,imagedata,bad_pixel,image_xsize,image_ysize,$
                 FFT_replicate_value,$
                 info.data.subarray,refdata,ref_xsize,ref_ysize,channel_data,$
                 channel_badpixel,$
                 channel_ximage_range,channel_yimage_range,timedata,time,timeflag,$
                 timebadpixel

for i = 0, 4 do begin 
    info.channelT[i].xsize = image_xsize  
    info.channelT[i].ysize = image_ysize
    
    info.channelT[i].iramp = frameNO
    info.channelT[i].jintegration = intNO

    info.channelT[i].ximage_range[0] = channel_ximage_range[i,0]
    info.channelT[i].ximage_range[1] = channel_ximage_range[i,1]
    info.channelT[i].yimage_range[0] = channel_yimage_range[i,0]
    info.channelT[i].yimage_range[1] = channel_yimage_range[i,1]

; elimiate the place holders for reset time and wait time needed for FFT
    index = where(timeflag[i,*] ge 0)
    if ptr_valid ( info.channelT[i].ptimedata) then ptr_free,$
      info.channelT[i].ptimedata
    info.channelT[i].ptimedata = ptr_new(timedata[i,index])

    if ptr_valid ( info.channelT[i].ptime) then ptr_free,$
      info.channelT[i].ptime
    info.channelT[i].ptime = ptr_new(time[i,index])

    if ptr_valid ( info.channelT[i].pbadpixel) then ptr_free,$
      info.channelT[i].pbadpixel
    info.channelT[i].pbadpixel = ptr_new(timebadpixel[i,index])


    if ptr_valid ( info.channelT[i].ptimeflag) then ptr_free,$
      info.channelT[i].ptimeflag
    info.channelT[i].ptimeflag = ptr_new(timeflag[i,index])

    if ptr_valid ( info.channelT[i].pdata) then ptr_free,$
      info.channelT[i].pdata
    info.channelT[i].pdata = ptr_new(channel_data[i,*,*])

endfor

evenodd = 0
flag = 0

stat_channel = 0
channel_ximage_range = 0
channel_yimage_range = 0
channel_data = 0
channel_badpixel = 0
timebadpixel = 0
timedata = 0
time = 0
timeflag = 0
widget_control,info.QuickLook,Set_Uvalue = info
end


;_______________________________________________________________________
pro setup_ChannelTimeRefcorrected,info,IntNo,FrameNo

read_refcorrected_frame,info.control.filename_refcorrection,IntNo,FrameNo,$
  info.data.subarray,imagedata,image_xsize,image_ysize,stats_image,$
  status,error_message

if(info.data.subarray eq 1) then begin
    ref_xsize = image_xsize/4
    ref_ysize =image_xsize
endif else begin 
    ref_xsize = 258
    ref_ysize = 1024
endelse
refdata = fltarr(ref_xsize,ref_ysize) 


if(status ne 0) then begin
    print, error_message
    return
endif


extract_channels,imagedata,bad_pixel,image_xsize,image_ysize,$
                 FFT_replicate_value,$
                 info.data.subarray,refdata,ref_xsize,ref_ysize,channel_data,$
                 channel_badpixel,$
                 channel_ximage_range,channel_yimage_range,timedata,time,timeflag,$
                 timebadpixel
bad_pixel = 0 

for i = 0, 4 do begin 
    info.channelTR[i].xsize = image_xsize  
    info.channelTR[i].ysize = image_ysize
    
    info.channelTR[i].iramp = frameNO
    info.channelTR[i].jintegration = intNO

    info.channelTR[i].ximage_range[0] = channel_ximage_range[i,0]
    info.channelTR[i].ximage_range[1] = channel_ximage_range[i,1]
    info.channelTR[i].yimage_range[0] = channel_yimage_range[i,0]
    info.channelTR[i].yimage_range[1] = channel_yimage_range[i,1]

; elimiate the place holders for reset time and wait time needed for FFT
    index = where(timeflag[i,*] ge 0)
    if ptr_valid ( info.channelTR[i].ptimedata) then ptr_free,$
      info.channelTR[i].ptimedata
    info.channelTR[i].ptimedata = ptr_new(timedata[i,index])

    if ptr_valid ( info.channelTR[i].ptime) then ptr_free,$
      info.channelTR[i].ptime
    info.channelTR[i].ptime = ptr_new(time[i,index])

    if ptr_valid ( info.channelTR[i].pbadpixel) then ptr_free,$
      info.channelTR[i].pbadpixel
    info.channelTR[i].pbadpixel = ptr_new(timebadpixel[i,index])


    if ptr_valid ( info.channelTR[i].ptimeflag) then ptr_free,$
      info.channelTR[i].ptimeflag
    info.channelTR[i].ptimeflag = ptr_new(timeflag[i,index])

    if ptr_valid ( info.channelTR[i].pdata) then ptr_free,$
      info.channelTR[i].pdata
    info.channelTR[i].pdata = ptr_new(channel_data[i,*,*])

endfor

evenodd = 0
flag = 0

stat_channel = 0
channel_ximage_range = 0
channel_yimage_range = 0
channel_data = 0
channel_badpixel = 0
timebadpixel = 0
timedata = 0
time = 0
timeflag = 0
widget_control,info.QuickLook,Set_Uvalue = info
end




; LocalWords:  ysize
