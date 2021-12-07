 ;_______________________________________________________________________
pro jwst_msql_histo_quit,event

widget_control,event.top, Get_UValue = hinfo	
widget_control,hinfo.info.jwst_QuickLook,Get_Uvalue = info

if(hinfo.win eq 1 and XRegistered ('jwst_msqlh1')) then begin
    widget_control,info.jwst_HistoS1Display,/destroy
endif

if(hinfo.win eq 2 and XRegistered ('jwst_msqlh2')) then begin
    widget_control,info.jwst_HistoS2Display,/destroy
 endif

if(hinfo.win eq 3 and XRegistered ('jwst_msqlhz')) then begin
    widget_control,info.jwst_HistoSZDisplay,/destroy
endif
end

;_______________________________________________________________________
pro jwst_msql_setup_histo, win, info
;_______________________________________________________________________

; data plane 0  rate
; data plane 1  error
; data plane 2  dq
  
data_plane = info.jwst_slope.plane[win-1]
data_type = info.jwst_slope.data_type[win-1]

if(win eq 1) then begin ; Image 1 
    info.jwst_histoS1.xsize = info.jwst_data.slope_xsize 
    info.jwst_histoS1.ysize = info.jwst_data.slope_ysize

    info.jwst_histoS1.ximage_range[0]  = 1
    info.jwst_histoS1.ximage_range[1]  = info.jwst_data.slope_xsize
    info.jwst_histoS1.yimage_range[0]  = 1
    info.jwst_histoS1.yimage_range[1]  = info.jwst_data.slope_ysize

    info.jwst_histoS1.jintegration = info.jwst_image.integrationNO

    frame_image = fltarr(info.jwst_data.slope_xsize,info.jwst_data.slope_ysize)
    frame_image[*,*] = (*info.jwst_data.prate1)[*,*,data_plane]
    if(info.jwst_data.subarray eq 0) then begin
       frame_image_noref = frame_image[4:info.jwst_data.slope_xsize-5,*]
       frame_image = 0
       frame_image = frame_image_noref
       info.jwst_histoS1.ximage_range[0]  = 5
       info.jwst_histoS1.ximage_range[1]  = 1028
       frame_image_noref = 0
    endif
    
    if ptr_valid (info.jwst_histoS1.pdata) then ptr_free,info.jwst_histoS1.pdata
    info.jwst_histoS1.pdata = ptr_new(frame_image)
 endif

if(win eq 3) then begin ; zoom image
    xsize = info.jwst_slope.zoom_xplot_size
    ysize = info.jwst_slope.zoom_yplot_size

    info.jwst_histoSZ.xsize = xsize
    info.jwst_histoSZ.ysize = ysize
    xsize = info.jwst_slope.x_zoom_end - info.jwst_slope.x_zoom_start + 1
    ysize = info.jwst_slope.y_zoom_end - info.jwst_slope.y_zoom_start +1

    frame_image = fltarr(xsize,ysize)

    x1 = info.jwst_slope.x_zoom_start
    x2 = info.jwst_slope.x_zoom_end
    
    y1 = info.jwst_slope.y_zoom_start
    y2 = info.jwst_slope.y_zoom_end

    zoom_win = info.jwst_slope.zoom_window -1
    frame_image[*,*] = (*info.jwst_slope.pzoomdata)

    if(zoom_win eq 0) then begin
       if(data_plane eq 0) then szoom = "Zoom Centered on Rate     " 
       if(data_plane eq 1) then szoom = "Zoom Centered on Rate Error    " 
       if(data_plane eq 2) then szoom = "Zoom Centered on Rate DQ       "
       info.jwst_histoSZ.jintegration = -1
    endif else begin
       if(data_plane eq 0) then szoom = "Zoom Centered on Int Rate     " 
       if(data_plane eq 1) then szoom = "Zoom Centered on Int Error    " 
       if(data_plane eq 2) then szoom = "Zoom Centered on Int DQ       "
       info.jwst_histoSZ.jintegration = info.jwst_slope.integrationNO[1]
    endelse

    info.jwst_histoSZ.ximage_range[0]  = x1+1
    info.jwst_histoSZ.ximage_range[1]  = x2+1
    info.jwst_histoSZ.yimage_range[0]  = info.jwst_slope.y_zoom_start+1
    info.jwst_histoSZ.yimage_range[1]  = info.jwst_slope.y_zoom_end+1

    if ptr_valid (info.jwst_histoSZ.pdata) then ptr_free,info.jwst_histoSZ.pdata
    info.jwst_histoSZ.pdata = ptr_new(frame_image)
endif

if(win eq 2) then begin ; Image 2
    info.jwst_histoS2.xsize = info.jwst_data.slope_xsize 
    info.jwst_histoS2.ysize = info.jwst_data.slope_ysize

    info.jwst_histoS2.ximage_range[0]  = 1
    info.jwst_histoS2.ximage_range[1]  = info.jwst_data.slope_xsize
    info.jwst_histoS2.yimage_range[0]  = 1
    info.jwst_histoS2.yimage_range[1]  = info.jwst_data.slope_ysize

    info.jwst_histoS2.jintegration = info.jwst_slope.integrationNO[1]

    frame_image = fltarr(info.jwst_data.slope_xsize,info.jwst_data.slope_ysize)
    frame_image[*,*] = (*info.jwst_data.prate2)[*,*,data_plane]
    if(info.jwst_data.subarray eq 0) then begin
        frame_image_noref = frame_image[4:info.jwst_data.slope_xsize-5,*]
        frame_image = 0
        frame_image = frame_image_noref
        info.jwst_histoS2.ximage_range[0]  = 5
        info.jwst_histoS2.ximage_range[1]  = 1028
        frame_image_noref = 0
     endif

    if ptr_valid (info.jwst_histoS2.pdata) then ptr_free,info.jwst_histoS2.pdata
    info.jwst_histoS2.pdata = ptr_new(frame_image)
endif

frame_image = 0
end

;_______________________________________________________________________
pro jwst_msql_update_histo,hinfo,ps=ps,eps=eps,ascii=ascii,unit=iunit
;_______________________________________________________________________
hcopy = 0
if ( (keyword_set(ps)) or ( keyword_set(eps)) ) then hcopy = 1

win = hinfo.win
; data plane 0  rate
; data plane 1  error
; data plane 2  dq
data_plane = hinfo.info.jwst_slope.plane[win-1]
data_type = hinfo.info.jwst_slope.data_type[win-1]
xt = 'Rate'
if(data_plane eq 1) then xt = 'Error'
if(data_plane eq 2) then xt = 'DQ'
numbins = hinfo.histo_binnum

if(hcopy eq 0 ) then wset,hinfo.draw_window_id
if(win eq 1) then begin
    frame_image = (*hinfo.info.jwst_histoS1.pdata)
 endif
if(win eq 2) then begin
    frame_image = (*hinfo.info.jwst_histoS2.pdata)
endif
if(win eq 3) then begin
    frame_image = (*hinfo.info.jwst_histoSZ.pdata)
endif

indxs = where(finite(frame_image),n_pixels)
min = min(frame_image[indxs])
max = max(frame_image[indxs])
median = median(frame_image[indxs])
mean = mean(frame_image[indxs])
stdev = stddev(frame_image[indxs])

smin = strcompress(string(min),/remove_all) 
smax = strcompress(string(max),/remove_all) 
smedian = strcompress(string(median),/remove_all) 
smean = strcompress(string(mean),/remove_all) 
sstdev = strcompress(string(stdev),/remove_all) 
snum = strcompress(string(n_pixels),/remove_all) 

hinfo.mean = mean
hinfo.median = median
hinfo.standard_dev = stdev

if(hinfo.default_scale_histo[0] eq 0) then begin
    xhistomin = hinfo.histo_range[0,0]
    xhistomax = hinfo.histo_range[0,1]
endif else begin
    xhistomin = median - 3*stdev
    xhistomax = median + 3*stdev
    if(finite(xhistomin) eq 0) then xhistomin = 0 
    if(finite(xhistomax) eq 0) then xhistomax = 1
endelse

jwst_findhistogram_xlimits,frame_image,xnew,h,numbins,bins,xplot_min,xplot_max,xhistomin,xhistomax,status


sstitle = ' ' 
if(hcopy eq 1) then begin
   sstitle = hinfo.info.jwst_control.filename_slope
   if(info.jwst_control.file_slope_int_exist eq 1 and win eq 3) then $
      sstitle = hinfo.info.jwst_control.filename_slope_int
endif
   
min_value = min(h)
max_value = max(h)

max_value = max_value + .1*max_value
hinfo.histo_range[0,0] = xplot_min
hinfo.histo_range[0,1] = xplot_max
  
if(hinfo.default_scale_histo[1] eq 1) then begin
    hinfo.histo_range[1,0] = 0
    hinfo.histo_range[1,1] = max_value
endif

x1 = hinfo.histo_range[0,0]
x2 = hinfo.histo_range[0,1]

y1 = hinfo.histo_range[1,0]
y2 = hinfo.histo_range[1,1]

plot,xnew,h,psym=10,xtitle= xt,ytitle='Number of Pixels',$
     yrange = [y1,y2],xrange=[x1,x2],$
     xstyle = 1,$
     ystyle=1,title = stitle,subtitle = sstitle,/nodata,ytickformat = '(f8.0)',xtickformat= '(f9.3)'
oplot,xnew,h,psym=10
if(status ne 0) then begin
    print,'All the values were the same for the histogram plot'
    ypt = (y2 + y1)/2.0
    xyouts,xplot_min,ypt,'  All Values = ' + string(xplot_min)
endif

widget_control,hinfo.median_labelID,set_value=('Median: ' +smedian) 
widget_control,hinfo.mean_labelID,set_value=('Mean: ' +smean) 
widget_control,hinfo.std_labelID,set_value=('Standard Devation: ' +sstdev )
widget_control,hinfo.min_labelID,set_value=('Minimum: ' +smin) 
widget_control,hinfo.max_labelID,set_value=('Maximum: ' +smax) 

widget_control,hinfo.histo_binlabel,set_value=hinfo.histo_binnum
widget_control,hinfo.histo_mmlabel[0,0],set_value=hinfo.histo_range[0,0]
widget_control,hinfo.histo_mmlabel[0,1],set_value=hinfo.histo_range[0,1]
widget_control,hinfo.histo_mmlabel[1,0],set_value=hinfo.histo_range[1,0]
widget_control,hinfo.histo_mmlabel[1,1],set_value=hinfo.histo_range[1,1]

if(hinfo.use_standard_dev eq 1) then begin 
    widget_control,hinfo.stdvalue_labelID[0],get_value = temp
    hinfo.std_limit_lower = temp

    widget_control,hinfo.stdvalue_labelID[1],get_value = temp
    hinfo.std_limit_upper = temp
    center = 0

    if(hinfo.use_median eq 1 )then  center =  hinfo.median
    if(hinfo.use_mean eq 1 ) then center =  hinfo.mean
    st1 = center - (hinfo.standard_dev)*hinfo.std_limit_lower
    st2 = center + (hinfo.standard_dev)*hinfo.std_limit_upper

    hinfo.limit1 = st1
    hinfo.limit2 = st2
endif


if(hinfo.use_input eq 1) then begin 
    widget_control,hinfo.lvalue_labelID[0],get_value = temp
    hinfo.limit_lower = temp

    widget_control,hinfo.lvalue_labelID[1],get_value = temp
    hinfo.limit_upper = temp

    st1 = hinfo.limit_lower
    st2 = hinfo.limit_upper
    hinfo.limit1 = st1
    hinfo.limit2 = st2
endif
s1= strcompress(string(st1),/remove_all) 
s2= strcompress(string(st2),/remove_all) 
widget_control,hinfo.limit1_labelID,set_value=('Lower Limit: ' +s1) 
widget_control,hinfo.limit2_labelID,set_value=('Upper Limit: ' +s2) 


xlimit = fltarr(2) & ylimit = fltarr(2)
xlimit[*] = st1   & ylimit[0] = 0  & ylimit[1] =  max_value*10
oplot,xlimit,ylimit,color=FSC_Color('red'),thick=2

xlimit[*] = st2   & ylimit[0] = 0  & ylimit[1] =  max_value*10
oplot,xlimit,ylimit,color=FSC_Color('red'),thick=2
index1 = where(frame_image[*,*] lt st1,num1) 
index1 = where(frame_image[*,*] gt st2, num2)
num = num1 + num2 
snum = strcompress(string(num),/remove_all)
snum1 = strcompress(string(num1),/remove_all)
snum2 = strcompress(string(num2),/remove_all)

widget_control,hinfo.num1_labelID,set_value=('# Below Limit: ' +snum1) 
widget_control,hinfo.num2_labelID,set_value=('# Above Limit: ' +snum2) 
widget_control,hinfo.num_labelID,set_value=('Total # outside Limits: ' +snum) 

if(keyword_set(ascii)) then begin 
    if(N_elements(iunit)) then begin
        printf,iunit,'# Comment: Binsize, center of first bin, center of last bin'
        printf,iunit,'# Comment: center of bin, number in bin'
        printf,iunit,bins,xplot_min,xplot_max
        for i = 0, n_elements(h)-1 do begin
            printf,iunit,xnew[i],h[i]
        endfor

    endif
endif
frame_image = 0
xnew = 0
h = 0

end

;***********************************************************************
; the event manager for the ql.pro (main base widget)
pro jwst_msql_histo_event,event

Widget_Control,event.id,Get_uValue=event_name
widget_control,event.top, Get_UValue = hinfo
Widget_Control, hinfo.info.jwst_QuickLook, Get_UValue=info
win = hinfo.win

if (widget_info(event.id,/TLB_SIZE_EVENTS) eq 1 ) then begin
    if(win eq 1) then begin
        info.jwst_histoS1.xwindowsize = event.x
        info.jwst_histoS1.ywindowsize = event.y
        info.jwst_histoS1.uwindowsize  = 1
    endif

    if(win eq 3) then begin
        info.jwst_histoZ.xwindowsize = event.x
        info.jwst_histoZ.ywindowsize = event.y
        info.jwst_histoZ.uwindowsize  = 1
    endif

    if(win eq 2) then begin
        info.jwst_histoS2.xwindowsize = event.x
        info.jwst_histoS2.ywindowsize = event.y
        info.jwst_histoS2.uwindowsize  = 1
    endif
    widget_control,event.top,set_uvalue = hinfo
    widget_control,hinfo.info.Quicklook,set_uvalue = info
    jwst_msql_display_histo,win,info
    return
endif

case 1 of
    (strmid(event_name,0,6) EQ 'printP') : begin
        jwst_print_histo,hinfo
    end    

    (strmid(event_name,0,6) EQ 'printD') : begin
        jwst_print_histo_data,hinfo
    end    

    (strmid(event_name,0,3) EQ 'Bin') : begin
        hinfo.histo_binnum = event.value
        jwst_msql_update_histo,hinfo
        Widget_Control,event.top,Set_UValue=hinfo
    end

    (strmid(event_name,0,3) EQ 'md1') : begin
        hinfo.use_median = 1  
        hinfo.use_mean = 0  
        widget_control,hinfo.mdID1,set_button = 1
        widget_control,hinfo.mnID1,set_button = 0
       
        jwst_msql_update_histo,hinfo
        Widget_Control,event.top,Set_UValue=hinfo
    end

    (strmid(event_name,0,3) EQ 'mn1') : begin
        hinfo.use_mean = 1  
        hinfo.use_median = 0  
        widget_control,hinfo.mdID1,set_button = 0
        widget_control,hinfo.mnID1,set_button = 1
       
        jwst_msql_update_histo,hinfo
        Widget_Control,event.top,Set_UValue=hinfo
    end

    (strmid(event_name,0,7) EQ 'option1') : begin
        hinfo.use_standard_dev = 1
        hinfo.use_input  = 0      
        widget_control,hinfo.limit_option1,set_button = 1
        widget_control,hinfo.limit_option2,set_button = 0
        
        jwst_msql_update_histo,hinfo
        Widget_Control,event.top,Set_UValue=hinfo
    end

    (strmid(event_name,0,7) EQ 'option2') : begin
        hinfo.use_input  = 1  
        hinfo.use_standard_dev = 0
        widget_control,hinfo.limit_option2,set_button = 1
        widget_control,hinfo.limit_option1,set_button = 0
       
        jwst_msql_update_histo,hinfo
        Widget_Control,event.top,Set_UValue=hinfo
    end

    (strmid(event_name,0,4) EQ 'stdu') : begin
        hinfo.std_limit_upper = event.value
        
        hinfo.use_standard_dev = 1
        hinfo.use_input = 0
        widget_control,hinfo.limit_option1,set_button = 1
        widget_control,hinfo.limit_option2,set_button = 0
        
        jwst_msql_update_histo,hinfo
        Widget_Control,event.top,Set_UValue=hinfo
    end

    (strmid(event_name,0,4) EQ 'stdl') : begin
        hinfo.std_limit_lower = event.value
        hinfo.use_standard_dev = 1
        hinfo.use_input = 0
        widget_control,hinfo.limit_option1,set_button = 1
        widget_control,hinfo.limit_option2,set_button = 0
       
        jwst_msql_update_histo,hinfo
        Widget_Control,event.top,Set_UValue=hinfo
    end

    (strmid(event_name,0,6) EQ 'limitl') : begin
        hinfo.limit_lower = event.value
        hinfo.use_input = 1
        hinfo.use_standard_dev = 0
        widget_control,hinfo.limit_option1,set_button = 0
        widget_control,hinfo.limit_option2,set_button = 1
        
        jwst_msql_update_histo,hinfo
        Widget_Control,event.top,Set_UValue=hinfo
    end

    (strmid(event_name,0,6) EQ 'limitu') : begin
        hinfo.limit_upper = event.value
        hinfo.use_input = 1
        hinfo.use_standard_dev = 0
        widget_control,hinfo.limit_option1,set_button = 0
        widget_control,hinfo.limit_option2,set_button = 1
        jwst_msql_update_histo,hinfo
        Widget_Control,event.top,Set_UValue=hinfo
    end
    (strmid(event_name,0,6) EQ 'limits'): begin
        jwst_msql_update_histo,hinfo
        Widget_Control,event.top,Set_UValue=hinfo
     end
;_______________________________________________________________________
; change x and y range of histo graph
;_______________________________________________________________________
    (strmid(event_name,0,7) EQ 'hist_mm') : begin

        if(strmid(event_name,7,1) EQ 'x') then graphno = 0 else graphno = 1 
        if(strmid(event_name,7,2) EQ 'x1') then begin
            hinfo.histo_range[0,0]  = event.value
            widget_control,hinfo.histo_mmlabel[0,1],get_value = temp
            hinfo.histo_range[0,1] = temp

        endif
        if(strmid(event_name,7,2) EQ 'x2') then begin
            hinfo.histo_range[0,1]  = event.value
            widget_control,hinfo.histo_mmlabel[0,0],get_value = temp
            hinfo.histo_range[0,0] = temp
        endif

        if(strmid(event_name,7,2) EQ 'y1') then begin
            hinfo.histo_range[1,0]  = event.value
            widget_control,hinfo.histo_mmlabel[1,1],get_value = temp
            hinfo.histo_range[1,1] = temp
        endif
        if(strmid(event_name,7,2) EQ 'y2') then  begin
            hinfo.histo_range[1,1]  = event.value
            widget_control,hinfo.histo_mmlabel[1,0],get_value = temp
            hinfo.histo_range[1,0] = temp
        endif

        hinfo.default_scale_histo[graphno] = 0
        widget_control,hinfo.histo_recomputeID[graphno],set_value='Default Range'
        jwst_msql_update_histo,hinfo
        Widget_Control,event.top,Set_UValue=hinfo
    end
    
;_______________________________________________________________________
; set the Default range or user defined range for  histogram plot
    (strmid(event_name,0,1) EQ 'h') : begin
        graphno = fix(strmid(event_name,1,1))
        if(hinfo.default_scale_histo[graphno-1] eq 1 ) then begin ; true - turn to false
            widget_control,hinfo.histo_recomputeID[graphno-1],set_value='Default Range'
            hinfo.default_scale_histo[graphno-1] = 0
        endif else begin        ;false then turn true
            widget_control,hinfo.histo_recomputeID[graphno-1],set_value=' Plot Range'
            hinfo.default_scale_histo[graphno-1] = 1
        endelse

        jwst_msql_update_histo,hinfo
        Widget_Control,event.top,Set_UValue=hinfo
    end
else: print," Event name not found",event_name
endcase
end

;***********************************************************************
pro jwst_msql_display_histo,win,info

window,1,/pixmap
wdelete,1

jintegration = 0 
if(win eq 1) then begin
   data_plane = info.jwst_slope.plane[0]
   data_type = info.jwst_slope.data_type[0] 
    histo_uwindowsize = info.jwst_histoS1.uwindowsize
    histo_xwindowsize = info.jwst_histoS1.xwindowsize
    histo_ywindowsize = info.jwst_histoS1.ywindowsize

    stitle = "MIRI Slope Quick Look- Histogram" + info.jwst_version
    jintegration = fix(info.jwst_histoS1.jintegration+1)

    ftitle = "Integration #: " + strtrim(string(jintegration),2) 
    if( XRegistered ('jwst_msqlh1')) then begin
        widget_control,info.jwst_histoS1Display,/destroy
    endif

    ij = 'int' + string(jintegration) 
    ij = strcompress(ij,/remove_all)

    outname = '_'+ ij  + info.jwst_output.histoS1

    sxmin = strcompress(string(info.jwst_histoS1.ximage_range[0]),/remove_all)
    sxmax = strcompress(string(info.jwst_histoS1.ximage_range[1]),/remove_all)
    symin = strcompress(string(info.jwst_histoS1.yimage_range[0]),/remove_all)
    symax = strcompress(string(info.jwst_histoS1.yimage_range[1]),/remove_all)
    sregion = "Plot Region: range: " + sxmin + " - " + sxmax + " yrange: " + $
              symin + "  - " + symax + "  [No reference pixels included.]" 
endif

if(win eq 3) then begin
   data_plane = info.jwst_slope.plane[2]
   data_type = info.jwst_slope.data_type[2] 
    histo_uwindowsize = info.jwst_histoSZ.uwindowsize
    histo_xwindowsize = info.jwst_histoSZ.xwindowsize
    histo_ywindowsize = info.jwst_histoSZ.ywindowsize
    stitle = "MIRI Quick Look- Histo Zoomed Science Frame" + info.jwst_version
    jintegration = fix(info.jwst_histoSZ.jintegration+1)

    ftitle = "Integration #: " + strtrim(string(jintegration),2) 
    if( XRegistered ('jwst_msqlhz')) then begin
        widget_control,info.jwst_histoSZDisplay,/destroy
    endif

    ij = 'int' + string(jintegration)   
    ij = strcompress(ij,/remove_all)

    outname ='_'+ ij + info.jwst_output.histoSZ  

    sxmin = strcompress(string(info.jwst_histoSZ.ximage_range[0]),/remove_all)
    sxmax = strcompress(string(info.jwst_histoSZ.ximage_range[1]),/remove_all)
    symin = strcompress(string(info.jwst_histoSZ.yimage_range[0]),/remove_all)
    symax = strcompress(string(info.jwst_histoSZ.yimage_range[1]),/remove_all)
    sregion = "Plot Region: range: " + sxmin + " - " + sxmax + " yrange: " + $
              symin + "  - " + symax + "  [No reference pixels included.]" 
endif

if(win eq 2) then begin
   data_plane = info.jwst_slope.plane[1]
   data_type = info.jwst_slope.data_type[1] 
    histo_uwindowsize = info.jwst_histoS.uwindowsize
    histo_xwindowsize = info.jwst_histoS.xwindowsize
    histo_ywindowsize = info.jwst_histoS.ywindowsize
    stitle = "MIRI Quick Look- Histo Slope Image" + info.jwst_version

    jintegration = fix(info.jwst_histoS.jintegration+1)
    ftitle = " Integration #: " + strtrim(string(jintegration),2)
    if(XRegistered ('jwst_msqlh2')) then begin
        widget_control,info.jwst_histoS2Display,/destroy
    endif

    ij = 'int' + string(jintegration)   
    ij = strcompress(ij,/remove_all)
    outname = '_'+ ij + info.jwst_output.histoS2 

    sxmin = strcompress(string(info.jwst_histoS.ximage_range[0]),/remove_all)
    sxmax = strcompress(string(info.jwst_histoS.ximage_range[1]),/remove_all)
    symin = strcompress(string(info.jwst_histoS.yimage_range[0]),/remove_all)
    symax = strcompress(string(info.jwst_histoS.yimage_range[1]),/remove_all)
    sregion = "Plot Region: range: " + sxmin + " - " + sxmax + " yrange: " + $
              symin + "  - " + symax + "  [No reference pixels included.]"  
endif

subt = ftitle

; widget window parameters
xwidget_size = 1000
ywidget_size = 900
xsize_scroll = 900
ysize_scroll = 900

if(histo_uwindowsize eq 1) then begin ; user has set window size 
    xsize_scroll =histo_xwindowsize
    ysize_scroll = histo_ywindowsize
endif
if(info.jwst_control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.jwst_control.x_scroll_window
if(info.jwst_control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.jwst_control.y_scroll_window

if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-20
if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-20

HistoQuickLook = widget_base(title=stitle ,$
                             col = 1,mbar = menuBar,group_leader=info.jwst_SlopeQuickLook,$
                             xsize = xwidget_size,$
                             ysize= ywidget_size,/scroll,$
                             x_scroll_size=xsize_scroll,y_scroll_size=ysize_scroll,/TLB_SIZE_EVENTS)

QuitMenu = widget_button(menuBar,value="Quit",font = info.font2)
; add quit button
quitbutton = widget_button(quitmenu,value="Quit",event_pro='jwst_msql_histo_quit')

PMenu = widget_button(menuBar,value="Print",font = info.font2)
PbuttonR = widget_button(Pmenu,value = "Print Histogram Plot to an output file ",uvalue='printP')
PbuttonD = widget_button(Pmenu,value = "Print Histogram Data to ascii file ",uvalue='printD')
;********
; build the menubar
;********

titlelabel = widget_label(HistoQuickLook, $
                           value=info.jwst_control.filename_slope,/align_left, $
                           font=info.font3,/dynamic_resize)

subtitle = widget_label(HistoQuickLook, $
                           value=ftitle,/align_left, $
                           font=info.font3,/dynamic_resize)
;_______________________________________________________________________
histo_mmlabel        = lonarr(2,2) ; plot label 
histo_range          = fltarr(2,2) ; plot range
histo_recomputeID    = lonarr(2); button controlling Default scale or User Set Scale
default_scale_histo  = intarr(2) ; scaling min and max display ranges 

histo_range[*,*] = 0.0
default_scale_histo[*] = 1

svalue = '   '

if(data_type eq 1) then begin 
   if(data_plane eq 0) then svalue = 'Rate'
   if(data_plane eq 1) then svalue = 'Rate Error'
   if(data_plane eq 2) then svalue = 'Rate DQ'
endif

if(data_type eq 2) then begin 
   if(data_plane eq 0) then svalue = 'Int Rate'
   if(data_plane eq 1) then svalue = 'Int Rate Error'
   if(data_plane eq 2) then svalue = 'Int Rate DQ'
endif
tlabelID = widget_label(HistoQuickLook,$
                        value =svalue ,/align_center,$
                        font=info.font5)
rlabel = widget_label(HistoQuicklook, value=sregion, font=info.font3)
xsize_label = 10    

graph_master = widget_base(HistoQuickLook,row=1)
graphID1 = widget_base(graph_master,col=1)
graphID2 = widget_base(graph_master,col=1)

; button to change 
histo_binnum = 5000
pix_num_base = widget_base(graphID1,row=1,/align_center)
histo_binlabel = cw_field(pix_num_base,title='Number of Bins',xsize=xsize_label,$
                                         value=histo_binnum,font=info.font4,$
                                         uvalue='Bin',/return_events)

graphID = widget_draw(graphID1,$
                      xsize = info.jwst_plotsize1*2.2,$
                      ysize = info.jwst_plotsize1*2.2,$
                      retain=info.retn)
pix_num_base2 = widget_base(graphID1,row=1)
labelID = widget_label(pix_num_base2,value="X->",font=info.font4)
histo_mmlabel[0,0] = cw_field(pix_num_base2,title="min:",font=info.font4, $
                                        uvalue="hist_mmx1",/float,/return_events, $
                                        value=histo_range[0,0], $
                                        xsize=xsize_label,fieldfont=info.font4)

histo_mmlabel[0,1] = cw_field(pix_num_base2,title="max:",font=info.font4, $
                                        uvalue="hist_mmx2",/float,/return_events, $
                                        value=histo_range[0,1],xsize=xsize_label,$
                                        fieldfont=info.font4)

histo_recomputeID[0] = widget_button(pix_num_base2,value=' Plot Range ',$
                                               font=info.font4,$
                                               uvalue = 'h1',/dynamic_resize)

pix_num_base3 = widget_base(graphID1,row=1)
labelID = widget_label(pix_num_base3,value="Y->",font=info.font4)
histo_mmlabel[1,0] = cw_field(pix_num_base3,title="min:",font=info.font4, $
                                        uvalue="hist_mmy1",/float,/return_events, $
                                        value=histo_range[1,0],xsize=xsize_label,$
                                        fieldfont=info.font4)

histo_mmlabel[1,1] = cw_field(pix_num_base3,title="max:",font=info.font4, $
                                        uvalue="hist_mmy2",/float,/return_events, $
                                        value=histo_range[1,1],xsize=xsize_label,$
                                        fieldfont=info.font4)

histo_recomputeID[1] = widget_button(pix_num_base3,value=' Plot Range ',$
                                               font=info.font4,$
                                               uvalue = 'h2',/dynamic_resize)

blank10 = '              '
median_labelID = widget_label(graphID2,$
                         value='Median: ' + blank10,/align_left,font=info.font3)

mean_labelID = widget_label(graphID2,$
                         value='Mean: ' + blank10,/align_left,font=info.font3)

std_labelID = widget_label(graphID2,$
                         value='Standard Deviation: ' + blank10,/align_left,font=info.font3)

min_labelID = widget_label(graphID2,$
                         value='Minimum: ' + blank10,/align_left,font=info.font3)

max_labelID = widget_label(graphID2,$
                         value='Maximum: ' + blank10,/align_left,font=info.font3)

subtitle = widget_label(graphID2, $
                           value='Set Cut Limits',/align_left, $
                           font=info.font5)

base = widget_base(graphID2,row= 1,/align_left)
r_label1 = widget_label(base,value = ' Use Median')
obase = widget_base(base,/row,/nonexclusive)
mdID1 = widget_button(obase,value = 'Yes',uvalue = 'md1')
widget_control,mdID1,set_button = 1
use_median = 1

base = widget_base(graphID2,row= 1,/align_left)
r_label1 = widget_label(base,value = ' Use Mean')
obase = widget_base(base,/row,/nonexclusive)
mnID1 = widget_button(obase,value = 'Yes',uvalue = 'mn1')
widget_control,mnID1,set_button = 0
use_mean = 0

info_label = widget_label(graphID2,$
                          value = 'Input the desired cut-off limits',$
                          font = info.font5,/align_left)
stdvalue_labelID = lonarr(2)
base = widget_base(graphID2,row= 1,/align_left)

r_label1 = widget_label(base,value = ' Limits Based on Standard Deviations')
obase = widget_base(base,/row,/nonexclusive)
limit_option1 = widget_button(obase,value = 'Yes',uvalue = 'option1')
widget_control,limit_option1,set_button = 1
use_standard_dev = 1

std_limit_upper = 3.0
std_limit_lower = 3.0
base = widget_base(graphID2,row= 1,/align_left)
stdvalue_labelID[0] = cw_field(base,title="        - Std dev",font=info.font4, $
                                uvalue="stdl",/float,/return_events, $
                                value=std_limit_lower,xsize=7,$
                                fieldfont=info.font4)

stdvalue_labelID[1] = cw_field(base,title=" + Std dev",font=info.font4, $
                                uvalue="stdu",/float,/return_events, $
                                value=std_limit_upper,xsize=7,$
                                fieldfont=info.font4)

lvalue_labelID = lonarr(2) 
limit_lower = 0.0
limit_upper = 0.0
base = widget_base(graphID2,row= 1,/align_left)
r_label1 = widget_label(base,value = ' Limits based on User Input')
obase = widget_base(base,/row,/nonexclusive)
limit_option2 = widget_button(obase,value = 'Yes',uvalue = 'option2')
widget_control,limit_option2,set_button = 0
use_input = 0
base = widget_base(graphID2,row= 1,/align_left)
lvalue_labelID[0] = cw_field(base,title="        Lower Limit",font=info.font4, $
                                uvalue="limitl",/float,/return_events, $
                                value=limit_lower,xsize=7,$
                                fieldfont=info.font4)

lvalue_labelID[1] = cw_field(base,title=" Upper Limit",font=info.font4, $
                                uvalue="limitu",/float,/return_events, $
                                value=limit_upper,xsize=7,$
                                fieldfont=info.font4)

dropLabel = widget_label(graphID2, value = ' # Pixels Outside Limits',$
                         font=info.font5,/align_left)

limit1_labelID = widget_label(graphID2,$
                         value='Lower Limit: ' + blank10,/align_left,font=info.font3)

limit2_labelID = widget_label(graphID2,$
                         value='Upper Limit: ' + blank10,/align_left,font=info.font3)

num1_labelID = widget_label(graphID2,$
                         value='# Below Limit: ' + blank10,/align_left,font=info.font3)
num2_labelID = widget_label(graphID2,$
                         value='# Above Limit: ' + blank10,/align_left,font=info.font3)
num_labelID = widget_label(graphID2,$
                         value='Total # Outside Limits: ' + blank10,/align_left,font=info.font3)

;Set up the GUI
longline = '                                                                                                                        '
longtag = widget_label(HistoQuickLook,value = longline)
Widget_control,HistoQuickLook,/Realize

if(win eq 1) then $
   XManager,'jwst_msqlh1',HistoQuickLook,/No_Block,event_handler='jwst_msql_histo_event'

if(win eq 2) then $
   XManager,'jwst_msqlh2',HistoQuickLook,/No_Block,event_handler='jwst_msql_histo_event'

if(win eq 3) then $
   XManager,'jwst_msqlhz',HistoQuickLook,/No_Block,event_handler='jwst_msql_histo_event'

widget_control,graphID,get_value=tdraw_id
draw_window_id = tdraw_id

mean = 0.0 
median = 0.0
standard_dev = 0.0
limit1 = 0.0 & limit2 = 0.0

Widget_Control,info.jwst_QuickLook,Set_UValue=info
hinfo = {histo_binnum        : histo_binnum,$
         histo_binlabel      : histo_binlabel,$
         median_labelID      : median_labelID,$
         min_labelID         : min_labelID,$
         max_labelID         : max_labelID,$
         mean_labelID        : mean_labelID,$
         std_labelID         : std_labelID,$
         mdID1               : mdID1,$
         mnID1               : mnID1,$
         limit_option1       : limit_option1,$
         limit_option2       : limit_option2,$
         use_standard_dev    : use_standard_dev,$
         use_input           : use_input,$
         num_labelID         : num_labelID,$
         num1_labelID        : num1_labelID,$
         num2_labelID        : num2_labelID,$
         limit1_labelID      : limit1_labelID,$
         limit2_labelID      : limit2_labelID,$
         stdvalue_labelID    : stdvalue_labelID,$
         std_limit_upper     : std_limit_upper,$
         std_limit_lower     : std_limit_lower,$
         lvalue_labelID      : lvalue_labelID,$
         limit_lower         : limit_lower,$
         limit_upper         : limit_upper,$
         use_mean            : use_mean,$
         use_median          : use_median,$
         mean                : mean,$
         median              : median,$
         standard_dev        : standard_dev,$
         limit1              : limit1,$
         limit2              : limit2,$
         histo_recomputeID   : histo_recomputeID,$
         histo_mmlabel       : histo_mmlabel,$
         histo_range         : histo_range,$
         graphID             : graphID,$
         draw_window_id      : draw_window_id,$
         default_scale_histo : default_scale_histo,$
         outname             : outname,$
         win                 : win,$
         subt                : subt,$
         otype               : 0,$
         info                : info}

Widget_Control,HistoQuickLook,Set_UValue=hinfo
jwst_msql_update_histo,hinfo

Widget_Control,HistoQuickLook,Set_UValue=hinfo

if(win eq 1) then begin
    info.jwst_histoS1Display = HistoQuickLook
    Widget_Control,info.jwst_QuickLook,Set_UValue=info
    Widget_Control,info.jwst_histoS1Display,Set_UValue=hinfo
endif

if(win eq 2) then begin
    info.jwst_histoS2Display = HistoQuickLook
    Widget_Control,info.jwst_QuickLook,Set_UValue=info
    Widget_Control,info.jwst_histoS2Display,Set_UValue=hinfo
endif

if(win eq 3) then begin
    info.jwst_histoSZDisplay = HistoQuickLook
    Widget_Control,info.jwst_QuickLook,Set_UValue=info
    Widget_Control,info.jwst_histoSZDisplay,Set_UValue=hinfo
endif

end
