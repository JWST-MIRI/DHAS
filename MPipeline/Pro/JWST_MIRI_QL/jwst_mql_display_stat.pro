;***********************************************************************
pro jwst_mql_stat_quit,event
widget_control,event.top, Get_UValue = tinfo
widget_control,tinfo.info.jwst_QuickLook,Get_UValue=info
widget_control,info.jwst_StatInfo,/destroy
end

;_______________________________________________________________________
; This program produces a widget that gives statistical information
; on an image. The statisical information was determined by the
; program jwst_get_image_stat.pro

pro jwst_mql_display_stat,info

window,4,/pixmap
wdelete,4
if(XRegistered ('mstat')) then begin
    widget_control,info.jwst_StatInfo,/destroy
endif

;_______________________________________________________________________
;*********
;Setup main panel
;*********
i = info.jwst_image.integrationNO
j = info.jwst_image.frameNO

if(info.jwst_data.read_all eq 0) then begin
    i = 0
    if(info.jwst_data.num_frames ne info.jwst_data.ngroups) then begin 
        j = info.jwst_image.frameNO- info.jwst_control.frame_start
    endif
endif

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

ngood = lonarr(3)
nbad = lonarr(3)

stitle[0] = " Statistics on Science Image "
; These statistics were filled in after they where read in (read_multi_frames) 
; mask and does not include the reference pixels for the statistics. 

mean[0] = info.jwst_image.stat[0]
st_pixel[0] = info.jwst_image.stat[1]
var[0] = st_pixel[0]*st_pixel[0]
min[0] = info.jwst_image.stat[2]
max[0] = info.jwst_image.stat[3]
median[0] = info.jwst_image.stat[4]
st_mean[0] = info.jwst_image.stat[5]

stitle[1] = " Statistics on Zoom Image "
mean[1] = info.jwst_image.zoom_stat[0]
st_pixel[1] = info.jwst_image.zoom_stat[1]
var[1] = st_pixel[1]*st_pixel[1] 
min[1] = info.jwst_image.zoom_stat[2] 
max[1] = info.jwst_image.zoom_stat[3] 
median[1] = info.jwst_image.zoom_stat[4] 
st_mean[1] = info.jwst_image.zoom_stat[5] 

xstart = info.jwst_image.x_zoom_start
xend = info.jwst_image.x_zoom_end
ystart = info.jwst_image.y_zoom_start
yend = info.jwst_image.y_zoom_end

if(info.jwst_image.data_type[2] eq 1) then begin 
   stitle[2] = " Statistics on Rate Image "
   mean[2] = info.jwst_data.reduced_stat[0,0]
   st_pixel[2] = info.jwst_data.reduced_stat[2,0]
   var[2] = st_pixel[2]*st_pixel[2,0]
   min[2] = info.jwst_data.reduced_stat[3,0]
   max[2] = info.jwst_data.reduced_stat[4,0]
   median[2] = info.jwst_data.reduced_stat[2,0]
   st_mean[2] = info.jwst_data.reduced_stat[7,0]
endif

if(info.jwst_image.data_type[2] eq 2) then begin 
   stitle[2] = " Statistics on Rate Int Image "
   mean[2] = info.jwst_data.reducedint_stat[0,0]
   st_pixel[2] = info.jwst_data.reducedint_stat[2,0]
   var[2] = st_pixel[2]*st_pixel[2,0]
   min[2] = info.jwst_data.reducedint_stat[3,0]
   max[2] = info.jwst_data.reducedint_stat[4,0]
   median[2] = info.jwst_data.reducedint_stat[2,0]
   st_mean[2] = info.jwst_data.reducedint_stat[7,0]
endif

if(info.jwst_image.data_type[2] eq 3) then begin 
   stitle[2] = " Statistics on Calibrated Image "
   mean[2] = info.jwst_data.reduced_cal_stat[0,0]
   st_pixel[2] = info.jwst_data.reduced_cal_stat[2,0]
   var[2] = st_pixel[2]*st_pixel[2,0]
   min[2] = info.jwst_data.reduced_cal_stat[3,0]
   max[2] = info.jwst_data.reduced_cal_stat[4,0]
   median[2] = info.jwst_data.reduced_cal_stat[2,0]
   st_mean[2] = info.jwst_data.reduced_cal_stat[7,0]
endif
statinfo = widget_base(title="Statistics on Images",$
                         col = 1,mbar = menuBar,group_leader = info.jwst_RawQuickLook,$
                           xsize = 730,ysize = 270,/align_right)
lineid = widget_base(statinfo,row = 1)
si = strtrim(string(info.jwst_image.integrationNO+1),2)
sj = strtrim(string(info.jwst_image.frameNO+1),2)
st = 'Integration: ' + si + '    Frame: ' + sj
label = widget_label(lineid,value=st,/align_center,font=info.font5)
nolable = widget_label(lineid,value='   No reference pixels included',font = info.font5)

graphID_master1 = widget_base(statinfo,row=1)
graphID = lonarr(3)
graphID[0] = widget_base(graphID_master1,col=1)
graphID[1] = widget_base(graphID_master1,col=1)
graphID[2] = widget_base(graphID_master1,col=1)
;********
; build the menubar
;********
QuitMenu = widget_button(menuBar,value="Quit",font = info.font2)
quitbutton = widget_button(quitmenu,value="Quit",event_pro='jwst_mql_stat_quit')
;_______________________________________________________________________
for i = 0,2 do begin 
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
        if(info.jwst_data.subarray eq 0) then begin
            if(xstart lt 4) then xstart = 4
            if(xend gt 1028) then xend = 1028
        endif
        sxrange =   ' X pixel range :  '+ strtrim( string(xstart+1,format="(g14.6)"),2) + ' to ' +$
                    strtrim( string(xend+1,format="(g14.6)"),2)
        syrange =   ' Y pixel range :  '+ strtrim( string(ystart+1,format="(g14.6)"),2) + ' to ' +$
                strtrim( string(yend+1,format="(g14.6)"),2)
        xrangelab = Widget_Label(resbase, Value = sxrange)
        yrangelab = Widget_Label(resbase, Value = syrange)
    endif
endfor

info.jwst_StatInfo = statinfo

stat = {info                  : info}	

Widget_Control,info.jwst_StatInfo,Set_UValue=stat
widget_control,info.jwst_StatInfo,/realize

XManager,'mstat',info.jwst_statinfo,/No_Block
Widget_Control,info.jwst_QuickLook,Set_UValue=info

end
