;_______________________________________________________________________
pro mql_setup_miri_sloper_names,info,status

status = 0
if(info.control.set_scidata eq 0) then begin

    image_file = dialog_pickfile(/read,$
                                get_path=realpath,Path=info.control.dir,$
                                filter = '*.fits')
 

    len = strlen(realpath)
    realpath = strmid(realpath,0,len-1); just to be consistent 
    info.control.dir = realpath
    
    if(image_file eq '')then begin
        print,' No file selected, can not read in data'
	status = 2
        return
    endif
    if (image_file NE '') then begin
        filename = image_file
    endif
endif

;-----------------------------------------------------------------------
; the User did provide a filename on the command line - 
if(info.control.set_scidata eq 1) then begin
    filename = strcompress(info.control.filename_raw,/remove_all)
endif
;-----------------------------------------------------------------------

filename_raw = filename
info.control.filename_raw = filename_raw

file_exist1 = file_test(info.control.filename_raw,/regular,/read)
if(file_exist1 ne 1 ) then begin
    result = dialog_message(" The Raw file does not exist "+ info.control.filename_raw,/error )
    status = 2
    return
endif

info.data.raw_exist =1
read_data_type,info.control.filename_raw,type
read_coadd_type,info.control.filename_raw,coadd_type

if(type ne 0) then begin
    error_message = ' You did not open a Raw Science Image data File, try again'
    fail = dialog_message(error_message,/error)
    status = 1
    return
endif


if(coadd_type ne 0) then begin
    error_message = ' The DHAS does not work on NGROUP =1 data'
    fail = dialog_message(error_message,/error)
    status = 1
    return
endif

info.data.raw_exist = 1

slash_str = strsplit(info.control.filename_raw,'/',/extract)
n_slash = n_elements(slash_str)
if (n_slash GT 1) then begin
    out_filebase = slash_str[n_slash-1]
endif else begin
    out_filebase = info.control.filename_raw
endelse
info.control.filename = out_filebase ; only the filename not directory
len= strlen(out_filebase)
out_file = strmid(out_filebase,0,len-5)
info.control.filebase = out_file
end

;_______________________________________________________________________
pro mql_setup_miri_sloper,info,status 
status = 0

; filling the  the info.ms struture - this is passed and used
; by mql_edit_miri_sloper_paramters (change parameters) 
; then mql_run_miri_sloper is called to spawn the miri_sloper process.


mql_setup_miri_sloper_names,info,status

if(status ne 0) then return 
; open to read in the SCA ID
fits_open,info.control.filename_raw,fcb
fits_read,fcb,cube_raw,header_raw,/header_only
fits_close,fcb

info.ms.quickslope = 0 ; Quick slope method - no reference corrections

info.ms.electrons_second = 0
info.ms.gain = info.control.gain
info.ms.read_noise = info.control.readnoise
info.ms.uncertaintyMethod = info.control.UncertaintyMethod

info.ms.frametime = info.control.frametime
info.ms.filename = info.control.filename
info.ms.cosmic_ray_test = 1
info.ms.filebase = info.control.filebase
info.ms.output_filename = info.control.filebase

info.ms.dir = info.control.dir
info.ms.dirout = info.control.dirout
info.ms.dircal = info.control.dircal

info.ms.subset_size = info.control.subset_size
info.ms.frame_limit = info.control.frame_limit
info.ms.start_fit = info.control.start_fit
info.ms.highDN = info.control.highDN


info.ms.sat_mask = info.control.apply_pixel_sat ; use a saturation mask to mark saturated pixels
info.ms.badpixel = info.control.apply_bad ; use a bad pixel file to mark bad pixels
info.ms.lincor = info.control.apply_lin ; correct data using non-linearity file
info.ms.reset_correction = info.control.apply_reset
info.ms.rscd_correction = info.control.apply_rscd
info.ms.dark_correction = info.control.apply_dark
info.ms.lastframe_correction = info.control.apply_lastframe

info.ms.saturation_file = ' ' 
info.ms.bad_file = ' ' 
info.ms.lincor_file = '  '
info.ms.reset_correction_file = ' ' 
info.ms.rscd_correction_file = ' ' 
info.ms.lastframe_correction_file = ' ' 
info.ms.dark_correction_file = ' '
 
info.ms.flag_satmask= 0
info.ms.flag_badfile= 0
info.ms.flag_lincor = 0
info.ms.flag_reset = 0 
info.ms.flag_rscd = 0 
info.ms.flag_lastframe = 0 
info.ms.flag_dark = 0

info.ms.end_fit = info.control.end_fit
info.ms.delta_row_even_odd = info.control.delta_row_even_odd
info.ms.apply_rscd = info.control.apply_rscd  
info.ms.refpixel_option = info.control.refpixel_option


info.ms.flag_outputname = 0
info.ms.do_diagnostic = 0
info.ms.write_refcorrected_data = 0
info.ms.write_id_data = 0
info.ms.write_lincor_data = 0
info.ms.write_reset_corrected_data = 0
info.ms.write_rscd_corrected_data = 0
info.ms.write_lastframe_corrected_data = 0
info.ms.write_dark_corrected_data = 0 
info.ms.flag_subset_size = 0
info.ms.flag_frame_limit= 0
info.ms.flag_dircal= 0
info.ms.flag_dir= 0
info.ms.flag_dirout= 0

info.ms.flag_highDN = 0
info.ms.flag_gain = 0
info.ms.flag_read_noise = 0
info.ms.flag_frametime = 0
end



;***********************************************************************
pro mql_edit_ms_parameters_done,event
widget_control,event.top, Get_UValue = tinfo
widget_control,tinfo.info.QuickLook,Get_UValue=info
    widget_control,info.EditMSParameters,/destroy
    
end

;***********************************************************************
pro mql_edit_ms_parameters_cleanup,topbaseID

; get all defined structures so they are deleted when the program
; terminates

widget_control,topbaseID,get_uvalue=ginfo
widget_control,ginfo.info.Quicklook,get_uvalue = info
widget_control,info.EditMSParameters,/destroy
end
;***********************************************************************
pro mql_edit_ms_parameters_run,event

; get all defined structures so they are deleted when the program
; terminates
widget_control,event.top, Get_UValue = tinfo
widget_control,tinfo.info.QuickLook,Get_UValue=info

widget_control,tinfo.filenameButton, get_value = temp
filein = strcompress(temp,/remove_all)
result = strcmp(filein, info.control.filename)
if(result eq 0) then begin 
    len = strlen(filein) 
    test = strmid(filein,len-1,len-1)
    info.ms.filename =filein
endif

widget_control,tinfo.outnameButton, get_value = temp
outname = strcompress(temp,/remove_all)
result = strcmp(outname, info.control.filebase)

if(result eq 0) then begin 
    info.ms.output_filename = outname
    info.ms.flag_outputname = 1
endif


widget_control,tinfo.dirinField, get_value = temp
dirin = strcompress(temp,/remove_all)
result = strcmp(dirin, info.control.dir)
if(result eq 0) then begin 
    len = strlen(dirin) 
    test = strmid(dirin,len-1,len-1)
    if(test eq '/') then dirin = strmid(dirin,0,len-1)
    info.ms.dir =dirin
    info.ms.flag_dir = 1
endif


widget_control,tinfo.diroutField, get_value = temp
dirout = strcompress(temp,/remove_all)
result = strcmp(dirout, info.control.dirout)
if(result eq 0) then begin 
    len = strlen(dirout) 
    test = strmid(dirout,len-1,len-1)
    if(test eq '/') then dirout = strmid(dirout,0,len-1)
    info.ms.dirout =dirout
    info.ms.flag_dirout = 1
endif



widget_control,tinfo.dircalField, get_value = temp
dircal = strcompress(temp,/remove_all)
result = strcmp(dircal, info.control.dircal)
if(result eq 0) then begin
    len = strlen(dircal) 
    test = strmid(dircal,len-1,len-1)
    if(test eq '/') then dircal = strmid(dircal,0,len-1)
    info.ms.dircal =dircal
    info.ms.flag_dircal = 1
endif

widget_control,tinfo.quickbutton, get_value = temp
info.ms.quickslope = temp



widget_control,tinfo.rtypebutton, get_value = temp
; translate no correction, r1, r2, r3, r5, r6
info.ms.refpixel_type = temp
if(temp eq 4) then temp = 5
if(temp eq 5) then temp = 6
info.ms.refpixel_type = temp 	 

widget_control,tinfo.deltarowButton, get_value = temp
info.ms.delta_row_even_odd = temp 	 


widget_control,tinfo.esButton, get_value = temp
info.ms.electrons_second = temp 	 

widget_control,tinfo.crButton, get_value = temp
info.ms.cosmic_ray_test = temp 	 

widget_control,tinfo.gainButton, get_value = temp
if(temp ne info.control.gain) then begin
    info.ms.gain = temp 	 
    info.ms.flag_gain = 1
endif

widget_control,tinfo.rnButton, get_value = temp
if(temp ne info.control.readnoise) then begin
    info.ms.read_noise = temp 	 
    info.ms.flag_read_noise = 1
endif

widget_control,tinfo.frametimeButton, get_value = temp
if(temp ne info.control.frametime) then begin 
    info.ms.frametime = temp
    info.ms.flag_frametime = 1 	 
endif

widget_control,tinfo.ORButton, get_value = temp
info.ms.write_refcorrected_data = temp 	 


widget_control,tinfo.OIDButton, get_value = temp
info.ms.write_id_data = temp 	 

widget_control,tinfo.OLCButton, get_value = temp
info.ms.write_lincor_data = temp 	 

widget_control,tinfo.ORSCDButton, get_value = temp
info.ms.write_rscd_corrected_data = temp 	 

widget_control,tinfo.ODCButton, get_value = temp
info.ms.write_dark_corrected_data = temp 	 

widget_control,tinfo.OLFButton, get_value = temp
info.ms.write_lastframe_corrected_data = temp 	 


widget_control,tinfo.OdiagButton, get_value = temp
info.ms.do_diagnostic = temp 	 


widget_control,tinfo.rejectsButton, get_value = temp
info.ms.start_fit = temp 	 


widget_control,tinfo.rejecteButton, get_value = temp
info.ms.end_fit = temp 	 
    

widget_control,tinfo.highDNButton, get_value = temp
if(temp ne info.control.highDN) then begin
    info.ms.highDN = temp 	 
    info.ms.flag_highDN = 1
endif


;default saturation mask
widget_control,tinfo.smbutton,get_value = temp
info.ms.sat_mask = temp

; select a different saturation mask
widget_control,tinfo.saturation_fileButton, get_value = temp
file  = strcompress(temp,/remove_all)
if(strlen(file) gt 5) then begin
    info.ms.saturation_file =file
    info.ms.flag_satmask = 1
;    info.ms.sat_mask = 1
endif 


;apply linearity
widget_control,tinfo.lcbutton,get_value = temp
info.ms.lincor = temp

; select a different linearity file
widget_control,tinfo.lincor_fileButton, get_value = temp
file  = strcompress(temp,/remove_all)
if(strlen(file) gt 5) then begin
    info.ms.lincor_file =file
    info.ms.flag_lincor = 1
endif 

;apply bad pixel mask 
widget_control,tinfo.bpbutton,get_value = temp
info.ms.badpixel = temp

widget_control,tinfo.bad_fileButton, get_value = temp
file  = strcompress(temp,/remove_all)
if(strlen(file) gt 5) then begin 
    info.ms.bad_file =file
    info.ms.flag_badfile = 1
 endif


;rscd
widget_control,tinfo.rcbutton,get_value = temp
info.ms.rscd_correction = temp

widget_control,tinfo.rscd_fileButton, get_value = temp
file  = strcompress(temp,/remove_all)
if(strlen(file) gt 5) then begin 
    info.ms.rscd_correction_file =file
    info.ms.flag_rscd = 1
 endif

;last frame
widget_control,tinfo.lfbutton,get_value = temp
info.ms.lastframe_correction = temp

widget_control,tinfo.lastframe_fileButton, get_value = temp
file  = strcompress(temp,/remove_all)
if(strlen(file) gt 5) then begin 
    info.ms.lastframe_correction_file =file
    info.ms.flag_lastframe = 1
 endif

;dark
widget_control,tinfo.dcbutton,get_value = temp
info.ms.dark_correction = temp

widget_control,tinfo.dark_fileButton, get_value = temp
file  = strcompress(temp,/remove_all)
if(strlen(file) gt 5) then begin 
    info.ms.dark_correction_file =file
    info.ms.flag_dark  = 1
endif


widget_control,tinfo.framelimitButton, get_value = temp
if(temp ne info.control.frame_limit) then begin 
    info.ms.frame_limit = temp 	
    info.ms.flag_frame_limit = 1
endif
widget_control,tinfo.subsetsizeButton, get_value = temp
if(temp ne info.control.subset_size) then begin 
    info.ms.subset_size = temp
    info.ms.flag_subset_size = 1
endif


;_______________________________________________________________________
; Checks

flag = 0
fail = 0


widget_control,info.Quicklook,Set_UValue = info

if(fail eq 0) then begin 
    widget_control,info.EditMSParameters,/destroy
    mql_run_miri_sloper,info,status
    if(status ne 0) then return 

    if(info.display_widget eq 1) then begin 
       ; print,' Display Science Frames and Slope images'
        info.control.int_num = info.control.int_num_save
        info.image.integrationNO = info.control.int_num
        info.image.rampNO = info.control.frame_start
        info.control.int_num = info.control.int_num_save
        reading_header,info,status,error_message	
        status = 0
        if(status eq 1) then return

        find_image_binfactor,info

        setup_frame_image_stepA,info
        info.image.x_pos =(info.data.image_xsize/info.image.binfactor)/2.0
        info.image.y_pos = (info.data.image_ysize/info.image.binfactor)/2.0
        setup_frame_pixelvalues,info
        setup_frame_image_stepB,info
        get_this_frame_stat,info
        mql_display_images,info
    endif

    if(info.display_widget eq 2) then begin
        if(XRegistered ('mpl')) then begin
            info.pl.slope_exists = 1
            get_pltracking_slope,info.pl.group, info
            for k = 0, 3 do begin
                mpl_calculate_ramp,k,info
            endfor
            mpl_update_plot,info
        endif
        setup_slope_image,info
        msql_display_slope,info



    endif

    if(info.display_widget eq 3) then begin
        setup_slope_image,info
        setup_cal_image,info
        msql_display_slope,info

    endif

endif



end


;***********************************************************************
pro mql_edit_ms_parameters_event,event
Widget_Control,event.id,Get_uValue=event_name
widget_control,event.top, Get_UValue = einfo	
widget_control,einfo.info.QuickLook,Get_Uvalue = info

;_______________________________________________________________________

if (widget_info(event.id,/TLB_SIZE_EVENTS) eq 1 ) then begin
    info.ms.xwindowsize = event.x
    info.ms.ywindowsize = event.y

    info.ms.uwindowsize = 1
    widget_control,event.top,set_uvalue = einfo
    widget_control,einfo.info.Quicklook,set_uvalue = info
    mql_edit_miri_sloper_parameters,info
    return
endif

case event.id of
    einfo.refButton1: begin
      ; Change the option for subtracting reference image
        temp = event.value
        if(temp eq 1) then info.ms.apply_rscd = 1 	 
    end

    einfo.refButton2: begin
      ; Change the option for subtracting reference image
        temp = event.value
        if(temp eq 1) then info.ms.apply_rscd = 2 	 
    end

    einfo.esButton: begin
      ; convert to electrons per seconds
        temp = event.value
        info.ms.electrons_second = temp 	 
    end

    einfo.gainbutton: begin
      ; Gain
        temp = event.value
        info.ms.gain = temp 	 
        info.ms.flag_gain = 1
    end

    einfo.rnbutton: begin
      ; read noise
        temp = event.value
        info.ms.read_noise = temp 	 
        info.ms.flag_read_noise = 1
    end




    einfo.quickbutton: begin
      ; Quick slope 
        temp = event.value
        info.ms.quickslope = event.value
        if(event.value eq 1) then  begin
            widget_control,einfo.crbutton,sensitive = 0
            widget_control,einfo.rtypeButton,sensitive = 0
            widget_control,einfo.deltarowButton,sensitive = 0
            widget_control,einfo.bpButton,sensitive = 0
            widget_control,einfo.smButton,sensitive = 0
            widget_control,einfo.lcButton,sensitive = 0
            widget_control,einfo.rcButton,sensitive = 0
            widget_control,einfo.dcButton,sensitive = 0
            widget_control,einfo.bad_fileButton,sensitive = 0
            widget_control,einfo.saturation_fileButton,sensitive = 0
            widget_control,einfo.lincor_fileButton,sensitive = 0
            widget_control,einfo.rscd_fileButton,sensitive = 0
            widget_control,einfo.lastframe_fileButton,sensitive = 0
            widget_control,einfo.dark_fileButton,sensitive = 0
            widget_control,einfo.CRButton,sensitive = 0
            widget_control,einfo.ORButton,sensitive = 0
            widget_control,einfo.OLCButton,sensitive = 0
            widget_control,einfo.OIDButton,sensitive = 0
            widget_control,einfo.OdiagButton,sensitive = 0
            widget_control,einfo.ORSCDButton,sensitive = 0
            widget_control,einfo.OLFButton,sensitive = 0
            widget_control,einfo.ODCButton,sensitive = 0
            widget_control,einfo.bButton[0],sensitive = 0
            widget_control,einfo.bButton[1],sensitive = 0
            widget_control,einfo.bButton[2],sensitive = 0
            widget_control,einfo.bButton[3],sensitive = 0
            widget_control,einfo.bButton[4],sensitive = 0
            widget_control,einfo.bButton[5],sensitive = 0
            

        endif

        if(event.value eq 0) then  begin
            widget_control,einfo.crbutton,sensitive = 1
            widget_control,einfo.rtypeButton,sensitive = 1
            widget_control,einfo.deltarowButton,sensitive = 1
            widget_control,einfo.bpButton,sensitive = 1
            widget_control,einfo.smButton,sensitive = 1
            widget_control,einfo.lcButton,sensitive = 1
            widget_control,einfo.rcButton,sensitive = 1
            widget_control,einfo.lfButton,sensitive = 1
            widget_control,einfo.dcButton,sensitive = 1
            widget_control,einfo.bad_fileButton,sensitive = 1
            widget_control,einfo.saturation_fileButton,sensitive = 1
            widget_control,einfo.lincor_fileButton,sensitive = 1
            widget_control,einfo.rscd_fileButton,sensitive = 0
            widget_control,einfo.lastframe_fileButton,sensitive = 0
            widget_control,einfo.dark_fileButton,sensitive = 0
            widget_control,einfo.CRButton,sensitive = 1
            widget_control,einfo.ORButton,sensitive = 1
            widget_control,einfo.ORSCDButton,sensitive = 1
            widget_control,einfo.OLFButton,sensitive = 1
            widget_control,einfo.ODCButton,sensitive = 1
            widget_control,einfo.OLCButton,sensitive = 1
            widget_control,einfo.OIDButton,sensitive = 1
            widget_control,einfo.OdiagButton,sensitive = 1
            widget_control,einfo.bButton[0],sensitive = 1
            widget_control,einfo.bButton[1],sensitive = 1
            widget_control,einfo.bButton[2],sensitive = 1
            widget_control,einfo.bButton[3],sensitive = 1
            widget_control,einfo.bButton[4],sensitive = 1
            widget_control,einfo.bButton[5],sensitive = 1
        endif
    end

    einfo.crbutton: begin
      ; cosmic ray test
        temp = event.value
        info.ms.cosmic_ray_test = temp 	 
    end

    einfo.frametimebutton: begin
      ; Frame Time
        temp = event.value
        info.ms.frametime = temp
        info.ms.flag_frametime = 1 	 
    end


    einfo.rtypeButton: begin
        temp = event.value
        info.ms.refpixel_type = temp 	

        if(info.ms.refpixel_type ne 2) then  begin
            widget_control,einfo.deltarowButton,sensitive = 0
         endif

        if(info.ms.refpixel_type  eq 2) then  begin
            widget_control,einfo.deltarowButton,sensitive = 1
         endif
    end

    einfo.deltarowButton: begin
      ; Change the option  delta row
        temp = event.value
        info.ms.delta_row_even_odd = temp 	 
    end


    einfo.rejectsButton: begin
      ; Change the option  frame to start slope fit
        temp = event.value
        info.ms.start_fit = temp 	 
    end


    einfo.rejecteButton: begin
      ; Change the option  frame to end slope fit
        temp = event.value
        info.ms.end_fit = temp 	 
        if(info.ms.end_fit ne 0) then begin  
           widget_control,einfo.lfButton,sensitive = 0
           widget_control,einfo.lastframe_fileButton,sensitive = 0
           widget_control,einfo.OLFButton,sensitive = 0
        endif

        if(info.ms.end_fit eq 0) then begin  
           widget_control,einfo.lfButton,sensitive = 1
           widget_control,einfo.lastframe_fileButton,sensitive = 1
           widget_control,einfo.OLFButton,sensitive = 1
        endif


    end


    einfo.highDNButton: begin
      ; Change the option  frame to end slope fit
        temp = event.value
        info.ms.highDN = temp 	 
    end

    einfo.bpButton: begin
      ; Change the option for applying bad pixel list
        temp = event.value
        info.ms.badpixel = temp 	 
    end

    einfo.smButton: begin
      ; Change the option for applying saturation mask
        temp = event.value
        info.ms.sat_mask = temp 	 
    end

    einfo.lcButton: begin
      ; Change the option for applying linearity correction file
        temp = event.value
        info.ms.lincor = temp 	 
     end

    einfo.rcButton: begin
      ; Change the option for applying rscd correction
        temp = event.value
        info.ms.rscd_correction = temp 	 
     end

    einfo.lfButton: begin
      ; Change the option for applying last frame correction file
        temp = event.value
        info.ms.lastframe_correction = temp 	 
     end

    einfo.dcButton: begin
      ; Change the option for using dark correction file
        temp = event.value
        info.ms.dark_correction = temp 	 
    end

    einfo.framelimitButton: begin
      ; Change the option chaning the frame limit button
        temp = event.value
        info.ms.frame_limit = temp 	
        info.ms.flag_frame_limit = 1
    end

    einfo.subsetsizeButton: begin
      ; Change the option chaning the subset size (2,4,8,16,32)
        temp = event.value
        info.ms.subset_size = temp
        info.ms.flag_subset_size = 1
    end

    einfo.dircalField: begin
      ; calibration directory
        Widget_Control, einfo.dircalField, Get_Value = temp
        dircal = temp[0]
        dircal = strcompress(dircal,/remove_all)
        len = strlen(dircal) 
        test = strmid(dircal,len-1,len-1)
        if(test eq '/') then dircal = strmid(dircal,0,len-1)
        info.ms.dircal =dircal
        info.ms.flag_dircal = 1
    end

    einfo.filenamebutton: begin
      ; input filename
        Widget_Control, einfo.filenamebutton, Get_Value = temp
        filein = temp[0]
        filein = strcompress(filein,/remove_all)
        len = strlen(filein) 
        test = strmid(filein,len-1,len-1)
        if(test eq '/') then dircal = strmid(filein,0,len-1)
        info.ms.filename =filein
    end

    einfo.outnamebutton: begin
      ; output filename
        Widget_Control, einfo.outnamebutton, Get_Value = temp
        filein = temp[0]
        filein = strcompress(filein,/remove_all)
        info.ms.output_filename =filein
        info.ms.flag_outputname = 1
    end

    einfo.bad_filebutton: begin
;      ; bad pixel  filename
        Widget_Control, einfo.bad_filebutton, Get_Value = temp
        filein = temp[0]
        filein = strcompress(filein,/remove_all)
        info.ms.bad_file =filein
        info.ms.flag_badfile = 1
        info.ms.badpixel = 1
    end


    einfo.saturation_filebutton: begin
      ; pixel saturation filename
        Widget_Control, einfo.saturation_filebutton, Get_Value = temp
        filein = temp[0]
        filein = strcompress(filein,/remove_all)
        info.ms.saturation_file =filein
        info.ms.flag_satmask = 1
    end


    einfo.lincor_filebutton: begin
      ; linearity correction
        Widget_Control, einfo.lincor_filebutton, Get_Value = temp
        filein = temp[0]
        filein = strcompress(filein,/remove_all)
        info.ms.lincor_file =filein
        info.ms.flag_lincor = 1
     end

    einfo.rscd_filebutton: begin
      ; rscd correction
        Widget_Control, einfo.rscd_filebutton, Get_Value = temp
        filein = temp[0]
        filein = strcompress(filein,/remove_all)
        info.ms.rscd_correction_file =filein
        info.ms.flag_rscd = 1
     end

    einfo.lastframe_filebutton: begin
      ; lastframe correction
        Widget_Control, einfo.lastframe_filebutton, Get_Value = temp
        filein = temp[0]
        filein = strcompress(filein,/remove_all)
        info.ms.lastframe_correction_file =filein
        info.ms.flag_lastframe = 1
     end

    einfo.dark_filebutton: begin
      ; dark correction
        Widget_Control, einfo.dark_filebutton, Get_Value = temp
        filein = temp[0]
        filein = strcompress(filein,/remove_all)
        info.ms.dark_correction_file =filein
        info.ms.flag_dark = 1
    end


    einfo.changeButton: begin
        status = 0
        info.control.set_scidata = 0
        mql_setup_miri_sloper_names,info,status
        if(status ne 0) then return

        info.ms.filename = info.control.filename
        info.ms.filebase = info.control.filebase
        info.ms.dir = info.control.dir
        info.ms.dirout = info.control.dirout
        widget_control,einfo.filenamebutton,set_value = info.ms.filename 
        info.ms.output_filename = info.control.filebase
        widget_control,einfo.outnamebutton,set_value = info.ms.output_filename 
        widget_control,einfo.dirinField,set_value = info.ms.dir
        widget_control,einfo.diroutField,set_value = info.ms.dirout
        
    end

    einfo.dirinField: begin
      ; set name input directory
        Widget_Control, einfo.dirinField, Get_Value = temp
        dirin = temp[0]
        dirin = strcompress(dirin,/remove_all)
        len = strlen(dirin) 
        test = strmid(dirin,len-1,len-1)
        if(test eq '/') then dirin = strmid(dirin,0,len-1)
        info.ms.dir =dirin
        info.ms.flag_dir = 1
    end

    einfo.diroutField: begin
      ; set name output directory
        Widget_Control, einfo.diroutField, Get_Value = temp
        dirout = temp[0]
        dirout = strcompress(dirout,/remove_all)
        len = strlen(dirout) 
        test = strmid(dirout,len-1,len-1)
        if(test eq '/') then dirout = strmid(dirout,0,len-1)
        info.ms.dirout =dirout
        info.ms.flag_dirout = 1
    end


    einfo.bbutton[1]: begin
        image_file = dialog_pickfile(/read,Title = 'Please select Pixel Saturation Calibration file',$
                             get_path=realpath,Path=info.control.dircal,$
                             filter = '*.fits')

        if(image_file eq '')then begin
            print,' No file selected, can not read in data'
        endif
        if (image_file NE '') then begin
            info.ms.saturation_file = image_file
            info.ms.flag_satmask = 1
            Widget_Control, einfo.saturation_filebutton, Set_Value = image_file            
        endif
        
    end

    einfo.bbutton[0]: begin
        image_file = dialog_pickfile(/read,Title = 'Please select Bad Pixel Mask',$
                             get_path=realpath,Path=info.control.dircal,$
                             filter = '*.fits')

        if(image_file eq '')then begin
            print,' No file selected, can not read in data'
        endif
        if (image_file NE '') then begin
            info.ms.bad_file = image_file
            info.ms.flag_badfile = 1
            Widget_Control, einfo.bad_filebutton, Set_Value = image_file            
        endif
        
    end

    einfo.bbutton[2]: begin
        image_file = dialog_pickfile(/read,Title = 'Please select RSCD Correction File',$
                             get_path=realpath,Path=info.control.dircal,$
                             filter = '*.fits')

        if(image_file eq '')then begin
            print,' No file selected, can not read in data'
        endif
        if (image_file NE '') then begin
            info.ms.rscd_correction_file = image_file
            info.ms.flag_rscd= 1
            Widget_Control, einfo.rscd_filebutton, Set_Value = image_file            
        endif
        
     end


    einfo.bbutton[4]: begin
        image_file = dialog_pickfile(/read,Title = 'Please select Dark Correction File',$
                             get_path=realpath,Path=info.control.dircal,$
                             filter = '*.fits')

        if(image_file eq '')then begin
            print,' No file selected, can not read in data'
        endif
        if (image_file NE '') then begin
            info.ms.dark_correction_file = image_file
            info.ms.flag_dark= 1
            Widget_Control, einfo.dark_filebutton, Set_Value = image_file            
        endif
        
     end


    einfo.bbutton[5]: begin
        image_file = dialog_pickfile(/read,Title = 'Please select Linearity Correction File',$
                             get_path=realpath,Path=info.control.dircal,$
                             filter = '*.fits')

        if(image_file eq '')then begin
            print,' No file selected, can not read in data'
        endif
        if (image_file NE '') then begin
            info.ms.lincor_file = image_file
            info.ms.flag_lincor= 1
            Widget_Control, einfo.lincor_filebutton, Set_Value = image_file            
        endif
        
    end


    einfo.ORButton: begin
      ; Write reference Pixel corrected data
        temp = event.value
        info.ms.write_refcorrected_data = temp 	 
     end

    einfo.ORSCDButton: begin
      ; Write rscdcorrected data
        temp = event.value
        info.ms.write_rscd_corrected_data = temp 	 
     end

    einfo.OLFButton: begin
      ; Write last frame corrected data
        temp = event.value
        info.ms.write_lastframe_corrected_data = temp 	 
     end

    einfo.OLCButton: begin
      ; Write linearity corrected data
        temp = event.value
        info.ms.write_lincor_data = temp 	 
     end

    einfo.ODCButton: begin
      ; Write dark corrected data
        temp = event.value
        info.ms.write_dark_corrected_data = temp 	 
    end


    einfo.qbutton : begin
        message = " miri_sloper -Q: quick processing. Produce a slope & a zero pt image only. Only options allowed " +$
                  " rejection of initial & final frames, and reject above saturation limit" 
        result = dialog_message(message,/information)
    end

    einfo.ibutton[0] : begin
        message = " The default bad pixel mask is found in the calibration directory." +$
                  string(10b) + " This FITS file contains a 0(good pixel) or nonzero (hot,dead,noisy data) for every pixel "
        result = dialog_message(message,/information)
    end

    einfo.ibutton[1] : begin
        message = " The default pixel saturation file is found in the calibration directory." +$
                  string(10b) + " This FITS file contains the saturation level for every pixel"
        result = dialog_message(message,/information)
    end

    einfo.ibutton[2] : begin
        message = " The default rscd correction file is found in the calibration directory." +$
                  string(10b) + " This FITS file contains a rscd correction for every pixel "
        result = dialog_message(message,/information)
     end
    einfo.ibutton[3] : begin
        message = " The default last frame correction is found in the calibration directory." +$
                  string(10b) + " This FITS file contains the dark portion of the last frame correction for every pixel "
        result = dialog_message(message,/information)
     end
    einfo.ibutton[4] : begin
        message = " The default dark correction is found in the calibration directory." +$
                  string(10b) + " This FITS file contains a dark correction for every pixel "
        result = dialog_message(message,/information)
    end

    einfo.ibutton[5] : begin
        message = " The default linearity correction is found in the calibration directory." +$
                  string(10b) + " This FITS file contains a linearity correction  for every pixel "
        result = dialog_message(message,/information)
    end

    
    einfo.lbutton[0] : begin
        result = dialog_message($
                 ['To determine a slope for each pixel, all the reads for the pixel must be held in memory.', $
                  'For datasets with a large number of reads/integration, the program operates more efficiently',$
                  'if only a portion of the pixels are held in memory for processing. ',$
                  'The option given here, means that if the number of frames is greater than the value provided',$
                  'the program will read the dataset in rows. The number of rows to read in at one time is ',$
                  'given by the next option.' ],/information)
    end

    einfo.lbutton[1] : begin
        result = dialog_message($
                 ['To determine a slope for each pixel, all the reads for the pixel must be held in memory.', $
                  'For datasets with a large number of reads/integration, the program operates more efficiently',$
                  'if only a portion of the pixels are held in memory for processing. ',$
                  'The option given here sets the number of rows to read in at one time and determine the slope.'],$
                 /information)
    end


    else:
  endcase

   Widget_Control,einfo.info.QuickLook,Set_UValue=info
end


;***********************************************************************
pro mql_edit_miri_sloper_parameters,info


if(XRegistered ('mems')) then begin
    widget_control,info.EditMSParameters,/destroy
endif
;_______________________________________________________________________  
 ; Don't pop up if there is already an edit user preferences widget up.

;if (XRegistered('mems')) then return
xwidget_size = 1250
ywidget_size = 1300
ysize_scroll = 1000
xsize_scroll = 1080



if(info.ms.uwindowsize eq 1) then begin ; user has set window size 
    xsize_scroll = info.ms.xwindowsize
    ysize_scroll = info.ms.ywindowsize
endif    
if(info.control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.control.x_scroll_window
if(info.control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.control.y_scroll_window
if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10


option2b = 0

if(info.ms.delta_row_even_odd ne 0) then option2b = 1
etitle = 'Parameters to run Miri_Sloper Program on file ' 

EditParameters = Widget_base(Title = etitle, /Column, $
                             mbar = menuBar,$
                             Group_Leader = info.QuickLook,xsize=xwidget_size,ysize=ywidget_size,$
                             /scroll,x_scroll_size = xsize_scroll,y_scroll_size = ysize_scroll,$
                            /TLB_SIZE_EVENTS,/grid_layout)

;********
; build the menubar
;********

DoneMenu = widget_button(menuBar,value="Quit",font = info.font2)
Donebutton = widget_button(Donemenu,value="Quit",event_pro='mql_edit_ms_parameters_done')

lbase  = widget_base(EditParameters,/row,/align_center)
runbutton = widget_button(lbase, $
                        value =' Accept Values and Run the MIRI_SLOPER program',$
                        font=info.font5,event_pro = 'mql_edit_ms_parameters_run')


infotitle = 'MUST hit RETURN in INPUT BOXES to EFFECT change!'

tlabelID = widget_label(lbase,value =infotitle ,font=info.font5)

highDNbutton = 0L
bpbutton  = 0L
smbutton  = 0L
lcbutton = 0L
bad_filebutton = 0L
sat_filebutton = 0L
lincor_fileButton = 0L
refbutton1 = 0L
rnbutton = 0L
uncerbutton = 0L
refbutton2 = 0L
rtypebutton = 0L
deltarowbutton = 0L
deltarow_evenodd_button = 0L
rejectsbutton = 0L
rejectebutton = 0L
framelimitbutton = 0L
subsetsizebutton = 0L
dircalfield = 0L
dirinfield = 0L
diroutfield = 0L
filenamebutton = 0L
changebutton = 0L
outnameButton = 0L
quickButton = 0L
ibutton = lonarr(6)
bbutton = lonarr(6)
lbutton = lonarr(2)

ORButton = 0L
ORSCDbutton = 0L
OLFbutton = 0L
OLCbutton = 0L
ODCbutton = 0L
OdiagButton = 0L
qbutton = 0L


yesno_names = ['No', 'Yes']

dname = info.ms.filename
loadbase = Widget_Base(EditParameters, /Row, /Frame)
filenamebutton = cw_field(loadbase, value=dname, $
                          title='Filename', $
                           uvalue='dname', /Return_Events, /String,xsize=60,/noedit)
changebutton = widget_button(loadbase,value=' Change Filename ')


dname = ' Quick Slope Processing'
dlabel = Widget_Label(loadbase, Value=dname)
dnames = ['No', 'Yes']
dvalue =0
if(info.ms.quickslope eq 1) then  dvalue = 1
quickbutton = CW_BGroup(loadbase, yesno_names, exclusive=1, row=1, $
                        Set_Value=dvalue, /No_Release)

qbutton = widget_button(loadbase,value='Info',font=info.font4)
    
;________________________________________________________________________________
dname = info.ms.dir
loadbase = Widget_Base(EditParameters, /Row)
dirinField = cw_field(loadbase, value=dname, $
                      title='Directory name for input science files', $
                      uvalue='dname', /Return_Events, /String,xsize=60)


dname = info.ms.dirout
loadbase = Widget_Base(EditParameters, /Row )
diroutField = cw_field(loadbase, value=dname, $
                      title='Directory name for output science files (LVL2) ', $
                      uvalue='dname', /Return_Events, /String,xsize=60)


dname = info.ms.output_filename
loadbase = Widget_Base(EditParameters, /Row)
outnameButton = cw_field(loadbase, value=dname, $
                       title='Supply an output prefix name for the slope fits file, '+ $
                       'instead of the default:', $
                       uvalue='dname', /Return_Events, /String,xsize=60)
dname = info.ms.dircal
loadbase = Widget_Base(EditParameters, /Row)
dircalField = cw_field(loadbase, value=dname, $
                       title='Directory name for location of calibration files', $
                       uvalue='dname', /Return_Events, /String,xsize=60)



dbase = Widget_Base(EditParameters, /Row)
dname = ' Convert to Electrons per Second ' 
dlabel = Widget_Label(dbase, Value=dname)
dvalue = info.ms.electrons_second
esbutton = CW_BGroup(dbase, yesno_names, exclusive=1, row=1, $
                          Set_Value=dvalue, /No_Release)

dname = info.ms.gain
gainbutton = cw_field(dbase, value=dname, $
                         title='Gain ', $
                         /Return_Events, /String,xsize=15)

dname = info.ms.frametime
frametimebutton = cw_field(dbase, value=dname, $
                         title='FrameTime ', $
                         /Return_Events, /String,xsize=15)

dname = info.ms.read_noise
rnbutton = cw_field(dbase, value=dname, $
                         title='Read Noise ', $
                         /Return_Events, /String,xsize=15)


;________________________________________________________________________________

dname = info.ms.start_fit
loadbase = Widget_Base(EditParameters, /Row, /Frame)
rejectsbutton = cw_field(loadbase, value=dname, $
                         title='Frame number to start slope fit', $
                         /Return_Events, /String,xsize=5)

dname = info.ms.end_fit
rejectebutton = cw_field(loadbase, value=dname, $
                         title='End fit on # of frames before last frame', $
                         /Return_Events, /String,xsize=5)
infolabel = widget_label(loadbase, value=' (Option is not used if value = 0)') 

dname = info.ms.highDN



highDNbutton = cw_field(loadbase, value=dname, $
                         title='Reject values above ', $
                         /Return_Events, /String,xsize=15)

;dbase = Widget_Base(EditParameters, /Row, /Frame)
;dname = 'Measurement Uncertainty: ' 
;dlabel = Widget_Label(dbase, Value=dname)
;dnames = ['U1: equal to 1', 'UU determined from photon noise & read noise', 'UC, UU + correlated measurements']
;dvalue = info.ms.UncertaintyMethod
;uncerbutton = CW_BGroup(dbase, dnames, exclusive=1, row=1, $
;                          Set_Value=dvalue, /No_Release)

;dbase = Widget_Base(EditParameters, /Row, /Frame)
;dname = 'Subtract Raw Reference Output: (+ro1) ' 
;dlabel = Widget_Label(dbase, Value=dname)
;dvalue = 0
;if(info.ms.subtract_refoutput eq 1)  then dvalue = 1
;refbutton1 = CW_BGroup(dbase, yesno_names, exclusive=1, row=1, $
;                          Set_Value=dvalue, /No_Release)

;dname = 'Subtract de-sloped Ref Output: (+ro2) ' 
;dlabel = Widget_Label(dbase, Value=dname)
;dvalue =0
;if(info.ms.subtract_refoutput eq 2) then  dvalue = 1
;refbutton2 = CW_BGroup(dbase, yesno_names, exclusive=1, row=1, $
;                          Set_Value=dvalue, /No_Release)


;_______________________________________________________________________
; Reference pixel options

dbase = Widget_Base(EditParameters, /Row)

optionb = 0
if(info.ms.refpixel_option eq 1) then optionb = 1
if(info.ms.refpixel_option eq 2) then optionb = 2
if(info.ms.refpixel_option eq 3) then optionb = 3
if(info.ms.refpixel_option eq 5) then optionb = 4
if(info.ms.refpixel_option eq 6) then optionb = 5



dnames2 = ['No Correction','r1','r2','r3','r5','r6']

dlabel = Widget_Label(dbase, Value= 'Reference Pixel Correction Options:')
rtypebutton = cw_BGroup(dbase, dnames2,  exclusive=1, row=1, $
                        Set_Value=optionb, /No_Release)
    
dbase = Widget_Base(EditParameters, /Row)
dname = 'If using +r2, ref pixel correctionrow by row, interpolating between left & right ref pixels' 
dlabel = Widget_Label(dbase, Value=dname)

dname = info.ms.delta_row_even_odd
deltarowbutton = cw_field(dbase, value=dname, $
                          title='# delta (even/odd) rows to find slope & y-int',$
                          /Return_Events, /String,xsize=5)


dbase = Widget_Base(EditParameters, /Row)
bbase = widget_label(dbase,value = 'Write reference corrected frame data to FITS file')
bpvalue = info.ms.write_refcorrected_data
ORbutton = CW_BGroup(dbase, yesno_names, exclusive=1, row=1, Set_Value=bpvalue, /No_Release)
;_______________________________________________________________________
dbase = Widget_Base(EditParameters, /Row, /Frame)
dlabel = Widget_Label(dbase, Value=' Do Cosmic Ray Flagging ' )
dvalue = info.ms.cosmic_ray_test
crbutton = CW_BGroup(dbase, yesno_names, exclusive=1, row=1, $
                          Set_Value=dvalue, /No_Release)


;_______________________________________________________________________
;_______________________________________________________________________
; Bad Pixels
loadbase = Widget_Base(EditParameters, /Row)
bplabel = Widget_Label(loadbase, Value='Apply Bad Pixel Mask:   ' )
bpvalue = info.ms.badpixel
bpbutton = CW_BGroup(loadbase, yesno_names, exclusive=1, row=1, $
                         Set_Value=bpvalue, /No_Release)
ibutton[0] = widget_button(loadbase,value='Info',font=info.font4)    
dname = info.ms.bad_file
bad_filebutton = cw_field(loadbase, value=dname, $
                       title=' Use default or Select file', $
                       uvalue='dname', /Return_Events, /String,xsize=40)
bbutton[0] = widget_button(loadbase,value='Browse',font=info.font4)
;_______________________________________________________________________

; Pixel Saturation
loadbase = Widget_Base(EditParameters, /Row)
smlabel = Widget_Label(loadbase, Value='Apply Saturation Mask: ' )
smvalue = info.ms.sat_mask
smbutton = CW_BGroup(loadbase, yesno_names, exclusive=1, row=1, $
                         Set_Value=smvalue, /No_Release)
ibutton[1] = widget_button(loadbase,value='Info',font=info.font4)

dname = info.ms.saturation_file 
saturation_filebutton = cw_field(loadbase, value=dname, $
                                 title=' Use default or Select file', $
                                 uvalue='dname', /Return_Events, /String,xsize=40)
bbutton[1] = widget_button(loadbase,value='Browse',font=info.font4)

;_______________________________________________________________________
; RSCD Correction
loadbase = Widget_Base(EditParameters, /Row)

rclabel = Widget_Label(loadbase, Value='Apply RSCD Correction:' )
rcvalue = info.ms.rscd_correction
rcbutton = CW_BGroup(loadbase, yesno_names, exclusive=1, row=1, $
                         Set_Value=rcvalue, /No_Release)
ibutton[2] = widget_button(loadbase,value='Info',font=info.font4)

dname = info.ms.rscd_correction_file 
rscd_filebutton = cw_field(loadbase, value=dname, $
                                 title=' Use default or Select file', $
                                 uvalue='dname', /Return_Events, /String,xsize=40)
bbutton[2] = widget_button(loadbase,value='Browse',font=info.font4)

ORSCDbutton = 0L
bbase = widget_label(loadbase,value = 'Write corrected data to FITS file')
bpvalue = info.ms.write_rscd_corrected_data
ORSCDbutton = CW_BGroup(loadbase, yesno_names, exclusive=1, row=1, Set_Value=bpvalue, /No_Release)
;_______________________________________________________________________
; last Frame 
loadbase = Widget_Base(EditParameters, /Row)

lflabel = Widget_Label(loadbase, Value='Apply Last Frame Corr: ' )
lfvalue = info.ms.lastframe_correction
lfbutton = CW_BGroup(loadbase, yesno_names, exclusive=1, row=1, $
                         Set_Value=lfvalue, /No_Release)
ibutton[3] = widget_button(loadbase,value='Info',font=info.font4)

dname = info.ms.lastframe_correction_file 
lastframe_filebutton = cw_field(loadbase, value=dname, $
                                 title=' Use default or Select file', $
                                 uvalue='dname', /Return_Events, /String,xsize=40)
bbutton[3] = widget_button(loadbase,value='Browse',font=info.font4)

bbase = widget_label(loadbase,value = 'Write corrected data to FITS file')
bpvalue = info.ms.write_lastframe_corrected_data
OLFbutton = CW_BGroup(loadbase, yesno_names, exclusive=1, row=1,Set_Value=bpvalue, /No_Release)

if(info.ms.end_fit ne 0) then begin  
   widget_control,lfButton,sensitive = 0
   widget_control,lastframe_fileButton,sensitive = 0
   widget_control,OLFButton,sensitive = 0
endif

if(info.ms.end_fit eq 0) then begin  
   widget_control,lfButton,sensitive = 1
   widget_control,lastframe_fileButton,sensitive = 1
   widget_control,OLFButton,sensitive = 1
endif

;_______________________________________________________________________
; Dark Correction
loadbase = Widget_Base(EditParameters, /Row)

dclabel = Widget_Label(loadbase, Value='Apply Dark Correction: ' )
dcvalue = info.ms.dark_correction
dcbutton = CW_BGroup(loadbase, yesno_names, exclusive=1, row=1, $
                         Set_Value=dcvalue, /No_Release)
ibutton[4] = widget_button(loadbase,value='Info',font=info.font4)

dname = info.ms.dark_correction_file 
dark_filebutton = cw_field(loadbase, value=dname, $
                                 title=' Use default or Select file', $
                                 uvalue='dname', /Return_Events, /String,xsize=40)
bbutton[4] = widget_button(loadbase,value='Browse',font=info.font4)

bbase = widget_label(loadbase,value = 'Write corrected data to FITS file')
bpvalue = info.ms.write_dark_corrected_data
ODCbutton = CW_BGroup(loadbase, yesno_names, exclusive=1, row=1,Set_Value=bpvalue, /No_Release)
;_______________________________________________________________________

; Linearity Correction
loadbase = Widget_Base(EditParameters, /Row)

lclabel = Widget_Label(loadbase, Value='Apply Linearity Corr:  ')
lcvalue = info.ms.lincor
lcbutton = CW_BGroup(loadbase, yesno_names, exclusive=1, row=1, $
                         Set_Value=lcvalue, /No_Release)
ibutton[5] = widget_button(loadbase,value='Info',font=info.font4)

dname = info.ms.lincor_file 
lincor_filebutton = cw_field(loadbase, value=dname, $
                                 title=' Use default  or Select File', $
                                 uvalue='dname', /Return_Events, /String,xsize=40)
bbutton[5] = widget_button(loadbase,value='Browse',font=info.font4)

bbase = widget_label(loadbase,value = 'Write corrected data to FITS file')
bpvalue = info.ms.write_lincor_data
OLCbutton = CW_BGroup(loadbase, yesno_names, exclusive=1, row=1, Set_Value=bpvalue, /No_Release)
;_______________________________________________________________________

crbase =  Widget_Base(EditParameters, /Row,/frame)
dlabel = Widget_label(crbase,value = 'Write frame data quality id flags FITS file:   ')
bpvalue = info.ms.write_id_data
OIDbutton = CW_BGroup(crbase, yesno_names, exclusive=1, row=1, Set_Value=bpvalue, /No_Release)


crbase =  Widget_Base(EditParameters, /Row)
dlabel = Widget_label(crbase,value = 'Write 2 pt difference information to FITS file: ')
bpvalue = info.ms.do_diagnostic 
Odiagbutton = CW_BGroup(crbase, yesno_names, exclusive=1, row=1, Set_Value=bpvalue, /No_Release)

;_______________________________________________________________________

dname = info.ms.frame_limit
loadbase = Widget_Base(EditParameters, /Row, /Frame)
framelimitbutton = cw_field(loadbase, value=dname, $
                            title='Read frames in groups (subset mode) if # of frames/int >', $
                            /Return_Events, /String,xsize=5)
lbutton[0] = widget_button(loadbase,value='Info',font=info.font4)

dname = info.ms.subset_size
subsetsizebutton = cw_field(loadbase, value=dname, $
                        title='If in subset mode, # of rows to read in and process', $
                        /Return_Events, /String,xsize=5)
lbutton[1] = widget_button(loadbase,value='Info',font=info.font4)




einfo = {$
        filenamebutton    : filenamebutton,$
        changebutton      : changebutton,$
        outnameButton     : outnameButton,$
        quickbutton       : quickbutton,$
	refbutton1         : refbutton1,$
	refbutton2         : refbutton2,$
	uncerbutton        : uncerbutton,$
	esbutton          : esbutton,$
	gainbutton        : gainbutton,$
	rnbutton          : rnbutton,$
	frametimebutton   : frametimebutton,$
        rtypebutton        : rtypebutton,$
        deltarowbutton    : deltarowbutton,$
        ORbutton          : ORbutton,$
        ORSCDbutton      : ORSCDbutton,$
        OLFbutton         : OLFbutton,$
        ODCbutton         : ODCbutton,$
        OLCbutton         : OLCbutton,$
        OIDbutton          : OIDbutton,$
        Odiagbutton        : Odiagbutton,$
	rejectsbutton     : rejectsbutton,$
	rejectebutton     : rejectebutton,$
        highDNbutton      : highDNbutton,$
        bad_filebutton    : bad_filebutton,$
        saturation_filebutton    : saturation_filebutton,$
        rscd_filebutton    : rscd_filebutton,$
        lastframe_filebutton    : lastframe_filebutton,$
        dark_filebutton    : dark_filebutton,$
        lincor_filebutton    : lincor_filebutton,$
	bpbutton          : bpbutton,$
	smbutton          : smbutton,$
	rcbutton          : rcbutton,$
	lfbutton          : lfbutton,$
	dcbutton          : dcbutton,$
        lcbutton          : lcbutton,$
        framelimitbutton  : framelimitbutton,$
        subsetsizebutton  : subsetsizebutton,$
	dircalfield       : dircalfield,$
        dirinfield        : dirinfield,$
        diroutfield       : diroutfield,$
        qbutton           : qbutton,$
        ibutton           : ibutton,$	
        bbutton           : bbutton,$
        lbutton           : lbutton,$
        crbutton          : crbutton,$
         info             : info}

Widget_Control,EditParameters,Set_UValue=einfo

info.EditMSParameters = EditParameters                                                                             
widget_control,info.Quicklook,Set_UValue = info
Widget_control,info.EditMSParameters,/Realize  
XManager,'mems',info.EditMSParameters,/No_Block,cleanup='mql_edit_ms_parameters_cleanup',$
         event_handler='mql_edit_ms_parameters_event'

end



;;_______________________________________________________________________

