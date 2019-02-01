pro jwst_mql_moveframe,jintegration,iramp,info

imove=0
fmove =0
if(jintegration  ne info.jwst_image.integrationNO) then imove=1
if(iramp ne info.jwst_image.frameNO) then fmove = 1


; If integration or frame number changed then -update to following
; plots (if the widget is up);
; From main mql window: science image, zoom image, and slope
; If 5 channel plots are open - update
; If Time Channel plot is open update
; If inspect science image is up - update.
; All other minor plots kill: histogram, column slice, row slice 
;_______________________________________________________________________
; Integration Button

if(imove eq 1) then begin
    info.jwst_image.integrationNO = jintegration

    if(info.jwst_control.file_slope_int_exist) then begin 
        jwst_read_single_slope,info.jwst_control.filename_slope_int,slope_exists,$
                               info.jwst_image.integrationNO,subarray,$
                               slopedata,$
                               slope_xsize,slope_ysize,$
                               stats,$
                               status,error_message

        if(slope_exists eq 1) then begin 
           if ptr_valid (info.jwst_data.preducedint) then ptr_free,info.jwst_data.preducedint
            info.jwst_data.preducedint = ptr_new(slopedata)
            
            info.jwst_data.reducedint_stat = stats
        endif
        slopedata = 0
        stats = 0
    endif
; if not all of the data has been read in - then check to make sure that frame
; in question has been read in.
; If not then 1. call read_multi_frames
;             2. update main display images
;             3. clean up extra widgets that might of been openned - histogram, inspect, ect.
;	      4. update plots 
    if(info.jwst_data.read_all eq 0 and info.jwst_image.integrationNO ne info.jwst_control.int_num) then begin
        info.jwst_control.int_num = info.jwst_image.integrationNO
        print,'Reading in another set of images'
        info.jwst_image.frameNO = 0
        info.jwst_control.frame_start = info.jwst_control.frame_start_save
        info.jwst_control.frame_end = info.jwst_control.frame_start + info.jwst_control.read_limit -1
        if(info.jwst_control.frame_end+1 ge info.jwst_data.ngroups) then $
          info.jwst_control.frame_end = info.jwst_data.ngroups -1
        iramp = 0

        jwst_read_multi_frames,info
        Widget_Control,info.jwst_QuickLook,Set_UValue=info

    endif
;____________________
; kill single widget plots
    type = 0 ;(integration clean up)
    ;;;;mql_cleanup_widgets,type,info
    
    jwst_get_this_frame_stat,info
    jwst_mql_update_images,info
    jwst_mql_update_zoom_image,info

    jwst_mql_update_slope,info
    info.jwst_image.int_range[*] = jintegration + 1

    jwst_mql_update_pixel_stat,info

    graphno = [0,2]
    for i = 0,1  do begin 
        info.jwst_image.current_graph = graphno[i]
        jwst_mql_update_pixel_location,info ; update pixel location on graph windows
    endfor

    
    jwst_mql_update_rampread,info                          
    widget_control,info.jwst_image.integration_label,set_value= fix(jintegration+1)
    widget_control,info.jwst_image.frame_label,set_value= fix(iramp+1)
        
; if inspect images open then update
    if(XRegistered ('miql')) then begin
        i = info.jwst_image.integrationNO
        j = info.jwst_image.frameNO
        if(info.jwst_data.read_all eq 0) then begin
            i = 0
            if(info.jwst_data.num_frames ne info.jwst_data.ngroups) then begin 
                j = info.jwst_image.frameNO- info.jwst_control.frame_start
            endif
        endif
        info.jwst_inspect.integrationNO = info.jwst_image.integrationNO
        info.jwst_inspect.frameNO = info.jwst_image.frameNO
        frame_image = fltarr(info.jwst_data.image_xsize,info.jwst_data.image_ysize)
        frame_image[*,*] = (*info.jwst_data.pimagedata)[i,j,*,*]
        if ptr_valid (info.jwst_inspect.pdata) then ptr_free,info.jwst_inspect.pdata
        info.jwst_inspect.pdata = ptr_new(frame_image)
        frame_image = 0
        Widget_Control,info.jwst_QuickLook,Set_UValue=info

        miql_update_images,info
        miql_update_pixel_location,info
        Widget_Control,info.jwst_QuickLook,Set_UValue=info
    endif


endif
;_______________________________________________________________________
;_______________________________________________________________________
;  Frame Button
if(fmove eq 1) then begin
    info.jwst_image.frameNO = iramp
    if(info.jwst_data.read_all eq 0) then begin

        
        if(iramp lt info.jwst_control.frame_start or iramp gt info.jwst_control.frame_end)  then begin
            ; reset the frame start and frame end
            frame_start = iramp - (info.jwst_control.read_limit/4)
            if(frame_start lt 0) then frame_start = 0
            

            frame_end = frame_start + info.jwst_control.read_limit -1
            if(frame_end+1 ge info.jwst_data.ngroups) then begin
                frame_end = info.jwst_data.ngroups -1
                frame_start = frame_end - info.jwst_control.read_limit +1
                if(frame_start lt 0) then frame_start = 0
            endif


            info.jwst_control.frame_start = frame_start
            info.jwst_control.frame_end = frame_end
            Widget_Control,info.jwst_QuickLook,Set_UValue=info


            print,'Reading in  another set of images',iramp,info.jwst_control.frame_start+1, $
                  info.jwst_control.frame_end+1
            jwst_read_multi_frames,info

        endif                          

    endif
    widget_control,info.jwst_image.frame_label,set_value= fix(iramp+1)
;____________________
; kill single widget plots
    type = 1; (frame clean up) 
    ;;mql_cleanup_widgets,type,info

    jwst_get_this_frame_stat,info
    jwst_mql_update_images,info
    jwst_mql_update_zoom_image,info
    Widget_Control,info.jwst_QuickLook,Set_UValue=info    

; if inspect images open then update
    if(XRegistered ('miql')) then begin
        i = info.jwst_image.integrationNO
        j = info.jwst_image.frameNO
        if(info.jwst_data.read_all eq 0) then begin
            i = 0
            if(info.jwst_data.num_frames ne info.jwst_data.ngroups) then begin 
                j = info.jwst_image.frameNO- info.jwst_control.frame_start
            endif
        endif
        info.jwst_inspect.integrationNO = info.jwst_image.integrationNO
        info.jwst_inspect.frameNO = info.jwst_image.frameNO
        frame_image = fltarr(info.jwst_data.image_xsize,info.jwst_data.image_ysize)
        frame_image[*,*] = (*info.jwst_data.pimagedata)[i,j,*,*]
        if ptr_valid (info.jwst_inspect.pdata) then ptr_free,info.jwst_inspect.pdata
        info.jwst_inspect.pdata = ptr_new(frame_image)
        frame_image = 0
        Widget_Control,info.jwst_QuickLook,Set_UValue=info

        miql_update_images,info
        miql_update_pixel_location,info
        Widget_Control,info.jwst_QuickLook,Set_UValue=info
    endif


endif

;_______________________________________________________________________


Widget_Control,info.jwst_QuickLook,Set_UValue=info


end


