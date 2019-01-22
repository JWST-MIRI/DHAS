; the event manager for the jwst_ql.pro (main base widget)
pro jwst_ql_event,event

Widget_Control,event.id,Get_uValue=event_name
Widget_Control,event.top,Get_UValue=info
if (widget_info(event.id,/TLB_SIZE_EVENTS) eq 1 ) then begin
    
    widget_control,info.jwst_quicklook,draw_xsize = event.x, draw_ysize=event.y
    Widget_Control,event.top,Set_UValue=info
    return
endif

case 1 of
;_______________________________________________________________________
; Main window for displaying data - loads level 1 and if it exist
;                                   level2 data 
;_______________________________________________________________________
    (strmid(event_name,0,10) EQ 'JWST_LoadI') : begin

        if(XRegistered ('jwst_msql')) then sl_filename = info.jwst_control.filename_raw

        info.jwst_image.uwindowsize = 0
        jwst_setup_names,info,1,status,error_message
        if(status eq 2) then return
        if(status eq 1) then begin
            result = dialog_message(error_message,/error)
            return
        endif

        if(XRegistered ('jwst_msql')) then begin
            if(sl_filename ne info.jwst_control.filename_raw) then begin
                jwst_ql_reset,info
                widget_control,info.jwst_SlopeQuickLook,/destroy
                print,'Closing Rate Look window'
            endif
        endif        

        info.jwst_image.integrationNO = info.jwst_control.int_num
        info.jwst_control.int_num = info.jwst_control.int_num_save
        jwst_reading_header,info,status,error_message	
        status = 0
        if(status eq 1) then return

        jwst_find_image_binfactor,info
        jwst_setup_frames_and_header,info

        info.jwst_image.x_pos =(info.jwst_data.image_xsize/info.jwst_image.binfactor)/2.0
        info.jwst_image.y_pos = (info.jwst_data.image_ysize/info.jwst_image.binfactor)/2.0
        jwst_setup_intermediate,info ; ramp data, slope data, and  all intemediate data 
        jwst_setup_slope,info,info.jwst_image.integrationNO,0

        xvalue = info.jwst_image.x_pos * info.jwst_image.binfactor
        yvalue = info.jwst_image.y_pos * info.jwst_image.binfactor

        jwst_mql_read_slopedata,xvalue,yvalue,info

        jwst_get_this_frame_stat,info
        jwst_mql_display_images,info
     end	

;____________________________________________________________________

; Slope 
    (strmid(event_name,0,10) EQ 'JWST_LoadS') : begin
       if(XRegistered ('jwst_mql')) then sl_filename = info.jwst_control.filename_slope

        status_continue = 0
        jwst_setup_names,info,2,status_continue,error_message

        if(status_continue eq 2) then return
        if(status_continue eq 1 ) then begin
            result = dialog_message(error_message,/error)
            return
         endif

        if(XRegistered ('jwst_mql')) then begin
            if(sl_filename ne info.jwst_control.filename_slope) then begin
                jwst_ql_reset,info
                widget_control,info.jwst_QuickLook,/destroy
                print,'Closing JWST QuickLook window'
            endif
        endif    
    

        jwst_setup_slope,info,info.jwst_slope.integrationNO,1
        jwst_find_slope_binfactor,info

;        setup_cal_image,info
        jwst_msql_display_slope,info
    end
;_______________________________________________________________________

    (strmid(event_name,0,10) EQ 'JWST_Load2') : begin
       jwst_load_compare,info
     end	
;_______________________________________________________________________


else: print," Event name not found",event_name
endcase
widget_control,event.top,Set_UValue=info
end
