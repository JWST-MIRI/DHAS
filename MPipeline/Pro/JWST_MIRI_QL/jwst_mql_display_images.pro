; This program is used to display and analyze the science frames,
; slope image if it exists. This is the main display for the QL tool.
; From this window the user can query pixel values, zoom the images,
; get statstics on the data
;***********************************************************************
; _______________________________________________________________________
pro jwst_mql_quit,event
; _______________________________________________________________________

widget_control,event.top, Get_UValue = tinfo
widget_control,tinfo.info.jwst_QuickLook,Get_UValue=info

if( XRegistered ('jwst_mql')) then begin ; channel image display
    widget_control,info.jwst_RawQuickLook,/destroy
endif
end

; _______________________________________________________________________
pro jwst_mql_update_pixel_location,info
; Update the pixel location is the user selected a different pixel
; _______________________________________________________________________
ij = info.jwst_image.current_graph
wset,info.jwst_image.draw_window_id[ij]
; set up the pixel box window - this will initialize the
;                               jwst_mql_update_rampread.pro x and y positions.

xsize_image = fix(info.jwst_data.image_xsize/info.jwst_image.binfactor) 
ysize_image = fix(info.jwst_data.image_ysize/info.jwst_image.binfactor)
device,copy=[0,0,xsize_image,ysize_image, 0,0,info.jwst_image.pixmapID[ij]]

xvalue = info.jwst_image.x_pos 
yvalue = info.jwst_image.y_pos

xcenter = xvalue + 0.5
ycenter = yvalue + 0.5

box_coords1 = [xcenter,(xcenter+1), $
               ycenter,(ycenter+1)]
plots,box_coords1[[0,0,1,1,0]],box_coords1[[2,3,3,2,2]],psym=0,/device

end

;***********************************************************************
; _______________________________________________________________________
pro jwst_mql_update_pixel_stat,info
; _______________________________________________________________________

i = info.jwst_image.integrationNO
ii = info.jwst_image.integrationNO
j = info.jwst_image.frameNO
x = info.jwst_image.x_pos*info.jwst_image.binfactor
y = info.jwst_image.y_pos*info.jwst_image.binfactor

if(info.jwst_data.read_all eq 0) then begin
    i = 0
    if(info.jwst_data.num_frames ne info.jwst_data.ngroups) then begin 
        j = info.jwst_image.frameNO- info.jwst_control.frame_start
    endif
endif

pixelvalue = (*info.jwst_data.pimagedata)[i,j,x,y]
sp =   strtrim(string(pixelvalue,format="("+info.jwst_image.pix_statFormat[0]+")"),2)
widget_control,info.jwst_image.pix_statID[0],set_value=info.jwst_image.pix_statLabel[0]+' = ' +sp

ssignal = 'NA'
serror = 'NA'
sdq = 'NA'
if(info.jwst_control.file_slope_exist eq 1) then begin
    signal = (*info.jwst_data.preduced)[x,y,0]
    ssignal =   strtrim(string(signal,format="("+info.jwst_image.pix_statFormat1[0]+")"),2)
    error = (*info.jwst_data.preduced)[x,y,1]
    serror =   strtrim(string(error,format="("+info.jwst_image.pix_statFormat1[1]+")"),2)

    dq = (*info.jwst_data.preduced)[x,y,2]
    sdq =   strtrim(string(dq,format="("+info.jwst_image.pix_statFormat1[2]+")"),2)
endif


widget_control,info.jwst_image.pix_statID1[0],set_value=info.jwst_image.pix_statLabel1[0]+' = ' +ssignal
widget_control,info.jwst_image.pix_statID1[1],set_value= info.jwst_image.pix_statLabel1[1] +' = '+serror
widget_control,info.jwst_image.pix_statID1[2],set_value= info.jwst_image.pix_statLabel1[2] +' = '+ sdq

if(info.jwst_control.file_slope_int_exist eq 1) then begin
   ssignal = 'NA'
   serror = 'NA'
   sdq = 'NA'
    signal = (*info.jwst_data.preducedint)[x,y,0]
    ssignal =   strtrim(string(signal,format="("+info.jwst_image.pix_statFormat2[0]+")"),2)
    error = (*info.jwst_data.preducedint)[x,y,1]
    serror =   strtrim(string(error,format="("+info.jwst_image.pix_statFormat2[1]+")"),2)

    dq = (*info.jwst_data.preducedint)[x,y,2]
    sdq =   strtrim(string(dq,format="("+info.jwst_image.pix_statFormat2[2]+")"),2)
    widget_control,info.jwst_image.pix_statID2[0],set_value=info.jwst_image.pix_statLabel2[0]+' = ' +ssignal
    widget_control,info.jwst_image.pix_statID2[1],set_value= info.jwst_image.pix_statLabel2[1] +' = '+serror
    widget_control,info.jwst_image.pix_statID2[2],set_value= info.jwst_image.pix_statLabel2[2] +' = '+ sdq
endif


if(info.jwst_control.file_cal_exist eq 1) then begin
   ssignal = 'NA'
   serror = 'NA'
   sdq = 'NA'
   signal = (*info.jwst_data.preduced_cal)[x,y,0]
   ssignal =   strtrim(string(signal,format="("+info.jwst_image.pix_statFormat3[0]+")"),2)
   error = (*info.jwst_data.preduced_cal)[x,y,1]
   serror =   strtrim(string(error,format="("+info.jwst_image.pix_statFormat3[1]+")"),2)   
   dq = (*info.jwst_data.preduced_cal)[x,y,2]
   sdq =   strtrim(string(dq,format="("+info.jwst_image.pix_statFormat3[2]+")"),2)

   widget_control,info.jwst_image.pix_statID3[0],set_value=info.jwst_image.pix_statLabel3[0]+' = ' +ssignal
   widget_control,info.jwst_image.pix_statID3[1],set_value= info.jwst_image.pix_statLabel3[1] +' = '+serror
   widget_control,info.jwst_image.pix_statID3[2],set_value= info.jwst_image.pix_statLabel3[2] +' = '+ sdq
endif


end

; _______________________________________________________________________
pro jwst_mql_display_images,info
; _______________________________________________________________________
; This is the main widget program controlling the "Analyze" images
; window. This widget contains the science image, zoomed image,
; slope image and pixel plots. The images are by
; default plotted in a 4 X 4 binning mode. 
; The reference pixels are displayed 
; _______________________________________________________________________
status = 0
; if ql was run with command line options - we have already read in
;                                           the data
; if is is run interactively then we need to call setup_names

jwst_get_this_frame_stat,info  ; set up the image.stat and image.range values


window,1,/pixmap
wdelete,1
; Clean up window already open
if(XRegistered ('jwst_mql')) then begin
    widget_control,info.jwst_RawQuickLook,/destroy
endif

;info.jwst_image.plane_final = 0
;info.jwst_image.plane_int = 1

;_______________________________________________________________________
; widget window parameters
xwidget_size = 1200
ywidget_size = 1000
xsize_scroll = 1100
ysize_scroll = 950

;check the maximum size of the windows

if(info.jwst_image.uwindowsize eq 1) then begin ; user has set window size 
    xsize_scroll = info.jwst_image.xwindowsize
    ysize_scroll = info.jwst_image.ywindowsize
endif

if(info.jwst_control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.jwst_control.x_scroll_window
if(info.jwst_control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.jwst_control.y_scroll_window
if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10
;_______________________________________________________________________
RawQuickLook = widget_base(title="JWST MIRI Quick Look- Science Images" + info.jwst_version,$
                           col = 1,mbar = menuBar,group_leader = info.jwst_QuickLook,$
                           xsize = xwidget_size,$
                           ysize = ywidget_size,/scroll,$
                           x_scroll_size= xsize_scroll,$
                           y_scroll_size = ysize_scroll,/TLB_SIZE_EVENTS,/align_right)

info.jwst_RawQuickLook = RawQuickLook

;********
; build the menubar
;********
QuitMenu = widget_button(menuBar,value="Quit",font = info.font2)
quitbutton = widget_button(quitmenu,value="Quit",event_pro='jwst_mql_quit')

hMenu = widget_button(menuBar,value=" Header",font = info.font2)
hrMenu = widget_button(hmenu,value="Display Science Image Header",uvalue = 'rheader')
hsMenu = widget_button(hmenu,value="Display Rate Header",uvalue='sheader')
hcMenu = widget_button(hmenu,value="Display Calibrated Header",uvalue='cheader')

statMenu = widget_button(menuBar,value="Statistics",font = info.font2)
statbutton = widget_button(statmenu,value="Statistics on Images",uvalue = 'Stat')

CHMenu = widget_button(menuBar,value="Amplifier",font = info.font2)
CHbuttonD = widget_button(CHmenu,value = "Display Science Image by Amplifier",$
                             uvalue='DisplayAmp')
CHbuttonS = widget_button(CHmenu,value = "Display Reduced Image by Amplifier",$
                             uvalue='DisplayRAmp')
;CHbuttonT = widget_button(CHmenu,value = "Plot Amplifier values in readout order",$
;                             uvalue='DisplayTAmp')

cMenu   = widget_button(menuBar,value="Compare",font= info.font2)
cbutton = widget_button(cMenu,value = "Compare Science Frame to another Science Frame",uvalue = 'compare')

PMenu = widget_button(menuBar,value="Print",font = info.font2)
PbuttonR = widget_button(Pmenu,value = "Print Science Image",uvalue='print_R')
PbuttonZ = widget_button(Pmenu,value = "Print Zoom Image",uvalue='print_Z')
PbuttonS = widget_button(Pmenu,value = "Print Reduced Image",uvalue='print_S')
PbuttonP = widget_button(Pmenu,value = "Print Frame value for pixel",uvalue='print_P')

if(info.jwst_data.subarray ne 0) then begin
    SMenu = widget_button(menuBar,value = "Subarray",font = info.font2)
    SGbutton = widget_button(SMenu, value = "Subarray Geometry",uvalue = 'sgeometry')
endif
titlelabel = widget_label(info.jwst_RawQuickLook, $
                          value=info.jwst_control.filename_raw,/align_left, $
                          font=info.font3,/dynamic_resize)

jwst_clear_ql_info,info
;_______________________________________________________________________
; window size is based on 1032 X 1024 image
; The default scale is 4 so the window (on the analyze raw images
; window) is 258 X 256 (if subarray mode then 256 X 256) 

;find_image_binfactor, info
; determine the main window display based on scale and image size

xsize_image = fix(info.jwst_data.image_xsize/info.jwst_image.binfactor) 
ysize_image = fix(info.jwst_data.image_ysize/info.jwst_image.binfactor)

info.jwst_image.xplot_size = 258
info.jwst_image.yplot_size = 256
if(info.jwst_data.subarray ne 0) then info.jwst_image.xplot_size = 256

info.jwst_image.xplot_size = xsize_image
info.jwst_image.yplot_size  = ysize_image

widget_control,info.jwst_filetag[0] ,set_value = 'Science File name: ' + info.jwst_control.filename_raw 
widget_control,info.jwst_typetag, set_value ='Science Image ' 

si = strcompress(string(fix(info.jwst_data.nints)),/remove_all)
sr = strcompress(string(fix(info.jwst_data.ngroups)),/remove_all)
sx = strcompress(string(info.jwst_data.image_xsize),/remove_all)
sy = strcompress(string(info.jwst_data.image_ysize),/remove_all)

widget_control,info.jwst_line_tag[0],set_value = '# of Integrations: ' + si 
widget_control,info.jwst_line_tag[1],set_value = '# of Samples/Integrations: ' + sr
widget_control,info.jwst_line_tag[2],set_value = ' Image Size ' + sx + ' X ' + sy 

if(info.jwst_control.file_slope_exist eq 0) then $
widget_control,info.jwst_line_tag[4],set_value = ' No slope image exists' 

if(info.jwst_control.file_slope_exist eq 1) then $
widget_control,info.jwst_filetag[1] ,set_value = 'Slope File name: ' + info.jwst_control.filename_slope

if(info.jwst_data.subarray ne 0) then begin
    scol =  strcompress(string(info.jwst_data.colstart),/remove_all)
    srow =  strcompress(string(info.jwst_data.rowstart),/remove_all)
    widget_control,info.jwst_line_tag[5],set_value = ' This is Subarray data'  
    widget_control,info.jwst_line_tag[6],set_value = ' Column Start ' + scol
    widget_control,info.jwst_line_tag[7],set_value =' Row Start ' + srow  

endif
;_______________________________________________________________________
; defaults to start with 
info.jwst_image.default_scale_graph[*] = 1
info.jwst_image.default_scale_ramp[*] = 1

info.jwst_image.x_pos =(info.jwst_data.image_xsize/info.jwst_image.binfactor)/2.0
info.jwst_image.y_pos = (info.jwst_data.image_ysize/info.jwst_image.binfactor)/2.0

info.jwst_image.current_graph = 0
Widget_Control,info.jwst_QuickLook,Set_UValue=info

;*********
;Setup main panel
;*********
; setup the image windows
;*****
; set up for Raw image widget window

graphID_master1 = widget_base(info.jwst_RawQuickLook,row=1)
graphID_master2 = widget_base(info.jwst_RawQuickLook,row=1)

info.jwst_image.graphID11 = widget_base(graphID_master1,col=1)
info.jwst_image.graphID12 = widget_base(graphID_master1,col=1)

info.jwst_image.infoID00 = widget_base(graphID_master1,col=1)

info.jwst_image.graphID21 = widget_base(graphID_master2,col=1) 
info.jwst_image.graphID22 = widget_base(graphID_master2,col=1) 
info.jwst_image.infoID22 = widget_base(graphID_master2,col=1) 
;_______________________________________________________________________  
; set up the images to be displayed
; default to start with first integration and first ramp
; 
;_______________________________________________________________________  
zoomvalues = ['No Zoom', '2X', '4X', '8X', '16X', '32x']
if(info.jwst_data.subarray ne 0) then zoomvalues = ['No Zoom', '2X', '4X', '8X', '16X', '32X']

bimage = "Binned 4 X 4"
bup =strcompress(string(1/info.jwst_image.binfactor,format="(f5.1)"),/remove_all)
if(info.jwst_image.binfactor eq 1) then bimage = "No Binning"
if(info.jwst_image.binfactor eq 2) then bimage = "Binned 2 X 2"
if(info.jwst_image.binfactor lt 1.0) then bimage = "Blown up by " + bup

info.jwst_image.bindisplay=[bimage,"Scroll Full Image"] 

;_______________________________________________________________________
;*****
;graph 1,1
;*****
sraw = " Science Image [" + strtrim(string(info.jwst_data.image_xsize),2) + ' x ' +$
        strtrim(string(info.jwst_data.image_ysize),2) + ']' + " " + info.jwst_image.bindisplay[0]
info.jwst_image.graph_label[0] = widget_label(info.jwst_image.graphID11,$
                                         value=sraw,/align_right,$
                                        font=info.font5,/sunken_frame)
; statistical information
info.jwst_image.data_type[0] = 0 ; always uncal data
rawmean = info.jwst_image.stat[0]
rawmin = info.jwst_image.stat[1]
rawmax = info.jwst_image.stat[2]

rawmean =0.0
rawmin = 0.0
rawmax = 0.0

range_min = info.jwst_image.range[0]
range_max = info.jwst_image.range[1]
info.jwst_image.graph_range[0,0] = range_min
info.jwst_image.graph_range[0,1] = range_max

smean =  strcompress(string(rawmean),/remove_all)
smin = strcompress(string(rawmin),/remove_all) 
smax = strcompress(string(rawmax),/remove_all) 

stat_base1 = widget_base(info.jwst_image.graphID11,row=1)
stat_base2 = widget_base(info.jwst_image.graphID11,row=1)

histo = widget_button(stat_base1,value='Histogram',uvalue='histo_i',font=info.font4)
FullSize = widget_button(stat_base1,value='Inspect Image',uvalue='inspect_i',font=info.font4)

info.jwst_image.slabelID[0] = widget_label(stat_base2,value=(' Mean: ' + smean),$ 
                                          /align_left,font=info.font3)
info.jwst_image.mlabelID[0] = widget_label(stat_base2,$
                         value=(' Min: ' + smin + '   Max: ' + smax),$
                                      /align_left,font=info.font3)

; min and max scale of  image
info.jwst_image.srange_base[0] = widget_base(info.jwst_image.graphID11,row=1)

info.jwst_image.image_recomputeID[0] = widget_button(info.jwst_image.srange_base[0],value=' Image Scale ',$
                                                font=info.font4,$
                                                uvalue = 'scale1')

info.jwst_image.rlabelID[0,0] = cw_field(info.jwst_image.srange_base[0],title="min",font=info.font4,$
                                    uvalue="sr1_b",/float,/return_events,$
                                    xsize=info.xsize_label,value =range_min,$
                                    fieldfont = info.font4)

info.jwst_image.rlabelID[0,1] = cw_field(info.jwst_image.srange_base[0],title="max",font=info.font4,$
                                    uvalue="sr1_t",/float,/return_events,$
                                    xsize = info.xsize_label,value =range_max,$
                                   fieldfont=info.font4)


info.jwst_image.plot_base[0] = widget_base(info.jwst_image.graphID11)


info.jwst_image.graphID[0] = widget_draw(info.jwst_image.plot_base[0],$
                                        xsize =info.jwst_image.xplot_size,$ 
                                        ysize =info.jwst_image.yplot_size,$
                                        /Button_Events,$
                                        retain=info.retn,uvalue='mqlpixel1')

;*****
;graph 1,2; window 2 initally set to raw image zoom
;*****

 subt = "Zoom Centered on Raw image       "
info.jwst_image.graph_label[1] = widget_label(info.jwst_image.graphID12,$
                                         value=subt,/align_center,$
                                        font=info.font5,/sunken_frame)

info.jwst_image.data_type[1] = 0 ; start off as  uncal data
;info.jwst_image.slabelID[1] = widget_label(info.jwst_image.graphID12,value='    ' )
range_min = info.jwst_image.range[0]
range_max = info.jwst_image.range[1]
info.jwst_image.graph_range[1,0] = range_min
info.jwst_image.graph_range[1,1] = range_max

stat_base1 = widget_base(info.jwst_image.graphID12,row=1)
stat_base2 = widget_base(info.jwst_image.graphID12,row=1)

histo = widget_button(stat_base1,value='Histogram',uvalue='histo_z',font=info.font4)
info.jwst_image.slabelID[1] = widget_label(stat_base2,value=(' Mean: ' + smean),$ 
                                          /align_left,font=info.font3)
info.jwst_image.mlabelID[1] = widget_label(stat_base2,$
                         value=(' Min: ' + smin + '   Max: ' + smax),$
                                      /align_left,font=info.font3)


; min and max scale of  image
info.jwst_image.srange_base[1] = widget_base(info.jwst_image.graphID12,row=1)
info.jwst_image.image_recomputeID[1] = widget_button(info.jwst_image.srange_base[1],value=' Image Scale ',$
                                                font=info.font4,$
                                                uvalue = 'scale2')

info.jwst_image.rlabelID[1,0] = cw_field(info.jwst_image.srange_base[1],title="min",font=info.font4,$
                                    uvalue="sr2_b",/float,/return_events,$
                                    xsize=info.xsize_label,value =range_min,$
                                    fieldfont = info.font4)

info.jwst_image.rlabelID[1,1] = cw_field(info.jwst_image.srange_base[1],title="max",font=info.font4,$
                                    uvalue="sr2_t",/float,/return_events,$
                                    xsize = info.xsize_label,value =range_max,$
                                   fieldfont=info.font4)

info.jwst_image.plot_base[1] = widget_base(info.jwst_image.graphID12)
info.jwst_image.graphID[1] = widget_draw(info.jwst_image.plot_base[1],$
                                    xsize =info.jwst_plotsize1,$ ; 256 
                                    ysize =info.jwst_plotsize1,$ ; 256
                                    /Button_Events,$
                                    retain=info.retn,uvalue='mqlpixel2')

zoom_base = widget_base(info.jwst_image.graphID12,row=1)

info.jwst_image.zoom_label[0] = widget_button(zoom_base,value=zoomvalues[0],$
                                           uvalue='zsize1',$
                                           font=info.font4)

info.jwst_image.zoom_label[1] = widget_button(zoom_base,value=zoomvalues[1],$
                                           uvalue='zsize2',$
                                           font=info.font4)
info.jwst_image.zoom_label[2] = widget_button(zoom_base,value=zoomvalues[2],$
                                           uvalue='zsize3',$
                                           font=info.font4)
info.jwst_image.zoom_label[3] = widget_button(zoom_base,value=zoomvalues[3],$
                                           uvalue='zsize4',$
                                           font=info.font4)
info.jwst_image.zoom_label[4] = widget_button(zoom_base,value=zoomvalues[4],$
                                           uvalue='zsize5',$
                                           font=info.font4)

info.jwst_image.zoom_label[5] = widget_button(zoom_base,value=zoomvalues[5],$
                                           uvalue='zsize6',$
                                           font=info.font4)
;_______________________________________________________________________
; Information 

compare_label = cw_field(info.jwst_image.infoID00,title='Compare Science Frame to Frame #',$
                         font = info.font5,uvalue='fcompare',/integer,/return_events,$
                         value = 0, xsize=4,fieldfont = info.font3)

; button to change all the images- one for integration#  and 
;                                  one for frame #

iramp = info.jwst_image.frameNO
jintegration = info.jwst_image.IntegrationNO

moveframe_label = widget_label(info.jwst_image.infoID00,value='Change Image Displayed',$
                                font=info.font5,/sunken_frame,/align_left)
move_base1 = widget_base(info.jwst_image.infoID00,row=1,/align_left)
info.jwst_image.integration_label = cw_field(move_base1,$
                    title="Integration # ",font=info.font5, $
                    uvalue="integration",/integer,/return_events, $
                    value=jintegration+1,xsize=4,$
                    fieldfont=info.font3)

labelID = widget_button(move_base1,uvalue='integr_move_dn',value='<',font=info.font3)
labelID = widget_button(move_base1,uvalue='integr_move_up',value='>',font=info.font3)


tlabel = "Total # " + strcompress(string(info.jwst_data.nints),/remove_all)

total_ilabel = widget_label( move_base1,value = tlabel,/align_left)


move_base2 = widget_base(info.jwst_image.infoID00,row=1,/align_left)
info.jwst_image.frame_label = cw_field(move_base2,$
              title="Frame # ",font=info.font5, $
              uvalue="frame",/integer,/return_events, $
              value=iramp+1,xsize=4,fieldfont=info.font3)
labelID = widget_button(move_base2,uvalue='fram_move_dn',value='<',font=info.font3)
labelID = widget_button(move_base2,uvalue='fram_move_up',value='>',font=info.font3)


tlabel = "Frames/Int  " + strcompress(string(info.jwst_data.ngroups),/remove_all)

total_ilabel = widget_label( move_base2,value = tlabel,/align_left)
;-----------------------------------------------------------------------
; Pixel Information
general_label= widget_label(info.jwst_image.infoID00,$
                            value=" Pixel Information (Image: 1032 X 1024)",/align_left,$
                            font=info.font5,/sunken_frame)
; button to change 
pix_num_base = widget_base(info.jwst_image.infoID00,row=1,/align_left)
labelID = widget_button(pix_num_base,uvalue='pix_move_x1',value='<',font=info.font3)
labelID = widget_button(pix_num_base,uvalue='pix_move_x2',value='>',font=info.font3)

xvalue = info.jwst_image.x_pos*info.jwst_image.binfactor

yvalue = info.jwst_image.y_pos*info.jwst_image.binfactor

info.jwst_image.pix_label[0] = cw_field(pix_num_base,title="x",font=info.font4, $
                                   uvalue="pix_x_val",/integer,/return_events, $
                                   value=fix(xvalue+1),xsize=6,$  ; xvalue + 1 -4 (reference pixel)
                                   fieldfont=info.font3)

info.jwst_image.pix_label[1] = cw_field(pix_num_base,title="y",font=info.font4, $
                                   uvalue="pix_y_val",/integer,/return_events, $
                                   value=fix(yvalue+1),xsize=6,$
                                   fieldfont=info.font3)

labelID = widget_button(pix_num_base,uvalue='pix_move_y1',value='<',font=info.font3)
labelID = widget_button(pix_num_base,uvalue='pix_move_y2',value='>',font=info.font3)

flabel = widget_button(info.jwst_image.infoID00,value="Display a Table of  Frame Values",/align_left,$
                        uvalue = "getframe")
pix_num_base = widget_base(info.jwst_image.infoID00,col=2,/align_left)    

info.jwst_image.pix_statLabel = ["Frame Value"]
info.jwst_image.pix_statFormat =  ["F10.2"]

info.jwst_image.pix_statLabel1 = ["Rate (DN/s)", $
                                 "Error ",$
                                 "DQ Flag"]

info.jwst_image.pix_statFormat1 =  ["F12.5", "F12.5","I10"]

info.jwst_image.pix_statID[0] = widget_label(pix_num_base,value = info.jwst_image.pix_statLabel[0]+$
                                            ' =   ' ,/align_left,/dynamic_resize)
pix_num_base = widget_base(info.jwst_image.infoID00,row=1,/align_left)    
for i = 0,2 do begin  
    info.jwst_image.pix_statID1[i] = widget_label(pix_num_base,value = info.jwst_image.pix_statLabel1[i]+$
                                            ' =   ' ,/align_left,/dynamic_resize)
endfor

if(info.jwst_control.file_slope_int_exist eq 1) then begin 
   pix_num_base = widget_base(info.jwst_image.infoID00,row=1,/align_left)    

   info.jwst_image.pix_statLabel2 = ["Int Rate   (DN/s)", $
                                    "Error ",$
                                    "DQ Flag"]

   info.jwst_image.pix_statFormat2 =  ["F12.5", "F12.5","I10"]

   for i = 0,2 do begin  
      info.jwst_image.pix_statID2[i] = widget_label(pix_num_base,value = info.jwst_image.pix_statLabel2[i]+$
                                                   ' =   ' ,/align_left,/dynamic_resize)
   endfor
endif

if(info.jwst_control.file_cal_exist eq 1) then begin 
   pix_num_base = widget_base(info.jwst_image.infoID00,row=1,/align_left)    

   info.jwst_image.pix_statLabel3 = ["Cal      (MJy/sr)", $
                                    "Error ",$
                                    "DQ Flag"]

   info.jwst_image.pix_statFormat3 =  ["F12.5", "F12.5","I10"]

   for i = 0,2 do begin  
      info.jwst_image.pix_statID3[i] = widget_label(pix_num_base,value = info.jwst_image.pix_statLabel3[i]+$
                                                   ' =   ' ,/align_left,/dynamic_resize)
   endfor
endif

info_base = widget_base(info.jwst_image.infoID00,row=1,/align_left)
info_label = widget_button(info_base,value = 'DQ flag values',uvalue = 'datainfo')

;_______________________________________________________________________
;*****
;graph 2,1
;*****
rate_option = 'Rate Image'
rate_int_option = 'Integration Rate Image   '
cal_option = 'Calibrated Image     '


if(info.jwst_control.file_slope_exist eq 0) then  rate_option= " No Rate Image Exist" 
if(info.jwst_control.file_slope_int_exist eq 0) then rate_int_option= " No Rate Ints Image Exist" 
if(info.jwst_control.file_cal_exist eq 0) then cal_option= " No Calibrated Image Exist" 

voptions = [rate_option, rate_int_option, cal_option]

ss = " Rate Image  [" + strtrim(string(info.jwst_data.image_xsize),2) + ' x ' +$
        strtrim(string(info.jwst_data.image_ysize),2) + ']' + " " + info.jwst_image.bindisplay[0]


label21= widget_label(info.jwst_image.graphID21,value = ss,$
                                      /align_center,font=info.font5,/sunken_frame)
info.jwst_image.plane = 0       ; final rate image
info.jwst_image.data_type[2] = 1 ; start off as rate 
base1 = widget_base(info.jwst_image.graphID21,row=1)
info.jwst_image.graph_label[2] = widget_droplist(base1,value=voptions,$
                                            uvalue='voption',font=info.font5)

mean = 0 & min = 0 & max = 0 
range_min = 0 & range_max = 0

if(info.jwst_control.file_slope_exist eq 1) then begin 
    mean = info.jwst_data.reduced_stat[0,0]
    min = info.jwst_data.reduced_stat[3,0]
    max = info.jwst_data.reduced_stat[4,0]
    
    range_min = info.jwst_data.reduced_stat[5,0]
    range_max = info.jwst_data.reduced_stat[6,0]
endif
info.jwst_image.graph_range[2,0] = range_min
info.jwst_image.graph_range[2,1] = range_max

smean =  strcompress(string(mean),/remove_all)
smin = strcompress(string(min),/remove_all) 
smax = strcompress(string(max),/remove_all) 
    
ssmean = string('Mean ' + smean )    
sminmax = string(' Min: ' + smin + '    Max: ' + smax) 

if(info.jwst_control.file_slope_exist eq 0) then begin
   ssmean = '   Mean  NA        '
   sminmax = '   Min and Max  NA  '
endif

stat_base1 = widget_base(info.jwst_image.graphID21,row=1)
stat_base2 = widget_base(info.jwst_image.graphID21,row=1)

histo = widget_button(stat_base1,value='Histogram',uvalue='histo_s',font=info.font4)
FullSize = widget_button(stat_base1,value='Inspect Image',uvalue='inspect_s',font=info.font4)
info.jwst_image.slabelID[2] = widget_label(stat_base2,$
                                      value=ssmean,font=info.font3,/align_left)
info.jwst_image.mlabelID[2] = widget_label(stat_base2,$
                                      value= sminmax,/align_left,font=info.font3)
info.jwst_image.srange_base[2] = widget_base(info.jwst_image.graphID21,row=1)
info.jwst_image.image_recomputeID[2] = widget_button(info.jwst_image.srange_base[2],value=' Image Scale ',$
                                                font=info.font4,$
                                                uvalue = 'scale3')
info.jwst_image.rlabelID[2,0] = cw_field(info.jwst_image.srange_base[2],$
                                    title="min",font=info.font4,uvalue='sr3_b',$
                                    /float,/return_events,xsize=info.xsize_label,value =range_min)

info.jwst_image.rlabelID[2,1] = cw_field(info.jwst_image.srange_base[2],$
                                    title="max",font=info.font4,uvalue='sr3_t',$
                                    /float,/return_events,xsize = info.xsize_label,value =range_max)
    

info.jwst_image.plot_base[2] = widget_base(info.jwst_image.graphID21)
info.jwst_image.graphID[2] = widget_draw(info.jwst_image.plot_base[2],$
                                        xsize =info.jwst_image.xplot_size,$ 
                                        ysize =info.jwst_image.yplot_size,$
                                        /Button_Events,$
                                        retain=info.retn,uvalue='mqlpixel3')
;*****
;graph 2,2
;*****
ramp_range = fltarr(2,2)        ; plot range for the ramp plot, 

tlabelID = widget_label(info.jwst_image.graphID22,$
                        value = " Frame Values in Selected Pixel for Given " $
                        + "Integration Range",$
                        /align_center,$
                        font=info.font5,/sunken_frame)

; button to change selected pixel
pix_num_base = widget_base(info.jwst_image.graphID22,row=1,/align_center)

xs = ' x: '+ strcompress(string(fix(info.jwst_image.x_pos*info.jwst_image.binfactor) +1),/remove_all)
ys = ' y: '+ strcompress(string(fix(info.jwst_image.y_pos*info.jwst_image.binfactor)+ 1),/remove_all)

if(info.jwst_data.ngroups gt 200) then begin
    xs = 'Click on pixel to plot ramp'
    ys = ' '
endif
info.jwst_image.ramp_x_label = widget_label (pix_num_base,value=xs,/dynamic_resize)
info.jwst_image.ramp_y_label = widget_label (pix_num_base,value=ys,/dynamic_resize)
int_range = intarr(2) 
int_range[0] = 1  ; initialize to look at first integration
int_range[1] = 1
info.jwst_image.int_range[*] = int_range[*]

move_base = widget_base(info.jwst_image.graphID22,/row,/align_left)

IrangeID = lonarr(2)
info.jwst_image.IrangeID[0] = cw_field(move_base,$
                  title="Integration range: Start", $
                  uvalue="int_chng_1",/integer,/return_events, $
                  value=info.jwst_image.int_range[0],xsize=4,$
                  fieldfont=info.font3)
info.jwst_image.IrangeID[1] = cw_field(move_base,$
                  title="End", $
                  uvalue="int_chng_2",/integer,/return_events, $
                  value=info.jwst_image.int_range[1],xsize=4,$
                  fieldfont=info.font3)

labelID = widget_button(move_base,uvalue='int_move_d',value='<',font=info.font3)
labelID = widget_button(move_base,uvalue='int_move_u',value='>',font=info.font3)

info.jwst_image.graphID[3] = widget_draw(info.jwst_image.graphID22,$
                                    xsize = info.jwst_plotsize3,$
                                    ysize = info.jwst_plotsize1,$
                                    retain=info.retn)

;buttons to  change the x and y ranges
pix_num_base2 = widget_base(info.jwst_image.graphID22,row=1)
labelID = widget_label(pix_num_base2,value="X->",font=info.font4)
info.jwst_image.ramp_mmlabel[0,0] = cw_field(pix_num_base2,title="min:",font=info.font4, $
                                        uvalue="ramp_mmx1",/integer,/return_events, $
                                        value=fix(ramp_range[0,0]), $
                                        xsize=info.xsize_label,fieldfont=info.font4)

info.jwst_image.ramp_mmlabel[0,1] = cw_field(pix_num_base2,title="max:",font=info.font4, $
                                        uvalue="ramp_mmx2",/integer,/return_events, $
                                        value=fix(ramp_range[0,1]),xsize=info.xsize_label,$
                                        fieldfont=info.font4)

info.jwst_image.ramp_recomputeID[0] = widget_button(pix_num_base2,value='  Plot Range  ',$
                                               font=info.font4,$
                                               uvalue = 'r1')

pix_num_base3 = widget_base(info.jwst_image.graphID22,row=1)

labelID = widget_label(pix_num_base3,value="Y->",font=info.font4)
info.jwst_image.ramp_mmlabel[1,0] = cw_field(pix_num_base3,title="min:",font=info.font4, $
                                        uvalue="ramp_mmy1",/float,/return_events, $
                                        value=ramp_range[1,0],xsize=info.xsize_label,$
                                        fieldfont=info.font4)

info.jwst_image.ramp_mmlabel[1,1] = cw_field(pix_num_base3,title="max:",font=info.font4, $
                                        uvalue="ramp_mmy2",/float,/return_events, $
                                        value=ramp_range[1,1],xsize=info.xsize_label,$
                                        fieldfont=info.font4)

info.jwst_image.ramp_recomputeID[1] = widget_button(pix_num_base3,value='  Plot Range  ',$
                                               font=info.font4,$
                                               uvalue = 'r2')

info.jwst_image.ramp_range = ramp_range


info.jwst_image.pixeldisplay=["Automatically Read/Plot Pixel Values",$
                         "Do not Read/Update Plot with new pixels values"] 
updatepixel = widget_droplist(info.jwst_image.graphID22,value=info.jwst_image.pixeldisplay,$
                                       uvalue='auto',/align_left)
info.jwst_image.autopixelupdate = 1

;_______________________________________________________________________

IAllButton = Widget_button(info.jwst_image.infoID22, Value = 'Plot All Integrations',$
                           uvalue = 'int_grab_all',/align_left)
widget_control,IAllButton,Set_Button = 0

IAllButton = Widget_button(info.jwst_image.infoID22, Value = 'Over plot Integrations',$
                           uvalue = 'int_overplot',/align_left)
widget_control,IAllButton,Set_Button = 0
bk = widget_label(info.jwst_image.infoID22,value = ' ' ) 
overplotFitID = lonarr(2)
if(info.jwst_control.file_fitopt_exist)then begin 

    overplot = widget_label(info.jwst_image.infoID22,value = 'Over-plot Values from Fit (red)',/sunken_frame,$
                            font = info.font5,/align_left)

    oBase = Widget_base(info.jwst_image.infoID22,/row,/nonexclusive)

    OverplotFitID[0] = Widget_button(oBase, Value = ' Yes ',uvalue = 'overslope1')
    widget_control,OverplotFitID[0],Set_Button = 0

    OverplotFitID[1] = Widget_Button(oBase, Value = ' No ',uvalue = 'overslope2')
    widget_control,OverplotFitID[1],Set_Button = 1

endif

info.jwst_image.overplotFitID = overplotFitID

overplotRefpixID = lonarr(2)

if(info.jwst_control.file_refpix_exist eq 1)then begin 
    overplot = widget_label(info.jwst_image.infoID22,value = 'Over-plot Reference Corrected Data (blue box)',/sunken_frame,$
                            font = info.font5,/align_left)

    oBase = Widget_base(info.jwst_image.infoID22,/row,/nonexclusive)

    OverplotRefpixID[0] = Widget_button(oBase, Value = ' Yes ',uvalue = 'overref1')
    widget_control,OverplotRefpixID[0],Set_Button = 1

    OverplotRefpixID[1] = Widget_Button(oBase, Value = ' No ',uvalue = 'overref2')
    widget_control,OverplotRefpixID[1],Set_Button = 0
endif

info.jwst_image.overplotRefpixID = overplotRefpixID
;_______________________________________________________________________
overplotresetID = lonarr(2)
if(info.jwst_control.file_reset_exist eq 1)then begin 
    mark = widget_label(info.jwst_image.infoID22,value = 'Over Plot Reset Corrected Data  (green +)',/sunken_frame,$
                            font = info.font5,/align_left)

    oBase = Widget_base(info.jwst_image.infoID22,/row,/nonexclusive)

    OverplotresetID[0] = Widget_button(oBase, Value = ' Yes ',uvalue = 'overreset1')
    widget_control,OverplotresetID[0],Set_Button = 1

    OverplotresetID[1] = Widget_Button(oBase, Value = ' No ',uvalue = 'overreset2')
    widget_control,OverplotresetID[1],Set_Button = 0
endif

info.jwst_image.overplotresetID = overplotresetID
;_______________________________________________________________________
overplotrscdID = lonarr(2)
if(info.jwst_control.file_rscd_exist eq 1)then begin 
    mark = widget_label(info.jwst_image.infoID22,value = 'Over Plot RSCD Corrected Data  (green +)',/sunken_frame,$
                            font = info.font5,/align_left)

    oBase = Widget_base(info.jwst_image.infoID22,/row,/nonexclusive)

    OverplotrscdID[0] = Widget_button(oBase, Value = ' Yes ',uvalue = 'overrscd1')
    widget_control,OverplotrscdID[0],Set_Button = 1

    OverplotrscdID[1] = Widget_Button(oBase, Value = ' No ',uvalue = 'overrscd2')
    widget_control,OverplotrscdID[1],Set_Button = 0
endif

info.jwst_image.overplotrscdID = overplotrscdID

;_______________________________________________________________________
overplotlastframeID = lonarr(2)
if(info.jwst_control.file_lastframe_exist eq 1)then begin 
    mark = widget_label(info.jwst_image.infoID22,value = 'Over Plot Lastframe Corrected Data  (blue Diamond)',/sunken_frame,$
                            font = info.font5,/align_left)

    oBase = Widget_base(info.jwst_image.infoID22,/row,/nonexclusive)

    OverplotlastframeID[0] = Widget_button(oBase, Value = ' Yes ',uvalue = 'overlastframe1')
    widget_control,OverplotlastframeID[0],Set_Button = 1

    OverplotlastframeID[1] = Widget_Button(oBase, Value = ' No ',uvalue = 'overlastframe2')
    widget_control,OverplotlastframeID[1],Set_Button = 0
endif

info.jwst_image.overplotlastframeID = overplotlastframeID


;_______________________________________________________________________
overplotdarkID = lonarr(2)
if(info.jwst_control.file_dark_exist eq 1)then begin 
    mark = widget_label(info.jwst_image.infoID22,value = 'Over Plot Dark Corrected Data  (green boxes)',/sunken_frame,$
                            font = info.font5,/align_left)

    oBase = Widget_base(info.jwst_image.infoID22,/row,/nonexclusive)

    OverplotdarkID[0] = Widget_button(oBase, Value = ' Yes ',uvalue = 'overmd1')
    widget_control,OverplotdarkID[0],Set_Button = 1

    OverplotdarkID[1] = Widget_Button(oBase, Value = ' No ',uvalue = 'overmd2')
    widget_control,OverplotdarkID[1],Set_Button = 0
endif

info.jwst_image.overplotdarkID = overplotdarkID
;_______________________________________________________________________
overplotlinID = lonarr(2)
if(info.jwst_control.file_linearity_exist eq 1)then begin 
    mark = widget_label(info.jwst_image.infoID22,value = 'Overplot Linearity Corrected Data (blue *)',/sunken_frame,$
                            font = info.font5,/align_left)

    oBase = Widget_base(info.jwst_image.infoID22,/row,/nonexclusive)

    OverplotlinID[0] = Widget_button(oBase, Value = ' Yes ',uvalue = 'overlc1')
    widget_control,OverplotlinID[0],Set_Button = 1

    OverplotlinID[1] = Widget_Button(oBase, Value = ' No ',uvalue = 'overlc2')
    widget_control,OverplotLinID[1],Set_Button = 0
endif
info.jwst_image.overplotlinID = overplotlinID

;*****
blank = "                                                                                                                                                       "
blank_label= widget_label(info.jwst_image.infoID00,value = blank)
;_______________________________________________________________________
; realize main panel
longline = '                                                                                                                        '
longtag = widget_label(RawQuicklook,value = longline)
;Set up the GUI
Widget_control,info.jwst_RawQuickLook,/Realize
XManager,'jwst_mql',info.jwst_RawQuickLook,/No_Block,event_handler='jwst_mql_event'

; get the window ids of the draw windows

n_draw = n_elements(info.jwst_image.graphID)
for i = 0,(n_draw-1) do begin
    widget_control,info.jwst_image.graphID[i],get_value=tdraw_id
    info.jwst_image.draw_window_id[i] = tdraw_id
    if(i eq 0 or i eq 2 ) then begin
        window,/pixmap,xsize=info.jwst_image.xplot_size,ysize=info.jwst_image.yplot_size,/free
        info.jwst_image.pixmapID[i] = !D.WINDOW
    endif

    if(i eq 1 ) then begin
        window,/pixmap,xsize=info.jwst_plotsize1,ysize=info.jwst_plotsize1,/free
        info.jwst_image.pixmapID[i] = !D.WINDOW
    endif
endfor

; load the first image into the graph windows
loadct,info.col_table,/silent
jwst_mql_update_images,info

info.jwst_image.graph_mpixel = 1
info.jwst_image.zoom_window = 1
info.jwst_image.x_zoom = info.jwst_image.x_pos* info.jwst_image.binfactor
info.jwst_image.y_zoom = info.jwst_image.y_pos* info.jwst_image.binfactor
info.jwst_image.zoom_window = 1

jwst_mql_update_zoom_image,info
jwst_mql_update_slope,info
; load individual ramp graph - based on x_pos, y_pos
if(info.jwst_data.ngroups lt 200) then  jwst_mql_update_rampread,info
jwst_mql_update_pixel_stat,info

Widget_Control,info.jwst_QuickLook,Set_UValue=info
sinfo = {info        : info}

Widget_Control,info.jwst_RawQuickLook,Set_UValue=sinfo
Widget_Control,info.jwst_QuickLook,Set_UValue=info

end
