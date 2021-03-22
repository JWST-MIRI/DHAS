; Get the statistics on each channel of a science image
;***********************************************************************
pro jwst_amplifier_stat_quit,event
widget_control,event.top, Get_UValue = tinfo
widget_control,tinfo.info.jwst_QuickLook,Get_UValue=info
widget_control,info.jwst_AmpStatDisplay,/destroy
end

;***********************************************************************
;_______________________________________________________________________
; This program produces a widget that gives statistical information
; on an image. The statisical information was determined by the
; program get_image_stat.pro

pro jwst_display_amplifier_stat,info

window,4
wdelete,4
if(XRegistered ('amp_frame_stat')) then begin
    widget_control,info.jwst_AmpStatDisplay,/destroy
endif

;_______________________________________________________________________
;*********
;Setup main panel
;*********


; widget window parameters
  xwidget_size = 950
  ywidget_size = 500

  xsize_scroll = 950
  ysize_scroll = 500

if(info.jwst_control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.jwst_control.x_scroll_window
if(info.jwst_control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.jwst_control.y_scroll_window
if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10

stitle = "Statistics on Image by Amplifier"

mean = fltarr(5)
st_pixel = fltarr(5)
var = fltarr(5)
min = fltarr(5)
max = fltarr(5)
median = fltarr(5)
st_mean = fltarr(5)


for i = 0,4 do begin
    image_xsize = info.jwst_AmpFrame_image[i].xsize  
    image_ysize = info.jwst_AmpFrame_image[i].ysize  
    channel_image = (*info.jwst_AmpFrame_image[i].pdata)     

    channel_noref = channel_image
    if(info.jwst_data.subarray eq 0) then begin
        channel_noref = channel_image[*,1:(image_xsize/4)-2,*]
    endif else begin
        if(info.jwst_data.colstart eq 1) then begin
            channel_noref = channel_image[*,1:*,*]
        endif 
    endelse
            
    jwst_get_image_stat,channel_noref,image_mean,stdev,image_min,$
                   image_max,irange_min,irange_max,image_median,$
                   stdev_mean

    mean[i] = image_mean
    st_pixel[i] = stdev
    var[i] = st_pixel[i] * st_pixel[i]
    min[i] = image_min
    max[i] = image_max
    median[i] = image_median
    st_mean[i] = stdev_mean

endfor

sd_mean = fltarr(5)
sd_st_pixel = fltarr(5)
sd_var = fltarr(5)
sd_min = fltarr(5)
sd_max = fltarr(5)
sd_median = fltarr(5)
sd_st_mean = fltarr(5)

for i = 0,4 do begin
    sd_mean[i] = info.jwst_AmpFrame_image[i].sd_mean
    sd_st_pixel[i] = info.jwst_AmpFrame_image[i].sd_stdev
    sd_var[i] = sd_st_pixel[i] * sd_st_pixel[i]
    sd_min[i] = info.jwst_AmpFrame_image[i].sd_min
    sd_max[i] = info.jwst_AmpFrame_image[i].sd_max
    sd_median[i] = info.jwst_AmpFrame_image[i].sd_median
    sd_st_mean[i] = info.jwst_AmpFrame_image[i].sd_stdev_mean

endfor

StatChannelInfo = widget_base(title=stitle,$
                         col = 1,mbar = menuBar,group_leader = info.jwst_ampFrameDisplay,$
                           xsize = xwidget_size,ysize = ywidget_size,/align_right,$
                           /scroll,$
                           x_scroll_size= xsize_scroll,$
                           y_scroll_size = ysize_scroll)

;********
; build the menubar
;********
QuitMenu = widget_button(menuBar,value="Quit",font = info.font2)
quitbutton = widget_button(quitmenu,value="Quit",event_pro='jwst_Amplifier_stat_quit')

;_______________________________________________________________________
sxmin = strcompress(string(info.jwst_AmpFrame_image[0].ximage_range[0]),/remove_all)
sxmax = strcompress(string(info.jwst_AmpFrame_image[0].ximage_range[1]),/remove_all)
symin = strcompress(string(info.jwst_AmpFrame_image[0].yimage_range[0]),/remove_all)
symax = strcompress(string(info.jwst_AmpFrame_image[0].yimage_range[1]),/remove_all)

if(info.jwst_data.subarray eq 0) then begin 
    sxmin = '2'
    sxmax = '257'
endif
srange = " Amplifier Image range,  Xrange: " + sxmin + " to " + sxmax + $
         " Yrange: " + symin + " to " + symax + $
             ' (Border reference pixels not included in statistics)'

jintegration = info.jwst_AmpFrame_image[0].jintegration
igroup = info.jwst_AmpFrame_image[0].igroup
titlelabel = widget_label(statChannelInfo, $
                          value=info.jwst_control.filename_raw,/align_left, $
                          font=info.font3,/dynamic_resize)
sint = " Integration # " + strcompress(string(fix(jintegration+1)),/remove_all) + $
       " Frame # " + strcompress(string(fix(igroup+1)),/remove_all)

tlabelID = widget_label(StatChannelInfo,value =sint,font=info.font5)
tlabelID = widget_label(StatChannelInfo,value = ' No reference pixels used',font=info.font5)
tlabelID = widget_label(StatChannelInfo,value =srange,font=info.font5)
;_______________________________________________________________________
row1 = Widget_Base(statChannelInfo, col=5 )
resbase = Widget_Base(row1, /column , /Frame)
stitle =   '  Amplifier 1 '
smean =    '          Mean: ' + strtrim(string(mean[0],format="(g14.6)"),2) 
sdpixel =  ' Standard Dev.: ' +  strtrim(string(st_pixel[0],format="(g14.6)"),2)
smin =     '           Min: '+ strtrim(string(min[0],format="(g14.6)"),2) 
smax =     '           Max: '+strtrim( string(max[0],format="(g14.6)"),2)
smed     = '        Median: '+strtrim( string(median[0],format="(g14.6)"),2)

amplab = Widget_Label(resbase, Value = stitle)
meanlab = Widget_Label(resbase, Value = smean)
sdplab = Widget_Label(resbase, Value = sdpixel)
minlab = Widget_Label(resbase, Value = smin)
maxlab = Widget_Label(resbase, Value = smax)
medlab = Widget_Label(resbase, Value = smed)

;_______________________________________________________________________

resbase = Widget_Base(row1, /column , /Frame)
stitle =   '  Amplifier 2 '
smean =    '          Mean: ' + strtrim(string(mean[1],format="(g14.6)"),2) 
sdpixel =  ' Standard Dev.: ' +  strtrim(string(st_pixel[1],format="(g14.6)"),2)
smin =     '           Min: '+ strtrim(string(min[1],format="(g14.6)"),2) 
smax =     '           Max: '+strtrim( string(max[1],format="(g14.6)"),2)
smed     = '        Median: '+strtrim( string(median[1],format="(g14.6)"),2)

amplab = Widget_Label(resbase, Value = stitle)
meanlab = Widget_Label(resbase, Value = smean)
sdplab = Widget_Label(resbase, Value = sdpixel)
minlab = Widget_Label(resbase, Value = smin)
maxlab = Widget_Label(resbase, Value = smax)
medlab = Widget_Label(resbase, Value = smed)
;_______________________________________________________________________
;row1 = Widget_Base(statChannelInfo, col=2 )
resbase = Widget_Base(row1, /column , /Frame)
stitle =   '  Amplifier 3 '
smean =    '          Mean: ' + strtrim(string(mean[2],format="(g14.6)"),2) 
sdpixel =  ' Standard Dev.: ' +  strtrim(string(st_pixel[2],format="(g14.6)"),2)
smin =     '           Min: '+ strtrim(string(min[2],format="(g14.6)"),2) 
smax =     '           Max: '+strtrim( string(max[2],format="(g14.6)"),2)
smed     = '        Median: '+strtrim( string(median[2],format="(g14.6)"),2)

amplab = Widget_Label(resbase, Value = stitle)
meanlab = Widget_Label(resbase, Value = smean)
sdplab = Widget_Label(resbase, Value = sdpixel)
minlab = Widget_Label(resbase, Value = smin)
maxlab = Widget_Label(resbase, Value = smax)
medlab = Widget_Label(resbase, Value = smed)

;_______________________________________________________________________

resbase = Widget_Base(row1, /column , /Frame)
stitle =   '  Amplifier 4 '

smean =    '          Mean: ' + strtrim(string(mean[3],format="(g14.6)"),2) 
sdpixel =  ' Standard Dev.: ' +  strtrim(string(st_pixel[3],format="(g14.6)"),2)

smin =     '           Min: '+ strtrim(string(min[3],format="(g14.6)"),2) 
smax =     '           Max: '+strtrim( string(max[3],format="(g14.6)"),2)
smed     = '        Median: '+strtrim( string(median[3],format="(g14.6)"),2)

amplab = Widget_Label(resbase, Value = stitle)
meanlab = Widget_Label(resbase, Value = smean)
sdplab = Widget_Label(resbase, Value = sdpixel)
minlab = Widget_Label(resbase, Value = smin)
maxlab = Widget_Label(resbase, Value = smax)
medlab = Widget_Label(resbase, Value = smed)
;_______________________________________________________________________

resbase = Widget_Base(row1, /column , /Frame)
stitle =   '  Amplifier 5 '

smean =    '          Mean: ' + strtrim(string(mean[4],format="(g14.6)"),2) 
sdpixel =  ' Standard Dev.: ' +  strtrim(string(st_pixel[4],format="(g14.6)"),2)
smin =     '           Min: '+ strtrim(string(min[4],format="(g14.6)"),2) 
smax =     '           Max: '+strtrim( string(max[4],format="(g14.6)"),2)
smed     = '        Median: '+strtrim( string(median[4],format="(g14.6)"),2)

amplab = Widget_Label(resbase, Value = stitle)
meanlab = Widget_Label(resbase, Value = smean)
sdplab = Widget_Label(resbase, Value = sdpixel)
minlab = Widget_Label(resbase, Value = smin)
maxlab = Widget_Label(resbase, Value = smax)
medlab = Widget_Label(resbase, Value = smed)

;***********************************************************************
if(info.jwst_AmpFrame.zoom ne 1) then begin
    xmin_image = info.jwst_AmpFrame_image[0].sd_ximage_range[0]
    xmax_image = info.jwst_AmpFrame_image[0].sd_ximage_range[1]

    if(info.jwst_data.subarray eq 0) then begin
        if(xmin_image eq 1) then xmin_image = 2
        if(xmax_image eq 258) then xmax_image = 257
    endif
    sxmin = strcompress(string(xmin_image),/remove_all)
    sxmax = strcompress(string(xmax_image),/remove_all)
    symin = strcompress(string(info.jwst_AmpFrame_image[0].sd_yimage_range[0]),/remove_all)
    symax = strcompress(string(info.jwst_AmpFrame_image[0].sd_yimage_range[1]),/remove_all)
    srange = " Zoomed Amplifier  Image range,  Xrange: " + sxmin + " to " + sxmax + $
             " Yrange: " + symin + " to " + symax + $
             ' (Border reference pixels not included in statistics)'

    tlabelID = widget_label(StatChannelInfo,value =srange,font=info.font5)
;_______________________________________________________________________
    row1 = Widget_Base(statChannelInfo, col=5 )
    resbase = Widget_Base(row1, /column , /Frame)
    stitle =   '  Amplifier 1  (zoom)'
    smean =    '          Mean: ' + strtrim(string(sd_mean[0],format="(g14.6)"),2) 
    sdpixel =  ' Standard Dev.: ' +  strtrim(string(sd_st_pixel[0],format="(g14.6)"),2)
    smin =     '           Min: '+ strtrim(string(sd_min[0],format="(g14.6)"),2) 
    smax =     '           Max: '+strtrim( string(sd_max[0],format="(g14.6)"),2)
    smed     = '        Median: '+strtrim( string(sd_median[0],format="(g14.6)"),2)
    
    amplab = Widget_Label(resbase, Value = stitle)
    meanlab = Widget_Label(resbase, Value = smean)
    sdplab = Widget_Label(resbase, Value = sdpixel)
    minlab = Widget_Label(resbase, Value = smin)
    maxlab = Widget_Label(resbase, Value = smax)
    medlab = Widget_Label(resbase, Value = smed)
;_______________________________________________________________________

    resbase = Widget_Base(row1, /column , /Frame)
    stitle =   '  Amplifier 2  (zoom) '
    smean =    '          Mean: ' + strtrim(string(sd_mean[1],format="(g14.6)"),2) 
    sdpixel =  ' Standard Dev.: ' +  strtrim(string(sd_st_pixel[1],format="(g14.6)"),2)
    smin =     '           Min: '+ strtrim(string(sd_min[1],format="(g14.6)"),2) 
    smax =     '           Max: '+strtrim( string(sd_max[1],format="(g14.6)"),2)
    smed     = '        Median: '+strtrim( string(sd_median[1],format="(g14.6)"),2)

    amplab = Widget_Label(resbase, Value = stitle)
    meanlab = Widget_Label(resbase, Value = smean)
    sdplab = Widget_Label(resbase, Value = sdpixel)
    minlab = Widget_Label(resbase, Value = smin)
    maxlab = Widget_Label(resbase, Value = smax)
    medlab = Widget_Label(resbase, Value = smed)

;_______________________________________________________________________
    resbase = Widget_Base(row1, /column , /Frame)
    stitle =   '  Amplifier 3  (zoom)'

    smean =    '          Mean: ' + strtrim(string(sd_mean[2],format="(g14.6)"),2) 
    sdpixel =  ' Standard Dev.: ' +  strtrim(string(sd_st_pixel[2],format="(g14.6)"),2)
    smin =     '           Min: '+ strtrim(string(sd_min[2],format="(g14.6)"),2) 
    smax =     '           Max: '+strtrim( string(sd_max[2],format="(g14.6)"),2)
    smed     = '        Median: '+strtrim( string(sd_median[2],format="(g14.6)"),2)

    amplab = Widget_Label(resbase, Value = stitle)
    meanlab = Widget_Label(resbase, Value = smean)
    sdplab = Widget_Label(resbase, Value = sdpixel)
    minlab = Widget_Label(resbase, Value = smin)
    maxlab = Widget_Label(resbase, Value = smax)
    medlab = Widget_Label(resbase, Value = smed)

;_______________________________________________________________________

    resbase = Widget_Base(row1, /column , /Frame)
    stitle =   '  Amplifier 4  (zoom)'
    smean =    '          Mean: ' + strtrim(string(sd_mean[3],format="(g14.6)"),2) 
    sdpixel =  ' Standard Dev.: ' +  strtrim(string(sd_st_pixel[3],format="(g14.6)"),2)
    smin =     '           Min: '+ strtrim(string(sd_min[3],format="(g14.6)"),2) 
    smax =     '           Max: '+strtrim( string(sd_max[3],format="(g14.6)"),2)
    smed     = '        Median: '+strtrim( string(sd_median[3],format="(g14.6)"),2)

    amplab = Widget_Label(resbase, Value = stitle)
    meanlab = Widget_Label(resbase, Value = smean)
    sdplab = Widget_Label(resbase, Value = sdpixel)
    minlab = Widget_Label(resbase, Value = smin)
    maxlab = Widget_Label(resbase, Value = smax)
    medlab = Widget_Label(resbase, Value = smed)

    ;_______________________________________________________________________
    resbase = Widget_Base(row1, /column , /Frame)
    stitle =   '  Amplifier 5  (zoom) '

    smean =    '          Mean: ' + strtrim(string(sd_mean[4],format="(g14.6)"),2) 
    sdpixel =  ' Standard Dev.: ' +  strtrim(string(sd_st_pixel[4],format="(g14.6)"),2)
    smin =     '           Min: '+ strtrim(string(sd_min[4],format="(g14.6)"),2) 
    smax =     '           Max: '+strtrim( string(sd_max[4],format="(g14.6)"),2)
    smed     = '        Median: '+strtrim( string(sd_median[4],format="(g14.6)"),2)

    
    amplab = Widget_Label(resbase, Value = stitle)
    meanlab = Widget_Label(resbase, Value = smean)
    sdplab = Widget_Label(resbase, Value = sdpixel)
    minlab = Widget_Label(resbase, Value = smin)
    maxlab = Widget_Label(resbase, Value = smax)
    medlab = Widget_Label(resbase, Value = smed)
    
endif


info.jwst_AmpStatDisplay = StatChannelInfo

stat = {info                  : info}	


Widget_Control,info.jwst_AmpStatDisplay,Set_UValue=stat
widget_control,info.jwst_AmpStatDisplay,/realize

XManager,'amp_stat',StatChannelInfo,/No_Block
Widget_Control,info.jwst_QuickLook,Set_UValue=info

end
