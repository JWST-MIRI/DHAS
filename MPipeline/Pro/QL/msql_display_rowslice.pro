;************************************************************************
;_______________________________________________________________________
pro msql_rowslice_quit,event
;************************************************************************

widget_control,event.top, Get_UValue = cinfo	
widget_control,cinfo.info.QuickLook,Get_Uvalue = info
if(cinfo.graphnum eq 1 and XRegistered ('msqlrs1')) then begin
    widget_control,info.RS1_SlopeQuickLook,/destroy
endif

if(cinfo.graphnum eq 2 and XRegistered ('msqlrs2')) then begin
    widget_control,info.RS2_SlopeQuickLook,/destroy
endif

if(cinfo.graphnum eq 3 and XRegistered ('msqlrs3')) then begin
    widget_control,info.RS3_SlopeQuickLook,/destroy
endif
end

;************************************************************************
;_______________________________________________________________________
pro msql_setup_rowslice, graphnum, info
;_______________________________________________________________________
i = info.slope.integrationNO


if(graphnum eq 1) then begin ; Window 1
    info.rowsliceS1.xsize = info.data.slope_xsize 
    info.rowsliceS1.ysize = info.data.slope_ysize

    info.rowsliceS1.ximage_range[0]  = 1
    info.rowsliceS1.ximage_range[1]  = info.data.slope_xsize
    info.rowsliceS1.yimage_range[0]  = 1
    info.rowsliceS1.yimage_range[1]  = info.data.slope_ysize

    info.rowsliceS1.jintegration = info.slope.integrationNO


    frame_image = fltarr(info.data.slope_xsize,info.data.slope_ysize)    
    if(info.slope.plane[0] eq info.slope.plane_cal) then begin 
        frame_image[*,*] = (*info.data.pcaldata)[*,*,0]
        info.rowsliceS1.mean = info.data.cal_stat(0,0)
        info.rowsliceS1.median = info.data.cal_stat(1,0)
    endif else begin 
        frame_image[*,*] = (*info.data.pslopedata)[*,*,info.slope.plane[0]]
        info.rowsliceS1.mean = info.data.slope_stat(0,info.slope.plane[0])
        info.rowsliceS1.median = info.data.slope_stat(1,info.slope.plane[0])

    endelse
    indxs = where(finite(frame_image),n_pixels)
    if ptr_valid (info.rowsliceS1.pdata) then ptr_free,info.rowsliceS1.pdata
    info.rowsliceS1.pdata = ptr_new(frame_image)
    frame_image = 0
    info.rowsliceS1.pixelunits = 0
    if(info.slope.plane[0] ge 2) then info.rowsliceS1.pixelunits = 1
endif


if(graphnum eq 2) then begin ; Zoom - Window 2

    info.rowsliceS2.ximage_range[0]  = info.slope.x_zoom_start+1
    info.rowsliceS2.ximage_range[1]  = info.slope.x_zoom_end+1
    info.rowsliceS2.yimage_range[0]  = info.slope.y_zoom_start+1
    info.rowsliceS2.yimage_range[1]  = info.slope.y_zoom_end+1

    xsize = info.slope.zoom_xplot_size
    ysize = info.slope.zoom_yplot_size

    frame_image = (*info.slope.pzoomdata)
    s = size(frame_iamge)
    xsize = s[1]
    ysize = s[2]
 
    info.rowsliceS2.xsize = xsize
    info.rowsliceS2.ysize = ysize

    info.rowsliceS2.jintegration = info.slope.integrationNO

    info.rowsliceS2.mean = info.slope.zoom_stat[0]
    info.rowsliceS2.median = info.slope.zoom_stat[4]
    
;    frame_image = fltarr(xsize,ysize)
;    frame_image[*,*] = (*info.slope.pzoomdata)
    if ptr_valid (info.rowsliceS2.pdata) then ptr_free,info.rowsliceS2.pdata
    info.rowsliceS2.pdata = ptr_new(frame_image)
    frame_image = 0
    info.rowsliceS2.pixelunits = 0
    if(info.slope.plane[1] ge 2) then info.rowsliceS2.pixelunits = 1
endif


if(graphnum eq 3) then begin ; Window 3
    info.rowsliceS3.xsize = info.data.slope_xsize 
    info.rowsliceS3.ysize = info.data.slope_ysize
    info.rowsliceS3.ximage_range[0]  = 1
    info.rowsliceS3.ximage_range[1]  = info.data.slope_xsize
    info.rowsliceS3.yimage_range[0]  = 1
    info.rowsliceS3.yimage_range[1]  = info.data.slope_ysize

    info.rowsliceS3.jintegration = info.slope.integrationNO


    

    frame_image = fltarr(info.data.slope_xsize,info.data.slope_ysize)

    if(info.slope.plane[2] eq info.slope.plane_cal) then begin 
        frame_image[*,*] = (*info.data.pcaldata)[*,*,0]
        info.rowsliceS3.mean = info.data.cal_stat(0,0)
        info.rowsliceS3.median = info.data.cal_stat(1,0)
    endif else begin
        frame_image[*,*] = (*info.data.pslopedata)[*,*,info.slope.plane[2]]
        info.rowsliceS3.mean = info.data.slope_stat(0,info.slope.plane[2])
        info.rowsliceS3.median = info.data.slope_stat(1,info.slope.plane[2])
    endelse
    if ptr_valid (info.rowsliceS3.pdata) then ptr_free,info.rowsliceS3.pdata
    info.rowsliceS3.pdata = ptr_new(frame_image)
    frame_image = 0
    info.rowsliceS3.pixelunits = 0
    if(info.slope.plane[2] ge 2) then info.rowsliceS3.pixelunits = 1
endif
end



;***********************************************************************
;_______________________________________________________________________
pro msql_update_rowslice,cinfo,ps=ps,eps=eps,ascii=ascii,unit=iunit
;_______________________________________________________________________
graphnum = cinfo.graphnum

if(cinfo.rownum_start gt cinfo.rownum_end) then  begin
    temp = cinfo.rownum_start
    cinfo.rownum_start = cinfo.rownum_end
    cinfo.rownum_end = temp 
    widget_control,cinfo.start_row_label,set_value=cinfo.rownum_start
endif

y1 = cinfo.rownum_start-1
y2 = cinfo.rownum_end-1

srow = ' Row range: ' + strcompress(string(fix(y1)),/remove_all) + ' - ' + $
       strcompress(string(fix(y2)),/remove_all) 

yt = 'DN/s'
if(graphnum eq 1) then begin
    rowdataW = (*cinfo.info.rowsliceS1.pdata)[*,y1:y2]
    if(cinfo.info.rowsliceS1.pixelunits eq 1) then yt = 'Y units'
endif
if(graphnum eq 2) then begin
    ydiff = y2 - y1
    y1 =  cinfo.rownum_start - cinfo.info.slope.y_zoom_start
    y2 = y1 + ydiff
    y1 = y1 -1
    y2 = y2 -1
    rowdataW = (*cinfo.info.rowsliceS2.pdata)[*,y1:y2]
    if(cinfo.info.rowsliceS2.pixelunits eq 1) then yt = 'Y units'
endif
if(graphnum eq 3) then begin
    rowdataW = (*cinfo.info.rowsliceS3.pdata)[*,y1:y2]
    if(cinfo.info.rowsliceS3.pixelunits eq 1) then yt = 'Y units'
endif

s = size(rowdataW)
num = s[1]
width = y2 - y1 + 1

rowdataALL = fltarr(num)

flagvalue = -999.99
for i = 0,num -1 do begin
    indx = where(finite( rowdataW(i,*)),num)
    if(num ne 0) then rowdataALL[i] = total(rowdataW[i,*])/width
    if(num eq 0) then rowdataALL[i] = flagvalue
endfor

indx = where(rowdataALL[*] ne flagvalue,numpixel)
rowdata = rowdataALL(indx)

stitle = ' '
sstitle = ' ' 
if ((not keyword_set(ps)) AND (not keyword_set(eps))) then begin
    wset,cinfo.draw_window_id  
endif else begin 
    stitle = cinfo.subt + srow
    sstitle = cinfo.info.control.filename_slope
endelse


n_reads = n_elements(rowdata)
xvalues = indgen(n_reads) + 1
pad = 0.002
xmin = min(xvalues)
xmax = max(xvalues)

 
xpad = fix(n_reads*pad)
if(xpad le 0 ) then xpad = 1

; get signal min and max values
get_image_stat,rowdata,mean_row,std,min_row,max_row,$
               min_image,max_image,median_row,stdev_mean,skew,ngood,nbad

; check if default scale is true - then reset to orginal value
if(cinfo.default_scale_rowslice[0] eq 1) then begin
    cinfo.rowslice_range[0,0] = xmin-xpad
    cinfo.rowslice_range[0,1] = xmax+xpad
    if(cinfo.rowslice_range[0,0]  lt 0) then cinfo.rowslice_range[0,0] = 0
    if(cinfo.rowslice_range[0,1] gt cinfo.maxsize) then cinfo.rowslice_range[0,1] = cinfo.maxsize
endif 
  
if(cinfo.default_scale_rowslice[1] eq 1) then begin
    cinfo.rowslice_range[1,0] =min_image
    cinfo.rowslice_range[1,1] = max_image
endif
x1 = cinfo.rowslice_range[0,0]
x2 = cinfo.rowslice_range[0,1]
y1 = cinfo.rowslice_range[1,0]
y2 = cinfo.rowslice_range[1,1]


plot,xvalues,rowdata,xtitle = "Column #", ytitle=yt,$
  xrange=[x1,x2],yrange=[y1,y2],xstyle =1,ystyle=1,title = stitle,subtitle = sstitle


widget_control,cinfo.rowslice_mmlabel[0,0],set_value=fix(cinfo.rowslice_range[0,0])
widget_control,cinfo.rowslice_mmlabel[0,1],set_value=fix(cinfo.rowslice_range[0,1])
widget_control,cinfo.rowslice_mmlabel[1,0],set_value=cinfo.rowslice_range[1,0]
widget_control,cinfo.rowslice_mmlabel[1,1],set_value=cinfo.rowslice_range[1,1]



widget_control,cinfo.slabelID[0],set_value=cinfo.sname[0]+ strtrim(string(mean_row,format="(g14.6)"),2) 
widget_control,cinfo.slabelID[1],set_value=cinfo.sname[1]+ strtrim(string(std,format="(g14.6)"),2) 
widget_control,cinfo.slabelID[2],set_value=cinfo.sname[2]+ strtrim(string(median_row,format="(g14.6)"),2) 
widget_control,cinfo.slabelID[3],set_value=cinfo.sname[3]+ strtrim(string(min_row,format="(g14.6)"),2) 
widget_control,cinfo.slabelID[4],set_value=cinfo.sname[4]+ strtrim(string(max_row,format="(g14.6)"),2) 
widget_control,cinfo.slabelID[5],set_value=cinfo.sname[5]+ strtrim(string(ngood,format="(i10)"),2) 
widget_control,cinfo.slabelID[6],set_value=cinfo.sname[6]+ strtrim(string(nbad,format="(i10)"),2) 

if(keyword_set(ascii)) then begin 
    if(N_elements(iunit)) then begin
        printf,iunit,'# Comment: Start Row, End Row'
        printf,iunit,'# Comment: Column #, Value'
        printf,iunit,y1+1,y2+1
        for i = 0, n_elements(rowdata)-1 do begin
            printf,iunit,i+1,rowdata[i]
        endfor

    endif
endif

xvalues = 0
rowdata = 0
rowdataW = 0
rowdataALL = 0
end




;***********************************************************************
;_______________________________________________________________________
; the event manager for the ql.pro (main base widget)
pro msql_rowslice_event,event
;_______________________________________________________________________
Widget_Control,event.id,Get_uValue=event_name
widget_control,event.top, Get_UValue = cinfo
widget_control,cinfo.info.Quicklook,get_uvalue = info

graphnum = cinfo.graphnum


if (widget_info(event.id,/TLB_SIZE_EVENTS) eq 1 ) then begin

    if(graphnum eq 1) then begin
        info.rowsliceS1.xwindowsize = event.x
        info.rowsliceS1.ywindowsize = event.y
        info.rowsliceS1.uwindowsize  = 1
    endif

    if(graphnum eq 2) then begin
        info.rowsliceS2.xwindowsize = event.x
        info.rowsliceS2.ywindowsize = event.y
        info.rowsliceS2.uwindowsize  = 1
    endif

    if(graphnum eq 3) then begin
        info.rowsliceS3.xwindowsize = event.x
        info.rowsliceS3.ywindowsize = event.y
        info.rowsliceS3.uwindowsize  = 1
    endif
    widget_control,event.top,set_uvalue = cinfo
    widget_control,cinfo.info.Quicklook,set_uvalue = info
    msql_display_rowslice,graphnum,info
    return
endif


case 1 of

    (strmid(event_name,0,6) EQ 'printP') : begin
        print_rslice,cinfo
    end    
    (strmid(event_name,0,6) EQ 'printD') : begin
        print_rslice_data,cinfo
        
    end    
;_______________________________________________________________________
; change x and y range of rowslice graph 
;_______________________________________________________________________
    (strmid(event_name,0,7) EQ 'rows_mm') : begin
        if(strmid(event_name,7,1) EQ 'x') then graphno = 0 else graphno = 1 
        if(strmid(event_name,7,2) EQ 'x1') then begin
            cinfo.rowslice_range[0,0]  = event.value
            widget_control,cinfo.rowslice_mmlabel[0,1],get_value = temp
            cinfo.rowslice_range[0,1] = temp
        endif
        if(strmid(event_name,7,2) EQ 'x2') then begin
            cinfo.rowslice_range[0,1]  = event.value
            widget_control,cinfo.rowslice_mmlabel[0,0],get_value = temp
            cinfo.rowslice_range[0,0] = temp
        endif
        if(strmid(event_name,7,2) EQ 'y1') then begin
            cinfo.rowslice_range[1,0]  = event.value
            widget_control,cinfo.rowslice_mmlabel[1,1],get_value = temp
            cinfo.rowslice_range[1,1] = temp
        endif
        if(strmid(event_name,7,2) EQ 'y2') then begin
            cinfo.rowslice_range[1,1]  = event.value
            widget_control,cinfo.rowslice_mmlabel[1,0],get_value = temp
            cinfo.rowslice_range[1,0] = temp
        endif
        cinfo.default_scale_rowslice[graphno] = 0

        widget_control,cinfo.rowslice_recomputeID[graphno],set_value=' Default'
        msql_update_rowslice,cinfo
        Widget_Control,event.top,Set_UValue=cinfo
    end
    
;_______________________________________________________________________
; set the Default range or user defined range for  rowslicegram plot
    (strmid(event_name,0,2) EQ 'dr') : begin
        graphno = fix(strmid(event_name,2,1))
        if(cinfo.default_scale_rowslice[graphno-1] eq 0 ) then begin ; true - turn to false
            widget_control,cinfo.rowslice_recomputeID[graphno-1],set_value=' Plot Range'
            cinfo.default_scale_rowslice[graphno-1] = 1
        endif

        msql_update_rowslice,cinfo
        Widget_Control,event.top,Set_UValue=cinfo
    end

;_______________________________________________________________________
; show line rowumn
;_______________________________________________________________________
    (strmid(event_name,0,3) EQ 'slc') : begin
        if(cinfo.showline_row eq 1  ) then begin ; true - turn to false
            widget_control,cinfo.showline_row_label,set_value='No Line'
            cinfo.showline_row = 0
        endif else begin        ;false then turn true
            widget_control,cinfo.showline_row_label,set_value='Show Line'
            cinfo.showline_row = 1
        endelse

        plot_row1 = float(cinfo.rownum_start)/float(info.slope.binfactor)
        plot_row2 = float(cinfo.rownum_end)/float(info.slope.binfactor)

         msql_draw_slice,graphnum,1,cinfo.showline_row,plot_row1,plot_row2,info

        Widget_Control,event.top,Set_UValue=cinfo
    end
;______________________________________________________________________
; Select a different rowumn to plot a slice through
;_______________________________________________________________________
    (strmid(event_name,0,3) EQ 'row') : begin
        if(strmid(event_name,4,4) eq 'vals') then begin
            value = float(event.value) 
            cinfo.rownum_start = value
            if(value le 0) then cinfo.rownum_start = 1
            if(value gt cinfo.maxsize) then cinfo.rownum_start = cinfo.maxsize
            
            cinfo.rownum_end = cinfo.rownum_start + cinfo.rownum -1 
        endif

        if(strmid(event_name,4,4) eq 'valn') then begin
            value = float(event.value) 
            cinfo.rownum = value

            if(value le 0) then cinfo.rownum = 1
            
            value  = cinfo.rownum_start + cinfo.rownum -1
            cinfo.rownum_end = value
            cinfo.rownum = cinfo.rownum_end - cinfo.rownum_start  + 1

            if(value gt cinfo.maxsize) then begin
                cinfo.rownum_end = cinfo.maxsize
                cinfo.rownum = cinfo.rownum_end - cinfo.rownum_start  + 1

            endif
        endif

; check if the <> buttons were used
        step = 1.0
        if(strmid(event_name,4,4) eq 'move') then begin
            if(strmid(event_name,9,2) eq 'x1') then begin
                cinfo.rownum_start = cinfo.rownum_start - step
                cinfo.rownum_end = cinfo.rownum_end - step
            endif
            if(strmid(event_name,9,2) eq 'x2') then begin
                cinfo.rownum_start = cinfo.rownum_start + step
                cinfo.rownum_end = cinfo.rownum_end + step
            endif
        endif
;_______________________________________________________________________


        if(cinfo.rownum_start le 0) then cinfo.rownum_start=  1
        if(cinfo.rownum_start ge cinfo.maxsize) then cinfo.rownum_start =cinfo.maxsize

        if(cinfo.rownum_end le 0) then cinfo.rownum_end= 1
        if(cinfo.rownum_end ge cinfo.maxsize) then cinfo.rownum_end =cinfo.maxsize

        cinfo.rownum = cinfo.rownum_end - cinfo.rownum_start + 1

        widget_control,cinfo.start_row_label,set_value=cinfo.rownum_start
        widget_control,cinfo.num_row_label,set_value=cinfo.rownum

        msql_update_rowslice,cinfo

        if(cinfo.showline_row eq 1) then begin
            plot_row1 = float(cinfo.rownum_start)/float(info.slope.binfactor)
            plot_row2 = float(cinfo.rownum_end)/float(info.slope.binfactor)

            msql_draw_slice,graphnum,1,cinfo.showline_row,plot_row1,plot_row2,info
        endif
        Widget_Control,event.top,Set_UValue=cinfo
        Widget_Control,cinfo.info.QuickLook,Set_UValue=info

    end
else: print," Event name not found",event_name
endcase
end
;***********************************************************************
;***********************************************************************
pro msql_display_rowslice,graphnum,info

;print,' In msql_display_rowslice'
window,1,/pixmap
wdelete,1
maxsize = 0
rownum = 50
stitle = "MIRI Slope Quick Look- Row Slice" + info.version

if(info.slope.plane[graphnum-1] eq 0) then  begin
    svalue = " Row Slice of Slope Values"
    outn = '_row_slice_slope' 
endif
if(info.slope.plane[graphnum-1] eq 1) then  begin
    svalue = " Row Slice of Uncertainties"
    outn = '_row_slice_uncertainty' 
endif
if(info.slope.plane[graphnum-1] eq 2) then  begin
    svalue = " Row Slice of Data Quality Flag"
    outn = '_row_slice_quality_flag'
endif 
if(info.slope.plane[graphnum-1] eq 3) then begin
    svalue = " Row Slice of Zero Pt"
    outn = '_row_slice_zero_pt' 
endif
if(info.slope.plane[graphnum-1] eq 4) then begin
    svalue = " Row Slice of # Good Reads"
    outn = '_row_slice_num_good_reads' 
endif
if(info.slope.plane[graphnum-1] eq 5) then begin
    svalue = " Row Slice of Frame # of 1st Sat"
    outn = '_row_slice_frame_1st_sat' 
endif
if(info.slope.plane[graphnum-1] eq 6) then begin
    svalue = " Row Slice of Max 2 point Differences"
    outn = '_row_slice_max_2pt_diff' 
endif
if(info.slope.plane[graphnum-1] eq 7) then begin
    svalue = " Row Slice of Read # of Max 2 point Differences"
    outn = '_row_slice_frame_max_2pt_diff' 
endif
if(info.slope.plane[graphnum-1] eq 8) then begin
    svalue = " Row Slice of Standard Dev 2 point Differences"
    outn = '_row_slice_stdev_2pt_diff' 
endif
if(info.slope.plane[graphnum-1] eq 9) then  begin
    svalue = " Row Slice of Slope of  2 point Differences"
    outn = '_row_slice_slope_2pt_diff' 
endif


if(graphnum eq 1) then begin

    rowslice_uwindowsize = info.rowslices1.uwindowsize
    rowslice_xwindowsize = info.rowslices1.xwindowsize
    rowslice_ywindowsize = info.rowslices1.ywindowsize
    jintegration = fix(info.rowsliceS1.jintegration+1)
    ftitle = "Integration #: " + strtrim(string(jintegration),2) 
    maxsize = info.rowsliceS1.ysize
    if( XRegistered ('msqlrs1')) then begin
        widget_control,info.RS1_SlopeQuickLook,/destroy
    endif
    rownum = (info.rowsliceS1.ysize)/2
    rownum = info.slope.y_pos * info.slope.binfactor

    ij = strcompress( string(jintegration),/remove_all)
    outname = '_'+ ij + outn + '_' 

    sxmin = strcompress(string(info.rowsliceS1.ximage_range[0]),/remove_all)
    sxmax = strcompress(string(info.rowsliceS1.ximage_range[1]),/remove_all)
    symin = strcompress(string(info.rowsliceS1.yimage_range[0]),/remove_all)
    symax = strcompress(string(info.rowsliceS1.yimage_range[1]),/remove_all)
    sregion = "Plot Region: range: " + sxmin + " - " + sxmax + " yrange: " + $
              symin + "  - " + symax 
    type = 3

endif


if(graphnum eq 2) then begin
    rowslice_uwindowsize = info.rowslices2.uwindowsize
    rowslice_xwindowsize = info.rowslices2.xwindowsize
    rowslice_ywindowsize = info.rowslices2.ywindowsize
    svalue = " Zoom " + svalue
    jintegration = fix(info.rowsliceS2.jintegration+1)
    ftitle = "Integration #: " + strtrim(string(jintegration),2) 

    maxsize = info.rowsliceS2.ysize + info.slope.y_zoom_start

    if( XRegistered ('msqlrs2')) then begin
        widget_control,info.RS2_SlopeQuickLook,/destroy
    endif
    rownum = (info.rowsliceS2.ysize)/2
    rownum = info.slope.y_pos * info.slope.binfactor

    ij = strcompress(string(jintegration),/remove_all)
    outname = '_' + ij + '_zoom'+ outn + '_' 
    sxmin = strcompress(string(info.rowsliceS2.ximage_range[0]),/remove_all)
    sxmax = strcompress(string(info.rowsliceS2.ximage_range[1]),/remove_all)
    symin = strcompress(string(info.rowsliceS2.yimage_range[0]),/remove_all)
    symax = strcompress(string(info.rowsliceS2.yimage_range[1]),/remove_all)
    sregion = "Plot Region: range: " + sxmin + " - " + sxmax + " yrange: " + $
              symin + "  - " + symax 

    type = 4
endif


if(graphnum eq 3) then begin
    rowslice_uwindowsize = info.rowslices3.uwindowsize
    rowslice_xwindowsize = info.rowslices3.xwindowsize
    rowslice_ywindowsize = info.rowslices3.ywindowsize
    jintegration = fix(info.rowsliceS3.jintegration+1)
    ftitle = "  Integration #: " + strtrim(string(jintegration),2)
    maxsize = info.rowsliceS3.ysize
    if(XRegistered ('msqlrs3')) then begin
        widget_control,info.RS3_SlopeQuickLook,/destroy
    endif
    rownum = (info.rowsliceS3.ysize)/2
    rownum = info.slope.y_pos * info.slope.binfactor

    ij = strcompress(string(jintegration),/remove_all)
    outname = '_' + ij + outn+ '_' 
    sxmin = strcompress(string(info.rowsliceS3.ximage_range[0]),/remove_all)
    sxmax = strcompress(string(info.rowsliceS3.ximage_range[1]),/remove_all)
    symin = strcompress(string(info.rowsliceS3.yimage_range[0]),/remove_all)
    symax = strcompress(string(info.rowsliceS3.yimage_range[1]),/remove_all)
    sregion = "Plot Region: range: " + sxmin + " - " + sxmax + " yrange: " + $
              symin + "  - " + symax 
    type = 5

endif


subt = svalue + ": " + ftitle

rownum_start = fix(rownum)
rownum_end = fix(rownum)
rownum = 1

; widget window parameters
xwidget_size = 850
ywidget_size = 800
xsize_scroll = 800
ysize_scroll = 800

if(rowslice_uwindowsize eq 1) then begin ; user has set window size 
    xsize_scroll =rowslice_xwindowsize
    ysize_scroll = rowslice_ywindowsize
endif


if(info.control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.control.x_scroll_window
if(info.control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.control.y_scroll_window
if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10


RSQuickLook = widget_base(title=stitle ,$
                          col = 1,mbar = menuBar,group_leader = info.SlopeQuickLook,$
                          xsize = xwidget_size,$
                          ysize= ywidget_size,/scroll,$
                          x_scroll_size=xsize_scroll,y_scroll_size=ysize_scroll)

QuitMenu = widget_button(menuBar,value="Quit",font = info.font2)
; add quit button
quitbutton = widget_button(quitmenu,value="Quit",event_pro='msql_rowslice_quit')
PMenu = widget_button(menuBar,value="Print",font = info.font2)
PbuttonR = widget_button(Pmenu,value = "Print Plot to output file",uvalue='printP')
PbuttonD = widget_button(Pmenu,value = "Print Row Slice Data to ascii file ",uvalue='printD')
;********
; build the menubar
;********



titlelabel = widget_label(RSQuickLook, $
                           value=info.control.filename_raw,/align_left, $
                           font=info.font3,/dynamic_resize)





rlabel = widget_label(RSQuicklook, value=sregion, font=info.font3)

graph_master = widget_base(RSQuickLook,row=1)
graphID1 = widget_base(graph_master,col=1)
graphID2 = widget_base(graph_master,col=1)
;_______________________________________________________________________

;*****
;*****
subtitle = widget_label(graphID1, $
                           value=ftitle,/align_left, $
                           font=info.font3,/dynamic_resize)
rowslice_mmlabel        = lonarr(2,2) ; plot label 
rowslice_range          = fltarr(2,2) ; plot range
rowslice_recomputeID    = lonarr(2); button controlling Default scale or User Set Scale
default_scale_rowslice  = intarr(2) ; scaling min and max display ranges 

rowslice_range[*,*] = 0
default_scale_rowslice[*] = 1

tlabelID = widget_label(graphID1,$
                        value =svalue ,/align_center,$
                        font=info.font5)

pix_num_base = widget_base(graphID1,row=1,/align_center)
labelID = widget_button(pix_num_base,uvalue='row_move_x1',value='<',font=info.font3)
labelID = widget_button(pix_num_base,uvalue='row_move_x2',value='>',font=info.font3)


xsize_label = 12    
; button to change 

start_row_label = cw_field(pix_num_base,title='Start Row',xsize=5,$
                                         value=rownum_start,font=info.font4,$
                                         uvalue='row_vals',/return_events,/integer)

num_row_label = cw_field(pix_num_base,title='Number of Rows',xsize=5,$
                                         value=rownum,font=info.font4,$
                                         uvalue='row_valn',/return_events,/integer)

graphID = widget_draw(graphID1,$
                                    xsize = info.plotsize2,$
                                    ysize = info.plotsize2,$
                                    retain=info.retn)


pix_num_base2 = widget_base(graphID1,row=1)
labelID = widget_label(pix_num_base2,value="X->",font=info.font4)
rowslice_mmlabel[0,0] = cw_field(pix_num_base2,title="min:",font=info.font4, $
                                        uvalue="rows_mmx1",/integer,/return_events, $
                                        value=fix(rowslice_range[0,0]), $
                                        xsize=xsize_label,fieldfont=info.font4)

rowslice_mmlabel[0,1] = cw_field(pix_num_base2,title="max:",font=info.font4, $
                                        uvalue="rows_mmx2",/integer,/return_events, $
                                        value=fix(rowslice_range[0,1]),xsize=xsize_label,$
                                        fieldfont=info.font4)

rowslice_recomputeID[0] = widget_button(pix_num_base2,value=' Plot  Range',$
                                               font=info.font4,$
                                               uvalue = 'dr1')

pix_num_base3 = widget_base(graphID1,row=1)

labelID = widget_label(pix_num_base3,value="Y->",font=info.font4)
rowslice_mmlabel[1,0] = cw_field(pix_num_base3,title="min:",font=info.font4, $
                                        uvalue="rows_mmy1",/float,/return_events, $
                                        value=rowslice_range[1,0],xsize=xsize_label,$
                                        fieldfont=info.font4)

rowslice_mmlabel[1,1] = cw_field(pix_num_base3,title="max:",font=info.font4, $
                                        uvalue="rows_mmy2",/float,/return_events, $
                                        value=rowslice_range[1,1],xsize=xsize_label,$
                                        fieldfont=info.font4)

rowslice_recomputeID[1] = widget_button(pix_num_base3,value=' Plot Range',$
                                               font=info.font4,$
                                               uvalue = 'dr2')



b_label = widget_label(graphID2,value=' ')
s_label = widget_label(graphID2,value="Statisical Information" ,/align_left,/sunken_frame,font=info.font5)
s_label = widget_label(graphID2,value="Reference Pixels Not Included" ,/align_left)



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
showline_row = 0
showline_row_label = widget_button(graphID2,value='Plot No Line (on image)',font=info.font3,$
                                     uvalue = 'slc')

showline_row = 0
pix_num_base4 = widget_base(RSQuickLook,row=1,/align_center)
showline_row_label = widget_button(pix_num_base4,value=' No Line ',font=info.font3,$
                                     uvalue = 'slc')



;Set up the GUI
longline = '                                                                                                                        '
longtag = widget_label(RSQuickLook,value = longline)
Widget_control,RSQuickLook,/Realize
if(graphnum eq 1) then $
XManager,'msqlrs1',RSQuickLook,/No_Block,$
        event_handler='msql_rowslice_event'
if(graphnum eq 2) then $
XManager,'msqlrs2',RSQuickLook,/No_Block,$
        event_handler='msql_rowslice_event'

if(graphnum eq 3) then $
XManager,'msqlrs3',RSQuickLook,/No_Block,$
        event_handler='msql_rowslice_event'


widget_control,graphID,get_value=tdraw_id
draw_window_id = tdraw_id


Widget_Control,info.QuickLook,Set_UValue=info
cinfo = {rownum_start           : rownum_start,$
         rownum_end             : rownum_end,$
         rownum                 : rownum,$
         maxsize                : maxsize,$
         slabelID               : slabelID,$
         sname                  : sname,$
         start_row_label        : start_row_label,$
         num_row_label          : num_row_label,$
         showline_row           : showline_row,$
         showline_row_label     : showline_row_label,$
         rowslice_recomputeID   : rowslice_recomputeID,$
         rowslice_mmlabel       : rowslice_mmlabel,$
         rowslice_range         : rowslice_range,$
         graphID                : graphID,$
         draw_window_id         : draw_window_id,$
         default_scale_rowslice : default_scale_rowslice,$
         outname                : outname,$
         graphnum               : graphnum,$
         subt                   : subt,$
         otype                  : 0,$
         type                   : type,$
         info                   : info}


if(graphnum eq 1) then begin
    info.RS1_SlopeQuickLook = RSQuickLook
    Widget_Control,info.RS1_SlopeQuickLook,Set_UValue=cinfo
    Widget_Control,info.QuickLook,Set_UValue=info
    msql_update_rowslice,cinfo
    Widget_Control,info.RS1_SlopeQuickLook,Set_UValue=cinfo
endif

if(graphnum eq 2) then begin
    info.RS2_SlopeQuickLook = RSQuickLook
    Widget_Control,info.RS2_SlopeQuickLook,Set_UValue=cinfo
    Widget_Control,info.QuickLook,Set_UValue=info
    msql_update_rowslice,cinfo
    Widget_Control,info.RS2_SlopeQuickLook,Set_UValue=cinfo
endif

if(graphnum eq 3) then begin
    info.RS3_SlopeQuickLook = RSQuickLook
    Widget_Control,info.RS3_SlopeQuickLook,Set_UValue=cinfo
    Widget_Control,info.QuickLook,Set_UValue=info
    msql_update_rowslice,cinfo
    Widget_Control,info.RS3_SlopeQuickLook,Set_UValue=cinfo
endif

Widget_Control,info.QuickLook,Set_UValue=info

end
