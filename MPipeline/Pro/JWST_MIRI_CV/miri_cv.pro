;+
; NAME:
;      miri_cv (CubeView)
;
; PURPOSE:
;      Tool to visualize the spectroscopic cube built by cube_build in
;      the jwst pipeline
;
; EXPLANATION:
;      GUI (IDL Widget) which allows the user to interactively 
;      examine the spectrascopic cube, overlap the detector data and
;      extract 1-D spectra. 

;
; CALLING SEQUENCE:
;      interactive: miri_cv
;
;
; INPUTS:
;      1. All the default information is held in a preferences file:
;         JWST_MIRI_CV_v#.#.preferences. The location of this file is specified
;         by the environmental varible: MIRI_DHAS
;
; OUTPUTS:
;      There are options to print certain graphs to a postscript or
;      encapsulated postscript file.  
;
; EXAMPLE:
;       IDL> miri_cv
;
; PROCEDURES USED:
;       many - This code should be put into a specific directory and
;              the users IDL_PATH variable should be updated to
;              include this location.
; 
; ADDITIONAL DOCUMENTATION:
;       A detailed web page for the MIRI DHAS is located at the
;       password protected site:
;
;       http://ircamera.as.arizona.edu/MIRI/team_only/dhas/dhas.html
;       email morrison@as.arizona.edu for the username and password 
; SUPPORT:
;       Support is provided to authorized users by the author.
;       Suggested changes should be communicated to her 
;       (morrison @as.arizona.edu).
;
; REVISON HISTORY:
;       v1 Written by Jane Morrison Oct, 2020
;       

;-

@jwst_cv_code.pro ; listing of all code pieces

pro miri_cv

@jwst_cube_structs ; holds data structures
@jwst_view_structs ; holds display structures


; set 8 bit color according to operating system
  Case !version.os of
  'linux': device, decomposed=0
  'sunos': device, true = 24
  else:
endcase

  Case !version.os of
  'sunos': print,' Operating System: sunos'
  else:
endcase

device,decomposed = 0 ; set this from the start

; create  "control " structure
cv_control = {cube_controli}
; initialize varibles
cv_control.dirCube = "."
cv_control.added_dir = 0
cv_control.filename_cube = ' ' 

miri_dir = getenv('MIRI_DHAS')
len = strlen(miri_dir)
if(len eq 0) then begin
   result = dialog_message(" You need to set the environmental variable MIRI_DHAS",/error)
   stop
endif
   
test = strmid(miri_dir,len-1,len-1)
if(test ne '/') then miri_dir = miri_dir + '/'
cv_control.miri_dir = miri_dir

;_______________________________________________________________________
; create structures used in cube_viewing
cv_wave_play = {wavei}
cv_wave_play.stopflag = 0
cv_wave_play.delay = 1.1

jwst_coadd = {addi}
jwst_coadd.select_ranges = 0

jwst_centroid = {centroidi}
jwst_centroid.rebin_factor = 1
jwst_centroid.xoffset_surface = 50 
jwst_centroid.yoffset_surface = 50
jwst_centroid.uoffset_surface = 0

; create and initialize "cube" structure
jwst_cube = {cubei}
jwst_cube.istart_wavelength = 0

; create and initialize "view cube" structure
view_cube = {view_cubei}
view_cube.zoom = 1
view_cube.zoom_user = 1
view_cube.plot_pixel = 0

; Create and initialize the "Region Of Interest" structure.
roi = ptr_new({roii})
(*roi).color = 4
(*roi).boxx0 = -1
(*roi).boxy0 = -1
(*roi).tempxbox = -1
(*roi).tempybox = -1
(*roi).roixsize = 0
(*roi).roiysize = 0
(*roi).roix1 = 0
(*roi).roiy1 = 0
(*roi).roix2 = 0
(*roi).roiy2 = 0
(*roi).pressed = 0

adjust_roi= {adjustroii}
jwst_spectrum = {spectrumi}
view_spectrum = {view_spectrumi}
view_spectrum.default_range[*] = 1
;_______________________________________________________________________
; work out the fontname
; on command line you can find the fontnames by typing
; device,get_fontnames=fnames,set_font='*'

fontname1 = '-adobe-helvetica-medium-r-normal--18*'
fontname2 = '-adobe-helvetica-medium-r-normal--14*'
fontname3 = '-adobe-helvetica-medium-r-normal--12*'
fontname4 = '-adobe-helvetica-medium-r-normal--10*'
fontname6 = '-adobe-helvetica-medium-r-normal--8*'
fontname5 = '-adobe-helvetica-bold-r-normal--12*'
fontlarge = '-adobe-courier-bold-o-normal--20*'
fontmedium = '-adobe-courier-bold-o-normal--14*'
fontsmall = '-adobe-courier-bold-o-normal--8*'
window,1,/pixmap
device,get_fontnames=fnames,set_font=fontname1
fontname1 = fnames[0]
device,get_fontnames=fnames,set_font=fontname2
fontname2 = fnames[0]
device,get_fontnames=fnames,set_font=fontname3
fontname3 = fnames[0]
device,get_fontnames=fnames,set_font=fontname4
fontname4 = fnames[0]
device,get_fontnames=fnames,set_font=fontname5
fontname5 = fnames[0]
device,get_fontnames=fnames,set_font=fontname6
fontname6 = fnames[0]

wdelete,1
xsize_label = 9
view_header_lines = 60
;********
; setup the color table
;********
!EXCEPT = 2
col_table = 3
loadct,col_table,/silent
col_max =  min([!d.n_colors, 255])
bw_col_table =0  

jwst_cv_color6                 
col_bits = 6
; set value of retain for graphics
 retn=2
;___________________________________________________________________
window,1,/pixmap
wdelete,1
;*********
;Setup main panel
;*********
;_______________________________________________________________________
; Set up size of windows
w = get_screen_size()
x_max = w[0] * .95
y_max = w[1] * .85
if(x_max gt 1400) then x_max = 1400
if(y_max gt 1024) then y_max = 1024
cv_control.max_x_screen = x_max + (x_max*.1) 
cv_control.max_y_screen = y_max + (y_max*.1) 

cv_control.max_x_window = x_max*0.5
cv_control.max_y_window = y_max*0.5

print,'max screen',cv_control.max_x_screen, cv_control.max_y_screen
print,'max window',cv_control.max_x_window, cv_control.max_y_window
xsize_scroll =x_max
ysize_scroll =y_max
;_______________________________________________________________________
; call setup cube before read miri preferences because it has to read in
; setup_cube - pops up the window to select the cube to read in
jwst_setup_cube,cv_control,view_cube,jwst_cube,jwst_spectrum,roi,status

if(status eq 2) then begin
    return
endif

;_______________________________________________________________________

version = "(v 9.8.9 Nov 22, 2021)"
cv_control.pref_filename=miri_dir+'Preferences/'+'JWST_MIRI_CV_v9.8.preferences'
print,'  Preferences file ',cv_control.pref_filename

; only thing reading from preferences file (at this time) is the
; location of output plots file
Pdirps = ' ' 
status = 0
jwst_read_cube_preferences,cv_control.pref_filename,$
                           cv_control.miri_dir,$
                           Pdirps, status

print,' Done reading preferences file'
if(status eq 0) then begin
    cv_control.dirps = Pdirps
endif

;_______________________________________________________________________
xspectrum = jwst_spectrum.wavelength_range[1] - jwst_spectrum.wavelength_range[0] +1
yspectrum = jwst_spectrum.flux_range[1] - jwst_spectrum.flux_range[0] +1

xzoom = (view_cube.plot_xsize*2)/xspectrum 
yzoom = (view_cube.plot_ysize*1.1)/yspectrum ; y size a little smaller to fit in y direction
                                ; with all the boxes and labels 

view_spectrum.xzoom = xzoom
view_spectrum.yzoom = yzoom
;-----------------------------------------------------------------------
; test the x window size to make sure it is large enough
toobig = 0
newzoom = xzoom
j = 1
while(toobig eq 0) do begin
    newzoom = xzoom* 2 * j
    if( xspectrum*newzoom  le cv_control.max_x_window )then begin 
        j= j + 1
    endif else begin
        toobig = 1
    endelse
endwhile

if(j gt 1) then view_spectrum.xzoom  = xzoom*2*(j-1)
;-----------------------------------------------------------------------
view_spectrum.plot_xsize = xspectrum * view_spectrum.xzoom
view_spectrum.plot_ysize = yspectrum * view_spectrum.yzoom
;_______________________________________________________________________
xwidget_size = cv_control.max_x_screen
ywidget_size = cv_control.max_y_screen
;_______________________________________________________________________
CubeView = widget_base(title="MIRI CubeView " + version,$
                       /column,mbar = menuBar,/scroll,$
                       /TLB_SIZE_EVENTS, xsize = xwidget_size,ysize=ywidget_size,$
                       x_scroll_size = xsize_scroll,y_scroll_size = ysize_scroll)
;_______________________________________________________________________
; values set by the program
titlelabel = '      '

;********
; build the menubar
;********
LoadCubeMenu = widget_button(menuBar, value="View Cube",font=fontname2)
optionsMenu = widget_button(menuBar,value ="Options",font = fontname2)
WaveMenu = widget_button(menuBar, value=" Wavelength",font=fontname2)
ZoomMenu = widget_button(menuBar,value ="Zoom",font = fontname2)
ColorMenu = widget_button(menuBar,value ="Color",font = fontname2)
QuitMenu = widget_button(menuBar,value="Quit",font = fontname2)
PrintMenu = widget_button(menuBar,value="Print",font = fontname2)

; load cube
LoadCubeButton = widget_button(LoadCubeMenu,value=" Load New Cube",font=fontname2)
ViewHeaderButton = widget_button(LoadCubeMenu,value=" View Cube Header",font=fontname2)

; load science data to overplot
WaveButton = widget_button(WaveMenu,value="Select and Play Wavelength Slices in Cube",$
                               font=fontname2)
; zoom 
zoom1 = widget_button(zoommenu,value = ' No Zoom ' ,/checked_menu)
zoom2 = widget_button(zoommenu,value = ' 2 X Zoom ',/checked_menu)
zoom4 = widget_button(zoommenu,value = ' 4 X Zoom ',/checked_menu)
zoom8 = widget_button(zoommenu,value = ' 8 X Zoom ',/checked_menu)
zoom16 = widget_button(zoommenu,value = ' 16 X Zoom ',/checked_menu)

; change the color
colorbutton = widget_button(colormenu,value='Change Color of 2-D Image',event_pro='jwst_cv_color',font=fontname2)

PrintButtonI  = Widget_Button(PrintMenu, Value='Print 2-D Image')
PrintButtonD  = Widget_Button(PrintMenu, Value='Print Spectra to File')
PrintButtonP  = Widget_Button(PrintMenu, Value='Print Spectrum to Plot')

optionsbutton2 = widget_button(optionsmenu,value='Turn Off Plotting Box around Pixel',font=fontname2)

roi_image = 0
image_collapse = 0
; quit button
quitbutton = widget_button(quitmenu,value="Quit",event_pro='jwst_cv_quit')

;***********************************************************************
graphID_master0 = widget_base(CubeView,row=1)
graphID_master1 = widget_base(CubeView,row=1)
graphID_master2 = widget_base(CubeView,row=1)
graphID_master3 = widget_base(CubeView,row=1)


graphID0 = widget_base(graphID_master0,row= 1)
graphID1 = widget_base(graphID_master1,row= 1)
graphID2 = widget_base(graphID_master2,row= 1)

graphID2a = widget_base(graphID2,col=1)
graphID2b = widget_base(graphID2,col=1)

graphID3a = widget_base(graphID_master3,row= 1)
graphID3b = widget_base(graphID_master3,col= 1)

cube_box = widget_base(graphID0,/row)
cube_info_box = widget_base(cube_box,row=1)

Cube_name = 'IFU Cube: ' + cv_control.file_cube_base 
graph_labelID = widget_label(cube_info_box,value = cube_name,/align_left,$
                             font = fontname5,/dynamic_resize)
image2display = widget_label(cube_info_box, value = '   Image Displayed',font = fontname5)

ImageType = 0
ImageDisplayed=['Wavelength Slice','Co-added, Select Wavelength', 'Coadded, All Wavelengths']
ImageDID = widget_combobox(cube_info_box,value = ImageDisplayed, font = fontname5)

do_centroid = 0
CentroidID = widget_button(cube_info_box,value = ' Centroid ',font=fontname5)
CentroidParamID = widget_button(cube_info_box,value = ' Centroid Parameters',font=fontname5)
InfoCentroidID = widget_button(cube_info_box,value =  'Info')

;-----------------------------------------------------------------------
select_roi = 0
roi_box = widget_base(graphID2a,/row)

full_box = widget_base(graphID2a,/row)

roiID = widget_label(roi_box,value = ' Select Region of Interest',$
                     font = fontname5,/dynamic_resize)
obase = Widget_base(roi_box,/row,/nonexclusive)
roi_button1 = Widget_button(oBase, Value = ' Yes ')
widget_control,roi_button1,Set_Button = 0

roi_button2 = Widget_Button(oBase, Value = ' No ')
widget_control,roi_button2,Set_Button = 1

roi_adjust_button = Widget_button(roi_box, Value = ' Adjust ROI')

full_cube_button = widget_button(full_box, value = ' View Full Cube',font = fontname5,/dynamic_resize)

lock_wavelength = 0
lockID = widget_label(full_box,value='Lock Wavelength Plane',/align_left)

obase = Widget_base(full_box,/row,/nonexclusive)
lock_button1 = Widget_button(oBase, Value = ' Yes ')
widget_control,lock_button1,Set_Button = 0

lock_button2 = Widget_Button(oBase, Value = ' No ')
widget_control,lock_button2,Set_Button = 1
InfoLockID = widget_button(full_box,value =  'Info')
;-----------------------------------------------------------------------

plotID = widget_draw(graphID2a,xsize =view_cube.plot_xsize,$
                     ysize=view_cube.plot_ysize,$
                     retain= retn,/motion_events, /button_events,$
                     event_pro='jwst_cube_pixel')

    
; min and max scale of  image
scale_base = widget_base(graphID2a,row = 1)
default_scale = 1
default_scaleID = widget_button(scale_base,value=' Image Scale ',$
                                font=fontname3)

graph_range = fltarr(2)
rminlabelID = cw_field(scale_base[0],title="min",font=fontname4,$
                       /float,/return_events,$
                       xsize=xsize_label,value =graph_range[0],$
                       fieldfont = fontname3)

rmaxlabelID = cw_field(scale_base[0],title="max",font=fontname4,$
                       /float,/return_events,$
                       xsize=xsize_label,value =graph_range[1],$
                       fieldfont = fontname3)

; plot x,y, pixel value, wmap, ra, dec
coords_of_cube = 'Cube spaxel:         '
pix_box = widget_base(graphID2a,/row)
pixel_labelID1 = widget_label(pix_box,value = coords_of_cube,/align_left,$
                             font = fontname3,/dynamic_resize)
coords_of_cube = '         '
pix_box = widget_base(graphID2a,/row)
pixel_labelID2 = widget_label(pix_box,value = coords_of_cube,/align_left,$
                             font = fontname3,/dynamic_resize)

;_______________________________________________________________________
x1 = (*roi).roix1
y1 = (*roi).roiy1
x2 = (*roi).roix2
y2 = (*roi).roiy2

iwavelength = view_cube.this_iwavelength - jwst_cube.istart_wavelength 
jwst_cv_box_stat,x1,x2,y1,y2,iwavelength,jwst_cube,range_min,range_max,box_stat

swlength = strcompress(string((*jwst_cube.pwavelength)[iwavelength]),/remove_all)

info_box1 = box_stat[0] + box_stat[1] + box_stat[2] + box_stat[3] 
info_box2 = box_stat[4] + box_stat[5]

;_______________________________________________________________________
; Extracted Spectrum
stitle = "Extracted Spectrum "

smean = 0.0
sstdev = 0.0
smin = 0.0
smax = 0.0

range_min = 0.0
range_max = 0.0

base_line = widget_base(graphID2b,/row)
tlabelID = widget_label(base_line,value = stitle,$
                            /align_center,font=fontname5)
base_line2 = widget_base(base_line,/row,/nonexclusive)
;_______________________________________________________________________
value_lineID = 0L
error_barsID =  0L   	
info_spectrum_labelID   = 0L
view_spectrum.show_value_line = 1
view_spectrum.show_error_bars = 1

wlines = ['Show Wavelength Bar','Do not Show Wavelength Bar']
value_lineID = widget_combobox(base_line,value = wlines,$
                               font = fontname5,/dynamic_resize)
    

errorbars = ['Do not Show Error Bars','Show Error Bars']
error_barsID = widget_combobox(base_line,value = errorbars,font = fontname5,/dynamic_resize)

specDraw = Widget_Draw(graphID2b, XSize = view_spectrum.plot_xsize, YSize = view_spectrum.plot_ysize, $
                       /Button_Events, Retain=2,$
                       /motion_events,event_pro = 'jwst_cv_draw_line')

info_wave ='                                                                                                   '
info_box = widget_base(graphID2b,/row)
info_spectrum_labelID = widget_label(info_box,value = info_wave,/align_left,$
                                     font = fontname5,/dynamic_resize)
green_base = widget_base(graphID2b,/row)
green_lineID1 = widget_label(info_box, value = '(Green Line: Current Wavelength Plane in Cube View)',$
                             font = fontname3,/dynamic_resize)

range = fltarr(2,2)
range_base = widget_base(graphID2b,row = 1)
XlabelID = widget_label(range_base,value="Lamba->",font=fontname5)
range_x1_labelID = cw_field(range_base,title="min:",font=fontname3, $
                            /float,/return_events, $
                            value=fix(range[0,0]), $
                            xsize=xsize_label,fieldfont=fontname3)

range_x2_labelID = cw_field(range_base,title="max:",font=fontname3, $
                            /float,/return_events, $
                            value=fix(range[0,1]),xsize=xsize_label,$
                            fieldfont=fontname3)
    
default_x_ID = widget_button(range_base,value=' Plot Range ',$
                             font=fontname3)
    
    
YlabelID = widget_label(range_base,value="Flux->",font=fontname5)
range_y1_labelID = cw_field(range_base,title="min:",font=fontname3, $
                            /float,/return_events, $
                            value=fix(range[1,0]), $
                            xsize=xsize_label,fieldfont=fontname3)

range_y2_labelID = cw_field(range_base,title="max:",font=fontname3, $
                            /float,/return_events, $
                            value=fix(range[1,1]),xsize=xsize_label,$
                            fieldfont=fontname3)
    
default_y_ID = widget_button(range_base,value=' Plot Range ',$
                             font=fontname3)


box_info = widget_base(graphID3a,/col,/frame) 
label2d = lonarr(5)
stat_label = widget_label(box_info,value = ' 2-D Image Statistics at Wavelength: ' + swlength,$
                          /align_left,font = fontname5,/dynamic_resize)
label2d[0] =  widget_label(box_info,value = info_box1,/align_left,/dynamic_resize,font=fontname5)
label2d[1] =  widget_label(box_info,value = info_box2,/align_left,/dynamic_resize,font=fontname5)

cenID = lonarr(7)
cenID[0] = widget_label(graphid3b,value = '',/dynamic_resize,/align_left)
cenID[1] = widget_label(graphid3b,value = '',/dynamic_resize,/align_left)
cenID[2] = widget_label(graphid3b,value = '',/dynamic_resize,/align_left)
cenID[3] = widget_label(graphid3b,value = '',/dynamic_resize,/align_left)
cenID[4] = widget_label(graphid3b,value = '',/dynamic_resize,/align_left)
cenID[5] = widget_label(graphid3b,value = '',/dynamic_resize,/align_left)
cenID[6] = widget_label(graphid3b,value = '',/dynamic_resize,/align_left)
;_______________________________________________________________________
longline = '                                                                                                                        '
longtag = widget_label(CubeView,value = longline)
viewhead = 0

Widget_control,CubeView,/Realize,/update

widget_control,plotID,get_value=tdraw_id
draw_window_id = tdraw_id
window,/pixmap,xsize =plotsize_cube_window,ysize = plotsize_cube_window,/free
pixmapID = !D.window

widget_control,specDraw,get_value=tdraw_id
view_spectrum.draw_window_id = tdraw_id
window,/pixmap,xsize =view_spectrum.plot_xsize,ysize = view_spectrum.plot_ysize,/free
pixmapID = !D.window
view_spectrum.pixmapID = pixmapID

view_image2d = {viewimage2di}

view_image2d.xpos = view_cube.xpos_cube
View_image2d.ypos = view_cube.ypos_cube

jwst_image2d = {image2di}

;********b
cinfo = {version                : version,$
         titlelabel             : titlelabel,$
         cv_control             : cv_control,$
         view_cube              : view_cube,$
         jwst_cube              : jwst_cube,$
         roi                    : roi,$
         cv_wave_play           : cv_wave_play,$
         jwst_coadd             : jwst_coadd,$
         jwst_spectrum          : jwst_spectrum,$
         jwst_centroid            : jwst_centroid,$
         view_spectrum          : view_spectrum,$
         view_image2d           : view_image2d,$
         jwst_image2d           : jwst_image2d,$
         adjust_roi             : adjust_roi,$
         Image2dDisplay         : 0L,$
         SelectWavelength       : 0L,$
         ViewSlope              : 0L,$
         WavePlay               : 0L,$
         CoaddSelect            : 0L,$ 
         SurfacePlot            : 0L,$
         AdjustROI              : 0L,$
         col_max                : col_max,$
         col_table              : col_table,$
         bw_col_table           : bw_col_table,$
         col_bits               : col_bits,$
         xsize_label            : xsize_label,$
         retn                   : retn,$
         font1                  : fontname1,$
         font2                  : fontname2,$
         font3                  : fontname3,$
         font4                  : fontname4,$
         font5                  : fontname5,$
         font6                  : fontname6,$
         fontsmall              : fontsmall,$
         pixel_labelID1          : pixel_labelID1,$
         pixel_labelID2         : pixel_labelID2,$
         graph_labelID          : graph_labelID,$
         cenID                  : cenID,$
         wavelengthID           : 0L,$
         LoadCubeButton         : LoadCubeButton,$
         ViewHeaderButton       : ViewHeaderButton,$
         OptionsButton2         : OptionsButton2,$
         imageDID               : imageDID,$
         ImageType              : ImageType,$
         InfoLockID             : InfoLockID,$
         InfoCentroidID         : InfoCentroidID,$
         CentroidID             : CentroidID,$
         CentroidParamID        : CentroidParamID,$
         do_centroid            : do_centroid,$
         roi_button1            : roi_button1,$
         roi_button2            : roi_button2,$
         roi_adjust_button      : roi_adjust_button,$
         full_cube_button       : full_cube_button,$
         WaveButton             : WaveButton,$
	 lock_button1            : lock_button1,$
	 lock_button2            : lock_button2,$
	 lock_wavelength         : lock_wavelength,$
         PrintButtonI           : PrintButtonI,$
         PrintButtonP           : PrintButtonP,$
         PrintButtonD           : PrintButtonD,$
         zoom1                  : zoom1,$
         zoom2                  : zoom2,$
         zoom4                  : zoom4,$
         zoom8                  : zoom8,$
         zoom16                 : zoom16,$
         specdraw               : specdraw,$
         plotID                 : plotID,$
         rminlabelID            : rminlabelID,$
         rmaxlabelID            : rmaxlabelID,$
         graph_range            : graph_range,$
         default_scale          : default_scale,$
         default_scaleID        : default_scaleID,$
         pixmapID               : pixmapID,$
         draw_window_id         : draw_window_id,$
         range_x1_labelID       : range_x1_labelID,$
         range_x2_labelID       : range_x2_labelID,$
         range_y1_labelID       : range_y1_labelID,$
         range_y2_labelID       : range_y2_labelID,$
         default_x_ID           : default_x_ID,$
         default_y_ID           : default_y_ID,$
         value_lineID           : value_lineID,$
         error_barsID           : error_barsID,$
         info_spectrum_labelID  : info_spectrum_labelID ,$
         viewhdrysize           : view_header_lines,$
         viewhead               : ptr_new(viewhead),$
         roi_image              : roi_image,$
         stat_label             : stat_label,$
         label2d                : label2d,$
         CubeView               : CubeView}
    

Widget_Control,CubeView,Set_UValue=cinfo

XManager,'jwst_cv',CubeView,/No_Block,cleanup='jwst_cv_cleanup',$
         event_handler="jwst_cv_event"


jwst_cv_header_setup,cinfo
jwst_cv_update_cube,cinfo
jwst_cv_update_spectrum,cinfo
jwst_cv_draw_current_wavelength,cinfo


Widget_Control,cinfo.CubeView,Set_UValue=cinfo
Widget_Control,cinfo.CubeView,Set_UValue=cinfo

end

