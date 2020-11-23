pro jwst_msql_event,event
Widget_Control,event.id,Get_uValue=event_name
widget_control,event.top, Get_UValue = ginfo	
widget_control,ginfo.info.jwst_QuickLook,Get_Uvalue = info
jintegration = intarr(2)
jintegration[0] = info.jwst_slope.integrationNO[0]
jintegration[1] = info.jwst_slope.integrationNO[1]

if (widget_info(event.id,/TLB_SIZE_EVENTS) eq 1 ) then begin
    info.jwst_slope.xwindowsize = event.x
    info.jwst_slope.ywindowsize = event.y
    info.jwst_slope.uwindowsize = 1
    widget_control,event.top,set_uvalue = ginfo
    widget_control,ginfo.info.jwst_Quicklook,set_uvalue = info
    jwst_msql_display_slope,info
    return
endif

case 1 of
;_______________________________________________________________________
; Display statistics on the image 
;_______________________________________________________________________
    (strmid(event_name,0,4) EQ 'Stat') : begin
	jwst_msql_display_stat,info
        Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info
    end
;_______________________________________________________________________
; slope header
    (strmid(event_name,0,7) EQ 'sheader') : begin
        jwst_display_header,info,0
    end

; calibrated header 
    (strmid(event_name,0,7) EQ 'cheader') : begin
        if(info.jwst_control.file_cal_exist eq 0) then begin
            ok = dialog_message(" No calibration image exists",/Information)
        endif else begin
            jwst_display_header,info,1
        endelse
    end
;_______________________________________________________________________
    (strmid(event_name,0,7) EQ 'compare') : begin
        info.jwst_rcompare.uwindowsize = 0
        info.jwst_crinspect[*].uwindowsize = 1


        print,'planes',info.jwst_slope.plane[0], info.jwst_slope.plane[1]

        test1 = info.jwst_slope.plane[0]
        test2 = info.jwst_slope.plane[1]
        if(test1 ne test2) then begin 
           print,'Planes are not compatiable'
           ok = dialog_message(" Planes are not compatiable, load the same type of data in Window 1 and Window 2",/Information)
           return
        endif

        if (info.jwst_slope.integrationNO[0] eq -1) then begin 
           info.jwst_rcompare_image[0].filename  = info.jwst_control.filename_slope
           info.jwst_rcompare_image[0].type = 1
        endif else begin
           info.jwst_rcompare_image[0].filename  = info.jwst_control.filename_slope_int
           info.jwst_rcompare_image[0].type = 2
        endelse 

        if (info.jwst_slope.integrationNO[1] eq -1) then begin 
           info.jwst_rcompare_image[1].filename  = info.jwst_control.filename_slope
           info.jwst_rcompare_image[1].type = 1
        endif else begin
           info.jwst_rcompare_image[1].filename  = info.jwst_control.filename_slope_int
           info.jwst_rcompare_image[1].type = 2
        endelse 
              

        info.jwst_rcompare_image[0].jintegration = info.jwst_slope.integrationNO[0]
        info.jwst_rcompare_image[1].jintegration = info.jwst_slope.integrationNO[1]

        info.jwst_rcompare_image[0].plane = info.jwst_slope.plane[0]
        info.jwst_rcompare_image[1].plane = info.jwst_slope.plane[1]
        info.jwst_rcompare.uwindowsize = 0
        info.jwst_crinspect[*].uwindowsize = 1

	jwst_msql_compare_display,info
        Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info
    end




;_______________________________________________________________________
; print
    (strmid(event_name,0,5) EQ 'print') : begin
        if(strmid(event_name,6,1) eq '1') then type = 0
        if(strmid(event_name,6,1) eq 'Z') then type = 1
        if(strmid(event_name,6,1) eq '2') then type = 2
        if(strmid(event_name,6,1) eq 'E') then type = 3

        jwst_print_slope_images,info,type
    end
;_______________________________________________________________________
; inspect image
    (strmid(event_name,0,7) EQ 'inspect') : begin
        if(info.jwst_control.file_slope_exist eq 0) then begin
            ok = dialog_message(" No slope image exists",/Information)
            return
        endif
        type = fix(strmid(event_name,8,1))
	if(type eq 1) then begin 

            info.jwst_inspect_slope.integrationNO = info.jwst_slope.integrationNO[0]
            frame_image = (*info.jwst_data.prate1)

            if ptr_valid (info.jwst_inspect_slope.pdata) then ptr_free,info.jwst_inspect_slope.pdata
            info.jwst_inspect_slope.pdata = ptr_new(frame_image)
            frame_image = 0 
 
            Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info
            info.jwst_inspect_slope.plane = info.jwst_slope.plane[0]
            info.jwst_inspect_slope.zoom = 1
            info.jwst_inspect_slope.zoom_x = 1
            info.jwst_inspect_slope.x_pos =(info.jwst_data.slope_xsize)/2.0
            info.jwst_inspect_slope.y_pos = (info.jwst_data.slope_ysize)/2.0
            
            info.jwst_inspect_slope.xposful = info.jwst_inspect_slope.x_pos
            info.jwst_inspect_slope.yposful = info.jwst_inspect_slope.y_pos

            info.jwst_inspect_slope.limit_low = -5000.0
            info.jwst_inspect_slope.limit_high = 70000.0
            info.jwst_inspect_slope.limit_low_num = 0
            info.jwst_inspect_slope.limit_high_num = 0
            info.jwst_inspect_slope.graph_range[0] = info.jwst_slope.graph_range[0,0]
            info.jwst_inspect_slope.graph_range[1] = info.jwst_slope.graph_range[0,1]
            info.jwst_inspect_slope.default_scale_graph = info.jwst_slope.default_scale_graph[0]
            jwst_misql_display_images,info
            Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info

        endif
	if(type eq 2) then  begin
            info.jwst_inspect_slope2.integrationNO = info.jwst_slope.integrationNO[1]
            frame_image = (*info.jwst_data.prate2)

            if ptr_valid (info.jwst_inspect_slope2.pdata) then ptr_free,info.jwst_inspect_slope2.pdata
            info.jwst_inspect_slope2.pdata = ptr_new(frame_image)
            all_data = 0

            info.jwst_inspect_slope2.plane = info.jwst_slope.plane[1]
            info.jwst_inspect_slope2.zoom = 1
            info.jwst_inspect_slope2.zoom_x = 1
            info.jwst_inspect_slope2.x_pos =(info.jwst_data.slope_xsize)/2.0
            info.jwst_inspect_slope2.y_pos = (info.jwst_data.slope_ysize)/2.0

            info.jwst_inspect_slope2.xposful = info.jwst_inspect_slope.x_pos
            info.jwst_inspect_slope2.yposful = info.jwst_inspect_slope.y_pos

            info.jwst_inspect_slope2.limit_low = -5000.0
            info.jwst_inspect_slope2.limit_high = 70000.0
            info.jwst_inspect_slope2.limit_low_num = 0
            info.jwst_inspect_slope2.limit_high_num = 0
            info.jwst_inspect_slope2.graph_range[0] = info.jwst_slope.graph_range[2,0]
            info.jwst_inspect_slope2.graph_range[1] = info.jwst_slope.graph_range[2,1]
            info.jwst_inspect_slope2.default_scale_graph = info.jwst_slope.default_scale_graph[2]

            Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info
            jwst_misql2_display_images,info
        endif
        Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info
    end

;_______________________________________________________________________
; Change the Integration #  of image displayed
; event_name can equal integration1, integration2
; integr1_move_up, integr1_move_dn
; integr2_move_up, integr2_move_dn
;_______________________________________________________________________
    (strmid(event_name,0,6) EQ 'integr') : begin
        if (strmid(event_name,6,1) EQ 'a') then begin ; either integration1 or integration2
           num = fix(strmid(event_name,10,1)) -1
           this_value = event.value-1
           jintegration[num] = this_value
        endif

; check if the <> buttons were used
        if (strmid(event_name,7,5) EQ '_move')then begin
           num = fix(strmid(event_name,6,1))-1
           
            if(strmid(event_name,13,2) eq 'dn') then begin
                jintegration[num] = jintegration[num] -1
            endif
            if(strmid(event_name,13,2) eq 'up') then begin
                jintegration[num] = jintegration[num]+1
            endif
        endif

; do some checks - wrap around if necessary
        if(jintegration[num] lt 0) then begin
            jintegration[num] = info.jwst_data.nints-1
        endif
        if(jintegration[num] gt info.jwst_data.nints-1  ) then begin
            jintegration[num] = 0
        endif

        widget_control,info.jwst_slope.integration_label[num],set_value = jintegration[num]+1
        info.jwst_slope.integrationNO[num] = jintegration[num]
        if(jintegration[num] ge 0) then begin ; looking at rate int not rate image 
           widget_control,info.jwst_slope.graph_label[num],set_droplist_select=info.jwst_slope.plane[num]+3
        endif
        jwst_msql_moveframe,info,num
        Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info
    end
;_______________________________________________________________________
; clicked on images - update pixel information

   (strmid(event_name,0,6) EQ 'spixel') : begin

       if(event.type eq 1) then begin
           graphnum = fix(strmid(event_name,6,1))
           ; set the zoom plane number
           info.jwst_slope.plane[2] = info.jwst_slope.plane[graphnum-1]
           print,'jwst_msql_event',info.jwst_slope.plane[2]

           xvalue = event.x     ; starts at 0
           yvalue = event.y     ; starts at 0
; did not click on zoom image- so update the zoom image
           if(graphnum ne 3) then  begin 
               info.jwst_slope.zoom_window = graphnum
               info.jwst_slope.x_zoom = xvalue * info.jwst_slope.binfactor
               info.jwst_slope.y_zoom = yvalue * info.jwst_slope.binfactor
               jwst_msql_update_zoom_image,info

               info.jwst_slope.x_pos = xvalue 
               info.jwst_slope.y_pos = yvalue 
           endif

; clicked on the zoom image - so update the pixel in the zoom image 
           if(graphnum eq 3) then  begin
               x = (xvalue)/info.jwst_slope.scale_zoom
               y = (yvalue)/info.jwst_slope.scale_zoom
               if(x gt info.jwst_data.slope_xsize) then x = info.jwst_data.slope_xsize-1
               if(y gt info.jwst_data.slope_ysize) then y = info.jwst_data.slope_ysize-1
               xvalue = x * info.jwst_slope.scale_zoom
               yvalue = y * info.jwst_slope.scale_zoom
               jwst_msql_update_zoom_pixel_location,xvalue,yvalue,info

               ; redefine the center of the zoom image - if later
               ; want to zoom 

               x = (xvalue)/info.jwst_slope.scale_zoom
               y = (yvalue)/info.jwst_slope.scale_zoom
               x = x + info.jwst_slope.x_zoom_start - info.jwst_slope.ixstart_zoom
               y = y + info.jwst_slope.y_zoom_start - info.jwst_slope.iystart_zoom

               if(x gt info.jwst_data.slope_xsize) then x = info.jwst_data.slope_xsize-1
               if(y gt info.jwst_data.slope_ysize) then y = info.jwst_data.slope_ysize-1

               info.jwst_slope.x_zoom_pos = x
               info.jwst_slope.y_zoom_pos = y

            endif

; update the pixel locations in graphs 1, 2
           for i = 0,1 do begin 
               info.jwst_slope.current_graph = i
               jwst_msql_update_pixel_location,info
           endfor

           ; set current graph to the one clicked on
           if(graphnum eq 1) then info.jwst_slope.current_graph = 0
           if(graphnum eq 2) then info.jwst_slope.current_graph = 1
           
           jwst_msql_update_pixel_stat_slope,info
	   x = info.jwst_slope.x_pos * info.jwst_slope.binfactor	
	   y = info.jwst_slope.y_pos * info.jwst_slope.binfactor	
	   widget_control,info.jwst_slope.pix_label[0],set_value = x+1
	   widget_control,info.jwst_slope.pix_label[1],set_value = y+1

           
; Draw a box around the pixel - showing the zoom window size 
           if(info.jwst_slope.zoom_window ne 3) then  begin ;
               jwst_msql_draw_zoom_box,info
           endif

; load individual ramp graph - based on x_pos, y_pos
           x = info.jwst_slope.x_pos * info.jwst_slope.binfactor	
           y = info.jwst_slope.y_pos * info.jwst_slope.binfactor

           jwst_msql_read_slopedata,x,y,info
           jwst_msql_update_slopepixel,info
           Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info
       endif
   end
;_______________________________________________________________________
   
   (strmid(event_name,0,8) EQ 'getframe') : begin
	x = info.jwst_slope.x_pos * info.jwst_slope.binfactor
	y = info.jwst_slope.y_pos * info.jwst_slope.binfactor

        ; check and see if read in all frame values for pixel
        ; if not then read in

        pixeldata = (*info.jwst_slope.pixeldata)

        size_data = size(pixeldata)
        if(size_data[0] eq 0) then return

        info.jwst_image_pixel.nints = info.jwst_data.nints
        info.jwst_image_pixel.slope = (*info.jwst_data.pslopedata)[x,y,0]

        info.jwst_image_pixel.uncertainty =  (*info.jwst_data.pslopedata)[x,y,1]
        info.jwst_image_pixel.quality_flag =  (*info.jwst_data.pslopedata)[x,y,2]

        info.jwst_image_pixel.filename = info.jwst_control.filename_slope

	display_frame_values,x,y,info,0
    end
;_______________________________________________________________________
    (strmid(event_name,0,8) EQ 'datainfo') : begin
       jwst_dqflags,info
    end
;_______________________________________________________________________
; scaling images
;_______________________________________________________________________
    (strmid(event_name,0,5) EQ 'scale') : begin

        graphno = fix(strmid(event_name,5,1))
        if(info.jwst_slope.default_scale_graph[graphno-1] eq 0 ) then begin ; true - turn to false
            widget_control,info.jwst_slope.image_recomputeID[graphno-1],set_value=' Image Scale '
            info.jwst_slope.default_scale_graph[graphno-1] = 1
        endif

	if(graphno eq 1)then  $
        jwst_msql_update_slope,info.jwst_slope.plane[0],0,info
	if(graphno eq 2)then  $
        jwst_msql_update_slope,info.jwst_slope.plane[1],1,info
	if(graphno eq 3)then  $
        jwst_msql_update_zoom_image,info

        Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info
    end

;_______________________________________________________________________
; change range of image graphs
; if change range then also change the scale button to 'Default Set
; Scale'
;_______________________________________________________________________
    (strmid(event_name,0,2) EQ 'cr') : begin
        graph_num = fix(strmid(event_name,2,1))
        
        if(strmid(event_name,4,1) EQ 'b') then begin ;bottom
            info.jwst_slope.graph_range[graph_num-1,0] = event.value
            widget_control,info.jwst_slope.rlabelID[graph_num-1,1],get_value = temp
            info.jwst_slope.graph_range[graph_num-1,1] = temp
        endif
        if(strmid(event_name,4,1) EQ 't') then begin ;top
            info.jwst_slope.graph_range[graph_num-1,1] = event.value
            widget_control,info.jwst_slope.rlabelID[graph_num-1,0],get_value = temp
            info.jwst_slope.graph_range[graph_num-1,0] = temp
        endif
                        
        info.jwst_slope.default_scale_graph[graph_num-1] = 0
        widget_control,info.jwst_slope.image_recomputeID[graph_num-1],set_value='Default Scale'

	if(graph_num eq 1) then $
          jwst_msql_update_slope,info.jwst_slope.plane[0],0,info
	if(graph_num eq 2) then $
          jwst_msql_update_slope,info.jwst_slope.plane[1],1,info
	if(graph_num eq 3) then $
          jwst_msql_update_zoom_image,info

        Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info
    end

;_______________________________________________________________________
;  Change the Zoom level for window 2
;_______________________________________________________________________

    (strmid(event_name,0,5) EQ 'zsize') : begin
        zsize = fix(strmid(event_name,5,1))
        if(zsize eq 1) then info.jwst_slope.scale_zoom= 1.0
        if(zsize eq 2) then info.jwst_slope.scale_zoom = 2.0
        if(zsize eq 3) then info.jwst_slope.scale_zoom = 4.0
        if(zsize eq 4) then info.jwst_slope.scale_zoom = 8.0
        if(zsize eq 5) then info.jwst_slope.scale_zoom = 16.0
        if(zsize eq 6) then info.jwst_slope.scale_zoom = 32.0
        info.jwst_slope.x_zoom = info.jwst_slope.x_zoom_pos
        info.jwst_slope.y_zoom = info.jwst_slope.y_zoom_pos
        jwst_msql_update_zoom_image,info
    
; redraw box

        if(info.jwst_slope.current_graph eq 0) then jwst_msql_update_slope,info.jwst_slope.plane[0],0,info
        if(info.jwst_slope.current_graph eq 1) then jwst_msql_update_slope,info.jwst_slope.plane[1],1,info

        jwst_msql_draw_zoom_box,info

        widget_control,event.top,Set_UValue = ginfo
        Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info    
    end

;_______________________________________________________________________

;_______________________________________________________________________

; Change automatically reading pixels values and plotting ramp data
;_______________________________________________________________________

    (strmid(event_name,0,4) EQ 'auto') : begin
        if(event.index eq 0) then begin
            info.jwst_slope.autopixelupdate = 1
            widget_control,info.jwst_slope.updatingID, set_value = 'Click on a pixel to plot ramp'
        endif

        if(event.index ne 0) then begin
            info.jwst_slope.autopixelupdate = 0
            widget_control,info.jwst_slope.updatingID, set_value = 'Not updating plot'
        endif
    end
;_______________________________________________________________________
; change x and y range of slope pixel  graph
;_______________________________________________________________________
    (strmid(event_name,0,7) EQ 'slop_mm') : begin
        if(strmid(event_name,7,1) EQ 'x') then graphno = 0 else graphno = 1
        if(strmid(event_name,7,2) EQ 'x1') then begin
            info.jwst_slope.slope_range[0,0]  = event.value
            widget_control,info.jwst_slope.slope_mmlabel[0,1], get_value  = temp
            info.jwst_slope.slope_range[0,1] = temp
        endif
        if(strmid(event_name,7,2) EQ 'x2') then begin
            info.jwst_slope.slope_range[0,1]  = event.value
            widget_control,info.jwst_slope.slope_mmlabel[0,0], get_value  = temp
            info.jwst_slope.slope_range[0,0] = temp
        endif
        if(strmid(event_name,7,2) EQ 'y1') then begin
            info.jwst_slope.slope_range[1,0]  = event.value
            widget_control,info.jwst_slope.slope_mmlabel[1,1], get_value  = temp
            info.jwst_slope.slope_range[1,1] = temp
        endif
        if(strmid(event_name,7,2) EQ 'y2') then begin
            info.jwst_slope.slope_range[1,1]  = event.value
            widget_control,info.jwst_slope.slope_mmlabel[1,0], get_value  = temp
            info.jwst_slope.slope_range[1,0] = temp
        endif


        info.jwst_slope.default_scale_slope[graphno] = 0
        widget_control,info.jwst_slope.slope_recomputeID[graphno],set_value='Default Range'


        jwst_msql_update_slopepixel,info
        Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info
    end

;_______________________________________________________________________
; set the Default range or user defined range for ramp plot
    (strmid(event_name,0,1) EQ 'e') : begin
        graphno = fix(strmid(event_name,1,1))

        if(info.jwst_slope.default_scale_slope[graphno-1] eq 0 ) then begin ; true - turn to false
            widget_control,info.jwst_slope.slope_recomputeID[graphno-1],set_value='   Plot Range '
            info.jwst_slope.default_scale_slope[graphno-1] = 1
        endif

        jwst_msql_update_slopepixel,info
        Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info
    end

;_______________________________________________________________________
; Select a different pixel 
;_______________________________________________________________________
    (strmid(event_name,0,3) EQ 'pix') : begin


        xsize = info.jwst_data.slope_xsize
        ysize = info.jwst_data.slope_ysize
        xvalue = info.jwst_slope.x_pos* info.jwst_slope.binfactor
        yvalue = info.jwst_slope.y_pos* info.jwst_slope.binfactor
        xstart = xvalue
        ystart = yvalue

        pixel_xvalue = xvalue
        pixel_yvalue = yvalue
; ++++++++++++++++++++++++++++++
        if(strmid(event_name,4,1) eq 'x') then  begin
            xvalue = event.value ; event value - user input starts at 1 

            if(xvalue lt 1) then xvalue = 1
            
            if(xvalue gt xsize) then xvalue = xsize

            pixel_xvalue = float(xvalue)-1.0

            ; check what is in y box 
            widget_control,info.jwst_slope.pix_label[1],get_value =  ytemp
            yvalue = ytemp
            if(yvalue lt 1) then yvalue = 1
            
            if(yvalue gt ysize) then yvalue = ysize
          
            pixel_yvalue = float(yvalue)-1


        endif
        if(strmid(event_name,4,1) eq 'y') then begin
            yvalue = event.value ; event value - user input starts at 1
            if(yvalue lt 1) then yvalue = 1
            if(yvalue gt ysize) then yvalue = ysize
            
            pixel_yvalue = float(yvalue)-1

            ; check what is in x box 
            widget_control,info.jwst_slope.pix_label[0], get_value= xtemp
            xvalue = xtemp
            if(xvalue lt 1) then xvalue = 1
            
            if(xvalue gt xsize) then xvalue = xsize
           
            pixel_xvalue = float(xvalue)-1.0
        endif

; check if the <> buttons were used

        if(strmid(event_name,4,4) eq 'move') then begin
            if(strmid(event_name,9,2) eq 'x1') then xvalue = xvalue - 1
            if(strmid(event_name,9,2) eq 'x2') then xvalue = xvalue + 1
            if(strmid(event_name,9,2) eq 'y1') then yvalue = yvalue - 1
            if(strmid(event_name,9,2) eq 'y2') then yvalue = yvalue + 1

            if(xvalue le 0) then xvalue = 0
            if(yvalue le 0) then yvalue  = 0
            if(xvalue ge  info.jwst_data.slope_xsize) then xvalue = info.jwst_data.slope_xsize-1
            if(yvalue ge  info.jwst_data.slope_ysize) then yvalue = info.jwst_data.slope_ysize-1

            pixel_xvalue= xvalue
            pixel_yvalue = yvalue

            widget_control,info.jwst_slope.pix_label[0],set_value=pixel_xvalue+1
            widget_control,info.jwst_slope.pix_label[1],set_value=pixel_yvalue+1

        endif
; ++++++++++++++++++++++++++++++

        info.jwst_slope.x_pos = float(pixel_xvalue)/float(info.jwst_slope.binfactor)
        info.jwst_slope.y_pos = float(pixel_yvalue)/float(info.jwst_slope.binfactor)

        jwst_msql_update_pixel_stat_slope,info
        xmove = (pixel_xvalue - xstart)/info.jwst_slope.binfactor
        ymove = (pixel_yvalue - ystart)/info.jwst_slope.binfactor

        current_graph_save = info.jwst_slope.current_graph
        graphno = [0,1]
        for i = 0,1  do begin 
            info.jwst_slope.current_graph = graphno[i]
            jwst_msql_update_pixel_location,info
        endfor
           ; set current graph to the one clicked on
        info.jwst_slope.current_graph = current_graph_save
        
        x = info.jwst_slope.x_pos * info.jwst_slope.binfactor	
        y = info.jwst_slope.y_pos * info.jwst_slope.binfactor

        jwst_msql_read_slopedata,x,y,info
        jwst_msql_update_slopepixel,info

        current_graph_save = info.jwst_slope.current_graph        
; update the pixel in the zoom window
            
        info.jwst_slope.x_zoom = pixel_xvalue
        info.jwst_slope.y_zoom = pixel_yvalue
        jwst_msql_update_zoom_image,info

; Draw a box around the pixel - showing the zoom window size 
           if(info.jwst_slope.zoom_window ne 3) then  begin ;
               jwst_msql_draw_zoom_box,info
           endif
        Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info


; If the Frame values for pixel window is open - update
        if(XRegistered ('mpixel')) then begin
            widget_control,info.jwst_RPixelInfo,/destroy

        endif
        
        Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info
     end
;_______________________________________________________________________
; Change the image displayed 
;_______________________________________________________________________
    (strmid(event_name,0,7) EQ 'voption') : begin
       plane = event.index
       if(plane ge 3) then plane = plane -3

        graphnum = fix(strmid(event_name,7,1))
        if(graphnum eq 1) then begin 
           value = event.index
           if (value le 2) then begin
              this_int = -1
           endif else begin
              this_int = info.jwst_slope.integrationNo[0]
              if(this_int eq -1) then this_int = 0
           endelse
           info.jwst_slope.plane[0] = plane
           if(this_int ne info.jwst_slope.integrationNo[0]) then begin
              info.jwst_slope.integrationNO[0] = this_int   
              jwst_msql_moveframe,info,0
           endif else begin     ; just update the image 
              info.jwst_slope.default_scale_graph[0] = 1
              jwst_msql_update_slope,info.jwst_slope.plane[0],0,info
           endelse
           
           if(info.jwst_slope.zoom_window eq 1) then  begin
              info.jwst_slope.plane[2] = plane
              jwst_msql_update_zoom_image,info
           endif
 
        endif

        if(graphnum eq 2) then begin
           value = event.index
           if (value le 2) then begin
              this_int = -1
           endif else begin
              this_int = info.jwst_slope.integrationNo[1]
              if(this_int eq -1) then this_int = 0
           endelse
           info.jwst_slope.plane[1] = plane
           if(this_int ne info.jwst_slope.integrationNo[1]) then begin
              info.jwst_slope.integrationNO[1] = this_int
              jwst_msql_moveframe,info,1
           endif else begin     ; just update the image 
              info.jwst_slope.default_scale_graph[1] = 1
              jwst_msql_update_slope,info.jwst_slope.plane[1],1,info
           endelse
           if(info.jwst_slope.zoom_window eq 2) then begin
              info.jwst_slope.plane[2] = plane
              jwst_msql_update_zoom_image,info
           endif
        endif

        Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info

        jwst_msql_update_pixel_stat_slope,info
    end

; ----------------------------------------------------------------------
else: print,' jwst_msql_event: Event name not found: ',event_name
endcase
Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info
end
