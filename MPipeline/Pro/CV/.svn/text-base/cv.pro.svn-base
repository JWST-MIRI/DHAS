;+
; NAME:
;      CV (CubeView)
;
; PURPOSE:
;      Tool to visualize the spectrascopic cube built by cube_build
;
; EXPLANATION:
;      GUI (IDL Widget) which allows the user to interactively 
;      examine the spectrascopic cube, overlap the detector data and
;      extract 1-D spectra. 

;
; CALLING SEQUENCE:
;      interactive: cubeview
;
;
; INPUTS:
;      1. All the default information is held in a preferences file:
;         MRI_MRS_DHAS_v#.#.preferences. The location of this file is specified
;         by the environmental varible: MIRI_DIR
;
; OUTPUTS:
;      There are options to print certain graphs to a postscript or
;      encapsulated postscript file.  
;
; EXAMPLE:
;       IDL> cubeview
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
;       v1 Written by Jane Morrison May 6, 2009
;       A list of changes are stored in a code change journal
;       

;-

@cv_code.pro ; listing of all code pieces
@color6
pro cv, prefname = prefnamein


@cube_structs ; holds data structures
@view_structs ; holds display structures


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
control = {cube_controli}
; initialize varibles
control.dirCube = "."
control.added_dir = 0
control.filename_cube = ' ' 
control.filename_slope = ' ' 
control.dircal = ' '
control.dirred = ' '


miri_dir = getenv('MIRI_DIR')
len = strlen(miri_dir) 
test = strmid(miri_dir,len-1,len-1)
if(test ne '/') then miri_dir = miri_dir + '/'
control.miri_dir = miri_dir

CDP_dir = getenv('CDP_DIR')
len = strlen(CDP_dir) 
test = strmid(CDP_dir,len-1,len-1)
if(test ne '/') then CDP_dir = CDP_dir + '/'
control.dircal = CDP_dir
;_______________________________________________________________________
; create wave_play structure

wave_play = {cvwavei}
wave_play.stopflag = 0
wave_play.delay = 1.1

coadd = {cvaddi}
coadd.select_ranges = 0


centroid = {cvcentroidi}
centroid.rebin_factor = 1
centroid.xoffset_surface = 50 
centroid.yoffset_surface = 50
centroid.uoffset_surface = 0
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

color6                 
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
; default values in case the preferences file could not be found
;********
calibration = {calibration_datai}

;_______________________________________________________________________
; Set up size of windows
w = get_screen_size()
x_max = w[0] * .95
y_max = w[1] * .88
if(x_max gt 1400) then x_max = 1400
if(y_max gt 1024) then y_max = 1024
control.max_x_screen = x_max + (x_max*.1) 
control.max_y_screen = y_max + (y_max*.1) 

control.max_x_window = x_max - (x_max*.3)
control.max_y_window = y_max*.3

xsize_scroll =x_max
ysize_scroll =y_max

;print,' max x and y screen', x_max, y_max, w[0],w[1]
;_______________________________________________________________________


; create and initialize "cube" structure
cube = {cubei}
cube.istart_wavelength = 0
cube.testmodel = -1


; create and initialize "slope" structure
slope = {slope_datai}
slope.subarray = 0

; create and initialize "slopeimage" structure
image = {slopeimagei}

; create and initialize "cube" structure
view_cube = {view_cubei}
view_cube.zoom = 1
view_cube.zoom_user = 1
view_cube.plot_pixel = 0
view_cube.detector_coordinates = 0
view_cube.read_d2c = 0
view_cube.read_slope_image  = 0
view_cube.plot_slope_image  = 0

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


adjust_roi= {cvadjustroii}

spectrum = {spectrumi}

view_spectrum = {view_spectrumi}
view_spectrum.default_range[*] = 1
;_______________________________________________________________________

; call setup cube before read miri preferences because it has to read in
; cube - testmodel - to figure out which preferences file to use
; 
;
; setup_cube - pops up the window to select the cube to read in
setup_cube,control,view_cube,cube,spectrum,roi,status
if(status eq 2) then begin
    return
    ;retall
    ;exit
endif
;while (status ne 0) do setup_cube,control,view_cube,cube,spectrum,roi,status

;_______________________________________________________________________

version = "(v 9.4.4 Oct 11, 2017)"
if(cube.TestModel eq 0) then begin
    Print,' VM option in CV is no longer possible, you can view/analyze data but use FM preferences file'
    stop
 endif
control.pref_filename=miri_dir+'Preferences/'+'MIRI_MRS_DHAS_v9.4.FM_preferences'

if(cube.TestModel eq 2) then begin
    control.pref_filename=miri_dir+'Preferences/'+'MIRI_MRS_DHAS_v8.3.ZM_preferences'
endif



if(N_elements(prefnamein)) then begin
    control.pref_filename =prefnamein
    control.pref_filename = strcompress(control.pref_filename,/remove_all)
endif
print,'  Preferences file ',control.pref_filename

; data read in from preferences file
Pdir = ' ' & Pdirps = ' ' 

Pcalibration_version = strarr(2)
Pscale = 0 & Pxdisplay_size = 0 & Pydisplay_size = 0


status = 0
cv_read_preferences,control.pref_filename,$
                    control.miri_dir,$
                    Pdirred,PdirCube,Pdirps,$
                    Pcalibration_version, status

print,' Done reading preferences file'
if(status eq 0) then begin
    control.dirred = Pdirred
    control.dirps = Pdirps
;    control.dircube = PdirCube  - this is HARDCODED to be the current directory
                                ; this is because setup_cube is read in first to read in cube
                                ; and figure out TestModel - if data is VM or FM. 

    control.calibration_version = Pcalibration_version
endif

;_______________________________________________________________________
xspectrum = spectrum.wavelength_range[1] - spectrum.wavelength_range[0] +1
yspectrum = spectrum.flux_range[1] - spectrum.flux_range[0] +1

xzoom = (view_cube.plot_xsize*1.0)/xspectrum 
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
    if( xspectrum*newzoom  le control.max_x_window )then begin 
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


xwidget_size = control.max_x_screen
ywidget_size = control.max_y_screen


;print,' size of window,',xwidget_size,ywidget_size,xsize_scroll,ysize_scroll 
;_______________________________________________________________________
CubeView = widget_base(title="MIRI CubeView " + version,$
                       /column,mbar = menuBar,/scroll,$
                       /TLB_SIZE_EVENTS, xsize = xwidget_size,ysize=ywidget_size,$
                       x_scroll_size = xsize_scroll,y_scroll_size = ysize_scroll)
;_______________________________________________________________________
; values set by the program
titlelabel = '      '

;*_______________________________________________________________________

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

; load science data to overplot

; zoom 
zoom1 = widget_button(zoommenu,value = ' No Zoom ' ,/checked_menu)
zoom2 = widget_button(zoommenu,value = ' 2 X Zoom ',/checked_menu)
zoom4 = widget_button(zoommenu,value = ' 4 X Zoom ',/checked_menu)
zoom8 = widget_button(zoommenu,value = ' 8 X Zoom ',/checked_menu)
zoom16 = widget_button(zoommenu,value = ' 16 X Zoom ',/checked_menu)

; change the color
colorbutton = widget_button(colormenu,value='Change Color',event_pro='cv_color',font=fontname2)

PrintButtonI  = Widget_Button(PrintMenu, Value='Print Image')
PrintButtonD  = Widget_Button(PrintMenu, Value='Print Spectra to File')
PrintButtonP  = Widget_Button(PrintMenu, Value='Print Spectrum to Plot')
; various options
optionsbutton1 = widget_button(optionsmenu,value='Provide Detector X & Y Pixel value',$
font=fontname2,/checked_menu)

optionsbutton1b = widget_button(optionsmenu,value='Provide Details of Detector X & Y Pixel value',$
font=fontname2,/checked_menu)

optionsbutton2 = widget_button(optionsmenu,value='Turn Off Plotting Box around Pixel',font=fontname2)


roi_image = 0
image_collapse = 0
; quit button
quitbutton = widget_button(quitmenu,value="Quit",event_pro='cv_quit')

;***********************************************************************
graphID_master0 = widget_base(CubeView,row=1)
graphID_master1 = widget_base(CubeView,row=1)
graphID_master2 = widget_base(CubeView,row=1)
graphID_master3 = widget_base(CubeView,row=1)
graphID_master4 = widget_base(CubeView,row=1)
graphID_master5 = widget_base(CubeView,row=1)

graphID0 = widget_base(graphID_master0,row= 1)
graphID1 = widget_base(graphID_master1,row= 1)
graphID2 = widget_base(graphID_master2,row= 1)

graphID2a = widget_base(graphID2,col=1)
graphID2b = widget_base(graphID2,col=1)

graphID3 = widget_base(graphID_master3,row= 1)

graphID4 = widget_base(graphID_master4,row= 1)

graphID5 = widget_base(graphID_master5,col= 1)

cube_box = widget_base(graphID0,/row,/frame)
cube_info_box = widget_base(cube_box,row=1)

Cube_name = 'Cube ' + control.file_cube_base 
graph_labelID = widget_label(cube_info_box,value = cube_name,/align_left,$
                             font = fontname5,/dynamic_resize)

;-----------------------------------------------------------------------
select_roi = 0
roi_box = widget_base(graphID1,/row)
adjust_box = widget_base(graphID1,/row)
full_box = widget_base(graphID1,/row)
image_box = widget_base(graphID1,/row)

roiID = widget_label(roi_box,value = ' Select Region of Interest',$
                     font = fontname5,/dynamic_resize)
obase = Widget_base(roi_box,/row,/nonexclusive)
roi_button1 = Widget_button(oBase, Value = ' Yes ')
widget_control,roi_button1,Set_Button = 0

roi_button2 = Widget_Button(oBase, Value = ' No ')
widget_control,roi_button2,Set_Button = 1

roi_adjust_button = Widget_button(adjust_box, Value = ' Adjust ROI')

full_cube_button = widget_button(full_box, value = ' View Full Cube',font = fontname5,/dynamic_resize)
image2display = widget_label(full_box, value = '   Image Displayed',font = fontname5)

ImageType = 0
ImageDisplayed=['Wavelength Slice','Co-added, Select Wavelength', 'Coadded, All Wavelengths']
ImageDID = widget_combobox(full_box,value = ImageDisplayed, font = fontname5)

do_centroid = 0
CentroidID = widget_button(full_box,value = ' Centroid ',font=fontname5)
CentroidParamID = widget_button(full_box,value = ' Centroid Parameters',font=fontname5)
InfoCentroidID = widget_button(full_box,value =  'Info')

;-----------------------------------------------------------------------

plotID = widget_draw(graphID2a,xsize =view_cube.plot_xsize,$
                     ysize=view_cube.plot_ysize,$
                     retain= retn,/motion_events, /button_events,$
                     event_pro='cube_pixel')

lock_wavelength = 0
lock_box = widget_base(graphid2b,/row)
lockID = widget_label(lock_box,value='Lock Wavelength Plane',/align_left)

obase = Widget_base(lock_box,/row,/nonexclusive)
lock_button1 = Widget_button(oBase, Value = ' Yes ')
widget_control,lock_button1,Set_Button = 0

lock_button2 = Widget_Button(oBase, Value = ' No ')
widget_control,lock_button2,Set_Button = 1
InfoLockID = widget_button(lock_box,value =  'Info')
    
cenID = lonarr(7)
cenID[0] = widget_label(graphid2b,value = '',/dynamic_resize,/align_left)
cenID[1] = widget_label(graphid2b,value = '',/dynamic_resize,/align_left)
cenID[2] = widget_label(graphid2b,value = '',/dynamic_resize,/align_left)
cenID[3] = widget_label(graphid2b,value = '',/dynamic_resize,/align_left)
cenID[4] = widget_label(graphid2b,value = '',/dynamic_resize,/align_left)
cenID[5] = widget_label(graphid2b,value = '',/dynamic_resize,/align_left)
cenID[6] = widget_label(graphid2b,value = '',/dynamic_resize,/align_left)


coords_of_cube = '                               '
pix_box = widget_base(graphID3,/row)
pixel_labelID = widget_label(pix_box,value = coords_of_cube,/align_left,$
                             font = fontname3,/dynamic_resize)

; min and max scale of  image
scale_base = widget_base(graphID4,row = 1)
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

    

;_______________________________________________________________________
x1 = (*roi).roix1
y1 = (*roi).roiy1
x2 = (*roi).roix2
y2 = (*roi).roiy2

iwavelength = view_cube.this_iwavelength - cube.istart_wavelength 
cv_box_stat,x1,x2,y1,y2,iwavelength,cube,box_stat


swlength = strcompress(string((*cube.pwavelength)[iwavelength]),/remove_all)

info_box1 = box_stat[0] + box_stat[1] + box_stat[2] + box_stat[3] 
info_box2 = box_stat[4] + box_stat[5]

box_info = widget_base(graphID4,/col,/frame) 
label2d = lonarr(5)
stat_label = widget_label(box_info,value = ' 2-D Image Statistics at Wavelength: ' + swlength,$
                          /align_left,font = fontname5,/dynamic_resize)
label2d[0] =  widget_label(box_info,value = info_box1,/align_left,/dynamic_resize,font=fontname5)
label2d[1] =  widget_label(box_info,value = info_box2,/align_left,/dynamic_resize,font=fontname5)

;_______________________________________________________________________
; Extracted Spectrum
stitle = "Extracted Spectrum "

smean = 0.0
sstdev = 0.0
smin = 0.0
smax = 0.0

range_min = 0.0
range_max = 0.0

base_line = widget_base(graphID5,/row)
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

specDraw = Widget_Draw(graphID5, XSize = view_spectrum.plot_xsize, YSize = view_spectrum.plot_ysize, $
                       /Button_Events, Retain=2,$
                       /motion_events,event_pro = 'cv_draw_line')


info_wave ='                                                                                                   '

info_box = widget_base(graphID5,/row)
info_spectrum_labelID = widget_label(info_box,value = info_wave,/align_left,$
                                     font = fontname5,/dynamic_resize)
green_base = widget_base(graphID5,/row)
green_lineID1 = widget_label(info_box, value = '(Green Line: Current Wavelength Plane in Cube View)',$
                             font = fontname3,/dynamic_resize)

range = fltarr(2,2)
range_base = widget_base(graphID5,row = 1)
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

image2d = {image2di}

;********b
cinfo = {version                : version,$
         titlelabel             : titlelabel,$
         control                : control,$
         calibration            : calibration,$
         view_cube              : view_cube,$
         cube                   : cube,$
         slope                  : slope,$
         image                  : image,$
         roi                    : roi,$
         wave_play              : wave_play,$
         coadd                  : coadd,$
         spectrum               : spectrum,$
         centroid               : centroid,$
         view_spectrum          : view_spectrum,$
         view_image2d           : view_image2d,$
         image2d                : image2d,$
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
         pixel_labelID          : pixel_labelID,$
         graph_labelID          : graph_labelID,$
         cenID                  : cenID,$
         wavelengthID           : 0L,$
         LoadCubeButton         : LoadCubeButton,$
         ViewHeaderButton       : ViewHeaderButton,$
         OptionsButton1         : OptionsButton1,$
         OptionsButton1b        : OptionsButton1b,$
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

XManager,'cv',CubeView,/No_Block,cleanup='cv_cleanup',$
         event_handler="cv_event"


cv_header_setup,0,cinfo
cv_update_cube,cinfo
cv_update_spectrum,cinfo
cv_draw_current_wavelength,cinfo


Widget_Control,cinfo.CubeView,Set_UValue=cinfo
Widget_Control,cinfo.CubeView,Set_UValue=cinfo

end

