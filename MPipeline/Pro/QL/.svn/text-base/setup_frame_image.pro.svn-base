pro setup_frame_image_stepA,info

info.control.frame_start = info.control.frame_start_save

info.control.read_limit = info.control.read_limit_save
info.control.frame_end = info.control.frame_start + info.control.read_limit -1
if(info.control.frame_end+1 ge info.data.nramps) then $
  info.control.frame_end = info.data.nramps -1

info.image.integrationNO = info.control.int_num

info.image.overplot_pixel_int = 0
info.badpixel.readin = 0
info.image.overplot_reference_corrected = 0
info.image.overplot_cr = 0
info.image.overplot_lc = 0
info.image.overplot_mdc = 0
info.image.overplot_reset = 0
info.image.overplot_rscd = 0
info.image.overplot_lastframe = 0


header_setup,2,info

; _______________________________________________________________________
; read in dead pixel mask
;
 ;_______________________________________________________________________
bad_file  = ''
do_bad = 0



bad_file = info.control.bad_file[info.data.detector_code]
print,'Bad Pixelfile',bad_file
bad_file = strcompress(info.control.dircal + '/' + bad_file,/remove_all)
info.badpixel.file = bad_file

info.image.apply_bad = info.control.display_apply_bad
if(info.image.apply_bad eq 1)  then  begin 

    read_dead_pixels,info,info.badpixel.file,bad_file_exist,$
                     numbad,bad_mask,status,error_message
    info.badpixel.file = info.control.dircal+'/' +bad_file	
    info.badpixel.file_exist = bad_file_exist
    if(status eq 0) then begin 
        info.badpixel.num = numbad
        if ptr_valid(info.badpixel.pmask) then ptr_free,info.badpixel.pmask
        info.badpixel.pmask = ptr_new(bad_mask)
        bad_mask = 0 
    endif 
    if(status ne 0) then begin
        info.image.apply_bad=0
        print,'Turning off Apply bad Pixel Mask'
    endif

endif


;
;_______________________________________________________________________
; read in multiple raw science frames


read_multi_frames,info


end

;***********************************************************************
pro setup_frame_pixelvalues, info
;_______________________________________________________________________


xvalue = info.image.x_pos * info.image.binfactor
yvalue = info.image.y_pos * info.image.binfactor



if(info.data.nramps lt 200) then begin 
    mql_read_rampdata,xvalue,yvalue,pixeldata,info
    if ptr_valid (info.image.pixeldata) then ptr_free,info.image.pixeldata
    info.image.pixeldata = ptr_new(pixeldata)
endif

info.data.refcorrected_xsize = info.data.image_xsize
info.data.refcorrected_ysize = info.data.image_ysize

if(info.control.file_refcorrection_exist eq 1) then begin 
    info.image.overplot_reference_corrected = 1
    if(info.data.nramps lt 200) then mql_read_refcorrected_data,xvalue,yvalue,info
endif


info.data.id_xsize = info.data.image_xsize
info.data.id_ysize = info.data.image_ysize

info.data.lc_xsize = info.data.image_xsize
info.data.lc_ysize = info.data.image_ysize

info.data.mdc_xsize = info.data.image_xsize
info.data.mdc_ysize = info.data.image_ysize

info.data.reset_xsize = info.data.image_xsize
info.data.reset_ysize = info.data.image_ysize

info.data.rscd_xsize = info.data.image_xsize
info.data.rscd_ysize = info.data.image_ysize

info.data.lastframe_xsize = info.data.image_xsize
info.data.lastframe_ysize = info.data.image_ysize

if(info.control.file_ids_exist eq 1) then begin 
    info.image.overplot_cr = 1
    if(info.data.nramps lt 200) then mql_read_id_data,xvalue,yvalue,info
endif

if(info.control.file_lc_exist eq 1) then begin 
    info.image.overplot_lc = 1
    if(info.data.nramps lt 200) then mql_read_lc_data,xvalue,yvalue,info
endif


if(info.control.file_mdc_exist eq 1) then begin 
    info.image.overplot_mdc = 1
    if(info.data.nramps lt 200) then mql_read_mdc_data,xvalue,yvalue,info
 endif

if(info.control.file_reset_exist eq 1) then begin 
    info.image.overplot_reset = 1
    if(info.data.nramps lt 200) then mql_read_reset_data,xvalue,yvalue,info
 endif

if(info.control.file_rscd_exist eq 1) then begin 
    info.image.overplot_rscd = 1
    if(info.data.nramps lt 200) then mql_read_rscd_data,xvalue,yvalue,info
 endif


if(info.control.file_lastframe_exist eq 1) then begin 
    info.image.overplot_lastframe = 1
    if(info.data.nramps lt 200) then mql_read_lastframe_data,xvalue,yvalue,info
endif

;_______________________________________________________________________

end

;***********************************************************************
pro setup_frame_image_stepB,info
;_______________________________________________________________________
; read in slope data
;_______________________________________________________________________


info.data.slope_exist = 0
slope_exists = 0
bad_file = " " 
status = 0 & error_message = " " 
read_single_slope,info.control.filename_slope,slope_exists,$
                  info.image.integrationNO,info.data.subarray,slopedata,$
                  slope_xsize,slope_ysize,slope_zsize,stats,$
                  do_bad,bad_file,$
                  status,$
                  error_message
info.image.overplot_slope = 0
info.data.slope_exist = slope_exists
if(slope_exists eq 0) then print, ' Slope image does not exist'
if(slope_exists eq 1) then begin
    info.image.overplot_slope = 1 
        
    info.data.slope_xsize = slope_xsize
    info.data.slope_ysize = slope_ysize
    info.data.slope_zsize = slope_zsize
    if ptr_valid (info.data.preduced) then ptr_free,info.data.preduced
    info.data.preduced = ptr_new(slopedata)
    info.data.reduced_stat = stats
    
    if(do_bad eq 1) then      info.badpixel.file = info.control.dircal+'/' +bad_file

    slopedata = 0
    stats = 0

    header_setup_slope,info
                                ; read slope processing to get
                                ; begining and end of fit and frame
                                ; time


    reading_slope_processing,info.control.filename_slope,$
                             slope_exists,start_fit,end_fit,low_sat,$
                             high_sat,do_bad,use_psm,use_rscd,use_lin,use_dark,subrp,deltarp,even_odd,$
                             badfile,psm_file,rscd_file,$
                             lin_file,dark_file,$
                             slope_unit,frame_time,gain



    info.image.start_fit = start_fit
    info.image.end_fit = end_fit
    info.image.frame_time = frame_time 
endif

; reads from info.control.filename_slope
xvalue = info.image.x_pos * info.image.binfactor
yvalue = info.image.y_pos * info.image.binfactor

mql_read_slopedata,xvalue,yvalue,info

;_______________________________________________________________________
info.data.cal_exist = 0
cal_exists = 0
status = 0 & error_message = " " 
read_single_cal,info.control.filename_cal,cal_exists,$
                info.image.integrationNO,info.data.subarray,caldata,$
                cal_xsize,cal_ysize,cal_zsize,stats,$
                status,error_message
info.data.cal_exist = cal_exists


if(cal_exists eq 1) then begin 
    info.data.cal_xsize = cal_xsize
    info.data.cal_ysize = cal_ysize
    info.data.cal_zsize = cal_zsize
    if ptr_valid (info.data.pcaldata) then ptr_free,info.data.pcaldata
    info.data.pcaldata = ptr_new(caldata)
    info.data.cal_stat = stats
    caldata = 0
    stats = 0
    header_setup_cal,info
endif



end
