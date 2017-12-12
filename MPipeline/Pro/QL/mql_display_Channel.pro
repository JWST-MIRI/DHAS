; Display the Science data by Channel. 
; This tools provides zooming, statistics on images, Column and Row slices
@mql_update_Channel
;_______________________________________________________________________
;***********************************************************************
pro mql_channel_quit,event

widget_control,event.top, Get_UValue = cinfo	
widget_control,cinfo.info.QuickLook,Get_Uvalue = info
widget_control,info.RawChannelQuickLook,/destroy

if( XRegistered ('mqlhchr')) then begin ; histo channel
   widget_control,info.HistoChannelRawQuickLook,/destroy
endif

if( XRegistered ('mqlrchr')) then begin ; histo channel
   widget_control,info.RSliceChannelRawQuickLook,/destroy
endif

if( XRegistered ('mqlcchr')) then begin ; histo channel
   widget_control,info.CSliceChannelRawQuickLook,/destroy
endif


; statistics on channels
if(XRegistered ('mchstat')) then begin
    widget_control,info.StatChannelInfo,/destroy
endif
end
;_______________________________________________________________________
;***********************************************************************
pro mql_update_pixel_Channel_location,info


xsize = info.Channel.xplotsize 
ysize = info.Channel.yplotsize 
for i = 0,4 do begin 
    wset,info.Channel.draw_window_id[i]
; set up the pixel box window - this will initialize the
;                               mql_update_rampread.pro x and y positions.


    device,copy=[0,0,xsize,ysize, $
                 0,0,info.Channel.pixmapID[i]]

    xvalue = info.Channel.xpos
    yvalue = info.Channel.ypos     
    xcenter = xvalue + 0.5
    ycenter = yvalue + 0.5
    box_coords1 = [xcenter,(xcenter+1), $
                   ycenter,(ycenter+1)]

    plots,box_coords1[[0,0,1,1,0]],box_coords1[[2,3,3,2,2]],psym=0,/device


endfor
end

;_______________________________________________________________________
;***********************************************************************

; the event manager for the mql_display_Channel.pro (Display image by Channel)
pro mql_Channel_event,event

Widget_Control,event.id,Get_uValue=event_name
widget_control,event.top, Get_UValue = cinfo
widget_control,cinfo.info.Quicklook,Get_Uvalue = minfo

cinfo.info = minfo

iramp = minfo.ChannelR[0].iramp
jintegration = minfo.ChannelR[0].jintegration

if (widget_info(event.id,/TLB_SIZE_EVENTS) eq 1 ) then begin
    minfo.channel.xwindowsize = event.x
    minfo.channel.ywindowsize = event.y
    minfo.channel.uwindowsize = 1
    widget_control,event.top,set_uvalue = cinfo
    widget_control,cinfo.info.Quicklook,set_uvalue = minfo
    mql_display_Channel,minfo
    return
endif

case 1 of
;_______________________________________________________________________
; print images
    (strmid(event_name,0,7) EQ 'print_i') : begin
        print_Channel,minfo
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

; do some checks wrap around
       if(jintegration lt 0) then begin
            jintegration = minfo.data.nints-1
        endif 
       if(jintegration gt minfo.data.nints-1  ) then begin
            jintegration = 0
        endif


        
        minfo.ChannelR[*].jintegration = jintegration
       setup_Channel,minfo,jintegration,iramp
; Fill in the Subimage
        mql_grab_Channel_images,minfo
        for i = 0,4 do begin 
            mql_update_Channel,i,minfo
        endfor
        widget_control,minfo.Channel.integration_label,set_value= fix(jintegration+1)
        widget_control,minfo.Channel.frame_label,set_value= fix(iramp+1)



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

        if(iramp lt 0) then iramp = minfo.data.nramps-1
        if(iramp gt minfo.data.nramps-1  ) then iramp = 0

        minfo.ChannelR[*].iramp = iramp
       setup_Channel,minfo,jintegration,iramp
; Fill in the Subimage
        mql_grab_Channel_images,minfo
        for i = 0,4 do begin 
            mql_update_Channel,i,minfo
        endfor
        widget_control,minfo.Channel.integration_label,set_value= fix(jintegration+1)
        widget_control,minfo.Channel.frame_label,set_value= fix(iramp+1)
    end	

;_______________________________________________________________________

    (strmid(event_name,0,3) EQ 'bad') : begin

        if(event.index eq 0) then minfo.Channel.apply_bad = 1
        if(event.index eq 1) then minfo.Channel.apply_bad = 0

        mql_grab_Channel_images,minfo
        for i = 0,4 do begin 
            mql_update_Channel,i,minfo
        endfor

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
        if(minfo.channel.scalechannel -1 eq 5) then begin
            minfo.Channel.graph_range[graph_num,mm_val] = event.value
            minfo.Channel.default_scale[graph_num] = 0
            widget_control,minfo.Channel.recomputeID[graph_num],set_value=' Default Scale '
            mql_update_Channel,graph_num,minfo
        endif

; scale to channel

        if(minfo.channel.scalechannel-1 ne 5) then begin
            index = minfo.channel.scalechannel-1
            if(graph_num eq index)then begin
                minfo.Channel.graph_range[graph_num,mm_val] = event.value

                minfo.Channel.default_scale[graph_num] = 0
                widget_control,minfo.Channel.recomputeID[graph_num],set_value=' Default Scale ' 
            endif


            for i = 0,4 do begin

                mql_update_Channel,i,minfo
            endfor
        endif


    end

;_______________________________________________________________________
; Default Scale Button
;_______________________________________________________________________
    (strmid(event_name,0,5) EQ 'scale') : begin
        graphno = fix(strmid(event_name,5,1))-1

        if(minfo.channel.scalechannel-1 eq 5) then begin
            widget_control,minfo.channel.recomputeID[graphno],set_value=' Image Scale '
            minfo.Channel.default_scale[graphno] = 1
            mql_update_Channel,graphno,minfo

        endif else begin
            if(graphno eq minfo.channel.scalechannel -1) then begin
                widget_control,minfo.channel.recomputeID[graphno],set_value=' Image Scale '
                minfo.Channel.default_scale[graphno] = 1
                for i = 0,4 do begin
                    mql_update_Channel,i,minfo
                endfor
            endif
        endelse
    end
;_______________________________________________________________________

; Display statistics on the image 
;_______________________________________________________________________
    (strmid(event_name,0,4) EQ 'stat') : begin
	mql_display_Channel_stat,minfo
    end

;_______________________________________________________________________
; Plotting options: row slice or  column slice
;_______________________________________________________________________
    (strmid(event_name,0,4) EQ 'plot') : begin


        if(event.index eq 1) then begin ; Histogram
            mql_display_Channel_histo,minfo  
        endif

 
        if(event.index eq 2) then begin ; column slice
            mql_display_Channel_colslice,minfo  
        endif

        if(event.index eq 3) then begin ; row slice
            mql_display_Channel_rowslice,minfo
        endif

        widget_control,minfo.Channel.optionMenu,set_droplist_select=0
        

    end
;_______________________________________________________________________
; Display the pixel values in a seperate window or do not pop up the box
;_______________________________________________________________________
    (strmid(event_name,0,8) EQ 'pdisplay') : begin
        no = fix(strmid(event_name,8,1))
        if(no eq 1) then minfo.Channel.pixeldisplay = 1
        if(no eq 2) then minfo.Channel.pixeldisplay = 0

        xvalue = minfo.Channel.xpos 
        yvalue = minfo.Channel.ypos 

        xposfull = (xvalue/minfo.channel.zoom)+ minfo.channel.xstart_zoom
        yposfull = (yvalue/minfo.channel.zoom)+ minfo.channel.ystart_zoom

        minfo.Channel.xposfull = xposfull
        minfo.Channel.yposfull = yposfull
        if(no eq 1) then mql_pixel_Channel_display,xposfull,yposfull,minfo

    end

;_______________________________________________________________________

    (strmid(event_name,0,6) EQ 'ascale') : begin
        minfo.channel.scalechannel = event.index+1

        for i = 0,4 do begin

            if(minfo.channel.scalechannel-1 eq 5) then begin
                widget_control,minfo.channel.recomputeID[i],set_value=' Image Scale '
                minfo.channel.default_scale[i] = 1
            endif

            if(minfo.channel.scalechannel-1 eq i) then begin
                widget_control,minfo.channel.recomputeID[i,0],set_value=' Image Scale '
                minfo.channel.default_scale[i] = 1
            endif

            mql_update_channel,i,minfo
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
           x = (xvalue)/minfo.channel.zoom
           y = (yvalue)/minfo.channel.zoom
           if(x gt minfo.data.image_xsize/4) then x = (minfo.data.image_xsize/4)-1
           if(y gt minfo.data.image_ysize) then y = minfo.data.image_ysize-1
           xvalue = x * minfo.channel.zoom
           yvalue = y * minfo.channel.zoom
;;

           minfo.Channel.xpos = xvalue
           minfo.Channel.ypos = yvalue

           xposfull = (xvalue/minfo.channel.zoom)+ minfo.channel.xstart_zoom
           yposfull = (yvalue/minfo.channel.zoom)+ minfo.channel.ystart_zoom

           minfo.Channel.xposfull = xposfull
           minfo.Channel.yposfull = yposfull




           if(xposfull gt minfo.data.image_xsize/4 or yposfull gt minfo.data.image_ysize) then begin
               ok = dialog_message(" Area out of range",/Information)
               return
           endif
           
           mql_update_pixel_Channel_location,minfo


           widget_control,cinfo.info.Quicklook,set_uvalue = minfo	
           if(minfo.Channel.pixeldisplay eq 1) then  begin
               xp_value = minfo.Channel.xposfull
               yp_value = minfo.Channel.yposfull
               if(XRegistered ('mCpixel') ) then begin
                  minfo.channel_pixel.xvalue = xp_value+1	
                  minfo.channel_pixel.yvalue = yp_value+1
                   mql_update_pixel_Channel_info,minfo
               endif else begin
                   mql_pixel_Channel_display,xp_value,yp_value,minfo
               endelse
           endif
       endif

   end
;_______________________________________________________________________e
; zoom images
;_______________________________________________________________________
   (strmid(event_name,0,4) EQ 'zoom') : begin

         if(event.index eq 0) then minfo.channel.zoom = 1.0
         if(event.index eq 1) then minfo.channel.zoom = 2.0
         if(event.index eq 2) then minfo.channel.zoom = 4.0
         if(event.index eq 3) then minfo.channel.zoom = 8.0
         if(event.index eq 4) then minfo.channel.zoom = 16.0
	 mql_grab_Channel_images,minfo
	 for i = 0,4 do begin
             mql_update_Channel,i,minfo
         endfor

         ; redefine the xpos and y pos value in new zoom window

         xpos_new = minfo.channel.xposfull -minfo.channel.xstart_zoom 
         ypos_new = minfo.channel.yposfull -minfo.channel.ystart_zoom
         minfo.channel.xpos = (xpos_new)*minfo.channel.zoom
         minfo.channel.ypos = (ypos_new)*minfo.channel.zoom


         mql_update_pixel_Channel_location,minfo

     end


endcase

cinfo.info = minfo
widget_control,event.top,set_uvalue = cinfo

widget_control,cinfo.info.Quicklook,set_uvalue = minfo
end

;***********************************************************************
;***********************************************************************
pro mql_display_Channel,info

window,1,/pixmap
wdelete,1
iramp = fix(info.ChannelR[0].iramp)
jintegration = fix(info.ChannelR[0].jintegration)
xplotsize = info.data.image_xsize/4
yplotsize = info.data.image_ysize
info.Channel.zoom  = 1

zoom = 1
if (yplotsize lt 1024) then begin
    plotsize = yplotsize
    if(xplotsize*4 gt yplotsize) then plotsize = xplotsize*4
    zoom = fix(1024/plotsize)
    info.Channel.zoom = zoom
    xplotsize = (info.data.image_xsize/4) * zoom
    yplotsize = info.data.image_ysize * zoom
endif


; widget window parameters
xwidget_size = 1600
ywidget_size = 1350
xsize_scroll = 1550
ysize_scroll = 1100

if(info.channel.uwindowsize eq 1) then begin ; user has set window size 
    xsize_scroll = info.channel.xwindowsize
    ysize_scroll = info.channel.ywindowsize
endif

if(info.control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.control.x_scroll_window
if(info.control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.control.y_scroll_window

if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10


stitle = "MIRI Quick Look- 5 Channel Plots of Science Frame Images" + info.version
svalue = " 5 Channel Plots of Science Frame Images: "


if( XRegistered ('mqldchr')) then begin
    widget_control,info.RawChannelQuickLook,/destroy
endif


RawChannelQuickLook = widget_base(title=stitle ,$
                                  col = 1,mbar = menuBar,$
                                  group_leader = info.QuickLook,$
                                  xsize =  xwidget_size,$
                                  ysize=   ywidget_size,/scroll,$
                                  x_scroll_size= xsize_scroll,$
                                  y_scroll_size = ysize_scroll,/TLB_SIZE_EVENTS)


; add quit button
QuitMenu = widget_button(menuBar,value="Quit",font = info.font2)
quitbutton = widget_button(quitmenu,value="Quit",event_pro='mql_channel_quit')

PrintMenu = widget_button(menuBar,value="Print",font = info.font2)
printbutton = widget_button(Printmenu,value="Print 5 Channel Images",uvalue='print_i')

DMenu = widget_button(menuBar,value="Display Pixel Values",font = info.font2)
Dbutton1 = widget_button(Dmenu,value="Display Pixel Values",uvalue='pdisplay1')
Dbutton2 = widget_button(Dmenu,value="Do Not Display Pixel Values",uvalue='pdisplay2')


title_base = widget_base(RawChannelQuickLook,col=3,/align_center)

tlabelID = widget_label(title_base,value =svalue,font=info.font5)
titlelabel = widget_label(title_base,value = info.control.filename_raw, font=info.font3)



;********
blankspaces  = '       '
options = ['Plot Options: ', 'Histogram', 'Column Slice','Row Slice ']


badpixeldisplay = [' Applying Bad Pixel Mask',$
              'Not applying Bad Pixel Mask ']

scaledisplay = ['Scale All to Channel 1', 'Scale All to Channel 2', $
                'Scale All to Channel 3', 'Scale All to Channel 4', $
                'Scale All to Channel 5', 'Scale to Individual Channel']

zoomdisplay = ['No Zoom ', 'Zoom (2X)', $
               'Zoom (4x)', 'Zoom (8x)', 'Zoom (16x)']
move_base = widget_base(RawChannelQuickLook,/row,/align_left)

integration_label = cw_field(move_base,$
                    title=" Integration # ",font=info.font5, $
                    uvalue="integration",/integer,/return_events, $
                    value=jintegration+1,xsize=4,$
                    fieldfont=info.font3)

labelID = widget_button(move_base,uvalue='integr_move_dn',value='<',font=info.font3)
labelID = widget_button(move_base,uvalue='integr_move_up',value='>',font=info.font3)

frame_label = cw_field(move_base,$
              title=" Frame # ",font=info.font5, $
              uvalue="frame",/integer,/return_events, $
              value=iramp+1,xsize=4,fieldfont=info.font3)
labelID = widget_button(move_base,uvalue='fram_move_dn',value='<',font=info.font3)
labelID = widget_button(move_base,uvalue='fram_move_up',value='>',font=info.font3)



scale_label  = widget_droplist(move_base,value=scaledisplay,uvalue='ascale',$
	font= info.font5)

stat_label = widget_button(move_base,value='Get Statistics',uvalue='stat',font=info.font5)
zoom_labelID = widget_droplist(move_base,value=zoomdisplay,uvalue='zoom',font=info.font5)
optionMenu = widget_droplist(move_base,value=options,uvalue='plot',font=info.font5)



info.channel.apply_bad = info.control.display_apply_bad
if(info.channel.apply_bad) then begin 
    DMenu = widget_droplist(move_base,value=badpixeldisplay,uvalue='badpixel',font=info.font5)
endif
;Set up the GUI


;_______________________________________________________________________
graphID_master0 = widget_base(RawChannelQuickLook,row=1)
graphID_master1 = widget_base(RawChannelQuickLook,row=1)


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
graph_range[0,1] = info.ChannelR[0].range_max
graph_range[0,0] = info.ChannelR[0].range_min

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
graph_range[1,1] = info.ChannelR[1].range_max
graph_range[1,0] = info.ChannelR[1].range_min
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
graph_range[2,1] = info.ChannelR[2].range_max
graph_range[2,0] = info.ChannelR[2].range_min
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
recomputeID[2] = widget_button(range_base,value=' Image  Scale',$
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
graph_range[3,1] = info.ChannelR[3].range_max
graph_range[3,0] = info.ChannelR[3].range_min
titleID = widget_label(graphID14, value = " Channel 4 Image ",$
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
graph_range[4,1] = info.ChannelR[4].range_max
graph_range[4,0] = info.ChannelR[4].range_min
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
longtag = widget_label(RawChannelQuicklook,value = longline)

Widget_control,RawChannelQuickLook,/Realize

XManager,'mqldchr',RawChannelQuickLook,/No_Block,event_handler='mql_Channel_event'

;_______________________________________________________________________
for i = 0, 4 do begin
    widget_control,graphID[i],get_value=tdraw_id
    draw_window_id[i] = tdraw_id
    window,/pixmap,xsize=xplotsize,ysize=yplotsize,/free
    pixmapID[i] = !D.WINDOW
endfor
info.Channel.recomputeID     = recomputeID
info.Channel.mlabelID        =mlabelID
info.Channel.slabelID = slabelID
info.Channel.rlabelID = rlabelID
info.Channel.graphID = graphID
info.Channel.pixmapID = pixmapID
info.Channel.draw_window_id = draw_window_id
info.Channel.default_scale = default_scale
info.Channel.graph_range = graph_range
info.Channel.xplotsize = xplotsize
info.Channel.yplotsize = yplotsize
info.Channel.integration_label = integration_label
info.Channel.frame_label = frame_label
info.Channel.optionMenu = optionMenu

info.Channel.xpos = 5
info.Channel.ypos = 5
info.channel.xposfull = info.channel.xpos
info.channel.yposfull = info.channel.ypos
info.Channel.pixeldisplay = 1
info.Channel.zoom_labelID = zoom_labelID
info.channel.scalechannel = 1

cinfo = {         info            : info}



info.RawChannelQuickLook = RawChannelQuickLook
Widget_Control,info.RawChannelQuickLook,Set_UValue=cinfo
Widget_Control,info.QuickLook,Set_UValue=info
loadct,info.col_table,/silent
;_______________________________________________________________________
; Fill in the Subimage
mql_grab_Channel_images,info
;_______________________________________________________________________




for i = 0,4 do begin
    mql_update_Channel,i,info
    Widget_Control,info.RawChannelQuickLook,Set_UValue=cinfo
    Widget_Control,info.QuickLook,Set_UValue=info        
endfor

mql_update_pixel_channel_location,info
Widget_Control,info.QuickLook,Set_UValue=info

end
