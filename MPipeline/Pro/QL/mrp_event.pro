; the event manager for the mrp_display.pro = Border reference pixels

pro mrp_event,event

Widget_Control,event.id,Get_uValue=event_name
widget_control,event.top, Get_UValue = ginfo
widget_control,ginfo.info.QuickLook,Get_Uvalue = info

iramp = info.refp.rampNO
jintegration = info.refp.integrationNO

if (widget_info(event.id,/TLB_SIZE_EVENTS) eq 1 ) then begin

    info.refp.xwindowsize = event.x
    info.refp.ywindowsize = event.y
    info.refp.uwindowsize = 1
    widget_control,event.top,set_uvalue = ginfo
    widget_control,ginfo.info.Quicklook,set_uvalue = info
    mrp_display,info

    return
endif



;    print,'event_name',event_name
    case 1 of

;_______________________________________________________________________
; Change the Integration # or Frame # of image displayed
;_______________________________________________________________________
    (strmid(event_name,0,6) EQ 'integr') : begin

	if (strmid(event_name,6,1) EQ 'a') then begin 
           this_value = event.value-1
           jintegration = this_value
	endif

; check if the <> buttons were used
       if (strmid(event_name,6,5) EQ '_move')then begin
          if(strmid(event_name,12,2) eq 'dn') then begin
             jintegration = jintegration -1
          endif
          if(strmid(event_name,12,2) eq 'up') then begin
             jintegration = jintegration+1
          endif
       endif

; do some checks 
       if(jintegration lt 0) then jintegrationNO = info.data.nints-1
       if(jintegration gt info.data.nints-1  ) then jintegration = 0


        move = 0
        if(jintegration ne info.refp.integrationNO) then move = 1

        if(move eq 1) then begin
            info.refp.integrationNO = jintegration
            mrp_setup_channel,info
            mrp_update_refpixel,info
            mrp_update_zoom_image,info
            
            mrp_update_row_info,info
            mrp_draw_zoom_box,info
            
            mrp_update_TimeChannel,info
            widget_control,info.refp.integration_label, set_value = jintegration+1
        endif

       Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end

;_______________________________________________________________________
;  Frame Button
    (strmid(event_name,0,4) EQ 'fram') : begin

	if (strmid(event_name,4,1) EQ 'e') then begin 	
           this_value = event.value-1
           iramp = this_value

	endif
; check if the <> buttons were used
        if (strmid(event_name,4,5) EQ '_move')then begin

            if(strmid(event_name,10,2) eq 'dn') then begin
              iramp = iramp -1
            endif
            if(strmid(event_name,10,2) eq 'up') then begin
              iramp = iramp +1
            endif
	endif
; do some checks	

        if(iramp lt 0) then  iramp = info.data.nramps-1
        if(iramp gt info.data.nramps-1  ) then iramp = 0


        move = 0
        if(iramp ne info.refp.rampNO) then move = 1

        if(move eq 1 ) then begin 
            info.refp.rampNO= iramp
            
            mrp_setup_channel,info
            mrp_update_refpixel,info
            mrp_update_zoom_image,info

            mrp_update_row_info,info
            mrp_draw_zoom_box,info
            
            mrp_update_TimeChannel,info
            widget_control,info.refp.frame_label, set_value = iramp+1
        endif

        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end	

;_______________________________________________________________________
; Select a different row
;_______________________________________________________________________
    (strmid(event_name,0,3) EQ 'row') : begin
        if(strmid(event_name,4,1) eq 'v') then  begin
            row = event.value ; event value - user input starts at 1 

            if(row lt 1) then row= 1
            if(row gt info.data.image_ysize) then row = info.data.image_ysize
            row_value = float(row)-1.0
        endif

; check if the <> buttons were used

        if(strmid(event_name,4,4) eq 'move') then begin
	    row = info.refp.row
;            print,'old row',row
            if(strmid(event_name,9,1) eq '1') then row = row - 1
            if(strmid(event_name,9,1) eq '2') then row = row + 1

            if(row le 0) then row = 0
            if(row ge  info.data.image_ysize) then row = info.data.image_ysize-1
	     row_value = row
            widget_control,info.refp.row_label,set_value=row_value+1
;            print,'new row',row_value
        endif

; ++++++++++++++++++++++++++++++
        info.refp.row = row_value
;        print,info.refp.row

        mrp_update_row_info,info
        mrp_update_pixel_location,20,info.refp.row,info
	mrp_update_zoom_image,info
        if(info.refp.draw_box eq 1) then mrp_draw_zoom_box,info
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end


;_______________________________________________________________________
; change range of image graphs
; if change range then also change the scale button to 'User Set
; Scale'
;_______________________________________________________________________
    (strmid(event_name,0,2) EQ 'sr') : begin
        graph_num = fix(strmid(event_name,2,1))-1
        
        if(strmid(event_name,4,1) EQ 'b') then mm_val = 0 else mm_val = 1 ; b for min, t for max
        info.refp.graph_range[graph_num,mm_val] = event.value
        info.refp.default_scale_graph[graph_num] = 0
        widget_control,info.refp.image_recomputeID[graph_num],set_value=' Default '

        if(graph_num eq 0) then mrp_update_refpixel,info
        if(graph_num eq 1) then mrp_update_zoom_image,info
    end

;_______________________________________________________________________
; scaling image and slope
;_______________________________________________________________________
    (strmid(event_name,0,5) EQ 'scale') : begin

        graphno = fix(strmid(event_name,5,1))
        if(info.refp.default_scale_graph[graphno-1] eq 0 ) then begin 
            widget_control,info.refp.image_recomputeID[graphno-1],set_value=' Image Scale'
            info.refp.default_scale_graph[graphno-1] = 1
        endif

	if(graphno eq 1)then  mrp_update_refpixel,info
	if(graphno eq 2)then  mrp_update_zoom_image,info
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end
;_______________________________________________________________________
; change range of image graphs
; if change range then also change the scale button to 'User Set
; Scale'
;_______________________________________________________________________
    (strmid(event_name,0,2) EQ 'sr') : begin
        graph_num = fix(strmid(event_name,2,1))
        if(strmid(event_name,4,1) EQ 'b')then mm_val = 0 else mm_val = 1 ; b for min, t for max
        info.refp.graph_range[graph_num-1,mm_val] = event.value
        info.refp.default_scale_graph[graph_num-1] = 0
        widget_control,info.refp.image_recomputeID[graph_num-1],set_value=' Default '

	if(graph_num eq 1) then mrp_update_refpixel,info
	if(graph_num eq 2) then mrp_update_zoom_image,info
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end

;_______________________________________________________________________
    (strmid(event_name,0,4) EQ 'draw') : begin
        if(info.refp.draw_box eq 1 ) then begin ; true - turn to false
            widget_control,info.refp.zboxID,set_value='Do not Draw Box'
            info.refp.draw_box = 0
        endif else begin        ;false then turn true
            widget_control,info.refp.zboxID,set_value='Draw Box'
            info.refp.draw_box = 1
        endelse

        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end


;_______________________________________________________________________
; Select a different pixel to report the values of
; event is generated for button pushing down and button release.
; only need this called once
;_______________________________________________________________________
   (strmid(event_name,0,6) EQ 'npixel') : begin
       if(event.type eq 1) then begin
           graphnum = fix(strmid(event_name,6,1))
           xvalue = event.x     ; starts at 0
           yvalue = event.y     ; starts at 0

; clicked on full image - so update the zoom image
           if(graphnum eq 1) then  begin 
	       info.refp.row = yvalue
               widget_control,info.refp.row_label,set_value=yvalue+1
               mrp_update_row_info,info

               mrp_update_pixel_location,20,info.refp.row,info
	       mrp_update_zoom_image,info
               if(info.refp.draw_box eq 1) then mrp_draw_zoom_box,info
           endif


; clicked on the zoom image - so update the pixel in the zoom image 
           if(graphnum eq 2) then  begin

	       zoom_channel = fix(xvalue/25)+1
	       if(zoom_channel gt 7) then zoom_channel = zoom_channel - 7

	       zoom_row = fix(yvalue/25) + info.refp.zoom_start
	       
	       info.refp.zoom_channel = zoom_channel
	       info.refp.row = zoom_row
	       info.refp.zoom_xpixel = xvalue
	       info.refp.zoom_ypixel = yvalue

               widget_control,info.refp.row_label,set_value=info.refp.row+1
               mrp_update_row_info,info
               mrp_update_zoom_pixel_location,info
	       
               xpos = fix(xvalue/25)
               if(xpos le 3) then xplot= fix( (xpos) *4) + 1.5
               if(xpos ge 4 and xpos le 6) then xplot = 20
               if(xpos ge 7) then xplot= fix( (xpos-1) *4) + 1.5
               
               mrp_update_pixel_location,xplot,info.refp.row,info
               if(info.refp.draw_box eq 1) then mrp_draw_zoom_box,info
           endif

           Widget_Control,ginfo.info.QuickLook,Set_UValue=info
       endif
   end
   

;_______________________________________________________________________
; type of data to plot
;_______________________________________________________________________
    (strmid(event_name,0,4) EQ 'trow') : begin
        idata=  strmid(event_name,4,1) 
	if(idata eq 'a') then begin 	
	    info.refp.ploteven = 1
	    info.refp.plotodd = 1
            ploteven = 0
            plotodd = 0
            plotall = 1
	endif

	if(idata eq 'e') then begin 	
	    info.refp.ploteven = 1
	    info.refp.plotodd = 0
            ploteven = 1
            plotodd = 0
            plotall = 0
	endif
	if(idata eq 'o') then begin 	
	    info.refp.ploteven = 0
	    info.refp.plotodd = 1
            ploteven = 0
            plotodd = 1
            plotall = 0
	endif
	


	widget_control,info.refp.evenoddbutton,set_button =  plotall 
	widget_control,info.refp.evenbutton,set_button = ploteven
	widget_control,info.refp.oddbutton,set_button = plotodd

        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
        mrp_update_TimeChannel,info    
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end
;_______________________________________________________________________

    (strmid(event_name,0,5) EQ 'White') : begin

        ii=  strmid(event_name,5,1)
        if(ii eq '1') then begin 
            info.refp.plotWhite = 1
            widget_control,info.refp.overplotWhiteID[0],set_button = 1
            widget_control,info.refp.overplotWhiteID[1],set_button = 0
        endif

        if(ii eq '2') then begin 
            info.refp.plotWhite = 0
            widget_control,info.refp.overplotWhiteID[0],set_button = 0
            widget_control,info.refp.overplotWhiteID[1],set_button = 1
        endif
        mrp_update_TimeChannel,info    
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end

;_______________________________________________________________________


    (strmid(event_name,0,4) EQ 'tcol') : begin

        idata=  strmid(event_name,4,1) 
	if(idata eq 'a') then begin 	
	    info.refp.plotrightleft = 1
	    info.refp.plotright = 0
	    info.refp.plotleft = 0
	endif
	if(idata eq 'l') then begin 	
	    info.refp.plotrightleft = 0
	    info.refp.plotright = 0
	    info.refp.plotleft = 1
	endif
	if(idata eq 'r') then begin 	
	    info.refp.plotrightleft = 0
	    info.refp.plotright = 1
	    info.refp.plotleft = 0
	endif


	widget_control,info.refp.rightleftbutton,set_button =  info.refp.plotrightleft 
	widget_control,info.refp.rightbutton,set_button = info.refp.plotright
	widget_control,info.refp.leftbutton,set_button =  info.refp.plotleft

        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
        mrp_update_TimeChannel,info    
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end

    
;_______________________________________________________________________
; overplot line through points
;_______________________________________________________________________

    (strmid(event_name,0,4) EQ 'line') : begin

        ii=  strmid(event_name,4,1)
        if(ii eq '1') then begin 
            info.refp.overplotline = 1
            widget_control,info.refp.overplotlineID[0],set_button = 1
            widget_control,info.refp.overplotlineID[1],set_button = 0
        endif

        if(ii eq '2') then begin 
            info.refp.overplotline = 0
            widget_control,info.refp.overplotlineID[0],set_button = 0
            widget_control,info.refp.overplotlineID[1],set_button = 1
        endif
        mrp_update_TimeChannel,info    
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end

;_______________________________________________________________________
;  On Border Reference Pixel Data
;_______________________________________________________________________

    (strmid(event_name,0,4) EQ 'lset') : begin

        ii=  strmid(event_name,4,1)
        if(ii eq '1') then begin 
            info.refp.LeftPixelSetA = 0
            widget_control,info.refp.LeftDataID[0],set_button = 1
            widget_control,info.refp.LeftDataID[1],set_button = 0
        endif

        if(ii eq '2') then begin 
            info.refp.LeftPixelSetA = 1
            widget_control,info.refp.LeftDataID[0],set_button = 0
            widget_control,info.refp.LeftDataID[1],set_button = 1

        endif

        mrp_update_refpixel,info
        mrp_update_row_info,info
        mrp_update_zoom_image,info
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end



;_______________________________________________________________________
;  Time Plot
;_______________________________________________________________________

    (strmid(event_name,0,3) EQ 'set') : begin

        ii=  strmid(event_name,3,1)
        if(ii eq '1') then begin 
            info.refp.LeftPixelSetB = 0
            widget_control,info.refp.LeftPixelsID[0],set_button = 1
            widget_control,info.refp.LeftPixelsID[1],set_button = 0
            widget_control,info.refp.LeftPixelsID[2],set_button = 0
        endif

        if(ii eq '2') then begin 
            info.refp.LeftPixelSetB = 1
            widget_control,info.refp.LeftPixelsID[0],set_button = 0
            widget_control,info.refp.LeftPixelsID[1],set_button = 1
            widget_control,info.refp.LeftPixelsID[2],set_button = 0
        endif

        if(ii eq '3') then begin 
            info.refp.LeftPixelSetB = 2
            widget_control,info.refp.LeftPixelsID[0],set_button = 0
            widget_control,info.refp.LeftPixelsID[1],set_button = 0
            widget_control,info.refp.LeftPixelsID[2],set_button = 1
        endif

        mrp_update_TimeChannel,info
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end
;_______________________________________________________________________
; Print time ordered plot
;_______________________________________________________________________

    (strmid(event_name,0,5) EQ 'print') : begin
        print_reference_pixel_timeordered,info
    end
;_______________________________________________________________________
; change x and y range of Time ordered plot
; if change range then also change the button to 'User Set Scale'
;_______________________________________________________________________
    (strmid(event_name,0,5) EQ 'range') : begin

        num = fix(strmid(event_name,5,1))
        num = num -1

        if(info.refp.time_default_range[num] eq 0 ) then begin 
            widget_control,info.refp.time_recomputeID[num],set_value='Plot Range'
            info.refp.time_default_range[num] = 1
        endif

        mrp_update_TimeChannel,info
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end


    (strmid(event_name,0,2) EQ 'cr') : begin
        widget_control,info.refp.trangeID[0,0],get_value = temp
        test = abs(temp - info.refp.time_range[0,0])
        info.refp.time_range[0,0]= temp
        if(test gt 1) then info.refp.time_default_range[0] = 0

        widget_control,info.refp.trangeID[0,1],get_value = temp
        test = abs(temp - info.refp.time_range[0,1])
        info.refp.time_range[0,1]= temp
        if(test gt 1) then info.refp.time_default_range[0] = 0


        widget_control,info.refp.trangeID[1,0],get_value = temp
        test = abs(temp - info.refp.time_range[1,0])
        info.refp.time_range[1,0]= temp
        if(test gt 1) then info.refp.time_default_range[1] = 0

        widget_control,info.refp.trangeID[1,1],get_value = temp
        test = abs(temp - info.refp.time_range[1,1])
        info.refp.time_range[1,1]= temp
        if(test gt 1) then info.refp.time_default_range[1] = 0
        

        if(info.refp.time_default_range[0] eq 0) then $
          widget_control,info.refp.time_recomputeID[0],set_value=' Default '

        if(info.refp.time_default_range[1] eq 0) then $
          widget_control,info.refp.time_recomputeID[1],set_value=' Default '

        mrp_update_TimeChannel,info
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end

;_______________________________________________________________________
    (strmid(event_name,0,2) EQ 'on') : begin
        num = fix(strmid(event_name,2,1))-1
        info.refp.onvalue[num] = 1
        widget_control, info.refp.offButton[num],Set_Button = 0
        widget_control, info.refp.onButton[num],Set_Button = 1
        mrp_update_TimeChannel,info
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end

    (strmid(event_name,0,3) EQ 'off') : begin
        num = fix(strmid(event_name,3,1))-1
        info.refp.onvalue[num] = 0
        widget_control, info.refp.onButton[num],Set_Button = 0
        widget_control, info.refp.offButton[num],Set_Button = 1
        mrp_update_TimeChannel,info
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end

    (strmid(event_name,0,7) EQ 'allplot') : begin
        type = fix(strmid(event_name,7,1))
        if(type eq 1) then begin
            widget_control, info.refp.noneButton,Set_Button = 0
            for i = 0,3 do begin 
                info.refp.onvalue[i] = 1
                widget_control, info.refp.onButton[i],Set_Button = 1
                widget_control, info.refp.offButton[i],Set_Button = 0
            endfor
        endif
        if(type eq 2) then begin
            widget_control, info.refp.allButton,Set_Button = 0
            for i = 0,3 do begin 
                info.refp.onvalue[i] = 0
                widget_control, info.refp.onButton[i],Set_Button = 0
                widget_control, info.refp.offButton[i],Set_Button = 1
            endfor
        endif
            
        mrp_update_TimeChannel,info
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end
else: print," Event name not found",event_name
endcase
Widget_Control,ginfo.info.QuickLook,Set_UValue=info




end
