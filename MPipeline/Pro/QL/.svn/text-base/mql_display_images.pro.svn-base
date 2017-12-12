; This program is used to display and analyze the science frames,
 ; slope image if it exists. This is the main display for the QL tool.
; From this window the user can query pixel values, zoom the images,
; get statstics on the data
;***********************************************************************
; _______________________________________________________________________
pro mql_quit,event
; _______________________________________________________________________

widget_control,event.top, Get_UValue = tinfo
widget_control,tinfo.info.QuickLook,Get_UValue=info

if( XRegistered ('mql')) then begin ; channel image display
    widget_control,info.RawQuickLook,/destroy
endif

end

;***********************************************************************
; _______________________________________________________________________
pro mql_update_pixel_location,info
; Update the pixel location is the user selected a different pixel
; _______________________________________________________________________
ij = info.image.current_graph
wset,info.image.draw_window_id[ij]
; set up the pixel box window - this will initialize the
;                               mql_update_rampread.pro x and y positions.

xsize_image = fix(info.data.image_xsize/info.image.binfactor) 
ysize_image = fix(info.data.image_ysize/info.image.binfactor)
device,copy=[0,0,xsize_image,ysize_image, 0,0,info.image.pixmapID[ij]]

xvalue = info.image.x_pos 
yvalue = info.image.y_pos

xcenter = xvalue + 0.5
ycenter = yvalue + 0.5

box_coords1 = [xcenter,(xcenter+1), $
               ycenter,(ycenter+1)]


plots,box_coords1[[0,0,1,1,0]],box_coords1[[2,3,3,2,2]],psym=0,/device

end

;***********************************************************************
; _______________________________________________________________________
pro mql_update_pixel_stat,info
; _______________________________________________________________________

i = info.image.integrationNO
ii = info.image.integrationNO
j = info.image.rampNO
x = info.image.x_pos*info.image.binfactor
y = info.image.y_pos*info.image.binfactor


slope_exist = info.data.slope_exist

if(info.data.read_all eq 0) then begin
    i = 0
    if(info.data.num_frames ne info.data.nramps) then begin 
        j = info.image.rampNO- info.control.frame_start
    endif
endif


pixelvalue = (*info.data.pimagedata)[i,j,x,y]
sp =   strtrim(string(pixelvalue,format="("+info.image.pix_statFormat[1]+")"),2)

dead_pix = 0
dead_pix = (*info.badpixel.pmask)[x,y]

dead_str = 'No'
if(dead_pix and 1) then dead_str ='Yes'
if(info.image.apply_bad eq 0) then dead_str = 'NA' 


sdead = strtrim(string(dead_str,format="("+info.image.pix_statFormat[0]+")"),2)

ss = 'NA'
su = 'NA'
sd = 'NA'
sg = 'NA'
sr = 'NA'
sy = 'NA'
sseg = 'NA'
smax = 'NA'
srms = 'NA'
simax = 'NA'
sdmax = 'NA'
ssmax = 'NA'



if(slope_exist) then begin

    signal = (*info.data.preduced)[x,y,0]
    ss =   strtrim(string(signal,format="("+info.image.pix_statFormat[2]+")"),2)
    dq = (*info.data.preduced)[x,y,2]
    sd =   strtrim(string(dq,format="("+info.image.pix_statFormat[4]+")"),2)
    if(info.data.slope_zsize eq 2) then begin
        yi = (*info.data.preduced)[x,y,1]
        sy =   strtrim(string(yi,format="("+info.image.pix_statFormat[5]+")"),2)

    endif 

    if(info.data.slope_zsize eq 3) then begin
        yi = (*info.data.preduced)[x,y,1]
        sy =   strtrim(string(yi,format="("+info.image.pix_statFormat[5]+")"),2)

        rms = (*info.data.preduced)[x,y,2]
        srms =   strtrim(string(rms,format="("+info.image.pix_statFormat[6]+")"),2)
    endif 
    
    if (info.data.slope_zsize ge 6) then begin 
        unc = (*info.data.preduced)[x,y,1]
        yi = (*info.data.preduced)[x,y,3]
        ng = (*info.data.preduced)[x,y,4]
        rs = (*info.data.preduced)[x,y,5]

        su=    strtrim(string(unc,format="("+info.image.pix_statFormat[3]+")"),2)
        sy =   strtrim(string(yi,format="("+info.image.pix_statFormat[5]+")"),2)
        sg =   strtrim(string(ng,format="("+info.image.pix_statFormat[9]+")"),2)
        sr =   strtrim(string(rs,format="("+info.image.pix_statFormat[7]+")"),2)
    endif

    if(info.data.slope_zsize ge 7) then begin 
        gseg = (*info.data.preduced)[x,y,6]
        sseg =   strtrim(string(gseg,format="("+info.image.pix_statFormat[8]+")"),2)
    endif

    if(info.data.slope_zsize ge 8) then begin 

        rms = (*info.data.preduced)[x,y,7]
        srms =   strtrim(string(rms,format="("+info.image.pix_statFormat[6]+")"),2)
    endif
    if(info.data.slope_zsize gt 8 )then begin 

        max2pt = (*info.data.preduced)[x,y,8]
        imax2pt = (*info.data.preduced)[x,y,9]
        stdev2pt = (*info.data.preduced)[x,y,10]
        slope2pt = (*info.data.preduced)[x,y,11]

        smax =   strtrim(string(max2pt,format="("+info.image.pix_statFormat2[1]+")"),2)
        simax =   strtrim(string(float(imax2pt),format="("+info.image.pix_statFormat2[1]+")"),2)
        ssmax =   strtrim(string(slope2pt,format="("+info.image.pix_statFormat2[3]+")"),2)
        sdmax =   strtrim(string(stdev2pt,format="("+info.image.pix_statFormat2[3]+")"),2)
    endif
endif

if(dead_pix and 1 and info.image.apply_bad eq 1) then begin 
    ss = 'NA'
    su = 'NA'
;    sd = 'NA'
    sg = 'NA'
    sr = 'NA'
    sy = 'NA'
    sseg = 'NA'
    smax = 'NA'
    srms = 'NA'
    simax = 'NA'
    sdmax = 'NA'
    ssmax = 'NA'
     sp = 'NA'
endif

if(info.data.coadd) then sy = 'NA'

widget_control,info.image.pix_statID[0],set_value=info.image.pix_statLabel[0]+' = ' +sdead
widget_control,info.image.pix_statID[1],set_value=info.image.pix_statLabel[1]+' = ' +sp
widget_control,info.image.pix_statID[2],set_value= info.image.pix_statLabel[2] +' = '+ ss
widget_control,info.image.pix_statID[3],set_value= info.image.pix_statLabel[3] +' = '+su 
widget_control,info.image.pix_statID[4],set_value= info.image.pix_statLabel[4] +' = ' +sd
widget_control,info.image.pix_statID[5],set_value= info.image.pix_statLabel[5] +' = ' +sy
widget_control,info.image.pix_statID[6],set_value= info.image.pix_statLabel[6] +' = ' +srms
widget_control,info.image.pix_statID[7],set_value= info.image.pix_statLabel[7] +' = ' +sr
widget_control,info.image.pix_statID[8],set_value= info.image.pix_statLabel[8] +' = ' +sseg
widget_control,info.image.pix_statID[9],set_value= info.image.pix_statLabel[9] +' = ' +sg


if(info.data.slope_zsize ge 9)then begin 

    widget_control,info.image.pix_statID2[0],set_value= info.image.pix_statLabel2[0] +' = ' +smax
    widget_control,info.image.pix_statID2[1],set_value= info.image.pix_statLabel2[1] +' = ' +simax
    widget_control,info.image.pix_statID2[2],set_value= info.image.pix_statLabel2[2] +' = ' +ssmax
    widget_control,info.image.pix_statID2[3],set_value= info.image.pix_statLabel2[3] +' = ' +sdmax

endif
end



;***********************************************************************
; _______________________________________________________________________
pro mql_display_images,info
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

get_this_frame_stat,info  ; set up the image.stat and image.range values


window,1,/pixmap
wdelete,1
if(XRegistered ('mql')) then begin
    widget_control,info.RawQuickLook,/destroy
endif

;_______________________________________________________________________
; widget window parameters
xwidget_size = 1200
ywidget_size = 1000
xsize_scroll = 960
ysize_scroll = 980

;check the maximum size of the windows

if(info.image.uwindowsize eq 1) then begin ; user has set window size 
    xsize_scroll = info.image.xwindowsize
    ysize_scroll = info.image.ywindowsize
endif

if(info.control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.control.x_scroll_window
if(info.control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.control.y_scroll_window
if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10

;_______________________________________________________________________


RawQuickLook = widget_base(title="MIRI Quick Look- Science Images" + info.version,$
                           col = 1,mbar = menuBar,group_leader = info.QuickLook,$
                           xsize = xwidget_size,$
                           ysize = ywidget_size,/scroll,$
                           x_scroll_size= xsize_scroll,$
                           y_scroll_size = ysize_scroll,/TLB_SIZE_EVENTS,/align_right)

info.RawQuickLook = RawQuickLook

;********
; build the menubar
;********
QuitMenu = widget_button(menuBar,value="Quit",font = info.font2)
quitbutton = widget_button(quitmenu,value="Quit",event_pro='mql_quit')

hMenu = widget_button(menuBar,value=" Header",font = info.font2)
hrMenu = widget_button(hmenu,value="Display Science Image Header",uvalue = 'rheader')
hsMenu = widget_button(hmenu,value="Display Reduced Header",uvalue='sheader')
hcMenu = widget_button(hmenu,value="Display Calibrated Header",uvalue='cheader')

statMenu = widget_button(menuBar,value="Statistics",font = info.font2)
statbutton = widget_button(statmenu,value="Statistics on Images",uvalue = 'Stat')
rbutton = widget_button(statmenu,value = "Create Test Report", uvalue = 'treport')


CHMenu = widget_button(menuBar,value="Channel",font = info.font2)

CHbuttonD = widget_button(CHmenu,value = "Display Science Image by Channel",$
                             uvalue='DisplayCHR')
CHbuttonS = widget_button(CHmenu,value = "Display Reduced Image by Channel",$
                             uvalue='DisplayCHS')
CHbuttonT = widget_button(CHmenu,value = "Plot Channel Data values in readout order",$
                             uvalue='ChannelT')


slopeMenu = widget_button(menuBar,value="Reduced Data",font = info.font2)
slopebutton = widget_button(slopemenu,value="Display Reduced Data",uvalue = 'LoadS')

refMenu = widget_button(menuBar,value="Reference Data",font = info.font2)
refbutton = widget_button(refmenu,value="Display Reference Output Image",uvalue = 'LoadR')
refpbutton = widget_button(refmenu,value="Display Reference Pixel Data",uvalue = 'LoadP')



plMenu = widget_button(menuBar,value="Pixel Look",font = info.font2)
plbutton = widget_button(plmenu,value="Pixel Look",uvalue = 'PLook')


cMenu   = widget_button(menuBar,value="Compare",font= info.font2)
cbutton = widget_button(cMenu,value = "Compare Science Frame to another Science Frame",uvalue = 'compare')



PMenu = widget_button(menuBar,value="Print",font = info.font2)
PbuttonR = widget_button(Pmenu,value = "Print Science Image",uvalue='print_R')
PbuttonZ = widget_button(Pmenu,value = "Print Zoom Image",uvalue='print_Z')
PbuttonS = widget_button(Pmenu,value = "Print Reduced Image",uvalue='print_S')
PbuttonP = widget_button(Pmenu,value = "Print Frame value for pixel",uvalue='print_P')

RMenu = widget_button(menuBar,value="Pipeline",font = info.font2)
;rbutton1 = widget_button(RMenu,$
;                         value="Quick Slope processing",$
;                         uvalue='CalQSlope',font=info.font2)

rbutton2 = widget_button(RMenu,$
                         value=" Default Slope processing",$
                         uvalue='CalDSlope',font=info.font2)

rbutton3 = widget_button(RMenu,$
                         value=" User selected options for slope processing",$
                         uvalue='CalSlope',font=info.font2)


if(info.data.subarray ne 0) then begin
    SMenu = widget_button(menuBar,value = "Subarray",font = info.font2)
    SGbutton = widget_button(SMenu, value = "Subarray Geometry",uvalue = 'sgeometry')
endif
titlelabel = widget_label(info.RawQuickLook, $
                          value=info.control.filename_raw,/align_left, $
                          font=info.font3,/dynamic_resize)

clear_ql_info,info
;_______________________________________________________________________
; window size is based on 1032 X 1024 image
; The default scale is 4 so the window (on the analyze raw images
; window) is 258 X 256 (if subarray mode then 256 X 256) 

;find_image_binfactor, info
; determine the main window display based on scale and image size

xsize_image = fix(info.data.image_xsize/info.image.binfactor) 
ysize_image = fix(info.data.image_ysize/info.image.binfactor)

info.image.xplot_size = 258

;;info.image.xplot_size = 256
info.image.yplot_size = 256
if(info.data.subarray ne 0) then info.image.xplot_size = 256

info.image.xplot_size = xsize_image
info.image.yplot_size  = ysize_image


widget_control,info.filetag[0] ,set_value = 'Science File name: ' + info.control.filename_raw 
widget_control,info.typetag, set_value ='Science Image ' 

si = strcompress(string(fix(info.data.nints)),/remove_all)
sr = strcompress(string(fix(info.data.nramps)),/remove_all)
sx = strcompress(string(info.data.image_xsize),/remove_all)
sy = strcompress(string(info.data.image_ysize),/remove_all)

widget_control,info.line_tag[0],set_value = '# of Integrations: ' + si 
widget_control,info.line_tag[1],set_value = '# of Samples/Integrations: ' + sr
widget_control,info.line_tag[2],set_value = ' Image Size ' + sx + ' X ' + sy 

if(info.data.slope_exist eq 0) then $
widget_control,info.line_tag[4],set_value = ' No slope image exists' 

if(info.data.slope_exist eq 1) then $
widget_control,info.filetag[1] ,set_value = 'Slope File name: ' + info.control.filename_slope

if(info.data.subarray ne 0) then begin
    scol =  strcompress(string(info.data.colstart),/remove_all)
    srow =  strcompress(string(info.data.rowstart),/remove_all)
    widget_control,info.line_tag[5],set_value = ' This is Subarray data'  
    widget_control,info.line_tag[6],set_value = ' Column Start ' + scol
    widget_control,info.line_tag[7],set_value =' Row Start ' + srow  

endif
;_______________________________________________________________________

;_______________________________________________________________________
; defaults to start with 


info.image.default_scale_graph[*] = 1
info.image.default_scale_ramp[*] = 1


info.image.x_pos =(info.data.image_xsize/info.image.binfactor)/2.0
info.image.y_pos = (info.data.image_ysize/info.image.binfactor)/2.0


info.image.current_graph = 0

Widget_Control,info.QuickLook,Set_UValue=info

;*********
;Setup main panel
;*********
; setup the image windows
;*****
; set up for Raw image widget window



graphID_master1 = widget_base(info.RawQuickLook,row=1)
graphID_master2 = widget_base(info.RawQuickLook,row=1)

info.image.graphID11 = widget_base(graphID_master1,col=1)
info.image.graphID12 = widget_base(graphID_master1,col=1)

info.image.infoID00 = widget_base(graphID_master1,col=1)

info.image.graphID21 = widget_base(graphID_master2,col=1) 
info.image.graphID22 = widget_base(graphID_master2,col=1) 
info.image.infoID22 = widget_base(graphID_master2,col=1) 
;_______________________________________________________________________  
; set up the images to be displayed
; default to start with first integration and first ramp
; 
;_______________________________________________________________________  
zoomvalues = ['No Zoom', '2X', '4X', '8X', '16X', '32x']
if(info.data.subarray ne 0) then zoomvalues = ['No Zoom', '2X', '4X', '8X', '16X', '32X']
options = ['Plot Options: ', 'Histogram', 'Column Slice',$
           'Row Slice ' ]


bimage = "Binned 4 X 4"
bup =strcompress(string(1/info.image.binfactor,format="(f5.1)"),/remove_all)
if(info.image.binfactor eq 1) then bimage = "No Binning"
if(info.image.binfactor eq 2) then bimage = "Binned 2 X 2"
if(info.image.binfactor lt 1.0) then bimage = "Blown up by " + bup


info.image.bindisplay=[bimage,"Scroll Full Image"] 

;_______________________________________________________________________
;*****
;graph 1,1
;*****
sraw = " Science Image [" + strtrim(string(info.data.image_xsize),2) + ' x ' +$
        strtrim(string(info.data.image_ysize),2) + ']' + " " + info.image.bindisplay[0]
info.image.graph_label[0] = widget_label(info.image.graphID11,$
                                         value=sraw,/align_right,$
                                        font=info.font5,/sunken_frame)
; statistical information

rawmean = info.image.stat[0]
rawmin = info.image.stat[1]
rawmax = info.image.stat[2]

rawmean =0.0
rawmin = 0.0
rawmax = 0.0

range_min = info.image.range[0]
range_max = info.image.range[1]
info.image.graph_range[0,0] = range_min
info.image.graph_range[0,1] = range_max

smean =  strcompress(string(rawmean),/remove_all)
smin = strcompress(string(rawmin),/remove_all) 
smax = strcompress(string(rawmax),/remove_all) 

stat_base1 = widget_base(info.image.graphID11,row=1)
stat_base2 = widget_base(info.image.graphID11,row=1)


info.image.optionMenu[0] = widget_droplist(stat_base1,value=options,uvalue='option1',font=info.font4)
FullSize = widget_button(stat_base1,value='Inspect Image',uvalue='inspect_i',font=info.font4)

info.image.slabelID[0] = widget_label(stat_base2,value=(' Mean: ' + smean),$ 
                                          /align_left,font=info.font3)
info.image.mlabelID[0] = widget_label(stat_base2,$
                         value=(' Min: ' + smin + '   Max: ' + smax),$
                                      /align_left,font=info.font3)

; min and max scale of  image
info.image.srange_base[0] = widget_base(info.image.graphID11,row=1)

info.image.image_recomputeID[0] = widget_button(info.image.srange_base[0],value=' Image Scale ',$
                                                font=info.font4,$
                                                uvalue = 'scale1')

info.image.rlabelID[0,0] = cw_field(info.image.srange_base[0],title="min",font=info.font4,$
                                    uvalue="sr1_b",/float,/return_events,$
                                    xsize=info.xsize_label,value =range_min,$
                                    fieldfont = info.font4)

info.image.rlabelID[0,1] = cw_field(info.image.srange_base[0],title="max",font=info.font4,$
                                    uvalue="sr1_t",/float,/return_events,$
                                    xsize = info.xsize_label,value =range_max,$
                                   fieldfont=info.font4)


info.image.plot_base[0] = widget_base(info.image.graphID11)


info.image.graphID[0] = widget_draw(info.image.plot_base[0],$
                                        xsize =info.image.xplot_size,$ 
                                        ysize =info.image.yplot_size,$
                                        /Button_Events,$
                                        retain=info.retn,uvalue='mqlpixel1')


;*****
;graph 1,2; window 2 initally set to raw image zoom
;*****

 subt = "Zoom Centered on Raw image       "
info.image.graph_label[1] = widget_label(info.image.graphID12,$
                                         value=subt,/align_center,$
                                        font=info.font5,/sunken_frame)

;info.image.slabelID[1] = widget_label(info.image.graphID12,value='    ' )
range_min = info.image.range[0]
range_max = info.image.range[1]
info.image.graph_range[1,0] = range_min
info.image.graph_range[1,1] = range_max

stat_base1 = widget_base(info.image.graphID12,row=1)
stat_base2 = widget_base(info.image.graphID12,row=1)

info.image.optionMenu[1] = widget_droplist(stat_base1,value=options,uvalue='option2',font=info.font4)

info.image.slabelID[1] = widget_label(stat_base2,value=(' Mean: ' + smean),$ 
                                          /align_left,font=info.font3)
info.image.mlabelID[1] = widget_label(stat_base2,$
                         value=(' Min: ' + smin + '   Max: ' + smax),$
                                      /align_left,font=info.font3)


; min and max scale of  image
info.image.srange_base[1] = widget_base(info.image.graphID12,row=1)
info.image.image_recomputeID[1] = widget_button(info.image.srange_base[1],value=' Image Scale ',$
                                                font=info.font4,$
                                                uvalue = 'scale2')

info.image.rlabelID[1,0] = cw_field(info.image.srange_base[1],title="min",font=info.font4,$
                                    uvalue="sr2_b",/float,/return_events,$
                                    xsize=info.xsize_label,value =range_min,$
                                    fieldfont = info.font4)

info.image.rlabelID[1,1] = cw_field(info.image.srange_base[1],title="max",font=info.font4,$
                                    uvalue="sr2_t",/float,/return_events,$
                                    xsize = info.xsize_label,value =range_max,$
                                   fieldfont=info.font4)

info.image.plot_base[1] = widget_base(info.image.graphID12)
info.image.graphID[1] = widget_draw(info.image.plot_base[1],$
                                    xsize =info.plotsize1,$ ; 256 
                                    ysize =info.plotsize1,$ ; 256
                                    /Button_Events,$
                                    retain=info.retn,uvalue='mqlpixel2')

zoom_base = widget_base(info.image.graphID12,row=1)

info.image.zoom_label[0] = widget_button(zoom_base,value=zoomvalues[0],$
                                           uvalue='zsize1',$
                                           font=info.font4)

info.image.zoom_label[1] = widget_button(zoom_base,value=zoomvalues[1],$
                                           uvalue='zsize2',$
                                           font=info.font4)
info.image.zoom_label[2] = widget_button(zoom_base,value=zoomvalues[2],$
                                           uvalue='zsize3',$
                                           font=info.font4)
info.image.zoom_label[3] = widget_button(zoom_base,value=zoomvalues[3],$
                                           uvalue='zsize4',$
                                           font=info.font4)
info.image.zoom_label[4] = widget_button(zoom_base,value=zoomvalues[4],$
                                           uvalue='zsize5',$
                                           font=info.font4)

info.image.zoom_label[5] = widget_button(zoom_base,value=zoomvalues[5],$
                                           uvalue='zsize6',$
                                           font=info.font4)
;_______________________________________________________________________
; Information 

compare_label = cw_field(info.image.infoID00,title='Compare Science Frame to Frame #',$
                         font = info.font5,uvalue='fcompare',/integer,/return_events,$
                         value = 0, xsize=4,fieldfont = info.font3)

; button to change all the images- one for integration#  and 
;                                  one for frame #

iramp = info.image.rampNO
jintegration = info.image.IntegrationNO

moveframe_label = widget_label(info.image.infoID00,value='Change Image Displayed',$
                                font=info.font5,/sunken_frame,/align_left)
move_base1 = widget_base(info.image.infoID00,row=1,/align_left)
info.image.integration_label = cw_field(move_base1,$
                    title="Integration # ",font=info.font5, $
                    uvalue="integration",/integer,/return_events, $
                    value=jintegration+1,xsize=4,$
                    fieldfont=info.font3)

labelID = widget_button(move_base1,uvalue='integr_move_dn',value='<',font=info.font3)
labelID = widget_button(move_base1,uvalue='integr_move_up',value='>',font=info.font3)


tlabel = "Total # " + strcompress(string(info.data.nints),/remove_all)

total_ilabel = widget_label( move_base1,value = tlabel,/align_left)


move_base2 = widget_base(info.image.infoID00,row=1,/align_left)
info.image.frame_label = cw_field(move_base2,$
              title="Frame # ",font=info.font5, $
              uvalue="frame",/integer,/return_events, $
              value=iramp+1,xsize=4,fieldfont=info.font3)
labelID = widget_button(move_base2,uvalue='fram_move_dn',value='<',font=info.font3)
labelID = widget_button(move_base2,uvalue='fram_move_up',value='>',font=info.font3)


tlabel = "Frames/Int  " + strcompress(string(info.data.nramps),/remove_all)

total_ilabel = widget_label( move_base2,value = tlabel,/align_left)
;-----------------------------------------------------------------------


; Pixel Information
general_label= widget_label(info.image.infoID00,$
                            value=" Pixel Information (Image: 1032 X 1024)",/align_left,$


                            font=info.font5,/sunken_frame)
; button to change 
pix_num_base = widget_base(info.image.infoID00,row=1,/align_left)
labelID = widget_button(pix_num_base,uvalue='pix_move_x1',value='<',font=info.font3)
labelID = widget_button(pix_num_base,uvalue='pix_move_x2',value='>',font=info.font3)

xvalue = info.image.x_pos*info.image.binfactor

yvalue = info.image.y_pos*info.image.binfactor

info.image.pix_label[0] = cw_field(pix_num_base,title="x",font=info.font4, $
                                   uvalue="pix_x_val",/integer,/return_events, $
                                   value=fix(xvalue+1),xsize=6,$  ; xvalue + 1 -4 (reference pixel)
                                   fieldfont=info.font3)

info.image.pix_label[1] = cw_field(pix_num_base,title="y",font=info.font4, $
                                   uvalue="pix_y_val",/integer,/return_events, $
                                   value=fix(yvalue+1),xsize=6,$
                                   fieldfont=info.font3)

labelID = widget_button(pix_num_base,uvalue='pix_move_y1',value='<',font=info.font3)
labelID = widget_button(pix_num_base,uvalue='pix_move_y2',value='>',font=info.font3)


if(info.image.apply_bad) then begin 
    apply_bad_pixel = intarr(2)
    apply_bad_pixel[0] = 1
    BadBase1 = Widget_base(info.image.infoID00,/row)
    blabel = widget_label (BadBase1, value = 'Apply Bad Pixel Mask: ',/align_left,font=info.font5)
    BadBase2 = Widget_base(BadBase1,/row,/nonexclusive)


    info.image.BadButton[0] = Widget_button(BadBase2, Value = 'YES',uvalue = 'bad1',font=info.font5)
    widget_control, info.image.BadButton[0],Set_Button =apply_bad_pixel[0] 


    info.image.BadButton[1] = Widget_Button(BadBase2, Value = ' NO ',uvalue = 'bad2',font=info.font5)
    widget_control, info.image.BadButton[1],Set_Button = apply_bad_pixel[1]
endif




flabel = widget_button(info.image.infoID00,value="Display a Table of  Frame Values",/align_left,$
                        uvalue = "getframe")
pix_num_base = widget_base(info.image.infoID00,col=2,/align_left)    



info.image.pix_statLabel = ["Dead/hot/noisy Pixel","Frame Value","Slope (DN/s)", $
                            "Uncertainty (DN/s)","Data Quality Flag",$
                            "Zero-Pt (DN)",$
                            "STD Fit ", "Read # of 1st Sat", $
                            "# Good Segments", "# of Good Frames"]

if(info.data.coadd eq 1) then info.image.pix_statLabel = ["Dead/hot/noisy Pixel","Frame Value","Coadd (DN/frame)", $
                            "Uncertainty (DN/frame)","Data Quality Flag",$
                            "Y-intercept ",$
                            "# Good Frames", "Read # of 1st Sat"]

info.image.pix_statLabel2 = ["Max 2pt Diff","Read # Max 2 pt Diff",$
                            "Slope 2pt Diff", "STDDEV 2pt diff" ]


info.image.pix_statFormat =  ["A4","F10.2","F12.5", "F10.5","I5","F10.2",$
                              "F12.5","F5.0","F5.0","F5.0"]


info.image.pix_statFormat2 =  ["F15.4","F5.3", "F15.5", "F15.2"]  
for i = 0,3 do begin  
    info.image.pix_statID[i] = widget_label(pix_num_base,value = info.image.pix_statLabel[i]+$
                                            ' =   ' ,/align_left,/dynamic_resize)
endfor

info_base = widget_base(info.image.infoID00,row=1,/align_left)
info.image.pix_statID[4] = widget_label(info_base,value = info.image.pix_statLabel[4]+$
                                        ' =  ' ,/align_left,/dynamic_resize)                                       
info_label = widget_button(info_base,value = 'Info',uvalue = 'datainfo')


for i = 5,9 do begin  
    info.image.pix_statID[i] = widget_label(pix_num_base,value = info.image.pix_statLabel[i]+$
                                     ' =  ' ,/align_left,/dynamic_resize)
endfor


if(info.data.slope_zsize ge 9)then begin 
    for i = 0,3 do begin  
        info.image.pix_statID2[i] = widget_label(pix_num_base,$
                                                 value = info.image.pix_statLabel2[i]+$
                                     ' =  ' ,/align_left,/dynamic_resize)
    endfor
endif


;_______________________________________________________________________
;*****
;graph 2,1
;*****

ss = " Slope Image [" + strtrim(string(info.data.image_xsize),2) + ' x ' +$
        strtrim(string(info.data.image_ysize),2) + ']' + " " + info.image.bindisplay[0]
if(not info.data.slope_exist) then ss = " NO Slope Image Exist" 


info.image.graph_label[2]= widget_label(info.image.graphID21,value = ss,$
                                      /align_center,font=info.font5,/sunken_frame)
mean = 0 & min = 0 & max = 0 
range_min = 0 & range_max = 0

if(info.data.slope_exist eq 1) then begin 
    mean = info.data.reduced_stat[0,0]
    min = info.data.reduced_stat[3,0]
    max = info.data.reduced_stat[4,0]
    
    range_min = info.data.reduced_stat[5,0]
    range_max = info.data.reduced_stat[6,0]
endif
info.image.graph_range[2,0] = range_min
info.image.graph_range[2,1] = range_max


smean =  strcompress(string(mean),/remove_all)
smin = strcompress(string(min),/remove_all) 
smax = strcompress(string(max),/remove_all) 
    
ssmean = string('Mean ' + smean )    
sminmax = string(' Min: ' + smin + '    Max: ' + smax) 

if(not info.data.slope_exist) then begin
	ssmean = '   Mean  NA        '
	sminmax = '   Min and Max  NA  '
endif

stat_base1 = widget_base(info.image.graphID21,row=1)
stat_base2 = widget_base(info.image.graphID21,row=1)


info.image.optionMenu[2] = widget_droplist(stat_base1,value=options,uvalue='option3',font=info.font4)

FullSize = widget_button(stat_base1,value='Inspect Image',uvalue='inspect_s',font=info.font4)
info.image.slabelID[2] = widget_label(stat_base2,$
                                      value=ssmean,font=info.font3,/align_left)
info.image.mlabelID[2] = widget_label(stat_base2,$
                                      value= sminmax,/align_left,font=info.font3)
info.image.srange_base[2] = widget_base(info.image.graphID21,row=1)
info.image.image_recomputeID[2] = widget_button(info.image.srange_base[2],value=' Image Scale ',$
                                                font=info.font4,$
                                                uvalue = 'scale3')
info.image.rlabelID[2,0] = cw_field(info.image.srange_base[2],$
                                    title="min",font=info.font4,uvalue='sr3_b',$
                                    /float,/return_events,xsize=info.xsize_label,value =range_min)

info.image.rlabelID[2,1] = cw_field(info.image.srange_base[2],$
                                    title="max",font=info.font4,uvalue='sr3_t',$
                                    /float,/return_events,xsize = info.xsize_label,value =range_max)

    

info.image.plot_base[2] = widget_base(info.image.graphID21)
info.image.graphID[2] = widget_draw(info.image.plot_base[2],$
                                        xsize =info.image.xplot_size,$ 
                                        ysize =info.image.yplot_size,$
                                        /Button_Events,$
                                        retain=info.retn,uvalue='mqlpixel3')

;*****
;graph 2,2
;*****

ramp_range = fltarr(2,2)        ; plot range for the ramp plot, 


tlabelID = widget_label(info.image.graphID22,$
                        value = " Frame Values in Selected Pixel for Given " $
                        + "Integration Range",$
                        /align_center,$
                        font=info.font5,/sunken_frame)


; button to change selected pixel


pix_num_base = widget_base(info.image.graphID22,row=1,/align_center)

xs = ' x: '+ strcompress(string(fix(info.image.x_pos*info.image.binfactor) +1),/remove_all)
ys = ' y: '+ strcompress(string(fix(info.image.y_pos*info.image.binfactor)+ 1),/remove_all)

if(info.data.nramps gt 200) then begin
    xs = 'Click on pixel to plot ramp'
    ys = ' '
endif
info.image.ramp_x_label = widget_label (pix_num_base,value=xs,/dynamic_resize)
info.image.ramp_y_label = widget_label (pix_num_base,value=ys,/dynamic_resize)
int_range = intarr(2) 
int_range[0] = 1  ; initialize to look at first integration
int_range[1] = 1
info.image.int_range[*] = int_range[*]
if(info.data.coadd eq 1) then info.image.int_range[1] = info.data.nints

move_base = widget_base(info.image.graphID22,/row,/align_left)

IrangeID = lonarr(2)
info.image.IrangeID[0] = cw_field(move_base,$
                  title="Integration range: Start", $
                  uvalue="int_chng_1",/integer,/return_events, $
                  value=info.image.int_range[0],xsize=4,$
                  fieldfont=info.font3)
info.image.IrangeID[1] = cw_field(move_base,$
                  title="End", $
                  uvalue="int_chng_2",/integer,/return_events, $
                  value=info.image.int_range[1],xsize=4,$
                  fieldfont=info.font3)

labelID = widget_button(move_base,uvalue='int_move_d',value='<',font=info.font3)
labelID = widget_button(move_base,uvalue='int_move_u',value='>',font=info.font3)



info.image.graphID[3] = widget_draw(info.image.graphID22,$
                                    xsize = info.plotsize3,$
                                    ysize = info.plotsize1,$
                                    retain=info.retn)


;buttons to  change the x and y ranges

pix_num_base2 = widget_base(info.image.graphID22,row=1)
labelID = widget_label(pix_num_base2,value="X->",font=info.font4)
info.image.ramp_mmlabel[0,0] = cw_field(pix_num_base2,title="min:",font=info.font4, $
                                        uvalue="ramp_mmx1",/integer,/return_events, $
                                        value=fix(ramp_range[0,0]), $
                                        xsize=info.xsize_label,fieldfont=info.font4)

info.image.ramp_mmlabel[0,1] = cw_field(pix_num_base2,title="max:",font=info.font4, $
                                        uvalue="ramp_mmx2",/integer,/return_events, $
                                        value=fix(ramp_range[0,1]),xsize=info.xsize_label,$
                                        fieldfont=info.font4)

info.image.ramp_recomputeID[0] = widget_button(pix_num_base2,value='  Plot Range  ',$
                                               font=info.font4,$
                                               uvalue = 'r1')

pix_num_base3 = widget_base(info.image.graphID22,row=1)

labelID = widget_label(pix_num_base3,value="Y->",font=info.font4)
info.image.ramp_mmlabel[1,0] = cw_field(pix_num_base3,title="min:",font=info.font4, $
                                        uvalue="ramp_mmy1",/float,/return_events, $
                                        value=ramp_range[1,0],xsize=info.xsize_label,$
                                        fieldfont=info.font4)

info.image.ramp_mmlabel[1,1] = cw_field(pix_num_base3,title="max:",font=info.font4, $
                                        uvalue="ramp_mmy2",/float,/return_events, $
                                        value=ramp_range[1,1],xsize=info.xsize_label,$
                                        fieldfont=info.font4)

info.image.ramp_recomputeID[1] = widget_button(pix_num_base3,value='  Plot Range  ',$
                                               font=info.font4,$
                                               uvalue = 'r2')

info.image.ramp_range = ramp_range


info.image.pixeldisplay=["Automatically Read/Plot Pixel Values",$
                         "Do not Read/Update Plot with new pixels values"] 
updatepixel = widget_droplist(info.image.graphID22,value=info.image.pixeldisplay,$
                                       uvalue='auto',/align_left)
info.image.autopixelupdate = 1

;_______________________________________________________________________





IAllButton = Widget_button(info.image.infoID22, Value = 'Plot All Integrations',$
                           uvalue = 'int_grab_all',/align_left)
widget_control,IAllButton,Set_Button = 0

IAllButton = Widget_button(info.image.infoID22, Value = 'Over plot Integrations',$
                           uvalue = 'int_overplot',/align_left)
widget_control,IAllButton,Set_Button = 0
bk = widget_label(info.image.infoID22,value = ' ' ) 
overplotSlopeID = lonarr(2)
overplotRefID = lonarr(2)
if(info.data.slope_exist)then begin 
    if(info.data.coadd ne 1) then $
    overplot = widget_label(info.image.infoID22,value = 'Over-plot Values from Fit (red)',/sunken_frame,$
                            font = info.font5,/align_left)
    if(info.data.coadd eq 1) then $
    overplot = widget_label(info.image.infoID22,value = 'Over-plot Coadded Value (red)',/sunken_frame,$
                            font = info.font5,/align_left)
    oBase = Widget_base(info.image.infoID22,/row,/nonexclusive)

    OverplotSlopeID[0] = Widget_button(oBase, Value = ' Yes ',uvalue = 'overslope1')
    widget_control,OverplotSlopeID[0],Set_Button = 1

    OverplotSlopeID[1] = Widget_Button(oBase, Value = ' No ',uvalue = 'overslope2')
    widget_control,OverplotSlopeID[1],Set_Button = 0

endif

info.image.overplotSlopeID = overplotSlopeID

overplotRefCorrectedID = lonarr(2)

if(info.control.file_refcorrection_exist eq 1)then begin 
    overplot = widget_label(info.image.infoID22,value = 'Over-plot Reference Corrected Data (blue +)',/sunken_frame,$
                            font = info.font5,/align_left)

    oBase = Widget_base(info.image.infoID22,/row,/nonexclusive)

    OverplotRefCorrectedID[0] = Widget_button(oBase, Value = ' Yes ',uvalue = 'overref1')
    widget_control,OverplotRefCorrectedID[0],Set_Button = 1

    OverplotRefCorrectedID[1] = Widget_Button(oBase, Value = ' No ',uvalue = 'overref2')
    widget_control,OverplotRefCorrectedID[1],Set_Button = 0
endif

info.image.overplotRefcorrectedID = overplotRefCorrectedID



;_______________________________________________________________________
overplotCRID = lonarr(2)
if(info.control.file_ids_exist eq 1)then begin 
    mark = widget_label(info.image.infoID22,value = 'Mark Noise & Cosmic Rays  (yellow)',/sunken_frame,$
                            font = info.font5,/align_left)
    mark = widget_label(info.image.infoID22,value = '(Corrupted Frames are marked in a yellow triangle)',$
                            font = info.font6,/align_left)

    oBase = Widget_base(info.image.infoID22,/row,/nonexclusive)

    OverplotCRID[0] = Widget_button(oBase, Value = ' Yes ',uvalue = 'overcr1')
    widget_control,OverplotCRID[0],Set_Button = 1

    OverplotCRID[1] = Widget_Button(oBase, Value = ' No ',uvalue = 'overcr2')
    widget_control,OverplotCRID[1],Set_Button = 0
endif

info.image.overplotCRID = overplotCRID


;_______________________________________________________________________

;_______________________________________________________________________
overplotresetID = lonarr(2)
if(info.control.file_reset_exist eq 1)then begin 
    mark = widget_label(info.image.infoID22,value = 'Over Plot Reset Corrected Data  (green +)',/sunken_frame,$
                            font = info.font5,/align_left)

    oBase = Widget_base(info.image.infoID22,/row,/nonexclusive)

    OverplotresetID[0] = Widget_button(oBase, Value = ' Yes ',uvalue = 'overreset1')
    widget_control,OverplotresetID[0],Set_Button = 1

    OverplotresetID[1] = Widget_Button(oBase, Value = ' No ',uvalue = 'overreset2')
    widget_control,OverplotresetID[1],Set_Button = 0
endif

info.image.overplotresetID = overplotresetID

;_______________________________________________________________________


;_______________________________________________________________________
overplotrscdID = lonarr(2)
if(info.control.file_rscd_exist eq 1)then begin 
    mark = widget_label(info.image.infoID22,value = 'Over Plot RSCD Corrected Data  (green +)',/sunken_frame,$
                            font = info.font5,/align_left)

    oBase = Widget_base(info.image.infoID22,/row,/nonexclusive)

    OverplotrscdID[0] = Widget_button(oBase, Value = ' Yes ',uvalue = 'overrscd1')
    widget_control,OverplotrscdID[0],Set_Button = 1

    OverplotrscdID[1] = Widget_Button(oBase, Value = ' No ',uvalue = 'overrscd2')
    widget_control,OverplotrscdID[1],Set_Button = 0
endif

info.image.overplotrscdID = overplotrscdID

;_______________________________________________________________________
overplotlastframeID = lonarr(2)
if(info.control.file_lastframe_exist eq 1)then begin 
    mark = widget_label(info.image.infoID22,value = 'Over Plot Lastframe Corrected Data  (blue Diamond)',/sunken_frame,$
                            font = info.font5,/align_left)

    oBase = Widget_base(info.image.infoID22,/row,/nonexclusive)

    OverplotlastframeID[0] = Widget_button(oBase, Value = ' Yes ',uvalue = 'overlastframe1')
    widget_control,OverplotlastframeID[0],Set_Button = 1

    OverplotlastframeID[1] = Widget_Button(oBase, Value = ' No ',uvalue = 'overlastframe2')
    widget_control,OverplotlastframeID[1],Set_Button = 0
endif

info.image.overplotlastframeID = overplotlastframeID


;_______________________________________________________________________
overplotMDCID = lonarr(2)
if(info.control.file_mdc_exist eq 1)then begin 
    mark = widget_label(info.image.infoID22,value = 'Over Plot Dark Corrected Data  (green boxes)',/sunken_frame,$
                            font = info.font5,/align_left)

    oBase = Widget_base(info.image.infoID22,/row,/nonexclusive)

    OverplotMDCID[0] = Widget_button(oBase, Value = ' Yes ',uvalue = 'overmd1')
    widget_control,OverplotMDCID[0],Set_Button = 1

    OverplotMDCID[1] = Widget_Button(oBase, Value = ' No ',uvalue = 'overmd2')
    widget_control,OverplotMDCID[1],Set_Button = 0
endif

info.image.overplotMDCID = overplotMDCID
;_______________________________________________________________________

overplotLCID = lonarr(2)

plotRLCID = lonarr(2)
info.image.plot_lc_results = 0
if(info.control.file_lc_exist eq 1)then begin 
    mark = widget_label(info.image.infoID22,value = 'Overplot Linearity Corrected Data (blue *)',/sunken_frame,$
                            font = info.font5,/align_left)

    oBase = Widget_base(info.image.infoID22,/row,/nonexclusive)

    OverplotLCID[0] = Widget_button(oBase, Value = ' Yes ',uvalue = 'overlc1')
    widget_control,OverplotLCID[0],Set_Button = 1

    OverplotLCID[1] = Widget_Button(oBase, Value = ' No ',uvalue = 'overlc2')
    widget_control,OverplotLCID[1],Set_Button = 0


    mark = widget_label(info.image.infoID22,value = 'Plot Lin. Cor. Results',/sunken_frame,$
                            font = info.font5,/align_left)

    oBase = Widget_base(info.image.infoID22,/row,/nonexclusive)

    plotRLCID[0] = Widget_button(oBase, Value = ' Yes ',uvalue = 'plotrlc1')
    widget_control,plotRLCID[0],Set_Button = 0

    plotRLCID[1] = Widget_Button(oBase, Value = ' No ',uvalue = 'plotrlc2')
    widget_control,plotRLCID[1],Set_Button = 1


endif

info.image.plotRLCID = plotRLCID
info.image.overplotLCID = overplotLCID



;*****

blank = "                                                                                                                                                       "
blank_label= widget_label(info.image.infoID00,value = blank)
;_______________________________________________________________________
; realize main panel
longline = '                                                                                                                        '
longtag = widget_label(RawQuicklook,value = longline)
;Set up the GUI
Widget_control,info.RawQuickLook,/Realize
XManager,'mql',info.RawQuickLook,/No_Block,event_handler='mql_event'


; get the window ids of the draw windows

n_draw = n_elements(info.image.graphID)
for i = 0,(n_draw-1) do begin
    widget_control,info.image.graphID[i],get_value=tdraw_id
    info.image.draw_window_id[i] = tdraw_id
    if(i eq 0 or i eq 2 ) then begin
        window,/pixmap,xsize=info.image.xplot_size,ysize=info.image.yplot_size,/free
        info.image.pixmapID[i] = !D.WINDOW
    endif

    if(i eq 1 ) then begin
        window,/pixmap,xsize=info.plotsize1,ysize=info.plotsize1,/free
        info.image.pixmapID[i] = !D.WINDOW
    endif
endfor


; load the first image into the graph windows


loadct,info.col_table,/silent


mql_update_images,info

info.image.graph_mpixel = 1
info.image.zoom_window = 1
info.image.x_zoom = info.image.x_pos* info.image.binfactor
info.image.y_zoom = info.image.y_pos* info.image.binfactor
info.image.zoom_window = 1

mql_update_zoom_image,info


mql_update_slope,info
; load individual ramp graph - based on x_pos, y_pos

if(info.data.nramps lt 200) then  mql_update_rampread,info


mql_update_pixel_stat,info

Widget_Control,info.QuickLook,Set_UValue=info
sinfo = {info        : info}

Widget_Control,info.RawQuickLook,Set_UValue=sinfo
Widget_Control,info.QuickLook,Set_UValue=info

end
