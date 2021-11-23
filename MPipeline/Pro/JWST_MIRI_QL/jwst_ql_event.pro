; the event manager for the miri_ql.pro (main base widget)
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

        if(XRegistered ('jwst_msql')) then sl_filename = info.jwst_control.filebase

        info.jwst_image.uwindowsize = 0
        jwst_setup_names,info,0,status,error_message
        if(status eq 2) then return
        if(status eq 1) then begin
            result = dialog_message(error_message,/error)
            return
        endif

        if(XRegistered ('jwst_msql')) then begin
            if(sl_filename ne info.jwst_control.filebase) then begin
                jwst_ql_reset,info
                widget_control,info.jwst_SlopeQuickLook,/destroy
                print,'Closing Rate Look window'
            endif
        endif        

        if(XRegistered ('jwst_misql')) then begin
           widget_control,info.jwst_InspectSlope,/destroy
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
        ; read in the data
        jwst_setup_intermediate,info ; ramp data, slope data, and  all intemediate data 
        jwst_setup_slope_final,info,0,status  ;rate
        jwst_setup_slope_int,info,0,0         ;rate int
        jwst_setup_cal,info,0

        xvalue = info.jwst_image.x_pos * info.jwst_image.binfactor
        yvalue = info.jwst_image.y_pos * info.jwst_image.binfactor

        jwst_mql_read_slopedata,xvalue,yvalue,info
        jwst_get_this_frame_stat,info
        jwst_mql_display_images,info

     end	
;____________________________________________________________________
; Slope and Slope Int - MUST HAVE RATE FILE 
    (strmid(event_name,0,10) EQ 'JWST_LoadS') : begin
       if(XRegistered ('jwst_mql')) then sl_filename = info.jwst_control.filebase

        status_continue = 0
        jwst_setup_names,info,1,status_continue,error_message

        if(status_continue eq 2) then return
        if(status_continue eq 1 ) then begin
            result = dialog_message(error_message,/error)
            return
         endif

        if(XRegistered ('jwst_mql')) then begin
            if(sl_filename ne info.jwst_control.filebase) then begin
                jwst_ql_reset,info
                widget_control,info.jwst_RawQuickLook,/destroy
                print,'Closing JWST QuickLook window'
            endif
        endif    

        if(XRegistered ('jwst_misql')) then begin
           widget_control,info.jwst_InspectSlope,/destroy
        endif
        info.jwst_slope.integrationNO[0] = -1 ; final rate image 
        info.jwst_slope.plane[0] = 0 ; rate 
        info.jwst_slope.integrationNO[1] = 0
        ; open rate data
        jwst_setup_slope_final,info,1,status  ; default set first image to Final Rate
        if (info.jwst_control.file_slope_exist eq 0) then begin
           result = dialog_message('Rate File does not exist, it must for this option',/error)
           return
        endif

        ; open rate int data 
        jwst_setup_slope_int,info,info.jwst_slope.integrationNO[1],1 ; fills in prate2 is *rate_ints.fits exist - if not return

        if (info.jwst_control.file_slope_exist eq 1) then begin ; rate image  
           info.jwst_slope.data_type[0] = 1 ; rate
           info.jwst_slope.plane[0] = 0
        endif

        if(info.jwst_control.file_slope_int_exist eq 1) then begin ; rate int image 
           info.jwst_slope.data_type[1] = 2 ; rate int 
           info.jwst_slope.plane[1] = 0
        endif

        if(info.jwst_control.file_slope_int_exist eq 0) then begin ; set rate2 to final error
           ; jwst_setup_slope_int could not fill in prate2 image
           ; set prate2 to rate error

           info.jwst_slope.plane[1] = 2        ; dq 
           info.jwst_slope.data_type[1] = 1    ; rate
           stats = info.jwst_data.rate1_stat
           slopedata = (*info.jwst_data.prate1)
           if ptr_valid (info.jwst_data.prate2) then ptr_free,info.jwst_data.prate2
           info.jwst_data.prate2 = ptr_new(slopedata)
           info.jwst_data.rate2_stat = stats
           info.jwst_slope.integrationNO[1] = -1
           slopedata = 0
           stats = 0 
        endif

        jwst_find_slope_binfactor,info
        jwst_msql_display_slope,info
     end
;_______________________________________________________________________
;reduced data:  Calibration Image and Rate (option). Must have cal file
    (strmid(event_name,0,10) EQ 'JWST_LoadR') : begin

        status_continue = 0
        jwst_setup_names,info,2,status_continue,error_message

        if(status_continue eq 2) then return
        if(status_continue eq 1 ) then begin
            result = dialog_message(error_message,/error)
            return
         endif

        if(XRegistered ('jwst_mql')) then begin
           widget_control,info.jwst_RawQuickLook,/destroy
           print,'Closing JWST QuickLook window'
        endif
        if(XRegistered ('jwst_msql')) then begin
           widget_control,info.jwst_SlopeQuickLook,/destroy
           print,'Closing JWST Slope QuickLook window'
        endif

        if(XRegistered ('jwst_misql')) then begin
           widget_control,info.jwst_InspectSlope,/destroy
        endif
        jwst_setup_cal,info,2

        if (info.jwst_control.file_cal_exist eq 0) then begin
           result = dialog_message('Cal File does not exist, it must for this option',/error)
           return
        endif
        jwst_setup_slope_final,info,2,status
        jwst_find_cal_binfactor,info


        if (info.jwst_control.file_slope_exist eq 1 and info.jwst_control.file_cal_exist eq 1) then begin; default
           info.jwst_cal.data_type[0] = 3 ; cal image
           info.jwst_cal.plane[0] = 0 
           info.jwst_cal.data_type[1] = 1 ; rate image
           info.jwst_cal.plane[1] = 0 
           
        endif else begin 

           if(info.jwst_control.file_slope_exist eq 0) then begin ; set cal2 to cal error 
              
              stats = info.jwst_data.cal1_stat
              data = (*info.jwst_data.pcal1)
              if ptr_valid (info.jwst_data.pcal2) then ptr_free,info.jwst_data.pcal2
              info.jwst_data.pcal2 = ptr_new(data)
              info.jwst_data.rcal2_stat = stats
              info.jwst_cal.plane[1] = 2 ; error
              info.jwst_cal.data_type[1] = 3
           endif

           data = 0
           stats = 0 

        endelse

        jwst_mcql_display_images,info
       return
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
