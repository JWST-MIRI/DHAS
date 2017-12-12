pro mtql_event,event

Widget_Control,event.id,Get_uValue=event_name
widget_control,event.top, Get_UValue = tinfo
widget_control,tinfo.info.QuickLook,Get_UValue=info

if (widget_info(event.id,/TLB_SIZE_EVENTS) eq 1 ) then begin
    info.telemetry.xwindowsize = event.x
    info.telemetry.ywindowsize = event.y
    info.telemetry.uwindowsize = 1
    widget_control,event.top,set_uvalue = tinfo
    widget_control,tinfo.info.Quicklook,set_uvalue = info
    mtql_display_telemetry,info,1
    return
endif

case 1 of
;_______________________________________________________________________

    
;_______________________________________________________________________
; change the range of the graph
;_______________________________________________________________________
    (strmid(event_name,0,5) EQ 'range') : begin

        graphno = fix(strmid(event_name,5,1))
        if(info.telemetry.default_scale_graph[graphno-1] eq 0 ) then begin ; true - turn to false
            widget_control,info.telemetry.recomputeID[graphno-1],set_value='Default Scale'
            info.telemetry.default_scale_graph[graphno-1] = 1
        endif
        Widget_Control,tinfo.info.QuickLook,Set_UValue=info
        mtql_update_plot,info,1
    end
;_______________________________________________________________________
; change range of telemetry graohs
; if change range then also change the scale button to 'User Set Range'
;_______________________________________________________________________
    (strmid(event_name,0,2) EQ 'rp') : begin
        graph_num = fix(strmid(event_name,3,1))
        if(strmid(event_name,4,1) EQ 'b') then mm_val = 0 else mm_val = 1 ; b for min, t for max
        info.telemetry.plot_ranges[graph_num-1,mm_val] = event.value
        info.telemetry.default_scale_graph[graph_num-1] = 0
        widget_control,info.telemetry.recomputeID[graph_num-1],set_value='User Set Scale'

        Widget_Control,tinfo.info.QuickLook,Set_UValue=info

        mtql_update_plot,info,1
    end



;_______________________________________________________________________
; select a different keyword to plot
;_______________________________________________________________________
    (strmid(event_name,0,4) EQ 'line') : begin
      k_val = fix(strmid(event_name,4,1))

      info.telemetry.line_vals[k_val-1] = event.index
        if (info.telemetry.default_scale_graph[k_val]) then begin
            info.telemetry.plot_ranges[k_val,0] = [0.0]
            info.telemetry.plot_ranges[k_val,1] = [0.0]
        endif

        Widget_Control,tinfo.info.QuickLook,Set_UValue=info
        
        mtql_update_plot,info,1
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
          if(info.telemetry.type[k_val-1] ne 0) then $ 
            widget_control,info.telemetry.housekeepingID[k_val-1],set_droplist_select=info.telemetry.type[k_val-1]
          return
      endif
      info.telemetry.type[k_val-1] = event.index
      
      tname = (*info.telemetry.pkname)[*,event.index-1]
      linechoices = ['None          ',tname]
      widget_control,info.telemetry.linechoiceID[k_val-1],set_value = linechoices

      widget_control,info.telemetry.linechoiceID[k_val-1],set_list_select=info.telemetry.line_vals[k_val-1]


      mtql_update_plot,info,1
      Widget_Control,tinfo.info.QuickLook,Set_UValue=info
    end
   
    
;_______________________________________________________________________
; Print the telemetry values to a table
;_______________________________________________________________________
    (strmid(event_name,0,3) EQ 'Get') : begin
        mtql_table_values,info
        Widget_Control,tinfo.info.QuickLook,Set_UValue=info
    end

;_______________________________________________________________________
; Offset axes
;_______________________________________________________________________
    (strmid(event_name,0,6) EQ 'offset') : begin

        info.telemetry.offset = event.index
        mtql_update_plot,info,1
        
        Widget_Control,tinfo.info.QuickLook,Set_UValue=info
    end
else: print,event_name
endcase
Widget_Control,tinfo.info.QuickLook,Set_UValue=info
end




;***********************************************************************
;***********************************************************************
pro mtql_raw_event,event

Widget_Control,event.id,Get_uValue=event_name
widget_control,event.top, Get_UValue = tinfo
widget_control,tinfo.info.QuickLook,Get_UValue=info

if (widget_info(event.id,/TLB_SIZE_EVENTS) eq 1 ) then begin
    info.telemetry_raw.xwindowsize = event.x
    info.telemetry_raw.ywindowsize = event.y
    info.telemetry_raw.uwindowsize = 1
    widget_control,event.top,set_uvalue = tinfo
    widget_control,tinfo.info.Quicklook,set_uvalue = info
    mtql_display_telemetry,info,2
    return
endif

case 1 of
;_______________________________________________________________________

    
;_______________________________________________________________________
; change the range of the graph
;_______________________________________________________________________
    (strmid(event_name,0,5) EQ 'range') : begin

        graphno = fix(strmid(event_name,5,1))
        if(info.telemetry_raw.default_scale_graph[graphno-1] eq 0 ) then begin 
            widget_control,info.telemetry_raw.recomputeID[graphno-1],set_value='Default Scale'
            info.telemetry_raw.default_scale_graph[graphno-1] = 1
        endif
        mtql_update_plot,info,2
        Widget_Control,tinfo.info.QuickLook,Set_UValue=info
    end
;_______________________________________________________________________
; change range of telemetry graohs
; if change range then also change the scale button to 'User Set Range'
;_______________________________________________________________________
    (strmid(event_name,0,2) EQ 'rp') : begin
        graph_num = fix(strmid(event_name,3,1))
        if(strmid(event_name,4,1) EQ 'b') then mm_val = 0 else mm_val = 1 ; b for min, t for max
        info.telemetry_raw.plot_ranges[graph_num-1,mm_val] = event.value
        info.telemetry_raw.default_scale_graph[graph_num-1] = 0
        widget_control,info.telemetry_raw.recomputeID[graph_num-1],set_value='User Set Scale'



        mtql_update_plot,info,2
        Widget_Control,tinfo.info.QuickLook,Set_UValue=info
    end



;_______________________________________________________________________
; select a different keyword to plot
;_______________________________________________________________________
    (strmid(event_name,0,4) EQ 'line') : begin
      k_val = fix(strmid(event_name,4,1))

      info.telemetry_raw.line_vals[k_val-1] = event.index
        if (info.telemetry_raw.default_scale_graph[k_val]) then begin
            info.telemetry_raw.plot_ranges[k_val,0] = [0.0]
            info.telemetry_raw.plot_ranges[k_val,1] = [0.0]
        endif

        
        
        mtql_update_plot,info,2
        Widget_Control,tinfo.info.QuickLook,Set_UValue=info
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
          if(info.telemetry_raw.type[k_val-1] ne 0) then $ 
            widget_control,info.telemetry_raw.housekeepingID[k_val-1],set_droplist_select=info.telemetry_raw.type[k_val-1]
          return
      endif
      info.telemetry_raw.type[k_val-1] = event.index
      
      tname = (*info.telemetry_raw.pkname)[*,event.index-1]
      linechoices = ['None          ',tname]
      widget_control,info.telemetry_raw.linechoiceID[k_val-1],set_value = linechoices

      widget_control,info.telemetry_raw.linechoiceID[k_val-1],set_list_select=info.telemetry_raw.line_vals[k_val-1]


      mtql_update_plot,info,2
      Widget_Control,tinfo.info.QuickLook,Set_UValue=info
    end
   
    
;_______________________________________________________________________
; Print the telemetry values to a table
;_______________________________________________________________________
    (strmid(event_name,0,3) EQ 'Get') : begin
        mtql_table_raw_values,info
    end


;_______________________________________________________________________
; Offset axes
;_______________________________________________________________________
    (strmid(event_name,0,6) EQ 'offset') : begin

        info.telemetry_raw.offset = event.index
        mtql_update_plot,info,2
        
        Widget_Control,tinfo.info.QuickLook,Set_UValue=info
    end
else: print,event_name
endcase
Widget_Control,tinfo.info.QuickLook,Set_UValue=info
end
