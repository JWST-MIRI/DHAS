;***********************************************************************
;_______________________________________________________________________
pro msql_histo_quit,event
;_______________________________________________________________________

widget_control,event.top, Get_UValue = hinfo	
widget_control,hinfo.info.QuickLook,Get_Uvalue = info

if(hinfo.graphnum eq 1 and XRegistered ('msqlh1')) then begin
    widget_control,info.Histo1_SlopeQuickLook,/destroy
endif

if(hinfo.graphnum eq 2 and XRegistered ('msqlh2')) then begin
    widget_control,info.Histo2_SlopeQuickLook,/destroy
endif

if(hinfo.graphnum eq 3 and XRegistered ('msqlh3')) then begin
    widget_control,info.Histo3_SlopeQuickLook,/destroy
endif


end


;***********************************************************************
;_______________________________________________________________________
pro msql_setup_hist, graphnum, info
;_______________________________________________________________________
i = info.slope.integrationNO


if(graphnum eq 1) then begin ; Window 1

    info.histoS1.xsize = info.data.slope_xsize 
    info.histoS1.ysize = info.data.slope_ysize

    info.histoS1.ximage_range[0]  = 1
    info.histoS1.ximage_range[1]  = info.data.slope_xsize
    info.histoS1.yimage_range[0]  = 1
    info.histoS1.yimage_range[1]  = info.data.slope_ysize

    info.histoS1.jintegration = info.slope.integrationNO

    frame_image = fltarr(info.data.slope_xsize,info.data.slope_ysize)

    if(info.slope.plane[0] eq info.slope.plane_cal) then begin 
        frame_image[*,*] = (*info.data.pcaldata)[*,*,0]
    endif else begin 
        frame_image[*,*] = (*info.data.pslopedata)[*,*,info.slope.plane[0]]
    endelse
    if ptr_valid (info.histoS1.pdata) then ptr_free,info.histoS1.pdata
    info.histoS1.pdata = ptr_new(frame_image)
    frame_image = 0
    info.histoS1.pixelunits = 0
    if(info.slope.plane[0] ge 2) then info.histoS1.pixelunits = 1
endif

if(graphnum  eq 2) then begin ; Window 2, Zoom Window

    frame_image = (*info.slope.pzoomdata)
    s = size(frame_image)
    xsize = s[1]
    ysize = s[2]

    info.histoS2.ximage_range[0]  = info.slope.x_zoom_start+1
    info.histoS2.ximage_range[1]  = info.slope.x_zoom_end+1
    info.histoS2.yimage_range[0]  = info.slope.y_zoom_start+1
    info.histoS2.yimage_range[1]  = info.slope.y_zoom_end+1

    info.histoS2.xsize = xsize
    info.histoS2.ysize = ysize

    info.histoS2.jintegration = info.slope.integrationNO

    
;    frame_image = fltarr(xsize,ysize)
;    frame_image[*,*] = (*info.slope.pzoomdata)
    if ptr_valid (info.histoS2.pdata) then ptr_free,info.histoS2.pdata
    info.histoS2.pdata = ptr_new(frame_image)
    frame_image = 0
    info.histoS2.pixelunits = 0
    if(info.slope.plane[1] ge 2) then info.histoS2.pixelunits = 1
endif



if(graphnum eq 3) then begin ; Window 3
    
    info.histoS3.xsize = info.data.slope_xsize 
    info.histoS3.ysize = info.data.slope_ysize

    info.histoS3.ximage_range[0]  = 1
    info.histoS3.ximage_range[1]  = info.data.slope_xsize
    info.histoS3.yimage_range[0]  = 1
    info.histoS3.yimage_range[1]  = info.data.slope_ysize

    info.histoS3.jintegration = info.slope.integrationNO

    frame_image = fltarr(info.data.slope_xsize,info.data.slope_ysize)
    if(info.slope.plane[2] eq info.slope.plane_cal) then begin 
        frame_image[*,*] = (*info.data.pcaldata)[*,*,0]
    endif else begin 
        frame_image[*,*] = (*info.data.pslopedata)[*,*,info.slope.plane[2]]
    endelse

    if ptr_valid (info.histoS3.pdata) then ptr_free,info.histoS3.pdata
    info.histoS3.pdata = ptr_new(frame_image)

    frame_image = 0
    info.histoS3.pixelunits = 0
    if(info.slope.plane[2] ge 2) then info.histoS3.pixelunits = 1
endif
end

;***********************************************************************
;_______________________________________________________________________
pro msql_update_histo,hinfo,ps=ps,eps=eps,ascii=ascii,unit=iunit
;_______________________________________________________________________

graphnum = hinfo.graphnum

if(graphnum eq 1) then xt = ' Slope Values'
if(graphnum eq 2) then xt = ' Uncertainty in Slope'
if(graphnum eq 3) then xt = ' Data Quality Flag'
if(graphnum eq 4) then xt = ' Zero Pt of Fit'
if(graphnum eq 5) then xt = ' # of Good Frames'
if(graphnum eq 6) then xt = ' Frame # of 1st Saturated Value'
numbins = hinfo.histo_binnum

xt = 'Pixel Slope Values'
if(graphnum eq 1) then begin
    frame_image = (*hinfo.info.histoS1.pdata)
    if(hinfo.info.histoS1.pixelunits eq 1) then xt = 'X units'
endif
if(graphnum eq 2) then begin
    frame_image = (*hinfo.info.histoS2.pdata)
    if(hinfo.info.histoS2.pixelunits eq 1) then xt = 'X units'
endif
if(graphnum eq 3) then begin
    frame_image = (*hinfo.info.histoS3.pdata)
    if(hinfo.info.histoS3.pixelunits eq 1) then xt = 'X units'
endif

indxs = where(finite(frame_image),n_pixels)
min = min(frame_image[indxs])
max = max(frame_image[indxs])
median = median(frame_image[indxs])
stdev = stddev(frame_image[indxs])

smin = strcompress(string(min),/remove_all)
smax = strcompress(string(max),/remove_all)
smedian = strcompress(string(median),/remove_all)
snum = strcompress(string(n_pixels),/remove_all)

if(hinfo.default_scale_histo[0] eq 0) then begin
    xhistomin = hinfo.histo_range[0,0]
    xhistomax = hinfo.histo_range[0,1]
endif else begin

    xhistomin = median - 3*stdev
    xhistomax = median + 3*stdev
    if(finite(xhistomin) eq 0) then xhistomin = 0 
    if(finite(xhistomax) eq 0) then xhistomax = 1    
endelse


findhistogram_xlimits,frame_image,xnew,h,numbins,bins,xplot_min,xplot_max,xhistomin,xhistomax,status


stitle = ' '
sstitle = ' ' 
if ((not keyword_set(ps)) AND (not keyword_set(eps))) then begin
    wset,hinfo.draw_window_id
endif else begin 
    stitle = hinfo.subt
    sstitle = hinfo.info.control.filename_slope
endelse


xmin = xplot_min
xmax = xplot_max
min_value = min(h)
max_value = max(h)

yt = 'Number of Pixels'

max_value = max_value + .1*max_value
hinfo.histo_range[0,0] = xmin
hinfo.histo_range[0,1] = xmax

  
if(hinfo.default_scale_histo[1] eq 1) then begin
    hinfo.histo_range[1,0] = min_value
    hinfo.histo_range[1,0] = 0
    hinfo.histo_range[1,1] = max_value
endif


x1 = hinfo.histo_range[0,0]
x2 = hinfo.histo_range[0,1]

y1 = hinfo.histo_range[1,0]
y2 = hinfo.histo_range[1,1]

xr = xmax - xmin


if(xr lt 100) then begin 
    plot,xnew,h,psym=10,xtitle= xt,ytitle=yt,$
    yrange = [y1,y2],xrange=[xmin,xmax],$
        ystyle=2,title = stitle,subtitle = sstitle,xstyle = 1,xtickformat='(f9.3)',$
     ytickformat = '(f8.0)'
endif else begin
    plot,xnew,h,psym=10,xtitle= xt,ytitle=yt,$
    yrange = [y1,y2],xrange=[xmin,xmax],$
        ystyle=2,title = stitle,subtitle = sstitle,xstyle = 1,xtickformat='(f8.0)',$
     ytickformat = '(f8.0)'
endelse
	
if(status ne 0) then begin
    print,'All the values were the same for the histogram plot'
    ypt = (y2 + y1)/2.0
    xyouts,xmin,ypt,'  All Values = ' + string(xmin)
endif



widget_control,hinfo.median_labelID,set_value=('Median: ' +smedian) 
widget_control,hinfo.min_labelID,set_value=('Minimum: ' +smin)
widget_control,hinfo.max_labelID,set_value=('Maximum: ' +smax)
widget_control,hinfo.num_labelID,set_value=('# Good Pixels: ' +snum)
widget_control,hinfo.histo_binlabel,set_value=hinfo.histo_binnum
widget_control,hinfo.histo_mmlabel[0,0],set_value=hinfo.histo_range[0,0]
widget_control,hinfo.histo_mmlabel[0,1],set_value=hinfo.histo_range[0,1]
widget_control,hinfo.histo_mmlabel[1,0],set_value=long(hinfo.histo_range[1,0])
widget_control,hinfo.histo_mmlabel[1,1],set_value=long(hinfo.histo_range[1,1])


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
;_______________________________________________________________________
; the event manager for the ql.pro (main base widget)
pro msql_histo_event,event
;_______________________________________________________________________
Widget_Control,event.id,Get_uValue=event_name
widget_control,event.top, Get_UValue = hinfo
widget_control,hinfo.info.QuickLook,Get_Uvalue = info

graphnum = hinfo.graphnum

if (widget_info(event.id,/TLB_SIZE_EVENTS) eq 1 ) then begin

    if(graphnum eq 1) then begin
        info.histoS1.xwindowsize = event.x
        info.histoS1.ywindowsize = event.y
        info.histoS1.uwindowsize  = 1
    endif

    if(graphnum eq 2) then begin
        info.histoS2.xwindowsize = event.x
        info.histoS2.ywindowsize = event.y
        info.histoS2.uwindowsize  = 1
    endif

    if(graphnum eq 3) then begin
        info.histoS3.xwindowsize = event.x
        info.histoS3.ywindowsize = event.y
        info.histoS3.uwindowsize  = 1
    endif
    widget_control,event.top,set_uvalue = hinfo
    widget_control,hinfo.info.Quicklook,set_uvalue = info
    msql_display_histo,graphnum,info
    return
endif

case 1 of

    (strmid(event_name,0,6) EQ 'printP') : begin
        print_histo,hinfo
    end    

    (strmid(event_name,0,6) EQ 'printD') : begin
        print,hinfo.type
        print_histo_data,hinfo
        
    end    
    (strmid(event_name,0,3) EQ 'Bin') : begin
        hinfo.histo_binnum = event.value
        
        msql_update_histo,hinfo
        Widget_Control,event.top,Set_UValue=hinfo
    end
;_______________________________________________________________________
; change x and y range of histo graph 
;_______________________________________________________________________
    (strmid(event_name,0,7) EQ 'hist_mm') : begin

        if(strmid(event_name,7,1) EQ 'x') then type = 0 else type = 1 
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
        if(strmid(event_name,7,2) EQ 'y2') then begin
            hinfo.histo_range[1,1]  = event.value
            widget_control,hinfo.histo_mmlabel[1,0],get_value = temp
            hinfo.histo_range[1,0] = temp
        endif

        hinfo.default_scale_histo[type] = 0

        widget_control,hinfo.histo_recomputeID[type],set_value=' Default '

        msql_update_histo,hinfo
        Widget_Control,event.top,Set_UValue=hinfo

    end
    
;_______________________________________________________________________
; set the Default range or user defined range for  histogram plot
    (strmid(event_name,0,1) EQ 'h') : begin
        type = fix(strmid(event_name,1,1)) - 1
        if(hinfo.default_scale_histo[type] eq 0 ) then begin ; true - turn to false
            widget_control,hinfo.histo_recomputeID[type],set_value=' Plot Range '
            hinfo.default_scale_histo[type] = 1
        endif

        msql_update_histo,hinfo
        Widget_Control,event.top,Set_UValue=hinfo
    end
else: print," Event name not found",event_name
endcase
end
;***********************************************************************
;***********************************************************************
pro msql_display_histo,graphnum,info



window,1,/pixmap
wdelete,1

jintegration = 0 
stitle = "MIRI Slope Quick Look- Histogram" + info.version	


if(info.slope.plane[graphnum-1] eq 0) then  begin
    svalue = " Histogram of Slope Values"
    outn = '_histo_slope' 
endif
if(info.slope.plane[graphnum-1] eq 1) then  begin
    svalue = " Histogram of Uncertainties"
    outn = '_histo_uncertainty' 
endif
if(info.slope.plane[graphnum-1] eq 2) then  begin
    svalue = " Histogram of Data Quality Flag"
    outn = '_histo_quality_flag'
endif 
if(info.slope.plane[graphnum-1] eq 3) then begin
    svalue = " Histogram of Zero Pt"
    outn = '_histo_zero_pt' 
endif
if(info.slope.plane[graphnum-1] eq 4) then begin
    svalue = " Histogram of # Good Reads"
    outn = '_histo_num_good_reads' 
endif
if(info.slope.plane[graphnum-1] eq 5) then begin
    svalue = " Histogram of Frame # of 1st Sat"
    outn = '_histo_frame_1st_sat' 
endif
if(info.slope.plane[graphnum-1] eq 6) then begin
    svalue = " Histogram of Max 2 point Differences"
    outn = '_histo_max_2pt_diff' 
endif
if(info.slope.plane[graphnum-1] eq 7) then begin
    svalue = " Histogram of Read # of Max 2 point Differences"
    outn = '_histo_frame_max_2pt_diff' 
endif
if(info.slope.plane[graphnum-1] eq 8) then begin
    svalue = " Histogram of Standard Dev 2 point Differences"
    outn = '_histo_stdev_2pt_diff' 
endif
if(info.slope.plane[graphnum-1] eq 9) then  begin
    svalue = " Histogram of Slope of  2 point Differences"
    outn = '_histo_slope_2pt_diff' 
endif

type = 0

if(graphnum eq 1) then begin

    histo_uwindowsize = info.histos1.uwindowsize
    histo_xwindowsize = info.histos1.xwindowsize
    histo_ywindowsize = info.histos1.ywindowsize
    jintegration = fix(info.histoS1.jintegration+1)

    ftitle = "Integration #: " + strtrim(string(jintegration),2) 
    if( XRegistered ('msqlh1')) then begin
        widget_control,info.Histo1_SlopeQuickLook,/destroy
    endif

    ij = 'int' + string(jintegration) 
    ij = strcompress(ij,/remove_all)

    outname = '_'+ ij + outn 


    sxmin = strcompress(string(info.histoS1.ximage_range[0]),/remove_all)
    sxmax = strcompress(string(info.histoS1.ximage_range[1]),/remove_all)
    symin = strcompress(string(info.histoS1.yimage_range[0]),/remove_all)
    symax = strcompress(string(info.histoS1.yimage_range[1]),/remove_all)
    sregion = "Plot Region: range: " + sxmin + " - " + sxmax + " yrange: " + $
              symin + "  - " + symax 
    type = 3
endif

if(graphnum eq 2) then begin
    svalue = " Zoomed " + svalue

    histo_uwindowsize = info.histos2.uwindowsize
    histo_xwindowsize = info.histos2.xwindowsize
    histo_ywindowsize = info.histos2.ywindowsize
    jintegration = fix(info.histoS2.jintegration+1)

    ftitle = "Integration #: " + strtrim(string(jintegration),2)
    if( XRegistered ('msqlh2')) then begin
        widget_control,info.Histo2_SlopeQuickLook,/destroy
    endif

    ij = 'int' + string(jintegration) 
    ij = strcompress(ij,/remove_all)

    outname ='_' + ij + '_zoom'+ outn
    sxmin = strcompress(string(info.histoS2.ximage_range[0]),/remove_all)
    sxmax = strcompress(string(info.histoS2.ximage_range[1]),/remove_all)
    symin = strcompress(string(info.histoS2.yimage_range[0]),/remove_all)
    symax = strcompress(string(info.histoS2.yimage_range[1]),/remove_all)
    sregion = "Plot Region: range: " + sxmin + " - " + sxmax + " yrange: " + $
              symin + "  - " + symax 
    type = 4
endif



if(graphnum eq 3) then begin

    histo_uwindowsize = info.histos3.uwindowsize
    histo_xwindowsize = info.histos3.xwindowsize
    histo_ywindowsize = info.histos3.ywindowsize
    jintegration = fix(info.histoS3.jintegration+1)
    ftitle = " Integration #: " + strtrim(string(jintegration),2)
    if(XRegistered ('msqlh3')) then begin
        widget_control,info.Histo3_SlopeQuickLook,/destroy
    endif

    ij = 'int' + string(jintegration) 
    ij = strcompress(ij,/remove_all)


    outname = '_' + ij + outn

    sxmin = strcompress(string(info.histoS3.ximage_range[0]),/remove_all)
    sxmax = strcompress(string(info.histoS3.ximage_range[1]),/remove_all)
    symin = strcompress(string(info.histoS3.yimage_range[0]),/remove_all)
    symax = strcompress(string(info.histoS3.yimage_range[1]),/remove_all)
    sregion = "Plot Region: range: " + sxmin + " - " + sxmax + " yrange: " + $
              symin + "  - " + symax 
    type = 5
endif

subt = svalue + ": " + ftitle

; widget window parameters
xwidget_size = 800
ywidget_size = 1000
xsize_scroll = 750
ysize_scroll = 900

if(histo_uwindowsize eq 1) then begin ; user has set window size 
    xsize_scroll =histo_xwindowsize
    ysize_scroll = histo_ywindowsize
endif
if(info.control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.control.x_scroll_window
if(info.control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.control.y_scroll_window
if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10

HistoQuickLook = widget_base(title=stitle ,$
                             col = 1,mbar = menuBar,group_leader=info.SlopeQuickLook,$
                             xsize = ywidget_size,$
                             ysize= xwidget_size,/scroll,$
                             x_scroll_size=xsize_scroll,y_scroll_size=ysize_scroll,/TLB_SIZE_EVENTS)


QuitMenu = widget_button(menuBar,value="Quit",font = info.font2)
; add quit button
quitbutton = widget_button(quitmenu,value="Quit",event_pro='msql_histo_quit')
PMenu = widget_button(menuBar,value="Print",font = info.font2)
PbuttonR = widget_button(Pmenu,value = "Print Plot to output file",uvalue='printP')
PbuttonD = widget_button(Pmenu,value = "Print Histogram Data to ascii file ",uvalue='printD')
;********
; build the menubar
;********

titlelabel = widget_label(HistoQuickLook, $
                           value=info.control.filename_raw,/align_left, $
                           font=info.font3,/dynamic_resize)



subtitle = widget_label(HistoQuickLook, $
                           value=ftitle,/align_left, $
                           font=info.font3,/dynamic_resize)

;_______________________________________________________________________

rawmedian = 0

histo_mmlabel        = lonarr(2,2) ; plot label 
histo_range          = fltarr(2,2) ; plot range
histo_recomputeID    = lonarr(2); button controlling Default scale or User Set Scale
default_scale_histo  = intarr(2) ; scaling min and max display ranges 

histo_range[*,*] = 0.0
default_scale_histo[*] = 1

tlabelID = widget_label(HistoQuickLook,$
                        value =svalue ,/align_center,$
                        font=info.font5,/align_left)
rlabel = widget_label(HistoQuicklook, value=sregion, font=info.font3,/align_left)
xsize_label = 12    
; button to change 
histo_binnum = 5000
pix_num_base = widget_base(HistoQuickLook,row=1,/align_left)
histo_binlabel = cw_field(pix_num_base,title='Number of Bins',xsize=xsize_label,$
                                         value=histo_binnum,font=info.font4,$
                                         uvalue='Bin',/return_events)

blank10 = '             '
num_base = widget_base(HistoQuickLook,row=1,/align_left)
median_labelID = widget_label(num_base,$
                         value='Median: ' + blank10,font=info.font3)

min_labelID = widget_label(num_base,$
                         value='Minimum: ' + blank10,font=info.font3)

max_labelID = widget_label(num_base,$
                         value='Maximum: ' + blank10,font=info.font3)

num_labelID = widget_label(num_base,$
                         value='# Good Pixels: ' + blank10,font=info.font3)


graphID = widget_draw(HistoQuickLook,$
                                    xsize = info.plotsize1*2.2,$
                                    ysize = info.plotsize1*2.2,$
                                    retain=info.retn)


pix_num_base2 = widget_base(HistoQuickLook,row=1)
labelID = widget_label(pix_num_base2,value="X->",font=info.font4)
histo_mmlabel[0,0] = cw_field(pix_num_base2,title="min:",font=info.font4, $
                                        uvalue="hist_mmx1",/float,/return_events, $
                                        value=histo_range[0,0], $
                                        xsize=xsize_label,fieldfont=info.font4)

histo_mmlabel[0,1] = cw_field(pix_num_base2,title="max:",font=info.font4, $
                                        uvalue="hist_mmx2",/float,/return_events, $
                                        value=histo_range[0,1],xsize=xsize_label,$
                                        fieldfont=info.font4)

histo_recomputeID[0] = widget_button(pix_num_base2,value=' Plot Range',$
                                               font=info.font4,$
                                               uvalue = 'h1')

;pix_num_base3 = widget_base(HistoQuickLook,row=1)

labelID = widget_label(pix_num_base2,value="Y->",font=info.font4)
histo_mmlabel[1,0] = cw_field(pix_num_base2,title="min:",font=info.font4, $
                                        uvalue="hist_mmy1",/long,/return_events, $
                                        value=long(histo_range[1,0]),xsize=xsize_label,$
                                        fieldfont=info.font4)

histo_mmlabel[1,1] = cw_field(pix_num_base2,title="max:",font=info.font4, $
                                        uvalue="hist_mmy2",/long,/return_events, $
                                        value=long(histo_range[1,1]),xsize=xsize_label,$
                                        fieldfont=info.font4)

histo_recomputeID[1] = widget_button(pix_num_base2,value=' Plot Range',$
                                               font=info.font4,$
                                               uvalue = 'h2')

;Set up the GUI
longline = '                                                                                                                        '
longtag = widget_label(HistoQuickLook,value = longline)
Widget_control,HistoQuickLook,/Realize

if(graphnum eq 1) then $
XManager,'msqlh1',HistoQuickLook,/No_Block,event_handler='msql_histo_event'


if(graphnum eq 2) then $
XManager,'msqlh2',HistoQuickLook,/No_Block,event_handler='msql_histo_event'

if(graphnum eq 3) then $
XManager,'msqlh3',HistoQuickLook,/No_Block,event_handler='msql_histo_event'


widget_control,graphID,get_value=tdraw_id
draw_window_id = tdraw_id


Widget_Control,info.QuickLook,Set_UValue=info
hinfo = {histo_binnum        : histo_binnum,$
         histo_binlabel      : histo_binlabel,$
         median_labelID      : median_labelID,$
         min_labelID         : min_labelID,$
         max_labelID         : max_labelID,$
         num_labelID         : num_labelID,$
         histo_recomputeID   : histo_recomputeID,$
         histo_mmlabel       : histo_mmlabel,$
         histo_range         : histo_range,$
         graphID             : graphID,$
         draw_window_id      : draw_window_id,$
         default_scale_histo : default_scale_histo,$
         outname             : outname,$
         graphnum            : graphnum,$
         subt                : subt,$
         otype               : 0,$
         type                : type,$
         info                : info}


if(graphnum eq 1) then begin
    info.Histo1_SlopeQuickLook = HistoQuickLook
    Widget_Control,info.Histo1_SlopeQuickLook,Set_UValue=hinfo
    Widget_Control,info.QuickLook,Set_UValue=info
    msql_update_histo,hinfo
    Widget_Control,info.Histo1_SlopeQuickLook,Set_UValue=hinfo
endif


if(graphnum eq 2) then begin
    info.Histo2_SlopeQuickLook = HistoQuickLook
    Widget_Control,info.Histo2_SlopeQuickLook,Set_UValue=hinfo
    Widget_Control,info.QuickLook,Set_UValue=info
    msql_update_histo,hinfo
    Widget_Control,info.Histo2_SlopeQuickLook,Set_UValue=hinfo
endif
 
if(graphnum eq 3) then begin
    info.Histo3_SlopeQuickLook = HistoQuickLook
    Widget_Control,info.Histo3_SlopeQuickLook,Set_UValue=hinfo
    Widget_Control,info.QuickLook,Set_UValue=info
    msql_update_histo,hinfo
    Widget_Control,info.Histo3_SlopeQuickLook,Set_UValue=hinfo
endif

Widget_Control,info.QuickLook,Set_UValue=info

end
