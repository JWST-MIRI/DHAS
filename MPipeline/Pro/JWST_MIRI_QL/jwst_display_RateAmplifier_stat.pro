;***********************************************************************
pro jwst_RateAmplifier_stat_quit,event
widget_control,event.top, Get_UValue = tinfo
widget_control,tinfo.info.jwst_QuickLook,Get_UValue=info
widget_control,info.jwst_AmpRateStatSiplay,/destroy
end
;_______________________________________________________________________
; This program produces a widget that gives statistical information
; on an image. The statisical information was determined by the
; program get_image_stat.pro

pro jwst_display_RateAmplifier_stat,info

window,4
wdelete,4
if(XRegistered ('amp_ratestat')) then begin
    widget_control,info.jwst_AmpRateStatDisplay,/destroy
endif

;_______________________________________________________________________
;Setup main panel

stitle = "Statistics on Rate Image by Amplifier (without reference pixels)"

; widget window parameters
  xwidget_size = 950
  ywidget_size = 500

  xsize_scroll = 950
  ysize_scroll = 500

  if(info.jwst_control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.jwst_control.x_scroll_window
  if(info.jwst_control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.jwst_control.y_scroll_window
  if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
  if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10
  StatChannelInfo = widget_base(title=stitle,$
                                col = 1,mbar = menuBar,$
                                group_leader = info.jwst_AmpRateDisplay,$
                                xsize = xwidget_size,ysize = ywidget_size,/align_right,$
                                /scroll,$
                                x_scroll_size= xsize_scroll,$
                                y_scroll_size = ysize_scroll)

; build the menubar
  QuitMenu = widget_button(menuBar,value="Quit",font = info.font2)
  quitbutton = widget_button(quitmenu,value="Quit",$
                             event_pro='jwst_RateAmplifier_stat_quit')

  mean = fltarr(5)
  st_pixel = fltarr(5)
  var = fltarr(5)
  min = fltarr(5)
  max = fltarr(5)
  median = fltarr(5)
  st_mean = fltarr(5)

  for i = 0,3 do begin
     mean[i] = info.jwst_AmpRate_image[i].mean
     st_pixel[i] = info.jwst_AmpRate_image[i].stdev
     var[i] = st_pixel[i] * st_pixel[i]
     min[i] = info.jwst_AmpRate_image[i].min
     max[i] = info.jwst_AmpRate_image[i].max
     median[i] = info.jwst_AmpRate_image[i].median
     st_mean[i] = info.jwst_AmpRate_image[i].stdev_mean
  endfor

  sd_mean = fltarr(5)
  sd_st_pixel = fltarr(5)
  sd_var = fltarr(5)
  sd_min = fltarr(5)
  sd_max = fltarr(5)
  sd_median = fltarr(5)
  sd_st_mean = fltarr(5)

  for i = 0,3 do begin
     sd_mean[i] = info.jwst_AmpRate_image[i].sd_mean
     sd_st_pixel[i] = info.jwst_AmpRate_image[i].sd_stdev
     sd_var[i] = sd_st_pixel[i] * sd_st_pixel[i]
     sd_min[i] = info.jwst_AmpRate_image[i].sd_min
     sd_max[i] = info.jwst_AmpRate_image[i].sd_max
     sd_median[i] = info.jwst_AmpRate_image[i].sd_median
     sd_st_mean[i] = info.jwst_AmpRate_image[i].sd_stdev_mean
  endfor

;_______________________________________________________________________
  sxmin = strcompress(string(info.jwst_AmpRate_image[0].ximage_range[0]),/remove_all)
  sxmax = strcompress(string(info.jwst_AmpRate_image[0].ximage_range[1]),/remove_all)
  symin = strcompress(string(info.jwst_AmpRate_image[0].yimage_range[0]),/remove_all)
  symax = strcompress(string(info.jwst_AmpRate_image[0].yimage_range[1]),/remove_all)
  srange = " Amplifier Image range ,  Xrange: " + sxmin + " to " + sxmax + $
           " Yrange: " + symin + " to " + symax + $
           ' (Border reference pixel not included in statistics)' 

  titlelabel = widget_label(statChannelInfo, $
                            value=info.jwst_control.filename_slope,/align_left, $
                            font=info.font3,/dynamic_resize)

  tlabelID = widget_label(StatChannelInfo,value =srange,font=info.font5)
;_______________________________________________________________________
  row1 = Widget_Base(statChannelInfo, col=4 )
  resbase = Widget_Base(row1, /column , /Frame)
  stitle =   '  Amplifier 1 '
  smean =    '           Mean:  ' + strtrim(string(mean[0],format="(g14.6)"),2) 
  svar =     '       Variance:  '+  strtrim(string(var[0],format="(g14.6)"),2)
  sdpixel =  '   Standard Dev:  ' +  strtrim(string(st_pixel[0],format="(g14.6)"),2)
  sdmean =   '   STDEV (Mean):  '+ strtrim( string(st_mean[0],format="(g14.6)"),2)
  smin =     '            Min:  '+ strtrim(string(min[0],format="(g14.6)"),2) 
  smax =     '            Max:  '+strtrim( string(max[0],format="(g14.6)"),2)
  smed     = '         Median:  '+strtrim( string(median[0],format="(g14.6)"),2)

  amplab = Widget_Label(resbase, Value = stitle)
  meanlab = Widget_Label(resbase, Value = smean)
  sdplab = Widget_Label(resbase, Value = sdpixel)
  minlab = Widget_Label(resbase, Value = smin)
  maxlab = Widget_Label(resbase, Value = smax)
  medlab = Widget_Label(resbase, Value = smed)
;_______________________________________________________________________

  resbase = Widget_Base(row1, /column , /Frame)
  stitle =   '  Amplifier 2 '
  smean =    '           Mean:  ' + strtrim(string(mean[1],format="(g14.6)"),2) 
  svar =     '       Variance:  '+  strtrim(string(var[1],format="(g14.6)"),2)
  sdpixel =  '   Standard Dev:  ' +  strtrim(string(st_pixel[1],format="(g14.6)"),2)
  sdmean =   '   STDEV (Mean):  '+ strtrim( string(st_mean[1],format="(g14.6)"),2)
  smin =     '            Min:  '+ strtrim(string(min[1],format="(g14.6)"),2) 
  smax =     '            Max:  '+strtrim( string(max[1],format="(g14.6)"),2)
  smed     = '         Median:  '+strtrim( string(median[1],format="(g14.6)"),2)

  amplab = Widget_Label(resbase, Value = stitle)
  meanlab = Widget_Label(resbase, Value = smean)
  sdplab = Widget_Label(resbase, Value = sdpixel)
  minlab = Widget_Label(resbase, Value = smin)
  maxlab = Widget_Label(resbase, Value = smax)
  medlab = Widget_Label(resbase, Value = smed)
;_______________________________________________________________________
  resbase = Widget_Base(row1, /column , /Frame)
  stitle =   '  Amplifier 3 '
  smean =    '           Mean:  ' + strtrim(string(mean[2],format="(g14.6)"),2) 
  svar =     '       Variance:  '+  strtrim(string(var[2],format="(g14.6)"),2)
  sdpixel =  '   Standard Dev:  ' +  strtrim(string(st_pixel[2],format="(g14.6)"),2)
  sdmean =   '   STDEV (Mean):  '+ strtrim( string(st_mean[2],format="(g14.6)"),2)
  smin =     '            Min:  '+ strtrim(string(min[2],format="(g14.6)"),2) 
  smax =     '            Max:  '+strtrim( string(max[2],format="(g14.6)"),2)
  smed     = '         Median:  '+strtrim( string(median[2],format="(g14.6)"),2)

  amplab = Widget_Label(resbase, Value = stitle)
  meanlab = Widget_Label(resbase, Value = smean)
  sdplab = Widget_Label(resbase, Value = sdpixel)
  minlab = Widget_Label(resbase, Value = smin)
  maxlab = Widget_Label(resbase, Value = smax)
  medlab = Widget_Label(resbase, Value = smed)
;_______________________________________________________________________

  resbase = Widget_Base(row1, /column , /Frame)
  stitle =   '  Amplifier 4 '
  smean =    '           Mean:  ' + strtrim(string(mean[3],format="(g14.6)"),2) 
  svar =     '       Variance:  '+  strtrim(string(var[3],format="(g14.6)"),2)
  sdpixel =  '   Standard Dev:  ' +  strtrim(string(st_pixel[3],format="(g14.6)"),2)
  sdmean =   '   STDEV (Mean):  '+ strtrim( string(st_mean[3],format="(g14.6)"),2)
  smin =     '            Min:  '+ strtrim(string(min[3],format="(g14.6)"),2) 
  smax =     '            Max:  '+strtrim( string(max[3],format="(g14.6)"),2)
  smed     = '         Median:  '+strtrim( string(median[3],format="(g14.6)"),2)

  amplab = Widget_Label(resbase, Value = stitle)
  meanlab = Widget_Label(resbase, Value = smean)
  sdplab = Widget_Label(resbase, Value = sdpixel)
  minlab = Widget_Label(resbase, Value = smin)
  maxlab = Widget_Label(resbase, Value = smax)
  medlab = Widget_Label(resbase, Value = smed)
    ;_______________________________________________________________________

  if(info.jwst_Amprate.zoom ne 1) then begin
     sxmin = strcompress(string(info.jwst_AmpRate_image[0].sd_ximage_range[0]),/remove_all)
     sxmax = strcompress(string(info.jwst_AmpRate_image[0].sd_ximage_range[1]),/remove_all)
     symin = strcompress(string(info.jwst_AmpRate_image[0].sd_yimage_range[0]),/remove_all)
     symax = strcompress(string(info.jwst_AmpRate_image[0].sd_yimage_range[1]),/remove_all)
     srange = " Zoomed Channel  Image  range ,  Xrange: " + sxmin + " to " + sxmax + $
              " Yrange: " + symin + " to " + symax + $
              ' (Border reference pixels not included in statistics)'

     tlabelID = widget_label(StatChannelInfo,value =srange,font=info.font5)
;_______________________________________________________________________
     row1 = Widget_Base(statChannelInfo, col=4 )
     resbase = Widget_Base(row1, /column , /Frame)
     stitle =   '  Amplifier 1  (zoom)'
     smean =    '           Mean:  ' + strtrim(string(sd_mean[0],format="(g14.6)"),2) 
     svar =     '       Variance:  '+  strtrim(string(sd_var[0],format="(g14.6)"),2)
     sdpixel =  '   Standard Dev:  ' +  strtrim(string(sd_st_pixel[0],format="(g14.6)"),2)
     sdmean =   '   STDEV (Mean):  '+ strtrim( string(sd_st_mean[0],format="(g14.6)"),2)
     smin =     '            Min:  '+ strtrim(string(sd_min[0],format="(g14.6)"),2) 
     smax =     '            Max:  '+strtrim( string(sd_max[0],format="(g14.6)"),2)
     smed     = '         Median:  '+strtrim( string(sd_median[0],format="(g14.6)"),2)

     amplab = Widget_Label(resbase, Value = stitle)
     meanlab = Widget_Label(resbase, Value = smean)
     sdplab = Widget_Label(resbase, Value = sdpixel)
     minlab = Widget_Label(resbase, Value = smin)
     maxlab = Widget_Label(resbase, Value = smax)
     medlab = Widget_Label(resbase, Value = smed)
;_______________________________________________________________________
     resbase = Widget_Base(row1, /column , /Frame)
     stitle =   '  Amplifier 2  (zoom) '
     smean =    '           Mean:  ' + strtrim(string(sd_mean[1],format="(g14.6)"),2) 
     sdpixel =  '   Standard Dev:  ' +  strtrim(string(sd_st_pixel[1],format="(g14.6)"),2)
     svar =     '       Variance:  '+  strtrim(string(sd_var[1],format="(g14.6)"),2)
     sdpixel =  '  STDEV (Pixel):  ' +  strtrim(string(sd_st_pixel[1],format="(g14.6)"),2)
     sdmean =   '   STDEV (Mean):  '+ strtrim( string(sd_st_mean[1],format="(g14.6)"),2)
     smin =     '            Min:  '+ strtrim(string(sd_min[1],format="(g14.6)"),2) 
     smax =     '            Max:  '+strtrim( string(sd_max[1],format="(g14.6)"),2)
     smed     = '         Median:  '+strtrim( string(sd_median[1],format="(g14.6)"),2)
    
     amplab = Widget_Label(resbase, Value = stitle)
     meanlab = Widget_Label(resbase, Value = smean)
     sdplab = Widget_Label(resbase, Value = sdpixel)
     minlab = Widget_Label(resbase, Value = smin)
     maxlab = Widget_Label(resbase, Value = smax)
     medlab = Widget_Label(resbase, Value = smed)
;_______________________________________________________________________
     resbase = Widget_Base(row1, /column , /Frame)
     stitle =   '  Amplifier 3  (zoom)'
     smean =    '           Mean:  ' + strtrim(string(sd_mean[2],format="(g14.6)"),2) 
     sdpixel =  '   Standard Dev:  ' +  strtrim(string(sd_st_pixel[2],format="(g14.6)"),2)
     svar =     '       Variance:  '+  strtrim(string(sd_var[2],format="(g14.6)"),2)
     sdpixel =  '  STDEV (Pixel):  ' +  strtrim(string(sd_st_pixel[2],format="(g14.6)"),2)
     sdmean =   '   STDEV (Mean):  '+ strtrim( string(sd_st_mean[2],format="(g14.6)"),2)
     smin =     '            Min:  '+ strtrim(string(sd_min[2],format="(g14.6)"),2) 
     smax =     '            Max:  '+strtrim( string(sd_max[2],format="(g14.6)"),2)
     smed     = '         Median:  '+strtrim( string(sd_median[2],format="(g14.6)"),2)
    
     amplab = Widget_Label(resbase, Value = stitle)
     meanlab = Widget_Label(resbase, Value = smean)
     sdplab = Widget_Label(resbase, Value = sdpixel)
     minlab = Widget_Label(resbase, Value = smin)
     maxlab = Widget_Label(resbase, Value = smax)
     medlab = Widget_Label(resbase, Value = smed)
;_______________________________________________________________________
     resbase = Widget_Base(row1, /column , /Frame)
     stitle =   '  Amplifier 4  (zoom)'
     smean =    '           Mean:  ' + strtrim(string(sd_mean[3],format="(g14.6)"),2) 
     sdpixel =  '   Standard Dev:  ' +  strtrim(string(sd_st_pixel[3],format="(g14.6)"),2)
     svar =     '       Variance:  '+  strtrim(string(sd_var[3],format="(g14.6)"),2)
     sdpixel =  '  STDEV (Pixel):  ' +  strtrim(string(sd_st_pixel[3],format="(g14.6)"),2)
     sdmean =   '   STDEV (Mean):  '+ strtrim( string(sd_st_mean[3],format="(g14.6)"),2)
     smin =     '            Min:  '+ strtrim(string(sd_min[3],format="(g14.6)"),2) 
     smax =     '            Max:  '+strtrim( string(sd_max[3],format="(g14.6)"),2)
     smed     = '         Median:  '+strtrim( string(sd_median[3],format="(g14.6)"),2)

     amplab = Widget_Label(resbase, Value = stitle)
     meanlab = Widget_Label(resbase, Value = smean)
     sdplab = Widget_Label(resbase, Value = sdpixel)
     minlab = Widget_Label(resbase, Value = smin)
     maxlab = Widget_Label(resbase, Value = smax)
     medlab = Widget_Label(resbase, Value = smed)
    
  endif
  
  info.jwst_AmpRateStatDisplay = StatChannelInfo
  stat = {info                  : info}	
  Widget_Control,info.jwst_AmpRateStatDisplay,Set_UValue=stat
  widget_control,info.jwst_AmpRateStatDisplay,/realize

  XManager,'amprate_stat',StatChannelInfo,/No_Block
  Widget_Control,info.jwst_QuickLook,Set_UValue=info

end
