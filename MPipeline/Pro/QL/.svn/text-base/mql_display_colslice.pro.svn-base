;***********************************************************************
;_______________________________________________________________________
pro mql_colslice_quit,event
;_______________________________________________________________________

widget_control,event.top, Get_UValue = cinfo	
widget_control,cinfo.info.QuickLook,Get_Uvalue = info


if(cinfo.type eq 0 and XRegistered ('mqlcsr')) then begin
    widget_control,info.CSRawQuickLook,/destroy
endif

if(cinfo.type eq 1 and XRegistered ('mqlcsz')) then begin
    widget_control,info.CSZoomQuickLook,/destroy
endif

if(cinfo.type eq 2 and XRegistered ('mqlcss')) then begin
    widget_control,info.CSSlopeQuickLook,/destroy
endif

end
;***********************************************************************
;_______________________________________________________________________
pro mql_setup_colslice, type, info
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

if(type eq 0) then begin        ; Raw type data 
    info.colsliceR.xsize = info.data.image_xsize 
    info.colsliceR.ysize = info.data.image_ysize

    info.colsliceR.ximage_range[0]  = 1
    info.colsliceR.ximage_range[1]  = info.data.image_xsize
    info.colsliceR.yimage_range[0]  = 1
    info.colsliceR.yimage_range[1]  = info.data.image_ysize

    info.colsliceR.iramp = info.image.rampNO
    info.colsliceR.jintegration = info.image.integrationNO

    info.colsliceR.mean = info.image.stat[0]
    info.colsliceR.median = info.image.stat[4]
    
    frame_image = fltarr(info.data.image_xsize,info.data.image_ysize)
    frame_image[*,*] = (*info.data.pimagedata)[i,j,*,*]


    if(info.image.apply_bad) then begin
        index = where( (*info.badpixel.pmask) and 0,numbad)
        if(numbad gt 0) then frame_image[index] = !values.F_NaN
    endif


    if ptr_valid (info.colsliceR.pdata) then ptr_free,info.colsliceR.pdata
    info.colsliceR.pdata = ptr_new(frame_image)
    frame_image = 0
endif

if(type eq 1) then begin ; Zoom
    frame_image = (*info.image.pzoomdata)
    s = size(frame_image)
    xsize = s[1]
    ysize = s[2]

    info.colsliceZ.ximage_range[0]  = info.image.x_zoom_start+1
    info.colsliceZ.ximage_range[1]  = info.image.x_zoom_end+1
    info.colsliceZ.yimage_range[0]  = info.image.y_zoom_start+1
    info.colsliceZ.yimage_range[1]  = info.image.y_zoom_end+1

    info.colsliceZ.xsize = xsize
    info.colsliceZ.ysize = ysize


    info.colsliceZ.iramp = info.image.rampNO
    info.colsliceZ.jintegration = info.image.integrationNO

    info.colsliceZ.mean = info.image.zoom_stat[0]
    info.colsliceZ.median = info.image.zoom_stat[4]
    
    if ptr_valid (info.colsliceZ.pdata) then ptr_free,info.colsliceZ.pdata
    info.colsliceZ.pdata = ptr_new(frame_image)
    frame_image = 0
endif


if(type eq 2) then begin ; Slope  data
    info.colsliceS.xsize = info.data.slope_xsize 
    info.colsliceS.ysize = info.data.slope_ysize
    info.colsliceS.ximage_range[0]  = 1
    info.colsliceS.ximage_range[1]  = info.data.slope_xsize
    info.colsliceS.yimage_range[0]  = 1
    info.colsliceS.yimage_range[1]  = info.data.slope_ysize


    info.colsliceS.iramp = info.image.rampNO
    info.colsliceS.jintegration = info.image.integrationNO

    info.colsliceS.mean = info.data.slope_stat[0,0]
    info.colsliceS.median = info.data.slope_stat[1,0]
    
    frame_image = fltarr(info.data.slope_xsize,info.data.slope_ysize)
    frame_image[*,*] = (*info.data.preduced)[*,*,0]
    if ptr_valid (info.colsliceS.pdata) then ptr_free,info.colsliceS.pdata
    info.colsliceS.pdata = ptr_new(frame_image)
    frame_image = 0
endif
end


;***********************************************************************
;_______________________________________________________________________
pro mql_update_colslice,cinfo,ps=ps,eps=eps,ascii=ascii,unit=iunit
;_______________________________________________________________________
save_color = cinfo.info.col_table
color6

type = cinfo.type
if(cinfo.colnum_start gt cinfo.colnum_end) then  begin
    result = dialog_message(" Your starting and ending values are in the wrong order ",/error )
    cinfo.colnum_start = cinfo.colnum_end
    widget_control,cinfo.start_col_label,set_value=cinfo.colnum_start
endif

x1 = cinfo.colnum_start-1
x2 = cinfo.colnum_end-1


scol = ' Column range: ' + strcompress(string(fix(x1)),/remove_all) + ' - ' + $
       strcompress(string(fix(x2)),/remove_all) 

if(type eq 0) then begin
    coldataW = (*cinfo.info.colsliceR.pdata)[x1:x2,*]
endif

if(type eq 1) then begin
    xdiff = x2 - x1
    x1 =  cinfo.colnum_start -cinfo.info.image.x_zoom_start
    x2 = x1 + xdiff
    x1 = x1 -1
    x2 = x2 -1
    coldataW = (*cinfo.info.colsliceZ.pdata)[x1:x2,*]
endif
if(type eq 2) then begin
    coldataW = (*cinfo.info.colsliceS.pdata)[x1:x2,*]
endif




s = size(coldataW)
num = s[2]
width = x2 - x1 + 1

coldataALL = fltarr(num)

for i = 0,num -1 do begin
    coldataALL[i] = total(coldataW[*,i])/width
endfor

coldata = coldataALL
coldataALL = 0

stitle = ' '
sstitle = ' ' 
if ((not keyword_set(ps)) AND (not keyword_set(eps))) then begin
wset,cinfo.draw_window_id  
endif else begin 
    stitle = cinfo.subt + scol
    if(type lt 2) then sstitle = cinfo.info.control.filename_raw
    if(type eq 2 ) then sstitle = cinfo.info.control.filename_slope
endelse



n_reads = n_elements(coldata)
xvalues = indgen(n_reads) + 1
pad = 0.002
xmin = min(xvalues)
xmax = max(xvalues)
 

xpad = fix(n_reads*pad)
if(xpad le 0 ) then xpad = 1
; get min and max for the display
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
xx1 = cinfo.colslice_range[0,0]
xx2 = cinfo.colslice_range[0,1]
yy1 = cinfo.colslice_range[1,0]
yy2 = cinfo.colslice_range[1,1]


yt = 'DN'
plot_slope = 0
if(type eq 2) then plot_slope= 1
if(type eq 1 and cinfo.info.image.zoom_window eq 3) then plot_slope = 1

if(plot_slope eq 1 ) then begin 
	yt = 'DN/s'
   if(cinfo.connect_pts eq 1) then begin
       plot,xvalues,coldata,xtitle = "ROW  #", ytitle=yt,$
            xrange=[xx1,xx2],yrange=[yy1,yy2],xstyle =1,ystyle=1,title = stitle,subtitle = sstitle,$
            linestyle = 1,ytickformat = '(f8.3)'
   endif else begin
       plot,xvalues,coldata,xtitle = "ROW  #", ytitle=yt,$
            xrange=[xx1,xx2],yrange=[yy1,yy2],xstyle =1,ystyle=1,title = stitle,subtitle = sstitle,$
            ytickformat = '(f8.3)',/nodata
   endelse

endif else begin 
   if(cinfo.connect_pts eq 1) then begin
       plot,xvalues,coldata,xtitle = "ROW  #", ytitle=yt,$
            xrange=[xx1,xx2],yrange=[yy1,yy2],xstyle =1,ystyle=1,title = stitle,subtitle = sstitle,$
            linestyle = 1,ytickformat = '(f7.0)'
   endif else begin
       plot,xvalues,coldata,xtitle = "ROW  #", ytitle=yt,$
            xrange=[xx1,xx2],yrange=[yy1,yy2],xstyle =1,ystyle=1,title = stitle,subtitle = sstitle,$
            ytickformat = '(f7.0)',/nodata
   endelse
       
endelse

oplot,xvalues,coldata,psym = 1,symsize = 0.8

nn = n_elements(xvalues)
for ir = 0,nn -1 do begin
    sign = ir mod 2
    xpt = xvalues[ir]
    ypt = coldata[ir]
    xplot = fltarr(1) & yplot = fltarr(1)
    xplot[0] = xpt
    yplot[0] = ypt
    if(sign eq 0) then begin
        oplot,xplot,yplot,color = 2,psym = 1
    endif else begin 
        oplot,xplot,yplot,color = 5, psym = 1
    endelse
endfor



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

cinfo.info.col_table = save_color
end

;***********************************************************************



;_______________________________________________________________________
;***********************************************************************

; the event manager for the ql.pro (main base widget)
pro mql_colslice_event,event

Widget_Control,event.id,Get_uValue=event_name
widget_control,event.top, Get_UValue = cinfo
widget_control,cinfo.info.Quicklook,get_uvalue = info

type = cinfo.type

if (widget_info(event.id,/TLB_SIZE_EVENTS) eq 1 ) then begin

    if(type eq 0) then begin
        info.colsliceR.xwindowsize = event.x
        info.colsliceR.ywindowsize = event.y
        info.colsliceR.uwindowsize  = 1
    endif

    if(type eq 1) then begin
        info.colsliceZ.xwindowsize = event.x
        info.colsliceZ.ywindowsize = event.y
        info.colsliceZ.uwindowsize  = 1
    endif

    if(type eq 1) then begin
        info.colsliceS.xwindowsize = event.x
        info.colsliceS.ywindowsize = event.y
        info.colsliceS.uwindowsize  = 1
    endif
    widget_control,event.top,set_uvalue = cinfo
    widget_control,cinfo.info.Quicklook,set_uvalue = info
    mql_display_colslice,type,info
    return
endif


case 1 of
    (strmid(event_name,0,6) EQ 'printP') : begin
        print_cslice,cinfo
    end    
    (strmid(event_name,0,6) EQ 'printD') : begin
        print_cslice_data,cinfo
        
    end    
;_______________________________________________________________________
; change x and y range of colslice graph 
;_______________________________________________________________________
    (strmid(event_name,0,7) EQ 'cols_mm') : begin


        widget_control,cinfo.colslice_mmlabel[0,0],get_value = temp
        test = abs(temp - cinfo.colslice_range[0,0])
        if(test gt 1) then cinfo.default_scale_colslice[0] = 0
        cinfo.colslice_range[0,0] = temp

        widget_control,cinfo.colslice_mmlabel[0,1],get_value = temp
        test = abs(temp - cinfo.colslice_range[0,1])
        if(test gt 1) then cinfo.default_scale_colslice[0] = 0
        cinfo.colslice_range[0,1] = temp

        widget_control,cinfo.colslice_mmlabel[1,0],get_value = temp
        test = abs(temp - cinfo.colslice_range[1,0])
        ;if(test gt 1) then 
        cinfo.default_scale_colslice[1] = 0
        cinfo.colslice_range[1,0] = temp

        widget_control,cinfo.colslice_mmlabel[1,1],get_value = temp
        test = abs(temp - cinfo.colslice_range[1,1])
        ;if(test gt 1) then  
        cinfo.default_scale_colslice[1] = 0
        cinfo.colslice_range[1,1] = temp



        if(cinfo.default_scale_colslice[0] ne 1) then $
          widget_control,cinfo.colslice_recomputeID[0],set_value='Default Range'

        if(cinfo.default_scale_colslice[1] ne 1) then $
          widget_control,cinfo.colslice_recomputeID[1],set_value='Default Range'
        mql_update_colslice,cinfo
        Widget_Control,event.top,Set_UValue=cinfo

    end
    
;_______________________________________________________________________
; set the Default range or user defined range for  colslicegram plot
    (strmid(event_name,0,2) EQ 'dr') : begin
        graphno = fix(strmid(event_name,2,1))
        if(cinfo.default_scale_colslice[graphno-1] eq 0 ) then begin 
            widget_control,cinfo.colslice_recomputeID[graphno-1],set_value=' Plot Range'
            cinfo.default_scale_colslice[graphno-1] = 1
        endif

        mql_update_colslice,cinfo
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
        plot_col1 = float(cinfo.colnum_start)/float(info.image.binfactor)
        plot_col2 = float(cinfo.colnum_end)/float(info.image.binfactor)

        mql_draw_slice,type,0,cinfo.showline_col,plot_col1,plot_col2,info
        

        Widget_Control,event.top,Set_UValue=cinfo
    end

;_______________________________________________________________________
; connect points
;_______________________________________________________________________
    (strmid(event_name,0,2) EQ 'cp') : begin
        if(cinfo.connect_pts eq 1  ) then begin ; true - turn to false
            widget_control,cinfo.connect_pts_label,set_value='Do not Connect Pts'
            cinfo.connect_pts = 0
        endif else begin        ;false then turn true
            widget_control,cinfo.connect_pts_label,set_value='Connect Pts'
            cinfo.connect_pts = 1
        endelse
        mql_update_colslice,cinfo
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
            if(value le 0) then begin
    		result = dialog_message(" Enter a value equal to or greater than 1",/error )		
                cinfo.colnum = 1
            endif
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


        mql_update_colslice,cinfo

        if(cinfo.showline_col eq 1) then begin
            plot_col1 = float(cinfo.colnum_start)/float(info.image.binfactor)
            plot_col2 = float(cinfo.colnum_end)/float(info.image.binfactor)
            mql_draw_slice,type,0,cinfo.showline_col,plot_col1,plot_col2,info
        endif
        Widget_Control,event.top,Set_UValue=cinfo

        Widget_Control,cinfo.info.QuickLook,Set_UValue=info

    end



else: print," Event name not found",event_name
endcase
end
;***********************************************************************
;***********************************************************************
pro mql_display_colslice,type,info


window,1,/pixmap
wdelete,1
maxsize = 0
colnum = 50
if(type eq 0) then begin

    colslice_uwindowsize = info.colsliceR.uwindowsize
    colslice_xwindowsize = info.colsliceR.xwindowsize
    colslice_ywindowsize = info.colsliceR.ywindowsize
    stitle = "MIRI Quick Look- Column Slice of Science Frame Image" + info.version
    svalue = " Column Slice of Science Frame Values"
    iframe = fix(info.colsliceR.iramp+1)
    jintegration = fix(info.colsliceR.jintegration+1)

    ftitle = "  Integration #: " + strtrim(string(jintegration),2)+$
	 " Frame #: " + strtrim(string(iframe),2)  
    maxsize = info.colsliceR.xsize
    if( XRegistered ('mqlcsr')) then begin
        widget_control,info.CSRawQuickLook,/destroy
    endif
    colnum = (info.colsliceR.xsize)/2
    colnum = info.image.x_pos * info.image.binfactor

    ij = 'int' + string(jintegration) + '_frame' + string(iframe)  
    ij = strcompress(ij,/remove_all)

    outname = '_' + ij + info.output.colsliceraw + '_' 


    sxmin = strcompress(string(info.colsliceR.ximage_range[0]),/remove_all)
    sxmax = strcompress(string(info.colsliceR.ximage_range[1]),/remove_all)
    symin = strcompress(string(info.colsliceR.yimage_range[0]),/remove_all)
    symax = strcompress(string(info.colsliceR.yimage_range[1]),/remove_all)
    sregion = " Available Pixel Region to plot: range: " + sxmin + " - " + sxmax + " yrange: " + $
              symin + "  - " + symax 

endif


if(type eq 1) then begin
    colslice_uwindowsize = info.colsliceZ.uwindowsize
    colslice_xwindowsize = info.colsliceZ.xwindowsize
    colslice_ywindowsize = info.colsliceZ.ywindowsize
    stitle = "MIRI Quick Look- Column Slice of Zoom Image" + info.version
    svalue = " Column Slice of Zoom Values"
    iframe = fix(info.colsliceZ.iramp+1)
    jintegration = fix(info.colsliceZ.jintegration+1)

    ftitle = "  Integration #: " + strtrim(string(jintegration),2)+$
	 " Frame #: " + strtrim(string(iframe),2)  
    maxsize = info.colsliceZ.xsize + info.image.x_zoom_start

    if( XRegistered ('mqlcsz')) then begin
        widget_control,info.CSZoomQuickLook,/destroy
    endif
    colnum = (info.colsliceZ.xsize)/2
    colnum = info.image.x_pos * info.image.binfactor

    ij = 'int' + string(jintegration) + '_frame' + string(iframe)  
    ij = strcompress(ij,/remove_all)

    outname = '_' + ij + info.output.colslicezoom+ '_' 
    sxmin = strcompress(string(info.colsliceZ.ximage_range[0]),/remove_all)
    sxmax = strcompress(string(info.colsliceZ.ximage_range[1]),/remove_all)
    symin = strcompress(string(info.colsliceZ.yimage_range[0]),/remove_all)
    symax = strcompress(string(info.colsliceZ.yimage_range[1]),/remove_all)
    sregion = "Available Pixel Region to Plot: range: " + sxmin + " - " + sxmax + " yrange: " + $
              symin + "  - " + symax 
endif



if(type eq 2) then begin

    colslice_uwindowsize = info.colsliceS.uwindowsize
    colslice_xwindowsize = info.colsliceS.xwindowsize
    colslice_ywindowsize = info.colsliceS.ywindowsize
    stitle = "MIRI Quick Look- Column Slice Slope Image" + info.version
    svalue = " Column Slice of Slope Values"
    jintegration = fix(info.colsliceS.jintegration+1)
    ftitle = "  Integration #: " + strtrim(string(jintegration),2)
    maxsize = info.colsliceS.xsize
    if(XRegistered ('mqlcss')) then begin
        widget_control,info.CSSlopeQuickLook,/destroy
    endif
    colnum = (info.colsliceS.xsize)/2
    colnum = info.image.x_pos * info.image.binfactor


    ij = 'int' + string(jintegration) + '_frame'
        ij = strcompress(ij,/remove_all)
;    outname = info.output.colsliceslope+ '_' + ij
    outname = '_' + ij + info.output.colsliceslope+ '_' 
    sxmin = strcompress(string(info.colsliceS.ximage_range[0]),/remove_all)
    sxmax = strcompress(string(info.colsliceS.ximage_range[1]),/remove_all)
    symin = strcompress(string(info.colsliceS.yimage_range[0]),/remove_all)
    symax = strcompress(string(info.colsliceS.yimage_range[1]),/remove_all)
    sregion = "Available Pixel Region to Plot: range: " + sxmin + " - " + sxmax + " yrange: " + $
              symin + "  - " + symax 
endif

subt = svalue + ": " + ftitle



; widget window parameters
xwidget_size = 800
ywidget_size = 820
xsize_scroll = 720
ysize_scroll = 760

if(colslice_uwindowsize eq 1) then begin ; user has set window size 
    xsize_scroll =colslice_xwindowsize
    ysize_scroll = colslice_ywindowsize
endif

if(info.control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.control.x_scroll_window
if(info.control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.control.y_scroll_window
if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-20
if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-20


CSQuickLook = widget_base(title=stitle ,$
                          col = 1,mbar = menuBar,group_leader = info.RAWQuickLook,$
                          xsize = xwidget_size,$
                          ysize= ywidget_size,/scroll,$
                          x_scroll_size=xsize_scroll,y_scroll_size=ysize_scroll,/TLB_SIZE_EVENTS)



QuitMenu = widget_button(menuBar,value="Quit",font = info.font2)
; add quit button
quitbutton = widget_button(quitmenu,value="Quit",event_pro='mql_colslice_quit')
PMenu = widget_button(menuBar,value="Print",font = info.font2)
PbuttonR = widget_button(Pmenu,value = "Print Column Slice Plot to an output file",uvalue='printP')
PbuttonD = widget_button(Pmenu,value = "Print Column Slice Data to ascii file ",uvalue='printD')

;********
; build the menubar
;********

titlelabel = widget_label(CSQuickLook, $
                           value=info.control.filename_raw,/align_left, $
                           font=info.font3,/dynamic_resize)



subtitle = widget_label(CSQuickLook, $
                           value=ftitle,/align_left, $
                           font=info.font3,/dynamic_resize)


tlabelID = widget_label(CSQuickLook,$
                        value =svalue ,/align_center,$
                        font=info.font5)
graph_master = widget_base(CSQuickLook,row=1)
graphID1 = widget_base(graph_master,col=1)
graphID2 = widget_base(graph_master,col=1)
;_______________________________________________________________________

;*****
;

colslice_mmlabel        = lonarr(2,2) ; plot label 
colslice_range          = fltarr(2,2) ; plot range
colslice_recomputeID    = lonarr(2); button controlling Default scale or User Set Scale
default_scale_colslice  = intarr(2) ; scaling min and max display ranges 

colslice_range[*,*] = 0
default_scale_colslice[*] = 1

rlabel = widget_label(graphID1, value=sregion, font=info.font3)

pix_num_base = widget_base(graphID1,row=1,/align_left)
labelID = widget_button(pix_num_base,uvalue='col_move_x1',value='<',font=info.font3)
labelID = widget_button(pix_num_base,uvalue='col_move_x2',value='>',font=info.font3)


xsize_label = 8    
; button to change 

colnum_start = colnum+1
colnum_end = colnum+1
colnum = 1
start_col_label = cw_field(pix_num_base,title=' Start Column',xsize=5,$
                                         value=fix(colnum_start),/integer,font=info.font4,$
                                         uvalue='col_vals',/return_events)

num_col_label = cw_field(pix_num_base,title=' Number of Columns',xsize=5,$
                                         value=fix(colnum),/integer,font=info.font4,$
                                         uvalue='col_valn',/return_events)


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

colslice_recomputeID[0] = widget_button(pix_num_base2,value=' Plot Range ',$
                                               font=info.font4,$
                                               uvalue = 'dr1',/dynamic_resize)


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

colslice_recomputeID[1] = widget_button(pix_num_base3,value=' Plot Range ',$
                                               font=info.font4,$
                                               uvalue = 'dr2',/dynamic_resize)

;_______________________________________________________________________
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
connect_pts = 1
connect_pts_label =  widget_button(graphID2,value=' Connect Points',font=info.font3,$
                                     uvalue = 'cp')

info_label = widget_label(graphID2,value = "Red points: odd rows",$
                          font=info.font3,/align_left)
info_label = widget_label(graphID2,value = "Yellow points: even rows",$
                          font=info.font3,/align_left)

;Set up the GUI
longline = '                                                                                                                        '
longtag = widget_label(CSQuickLook,value = longline)
Widget_control,CSQuickLook,/Realize
if(type eq 0) then $
XManager,'mqlcsr',CSQuickLook,/No_Block,event_handler='mql_colslice_event'

if(type eq 1) then $
XManager,'mqlcsz',CSQuickLook,/No_Block,event_handler='mql_colslice_event'


if(type eq 2) then $
XManager,'mqlcss',CSQuickLook,/No_Block,event_handler='mql_colslice_event'



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
         connect_pts            : connect_pts,$
         connect_pts_label      : connect_pts_label,$
         showline_col           : showline_col,$
         showline_col_label     : showline_col_label,$
         colslice_recomputeID   : colslice_recomputeID,$
         colslice_mmlabel       : colslice_mmlabel,$
         colslice_range         : colslice_range,$
         graphID                : graphID,$
         draw_window_id         : draw_window_id,$
         default_scale_colslice : default_scale_colslice,$
         outname                : outname,$
         type                   : type,$
         subt                   : subt,$
         otype                  : 0,$
         info                   : info}


Widget_Control,CSQuickLook,Set_UValue=cinfo
mql_update_colslice,cinfo

if(type eq 0) then begin
    info.CSRawQuickLook = CSQuickLook
    Widget_Control,info.CSRawQuickLook,Set_UValue=cinfo
    Widget_Control,info.QuickLook,Set_UValue=info
    Widget_Control,info.CSRawQuickLook,Set_UValue=cinfo
endif

if(type eq 1) then begin
    info.CSZoomQuickLook = CSQuickLook
    Widget_Control,info.CSZoomQuickLook,Set_UValue=cinfo
    Widget_Control,info.QuickLook,Set_UValue=info
    Widget_Control,info.CSZoomQuickLook,Set_UValue=cinfo
endif

if(type eq 2) then begin
    info.CSSlopeQuickLook = CSQuickLook
    Widget_Control,info.CSSlopeQuickLook,Set_UValue=cinfo
    Widget_Control,info.QuickLook,Set_UValue=info
    Widget_Control,info.CSSlopeQuickLook,Set_UValue=cinfo
endif

Widget_Control,info.QuickLook,Set_UValue=info



end
