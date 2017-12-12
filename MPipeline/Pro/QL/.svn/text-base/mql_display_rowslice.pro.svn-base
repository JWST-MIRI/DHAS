;***********************************************************************
;_______________________________________________________________________
pro mql_rowslice_quit,event
;_______________________________________________________________________
widget_control,event.top, Get_UValue = cinfo	
widget_control,cinfo.info.QuickLook,Get_Uvalue = info
if(cinfo.type eq 0 and XRegistered ('mqlrsr')) then begin
    widget_control,info.RSRawQuickLook,/destroy
endif

if(cinfo.type eq 1 and XRegistered ('mqlrsz')) then begin
    widget_control,info.RSZoomQuickLook,/destroy
endif

if(cinfo.type eq 2 and XRegistered ('mqlrss')) then begin
    widget_control,info.RSSlopeQuickLook,/destroy
endif
end

;***********************************************************************
;_______________________________________________________________________
pro mql_update_rowslice,cinfo,ps=ps,eps=eps,ascii=ascii,unit=iunit
;_______________________________________________________________________
type = cinfo.type


if(cinfo.rownum_start gt cinfo.rownum_end) then  begin
    cinfo.rownum_start = cinfo.rownum_end
    result = dialog_message(" Your starting and ending values are in the wrong order ",/error )
    widget_control,cinfo.start_row_label,set_value=cinfo.rownum_start

endif

y1 = cinfo.rownum_start-1
y2 = cinfo.rownum_end -1

width = cinfo.rownum_end - cinfo.rownum_start

srow = ' Row range: ' + strcompress(string(fix(y1)),/remove_all) + ' - ' + $
       strcompress(string(fix(y2)),/remove_all) 

if(type eq 0) then begin
    rowdataW = (*cinfo.info.rowsliceR.pdata)[*,y1:y2]
endif
if(type eq 1) then begin
    ydiff = y2 - y1
    y1 =  cinfo.rownum_start - cinfo.info.image.y_zoom_start
    y2 = y1 + ydiff
    y1 = y1 -1
    y2 = y2 -1
    rowdataW = (*cinfo.info.rowsliceZ.pdata)[*,y1:y2]
endif
if(type eq 2) then begin
    rowdataW = (*cinfo.info.rowsliceS.pdata)[*,y1:y2]
endif


s = size(rowdataW)
num = s[1]
width = y2 - y1 + 1

rowdataALL = fltarr(num)

for i = 0,num -1 do begin
    indx = where(finite( rowdataW(i,*)),num)
    rowdataALL[i] = total(rowdataW[i,*])/width
endfor

rowdata = rowdataALL
rowdataALL = 0

stitle = ' '
sstitle = ' ' 
if ((not keyword_set(ps)) AND (not keyword_set(eps))) then begin
    wset,cinfo.draw_window_id  
endif else begin 
    stitle = cinfo.subt + srow
    if(type eq 0 or type eq 2) then sstitle = cinfo.info.control.filename_raw
    if(type eq 3 ) then sstitle = cinfo.info.control.filename_slope
endelse


n_reads = n_elements(rowdata)

xvalues = indgen(n_reads) + 1
pad = 0.002
xmin = min(xvalues)
xmax = max(xvalues)

 
xpad = fix(n_reads*pad)
if(xpad le 0 ) then xpad = 1

rowdata_noref = rowdata
if(cinfo.info.data.subarray eq 0) then begin
    if( type eq 0 or type eq 2 ) then begin
        rowdata_noref = rowdata[4:1027]
    endif
    if(type eq 1) then begin
        rowdata_noref  = (*cinfo.info.rowsliceZ.psubdata_noref)[*,y1:y2]
    endif
endif

; get stats
get_image_stat,rowdata_noref,mean_row,std,min_row,max_row,$
               min_image,max_image,median_row,stdev_mean,skew,ngood,nbad



rowdata_noref = 0
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
xx1 = cinfo.rowslice_range[0,0]
xx2 = cinfo.rowslice_range[0,1]
yy1 = cinfo.rowslice_range[1,0]
yy2 = cinfo.rowslice_range[1,1]


yt = 'DN'
plot_slope = 0
if(type eq 2) then plot_slope= 1
if(type eq 1 and cinfo.info.image.zoom_window eq 3) then plot_slope = 1
 
if(plot_slope eq 1 ) then begin 
	yt = 'DN/s'
   if(cinfo.connect_pts eq 1) then begin
       plot,xvalues,rowdata,xtitle = "Column #", ytitle=yt,$
            xrange=[xx1,xx2],yrange=[yy1,yy2],xstyle =1,ystyle=1,title = stitle,subtitle = sstitle,$
            linestyle = 1,ytickformat = '(f8.3)'
   endif else begin
       
       plot,xvalues,rowdata,xtitle = "Column #", ytitle=yt,$
            xrange=[xx1,xx2],yrange=[yy1,yy2],xstyle =1,ystyle=1,title = stitle,subtitle = sstitle,$
            ytickformat = '(f8.3)',/nodata
   endelse
endif else begin
   if(cinfo.connect_pts eq 1) then begin
       plot,xvalues,rowdata,xtitle = "Column #", ytitle=yt,$
            xrange=[xx1,xx2],yrange=[yy1,yy2],xstyle =1,ystyle=1,title = stitle,subtitle = sstitle,$
            linestyle = 1,ytickformat = '(f7.0)'
   endif else begin 
       plot,xvalues,rowdata,xtitle = "Column #", ytitle=yt,$
            xrange=[xx1,xx2],yrange=[yy1,yy2],xstyle =1,ystyle=1,title = stitle,subtitle = sstitle,$
            ytickformat = '(f7.0)',/nodata
   endelse
endelse
	
oplot,xvalues,rowdata,psym = 1, symsize = 0.8


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



if(type eq 0 and cinfo.info.data.subarray eq 0) then begin 
    widget_control,cinfo.rlabelID[0],set_value=cinfo.rname[0]+ strtrim(string(rowdata[0],format="(g14.6)"),2) 
    widget_control,cinfo.rlabelID[1],set_value=cinfo.rname[1]+ strtrim(string(rowdata[1],format="(g14.6)"),2) 
    widget_control,cinfo.rlabelID[2],set_value=cinfo.rname[2]+ strtrim(string(rowdata[2],format="(g14.6)"),2) 
    widget_control,cinfo.rlabelID[3],set_value=cinfo.rname[3]+ strtrim(string(rowdata[3],format="(g14.6)"),2) 
    widget_control,cinfo.rlabelID[4],set_value=cinfo.rname[4]+ strtrim(string(rowdata[1028],format="(g14.6)"),2) 
    widget_control,cinfo.rlabelID[5],set_value=cinfo.rname[5]+ strtrim(string(rowdata[1029],format="(g14.6)"),2) 
    widget_control,cinfo.rlabelID[6],set_value=cinfo.rname[6]+ strtrim(string(rowdata[1030],format="(g14.6)"),2) 
    widget_control,cinfo.rlabelID[7],set_value=cinfo.rname[7]+ strtrim(string(rowdata[1031],format="(g14.6)"),2) 
endif

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
rowdata = 0
end


;_______________________________________________________________________
;************************************************************************
pro mql_setup_rowslice, type, info
;_______________________________________________________________________

i = info.image.integrationNO
ii = info.image.integrationNO
j = info.image.rampNO
if(info.data.read_all eq 0) then begin
    i = 0
    if(info.data.num_frames ne info.data.nramps) then begin 
        j = info.image.rampNO- info.control.frame_start
    endif
endif

if(type eq 0) then begin ; Raw type data 
    info.rowsliceR.xsize = info.data.image_xsize 
    info.rowsliceR.ysize = info.data.image_ysize

    info.rowsliceR.ximage_range[0]  = 1
    info.rowsliceR.ximage_range[1]  = info.data.image_xsize
    info.rowsliceR.yimage_range[0]  = 1
    info.rowsliceR.yimage_range[1]  = info.data.image_ysize

    info.rowsliceR.iramp = info.image.rampNO
    info.rowsliceR.jintegration = info.image.integrationNO

    info.rowsliceR.mean = info.image.stat[0]
    info.rowsliceR.median = info.image.stat[4]
    
    frame_image = fltarr(info.data.image_xsize,info.data.image_ysize)
    frame_image[*,*] = (*info.data.pimagedata)[i,j,*,*]

    if ptr_valid (info.rowsliceR.pdata) then ptr_free,info.rowsliceR.pdata
    info.rowsliceR.pdata = ptr_new(frame_image)
    frame_image = 0
endif



if(type eq 1) then begin ; Zoom

    frame_image = (*info.image.pzoomdata)

    s = size(frame_image)
    xsize = s[1]
    ysize = s[2]

    info.rowsliceZ.ximage_range[0]  = info.image.x_zoom_start+1
    info.rowsliceZ.ximage_range[1]  = info.image.x_zoom_end+1
    info.rowsliceZ.yimage_range[0]  = info.image.y_zoom_start+1
    info.rowsliceZ.yimage_range[1]  = info.image.y_zoom_end+1

    info.rowsliceZ.xsize = xsize
    info.rowsliceZ.ysize = ysize

    info.rowsliceZ.iramp = info.image.rampNO
    info.rowsliceZ.jintegration = info.image.integrationNO

    info.rowsliceZ.mean = info.image.zoom_stat[0]
    info.rowsliceZ.median = info.image.zoom_stat[4]
    

    if ptr_valid (info.rowsliceZ.pdata) then ptr_free,info.rowsliceZ.pdata
    info.rowsliceZ.pdata = ptr_new(frame_image)
    frame_image = 0

    x1 = info.image.x_zoom_start_noref
    x2 = info.image.x_zoom_end_noref

    
    y1 = info.image.y_zoom_start
    y2 = info.image.y_zoom_end
    frame_image = fltarr(x2-x1+1,y2-y1+1)
    frame_image[*,*] = (*info.data.pimagedata)[i,j,x1:x2,y1:y2]
    if(info.image.zoom_window eq 3) then     frame_image[*,*] = (*info.data.preduced)[x1:x2,y1:y2,0]

    if ptr_valid (info.rowsliceZ.psubdata_noref) then ptr_free,info.rowsliceZ.psubdata_noref
    info.rowsliceZ.psubdata_noref = ptr_new(frame_image)

    frame_image2 = 0

endif


if(type eq 2) then begin ; Slope  data
    info.rowsliceS.xsize = info.data.slope_xsize 
    info.rowsliceS.ysize = info.data.slope_ysize
    info.rowsliceS.ximage_range[0]  = 1
    info.rowsliceS.ximage_range[1]  = info.data.slope_xsize
    info.rowsliceS.yimage_range[0]  = 1
    info.rowsliceS.yimage_range[1]  = info.data.slope_ysize

    info.rowsliceS.iramp = info.image.rampNO
    info.rowsliceS.jintegration = info.image.integrationNO

    info.rowsliceS.mean = info.data.slope_stat[0,0]
    info.rowsliceS.median = info.data.slope_stat[1,0]
    
    frame_image = fltarr(info.data.slope_xsize,info.data.slope_ysize)
    frame_image[*,*] = (*info.data.preduced)[*,*,0]
    if ptr_valid (info.rowsliceS.pdata) then ptr_free,info.rowsliceS.pdata
    info.rowsliceS.pdata = ptr_new(frame_image)
    frame_image = 0
endif


end


;***********************************************************************
;_______________________________________________________________________
; the event manager for the ql.pro (main base widget)
pro mql_rowslice_event,event
;_______________________________________________________________________

Widget_Control,event.id,Get_uValue=event_name
widget_control,event.top, Get_UValue = cinfo
widget_control,cinfo.info.Quicklook,get_uvalue = info

type = cinfo.type

if (widget_info(event.id,/TLB_SIZE_EVENTS) eq 1 ) then begin

    if(type eq 0) then begin
        info.rowsliceR.xwindowsize = event.x
        info.rowsliceR.ywindowsize = event.y
        info.rowsliceR.uwindowsize  = 1
    endif

    if(type eq 1) then begin
        info.rowsliceZ.xwindowsize = event.x
        info.rowsliceZ.ywindowsize = event.y
        info.rowsliceZ.uwindowsize  = 1
    endif

    if(type eq 1) then begin
        info.rowsliceS.xwindowsize = event.x
        info.rowsliceS.ywindowsize = event.y
        info.rowsliceS.uwindowsize  = 1
    endif
    widget_control,event.top,set_uvalue = cinfo
    widget_control,cinfo.info.Quicklook,set_uvalue = info
    mql_display_rowslice,type,info
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
        widget_control,cinfo.rowslice_mmlabel[0,0],get_value = temp
        test = abs(temp - cinfo.rowslice_range[0,0])
        if(test gt 1) then cinfo.default_scale_rowslice[0] = 0
        cinfo.rowslice_range[0,0] = temp

        widget_control,cinfo.rowslice_mmlabel[0,1],get_value = temp
        test = abs(temp - cinfo.rowslice_range[0,1])
        if(test gt 1) then cinfo.default_scale_rowslice[0] = 0
        cinfo.rowslice_range[0,1] = temp

        widget_control,cinfo.rowslice_mmlabel[1,0],get_value = temp
        test = abs(temp - cinfo.rowslice_range[1,0])
        if(test gt 1) then cinfo.default_scale_rowslice[1] = 0
        cinfo.rowslice_range[1,0] = temp

        widget_control,cinfo.rowslice_mmlabel[1,1],get_value = temp
        test = abs(temp - cinfo.rowslice_range[1,1])
        if(test gt 1) then  cinfo.default_scale_rowslice[1] = 0
        cinfo.rowslice_range[1,1] = temp


        if(cinfo.default_scale_rowslice[0] ne 1) then $
          widget_control,cinfo.rowslice_recomputeID[0],set_value='Default Range'

        if(cinfo.default_scale_rowslice[1] ne 1) then $
          widget_control,cinfo.rowslice_recomputeID[1],set_value='Default Range'
        mql_update_rowslice,cinfo
        Widget_Control,event.top,Set_UValue=cinfo
    end
    
;_______________________________________________________________________
; set the Default range or user defined range for  rowslicegram plot
    (strmid(event_name,0,2) EQ 'dr') : begin
        graphno = fix(strmid(event_name,2,1))
        if(cinfo.default_scale_rowslice[graphno-1] eq 1 ) then begin ; true - turn to false
            widget_control,cinfo.rowslice_recomputeID[graphno-1],set_value='Default Range'
            cinfo.default_scale_rowslice[graphno-1] = 0
        endif else begin        ;false then turn true
            widget_control,cinfo.rowslice_recomputeID[graphno-1],set_value=' Plot Range'
            cinfo.default_scale_rowslice[graphno-1] = 1
        endelse

        mql_update_rowslice,cinfo
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

        plot_row1 = float(cinfo.rownum_start)/float(info.image.binfactor)
        plot_row2 = float(cinfo.rownum_end)/float(info.image.binfactor)


         mql_draw_slice,type,1,cinfo.showline_row,plot_row1,plot_row2,info

        Widget_Control,event.top,Set_UValue=cinfo
    end

;_______________________________________________________________________
; connect pints
;_______________________________________________________________________
    (strmid(event_name,0,2) EQ 'cp') : begin
        if(cinfo.connect_pts eq 1  ) then begin ; true - turn to false
            widget_control,cinfo.connect_pts_label,set_value='Do not Connect Pts'
            cinfo.connect_pts = 0
        endif else begin        ;false then turn true
            widget_control,cinfo.connect_pts_label,set_value='Connect Pts'
            cinfo.connect_pts = 1
        endelse
        mql_update_rowslice,cinfo
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
            if(value le 0) then begin
    		result = dialog_message("Enter a value equal to or greater than 1",/error )
                cinfo.rownum = 1
            endif
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

        mql_update_rowslice,cinfo

        if(cinfo.showline_row eq 1) then begin
            plot_row1 = float(cinfo.rownum_start)/float(info.image.binfactor)
            plot_row2 = float(cinfo.rownum_end)/float(info.image.binfactor)

            mql_draw_slice,type,1,cinfo.showline_row,plot_row1,plot_row2,info
        endif
        Widget_Control,event.top,Set_UValue=cinfo
        Widget_Control,cinfo.info.QuickLook,Set_UValue=info
        ;print,'values',cinfo.rownum_start,cinfo.rownum_end, cinfo.rownum
    end
else: print," Event name not found",event_name
endcase
end
;***********************************************************************
;***********************************************************************
pro mql_display_rowslice,type,info


window,1,/pixmap
wdelete,1
maxsize = 0
rownum = 50
if(type eq 0) then begin
    rowslice_uwindowsize = info.rowsliceR.uwindowsize
    rowslice_xwindowsize = info.rowsliceR.xwindowsize
    rowslice_ywindowsize = info.rowsliceR.ywindowsize

    stitle = "MIRI Quick Look- Row Slice of Science Frame Image" + info.version
    svalue = " Row Slice of Science Frame Values"
    iframe = fix(info.rowsliceR.iramp+1)
    jintegration = fix(info.rowsliceR.jintegration+1)
    ftitle = "Integration #: " + strtrim(string(jintegration),2) +    "  Frame #: " + $
         strtrim(string(iframe),2)
    maxsize = info.rowsliceR.xsize
    if( XRegistered ('mqlrsr')) then begin
        widget_control,info.RSRawQuickLook,/destroy
    endif
    rownum = (info.rowsliceR.ysize)/2
    rownum = info.image.y_pos * info.image.binfactor


    ij = 'int' + string(jintegration) + '_frame' + string(iframe)  
    ij = strcompress(ij,/remove_all)
    outname = info.output.rowsliceraw + '_' + ij

    outname ='_' + ij +  info.output.rowsliceraw + '_' 

    sxmin = strcompress(string(info.rowsliceR.ximage_range[0]),/remove_all)
    sxmax = strcompress(string(info.rowsliceR.ximage_range[1]),/remove_all)
    symin = strcompress(string(info.rowsliceR.yimage_range[0]),/remove_all)
    symax = strcompress(string(info.rowsliceR.yimage_range[1]),/remove_all)
    sregion = " Available Pixel Region to Plot: range: " + sxmin + " - " + sxmax + " yrange: " + $
              symin + "  - " + symax 

endif


if(type eq 1) then begin
    rowslice_uwindowsize = info.rowsliceZ.uwindowsize
    rowslice_xwindowsize = info.rowsliceZ.xwindowsize
    rowslice_ywindowsize = info.rowsliceZ.ywindowsize
    stitle = "MIRI Quick Look- Row Slice of Zoom Image" + info.version
    svalue = " Row Slice of Zoom Values"
    iframe = fix(info.rowsliceZ.iramp+1)
    jintegration = fix(info.rowsliceZ.jintegration+1)
    ftitle = "Integration #: " + strtrim(string(jintegration),2) +    "  Frame #: " + $
         strtrim(string(iframe),2)
    maxsize = info.rowsliceZ.xsize + info.image.x_zoom_start

    if( XRegistered ('mqlrsz')) then begin
        widget_control,info.RSZoomQuickLook,/destroy
    endif
    rownum = (info.rowsliceZ.ysize)/2
    rownum = info.image.y_pos * info.image.binfactor


    ij = 'int' + string(jintegration) + '_frame' + string(iframe)  
    ij = strcompress(ij,/remove_all)
    outname = '_' + ij  + info.output.rowslicezoom + '_' 

    sxmin = strcompress(string(info.rowsliceZ.ximage_range[0]),/remove_all)
    sxmax = strcompress(string(info.rowsliceZ.ximage_range[1]),/remove_all)
    symin = strcompress(string(info.rowsliceZ.yimage_range[0]),/remove_all)
    symax = strcompress(string(info.rowsliceZ.yimage_range[1]),/remove_all)
    sregion = "Available Pixel Region to Plot: range: " + sxmin + " - " + sxmax + " yrange: " + $
              symin + "  - " + symax 

endif


if(type eq 2) then begin
    rowslice_uwindowsize = info.rowsliceS.uwindowsize
    rowslice_xwindowsize = info.rowsliceS.xwindowsize
    rowslice_ywindowsize = info.rowsliceS.ywindowsize
    stitle = "MIRI Quick Look- Row Slice Slope Image" + info.version
    svalue = " Row Slice of Slope Values"
    jintegration = fix(info.rowsliceS.jintegration+1)
    ftitle = "  Integration #: " + strtrim(string(jintegration),2)
    maxsize = info.rowsliceS.xsize
    if(XRegistered ('mqlrss')) then begin
        widget_control,info.RSSlopeQuickLook,/destroy
    endif
    rownum = (info.rowsliceS.ysize)/2
    rownum = info.image.y_pos * info.image.binfactor


    ij = 'int' + string(jintegration) 
    ij = strcompress(ij,/remove_all)

    outname = '_'+ ij  + info.output.rowsliceslope+ '_' 

    sxmin = strcompress(string(info.rowsliceS.ximage_range[0]),/remove_all)
    sxmax = strcompress(string(info.rowsliceS.ximage_range[1]),/remove_all)
    symin = strcompress(string(info.rowsliceS.yimage_range[0]),/remove_all)
    symax = strcompress(string(info.rowsliceS.yimage_range[1]),/remove_all)
    sregion = "Available Pixel Region to Plot: range: " + sxmin + " - " + sxmax + " yrange: " + $
              symin + "  - " + symax 

endif

subt = svalue + ": " + ftitle

rownum_start = rownum+1
rownum_end = rownum+1
rownum = rownum_end - rownum_start + 1 


; widget window parameters
xwidget_size = 850
ywidget_size = 900
xsize_scroll = 800
ysize_scroll = 900

if(rowslice_uwindowsize eq 1) then begin ; user has set window size 
    xsize_scroll =rowslice_xwindowsize
    ysize_scroll = rowslice_ywindowsize
endif


if(info.control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.control.x_scroll_window
if(info.control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.control.y_scroll_window
if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10

RSQuickLook = widget_base(title=stitle ,$
                          col = 1,mbar = menuBar,group_leader = info.RawQuickLook,$
                          xsize =xwidget_size,$
                          ysize= ywidget_size,/scroll,$
                          x_scroll_size=xsize_scroll,y_scroll_size=ysize_scroll,/TLB_SIZE_EVENTS)

QuitMenu = widget_button(menuBar,value="Quit",font = info.font2)
; add quit button
quitbutton = widget_button(quitmenu,value="Quit",event_pro='mql_rowslice_quit')
PMenu = widget_button(menuBar,value="Print",font = info.font2)
PbuttonR = widget_button(Pmenu,value = "Print Row Slice plot to an output file",uvalue='printP')
PbuttonD = widget_button(Pmenu,value = "Print Row Slice Data to ascii file ",uvalue='printD')

;********
; build the menubar
;********

titlelabel = widget_label(RSQuickLook, $
                           value=info.control.filename_raw,/align_left, $
                           font=info.font3,/dynamic_resize)



subtitle = widget_label(RSQuickLook, $
                           value=ftitle,/align_left, $
                           font=info.font3,/dynamic_resize)



tlabelID = widget_label(RSQuickLook,$
                        value =svalue ,/align_center,$
                        font=info.font5)
rlabel = widget_label(RSQuicklook, value=sregion, font=info.font3)
graph_master = widget_base(RSQuickLook,row=1)
graphID1 = widget_base(graph_master,col=1)
graphID2 = widget_base(graph_master,col=1)
;_______________________________________________________________________

;*****

rowslice_mmlabel        = lonarr(2,2) ; plot label 
rowslice_range          = fltarr(2,2) ; plot range
rowslice_recomputeID    = lonarr(2); button controlling Default scale or User Set Scale
default_scale_rowslice  = intarr(2) ; scaling min and max display ranges 

rowslice_range[*,*] = 0
default_scale_rowslice[*] = 1



pix_num_base = widget_base(graphID1,row=1,/align_center)
labelID = widget_button(pix_num_base,uvalue='row_move_x1',value='<',font=info.font3)
labelID = widget_button(pix_num_base,uvalue='row_move_x2',value='>',font=info.font3)


xsize_label = 8    
; button to change 

start_row_label = cw_field(pix_num_base,title='Start Row',xsize=5,$
                                         value=fix(rownum_start),/integer,font=info.font4,$
                                         uvalue='row_vals',/return_events)

num_row_label = cw_field(pix_num_base,title='Number of Rows',xsize=5,$
                                         value=fix(rownum),/integer,font=info.font4,$
                                         uvalue='row_valn',/return_events)

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

rowslice_recomputeID[0] = widget_button(pix_num_base2,value=' Plot Range ',$
                                               font=info.font4,$
                                               uvalue = 'dr1',/dynamic_resize)

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

rowslice_recomputeID[1] = widget_button(pix_num_base3,value=' Plot Range ',$
                                               font=info.font4,$
                                               uvalue = 'dr2',/dynamic_resize)



;_______________________________________________________________________

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
connect_pts = 1
connect_pts_label =  widget_button(graphID2,value=' Connect Points',font=info.font3,$
                                     uvalue = 'cp')

rlabelID = lonarr(8)
rname = ['Left Reference Pixel Ch 1:  ',$
         'Left Reference Pixel Ch 2:  ',$
         'Left Reference Pixel Ch 3:  ',$
         'Left Reference Pixel Ch 4:  ',$
         'Right Reference Pixel Ch 1:  ',$
         'Right Reference Pixel Ch 2:  ',$
         'Right Reference Pixel Ch 3:  ',$
         'Right Reference Pixel Ch 4:  ']

if(type eq 0 and info.data.subarray eq 0) then begin 
    blankID = widget_label(graphID2,value = ' ' )
    refID = widget_label(graphID2,value = ' Reference Pixels For Row',/align_left,/sunken_frame,font=info.font5)
    
    rlabelID[0] = widget_label(graphID2,value=rname[0] +blank10,/align_left)
    rlabelID[1] = widget_label(graphID2,value=rname[1] +blank10,/align_left)
    rlabelID[2] = widget_label(graphID2,value=rname[2] +blank10,/align_left)
    rlabelID[3] = widget_label(graphID2,value=rname[3] +blank10,/align_left)
    rlabelID[4] = widget_label(graphID2,value=rname[4] +blank10,/align_left)
    rlabelID[5] = widget_label(graphID2,value=rname[5] +blank10,/align_left)
    rlabelID[6] = widget_label(graphID2,value=rname[6] +blank10,/align_left)
    rlabelID[7] = widget_label(graphID2,value=rname[7] +blank10,/align_left)
    

endif



;Set up the GUI
longline = '                                                                                                                        '
longtag = widget_label(RSQuickLook,value = longline)
Widget_control,RSQuickLook,/Realize
if(type eq 0) then $
XManager,'mqlrsr',RSQuickLook,/No_Block,$
        event_handler='mql_rowslice_event'
if(type eq 1) then $
XManager,'mqlrsz',RSQuickLook,/No_Block,$
        event_handler='mql_rowslice_event'

if(type eq 2) then $
XManager,'mqlrss',RSQuickLook,/No_Block,$
        event_handler='mql_rowslice_event'


widget_control,graphID,get_value=tdraw_id
draw_window_id = tdraw_id


Widget_Control,info.QuickLook,Set_UValue=info
cinfo = {rownum_start           : rownum_start,$
         rownum_end             : rownum_end,$
         rownum                 : rownum,$
         maxsize                : maxsize,$
         start_row_label        : start_row_label,$
         num_row_label          : num_row_label,$
         slabelID               : slabelID,$
         sname                  : sname,$
         rlabelID               : rlabelID,$
         rname                  : rname,$
         showline_row           : showline_row,$
         showline_row_label     : showline_row_label,$
         connect_pts            : connect_pts,$
         connect_pts_label      : connect_pts_label,$
         rowslice_recomputeID   : rowslice_recomputeID,$
         rowslice_mmlabel       : rowslice_mmlabel,$
         rowslice_range         : rowslice_range,$
         graphID                : graphID,$
         draw_window_id         : draw_window_id,$
         default_scale_rowslice : default_scale_rowslice,$
         outname                : outname,$
         type                   : type,$
         subt                   : subt,$
         otype                  : 0,$
         info                   : info}


Widget_Control,RSQuickLook,Set_UValue=cinfo
mql_update_rowslice,cinfo

if(type eq 0) then begin
    info.RSRawQuickLook = RSQuickLook
    Widget_Control,info.RSRawQuickLook,Set_UValue=cinfo
    Widget_Control,info.QuickLook,Set_UValue=info
    Widget_Control,info.RSRawQuickLook,Set_UValue=cinfo
endif

if(type eq 1) then begin
    info.RSZoomQuickLook = RSQuickLook
    Widget_Control,info.RSZoomQuickLook,Set_UValue=cinfo
    Widget_Control,info.QuickLook,Set_UValue=info
    Widget_Control,info.RSZoomQuickLook,Set_UValue=cinfo
endif

if(type eq 2) then begin
    info.RSSlopeQuickLook = RSQuickLook
    Widget_Control,info.RSSlopeQuickLook,Set_UValue=cinfo
    Widget_Control,info.QuickLook,Set_UValue=info
    Widget_Control,info.RSSlopeQuickLook,Set_UValue=cinfo
endif

Widget_Control,info.QuickLook,Set_UValue=info

end
