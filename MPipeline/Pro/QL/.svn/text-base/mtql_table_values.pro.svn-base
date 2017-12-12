;***********************************************************************
pro mtql_table_values_quit,event
widget_control,event.top, Get_UValue = tinfo
widget_control,tinfo.info.QuickLook,Get_UValue=info
widget_control,info.TelTable,/destroy
end
;***********************************************************************



;***********************************************************************
;_______________________________________________________________________
;***********************************************************************
pro mtql_table_values_event,event

Widget_Control,event.id,Get_uValue=event_name
widget_control,event.top, Get_UValue = ginfo
widget_control,ginfo.info.QuickLook,Get_Uvalue = info


if (widget_info(event.id,/TLB_SIZE_EVENTS) eq 1 ) then begin
    info.telemetry.xwindowsize_table = event.x
    info.telemetry.ywindowsize_table = event.y
    info.telemetry.uwindowsize_table = 1
    widget_control,event.top,set_uvalue = ginfo
    widget_control,ginfo.info.Quicklook,set_uvalue = info
    mtql_table_values,info
    return
endif

end


;_______________________________________________________________________
; The parameters for this widget are contained in the image_pixel
; structure, rather than a local imbedded structure because
; mql_event.pro also calls to update the pixel info widget

pro mtql_table_values,info

window,4,/pixmap
wdelete,4
if(XRegistered ('mtqltable')) then begin
    widget_control,info.TelTable,/destroy
endif

;_______________________________________________________________________
;*********
;Setup main panel
;*********

; widget window parameters
xwidget_size = 1300
ywidget_size = 900

xsize_scroll = 1100
ysize_scroll = 600



if(info.telemetry.uwindowsize_table eq 1) then begin
    xsize_scroll = info.telemetry.xwindowsize_table
    ysize_scroll = info.telemetry.ywindowsize_table
    
endif
if(info.control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.control.x_scroll_window
if(info.control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.control.y_scroll_window
if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10


TableInfo = widget_base(title=" Table of HouseKeeping Values",$
                         col = 1,mbar = menuBar,group_leader = info.QuickLook,$
                        xsize = xwidget_size,ysize =ywidget_size,/base_align_right,$
                        /scroll,y_scroll_size= ysize_scroll,$
                        x_scroll_size= xsize_scroll,$
                        yoffset=100,/TLB_SIZE_EVENT)

;********
; build the menubar
;********
QuitMenu = widget_button(menuBar,value="Quit",font = info.font2)
quitbutton = widget_button(quitmenu,value="Quit",event_pro='mtql_table_values_quit')



draw_window_id = info.telemetry.draw_window_id
n_poss_lines = info.telemetry.n_poss_lines
filebase_tel = info.control.filebase_tel
x_vals_all = (*info.telemetry.px_vals)

ntimes = info.telemetry.ntimes
line_vals = info.telemetry.line_vals

teltype = (*info.telemetry.pteltype)
telstring = (*info.telemetry.ptelstring)
telstring_num = (*info.telemetry.ptelstring_num)

y_vals_all = (*info.telemetry.pkdata_org)
key_str_all = (*info.telemetry.pkname)    
intvalue = (*info.telemetry.pintvalue)
nstring  =  info.telemetry.nstring 


x_vals_all = x_vals_all - info.telemetry.start_time

ntimes = intarr(4)
nvalues = intarr(4)
this_type = intarr(4)
for i = 0, 3 do begin
    this_type[i] = info.telemetry.type[i] -1
    nvalues[i] = info.telemetry.nvalues[this_type[i]]
    ntimes[i] = info.telemetry.ntimes[this_type[i]]
endfor    


; Table Display
;*********

infoID  = widget_label(tableinfo,value=' Telemetry Files ',/align_left,font=info.font5)

For i = 0,5 do begin
    if(info.telemetry.file_exist[i] eq 1) then begin
        file_title = widget_label(tableinfo,value = info.telemetry.files[i],/align_left)
    endif
endfor
stime = string(info.telemetry.start_time,format='(f20.2)')
stime = strcompress(stime,/remove_all)
infoID  = widget_label(tableinfo,value=' Start Time ' + stime ,/align_left,font=info.font5)
master1 = widget_base(tableinfo,row=1,/align_left)
master2 = widget_base(tableinfo,row=1,/align_left)

master11 = widget_base(master1,col=1,/align_left)
master12 = widget_base(master1,col=1,/align_left)
master21 = widget_base(master1,col=1,/align_left)
master22 = widget_base(master1,col=1,/align_left)
tel_base = lonarr(4)

tel_base[0] = widget_base(master11,col=1,/align_left)
tel_base[1] = widget_base(master12,col=1,/align_left)
tel_base[2] = widget_base(master21,col=1,/align_left)
tel_base[3] = widget_base(master22,col=1,/align_left)

;_______________________________________________________________________
;
value1 = strarr(ntimes[0]+3)
value2 = strarr(ntimes[0]+3)

; Values for first telemetry value
if(info.telemetry.type[0] ne 0 and line_vals[0] ne 0) then begin 

    data1 = strarr(ntimes[0])
    time1 = fltarr(ntimes[0])
    data1 = y_vals_all[line_vals[0] - 1,0:ntimes[0]-1,this_type[0]]
    time1 = x_vals_all[0:ntimes[0]-1,this_type[0]]
 
    key_str1 = key_str_all[line_vals[0]-1,info.telemetry.type[0]-1] + '('+ info.tel_types[info.telemetry.type[0]] + ')'


    for k = 0, ntimes[0]+2 do begin
        if(k eq 0 ) then begin
            time = 'Time from'
            tel = 'Housekeeping'
            timevalue  =  ' '
            telvalue = ' ' 
        endif else if(k eq 1 ) then begin
            time = 'Start Time (sec)'
            tel = 'Value'
            timevalue  =  ' '
            telvalue = ' ' 
        endif else if(k eq 2 ) then begin
            time = ' '
            tel = ' '
            timevalue  =  ' '
            telvalue = ' ' 
        endif else begin 
            time = strcompress(string(k-2),/remove_all) + ': '
            tel = ''
            timevalue = strtrim(string(time1[k-3]),2) 
            telvalue = strtrim(string(data1[k-3]),2)
        endelse
        value1[k] = time + timevalue
        value2[k] = tel + telvalue
    endfor
    tel_1ID = widget_label(tel_base[0],value =key_str1,/align_left)
    pix2 = widget_base(tel_base[0],row=1,/align_left)
    pixID1 = widget_list(pix2,$
                         value=value1,/align_left,$
                         scr_ysize=500,uvalue = '')

    pixID2 = widget_list(pix2,$
                         value=value2,/align_left,$
                         scr_ysize=500,uvalue= '')
endif


;_______________________________________________________________________
; Values for second telemetry value
value1 = strarr(ntimes[1]+3)
value2 = strarr(ntimes[1]+3)

if(info.telemetry.type[1] ne 0 and line_vals[1] ne 0) then begin 

    data2 = strarr(ntimes[1])
    time2 = fltarr(ntimes[1])
    data2 =y_vals_all[line_vals[1] - 1,0:ntimes[1]-1,this_type[1]]
    time2 = x_vals_all[0:ntimes[1]-1,this_type[1]]

    for k = 0, ntimes[1]+2 do begin
        if(k eq 0 ) then begin
            time = 'Time from'
            tel = 'Housekeeping'
            timevalue  =  ' '
            telvalue = ' ' 
        endif else if(k eq 1 ) then begin
            time = 'Start Time (sec)'
            tel = 'Value'
            timevalue  =  ' '
            telvalue = ' ' 
        endif else if(k eq 2 ) then begin
            time = ' '
            tel = ' '
            timevalue  =  ' '
            telvalue = ' ' 
        endif else begin 
            time = strcompress(string(k-2),/remove_all) + ': '
            tel = ''
            timevalue = strtrim(string(time2[k-3]),2) 
            telvalue = strtrim(string(data2[k-3]),2)
        endelse
        value1[k] = time + timevalue
        value2[k] = tel + telvalue
    endfor

    key_str2 = key_str_all[line_vals[1]-1,info.telemetry.type[1]-1]+ '('+ info.tel_types[info.telemetry.type[1]] + ')'
    tel_2ID = widget_label(tel_base[1],value =key_str2,/align_left)

    pix2 = widget_base(tel_base[1],row=1,/align_left)
    pixID1 = widget_list(pix2,$
                         value=value1,/align_left,$
                         scr_ysize=500,uvalue = '')

    pixID2 = widget_list(pix2,$
                         value=value2,/align_left,$
                         scr_ysize=500,uvalue= '')
endif
;_______________________________________________________________________
; Values for third telemetry value
value1 = strarr(ntimes[2]+3)
value2 = strarr(ntimes[2]+3)
if(info.telemetry.type[2] ne 0 and line_vals[2] ne 0) then begin 

    data3 = strarr(ntimes[2])
    time3 = fltarr(ntimes[2])
    data3 =y_vals_all[line_vals[2] - 1,0:ntimes[2]-1,this_type[2]]
    time3 = x_vals_all[0:ntimes[2]-1,this_type[2]]

    for k = 0, ntimes[2]+2 do begin
        if(k eq 0 ) then begin
            time = 'Time from'
            tel = 'Housekeeping'
            timevalue  =  ' '
            telvalue = ' ' 
        endif else if(k eq 1 ) then begin
            time = 'Start Time (sec)'
            tel = 'Value'
            timevalue  =  ' '
            telvalue = ' ' 
        endif else if(k eq 2 ) then begin
            time = ' '
            tel = ' '
            timevalue  =  ' '
            telvalue = ' ' 
        endif else begin 
            time = strcompress(string(k-2),/remove_all) + ': '
            tel = ''
            timevalue = strtrim(string(time3[k-3]),2) 
            telvalue = strtrim(string(data3[k-3]),2)
        endelse
        value1[k] = time + timevalue
        value2[k] = tel + telvalue
    endfor

    key_str3 = key_str_all[line_vals[2]-1,info.telemetry.type[2]-1]+ '('+ info.tel_types[info.telemetry.type[2]] + ')'
    tel_3ID = widget_label(tel_base[2],value =key_str3,/align_left)
    pix2 = widget_base(tel_base[2],row=1,/align_left)
    pixID1 = widget_list(pix2,$
                         value=value1,/align_left,$
                         scr_ysize=500,uvalue = '')
    
    pixID2 = widget_list(pix2,$
                         value=value2,/align_left,$
                         scr_ysize=500,uvalue = '')
endif
;_______________________________________________________________________
; Values for forth telemetry value
value1 = strarr(ntimes[3]+3)
value2 = strarr(ntimes[3]+3)
if(info.telemetry.type[3] ne 0 and line_vals[3] ne 0) then begin 
    data4 = strarr(ntimes[3])
    time4 = fltarr(ntimes[3])
    data4 =y_vals_all[line_vals[3] - 1,0:ntimes[3]-1,this_type[3]]
    time4 = x_vals_all[0:ntimes[3]-1,this_type[3]]

    for k = 0, ntimes[3]+2 do begin
        if(k eq 0 ) then begin
            time = 'Time from'
            tel = 'Housekeeping'
            timevalue  =  ' '
            telvalue = ' ' 
        endif else if(k eq 1 ) then begin
            time = 'Start Time (sec)'
            tel = 'Value'
            timevalue  =  ' '
            telvalue = ' ' 
        endif else if(k eq 2 ) then begin
            time = ' '
            tel = ' '
            timevalue  =  ' '
            telvalue = ' ' 
        endif else begin 
            time = strcompress(string(k-2),/remove_all) + ': '
            tel = ''
            timevalue = strtrim(string(time4[k-3]),2) 
            telvalue = strtrim(string(data4[k-3]),2)
        endelse
        value1[k] = time + timevalue
        value2[k] = tel + telvalue
    endfor
    key_str4 = key_str_all[line_vals[3]-1,info.telemetry.type[3]-1]+ '('+ info.tel_types[info.telemetry.type[3]] + ')'
    tel_4ID = widget_label(tel_base[3],value =key_str4,/align_left)
    
    pix2 = widget_base(tel_base[3],row=1,/align_left)
    pixID1 = widget_list(pix2,$
                         value=value1,/align_left,$
                         scr_ysize=500,uvalue = '')
    
    pixID2 = widget_list(pix2,$
                         value=value2,/align_left,$
                         scr_ysize=500,uvalue = '')
endif

info.TelTable = tableinfo

tel = {info                  : info}	


value1 =0
value2 = 0
Widget_Control,info.TelTable,Set_UValue=tel
widget_control,info.TelTable,/realize

XManager,'mtqltable',tableinfo,/No_Block,event_handler = 'mtql_table_values_event'

Widget_Control,info.QuickLook,Set_UValue=info

end









;***********************************************************************
;***********************************************************************
pro mtql_table_raw_values_quit,event
widget_control,event.top, Get_UValue = tinfo
widget_control,tinfo.info.QuickLook,Get_UValue=info
widget_control,info.TelTableRaw,/destroy
end
;***********************************************************************



;***********************************************************************
;_______________________________________________________________________
;***********************************************************************
pro mtql_table_raw_values_event,event

Widget_Control,event.id,Get_uValue=event_name
widget_control,event.top, Get_UValue = ginfo
widget_control,ginfo.info.QuickLook,Get_Uvalue = info


if (widget_info(event.id,/TLB_SIZE_EVENTS) eq 1 ) then begin
    info.telemetry_raw.xwindowsize_table = event.x
    info.telemetry_raw.ywindowsize_table = event.y
    info.telemetry_raw.uwindowsize_table = 1
    widget_control,event.top,set_uvalue = ginfo
    widget_control,ginfo.info.Quicklook,set_uvalue = info
    mtql_table_raw_values,info
    return
endif

end


;_______________________________________________________________________
; The parameters for this widget are contained in the image_pixel
; structure, rather than a local imbedded structure because
; mql_event.pro also calls to update the pixel info widget

pro mtql_table_raw_values,info

window,4,/pixmap
wdelete,4
if(XRegistered ('mtql_rawtable')) then begin
    widget_control,info.TelTableRaw,/destroy
endif

;_______________________________________________________________________
;*********
;Setup main panel
;*********

; widget window parameters
xwidget_size = 1300
ywidget_size = 900

xsize_scroll = 1100
ysize_scroll = 600



if(info.telemetry_raw.uwindowsize_table eq 1) then begin
    xsize_scroll = info.telemetry_raw.xwindowsize_table
    ysize_scroll = info.telemetry_raw.ywindowsize_table
    
endif
if(info.control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.control.x_scroll_window
if(info.control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.control.y_scroll_window
if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10


TableInfo = widget_base(title=" Table of HouseKeeping Values- Raw",$
                         col = 1,mbar = menuBar,group_leader = info.QuickLook,$
                        xsize = xwidget_size,ysize =ywidget_size,/base_align_right,$
                        /scroll,y_scroll_size= ysize_scroll,$
                        x_scroll_size= xsize_scroll,$
                        yoffset=100,/TLB_SIZE_EVENT)

;********
; build the menubar
;********
QuitMenu = widget_button(menuBar,value="Quit",font = info.font2)
quitbutton = widget_button(quitmenu,value="Quit",event_pro='mtql_table_raw_values_quit')



draw_window_id = info.telemetry_raw.draw_window_id
n_poss_lines = info.telemetry_raw.n_poss_lines
filebase_tel = info.control.filebase_tel
x_vals_all = (*info.telemetry_raw.px_vals)

ntimes = info.telemetry_raw.ntimes
line_vals = info.telemetry_raw.line_vals

teltype = (*info.telemetry_raw.pteltype)
telstring = (*info.telemetry_raw.ptelstring)
telstring_num = (*info.telemetry_raw.ptelstring_num)

y_vals_all = (*info.telemetry_raw.pkdata)
key_str_all = (*info.telemetry_raw.pkname)    
intvalue = (*info.telemetry_raw.pintvalue)
nstring  =  info.telemetry_raw.nstring 

x_vals_all = x_vals_all - info.telemetry_raw.start_time


ntimes = intarr(4)
nvalues = intarr(4)
this_type = intarr(4)
for i = 0, 3 do begin
    this_type[i] = info.telemetry_raw.type[i] -1
    nvalues[i] = info.telemetry_raw.nvalues[this_type[i]]
    ntimes[i] = info.telemetry_raw.ntimes[this_type[i]]
endfor    








; Table Display
;*********

infoID  = widget_label(tableinfo,value=' Telemetry Files ',/align_left,font=info.font5)

For i = 0,5 do begin
    if(info.telemetry_raw.file_exist[i] eq 1) then begin
        file_title = widget_label(tableinfo,value = info.telemetry_raw.files[i],/align_left)
    endif
endfor

stime = string(info.telemetry_raw.start_time,format='(f20.2)')
stime = strcompress(stime,/remove_all)
infoID  = widget_label(tableinfo,value=' Start Time ' + stime ,/align_left,font=info.font5)
master1 = widget_base(tableinfo,row=1,/align_left)
master2 = widget_base(tableinfo,row=1,/align_left)

master11 = widget_base(master1,col=1,/align_left)
master12 = widget_base(master1,col=1,/align_left)
master21 = widget_base(master1,col=1,/align_left)
master22 = widget_base(master1,col=1,/align_left)
tel_base = lonarr(4)

tel_base[0] = widget_base(master11,col=1,/align_left)
tel_base[1] = widget_base(master12,col=1,/align_left)
tel_base[2] = widget_base(master21,col=1,/align_left)
tel_base[3] = widget_base(master22,col=1,/align_left)



;_______________________________________________________________________
;
value1 = strarr(ntimes[0]+3)
value2 = strarr(ntimes[0]+3)

if(info.telemetry_raw.type[0] ne 0 and line_vals[0] ne 0) then begin 
    data1 = lonarr(ntimes[0])
    time1 = fltarr(ntimes[0])
    data1 = long(y_vals_all[line_vals[0] - 1,0:ntimes[0]-1,this_type[0]])
    time1 = x_vals_all[0:ntimes[0]-1,this_type[0]] 
; Values for second telemetry value
    for k = 0, ntimes[0]+2 do begin
        if(k eq 0 ) then begin
            time = 'Time from'
            tel = 'Housekeeping'
            timevalue  =  ' '
            telvalue = ' ' 
        endif else if(k eq 1 ) then begin
            time = 'Start Time (sec)'
            tel = 'Value'
            timevalue  =  ' '
            telvalue = ' ' 
        endif else if(k eq 2 ) then begin
            time = ' '
            tel = ' '
            timevalue  =  ' '
            telvalue = ' ' 
        endif else begin 
            time = strcompress(string(k-2),/remove_all) + ': '
            tel = ''
            timevalue = strtrim(string(time1[k-3]),2) 
            telvalue = strtrim(string(data1[k-3]),2)
        endelse
        value1[k] = time + timevalue
        value2[k] = tel + telvalue
    endfor

    key_str1 = key_str_all[line_vals[0]-1,info.telemetry_raw.type[0]-1]+'('+ info.tel_types[info.telemetry_raw.type[0]] + ')'
    tel_1ID = widget_label(tel_base[0],value =key_str1,/align_left)
    pix2 = widget_base(tel_base[0],row=1,/align_left)
    pixID1 = widget_list(pix2,$
                         value=value1,/align_left,$
                         scr_ysize=500,uvalue = '')

    pixID2 = widget_list(pix2,$
                         value=value2,/align_left,$
                         scr_ysize=500,uvalue = '')
endif


;_______________________________________________________________________
; Values for second telemetry value
value1 = strarr(ntimes[1]+3)
value2 = strarr(ntimes[1]+3)

if(info.telemetry_raw.type[1] ne 0 and line_vals[1] ne 0) then begin 

    data2 = lonarr(ntimes[1])
    time2 = fltarr(ntimes[1])
    data2 = long(y_vals_all[line_vals[1] - 1,0:ntimes[1]-1,this_type[1]])
    time2 = x_vals_all[0:ntimes[1]-1,this_type[1]]
    for k = 0, ntimes[1]+2 do begin
        if(k eq 0 ) then begin
            time = 'Time from'
            tel = 'Housekeeping'
            timevalue  =  ' '
            telvalue = ' ' 
        endif else if(k eq 1 ) then begin
            time = 'Start Time (sec)'
            tel = 'Value'
            timevalue  =  ' '
            telvalue = ' ' 
        endif else if(k eq 2 ) then begin
            time = ' '
            tel = ' '
            timevalue  =  ' '
            telvalue = ' ' 
        endif else begin 
            time = strcompress(string(k-2),/remove_all) + ': '
            tel = ''
            timevalue = strtrim(string(time2[k-3]),2) 
            telvalue = strtrim(string(data2[k-3]),2)
        endelse
        value1[k] = time + timevalue
        value2[k] = tel + telvalue
    endfor

    key_str2 = key_str_all[line_vals[1]-1,info.telemetry_raw.type[1]-1]+'('+ info.tel_types[info.telemetry_raw.type[1]] + ')'
    tel_2ID = widget_label(tel_base[1],value =key_str2,/align_left)
    pix2 = widget_base(tel_base[1],row=1,/align_left)
    pixID1 = widget_list(pix2,$
                         value=value1,/align_left,$
                         scr_ysize=500,uvalue = '')

    pixID2 = widget_list(pix2,$
                         value=value2,/align_left,$
                         scr_ysize=500,uvalue = '')
endif
;_______________________________________________________________________
; Values for third telemetry value
value1 = strarr(ntimes[2]+3)
value2 = strarr(ntimes[2]+3)
if(info.telemetry_raw.type[2] ne 0 and line_vals[2] ne 0) then begin 
    data3 = lonarr(ntimes[2])
    time3 = fltarr(ntimes[2])
    data3 = long(y_vals_all[line_vals[2] - 1,0:ntimes[2]-1,this_type[2]])
    time3 = x_vals_all[0:ntimes[2]-1,this_type[2]]

    for k = 0, ntimes[2]+2 do begin
        if(k eq 0 ) then begin
            time = 'Time from'
            tel = 'Housekeeping'
            timevalue  =  ' '
            telvalue = ' ' 
        endif else if(k eq 1 ) then begin
            time = 'Start Time (sec)'
            tel = 'Value'
            timevalue  =  ' '
            telvalue = ' ' 
        endif else if(k eq 2 ) then begin
            time = ' '
            tel = ' '
            timevalue  =  ' '
            telvalue = ' ' 
        endif else begin 
            time = strcompress(string(k-2),/remove_all) + ': '
            tel = ''
            timevalue = strtrim(string(time3[k-3]),2) 
            telvalue = strtrim(string(data3[k-3]),2)
        endelse
        value1[k] = time + timevalue
        value2[k] = tel + telvalue
    endfor

    key_str3 = key_str_all[line_vals[2]-1,info.telemetry_raw.type[2]-1]+'('+ info.tel_types[info.telemetry_raw.type[2]] + ')'
    tel_3ID = widget_label(tel_base[2],value =key_str3,/align_left)
    pix2 = widget_base(tel_base[2],row=1,/align_left)
    pixID1 = widget_list(pix2,$
                         value=value1,/align_left,$
                         scr_ysize=500,uvalue = '')
    
    pixID2 = widget_list(pix2,$
                         value=value2,/align_left,$
                         scr_ysize=500,uvalue = '')
endif
;_______________________________________________________________________
; Values for forth telemetry value
value1 = strarr(ntimes[3]+3)
value2 = strarr(ntimes[3]+3)
if(info.telemetry_raw.type[3] ne 0 and line_vals[3] ne 0) then begin 

    data4 = lonarr(ntimes[3])
    time4 = fltarr(ntimes[3])
    data4 =  long(y_vals_all[line_vals[3] - 1,0:ntimes[3]-1,this_type[3]])
    time4 = x_vals_all[0:ntimes[3]-1,this_type[3]]

    for k = 0, ntimes[3]+2 do begin
        if(k eq 0 ) then begin
            time = 'Time from'
            tel = 'Housekeeping'
            timevalue  =  ' '
            telvalue = ' ' 
        endif else if(k eq 1 ) then begin
            time = 'Start Time (sec)'
            tel = 'Value'
            timevalue  =  ' '
            telvalue = ' ' 
        endif else if(k eq 2 ) then begin
            time = ' '
            tel = ' '
            timevalue  =  ' '
            telvalue = ' ' 
        endif else begin 
            time = strcompress(string(k-2),/remove_all) + ': '
            tel = ''
            timevalue = strtrim(string(time4[k-3]),2) 
            telvalue = strtrim(string(data4[k-3]),2)
        endelse
        value1[k] = time + timevalue
        value2[k] = tel + telvalue
    endfor

    key_str4 = key_str_all[line_vals[3]-1,info.telemetry_raw.type[3]-1]+'('+ info.tel_types[info.telemetry_raw.type[3]] + ')'
    tel_4ID = widget_label(tel_base[3],value =key_str4,/align_left)    
    pix2 = widget_base(tel_base[3],row=1,/align_left)
    pixID1 = widget_list(pix2,$
                         value=value1,/align_left,$
                         scr_ysize=500,uvalue = '')
    
    pixID2 = widget_list(pix2,$
                         value=value2,/align_left,$
                         scr_ysize=500,uvalue = '')
endif

info.TelTableRaw = tableinfo

tel = {info                  : info}	


value1 =0
value2 = 0
Widget_Control,info.TelTableRaw,Set_UValue=tel
widget_control,info.TelTableRaw,/realize

XManager,'mtql_rawtable',tableinfo,/No_Block,event_handler = 'mtql_table_raw_values_event'

Widget_Control,info.QuickLook,Set_UValue=info

end
