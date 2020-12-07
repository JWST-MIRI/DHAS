;***********************************************************************
; This tool displays the Rate File  and other planes of data from the
; JWST  pipeline. The user can zoom the images, query pixel
 ; values and get statistics on the images.

;_______________________________________________________________________
pro jwst_msql_quit,event
;_______________________________________________________________________
widget_control,event.top, Get_UValue = tinfo
widget_control,tinfo.info.jwst_QuickLook,Get_UValue=info

print,'Exiting MIRI QuickLook - Slope Images'
widget_control,info.jwst_SlopeQuickLook,/destroy
end
;_______________________________________________________________________
pro jwst_msql_read_slopedata,x,y,info
; Read slopes for a pixel for all integrations + average value in rate file
;_______________________________________________________________________
slopes = fltarr(info.jwst_data.nints+1)
jwst_get_slopepixel,info,x,y,slopedata,slopefinal,status
slopes[0] = slopefinal
slopes[1:info.jwst_data.nints] = slopedata
if(ptr_valid(info.jwst_slope.pslope_pixeldata)) then ptr_free, info.jwst_slope.pslope_pixeldata
info.jwst_slope.pslope_pixeldata = ptr_new(slopes)
end
;_______________________________________________________________________
pro jwst_msql_update_pixel_location,info
;_______________________________________________________________________
ij = info.jwst_slope.current_graph
wset,info.jwst_slope.draw_window_id[ij]
; set up the pixel box window - this will initialize the
;                               mql_update_rampread.pro x and y positions.

xsize_image = fix(info.jwst_data.slope_xsize/info.jwst_slope.binfactor) 
ysize_image = fix(info.jwst_data.slope_ysize/info.jwst_slope.binfactor)

device,copy=[0,0,xsize_image,ysize_image, $
             0,0,info.jwst_slope.pixmapID[ij]]

; info.slope.x_pos,y_pos based on Raw image plot 1 
factorx = 1
factory = 1
if(ij eq 1) then begin 
    factorx = info.jwst_slope.binfactor/info.jwst_slope.scale_zoom
    factory = info.jwst_slope.binfactor/info.jwst_slope.scale_zoom
endif

xvalue = info.jwst_slope.x_pos * factorx
yvalue = info.jwst_slope.y_pos * factory

xcenter = xvalue + 0.5
ycenter = yvalue + 0.5

box_coords1 = [xcenter,(xcenter+1), $
               ycenter,(ycenter+1)]

plots,box_coords1[[0,0,1,1,0]],box_coords1[[2,3,3,2,2]],psym=0,/device

end
;_______________________________________________________________________
pro jwst_msql_update_pixel_stat_slope,info
;_______________________________________________________________________
x = info.jwst_slope.x_pos*info.jwst_slope.binfactor
y = info.jwst_slope.y_pos*info.jwst_slope.binfactor

signal1 = (*info.jwst_data.prate1)[x,y,0]
error1 = (*info.jwst_data.prate1)[x,y,1]
dq1 = (*info.jwst_data.prate1)[x,y,2]

sfin = strtrim(string(signal1,format="("+info.jwst_slope.pix_statFormat1[0]+")"),2)
se = strtrim(string(error1,format="("+info.jwst_slope.pix_statFormat1[1]+")"),2)
sdq = strtrim(string(dq1,format="("+info.jwst_slope.pix_statFormat1[2]+")"),2)

widget_control,info.jwst_slope.pix_statID1[0],set_value= info.jwst_slope.pix_statLabel1[0] + ' = ' + sfin
widget_control,info.jwst_slope.pix_statID1[1],set_value= info.jwst_slope.pix_statLabel1[1] + ' = ' + se
widget_control,info.jwst_slope.pix_statID1[2],set_value= info.jwst_slope.pix_statLabel1[2] + ' = ' + sdq


signal2 = (*info.jwst_data.prate2)[x,y,0]
unc2 = (*info.jwst_data.prate2)[x,y,1]
dq2 = (*info.jwst_data.prate2)[x,y,2]

ss = strtrim(string(signal2,format="("+info.jwst_slope.pix_statFormat2[0]+")"),2)
su = strtrim(string(unc2,format="("+info.jwst_slope.pix_statFormat2[1]+")"),2)
sf = strtrim(string(dq2,format="("+info.jwst_slope.pix_statFormat2[2]+")"),2)

widget_control,info.jwst_slope.pix_statID2[0],set_value= info.jwst_slope.pix_statLabel2[0] + ' = ' + ss
widget_control,info.jwst_slope.pix_statID2[1],set_value= info.jwst_slope.pix_statLabel2[1] + ' = ' + su
widget_control,info.jwst_slope.pix_statID2[2],set_value= info.jwst_slope.pix_statLabel2[2] + ' = ' + sf

end
;_______________________________________________________________________
pro jwst_msql_update_slopepixel,info,ps = ps,eps = eps
;_______________________________________________________________________
hcopy = 0
if ( (keyword_set(ps)) or ( keyword_set(eps)) ) then hcopy = 1

stitle = ' '
sstitle = ' ' 

xvalue = info.jwst_slope.x_pos*info.jwst_slope.binfactor
yvalue = info.jwst_slope.y_pos*info.jwst_slope.binfactor

pixeldata = (*info.jwst_data.pslopedata_all)[xvalue,yvalue,*]
if(info.jwst_control.file_slope_int_exist eq 0) then begin
   pixeldata = pixeldata[*,*,0]
endif

if(hcopy eq 0) then wset,info.jwst_slope.draw_window_id[3]

n_reads = n_elements(pixeldata)
xvalues = indgen(n_reads) 

xmin = min(xvalues)
xmax = max(xvalues)
ymin = min(pixeldata)
ymax = max(pixeldata)
flag_no_slope = 0
if(finite(ymax) eq 0 and finite(ymin) eq 0) then begin
    ymin = 0
    ymax =1
    flag_no_slope = 1
endif

xpad = fix(n_reads*.10)
if(xpad le 1 ) then xpad = 1
ypad = (ymin + ymax)*.10
if(ypad le 1 ) then ypad = 1


; check if default scale is true - then reset to orginal value
if(info.jwst_slope.default_scale_slope[0] eq 1) then begin
    info.jwst_slope.slope_range[0,0] = xmin-xpad 
    info.jwst_slope.slope_range[0,1] = xmax+xpad
endif 
  
if(info.jwst_slope.default_scale_slope[1] eq 1) then begin
    info.jwst_slope.slope_range[1,0] = ymin-ypad 
    info.jwst_slope.slope_range[1,1] = ymax+ypad
endif

if(hcopy eq 1) then begin
    sstitle = info.jwst_control.filebase + '.fits: '
    pvalue = strtrim(fix(xvalue)+1,2) + ' ' + strtrim(fix(yvalue)+1,2)
    stitle = "Slope values for selected pixel :"  +  pvalue
endif
x1 = info.jwst_slope.slope_range[0,0]
x2 = info.jwst_slope.slope_range[0,1]
y1 = info.jwst_slope.slope_range[1,0]
y2 = info.jwst_slope.slope_range[1,1]
plot,xvalues,pixeldata,xtitle = "int #", ytitle='DN/s',$
  xrange=[x1,x2],yrange=[y1,y2],title = stitle, subtitle = sstitle
oplot,xvalues,pixeldata,psym = 6,symsize=0.5
widget_control,info.jwst_slope.slope_mmlabel[0,0],set_value=info.jwst_slope.slope_range[0,0]
widget_control,info.jwst_slope.slope_mmlabel[0,1],set_value=info.jwst_slope.slope_range[0,1]
widget_control,info.jwst_slope.slope_mmlabel[1,0],set_value=info.jwst_slope.slope_range[1,0]
widget_control,info.jwst_slope.slope_mmlabel[1,1],set_value=info.jwst_slope.slope_range[1,1]

if(flag_no_slope eq 1) then begin
    xmiddle = (xmin)
    ymiddle = (ymax - ymin)/2.0
    xyouts, xmiddle,ymiddle,' No Slope Found for Pixel - NaN'
endif

end
;_______________________________________________________________________
pro jwst_msql_display_slope,info
;_______________________________________________________________________
window,2,/pixmap
wdelete,2
if(XRegistered ('jwst_msql')) then begin
    widget_control,info.jwst_SlopeQuickLook,/destroy
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

if(info.jwst_slope.uwindowsize eq 1) then begin ; user has set window size 
    xsize_scroll = info.jwst_slope.xwindowsize
    ysize_scroll = info.jwst_slope.ywindowsize
endif

if(info.jwst_control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.jwst_control.x_scroll_window
if(info.jwst_control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.jwst_control.y_scroll_window

if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10
;_______________________________________________________________________
SlopeQuickLook = widget_base(title="JWST MIRI Quick Look- Rate & Rate Int Images" + info.jwst_version,$
                             col = 1,mbar = menuBar,group_leader = info.jwst_QuickLook,$
                             xsize = xwidget_size,$
                             ysize = ywidget_size,/scroll,$
                             x_scroll_size= xsize_scroll,$
                             y_scroll_size = ysize_scroll,/TLB_SIZE_EVENTS)

info.jwst_SlopeQuickLook = SlopeQuickLook
;********
; build the menubar
;********
QuitMenu = widget_button(menuBar,value="Quit",font = info.font2)
quitbutton = widget_button(quitmenu,value="Quit",event_pro='jwst_msql_quit')

hMenu = widget_button(menuBar,value="Display Header",font = info.font2)
hsMenu = widget_button(hmenu,value="Display Reduced Header",uvalue='sheader')


statMenu = widget_button(menuBar,value="Statistics",font = info.font2)
statbutton = widget_button(statmenu,value="Get Statistics on Images",uvalue = 'Stat')

cMenu   = widget_button(menuBar,value="Compare",font= info.font2)
cbutton = widget_button(cMenu,value = "Compare Image in Window 1 to an Image in Window 2 (both must be of same type: rate, error, dq)",uvalue = 'compare')

;chMenu   = widget_button(menuBar,value="Channel",font= info.font2)
;cbutton = widget_button(chMenu,value = "Display Reduced Image by Channel",uvalue = 'channel')

;PMenu = widget_button(menuBar,value="Print",font = info.font2)
;PbuttonS = widget_button(Pmenu,value = "Print Plot 1",uvalue='print_1')
;PbuttonZ = widget_button(Pmenu,value = "Print Zoom Image (Plot 2)",uvalue='print_Z')
;PbuttonU = widget_button(Pmenu,value = "Print Plot 2",uvalue='print_2')
;PbuttonE = widget_button(Pmenu,value = "Print Slope value for pixel for exposure",uvalue='print_E')

filelabelID = widget_label(info.jwst_SlopeQuickLook, $
                           value=info.jwst_control.filename_slope,/align_left, $
                           font=info.font2,/dynamic_resize)
;_______________________________________________________________________
; determine the main window display based on scale and image size


xsize = info.jwst_data.slope_xsize/info.jwst_slope.binfactor
ysize = info.jwst_data.slope_ysize/info.jwst_slope.binfactor
info.jwst_slope.xplot_size = fix(xsize)
info.jwst_slope.yplot_size = fix(ysize)

info.jwst_slope.current_graph = 0
;*********
; Draw Main Display Window
; for Single Slope insecption image
;*********
graphID_master1 = widget_base(info.jwst_SlopeQuickLook,row=1)
graphID_master2 = widget_base(info.jwst_SlopeQuickLook,row=1)

info.jwst_slope.graphID11 = widget_base(graphID_master1,col=1)
info.jwst_slope.graphID12 = widget_base(graphID_master1,col=1)
infoID00 = widget_base(graphID_master1,col=1)

info.jwst_slope.graphID21 = widget_base(graphID_master2,col=1)
info.jwst_slope.graphID22 = widget_base(graphID_master2,col=1)
infoID01 = widget_base(graphID_master2,col=1)
;_______________________________________________________________________
; set up structure for pass information around
;_______________________________________________________________________
info.jwst_slope.default_scale_graph[*,*] = 1
info.jwst_slope.default_scale_slope[*] =  1

zoomvalues = ['No Zoom', '2X', '4X', '8X', '16X', '32x']
if(info.jwst_data.subarray ne 0) then zoomvalues = ['No Zoom', '2X', '4X', '8X', '16X', '32X']

bimage = "Binned 4 X 4"
if(info.jwst_slope.binfactor eq 1) then bimage = "No Binning"
if(info.jwst_slope.binfactor eq 2) then bimage = "Binned 2 X 2"
if(info.jwst_slope.binfactor lt 1.0) then bimage = "Blown up by " + $
  strcompress(string(1/info.jwst_slope.binfactor,format="(f6.4)"),/remove_all)

info.jwst_slope.bindisplay=[bimage,"Scroll Full Image"] 
;_______________________________________________________________________
voptions = ['Final Rate: ', 'Final Error', 'Final DQ','Int Rate','Int Error','Int DQ']
if(info.jwst_control.file_slope_int_exist eq 0) then voptions = ['Final Rate: ', 'Final Error', 'Final DQ']


xsize_label = 9
;************************************
;graph 1,1- slope image
;************************************
bintitle =   "[" + strtrim(string(info.jwst_data.slope_xsize),2) + ' x ' +$
        strtrim(string(info.jwst_data.slope_ysize),2) + " " + info.jwst_slope.bindisplay[0] + "]"


base1 = widget_base(info.jwst_slope.graphID11,row=1)
info.jwst_slope.graph_label[0] = widget_droplist(base1,value=voptions,$
                                            uvalue='voption1',font=info.font5)
slope_bin = widget_label(base1,value = bintitle,font=info.font4)

slmean = info.jwst_data.rate1_stat[0,0]
slmin = info.jwst_data.rate1_stat[3,0]
slmax = info.jwst_data.rate1_stat[4,0]

smean =  strcompress(string(slmean),/remove_all)
smin = strcompress(string(slmin),/remove_all) 
smax = strcompress(string(slmax),/remove_all) 

range_min = info.jwst_data.rate1_stat[5,0]
range_max = info.jwst_data.rate1_stat[6,0]
info.jwst_slope.graph_range[0,0] = range_min
info.jwst_slope.graph_range[0,1] = range_max

stat_base1 = widget_base(info.jwst_slope.graphID11,row=1)
stat_base2 = widget_base(info.jwst_slope.graphID11,row=1)
FullSize = widget_button(stat_base1,value='Inspect Image',uvalue='inspect_1',font=info.font4)
if(info.jwst_control.file_slope_int_exist eq 1) then begin 
   info.jwst_slope.integration_label[0] = cw_field(stat_base1,$
                                                   title=" Integration # ",font=info.font5, $
                                                   uvalue="integration1",/integer,/return_events, $
                                                   value=info.jwst_slope.IntegrationNO[0]+1,xsize=4,$
                                                   fieldfont=info.font3)
   sinum = strcompress(string(info.jwst_data.nints),/remove_all)
   labelID = widget_button(stat_base1,uvalue='integr1_move_dn',value='<',font=info.font3)
   labelID = widget_button(stat_base1,uvalue='integr1_move_up',value='>',font=info.font3)
   num_int= widget_label(stat_base1,value = '# ints ' + sinum,/align_left)
endif

info.jwst_slope.slabelID[0] = widget_label(stat_base2,value=('Mean: ' + smean),$ 
                                          /align_left,font=info.font4)
info.jwst_slope.mlabelID[0] = widget_label(stat_base2,$
                         value=(' Min: ' + smin + ' Max: ' + smax),$
                                      /align_left,font=info.font4)

; min and max scale of  image
info.jwst_slope.srange_base[0] = widget_base(info.jwst_slope.graphID11,row=1)
info.jwst_slope.image_recomputeID[0] = widget_button(info.jwst_slope.srange_base[0],$
                                                value=' Image Scale ',$
                                                font=info.font4,$
                                                uvalue = 'scale1',/dynamic_resize)

info.jwst_slope.rlabelID[0,0] = cw_field(info.jwst_slope.srange_base[0],title="min",$
                                    font=info.font4,uvalue="cr1_b",$
                                    /float,/return_events,xsize=xsize_label,value =range_min,$
                                    fieldfont = info.font4)

info.jwst_slope.rlabelID[0,1] = cw_field(info.jwst_slope.srange_base[0],title="max",$
                                    font=info.font4,uvalue="cr1_t",$
                                    /float,/return_events,xsize=xsize_label,value =range_max,$
                                    fieldfont = info.font4)


info.jwst_slope.plot_base[0] = widget_base(info.jwst_slope.graphID11)
; slope size is the same size as the image size
info.jwst_slope.graphID[0] = widget_draw(info.jwst_slope.plot_base[0],$
                                    xsize =info.jwst_slope.xplot_size,$ 
                                    ysize =info.jwst_slope.yplot_size,$
                                    /Button_Events,$
                                    retain=info.retn,uvalue='spixel1')
;_______________________________________________________________________
; initialize x_pos,y_pos
info.jwst_slope.x_pos =(info.jwst_data.slope_xsize/info.jwst_slope.binfactor)/2.0
info.jwst_slope.y_pos = (info.jwst_data.slope_ysize/info.jwst_slope.binfactor)/2.0

;_______________________________________________________________________
;graph 1,2- uncertainty slope image (default) 

base1 = widget_base(info.jwst_slope.graphID12,row=1)

info.jwst_slope.graph_label[1] = widget_droplist(base1,value=voptions,$
                                            uvalue='voption2',font=info.font5)
slope_bin = widget_label(base1,value = bintitle,font=info.font4)
value = info.jwst_slope.plane[1]
if(info.jwst_control.file_slope_int_exist eq 1) then value = value + 3
widget_control,info.jwst_slope.graph_label[1],set_droplist_select=value

slmean = info.jwst_data.rate2_stat[0,1]
slmin = info.jwst_data.rate2_stat[3,1]
slmax = info.jwst_data.rate2_stat[4,1]

smean =  strcompress(string(slmean),/remove_all)
smin = strcompress(string(slmin),/remove_all) 
smax = strcompress(string(slmax),/remove_all) 

range_min = info.jwst_data.rate2_stat[5,1]
range_max = info.jwst_data.rate2_stat[6,1]
info.jwst_slope.graph_range[1,0] = range_min
info.jwst_slope.graph_range[1,1] = range_max


stat_base1 = widget_base(info.jwst_slope.graphID12,row=1)
stat_base2 = widget_base(info.jwst_slope.graphID12,row=1)

FullSize = widget_button(stat_base1,value='Inspect Image',uvalue='inspect_2',font=info.font4)
if(info.jwst_control.file_slope_int_exist eq 1) then begin 
   info.jwst_slope.integration_label[1] = cw_field(stat_base1,$
                                                   title=" Integration # ",font=info.font5, $
                                                   uvalue="integration2",/integer,/return_events, $
                                                   value=info.jwst_slope.IntegrationNO[1]+1,xsize=4,$
                                                   fieldfont=info.font3)

   sinum = strcompress(string(info.jwst_data.nints),/remove_all)

   labelID = widget_button(stat_base1,uvalue='integr2_move_dn',value='<',font=info.font3)
   labelID = widget_button(stat_base1,uvalue='integr2_move_up',value='>',font=info.font3)
   num_int= widget_label(stat_base1,value = '# ints ' + sinum,/align_left)
endif

info.jwst_slope.slabelID[1] = widget_label(stat_base2,value=('Mean: ' + smean),$ 
                                          /align_left,font=info.font4)
info.jwst_slope.mlabelID[1] = widget_label(stat_base2,$
                         value=(' Min: ' + smin + ' Max: ' + smax),$
                                      /align_left,font=info.font4)

; min and max scale of  image
info.jwst_slope.srange_base[1] = widget_base(info.jwst_slope.graphID12,row=1)
info.jwst_slope.image_recomputeID[1] = widget_button(info.jwst_slope.srange_base[1],$
                                                value=' Image Scale ',$
                                                font=info.font4,$
                                                uvalue = 'scale2',/dynamic_resize)

info.jwst_slope.rlabelID[1,0] = cw_field(info.jwst_slope.srange_base[1],title="min",$
                                    font=info.font4,uvalue="cr2_b",$
                                    /float,/return_events,xsize=xsize_label,value =range_min,$
                                    fieldfont = info.font4)

info.jwst_slope.rlabelID[1,1] = cw_field(info.jwst_slope.srange_base[1],title="max",$
                                    font=info.font4,uvalue="cr2_t",$
                                    /float,/return_events,xsize=xsize_label,value =range_max,$
                                    fieldfont = info.font4)

info.jwst_slope.plot_base[1] = widget_base(info.jwst_slope.graphID12)
; slope size is the same size as the image size
info.jwst_slope.graphID[1] = widget_draw(info.jwst_slope.plot_base[1],$
                                    xsize =info.jwst_slope.xplot_size,$ 
                                    ysize =info.jwst_slope.yplot_size,$
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

xvalue = info.jwst_slope.x_pos*info.jwst_slope.binfactor
yvalue = info.jwst_slope.y_pos*info.jwst_slope.binfactor
info.jwst_slope.pix_label[0] = cw_field(pix_num_base,title="x",font=info.font4, $
                                   uvalue="pix_x_val",/integer,/return_events, $
                                   value=fix(xvalue+1),xsize=6,$
                                   fieldfont=info.font3)

pix_num_base = widget_base(infoID00,row=1,/align_left)
labelID = widget_button(pix_num_base,uvalue='pix_move_y1',value='<',font=info.font3)
labelID = widget_button(pix_num_base,uvalue='pix_move_y2',value='>',font=info.font3)

info.jwst_slope.pix_label[1] = cw_field(pix_num_base,title="y",font=info.font4, $
                                   uvalue="pix_y_val",/integer,/return_events, $
                                   value=fix(yvalue+1),xsize=6,$
                                   fieldfont=info.font3)

info.jwst_slope.pix_statLabel1 = ["Image 1 Rate (DN/s)",  "Image 1 Error",  "DQ flag"] 
info.jwst_slope.pix_statFormat1 =  ["F16.4", "F16.8", "I16"] 
for i = 0,2 do begin  
    info.jwst_slope.pix_statID1[i] = widget_label(infoID00,value = info.jwst_slope.pix_statLabel1[i]+$
                                        ' =  NA' ,/align_left,/dynamic_resize)
endfor

info_base = widget_base(infoID01,row=1,/align_left)
info_label = widget_label(info_base,value = ' ')

info.jwst_slope.pix_statLabel2 = ["Image 2 Rate (DN/s)", "Image 2 Error (DN/S)","DQ Flag"]
info.jwst_slope.pix_statFormat2 =  ["F16.4", "F16.8", "I16"] 
for i = 0,2 do begin  
    info.jwst_slope.pix_statID2[i] = widget_label(infoID00,value = info.jwst_slope.pix_statLabel2[i]+$
                                        ' =  NA' ,/align_left,/dynamic_resize)
endfor

info_base = widget_base(infoID00,row=1,/align_left)

info_label = widget_button(info_base,value = 'DQ Info',uvalue = 'datainfo')
;*****
;graph 2,1; window 2 initally set to Slope image zoom
;*****

base1 = widget_base(info.jwst_slope.graphID21,row=1)

 subt = "    Zoom Centered on Slope image       "
info.jwst_slope.graph_label[2] = widget_label(base1,$
                                              value=subt,/align_center,$
                                              font=info.font5,/sunken_frame)


zoom_base = widget_base(info.jwst_slope.graphID21,row=1)
info.jwst_slope.zoom_label[0] = widget_button(zoom_base,value=zoomvalues[0],$
                                           uvalue='zsize1',$
                                           font=info.font4)

info.jwst_slope.zoom_label[1] = widget_button(zoom_base,value=zoomvalues[1],$
                                           uvalue='zsize2',$
                                           font=info.font4)
info.jwst_slope.zoom_label[2] = widget_button(zoom_base,value=zoomvalues[2],$
                                           uvalue='zsize3',$
                                           font=info.font4)
info.jwst_slope.zoom_label[3] = widget_button(zoom_base,value=zoomvalues[3],$
                                           uvalue='zsize4',$
                                           font=info.font4)
info.jwst_slope.zoom_label[4] = widget_button(zoom_base,value=zoomvalues[4],$
                                           uvalue='zsize5',$
                                           font=info.font4)

info.jwst_slope.zoom_label[5] = widget_button(zoom_base,value=zoomvalues[5],$
                                           uvalue='zsize5',$
                                           font=info.font4)

; default values for slope image
slmean = info.jwst_data.rate1_stat[0,0]
slmin = info.jwst_data.rate1_stat[3,0]
slmax = info.jwst_data.rate1_stat[4,0]

smean =  strcompress(string(slmean),/remove_all)
smin = strcompress(string(slmin),/remove_all) 
smax = strcompress(string(slmax),/remove_all) 

range_min = info.jwst_data.rate1_stat[5,0]
range_max = info.jwst_data.rate1_stat[6,0]

info.jwst_slope.graph_range[2,0] = range_min
info.jwst_slope.graph_range[2,1] = range_max

stat_base1 = widget_base(info.jwst_slope.graphID21,row=1)
stat_base2 = widget_base(info.jwst_slope.graphID21,row=1)

info.jwst_slope.slabelID[2] = widget_label(stat_base2,value=('Mean: ' + smean),$ 
                                          /align_left,font=info.font4)
info.jwst_slope.mlabelID[2] = widget_label(stat_base2,$ 
                         value=(' Min: '  + smin + ' Max: ' + smax),$
                                      /align_left,font=info.font4)
; min and max scale of  image
info.jwst_slope.srange_base[2] = widget_base(info.jwst_slope.graphID21,row=1)
info.jwst_slope.image_recomputeID[2] = widget_button(info.jwst_slope.srange_base[2],value=' Image Scale ',$
                                                font=info.font4,$
                                                uvalue = 'scale3',/dynamic_resize)

info.jwst_slope.rlabelID[2,0] = cw_field(info.jwst_slope.srange_base[2],title="min",font=info.font4,$
                                    uvalue="cr3_b",/float,/return_events,$
                                    xsize=xsize_label,value =range_min,$
                                    fieldfont = info.font4)

info.jwst_slope.rlabelID[2,1] = cw_field(info.jwst_slope.srange_base[2],title="max",font=info.font4,$
                                    uvalue="cr3_t",/float,/return_events,$
                                    xsize = xsize_label,value =range_max,$
                                   fieldfont=info.font4)

info.jwst_slope.plot_base[2] = widget_base(info.jwst_slope.graphID21)

info.jwst_slope.graphID[2] = widget_draw(info.jwst_slope.plot_base[2],$
                                    xsize =info.jwst_plotsize1,$ 
                                    ysize =info.jwst_plotsize1,$
                                    /Button_Events,$
                                    retain=info.retn,uvalue='spixel3')


;*****
;graph 2,2 - slope values for entire exposure for a certain pixel
;*****

slope_range = fltarr(2,2)        ; plot range for pixel over exposure ,


stitle = "Rate Values for Selected Pixel for Exposure"
stitle1 = " Final Rate is given at Int = 0" 

tlabelID = widget_label(info.jwst_slope.graphID22,value = stitle,/align_center,$
                                     font=info.font5,/sunken_frame)

tlabelID = widget_label(info.jwst_slope.graphID22,value = stitle1,/align_center)

pix_num_base = widget_base(info.jwst_slope.graphID22,row=1,/align_center)

info.jwst_slope.graphID[3] = widget_draw(info.jwst_slope.graphID22,$
                                    xsize = info.jwst_plotsize3,$
                                    ysize = info.jwst_plotsize1,$
                                    retain=info.retn)

;buttons to  change the x and y ranges

pix_num_base2 = widget_base(info.jwst_slope.graphID22,row=1)
labelID = widget_label(pix_num_base2,value="X->",font=info.font4)
info.jwst_slope.slope_mmlabel[0,0] = cw_field(pix_num_base2,title="min:",font=info.font4, $
                                        uvalue="slop_mmx1",/integer,/return_events, $
                                        value=slope_range[0,0], $
                                        xsize=info.xsize_label,fieldfont=info.font4)

info.jwst_slope.slope_mmlabel[0,1] = cw_field(pix_num_base2,title="max:",font=info.font4, $
                                        uvalue="slop_mmx2",/integer,/return_events, $
                                        value=slope_range[0,1],xsize=info.xsize_label,$
                                        fieldfont=info.font4)

info.jwst_slope.slope_recomputeID[0] = widget_button(pix_num_base2,value=' Plot Range ',$
                                               font=info.font4,$
                                               uvalue = 'e1',/dynamic_resize)

pix_num_base3 = widget_base(info.jwst_slope.graphID22,row=1)

labelID = widget_label(pix_num_base3,value="Y->",font=info.font4)
info.jwst_slope.slope_mmlabel[1,0] = cw_field(pix_num_base3,title="min:",font=info.font4, $
                                        uvalue="slop_mmy1",/float, /return_events,$
                                        value=slope_range[1,0],xsize=info.xsize_label,$
                                        fieldfont=info.font4)

info.jwst_slope.slope_mmlabel[1,1] = cw_field(pix_num_base3,title="max:",font=info.font4, $
                                        uvalue="slop_mmy2",/float,/return_events, $
                                        value=slope_range[1,1],xsize=info.xsize_label,$
                                        fieldfont=info.font4)

info.jwst_slope.slope_recomputeID[1] = widget_button(pix_num_base3,value=' Plot Range ',$
                                               font=info.font4,$
                                               uvalue = 'e2',/dynamic_resize)

info.jwst_slope.slope_range = slope_range


;Set up the GUI
longline = '                                                                                                                        '
longtag = widget_label(SlopeQuicklook,value = longline)
Widget_control,info.jwst_slopeQuickLook,/Realize

XManager,'jwst_msql',info.jwst_slopeQuickLook,/No_Block,$
	event_handler='jwst_msql_event'
;_______________________________________________________________________
;_______________________________________________________________________
; realize main panel
widget_control,info.jwst_slopeQuickLook,/realize

; get the window ids of the draw windows

for i = 0,3 do begin
    widget_control,info.jwst_slope.graphID[i],get_value=tdraw_id
    info.jwst_slope.draw_window_id[i] = tdraw_id

    if(i eq 0 or i eq 1 ) then begin
        window,/pixmap,xsize=info.jwst_slope.xplot_size,ysize=info.jwst_slope.yplot_size,/free
        info.jwst_slope.pixmapID[i] = !D.WINDOW
    endif

    if(i eq 2 ) then begin
        window,/pixmap,xsize=info.jwst_plotsize1,ysize=info.jwst_plotsize1,/free
        info.jwst_slope.pixmapID[i] = !D.WINDOW
    endif

endfor
loadct,info.col_table,/silent

; plot first image - defaulted to slope
jwst_msql_update_slope,0,info

; plot second plane - defaulted to error 
jwst_msql_update_slope,1,info

;plot zoom image 
info.jwst_slope.plane[2] = 0 ; default to image in window 1
info.jwst_slope.zoom_window = 1
info.jwst_slope.x_zoom = info.jwst_slope.x_pos* info.binfactor
info.jwst_slope.y_zoom = info.jwst_slope.y_pos* info.binfactor
jwst_msql_update_zoom_image,info

xvalue = fix(  (info.jwst_slope.x_pos) *info.jwst_slope.binfactor)
yvalue = fix(  (info.jwst_slope.y_pos) *info.jwst_slope.binfactor)

; read slope information on pixel 
jwst_msql_read_slopedata,xvalue,yvalue,info

; This takes a long time to read if # int large - may not need to do
                                ;it this way - read slope info with
                                ;              each change in pixel
; only need to read in all the slopes for all the pixels once
jwst_read_all_slopes,info,slopedata,status,error_message
if ptr_valid (info.jwst_data.pslopedata_all) then ptr_free,info.jwst_data.pslopedata_all
info.jwst_data.pslopedata_all = ptr_new(slopedata)
slopedata = 0

jwst_msql_update_slopepixel,info
jwst_msql_update_pixel_stat_slope,info

Widget_Control,info.jwst_QuickLook,Set_UValue=info
sinfo = {info        : info}

Widget_Control,info.jwst_slopeQuickLook,Set_UValue=sinfo
end
