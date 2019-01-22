pro jwst_setup_frames_and_header,info

info.jwst_control.frame_start = info.jwst_control.frame_start_save
info.jwst_control.read_limit = info.jwst_control.read_limit_save
info.jwst_control.frame_end = info.jwst_control.frame_start + info.jwst_control.read_limit -1
if(info.jwst_control.frame_end+1 ge info.jwst_data.ngroups) then $
  info.jwst_control.frame_end = info.jwst_data.ngroups -1

info.jwst_image.integrationNO = info.jwst_control.int_num

;initialize to 0 - do not plot
info.jwst_image.overplot_pixel_int = 0
info.jwst_image.overplot_refpix = 0
info.jwst_image.overplot_lin = 0
info.jwst_image.overplot_dark = 0
info.jwst_image.overplot_reset = 0
info.jwst_image.overplot_rscd = 0
info.jwst_image.overplot_lastframe = 0
info.jwst_image.overplot_fit = 0 

jwst_header_setup,0,info
jwst_header_setup_image,info
jwst_read_multi_frames,info

end

;***********************************************************************
pro jwst_setup_intermediate, info
;_______________________________________________________________________

xvalue = info.jwst_image.x_pos * info.jwst_image.binfactor
yvalue = info.jwst_image.y_pos * info.jwst_image.binfactor

if(info.jwst_data.ngroups lt 200) then begin 
    jwst_mql_read_rampdata,xvalue,yvalue,pixeldata,info
    if ptr_valid (info.jwst_image.ppixeldata) then ptr_free,info.jwst_image.ppixeldata
    info.jwst_image.ppixeldata = ptr_new(pixeldata)
endif

info.jwst_data.refpix_xsize = info.jwst_data.image_xsize
info.jwst_data.refpix_ysize = info.jwst_data.image_ysize

if(info.jwst_control.file_refpix_exist eq 1) then begin 
    info.jwst_image.overplot_refpix = 1
    if(info.jwst_data.ngroups lt 200) then jwst_mql_read_refpix_data,xvalue,yvalue,info
endif

info.jwst_data.lin_xsize = info.jwst_data.image_xsize
info.jwst_data.lin_ysize = info.jwst_data.image_ysize

info.jwst_data.dark_xsize = info.jwst_data.image_xsize
info.jwst_data.dark_ysize = info.jwst_data.image_ysize

info.jwst_data.reset_xsize = info.jwst_data.image_xsize
info.jwst_data.reset_ysize = info.jwst_data.image_ysize

info.jwst_data.rscd_xsize = info.jwst_data.image_xsize
info.jwst_data.rscd_ysize = info.jwst_data.image_ysize

info.jwst_data.lastframe_xsize = info.jwst_data.image_xsize
info.jwst_data.lastframe_ysize = info.jwst_data.image_ysize

if(info.jwst_control.file_linearity_exist eq 1) then begin 
    info.jwst_image.overplot_lin = 1
    if(info.jwst_data.ngroups lt 200) then jwst_mql_read_lin_data,xvalue,yvalue,info
endif

if(info.jwst_control.file_dark_exist eq 1) then begin 
    info.jwst_image.overplot_dark = 1
    if(info.jwst_data.ngroups lt 200) then jwst_mql_read_dark_data,xvalue,yvalue,info
 endif

if(info.jwst_control.file_reset_exist eq 1) then begin 
    info.jwst_image.overplot_reset = 1
    if(info.jwst_data.ngroups lt 200) then jwst_mql_read_reset_data,xvalue,yvalue,info
 endif

if(info.jwst_control.file_rscd_exist eq 1) then begin 
    info.jwst_image.overplot_rscd = 1
    if(info.jwst_data.ngroups lt 200) then jwst_mql_read_rscd_data,xvalue,yvalue,info
 endif

if(info.jwst_control.file_lastframe_exist eq 1) then begin 
    info.jwst_image.overplot_lastframe = 1
    if(info.jwst_data.ngroups lt 200) then jwst_mql_read_lastframe_data,xvalue,yvalue,info
endif

end

;***********************************************************************
pro jwst_setup_slope,info,integrationNO,type
;_______________________________________________________________________
; read in slope data
; type = 0 Read slope for Frame display jwst_mql
; type = 1 Read slope for Rate display jwst_msql
;_______________________________________________________________________

slope_exists = 0
status = 0 & error_message = " " 
jwst_read_single_slope,info.jwst_control.filename_slope_int,slope_exists,$
                       integrationNO,$
                       info.jwst_data.subarray,slopedata,$
                       slope_xsize,slope_ysize,$
                       stats,$
                       status,$
                       error_message

info.jwst_control.file_slope_int_exist = slope_exists
if(slope_exists eq 0) then begin
   print, ' Slope image does not exist'
   info.jwst_control.file_slope_int_exist = 0
   return
endif

info.jwst_data.slope_xsize = slope_xsize
info.jwst_data.slope_ysize = slope_ysize

jwst_reading_slope_header,info,status,error_message

if (type eq 0) then begin 
   if ptr_valid (info.jwst_data.preduced) then ptr_free,info.jwst_data.preduced
   info.jwst_data.preduced = ptr_new(slopedata)
   info.jwst_data.reduced_stat = stats
   jwst_header_setup_slope,0,info
endif 

if (type eq 1) then begin 
   if ptr_valid (info.jwst_data.pslopedata) then ptr_free,info.jwst_data.pslopedata
   info.jwst_data.pslopedata = ptr_new(slopedata)
   info.jwst_data.slope_stat = stats
   jwst_header_setup,1,info 
   jwst_header_setup_slope,1,info
endif 

slopedata = 0
stats = 0

;_______________________________________________________________________
;pro jwst_setup_cal,info
;info.jwst_data.cal_exist = 0
;cal_exists = 0
;status = 0 & error_message = " " 
;read_single_cal,info.jwst_control.filename_cal,cal_exists,$
;                info.jwst_image.integrationNO,info.jwst_data.subarray,caldata,$
;                cal_xsize,cal_ysize,cal_zsize,stats,$
;                status,error_message
;info.jwst_data.cal_exist = cal_exists


;if(cal_exists eq 1) then begin 
;    info.jwst_data.cal_xsize = cal_xsize
;    info.jwst_data.cal_ysize = cal_ysize
;    info.jwst_data.cal_zsize = cal_zsize
;    if ptr_valid (info.jwst_data.pcaldata) then ptr_free,info.jwst_data.pcaldata
;    info.jwst_data.pcaldata = ptr_new(caldata)
;    info.jwst_data.cal_stat = stats
;    caldata = 0
;    stats = 0
;    header_setup_cal,info
;endif



end
