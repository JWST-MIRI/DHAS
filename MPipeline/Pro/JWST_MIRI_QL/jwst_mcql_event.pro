pro jwst_mcql_event,event
Widget_Control,event.id,Get_uValue=event_name
widget_control,event.top, Get_UValue = ginfo	
widget_control,ginfo.info.jwst_QuickLook,Get_Uvalue = info

if (widget_info(event.id,/TLB_SIZE_EVENTS) eq 1 ) then begin
    info.jwst_cal.xwindowsize = event.x
    info.jwst_cal.ywindowsize = event.y
    info.jwst_cal.uwindowsize = 1
    widget_control,event.top,set_uvalue = ginfo
    widget_control,ginfo.info.jwst_Quicklook,set_uvalue = info
    jwst_mcql_display_images,info
    return
endif

case 1 of
;_______________________________________________________________________
; Display statistics on the image 
;_______________________________________________________________________
    (strmid(event_name,0,4) EQ 'Stat') : begin
	jwst_mcql_display_stat,info
        Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info
    end
;_______________________________________________________________________
; slope header
    (strmid(event_name,0,7) EQ 'sheader') : begin
       if(info.jwst_control.file_slope_exist eq 0) then begin
          ok = dialog_message(" No rate file  exists",/Information)
       endif else begin
          jwst_display_header,info,1
       endelse
     end

; calibrated header 
    (strmid(event_name,0,7) EQ 'cheader') : begin
       jwst_display_header,info,0
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
        type = fix(strmid(event_name,8,1))
	if(type eq 1) then begin 
           if( info.jwst_cal.data_type[0]) eq 3 then begin 
              frame_image = (*info.jwst_data.pcal1)
           endif

           if( info.jwst_cal.data_type[0]) eq 1 then begin 
              frame_image = (*info.jwst_data.pcal2)
           endif
            if ptr_valid (info.jwst_inspect_cal1.pdata) then ptr_free,info.jwst_inspect_cal1.pdata
            info.jwst_inspect_cal1.pdata = ptr_new(frame_image)
            frame_image = 0 
 
            Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info
            info.jwst_inspect_cal1.plane = info.jwst_cal.plane[0]
            info.jwst_inspect_cal1.zoom = 1
            info.jwst_inspect_cal1.zoom_x = 1
            info.jwst_inspect_cal1.x_pos =(info.jwst_data.slope_xsize)/2.0
            info.jwst_inspect_cal1.y_pos = (info.jwst_data.slope_ysize)/2.0
            
            info.jwst_inspect_cal1.xposful = info.jwst_inspect_cal1.x_pos
            info.jwst_inspect_cal1.yposful = info.jwst_inspect_cal1.y_pos

            info.jwst_inspect_cal1.limit_low = -5000.0
            info.jwst_inspect_cal1.limit_high = 70000.0
            if(info.jwst_inspect_cal1.plane eq 2) then  info.jwst_inspect_cal1.limit_high = ulong64(2.0^30)
            info.jwst_inspect_cal1.limit_low_num = 0
            info.jwst_inspect_cal1.limit_high_num = 0
            info.jwst_inspect_cal1.data_type = info.jwst_cal.data_type[0]
            info.jwst_inspect_cal1.graph_range[0] = info.jwst_cal.graph_range[0,0]
            info.jwst_inspect_cal1.graph_range[1] = info.jwst_cal.graph_range[0,1]
            info.jwst_inspect_cal1.default_scale_graph = info.jwst_cal.default_scale_graph[0]
            jwst_micalql_display_images,info
            Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info

        endif
	if(type eq 2) then  begin
           if( info.jwst_cal.data_type[1]) eq 3 then begin 
              frame_image = (*info.jwst_data.pcal1)
           endif
           if( info.jwst_cal.data_type[1]) eq 1 then begin 
              frame_image = (*info.jwst_data.pcal2)
           endif
            if ptr_valid (info.jwst_inspect_cal2.pdata) then ptr_free,info.jwst_inspect_cal2.pdata
            info.jwst_inspect_cal2.pdata = ptr_new(frame_image)
            all_data = 0

            info.jwst_inspect_cal2.plane = info.jwst_cal.plane[1]
            info.jwst_inspect_cal2.zoom = 1
            info.jwst_inspect_cal2.zoom_x = 1
            info.jwst_inspect_cal2.x_pos =(info.jwst_data.slope_xsize)/2.0
            info.jwst_inspect_cal2.y_pos = (info.jwst_data.slope_ysize)/2.0

            info.jwst_inspect_cal2.xposful = info.jwst_inspect_cal2.x_pos
            info.jwst_inspect_cal2.yposful = info.jwst_inspect_cal2.y_pos

            info.jwst_inspect_cal2.limit_low = -5000.0
            info.jwst_inspect_cal2.limit_high = 70000.0
            if(info.jwst_inspect_cal2.plane eq 2) then  info.jwst_inspect_cal2.limit_high = ulong64(2.0^30)
            info.jwst_inspect_cal2.limit_low_num = 0
            info.jwst_inspect_cal2.limit_high_num = 0
            info.jwst_inspect_cal2.graph_range[0] = info.jwst_cal.graph_range[2,0]
            info.jwst_inspect_cal2.graph_range[1] = info.jwst_cal.graph_range[2,1]
            info.jwst_inspect_cal2.default_scale_graph = info.jwst_cal.default_scale_graph[2]
            info.jwst_inspect_cal2.data_type = info.jwst_cal.data_type[1]

            Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info
            jwst_micalql2_display_images,info
        endif
        Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info
    end

;_______________________________________________________________________
; clicked on images - update pixel information

   (strmid(event_name,0,6) EQ 'spixel') : begin
       if(event.type eq 1) then begin
          graphnum = fix(strmid(event_name,6,1))
           ; set the zoom plane number
           info.jwst_cal.plane[2] = info.jwst_cal.plane[graphnum-1]

           xvalue = event.x     ; starts at 0
           yvalue = event.y     ; starts at 0
; did not click on zoom image- so update the zoom image
           if(graphnum ne 3) then  begin 
               info.jwst_cal.zoom_window = graphnum
               info.jwst_cal.x_zoom = xvalue * info.jwst_cal.binfactor
               info.jwst_cal.y_zoom = yvalue * info.jwst_cal.binfactor
               jwst_mcql_update_zoom_image,info
               
               info.jwst_cal.x_pos = xvalue 
               info.jwst_cal.y_pos = yvalue
           endif

; clicked on the zoom image - so update the pixel in the zoom image 
           if(graphnum eq 3) then  begin
               x = (xvalue)/info.jwst_cal.scale_zoom
               y = (yvalue)/info.jwst_cal.scale_zoom
               if(x gt info.jwst_data.slope_xsize) then x = info.jwst_data.slope_xsize-1
               if(y gt info.jwst_data.slope_ysize) then y = info.jwst_data.slope_ysize-1
               xvalue = x * info.jwst_cal.scale_zoom
               yvalue = y * info.jwst_cal.scale_zoom
               jwst_mcql_update_zoom_pixel_location,xvalue,yvalue,info

               ; redefine the center of the zoom image - if later
               ; want to zoom 

               x = (xvalue)/info.jwst_cal.scale_zoom
               y = (yvalue)/info.jwst_cal.scale_zoom
               x = x + info.jwst_cal.x_zoom_start - info.jwst_cal.ixstart_zoom
               y = y + info.jwst_cal.y_zoom_start - info.jwst_cal.iystart_zoom

               if(x gt info.jwst_data.slope_xsize) then x = info.jwst_data.slope_xsize-1
               if(y gt info.jwst_data.slope_ysize) then y = info.jwst_data.slope_ysize-1

               info.jwst_cal.x_zoom_pos = x
               info.jwst_cal.y_zoom_pos = y

            endif

; update the pixel locations in graphs 1, 2
           for i = 0,1 do begin
               info.jwst_cal.current_graph = i
               jwst_mcql_update_pixel_location,info
           endfor

           ; set current graph to the one clicked on
           if(graphnum eq 1) then info.jwst_cal.current_graph = 0
           if(graphnum eq 2) then info.jwst_cal.current_graph = 1

           jwst_mcql_update_pixel_stat,info
	   x = info.jwst_cal.x_pos * info.jwst_cal.binfactor	
	   y = info.jwst_cal.y_pos * info.jwst_cal.binfactor	
	   widget_control,info.jwst_cal.pix_label[0],set_value = x+1
	   widget_control,info.jwst_cal.pix_label[1],set_value = y+1
           
; Draw a box around the pixel - showing the zoom window size 
           if(info.jwst_cal.zoom_window ne 3) then  begin ;
               jwst_mcql_draw_zoom_box,info
           endif

           Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info
       endif
   end
;_______________________________________________________________________
   
   (strmid(event_name,0,8) EQ 'getframe') : begin
	x = info.jwst_cal.x_pos * info.jwst_cal.binfactor
	y = info.jwst_cal.y_pos * info.jwst_cal.binfactor

        ; check and see if read in all frame values for pixel
        ; if not then read in

        pixeldata = (*info.jwst_cal.pixeldata)

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
        if(info.jwst_cal.default_scale_graph[graphno-1] eq 0 ) then begin ; true - turn to false
            widget_control,info.jwst_cal.image_recomputeID[graphno-1],set_value=' Image Scale '
            info.jwst_cal.default_scale_graph[graphno-1] = 1
        endif

	if(graphno eq 1)then  $
        jwst_mcql_update_images,0,info
	if(graphno eq 2)then  $
        jwst_mcql_update_images,1,info
	if(graphno eq 3)then  $
        jwst_mcql_update_zoom_image,info
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
            info.jwst_cal.graph_range[graph_num-1,0] = event.value
            widget_control,info.jwst_cal.rlabelID[graph_num-1,1],get_value = temp
            info.jwst_cal.graph_range[graph_num-1,1] = temp
        endif
        if(strmid(event_name,4,1) EQ 't') then begin ;top
            info.jwst_cal.graph_range[graph_num-1,1] = event.value
            widget_control,info.jwst_cal.rlabelID[graph_num-1,0],get_value = temp
            info.jwst_cal.graph_range[graph_num-1,0] = temp
        endif
                        
        info.jwst_cal.default_scale_graph[graph_num-1] = 0
        widget_control,info.jwst_cal.image_recomputeID[graph_num-1],set_value='Default Scale'

	if(graph_num eq 1) then $
          jwst_mcql_update_images,0,info
	if(graph_num eq 2) then $
          jwst_mcql_update_images,1,info
	if(graph_num eq 3) then $
          jwst_mcql_update_zoom_image,info

        Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info
    end

;_______________________________________________________________________
;  Change the Zoom level for window 2
;_______________________________________________________________________

    (strmid(event_name,0,5) EQ 'zsize') : begin
        zsize = fix(strmid(event_name,5,1))
        if(zsize eq 1) then info.jwst_cal.scale_zoom= 1.0
        if(zsize eq 2) then info.jwst_cal.scale_zoom = 2.0
        if(zsize eq 3) then info.jwst_cal.scale_zoom = 4.0
        if(zsize eq 4) then info.jwst_cal.scale_zoom = 8.0
        if(zsize eq 5) then info.jwst_cal.scale_zoom = 16.0
        if(zsize eq 6) then info.jwst_cal.scale_zoom = 32.0
        info.jwst_cal.x_zoom = info.jwst_cal.x_zoom_pos
        info.jwst_cal.y_zoom = info.jwst_cal.y_zoom_pos
        jwst_mcql_update_zoom_image,info
    
; redraw box

        if(info.jwst_cal.current_graph eq 0) then jwst_mcql_update_images,0,info
        if(info.jwst_cal.current_graph eq 1) then jwst_mcql_update_images,1,info

        jwst_mcql_draw_zoom_box,info

        widget_control,event.top,Set_UValue = ginfo
        Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info    
    end


;_______________________________________________________________________
; Select a different pixel 
;_______________________________________________________________________
    (strmid(event_name,0,3) EQ 'pix') : begin
        xsize = info.jwst_data.slope_xsize
        ysize = info.jwst_data.slope_ysize
        xvalue = info.jwst_cal.x_pos* info.jwst_cal.binfactor
        yvalue = info.jwst_cal.y_pos* info.jwst_cal.binfactor
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
            widget_control,info.jwst_cal.pix_label[1],get_value =  ytemp
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
            widget_control,info.jwst_cal.pix_label[0], get_value= xtemp
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

            widget_control,info.jwst_cal.pix_label[0],set_value=pixel_xvalue+1
            widget_control,info.jwst_cal.pix_label[1],set_value=pixel_yvalue+1

        endif
; ++++++++++++++++++++++++++++++

        info.jwst_cal.x_pos = float(pixel_xvalue)/float(info.jwst_cal.binfactor)
        info.jwst_cal.y_pos = float(pixel_yvalue)/float(info.jwst_cal.binfactor)


        xmove = (pixel_xvalue - xstart)/info.jwst_cal.binfactor
        ymove = (pixel_yvalue - ystart)/info.jwst_cal.binfactor

        current_graph_save = info.jwst_cal.current_graph
        graphno = [0,1]
        for i = 0,1  do begin 
            info.jwst_cal.current_graph = graphno[i]
            jwst_mcql_update_pixel_location,info
        endfor
           ; set current graph to the one clicked on
        info.jwst_cal.current_graph = current_graph_save
        
        x = info.jwst_cal.x_pos * info.jwst_cal.binfactor	
        y = info.jwst_cal.y_pos * info.jwst_cal.binfactor


        current_graph_save = info.jwst_cal.current_graph        
; update the pixel in the zoom window
            
        info.jwst_cal.x_zoom = pixel_xvalue
        info.jwst_cal.y_zoom = pixel_yvalue
        jwst_mcql_update_zoom_image,info

; Draw a box around the pixel - showing the zoom window size 
           if(info.jwst_cal.zoom_window ne 3) then  begin ;
               jwst_mcql_draw_zoom_box,info
           endif
        Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info

; If the Frame values for pixel window is open - update
        if(XRegistered ('mpixel')) then begin
            widget_control,info.jwst_RPixelInfo,/destroy
        endif
        jwst_mcql_update_pixel_stat,info        
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
             info.jwst_cal.data_type[0] = 3
          endif else begin
             info.jwst_cal.data_type[0] = 1
          endelse
          info.jwst_cal.plane[0] = plane
          info.jwst_cal.default_scale_graph[0] = 1

          if(info.jwst_cal.data_type[0] eq 3) then begin 
             stat = info.jwst_data.cal1_stat[*,plane]
          endif
          if(info.jwst_cal.data_type[0] eq 1) then begin 
             stat = info.jwst_data.cal2_stat[*,plane]
          endif

          info.jwst_cal.graph_range[0,0] = stat[5]
          info.jwst_cal.graph_range[0,1] = stat[6]
          jwst_mcql_update_images,0,info
       
          if(info.jwst_cal.zoom_window eq 1) then  begin
             info.jwst_cal.plane[2] = plane
             jwst_mcql_update_zoom_image,info
          endif
       endif

        if(graphnum eq 2) then begin
           value = event.index
           if (value le 2) then begin
              info.jwst_cal.data_type[1] = 3
           endif else begin
              info.jwst_cal.data_type[1] = 1
           endelse
           info.jwst_cal.plane[1] = plane

           info.jwst_cal.default_scale_graph[1] = 1
           if(info.jwst_cal.data_type[1] eq 3) then begin 
              stat = info.jwst_data.cal1_stat[*,plane]
          endif
           if(info.jwst_cal.data_type[1] eq 1) then begin 
              stat = info.jwst_data.cal2_stat[*,plane]
           endif

           info.jwst_cal.graph_range[1,0] = stat[5]
           info.jwst_cal.graph_range[1,1] = stat[6]
           jwst_mcql_update_images,1,info
           if(info.jwst_cal.zoom_window eq 2) then begin
              info.jwst_cal.plane[2] = plane
              jwst_mcql_update_zoom_image,info
           endif
        endif
        jwst_mcql_update_pixel_stat,info
        Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info
    end

; ----------------------------------------------------------------------
else: print,' jwst_mcql_event: Event name not found: ',event_name
endcase
Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info
end
