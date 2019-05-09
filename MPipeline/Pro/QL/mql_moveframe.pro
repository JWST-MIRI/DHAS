pro mql_moveframe,jintegration,iramp,info

imove=0
fmove =0
if(jintegration  ne info.image.integrationNO) then imove=1
if(iramp ne info.image.rampNO) then fmove = 1


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
    info.image.integrationNO = jintegration

    read_single_slope,info.control.filename_slope,slope_exists,$
                      info.image.integrationNO,subarray,slopedata,$
                      slope_xsize,slope_ysize,slope_zsize,stats,$
                      do_bad,badfile, status,error_message

    if(slope_exists eq 1) then begin 
       if ptr_valid (info.data.preduced) then ptr_free,info.data.preduced
       info.data.preduced = ptr_new(slopedata)
            
       info.data.reduced_stat = stats
    endif
    slopedata = 0
    stats = 0
; if not all of the data has been read in - then check to make sure that frame
; in question has been read in.
; If not then 1. call read_multi_frames
;             2. update main display images
;             3. clean up extra widgets that might of been openned - histogram, inspect, ect.
;	      4. update plots 
    if(info.data.read_all eq 0 and info.image.integrationNO ne info.control.int_num) then begin
        info.control.int_num = info.image.integrationNO
        print,'Reading in another set of images'
        info.image.rampNO = 0
        info.control.frame_start = info.control.frame_start_save
        info.control.frame_end = info.control.frame_start + info.control.read_limit -1
        if(info.control.frame_end+1 ge info.data.nramps) then $
          info.control.frame_end = info.data.nramps -1
        iramp = 0

        read_multi_frames,info


        Widget_Control,info.QuickLook,Set_UValue=info

    endif
;____________________
; kill single widget plots
    type = 0 ;(integration clean up)
    mql_cleanup_widgets,type,info
    
    get_this_frame_stat,info
    mql_update_images,info
    mql_update_zoom_image,info

    mql_update_slope,info
    info.image.int_range[*] = jintegration + 1

    mql_update_pixel_stat,info

    graphno = [0,2]
    for i = 0,1  do begin 
        info.image.current_graph = graphno[i]
        mql_update_pixel_location,info ; update pixel location on graph windows
    endfor

    
    mql_update_rampread,info                          


    widget_control,info.image.integration_label,set_value= fix(jintegration+1)
    widget_control,info.image.frame_label,set_value= fix(iramp+1)
;____________________
    

        
; if inspect images open then update
    if(XRegistered ('miql')) then begin
        i = info.image.integrationNO
        j = info.image.rampNO
        if(info.data.read_all eq 0) then begin
            i = 0
            if(info.data.num_frames ne info.data.nramps) then begin 
                j = info.image.rampNO- info.control.frame_start
            endif
        endif
        info.inspect.integrationNO = info.image.integrationNO
        info.inspect.frameNO = info.image.rampNO
        frame_image = fltarr(info.data.image_xsize,info.data.image_ysize)
        frame_image[*,*] = (*info.data.pimagedata)[i,j,*,*]
        if ptr_valid (info.inspect.pdata) then ptr_free,info.inspect.pdata
        info.inspect.pdata = ptr_new(frame_image)
        frame_image = 0
        Widget_Control,info.QuickLook,Set_UValue=info

        miql_update_images,info
        miql_update_pixel_location,info
        Widget_Control,info.QuickLook,Set_UValue=info
    endif


endif
;_______________________________________________________________________
;_______________________________________________________________________
;  Frame Button
if(fmove eq 1) then begin
    info.image.rampNO = iramp
    if(info.data.read_all eq 0) then begin

        
        if(iramp lt info.control.frame_start or iramp gt info.control.frame_end)  then begin
            ; reset the frame start and frame end
            frame_start = iramp - (info.control.read_limit/4)
            if(frame_start lt 0) then frame_start = 0
            

            frame_end = frame_start + info.control.read_limit -1
            if(frame_end+1 ge info.data.nramps) then begin
                frame_end = info.data.nramps -1
                frame_start = frame_end - info.control.read_limit +1
                if(frame_start lt 0) then frame_start = 0
            endif


            info.control.frame_start = frame_start
            info.control.frame_end = frame_end
            Widget_Control,info.QuickLook,Set_UValue=info


            print,'Reading in  another set of images',iramp,info.control.frame_start+1, $
                  info.control.frame_end+1
            read_multi_frames,info

        endif                          

    endif
    widget_control,info.image.frame_label,set_value= fix(iramp+1)
;____________________
; kill single widget plots
    type = 1; (frame clean up) 
    mql_cleanup_widgets,type,info

    get_this_frame_stat,info
    mql_update_images,info
    mql_update_zoom_image,info
    Widget_Control,info.QuickLook,Set_UValue=info    

    


; if inspect images open then update
    if(XRegistered ('miql')) then begin
        i = info.image.integrationNO
        j = info.image.rampNO
        if(info.data.read_all eq 0) then begin
            i = 0
            if(info.data.num_frames ne info.data.nramps) then begin 
                j = info.image.rampNO- info.control.frame_start
            endif
        endif
        info.inspect.integrationNO = info.image.integrationNO
        info.inspect.frameNO = info.image.rampNO
        frame_image = fltarr(info.data.image_xsize,info.data.image_ysize)
        frame_image[*,*] = (*info.data.pimagedata)[i,j,*,*]
        if ptr_valid (info.inspect.pdata) then ptr_free,info.inspect.pdata
        info.inspect.pdata = ptr_new(frame_image)
        frame_image = 0
        Widget_Control,info.QuickLook,Set_UValue=info

        miql_update_images,info
        miql_update_pixel_location,info
        Widget_Control,info.QuickLook,Set_UValue=info
    endif


endif

; update single widget plots - this is not done if using
;                              mql_cleanup_widgets
; Kept code - incase people want this option
;_______________________________________________________________________

update_single_plots =0
update_slope_plots = 0
if(update_single_plots) then begin 
    if(XRegistered ('mqlhr')) then begin
        type = 0
        mql_setup_hist,type,info
        mql_display_histo,type,info
    endif
    
; if column slice  plots up - replot
    if(XRegistered ('mqlcsr')) then begin
        type = 0
        mql_setup_colslice,type,info
        mql_display_colslice,type,info
    endif

; if row slice  plots up - replot
    if(XRegistered ('mqlrsr')) then begin
        type = 0
        mql_setup_rowslice,type,info
        mql_display_rowslice,type,info
    endif

endif


if(update_single_plots) then begin 
    if(XRegistered ('mqlhs')) then begin
        type = 2
        mql_setup_hist,type,info
        mql_display_histo,type,info
    endif
    
; if column slice  plots up - replot
    if(XRegistered ('mqlcss')) then begin
        type = 2
        mql_setup_colslice,type,info
        mql_display_colslice,type,info
    endif

; if row slice  plots up - replot
    if(XRegistered ('mqlrss')) then begin
        type = 2
        mql_setup_rowslice,type,info
        mql_display_colslice,type,info
    endif

endif

Widget_Control,info.QuickLook,Set_UValue=info


end


