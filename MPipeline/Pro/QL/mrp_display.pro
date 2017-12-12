;***********************************************************************
;_______________________________________________________________________
pro mrp_quit,event
;_______________________________________________________________________
widget_control,event.top, Get_UValue = ginfo	
widget_control,ginfo.info.QuickLook,Get_Uvalue = info
wdelete,info.refp.pixmapID[0]
wdelete,info.refp.pixmapID[1]
widget_control,info.RefPixelQuickLook,/destroy

end

;***********************************************************************
; _______________________________________________________________________
pro mrp_setup_Channel,info
; _______________________________________________________________________
i = info.refp.integrationNO
j = info.refp.rampNO


pixelL  = (*info.refpixel_data.prefpixelL)[i,j,*,*]
pixelR  = (*info.refpixel_data.prefpixelR)[i,j,*,*]
    

for m = 0,3 do begin 
    time_image = fltarr(info.data.image_ysize*2)
    time_image2 = fltarr(info.data.image_ysize*2)
    time = fltarr(info.data.image_ysize*2)
    t = 0.0
    k = long(0)
    for p = 0,info.data.image_ysize-1 do begin
        time_image[k] = pixelL[0,0,m,p]
        time_image2[k] = time_image[k]
        t = t + 4
        time[k]  = t
        k = long(k) + 1
        time_image[k] = pixelR[0,0,m,p]
        time_image2[k] =time_image[k]
        t = t + 256.0 + 4.0
        time[k] = t
        t = t + 5.0
        k = long(k) + 1
    endfor
    if ptr_valid ( info.channelRP[m].ptimedata) then ptr_free,$
      info.channelRP[m].ptimedata
    info.channelRP[m].ptimedata = ptr_new(time_image)

    if ptr_valid ( info.channelRP[m].ptimedata2) then ptr_free,$
      info.channelRP[m].ptimedata2
    info.channelRP[m].ptimedata2 = ptr_new(time_image2)

    if ptr_valid ( info.channelRP[m].ptime) then ptr_free,$
      info.channelRP[m].ptime
    info.channelRP[m].ptime = ptr_new(time)
    

    get_image_stat,time_image,image_mean,stdev_pixel,image_min,$
                   image_max,irange_min,irange_max,image_median,$
                   stdev_mean,skew,ngood,nbad
    info.channelRP[m].mean = image_mean
    info.channelRP[m].median = image_median
    info.channelRP[m].stdev = stdev_pixel
    info.channelRP[m].min = image_min
    info.channelRP[m].max = image_max
    info.channelRP[m].range_min = irange_min
    info.channelRP[m].range_max = irange_max
    info.channelRP[m].skew = skew
    info.channelRP[m].stdev_mean = stdev_mean
    info.channelRP[m].ximage_range[0] = 0
    info.channelRP[m].ximage_range[1] = 0
    info.channelRP[m].yimage_range[0] = 0
    info.channelRP[m].yimage_range[1] = 0

    time_image = 0
endfor

pixelL = 0
pixelR = 0
widget_control,info.QuickLook,Set_Uvalue = info

end


;***********************************************************************
; _______________________________________________________________________
pro mrp_display,info
; _______________________________________________________________________
; Display the reference reference pixels


window,1,/pixmap
wdelete,1
if(XRegistered ('mrp')) then begin
    widget_control,info.RefPixelQuickLook,/destroy
endif

; widget window parameters
xwidget_size = 1400
ywidget_size = 1050

xsize_scroll = 1220
ysize_scroll = 980

if(info.refp.uwindowsize eq 1) then begin ; user has set window size 
    xsize_scroll = info.refp.xwindowsize
    ysize_scroll = info.refp.ywindowsize
endif
if(info.control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.control.x_scroll_window
if(info.control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.control.y_scroll_window
if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10





; if the user set the scroll window size larger than widget window
; size- resize scroll limits
if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size
if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size

mtitle = "MIRI QL: Border Reference Pixels for " + info.control.filename_raw
RefPixelQuickLook = widget_base(title=mtitle,$
                           col = 1,mbar = menuBar,group_leader = info.QuickLook,$
                           xsize = xwidget_size,$
                           ysize = ywidget_size,/scroll,$
                           x_scroll_size= xsize_scroll,$
                           y_scroll_size = ysize_scroll,/TLB_SIZE_EVENTs)

info.RefPixelQuickLook = RefPixelQuickLook

;********
; build the menubar
;********
QuitMenu = widget_button(menuBar,value="Quit",font = info.font2)
quitbutton = widget_button(quitmenu,value="Quit",event_pro='mrp_quit')

PrintMenu = widget_button(menuBar,value="Print",font = info.font2)
printbutton = widget_button(Printmenu,value="Print Time Ordered Reference Pixel Plot ",uvalue='print')



;Set up the GUI

;*********
;Setup main panel
;*********
graphID_master0 = widget_base(info.RefPixelQuickLook,row=1)
graphID_master1 = widget_base(info.RefPixelQuickLook,row=1)


info.refp.graphID11 = widget_base(graphID_master1,col=1)
info.refp.graphID12 = widget_base(graphID_master1,col=1)
info.refp.graphID13 = widget_base(graphID_master1,col=1) 



;_______________________________________________________________________

info.refp.binfactorx = 4 ; set default 
info.refp.binfactory = 1 ; set default 
;_______________________________________________________________________
; defaults to start with 

info.refp.default_scale_graph[*] = 1

info.refp.integrationNO = info.control.int_num
info.refp.rampNO = info.control.frame_start
;print,'in mrp_display',info.control.int_num
if(info.data.coadd eq 1) then info.refp.rampNO = 0
i = info.refp.integrationNO
j = info.refp.rampNO
;_______________________________________________________________________  
; set up the images to be displayed
; default to start with first integration and first ramp
; 
;_______________________________________________________________________  
;-----------------------------------------------------------------------
; Information 
; button to change all the images- one for integration#  and 
;                                  one for frame #

iramp = info.refp.rampNO
jintegration = info.refp.IntegrationNO

move_base1 = widget_base(graphid_master0,row=1,/align_left)

moveframe_label = widget_label(move_base1,value='            ')


moveframe_label = widget_label(move_base1,value='Change Image Displayed',$
                                font=info.font5,/sunken_frame,/align_left)
;move_base1 = widget_base(graphid_master0,row=1,/align_left)
info.refp.integration_label = cw_field(move_base1,$
                    title="Integration # ",font=info.font5, $
                    uvalue="integration",/integer,/return_events, $
                    value=jintegration+1,xsize=4,$
                    fieldfont=info.font3)

labelID = widget_button(move_base1,uvalue='integr_move_dn',value='<',font=info.font3)
labelID = widget_button(move_base1,uvalue='integr_move_up',value='>',font=info.font3)

info.refp.frame_label = cw_field(move_base1,$
              title="Frame # ",font=info.font5, $
              uvalue="frame",/integer,/return_events, $
              value=iramp+1,xsize=4,fieldfont=info.font3)
labelID = widget_button(move_base1,uvalue='fram_move_dn',value='<',font=info.font3)
labelID = widget_button(move_base1,uvalue='fram_move_up',value='>',font=info.font3)




st = " Border Reference Pixels"

plot_name = widget_label(info.refp.graphid11,value = st,$
                           /align_left,font=info.font5,/sunken_frame)

LeftPixelSetA = 0
info.refp.LeftPixelSetA = LeftPixelSetA

LeftDataID = lonarr(2)

info.refp.LeftDataID = LeftDataID

range_min = (*info.refpixel_data.prange)(i,j,0)
range_max = (*info.refpixel_data.prange)(i,j,1)
info.refp.graph_range[0,0] = 0.0
info.refp.graph_range[0,1] = 0.0



ss =  '           '

info.refp.mlabelID[0] = widget_label(info.refp.graphid11,$
                         value=( 'Mean: ' + ss + '  Min: ' + ss + '   Max: ' + ss),$
                                      /align_left,font=info.font3)

base1 = widget_base(info.refp.graphID11,col=3,/align_left)

info.refp.image_recomputeID[0] = widget_button(base1,value=' Image Scale ',$
                                                font=info.font4,$
                                                uvalue = 'scale1')

info.refp.rlabelID[0,0] = cw_field(base1,title="min",font=info.font4,$
                                    uvalue="sr1_b",/float,/return_events,$
                                    xsize=info.xsize_label,value =range_min,$
                                    fieldfont = info.font4)

info.refp.rlabelID[0,1] = cw_field(base1,title="max",font=info.font4,$
                                    uvalue="sr1_t",/float,/return_events,$
                                    xsize = info.xsize_label,value =range_max,$
                                   fieldfont=info.font4)


;-----------------------------------------------------------------------
; Pixel Information

blank = widget_label(info.refp.graphid11,value=" ")
blank = widget_label(info.refp.graphid11,value=" ")


general_label= widget_label(info.refp.graphid11,$
                            value=" Zoom Region Information",/align_left,$
                            font=info.font5,/sunken_frame)
;; button to change 
pix_num_base = widget_base(info.refp.graphid11,row=1,/align_left)
labelID = widget_button(pix_num_base,uvalue='row_move_1',value='<',font=info.font3)
labelID = widget_button(pix_num_base,uvalue='row_move_2',value='>',font=info.font3)

info.refp.row = info.data.image_ysize/2 + 5
info.refp.row_label = cw_field(pix_num_base,title="row",font=info.font4, $
                                   uvalue="row_val",/integer,/return_events, $
                                   value=fix(info.refp.row+1),xsize=6,$  ;
                                  fieldfont=info.font3)


label = ' CH #   Left Value    Right Value     Delta '
stat = widget_label(info.refp.graphid11, value =label, /align_left,font=info.font5)
left = fltarr(4)
right = fltarr(4)
delta = fltarr(4)
left[*] =  0
right[*]=  0
delta[*] = 0
slab = strarr(4)

;_______________________________________________________________________
for i = 0,3 do begin
    inum = strcompress(string(i+1),/remove_all)
    slab[i] = ' ' + inum + '         ' + $
              strtrim(string(left[i],format="(g10.6)"),2) +    '       ' +$
              strtrim(string(right[i],format="(g10.6)"),2) +   '       ' +$
              strtrim(string(delta[i],format="(g10.6)"),2) 

    info.refp.clabelID[i] = widget_label(info.refp.graphid11,value=slab[i],/align_left,font=info.font3)
endfor

;_______________________________________________________________________
;graph 1,2; zoom window
;*****

blank = widget_label(info.refp.graphid11,value = '   ')

subt = "Zoom (25X) of  Border Ref Pixels "
graph_label = widget_label(info.refp.graphID11,$
                           value=subt,/align_center,$
                           font=info.font5,/sunken_frame)


info.refp.graph_range[1,0] = info.refp.graph_range[0,0]
info.refp.graph_range[1,1] = info.refp.graph_range[0,1]


info.refp.mlabelID[1] = widget_label(info.refp.graphid11,$
                         value=('Mean: ' + ss + '  Min: ' + ss + '   Max: ' + ss),$
                                      /align_left,font=info.font3,/dynamic_resize)


; min and max scale of  image
base = widget_base(info.refp.graphid11, col=3,/align_left)
info.refp.image_recomputeID[1] = widget_button(base,value='Image Scale',$
                                                font=info.font4,$
                                                uvalue = 'scale2')


info.refp.rlabelID[1,0] = cw_field(base,title="min",font=info.font4,$
                                    uvalue="sr2_b",/float,/return_events,$
                                    xsize=info.xsize_label,value =range_min,$
                                    fieldfont = info.font4)

info.refp.rlabelID[1,1] = cw_field(base,title="max",font=info.font4,$
                                    uvalue="sr2_t",/float,/return_events,$
                                    xsize = info.xsize_label,value =range_max,$
                                   fieldfont=info.font4)


label = widget_label(info.refp.graphid11,$
                     value = ' Left Pixels       Gap       Right Pixels ',/align_center)
info.refp.graphID[1] = widget_draw(info.refp.graphid11,$
                                    xsize =275,$ 
                                    ysize =275,$
                                    /Button_Events,$
                                    retain=info.retn,uvalue='npixel2')

base = widget_base(info.refp.graphid11, col=3,/align_left)
info.refp.channelID = widget_label(base,value=('Channel: NA '),$ 
                                          /align_left,font=info.font3)
info.refp.valueID = widget_label(base,value=('Value: NA    '),$
                                      /align_left,font=info.font3,/dynamic_resize)

info.refp.draw_box = 1 ; draw the box on the main window

info.refp.zboxID = widget_button(base,value='       Draw Box    ',$
                                                font=info.font4,$
                                                uvalue = 'draw')
;_______________________________________________________________________
st = "Left  Right"
title = widget_label(info.refp.graphid12,value = st,/sunken_frame,font=info.fontsmall,/align_center)

info.refp.graphID[0] = widget_draw(info.refp.graphid12,$
                                  xsize =40,$ 
                                  ysize =info.data.image_ysize,$
                                  /Button_Events,$
                                  retain=info.retn,uvalue='npixel1')

;_______________________________________________________________________
;*****
;Plot values verse time
;*****
st = ' Reference Pixel DN vs Time per Channel '
plot_name = widget_label(info.refp.graphid13,value = st,$
                           /align_center,font=info.font5,/sunken_frame)
info.refp.graphID[2] = widget_draw(info.refp.graphID13,$
                                  xsize = 800,$
                                  ysize=  300,$
                                  retain=info.retn)

;_______________________________________________________________________
min = (*info.refpixel_data.prange)[0,0,0]
max = (*info.refpixel_data.prange)[0,0,1]


info.refp.time_range[0,0] = 0
info.refp.time_range[0,1] =  269*1024.0
info.refp.time_range[1,0] = min
info.refp.time_range[1,1] = max


info.refp.time_default_range[*] = 1

rangeID = lonarr(2,2)
recomputeID = lonarr(2)


xrange = widget_label(info.refp.graphID13,value ='Change Plot range', /align_left,$
                      font=info.font5,/sunken_frame)
xlabel_base = widget_base(info.refp.graphID13,/row,/align_left)


info.refp.trangeID[0,0] = cw_field(Xlabel_base,$
                  title=" X Min ",font=info.font5, $
                  uvalue="cr1_b",/return_events, $
                  value=info.refp.time_range[0,0],xsize=9,$
                  fieldfont=info.font3)

info.refp.trangeID[0,1] = cw_field(Xlabel_base,$
                  title=" X Max ",font=info.font5, $
                  uvalue="cr1_t",/return_events, $
                  value=info.refp.time_range[0,1],xsize=9,$
                  fieldfont=info.font3)
info.refp.time_recomputeID[0] = widget_button(xlabel_base,value='Plot Range',$font=info.font4,$
                                                uvalue = 'range1')


ylabel_base = widget_base(info.refp.graphID13,col=3,/align_left)


info.refp.trangeID[1,0] = cw_field(xlabel_base,$
                  title=" Y Min ",font=info.font5, $
                  uvalue="cr2_b",/float,/return_events, $
                  value=info.refp.time_range[1,0],xsize=9,$
                  fieldfont=info.font3)

info.refp.trangeID[1,1] = cw_field(xlabel_base,$
                  title=" Y Max ",font=info.font5, $
                  uvalue="cr2_t",/float,/return_events, $
                  value=info.refp.time_range[1,1],xsize=9,$
                  fieldfont=info.font3)
info.refp.time_recomputeID[1] = widget_button(xlabel_base,value='Plot Range',$font=info.font4,$
                                                uvalue = 'range2')
;_______________________________________________________________________
Name = ["Channel 1" ,"Channel 2" ,"Channel 3" ,"Channel 4"  ]
imBases = lonarr(4)
onButton  = lonarr(4)
offButton = lonarr(4)
onvalue = intarr(4) 
offvalue = intarr(4)
onvalue(*) = 1

blank_label= widget_label(info.refp.graphID13,value="    ")

base = widget_base(info.refp.graphID13,/row,/align_left)
amp = widget_label(base, value =' Select Data to Plot', $
                      /align_left,font=info.font5,/sunken_frame)

OverplotLineID = lonarr(2)
overplotline = 0
lines = widget_label(base,value = '           Plot lines through points')
oBase = Widget_base(base,/row,/nonexclusive)
OverplotLineID[0] = Widget_button(oBase, Value = ' Yes ',uvalue = 'line1')
widget_control,OverplotLineID[0],Set_Button = 0

OverplotLineID[1] = Widget_Button(oBase, Value = ' No ',uvalue = 'line2')
widget_control,OverplotLineID[1],Set_Button = 1


LeftPixels = lonarr(3)


info.refp.LeftPixelsID = LeftPixels
info.refp.overplotlineID = overplotlineID
info.refp.overplotline = overplotline

info.refp.ploteven = 1
info.refp.plotodd = 1
all_base = widget_base(info.refp.graphID13,/row,/align_left)

base1 = Widget_Base(all_base,/row,/exclusive)
info.refp.evenoddbutton = widget_button(base1,$
	Value=' All rows',uvalue ='trowa')
widget_control,info.refp.evenoddbutton,set_button = 1


base1 = Widget_Base(all_base,/row,/exclusive)
info.refp.evenbutton = widget_button(base1,$
	Value=' Even Rows Only ',uvalue ='trowe')
widget_control,info.refp.evenbutton,set_button = 0

base1 = Widget_Base(all_base,/row,/exclusive)
info.refp.oddbutton = widget_button(base1,$
	Value=' Odd Rows Only',uvalue ='trowo')
widget_control,info.refp.oddbutton,set_button = 0



OverplotwhiteID = lonarr(2)
info.refp.plotwhite = 0
lines = widget_label(all_base,value = '   Plot Odd Rows in White')
oBase = Widget_base(all_base,/row,/nonexclusive)
OverplotWhiteID[0] = Widget_button(oBase, Value = ' Yes ',uvalue = 'White1')
widget_control,OverplotWhiteID[0],Set_Button = 0

OverplotWhiteID[1] = Widget_Button(oBase, Value = ' No ',uvalue = 'White2')
widget_control,OverplotWhiteID[1],Set_Button = 1

info.refp.overplotWhiteID = overplotWhiteID



info.refp.plotrightleft = 1
info.refp.plotleft = 0
info.refp.plotright = 0
info.refp.plotwhite = 0



all_base = widget_base(info.refp.graphID13,col=3,/align_left)

base1 = Widget_Base(all_base,/row,/exclusive)
info.refp.rightleftbutton = Widget_button(Base1,$
 Value = 'Left and Right Data',uvalue = 'tcola')	
widget_control, info.refp.rightleftbutton,Set_Button = 1

base1 = Widget_Base(all_base,/row,/exclusive)
info.refp.leftbutton = widget_button(base1,$
Value=' Left Side Only',uvalue ='tcoll')
widget_control,info.refp.leftbutton,set_button = 0

base1 = Widget_Base(all_base,/row,/exclusive)
info.refp.rightbutton = widget_button(base1,$
	Value=' Right Side Only',uvalue ='tcolr')
widget_control,info.refp.rightbutton,set_button = 0

all_base = widget_base(info.refp.graphID13,/row,/align_left)
amp = widget_label(all_base, value =' Select Channel to Plot', $
                      /align_left,font=info.font5,/sunken_frame)
info.refp.allbutton = widget_button(all_base,Value = ' Select All',uvalue='allplot1')
widget_control,info.refp.allbutton,Set_Button = 1
info.refp.nonebutton = widget_button(all_base,Value = ' Select None',uvalue='allplot2')
widget_control,info.refp.nonebutton,Set_Button = 0


boxright = lonarr(4)
boxleft= lonarr(4)
boxleft2= lonarr(4)
for i = 0,3 do begin
    imBases[i] = Widget_Base(info.refp.graphID13,/row)

    iName = Widget_label(imbases[i],value = Name[i])
    onBase = Widget_base(imBases[i],/row,/nonexclusive)
    suvalue = strcompress('on'+ string(i+1),/remove_all)
    onButton[i] = Widget_button(onBase, Value = ' ON ',uvalue = suvalue)
    widget_control, onButton[i],Set_Button = onvalue[i]

    offBase = Widget_base(imBases[i],/row,/nonexclusive)
    suvalue = strcompress('off'+ string(i+1),/remove_all)
    offButton[i] = Widget_Button(offBase, Value = ' OFF ',uvalue = suvalue)
    widget_control, offButton[i],Set_Button = offvalue[i]

    leftlabel = widget_label(imBases[i],value = ' Left Side (1-4)')
    boxleft[i] = widget_draw(imBases[i],scr_xsize=50,scr_ysize=20, $
                               frame=1)

    rightlabel = widget_label(imBases[i],value = ' Right Side')
    boxright[i] = widget_draw(imBases[i],scr_xsize=50,scr_ysize=20, $
                               frame=1)


endfor



info.refp.onbutton        = onbutton
info.refp.offbutton       = offbutton
info.refp.onvalue         = onvalue
info.refp.offvalue        = offvalue




;-----------------------------------------------------------------------
longline = '                                                                                                                        '
longtag = widget_label(RefPixelQuicklook,value = longline)
;_______________________________________________________________________
; realize main panel
Widget_control,info.RefPixelQuickLook,/Realize
XManager,'mrp',info.RefPixelQuickLook,/No_Block,event_handler='mrp_event'


for i = 0,3 do begin
  widget_control,boxleft[i],get_value=tdraw_id
  info.refp.draw_box_left[i] = tdraw_id

  widget_control,boxright[i],get_value=tdraw_id
  info.refp.draw_box_right[i] = tdraw_id
endfor


; get the window ids of the draw windows


n_draw = n_elements(info.refp.graphID)
for i = 0,(n_draw-1) do begin
    widget_control,info.refp.graphID[i],get_value=tdraw_id
    info.refp.draw_window_id[i] = tdraw_id
    if( i eq 0) then window,/pixmap,xsize=40,ysize=info.data.image_ysize,/free
    if( i eq 1) then window,/pixmap,xsize=275,ysize=275,/free
    if(i le 1) then info.refp.pixmapID[i] = !D.WINDOW
endfor



; reference border pixel image display
mrp_update_refpixel,info
mrp_update_row_info,info
mrp_update_zoom_image,info
mrp_draw_zoom_box,info

; reference pixel = time ordered display
mrp_update_TimeChannel,info



Widget_Control,info.QuickLook,Set_UValue=info
sinfo = {info        : info}

Widget_Control,info.RefPixelQuickLook,Set_UValue=sinfo
Widget_Control,info.QuickLook,Set_UValue=info
;print, ' Done displaying data'
end
