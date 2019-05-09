;***********************************************************************
; This tool displays the Slope image and other planes of data from the
; miri_sloper pipeline. The user can zoom the images, query pixel
 ; values and get statistics on the images.

;_______________________________________________________________________
pro msql_quit,event
;_______________________________________________________________________
widget_control,event.top, Get_UValue = tinfo
widget_control,tinfo.info.QuickLook,Get_UValue=info

print,'Exiting MIRI QuickLook - Slope Images'
widget_control,info.SlopeQuickLook,/destroy

end


;***********************************************************************
;_______________________________________________________________________
pro msql_update_pixel_location,info
;_______________________________________________________________________

ij = info.slope.current_graph
wset,info.slope.draw_window_id[ij]
; set up the pixel box window - this will initialize the
;                               mql_update_rampread.pro x and y positions.

xsize_image = fix(info.data.slope_xsize/info.slope.binfactor) 
ysize_image = fix(info.data.slope_ysize/info.slope.binfactor)

device,copy=[0,0,xsize_image,ysize_image, $
             0,0,info.slope.pixmapID[ij]]

; info.slope.x_pos,y_pos based on Raw image plot 1 
factorx = 1
factory = 1
if(ij eq 1) then begin 
    factorx = info.slope.binfactor/info.slope.scale_zoom
    factory = info.slope.binfactor/info.slope.scale_zoom
endif

xvalue = info.slope.x_pos * factorx
yvalue = info.slope.y_pos * factory

xcenter = xvalue + 0.5
ycenter = yvalue + 0.5

box_coords1 = [xcenter,(xcenter+1), $
               ycenter,(ycenter+1)]

plots,box_coords1[[0,0,1,1,0]],box_coords1[[2,3,3,2,2]],psym=0,/device

end



;*********************************************************************************
;_______________________________________________________________________
pro msql_update_pixel_stat_slope,info
;_______________________________________________________________________

i = info.slope.integrationNO
x = info.slope.x_pos*info.slope.binfactor
y = info.slope.y_pos*info.slope.binfactor

ss = 'NA'
su = 'NA'
sf = 'NA'
sg = 'NA'
ssat = 'NA'
sz = 'NA'
srms = 'NA'
signal = (*info.data.pslopedata)[x,y,0]

ss = strtrim(string(signal,format="("+info.slope.pix_statFormat[0]+")"),2)
if(info.data.slope_zsize eq 2) then begin
    zero = (*info.data.pslopedata)[x,y,1]
    sz = strtrim(string(zero,format="("+info.slope.pix_statFormat[3]+")"),2)
endif

if(info.data.slope_zsize eq 3) then begin
    zero = (*info.data.pslopedata)[x,y,1]
    rms = (*info.data.pslopedata)[x,y,2]
    sz = strtrim(string(zero,format="("+info.slope.pix_statFormat[3]+")"),2)
    srms = strtrim(string(rms,format="("+info.slope.pix_statFormat[4]+")"),2)
endif

if(info.data.slope_zsize ge 6) then begin

    unc = (*info.data.pslopedata)[x,y,1]
    dq = (*info.data.pslopedata)[x,y,2]
    zero = (*info.data.pslopedata)[x,y,3]
    good= (*info.data.pslopedata)[x,y,4]
    sat= (*info.data.pslopedata)[x,y,5]

    su =   strtrim(string(unc,format="("+info.slope.pix_statFormat[1]+")"),2)
    sf = strtrim(string(dq,format="("+info.slope.pix_statFormat[2]+")"),2)
    sg = strtrim(string(good,format="("+info.slope.pix_statFormat[7]+")"),2)
    ssat = strtrim(string(sat,format="("+info.slope.pix_statFormat[5]+")"),2)
endif

signal_final = (*info.data.pslopedata_all)[x,y,0]

sgoodseg = 'NA'
if(info.data.slope_zsize gt 6) then begin
    goodseg = (*info.data.pslopedata)[x,y,6] 
    sgoodseg = strtrim(string(goodseg,format="("+info.slope.pix_statFormat[6]+")"),2)

endif

if(info.data.slope_zsize eq 8) then begin

    rms = (*info.data.pslopedata)[x,y,7]
    srms = strtrim(string(rms,format="("+info.slope.pix_statFormat[4]+")"),2)
endif
if(info.data.slope_zsize gt 8) then begin 

    max2pt = (*info.data.pslopedata)[x,y,8]
    imax2pt = (*info.data.pslopedata)[x,y,9]
    stdev2pt=  (*info.data.pslopedata)[x,y,10]
    slope2pt =  (*info.data.pslopedata)[x,y,11]
endif

scal = 'NA'
if(info.data.cal_exist eq 1) then begin
    cal = (*info.data.pcaldata)[x,y,0]
    scal = strtrim(string(cal,format="("+info.slope.pix_statFormat[8]+")"),2)
endif

widget_control,info.slope.pix_statID[0],set_value= info.slope.pix_statLabel[0] + ' = ' + ss
widget_control,info.slope.pix_statID[1],set_value= info.slope.pix_statLabel[1] + ' = ' + su
widget_control,info.slope.pix_statID[2],set_value= info.slope.pix_statLabel[2] + ' = ' + sf



widget_control,info.slope.pix_statID[3],set_value= info.slope.pix_statLabel[3] + ' = ' + $
               strtrim(string(zero,format="("+info.slope.pix_statFormat[3]+")"),2)


widget_control,info.slope.pix_statID[4],set_value= info.slope.pix_statLabel[4] + ' = ' + srms
widget_control,info.slope.pix_statID[5],set_value= info.slope.pix_statLabel[5] + ' = ' + ssat
widget_control,info.slope.pix_statID[6],set_value= info.slope.pix_statLabel[6] + ' = ' + sgoodseg
widget_control,info.slope.pix_statID[7],set_value= info.slope.pix_statLabel[7] + ' = ' + sg
widget_control,info.slope.pix_statID[8],set_value= info.slope.pix_statLabel[8] + ' = ' + scal

if(info.data.slope_zsize gt 8) then begin 

    widget_control,info.slope.pix_statID2[0],$
                   set_value= info.slope.pix_statLabel2[0] + ' = ' + $
                   strtrim(string(max2pt,format="("+info.slope.pix_statFormat2[0]+")"),2)

    widget_control,info.slope.pix_statID2[1],$
                   set_value= info.slope.pix_statLabel2[1] + ' = ' + $
                   strtrim(string(imax2pt,format="("+info.slope.pix_statFormat2[1]+")"),2)

    widget_control,info.slope.pix_statID2[2],$
                   set_value= info.slope.pix_statLabel2[2] + ' = ' + $
                   strtrim(string(slope2pt,format="("+info.slope.pix_statFormat2[2]+")"),2)

    widget_control,info.slope.pix_statID2[3],$
                   set_value= info.slope.pix_statLabel2[3] + ' = ' + $
                   strtrim(string(stdev2pt,format="("+info.slope.pix_statFormat2[3]+")"),2)

endif


widget_control,info.slope.pix_statID3,set_value= info.slope.pix_statLabel[0] + ' = ' + $
  strtrim(string(signal_final,format="("+info.slope.pix_statFormat[0]+")"),2)

end



;*************************************************************************
;_______________________________________________________________________
pro msql_update_slopepixel,info,ps = ps,eps = eps
;_______________________________________________________________________

hcopy = 0
if(not info.data.slope_exist) then return
if ( (keyword_set(ps)) or ( keyword_set(eps)) ) then hcopy = 1

stitle = ' '
sstitle = ' ' 

xvalue = info.slope.x_pos*info.slope.binfactor
yvalue = info.slope.y_pos*info.slope.binfactor

pixeldata = (*info.data.pslopedata_all)[xvalue,yvalue,*]

if(hcopy eq 0) then wset,info.slope.draw_window_id[4]

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
if(info.slope.default_scale_slope[0] eq 1) then begin
    info.slope.slope_range[0,0] = xmin-xpad 
    info.slope.slope_range[0,1] = xmax+xpad
endif 
  
if(info.slope.default_scale_slope[1] eq 1) then begin

    info.slope.slope_range[1,0] = ymin-ypad 
    info.slope.slope_range[1,1] = ymax+ypad
endif


if(hcopy eq 1) then begin
    sstitle = info.control.filebase + '.fits: '
    pvalue = strtrim(fix(xvalue)+1,2) + ' ' + strtrim(fix(yvalue)+1,2)
    stitle = "Slope values for selected pixel :"  +  pvalue

endif
x1 = info.slope.slope_range[0,0]
x2 = info.slope.slope_range[0,1]
y1 = info.slope.slope_range[1,0]
y2 = info.slope.slope_range[1,1]
plot,xvalues,pixeldata,xtitle = "int #", ytitle='DN/s',$
  xrange=[x1,x2],yrange=[y1,y2],title = stitle, subtitle = sstitle
oplot,xvalues,pixeldata,psym = 6,symsize=0.5
widget_control,info.slope.slope_mmlabel[0,0],set_value=info.slope.slope_range[0,0]
widget_control,info.slope.slope_mmlabel[0,1],set_value=info.slope.slope_range[0,1]
widget_control,info.slope.slope_mmlabel[1,0],set_value=info.slope.slope_range[1,0]
widget_control,info.slope.slope_mmlabel[1,1],set_value=info.slope.slope_range[1,1]

if(flag_no_slope eq 1) then begin
    xmiddle = (xmin)
    ymiddle = (ymax - ymin)/2.0
    xyouts, xmiddle,ymiddle,' No Slope Found for Pixel - NaN'
endif

end


;*********************************************************************************
;_______________________________________________________________________
pro msql_display_slope,info
;_______________________________________________________________________

window,2,/pixmap
wdelete,2
if(XRegistered ('msql')) then begin
    widget_control,info.SlopeQuickLook,/destroy
endif



reading_slope_processing,info.control.filename_slope,$
                         slope_exists,start_fit,end_fit,low_sat,$
                         high_sat,do_bad,use_psm,use_rscd,use_lin,use_dark,$
                         subrp,deltarp,even_odd,$
                         bad_file,psm_file,rscd_file,$
                         lin_file,dark_file,$
                         slope_unit,frame_time,gain


info.slope.start_fit = start_fit
info.slope.end_fit = end_fit
info.slope.frame_time = frame_time 
info.slope.overplot_pixel_int = 0

;*********
;Setup main panel
;*********
;_______________________________________________________________________
; widget window parameters
xwidget_size = 1355
ywidget_size = 910
xsize_scroll = 1250
ysize_scroll = 900


if(info.slope.uwindowsize eq 1) then begin ; user has set window size 
    xsize_scroll = info.slope.xwindowsize
    ysize_scroll = info.slope.ywindowsize
endif

if(info.control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.control.x_scroll_window
if(info.control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.control.y_scroll_window


if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10
;_______________________________________________________________________

info.slope.overplot_reference_corrected = 0
info.slope.overplot_cr= 0
info.slope.overplot_lc= 0
info.slope.overplot_mdc = 0 
info.slope.overplot_reset = 0 
info.slope.overplot_rscd = 0 
info.slope.overplot_lastframe = 0 


SlopeQuickLook = widget_base(title="MIRI Quick Look- Slope Images" + info.version,$
                             col = 1,mbar = menuBar,group_leader = info.QuickLook,$
                             xsize = xwidget_size,$
                             ysize = ywidget_size,/scroll,$
                             x_scroll_size= xsize_scroll,$
                             y_scroll_size = ysize_scroll,/TLB_SIZE_EVENTS)



info.SlopeQuickLook = SlopeQuickLook
;********
; build the menubar
;********
QuitMenu = widget_button(menuBar,value="Quit",font = info.font2)
quitbutton = widget_button(quitmenu,value="Quit",event_pro='msql_quit')

hMenu = widget_button(menuBar,value="Display Header",font = info.font2)
hsMenu = widget_button(hmenu,value="Display Reduced Header",uvalue='sheader')
hcMenu = widget_button(hmenu,value="Display Calibrated Header",uvalue='cheader')

statMenu = widget_button(menuBar,value="Statistics",font = info.font2)
statbutton = widget_button(statmenu,value="Get Statistics on Images",uvalue = 'Stat')

cMenu   = widget_button(menuBar,value="Compare",font= info.font2)
cbutton = widget_button(cMenu,value = "Compare First Image to an Image in another file",uvalue = 'compare')

chMenu   = widget_button(menuBar,value="Channel",font= info.font2)
cbutton = widget_button(chMenu,value = "Display Reduced Image by Channel",uvalue = 'channel')

FMenu   = widget_button(menuBar,value=" Frames",font= info.font2)
fbutton = widget_button(FMenu,value = "Display Frames",uvalue = 'frame')

PMenu = widget_button(menuBar,value="Print",font = info.font2)
PbuttonS = widget_button(Pmenu,value = "Print Plot 1",uvalue='print_S')
PbuttonZ = widget_button(Pmenu,value = "Print Zoom Image (Plot 2)",uvalue='print_Z')
PbuttonU = widget_button(Pmenu,value = "Print Plot 2",uvalue='print_U')
PbuttonP = widget_button(Pmenu,value = "Print Frame value for pixel",uvalue='print_P')
PbuttonE = widget_button(Pmenu,value = "Print Slope value for pixel for exposure",uvalue='print_E')

filelabelID = widget_label(info.SlopeQuickLook, $
                           value=info.control.filename_slope,/align_left, $
                           font=info.font2,/dynamic_resize)



;_______________________________________________________________________
find_slope_binfactor,info

; determine the main window display based on scale and image size

find_slope_binfactor, info

xsize = info.data.slope_xsize/info.slope.binfactor
ysize = info.data.slope_ysize/info.slope.binfactor
info.slope.xplot_size = fix(xsize)
info.slope.yplot_size = fix(ysize)

;info.slope.xplot_size = 258
;info.slope.yplot_size = 256
;if(info.data.subarray ne 0 ) then info.slope.xplot_size = 256

info.slope.integrationNO = info.control.int_num

;print,' info.slope.integration control.int_num',info.slope.integrationNO,info.control.int_num
info.slope.current_graph = 0
;*********
; Draw Main Display Window
; for Single Slope insecption image
;*********

graphID_master1 = widget_base(info.SlopeQuickLook,row=1)
graphID_master2 = widget_base(info.SlopeQuickLook,row=1)

info.slope.graphID11 = widget_base(graphID_master1,col=1)
info.slope.graphID12 = widget_base(graphID_master1,col=1)
info.slope.graphID13 = widget_base(graphID_master1,col=1)
infoID00 = widget_base(graphID_master1,col=1)

info.slope.graphID21 = widget_base(graphID_master2,col=1)
info.slope.graphID22 = widget_base(graphID_master2,col=1)
;graphID_blank  = widget_base(graphID_master2,col=1)
infoID01 = widget_base(graphID_master2,col=1)

;_______________________________________________________________________
;
;*****
; set up structure for pass information around
;_______________________________________________________________________

info.slope.default_scale_graph[*,*] = 1
info.slope.default_scale_ramp[*] = 1
info.slope.default_scale_slope[*] =  1


zoomvalues = ['No Zoom', '2X', '4X', '8X', '16X', '32x']
if(info.data.subarray ne 0) then zoomvalues = ['No Zoom', '2X', '4X', '8X', '16X', '32X']
options = ['Plot Options: ', 'Histogram', 'Column Slice','Row Slice ' ]


bimage = "Binned 4 X 4"
if(info.slope.binfactor eq 1) then bimage = "No Binning"
if(info.slope.binfactor eq 2) then bimage = "Binned 2 X 2"
if(info.slope.binfactor lt 1.0) then bimage = "Blown up by " + $
  strcompress(string(1/info.image.binfactor,format="(f6.4)"),/remove_all)

info.slope.bindisplay=[bimage,"Scroll Full Image"] 

;_______________________________________________________________________


;************************************
;graph 1,1- slope image
;************************************

info.slope.plane[0] = 0
info.slope.plane_cal = -1

voptions = ['Slope Image: ', 'Uncertainty Image', 'Data Quality Flag',' Zero Pt', '# of Good Frames',$
           'Frame # of 1st Sat','# Good Segments', 'STD Fit']

if(info.data.cal_exist) then begin
    voptions = ['Slope Image: ', 'Uncertainty Image', 'Data Quality Flag',$
                ' Zero Pt', '# of Good Frames',$
                'Frame # of 1st Sat','# of Good Segments', 'STD FIT', ' Calibrated Image' ]
    info.slope.plane_cal = 8
endif

if(info.data.slope_zsize eq 3) then voptions = ['Slope Image: ',' Zero Pt', 'STD FIT']


if(info.data.slope_zsize eq 2) then voptions = ['Slope Image: ',' Zero Pt']



if(info.data.slope_zsize gt 8) then $
voptions = ['Slope Image: ', 'Uncertainty Image', 'Data Quality Flag',' Zero Pt', '# of Good Frames',$
           'Frame # of 1st Sat','# Good Segments', $
            'STD FIT', ' Max 2 Pt Differences' , 'Read # max 2pt Diff', $
            'Standard Dev 2pt Diff' ,$
            'Slope 2pt Diff ' ]

if(info.data.slope_zsize gt 8 and info.data.cal_exist) then begin
    voptions = ['Slope Image: ', 'Uncertainty Image', 'Data Quality Flag',' Zero Pt', $
                '# of Good Frames','Frame # of 1st Sat','# of Good Segments', $
                'STD FIT', ' Max 2 Pt Differences' , 'Read # max 2pt Diff', $
                'Standard Dev 2pt Diff' ,$
                'Slope 2pt Diff ', 'Calibrated Image' ]
    info.slope.plane_cal = 12
endif
  
bintitle =   "[" + strtrim(string(info.data.slope_xsize),2) + ' x ' +$
        strtrim(string(info.data.slope_ysize),2) + " " + info.slope.bindisplay[0] + "]"

base1 = widget_base(info.slope.graphID11,row=1)
info.slope.graph_label[0] = widget_droplist(base1,value=voptions,$
                                            uvalue='voption1',font=info.font5)
slope_bin = widget_label(base1,value = bintitle,font=info.font4)

xsize_label = 9

slmean = info.data.slope_stat[0,0]
slmin = info.data.slope_stat[3,0]
slmax = info.data.slope_stat[4,0]

smean =  strcompress(string(slmean),/remove_all)
smin = strcompress(string(slmin),/remove_all) 
smax = strcompress(string(slmax),/remove_all) 

range_min = info.data.slope_stat[5,0]
range_max = info.data.slope_stat[6,0]
info.slope.graph_range[0,0] = range_min
info.slope.graph_range[0,1] = range_max

stat_base1 = widget_base(info.slope.graphID11,row=1)
stat_base2 = widget_base(info.slope.graphID11,row=1)


info.slope.optionMenu[0] = widget_droplist(stat_base1,value=options,uvalue='option1',font=info.font4)
FullSize = widget_button(stat_base1,value='Inspect Image',uvalue='inspect_1',font=info.font4)

info.slope.slabelID[0] = widget_label(stat_base2,value=('Mean: ' + smean),$ 
                                          /align_left,font=info.font4)
info.slope.mlabelID[0] = widget_label(stat_base2,$
                         value=(' Min: ' + smin + ' Max: ' + smax),$
                                      /align_left,font=info.font4)



; min and max scale of  image
info.slope.srange_base[0] = widget_base(info.slope.graphID11,row=1)
info.slope.image_recomputeID[0] = widget_button(info.slope.srange_base[0],$
                                                value=' Image Scale ',$
                                                font=info.font4,$
                                                uvalue = 'scale1',/dynamic_resize)

info.slope.rlabelID[0,0] = cw_field(info.slope.srange_base[0],title="min",$
                                    font=info.font4,uvalue="cr1_b",$
                                    /float,/return_events,xsize=xsize_label,value =range_min,$
                                    fieldfont = info.font4)

info.slope.rlabelID[0,1] = cw_field(info.slope.srange_base[0],title="max",$
                                    font=info.font4,uvalue="cr1_t",$
                                    /float,/return_events,xsize=xsize_label,value =range_max,$
                                    fieldfont = info.font4)


info.slope.plot_base[0] = widget_base(info.slope.graphID11)
; slope size is the same size as the image size
info.slope.graphID[0] = widget_draw(info.slope.plot_base[0],$
                                    xsize =info.slope.xplot_size,$ 
                                    ysize =info.slope.yplot_size,$
                                    /Button_Events,$
                                    retain=info.retn,uvalue='spixel1')
;_______________________________________________________________________
; initialize x_pos,y_pos
info.slope.x_pos =(info.data.slope_xsize/info.slope.binfactor)/2.0
info.slope.y_pos = (info.data.slope_ysize/info.slope.binfactor)/2.0


;*****
;graph 1,2; window 2 initally set to Slope image zoom
;*****
info.slope.plane[1] = 0 ; default to be slope image

 subt = "    Zoom Centered on Slope image       "
info.slope.graph_label[1] = widget_label(info.slope.graphID12,$
                                         value=subt,/align_center,$
                                        font=info.font5,/sunken_frame)


range_min = info.data.slope_stat[5,0]
range_max = info.data.slope_stat[6,0]
info.slope.graph_range[1,0] = range_min
info.slope.graph_range[1,1] = range_max

stat_base1 = widget_base(info.slope.graphID12,row=1)
stat_base2 = widget_base(info.slope.graphID12,row=1)
info.slope.optionMenu[1] = widget_droplist(stat_base1,value=options,uvalue='option2',font=info.font4)

info.slope.slabelID[1] = widget_label(stat_base2,value=('Mean:       ' + smean),$ 
                                          /align_left,font=info.font4)
info.slope.mlabelID[1] = widget_label(stat_base2,$ 
                         value=(' Min:        '  + smin + ' Max:         ' + smax),$
                                      /align_left,font=info.font4)
; min and max scale of  image
info.slope.srange_base[1] = widget_base(info.slope.graphID12,row=1)
info.slope.image_recomputeID[1] = widget_button(info.slope.srange_base[1],value=' Image Scale ',$
                                                font=info.font4,$
                                                uvalue = 'scale2',/dynamic_resize)

info.slope.rlabelID[1,0] = cw_field(info.slope.srange_base[1],title="min",font=info.font4,$
                                    uvalue="cr2_b",/float,/return_events,$
                                    xsize=xsize_label,value =range_min,$
                                    fieldfont = info.font4)

info.slope.rlabelID[1,1] = cw_field(info.slope.srange_base[1],title="max",font=info.font4,$
                                    uvalue="cr2_t",/float,/return_events,$
                                    xsize = xsize_label,value =range_max,$
                                   fieldfont=info.font4)

info.slope.plot_base[1] = widget_base(info.slope.graphID12)

info.slope.graphID[1] = widget_draw(info.slope.plot_base[1],$
;                                    xsize =info.slope.xplot_size,$ 
;                                    ysize =info.slope.yplot_size,$
                                    xsize =info.plotsize1,$ 
                                    ysize =info.plotsize1,$
                                    /Button_Events,$
                                    retain=info.retn,uvalue='spixel2')



zoom_base = widget_base(info.slope.graphID12,row=1)

info.slope.zoom_label[0] = widget_button(zoom_base,value=zoomvalues[0],$
                                           uvalue='zsize1',$
                                           font=info.font4)

info.slope.zoom_label[1] = widget_button(zoom_base,value=zoomvalues[1],$
                                           uvalue='zsize2',$
                                           font=info.font4)
info.slope.zoom_label[2] = widget_button(zoom_base,value=zoomvalues[2],$
                                           uvalue='zsize3',$
                                           font=info.font4)
info.slope.zoom_label[3] = widget_button(zoom_base,value=zoomvalues[3],$
                                           uvalue='zsize4',$
                                           font=info.font4)
info.slope.zoom_label[4] = widget_button(zoom_base,value=zoomvalues[4],$
                                           uvalue='zsize5',$
                                           font=info.font4)

info.slope.zoom_label[5] = widget_button(zoom_base,value=zoomvalues[5],$
                                           uvalue='zsize5',$
                                           font=info.font4)

;************************************************************************
;graph 1,3- uncertainty slope image (default) 
;************************************************************************

base1 = widget_base(info.slope.graphID13,row=1)

info.slope.graph_label[2] = widget_droplist(base1,value=voptions,$
                                            uvalue='voption2',font=info.font5)
slope_bin = widget_label(base1,value = bintitle,font=info.font4)

widget_control,info.slope.graph_label[2],set_droplist_select=1
info.slope.plane[2] = 1 
slmean = info.data.slope_stat[0,1]
slmin = info.data.slope_stat[3,1]
slmax = info.data.slope_stat[4,1]

smean =  strcompress(string(slmean),/remove_all)
smin = strcompress(string(slmin),/remove_all) 
smax = strcompress(string(slmax),/remove_all) 

range_min = info.data.slope_stat[5,1]
range_max = info.data.slope_stat[6,1]
info.slope.graph_range[2,0] = range_min
info.slope.graph_range[2,1] = range_max


stat_base1 = widget_base(info.slope.graphID13,row=1)
stat_base2 = widget_base(info.slope.graphID13,row=1)


info.slope.optionMenu[2] = widget_droplist(stat_base1,value=options,uvalue='option3',font=info.font4)
FullSize = widget_button(stat_base1,value='Inspect Image',uvalue='inspect_3',font=info.font4)

info.slope.slabelID[2] = widget_label(stat_base2,value=('Mean: ' + smean),$ 
                                          /align_left,font=info.font4)
info.slope.mlabelID[2] = widget_label(stat_base2,$
                         value=(' Min: ' + smin + ' Max: ' + smax),$
                                      /align_left,font=info.font4)


; min and max scale of  image
info.slope.srange_base[2] = widget_base(info.slope.graphID13,row=1)
info.slope.image_recomputeID[2] = widget_button(info.slope.srange_base[2],$
                                                value=' Image Scale ',$
                                                font=info.font4,$
                                                uvalue = 'scale3',/dynamic_resize)

info.slope.rlabelID[2,0] = cw_field(info.slope.srange_base[2],title="min",$
                                    font=info.font4,uvalue="cr3_b",$
                                    /float,/return_events,xsize=xsize_label,value =range_min,$
                                    fieldfont = info.font4)

info.slope.rlabelID[2,1] = cw_field(info.slope.srange_base[2],title="max",$
                                    font=info.font4,uvalue="cr3_t",$
                                    /float,/return_events,xsize=xsize_label,value =range_max,$
                                    fieldfont = info.font4)


info.slope.plot_base[2] = widget_base(info.slope.graphID13)
; slope size is the same size as the image size
info.slope.graphID[2] = widget_draw(info.slope.plot_base[2],$
                                    xsize =info.slope.xplot_size,$ 
                                    ysize =info.slope.yplot_size,$
                                    /Button_Events,$
                                    retain=info.retn,uvalue='spixel3')



;_______________________________________________________________________
; Information 
; Move through images (integrations)
; Pixel Information
compare_label = cw_field(infoID00,title='Compare Image 1 to Integration #',$
                         font = info.font5,uvalue='fcompare',/integer,/return_events,$
                         value = 0, xsize=4,fieldfont = info.font3)
compare_info = widget_label(infoID00,value='(Enter 0 to compare to the  Final Averaged Image)')
sinum = strcompress(string(info.data.nslopes),/remove_all)
compare_info = widget_label(infoID00,value = ' Number of integrations in file: ' + sinum,/align_left)

move_base0 = widget_base(infoID00,row=1,/align_left)
jintegration = info.slope.IntegrationNO

;print,'Integration NO',info.slope.IntegrationNO
moveframe_label = widget_label(move_base0,value='Change Image Displayed',$
                                font=info.font5,/sunken_frame)
move_base1 = widget_base(infoID00,row=1,/align_left)
info.slope.integration_label = cw_field(move_base1,$
                    title=" Integration # ",font=info.font5, $
                    uvalue="integration",/integer,/return_events, $
                    value=jintegration+1,xsize=4,$
                    fieldfont=info.font3)


base1 = widget_base(infoID00,row=1)
FinalID = widget_button(base1,value='View Averaged Slope',uvalue='final_inspect',font=info.font5)
labelID = widget_button(move_base1,uvalue='integr_move_dn',value='<',font=info.font3)
labelID = widget_button(move_base1,uvalue='integr_move_up',value='>',font=info.font3)


;sf = "Average Slope" 

;slope_intid = widget_label(infoID00,value= sf,/align_left)

info.slope.pix_statID3 = widget_label(infoID00,value = info.slope.pix_statLabel[0]+$
                                        ' =                     ' ,/align_left)

;__________________________
; Pixel Statistics Display
blank_label= widget_label(infoID00,value="     ")
general_label= widget_label(infoID00,$
                            value=" Pixel Information [Image 1032 X 1024]",/align_left,$
                            font=info.font5,/sunken_frame)

; button to change 
pix_num_base = widget_base(infoID00,row=1,/align_left)
labelID = widget_button(pix_num_base,uvalue='pix_move_x1',value='<',font=info.font3)
labelID = widget_button(pix_num_base,uvalue='pix_move_x2',value='>',font=info.font3)

xvalue = info.slope.x_pos*info.slope.binfactor
yvalue = info.slope.y_pos*info.slope.binfactor
info.slope.pix_label[0] = cw_field(pix_num_base,title="x",font=info.font4, $
                                   uvalue="pix_x_val",/integer,/return_events, $
                                   value=fix(xvalue+1),xsize=6,$
                                   fieldfont=info.font3)

pix_num_base = widget_base(infoID00,row=1,/align_left)
labelID = widget_button(pix_num_base,uvalue='pix_move_y1',value='<',font=info.font3)
labelID = widget_button(pix_num_base,uvalue='pix_move_y2',value='>',font=info.font3)

info.slope.pix_label[1] = cw_field(pix_num_base,title="y",font=info.font4, $
                                   uvalue="pix_y_val",/integer,/return_events, $
                                   value=fix(yvalue+1),xsize=6,$
                                   fieldfont=info.font3)

if(info.data.raw_exist eq 1) then $
flabel = widget_button(infoID00,value="Get Frame Values",/align_left,$
                        uvalue = "getframe")


;_______________________________________________________________________

;*****
;graph 2,1 - Ramp values for pixel
;*****
ramp_range = fltarr(2,2)        ; plot range for the ramp plot, 
tlabelID = widget_label(info.slope.graphID21,$
                        value = " Frame Values for Selected Pixel, click on pixel to plot ramp)" ,$
                        /align_center,$
                        font=info.font5,/sunken_frame)
info.slope.overplot_fit= 1 
overplotSlopeID = lonarr(2)
oinfo = widget_base(info.slope.graphID21,/row)

overplot = widget_label(oinfo,value = 'Over-plot Values from Fit (red)',/sunken_frame,$
                        font = info.font5,/align_left)

oBase = Widget_base(oinfo,/row,/nonexclusive)

OverplotSlopeID[0] = Widget_button(oBase, Value = ' Yes ',uvalue = 'overslope1')
widget_control,OverplotSlopeID[0],Set_Button = 1

OverplotSlopeID[1] = Widget_Button(oBase, Value = ' No ',uvalue = 'overslope2')
widget_control,OverplotSlopeID[1],Set_Button = 0



info.slope.overplotSlopeID = overplotSlopeID

overplotRefCorrectedID = lonarr(2)
if(info.control.file_refcorrection_exist eq 1)then begin 
    oinfo = widget_base(info.slope.graphID21,/row)
    overplot = widget_label(oinfo,value = 'Over-plot Reference Corrected Data (blue)',$
                            font = info.font5,/align_left)

    oBase = Widget_base(oinfo,/row,/nonexclusive)

    OverplotRefCorrectedID[0] = Widget_button(oBase, Value = ' Yes ',uvalue = 'overref1')
    widget_control,OverplotRefCorrectedID[0],Set_Button = 1

    OverplotRefCorrectedID[1] = Widget_Button(oBase, Value = ' No ',uvalue = 'overref2')
    widget_control,OverplotRefCorrectedID[1],Set_Button = 0
endif

info.slope.overplotRefcorrectedID = overplotRefCorrectedID


overplotcrID = lonarr(2)
if(info.control.file_ids_exist eq 1)then begin 
    oinfo = widget_base(info.slope.graphID21,/row)
    overplot = widget_label(oinfo,value = 'Mark Noise & Cosmic Rays (yellow)',$
                            font = info.font5,/align_left)


    oBase = Widget_base(oinfo,/row,/nonexclusive)

    OverplotCRID[0] = Widget_button(oBase, Value = 'Yes',uvalue = 'overcr1')
    widget_control,OverplotcrID[0],Set_Button = 1

    OverplotCRID[1] = Widget_Button(oBase, Value = 'No',uvalue = 'overcr2')
    widget_control,OverplotCRID[1],Set_Button = 0

    mark = widget_label(oinfo,value = '(Corrupted Frames are marked in a yellow box)',$
                            font = info.font6,/align_left)
endif

info.slope.overplotCRID = overplotCRID


overplotmdcID = lonarr(2)

if(info.control.file_mdc_exist eq 1)then begin 
    oinfo = widget_base(info.slope.graphID21,/row)
    overplot = widget_label(oinfo,value = 'Overplot Mean Dark Corrected Data (yellow +)',$
                            font = info.font5,/align_left)

    oBase = Widget_base(oinfo,/row,/nonexclusive)

    OverplotmdcID[0] = Widget_button(oBase, Value = 'Yes',uvalue = 'overmdc1')
    widget_control,OverplotmdcID[0],Set_Button = 1

    OverplotmdcID[1] = Widget_Button(oBase, Value = 'No',uvalue = 'overmdc2')
    widget_control,OverplotmdcID[1],Set_Button = 0

endif

info.slope.overplotmdcID = overplotmdcID

overplotresetID = lonarr(2)
if(info.control.file_reset_exist eq 1)then begin 
    oinfo = widget_base(info.slope.graphID21,/row)
    overplot = widget_label(oinfo,value = 'Overplot Reset Corrected Data (blue +)',$
                            font = info.font5,/align_left)

    oBase = Widget_base(oinfo,/row,/nonexclusive)

    OverplotresetID[0] = Widget_button(oBase, Value = 'Yes',uvalue = 'overreset1')
    widget_control,OverplotresetID[0],Set_Button = 1

    OverplotresetID[1] = Widget_Button(oBase, Value = 'No',uvalue = 'overreset2')
    widget_control,OverplotresetID[1],Set_Button = 0

endif
info.slope.overplotresetID = overplotresetID

overplotrscdID = lonarr(2)
if(info.control.file_rscd_exist eq 1)then begin 
    oinfo = widget_base(info.slope.graphID21,/row)
    overplot = widget_label(oinfo,value = 'Overplot RSCD Corrected Data (green * )',$
                            font = info.font5,/align_left)

    oBase = Widget_base(oinfo,/row,/nonexclusive)

    OverplotrscdID[0] = Widget_button(oBase, Value = 'Yes',uvalue = 'overrscd1')
    widget_control,OverplotrscdID[0],Set_Button = 1

    OverplotrscdID[1] = Widget_Button(oBase, Value = 'No',uvalue = 'overrscd2')
    widget_control,OverplotrscdID[1],Set_Button = 0

endif
info.slope.overplotrscdID = overplotrscdID


overplotlastframeID = lonarr(2)
if(info.control.file_lastframe_exist eq 1)then begin 
    oinfo = widget_base(info.slope.graphID21,/row)
    overplot = widget_label(oinfo,value = 'Overplot Lastframe Corrected Data (blue)',$
                            font = info.font5,/align_left)

    oBase = Widget_base(oinfo,/row,/nonexclusive)

    OverplotlastframeID[0] = Widget_button(oBase, Value = 'Yes',uvalue = 'overlastframe1')
    widget_control,OverplotlastframeID[0],Set_Button = 1

    OverplotlastframeID[1] = Widget_Button(oBase, Value = 'No',uvalue = 'overlastframe2')
    widget_control,OverplotlastframeID[1],Set_Button = 0

endif
info.slope.overplotlastframeID = overplotlastframeID



overplotlcID = lonarr(2)

if(info.control.file_lc_exist eq 1)then begin 
    oinfo = widget_base(info.slope.graphID21,/row)
    overplot = widget_label(oinfo,value = 'Overplot Linearity Corrected Data (green +)',$
                            font = info.font5,/align_left)

    oBase = Widget_base(oinfo,/row,/nonexclusive)

    OverplotLCID[0] = Widget_button(oBase, Value = 'Yes',uvalue = 'overlc1')
    widget_control,OverplotlcID[0],Set_Button = 1

    OverplotLCID[1] = Widget_Button(oBase, Value = 'No',uvalue = 'overlc2')
    widget_control,OverplotlcID[1],Set_Button = 0

endif

info.slope.overplotlcID = overplotlcID


int_range = intarr(2) 
int_range[0] = 1  ; initialize to look at first integration
int_range[1] = 1
info.slope.int_range[*] = int_range[*]

int_base = widget_base(info.slope.graphID21,row=1,/align_left)
IrangeID = lonarr(2)
info.slope.IrangeID[0] = cw_field(int_base,$
                  title="Integration Range: Start",font=info.font4, $
                  uvalue="int_chng_1",/integer,/return_events, $
                  value=info.slope.int_range[0],xsize=3)
info.slope.IrangeID[1] = cw_field(int_base,$
                  title="End",font=info.font4, $
                  uvalue="int_chng_2",/integer,/return_events, $
                  value=info.slope.int_range[1],xsize=3)

labelID = widget_button(int_base,uvalue='int_move_d',value='<',font=info.font4)
labelID = widget_button(int_base,uvalue='int_move_u',value='>',font=info.font4)
IAllButton = Widget_button(int_base, Value = 'Plot All',$
                           uvalue = 'int_grab_all')
widget_control,IAllButton,Set_Button = 0

IOAllButton = Widget_button(int_base, Value = 'Over-Plot All',$
                           uvalue = 'int_overplot')
widget_control,IOAllButton,Set_Button = 0

info.slope.graphID[3] = widget_draw(info.slope.graphID21,$
                                    xsize = info.plotsize2,$
                                    ysize = info.plotsizeA+10,$
                                    retain=info.retn)


;buttons to  change the x and y ranges

pix_num_base2 = widget_base(info.slope.graphID21,row=1)
labelID = widget_label(pix_num_base2,value="X->",font=info.font4)
info.slope.ramp_mmlabel[0,0] = cw_field(pix_num_base2,title="min:",font=info.font4, $
                                        uvalue="ramp_mmx1",/integer,/return_events, $
                                        value=fix(ramp_range[0,0]), $
                                        xsize=5,fieldfont=info.font4)

info.slope.ramp_mmlabel[0,1] = cw_field(pix_num_base2,title="max:",font=info.font4, $
                                        uvalue="ramp_mmx2",/integer,/return_events, $
                                        value=fix(ramp_range[0,1]),xsize=5,$
                                        fieldfont=info.font4)

info.slope.ramp_recomputeID[0] = widget_button(pix_num_base2,value='  Plot Range ',$
                                               font=info.font4,$
                                               uvalue = 'r1',/dynamic_resize)

;pix_num_base3 = widget_base(info.slope.graphID21,row=1)
pix_num_base3 = pix_num_base2
labelID = widget_label(pix_num_base3,value="Y->",font=info.font4)
info.slope.ramp_mmlabel[1,0] = cw_field(pix_num_base3,title="min:",font=info.font4, $
                                        uvalue="ramp_mmy1",/float,/return_events, $
                                        value=ramp_range[1,0],xsize=info.xsize_label,$
                                        fieldfont=info.font4)

info.slope.ramp_mmlabel[1,1] = cw_field(pix_num_base3,title="max:",font=info.font4, $
                                        uvalue="ramp_mmy2",/float,/return_events, $
                                        value=ramp_range[1,1],xsize=info.xsize_label,$
                                        fieldfont=info.font4)

info.slope.ramp_recomputeID[1] = widget_button(pix_num_base3,value='  Plot Range ',$
                                               font=info.font4,$
                                               uvalue = 'r2',/dynamic_resize)

info.slope.ramp_range = ramp_range
ainfo = widget_base(info.slope.graphID21,/row)
info.slope.pixeldisplay=["Automatically Read/Plot Pixel Values",$
                         "Do not Read/Update Plot with new pixels values"] 
updatepixel = widget_droplist(ainfo,value=info.slope.pixeldisplay,$
                                       uvalue='auto',/align_left)
 info.slope.updatingID = widget_label(ainfo,value='Click on a pixel to plot ramp' ,$
                                       /align_left,/dynamic_resize)

info.slope.autopixelupdate = 1





;*****

;*****
;graph 2,2 - slope values for entire exposure for a certain pixel
;*****

slope_range = fltarr(2,2)        ; plot range for pixel over exposure ,


stitle = "Slope Values for Selected Pixel for Exposure"
stitle1 = " Averaged Slope is given at Int = 0" 

if(not info.data.slope_exist) then stitle = "NO Slope Values in Selected Pixel for Exposure"
tlabelID = widget_label(info.slope.graphID22,value = stitle,/align_center,$
                                     font=info.font5,/sunken_frame)

tlabelID = widget_label(info.slope.graphID22,value = stitle1,/align_center)

pix_num_base = widget_base(info.slope.graphID22,row=1,/align_center)

info.slope.graphID[4] = widget_draw(info.slope.graphID22,$
                                    xsize = info.plotsize3,$
                                    ysize = info.plotsize1,$
                                    retain=info.retn)

;buttons to  change the x and y ranges

pix_num_base2 = widget_base(info.slope.graphID22,row=1)
labelID = widget_label(pix_num_base2,value="X->",font=info.font4)
info.slope.slope_mmlabel[0,0] = cw_field(pix_num_base2,title="min:",font=info.font4, $
                                        uvalue="slop_mmx1",/integer,/return_events, $
                                        value=slope_range[0,0], $
                                        xsize=info.xsize_label,fieldfont=info.font4)

info.slope.slope_mmlabel[0,1] = cw_field(pix_num_base2,title="max:",font=info.font4, $
                                        uvalue="slop_mmx2",/integer,/return_events, $
                                        value=slope_range[0,1],xsize=info.xsize_label,$
                                        fieldfont=info.font4)

info.slope.slope_recomputeID[0] = widget_button(pix_num_base2,value=' Plot Range ',$
                                               font=info.font4,$
                                               uvalue = 'e1',/dynamic_resize)

pix_num_base3 = widget_base(info.slope.graphID22,row=1)

labelID = widget_label(pix_num_base3,value="Y->",font=info.font4)
info.slope.slope_mmlabel[1,0] = cw_field(pix_num_base3,title="min:",font=info.font4, $
                                        uvalue="slop_mmy1",/float, /return_events,$
                                        value=slope_range[1,0],xsize=info.xsize_label,$
                                        fieldfont=info.font4)

info.slope.slope_mmlabel[1,1] = cw_field(pix_num_base3,title="max:",font=info.font4, $
                                        uvalue="slop_mmy2",/float,/return_events, $
                                        value=slope_range[1,1],xsize=info.xsize_label,$
                                        fieldfont=info.font4)

info.slope.slope_recomputeID[1] = widget_button(pix_num_base3,value=' Plot Range ',$
                                               font=info.font4,$
                                               uvalue = 'e2',/dynamic_resize)

info.slope.slope_range = slope_range


;_______________________________________________________________________
info.slope.pix_statLabel = $
  [" Average Slope (DN/s)", "Uncertainty(DN/S)","Data Quality Flag","Zero Pt","STD Fit (DN)",$
   "Frame # of 1st Sat Value", "# Good Segments","# Good Frames", "Calibrated Value"]

info.slope.pix_statFormat =  ["F16.4", "F16.8", "I5","F12.4","F10.2","F5.0","F5.0","F5.0","F14.4"] 
info.slope.pix_statLabel2 = ["Max 2pt Diff","Read # Max 2 pt Diff",$
                            "Slope 2pt Diff", "STDDEV 2pt diff" ]

info.slope.pix_statFormat2 =  ["F14.4","F7.3", "F10.5", "F14.6"]  

slope_intid = widget_label(infoID01,value= "Reduced Information of Current Integration",/align_left)

for i = 0,1 do begin  
    info.slope.pix_statID[i] = widget_label(infoID01,value = info.slope.pix_statLabel[i]+$
                                        ' =  ' ,/align_left,/dynamic_resize)
    
endfor


info_base = widget_base(infoID01,row=1,/align_left)
info.slope.pix_statID[2] = widget_label(info_base,value = info.slope.pix_statLabel[2]+$
                                        ' =  ' ,/align_left,/dynamic_resize)                                       
info_label = widget_button(info_base,value = 'Info',uvalue = 'datainfo')
for i = 3,8 do begin  
    info.slope.pix_statID[i] = widget_label(infoID01,value = info.slope.pix_statLabel[i]+$
                                        ' =   ' ,/align_left,/dynamic_resize)
    
endfor

if(info.data.slope_zsize gt 8) then begin 
    for i = 0,3 do begin 
        info.slope.pix_statID2[i]=widget_label(infoID01,value = info.slope.pix_statLabel2[i]+$
                                                      ' =               ' ,/align_left)
    endfor
endif


;Set up the GUI
longline = '                                                                                                                        '
longtag = widget_label(SlopeQuicklook,value = longline)
Widget_control,info.SlopeQuickLook,/Realize
XManager,'msql',info.SlopeQuickLook,/No_Block,$
	event_handler='msql_event'


;_______________________________________________________________________
;_______________________________________________________________________
; realize main panel
widget_control,info.SlopeQuickLook,/realize

; get the window ids of the draw windows

for i = 0,4 do begin
    widget_control,info.slope.graphID[i],get_value=tdraw_id
    info.slope.draw_window_id[i] = tdraw_id
    ;if(i le 2) then begin 
    ;    window,/pixmap,xsize=info.slope.xplot_size,ysize=info.slope.yplot_size,/free
    ;    info.slope.pixmapID[i] = !D.WINDOW
    ;endif


    if(i eq 0 or i eq 2 ) then begin
        window,/pixmap,xsize=info.slope.xplot_size,ysize=info.slope.yplot_size,/free
        info.slope.pixmapID[i] = !D.WINDOW
    endif

    if(i eq 1 ) then begin
        window,/pixmap,xsize=info.plotsize1,ysize=info.plotsize1,/free
        info.slope.pixmapID[i] = !D.WINDOW
    endif



endfor
loadct,info.col_table,/silent

; plot the slope image
msql_update_slope,info.slope.plane[0],0,info

; plot the slope image
msql_update_slope,info.slope.plane[2],2,info

info.slope.plane[1] = 0 ; default to slope image
info.slope.zoom_window = 1
info.slope.x_zoom = info.slope.x_pos* info.binfactor
info.slope.y_zoom = info.slope.y_pos* info.binfactor
msql_update_zoom_image,info

xvalue = fix(  (info.slope.x_pos) *info.slope.binfactor)
yvalue = fix(  (info.slope.y_pos) *info.slope.binfactor)

if(info.data.nramps lt 200) then begin 
    msql_read_rampdata,xvalue,yvalue,pixeldata,info
    if ptr_valid (info.slope.pixeldata) then ptr_free,info.slope.pixeldata
    info.slope.pixeldata = ptr_new(pixeldata)
endif

; read slope information on pixel 
msql_read_slopedata,xvalue,yvalue,info


info.data.refcorrected_xsize = info.data.slope_xsize
info.data.refcorrected_ysize = info.data.slope_ysize

if(info.control.file_refcorrection_exist eq 1) then begin 
    info.slope.overplot_reference_corrected = 1
    if(info.data.nramps lt 200) then  msql_read_refcorrected_data,xvalue,yvalue,info
endif

info.data.lc_xsize = info.data.slope_xsize
info.data.lc_ysize = info.data.slope_ysize

if(info.control.file_lc_exist eq 1) then begin 
    info.slope.overplot_lc = 1
    if(info.data.nramps lt 200) then msql_read_lc_data,xvalue,yvalue,info
endif

info.data.mdc_xsize = info.data.slope_xsize
info.data.mdc_ysize = info.data.slope_ysize
if(info.control.file_mdc_exist eq 1) then begin
    info.slope.overplot_mdc = 1
    if(info.data.nramps lt 200) then msql_read_mdc_data,xvalue,yvalue,info
 endif

info.data.reset_xsize = info.data.slope_xsize
info.data.reset_ysize = info.data.slope_ysize
if(info.control.file_reset_exist eq 1) then begin 
    info.slope.overplot_reset = 1
    if(info.data.nramps lt 200) then msql_read_reset_data,xvalue,yvalue,info
 endif

info.data.rscd_xsize = info.data.slope_xsize
info.data.rscd_ysize = info.data.slope_ysize
if(info.control.file_rscd_exist eq 1) then begin 
    info.slope.overplot_rscd = 1
    if(info.data.nramps lt 200) then msql_read_rscd_data,xvalue,yvalue,info
 endif

info.data.lastframe_xsize = info.data.slope_xsize
info.data.lastframe_ysize = info.data.slope_ysize
if(info.control.file_lastframe_exist eq 1) then begin 
    info.slope.overplot_lastframe = 1
    if(info.data.nramps lt 200) then msql_read_lastframe_data,xvalue,yvalue,info
 endif






info.data.id_xsize = info.data.slope_xsize
info.data.id_ysize = info.data.slope_ysize

if(info.control.file_ids_exist eq 1) then begin 
    info.slope.overplot_cr = 1
    if(info.data.nramps lt 200) then msql_read_id_data,xvalue,yvalue,info
endif


; This takes a long time to read if # int large - may not need to do
                                ;it this way - read slope info with
                                ;              each change in pixel

read_all_slopes,info.control.filename_slope,slopedata,exists,status,error_message
if ptr_valid (info.data.pslopedata_all) then ptr_free,info.data.pslopedata_all
info.data.pslopedata_all = ptr_new(slopedata)
slopedata = 0


if(info.data.nramps lt 200) then msql_update_rampread,info


msql_update_slopepixel,info

msql_update_pixel_stat_slope,info


Widget_Control,info.QuickLook,Set_UValue=info
sinfo = {info        : info}

Widget_Control,info.SlopeQuickLook,Set_UValue=sinfo
end
