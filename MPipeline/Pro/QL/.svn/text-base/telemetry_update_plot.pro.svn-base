pro telemetry_plot_nothing,error_flag,x_title,y_title
plot_ranges = fltarr(2,2)
 plot_ranges[*,0] = 1
plot_ranges[*,1] = 2
plot,[1],[1],xrange=[plot_ranges[0,0],plot_ranges[0,1]],$
  yrange=[plot_ranges[1,0],plot_ranges[1,1]],$
  charsize=tcharsize,/nodata,ystyle=1,thick=1,charthick=1, $
  background=back_color,color=base_color,xstyle = 1,$
     title = 'Invalid Data',xtitle = title_x, ytitle = title_y,position=[0.1,0.1,0.9,0.9]
message = ' ' 
xyouts,1.5,1.8,' No DATA Plotted',charsize = 2,alignment = 0.5
if(error_flag eq 1) then message = " One or both of the parameters contains unknown strings" 
if(error_flag eq 2) then message = $
  'These values can not be plotted against one another, because they were taken at differnt times'





info_message = 'To view these values go back to main telemetry window and ' + $
    'click button: Print Telemetey Values to a Table'



xyouts,1.5,1.5,message,charsize = 1.1,alignment = 0.5
xyouts,1.5,1.25,info_message,charsize = 1.1,alignment = 0.5

end
;_______________________________________________________________________
; PLot housekeeping values:  value 1 vs value 2
; 

pro telemetry_update_plot,info,ext,ps = ps, eps = eps
hcopy = 0
if ( (keyword_set(ps)) or ( keyword_set(eps)) ) then hcopy = 1

tcharsize = 1.2
if(ext eq 1) then begin
    if(max(info.telemetry.maxlen[*]) gt 20) then tcharsize = 1.0
    draw_window_id = info.tplot.draw_window_id
    filebase_tel = info.control.filebase_tel
    plot_ranges = info.tplot.plot_ranges
    plot_mmlabel = info.tplot.plot_mmlabel 
    default_scale_graph = info.tplot.default_scale_graph
    ntimes = info.telemetry.ntimes
    line_vals = info.tplot.line_vals
    meanstdID = info.tplot.meanstdID
    mmID =  info.tplot.mmID
    nptsID = info.tplot.nptsID
    extralabelID = info.tplot.extralabelID
    teltype = (*info.telemetry.pteltype)
    telstring = (*info.telemetry.ptelstring)
    telstring_num = (*info.telemetry.ptelstring_num)
    time = (*info.telemetry.px_vals)

    y_vals_all = (*info.telemetry.pkdata)
    key_str_all = (*info.telemetry.pkname)    
    intvalue = (*info.tplot.pintvalue)
    nstring  =  info.telemetry.nstring 

    this_type_x = info.tplot.type[0] -1
    nvalues_x = info.telemetry.nvalues[this_type_x]
    ntimes_x = info.telemetry.ntimes[this_type_x]

    this_type_y = info.tplot.type[1] -1
    nvalues_y = info.telemetry.nvalues[this_type_y]
    ntimes_y = info.telemetry.ntimes[this_type_y]
    
endif else if(ext eq 2) then begin
    if(max(info.telemetry_raw.maxlen[*]) gt 20) then tcharsize = 1.0
    draw_window_id = info.tplot_raw.draw_window_id
    filebase_tel = info.control.filebase_telraw
    plot_ranges = info.tplot_raw.plot_ranges
    plot_mmlabel = info.tplot_raw.plot_mmlabel 
    default_scale_graph = info.tplot_raw.default_scale_graph
    ntimes = info.telemetry_raw.ntimes
    line_vals = info.tplot_raw.line_vals
    meanstdID = info.tplot_raw.meanstdID
    mmID =  info.tplot_raw.mmID
    nptsID = info.tplot_raw.nptsID
    extralabelID = info.tplot_raw.extralabelID
    teltype = (*info.telemetry_raw.pteltype)
    telstring = (*info.telemetry_raw.ptelstring)
    telstring_num = (*info.telemetry_raw.ptelstring_num)
    time = (*info.telemetry.px_vals)

    y_vals_all = (*info.telemetry_raw.pkdata)
    key_str_all = (*info.telemetry_raw.pkname)    
    intvalue = (*info.tplot_raw.pintvalue)
    nstring  =  info.telemetry_raw.nstring 

    this_type_x = info.tplot_raw.type[0] -1
    nvalues_x = info.telemetry_raw.nvalues[this_type_x]
    ntimes_x = info.telemetry_raw.ntimes[this_type_x]

    this_type_y = info.tplot_raw.type[1] -1
    nvalues_y = info.telemetry_raw.nvalues[this_type_y]
    ntimes_y = info.telemetry_raw.ntimes[this_type_y]

endif

if(hcopy eq 0) then wset,draw_window_id[0]
title_x = key_str_all[line_vals[0],this_type_x] + ' ( '+ info.tel_types[this_type_x+1] + ' )'
title_y = key_str_all[line_vals[1],this_type_y] + ' ( '+ info.tel_types[this_type_y+1] + ' )'
;_______________________________________________________________________

teltype_x = teltype[line_vals[0],this_type_x]
teltype_y = teltype[line_vals[1],this_type_y]
flag = 0
if(teltype_x eq -99) then begin 
    sinfo1 = 'Parameter contains unknown strings' 
    sinfo2 = 'This parameter can not be plotted'
    sinfo3 = 'To view these values'
    sinfo4 = 'Go back to main telemetry window'
    sinfo5 = 'Click button: Print Telemetey Values to a Table'
    widget_control,meanstdID[0,0],set_value=" "
    widget_control,meanstdID[0,1],set_value=sinfo1
    widget_control,mmID[0,0],set_value=sinfo2
    widget_control,mmID[0,1],set_value=sinfo3
    widget_control,nptsID[0],set_value=sinfo4
    widget_control,extralabelID[0],set_value=sinfo5
    flag = 1
endif

if(teltype_y eq -99) then begin 
    sinfo1 = 'Parameter contains unknown strings' 
    sinfo2 = 'This parameter can not be plotted'
    sinfo3 = 'To view these values'
    sinfo4 = 'Go back to main telemetry window'
    sinfo5 = 'Click button: Print Telemetey Values to a Table'
    widget_control,meanstdID[1,0],set_value=" "
    widget_control,meanstdID[1,1],set_value=sinfo1
    widget_control,mmID[1,0],set_value=sinfo2
    widget_control,mmID[1,1],set_value=sinfo3
    widget_control,nptsID[1],set_value=sinfo4
    widget_control,extralabelID[1],set_value=sinfo5
    flag = 1
endif

if(flag eq 1) then begin

    y_vals_all = 0
    key_str_all = 0
    teltype = 0
    telstring = 0
    telstring_num = 0
    time = 0
    telemetry_plot_nothing,1,x_title,y_title
    return
endif
;_______________________________________________________________________
; pull out the varibles that have the same times

x_time = time[0:ntimes_x-1,this_type_x]
y_time = time[0:ntimes_y-1,this_type_y]

x_vals = y_vals_all[line_vals[0],0:ntimes_x-1,this_type_x]
y_vals = y_vals_all[line_vals[1],0:ntimes_y-1,this_type_y]



sfile_x = strcompress(info.tel_types[this_type_x+1],/remove_all) 
sfile_y = strcompress(info.tel_types[this_type_y+1],/remove_all) 

; Find all the common times. This could be faster if looped over
; the smaller of x_time or y_time
found_index = intarr(ntimes_y)
found_index[*] = -1
nfound = 0
for i = 0,ntimes_y - 1 do begin 
    ii= where(x_time[*] eq y_time[i], num)
    if(num eq 1) then begin
        found_index[i] = ii
        nfound = nfound + 1
    endif
endfor


if(nfound eq 0) then begin
    sinfo1 = 'These values can not be plotted' 
    sinfo2 = 'against one another'
    sinfo3 = 'The values were taken at different times'
    sinfo4 = 'Change either '+ sfile_x + ' or '+ sfile_y
    sinfo5 = ' '
    for j = 0,1 do begin 
        widget_control,meanstdID[j,0],set_value=" "
        widget_control,meanstdID[j,1],set_value=sinfo1
        widget_control,mmID[j,0],set_value=sinfo2
        widget_control,mmID[j,1],set_value=sinfo3
        widget_control,nptsID[j],set_value=sinfo4
        widget_control,extralabelID[j],set_value=sinfo5
    endfor
    telemetry_plot_nothing,2,x_title,y_title
    return
endif else begin 
    
    xval = dblarr(nfound) & yval = dblarr(nfound)
    n = 0
    for i = 0,ntimes_y-1  do begin
        if(found_index[i] ne -1) then begin
            yval[n] = y_vals[i]
            xval[n] = x_vals[found_index[i]]
            n = n + 1
        endif
    endfor
endelse    


x_vals = xval
y_vals = yval

; determine the x range to plot
if (default_scale_graph[0] eq 1) then begin
    if(teltype[line_vals[0],this_type_x] eq 0) then begin 
        xmin =  min(x_vals)*0.90
        xmax =  max(x_vals)*1.10 ; 
        if(min(x_vals) lt 0) then xmin = min(x_vals)*1.10        
        if(max(x_vals) lt 0) then xmax = max(x_vals)*0.90
        if(xmin eq xmax) then begin
            xmin = xmin -1
            xmax = xmax + 1
        endif
        plot_ranges[0,0] =xmin
        plot_ranges[0,1] =xmax

    endif else begin 
        num = teltype[line_vals[0],this_type_x]
        string_num = telstring_num[line_vals[0],this_type_x,*]
        max_value = max(string_num) 
        plot_ranges[0,0] = -1
        plot_ranges[0,1] = max_value + 1        
    endelse

    widget_control,plot_mmlabel[0,0],set_value=plot_ranges[0,0]
    widget_control,plot_mmlabel[0,1],set_value=plot_ranges[0,1]
endif


if (default_scale_graph[1] eq 1) then begin
    if(teltype[line_vals[1],this_type_y] eq 0) then begin

        ymin =  min(y_vals)*0.90
        ymax =  max(y_vals)*1.10 ; 
        if(min(y_vals) lt 0) then ymin = min(y_vals)*1.10        
        if(max(y_vals) lt 0) then ymax = max(y_vals)*0.90
        if(ymin eq ymax) then begin
            ymin = ymin -1
            ymax = ymax + 1
        endif
        plot_ranges[1,0] =ymin
        plot_ranges[1,1] =ymax
 
    endif else begin
        num = teltype[line_vals[1],this_type_y]
        string_num = telstring_num[line_vals[0],this_type_y,*]
        max_value = max(string_num) 
        plot_ranges[1,0] = -1
        plot_ranges[1,1] = max_value + 1        
    endelse
    

    widget_control,plot_mmlabel[1,0],set_value=plot_ranges[1,0]
    widget_control,plot_mmlabel[1,1],set_value=plot_ranges[1,1]
endif


; setup the plot axis

stitle = ' ' 

if(hcopy eq 1) then stitle = filebase_tel


        
if(hcopy eq 0) then $
plot,[1],[1],xrange=[plot_ranges[0,0],plot_ranges[0,1]],$
  yrange=[plot_ranges[1,0],plot_ranges[1,1]],$
  charsize=tcharsize,/nodata,ystyle=1,thick=1,charthick=1, $
  background=back_color,color=base_color,xstyle = 1,$
     title = stitle,xtitle = title_x, ytitle = title_y,position=[0.1,0.1,0.9,0.9]
if(hcopy eq 1) then $
plot,[1],[1],xrange=[plot_ranges[0,0],plot_ranges[0,1]],$
  yrange=[plot_ranges[1,0],plot_ranges[1,1]],$
  charsize=tcharsize,/nodata,ystyle=1,thick=1,charthick=1, $
  xstyle = 1,title = stitle,xtitle = title_x, ytitle = title_y,position=[0.1,0.1,0.9,0.9]

;_______________________________________________________________________
; Plot the data
if(hcopy eq 0) then wset, draw_window_id[0]


oplot,x_vals,y_vals,psym=1,symsize=0.75


;_______________________________________________________________________
; set up x axis statistics
;_______________________________________________________________________
; clear out string names
for p = 0,9 do begin
    svalue = '                       '
    widget_control,intvalue[0,p],set_value = svalue
endfor

num = n_elements(x_vals)
ave_val = mean(x_vals)

min_val  = min(x_vals)
max_val  = max(x_vals)
if(num gt 1) then begin
    std_val = stddev(x_vals)
    sstdev = strtrim(string(std_val),2)
endif else begin
    sstdev = 'NA'
endelse
        


ny = where((y_vals GE plot_ranges[1,0]) AND $
           (y_vals LE plot_ranges[1,1]),ynpts)    

nx = where((x_vals GE plot_ranges[0,0]) AND $
           (x_vals LE plot_ranges[0,1]),xnpts)
nx = 0 & ny = 0
; data type not a string (an integer, float or double)

if(teltype[ line_vals[0],this_type_x] eq 0) then begin 
    widget_control,meanstdID[0,0],set_value="ave: " + strtrim(string(ave_val),2)
    widget_control,meanstdID[0,1],set_value="std: " + sstdev

    widget_control,mmID[0,0],set_value="min: " + strtrim(string(min_val),2)
    widget_control,mmID[0,1],set_value="max: " + strtrim(string(max_val),2)
    widget_control,nptsID[0],set_value="Num pts: " + strtrim(string(xnpts),2)
    widget_control,extralabelID[1],set_value= '                               '
endif else begin
    sinfo1 = 'Data Value is a string ' 
    sinfo2 = 'Integer equivalents'
    widget_control,meanstdID[0,0],set_value=" "
    widget_control,meanstdID[0,1],set_value=sinfo1
    widget_control,mmID[0,0],set_value=sinfo2
    widget_control,mmID[0,1],set_value=" "
    widget_control,nptsID[0],set_value="Num pts: " + strtrim(string(xnpts),2)
    widget_control,extralabelID[1],set_value= '                               '

    num =   teltype[line_vals[0],this_type_x]
    string_values = strarr(teltype[line_vals[0],this_type_x])
    string_values = strcompress(telstring[line_vals[0],this_type_x,*],/remove_all)
    string_num = telstring_num[line_vals[0],this_type_x,*]
    for p = 0,nstring[this_type_x] -1 do begin
        svalue = '                       '
        if(p lt num) then svalue  = string_values[p] + '=' + strcompress(string(string_num[p]),/remove_all)
        widget_control,intvalue[0,p],set_value = svalue
    endfor
endelse




;_______________________________________________________________________
; set up y axis statistics
;_______________________________________________________________________
; clear out string names
for p = 0,9 do begin
    svalue = '                       '
    widget_control,intvalue[1,p],set_value = svalue
endfor

    num = n_elements(y_vals)
    ave_val = mean(y_vals)

    min_val  = min(y_vals)
    max_val  = max(y_vals)


    if(num gt 1) then begin
        std_val = stddev(y_vals)
        sstdev = strtrim(string(std_val),2)
    endif else begin
        sstdev = 'NA'
    endelse

; data type not a string (an integer, float or double)
if(teltype[ line_vals[1],this_type_y] eq 0) then begin 
    widget_control,meanstdID[1,0],set_value="ave: " + strtrim(string(ave_val),2)
    widget_control,meanstdID[1,1],set_value="std: " + sstdev

    widget_control,mmID[1,0],set_value="min: " + strtrim(string(min_val),2)
    widget_control,mmID[1,1],set_value="max: " + strtrim(string(max_val),2)
    widget_control,nptsID[1],set_value="Num pts: " + strtrim(string(ynpts),2)
endif else begin
    sinfo1 = 'Data Value is a string ' 
    sinfo2 = 'Integer equivalents'
    widget_control,meanstdID[1,0],set_value=" "
    widget_control,meanstdID[1,1],set_value=sinfo1
    widget_control,mmID[1,0],set_value=sinfo2
    widget_control,mmID[1,1],set_value=" "
    widget_control,nptsID[1],set_value="Num pts: " + strtrim(string(ynpts),2)

    num =   teltype[line_vals[1],this_type_y]
    string_values = strarr(teltype[line_vals[1] ,this_type_y])
    string_values = strcompress(telstring[line_vals[1] ,this_type_y,*],/remove_all)
    string_num = telstring_num[line_vals[1],this_type_y,*]
    for p = 0,nstring[this_type_y] -1 do begin
        svalue = '                       '
        if(p lt num) then svalue  = string_values[p] + '=' + strcompress(string(string_num[p]),/remove_all)
        widget_control,intvalue[1,p],set_value = svalue
    endfor
endelse


;_______________________________________________________________________


if(ext eq 1) then begin
    info.tplot.plot_ranges = plot_ranges
    info.tplot.plot_mmlabel = plot_mmlabel
    info.tplot.meanstdID = meanstdID 
endif

if(ext eq 2) then begin
    info.tplot_raw.plot_ranges = plot_ranges
    info.tplot_raw.plot_mmlabel = plot_mmlabel
    info.tplot_raw.meanstdID = meanstdID 
endif

x_vals = 0

y_vals = 0
y_vals_all = 0
key_str_all = 0
teltype = 0
telstring = 0
telstring_num = 0
time = 0
x_time = 0
y_time = 0
end
