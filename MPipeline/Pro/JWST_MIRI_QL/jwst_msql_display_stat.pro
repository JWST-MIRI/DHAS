;***********************************************************************
pro jwst_msql_stat_quit,event
widget_control,event.top, Get_UValue = tinfo
widget_control,tinfo.info.jwst_QuickLook,Get_UValue=info
widget_control,info.jwst_Slope_StatInfo,/destroy
end
;_______________________________________________________________________
; This program produces a widget that gives statistical information
; on an image. The statisical information was determined by the
; program jwst_get_image_stat.pro

pro jwst_msql_display_stat,info

window,4,/pixmap
wdelete,4
if(XRegistered ('mstat_slope')) then begin
    widget_control,info.jwst_Slope_StatInfo,/destroy
endif

;_______________________________________________________________________
;*********
;Setup main panel
;*********
i = info.jwst_slope.integrationNO

xstart = 0 & xend = 0 
ystart = 0 & yend = 0 

stitle = strarr(3)
mean = fltarr(3)
st_pixel = fltarr(3)
var = fltarr(3)
min = fltarr(3)
max = fltarr(3)
median = fltarr(3)
st_mean  = fltarr(3)

stitle[0] = " Statistics on Window 1 "
plane = info.jwst_slope.plane[0]
if(plane le 2) then begin
   stat = info.jwst_data.ratefinal_stat
endif
if(plane gt 2) then begin
   stat = info.jwst_data.rateint_stat
   plane = plane - 3
endif

mean[0] = stat[0,plane]
st_pixel[0] = stat[2,plane]
var[0] = st_pixel[0]*st_pixel[0]
min[0] = stat[3,plane]
max[0] = stat[4,plane]
median[0] =stat[1,plane]
st_mean[0] = stat[7,plane]

stitle[1] = " Statistics on Zoom Image "

mean[1] = info.jwst_slope.zoom_stat[0]
st_pixel[1] = info.jwst_slope.zoom_stat[1]
var[1] = st_pixel[1]*st_pixel[1] 

min[1] = info.jwst_slope.zoom_stat[2] 
max[1] = info.jwst_slope.zoom_stat[3] 
median[1] = info.jwst_slope.zoom_stat[4] 
st_mean[1] = info.jwst_slope.zoom_stat[5] 

xstart = info.jwst_slope.x_zoom_start
xend = info.jwst_slope.x_zoom_end
ystart = info.jwst_slope.y_zoom_start
yend = info.jwst_slope.y_zoom_end

stitle[2] = " Statistics on Window 2"
plane = info.jwst_slope.plane[1]
if(plane le 2) then begin
   stat = info.jwst_data.ratefinal_stat
endif
if(plane gt 2) then begin
   stat = info.jwst_data.rateint_stat
   plane = plane - 3
endif
mean[2] = stat[0,plane]
st_pixel[2] = stat[2,plane]
var[2] = st_pixel[2]*st_pixel[1]
min[2] = stat[3,plane]
max[2] = stat[4,plane]
median[2] = stat[1,plane]
st_mean[2] = stat[7,plane]

statinfo = widget_base(title="Statisics on Slope Images (without reference pixels)",$
                         col=1,mbar=menuBar,group_leader=info.jwst_SlopeQuickLook,$
                           xsize = 780,ysize = 280,/align_right)

si = strtrim(string(info.jwst_slope.integrationNO+1),2)
st = 'Integration: ' + si 
label = widget_label(statinfo,value=st,/align_center,font=info.font5)

graphID_master1 = widget_base(statinfo,row=1)

graphID = lonarr(3)
graphID[0] = widget_base(graphID_master1,col=1)
graphID[1] = widget_base(graphID_master1,col=1)
graphID[2] = widget_base(graphID_master1,col=1)
;********
; build the menubar
;********
QuitMenu = widget_button(menuBar,value="Quit",font = info.font2)
quitbutton = widget_button(quitmenu,value="Quit",event_pro='jwst_msql_stat_quit')

;_______________________________________________________________________
for i = 0,2 do begin 
;    resbase = Widget_Base(statInfo, /column, /Frame)
    resbase = Widget_Base(graphid[i], /column, /Frame)
    stit  =    stitle[i]
    smean =    '           Mean:       ' + strtrim(string(mean[i],format="(g14.6)"),2) 
    sdpixel =  'Standard Deviation:    ' +  strtrim(string(st_pixel[i],format="(g14.6)"),2)
    smin =     '            Min:       '+ strtrim(string(min[i],format="(g14.6)"),2) 
    smax =     '            Max:       '+strtrim( string(max[i],format="(g14.6)"),2)
    smed     = '         Median:       '+strtrim( string(median[i],format="(g14.6)"),2)
 
    titlelab = Widget_Label(resbase, Value = stit)
    meanlab = Widget_Label(resbase, Value = smean)
    sdplab = Widget_Label(resbase, Value = sdpixel)
    minlab = Widget_Label(resbase, Value = smin)
    maxlab = Widget_Label(resbase, Value = smax)
    medlab = Widget_Label(resbase, Value = smed)

    if(i eq 1 )  then begin
        sxrange =   ' X pixel range :  '+ strtrim( string(xstart+1,format="(g14.6)"),2) + ' to ' +$
                    strtrim( string(xend+1,format="(g14.6)"),2)
        syrange =   ' Y pixel range :  '+ strtrim( string(ystart+1,format="(g14.6)"),2) + ' to ' +$
                strtrim( string(yend+1,format="(g14.6)"),2)
        xrangelab = Widget_Label(resbase, Value = sxrange)
        yrangelab = Widget_Label(resbase, Value = syrange)
    endif

endfor
info.jwst_slope_StatInfo = statinfo
stat = {info                  : info}	



Widget_Control,info.jwst_slope_StatInfo,Set_UValue=stat
widget_control,info.jwst_slope_StatInfo,/realize

XManager,'mstat_slope',info.jwst_slope_statinfo,/No_Block
Widget_Control,info.jwst_QuickLook,Set_UValue=info

end
