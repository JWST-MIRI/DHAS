;***********************************************************************
pro jwst_pixel_RateAmplifier_quit,event
widget_control,event.top, Get_UValue = tinfo
widget_control,tinfo.info.jwst_QuickLook,Get_UValue=info
widget_control,info.jwst_ARPixelInfo,/destroy
end
;_______________________________________________________________________
pro jwst_update_pixel_RateAmplifier_info,info

; xvaule and yvalue start at 0
; jwst_AmpRate_pixel.x(Y)value start at 1
xvalue = info.jwst_AmpRate_pixel.xvalue -1 ; starts at 0
yvalue = info.jwst_AmpRate_pixel.yvalue -1;  starts at 0

widget_control,info.jwst_AmpRate_pixel.pix_label[0],set_value=xvalue+1
widget_control,info.jwst_AmpRate_pixel.pix_label[1],set_value=yvalue+1

if(xvalue lt 0) then xvalue =0
if(yvalue lt 0) then yvalue = 0

value1 = (*info.jwst_AmpRate_image[0].pdata)[xvalue,yvalue]
value2 = (*info.jwst_AmpRate_image[1].pdata)[xvalue,yvalue]
value3 = (*info.jwst_AmpRate_image[2].pdata)[xvalue,yvalue]
value4 = (*info.jwst_AmpRate_image[3].pdata)[xvalue,yvalue]

svalue1 = strcompress(string(value1),/remove_all)
svalue2 = strcompress(string(value2),/remove_all)
svalue3 = strcompress(string(value3),/remove_all)
svalue4 = strcompress(string(value4),/remove_all)

widget_control,info.jwst_AmpRate_pixel.pix_statLabelID[0],set_value=' Amplifier 1 value = '+svalue1
widget_control,info.jwst_AmpRate_pixel.pix_statLabelID[1],set_value=' Amplifier 2 value = '+svalue2
widget_control,info.jwst_AmpRate_pixel.pix_statLabelID[2],set_value=' Amplifier 3 value = '+svalue3
widget_control,info.jwst_AmpRate_pixel.pix_statLabelID[3],set_value=' Amplifier 4 value = '+svalue4

if(info.jwst_data.subarray eq 0) then begin
    if(xvalue eq 0 or xvalue eq 257) then begin
        xvalue = info.jwst_AmpRate_pixel.xpixel_typelabel[1] 

    endif else begin
        xvalue = info.jwst_AmpRate_pixel.xpixel_typelabel[0] 
    endelse
    widget_control,info.jwst_AmpRate_pixel.xpixel_typeID,set_value = xvalue
endif

end
;_______________________________________________________________________
pro jwst_pixel_RateAmplifier_event,event

Widget_Control,event.id,Get_uValue=event_name
widget_control,event.top, Get_UValue = ginfo
widget_control,ginfo.info.jwst_QuickLook,Get_Uvalue = info

    case 1 of
;_______________________________________________________________________

; Select a different pixel to get the ramp read - also update the
; selected pixel location in the 3 image plots
;_______________________________________________________________________
    (strmid(event_name,0,3) EQ 'pix') : begin
; first check if have uvalue = pix_x_value, pix_y_value (user input  pixel value
; ++++++++++++++++++++++++++++++
        xsize = info.jwst_data.slope_xsize/4
        ysize = info.jwst_data.slope_ysize
        xvalue = info.jwst_AmpRate_pixel.xvalue
        yvalue = info.jwst_AmpRate_pixel.yvalue
        xstart = xvalue
        ystart = yvalue
;________________________
; Check if types in new x or y value
;________________________
        if(strmid(event_name,4,1) eq 'x') then  begin
            xvalue = event.value ; event value - user input starts at 1 
        endif
        if(strmid(event_name,4,1) eq 'y') then begin
            yvalue = event.value ; event value - user input starts at 1
        endif
;________________________
; check if the <> buttons were used
;________________________
        if(strmid(event_name,4,4) eq 'move') then begin
            xvalue = info.jwst_AmpRate_pixel.xvalue ;starts at 0
            yvalue = info.jwst_AmpRate_pixel.yvalue ;starts at 0
		xscale= 1
		yscale = 1
            xstep = 1.0/xscale
            ystep = 1.0/yscale

            xstep = 1.0
            ystep = 1.0
            if(strmid(event_name,9,2) eq 'x1') then xvalue = xvalue - xstep
            if(strmid(event_name,9,2) eq 'x2') then xvalue = xvalue + xstep
            if(strmid(event_name,9,2) eq 'y1') then yvalue = yvalue - ystep
            if(strmid(event_name,9,2) eq 'y2') then yvalue = yvalue + ystep

            if(xvalue lt 1) then xvalue = 1
            if(yvalue lt 1) then yvalue = 1

        endif
; ++++++++++++++++++++++++++++++

        if(xvalue lt 1) then xvalue = 1
        if(xvalue gt xsize) then xvalue = xsize
        if(yvalue lt 1) then yvalue = 1
        if(yvalue gt ysize) then yvalue = ysize

        info.jwst_AmpRate_pixel.xvalue = xvalue
        info.jwst_AmpRate_pixel.yvalue = yvalue

        xmove =info.jwst_AmpRate_pixel.xvalue - xstart
        ymove =info.jwst_AmpRate_pixel.yvalue - ystart

        info.jwst_AmpRate.xpos = info.jwst_AmpRate.xpos + xmove*info.jwst_AmpRate.zoom
        info.jwst_AmpRate.ypos = info.jwst_AmpRate.ypos + ymove*info.jwst_AmpRate.zoom

        info.jwst_AmpRate.xposfull = info.jwst_AmpRate_pixel.xvalue -1		
        info.jwst_AmpRate.yposfull = info.jwst_AmpRate_pixel.yvalue -1 
        jwst_update_pixel_RateAmplifier_info,info ; uses jwst_AmpRate_pixel.xvalue
                                           ;      jwst_AmpRate_pixel.yvalue
; ++++++++++++++++++++++++++++++
; update the location of the pixel on the images

        jwst_update_pixel_RateAmplifier_location,info ; uses info.jwst_AmpRate.xpos
                                                 ;      info.jwst_AmpRate.ypos  
    end
else: print," Event name not found ",event_name
endcase
widget_control,event.top, Set_UValue = ginfo
widget_control,ginfo.info.jwst_QuickLook,Set_Uvalue = info
end

;_______________________________________________________________________
; The parameters for this widget are contained in the image_pixel
; structure, rather than a local imbedded structure because
; mql_event.pro also calls to update the pixel info widget

pro jwst_pixel_RateAmplifier_display,xvalue,yvalue,info

window,4
wdelete,4
if(XRegistered ('ARpixel')) then begin
    widget_control,info.jwst_ARPixelInfo,/destroy
endif

;_______________________________________________________________________
;*********
;Setup main panel
;*********

PixelInfo = widget_base(title=" Pixel Information for Rate Amplifier Images",$
                         col = 1,mbar = menuBar,$
                        group_leader = info.jwst_AmpRateDisplay,$
                           xsize = 350,ysize = 400,/align_right)
; build the menubar
;********
QuitMenu = widget_button(menuBar,value="Quit",font = info.font2)
quitbutton = widget_button(quitmenu,value="Quit",event_pro='jwst_pixel_RateAmplifier_quit')

info.jwst_AmpRate_pixel.xvalue = xvalue+1 ; starts at 1
info.jwst_AmpRate_pixel.yvalue = yvalue+1 ; starts at 1

;_______________________________________________________________________
; Pixel Statistics Display
;*********
stitle = "Pixel Information for Slope Amplifier Images"

tlabelID = widget_label(PixelInfo,$
          value=stitle ,/align_left, font=info.font5)
labelID = widget_label(PixelInfo, $
                       value="**************************",/align_left,font=fontname3)

; button to change 
pix_num_base = widget_base(PixelInfo,row=1,/align_left)
labelID = widget_button(pix_num_base,uvalue='pix_move_x1',value='<',font=info.font3)
labelID = widget_button(pix_num_base,uvalue='pix_move_x2',value='>',font=info.font3)

info.jwst_AmpRate_pixel.pix_label[0] = cw_field(pix_num_base,title="x",font=info.font4, $
                                   uvalue="pix_x_val",/integer,/return_events, $
                                   value=xvalue+1,xsize=4,$
                                   fieldfont=info.font3)

info.jwst_AmpRate_pixel.pix_label[1] = cw_field(pix_num_base,title="y",font=info.font4, $
                                   uvalue="pix_y_val",/integer,/return_events, $
                                   value=yvalue+1,xsize=5,$
                                   fieldfont=info.font3)

labelID = widget_button(pix_num_base,uvalue='pix_move_y1',value='<',font=info.font3)
labelID = widget_button(pix_num_base,uvalue='pix_move_y2',value='>',font=info.font3)

value1 = (*info.jwst_AmpRate_image[0].pdata)[xvalue,yvalue]
value2 = (*info.jwst_AmpRate_image[1].pdata)[xvalue,yvalue]
value3 = (*info.jwst_AmpRate_image[2].pdata)[xvalue,yvalue]
value4 = (*info.jwst_AmpRate_image[3].pdata)[xvalue,yvalue]

svalue1 = strcompress(string(value1),/remove_all)
svalue2 = strcompress(string(value2),/remove_all)
svalue3 = strcompress(string(value3),/remove_all)
svalue4 = strcompress(string(value4),/remove_all)

info.jwst_AmpRate_pixel.pix_statLabelID[0] = widget_label(pixelinfo,$
                                             value= 'Amplifier 1 value  = ' + svalue1,$
                                             /dynamic_resize,/align_left)

info.jwst_AmpRate_pixel.pix_statLabelID[1] = widget_label(pixelinfo,$
                                             value= 'Amplifier 2 value  = ' + svalue2,$
                                             /dynamic_resize,/align_left)

info.jwst_AmpRate_pixel.pix_statLabelID[2] = widget_label(pixelinfo,$
                                             value= 'Amplifier 3 value  = ' + svalue3,$
                                             /dynamic_resize,/align_left)

info.jwst_AmpRate_pixel.pix_statLabelID[3] = widget_label(pixelinfo,$
                                             value= 'Amplifier 4 value  = ' + svalue4,$
                                             /dynamic_resize,/align_left)


blank = widget_label(pixelinfo,value= ' ')
info.jwst_AmpRate_pixel.xpixel_typeLabel = [" Note: X = 1 or 258 for reference pixel ", $
                               " **This is a Reference Pixel**           "]

sxvalue = info.jwst_AmpRate_pixel.xpixel_typelabel[0]

if(info.jwst_data.subarray eq 0) then $
  info.jwst_AmpRate_pixel.xpixel_typeID = widget_label(pixelinfo, $
                                          value= sxvalue,font = info.font4,$
                                          /align_left)

info.jwst_ARPixelInfo = pixelinfo

pixel = {info                  : info}	
Widget_Control,info.jwst_ARPixelInfo,Set_UValue=pixel
widget_control,info.Jwst_ARPixelInfo,/realize

XManager,'ARpixel',pixelinfo,/No_Block,event_handler = 'jwst_pixel_RateAmplifier_event'
Widget_Control,info.jwst_QuickLook,Set_UValue=info

end
