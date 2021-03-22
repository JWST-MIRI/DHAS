@mql_update_SlopeChannel
;_______________________________________________________________________
pro mql_SlopeChannel_quit,event

widget_control,event.top, Get_UValue = cinfo	
widget_control,cinfo.info.QuickLook,Get_Uvalue = info


if( XRegistered ('mqlhschr')) then begin ; histo channel
   widget_control,info.HistoSlopeChannelQuickLook,/destroy
endif

if( XRegistered ('mqlrschr')) then begin ; histo channel
   widget_control,info.RSliceSlopeChannelQuickLook,/destroy
endif

if( XRegistered ('mqlcschr')) then begin ; histo channel
   widget_control,info.CSliceSlopeChannelQuickLook,/destroy
endif

; statistics on channels
if(XRegistered ('mschstat')) then begin
    widget_control,info.StatSlopeChannelInfo,/destroy
endif


if(XRegistered ('mSCpixel')) then begin
    widget_control,info.SCPixelInfo,/destroy
endif
widget_control,info.SlopeChannelQuickLook,/destroy
end
;_______________________________________________________________________
;_______________________________________________________________________
;***********************************************************************

pro mql_update_pixel_SlopeChannel_location,info

xsize = info.SlopeChannel.xplotsize
ysize = info.SlopeChannel.yplotsize

for i = 0,4 do begin 
    wset,info.SlopeChannel.draw_window_id[i]

    device,copy=[0,0,xsize,ysize, $
                 0,0,info.SlopeChannel.pixmapID[i]]

    xvalue = info.SlopeChannel.xpos
    yvalue = info.SlopeChannel.ypos     
    xcenter = xvalue + 0.5
    ycenter = yvalue + 0.5
    box_coords1 = [xcenter,(xcenter+1), $
                   ycenter,(ycenter+1)]

    plots,box_coords1[[0,0,1,1,0]],box_coords1[[2,3,3,2,2]],psym=0,/device


endfor
end


;_______________________________________________________________________
;***********************************************************************
; the event manager for the mql_display_SlopeChannel.pro (Display image by SlopeChannel)
pro mql_SlopeChannel_event,event

Widget_Control,event.id,Get_uValue=event_name
widget_control,event.top, Get_UValue = cinfo
widget_control,cinfo.info.Quicklook,Get_Uvalue = minfo

cinfo.info = minfo

jintegration = minfo.ChannelS[0].jintegration

if (widget_info(event.id,/TLB_SIZE_EVENTS) eq 1 ) then begin
    minfo.slopechannel.xwindowsize = event.x
    minfo.slopechannel.ywindowsize = event.y
    minfo.slopechannel.uwindowsize = 1
    widget_control,event.top,set_uvalue = cinfo
    widget_control,cinfo.info.Quicklook,set_uvalue = minfo
    mql_display_SlopeChannel,minfo
    return
endif

case 1 of
;_______________________________________________________________________
; print images
    (strmid(event_name,0,7) EQ 'print_i') : begin
        print_SlopeChannel,minfo
        
    end
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
       if(jintegration lt 0) then jintegration = minfo.data.nslopes-1
       if(jintegration gt minfo.data.nslopes-1  ) then jintegration = 0

       widget_control,minfo.SlopeChannel.integration_label,set_value= fix(jintegration+1)
       mql_SlopeChannel_moveframe,jintegration,minfo
    end

;_______________________________________________________________________
;_______________________________________________________________________
; change range of image graphs
; if change range then also change the scale button to 'User Set
; Scale'
;_______________________________________________________________________
    (strmid(event_name,0,2) EQ 'sr') : begin
        graph_num = fix(strmid(event_name,2,1))-1
        
        if(strmid(event_name,4,1) EQ 'b') then mm_val = 0 else mm_val = 1 ; b for min, t for max

; channels scale individually
        if(minfo.SlopeChannel.scalechannel -1 eq 5) then begin
            minfo.SlopeChannel.graph_range[graph_num,mm_val] = event.value
            minfo.SlopeChannel.default_scale[graph_num] = 0
            widget_control,minfo.SlopeChannel.recomputeID[graph_num],set_value='Default Scale'
            mql_update_SlopeChannel,graph_num,minfo
        endif

; scale to channel

        if(minfo.SlopeChannel.scalechannel-1 ne 5) then begin
            index = minfo.SlopeChannel.scalechannel-1
            if(graph_num eq index)then begin
                minfo.SlopeChannel.graph_range[graph_num,mm_val] = event.value

                minfo.SlopeChannel.default_scale[graph_num] = 0
                widget_control,minfo.SlopeChannel.recomputeID[graph_num],set_value='Default Scale'
            endif

            for i = 0,4 do begin
                mql_update_SlopeChannel,i,minfo
            endfor
        endif





    end

;_______________________________________________________________________
; Default Scale Button
;_______________________________________________________________________
    (strmid(event_name,0,5) EQ 'scale') : begin
        graphno = fix(strmid(event_name,5,1))-1

        if(minfo.SlopeChannel.scalechannel-1 eq 5) then begin
            widget_control,minfo.SlopeChannel.recomputeID[graphno],set_value=' Image Scale '
            minfo.SlopeChannel.default_scale[graphno] = 1
            mql_update_SlopeChannel,graphno,minfo

        endif else begin
            if(graphno eq minfo.SlopeChannel.scalechannel -1) then begin
                widget_control,minfo.SlopeChannel.recomputeID[graphno],set_value=' Image Scale '
                minfo.SlopeChannel.default_scale[graphno] = 1
                for i = 0,4 do begin
                    mql_update_SlopeChannel,i,minfo
                endfor
            endif
        endelse


;        mql_update_SlopeChannel,graphno,minfo
    end
;_______________________________________________________________________

; Display statistics on the image 
;_______________________________________________________________________
    (strmid(event_name,0,4) EQ 'stat') : begin
	mql_display_SlopeChannel_stat,minfo
    end

;_______________________________________________________________________
; Plotting options: row slice or  column slice
;_______________________________________________________________________
    (strmid(event_name,0,4) EQ 'plot') : begin


        if(event.index eq 1) then begin ; Histogram
            mql_display_SlopeChannel_histo,minfo  
        endif

 
        if(event.index eq 2) then begin ; column slice
            mql_display_SlopeChannel_colslice,minfo  
        endif

        if(event.index eq 3) then begin ; row slice
            mql_display_SlopeChannel_rowslice,minfo
        endif

        widget_control,minfo.SlopeChannel.optionMenu,set_droplist_select=0
        

    end
;_______________________________________________________________________
; Display the pixel values in a seperate window or do not pop up the box
;_______________________________________________________________________
    (strmid(event_name,0,8) EQ 'pdisplay') : begin

        no = fix(strmid(event_name,8,1))
        if(no eq 1) then minfo.SlopeChannel.pixeldisplay = 1
        if(no eq 2) then minfo.SlopeChannel.pixeldisplay = 0

	xvalue = minfo.SlopeChannel.xpos 
	yvalue = minfo.SlopeChannel.ypos 

        xposfull = (xvalue/minfo.SlopeChannel.zoom)+ minfo.SlopeChannel.xstart_zoom
        yposfull = (yvalue/minfo.SlopeChannel.zoom)+ minfo.SlopeChannel.ystart_zoom

        minfo.SlopeChannel.xposfull = xposfull
        minfo.SlopeChannel.yposfull = yposfull
	if(no eq 1) then mql_pixel_SlopeChannel_display,xposfull,yposfull,minfo

    end

;_______________________________________________________________________

    (strmid(event_name,0,6) EQ 'ascale') : begin

	minfo.SlopeChannel.scalechannel = event.index+1
        for i = 0,4 do begin
            if(minfo.Slopechannel.scalechannel-1 eq 5) then begin
                widget_control,minfo.Slopechannel.recomputeID[i],set_value=' Image Scale '
                minfo.Slopechannel.default_scale[i] = 1
            endif

            if(minfo.Slopechannel.scalechannel-1 eq i) then begin
                widget_control,minfo.Slopechannel.recomputeID[i,0],set_value=' Image Scale '
                minfo.Slopechannel.default_scale[i] = 1
            endif

            mql_update_slopechannel,i,minfo
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
           x = (xvalue)/minfo.Slopechannel.zoom
           y = (yvalue)/minfo.Slopechannel.zoom
           if(x gt minfo.data.slope_xsize/4) then x = (minfo.data.slope_xsize/4)-1
           if(y gt minfo.data.slope_ysize) then y = minfo.data.slope_ysize-1
           xvalue = x * minfo.Slopechannel.zoom
           yvalue = y * minfo.Slopechannel.zoom
;;

           minfo.SlopeChannel.xpos = xvalue
           minfo.SlopeChannel.ypos = yvalue

           xposfull = (xvalue/minfo.SlopeChannel.zoom)+ minfo.SlopeChannel.xstart_zoom
           yposfull = (yvalue/minfo.SlopeChannel.zoom)+ minfo.SlopeChannel.ystart_zoom

           minfo.SlopeChannel.xposfull = xposfull
           minfo.SlopeChannel.yposfull = yposfull

           if(xposfull gt minfo.data.slope_xsize/4 or yposfull gt minfo.data.slope_ysize) then begin
               ok = dialog_message(" Area out of range",/Information)
               return
           endif

           mql_update_pixel_SlopeChannel_location,minfo


           widget_control,cinfo.info.Quicklook,set_uvalue = minfo	
           if(minfo.SlopeChannel.pixeldisplay eq 1) then  begin
               xp_value = minfo.SlopeChannel.xposfull
               yp_value = minfo.SlopeChannel.yposfull
               if(XRegistered ('mSCpixel') ) then begin
                  minfo.SlopeChannel_pixel.xvalue = xp_value+1	
                  minfo.SlopeChannel_pixel.yvalue = yp_value+1
                   mql_update_pixel_SlopeChannel_info,minfo
               endif else begin
                   mql_pixel_SlopeChannel_display,xp_value,yp_value,minfo
               endelse
           endif
       endif

   end
;_______________________________________________________________________e
; zoom images
;_______________________________________________________________________
   (strmid(event_name,0,4) EQ 'zoom') : begin
         if(event.index eq 0) then minfo.SlopeChannel.zoom = 1.0
         if(event.index eq 1) then minfo.SlopeChannel.zoom = 2.0
         if(event.index eq 2) then minfo.SlopeChannel.zoom = 4.0
         if(event.index eq 3) then minfo.SlopeChannel.zoom = 8.0
         if(event.index eq 4) then minfo.SlopeChannel.zoom = 16.0
	 mql_grab_SlopeChannel_images,minfo
	 for i = 0,4 do begin
             mql_update_SlopeChannel,i,minfo
         endfor

         ; redefine the xpos and y pos value in new zoom window

         xpos_new = minfo.SlopeChannel.xposfull -minfo.SlopeChannel.xstart_zoom 
         ypos_new = minfo.SlopeChannel.yposfull -minfo.SlopeChannel.ystart_zoom
         minfo.SlopeChannel.xpos = (xpos_new)*minfo.SlopeChannel.zoom
         minfo.SlopeChannel.ypos = (ypos_new)*minfo.SlopeChannel.zoom


         mql_update_pixel_SlopeChannel_location,minfo

     end


endcase

cinfo.info = minfo
widget_control,event.top,set_uvalue = cinfo

widget_control,cinfo.info.Quicklook,set_uvalue = minfo
end

;***********************************************************************
;***********************************************************************
pro mql_display_SlopeChannel,info

window,1,/pixmap
wdelete,1
jintegration = fix(info.ChannelS[0].jintegration)
xplotsize = info.data.image_xsize/4
yplotsize = info.data.image_ysize


info.SlopeChannel.zoom  = 1
if (yplotsize lt 1024) then begin
    plotsize = yplotsize
    if(xplotsize*4 gt yplotsize) then plotsize = xplotsize*4
    zoom = fix(1024/plotsize)
    info.SlopeChannel.zoom = zoom
    xplotsize = (info.data.image_xsize/4) * zoom
    yplotsize = info.data.image_ysize * zoom
endif

; widget window parameters
xwidget_size = 1650
ywidget_size = 1350

xsize_scroll = 1550
ysize_scroll = 1200




if(info.Slopechannel.uwindowsize eq 1) then begin ; user has set window size 
    xsize_scroll = info.Slopechannel.xwindowsize
    ysize_scroll = info.Slopechannel.ywindowsize
endif

if(info.control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.control.x_scroll_window
if(info.control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.control.y_scroll_window
if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10


stitle = "MIRI Quick Look- 5 Channel Plots of Slope Images" + info.version
svalue = " 5 Channel Plots of Slope Images: "


if( XRegistered ('mqldschr')) then begin
    widget_control,info.SlopeChannelQuickLook,/destroy
endif


SlopeChannelQuickLook = widget_base(title=stitle ,$
                                  col = 1,mbar = menuBar,$
                                  group_leader = info.QuickLook,$
                                  xsize =  xwidget_size,$
                                  ysize=   ywidget_size,/scroll,$
                                  x_scroll_size= xsize_scroll,$
                                  y_scroll_size = ysize_scroll,/TLB_SIZE_EVENTS)


; add quit button
QuitMenu = widget_button(menuBar,value="Quit",font = info.font2)
quitbutton = widget_button(quitmenu,value="Quit",event_pro='mql_slopechannel_quit')

PrintMenu = widget_button(menuBar,value="Print",font = info.font2)
printbutton = widget_button(Printmenu,value="Print 5 Channel Images",uvalue='print_i')


DMenu = widget_button(menuBar,value="Display Pixel Values",font = info.font2)
Dbutton1 = widget_button(Dmenu,value="Display Pixel Values",uvalue='pdisplay1')
Dbutton2 = widget_button(Dmenu,value="Do Not Display Pixel Values",uvalue='pdisplay2')


title_base = widget_base(SlopeChannelQuickLook,col=3,/align_center)

tlabelID = widget_label(title_base,value =svalue,font=info.font5)
titlelabel = widget_label(title_base,value = info.control.filename_raw, font=info.font3)

;********
blankspaces  = '       '
options = ['Plot Options: ', 'Histogram', 'Column Slice','Row Slice ']


scaledisplay = ['Scale All to Channel 1', 'Scale All to Channel 2', $
                'Scale All to Channel 3', 'Scale All to Channel 4', $
                'Scale All to Channel 5', 'Scale to Individual Channel']

zoomdisplay = ['No Zoom ', 'Zoom (2X)', $
               'Zoom (4x)', 'Zoom (8x)', 'Zoom (16x)']
move_base = widget_base(SlopeChannelQuickLook,/row,/align_left)

integration_label = cw_field(move_base,$
                    title=" Integration # ",font=info.font5, $
                    uvalue="integration",/integer,/return_events, $
                    value=jintegration+1,xsize=4,$
                    fieldfont=info.font3)

labelID = widget_button(move_base,uvalue='integr_move_dn',value='<',font=info.font3)
labelID = widget_button(move_base,uvalue='integr_move_up',value='>',font=info.font3)



scale_label  = widget_droplist(move_base,value=scaledisplay,uvalue='ascale',$
	font= info.font5)

stat_label = widget_button(move_base,value='Get Statistics',uvalue='stat',font=info.font5)
zoom_label = widget_droplist(move_base,value=zoomdisplay,uvalue='zoom',font=info.font5)
optionMenu = widget_droplist(move_base,value=options,uvalue='plot',font=info.font5)



;Set up the GUI




;_______________________________________________________________________
graphID_master0 = widget_base(SlopeChannelQuickLook,row=1)
graphID_master1 = widget_base(SlopeChannelQuickLook,row=1)


graphID11 = widget_base(graphID_master0,col=1)
graphID12 = widget_base(graphID_master0,col=1)
graphID13 = widget_base(graphID_master0,col=1)

graphID14 = widget_base(graphID_master0,col=1)
graphID15 = widget_base(graphID_master0,col=1)


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
;graph 1 Channel 1 Image 
;*****
graph_range[0,1] = info.ChannelS[0].range_max
graph_range[0,0] = info.ChannelS[0].range_min

titleID = widget_label(graphID11, value = " Channel 1 Image ",$
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
;graph 2 Channel 2 Image 
;*****
graph_range[1,1] = info.ChannelS[1].range_max
graph_range[1,0] = info.ChannelS[1].range_min
titleID = widget_label(graphID12, value = " Channel 2 Image ",$a
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
;*****
;graph 3 Channel 3 Image 
;*****
graph_range[2,1] = info.ChannelS[2].range_max
graph_range[2,0] = info.ChannelS[2].range_min
titleID = widget_label(graphID13, value = " Channel 3 Image ",$
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
;*****
;graph 4 Channel 4 Image 
;*****
graph_range[3,1] = info.ChannelS[3].range_max
graph_range[3,0] = info.ChannelS[3].range_min
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
;*****
;graph 5 Channel 5 Image 
;*****
graph_range[4,1] = info.ChannelS[4].range_max
graph_range[4,0] = info.ChannelS[4].range_min
titleID = widget_label(graphID15, value = " Channel 5 Image (Reference Output) ",$
                       /align_center,font=info.font3)

stat_base = widget_base(graphID15,row=1)
smean =  strcompress(string(imagemean[4]),/remove_all)
smin = strcompress(string(imagemin[4]),/remove_all) 
smax = strcompress(string(imagemax[4]),/remove_all)

slabelID[4] = widget_label(stat_base,value=(' Mean: ' + smean),$ 
                                          /align_left,font=info.font3) 
mlabelID[4] = widget_label(stat_base,$
                         value=(' Min: ' + smin + '   Max: ' + smax),$
                                      /align_left,font=info.font3)

; min and max scale of  image
range_base = widget_base(graphID15,row=1)
recomputeID[4] = widget_button(range_base,value=' Image Scale ',$
                                                font=info.font4,$
                                                uvalue = 'scale5')

rlabelID[4,0] = cw_field(range_base,title="min",font=info.font4,$
                                    uvalue="sr5_b",/float,/return_events,$
                                    xsize=info.xsize_label,value =graph_range[4,0],$
                                    fieldfont = info.font4)

rlabelID[4,1] = cw_field(range_base,title="max",font=info.font4,$
                                    uvalue="sr5_t",/float,/return_events,$
                                    xsize = info.xsize_label,value =graph_range[4,1],$
                                   fieldfont=info.font4)

graphID[4] = widget_draw(graphID15,$
                         xsize = xplotsize,$
                         ysize=yplotsize,$
                         retain=info.retn, /Button_Events,uvalue='pixel')


longline = '                                                                                                                        '
longtag = widget_label(SlopeChannelQuicklook,value = longline)

Widget_control,SlopeChannelQuickLook,/Realize

XManager,'mqldschr',SlopeChannelQuickLook,/No_Block,event_handler='mql_SlopeChannel_event'
;_______________________________________________________________________
for i = 0, 4 do begin
    widget_control,graphID[i],get_value=tdraw_id
    draw_window_id[i] = tdraw_id
    window,/pixmap,xsize=xplotsize,ysize=yplotsize,/free
    pixmapID[i] = !D.WINDOW
endfor
info.SlopeChannel.recomputeID     = recomputeID
info.SlopeChannel.mlabelID        =mlabelID
info.SlopeChannel.slabelID = slabelID
info.SlopeChannel.rlabelID = rlabelID
info.SlopeChannel.graphID = graphID
info.SlopeChannel.pixmapID = pixmapID
info.SlopeChannel.draw_window_id = draw_window_id
info.SlopeChannel.default_scale = default_scale
info.SlopeChannel.graph_range = graph_range
info.SlopeChannel.xplotsize = xplotsize
info.SlopeChannel.yplotsize = yplotsize
info.SlopeChannel.integration_label = integration_label
info.SlopeChannel.optionMenu = optionMenu
info.SlopeChannel.zoom_labelID = zoom_label 
info.SlopeChannel.xpos = 5
info.SlopeChannel.ypos = 5
info.SlopeChannel.xposfull = info.SlopeChannel.xpos
info.SlopeChannel.yposfull = info.SlopeChannel.ypos
info.SlopeChannel.pixeldisplay = 1

info.SlopeChannel.scalechannel = 1

cinfo = {         info            : info}

info.SlopeChannelQuickLook = SlopeChannelQuickLook
Widget_Control,info.SlopeChannelQuickLook,Set_UValue=cinfo
Widget_Control,info.QuickLook,Set_UValue=info

;_______________________________________________________________________
; Fill in the Subimage
mql_grab_SlopeChannel_images,info
;_______________________________________________________________________
for i = 0,4 do begin
    mql_update_SlopeChannel,i,info
    Widget_Control,info.SlopeChannelQuickLook,Set_UValue=cinfo
    Widget_Control,info.QuickLook,Set_UValue=info        
endfor

mql_update_pixel_SlopeChannel_location,info
Widget_Control,info.QuickLook,Set_UValue=info

end
