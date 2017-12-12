; the event manager for the ql.pro (main base widget)
pro ql_event,event


Widget_Control,event.id,Get_uValue=event_name
Widget_Control,event.top,Get_UValue=info
if (widget_info(event.id,/TLB_SIZE_EVENTS) eq 1 ) then begin
    
    widget_control,info.quicklook,draw_xsize = event.x, draw_ysize=event.y
    Widget_Control,event.top,Set_UValue=info
    return
endif



    case 1 of
;_______________________________________________________________________
;_______________________________________________________________________
; Pixel Look
    (strmid(event_name,0,5) EQ 'RunPL') : begin

        info.control.set_scidata = 0
        ; check and see if other analysis window are open -
        ; close ones that use same structure to hold data

        
        if(XRegistered ('mrp')) then begin
            print,'close display  ref pixel images'
            widget_control,info.RefPixelQuickLook,/destroy
        endif        

        if(XRegistered ('mirql')) then begin
            print,'close display  ref  images'
            widget_control,info.inspectrefimage,/destroy
        endif        

        if(XRegistered ('mql')) then mqlfile = info.control.filename_raw
        if(XRegistered ('msql')) then msqlfile = info.control.filename_raw

        info.pl.uwindowsize = 0

        info.pl.overplot_slope = 0
        info.pl.overplot_frame = 1
        info.pl.read_setB = 0
        info.pl2.uwindowsize = 0

        setup_names,info,status,error_message

        if(status eq 2) then return
        if(status eq 1) then begin
            result = dialog_message(error_message,/error)
            return
        endif

        status = 0


        if(XRegistered ('mql')) then begin 
            if(mqlfile ne info.control.filename_raw) then begin  
                ql_reset,info
                print,'close display images'
                widget_control,info.RawQuickLook,/destroy
            endif
        endif        

        if(XRegistered ('msql')) then begin 
            if(msqlfile ne info.control.filename_raw) then begin  
                ql_reset,info
                print,'close Slope display images'
                widget_control,info.SlopeQuickLook,/destroy
            endif
        endif        

        
        mpl_display,info,status


        if(XRegistered ('mpl')) then mpl_update_plot,info
    end
;____________________________________________________________________
; Slope 
    (strmid(event_name,0,5) EQ 'LoadS') : begin
        info.control.set_scidata = 0
        if(XRegistered ('mrp')) then begin
            widget_control,info.RefPixelQuickLook,/destroy
        endif        

        if(XRegistered ('mql')) then mqlfile = info.control.filename_raw
        if(XRegistered ('mpl')) then mplfile = info.control.filename_raw


        status_continue = 0
        setup_names_from_slope,info,status_continue,error_message

        if(status_continue eq 2) then return
        if(status_continue eq 1 ) then begin
            result = dialog_message(error_message,/error)
            return
        endif

        if(XRegistered ('mql')) then begin 
            if(mqlfile ne info.control.filename_raw) then begin  
                ql_reset,info
                print,'close display images'
                widget_control,info.RawQuickLook,/destroy
            endif
        endif        

        if(XRegistered ('mpl')) then begin
            print,mplfile,info.control.filename_raw
            if(mplfile ne info.control.filename_raw) then begin  
                ql_reset,info
                print,'close Pixel display'
                widget_control,info.PixelLook,/destroy
            endif
        endif        
            
        setup_slope_image,info
        setup_cal_image,info

        find_slope_binfactor,info


        Widget_Control,info.QuickLook,Set_UValue=info


        if(status_continue eq 3) then begin
            info.loadfile.uwindowsize = 0
            load_file,info
        endif else begin 
            reading_header,info ; read in raw header 
            msql_display_slope,info
        endelse

    end
;_______________________________________________________________________
    (strmid(event_name,0,6) EQ 'LoadT1') : begin
        info.telemetry.uwindowsize = 0
        info.telemetry.n_poss_lines = 4
        info.telemetry.uwindowsize_table = 0
        mtql_display_telemetry,info,1

    end

    (strmid(event_name,0,6) EQ 'LoadT2') : begin
        info.telemetry_raw.n_poss_lines = 4
        info.telemetry_raw.uwindowsize = 0
        info.telemetry_raw.uwindowsize_table = 0
        mtql_display_telemetry,info,2

    end
;_______________________________________________________________________
    (strmid(event_name,0,5) EQ 'LoadI') : begin

        info.control.set_scidata = 0
        if(XRegistered ('mpl')) then pl_filename = info.control.filename_raw

        if(XRegistered ('msql')) then sl_filename = info.control.filename_raw


        if(XRegistered ('mrp')) then begin
            widget_control,info.RefPixelQuickLook,/destroy
        endif        

        if(XRegistered ('mirql')) then begin
            widget_control,info.inspectrefimage,/destroy
        endif        



        info.image.uwindowsize = 0
        setup_names,info,status,error_message
        if(status eq 2) then return
        if(status eq 1) then begin
            result = dialog_message(error_message,/error)
            return
        endif


        if(XRegistered ('mpl')) then begin
            if(pl_filename ne info.control.filename_raw) then begin
                ql_reset,info
                widget_control,info.PixelLook,/destroy
                print,'Closing Pixel Look window'
            endif
        endif        


        if(XRegistered ('msql')) then begin
            if(sl_filename ne info.control.filename_raw) then begin
                ql_reset,info
                widget_control,info.SlopeQuickLook,/destroy
                print,'Closing Slope Look window'
            endif
        endif        

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
     end	
     
;_______________________________________________________________________

    (strmid(event_name,0,6) EQ 'Load2R') : begin
        load_compare,info
     end	
;_______________________________________________________________________
    (strmid(event_name,0,9) EQ 'CalQSlope') : begin
        info.control.set_scidata = 0
	mql_setup_miri_sloper,info,status
        if(status ne 0) then return
        info.ms.quickslope = 1
        mql_run_miri_sloper,info,status
        if(status ne 0) then return
        setup_slope_image,info
        msql_display_slope,info
        widget_control,event.top,Set_UValue = info
    end


    (strmid(event_name,0,9) EQ 'CalDSlope') : begin
        info.control.set_scidata = 0
	mql_setup_miri_sloper,info,status
        if(status ne 0) then return        
        mql_run_miri_sloper,info,status
        if(status ne 0) then return

        setup_slope_image,info
        msql_display_slope,info
        widget_control,event.top,Set_UValue = info

    end


    (strmid(event_name,0,8) EQ 'CalSlope') : begin
        info.control.set_scidata = 0
	mql_setup_miri_sloper,info,status
        if(status ne 0) then return
        info.display_widget = 1
	mql_edit_miri_sloper_parameters,info

    end

    (strmid(event_name,0,6) EQ 'CalCal') : begin
        info.control.set_scidata = 0
	mql_setup_miri_caler,info,status
        if(status ne 0) then return
        info.display_widget = 2
	mql_edit_miri_caler_parameters,info
        widget_control,event.top,Set_UValue = info

    end
;_______________________________________________________________________


else: print," Event name not found",event_name
endcase
end
