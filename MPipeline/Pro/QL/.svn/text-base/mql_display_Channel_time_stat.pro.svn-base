; Get the statistics on each channel of a science image
;***********************************************************************
pro mql_Channel_time_stat_quit,event
widget_control,event.top, Get_UValue = tinfo
widget_control,tinfo.info.QuickLook,Get_UValue=info
widget_control,info.StatChannelTimeInfo,/destroy
end

;***********************************************************************
;_______________________________________________________________________
; This program produces a widget that gives statistical information
; on an image. The statisical information was determined by the
; program get_image_stat.pro

pro mql_display_Channel_time_stat,info

window,4
wdelete,4
if(XRegistered ('mchstat')) then begin
    widget_control,info.StatChannelTimeInfo,/destroy
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


if(info.control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.control.x_scroll_window
if(info.control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.control.y_scroll_window
if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10

stitle = "Statistics on Image by Channel_time"

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
    image_xsize = info.ChannelT[i].xsize  
    image_ysize = info.ChannelT[i].ysize  
    channel_image = (*info.ChannelT[i].pdata)     
    channel_badpixel = (*info.ChannelT[i].pbadpixel)
    index = where(channel_badpixel eq 1,nbadpixels)
    ngoodpixels = n_elements(channel_image)

    ngoodpixels = ngoodpixels - nbadpixels

    index = where(channel_badpixel eq 1,nbadpixels)
    if(info.Timechannel.apply_bad eq 1 and nbadpixels gt 0) then begin
        channel_image[index] = !values.F_NaN
    endif
    if (info.Timechannel.apply_bad eq 0) then begin
        nbadpixels = 0
        ngoodpixels = n_elements(channel_image)
    endif


    channel_noref = channel_image
    if(info.data.subarray eq 0) then begin
        channel_noref = channel_image[*,1:(image_xsize/4)-2,*]
    endif else begin
        if(info.data.colstart eq 1) then begin
            channel_noref = channel_image[*,1:*,*]
        endif 
    endelse

    get_image_stat,channel_noref,image_mean,stdev,image_min,$
                   image_max,irange_min,irange_max,image_median,$
                   stdev_mean,skew_image,ngood_image,nbad_image


    mean[i] = image_mean
    st_pixel[i] = stdev
    var[i] = st_pixel[i] * st_pixel[i]
    min[i] = image_min
    max[i] = image_max
    median[i] = image_median
    st_mean[i] = stdev_mean
    skew[i] = skew_image
    ngood[i] = ngoodpixels
    nbad[i] = nbadpixels
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



StatChannelTimeInfo = widget_base(title=stitle,$
                         col = 1,mbar = menuBar,group_leader = info.TimeChannelQuickLook,$
                           xsize = xwidget_size,ysize = ywidget_size,/align_right,$
                           /scroll,$
                           x_scroll_size= xsize_scroll,$
                           y_scroll_size = ysize_scroll)

;********
; build the menubar
;********
QuitMenu = widget_button(menuBar,value="Quit",font = info.font2)
quitbutton = widget_button(quitmenu,value="Quit",event_pro='mql_Channel_time_stat_quit')

;_______________________________________________________________________
sxmin = strcompress(string(info.ChannelT[0].ximage_range[0]),/remove_all)
sxmax = strcompress(string(info.ChannelT[0].ximage_range[1]),/remove_all)
symin = strcompress(string(info.ChannelT[0].yimage_range[0]),/remove_all)
symax = strcompress(string(info.ChannelT[0].yimage_range[1]),/remove_all)

if(info.data.subarray eq 0) then begin 
    sxmin = '2'
    sxmax = '257'
endif
srange = " Channel Image range,  Xrange: " + sxmin + " to " + sxmax + $
         " Yrange: " + symin + " to " + symax


jintegration = info.ChannelT[0].jintegration
iramp = info.ChannelT[0].iramp
titlelabel = widget_label(statChannelTimeInfo, $
                          value=info.control.filename_raw,/align_left, $
                          font=info.font3,/dynamic_resize)
sint = " Integration # " + strcompress(string(fix(jintegration+1)),/remove_all) + $
       " Frame # " + strcompress(string(fix(iramp+1)),/remove_all)

tlabelID = widget_label(StatChannelTimeInfo,value =sint,font=info.font5)
tlabelID = widget_label(StatChannelTimeInfo,value = ' No reference pixels used',font=info.font5)
tlabelID = widget_label(StatChannelTimeInfo,value =srange,font=info.font5)
;_______________________________________________________________________
row1 = Widget_Base(statChannelTimeInfo, col=5 )
resbase = Widget_Base(row1, /column , /Frame)
stitle =   '  Channel 1 '
smean =    '          Mean: ' + strtrim(string(mean[0],format="(g14.6)"),2) 
sdpixel =  ' Standard Dev.: ' +  strtrim(string(st_pixel[0],format="(g14.6)"),2)
;sdmean =   '   STDEV (Mean):  '+ strtrim( string(st_mean[0],format="(g14.6)"),2)
smin =     '           Min: '+ strtrim(string(min[0],format="(g14.6)"),2) 
smax =     '           Max: '+strtrim( string(max[0],format="(g14.6)"),2)
smed     = '        Median: '+strtrim( string(median[0],format="(g14.6)"),2)
sskew =    '          Skew: '+strtrim( string(skew[0],format="(g14.6)"),2)
sgood =    ' # Good Pixels  '+strtrim( string(ngood[0],format="(i8)"),2)
sbad =     ' # Bad Pixel s  '+strtrim( string(nbad[0],format="(i8)"),2)

amplab = Widget_Label(resbase, Value = stitle)
meanlab = Widget_Label(resbase, Value = smean)
sdplab = Widget_Label(resbase, Value = sdpixel)
minlab = Widget_Label(resbase, Value = smin)
maxlab = Widget_Label(resbase, Value = smax)
medlab = Widget_Label(resbase, Value = smed)
sklab = Widget_Label(resbase, Value = sskew)
glab = Widget_Label(resbase, Value = sgood)
blab = Widget_Label(resbase, Value = sbad)
;_______________________________________________________________________

resbase = Widget_Base(row1, /column , /Frame)
stitle =   '  Channel 2 '
smean =    '          Mean: ' + strtrim(string(mean[1],format="(g14.6)"),2) 
sdpixel =  ' Standard Dev.: ' +  strtrim(string(st_pixel[1],format="(g14.6)"),2)
;sdmean =   '   STDEV (Mean):  '+ strtrim( string(st_mean[1],format="(g14.6)"),2)
smin =     '           Min: '+ strtrim(string(min[1],format="(g14.6)"),2) 
smax =     '           Max: '+strtrim( string(max[1],format="(g14.6)"),2)
smed     = '        Median: '+strtrim( string(median[1],format="(g14.6)"),2)
sskew =    '          Skew: '+strtrim( string(skew[1],format="(g14.6)"),2)
sgood =    ' # Good Pixels  '+strtrim( string(ngood[1],format="(i8)"),2)
sbad =     ' # Bad Pixel s  '+strtrim( string(nbad[1],format="(i8)"),2)


amplab = Widget_Label(resbase, Value = stitle)
meanlab = Widget_Label(resbase, Value = smean)
sdplab = Widget_Label(resbase, Value = sdpixel)
minlab = Widget_Label(resbase, Value = smin)
maxlab = Widget_Label(resbase, Value = smax)
medlab = Widget_Label(resbase, Value = smed)
sklab = Widget_Label(resbase, Value = sskew)
glab = Widget_Label(resbase, Value = sgood)
blab = Widget_Label(resbase, Value = sbad)
;_______________________________________________________________________
;row1 = Widget_Base(statChannelTimeInfo, col=2 )
resbase = Widget_Base(row1, /column , /Frame)
stitle =   '  Channel 3 '
smean =    '          Mean: ' + strtrim(string(mean[2],format="(g14.6)"),2) 
sdpixel =  ' Standard Dev.: ' +  strtrim(string(st_pixel[2],format="(g14.6)"),2)
;sdmean =   '   STDEV (Mean):  '+ strtrim( string(st_mean[2],format="(g14.6)"),2)
smin =     '           Min: '+ strtrim(string(min[2],format="(g14.6)"),2) 
smax =     '           Max: '+strtrim( string(max[2],format="(g14.6)"),2)
smed     = '        Median: '+strtrim( string(median[2],format="(g14.6)"),2)
sskew =    '          Skew: '+strtrim( string(skew[2],format="(g14.6)"),2)
sgood =    ' # Good Pixels  '+strtrim( string(ngood[2],format="(i8)"),2)
sbad =     ' # Bad Pixel s  '+strtrim( string(nbad[2],format="(i8)"),2)

amplab = Widget_Label(resbase, Value = stitle)
meanlab = Widget_Label(resbase, Value = smean)
sdplab = Widget_Label(resbase, Value = sdpixel)
minlab = Widget_Label(resbase, Value = smin)
maxlab = Widget_Label(resbase, Value = smax)
medlab = Widget_Label(resbase, Value = smed)
sklab = Widget_Label(resbase, Value = sskew)
glab = Widget_Label(resbase, Value = sgood)
blab = Widget_Label(resbase, Value = sbad)
;_______________________________________________________________________

resbase = Widget_Base(row1, /column , /Frame)
stitle =   '  Channel 4 '

smean =    '          Mean: ' + strtrim(string(mean[3],format="(g14.6)"),2) 
sdpixel =  ' Standard Dev.: ' +  strtrim(string(st_pixel[3],format="(g14.6)"),2)
;sdmean =   '   STDEV (Mean):  '+ strtrim( string(st_mean[3],format="(g14.6)"),2)
smin =     '           Min: '+ strtrim(string(min[3],format="(g14.6)"),2) 
smax =     '           Max: '+strtrim( string(max[3],format="(g14.6)"),2)
smed     = '        Median: '+strtrim( string(median[3],format="(g14.6)"),2)
sskew =    '          Skew: '+strtrim( string(skew[3],format="(g14.6)"),2)
sgood =    ' # Good Pixels  '+strtrim( string(ngood[3],format="(i8)"),2)
sbad =     ' # Bad Pixel s  '+strtrim( string(nbad[3],format="(i8)"),2)

amplab = Widget_Label(resbase, Value = stitle)
meanlab = Widget_Label(resbase, Value = smean)
sdplab = Widget_Label(resbase, Value = sdpixel)
minlab = Widget_Label(resbase, Value = smin)
maxlab = Widget_Label(resbase, Value = smax)
medlab = Widget_Label(resbase, Value = smed)
sklab = Widget_Label(resbase, Value = sskew)
glab = Widget_Label(resbase, Value = sgood)
blab = Widget_Label(resbase, Value = sbad)

    ;_______________________________________________________________________
;row1 = Widget_Base(statChannelTimeInfo, col=2 )
resbase = Widget_Base(row1, /column , /Frame)
stitle =   '  Channel 5 '

smean =    '          Mean: ' + strtrim(string(mean[4],format="(g14.6)"),2) 
sdpixel =  ' Standard Dev.: ' +  strtrim(string(st_pixel[4],format="(g14.6)"),2)
;sdmean =   '   STDEV (Mean):  '+ strtrim( string(st_mean[4],format="(g14.6)"),2)
smin =     '           Min: '+ strtrim(string(min[4],format="(g14.6)"),2) 
smax =     '           Max: '+strtrim( string(max[4],format="(g14.6)"),2)
smed     = '        Median: '+strtrim( string(median[4],format="(g14.6)"),2)
sskew =    '          Skew: '+strtrim( string(skew[4],format="(g14.6)"),2)
sgood =    ' # Good Pixels  '+strtrim( string(ngood[4],format="(i8)"),2)
sbad =     ' # Bad Pixel s  '+strtrim( string(nbad[4],format="(i8)"),2)

amplab = Widget_Label(resbase, Value = stitle)
meanlab = Widget_Label(resbase, Value = smean)
sdplab = Widget_Label(resbase, Value = sdpixel)
minlab = Widget_Label(resbase, Value = smin)
maxlab = Widget_Label(resbase, Value = smax)
medlab = Widget_Label(resbase, Value = smed)
sklab = Widget_Label(resbase, Value = sskew)
glab = Widget_Label(resbase, Value = sgood)
blab = Widget_Label(resbase, Value = sbad)

;***********************************************************************
if(info.channel.zoom ne 1) then begin
    xmin_image = info.ChannelT[0].sd_ximage_range[0]
    xmax_image = info.ChannelT[0].sd_ximage_range[1]

    if(info.data.subarray eq 0) then begin
        if(xmin_image eq 1) then xmin_image = 2
        if(xmax_image eq 258) then xmax_image = 257
    endif
    sxmin = strcompress(string(xmin_image),/remove_all)
    sxmax = strcompress(string(xmax_image),/remove_all)
    symin = strcompress(string(info.ChannelT[0].sd_yimage_range[0]),/remove_all)
    symax = strcompress(string(info.ChannelT[0].sd_yimage_range[1]),/remove_all)
    srange = " Zoomed Channel  Image range,  Xrange: " + sxmin + " to " + sxmax + $
             " Yrange: " + symin + " to " + symax




    tlabelID = widget_label(StatChannelTimeInfo,value =srange,font=info.font5)
;_______________________________________________________________________
    row1 = Widget_Base(statChannelTimeInfo, col=5 )
    resbase = Widget_Base(row1, /column , /Frame)
    stitle =   '  Channel 1  (zoom)'
    smean =    '          Mean: ' + strtrim(string(sd_mean[0],format="(g14.6)"),2) 
    sdpixel =  ' Standard Dev.: ' +  strtrim(string(sd_st_pixel[0],format="(g14.6)"),2)
;    sdmean =   ' STDEV (Mean):   '+ strtrim( string(sd_st_mean[0],format="(g14.6)"),2)
    smin =     '           Min: '+ strtrim(string(sd_min[0],format="(g14.6)"),2) 
    smax =     '           Max: '+strtrim( string(sd_max[0],format="(g14.6)"),2)
    smed     = '        Median: '+strtrim( string(sd_median[0],format="(g14.6)"),2)
    sskew =    '          Skew: '+strtrim( string(sd_skew[0],format="(g14.6)"),2)
    sgood =    ' # Good Pixels: '+strtrim( string(sd_ngood[0],format="(i8)"),2)
    sbad =     ' # Bad Pixels : '+strtrim( string(sd_nbad[0],format="(i8)"),2)
    
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
    smean =    '          Mean: ' + strtrim(string(sd_mean[1],format="(g14.6)"),2) 
    sdpixel =  ' Standard Dev.: ' +  strtrim(string(sd_st_pixel[1],format="(g14.6)"),2)
;    sdmean =   ' STDEV (Mean):   '+ strtrim( string(sd_st_mean[1],format="(g14.6)"),2)
    smin =     '           Min: '+ strtrim(string(sd_min[1],format="(g14.6)"),2) 
    smax =     '           Max: '+strtrim( string(sd_max[1],format="(g14.6)"),2)
    smed     = '        Median: '+strtrim( string(sd_median[1],format="(g14.6)"),2)
    sskew =    '          Skew: '+strtrim( string(sd_skew[1],format="(g14.6)"),2)
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

    smean =    '          Mean: ' + strtrim(string(sd_mean[2],format="(g14.6)"),2) 
    sdpixel =  ' Standard Dev.: ' +  strtrim(string(sd_st_pixel[2],format="(g14.6)"),2)
;    sdmean =   ' STDEV (Mean):   '+ strtrim( string(sd_st_mean[2],format="(g14.6)"),2)
    smin =     '           Min: '+ strtrim(string(sd_min[2],format="(g14.6)"),2) 
    smax =     '           Max: '+strtrim( string(sd_max[2],format="(g14.6)"),2)
    smed     = '        Median: '+strtrim( string(sd_median[2],format="(g14.6)"),2)
    sskew =    '          Skew: '+strtrim( string(sd_skew[2],format="(g14.6)"),2)
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
    smean =    '          Mean: ' + strtrim(string(sd_mean[3],format="(g14.6)"),2) 
    sdpixel =  ' Standard Dev.: ' +  strtrim(string(sd_st_pixel[3],format="(g14.6)"),2)
;    sdmean =   ' STDEV (Mean):   '+ strtrim( string(sd_st_mean[3],format="(g14.6)"),2)
    smin =     '           Min: '+ strtrim(string(sd_min[3],format="(g14.6)"),2) 
    smax =     '           Max: '+strtrim( string(sd_max[3],format="(g14.6)"),2)
    smed     = '        Median: '+strtrim( string(sd_median[3],format="(g14.6)"),2)
    sskew =    '          Skew: '+strtrim( string(sd_skew[3],format="(g14.6)"),2)
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

    smean =    '          Mean: ' + strtrim(string(sd_mean[4],format="(g14.6)"),2) 
    sdpixel =  ' Standard Dev.: ' +  strtrim(string(sd_st_pixel[4],format="(g14.6)"),2)
;    sdmean =   ' STDEV (Mean):   '+ strtrim( string(sd_st_mean[4],format="(g14.6)"),2)
    smin =     '           Min: '+ strtrim(string(sd_min[4],format="(g14.6)"),2) 
    smax =     '           Max: '+strtrim( string(sd_max[4],format="(g14.6)"),2)
    smed     = '        Median: '+strtrim( string(sd_median[4],format="(g14.6)"),2)
    sskew =    '          Skew: '+strtrim( string(sd_skew[4],format="(g14.6)"),2)
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


info.StatChannelTimeInfo = StatChannelTimeInfo

stat = {info                  : info}	


Widget_Control,info.StatChannelTimeInfo,Set_UValue=stat
widget_control,info.StatChannelTimeInfo,/realize

XManager,'mchstat',StatChannelTimeInfo,/No_Block
Widget_Control,info.QuickLook,Set_UValue=info

end
