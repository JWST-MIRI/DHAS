@jwst_update_RateAmplifier
;_______________________________________________________________________
pro jwst_RateAmplifier_quit,event

widget_control,event.top, Get_UValue = cinfo	
widget_control,cinfo.info.jwst_QuickLook,Get_Uvalue = info


;if( XRegistered ('mqlhschr')) then begin ; histo channel
;   widget_control,info.jwst_AmpRateHistoQuickLook,/destroy
;endif

; statistics on channels
if(XRegistered ('amprate_stat')) then begin
    widget_control,info.jwst_AmpRateStatDisplay,/destroy
endif

if(XRegistered ('ARpixel')) then begin
    widget_control,info.jwst_ARPixelInfo,/destroy
endif
widget_control,info.jwst_AmpRateDisplay,/destroy
end
;_______________________________________________________________________

pro jwst_update_pixel_RateAmplifier_location,info

xsize = info.jwst_AmpRate.xplotsize
ysize = info.jwst_AmpRate.yplotsize

for i = 0,3 do begin 
    wset,info.jwst_AmpRate.draw_window_id[i]

    device,copy=[0,0,xsize,ysize, $
                 0,0,info.jwst_AmpRate.pixmapID[i]]

    xvalue = info.jwst_AmpRate.xpos
    yvalue = info.jwst_AmpRate.ypos     
    xcenter = xvalue + 0.5
    ycenter = yvalue + 0.5
    box_coords1 = [xcenter,(xcenter+1), $
                   ycenter,(ycenter+1)]

    plots,box_coords1[[0,0,1,1,0]],box_coords1[[2,3,3,2,2]],psym=0,/device
endfor
end

;_______________________________________________________________________
; the event manager for the mql_display_RateAmplifier.pro (Display image by RateAmplifier)
pro jwst_RateAmplifier_event,event

Widget_Control,event.id,Get_uValue=event_name
widget_control,event.top, Get_UValue = cinfo
widget_control,cinfo.info.jwst_Quicklook,Get_Uvalue = minfo

cinfo.info = minfo
jintegration = minfo.jwst_AmpRate_image[0].jintegration

if (widget_info(event.id,/TLB_SIZE_EVENTS) eq 1 ) then begin
    minfo.jwst_AmpRate.xwindowsize = event.x
    minfo.jwst_AmpRate.ywindowsize = event.y
    minfo.jwst_AmpRate.uwindowsize = 1
    widget_control,event.top,set_uvalue = cinfo
    widget_control,cinfo.info.jwst_Quicklook,set_uvalue = minfo
    jwst_display_RateAmplifier,minfo
    return
endif

case 1 of
;_______________________________________________________________________
; print images
    (strmid(event_name,0,7) EQ 'print_i') : begin
        print_jwst_AmpRate,minfo
    end
;_______________________________________________________________________
; change range of image graphs
; if change range then also change the scale button to 'User Set
; Scale'
;_______________________________________________________________________
    (strmid(event_name,0,2) EQ 'sr') : begin
        graph_num = fix(strmid(event_name,2,1))-1
        
        if(strmid(event_name,4,1) EQ 'b') then mm_val = 0 else mm_val = 1 ; b for min, t for max

; channels scale individually
        if(minfo.jwst_AmpRate.scalechannel -1 eq 5) then begin
            minfo.jwst_AmpRate.graph_range[graph_num,mm_val] = event.value
            minfo.jwst_AmpRate.default_scale[graph_num] = 0
            widget_control,minfo.jwst_AmpRate.recomputeID[graph_num],set_value='Default Scale'
            jwst_update_RateAmplifier,graph_num,minfo
        endif

; scale to channel

        if(minfo.jwst_AmpRate.scalechannel-1 ne 5) then begin
            index = minfo.jwst_AmpRate.scalechannel-1
            if(graph_num eq index)then begin
                minfo.jwst_AmpRate.graph_range[graph_num,mm_val] = event.value

                minfo.jwst_AmpRate.default_scale[graph_num] = 0
                widget_control,minfo.jwst_AmpRate.recomputeID[graph_num],set_value='Default Scale'
            endif

            for i = 0,3 do begin
                jwst_update_RateAmplifier,i,minfo
            endfor
        endif
    end
;_______________________________________________________________________
; Default Scale Button
;_______________________________________________________________________
    (strmid(event_name,0,5) EQ 'scale') : begin
        graphno = fix(strmid(event_name,5,1))-1

        if(minfo.jwst_AmpRate.scalechannel-1 eq 5) then begin
            widget_control,minfo.jwst_AmpRate.recomputeID[graphno],set_value=' Image Scale '
            minfo.jwst_AmpRate.default_scale[graphno] = 1
            jwst_update_RateAmplifier,graphno,minfo

        endif else begin
            if(graphno eq minfo.jwst_AmpRate.scalechannel -1) then begin
                widget_control,minfo.jwst_AmpRate.recomputeID[graphno],set_value=' Image Scale '
                minfo.jwst_AmpRate.default_scale[graphno] = 1
                for i = 0,3 do begin
                    jwst_update_RateAmplifier,i,minfo
                endfor
            endif
        endelse


;        mql_update_jwst_AmpRate,graphno,minfo
    end
;_______________________________________________________________________

; Display statistics on the image 
;_______________________________________________________________________
    (strmid(event_name,0,4) EQ 'stat') : begin
	jwst_display_RateAmplifier_stat,minfo
    end
;_______________________________________________________________________
; Plotting options: row slice or  column slice
;_______________________________________________________________________
    (strmid(event_name,0,4) EQ 'plot') : begin
       jwst_display_RateAmp_histo,minfo  
    end
;_______________________________________________________________________
; Display the pixel values in a seperate window or do not pop up the box
;_______________________________________________________________________
    (strmid(event_name,0,8) EQ 'pdisplay') : begin

        no = fix(strmid(event_name,8,1))
        if(no eq 1) then minfo.jwst_AmpRate.pixeldisplay = 1
        if(no eq 2) then minfo.jwst_AmpRate.pixeldisplay = 0

	xvalue = minfo.jwst_AmpRate.xpos 
	yvalue = minfo.jwst_AmpRate.ypos 

        xposfull = (xvalue/minfo.jwst_AmpRate.zoom)+ minfo.jwst_AmpRate.xstart_zoom
        yposfull = (yvalue/minfo.jwst_AmpRate.zoom)+ minfo.jwst_AmpRate.ystart_zoom

        minfo.jwst_AmpRate.xposfull = xposfull
        minfo.jwst_AmpRate.yposfull = yposfull
        if(XRegistered ('ARpixel')) then begin
           widget_control,info.jwst_ARPixelInfo,/destroy
        endif
	if(no eq 1) then jwst_pixel_RateAmplifier_display,xposfull,yposfull,minfo
    end
;_______________________________________________________________________

    (strmid(event_name,0,6) EQ 'ascale') : begin
       minfo.jwst_AmpRate.scalechannel = event.index+1

        for i = 0,3 do begin
           ; if(minfo.jwst_AmpRate.scalechannel-1 eq 4) then begin
           ;     widget_control,minfo.jwst_AmpRate.recomputeID[i],set_value=' Image Scale '
           ;     minfo.jwst_AmpRate.default_scale[i] = 1
           ; endif
           ; if(minfo.jwst_AmpRate.scalechannel-1 eq i) then begin
                widget_control,minfo.jwst_AmpRate.recomputeID[i,0],set_value=' Image Scale '
                minfo.jwst_AmpRate.default_scale[i] = 1
           ; endif
            jwst_update_RateAmplifier,i,minfo
        endfor
    end
;_______________________________________________________________________
; Select a different pixel to report the values of
; event is generated for button pushing down and button release.
; only need this called once
;_______________________________________________________________________

   (strmid(event_name,0,5) EQ 'pixel') : begin
       if(event.type eq 1) then begin 
           xvalue = event.x     ; starts at 0
           yvalue = event.y     ; starts at 0

;; test for out of bounds area
           x = (xvalue)/minfo.jwst_AmpRate.zoom
           y = (yvalue)/minfo.jwst_AmpRate.zoom
           if(x gt minfo.jwst_data.slope_xsize/4) then x = (minfo.jwst_data.slope_xsize/4)-1
           if(y gt minfo.jwst_data.slope_ysize) then y = minfo.jwst_data.slope_ysize-1
           xvalue = x * minfo.jwst_AmpRate.zoom
           yvalue = y * minfo.jwst_AmpRate.zoom

           minfo.jwst_AmpRate.xpos = xvalue
           minfo.jwst_AmpRate.ypos = yvalue

           xposfull = (xvalue/minfo.jwst_AmpRate.zoom)+ minfo.jwst_AmpRate.xstart_zoom
           yposfull = (yvalue/minfo.jwst_AmpRate.zoom)+ minfo.jwst_AmpRate.ystart_zoom

           minfo.jwst_AmpRate.xposfull = xposfull
           minfo.jwst_AmpRate.yposfull = yposfull

           if(xposfull gt minfo.jwst_data.slope_xsize/4 or yposfull gt minfo.jwst_data.slope_ysize) then begin
               ok = dialog_message(" Area out of range",/Information)
               return
           endif

           jwst_update_pixel_RateAmplifier_location,minfo
           widget_control,cinfo.info.jwst_Quicklook,set_uvalue = minfo	
           if(minfo.jwst_AmpRate.pixeldisplay eq 1) then  begin
               xp_value = minfo.jwst_AmpRate.xposfull
               yp_value = minfo.jwst_AmpRate.yposfull
               if(XRegistered ('ARpixel') ) then begin
                  minfo.jwst_AmpRate_pixel.xvalue = xp_value+1	
                  minfo.jwst_AmpRate_pixel.yvalue =yp_value+1
                   jwst_update_pixel_RateAmplifier_info,minfo
               endif else begin
                   jwst_pixel_RateAmplifier_display,xp_value,yp_value,minfo
               endelse
           endif
       endif
   end
;_______________________________________________________________________e
; zoom images
;_______________________________________________________________________
   (strmid(event_name,0,4) EQ 'zoom') : begin
         if(event.index eq 0) then minfo.jwst_AmpRate.zoom = 1.0
         if(event.index eq 1) then minfo.jwst_AmpRate.zoom = 2.0
         if(event.index eq 2) then minfo.jwst_AmpRate.zoom = 4.0
         if(event.index eq 3) then minfo.jwst_AmpRate.zoom = 8.0
         if(event.index eq 4) then minfo.jwst_AmpRate.zoom = 16.0
	 jwst_grab_RateAmplifier_images,minfo
	 for i = 0,3 do begin
             jwst_update_RateAmplifier,i,minfo
         endfor

         ; redefine the xpos and y pos value in new zoom window

         xpos_new = minfo.jwst_AmpRate.xposfull -minfo.jwst_AmpRate.xstart_zoom 
         ypos_new = minfo.jwst_AmpRate.yposfull -minfo.jwst_AmpRate.ystart_zoom
         minfo.jwst_AmpRate.xpos = (xpos_new)*minfo.jwst_AmpRate.zoom
         minfo.jwst_AmpRate.ypos = (ypos_new)*minfo.jwst_AmpRate.zoom

         jwst_update_pixel_RateAmplifier_location,minfo
     end
endcase

cinfo.info = minfo
widget_control,event.top,set_uvalue = cinfo
widget_control,cinfo.info.jwst_Quicklook,set_uvalue = minfo
end

;***********************************************************************
pro jwst_display_RateAmplifier,info

window,1,/pixmap
wdelete,1

jintegration = fix(info.jwst_AmpRate_image[0].jintegration)
xplotsize = info.jwst_data.image_xsize/4
yplotsize = info.jwst_data.image_ysize

info.jwst_AmpRate.zoom  = 1
if (yplotsize lt 1024) then begin
    plotsize = yplotsize
    if(xplotsize*4 gt yplotsize) then plotsize = xplotsize*4
    zoom = fix(1024/plotsize)
    info.jwst_AmpRate.zoom = zoom
    xplotsize = (info.jwst_data.image_xsize/4) * zoom
    yplotsize = info.jwst_data.image_ysize * zoom
endif

; widget window parameters
xwidget_size = 1650
ywidget_size = 1350

xsize_scroll = 1550
ysize_scroll = 1200

if(info.jwst_AmpRate.uwindowsize eq 1) then begin ; user has set window size 
    xsize_scroll = info.jwst_AmpRate.xwindowsize
    ysize_scroll = info.jwst_AmpRate.ywindowsize
endif

if(info.jwst_control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.jwst_control.x_scroll_window
if(info.jwst_control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.jwst_control.y_scroll_window
if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10

stitle = "MIRI Quick Look- 4 Amplifier Plots of Rate Image" + info.jwst_version
svalue = " 4 Amplifier Plots of Rate Image: "

if( XRegistered ('amprate')) then begin
    widget_control,info.jwst_AmpRateDisplay,/destroy
endif

jwst_AmpRateQuickLook = widget_base(title=stitle ,$
                                  col = 1,mbar = menuBar,$
                                  group_leader = info.jwst_QuickLook,$
                                  xsize =  xwidget_size,$
                                  ysize=   ywidget_size,/scroll,$
                                  x_scroll_size= xsize_scroll,$
                                  y_scroll_size = ysize_scroll,/TLB_SIZE_EVENTS)

; add quit button
QuitMenu = widget_button(menuBar,value="Quit",font = info.font2)
quitbutton = widget_button(quitmenu,value="Quit",event_pro='jwst_RateAmplifier_quit')

PrintMenu = widget_button(menuBar,value="Print",font = info.font2)
printbutton = widget_button(Printmenu,value="Print 4 Amplifier Images",uvalue='print_i')

DMenu = widget_button(menuBar,value="Display Pixel Values",font = info.font2)
Dbutton1 = widget_button(Dmenu,value="Display Pixel Values",uvalue='pdisplay1')
Dbutton2 = widget_button(Dmenu,value="Do Not Display Pixel Values",uvalue='pdisplay2')

title_base = widget_base(jwst_AmpRateQuickLook,col=3,/align_center)
tlabelID = widget_label(title_base,value =svalue,font=info.font5)
titlelabel = widget_label(title_base,value = info.jwst_control.filename_slope, font=info.font3)

;********
blankspaces  = '       '
scaledisplay = ['Scale All to Amplifier 1', 'Scale All to Amplifier 2', $
                'Scale All to Amplifier 3', 'Scale All to Amplifier 4', $
                'Scale to Individual Amplifier']

zoomdisplay = ['No Zoom ', 'Zoom (2X)', $
               'Zoom (4x)', 'Zoom (8x)', 'Zoom (16x)']
move_base = widget_base(jwst_AmpRateQuickLook,/row,/align_left)

scale_label  = widget_droplist(move_base,value=scaledisplay,uvalue='ascale',$
	font= info.font5)

stat_label = widget_button(move_base,value='Get Statistics',uvalue='stat',font=info.font5)
zoom_label = widget_droplist(move_base,value=zoomdisplay,uvalue='zoom',font=info.font5)
;optionMenu = widget_button(move_base,value='Histogram',uvalue='plot',font=info.font5)

;Set up the GUI
;_______________________________________________________________________
graphID_master0 = widget_base(jwst_AmpRateQuickLook,row=1)
graphID_master1 = widget_base(jwst_AmpRateQuickLook,row=1)

graphID11 = widget_base(graphID_master0,col=1)
graphID12 = widget_base(graphID_master0,col=1)
graphID13 = widget_base(graphID_master0,col=1)
graphID14 = widget_base(graphID_master0,col=1)

graphID = lonarr(5)
pixmapID = lonarr(5)
draw_window_id = lonarr(5)
;_______________________________________________________________________
; initialize varibles 
recomputeID   = lonarr(5); button controlling Default scale or User Set Scale
mlabelID      = lonarr(5)
slabelID      = lonarr(5)
rlabelID      = lonarr(5,2)
default_scale = intarr(5)
default_scale[*] = 1

imagemean = fltarr(5)
imagestdev = fltarr(5)
imagemin = fltarr(5)
imagemax = fltarr(5)
imagemedain = fltarr(5)
graph_range = fltarr(5,2)

xsize_label = 6    
;_______________________________________________________________________
;*****
;graph 1 Apmifier 1 Image 
;*****
graph_range[0,1] = info.jwst_AmpRate_image[0].range_max
graph_range[0,0] = info.jwst_AmpRate_image[0].range_min

titleID = widget_label(graphID11, value = " Amplifier 1 Image ",$
                       /align_center,font=info.font3)
stat_base = widget_base(graphID11,row=1)
smean =  strcompress(string(imagemean[0]),/remove_all)
smin = strcompress(string(imagemin[0]),/remove_all) 
smax = strcompress(string(imagemax[0]),/remove_all)
slabelID[0] = widget_label(stat_base,value=(' Mean: ' + smean),$ 
                                          /align_left,font=info.font3) 
mlabelID[0] = widget_label(stat_base,$
                         value=(' Min: ' + smin + '   Max: ' + smax),$
                                      /align_left,font=info.font3)
; min and max scale of  image
range_base = widget_base(graphID11,row=1)
recomputeID[0] = widget_button(range_base,value=' Image Scale ',$
                                                font=info.font4,$
                                                uvalue = 'scale1')

rlabelID[0,0] = cw_field(range_base,title="min",font=info.font4,$
                                    uvalue="sr1_b",/float,/return_events,$
                                    xsize=info.xsize_label,value =graph_range[0,0],$
                                    fieldfont = info.font4)

rlabelID[0,1] = cw_field(range_base,title="max",font=info.font4,$
                                    uvalue="sr1_t",/float,/return_events,$
                                    xsize = info.xsize_label,value =graph_range[0,1],$
                                   fieldfont=info.font4)

graphID[0] = widget_draw(graphID11,$
                         xsize = xplotsize,$
                         ysize=yplotsize,$
                         retain=info.retn, /Button_Events,uvalue='pixel')
;_______________________________________________________________________
;*****
;graph 2 Amplifier 2 Image 
;*****
graph_range[1,1] = info.jwst_AmpRate_image[1].range_max
graph_range[1,0] = info.jwst_AmpRate_image[1].range_min
titleID = widget_label(graphID12, value = " Amplifier 2 Image ",$a
                       /align_center,font=info.font3)

stat_base = widget_base(graphID12,row=1)
smean =  strcompress(string(imagemean[1]),/remove_all)
smin = strcompress(string(imagemin[1]),/remove_all) 
smax = strcompress(string(imagemax[1]),/remove_all)

slabelID[1] = widget_label(stat_base,value=(' Mean: ' + smean),$ 
                                          /align_left,font=info.font3) 
mlabelID[1] = widget_label(stat_base,$
                         value=(' Min: ' + smin + '   Max: ' + smax),$
                                      /align_left,font=info.font3)

; min and max scale of  image
range_base = widget_base(graphID12,row=1)
recomputeID[1] = widget_button(range_base,value=' Image Scale ',$
                                                font=info.font4,$
                                                uvalue = 'scale2')

rlabelID[1,0] = cw_field(range_base,title="min",font=info.font4,$
                                    uvalue="sr2_b",/float,/return_events,$
                                    xsize=info.xsize_label,value =graph_range[1,0],$
                                    fieldfont = info.font4)

rlabelID[1,1] = cw_field(range_base,title="max",font=info.font4,$
                                    uvalue="sr2_t",/float,/return_events,$
                                    xsize = info.xsize_label,value =graph_range[1,1],$
                                   fieldfont=info.font4)

graphID[1] = widget_draw(graphID12,$
                         xsize = xplotsize,$
                         ysize=yplotsize,$
                         retain=info.retn, /Button_Events,uvalue='pixel')

;_______________________________________________________________________
;graph 3 Channel 3 Image

graph_range[2,1] = info.jwst_AmpRate_image[2].range_max
graph_range[2,0] = info.jwst_AmpRate_image[2].range_min
titleID = widget_label(graphID13, value = " Amplifier 3 Image ",$
                       /align_center,font=info.font3)

stat_base = widget_base(graphID13,row=1)
smean =  strcompress(string(imagemean[2]),/remove_all)
smin = strcompress(string(imagemin[2]),/remove_all) 
smax = strcompress(string(imagemax[2]),/remove_all)

slabelID[2] = widget_label(stat_base,value=(' Mean: ' + smean),$ 
                                          /align_left,font=info.font3) 
mlabelID[2] = widget_label(stat_base,$
                         value=(' Min: ' + smin + '   Max: ' + smax),$
                                      /align_left,font=info.font3)
; min and max scale of  image
range_base = widget_base(graphID13,row=1)
recomputeID[2] = widget_button(range_base,value=' Image Scale ',$
                                                font=info.font4,$
                                                uvalue = 'scale3')

rlabelID[2,0] = cw_field(range_base,title="min",font=info.font4,$
                                    uvalue="sr3_b",/float,/return_events,$
                                    xsize=info.xsize_label,value =graph_range[2,0],$
                                    fieldfont = info.font4)

rlabelID[2,1] = cw_field(range_base,title="max",font=info.font4,$
                                    uvalue="sr3_t",/float,/return_events,$
                                    xsize = info.xsize_label,value =graph_range[2,1],$
                                   fieldfont=info.font4)

graphID[2] = widget_draw(graphID13,$
                         xsize = xplotsize,$
                         ysize=yplotsize,$
                         retain=info.retn, /Button_Events,uvalue='pixel')
;_______________________________________________________________________
;graph 4 Amplifier 4 Image 
graph_range[3,1] = info.jwst_AmpRate_image[3].range_max
graph_range[3,0] = info.jwst_AmpRate_image[3].range_min
titleID = widget_label(graphID14, value = " Amplifer 4 Image ",$
                       /align_center,font=info.font3)

stat_base = widget_base(graphID14,row=1)
smean =  strcompress(string(imagemean[3]),/remove_all)
smin = strcompress(string(imagemin[3]),/remove_all) 
smax = strcompress(string(imagemax[3]),/remove_all)

slabelID[3] = widget_label(stat_base,value=(' Mean: ' + smean),$ 
                                          /align_left,font=info.font3) 
mlabelID[3] = widget_label(stat_base,$
                         value=(' Min: ' + smin + '   Max: ' + smax),$
                                      /align_left,font=info.font3)

; min and max scale of  image
range_base = widget_base(graphID14,row=1)
recomputeID[3] = widget_button(range_base,value=' Image Scale ',$
                                                font=info.font4,$
                                                uvalue = 'scale4')

rlabelID[3,0] = cw_field(range_base,title="min",font=info.font4,$
                                    uvalue="sr4_b",/float,/return_events,$
                                    xsize=info.xsize_label,value =graph_range[3,0],$
                                    fieldfont = info.font4)

rlabelID[3,1] = cw_field(range_base,title="max",font=info.font4,$
                                    uvalue="sr4_t",/float,/return_events,$
                                    xsize = info.xsize_label,value =graph_range[3,1],$
                                   fieldfont=info.font4)

graphID[3] = widget_draw(graphID14,$
                         xsize = xplotsize,$
                         ysize=yplotsize,$
                         retain=info.retn, /Button_Events,uvalue='pixel')
;_______________________________________________________________________

longline = '                                                                                                                        '
longtag = widget_label(jwst_AmpRateQuicklook,value = longline)

Widget_control,jwst_AmpRateQuickLook,/Realize

XManager,'amprate',jwst_AmpRateQuickLook,/No_Block,event_handler='jwst_RateAmplifier_event'
;_______________________________________________________________________
for i = 0, 3 do begin
    widget_control,graphID[i],get_value=tdraw_id
    draw_window_id[i] = tdraw_id
    window,/pixmap,xsize=xplotsize,ysize=yplotsize,/free
    pixmapID[i] = !D.WINDOW
endfor
info.jwst_AmpRate.recomputeID     = recomputeID
info.jwst_AmpRate.mlabelID        =mlabelID
info.jwst_AmpRate.slabelID = slabelID
info.jwst_AmpRate.rlabelID = rlabelID

info.jwst_AmpRate.graphID = graphID
info.jwst_AmpRate.pixmapID = pixmapID
info.jwst_AmpRate.draw_window_id = draw_window_id
info.jwst_AmpRate.default_scale = default_scale
info.jwst_AmpRate.graph_range = graph_range
info.jwst_AmpRate.xplotsize = xplotsize
info.jwst_AmpRate.yplotsize = yplotsize
;info.jwst_AmpRate.optionMenu = optionMenu
info.jwst_AmpRate.zoom_labelID = zoom_label 
info.jwst_AmpRate.xpos = 5
info.jwst_AmpRate.ypos = 5
info.jwst_AmpRate.xposfull = info.jwst_AmpRate.xpos
info.jwst_AmpRate.yposfull = info.jwst_AmpRate.ypos
info.jwst_AmpRate.pixeldisplay = 1

info.jwst_AmpRate.scalechannel = 1

cinfo = {         info            : info}

info.jwst_AmpRateDisplay = jwst_AmpRateQuickLook
Widget_Control,info.jwst_AmpRateDisplay,Set_UValue=cinfo
Widget_Control,info.jwst_QuickLook,Set_UValue=info
;_______________________________________________________________________
; Fill in the Subimage - in jwst_update_RateAmplifier.pro
jwst_grab_RateAmplifier_images,info
;_______________________________________________________________________
for i = 0,3 do begin
    jwst_update_RateAmplifier,i,info
endfor
Widget_Control,info.jwst_AmpRateDisplay,Set_UValue=cinfo
Widget_Control,info.jwst_QuickLook,Set_UValue=info        
jwst_update_pixel_RateAmplifier_location,info
Widget_Control,info.jwst_QuickLook,Set_UValue=info

end
