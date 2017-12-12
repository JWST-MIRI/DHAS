; the event manager for the ql.pro (main base widget)
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

;_______________________________________________________________________
    (strmid(event_name,0,10) EQ 'JWST_LoadI') : begin

        if(XRegistered ('jwst_msql')) then sl_filename = info.control.filename_raw

        info.jwst_image.uwindowsize = 0
        jwst_setup_names,info,status,error_message
        if(status eq 2) then return
        if(status eq 1) then begin
            result = dialog_message(error_message,/error)
            return
        endif

        if(XRegistered ('jwst_msql')) then begin
            if(sl_filename ne info.control.filename_raw) then begin
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
        jwst_setup_frame_image_stepA,info

        info.jwst_image.x_pos =(info.jwst_data.image_xsize/info.jwst_image.binfactor)/2.0
        info.jwst_image.y_pos = (info.jwst_data.image_ysize/info.jwst_image.binfactor)/2.0
        jwst_setup_frame_pixelvalues,info
        jwst_setup_frame_image_stepB,info
        jwst_get_this_frame_stat,info


        jwst_mql_display_images,info
     end	

;____________________________________________________________________
;_______________________________________________________________________

    (strmid(event_name,0,6) EQ 'Load2R') : begin
        not_converted_load_compare,info
     end	
;_______________________________________________________________________



else: print," Event name not found",event_name
endcase
end
