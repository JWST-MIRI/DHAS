;+
; NAME:
;      Miri_Quicklook for JWST pipeline 
;
; PURPOSE:
;      Tool to visualize the MIRI raw ramp images
;      and the processing of these ramps into slopes
;
; EXPLANATION:
;      GUI (IDL Widget) which allows the user to interactively 
;      examine the MIRI raw ramp images and to view what the
;      MIRI DHAS (mips_sloper) did to convert  charge ramps into
;      slopes.  Various diagnoistics are also displayed to enable
;      users to diagnoise problems in the processing.
;
; CALLING SEQUENCE:
;      Interactive: jwst_ql
;
; INPUTS:
;      1. All the default information is held in a preferences file:
;         JWST_MIRI_QL_v#.#.preferences. The location of this file is specified
;         by the environmental varible: MIRI_DIR
;      2. The MIRI DHAS JWST quicklook program can be used to view
;      science data. The user selects the file raw level 1 data to
;      open. The program checks if any intermediate output from the 
;      step processing also exists, if it does it reads it in.
; OUTPUTS:
;      There are options to print certain graphs to a postscript or
;      encapsulated postscript file.  
;
; EXAMPLE:
;       IDL> jwst_ql
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
;       v1  - written by Jane Morrison 
;       A list of changes written to the DHAS Web site 
;       
;

;@jwst_code.pro ; listing of all code pieces


pro jwst_ql,help=help

@jwst_ql_structs ; holds all data structures

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

;_______________________________________________________________________
; Print the help file
if keyword_set(help) then begin
        jwst_ql_help
	return
endif
device,decomposed = 0 ; set this from the start
device,pseudo = 8

; create  "jwst_control " structure
jwst_control = {jwst_controli}

;_______________________________________________________________________

;edit_uwindowsize = 0 ; paramters for editing preferences file
;edit_xwindowsize = 0 ; no structure exists for this widget
;edit_ywindowsize = 0

;_______________________________________________________________________
version = "(v 1.0 Feb 11, 2019)"

miri_dir = getenv('MIRI_DIR')
len = strlen(miri_dir) 
test = strmid(miri_dir,len-1,len-1)
if(test ne '/') then miri_dir = miri_dir + '/'
jwst_control.miri_dir = miri_dir

jwst_control.pref_filename = miri_dir + 'Preferences/JWST_MIRI_QL_v1.0.preferences'

print,'  Preferences file ',jwst_control.pref_filename

;_______________________________________________________________________
; work out the fontname
; on command line you can find the fontnames by typing

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


xsize_label = 8
plotsizeA = 200
plotsize1 = 256
plotsize1b = 258
plotsize2 = 512
plotsize3 = 350
plotsize4 = 450
plotsize_fullx = 1032
plotsize_fully = 1028
binfactor = 4
view_header_lines = 60
microsec2sec = 1000000.0

;********
; setup the color table
;********

!EXCEPT = 2
col_table = 0
loadct,col_table,/silent
col_max =  min([!d.n_colors, 255])
bw_col_table =0  

color6
black = 0
white = 1
red = 2
green =3
blue = 4
yellow = 5

col_bits = 6
; set value of retain for graphics
 retn=2
;___________________________________________________________________
window,1,/pixmap
wdelete,1
;*********
;Setup main panel
;*********

xql_size = 600
yql_size = 300

JWST_QuickLook = widget_base(title="JWST MIRI Quick Look " + version,$
                        col = 1,mbar = menuBar,xsize=850,ysize=600,$
                        /scroll,x_scroll_size = xql_size,y_scroll_size = yql_size,$
                       /TLB_SIZE_EVENTS)
;_______________________________________________________________________
; default values in case the preferences file could not be found
;********
; initialize varibles
jwst_control.filename_raw = ' ' 
jwst_control.frame_start = 0
jwst_control.int_num = 0

jwst_control.dir = ' '
jwst_control.dirout = ' '
jwst_control.read_limit = 20
; data read in from preferences file

Pdir = ' ' & Pdirps = ' '  & Pdirout = ' ' 
Pint_num = 0 & Pframe_num =0 & Pread_limit = 0
status = 0

jwst_read_preference_keys,jwst_control.pref_filename,$
                          jwst_control.miri_dir,$
                          Pdir,Pdirout,Pdirps,$
                          Pint_num,Pframe_num,Pread_limit,$
                          status

if(status ne 0) then begin
    print,' Problem reading preferences file'
    stop
endif

print,' Done reading preferences file'
if(status eq 0) then begin
; the program figures the largest window size 
    w = get_screen_size()
    xmax = w[0]* 0.95
    ymax = w[1]* 0.89
    if(xmax gt 1600) then xmax = 1600
    if(ymax gt 1600 ) then ymax = 1600
    jwst_control.x_scroll_window = xmax
    jwst_control.y_scroll_window = ymax
    
    print,'Max allowed Window size',jwst_control.x_scroll_window,jwst_control.y_scroll_window

    jwst_control.int_num = Pint_num-1      ; read from preference file - user starts at 1
    jwst_control.frame_start = Pframe_num-1  ; read from preference file - user starts at 1
    jwst_control.read_limit = Pread_limit
    jwst_control.frame_start_save = jwst_control.frame_start
    jwst_control.int_num_save = jwst_control.int_num
    jwst_control.read_limit_save = jwst_control.read_limit
    jwst_control.dir = Pdir
    jwst_control.dirout = Pdirout
    jwst_control.dirps = Pdirps
 endif
;_______________________________________________________________________
; Size of Windows.
if(jwst_control.x_scroll_window eq 0) then jwst_control.x_scroll_window = 680
if(jwst_control.y_scroll_window eq 0) then jwst_control.y_scroll_window = 680
;_______________________________________________________________________
; values set by the program
titlelabel = '      '
;*_______________________________________________________________________

;********
; build the menubar
;********
AnalyzeMenu = widget_button(menuBar,value="Display Data",/Menu,font=fontname2)
compareMenu = widget_button(menuBar,value="Compare Data ",/Menu,font=fontname2)
EditMenu = widget_button(menuBar,value="Color",font=fontname2)
QuitMenu = widget_button(menuBar,value="Quit",font = fontname2)

; Analyze
loadimageButton = widget_button(AnalyzeMenu,value=" Display Science Frames and Rates",$
                                uvalue='JWST_LoadI',font=fontname3)

loadimageButton = widget_button(AnalyzeMenu,value=" Display Rate and Rate Int Images",$
                                uvalue='JWST_LoadS',font=fontname3)


loadimageButton = widget_button(AnalyzeMenu,value=" Display Rate and Cal Images",$
                                uvalue='JWST_LoadC',font=fontname3)
; compare
loadcompareR2Button = widget_button(CompareMenu,value=" Compare Two Science Frames or Two Rate Images",$
                            font=fontname3,uvalue='JWST_Load2')

; Edits 
colorbutton = widget_button(editmenu,value='Change Image Color',event_pro='jwst_ql_color',font=fontname3)
;Set up the GUI

; add quit button
quitbutton = widget_button(quitmenu,value="Quit",event_pro='jwst_ql_quit')

;***********************************************************************
blankline = widget_label(JWST_Quicklook,value=' ')
longline = '                                                                                                                        '
longtag = widget_label(JWST_Quicklook,value = longline)
titletag = widget_label(JWST_Quicklook,$
                            value='      JWST MIRI DHAS Commissioning Tool' ,$
                            /align_left,font=fontlarge)

authortag = widget_label(JWST_Quicklook,$
                            value='      View JWST Pipeline products' ,$
                            /align_left,font=fontmedium)

emailtag = widget_label(JWST_Quicklook,$
                            value='       morrison@as.arizona.edu' ,$
                            /align_left,font=fontmedium)

blankline = widget_label(JWST_Quicklook,value=' ')


blankline = '                                                                                                 '
filetag = strarr(2)
typetag = " "
line_tag  = strarr(8)
filetag[0] = widget_label(JWST_Quicklook,value= blankline, /align_left,font=font5)
filetag[1] = widget_label(JWST_Quicklook,value= blankline,/align_left,font=font5)
typetag = widget_label(JWST_Quicklook,value=blankline,/align_left,font=font5)
for i = 0,7 do begin 
    line_tag[i]  = widget_label(JWST_Quicklook,value=blankline,  /align_left,font=font5)
endfor

longline = '                                                                                                                        '
longtag = widget_label(JWST_Quicklook,value = longline)

Widget_control,jwst_QuickLook,/Realize
;********
; create and initialize "slope " structure
jwst_slope = {jwst_slopei}
;jwst_slope.id_flags = [ 1,2,4,8,16,32]

; create and initialize "data" structure
jwst_data = {jwst_datai}

jwst_data.read_all = 1
;jwst_data.ref_exist = 1
;jwst_data.slope_stat[*,*] = 0

loadfile = {jwst_generic_windowi} 

; create and initialize "output file name" structure
output = {jwst_outputi}
output.inspect_rawimage = '_science_image'
output.inspect_slope = '_reduced_'
output.inspect_slope2 = '_reduced_'
output.rawimage      = '_science_image'
output.zoomimage      = '_zoom_image'
output.slopeimage      = '_reduced_image'
output.frame_pixel      = '_frame_pixel'
output.slope_win1      = '_reduced'
output.slope_zoomimage      = '_reduced_zoom_image'
output.slope_win2      = '_reduced'
output.slope_frame_pixel      = '_frame_pixel'
output.slope_slope_pixel     = '_reduced_pixel'


jwst_dqflag = {jwst_dqi} ; data quality flag
jwst_dqflag .Donotuse = 1
jwst_dqflag .Sdonotuse = 'Do Not Use'
jwst_dqflag.Saturated = 2
jwst_dqflag.SSaturated = 'Saturated'
jwst_dqflag.Jump = 4
jwst_dqflag.SJump = 'Jump Det'
jwst_dqflag.Dropout = 8
jwst_dqflag.SDropout = 'Drop Out'
jwst_dqflag.UnrelError = 256
jwst_dqflag.SUnrelError = 'Unrelialbe Error'
jwst_dqflag.Nonscience = 512
jwst_dqflag.SNonscience = 'Non Science'
jwst_dqflag.Dead = 1024 
jwst_dqflag.SDead = 'Dead'
jwst_dqflag.Hot = 2048
jwst_dqflag.SHot = 'Hot' 
jwst_dqflag.Warm =4096  
jwst_dqflag.SWarm = 'Warm'  
jwst_dqflag.RC = 16384
jwst_dqflag.SRC = 'RC'  
jwst_dqflag.nonlinear = 65536

jwst_dqflag.Snonlinear = 'Nonlinear'
jwst_dqflag.bad_refpixel= 131072
jwst_dqflag.sbad_refpixel= 'Bad ref pixel'
jwst_dqflag.no_flatfield=262144
jwst_dqflag.sno_flatfield='No flat field'
jwst_dqflag.no_gain=-524288
jwst_dqflag.sno_gain='No gain value'
jwst_dqflag.unrel_dark  = 8399608
jwst_dqflag.Sunrel_dark = 'Unreliable dark'
jwst_dqflag.unrel_slope  = 16777216
jwst_dqflag.Sunrel_slope = 'Unreliable slope'
jwst_dqflag.unrel_flat = 33554432
jwst_dqflag.Sunrel_flat = 'Unreliable flat'
jwst_dqflag.unrel_reset = 268435456
jwst_dqflag.Sunrel_reset = 'Unreliable reset'
jwst_dqflag.ref_pixel= 2147483648
jwst_dqflag.Sref_pixel='Reference Pixel'


jwst_image = {jwst_imagei}

jwst_image_pixel = {jwst_image_pixeli}

; create and initialize inspect structure - slope  image 
jwst_inspect_slope = {jwst_inspecti}

; create and initialize inspect structure - raw image 
jwst_inspect = {jwst_inspecti}

; create and initialize inspect structure - 3rd window slope  display  
jwst_inspect_slope2 = {jwst_inspecti}

; create and initialize inspect structure - slope  final image 
jwst_inspect_final = {jwst_inspecti}

; widget to load 2 files
jwst_compare_load = {jwst_generic_windowi}
jwst_compare_load.uwindowsize = 0

;; create and initialize "compare" structure - holds comparision
;;                                             widget for frames
jwst_compare = {jwst_comparei}
jwst_compare.uwindowsize = 0 
jwst_cinspect = replicate(jwst_inspect,3) ; inspect comparison raw science frames

; compare 2 images:
jwst_compare_image = replicate(jwst_single_image,3)

;; create and initialize "compare" structure - holds comparision
;;                                             widget for rate
jwst_rcompare = {jwst_comparei}
jwst_rcompare.uwindowsize = 0 

; compare 2 reduced images:
jwst_rcompare_image = replicate(jwst_single_image,3)
jwst_crinspect = replicate(jwst_inspect,3) ; inspect comparison reduced data

; defaults to start with 


jwst_viewhead = 0
display_widget = 1 ; default to display Science Frame and Slope Image
;********
jinfo = {jwst_version        : version,$
         titlelabel          : titlelabel,$
         display_widget      : display_widget,$
         microsec2sec        : microsec2sec,$
         col_max             : col_max,$
         col_table           : col_table,$
         bw_col_table        : bw_col_table,$
         col_bits            : col_bits,$
         black               : black,$
         white               : white,$
         red                 : red,$
         blue                : blue,$
         green               : green,$
         yellow              : yellow,$
         font1               : fontname1,$
         font2               : fontname2,$
         font3               : fontname3,$
         font4               : fontname4,$
         font5               : fontname5,$
         font6               : fontname6,$
         fontsmall           : fontsmall,$
         jwst_plotsizeA           : plotsizeA,$
         jwst_plotsize1           : plotsize1,$
         jwst_plotsize2           : plotsize2,$
         jwst_plotsize1b          : plotsize1b,$
         jwst_plotsize3           : plotsize3,$
         jwst_plotsize4           : plotsize4,$
;         jwst_plotsize_fullX      : plotsize_fullX,$
;         jwst_plotsize_fullY      : plotsize_fullY,$
         viewhdrysize        : view_header_lines,$
;         edit_uwindowsize    : edit_uwindowsize,$
;         edit_xwindowsize    : edit_xwindowsize,$
;         edit_ywindowsize    : edit_ywindowsize,$
         binfactor           : binfactor,$
         xsize_label         : xsize_label,$
         retn                : retn,$
         jwst_filetag        : filetag,$
         jwst_typetag        : typetag,$
         jwst_line_tag       : line_tag,$
         JWST_QuickLook      : JWST_QuickLook,$
         jwst_data           : jwst_data,$
         jwst_control        : jwst_control,$
         jwst_dqflag         : jwst_dqflag,$
         output              : output,$
         jwst_viewhead       : ptr_new(jwst_viewhead),$
         jwst_image          : jwst_image,$
         jwst_slope          : jwst_slope,$
         jwst_inspect        : jwst_inspect,$
         jwst_inspect_slope  : jwst_inspect_slope,$
         jwst_inspect_slope2      : jwst_inspect_slope2,$
         jwst_inspect_final       : jwst_inspect_final,$
         jwst_image_pixel    : jwst_image_pixel,$
         jwst_rcompare       : jwst_rcompare,$
         jwst_rcompare_image : jwst_rcompare_image,$
         jwst_compare        : jwst_compare,$
         jwst_compare_image  : jwst_compare_image,$
         jwst_compare_load   : jwst_compare_load,$
         jwst_cinspect       : jwst_cinspect,$
         jwst_crinspect      : jwst_crinspect,$
         loadfile            : loadfile,$
         jwst_RawQuickLook   : 0L,$
 ;       SubarrayGeo         : 0L,$
         jwst_SlopeQuickLook      : 0L,$
         jwst_RPixelInfo          : 0L,$
         jwst_StatInfo            : 0L,$
         jwst_Slope_StatInfo      : 0L,$
         jwst_rcomparedisplay     : 0L,$
         jwst_comparedisplay      : 0L,$
         jwst_load2display        : 0L,$
         jwst_InspectImage        : 0L,$
         jwst_InspectSlope        : 0L,$
         jwst_InspectSlope2       : 0L,$
         jwst_InspectSlopeFinal   : 0L,$
         jwst_CInspectImage       : lonarr(3),$
         jwst_CRInspectImage      : lonarr(3),$
         LoadFileInfo             : 0L}


Widget_Control,JWST_QuickLook,Set_UValue=jinfo


XManager,'jwst_ql',JWST_QuickLook,/No_Block,cleanup='jwst_ql_cleanup',$
	event_handler="jwst_ql_event"



end

