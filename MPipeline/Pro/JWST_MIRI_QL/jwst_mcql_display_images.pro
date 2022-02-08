;***********************************************************************
; This tool displays the Rate File  and other planes of data from the
; JWST  pipeline. The user can zoom the images, query pixel
 ; values and get statistics on the images.

;_______________________________________________________________________
pro jwst_mcql_quit,event
;_______________________________________________________________________
widget_control,event.top, Get_UValue = tinfo
widget_control,tinfo.info.jwst_QuickLook,Get_UValue=info

print,'Exiting MIRI QuickLook - Cal and Slope display'
widget_control,info.jwst_CalQuickLook,/destroy
end
;_______________________________________________________________________
pro jwst_mcql_update_pixel_location,info
;_______________________________________________________________________
ij = info.jwst_cal.current_graph
wset,info.jwst_cal.draw_window_id[ij]
; set up the pixel box window - this will initialize the
;                               mql_update_rampread.pro x and y positions.

xsize_image = fix(info.jwst_data.slope_xsize/info.jwst_cal.binfactor) 
ysize_image = fix(info.jwst_data.slope_ysize/info.jwst_cal.binfactor)

device,copy=[0,0,xsize_image,ysize_image, $
             0,0,info.jwst_cal.pixmapID[ij]]

factorx = 1
factory = 1
if(ij eq 1) then begin 
    factorx = info.jwst_cal.binfactor/info.jwst_cal.scale_zoom
    factory = info.jwst_cal.binfactor/info.jwst_cal.scale_zoom
endif

xvalue = info.jwst_cal.x_pos * factorx
yvalue = info.jwst_cal.y_pos * factory

xcenter = xvalue + 0.5
ycenter = yvalue + 0.5

box_coords1 = [xcenter,(xcenter+1), $
               ycenter,(ycenter+1)]

plots,box_coords1[[0,0,1,1,0]],box_coords1[[2,3,3,2,2]],psym=0,/device

end
;_______________________________________________________________________
pro jwst_mcql_update_pixel_stat,info
;_______________________________________________________________________
x = info.jwst_cal.x_pos*info.jwst_cal.binfactor
y = info.jwst_cal.y_pos*info.jwst_cal.binfactor

signal1 = (*info.jwst_data.pcal1)[x,y,0]
error1 = (*info.jwst_data.pcal1)[x,y,1]
dq1 = (*info.jwst_data.pcal1)[x,y,2]

if (info.jwst_cal.data_type[0] eq 3) then info.jwst_cal.pix_statLabel1 = ["Image 1 Cal (MJy/sr)",  "Image 1 Error",  "DQ flag"] 
if (info.jwst_cal.data_type[0] eq 1) then info.jwst_cal.pix_statLabel1 = ["Image 1 Rate (DN/s)",  "Image 1 Error",  "DQ flag"] 

if (info.jwst_cal.data_type[1] eq 3) then info.jwst_cal.pix_statLabel2 = ["Image 2 Cal (MJy/sr)",  "Image 2 Error",  "DQ flag"] 
if (info.jwst_cal.data_type[1] eq 1) then info.jwst_cal.pix_statLabel2 = ["Image 2 Rate (DN/s)",  "Image 2 Error",  "DQ flag"] 

sfin = strtrim(string(signal1,format="("+info.jwst_cal.pix_statFormat1[0]+")"),2)
se = strtrim(string(error1,format="("+info.jwst_cal.pix_statFormat1[1]+")"),2)
sdq = strtrim(string(dq1,format="("+info.jwst_cal.pix_statFormat1[2]+")"),2)

widget_control,info.jwst_cal.pix_statID1[0],set_value= info.jwst_cal.pix_statLabel1[0] + ' = ' + sfin
widget_control,info.jwst_cal.pix_statID1[1],set_value= info.jwst_cal.pix_statLabel1[1] + ' = ' + se
widget_control,info.jwst_cal.pix_statID1[2],set_value= info.jwst_cal.pix_statLabel1[2] + ' = ' + sdq

signal2 = (*info.jwst_data.pcal2)[x,y,0]
unc2 = (*info.jwst_data.pcal2)[x,y,1]
dq2 = (*info.jwst_data.pcal2)[x,y,2]

ss = strtrim(string(signal2,format="("+info.jwst_cal.pix_statFormat2[0]+")"),2)
su = strtrim(string(unc2,format="("+info.jwst_cal.pix_statFormat2[1]+")"),2)
sf = strtrim(string(dq2,format="("+info.jwst_cal.pix_statFormat2[2]+")"),2)

widget_control,info.jwst_cal.pix_statID2[0],set_value= info.jwst_cal.pix_statLabel2[0] + ' = ' + ss
widget_control,info.jwst_cal.pix_statID2[1],set_value= info.jwst_cal.pix_statLabel2[1] + ' = ' + su
widget_control,info.jwst_cal.pix_statID2[2],set_value= info.jwst_cal.pix_statLabel2[2] + ' = ' + sf

end
;_______________________________________________________________________

pro jwst_mcql_display_images,info
;_______________________________________________________________________
window,2,/pixmap
wdelete,2
if(XRegistered ('jwst_mcql')) then begin
    widget_control,info.jwst_CalQuickLook,/destroy
endif
;*********
;Setup main panel
;*********
;_______________________________________________________________________
; widget window parameters
xwidget_size = 950
ywidget_size = 910
xsize_scroll = 1250
ysize_scroll = 1250

if(info.jwst_cal.uwindowsize eq 1) then begin ; user has set window size 
    xsize_scroll = info.jwst_cal.xwindowsize
    ysize_scroll = info.jwst_cal.ywindowsize
endif

if(info.jwst_control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.jwst_control.x_scroll_window
if(info.jwst_control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.jwst_control.y_scroll_window

if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10
;_______________________________________________________________________
CalQuickLook = widget_base(title="JWST MIRI Quick Look- Rate & Cal Images" + info.jwst_version,$
                             col = 1,mbar = menuBar,group_leader = info.jwst_QuickLook,$
                             xsize = xwidget_size,$
                             ysize = ywidget_size,/scroll,$
                             x_scroll_size= xsize_scroll,$
                             y_scroll_size = ysize_scroll,/TLB_SIZE_EVENTS)

info.jwst_CalQuickLook = CalQuickLook
;********
; build the menubar
;********
QuitMenu = widget_button(menuBar,value="Quit",font = info.font2)
quitbutton = widget_button(quitmenu,value="Quit",event_pro='jwst_mcql_quit')

hMenu = widget_button(menuBar,value="Display Header",font = info.font2)
hsMenu = widget_button(hmenu,value="Display Cal Header",uvalue='cheader')
hcMenu = widget_button(hmenu,value="Display Rate Header",uvalue='sheader')

statMenu = widget_button(menuBar,value="Statistics",font = info.font2)
statbutton = widget_button(statmenu,value="Get Statistics on Images",uvalue = 'Stat')

;PMenu = widget_button(menuBar,value="Print",font = info.font2)
;PbuttonS = widget_button(Pmenu,value = "Print Plot 1",uvalue='print_1')
;PbuttonZ = widget_button(Pmenu,value = "Print Zoom Image (Plot 2)",uvalue='print_Z')
;PbuttonU = widget_button(Pmenu,value = "Print Plot 2",uvalue='print_2')

filelabelID = widget_label(info.jwst_CalQuickLook, $
                           value=info.jwst_control.filename_slope,/align_left, $
                           font=info.font2,/dynamic_resize)
;_______________________________________________________________________
; determine the main window display based on scale and image size

xsize = info.jwst_data.slope_xsize/info.jwst_cal.binfactor
ysize = info.jwst_data.slope_ysize/info.jwst_cal.binfactor
info.jwst_cal.xplot_size = fix(xsize)
info.jwst_cal.yplot_size = fix(ysize)

info.jwst_cal.current_graph = 0
;*********
; Draw Main Display Window
;*********
graphID_master1 = widget_base(info.jwst_CalQuickLook,row=1)
graphID_master2 = widget_base(info.jwst_CalQuickLook,row=1)

info.jwst_cal.graphID11 = widget_base(graphID_master1,col=1)
info.jwst_cal.graphID12 = widget_base(graphID_master1,col=1)
infoID00 = widget_base(graphID_master1,col=1)

info.jwst_cal.graphID21 = widget_base(graphID_master2,col=1)
info.jwst_cal.graphID22 = widget_base(graphID_master2,col=1)
infoID01 = widget_base(graphID_master2,col=1)
;_______________________________________________________________________
; set up structure for pass information around
;_______________________________________________________________________
info.jwst_cal.default_scale_graph[*,*] = 1
info.jwst_cal.default_scale_slope[*] =  1

zoomvalues = ['No Zoom', '2X', '4X', '8X', '16X', '32x']
if(info.jwst_data.subarray ne 0) then zoomvalues = ['No Zoom', '2X', '4X', '8X', '16X', '32X']

bimage = "Binned 4 X 4"
if(info.jwst_cal.binfactor eq 1) then bimage = "No Binning"
if(info.jwst_cal.binfactor eq 2) then bimage = "Binned 2 X 2"
if(info.jwst_cal.binfactor lt 1.0) then bimage = "Blown up by " + $
  strcompress(string(1/info.jwst_cal.binfactor,format="(f6.4)"),/remove_all)

info.jwst_cal.bindisplay=[bimage,"Scroll Full Image"] 
;_______________________________________________________________________
voptions = ['Cal Image','Cal Error','Cal DQ','Rate: ', 'Rate Error', 'Rate DQ']
if(info.jwst_control.file_slope_exist eq 0) then voptions = ['Cal Image','Cal Error','Cal DQ']

xsize_label = 9
;************************************
;graph 1,1- cal default image
;************************************
bintitle =   "[" + strtrim(string(info.jwst_data.slope_xsize),2) + ' x ' +$
        strtrim(string(info.jwst_data.slope_ysize),2) + " " + info.jwst_cal.bindisplay[0] + "]"


base1 = widget_base(info.jwst_cal.graphID11,row=1)
info.jwst_cal.graph_label[0] = widget_droplist(base1,value=voptions,$
                                            uvalue='voption1',font=info.font5)
slope_bin = widget_label(base1,value = bintitle,font=info.font4)
plane_win1 = info.jwst_cal.plane[0]
slmean = info.jwst_data.cal1_stat[0,plane_win1]
slmin = info.jwst_data.cal1_stat[3,plane_win1]
slmax = info.jwst_data.cal1_stat[4,plane_win1]

smean =  strcompress(string(slmean),/remove_all)
smin = strcompress(string(slmin),/remove_all) 
smax = strcompress(string(slmax),/remove_all) 

range_min = info.jwst_data.cal1_stat[5,plane_win1]
range_max = info.jwst_data.cal1_stat[6,plane_win1]
info.jwst_cal.graph_range[0,0] = range_min
info.jwst_cal.graph_range[0,1] = range_max

stat_base1 = widget_base(info.jwst_cal.graphID11,row=1)
stat_base2 = widget_base(info.jwst_cal.graphID11,row=1)
histo = widget_button(stat_base1,value='Histogram',uvalue='histo_1',font=info.font4)
FullSize = widget_button(stat_base1,value='Inspect Image',uvalue='inspect_1',font=info.font4)
info.jwst_cal.slabelID[0] = widget_label(stat_base2,value=('Mean: ' + smean),$ 
                                          /align_left,font=info.font4,/dynamic_resize)
info.jwst_cal.mlabelID[0] = widget_label(stat_base2,$
                         value=(' Min: ' + smin + ' Max: ' + smax),$
                                      /align_left,font=info.font4,/dynamic_resize)

; min and max scale of  image
info.jwst_cal.srange_base[0] = widget_base(info.jwst_cal.graphID11,row=1)
info.jwst_cal.image_recomputeID[0] = widget_button(info.jwst_cal.srange_base[0],$
                                                value=' Image Scale ',$
                                                font=info.font4,$
                                                uvalue = 'scale1',/dynamic_resize)

info.jwst_cal.rlabelID[0,0] = cw_field(info.jwst_cal.srange_base[0],title="min",$
                                    font=info.font4,uvalue="cr1_b",$
                                    /float,/return_events,xsize=xsize_label,value =range_min,$
                                    fieldfont = info.font4)

info.jwst_cal.rlabelID[0,1] = cw_field(info.jwst_cal.srange_base[0],title="max",$
                                    font=info.font4,uvalue="cr1_t",$
                                    /float,/return_events,xsize=xsize_label,value =range_max,$
                                    fieldfont = info.font4)


info.jwst_cal.plot_base[0] = widget_base(info.jwst_cal.graphID11)
; slope size is the same size as the image size
info.jwst_cal.graphID[0] = widget_draw(info.jwst_cal.plot_base[0],$
                                    xsize =info.jwst_cal.xplot_size,$ 
                                    ysize =info.jwst_cal.yplot_size,$
                                    /Button_Events,$
                                    retain=info.retn,uvalue='spixel1')
;_______________________________________________________________________
; initialize x_pos,y_pos
info.jwst_cal.x_pos =(info.jwst_data.slope_xsize/info.jwst_cal.binfactor)/2.0
info.jwst_cal.y_pos = (info.jwst_data.slope_ysize/info.jwst_cal.binfactor)/2.0

;_______________________________________________________________________
;graph 1,2- final slope  (default) 

base1 = widget_base(info.jwst_cal.graphID12,row=1)
info.jwst_cal.graph_label[1] = widget_droplist(base1,value=voptions,$
                                            uvalue='voption2',font=info.font5)
slope_bin = widget_label(base1,value = bintitle,font=info.font4)
value = info.jwst_cal.plane[1]
if(info.jwst_control.file_slope_exist eq 1) then value = value + 3 
widget_control,info.jwst_cal.graph_label[1],set_droplist_select=value

plane_win2 = info.jwst_cal.plane[1]

slmean = info.jwst_data.cal2_stat[0,plane_win2]
slmin = info.jwst_data.cal2_stat[3,plane_win2]
slmax = info.jwst_data.cal2_stat[4,plane_win2]

smean =  strcompress(string(slmean),/remove_all)
smin = strcompress(string(slmin),/remove_all) 
smax = strcompress(string(slmax),/remove_all) 

range_min = info.jwst_data.cal2_stat[5,plane_win2]
range_max = info.jwst_data.cal2_stat[6,plane_win2]
info.jwst_cal.graph_range[1,0] = range_min
info.jwst_cal.graph_range[1,1] = range_max


stat_base1 = widget_base(info.jwst_cal.graphID12,row=1)
stat_base2 = widget_base(info.jwst_cal.graphID12,row=1)
histo = widget_button(stat_base1,value='Histogram',uvalue='histo_2',font=info.font4)
FullSize = widget_button(stat_base1,value='Inspect Image',uvalue='inspect_2',font=info.font4)

info.jwst_cal.slabelID[1] = widget_label(stat_base2,value=('Mean: ' + smean),$ 
                                          /align_left,font=info.font4,/dynamic_resize)
info.jwst_cal.mlabelID[1] = widget_label(stat_base2,$
                         value=(' Min: ' + smin + ' Max: ' + smax),$
                                      /align_left,font=info.font4)

; min and max scale of  image
info.jwst_cal.srange_base[1] = widget_base(info.jwst_cal.graphID12,row=1)
info.jwst_cal.image_recomputeID[1] = widget_button(info.jwst_cal.srange_base[1],$
                                                value=' Image Scale ',$
                                                font=info.font4,$
                                                uvalue = 'scale2',/dynamic_resize)

info.jwst_cal.rlabelID[1,0] = cw_field(info.jwst_cal.srange_base[1],title="min",$
                                    font=info.font4,uvalue="cr2_b",$
                                    /float,/return_events,xsize=xsize_label,value =range_min,$
                                    fieldfont = info.font4)

info.jwst_cal.rlabelID[1,1] = cw_field(info.jwst_cal.srange_base[1],title="max",$
                                    font=info.font4,uvalue="cr2_t",$
                                    /float,/return_events,xsize=xsize_label,value =range_max,$
                                    fieldfont = info.font4)

info.jwst_cal.plot_base[1] = widget_base(info.jwst_cal.graphID12)
; slope size is the same size as the image size
info.jwst_cal.graphID[1] = widget_draw(info.jwst_cal.plot_base[1],$
                                    xsize =info.jwst_cal.xplot_size,$ 
                                    ysize =info.jwst_cal.yplot_size,$
                                    /Button_Events,$
                                    retain=info.retn,uvalue='spixel2')

;_______________________________________________________________________
; Pixel Statistics Display
blank_label= widget_label(infoID00,value="     ")
general_label= widget_label(infoID00,$
                            value=" Pixel Information [Image 1032 X 1024]",/align_left,$
                            font=info.font5,/sunken_frame)

; button to change 
pix_num_base = widget_base(infoID00,row=1,/align_left)
labelID = widget_button(pix_num_base,uvalue='pix_move_x1',value='<',font=info.font3)
labelID = widget_button(pix_num_base,uvalue='pix_move_x2',value='>',font=info.font3)

xvalue = info.jwst_cal.x_pos*info.jwst_cal.binfactor
yvalue = info.jwst_cal.y_pos*info.jwst_cal.binfactor
info.jwst_cal.pix_label[0] = cw_field(pix_num_base,title="x",font=info.font4, $
                                   uvalue="pix_x_val",/integer,/return_events, $
                                   value=fix(xvalue+1),xsize=6,$
                                   fieldfont=info.font3)

pix_num_base = widget_base(infoID00,row=1,/align_left)
labelID = widget_button(pix_num_base,uvalue='pix_move_y1',value='<',font=info.font3)
labelID = widget_button(pix_num_base,uvalue='pix_move_y2',value='>',font=info.font3)

info.jwst_cal.pix_label[1] = cw_field(pix_num_base,title="y",font=info.font4, $
                                   uvalue="pix_y_val",/integer,/return_events, $
                                   value=fix(yvalue+1),xsize=6,$
                                   fieldfont=info.font3)
; default values
info.jwst_cal.pix_statLabel1 = ["Image 1 Cal (MJy/sr)",  "Image 1 Error",  "DQ flag"] 
info.jwst_cal.pix_statFormat1 =  ["F16.4", "F16.8", "I16"] 
for i = 0,1 do begin  
    info.jwst_cal.pix_statID1[i] = widget_label(infoID00,value = info.jwst_cal.pix_statLabel1[i]+$
                                        ' =  NA' ,/align_left,/dynamic_resize)
endfor
info_base = widget_base(infoID00,row=1,/align_left)
info.jwst_cal.pix_statID1[2] = widget_label(info_base,value = info.jwst_cal.pix_statLabel1[2]+$
                                            ' =  NA' ,/align_left,/dynamic_resize)
info_label = widget_button(info_base,value = 'DQ Info',uvalue = 'datainfo1')
;info_base = widget_base(infoID01,row=1,/align_left)
;info_label = widget_label(info_base,value = ' ')

info.jwst_cal.pix_statLabel2 = ["Image 2 Rate (DN/s)", "Image 2 Error ","DQ Flag"]
if (info.jwst_cal.plane[1] eq 0) then info.jwst_cal.pix_statLabel2 = ["Image 2 Cal (MJy/sr)",  "Image 2 Error",  "DQ flag"] 

info.jwst_cal.pix_statFormat2 =  ["F16.4", "F16.8", "I16"] 
for i = 0,1 do begin  
    info.jwst_cal.pix_statID2[i] = widget_label(infoID00,value = info.jwst_cal.pix_statLabel2[i]+$
                                        ' =  NA' ,/align_left,/dynamic_resize)
 endfor

info_base = widget_base(infoID00,row=1,/align_left)
info.jwst_cal.pix_statID2[2] = widget_label(info_base,value = info.jwst_cal.pix_statLabel2[2]+$
                                        ' =  NA' ,/align_left,/dynamic_resize)

info_label = widget_button(info_base,value = 'DQ Info',uvalue = 'datainfo2')
;*****
;graph 2,1; window 2 initally set to cal image zoom
;*****

base1 = widget_base(info.jwst_cal.graphID21,row=1)

 subt = "    Zoom Centered on Cal image       "
info.jwst_cal.graph_label[2] = widget_label(base1,$
                                              value=subt,/align_center,$
                                              font=info.font5,/sunken_frame)


zoom_base = widget_base(info.jwst_cal.graphID21,row=1)
info.jwst_cal.zoom_label[0] = widget_button(zoom_base,value=zoomvalues[0],$
                                           uvalue='zsize1',$
                                           font=info.font4)

info.jwst_cal.zoom_label[1] = widget_button(zoom_base,value=zoomvalues[1],$
                                           uvalue='zsize2',$
                                           font=info.font4)
info.jwst_cal.zoom_label[2] = widget_button(zoom_base,value=zoomvalues[2],$
                                           uvalue='zsize3',$
                                           font=info.font4)
info.jwst_cal.zoom_label[3] = widget_button(zoom_base,value=zoomvalues[3],$
                                           uvalue='zsize4',$
                                           font=info.font4)
info.jwst_cal.zoom_label[4] = widget_button(zoom_base,value=zoomvalues[4],$
                                           uvalue='zsize5',$
                                           font=info.font4)

info.jwst_cal.zoom_label[5] = widget_button(zoom_base,value=zoomvalues[5],$
                                           uvalue='zsize5',$
                                           font=info.font4)
stat_base1 = widget_base(info.jwst_cal.graphID21,row=1)
histo = widget_button(stat_base1,value='Histogram',uvalue='histo_z',font=info.font4)
; default values for slope image
slmean = info.jwst_data.cal1_stat[0,plane_win1]
slmin = info.jwst_data.cal1_stat[3,plane_win1]
slmax = info.jwst_data.cal1_stat[4,plane_win1]

smean =  strcompress(string(slmean),/remove_all)
smin = strcompress(string(slmin),/remove_all) 
smax = strcompress(string(slmax),/remove_all) 

range_min = info.jwst_data.cal1_stat[5,plane_win1]
range_max = info.jwst_data.cal1_stat[6,plane_win1]

info.jwst_cal.graph_range[2,0] = range_min
info.jwst_cal.graph_range[2,1] = range_max

stat_base1 = widget_base(info.jwst_cal.graphID21,row=1)
stat_base2 = widget_base(info.jwst_cal.graphID21,row=1)

info.jwst_cal.slabelID[2] = widget_label(stat_base2,value=('Mean: ' + smean),$ 
                                          /align_left,font=info.font4)
info.jwst_cal.mlabelID[2] = widget_label(stat_base2,$ 
                         value=(' Min: '  + smin + ' Max: ' + smax),$
                                      /align_left,font=info.font4)
; min and max scale of  image
info.jwst_cal.srange_base[2] = widget_base(info.jwst_cal.graphID21,row=1)
info.jwst_cal.image_recomputeID[2] = widget_button(info.jwst_cal.srange_base[2],value=' Image Scale ',$
                                                font=info.font4,$
                                                uvalue = 'scale3',/dynamic_resize)

info.jwst_cal.rlabelID[2,0] = cw_field(info.jwst_cal.srange_base[2],title="min",font=info.font4,$
                                    uvalue="cr3_b",/float,/return_events,$
                                    xsize=xsize_label,value =range_min,$
                                    fieldfont = info.font4)

info.jwst_cal.rlabelID[2,1] = cw_field(info.jwst_cal.srange_base[2],title="max",font=info.font4,$
                                    uvalue="cr3_t",/float,/return_events,$
                                    xsize = xsize_label,value =range_max,$
                                   fieldfont=info.font4)

info.jwst_cal.plot_base[2] = widget_base(info.jwst_cal.graphID21)

info.jwst_cal.graphID[2] = widget_draw(info.jwst_cal.plot_base[2],$
                                    xsize =info.jwst_plotsize1,$ 
                                    ysize =info.jwst_plotsize1,$
                                    /Button_Events,$
                                    retain=info.retn,uvalue='spixel3')

;_______________________________________________________________________
;Set up the GUI
longline = '                                                                                                                        '
longtag = widget_label(CalQuicklook,value = longline)
Widget_control,info.jwst_CalQuickLook,/Realize

XManager,'jwst_mcql',info.jwst_CalQuickLook,/No_Block,$
	event_handler='jwst_mcql_event'
;_______________________________________________________________________
;_______________________________________________________________________
; realize main panel
widget_control,info.jwst_CalQuickLook,/realize

; get the window ids of the draw windows

for i = 0,2 do begin
    widget_control,info.jwst_cal.graphID[i],get_value=tdraw_id
    info.jwst_cal.draw_window_id[i] = tdraw_id

    if(i eq 0 or i eq 1 ) then begin
        window,/pixmap,xsize=info.jwst_cal.xplot_size,ysize=info.jwst_cal.yplot_size,/free
        info.jwst_cal.pixmapID[i] = !D.WINDOW
    endif

    if(i eq 2 ) then begin
        window,/pixmap,xsize=info.jwst_plotsize1,ysize=info.jwst_plotsize1,/free
        info.jwst_cal.pixmapID[i] = !D.WINDOW
    endif

endfor
loadct,info.col_table,/silent


; plot first image - defaulted to cal
jwst_mcql_update_images,0,info

; plot second plane - defaulted to slope 
jwst_mcql_update_images,1,info

;plot zoom image 
info.jwst_cal.plane[2] = 0 
info.jwst_cal.zoom_window = 1
info.jwst_cal.plane[2] = info.jwst_cal.plane[0]   ; default to image in window 1
info.jwst_cal.data_type[2] = info.jwst_cal.data_type[0] ; default to window 1

info.jwst_cal.x_zoom = info.jwst_cal.x_pos* info.binfactor
info.jwst_cal.y_zoom = info.jwst_cal.y_pos* info.binfactor
jwst_mcql_update_zoom_image,info

jwst_mcql_update_pixel_stat,info

Widget_Control,info.jwst_QuickLook,Set_UValue=info
sinfo = {info        : info}

Widget_Control,info.jwst_CalQuickLook,Set_UValue=sinfo
end
