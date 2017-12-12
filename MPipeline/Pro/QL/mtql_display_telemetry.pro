; mtlq_display_telemetry.pro: produces a window to analyze the
; telemetry data.

 
@print_telemetry.pro
;_______________________________________________________________________


pro mtql_quit,event
widget_control,event.top, Get_UValue = tinfo
widget_control,tinfo.info.QuickLook,Get_UValue=info
widget_control,info.telemetryLook,/destroy
end


pro mtql_raw_quit,event
widget_control,event.top, Get_UValue = tinfo
widget_control,tinfo.info.QuickLook,Get_UValue=info
widget_control,info.telemetryLook_raw,/destroy
end

;_______________________________________________________________________
pro mtql_display_telemetry,info,ext


if(XRegistered ('mtql') and ext eq 1) then begin
    widget_control,info.telemetryLook,/destroy
endif

if(XRegistered ('mtql_raw') and ext eq 2) then begin
    widget_control,info.telemetryLook_raw,/destroy
endif
status= 0


if(ext eq 1) then  begin
    uwindowsize = info.telemetry.uwindowsize
endif
if(ext eq 2) then begin
    uwindowsize = info.telemetry_raw.uwindowsize
endif
;_______________________________________________________________________
if(uwindowsize eq 0) then begin ; user changed the widget window size - 
                                           ; only redisplay
    reading_telemetry_data,info,ext,status  

    if(status ne 0) then return 
endif


if(ext eq 1) then begin
    maxlen= info.telemetry.maxlen
    xwindowsize = info.telemetry.xwindowsize
    ywindowsize = info.telemetry.ywindowsize
    graphID = lonarr(info.telemetry.n_poss_lines+1)
    tel_type = info.telemetry.type
    type = tel_type[0]-1        ; default all to be the same and to be the one selected by the user
    nvalues = info.telemetry.nvalues[type]
    tname = strarr(nvalues)
    tname = (*info.telemetry.pkname)[*,type]
    maxstring = max(info.telemetry.nstring[*])
    n_poss_lines = info.telemetry.n_poss_lines
    t_title = " MIRI Quick Look- Telemetry: Converted Data"
endif

if(ext eq 2) then begin 
    maxlen= info.telemetry_raw.maxlen
    xwindowsize = info.telemetry_raw.xwindowsize
    ywindowsize = info.telemetry_raw.ywindowsize
    graphID = lonarr(info.telemetry_raw.n_poss_lines+1)
    tel_type = info.telemetry_raw.type
    type = tel_type[0]-1        ; default all to be the same and to be the one selected by the user
    nvalues = info.telemetry_raw.nvalues[type]
    tname = strarr(nvalues)
    tname = (*info.telemetry_raw.pkname)[*,type]
    maxstring = max(info.telemetry_raw.nstring[*])
    n_poss_lines = info.telemetry_raw.n_poss_lines
    t_title = " MIRI Quick Look- Telemetry: Raw Data"
endif
offset = 0

plot_ranges = fltarr(5,2)
plot_mmlabel = lonarr(5,2)
meanstdID = lonarr(4,2)
default_scale_graph = intarr(5)
default_scale_graph[*] = 1   ; Default Range flag
recomputeID = lonarr(5)

mmID = lonarr(4,2)
extralabelID = lonarr(4)
nptsID = lonarr(4)

;_______________________________________________________________________

    


tfontsize = info.font3
sfontsize = info.font4



if(max(maxlen[*]) gt 20) then begin
    tfontsize = info.font4
    sfontsize = info.font6
endif

if(status ne 0) then return
                                                
Widget_Control,info.QuickLook,Set_UValue=info
window,2,/pixmap
wdelete,2
;*********
;Setup main panel
;*********
max_scrsize  = 400
set_xsize = 10
dscrsize = [max_scrsize*2.0,max_scrsize]


; widget window parameters
xwidget_size = 1550
ywidget_size = 1200
xsize_scroll = 1250
ysize_scroll = 1000


if(uwindowsize eq 1) then begin ; user has set window size 
    xsize_scroll = xwindowsize
    ysize_scroll = ywindowsize
    
endif

if(info.control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.control.x_scroll_window
if(info.control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.control.y_scroll_window
if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10

TelemetryLook = widget_base(title=t_title + info.version ,col = 1,mbar = menuBar,$
                            group_leader = info.Quicklook,$
                           xsize = xwidget_size,$
                           ysize = ywidget_size,/scroll,$
                           x_scroll_size= xsize_scroll,$
                           y_scroll_size = ysize_scroll,/TLB_SIZE_EVENTS,/align_right)





stitle =" Telemetry plots for" + info.control.filename_tel
filelabelID = widget_label(TelemetryLook, $
                           value=stitle,/align_left, $
                           font=info.font1,/dynamic_resize)
clear_ql_info,info
widget_control,info.filetag[0] ,set_value = ' Telemetry file name: ' + info.control.filename_tel
;********
; build the menubar
;********
QuitMenu = widget_button(menuBar,value="Quit",font = info.font1)
PrintMenu = widget_button(menuBar,value="Print",font = info.font1)
XYMenu = widget_button(menuBar,value=" Plot Value 1 VS Value 2",font = info.font1)
;********
; button row for main pulldown menus
;********
                                                                                                 
; add quit button
if(ext eq 1) then begin 
    quitbutton = widget_button(quitmenu,value="Quit",event_pro='mtql_quit',font=info.font3)
    printbutton = widget_button(printmenu,value="Print",event_pro='print_telemetry',font=info.font3)
    xybutton = widget_button(xymenu,value="Plot Value 1 VS Value 2",event_pro='telemetry_plot',font=info.font3)
endif

if(ext eq 2 ) then begin 
    quitbutton = widget_button(quitmenu,value="Quit",event_pro='mtql_raw_quit',font=info.font3)
    printbutton = widget_button(printmenu,value="Print",event_pro='print_telemetry_raw',font=info.font3)
    xybutton = widget_button(xymenu,value="Plot Value 1 VS Value 2",event_pro='telemetry_plot',font=info.font3)
endif


;_______________________________________________________________________

;*********
; base for display
;*********


graphID_master1 = widget_base(telemetryLook,row=1); plotting
graphID_master2 = widget_base(telemetryLook,row=1); plotting
graphID1 = widget_base(graphID_master1,col=1)
keywordbaseID = widget_base(graphID_master2,row=1) 




pix_num_base = widget_base(graphID1,row=1,/align_center)
graphID[0] = widget_draw(graphID1,scr_xsize=dscrsize[0], $
                         scr_ysize=dscrsize[1],frame=2,retain=info.retn)
pix_num_base2 = widget_base(graphID1,row=1)
tlabelID = widget_label(pix_num_base2,value="X ->",font=info.font3)

plot_mmlabel[0,0] = cw_field(pix_num_base2,title="min:",font=info.font3, $
                                          uvalue="rp_1b",/float,/return_events, $
                                          value=plot_ranges[0,0],$
                                          xsize=set_xsize,fieldfont=info.font3)

plot_mmlabel[0,1] = cw_field(pix_num_base2,title="max:",font=fontname3, $
                                          uvalue="rp_1t",/float,/return_events, $
                                          value=plot_ranges[0,1],$
                                          xsize=set_xsize,fieldfont=info.font3)

recomputeID[0] = widget_button(pix_num_base2,uvalue="range1", $
                            value='Default Scale',/dynamic_resize,font=info.font3)


offset_choices= [ 'Do not Offset Y axes', 'Offset Y axes']
offsetID = widget_droplist(pix_num_base2,value=offset_choices, $
                                             uvalue='offset',font=info.font3)

getValuesID = widget_button(pix_num_base2,uvalue='Get_Values',font=info.font3,$
                                                  value = 'Print Telemetry Values to a Table')




;*****
; setup keywords to allow the choice of keywords to plot
;*****




linesize = [max_scrsize*0.25,max_scrsize*0.05]


linechoiceID = lonarr(4)
linechoices = ['None          ',tname]

housekeepingID = lonarr(4)
linechoiceID = lonarr(4)


if(maxstring eq 0) then maxstring = 1 ; set = 1 if not string values found
intvalue = lonarr(4,maxstring)
line_vals = intarr(4)

for i = 0,(n_poss_lines-1) do begin
    tmpbase1ID = widget_base(keywordbaseID,row=1)
    tmpbaseID = widget_base(tmpbase1ID,col=1)
    tmpbase2ID = widget_base(tmpbase1ID,col=1)
    ; graph box for color of telemetry values
    graphID[i+1] = widget_draw(tmpbaseID,scr_xsize=linesize[0],scr_ysize=linesize[1], $
                               frame=1,retain=info.retn)

    
    line_vals[i] = i + 2
    indx_str = strtrim(string(i+1),2)
    suvalue = "line"+ indx_str
    hvalue = "house"+indx_str

    housekeepingID[i] = widget_droplist(tmpbase2ID,value = info.tel_types,font=sfontsize,$
                                    uvalue=hvalue)
    widget_control,housekeepingID[i],set_droplist_select=tel_type[i]
    linechoiceID[i] = widget_list(tmpbase2ID,value=linechoices, $
                                  uvalue=suvalue,scr_ysize=310,font=sfontsize)
    

    widget_control,linechoiceID[i],set_list_select=info.telemetry.line_vals[i]
    indx_str = strtrim(string(i+2),2)
    suvalue = "rp_" + indx_str 
    
    plot_mmlabel[i+1,0]=cw_field(tmpbaseID,title="min:",font=tfontsize, $
                                                  uvalue=suvalue+"b",/float,$
                                                  /return_events, $
                                                  value=plot_ranges[i+1,0],$
                                                  xsize=set_xsize,fieldfont=tfontsize)

    plot_mmlabel[i+1,1]=cw_field(tmpbaseID,title="max:",font=tfontsize, $
                                                    uvalue=suvalue+"t",/float,$
                                                    /return_events, $
                                                    value=plot_ranges[i+1,1],$
                                                    xsize=set_xsize,fieldfont=tfontsize)

    suvalue = 'range' + indx_str
    recomputeID[i+1] = widget_button(tmpbaseID,uvalue=suvalue,$
                                                    font=info.font4, $
                                                    value='Default Range',/dynamic_resize)

    
    meanstdID[i,0] = widget_label(tmpbaseID,value="ave: 0.0",font=tfont4size,$
                                                 /dynamic_resize,/align_left)
    meanstdID[i,1] = widget_label(tmpbaseID,value="std: 0.0",font=tfont4size,$
                                                 /dynamic_resize,/align_left)

    mmID[i,0] = widget_label(tmpbaseID,value="min: 0.0",font=tfont4size,$
                                                 /dynamic_resize,/align_left)
    mmID[i,1] = widget_label(tmpbaseID,value="max: 0.0",font=tfont4size,$
                                                 /dynamic_resize,/align_left)

    nptsID[i] = widget_label(tmpbaseID,value="Num pts: ",font=tfont4size,$
                                   /dynamic_resize,/align_left)
    extralabelID[i] = widget_label(tmpbaseID,value="     ",font=tfont4size,$
                                                 /dynamic_resize,/align_left)



    for j = 0,maxstring-1  do begin
        intvalue[i,j] = widget_label(tmpbaseID,value="  ",font=tfontsize,$
                                                 /dynamic_resize,/align_left)
    endfor
                                                                                             
endfor


; realize main panel
                                                                                             
Widget_control,TelemetryLook,/Realize

                                                                                             
; get the window ids of the draw windows
                                                                                             
n_draw = n_elements(graphID)
draw_window_id = intarr(n_draw)
for i = 0,(n_draw-1) do begin
    widget_control,graphID[i],get_value=tdraw_id
    draw_window_id[i] = tdraw_id
endfor

; store the info structure



if(ext eq 1) then begin 
    info.TelemetryLook = TelemetryLook
    XManager,'mtql',info.TelemetryLook,/No_Block,event_handler='mtql_event'

    info.telemetry.draw_window_id = draw_window_id
    info.telemetry.uwindowsize = uwindowsize
    info.telemetry.xwindowsize = xwindowsize
    info.telemetry.ywindowsize = ywindowsize
    info.telemetry.offset = offset
    info.telemetry.plot_ranges[*,*] =plot_ranges
    info.telemetry.plot_mmlabel[*,*] = plot_mmlabel
    info.telemetry.meanstdID[*,*] = meanstdID
    info.telemetry.default_scale_graph[*] = default_scale_graph
    info.telemetry.recomputeID = recomputeID
    info.telemetry.mmID = mmID
    info.telemetry.extralabelID = extralabelID
    info.telemetry.type = tel_type
    info.telemetry.housekeepingID = housekeepingID
    info.telemetry.linechoiceID = linechoiceID
    info.telemetry.line_vals = line_vals
    info.telemetry.nptsID = nptsID
    if ptr_valid (info.telemetry.pintvalue) then ptr_free,info.telemetry.pintvalue
    info.telemetry.pintvalue = ptr_new(intvalue)
endif


if(ext eq 2) then begin 
    info.TelemetryLook_raw = TelemetryLook
    XManager,'mtql_raw',info.TelemetryLook_raw,/No_Block,event_handler='mtql_raw_event'

    info.telemetry_raw.draw_window_id = draw_window_id
    info.telemetry_raw.uwindowsize = uwindowsize
    info.telemetry_raw.xwindowsize = xwindowsize
    info.telemetry_raw.ywindowsize = ywindowsize
    info.telemetry_raw.offset = offset
    info.telemetry_raw.plot_ranges[*,*] =plot_ranges
    info.telemetry_raw.plot_mmlabel[*,*] = plot_mmlabel
    info.telemetry_raw.meanstdID[*,*] = meanstdID
    info.telemetry_raw.default_scale_graph[*] = default_scale_graph
    info.telemetry_raw.recomputeID = recomputeID
    info.telemetry_raw.mmID = mmID
    info.telemetry_raw.extralabelID = extralabelID
    info.telemetry_raw.type = tel_type
    info.telemetry_raw.housekeepingID = housekeepingID
    info.telemetry_raw.linechoiceID = linechoiceID
    info.telemetry_raw.line_vals = line_vals
    info.telemetry_raw.nptsID = nptsID
    if ptr_valid (info.telemetry_raw.pintvalue) then ptr_free,info.telemetry_raw.pintvalue
    info.telemetry_raw.pintvalue = ptr_new(intvalue)
endif



Widget_Control,info.QuickLook,Set_UValue=info
mtql_update_plot,info,ext


tinfo = {ext              : ext,$
         info        : info}
Widget_Control,TelemetryLook,Set_UValue=tinfo


Widget_Control,info.QuickLook,Set_UValue=info

end
