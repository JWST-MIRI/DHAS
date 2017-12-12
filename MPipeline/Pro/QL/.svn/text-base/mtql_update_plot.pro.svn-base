; PLot 4 telemetry values on the same plot
; The y axis is scaled to fall between -0.1 and 1.1

pro mtql_update_plot,info,ext,ps = ps, eps = eps
hcopy = 0
if ( (keyword_set(ps)) or ( keyword_set(eps)) ) then hcopy = 1


tcharsize = 1.2
if(max(info.telemetry.maxlen[*]) gt 20) then tcharsize = 1.0


psymtype = [1,2,4,6]
ltype = [1,2,3,4]

save_color = info.col_table
color6
line_colors = [info.red,info.green,info.blue, info.yellow]

if(ext eq 1) then begin
    draw_window_id = info.telemetry.draw_window_id
    n_poss_lines = info.telemetry.n_poss_lines
    filebase_tel = info.control.filebase_tel
    plot_ranges = info.telemetry.plot_ranges
    plot_mmlabel = info.telemetry.plot_mmlabel 
    x_vals_all = (*info.telemetry.px_vals)
    default_scale_graph = info.telemetry.default_scale_graph
    ntimes = info.telemetry.ntimes
    line_vals = info.telemetry.line_vals
    meanstdID = info.telemetry.meanstdID
    mmID =  info.telemetry.mmID
    extraID =  info.telemetry.extralabelID
    nptsID = info.telemetry.nptsID
    teltype = (*info.telemetry.pteltype); ne 0 = values string, 0 = values numbers 
    telstring = (*info.telemetry.ptelstring)
    telstring_num = (*info.telemetry.ptelstring_num)

    y_vals_all = (*info.telemetry.pkdata)
    key_str_all = (*info.telemetry.pkname)    
    intvalue = (*info.telemetry.pintvalue)
    nstring  =  info.telemetry.nstring 
    offset_axes = info.telemetry.offset
endif else if(ext eq 2) then begin
    draw_window_id = info.telemetry_raw.draw_window_id
    n_poss_lines = info.telemetry_raw.n_poss_lines
    filebase_tel = info.control.filebase_telraw
    plot_ranges = info.telemetry_raw.plot_ranges
    plot_mmlabel = info.telemetry_raw.plot_mmlabel 
    x_vals_all = (*info.telemetry_raw.px_vals)
    default_scale_graph = info.telemetry_raw.default_scale_graph
    ntimes = info.telemetry_raw.ntimes
    line_vals = info.telemetry_raw.line_vals
    meanstdID = info.telemetry_raw.meanstdID
    mmID =  info.telemetry_raw.mmID
    nptsID = info.telemetry_raw.nptsID
    extraID =  info.telemetry_raw.extralabelID

    teltype = (*info.telemetry_raw.pteltype)
    telstring = (*info.telemetry_raw.ptelstring); ne 0 = values string, 0 = values numbers 
    telstring_num = (*info.telemetry_raw.ptelstring_num)

    y_vals_all = (*info.telemetry_raw.pkdata)
    key_str_all = (*info.telemetry_raw.pkname)    
    intvalue = (*info.telemetry_raw.pintvalue)
    nstring  =  info.telemetry_raw.nstring
    offset_axes = info.telemetry_raw.offset 
endif
if(hcopy eq 0) then wset,draw_window_id[0]

; pull out only values interested in
xsize = size(x_vals_all)
ysize = size(y_vals_all)
x_4vals = dblarr(xsize[1],4)
y_4vals  = dblarr(ysize[2],4)

x_index = x_4vals
x_index[*,*] = 0
stime = 10000000000.0d0


max_ntimes = -1
for k = 0,3 do begin
    if(ext eq 1) then this_type = info.telemetry.type[k]-1
    if(ext eq 2) then this_type = info.telemetry_raw.type[k]-1

    if(ext eq 1) then ntimes = info.telemetry.ntimes[this_type]
    if(ext eq 2) then ntimes = info.telemetry_raw.ntimes[this_type]

    if(ntimes gt max_ntimes) then max_ntimes = ntimes
endfor

for k = 0,3 do begin
    if(ext eq 1) then this_type = info.telemetry.type[k]-1
    if(ext eq 2) then this_type = info.telemetry_raw.type[k]-1

    if(ext eq 1) then ntimes = info.telemetry.ntimes[this_type]
    if(ext eq 2) then ntimes = info.telemetry_raw.ntimes[this_type]


    x_4vals[*,k] = x_vals_all[*,this_type]

    if(line_vals[k] gt 0) then  $
      y_4vals[*,k] = y_vals_all[line_vals[k] - 1,*,this_type]
    x_index[0:ntimes-1,k] = 1

    min_time = min(x_4vals[0:ntimes-1,k])
    if(min_time lt stime) then stime = min_time
endfor


valid_pts = where(x_index eq 1,n)

start_time = stime

if(ext eq 1) then info.telemetry.start_time = start_time
if(ext eq 2) then info.telemetry_raw.start_time = start_time
stime = strcompress(string(start_time),/remove_all)
stime_full = strcompress(string(start_time,format='(f20.1)'),/remove_all)


x_4vals = x_4vals - start_time

;_______________________________________________________________________
find_date,start_time,yr,mn,mnstring,day,hour,min,sec

shms = string(hour)+ ":" + string(min) + ":" + string(sec)
sdmy = mnstring + ' ' + strcompress(string(day),/remove_all)  + ', ' + strcompress(string(yr),/remove_all)
stime = sdmy + '   ' + strcompress(shms,/remove_all)
;_______________________________________________________________________
; plot the x axis range


; determine the x range to plot

if (default_scale_graph[0]) then begin

    plot_ranges[0,0] = min(x_4vals[valid_pts])*.90
    plot_ranges[0,1] = max(x_4vals[valid_pts])*1.05 ; x_vals time[i] - time[0] 



    if(max_ntimes eq 1) then plot_ranges[0,1] = 2.0; only one value - so shift x range so pt in center
    widget_control,plot_mmlabel[0,0],set_value=plot_ranges[0,0]
    widget_control,plot_mmlabel[0,1],set_value=plot_ranges[0,1]
endif


; compute the position of the graph relative to all the y axes

tot_pos = [0.1,0.1,0.9,0.9]
tot_width = tot_pos[2] - tot_pos[0]
plot_width = 0.5

yaxis1_width = (tot_width-plot_width)*fix(n_poss_lines/2)/$
  float(n_poss_lines)

yaxis2_width = (tot_width-plot_width) - yaxis1_width
plot_pos = tot_pos
plot_pos[0] = tot_pos[0]+yaxis1_width
plot_pos[2] = tot_pos[2]-yaxis2_width

; setup the plot axis


stitle = ' ' 

sxtitle = ' Time in  seconds from: Start Time: ' + stime + ' ( ' + stime_full + ')'  
if(hcopy eq 1) then stitle = filebase_tel
kyrange = [-0.1,1.1]
kyrange = [0,1]


if(hcopy eq 0) then $
plot,[1],[1],xrange=[plot_ranges[0,0],plot_ranges[0,1]],$
  yrange=kyrange, $
  charsize=tcharsize,position=plot_pos,/nodata,ystyle=5,thick=1,charthick=1, $
  background=back_color,color=info.white,xtitle=sxtitle,xstyle = 1,$
     title = stitle
if(hcopy eq 1) then $
plot,[1],[1],xrange=[plot_ranges[0,0],plot_ranges[0,1]],$
  yrange=kyrange, $
  charsize=tcharsize,position=plot_pos,/nodata,ystyle=5,thick=1,charthick=1, $
  xtitle=xstitle,xstyle = 1,title = stitle
; plot each of the keywords


; n_poss_lines = 4 -

for i = 0,(n_poss_lines-1) do begin   ; number of telemetry values

    if(ext eq 1) then begin 
        this_type = info.telemetry.type[i] -1
        nvalues = info.telemetry.nvalues[this_type]
        ntimes = info.telemetry.ntimes[this_type]
    endif
    if(ext eq 2) then begin 
        this_type = info.telemetry_raw.type[i] -1
        nvalues = info.telemetry_raw.nvalues[this_type]
        ntimes = info.telemetry_raw.ntimes[this_type]
    endif

    xindxs = where((x_4vals[*,i] GE plot_ranges[0,0]) AND $
                   (x_4vals[*,i] LE plot_ranges[0,1]),n_xindxs)



    if (n_xindxs EQ 0) then begin ;
        xindxs = indgen(ntimes)
        n_xindxs = ntimes
    endif



    if (line_vals[i] NE 0) then begin
        y_vals = y_4vals[0:ntimes-1,i]
        x_vals = x_4vals[0:ntimes-1,i]
        k = (i+1)*2
        if (default_scale_graph[i+1]) then begin
            if(teltype[ line_vals[i]-1,this_type] eq 0) then begin ; values numbers
                plot_ranges[i+1,0] = min(y_vals[xindxs])*0.9 
                plot_ranges[i+1,1] = max(y_vals[xindxs])*1.1 
                if(min(y_vals[xindxs]) lt 0) then         plot_ranges[i+1,0] = min(y_vals[xindxs])*1.01
                if(max(y_vals[xindxs]) lt 0) then         plot_ranges[i+1,1] = max(y_vals[xindxs])*0.99
                
            endif else begin ; values are strings
                num = teltype[line_vals[i]-1,this_type]
                string_num = telstring_num[line_vals[i]-1,this_type,*]
                max_value = max(string_num) 
                plot_ranges[i+1,0] = -1
                plot_ranges[i+1,1] = num + 1
                plot_ranges[i+1,1] = max_value + 1
                                ; if num = -99 (unknow strings, the
                                ; plot_ranges[i+1,0] = -1 and
                                ; plot_range[i+1,1] = 1 but the data
                                ; values = -99 so no plot avaiable
            endelse

            widget_control,plot_mmlabel[i+1,0],$
                           set_value=plot_ranges[i+1,0]
            widget_control,plot_mmlabel[i+1,1],$
                           set_value=plot_ranges[i+1,1]
        endif

;
;_______________________________________________________________________

        if(offset_axes eq 1) then $
          plot_ranges[i+1,0] = plot_ranges[i+1,0] - plot_ranges[i+1,0]*0.05*i

        ave_val = total(y_vals[xindxs])/float(n_xindxs)
        std_val = 0
        if(n_xindxs gt 1)then begin
            std_val =sqrt(total((y_vals[xindxs]-ave_val)^2)/float(n_xindxs-1))
            sstdev = strtrim(string(std_val),2)
        endif else begin
            sstdev = 'NA'
        endelse
        
        min_val  = min(y_vals[xindxs])
        max_val  = max(y_vals[xindxs])

        ny = where((y_vals GE plot_ranges[i+1,0]) AND $
                       (y_vals LE plot_ranges[i+1,1]),npts)

        

        if(plot_ranges[i+1,1] eq plot_ranges[i+1,0] )then begin ; if values are all the same
            y_vals = (y_vals - plot_ranges[i+1,0]) 
        endif else begin
            y_vals = kyrange[0] + (kyrange[1] - kyrange[0])*$
                     (y_vals - plot_ranges[i+1,0])/ $
                     (plot_ranges[i+1,1] - plot_ranges[i+1,0])
        endelse

; Plot the data

        if(hcopy eq 0) then wset, draw_window_id[0]
        oplot,x_vals,y_vals,psym=0,color=line_colors[i],linestyle=ltype[i]
        oplot,x_vals,y_vals,psym=2,symsize=0.75,color=line_colors[i]

        ; clear out string names
        for p = 0,nstring[this_type] -1 do begin
            svalue = '                       '
            widget_control,intvalue[i,p],set_value = svalue
        endfor
; data type not a string (an integer, float or double)
        if(teltype[ line_vals[i]-1,this_type] eq 0) then begin 
            widget_control,meanstdID[i,0],set_value="ave: " + strtrim(string(ave_val),2)
            widget_control,meanstdID[i,1],set_value="std: " + sstdev

            widget_control,mmID[i,0],set_value="min: " + strtrim(string(min_val),2)
            widget_control,mmID[i,1],set_value="max: " + strtrim(string(max_val),2)
            widget_control,nptsID[i],set_value="Num pts: " + strtrim(string(npts),2)
            widget_control,extraID[i],set_value=" "
        endif else begin
            num =   teltype[line_vals[i]-1,this_type]
            if(num eq -99) then begin 
                
                sinfo1 = 'Parameter contains unknown strings' 
                sinfo2 = 'Can not plot this parameter'
                sinfo3 = 'To view values click the button:'
                sinfo4 = 'Print Telemetey Values to a Table'
                widget_control,meanstdID[i,0],set_value=" "
                widget_control,meanstdID[i,1],set_value=sinfo1
                widget_control,mmID[i,0],set_value=sinfo2
                widget_control,mmID[i,1],set_value=sinfo3
                widget_control,nptsID[i],set_value=sinfo4
            endif  else begin 
                sinfo1 = 'Data Value is a string ' 
                sinfo2 = 'Integer equivalents'
                widget_control,meanstdID[i,0],set_value=" "
                widget_control,meanstdID[i,1],set_value=sinfo1
                widget_control,mmID[i,0],set_value=' '
                widget_control,mmID[i,1],set_value=" "
                widget_control,nptsID[i],set_value="Num pts: " + strtrim(string(npts),2)
                widget_control,extraID[i],set_value=sinfo2

                string_values = strarr(teltype[line_vals[i] -1,this_type])
                string_values = strcompress(telstring[line_vals[i] -1,this_type,*],/remove_all)
                string_num = telstring_num[line_vals[i]-1,this_type,*]
                for p = 0,nstring[this_type] -1 do begin
                    svalue = '                       '
                    if(p lt num) then svalue  = string_values[p] + '=' + strcompress(string(string_num[p]),/remove_all)
                    widget_control,intvalue[i,p],set_value = svalue
                endfor
                endelse
        endelse
        
    endif

endfor

;_______________________________________________________________________
; plot the y axis - 1/2 of the varibles on the left hand side
pos_x_min = tot_pos[0]
pos_x_max = tot_pos[0] + yaxis1_width
n_half_poss = fix(n_poss_lines/2)

for i = 0,(n_half_poss - 1) do begin
    if (line_vals[i] NE 0) then begin

        if(ext eq 1) then this_type = info.telemetry.type[i] -1
        if(ext eq 2) then this_type = info.telemetry_raw.type[i] -1
        ; now plot the y axis for this keyword
        pos_x = 0.2
        if(n_half_poss ne 1) then  pos_x = pos_x_min + i*(pos_x_max-pos_x_min)/(n_half_poss-1)


        k = (i+1)*2
        if(teltype[ line_vals[i]-1] eq 0) then begin 
            axis,pos_x,xrange=kxrange,yrange=[plot_ranges[i+1,0],$
                                              plot_ranges[i+1,1]],yaxis=0, $
                 color=line_colors[i],charsize=tcharsize,/normal,charthick=2,ystyle=1
        endif else begin
            this_num = teltype[line_vals[i]-1]

            string_title = telstring[line_vals[i]-1,0:this_num-1]
            string_num = telstring_num[line_vals[i]-1,this_type,0:this_num-1]
            
            ymin = plot_ranges[i+1,0]
            ymax = plot_ranges[i+1,1]
            num = ymax - ymin + 1
            string_values = strarr(num)
            ifound = 0
            search = ymin
            for jj = 0,num-1 do begin
                found = 0 
                ii = 0
                while (found eq 0 and ii lt this_num) do begin

                    if(string_num[ii] eq search) then Begin
                        string_values[jj] = string_title[ii]
                        found = 1
                    endif
                    ii = ii + 1
                endwhile
                if(found eq 0) then string_values[jj] = '  ' 
                search = search + 1
            endfor

            axis,pos_x,xrange=kxrange,yrange=[plot_ranges[i+1,0],$
                                              plot_ranges[i+1,1]],yaxis=0, $
                 color=line_colors[i],charsize=tcharsize,/normal,charthick=2,ystyle=1,$
                 yticks = num-1, ytickname = string_values
        endelse

        key_str = key_str_all[line_vals[i]-1,this_type]
        xyouts,pos_x,tot_pos[3]+0.03,key_str,charsize=tcharsize, $
          color=line_colors[i ],/normal,alignment=0.5

        ;if(hcopy eq 1) then begin
            house_str = info.tel_types[this_type+1]
            xyouts,pos_x,tot_pos[0]-0.03,house_str,charsize=tcharsize, $
                   color=line_colors[i ],/normal,alignment=0.5
        ;endif
    endif
endfor

; plot the y axis - 1/2 of the varibles on the right hand side
pos_x_min = tot_pos[2] - yaxis2_width
pos_x_max = tot_pos[2]
for i = n_half_poss,(n_poss_lines-1) do begin
    if (line_vals[i] NE 0) then begin
        if(ext eq 1) then this_type = info.telemetry.type[i] -1 ;  
        if(ext eq 2) then this_type = info.telemetry_raw.type[i] -1 ;  
        ; now plot the y axis for this keyword
        pos_x = pos_x_min + (i-n_half_poss)*(pos_x_max-pos_x_min)/$
          (n_poss_lines-n_half_poss-1)

        k = (i+1)*2
        if(teltype[ line_vals[i]-1] eq 0) then begin 
            axis,pos_x,xrange=kxrange,yrange=[plot_ranges[i+1,0],$
                                              plot_ranges[i+1,1]],yaxis=1, $
                 color=line_colors[i],charsize=tcharsize,/normal,charthick=2,ystyle=1
            
        endif else begin
            this_num = teltype[line_vals[i]-1]


            string_title = telstring[line_vals[i]-1,0:this_num-1]
            string_num = telstring_num[line_vals[i]-1,this_type,0:this_num-1]
            
            ymin = plot_ranges[i+1,0]
            ymax = plot_ranges[i+1,1]
            num = ymax - ymin + 1
            string_values = strarr(num)
            ifound = 0
            search = ymin
            for jj = 0,num-1 do begin
                found = 0 
                ii = 0
                while (found eq 0 and ii lt this_num) do begin

                    if(string_num[ii] eq search) then Begin
                        string_values[jj] = string_title[ii]
                        found = 1
                    endif
                    ii = ii + 1
                endwhile
                if(found eq 0) then string_values[jj] = '  ' 
                search = search + 1
            endfor


            axis,pos_x,xrange=kxrange,yrange=[plot_ranges[i+1,0],$
                                              plot_ranges[i+1,1]],yaxis=0, $
                 color=line_colors[i],charsize=tcharsize,/normal,charthick=2,ystyle=1,$
                 yticks = num-1, ytickname = string_values
        endelse
        key_str = key_str_all[line_vals[i]-1,this_type]
        xyouts,pos_x,tot_pos[3]+0.03,key_str,charsize=tcharsize, $
          color=line_colors[i],/normal,alignment=0.5
        ;if(hcopy eq 1) then begin
            house_str = info.tel_types[this_type+1]
            xyouts,pos_x,tot_pos[0]-0.03,house_str,charsize=tcharsize, $
                   color=line_colors[i ],/normal,alignment=0.5
        ;endif
    endif
endfor


; plot the color line in the widget box
for i = 0,(n_poss_lines-1) do begin
    if(hcopy eq 0) then wset,draw_window_id[i+1]
    plot,[0.0,1.0],[0.5,0.5],/normal,color=line_colors[i], $
      xstyle=4,ystyle=4,position=[0.1,0.1,0.9,0.9],xrange=[0.0,1.0], $
      yrange=[0.0,1.0],thick=2,linestyle = ltype[i]
endfor

if(ext eq 1) then begin
    info.telemetry.plot_ranges = plot_ranges
    info.telemetry.plot_mmlabel = plot_mmlabel
    info.telemetry.meanstdID = meanstdID 
endif

if(ext eq 2) then begin
    info.telemetry_raw.plot_ranges = plot_ranges
    info.telemetry_raw.plot_mmlabel = plot_mmlabel
    info.telemetry_raw.meanstdID = meanstdID 
endif

x_vals = 0
x_vals_all = 0
y_vals = 0
y_vals_all = 0
key_str = 0
key_str_all = 0
x_4vals = 0
y_4vals = 0
info.col_table = save_color 

end
