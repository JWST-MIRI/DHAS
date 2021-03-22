;***********************************************************************
pro jwst_pixel_amplifier_quit,event
widget_control,event.top, Get_UValue = tinfo
widget_control,tinfo.info.jwst_QuickLook,Get_UValue=info
widget_control,info.jwst_APixelInfo,/destroy
end

;_______________________________________________________________________
;***********************************************************************

pro jwst_update_pixel_Amplifier_info,info

; xvaule and yvalue start at 0
; jwst_amp_pixel.x(Y)value start at 1
xvalue = info.jwst_amp_pixel.xvalue -1 ; starts at 0
yvalue = info.jwst_amp_pixel.yvalue -1;  starts at 0

widget_control,info.jwst_amp_pixel.pix_label[0],set_value=xvalue+1
widget_control,info.jwst_amp_pixel.pix_label[1],set_value=yvalue+1

if(xvalue lt 0) then xvalue =0
if(yvalue lt 0) then yvalue = 0


value1 = (*info.jwst_AmpFrame_image[0].pdata)[0,xvalue,yvalue]
value2 = (*info.jwst_AmpFrame_image[1].pdata)[0,xvalue,yvalue]
value3 = (*info.jwst_AmpFrame_image[2].pdata)[0,xvalue,yvalue]
value4 = (*info.jwst_AmpFrame_image[3].pdata)[0,xvalue,yvalue]
value5 = (*info.jwst_AmpFrame_image[4].pdata)[0,xvalue,yvalue]


svalue1 = strcompress(string(value1),/remove_all)
svalue2 = strcompress(string(value2),/remove_all)
svalue3 = strcompress(string(value3),/remove_all)
svalue4 = strcompress(string(value4),/remove_all)
svalue5 = strcompress(string(value5),/remove_all)

if(info.jwst_amp_pixel.hex eq 1) then  begin
  if(value1 lt 0) then begin
      svalue1 = " Negative Value " 
  endif else begin
      dec2hex,value1,hexvalue,quiet=1,upper=1
      svalue1 = strcompress(string(hexvalue),/remove_all)
  endelse
  if(value2 lt 0) then begin
      svalue2 = " Negative Value " 
  endif else begin
      dec2hex,value2,hexvalue,quiet=1,upper=1
      svalue2 = strcompress(string(hexvalue),/remove_all)
  endelse
  if(value3 lt 0) then begin
      svalue3 = " Negative Value " 
  endif else begin
      dec2hex,value3,hexvalue,quiet=1,upper=1
      svalue3 = strcompress(string(hexvalue),/remove_all)
  endelse
  if(value4 lt 0) then begin
      svalue4 = " Negative Value " 
  endif else begin
      dec2hex,value4,hexvalue,quiet=1,upper=1
      svalue4 = strcompress(string(hexvalue),/remove_all)
  endelse
  if(value5 lt 0) then begin
      svalue5 = " Negative Value " 
  endif else begin
      dec2hex,value5,hexvalue,quiet=1,upper=1
      svalue5 = strcompress(string(hexvalue),/remove_all)
  endelse

endif
widget_control,info.jwst_amp_pixel.pix_statLabelID[0],set_value=' Amplifier 1 value = '+svalue1
widget_control,info.jwst_amp_pixel.pix_statLabelID[1],set_value=' Amplifier 2 value = '+svalue2
widget_control,info.jwst_amp_pixel.pix_statLabelID[2],set_value=' Amplifier 3 value = '+svalue3
widget_control,info.jwst_amp_pixel.pix_statLabelID[3],set_value=' Amplifier 4 value = '+svalue4
widget_control,info.jwst_amp_pixel.pix_statLabelID[4],set_value=' Amplifier 5 value = '+svalue5

if(info.jwst_data.subarray eq 0) then begin
    if(xvalue eq 0 or xvalue eq 257) then begin
        xvalue = info.jwst_amp_pixel.xpixel_typelabel[1] 

    endif else begin
        xvalue = info.jwst_amp_pixel.xpixel_typelabel[0] 
    endelse
        widget_control,info.jwst_amp_pixel.xpixel_typeID,set_value = xvalue
endif

end


;***********************************************************************
;_______________________________________________________________________

;***********************************************************************
pro jwst_pixel_amplifier_event,event

Widget_Control,event.id,Get_uValue=event_name
widget_control,event.top, Get_UValue = ginfo
widget_control,ginfo.info.jwst_QuickLook,Get_Uvalue = info

    case 1 of
;_______________________________________________________________________

; change the display type: decimal, hex
;_______________________________________________________________________

    (strmid(event_name,0,7) EQ 'display') : begin
        if(event.index eq 0) then info.jwst_amp_pixel.hex = 0
        if(event.index eq 1) then info.jwst_amp_pixel.hex = 1
        Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info

        jwst_update_pixel_amplifier_info,info
    end

; Select a different pixel to get the ramp read - also update the
; selected pixel location in the 3 image plots
;_______________________________________________________________________
    (strmid(event_name,0,3) EQ 'pix') : begin
; first check if have uvalue = pix_x_value, pix_y_value (user input
; pixel value
; ++++++++++++++++++++++++++++++
        xsize = info.data.image_xsize/4
        ysize = info.data.image_ysize
        xvalue = info.jwst_amp_pixel.xvalue
        yvalue = info.jwst_amp_pixel.yvalue
        xstart = xvalue
        ystart = yvalue
;	print,'starting value',xvalue,yvalue
; ++++++++++++++++++++++++++++++
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

            xvalue = info.jwst_amp_pixel.xvalue ;starts at 0
            yvalue = info.jwst_amp_pixel.yvalue ;starts at 0
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
        if(yvalue gt ysize) then  yvalue = ysize


        info.jwst_amp_pixel.xvalue = xvalue		
        info.jwst_amp_pixel.yvalue = yvalue	

        xmove =info.jwst_amp_pixel.xvalue - xstart
        ymove =info.jwst_amp_pixel.yvalue - ystart

        info.amplifier.xpos = info.amplifier.xpos + xmove*info.amplifier.zoom
        info.amplifier.ypos = info.amplifier.ypos + ymove*info.amplifier.zoom
        ;print,info.amplifier.xpos, info.amplifier.ypos


        info.amplifier.xposfull = info.jwst_amp_pixel.xvalue -1		
        info.amplifier.yposfull = info.jwst_amp_pixel.yvalue -1 
        jwst_update_pixel_amplifier_info,info ; uses jwst_amp_pixel.xvalue
                                           ;      jwst_amp_pixel.yvalue
; ++++++++++++++++++++++++++++++
; update the location of the pixel on the images

    	  jwst_update_pixel_Amplifier_location,info ; uses info.amplifier.xpos
                                                 ;      info.amplifier.ypos  
    end
else: print," Event name not found ",event_name
endcase
widget_control,event.top, Set_UValue = ginfo
widget_control,ginfo.info.jwst_QuickLook,Set_Uvalue = info
end


;_______________________________________________________________________
; The parameters for this widget are contained in the image_pixel
; structure, rather than a local imbedded structure because
; jwst_event.pro also calls to update the pixel info widget

pro jwst_pixel_Amplifier_display,xvalue,yvalue,info

window,4
wdelete,4
if(XRegistered ('Apixel')) then begin
    widget_control,info.jwst_APixelInfo,/destroy
endif

;_______________________________________________________________________
;*********
;Setup main panel
;*********

PixelInfo = widget_base(title=" Pixel Information for Amplifier Images",$
                         col = 1,mbar = menuBar,group_leader = info.jwst_AmpFrameDisplay,$
                           xsize = 350,ysize = 400,/align_right)

;********
; build the menubar
;********
QuitMenu = widget_button(menuBar,value="Quit",font = info.font2)
quitbutton = widget_button(quitmenu,value="Quit",event_pro='jwst_pixel_Amplifier_quit')


info.jwst_amp_pixel.xvalue = xvalue+1 ; starts at 1
info.jwst_amp_pixel.yvalue = yvalue+1 ; starts at 1

;_______________________________________________________________________
; Pixel Statistics Display
;*********

;displaytypes = ['Decimal Display',$
;              'Hexidecimal Display']

;display_base = widget_base(PixelInfo,col= 1,/align_left)
;DMenu = widget_droplist(display_base,value=displaytypes,uvalue='display')

r11_base = widget_base(PixelInfo,row=1)


stitle = "Pixel Information for Amplifier Images"


tlabelID = widget_label(PixelInfo,$
          value=stitle ,/align_left, font=info.font5,/sunken_frame)

; button to change 
pix_num_base = widget_base(PixelInfo,row=1,/align_left)
labelID = widget_button(pix_num_base,uvalue='pix_move_x1',value='<',font=info.font3)
labelID = widget_button(pix_num_base,uvalue='pix_move_x2',value='>',font=info.font3)

info.jwst_amp_pixel.pix_label[0] = cw_field(pix_num_base,title="x",font=info.font4, $
                                   uvalue="pix_x_val",/integer,/return_events, $
                                   value=xvalue+1,xsize=4,$
                                   fieldfont=info.font3)

info.jwst_amp_pixel.pix_label[1] = cw_field(pix_num_base,title="y",font=info.font4, $
                                   uvalue="pix_y_val",/integer,/return_events, $
                                   value=yvalue+1,xsize=5,$
                                   fieldfont=info.font3)

labelID = widget_button(pix_num_base,uvalue='pix_move_y1',value='<',font=info.font3)
labelID = widget_button(pix_num_base,uvalue='pix_move_y2',value='>',font=info.font3)


value1 = (*info.jwst_AmpFrame_image[0].pdata)[0,xvalue,yvalue]
value2 = (*info.jwst_AmpFrame_image[1].pdata)[0,xvalue,yvalue]
value3 = (*info.jwst_AmpFrame_image[2].pdata)[0,xvalue,yvalue]
value4 = (*info.jwst_AmpFrame_image[3].pdata)[0,xvalue,yvalue]
value5 = (*info.jwst_AmpFrame_image[4].pdata)[0,xvalue,yvalue]

svalue1 = strcompress(string(value1),/remove_all)
svalue2 = strcompress(string(value2),/remove_all)
svalue3 = strcompress(string(value3),/remove_all)
svalue4 = strcompress(string(value4),/remove_all)
svalue5 = strcompress(string(value5),/remove_all)

info.jwst_amp_pixel.pix_statLabelID[0] = widget_label(pixelinfo,$
                                             value= 'Amplifier 1 value  = ' + svalue1,$
                                             /dynamic_resize,/align_left)

info.jwst_amp_pixel.pix_statLabelID[1] = widget_label(pixelinfo,$
                                             value= 'Amplifier 2 value  = ' + svalue2,$
                                             /dynamic_resize,/align_left)

info.jwst_amp_pixel.pix_statLabelID[2] = widget_label(pixelinfo,$
                                             value= 'Amplifier 3 value  = ' + svalue3,$
                                             /dynamic_resize,/align_left)

info.jwst_amp_pixel.pix_statLabelID[3] = widget_label(pixelinfo,$
                                             value= 'Amplifier 4 value  = ' + svalue4,$
                                             /dynamic_resize,/align_left)

info.jwst_amp_pixel.pix_statLabelID[4] = widget_label(pixelinfo,$
                                             value= 'Amplifier 5 value  = ' + svalue5,$
                                             /dynamic_resize,/align_left)


blank = widget_label(pixelinfo,value= ' ')
info.jwst_amp_pixel.xpixel_typeLabel = [" Note: X = 1 or 258 for reference pixel ", $
                               " **This is a Reference Pixel**           "]


sxvalue = info.jwst_amp_pixel.xpixel_typelabel[0]

if(info.jwst_data.subarray eq 0) then $
  info.jwst_amp_pixel.xpixel_typeID = widget_label(pixelinfo, $
                                          value= sxvalue,font = info.font5,$
                                          /align_left)


info.jwst_APixelInfo = pixelinfo

pixel = {info                  : info}	



Widget_Control,info.jwst_APixelInfo,Set_UValue=pixel
widget_control,info.jwst_APixelInfo,/realize

XManager,'Apixel',pixelinfo,/No_Block,event_handler = 'jwst_pixel_amplifier_event'
Widget_Control,info.jwst_QuickLook,Set_UValue=info

end
