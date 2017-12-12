;***********************************************************************
;_______________________________________________________________________
pro msql_colslice_quit,event
;_______________________________________________________________________
widget_control,event.top, Get_UValue = cinfo	
widget_control,cinfo.info.QuickLook,Get_Uvalue = info


if(cinfo.graphnum eq 1 and XRegistered ('msqlcs1')) then begin
    widget_control,info.CS1_SlopeQuickLook,/destroy
endif

if(cinfo.graphnum eq 2 and XRegistered ('msqlcs2')) then begin
    widget_control,info.CS2_SlopeQuickLook,/destroy
endif

if(cinfo.graphnum eq 3 and XRegistered ('msqlcs3')) then begin
    widget_control,info.CS3_SlopeQuickLook,/destroy
endif

end

;***********************************************************************
;_______________________________________________________________________
pro msql_setup_colslice, graphnum, info
;_______________________________________________________________________
i = info.slope.integrationNO


if(graphnum eq 1) then begin ; window 1
    info.colsliceS1.xsize = info.data.slope_xsize 
    info.colsliceS1.ysize = info.data.slope_ysize

    info.colsliceS1.ximage_range[0]  = 1
    info.colsliceS1.ximage_range[1]  = info.data.slope_xsize
    info.colsliceS1.yimage_range[0]  = 1
    info.colsliceS1.yimage_range[1]  = info.data.slope_ysize

    info.colsliceS1.jintegration = info.slope.integrationNO

    frame_image = fltarr(info.data.slope_xsize,info.data.slope_ysize)

    if(info.slope.plane[0] eq info.slope.plane_cal) then begin 
        frame_image[*,*] = (*info.data.pcaldata)[*,*,0]
        info.colsliceS1.mean = info.data.cal_stat(0,0)
        info.colsliceS1.median = info.data.cal_stat(1,0)
    endif else begin
        frame_image[*,*] = (*info.data.pslopedata)[*,*,info.slope.plane[0]]
        info.colsliceS1.mean = info.data.slope_stat(0,info.slope.plane[0])
        info.colsliceS1.median = info.data.slope_stat(1,info.slope.plane[0])
    endelse
    indxs = where(finite(frame_image),n_pixels)
    if ptr_valid (info.colsliceS1.pdata) then ptr_free,info.colsliceS1.pdata
    info.colsliceS1.pdata = ptr_new(frame_image)
    frame_image = 0
    info.colsliceS1.pixelunits = 0
    if(info.slope.plane[0] ge 2) then info.colsliceS1.pixelunits = 1
endif

if(graphnum eq 2) then begin ; Zoom - Window 2

    frame_image = (*info.slope.pzoomdata)
    s = size(frame_image)
    xsize = s[1]
    ysize = s[2]

    info.colsliceS2.ximage_range[0]  = info.slope.x_zoom_start+1
    info.colsliceS2.ximage_range[1]  = info.slope.x_zoom_end+1
    info.colsliceS2.yimage_range[0]  = info.slope.y_zoom_start+1
    info.colsliceS2.yimage_range[1]  = info.slope.y_zoom_end+1

    info.colsliceS2.xsize = xsize
    info.colsliceS2.xsize = ysize


    info.colsliceS2.jintegration = info.slope.integrationNO

    info.colsliceS2.mean = info.slope.zoom_stat[0]
    info.colsliceS2.median = info.slope.zoom_stat[4]
    
;    frame_image = fltarr(xsize,ysize)
;    frame_image[*,*] = (*info.slope.pzoomdata)
    if ptr_valid (info.colsliceS2.pdata) then ptr_free,info.colsliceS2.pdata
    info.colsliceS2.pdata = ptr_new(frame_image)
    frame_image = 0
    info.colsliceS2.pixelunits = 0
    if(info.slope.plane[1] ge 2) then info.colsliceS2.pixelunits = 1
endif


if(graphnum eq 3) then begin ; Window 3
    info.colsliceS3.xsize = info.data.slope_xsize 
    info.colsliceS3.ysize = info.data.slope_ysize
    info.colsliceS3.ximage_range[0]  = 1
    info.colsliceS3.ximage_range[1]  = info.data.slope_xsize
    info.colsliceS3.yimage_range[0]  = 1
    info.colsliceS3.yimage_range[1]  = info.data.slope_ysize


    info.colsliceS3.jintegration = info.slope.integrationNO


    
    frame_image = fltarr(info.data.slope_xsize,info.data.slope_ysize)

    if(info.slope.plane[2] eq info.slope.plane_cal) then begin 
        frame_image[*,*] = (*info.data.pcaldata)[*,*,0]
        info.colsliceS3.mean = info.data.cal_stat(0,0)
        info.colsliceS3.median = info.data.cal_stat(1,0)
    endif else begin
        frame_image[*,*] = (*info.data.pslopedata)[*,*,info.slope.plane[2]]
        info.colsliceS3.mean = info.data.slope_stat(0,info.slope.plane[2])
        info.colsliceS3.median = info.data.slope_stat(1,info.slope.plane[2])
    endelse
    if ptr_valid (info.colsliceS3.pdata) then ptr_free,info.colsliceS3.pdata
    info.colsliceS3.pdata = ptr_new(frame_image)
    frame_image = 0
    info.colsliceS2.pixelunits = 0
    if(info.slope.plane[2] ge 2) then info.colsliceS3.pixelunits = 1
endif
end



;***********************************************************************
;_______________________________________________________________________
pro msql_update_colslice,cinfo,ps=ps,eps=eps,ascii=ascii,unit=iunit
;_______________________________________________________________________


graphnum = cinfo.graphnum
if(cinfo.colnum_start gt cinfo.colnum_end) then  begin
    result = dialog_message(" Your starting and ending values are in the wrong order ",/error )
    cinfo.colnum_start = cinfo.colnum_end
    widget_control,cinfo.start_col_label,set_value=cinfo.colnum_start
endif

x1 = cinfo.colnum_start-1
x2 = cinfo.colnum_end-1


scol = ' Column range: ' + strcompress(string(fix(x1)),/remove_all) + ' - ' + $
       strcompress(string(fix(x2)),/remove_all) 

yt = 'DN/s'
if(graphnum eq 1) then begin
    coldataW = (*cinfo.info.colsliceS1.pdata)[x1:x2,*]

    if(cinfo.info.colsliceS1.pixelunits eq 1) then yt = 'Y units'
endif

if(graphnum eq 2) then begin
    xdiff = x2 - x1
    x1 =  cinfo.colnum_start -cinfo.info.slope.x_zoom_start
    x2 = x1 + xdiff
    x1 = x1 -1
    x2 = x2 -1
    coldataW = (*cinfo.info.colsliceS2.pdata)[x1:x2,*]
    if(cinfo.info.colsliceS2.pixelunits eq 1) then yt = 'Y units'
endif
if(graphnum eq 3) then begin
    coldataW = (*cinfo.info.colsliceS3.pdata)[x1:x2,*]
    if(cinfo.info.colsliceS3.pixelunits eq 1) then yt = 'Y units'
endif


s = size(coldataW)
num = s[2]
width = x2 - x1 + 1

coldataALL = fltarr(num)

flagvalue = -999.99
for i = 0,num -1 do begin
    indx = where(finite( coldataW(*,i)),num)
    if(num ne 0) then coldataALL[i] = total(coldataW[*,i])/width
    if(num eq 0) then coldataALL[i] = flagvalue
endfor

indx = where(coldataALL[*] ne flagvalue,numpixel)
coldata = coldataALL(indx)


stitle = ' '
sstitle = ' ' 
if ((not keyword_set(ps)) AND (not keyword_set(eps))) then begin
wset,cinfo.draw_window_id  
endif else begin 
    stitle = cinfo.subt + scol
    sstitle = cinfo.info.control.filename_slope
endelse



n_reads = n_elements(coldata)
xvalues = indgen(n_reads) + 1
pad = 0.002
xmin = min(xvalues)
xmax = max(xvalues)
 
xpad = fix(n_reads*pad)
if(xpad le 0 ) then xpad = 1
; get min and max of signal
get_image_stat,coldata,mean_col,std,min_col,max_col,$
               min_image,max_image,median_col,stdev_mean,skew,ngood,nbad

; check if default scale is true - then reset to orginal value
if(cinfo.default_scale_colslice[0] eq 1) then begin
    cinfo.colslice_range[0,0] = xmin-xpad
    cinfo.colslice_range[0,1] = xmax+xpad
    if(cinfo.colslice_range[0,0]  lt 0) then cinfo.colslice_range[0,0] = 0
    if(cinfo.colslice_range[0,1] gt cinfo.maxsize) then cinfo.colslice_range[0,1] = cinfo.maxsize
endif 
  
if(cinfo.default_scale_colslice[1] eq 1) then begin

    cinfo.colslice_range[1,0] =min_image
    cinfo.colslice_range[1,1] = max_image
endif
x1 = cinfo.colslice_range[0,0]
x2 = cinfo.colslice_range[0,1]
y1 = cinfo.colslice_range[1,0]
y2 = cinfo.colslice_range[1,1]



plot,xvalues,coldata,xtitle = "ROW  #", ytitle=yt,$
  xrange=[x1,x2],yrange=[y1,y2],xstyle =1,ystyle=1,title = stitle,subtitle = sstitle


widget_control,cinfo.colslice_mmlabel[0,0],set_value=fix(cinfo.colslice_range[0,0])
widget_control,cinfo.colslice_mmlabel[0,1],set_value=fix(cinfo.colslice_range[0,1])
widget_control,cinfo.colslice_mmlabel[1,0],set_value=cinfo.colslice_range[1,0]
widget_control,cinfo.colslice_mmlabel[1,1],set_value=cinfo.colslice_range[1,1]

widget_control,cinfo.slabelID[0],set_value=cinfo.sname[0]+ strtrim(string(mean_col,format="(g14.6)"),2) 
widget_control,cinfo.slabelID[1],set_value=cinfo.sname[1]+ strtrim(string(std,format="(g14.6)"),2) 
widget_control,cinfo.slabelID[2],set_value=cinfo.sname[2]+ strtrim(string(median_col,format="(g14.6)"),2) 
widget_control,cinfo.slabelID[3],set_value=cinfo.sname[3]+ strtrim(string(min_col,format="(g14.6)"),2) 
widget_control,cinfo.slabelID[4],set_value=cinfo.sname[4]+ strtrim(string(max_col,format="(g14.6)"),2) 
widget_control,cinfo.slabelID[5],set_value=cinfo.sname[5]+ strtrim(string(ngood,format="(i10)"),2) 
widget_control,cinfo.slabelID[6],set_value=cinfo.sname[6]+ strtrim(string(nbad,format="(i10)"),2) 


if(keyword_set(ascii)) then begin 
    if(N_elements(iunit)) then begin
        printf,iunit,'# Comment: Start Column, End Column'
        printf,iunit,'# Comment: Row #, Value'
        printf,iunit,x1+1,x2+1
        for i = 0, n_elements(coldata)-1 do begin
            printf,iunit,i+1,coldata[i]
        endfor

    endif
endif

xvalues = 0
coldata = 0
coldataW = 0
coldataALL = 0

end


;***********************************************************************
;_______________________________________________________________________
; the event manager for the ql.pro (main base widget)
pro msql_colslice_event,event
;_______________________________________________________________________
Widget_Control,event.id,Get_uValue=event_name
widget_control,event.top, Get_UValue = cinfo
widget_control,cinfo.info.Quicklook,get_uvalue = info

graphnum = cinfo.graphnum

if (widget_info(event.id,/TLB_SIZE_EVENTS) eq 1 ) then begin

    if(graphnum eq 1) then begin
        info.colsliceS1.xwindowsize = event.x
        info.colsliceS1.ywindowsize = event.y
        info.colsliceS1.uwindowsize  = 1
    endif

    if(graphnum eq 2) then begin
        info.colsliceS2.xwindowsize = event.x
        info.colsliceS2.ywindowsize = event.y
        info.colsliceS2.uwindowsize  = 1
    endif

    if(graphnum eq 3) then begin
        info.colsliceS3.xwindowsize = event.x
        info.colsliceS3.ywindowsize = event.y
        info.colsliceS3.uwindowsize  = 1
    endif
    widget_control,event.top,set_uvalue = cinfo
    widget_control,cinfo.info.Quicklook,set_uvalue = info
    msql_display_colslice,graphnum,info
    return
endif


case 1 of

    (strmid(event_name,0,6) EQ 'printp') : begin
        print_cslice,cinfo
    end

    (strmid(event_name,0,6) EQ 'printD') : begin
        print_cslice_data,cinfo
        

    end    
;_______________________________________________________________________
; change x and y range of colslice graph 
;_______________________________________________________________________
    (strmid(event_name,0,7) EQ 'cols_mm') : begin

        if(strmid(event_name,7,1) EQ 'x') then graphno = 0 else graphno = 1 
        if(strmid(event_name,7,2) EQ 'x1') then begin
            cinfo.colslice_range[0,0]  = event.value
            widget_control,cinfo.colslice_mmlabel[0,1],get_value = temp
            cinfo.colslice_range[0,1] = temp
        endif
        if(strmid(event_name,7,2) EQ 'x2') then begin
            cinfo.colslice_range[0,1]  = event.value
            widget_control,cinfo.colslice_mmlabel[0,0],get_value = temp
            cinfo.colslice_range[0,0] = temp
        endif
        if(strmid(event_name,7,2) EQ 'y1') then begin
            cinfo.colslice_range[1,0]  = event.value
            widget_control,cinfo.colslice_mmlabel[1,1],get_value = temp
            cinfo.colslice_range[1,1] = temp
        endif
        if(strmid(event_name,7,2) EQ 'y2') then begin
            cinfo.colslice_range[1,1]  = event.value
            widget_control,cinfo.colslice_mmlabel[1,0],get_value = temp
            cinfo.colslice_range[1,0] = temp
        endif
        cinfo.default_scale_colslice[graphno] = 0

        widget_control,cinfo.colslice_recomputeID[graphno],set_value=' Default '

        msql_update_colslice,cinfo
        Widget_Control,event.top,Set_UValue=cinfo

    end
    
;_______________________________________________________________________
; set the Default range or user defined range for  colslicegram plot
    (strmid(event_name,0,2) EQ 'dr') : begin
        graphno = fix(strmid(event_name,2,1))
        if(cinfo.default_scale_colslice[graphno-1] eq 0 ) then begin ; true - turn to false
            widget_control,cinfo.colslice_recomputeID[graphno-1],set_value=' Plot Range'
            cinfo.default_scale_colslice[graphno-1] = 1
        endif

        msql_update_colslice,cinfo
        Widget_Control,event.top,Set_UValue=cinfo
    end

;_______________________________________________________________________
; show line column
;_______________________________________________________________________
    (strmid(event_name,0,3) EQ 'slc') : begin

        if(cinfo.showline_col eq 1  ) then begin ; true - turn to false
            widget_control,cinfo.showline_col_label,set_value='No Line'
            cinfo.showline_col = 0
        endif else begin        ;false then turn true
            widget_control,cinfo.showline_col_label,set_value='Show Line'
            cinfo.showline_col = 1
        endelse
        plot_col1 = float(cinfo.colnum_start)/float(info.slope.binfactor)
        plot_col2 = float(cinfo.colnum_end)/float(info.slope.binfactor)

        msql_draw_slice,graphnum,0,cinfo.showline_col,plot_col1,plot_col2,info


        Widget_Control,event.top,Set_UValue=cinfo
    end


;______________________________________________________________________
; Select a different column to plot a slice through
;_______________________________________________________________________
    (strmid(event_name,0,3) EQ 'col') : begin
        if(strmid(event_name,4,4) eq 'vals') then begin
            value = float(event.value) 
            cinfo.colnum_start = value
            if(value le 0) then cinfo.colnum_start = 1
            if(value gt cinfo.maxsize) then cinfo.colnum_start = cinfo.maxsize
            
            cinfo.colnum_end = cinfo.colnum_start + cinfo.colnum -1 

        endif

        if(strmid(event_name,4,4) eq 'valn') then begin
            value = float(event.value) 
            cinfo.colnum = value

            if(value le 0) then cinfo.colnum = 1

            value  = cinfo.colnum_start + cinfo.colnum -1
            cinfo.colnum_end = value
            cinfo.colnum = cinfo.colnum_end - cinfo.colnum_start  + 1


            if(value gt cinfo.maxsize) then begin
                cinfo.colnum_end = cinfo.maxsize
                cinfo.colnum = cinfo.colnum_end - cinfo.colnum_start  + 1
            endif

        endif

; check if the <> buttons were used
        step = 1.0
        if(strmid(event_name,4,4) eq 'move') then begin
            if(strmid(event_name,9,2) eq 'x1') then begin
                cinfo.colnum_start = cinfo.colnum_start - step
                cinfo.colnum_end = cinfo.colnum_end - step                
            endif
            if(strmid(event_name,9,2) eq 'x2') then begin
                cinfo.colnum_start = cinfo.colnum_start + step
                cinfo.colnum_end = cinfo.colnum_end + step
            endif
        endif

        if(cinfo.colnum_start le 0) then cinfo.colnum_start= 1
        if(cinfo.colnum_start ge cinfo.maxsize) then cinfo.colnum_start =cinfo.maxsize
        if(cinfo.colnum_end le 0) then cinfo.colnum_end= 1
        if(cinfo.colnum_end ge cinfo.maxsize) then cinfo.colnum_end =cinfo.maxsize

        cinfo.colnum = cinfo.colnum_end - cinfo.colnum_start + 1
        widget_control,cinfo.start_col_label,set_value=cinfo.colnum_start
        widget_control,cinfo.num_col_label,set_value=cinfo.colnum

        msql_update_colslice,cinfo


        if(cinfo.showline_col eq 1) then begin
            plot_col1 = float(cinfo.colnum_start)/float(info.slope.binfactor)
            plot_col2 = float(cinfo.colnum_end)/float(info.slope.binfactor)
            msql_draw_slice,graphnum,0,cinfo.showline_col,plot_col1,plot_col2,info
        endif
        Widget_Control,event.top,Set_UValue=cinfo
        Widget_Control,cinfo.info.QuickLook,Set_UValue=info

    end



else: print," Event name not found",event_name
endcase
end
;***********************************************************************
;***********************************************************************
pro msql_display_colslice,graphnum,info



window,1,/pixmap
wdelete,1
maxsize = 0
colnum = 50
stitle = "MIRI Slope Quick Look-Col Slice" + info.version

if(info.slope.plane[graphnum-1] eq 0) then  begin
    svalue = " Column Slice of Slope Values"
    outn = '_col_slice_slope' 
endif
if(info.slope.plane[graphnum-1] eq 1) then  begin
    svalue = " Column Slice of Uncertainties"
    outn = '_col_slice_uncertainty' 
endif
if(info.slope.plane[graphnum-1] eq 2) then  begin
    svalue = " Column Slice of Data Quality Flag"
    outn = '_col_slice_quality_flag'
endif 
if(info.slope.plane[graphnum-1] eq 3) then begin
    svalue = " Column Slice of Zero Pt"
    outn = '_col_slice_zero_pt' 
endif
if(info.slope.plane[graphnum-1] eq 4) then begin
    svalue = " Column Slice of # Good Reads"
    outn = '_col_slice_num_good_reads' 
endif
if(info.slope.plane[graphnum-1] eq 5) then begin
    svalue = " Column Slice of Frame # of 1st Sat"
    outn = '_col_slice_frame_1st_sat' 
endif
if(info.slope.plane[graphnum-1] eq 6) then begin
    svalue = " Column Slice of Max 2 point Differences"
    outn = '_col_slice_max_2pt_diff' 
endif
if(info.slope.plane[graphnum-1] eq 7) then begin
    svalue = " Column Slice of Read # of Max 2 point Differences"
    outn = '_col_slice_frame_max_2pt_diff' 
endif
if(info.slope.plane[graphnum-1] eq 8) then begin
    svalue = " Column Slice of Standard Dev 2 point Differences"
    outn = '_col_slice_stdev_2pt_diff' 
endif
if(info.slope.plane[graphnum-1] eq 9) then  begin
    svalue = " Column Slice of Slope of  2 point Differences"
    outn = '_col_slice_slope_2pt_diff' 
endif


if(graphnum eq 1) then begin

    colslice_uwindowsize = info.colslices1.uwindowsize
    colslice_xwindowsize = info.colslices1.xwindowsize
    colslice_ywindowsize = info.colslices1.ywindowsize

    jintegration = fix(info.colsliceS1.jintegration+1)

    ftitle = "  Integration #: " + strtrim(string(jintegration),2)
    maxsize = info.colsliceS1.xsize
    if( XRegistered ('msqlcs1')) then begin
        widget_control,info.CS1_SlopeQuickLook,/destroy
    endif
    colnum = (info.colsliceS1.xsize)/2
    colnum = info.slope.x_pos * info.slope.binfactor

    ij = 'int' + string(jintegration) 
    ij = strcompress(ij,/remove_all)
    outname = '_' + ij + outn + '_' 

    sxmin = strcompress(string(info.colsliceS1.ximage_range[0]),/remove_all)
    sxmax = strcompress(string(info.colsliceS1.ximage_range[1]),/remove_all)
    symin = strcompress(string(info.colsliceS1.yimage_range[0]),/remove_all)
    symax = strcompress(string(info.colsliceS1.yimage_range[1]),/remove_all)
    sregion = "Plot Region: range: " + sxmin + " - " + sxmax + " yrange: " + $
              symin + "  - " + symax 
    type = 3

endif


if(graphnum  eq 2) then begin

    colslice_uwindowsize = info.colslices2.uwindowsize
    colslice_xwindowsize = info.colslices2.xwindowsize
    colslice_ywindowsize = info.colslices2.ywindowsize
    svalue = " Zoom " + svalue
    jintegration = fix(info.colsliceS2.jintegration+1)
    ftitle = "  Integration #: " + strtrim(string(jintegration),2)
    maxsize = info.colsliceS2.xsize + info.slope.x_zoom_start

    if( XRegistered ('msqlcs2')) then begin
        widget_control,info.CS2_SlopeQuickLook,/destroy
    endif
    colnum = (info.colsliceS2.xsize)/2
    colnum = info.slope.x_pos * info.slope.binfactor

    ij = 'int' + string(jintegration) 
    ij = strcompress(ij,/remove_all)

    outname = '_' + ij + '_zoom'+ outn+ '_' 

    sxmin = strcompress(string(info.colsliceS2.ximage_range[0]),/remove_all)
    sxmax = strcompress(string(info.colsliceS2.ximage_range[1]),/remove_all)
    symin = strcompress(string(info.colsliceS2.yimage_range[0]),/remove_all)
    symax = strcompress(string(info.colsliceS2.yimage_range[1]),/remove_all)
    sregion = "Plot Region: range: " + sxmin + " - " + sxmax + " yrange: " + $
              symin + "  - " + symax 
    type = 4
endif

if(graphnum eq 3) then begin

    colslice_uwindowsize = info.colslices3.uwindowsize
    colslice_xwindowsize = info.colslices3.xwindowsize
    colslice_ywindowsize = info.colslices3.ywindowsize
    jintegration = fix(info.colsliceS3.jintegration+1)
    ftitle = "  Integration #: " + strtrim(string(jintegration),2)
    maxsize = info.colsliceS3.xsize
    if(XRegistered ('msqlcs3')) then begin
        widget_control,info.CS3_SlopeQuickLook,/destroy
    endif
    colnum = (info.colsliceS3.xsize)/2
    colnum = info.slope.x_pos * info.slope.binfactor


    ij = 'int' + string(jintegration) 
    ij = strcompress(ij,/remove_all)
    outname = '_' + ij + outn+ '_' 

    sxmin = strcompress(string(info.colsliceS3.ximage_range[0]),/remove_all)
    sxmax = strcompress(string(info.colsliceS3.ximage_range[1]),/remove_all)
    symin = strcompress(string(info.colsliceS3.yimage_range[0]),/remove_all)
    symax = strcompress(string(info.colsliceS3.yimage_range[1]),/remove_all)
    sregion = "Plot Region: range: " + sxmin + " - " + sxmax + " yrange: " + $
              symin + "  - " + symax 
    type = 5
endif

subt = svalue + ": " + ftitle

xwidget_size = 750
ywidget_size = 750
xsize_scroll = 740
ysize_scroll = 740

if(colslice_uwindowsize eq 1) then begin ; user has set window size 
    xsize_scroll =colslice_xwindowsize
    ysize_scroll = colslice_ywindowsize
endif


if(info.control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.control.x_scroll_window
if(info.control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.control.y_scroll_window
if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10

CSQuickLook = widget_base(title=stitle ,$
                          col = 1,mbar = menuBar,group_leader = info.SlopeQuickLook,$
                          xsize = xwidget_size,$
                          ysize= ywidget_size,/scroll,$
                          x_scroll_size=xsize_scroll,y_scroll_size=ysize_scroll,/TLB_SIZE_EVENTS)


QuitMenu = widget_button(menuBar,value="Quit",font = info.font2)
; add quit button
quitbutton = widget_button(quitmenu,value="Quit",event_pro='msql_colslice_quit')
PMenu = widget_button(menuBar,value="Print",font = info.font2)
PbuttonR = widget_button(Pmenu,value = "Print Plot to output file",uvalue='printp')
PbuttonD = widget_button(Pmenu,value = "Print Column Slice Data to ascii file ",uvalue='printD')
;********
; build the menubar
;********

titlelabel = widget_label(CSQuickLook, $
                           value=info.control.filename_raw,/align_left, $
                           font=info.font3,/dynamic_resize)






graph_master = widget_base(CSQuickLook,row=1)
graphID1 = widget_base(graph_master,col=1)
graphID2 = widget_base(graph_master,col=1)
;_______________________________________________________________________
subtitle = widget_label(graphID1, $
                           value=ftitle,/align_left, $
                           font=info.font3,/dynamic_resize)
;*****
;*****

colslice_mmlabel        = lonarr(2,2) ; plot label 
colslice_range          = fltarr(2,2) ; plot range
colslice_recomputeID    = lonarr(2); button controlling Default scale or User Set Scale
default_scale_colslice  = intarr(2) ; scaling min and max display ranges 

colslice_range[*,*] = 0.0
default_scale_colslice[*] = 1

tlabelID = widget_label(graphID1,$
                        value =svalue ,/align_center,$
                        font=info.font5)


rlabel = widget_label(graphID1, value=sregion, font=info.font3)

pix_num_base = widget_base(graphID1,row=1,/align_left)

labelID = widget_button(pix_num_base,uvalue='col_move_x1',value='<',font=info.font3)
labelID = widget_button(pix_num_base,uvalue='col_move_x2',value='>',font=info.font3)


xsize_label = 12    
; button to change 

colnum_start = fix(colnum+1)
colnum_end = fix(colnum+1)
colnum = 1
start_col_label = cw_field(pix_num_base,title=' Start Column',xsize=5,$
                                         value=colnum_start,font=info.font4,$
                                         uvalue='col_vals',/return_events,/integer)

num_col_label = cw_field(pix_num_base,title=' Number of  Column',xsize=5,$
                                         value=colnum,font=info.font4,$
                                         uvalue='col_valn',/return_events,/integer)


graphID = widget_draw(graphID1,$
                                    xsize = info.plotsize2,$
                                    ysize = info.plotsize2,$
                                    retain=info.retn)


pix_num_base2 = widget_base(graphID1,row=1)
labelID = widget_label(pix_num_base2,value="X->",font=info.font4)
colslice_mmlabel[0,0] = cw_field(pix_num_base2,title="min:",font=info.font4, $
                                        uvalue="cols_mmx1",/integer,/return_events, $
                                        value=fix(colslice_range[0,0]), $
                                        xsize=xsize_label,fieldfont=info.font4)

colslice_mmlabel[0,1] = cw_field(pix_num_base2,title="max:",font=info.font4, $
                                        uvalue="cols_mmx2",/integer,/return_events, $
                                        value=fix(colslice_range[0,1]),xsize=xsize_label,$
                                        fieldfont=info.font4)

colslice_recomputeID[0] = widget_button(pix_num_base2,value=' Plot Range',$
                                               font=info.font4,$
                                               uvalue = 'dr1')

pix_num_base3 = widget_base(graphID1,row=1)

labelID = widget_label(pix_num_base3,value="Y->",font=info.font4)
colslice_mmlabel[1,0] = cw_field(pix_num_base3,title="min:",font=info.font4, $
                                        uvalue="cols_mmy1",/float,/return_events, $
                                        value=colslice_range[1,0],xsize=xsize_label,$
                                        fieldfont=info.font4)

colslice_mmlabel[1,1] = cw_field(pix_num_base3,title="max:",font=info.font4, $
                                        uvalue="cols_mmy2",/float,/return_events, $
                                        value=colslice_range[1,1],xsize=xsize_label,$
                                        fieldfont=info.font4)

colslice_recomputeID[1] = widget_button(pix_num_base3,value=' Plot Range',$
                                               font=info.font4,$
                                               uvalue = 'dr2')




b_label = widget_label(graphID2,value=' ')
s_label = widget_label(graphID2,value="Statisical Information" ,/align_left,/sunken_frame,font=info.font5)

blank10 = '          '

slabelID = lonarr(7)
sname = ['Mean:              ',$
         'Standard Deviation ',$
         'Median:            ',$
         'Min:               ',$
         'Max:               ',$
         '# of Good Pixels   ',$
         '# of Bad Pixels    ']
slabelID[0] = widget_label(graphID2,value=sname[0] +blank10,/align_left)
slabelID[1] = widget_label(graphID2,value=sname[1] +blank10,/align_left)
slabelID[2] = widget_label(graphID2,value=sname[2] +blank10,/align_left)
slabelID[3] = widget_label(graphID2,value=sname[3] +blank10,/align_left)
slabelID[4] = widget_label(graphID2,value=sname[4] +blank10,/align_left)
slabelID[5] = widget_label(graphID2,value=sname[5] +blank10,/align_left)
slabelID[6] = widget_label(graphID2,value=sname[6] +blank10,/align_left)


blankID = widget_label(graphID2,value = ' ' )
showline_col = 0
showline_col_label = widget_button(graphID2,value='Plot No Line (on image)',font=info.font3,$
                                     uvalue = 'slc')


;Set up the GUI
longline = '                                                                                                                        '
longtag = widget_label(CSQuickLook,value = longline)
Widget_control,CSQuickLook,/Realize
if(graphnum eq 1) then $
XManager,'msqlcs1',CSQuickLook,/No_Block,event_handler='msql_colslice_event'

if(graphnum eq 2) then $
XManager,'msqlcs2',CSQuickLook,/No_Block,event_handler='msql_colslice_event'

if(graphnum eq 3) then $
XManager,'msqlcs3',CSQuickLook,/No_Block,event_handler='msql_colslice_event'

widget_control,graphID,get_value=tdraw_id
draw_window_id = tdraw_id


Widget_Control,info.QuickLook,Set_UValue=info
cinfo = {colnum_start           : colnum_start,$
         colnum_end             : colnum_end,$
         colnum                 : colnum,$
         maxsize                : maxsize,$
         sname                  : sname,$
         slabelID               : slabelID,$
         start_col_label        : start_col_label,$
         num_col_label          : num_col_label,$
         showline_col           : showline_col,$
         showline_col_label     : showline_col_label,$
         colslice_recomputeID   : colslice_recomputeID,$
         colslice_mmlabel       : colslice_mmlabel,$
         colslice_range         : colslice_range,$
         graphID                : graphID,$
         draw_window_id         : draw_window_id,$
         default_scale_colslice : default_scale_colslice,$
         outname                : outname,$
         graphnum               : graphnum,$
         subt                   : subt,$
         type                   : type,$
         otype                  : 0,$
         info                   : info}



if(graphnum eq 1) then begin
    info.CS1_SlopeQuickLook = CSQuickLook
    Widget_Control,info.CS1_SlopeQuickLook,Set_UValue=cinfo
    Widget_Control,info.QuickLook,Set_UValue=info
    msql_update_colslice,cinfo
    Widget_Control,info.CS1_SlopeQuickLook,Set_UValue=cinfo
endif

if(graphnum eq 2) then begin
    info.CS2_SlopeQuickLook = CSQuickLook
    Widget_Control,info.CS2_SlopeQuickLook,Set_UValue=cinfo
    Widget_Control,info.QuickLook,Set_UValue=info
    msql_update_colslice,cinfo
    Widget_Control,info.CS2_SlopeQuickLook,Set_UValue=cinfo
endif

if(graphnum eq 3) then begin
    info.CS3_SlopeQuickLook = CSQuickLook
    Widget_Control,info.CS3_SlopeQuickLook,Set_UValue=cinfo
    Widget_Control,info.QuickLook,Set_UValue=info
    msql_update_colslice,cinfo
    Widget_Control,info.CS3_SlopeQuickLook,Set_UValue=cinfo
endif

Widget_Control,info.QuickLook,Set_UValue=info



end
