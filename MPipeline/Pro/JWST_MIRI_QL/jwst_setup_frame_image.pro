pro jwst_setup_frame_image_stepA,info

info.jwst_control.frame_start = info.jwst_control.frame_start_save

info.jwst_control.read_limit = info.jwst_control.read_limit_save
info.jwst_control.frame_end = info.jwst_control.frame_start + info.jwst_control.read_limit -1
if(info.jwst_control.frame_end+1 ge info.jwst_data.ngroups) then $
  info.jwst_control.frame_end = info.jwst_data.ngroups -1

info.jwst_image.integrationNO = info.jwst_control.int_num

info.jwst_image.overplot_pixel_int = 0

info.jwst_image.overplot_reference_corrected = 0
info.jwst_image.overplot_cr = 0
info.jwst_image.overplot_lc = 0
info.jwst_image.overplot_mdc = 0
info.jwst_image.overplot_reset = 0
info.jwst_image.overplot_rscd = 0
info.jwst_image.overplot_lastframe = 0

jwst_header_setup,2,info
jwst_read_multi_frames,info

end

;***********************************************************************
pro jwst_setup_frame_pixelvalues, info
;_______________________________________________________________________


xvalue = info.jwst_image.x_pos * info.jwst_image.binfactor
yvalue = info.jwst_image.y_pos * info.jwst_image.binfactor

if(info.jwst_data.ngroups lt 200) then begin 
    jwst_mql_read_rampdata,xvalue,yvalue,pixeldata,info
    if ptr_valid (info.jwst_image.pixeldata) then ptr_free,info.jwst_image.pixeldata
    info.jwst_image.pixeldata = ptr_new(pixeldata)
endif

info.jwst_data.refcorrected_xsize = info.jwst_data.image_xsize
info.jwst_data.refcorrected_ysize = info.jwst_data.image_ysize

if(info.jwst_control.file_refcorrection_exist eq 1) then begin 
    info.jwst_image.overplot_reference_corrected = 1
    if(info.jwst_data.ngroups lt 200) then mql_read_refcorrected_data,xvalue,yvalue,info
endif


info.jwst_data.lc_xsize = info.jwst_data.image_xsize
info.jwst_data.lc_ysize = info.jwst_data.image_ysize

info.jwst_data.mdc_xsize = info.jwst_data.image_xsize
info.jwst_data.mdc_ysize = info.jwst_data.image_ysize

info.jwst_data.reset_xsize = info.jwst_data.image_xsize
info.jwst_data.reset_ysize = info.jwst_data.image_ysize

info.jwst_data.rscd_xsize = info.jwst_data.image_xsize
info.jwst_data.rscd_ysize = info.jwst_data.image_ysize

info.jwst_data.lastframe_xsize = info.jwst_data.image_xsize
info.jwst_data.lastframe_ysize = info.jwst_data.image_ysize


if(info.jwst_control.file_lc_exist eq 1) then begin 
    info.jwst_image.overplot_lc = 1
    if(info.jwst_data.ngroups lt 200) then mql_read_lc_data,xvalue,yvalue,info
endif


if(info.jwst_control.file_mdc_exist eq 1) then begin 
    info.jwst_image.overplot_mdc = 1
    if(info.jwst_data.ngroups lt 200) then mql_read_mdc_data,xvalue,yvalue,info
 endif

if(info.jwst_control.file_reset_exist eq 1) then begin 
    info.jwst_image.overplot_reset = 1
    if(info.jwst_data.ngroups lt 200) then mql_read_reset_data,xvalue,yvalue,info
 endif

if(info.jwst_control.file_rscd_exist eq 1) then begin 
    info.jwst_image.overplot_rscd = 1
    if(info.jwst_data.ngroups lt 200) then mql_read_rscd_data,xvalue,yvalue,info
 endif


if(info.jwst_control.file_lastframe_exist eq 1) then begin 
    info.jwst_image.overplot_lastframe = 1
    if(info.jwst_data.ngroups lt 200) then mql_read_lastframe_data,xvalue,yvalue,info
endif

;_______________________________________________________________________

end

;***********************************************************************
pro jwst_setup_frame_image_stepB,info
;_______________________________________________________________________
; read in slope data
;_______________________________________________________________________


info.jwst_data.slope_int_exist = 0
slope_exists = 0

status = 0 & error_message = " " 
jwst_read_single_slope,info.jwst_control.filename_slope_int,slope_exists,$
                       info.jwst_image.integrationNO,$
                       info.jwst_data.subarray,slopedata,$
                       slope_xsize,slope_ysize,$
                       stats,$
                       status,$
                       error_message


info.jwst_image.overplot_slope = 0
info.jwst_data.slope_int_exist = slope_exists
if(slope_exists eq 0) then print, ' Slope image does not exist'
if(slope_exists eq 1) then begin
    info.jwst_image.overplot_slope = 1 
        
    info.jwst_data.slope_xsize = slope_xsize
    info.jwst_data.slope_ysize = slope_ysize

    if ptr_valid (info.jwst_data.preduced) then ptr_free,info.jwst_data.preduced
    info.jwst_data.preduced = ptr_new(slopedata)
    info.jwst_data.reduced_stat = stats
    

    slopedata = 0
    stats = 0

    jwst_header_setup_slope,info
                                ; read slope processing to get
                                ; begining and end of fit and frame
                                ; time


    jwst_reading_slope_processing,info.jwst_control.filename_slope,$
                             slope_exists,start_fit,end_fit,frametime



    info.jwst_image.start_fit = 1
    info.jwst_image.end_fit = end_fit
    info.jwst_image.frame_time = frametime 
endif

; reads from info.jwst_control.filename_slope_int
xvalue = info.jwst_image.x_pos * info.jwst_image.binfactor
yvalue = info.jwst_image.y_pos * info.jwst_image.binfactor

jwst_mql_read_slopedata,xvalue,yvalue,info

;_______________________________________________________________________
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
