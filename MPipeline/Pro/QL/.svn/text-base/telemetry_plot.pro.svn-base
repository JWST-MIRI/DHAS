; These sets of functions plot 1 telemetry value against another 
; telemetry value
;_______________________________________________________________________

pro telemetry_event,event

Widget_Control,event.id,Get_uValue=event_name
widget_control,event.top, Get_UValue = tinfo
widget_control,tinfo.info.QuickLook,Get_UValue=info

if (widget_info(event.id,/TLB_SIZE_EVENTS) eq 1 ) then begin
    info.tplot.xwindowsize = event.x
    info.tplot.ywindowsize = event.y
    info.tplot.uwindowsize = 1
    widget_control,event.top,set_uvalue = tinfo
    widget_control,tinfo.info.Quicklook,set_uvalue = info
    telemetry_plot,info
    return
endif

case 1 of
;_______________________________________________________________________

;_______________________________________________________________________
; change the range of the graph
;_______________________________________________________________________
    (strmid(event_name,0,6) EQ 'change') : begin

        graphno = fix(strmid(event_name,6,1))
        if(info.tplot.default_scale_graph[graphno-1] eq 0 ) then begin ; true - turn to false
            widget_control,info.tplot.recomputeID[graphno-1],set_value='Default Scale'
            info.tplot.default_scale_graph[graphno-1] = 1
        endif
        Widget_Control,tinfo.info.QuickLook,Set_UValue=info
        telemetry_update_plot,info,1
    end

;_______________________________________________________________________
; change range of  graph
; if change range then also change the scale button to 'User Set Range'
;_______________________________________________________________________
    (strmid(event_name,0,2) EQ 'rp') : begin
        old11 = info.tplot.plot_ranges[0,0]
        old12 = info.tplot.plot_ranges[0,1]
        old21 = info.tplot.plot_ranges[1,0]
        old22 = info.tplot.plot_ranges[1,1]
        widget_control, info.tplot.plot_mmlabel[0,0],get_value= temp11
        widget_control, info.tplot.plot_mmlabel[0,1],get_value= temp12
        widget_control, info.tplot.plot_mmlabel[1,0],get_value= temp21
        widget_control, info.tplot.plot_mmlabel[1,1],get_value= temp22
        

        diff = 0.01
        
        test = (old11 - temp11)/old11
        if( abs( test ) gt diff) then begin
            info.tplot.plot_ranges[0,0] = temp11
            info.tplot.default_scale_graph[0] = 0
            widget_control,info.tplot.recomputeID[0],set_value='User Set Scale'
        endif

        test = (old12 - temp12)/old12
        if( abs(test) gt diff) then begin
            info.tplot.plot_ranges[0,1] = temp12
            info.tplot.default_scale_graph[0] = 0
            widget_control,info.tplot.recomputeID[0],set_value='User Set Scale'
        endif

        test = (old21 - temp21)/old21
        if( abs(test) gt diff) then begin
            info.tplot.plot_ranges[1,0] = temp21
            info.tplot.default_scale_graph[1] = 0
            widget_control,info.tplot.recomputeID[1],set_value='User Set Scale'
        endif

        test = (old22 - temp22)/old22
        if( abs(test) gt diff) then begin
            info.tplot.plot_ranges[1,1] = temp22
            info.tplot.default_scale_graph[1] = 0
            widget_control,info.tplot.recomputeID[1],set_value='User Set Scale'
        endif


        Widget_Control,tinfo.info.QuickLook,Set_UValue=info
        telemetry_update_plot,info,1
    end



;_______________________________________________________________________
; select a different keyword to plot
;_______________________________________________________________________
    (strmid(event_name,0,4) EQ 'line') : begin
      k_val = fix(strmid(event_name,4,1))

      info.tplot.line_vals[k_val-1] = event.index
        if (info.tplot.default_scale_graph[k_val]) then begin
            info.tplot.plot_ranges[k_val,0] = [0.0]
            info.tplot.plot_ranges[k_val,1] = [0.0]
        endif

        Widget_Control,tinfo.info.QuickLook,Set_UValue=info
        
        telemetry_update_plot,info,1
    end



;_______________________________________________________________________
; select a different housekeeping file to plot
;_______________________________________________________________________
    (strmid(event_name,0,5) EQ 'house') : begin
      k_val = fix(strmid(event_name,5,1))
      this_type =event.index
      if(this_type eq 0) then begin 
          result = dialog_message(" Select Type again " ,/info )
          return
      endif
      if(info.telemetry.file_exist[this_type-1] eq 0) then begin
          result = dialog_message(" The Data for this type of data does not exist" ,/info )
          if(info.tplot.type[k_val-1] ne 0) then $ 
            widget_control,info.tplot.housekeepingID[k_val-1],set_droplist_select=info.tplot.type[k_val-1]
          return
      endif
      info.tplot.type[k_val-1] = event.index
      
      tname = (*info.telemetry.pkname)[*,event.index-1]
      linechoices = [tname]
      widget_control,info.tplot.linechoiceID[k_val-1],set_value = linechoices

      widget_control,info.tplot.linechoiceID[k_val-1],set_list_select=info.telemetry.line_vals[k_val-1]

      Widget_Control,tinfo.info.QuickLook,Set_UValue=info
        telemetry_update_plot,info,1
    end
   
    
endcase
end


pro telemetry_raw_event,event

Widget_Control,event.id,Get_uValue=event_name
widget_control,event.top, Get_UValue = tinfo
widget_control,tinfo.info.QuickLook,Get_UValue=info

if (widget_info(event.id,/TLB_SIZE_EVENTS) eq 1 ) then begin
    info.tplot_raw.xwindowsize = event.x
    info.tplot_raw.ywindowsize = event.y
    info.tplot_raw.uwindowsize = 1
    widget_control,event.top,set_uvalue = tinfo
    widget_control,tinfo.info.Quicklook,set_uvalue = info
    telemetry_plot,info
    return
endif

case 1 of
;_______________________________________________________________________

;_______________________________________________________________________
; change the range of the graph
;_______________________________________________________________________
    (strmid(event_name,0,6) EQ 'change') : begin

        graphno = fix(strmid(event_name,6,1))
        if(info.tplot_raw.default_scale_graph[graphno-1] eq 0 ) then begin ; true - turn to false
            widget_control,info.tplot_raw.recomputeID[graphno-1],set_value='Default Scale'
            info.tplot_raw.default_scale_graph[graphno-1] = 1
        endif
        Widget_Control,tinfo.info.QuickLook,Set_UValue=info
        telemetry_update_plot,info,2
    end

;_______________________________________________________________________
; change range of  graph
; if change range then also change the scale button to 'User Set Range'
;_______________________________________________________________________
    (strmid(event_name,0,2) EQ 'rp') : begin
        old11 = info.tplot_raw.plot_ranges[0,0]
        old12 = info.tplot_raw.plot_ranges[0,1]
        old21 = info.tplot_raw.plot_ranges[1,0]
        old22 = info.tplot_raw.plot_ranges[1,1]
        widget_control, info.tplot_raw.plot_mmlabel[0,0],get_value= temp11
        widget_control, info.tplot_raw.plot_mmlabel[0,1],get_value= temp12
        widget_control, info.tplot_raw.plot_mmlabel[1,0],get_value= temp21
        widget_control, info.tplot_raw.plot_mmlabel[1,1],get_value= temp22
        

        diff = 0.01
        
        test = (old11 - temp11)/old11
        if( abs( test ) gt diff) then begin
            info.tplot_raw.plot_ranges[0,0] = temp11
            info.tplot_raw.default_scale_graph[0] = 0
            widget_control,info.tplot_raw.recomputeID[0],set_value='User Set Scale'
        endif

        test = (old12 - temp12)/old12
        if( abs(test) gt diff) then begin
            info.tplot_raw.plot_ranges[0,1] = temp12
            info.tplot_raw.default_scale_graph[0] = 0
            widget_control,info.tplot_raw.recomputeID[0],set_value='User Set Scale'
        endif

        test = (old21 - temp21)/old21
        if( abs(test) gt diff) then begin
            info.tplot_raw.plot_ranges[1,0] = temp21
            info.tplot_raw.default_scale_graph[1] = 0
            widget_control,info.tplot_raw.recomputeID[1],set_value='User Set Scale'
        endif

        test = (old22 - temp22)/old22
        if( abs(test) gt diff) then begin
            info.tplot_raw.plot_ranges[1,1] = temp22
            info.tplot_raw.default_scale_graph[1] = 0
            widget_control,info.tplot_raw.recomputeID[1],set_value='User Set Scale'
        endif


        Widget_Control,tinfo.info.QuickLook,Set_UValue=info
        telemetry_update_plot,info,2
    end

;_______________________________________________________________________
; select a different keyword to plot
;_______________________________________________________________________
    (strmid(event_name,0,4) EQ 'line') : begin
      k_val = fix(strmid(event_name,4,1))

      info.tplot_raw.line_vals[k_val-1] = event.index
        if (info.tplot_raw.default_scale_graph[k_val]) then begin
            info.tplot_raw.plot_ranges[k_val,0] = [0.0]
            info.tplot_raw.plot_ranges[k_val,1] = [0.0]
        endif

        Widget_Control,tinfo.info.QuickLook,Set_UValue=info
        
        telemetry_update_plot,info,2
    end



;_______________________________________________________________________
; select a different housekeeping file to plot
;_______________________________________________________________________
    (strmid(event_name,0,5) EQ 'house') : begin
      k_val = fix(strmid(event_name,5,1))
      this_type =event.index
      if(this_type eq 0) then begin 
          result = dialog_message(" Select Type again " ,/info )
          return
      endif
      if(info.telemetry_raw.file_exist[this_type-1] eq 0) then begin
          result = dialog_message(" The Data for this type of data does not exist" ,/info )
          if(info.tplot_raw.type[k_val-1] ne 0) then $ 
            widget_control,info.tplot_raw.housekeepingID[k_val-1],set_droplist_select=info.tplot_raw.type[k_val-1]
          return
      endif
      info.tplot_raw.type[k_val-1] = event.index
      
      tname = (*info.telemetry_raw.pkname)[*,event.index-1]
      linechoices = [tname]
      widget_control,info.tplot_raw.linechoiceID[k_val-1],set_value = linechoices

      widget_control,info.tplot_raw.linechoiceID[k_val-1],set_list_select=info.telemetry_raw.line_vals[k_val-1]

      Widget_Control,tinfo.info.QuickLook,Set_UValue=info
        telemetry_update_plot,info,2
    end
   
    
endcase
end





;***********************************************************************
pro tel_quit,event
widget_control,event.top, Get_UValue = tinfo
widget_control,tinfo.info.QuickLook,Get_UValue=info
widget_control,info.telemetryPlot,/destroy
end

pro tel_raw_quit,event
widget_control,event.top, Get_UValue = tinfo
widget_control,tinfo.info.QuickLook,Get_UValue=info
widget_control,info.telemetryPlot_Raw,/destroy
end

;***********************************************************************
; Plot one House keep value vs another value
pro telemetry_plot,event
widget_control,event.top, Get_UValue = tinfo
widget_control,tinfo.info.QuickLook,Get_UValue=info


ext = tinfo.ext

if(XRegistered ('tplot') and ext eq 1) then begin
    widget_control,info.telemetryPlot,/destroy
endif
if(XRegistered ('tplot_raw') and ext eq 2) then begin
    widget_control,info.telemetryPlot_Raw,/destroy
endif


status= 0

if(ext eq 1) then begin
    uwindowsize  = info.tplot.uwindowsize
    xwindowsize = info.tplot.xwindowsize
    ywindowsize = info.tplot.ywindowsize
    t_title = ' Converted Telemetry Data '
    info.tplot.type[*] = info.telemetry.type[0]
    plot_type = info.tplot.type
    type = info.tplot.type[0]-1 ; default all to be the same and to be the one selected by the user
    ;print,'plot_type',plot_type
    ;print,'type',type
    nvalues = info.telemetry.nvalues[type]
    tname = strarr(nvalues)
    tname = (*info.telemetry.pkname)[*,type]
endif

if(ext eq 2) then begin
    uwindowsize  = info.tplot_raw.uwindowsize
    xwindowsize = info.tplot_raw.xwindowsize
    ywindowsize = info.tplot_raw.ywindowsize
    t_title = ' Raw Telemetry Data '
    info.tplot_raw.type[*] = info.telemetry_raw.type[0]
    plot_type = info.tplot_raw.type
    type = info.tplot_raw.type[0]-1 ; default all to be the same and to be the one selected by the user
    nvalues = info.telemetry_raw.nvalues[type]
    tname = strarr(nvalues)
    tname = (*info.telemetry_raw.pkname)[*,type]
endif

; We will only use 2 of the 5(or 4) values, but this is how they are
 ; defined in the telemetry structure
plot_ranges = fltarr(5,2)
plot_mmlabel = lonarr(5,2)
meanstdID = lonarr(4,2)
default_scale_graph = intarr(5)
default_scale_graph[*] = 1   ; Default Range flag
recomputeID = lonarr(5)

mmID = lonarr(4,2)
extralabelID = lonarr(4)
nptsID = lonarr(4)



;*********
;Setup main panel
;*********

set_xsize = 18

; widget window parameters
xwidget_size = 950
ywidget_size = 850
xsize_scroll = 920
ysize_scroll = 820


if(uwindowsize eq 1) then begin ; user has set window size 
    xsize_scroll = xwindowsize
    ysize_scroll = ywindowsize
endif
if(info.control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.control.x_scroll_window
if(info.control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.control.y_scroll_window
if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10


TelemetryPlot = widget_base(title="MIRI Quick Look" + t_title + info.version ,col = 1,mbar = menuBar,$
                            group_leader = info.Quicklook,$
                           xsize = xwidget_size,$
                           ysize = ywidget_size,/scroll,$
                           x_scroll_size= xsize_scroll,$
                           y_scroll_size = ysize_scroll,/TLB_SIZE_EVENTS,/align_right)





stitle =" Telemetry plots for" + info.control.filename_tel
filelabelID = widget_label(TelemetryPlot, $
                           value=stitle,/align_left, $
                           font=info.font1,/dynamic_resize)
clear_ql_info,info
widget_control,info.filetag[0] ,set_value = ' Telemetry file name: ' + info.control.filename_tel
;********
; build the menubar
;********
QuitMenu = widget_button(menuBar,value="Quit",font = info.font1)
PrintMenu = widget_button(menuBar,value="Print",font = info.font1)
;********
; button row for main pulldown menus
;********
                                                                                                 
; add quit button
if(ext eq 1) then begin 
    quitbutton = widget_button(quitmenu,value="Quit",event_pro='tel_quit')
    printbutton = widget_button(printmenu,value="Print",event_pro='print_telemetry_plot')
endif

if(ext eq 2) then begin 
    quitbutton = widget_button(quitmenu,value="Quit",event_pro='tel_raw_quit')
    printbutton = widget_button(printmenu,value="Print",event_pro='print_telemetry_plot_raw')
endif
; add color button
;_______________________________________________________________________

;*********
; base for display
;*********



graphID_master1 = widget_base(telemetryPlot,row=1); plotting
graphID_master2 = widget_base(telemetryPlot,row=1); plotting
graphID1 = widget_base(graphID_master1,col=1)
keywordbaseID = widget_base(graphID_master2,row=1) 



pix_num_base = widget_base(graphID1,row=1,/align_center)
graphID = widget_draw(graphID1,scr_xsize=800, $
                         scr_ysize=500,frame=2,retain=info.retn)
;*****
; setup keywords to allow the choice of keywords to plot
;*****



if(ext eq 1) then begin 

endif

if(ext eq 2) then begin 

endif


linechoiceID = lonarr(4)
linechoices = [tname]

housekeepingID = lonarr(2)
line_vals = intarr(4)


intvalue = lonarr(2,10)


axis_title = ['X Axis', 'Y Axis']

for i = 0,1 do begin
    
    tmpbase1ID = widget_base(keywordbaseID,row=1)
    tmpbaseID = widget_base(tmpbase1ID,col=1)
    tmpbase2ID = widget_base(tmpbase1ID,col=1)
    ; graph box for color of telemetry values
    atitle = widget_label(tmpbaseID,value=axis_title[i],font = info.font5)

    
    line_vals[i] = i + 1
    indx_str = strtrim(string(i+1),2)
    duvalue = "change"+ indx_str
    hvalue = "house"+indx_str
    suvalue = "rp"+indx_str
    luvalue = "line"+indx_str

    housekeepingID[i] = widget_droplist(tmpbase2ID,value = info.tel_types,font=sfontsize,$
                                    uvalue=hvalue)
    widget_control,housekeepingID[i],set_droplist_select=plot_type[i]
    

    linechoiceID[i] = widget_list(tmpbase2ID,value=linechoices,font=sfontsize, $
                                  uvalue=luvalue,scr_ysize=200)
    

    widget_control,linechoiceID[i],set_list_select=line_vals[i]
    indx_str = strtrim(string(i+2),2)

    
    plot_mmlabel[i,0]=cw_field(tmpbaseID,title="min:",font=tfontsize, $
                                                  uvalue=suvalue,/float,$
                                                  /return_events, $
                                                  value=plot_ranges[i+1,0],$
                                                  xsize=set_xsize,fieldfont=tfontsize)

    plot_mmlabel[i,1]=cw_field(tmpbaseID,title="max:",font=tfontsize, $
                                                    uvalue=suvalue,/float,$
                                                    /return_events, $
                                                    value=plot_ranges[i+1,1],$
                                                    xsize=set_xsize,fieldfont=tfontsize)


    recomputeID[i] = widget_button(tmpbaseID,uvalue=duvalue,$
                                                    font=info.font4, $
                                                    value='Default Range',/dynamic_resize)

    
    meanstdID[i,0] = widget_label(tmpbaseID,value="ave: 0.0",font=tfontsize,$
                                                 /dynamic_resize,/align_left)
    meanstdID[i,1] = widget_label(tmpbaseID,value="std: 0.0",font=tfontsize,$
                                                 /dynamic_resize,/align_left)

    mmID[i,0] = widget_label(tmpbaseID,value="min: 0.0",font=tfont4size,$
                                                 /dynamic_resize,/align_left)
    mmID[i,1] = widget_label(tmpbaseID,value="max: 0.0",font=tfont4size,$
                                                 /dynamic_resize,/align_left)
    nptsID[i] = widget_label(tmpbaseID,value="Num pts (with same time): ",font=tfont4size,$
                                   /dynamic_resize,/align_left)
    extralabelID[i] = widget_label(tmpbaseID,value="     ",font=tfont4size,$
                                                 /dynamic_resize,/align_left)



    for j = 0,9  do begin
        intvalue[i,j] = widget_label(tmpbaseID,value="  ",font=tfontsize,$
                                                 /dynamic_resize,/align_left)
    endfor
                                                                                             
endfor


; realize main panel
Widget_control,TelemetryPlot,/Realize

; get the window ids of the draw windows
draw_window_id = intarr(5)
widget_control,graphID,get_value=tdraw_id
draw_window_id[0] = tdraw_id



; store the info structure
Widget_Control,info.QuickLook,Set_UValue=info

if(ext eq 1) then begin 
    info.TelemetryPlot = TelemetryPlot
    XManager,'tplot',info.TelemetryPlot,/No_Block,event_handler='telemetry_event'
    info.tplot.uwindowsize = uwindowsize
    info.tplot.xwindowsize = xwindowsize
    info.tplot.ywindowsize = ywindowsize
    info.tplot.plot_ranges = plot_ranges
    info.tplot.plot_mmlabel = plot_mmlabel
    info.tplot.meanstdID = meanstdID
    info.tplot.mmID = mmID
    info.tplot.nptsID = nptsID
    info.tplot.extraLabelID = extralabelID
    info.tplot.draw_window_id = draw_window_id
    info.tplot.recomputeID = recomputeID
    info.tplot.default_scale_graph= default_scale_graph
    info.tplot.housekeepingID = housekeepingID
    info.tplot.linechoiceID = linechoiceID
    info.tplot.line_vals = line_vals
    

    if ptr_valid (info.tplot.pintvalue) then ptr_free,info.tplot.pintvalue
    info.tplot.pintvalue = ptr_new(intvalue)

endif

if(ext eq 2) then begin 
    info.TelemetryPlot_RAW = TelemetryPlot
    XManager,'tplot_raw',info.TelemetryPlot_Raw,/No_Block,event_handler='telemetry_raw_event'
    info.tplot_raw.uwindowsize = uwindowsize
    info.tplot_raw.xwindowsize = xwindowsize
    info.tplot_raw.ywindowsize = ywindowsize
    info.tplot_raw.plot_ranges = plot_ranges
    info.tplot_raw.plot_mmlabel = plot_mmlabel
    info.tplot_raw.meanstdID = meanstdID
    info.tplot_raw.mmID = mmID
    info.tplot_raw.draw_window_id = draw_window_id
    info.tplot_raw.recomputeID = recomputeID
    info.tplot_raw.default_scale_graph= default_scale_graph
    info.tplot_raw.housekeepingID = housekeepingID
    info.tplot_raw.linechoiceID = linechoiceID
    info.tplot_raw.line_vals = line_vals
    info.tplot_raw.nptsID = nptsID
    info.tplot_raw.extraLabelID = extralabelID

    if ptr_valid (info.tplot_raw.pintvalue) then ptr_free,info.tplot_raw.pintvalue
    info.tplot_raw.pintvalue = ptr_new(intvalue)
endif


telemetry_update_plot,info,ext

tinfo = {info        : info}
Widget_Control,TelemetryPlot,Set_UValue=tinfo
Widget_Control,info.QuickLook,Set_UValue=info

end






