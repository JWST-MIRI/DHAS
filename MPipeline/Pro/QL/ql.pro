;+
; NAME:
;      Miri_Quicklook
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
;      1. interactive: ql
;      2. command line driven:
;          ql,dirin=dirinput,dirout=diroutput,$
;              dirps = dirpsin
; 
;
;
; INPUTS:
;      1. All the default information is held in a preferences file:
;         MIRI_DHAS_v#.#.preferences. The location of this file is specified
;         by the environmental varible: MIRI_DIR
;      2. The quicklook program can be used to view science data or
;      telemetry data. In the interactive mode the user selects the
;      file to openned


; OUTPUTS:
;      There are options to print certain graphs to a postscript or
;      encapsulated postscript file.  
;
; EXAMPLE:
;       IDL> ql
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
;       v1 & v2 - written by Jane Morrison 
;       A list of changes written to the DHAS Web site 
;       

;-

@code.pro ; listing of all code pieces

pro ql,dirin=dirinput,dirout=diroutput,$
       dirps = dirpsin,dirtel = dirtelin,$
       FM = FM, VM = VM, JPL=JPL, $ 
       help=help,$
       prefname = prefnamein

@ql_structs ; holds all data structures

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
   ql_help
   return
endif
device,decomposed = 0 ; set this from the start
device,pseudo = 8

; create  "control " structure
control = {controli}

; scripting - go off and do things - not interactive mode
script = {scripti}
script.go = 0
;_______________________________________________________________________

; create and initialize edit miri_sloper parameters structure
ms = {ems}

ms.badpixel = 0
ms.uwindowsize = 0

; create and initialize edit miri_caler parameters structure
mc = {emc}
mc.dark = 0
mc.uwindowsize = 0

edit_uwindowsize = 0 ; paramters for editing preferences file
edit_xwindowsize = 0 ; no structure exists for this widget
edit_ywindowsize = 0

;_______________________________________________________________________

version = "(v 9.8.2 Jan 6, 2021)"

miri_dir = getenv('MIRI_DIR')
len = strlen(miri_dir) 
test = strmid(miri_dir,len-1,len-1)
if(test ne '/') then miri_dir = miri_dir + '/'
control.miri_dir = miri_dir

control.pref_filename = miri_dir + 'Preferences/MIRI_DHAS_v9.8.preferences'

control.user_pref_file = 0
if(N_elements(prefnamein)) then begin
    control.pref_filename =prefnamein
    control.pref_filename = strcompress(control.pref_filename,/remove_all)
    control.user_pref_file = 1
endif
print,'  Preferences file ',control.pref_filename

control.dircal = ' '
cdp_dir = getenv('CDP_DIR')
len = strlen(cdp_dir) 
test = strmid(cdp_dir,len-1,len-1)
if(test ne '/') then cdp_dir = cdp_dir + '/'
control.dircal = cdp_dir

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

QuickLook = widget_base(title="MIRI Quick Look " + version,$
                        col = 1,mbar = menuBar,xsize=850,ysize=600,$
                        /scroll,x_scroll_size = xql_size,y_scroll_size = yql_size,$
                       /TLB_SIZE_EVENTS)
;_______________________________________________________________________
; default values in case the preferences file could not be found
;********
; initialize varibles
control.added_dir = 0
control.wait = 0

control.print = 0
control.set_scidata = 0
control.added_dir = 0
control.filename_raw = ' ' 
control.frame_start = 0
control.int_num = 0

control.dir = ' '
control.dirout = ' '
control.dirtel = ' '
control.tracking_file = ' ' 
control.read_limit = 20

control.start_fit = 0
control.end_fit = 0
control.delta_row_even_odd = 0
control.apply_bad = 1

; data read in from preferences file

Pdir = ' ' & Pdirps = ' ' & Pdircal = ' ' & Pdirout = ' ' 
Pcdp_im = ' ' & Pcdp_lw = ' ' & Pcdp_sw = ' ' & Pcdp_jpl = ' ' 

Pdirtel = ' ' 
PHighDN = 0
Pscale = 0 & Pxdisplay_size = 0 & Pydisplay_size = 0
Pint_num = 0 & Pframe_num =0 & Pread_limit = 0
Pframe_limit = 0 & Psubset_size = 0 & Pgain = 0 & PFrametime = 0
Ptracking_file = ' '  
status = 0
Pdisplay_apply_bad = 0 
Papply_bad = 0 & Papply_reset = 0 & Papply_lastframe = 0 & Papply_dark = 0 & Papply_lin=0
Pstart_fit = 0 & Pend_fit = 0 & Pdelta_row_even_odd = 0
Papply_rscd = 0 & Prefpixel_option = 0 & Preadnoise = 0.0 & PUncertaintyMethod = 0
Papply_pixel_sat = 0

read_preference_keys,control.pref_filename,$
                     control.miri_dir,$
                     Pdir,Pdirout,$
                     Pdirtel,Pdirps,Pint_num,Pframe_num,Pread_limit,$
                     Pframe_limit, Psubset_size,$
                     Ptracking_file,Pstart_fit, Pend_fit, $
                     PHighDN,$
                     Papply_rscd,Prefpixel_option,Pdelta_row_even_odd,$
                     Pgain,Pframetime,Pdisplay_apply_bad,Preadnoise,PUncertaintyMethod,$
                     Pcdp_im,Pcdp_lw,Pcdp_sw,Pcdp_jpl,Papply_bad,Papply_lastframe,$
                     Papply_dark,Papply_lin,Papply_pixel_sat,status


print, Pdirout

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
    control.x_scroll_window = xmax
    control.y_scroll_window = ymax
    
    print,'Max allowed Window size',control.x_scroll_window,control.y_scroll_window

    control.int_num = Pint_num-1      ; read from preference file - user starts at 1
    control.frame_start = Pframe_num-1  ; read from preference file - user starts at 1

    control.frame_start_save = control.frame_start

    control.int_num_save = control.int_num
    control.read_limit = Pread_limit
    control.read_limit_save = control.read_limit
    control.frame_end = control.frame_start + control.read_limit -1

    control.dir = Pdir
    control.dirout = Pdirout
    control.dirtel = Pdirtel
    control.dirps = Pdirps
    control.frame_limit = Pframe_limit
    control.subset_size = Psubset_size
    control.tracking_file = Ptracking_file
    control.start_fit = Pstart_fit
    control.end_fit = Pend_fit
    control.delta_row_even_odd   = Pdelta_row_even_odd
    control.apply_rscd = Papply_rscd
    control.apply_pixel_sat = Papply_pixel_sat
    control.refpixel_option = Prefpixel_option
    control.highDN = PhighDN
    control.gain = Pgain
    control.frametime = Pframetime
    control.readnoise = Preadnoise
    control.UncertaintyMethod  = PUncertaintyMethod 
    control.display_apply_bad = Pdisplay_apply_bad
    control.apply_bad = Papply_bad
    control.apply_reset = 0
    control.apply_lastframe = Papply_lastframe
    control.apply_dark = Papply_dark
    control.apply_lin = Papply_lin
    control.cdp_im = Pcdp_im
    control.cdp_lw = Pcdp_lw
    control.cdp_sw = Pcdp_sw
    control.cdp_jpl = Pcdp_jpl
 endif

get_cdp_badpixel_names,control ; for now only get bad pixels 
;_______________________________________________________________________
; Command line options
;_______________________________________________________________________
; if command line then check that file does not end in / - remove if
;                                                          it does 
if(N_elements(dirinput)) then begin
    if(dirinput ne '') then begin 
        control.dir = dirinput
        control.dir = strcompress(control.dir,/remove_all)
        len = strlen(control.dir) 
        test = strmid(control.dir,len-1,len-1)
        if(test eq '/') then control.dir = strmid(control.dir,0,len-1)
    endif
endif

if(N_elements(diroutput)) then begin
    if(diroutput ne '') then begin 
        control.dirout = diroutput
        control.dirout = strcompress(control.dirout,/remove_all)
        len = strlen(control.dirout) 
        test = strmid(control.dirout,len-1,len-1)
        if(test eq '/') then control.dirout = strmid(control.dirout,0,len-1)
    endif
endif

if(N_elements(dirtelin)) then begin
    control.dirtel = dirtelin
    control.dirtel = strcompress(control.dirtel,/remove_all)
    len = strlen(control.dirtel) 
    test = strmid(control.dirtel,len-1,len-1)
    if(test eq '/') then control.dirtel = strmid(control.dirtel,0,len-1)
endif

if(N_elements(dirpsin)) then begin
    if(dirpsin ne '') then begin 
        control.dirps = dirpsin
        control.dirps = strcompress(control.dirps,/remove_all)
        len = strlen(control.dirps) 
        test = strmid(control.dirps,len-1,len-1)
        if(test eq '/') then control.dirps = strmid(control.dirps,0,len-1)
    endif
endif
;_______________________________________________________________________
; defaults
;_______________________________________________________________________

; Size of Windows.
if(control.x_scroll_window eq 0) then control.x_scroll_window = 680
if(control.y_scroll_window eq 0) then control.y_scroll_window = 680

;_______________________________________________________________________
;if(N_ELEMENTS(sciencedata))then begin
;    control.set_scidata = 1
;    control.filename_raw = sciencedata
;endif


;_______________________________________________________________________
;_______________________________________________________________________
; values set by the program
titlelabel = '      '

;*_______________________________________________________________________

;********
; build the menubar
;********

PixelLookMenu = widget_button(menuBar, value="Pixel Look",font=fontname2)
fileMenu = widget_button(menuBar,value="Telemetry",/Menu,font=fontname2)
AnalyzeMenu = widget_button(menuBar,value="Analyze",/Menu,font=fontname2)
compareMenu = widget_button(menuBar,value="Compare ",/Menu,font=fontname2)
PipeMenu = widget_button(menuBar,value="Pipeline",/Menu,font=fontname2)
EditMenu = widget_button(menuBar,value="Color",font=fontname2)
QuitMenu = widget_button(menuBar,value="Quit",font = fontname2)
;HelpMenu = widget_button(menuBar,value="Help",font = fontname2)

; Pixel Look
pixellookButton = widget_button(PixelLookMenu,value=" Run Pixel Look",$
                                uvalue='RunPL',font=fontname3)
;telemetry menu 

loadTelButton = widget_button(fileMenu,value=" View Telemetry Data- Table 1: Converted Data",$
                                font=fontname3,uvalue='LoadT1')
loadTelButton = widget_button(fileMenu,value=" View Telemetry Data- Table 2: Raw Data",$
                                font=fontname3,uvalue='LoadT2')

; Analyze

loadimageButton = widget_button(AnalyzeMenu,value=" Display Science Frame Images and Slope image",$
                                uvalue='LoadI',font=fontname3)

loadslopeButton = widget_button(AnalyzeMenu,value=" Analyze Slope Data",$
                            font=fontname3,uvalue='LoadS')

; compare
loadcompareR2Button = widget_button(CompareMenu,value=" Compare Two Science Frames or Two Slope Images",$
                            font=fontname3,uvalue='Load2R')

; Run Pipeline


;findQuickDefaultButton = widget_button(PipeMenu,$
;                                value="Quick slope processing",$
;                                uvalue='CalQSlope',font=fontname3)


findSlopeDefaultButton = widget_button(PipeMenu,$
                                value="Default slope processing",$
                                uvalue='CalDSlope',font=fontname3)

findSlopeButton = widget_button(PipeMenu,$
                                value="User selected options for slope processing",$
                                uvalue='CalSlope',font=fontname3)

findCalButton = widget_button(PipeMenu,$
                                value="Run miri_caler,  then display results",$
                                uvalue='CalCal',font=fontname3)


; Edits 


colorbutton = widget_button(editmenu,value='Change Image Color',event_pro='ql_color',font=fontname3)
;Set up the GUI

; add quit button
quitbutton = widget_button(quitmenu,value="Quit",event_pro='ql_quit')
;***********************************************************************

blankline = widget_label(Quicklook,value=' ')
longline = '                                                                                                                        '
longtag = widget_label(Quicklook,value = longline)
titletag = widget_label(Quicklook,$
                            value='      JWST MIRI DHAS Tool' ,$
                            /align_left,font=fontlarge)

authortag = widget_label(Quicklook,$
                            value='      Jane Morrison (520-626-3181)' ,$
                            /align_left,font=fontmedium)

emailtag = widget_label(Quicklook,$
                            value='       morrison@as.arizona.edu' ,$
                            /align_left,font=fontmedium)

blankline = widget_label(Quicklook,value=' ')


blankline = '                                                                                                 '
filetag = strarr(2)
typetag = " "
line_tag  = strarr(8)
filetag[0] = widget_label(Quicklook,value= blankline, /align_left,font=font5)
filetag[1] = widget_label(Quicklook,value= blankline,/align_left,font=font5)
typetag = widget_label(Quicklook,value=blankline,/align_left,font=font5)
for i = 0,7 do begin 
    line_tag[i]  = widget_label(Quicklook,value=blankline,  /align_left,font=font5)
endfor

longline = '                                                                                                                        '
longtag = widget_label(Quicklook,value = longline)

Widget_control,QuickLook,/Realize
;********
; create and initialize "slope " structure
slope = {slopei}
slope.id_flags = [ 1,2,4,8,16,32]

lincor = {lincori}
lincor.uwindowsize = 0

; create and initialize "data" structure
data = {datai}
data.slope_zsize = 7
data.read_all = 1
data.slope_exist = 1
data.ref_exist = 1
data.slope_stat[*,*] = 0

badpixel = {badpixeli}
badpixel.num = 0
badpixel.readin = 0
bad_pixel = fltarr(1032,1024)
 if ptr_valid (badpixel.pmask) then ptr_free,badpixel.pmask
badpixel.pmask = ptr_new(bad_pixel)
bad_pixel = 0 

badpixel_compare = {badpixeli}
badpixel_compare.num = 0
badpixel_compare.readin = 0
; initialize bad pixel mask to 0

loadfile = {generic_windowi} 
channel_histo = {generic_windowi} 
channel_rowslice = {generic_windowi} 
channel_colslice = {generic_windowi} 

channel_Shisto = {generic_windowi} 
channel_Srowslice = {generic_windowi} 
channel_Scolslice = {generic_windowi} 

compare_histo = {generic_windowi} 
scompare_histo = {generic_windowi} 
compare_histo.uwindowsize = 0
scompare_histo.uwindowsize = 0

compare_colslice = {generic_windowi} 
scompare_colslice = {generic_windowi} 
compare_colslice.uwindowsize = 0
scompare_colslice.uwindowsize = 0

compare_rowslice = {generic_windowi} 
scompare_rowslice = {generic_windowi} 
compare_rowslice.uwindowsize = 0
scompare_rowslice.uwindowsize = 0

; pixel tracking information for Pixel look program
pltrack = {pixeltracki}
pltrack.num = 0


; pixel tracking information for Analyze Science images
pixeltrack = {pixeltracki}

; create and initialize "output file name" structure
output = {outputi}
output.historaw =  '_histo'
output.histozoom =  '_histo_zoom'
output.historef =  '_histo_ref'
output.histoslope = '_histo_slope'
;output.histounc = '_histo_uncertainty'
output.colsliceraw =  '_column_slice'
output.colslicezoom =  '_column_slice_zoom'
output.colsliceref =  '_column_slice_ref'
output.colsliceslope =  '_column_slice_slope'
output.colsliceunc =  '_column_slice_uncertainty'
output.rowsliceraw =  '_row_slice'
output.rowslicezoom =  '_row_slice_zoom'
output.rowsliceref =  '_row_slice_ref'
output.rowsliceslope =  '_row_slice_slope'
output.rowsliceunc =  '_row_slice_uncertainty'
output.referenceimage      = '_reference_image'

output.inspect_rawimage = '_science_image'
output.inspect_ref = '_reference_output_image'
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
output.pixellook = '_pixel_plot'

output.firstlook       = '_firstlook'
output.channel       = '_channel'
output.Slopechannel       = '_Reduced_Channel'
output.channel_stat       = '_channel_stat'
output.test_report  = '_test_report'


output.refpixel_time = '_reference_pixels_time_ordered_'
output.timeorder = '_pixels_time_ordered_'
output.Channelhistoraw =  '_histo_'
output.Channelhistoslope =  '_reduced_histo_'
output.Channelcslice =  '_column_slice_'
output.Channelcsliceslope =  '_reduced_column_slice_'

output.Channelrslice =  '_row_slice_'
output.Channelrsliceslope =  '_reduced_row_slice_'

dqflag = {dqi} ; data quality flag
dqflag.Reject_Frame = -1
dqflag.sReject_Frame = 'Reject Frame'
dqflag.Unusable = 1
dqflag.SUnusable = 'Unsable'
dqflag.Saturated = 2
dqflag.SSaturated = 'Saturated'
dqflag.CosmicRay = 4
dqflag.SCosmicRay = 'Cosmic Ray Hit'
dqflag.NoiseSpike = 8
dqflag.SNoiseSpike = 'Noise Spike'
dqflag.NegCosmicRay = 16
dqflag.SNegCosmicRay = 'Cosmic Ray (Negative)'
dqflag.NoReset = 32 
dqflag.SNoReset = 'Unreliable Reset Switch Charge Decay Correction' 
dqflag.NoDark = 64 
dqflag.SNoDark = 'Unreliable Dark Correction' 
dqflag.NoLin =128  
dqflag.SNoLin = 'Unreliable Linearity Correction'  
dqflag.NoLastFrame = 256
dqflag.SNoLastFrame = ' No Last Frame Correction'  
dqflag.Min_Frame_Failure = 512
dqflag.SMin_Frame_Failure = ' Ramp has too few valid frames'
dqflag.CorruptFrame= -2
dqflag.SCorruptFrame= 'Corrupt Frame'
dqflag.Reject_After_Noise=-8
dqflag.SReject_After_Noise='Frame Rejected after Noise Spike'
dqflag.Reject_After_Noise=-8
dqflag.Reject_After_CR  =-4
dqflag.SRefject_After_CR  ='Frame Rejected after Cosmic Ray'
dqflag.CR_Slope_Failure= -16
dqflag.SCR_Slope_Failure= 'Slope Failure on Segment - CR hit' 
dqflag.CR_Seg_Min=-32
dqflag.SCR_Seg_Min= 'Segment does not have min frames - CR hit' 



; create and initialize "pixel look" structure
pl = {pli}
pl.read_setB = 0

; create and initialize "pixel look" structure
pl2 = {pli}
; create reference pixel structure
refpixel ={refpixeli} 

refpixel_data = {refpixel_datai} 
; create and initialize "image" structure
image = {imagei}

image_pixel = {image_pixeli}
image_pixel.hex = 0


channel_pixel = {image_pixeli}
channel_pixel.hex = 0

SlopeChannel_pixel = {image_pixeli}
SlopeChannel_pixel.hex = 0
; create image histogram 
histoR = {single_imagei}
histoZ = {single_imagei}
histoS = {single_imagei}

; create slope histogram 
histoS1 = {single_imagei}
histoS2 = {single_imagei}
histoS3 = {single_imagei}

; create reference output histogram
histoRO = {single_imagei}

; create  image column slice  
colsliceR = {single_imagei}
colsliceZ = {single_imagei}
colsliceS = {single_imagei}

; create  slope column slice  
colsliceSS = {single_imagei}
colsliceSZ = {single_imagei}
colsliceSU = {single_imagei}

; create  reference output column slice  
colsliceRO = {single_imagei}

; create  image row slice  
rowsliceR = {single_imagei}
rowsliceZ = {single_imagei}
rowsliceS = {single_imagei}

; create  image row slice  
rowsliceSS = {single_imagei}
rowsliceSZ = {single_imagei}
rowsliceSU = {single_imagei}

; create  reference output row slice  
rowsliceRO = {single_imagei}

; Reference Pixel Display 
refp = {refpi}
ChannelRP = replicate(qlsingle_image,4)




; 5 Time  channel displays
TimeChannel = {TimeChanneli}
TimeChannel.uwindowsize = 0


; 5 channel display
Channel = {Channeli}

; 5 channel slope display
SlopeChannel = {Channeli}

ChannelR = replicate(qlsingle_image,5)
ChannelS = replicate(qlsingle_image,5)
ChannelT = replicate(qlsingle_image,5)
ChannelTR = replicate(qlsingle_image,5)

; create and initialize "compare" structure
compare = {comparei}
compare.uwindowsize = 0 


compare_load = {generic_windowi}
compare_load.uwindowsize = 0

; compare 2 images:
compare_image = replicate(qlsingle_image,3)

cinspect = replicate(qlinspect,3) ; inspect comparison raw science frames

rcompare = {comparei} ; reduced comparison widget

; compare 2 reduced images:
rcompare_image = replicate(qlsingle_image,3)
 
; defaults to start with 
crinspect = replicate(qlinspect,3) ; inspect comparison reduced data


; create and initialize inspect structure - raw image 
inspect = {inspecti}

; create and initialize inspect structure - ref  image 
inspect_ref = {inspecti}


; create and initialize inspect structure - slope  image 
inspect_slope = {inspecti}

; create and initialize inspect structure - 3rd window slope  display  
inspect_slope2 = {inspecti}


; create and initialize inspect structure - slope  final image 
inspect_final = {inspecti}

; create and initalize the "telemetry " structure
tel_types = ['UNKNOWN','ICE','SPW','MTS','SCE1','SCE2','SCE3']

telemetry = {tele}
telemetry.uwindowsize = 0
telemetry.n_poss_lines = 4
telemetry.type = 0

telemetry_raw = {tele}
telemetry_raw.n_poss_lines = 4
telemetry_raw.uwindowsize = 0
telemetry_raw.type = 0


tplot = {tele}
tplot.uwindowsize = 0
tplot.type = 0

tplot_raw = {tele}
tplot_raw.uwindowsize = 0
tplot_raw.type = 0

viewhead = 0
max_new_telemetry = 100; maximum number of new telemetry types read in (defined here because
                                ; 6 types of telemetry files are read
                                ; in an stored all together - I needed
                                ;                             an upper
                                ;                             limit
display_widget = 1 ; default to display Science Frame and Slope Image
;********
info = {version             : version,$
        titlelabel          : titlelabel,$
        display_widget       : display_widget,$
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
        tel_types           : tel_types,$
        max_new_telemetry   : max_new_telemetry,$
        font1               : fontname1,$
        font2               : fontname2,$
        font3               : fontname3,$
        font4               : fontname4,$
        font5               : fontname5,$
        font6               : fontname6,$
        fontsmall           : fontsmall,$
        plotsizeA           : plotsizeA,$
        plotsize1           : plotsize1,$
        plotsize2           : plotsize2,$
        plotsize1b          : plotsize1b,$
        plotsize3           : plotsize3,$
        plotsize4           : plotsize4,$
        plotsize_fullX      : plotsize_fullX,$
        plotsize_fullY      : plotsize_fullY,$
        viewhdrysize        : view_header_lines,$
        edit_uwindowsize    : edit_uwindowsize,$
        edit_xwindowsize    : edit_xwindowsize,$
        edit_ywindowsize    : edit_ywindowsize,$
        binfactor           : binfactor,$
        xsize_label         : xsize_label,$
        retn                : retn,$
        filetag             : filetag,$
        typetag             : typetag,$
        line_tag            : line_tag,$
        QuickLook           : QuickLook,$
        data                : data,$
        control             : control,$
        dqflag              : dqflag,$
        output              : output,$
        viewhead            : ptr_new(viewhead),$
        badpixel            : badpixel,$
        badpixel_compare    : badpixel_compare,$
        pltrack             : pltrack,$
        pixeltrack          : pixeltrack,$
        pl                  : pl,$
        pl2                 : pl2,$
        refpixel            : refpixel,$ ; used in First Look Tool
        refpixel_data       : refpixel_data,$ ; Used in Quick Look to display reference pixels 
        image               : image,$
        image_pixel         : image_pixel,$
        channel_pixel       : channel_pixel,$
        SlopeChannel_pixel  : SlopeChannel_pixel,$
        histoR              : histoR, $
        histoZ              : histoZ, $
        histoS              : histoS, $
        histoS1             : histoS1, $
        histoS2             : histoS2, $
        histoS3             : histoS3, $
        histoRO             : histoRO, $
        channelR            : channelR, $
        channelRP           : channelRP,$
        channelS            : channelS, $
        channelT            : channelT, $
        channelTR           : channelTR, $
        colsliceR           : colsliceR, $
        colsliceZ           : colsliceZ, $
        colsliceS           : colsliceS, $
        colsliceS1          : colsliceSS, $
        colsliceS2          : colsliceSZ, $
        colsliceS3          : colsliceSU, $
        colsliceRO          : colsliceRO, $
        rowsliceR           : rowsliceR, $
        rowsliceZ           : rowsliceZ, $
        rowsliceS           : rowsliceS, $
        rowsliceS1          : rowsliceSS, $
        rowsliceS2          : rowsliceSZ, $
        rowsliceS3          : rowsliceSU, $
        rowsliceRO          : rowsliceRO, $
        slope               : slope,$
        refp                : refp,$
        telemetry           : telemetry,$
        telemetry_raw       : telemetry_raw,$
        tplot               : tplot,$
        tplot_raw               : tplot_raw,$
        rcompare            : rcompare,$
        rcompare_image      : rcompare_image,$
        compare             : compare,$
        compare_image       : compare_image,$
        compare_load        : compare_load,$
        inspect             : inspect,$
        inspect_ref         : inspect_ref,$
        inspect_slope       : inspect_slope,$
        inspect_slope2      : inspect_slope2,$
        inspect_final       : inspect_final,$
        cinspect            : cinspect,$
        crinspect           : crinspect,$
        ms                  : ms,$
        mc                  : mc,$
        lincor              : lincor,$
        TimeChannel         : TimeChannel,$
        Channel             : Channel,$
        SlopeChannel        : SlopeChannel,$
        loadfile            : loadfile,$
        compare_histo       : compare_histo,$
        scompare_histo      : scompare_histo,$
        compare_colslice    : compare_colslice,$
        scompare_colslice   : scompare_colslice,$
        compare_rowslice    : compare_rowslice,$
        scompare_rowslice   : scompare_rowslice,$
        channel_histo       : channel_histo,$
        channel_rowslice    : channel_rowslice,$
        channel_colslice    : channel_colslice,$
        channel_Shisto      : channel_Shisto,$
        channel_Srowslice   : channel_Srowslice,$
        channel_Scolslice   : channel_Scolslice,$
        RawQuickLook        : 0L,$
        FirstLook           : 0L,$
        PixelLook           : 0L,$
        TwoPtDiff           : 0L,$
        SubarrayGeo         : 0L,$
        FwnHistoLook        : 0L,$
        HistoRawQuickLook   : 0L,$
        HistoZoomQuickLook  : 0L,$
        HistoSlopeQuickLook : 0L,$
        ColSliceCompareQuickLook : 0L,$
        RowSliceCompareQuickLook : 0L,$
        ColSliceSCompareQuickLook : 0L,$
        RowSliceSCompareQuickLook : 0L,$
        HistoCompareQuickLook : 0L,$
        HistoSCompareQuickLook : 0L,$
        Histo1_SlopeQuickLook  : 0L,$
        Histo2_SlopeQuickLook   : 0L,$
        Histo3_SlopeQuickLook     : 0L,$
        HistoIRefQuickLook         : 0L,$
        RawChannelQuickLook        : 0L,$
        SlopeChannelQuickLook      : 0L,$
        TimeChannelQuickLook       : 0L,$
        HistoChannelRawQuickLook   : 0L,$
        RSliceChannelRawQuickLook  : 0L,$
        CSliceChannelRawQuickLook  : 0L,$
        HistoSlopeChannelQuickLook   : 0L,$
        RSliceSlopeChannelQuickLook  : 0L,$
        CSliceSlopeChannelQuickLook  : 0L,$
        CSRawQuickLook             : 0L,$
        CSZoomQuickLook            : 0L,$
        CSSlopeQuickLook           : 0L,$
        CS1_SlopeQuickLook     : 0L,$
        CS2_slopeQuickLook      : 0L,$
        CS3_SlopeQuickLook        : 0L,$
        CSIRefQuickLook             : 0L,$
        RSRawQuickLook             : 0L,$
        RSZoomQuickLook            : 0L,$
        RSSlopeQuickLook           : 0L,$
        RS1_SlopeQuickLook     : 0L,$
        RS2_SlopeQuickLook      : 0L,$
        RS3_SlopeQuickLook        : 0L,$
        RSIRefQuickLook      : 0L,$
        SlopeQuickLook      : 0L,$
        RefQuickLook        : 0L,$
        RefPixelQuickLook   : 0L,$
        TelemetryLook       : 0L,$
        TelemetryLook_RAW   : 0L,$
        TelemetryPlot       : 0L,$
        TelemetryPlot_Raw   : 0L,$
        TelTable            : 0L,$
        TelTableRaw         : 0L,$
        RPixelInfo          : 0L,$
        FLPixelInfo         : 0L,$
        PLSLOPEInfo         : 0L,$
        PLPixelInfo         : 0L,$
        PL2ptInfo           : 0L,$
        UserSetInfo         : 0L,$
        CPixelInfo          : 0L,$
        SCPixelInfo         : 0L,$
        RFPixelInfo         : 0L,$
        MoveInfo            : 0L,$
        StatInfo            : 0L,$
        Slope_StatInfo      : 0L,$
        StatChannelInfo     : 0L,$
        StatChannelTimeInfo : 0L,$
        StatSlopeChannelInfo     : 0L,$
        rcomparedisplay     : 0L,$
        comparedisplay      : 0L,$
        comparepixelinfo    : 0L,$
        loadRdisplay        : 0L,$
        LinCorResults       : 0L,$
        InspectImage        : 0L,$
        InspectRefImage     : 0L,$
        InspectSlope        : 0L,$
        InspectSlope2       : 0L,$
        InspectSlopeFinal   : 0L,$
        CInspectImage       : lonarr(3),$
        CRInspectImage       : lonarr(3),$
        LoadFileInfo            : 0L,$
        RPixelPlot          : 0L,$
        EditMSParameters    : 0L,$
        EditMCParameters    : 0L}


Widget_Control,QuickLook,Set_UValue=info


XManager,'ql',QuickLook,/No_Block,cleanup='ql_cleanup',$
	event_handler="ql_event"



end

