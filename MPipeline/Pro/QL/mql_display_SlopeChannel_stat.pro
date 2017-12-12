;***********************************************************************
pro mql_SlopeChannel_stat_quit,event
widget_control,event.top, Get_UValue = tinfo
widget_control,tinfo.info.QuickLook,Get_UValue=info
widget_control,info.StatSlopeChannelInfo,/destroy
end

;***********************************************************************
;_______________________________________________________________________
; This program produces a widget that gives statistical information
; on an image. The statisical information was determined by the
; program get_image_stat.pro

pro mql_display_SlopeChannel_stat,info

window,4
wdelete,4
if(XRegistered ('mschstat')) then begin
    widget_control,info.StatSlopeChannelInfo,/destroy
endif

;_______________________________________________________________________
;*********
;Setup main panel
;*********
stitle = "Statistics on Slope Image by Channel (without reference pixels)"

; widget window parameters
  xwidget_size = 950
  ywidget_size = 500

  xsize_scroll = 950
  ysize_scroll = 500


if(info.control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.control.x_scroll_window
if(info.control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.control.y_scroll_window
if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10
StatChannelInfo = widget_base(title=stitle,$
                              col = 1,mbar = menuBar,$
                              group_leader = info.SlopeChannelQuickLook,$
                              xsize = xwidget_size,ysize = ywidget_size,/align_right,$
                              /scroll,$
                              x_scroll_size= xsize_scroll,$
                              y_scroll_size = ysize_scroll)


;********
; build the menubar
;********
QuitMenu = widget_button(menuBar,value="Quit",font = info.font2)
quitbutton = widget_button(quitmenu,value="Quit",$
	event_pro='mql_SlopeChannel_stat_quit')




mean = fltarr(5)
st_pixel = fltarr(5)
var = fltarr(5)
min = fltarr(5)
max = fltarr(5)
median = fltarr(5)
st_mean = fltarr(5)
skew = fltarr(5)
ngood = fltarr(5)
nbad = fltarr(5)


for i = 0,4 do begin
    mean[i] = info.ChannelS[i].mean
    st_pixel[i] = info.ChannelS[i].stdev
    var[i] = st_pixel[i] * st_pixel[i]
    min[i] = info.ChannelS[i].min
    max[i] = info.ChannelS[i].max
    median[i] = info.ChannelS[i].median
    st_mean[i] = info.ChannelS[i].stdev_mean
    skew[i] = info.ChannelS[i].skew
    ngood[i] = info.ChannelS[i].ngood
    nbad[i] = info.ChannelS[i].nbad
endfor

sd_mean = fltarr(5)
sd_st_pixel = fltarr(5)
sd_var = fltarr(5)
sd_min = fltarr(5)
sd_max = fltarr(5)
sd_median = fltarr(5)
sd_st_mean = fltarr(5)
sd_skew = fltarr(5)
sd_ngood = fltarr(5)
sd_nbad = fltarr(5)


for i = 0,4 do begin
    sd_mean[i] = info.ChannelS[i].sd_mean
    sd_st_pixel[i] = info.ChannelS[i].sd_stdev
    sd_var[i] = sd_st_pixel[i] * sd_st_pixel[i]
    sd_min[i] = info.ChannelS[i].sd_min
    sd_max[i] = info.ChannelS[i].sd_max
    sd_median[i] = info.ChannelS[i].sd_median
    sd_st_mean[i] = info.ChannelS[i].sd_stdev_mean
    sd_skew[i] = info.ChannelS[i].sd_skew
    sd_ngood[i] = info.ChannelR[i].sd_ngood
    sd_nbad[i] = info.ChannelR[i].sd_nbad
endfor


;_______________________________________________________________________
sxmin = strcompress(string(info.ChannelS[0].ximage_range[0]),/remove_all)
sxmax = strcompress(string(info.ChannelS[0].ximage_range[1]),/remove_all)
symin = strcompress(string(info.ChannelS[0].yimage_range[0]),/remove_all)
symax = strcompress(string(info.ChannelS[0].yimage_range[1]),/remove_all)
srange = " Channel Image range ,  Xrange: " + sxmin + " to " + sxmax + $
         " Yrange: " + symin + " to " + symax + $
         ' (Border reference pixel not included in statistics)' 

jintegration = info.ChannelS[0].jintegration

titlelabel = widget_label(statChannelInfo, $
                          value=info.control.filename_raw,/align_left, $
                          font=info.font3,/dynamic_resize)
sint = " Integration # " + strcompress(string(fix(jintegration+1)),/remove_all) 

tlabelID = widget_label(StatChannelInfo,value =sint,font=info.font5)
tlabelID = widget_label(StatChannelInfo,value =srange,font=info.font5)
;_______________________________________________________________________
row1 = Widget_Base(statChannelInfo, col=5 )
resbase = Widget_Base(row1, /column , /Frame)
stitle =   '  Channel 1 '
smean =    '           Mean:  ' + strtrim(string(mean[0],format="(g14.6)"),2) 
svar =     '       Variance:  '+  strtrim(string(var[0],format="(g14.6)"),2)
sdpixel =  '   Standard Dev:  ' +  strtrim(string(st_pixel[0],format="(g14.6)"),2)
sdmean =   '   STDEV (Mean):  '+ strtrim( string(st_mean[0],format="(g14.6)"),2)
smin =     '            Min:  '+ strtrim(string(min[0],format="(g14.6)"),2) 
smax =     '            Max:  '+strtrim( string(max[0],format="(g14.6)"),2)
smed     = '         Median:  '+strtrim( string(median[0],format="(g14.6)"),2)
sskew =    '           Skew:  '+strtrim( string(skew[0],format="(g14.6)"),2)
sgood =    ' # Good Pixels :  '+strtrim( string(ngood[0],format="(i8)"),2)
sbad =     ' # Bad/Sat Pixels: '+strtrim( string(nbad[0],format="(i8)"),2)



amplab = Widget_Label(resbase, Value = stitle)
meanlab = Widget_Label(resbase, Value = smean)
sdplab = Widget_Label(resbase, Value = sdpixel)
minlab = Widget_Label(resbase, Value = smin)
maxlab = Widget_Label(resbase, Value = smax)
medlab = Widget_Label(resbase, Value = smed)
sklab = Widget_Label(resbase, Value = sskew)
glab = Widget_Label(resbase, Value = sgood)
blab = Widget_Label(resbase, Value = sbad)
info_label = widget_button(resbase,value = 'Info on Bad Pixels',$
                                               event_pro = 'info_badpixel',/align_left)
;_______________________________________________________________________

resbase = Widget_Base(row1, /column , /Frame)
stitle =   '  Channel 2 '
smean =    '           Mean:  ' + strtrim(string(mean[1],format="(g14.6)"),2) 
svar =     '       Variance:  '+  strtrim(string(var[1],format="(g14.6)"),2)
sdpixel =  '   Standard Dev:  ' +  strtrim(string(st_pixel[1],format="(g14.6)"),2)
sdmean =   '   STDEV (Mean):  '+ strtrim( string(st_mean[1],format="(g14.6)"),2)
smin =     '            Min:  '+ strtrim(string(min[1],format="(g14.6)"),2) 
smax =     '            Max:  '+strtrim( string(max[1],format="(g14.6)"),2)
smed     = '         Median:  '+strtrim( string(median[1],format="(g14.6)"),2)
sskew =    '           Skew:  '+strtrim( string(skew[1],format="(g14.6)"),2)
sgood =    ' # Good Pixels :  '+strtrim( string(ngood[1],format="(i8)"),2)
sbad =     ' # Bad/Sat Pixels: '+strtrim( string(nbad[1],format="(i8)"),2)


amplab = Widget_Label(resbase, Value = stitle)
meanlab = Widget_Label(resbase, Value = smean)
sdplab = Widget_Label(resbase, Value = sdpixel)
minlab = Widget_Label(resbase, Value = smin)
maxlab = Widget_Label(resbase, Value = smax)
medlab = Widget_Label(resbase, Value = smed)
sklab = Widget_Label(resbase, Value = sskew)
glab = Widget_Label(resbase, Value = sgood)
blab = Widget_Label(resbase, Value = sbad)
info_label = widget_button(resbase,value = 'Info on Bad Pixels',$
                                               event_pro = 'info_badpixel',/align_left)
;_______________________________________________________________________
;row1 = Widget_Base(statChannelInfo, col=2 )
resbase = Widget_Base(row1, /column , /Frame)
stitle =   '  Channel 3 '
smean =    '           Mean:  ' + strtrim(string(mean[2],format="(g14.6)"),2) 
svar =     '       Variance:  '+  strtrim(string(var[2],format="(g14.6)"),2)
sdpixel =  '   Standard Dev:  ' +  strtrim(string(st_pixel[2],format="(g14.6)"),2)
sdmean =   '   STDEV (Mean):  '+ strtrim( string(st_mean[2],format="(g14.6)"),2)
smin =     '            Min:  '+ strtrim(string(min[2],format="(g14.6)"),2) 
smax =     '            Max:  '+strtrim( string(max[2],format="(g14.6)"),2)
smed     = '         Median:  '+strtrim( string(median[2],format="(g14.6)"),2)
sskew =    '           Skew:  '+strtrim( string(skew[2],format="(g14.6)"),2)
sgood =    ' # Good Pixels :  '+strtrim( string(ngood[2],format="(i8)"),2)
sbad =     ' # Bad/Sat Pixels: '+strtrim( string(nbad[2],format="(i8)"),2)

amplab = Widget_Label(resbase, Value = stitle)
meanlab = Widget_Label(resbase, Value = smean)
sdplab = Widget_Label(resbase, Value = sdpixel)
minlab = Widget_Label(resbase, Value = smin)
maxlab = Widget_Label(resbase, Value = smax)
medlab = Widget_Label(resbase, Value = smed)
sklab = Widget_Label(resbase, Value = sskew)
glab = Widget_Label(resbase, Value = sgood)
blab = Widget_Label(resbase, Value = sbad)
info_label = widget_button(resbase,value = 'Info on Bad Pixels',$
                                               event_pro = 'info_badpixel',/align_left)
;_______________________________________________________________________

resbase = Widget_Base(row1, /column , /Frame)
stitle =   '  Channel 4 '
smean =    '           Mean:  ' + strtrim(string(mean[3],format="(g14.6)"),2) 
svar =     '       Variance:  '+  strtrim(string(var[3],format="(g14.6)"),2)
sdpixel =  '   Standard Dev:  ' +  strtrim(string(st_pixel[3],format="(g14.6)"),2)
sdmean =   '   STDEV (Mean):  '+ strtrim( string(st_mean[3],format="(g14.6)"),2)
smin =     '            Min:  '+ strtrim(string(min[3],format="(g14.6)"),2) 
smax =     '            Max:  '+strtrim( string(max[3],format="(g14.6)"),2)
smed     = '         Median:  '+strtrim( string(median[3],format="(g14.6)"),2)
sskew =    '           Skew:  '+strtrim( string(skew[3],format="(g14.6)"),2)
sgood =    ' # Good Pixels :  '+strtrim( string(ngood[3],format="(i8)"),2)
sbad =     ' # Bad/Sat Pixels: '+strtrim( string(nbad[3],format="(i8)"),2)


amplab = Widget_Label(resbase, Value = stitle)
meanlab = Widget_Label(resbase, Value = smean)
sdplab = Widget_Label(resbase, Value = sdpixel)
minlab = Widget_Label(resbase, Value = smin)
maxlab = Widget_Label(resbase, Value = smax)
medlab = Widget_Label(resbase, Value = smed)
sklab = Widget_Label(resbase, Value = sskew)
glab = Widget_Label(resbase, Value = sgood)
blab = Widget_Label(resbase, Value = sbad)
info_label = widget_button(resbase,value = 'Info on Bad Pixels',$
                                               event_pro = 'info_badpixel',/align_left)
    ;_______________________________________________________________________
;row1 = Widget_Base(statChannelInfo, col=2 )
resbase = Widget_Base(row1, /column , /Frame)
stitle =   '  Channel 5 '
smean =    '           Mean:  ' + strtrim(string(mean[4],format="(g14.6)"),2) 
svar =     '       Variance:  '+  strtrim(string(var[4],format="(g14.6)"),2)
sdpixel =  '   Standard Dev:  ' +  strtrim(string(st_pixel[4],format="(g14.6)"),2)
sdmean =   '   STDEV (Mean):  '+ strtrim( string(st_mean[4],format="(g14.6)"),2)
smin =     '            Min:  '+ strtrim(string(min[4],format="(g14.6)"),2) 
smax =     '            Max:  '+strtrim( string(max[4],format="(g14.6)"),2)
smed     = '         Median:  '+strtrim( string(median[4],format="(g14.6)"),2)
sskew =    '           Skew:  '+strtrim( string(skew[4],format="(g14.6)"),2)
sgood =    ' # Good Pixels :  '+strtrim( string(ngood[4],format="(i8)"),2)
sbad =     ' # Bad Pixels  :  '+strtrim( string(nbad[4],format="(i8)"),2)

amplab = Widget_Label(resbase, Value = stitle)
meanlab = Widget_Label(resbase, Value = smean)
sdplab = Widget_Label(resbase, Value = sdpixel)
minlab = Widget_Label(resbase, Value = smin)
maxlab = Widget_Label(resbase, Value = smax)
medlab = Widget_Label(resbase, Value = smed)
sklab = Widget_Label(resbase, Value = sskew)
glab = Widget_Label(resbase, Value = sgood)
blab = Widget_Label(resbase, Value = sbad)
info_label = widget_button(resbase,value = 'Info on Bad Pixels',$
                                               event_pro = 'info_badpixel',/align_left)
;***********************************************************************
if(info.Slopechannel.zoom ne 1) then begin

    sxmin = strcompress(string(info.ChannelS[0].sd_ximage_range[0]),/remove_all)
    sxmax = strcompress(string(info.ChannelS[0].sd_ximage_range[1]),/remove_all)
    symin = strcompress(string(info.ChannelS[0].sd_yimage_range[0]),/remove_all)
    symax = strcompress(string(info.ChannelS[0].sd_yimage_range[1]),/remove_all)
    srange = " Zoomed Channel  Image  range ,  Xrange: " + sxmin + " to " + sxmax + $
             " Yrange: " + symin + " to " + symax + $
             ' (Border reference pixels not included in statistics)'



    tlabelID = widget_label(StatChannelInfo,value =srange,font=info.font5)
;_______________________________________________________________________
    row1 = Widget_Base(statChannelInfo, col=5 )
    resbase = Widget_Base(row1, /column , /Frame)
    stitle =   '  Channel 1  (zoom)'
    smean =    '           Mean:  ' + strtrim(string(sd_mean[0],format="(g14.6)"),2) 
    svar =     '       Variance:  '+  strtrim(string(sd_var[0],format="(g14.6)"),2)
    sdpixel =  '   Standard Dev:  ' +  strtrim(string(sd_st_pixel[0],format="(g14.6)"),2)
    sdmean =   '   STDEV (Mean):  '+ strtrim( string(sd_st_mean[0],format="(g14.6)"),2)
    smin =     '            Min:  '+ strtrim(string(sd_min[0],format="(g14.6)"),2) 
    smax =     '            Max:  '+strtrim( string(sd_max[0],format="(g14.6)"),2)
    smed     = '         Median:  '+strtrim( string(sd_median[0],format="(g14.6)"),2)
    sskew =    '           Skew:  '+strtrim( string(sd_skew[0],format="(g14.6)"),2)
    sgood =    '  # Good Pixels: '+strtrim( string(sd_ngood[0],format="(i8)"),2)
    sbad =     '  # Bad Pixels : '+strtrim( string(sd_nbad[0],format="(i8)"),2)

    
    amplab = Widget_Label(resbase, Value = stitle)
    meanlab = Widget_Label(resbase, Value = smean)
    sdplab = Widget_Label(resbase, Value = sdpixel)
    minlab = Widget_Label(resbase, Value = smin)
    maxlab = Widget_Label(resbase, Value = smax)
    medlab = Widget_Label(resbase, Value = smed)
    sklab = Widget_Label(resbase, Value = sskew)
    glab = Widget_Label(resbase, Value = sgood)
    nlab = Widget_Label(resbase, Value = sbad)
;_______________________________________________________________________

    resbase = Widget_Base(row1, /column , /Frame)
    stitle =   '  Channel 2  (zoom) '
    smean =    '           Mean:  ' + strtrim(string(sd_mean[1],format="(g14.6)"),2) 
    sdpixel =  '   Standard Dev:  ' +  strtrim(string(sd_st_pixel[1],format="(g14.6)"),2)
    svar =     '       Variance:  '+  strtrim(string(sd_var[1],format="(g14.6)"),2)
    sdpixel =  '  STDEV (Pixel):  ' +  strtrim(string(sd_st_pixel[1],format="(g14.6)"),2)
    sdmean =   '   STDEV (Mean):  '+ strtrim( string(sd_st_mean[1],format="(g14.6)"),2)
    smin =     '            Min:  '+ strtrim(string(sd_min[1],format="(g14.6)"),2) 
    smax =     '            Max:  '+strtrim( string(sd_max[1],format="(g14.6)"),2)
    smed     = '         Median:  '+strtrim( string(sd_median[1],format="(g14.6)"),2)
    sskew =    '           Skew:  '+strtrim( string(sd_skew[1],format="(g14.6)"),2)
    sgood =    ' # Good Pixels: '+strtrim( string(sd_ngood[1],format="(i8)"),2)
    sbad =     ' # Bad Pixels : '+strtrim( string(sd_nbad[1],format="(i8)"),2)

    amplab = Widget_Label(resbase, Value = stitle)
    meanlab = Widget_Label(resbase, Value = smean)
    sdplab = Widget_Label(resbase, Value = sdpixel)
    minlab = Widget_Label(resbase, Value = smin)
    maxlab = Widget_Label(resbase, Value = smax)
    medlab = Widget_Label(resbase, Value = smed)
    sklab = Widget_Label(resbase, Value = sskew)
    glab = Widget_Label(resbase, Value = sgood)
    nlab = Widget_Label(resbase, Value = sbad)


;_______________________________________________________________________
    resbase = Widget_Base(row1, /column , /Frame)
    stitle =   '  Channel 3  (zoom)'
    smean =    '           Mean:  ' + strtrim(string(sd_mean[2],format="(g14.6)"),2) 
    sdpixel =  '   Standard Dev:  ' +  strtrim(string(sd_st_pixel[2],format="(g14.6)"),2)
    svar =     '       Variance:  '+  strtrim(string(sd_var[2],format="(g14.6)"),2)
    sdpixel =  '  STDEV (Pixel):  ' +  strtrim(string(sd_st_pixel[2],format="(g14.6)"),2)
    sdmean =   '   STDEV (Mean):  '+ strtrim( string(sd_st_mean[2],format="(g14.6)"),2)
    smin =     '            Min:  '+ strtrim(string(sd_min[2],format="(g14.6)"),2) 
    smax =     '            Max:  '+strtrim( string(sd_max[2],format="(g14.6)"),2)
    smed     = '         Median:  '+strtrim( string(sd_median[2],format="(g14.6)"),2)
    sskew =    '           Skew:  '+strtrim( string(sd_skew[2],format="(g14.6)"),2)
    sgood =    ' # Good Pixels: '+strtrim( string(sd_ngood[2],format="(i8)"),2)
    sbad =     ' # Bad Pixels : '+strtrim( string(sd_nbad[2],format="(i8)"),2)

    amplab = Widget_Label(resbase, Value = stitle)
    meanlab = Widget_Label(resbase, Value = smean)
    sdplab = Widget_Label(resbase, Value = sdpixel)
    minlab = Widget_Label(resbase, Value = smin)
    maxlab = Widget_Label(resbase, Value = smax)
    medlab = Widget_Label(resbase, Value = smed)
    sklab = Widget_Label(resbase, Value = sskew)
    glab = Widget_Label(resbase, Value = sgood)
    nlab = Widget_Label(resbase, Value = sbad)
;_______________________________________________________________________

    resbase = Widget_Base(row1, /column , /Frame)
    stitle =   '  Channel 4  (zoom)'
    smean =    '           Mean:  ' + strtrim(string(sd_mean[3],format="(g14.6)"),2) 
    sdpixel =  '   Standard Dev:  ' +  strtrim(string(sd_st_pixel[3],format="(g14.6)"),2)
    svar =     '       Variance:  '+  strtrim(string(sd_var[3],format="(g14.6)"),2)
    sdpixel =  '  STDEV (Pixel):  ' +  strtrim(string(sd_st_pixel[3],format="(g14.6)"),2)
    sdmean =   '   STDEV (Mean):  '+ strtrim( string(sd_st_mean[3],format="(g14.6)"),2)
    smin =     '            Min:  '+ strtrim(string(sd_min[3],format="(g14.6)"),2) 
    smax =     '            Max:  '+strtrim( string(sd_max[3],format="(g14.6)"),2)
    smed     = '         Median:  '+strtrim( string(sd_median[3],format="(g14.6)"),2)
    sskew =    '           Skew:  '+strtrim( string(sd_skew[3],format="(g14.6)"),2)
    sgood =    ' # Good Pixels: '+strtrim( string(sd_ngood[3],format="(i8)"),2)
    sbad =     ' # Bad Pixels : '+strtrim( string(sd_nbad[3],format="(i8)"),2)

    amplab = Widget_Label(resbase, Value = stitle)
    meanlab = Widget_Label(resbase, Value = smean)
    sdplab = Widget_Label(resbase, Value = sdpixel)
    minlab = Widget_Label(resbase, Value = smin)
    maxlab = Widget_Label(resbase, Value = smax)
    medlab = Widget_Label(resbase, Value = smed)
    sklab = Widget_Label(resbase, Value = sskew)
    glab = Widget_Label(resbase, Value = sgood)
    nlab = Widget_Label(resbase, Value = sbad)

    ;_______________________________________________________________________
    resbase = Widget_Base(row1, /column , /Frame)
    stitle =   '  Channel 5  (zoom) '
    smean =    '           Mean:  ' + strtrim(string(sd_mean[4],format="(g14.6)"),2) 
    sdpixel =  '   Standard Dev:  ' +  strtrim(string(sd_st_pixel[4],format="(g14.6)"),2)
    svar =     '       Variance:  '+  strtrim(string(sd_var[4],format="(g14.6)"),2)
    sdpixel =  '  STDEV (Pixel):  ' +  strtrim(string(sd_st_pixel[4],format="(g14.6)"),2)
    sdmean =   '   STDEV (Mean):  '+ strtrim( string(sd_st_mean[4],format="(g14.6)"),2)
    smin =     '            Min:  '+ strtrim(string(sd_min[4],format="(g14.6)"),2) 
    smax =     '            Max:  '+strtrim( string(sd_max[4],format="(g14.6)"),2)
    smed     = '         Median:  '+strtrim( string(sd_median[4],format="(g14.6)"),2)
    sskew =    '           Skew:  '+strtrim( string(sd_skew[4],format="(g14.6)"),2)
    sgood =    ' # Good Pixels: '+strtrim( string(sd_ngood[4],format="(i8)"),2)
    sbad =     ' # Bad Pixels : '+strtrim( string(sd_nbad[4],format="(i8)"),2)
    
    amplab = Widget_Label(resbase, Value = stitle)
    meanlab = Widget_Label(resbase, Value = smean)
    sdplab = Widget_Label(resbase, Value = sdpixel)
    minlab = Widget_Label(resbase, Value = smin)
    maxlab = Widget_Label(resbase, Value = smax)
    medlab = Widget_Label(resbase, Value = smed)
    sklab = Widget_Label(resbase, Value = sskew)
    glab = Widget_Label(resbase, Value = sgood)
    nlab = Widget_Label(resbase, Value = sbad)
    
endif


info.StatSlopeChannelInfo = StatChannelInfo

stat = {info                  : info}	


Widget_Control,info.StatSlopeChannelInfo,Set_UValue=stat
widget_control,info.StatSlopeChannelInfo,/realize

XManager,'mschstat',StatChannelInfo,/No_Block
Widget_Control,info.QuickLook,Set_UValue=info

end
