;***********************************************************************
pro msql_stat_quit,event
widget_control,event.top, Get_UValue = tinfo
widget_control,tinfo.info.QuickLook,Get_UValue=info
widget_control,info.Slope_StatInfo,/destroy
end


;_______________________________________________________________________
; This program produces a widget that gives statistical information
; on an image. The statisical information was determined by the
; program get_image_stat.pro

pro msql_display_stat,info

window,4,/pixmap
wdelete,4
if(XRegistered ('mstat_slope')) then begin
    widget_control,info.Slope_StatInfo,/destroy
endif

;_______________________________________________________________________
;*********
;Setup main panel
;*********
i = info.slope.integrationNO

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
skew = fltarr(3)
ngood = lonarr(3)
nbad = lonarr(3)

stitle[0] = " Statistics on Window 1 "
mean[0] = info.data.slope_stat[0,info.slope.plane[0]]
st_pixel[0] = info.data.slope_stat[2,info.slope.plane[0]]
var[0] = st_pixel[0]*st_pixel[0]
min[0] = info.data.slope_stat[3,info.slope.plane[0]]
max[0] = info.data.slope_stat[4,info.slope.plane[0]]
median[0] = info.data.slope_stat[1,info.slope.plane[0]]
st_mean[0] = info.data.slope_stat[7,info.slope.plane[0]]
skew[0] = info.data.slope_stat[8,info.slope.plane[0]]

ngood[0] = info.data.slope_stat[9,info.slope.plane[0]]
nbad[0] = info.data.slope_stat[10,info.slope.plane[0]]


stitle[1] = " Statistics on Zoom Image "
mean[1] = info.slope.zoom_stat[0]
st_pixel[1] = info.slope.zoom_stat[1]

var[1] = st_pixel[1]*st_pixel[1] 

min[1] = info.slope.zoom_stat[2] 
max[1] = info.slope.zoom_stat[3] 
median[1] = info.slope.zoom_stat[4] 
st_mean[1] = info.slope.zoom_stat[5] 
Skew[1]= info.slope.zoom_stat[6] 
ngood[1] = info.slope.zoom_stat[7] 
nbad[1] = info.slope.zoom_stat[8] 

xstart = info.slope.x_zoom_start
xend = info.slope.x_zoom_end
ystart = info.slope.y_zoom_start
yend = info.slope.y_zoom_end


stitle[2] = " Statistics on Window 3"
mean[2] = info.data.slope_stat[0,info.slope.plane[2]]
st_pixel[2] = info.data.slope_stat[2,info.slope.plane[2]]
var[2] = st_pixel[2]*st_pixel[2]
min[2] = info.data.slope_stat[3,info.slope.plane[2]]
max[2] = info.data.slope_stat[4,info.slope.plane[2]]
median[2] = info.data.slope_stat[1,info.slope.plane[2]]
st_mean[2] = info.data.slope_stat[7,info.slope.plane[2]]
skew[2] = info.data.slope_stat[8,info.slope.plane[2]]
ngood[2] = info.data.slope_stat[9,info.slope.plane[2]]
nbad[2] = info.data.slope_stat[10,info.slope.plane[2]]


statinfo = widget_base(title="Statisics on Slope Images (without reference pixels)",$
                         col=1,mbar=menuBar,group_leader=info.SlopeQuickLook,$
                           xsize = 780,ysize = 280,/align_right)

si = strtrim(string(info.slope.integrationNO+1),2)
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
quitbutton = widget_button(quitmenu,value="Quit",event_pro='msql_stat_quit')

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
    sskew =    '           Skew:       '+strtrim( string(skew[i],format="(g14.6)"),2)
    sgood =    '# of Good Pixels:      '+strtrim( string(ngood[i],format="(i10)"),2)
    sbad  =    '# of Sat or Pixels Flagged as Bad:   '+strtrim( string(nbad[i],format="(i10)"),2)

 
    titlelab = Widget_Label(resbase, Value = stit)
    meanlab = Widget_Label(resbase, Value = smean)
    sdplab = Widget_Label(resbase, Value = sdpixel)
    minlab = Widget_Label(resbase, Value = smin)
    maxlab = Widget_Label(resbase, Value = smax)
    medlab = Widget_Label(resbase, Value = smed)
    sklab = Widget_Label(resbase, Value = sskew)
    sg = Widget_Label(resbase, Value = sgood)
    sn = Widget_Label(resbase, Value = sbad)

    if(i eq 1 )  then begin
        sxrange =   ' X pixel range :  '+ strtrim( string(xstart+1,format="(g14.6)"),2) + ' to ' +$
                    strtrim( string(xend+1,format="(g14.6)"),2)
        syrange =   ' Y pixel range :  '+ strtrim( string(ystart+1,format="(g14.6)"),2) + ' to ' +$
                strtrim( string(yend+1,format="(g14.6)"),2)
        xrangelab = Widget_Label(resbase, Value = sxrange)
        yrangelab = Widget_Label(resbase, Value = syrange)
    endif

    info_label = widget_button(resbase,value = 'Info on Bad Pixels',$
                                               event_pro = 'info_badpixel',/align_left)

endfor

info.slope_StatInfo = statinfo

stat = {info                  : info}	



Widget_Control,info.slope_StatInfo,Set_UValue=stat
widget_control,info.slope_StatInfo,/realize

XManager,'mstat_slope',info.slope_statinfo,/No_Block
Widget_Control,info.QuickLook,Set_UValue=info

end
