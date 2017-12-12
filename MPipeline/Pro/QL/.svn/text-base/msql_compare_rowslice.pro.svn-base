;______________________________________________________________________
pro msql_compare_rowslice_quit,event

widget_control,event.top, Get_UValue = hinfo	
widget_control,hinfo.info.QuickLook,Get_Uvalue = info
widget_control,info.RowsliceSCompareQuickLook,/destroy

end
;_______________________________________________________________________
;***********************************************************************

; the event manager for the ql.pro (main base widget)
pro msql_compare_rowslice_event,event

Widget_Control,event.id,Get_uValue=event_name
widget_control,event.top, Get_UValue = hinfo
widget_control,hinfo.info.Quicklook,Get_Uvalue = minfo

hinfo.info = minfo

if (widget_info(event.id,/TLB_SIZE_EVENTS) eq 1 ) then begin
    minfo.scompare_rowslice.xwindowsize = event.x
    minfo.scompare_rowslice.ywindowsize = event.y
    minfo.scompare_rowslice.uwindowsize = 1
    widget_control,event.top,set_uvalue = hinfo
    widget_control,hinfo.info.Quicklook,set_uvalue = minfo
    msql_compare_rowslice,minfo
    return
endif

case 1 of

;______________________________________________________________________
; Select a different column to plot a slice through
;_______________________________________________________________________
    (strmid(event_name,0,3) EQ 'row') : begin
        if(strmid(event_name,4,4) eq 'vals') then begin
            value = float(event.value) 
            hinfo.rowstart = value
            if(value le 0) then hinfo.rowstart = 1

            if(value gt hinfo.maxsize) then hinfo.rowstart = hinfo.maxsize

            hinfo.rowend = hinfo.rowstart + hinfo.rownum -1 
        endif

        if(strmid(event_name,4,4) eq 'valn') then begin
            value = float(event.value) 
            hinfo.rownum = value
            if(value le 0) then begin
;    		result=dialog_message("Enter a value equal to or greater than 1",/error )		-
                hinfo.rownum = 1
            endif
            value  = hinfo.rowstart + hinfo.rownum -1
            hinfo.rowend = value
            hinfo.rownum = hinfo.rowend - hinfo.rowstart  + 1

            if(value gt hinfo.maxsize) then begin
                hinfo.rowend = hinfo.maxsize
                hinfo.rownum = hinfo.rowend - hinfo.rowstart  + 1
            endif
        endif

;check if the <> buttons were used
        step = 1.0
        if(strmid(event_name,4,4) eq 'move') then begin
            if(strmid(event_name,9,2) eq 'x1') then begin
                hinfo.rowstart = hinfo.rowstart - step
                hinfo.rowend = hinfo.rowend - step                
            endif
            if(strmid(event_name,9,2) eq 'x2') then begin
                hinfo.rowstart = hinfo.rowstart + step
                hinfo.rowend = hinfo.rowend + step
            endif
        endif

        if(hinfo.rowstart le 0) then hinfo.rownum_start= 1
        if(hinfo.rowstart ge hinfo.maxsize) then hinfo.rowstart =hinfo.maxsize
        if(hinfo.rowend le 0) then hinfo.rowend= 1
        if(hinfo.rowend ge hinfo.maxsize) then hinfo.rowend =hinfo.maxsize

        hinfo.rownum = hinfo.rowend - hinfo.rowstart + 1
        widget_control,hinfo.start_label,set_value=hinfo.rowstart
        widget_control,hinfo.num_label,set_value=hinfo.rownum


	for i = 0,2 do begin
	
        	msql_update_compare_rowslice,i,hinfo
	endfor

     end	


;_______________________________________________________________________
    (strmid(event_name,0,6) EQ 'printP') : begin
        print_compare_rowslice,hinfo
        
    end    

    (strmid(event_name,0,6) EQ 'printD') : begin
        print_compare_rowslice_data,hinfo
        
    end    
;_______________________________________________________________________
; change x and y range of rowslice graph 
;_______________________________________________________________________
(strmid(event_name,0,5) EQ 'srow_') : begin

        k = fix(strmid(event_name,5,1))-1
        if(strmid(event_name,7,1) EQ '1') then begin
            p = 0
            pp = 1
        endif else begin
            p = 1
            pp = 0
        endelse
;_______________________________________________________________________
; channels scale individually


        if(hinfo.scaleimage-1 eq 3 or k eq 2) then begin
            if(strmid(event_name,6,1) EQ 'x') then begin
                hinfo.rowslice_xrange[k,p] = event.value
                widget_control,hinfo.rowslice_xlabel[k,pp],get_value = temp
                hinfo.rowslice_xrange[k,pp] = temp

                hinfo.default_scale_rowslice[k,0] = 0
                widget_control,hinfo.rowslice_recomputeID[k,0],set_value='Default Range'
            endif

            if(strmid(event_name,6,1) EQ 'y') then begin
                hinfo.rowslice_yrange[k,p] = event.value
                widget_control,hinfo.rowslice_ylabel[k,pp],get_value = temp
                hinfo.rowslice_yrange[k,pp] = temp
                hinfo.default_scale_rowslice[k,1] = 0
                widget_control,hinfo.rowslice_recomputeID[k,1],set_value='Default Range'

            endif
            msql_update_compare_rowslice,k,hinfo
        endif else begin 

;        if(hinfo.scaleimage-1 ne 3) then begin

            index = hinfo.scaleimage-1

            if(k eq index)then begin
                if(strmid(event_name,6,1) EQ 'x') then begin
                    hinfo.rowslice_xrange[k,p] = event.value
                    widget_control,hinfo.rowslice_xlabel[k,pp],get_value = temp
                    hinfo.rowslice_xrange[k,pp] = temp
                    hinfo.default_scale_rowslice[k,0] = 0
                    widget_control,hinfo.rowslice_recomputeID[k,0],set_value='Default Range'
                endif

                if(strmid(event_name,6,1) EQ 'y') then begin
                    hinfo.rowslice_yrange[k,p] = event.value
                    widget_control,hinfo.rowslice_ylabel[k,pp],get_value = temp
                    hinfo.rowslice_yrange[k,pp] = temp
                    hinfo.default_scale_rowslice[k,1] = 0
                    widget_control,hinfo.rowslice_recomputeID[k,1],set_value='Default Range'
                    
                endif
                msql_update_compare_rowslice,k,hinfo
            endif
            

            for i = 0,1 do begin
                hinfo.rowslice_xrange[i,*] = hinfo.rowslice_xrange[index,*]
                hinfo.rowslice_yrange[i,*] = hinfo.rowslice_yrange[index,*]
                hinfo.default_scale_rowslice[i,*] = hinfo.default_scale_rowslice[index,*]

                hinfo.info = minfo
                widget_control,event.top,set_uvalue = hinfo
                widget_control,hinfo.info.Quicklook,set_uvalue = minfo
                msql_update_compare_rowslice,i,hinfo
            endfor
;        endif
        endelse
    end
    
;_______________________________________________________________________
; set the Default range or user defined range for  rowslicegram plot
;_______________________________________________________________________
 (strmid(event_name,0,2) EQ 'hd') : begin
        if(strmid(event_name,2,1) EQ 'x') then xy = 0 else xy = 1
        graphno = fix(strmid(event_name,3,1))-1

        if(hinfo.scaleimage-1 eq 3 or graphno eq 2) then begin
            widget_control,hinfo.rowslice_recomputeID[graphno,xy],set_value='Plot Range '
            hinfo.default_scale_rowslice[graphno,xy] = 1
            msql_update_compare_rowslice,graphno,hinfo

        endif else begin
            if(graphno eq hinfo.scaleimage -1) then begin
                widget_control,hinfo.rowslice_recomputeID[graphno,xy],set_value='Plot Range '
                hinfo.default_scale_rowslice[graphno,xy] = 1
                for i = 0,2 do begin
                    msql_update_compare_rowslice,i,hinfo
                endfor
            endif
        endelse



    end

;_______________________________________________________________________

    (strmid(event_name,0,6) EQ 'ascale') : begin

        hinfo.scaleimage = fix(strmid(event_name,6,1))

        for i = 0,2 do begin

            if(hinfo.scaleimage-1 eq 3) then begin
                widget_control,hinfo.rowslice_recomputeID[i,0],set_value=' Plot Range '
                hinfo.default_scale_rowslice[i,0] = 1
                widget_control,hinfo.rowslice_recomputeID[i,1],set_value=' Plot Range '
                hinfo.default_scale_rowslice[i,1] = 1
            endif

            if(i lt 2 and hinfo.scaleimage-1 eq i) then begin
                widget_control,hinfo.rowslice_recomputeID[i,0],set_value=' Plot Range '
                hinfo.default_scale_rowslice[i,0] = 1
                widget_control,hinfo.rowslice_recomputeID[i,1],set_value=' Plot Range '
                hinfo.default_scale_rowslice[i,1] = 1
            endif


            msql_update_compare_rowslice,i,hinfo
        endfor



    end

;_______________________________________________________________________


else: print," Event name not found",event_name
endcase

hinfo.info = minfo
widget_control,event.top,set_uvalue = hinfo
widget_control,hinfo.info.Quicklook,set_uvalue = minfo

end

;***********************************************************************
pro msql_update_compare_rowslice,imageno,hinfo,ps=ps,eps=eps,ascii=ascii,unit=iunit


tick_no = 3
if(imageno eq 2) then tick_no = 5
hcopy = 0
if ( (keyword_set(ps)) or ( keyword_set(eps)) ) then hcopy = 1

info = hinfo.info


ximage_size = info.rcompare_image[imageno].xsize
yimage_size = info.rcompare_image[imageno].ysize
n_pixels = float( ximage_size*yimage_size)


; check if default scale is true - then reset to orginal value
if(info.rcompare.default_scale_graph[imageno] eq 1) then begin
    info.rcompare.graph_range[imageno,0] = info.rcompare_image[imageno].range_min
    info.rcompare.graph_range[imageno,1] = info.rcompare_image[imageno].range_max
endif

frame_image = fltarr(ximage_size,yimage_size)
frame_image[*,*] = (*info.rcompare_image[imageno].pdata)
indxs = where(finite(frame_image),n_pixels)


x1 = hinfo.rowstart-1
x2 = hinfo.rowend-1

srow = ' Row range: ' + strcompress(string(fix(x1)),/remove_all) + ' - ' + $
       strcompress(string(fix(x2)),/remove_all) 


rowdataW = frame_image[*,x1:x2]
s = size(frame_image)
num = s[1]


num = s[1]
width = x2 - x1 + 1

rowdataALL = fltarr(num)

for i = 0,num -1 do begin
    rowdataALL[i] = total(rowdataW[i,*])/width
endfor

rowdata = rowdataALL
rowdataALL = 0

n_reads = n_elements(rowdata)
xvalues = indgen(n_reads) + 1
pad = 0.002
xmin = min(xvalues)
xmax = max(xvalues)
 

xpad = fix(n_reads*pad)
if(xpad le 0 ) then xpad = 1
; get min and max for the display
get_image_stat,rowdata,mean_row,std,min_row,max_row,$
               min_image,max_image,median_row,stdev_mean,skew,ngood,nbad


; check if default scale is true - then reset to orginal value


index = hinfo.scaleimage -1
if(index eq 3) then index = imageno
if(imageno eq 2) then index = imageno


if(hinfo.default_scale_rowslice[index] eq 1) then begin
    xrowslicemin = xmin-xpad
    xrowslicemax = xmax+xpad
    if(xrowslicemin lt 0) then xmin = 0
endif

if(hcopy eq 0) then wset,hinfo.draw_window_id[imageno]     

xxmin = xmin-xpad
if(xxmin lt 0) then xxmin = 0
hinfo.xrange_default[imageno,0] = xxmin

xxmax = xmax+xpad
if(xxmax gt hinfo.maxsize) then xxmax = hinfo.maxsize 
hinfo.xrange_default[imageno,1] = xxmax


hinfo.yrange_default[imageno,0] = min_image
hinfo.yrange_default[imageno,1] = max_image

hinfo.rowslice_xrange[imageno,*] = hinfo.rowslice_xrange[index,*]
hinfo.rowslice_yrange[imageno,*] = hinfo.rowslice_yrange[index,*]


if(hinfo.default_scale_rowslice[index,0] eq 1) then begin
    hinfo.rowslice_xrange[imageno,0] = hinfo.xrange_default[index,0]
    hinfo.rowslice_xrange[imageno,1] = hinfo.xrange_default[index,1]
endif 
 
if(hinfo.default_scale_rowslice[index,1] eq 1) then begin
    hinfo.rowslice_yrange[imageno,0] = hinfo.yrange_default[index,0]
    hinfo.rowslice_yrange[imageno,1] = hinfo.yrange_default[index,1]
endif


xx1 = hinfo.rowslice_xrange[imageno,0]
xx2 = hinfo.rowslice_xrange[imageno,1]
yy1 = hinfo.rowslice_yrange[imageno,0]
yy2 = hinfo.rowslice_yrange[imageno,1]



yt = 'DN/s'
stitle = hinfo.ftitle[imageno]

plot,xvalues,rowdata,xtitle = "COLUMN  #", ytitle=yt,$
     xrange=[xx1,xx2],yrange=[yy1,yy2],xstyle =1,ystyle=1,title = stitle,subtitle = sstitle,$
     linestyle = 1,ytickformat = '(f10.3)'



widget_control,hinfo.rowslice_xlabel[imageno,0],$
               set_value=hinfo.rowslice_xrange[imageno,0]
widget_control,hinfo.rowslice_xlabel[imageno,1],$
               set_value=hinfo.rowslice_xrange[imageno,1]
widget_control,hinfo.rowslice_ylabel[imageno,0],$
               set_value=hinfo.rowslice_yrange[imageno,0]
widget_control,hinfo.rowslice_ylabel[imageno,1],$
               set_value=hinfo.rowslice_yrange[imageno,1]

index = hinfo.scaleimage -1
scale_name = ['Image 1','Image 2','Image 3']

if(index ne 3) then begin
    if(index ne imageno and imageno ne 2) then begin
                                                                                
        widget_control,hinfo.rowslice_recomputeID[imageno,0],set_value=scale_name[index]
        widget_control,hinfo.rowslice_recomputeID[imageno,1],set_value=scale_name[index]
    endif
endif

if(keyword_set(ascii)) then begin 
    if(N_elements(iunit)) then begin
        printf,iunit,'# Comment: Start Rowumn, End Rowumn'
        printf,iunit,'# Comment: Row #, Value'
        printf,iunit,x1+1,x2+1
        for i = 0, n_elements(rowdata)-1 do begin
            printf,iunit,i+1,rowdata[i]
        endfor
    endif
endif
frame_image = 0
xnew = 0
h = 0

plot_median = strcompress(string(median_row),/remove_all)
plot_mean = strcompress(string(mean_row),/remove_all)
plot_stdev = strcompress(string(std),/remove_all)
plot_min = strcompress(string(min_row),/remove_all)
plot_max = strcompress(string(max_row),/remove_all)


plot_label1 = 'Median: ' + plot_median + '   Mean: ' + plot_mean + '   Standard Dev: ' + plot_stdev
Plot_label2 = 'Min:    ' + plot_min +    '   Max:   ' + plot_max 
widget_control,hinfo.stat_label[imageno,0],set_value = plot_label1
widget_control,hinfo.stat_label[imageno,1],set_value = plot_label2





end
;***********************************************************************

;***********************************************************************
pro msql_compare_rowslice,info

window,1,/pixmap
wdelete,1
if( XRegistered ('CSrowslice')) then begin
    widget_control,info.RowsliceSCompareQuickLook,/destroy
endif



s = size( (*info.rcompare_image[0].pdata))
maxsize = s[2]


ftitle = strarr(3)
ftitle[0] = "Integration #: " + strtrim( string (fix(info.rcompare_image[0].jintegration+1)),2) 

ftitle[1] = "Integration #: " + strtrim( string (fix(info.rcompare_image[1].jintegration+1)),2) 

ftitle[2] = info.rcompare.compareoptions[info.rcompare.compare_type] 


stitle = "MIRI Quick Look- Row Slice of Comparison Slope Images" + info.version

; widget window parameters
xwidget_size = 1350
ywidget_size = 1200
xsize_scroll = 1250
ysize_scroll = 1100

if(info.scompare_rowslice.uwindowsize eq 1) then begin ; user has set window size 
    xsize_scroll = info.scompare_rowslice.xwindowsize
    ysize_scroll = info.scompare_rowslice.ywindowsize
endif

if(info.control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.control.x_scroll_window
if(info.control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.control.y_scroll_window

if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10


RowsliceQuickLook = widget_base(title=stitle ,$
                             col = 1,mbar = menuBar,$
                             group_leader = info.RCompareDisplay,$
                             xsize = xwidget_size,$
                             ysize = ywidget_size,/scroll,$
                             x_scroll_size= xsize_scroll,$
                             y_scroll_size = ysize_scroll,/TLB_SIZE_EVENTS)


QuitMenu = widget_button(menuBar,value="Quit",font = info.font2)

quitbutton = widget_button(quitmenu,value="Quit",event_pro='msql_compare_rowslice_quit')

scaleMenu = widget_button(menuBar,value="Lock Plot Ranges",font = info.font2)
scalebutton1 = widget_button(scalemenu,value=" Scale Plots 1 and 2 to Image 1",uvalue = 'ascale1')
scalebutton2 = widget_button(scalemenu,value=" Scale Plots 1 and 2 to Image 2",uvalue = 'ascale2')
scalebutton4 = widget_button(scalemenu,value=" Scale All Plot Individually",uvalue = 'ascale4')
scaleimage = 4


PMenu = widget_button(menuBar,value="Print",font = info.font2)
PbuttonR = widget_button(Pmenu,value = "Print Row Slice  plots to an output file ",uvalue='printP')
PbuttonD = widget_button(Pmenu,value = "Print Row Slice  Data to ascii file ",uvalue='printD')


move_base = widget_base(RowsliceQuickLook,/row,/align_left)


;_______________________________________________________________________
graphID_master0 = widget_base(RowsliceQuickLook,row=1)
graphID_master1 = widget_base(RowsliceQuickLook,row=1)
graphID11 = widget_base(graphID_master0,col=1)
graphID12 = widget_base(graphID_master0,col=1)
graphID21 = widget_base(graphID_master1,col=1)
graphID22 = widget_base(graphID_master1,col=1)


graphID = lonarr(3)
draw_window_id = lonarr(3)
;_______________________________________________________________________
; initialize varibles 

rowslice_xlabel        = lonarr(3,2) ; plot label 
rowslice_ylabel        = lonarr(3,2) ; plot label 
rowslice_xrange        = lonarr(3,2) ; x  plot range
rowslice_yrange        = fltarr(3,2) ; x  plot range

xrange_default        = lonarr(3,2) ; x  plot range
yrange_default        = fltarr(3,2) ; x  plot range

rowslice_recomputeID    = lonarr(3,2); button controlling Default scale or User Set Scale
default_scale_rowslice  = intarr(3,2) ; scaling min and max display ranges 

rowslice_xrange[*,*] = 0
rowslice_yrange[*,*] = 0

default_scale_rowslice[*] = 1

xsize_label = 7    
plotsizex = 520
plotsizey = 310
plotsizeC = 500
;_______________________________________________________________________
;*****
;graph 1 Row Slice  of Image 1
;*****


graphID[0] = widget_draw(graphID11,$
                         xsize = plotsizeC,$
                         ysize = plotsizey,$
                         retain=info.retn)


pix_num_base2 = widget_base(graphID11,row=1)
labelID = widget_label(pix_num_base2,value="X->",font=info.font4)
rowslice_xlabel[0,0] = cw_field(pix_num_base2,title="min:",font=info.font4, $
                                        uvalue="srow_1x1",/float,/return_events, $
                                        value=rowslice_xrange[0,0], $
                                        xsize=xsize_label,fieldfont=info.font4)

rowslice_xlabel[0,1] = cw_field(pix_num_base2,title="max:",font=info.font4, $
                                        uvalue="srow_1x2",/float,/return_events, $
                                        value=rowslice_xrange[0,1],xsize=xsize_label,$
                                        fieldfont=info.font4)

rowslice_recomputeID[0,0] = widget_button(pix_num_base2,value=' Plot Range ',$
                                               font=info.font4,$
                                               uvalue = 'hdx1',/dynamic_resize)


pix_num_base3 = pix_num_base2

labelID = widget_label(pix_num_base3,value="Y->",font=info.font4)
rowslice_ylabel[0,0] = cw_field(pix_num_base3,title="min:",font=info.font4, $
                                        uvalue="srow_1y1",/float,/return_events, $
                                        value=rowslice_yrange[0,0],xsize=xsize_label,$
                                        fieldfont=info.font4)

rowslice_ylabel[0,1] = cw_field(pix_num_base3,title="max:",font=info.font4, $
                                        uvalue="srow_1y2",/float,/return_events, $
                                        value=rowslice_yrange[0,1],xsize=xsize_label,$
                                        fieldfont=info.font4)

rowslice_recomputeID[0,1] = widget_button(pix_num_base3,value=' Plot Range ',$
                                               font=info.font4,$
                                               uvalue = 'hdy1',/dynamic_resize)

;_______________________________________________________________________
;*****
;graph 2 Row Slice  of Image
;*****

graphID[1] = widget_draw(graphID12,$
                         xsize = plotsizeC,$
                         ysize = plotsizey,$
                         retain=info.retn)


pix_num_base2 = widget_base(graphID12,row=1)
labelID = widget_label(pix_num_base2,value="X->",font=info.font4)
rowslice_xlabel[1,0] = cw_field(pix_num_base2,title="min:",font=info.font4, $
                                        uvalue="srow_2x1",/float,/return_events, $
                                        value=rowslice_xrange[1,0], $
                                        xsize=xsize_label,fieldfont=info.font4)

rowslice_xlabel[1,1] = cw_field(pix_num_base2,title="max:",font=info.font4, $
                                        uvalue="srow_2x2",/float,/return_events, $
                                        value=rowslice_xrange[1,1],xsize=xsize_label,$
                                        fieldfont=info.font4)

rowslice_recomputeID[1,0] = widget_button(pix_num_base2,value=' Plot Range ',$
                                               font=info.font4,$
                                               uvalue = 'hdx2',/dynamic_resize)


pix_num_base3 = pix_num_base2

labelID = widget_label(pix_num_base3,value="Y->",font=info.font4)
rowslice_ylabel[1,0] = cw_field(pix_num_base3,title="min:",font=info.font4, $
                                        uvalue="srow_2y1",/float,/return_events, $
                                        value=rowslice_yrange[1,0],xsize=xsize_label,$
                                        fieldfont=info.font4)

rowslice_ylabel[1,1] = cw_field(pix_num_base3,title="max:",font=info.font4, $
                                        uvalue="srow_2y2",/float,/return_events, $
                                        value=rowslice_yrange[1,1],xsize=xsize_label,$
                                        fieldfont=info.font4)

rowslice_recomputeID[1,1] = widget_button(pix_num_base3,value=' Plot Range',$
                                               font=info.font4,$
                                               uvalue = 'hdy2',/dynamic_resize)

;_______________________________________________________________________
;*****
;graph 2 Row Slice  of Image 3 
;*****

graphID[2] = widget_draw(graphID21,$
                         xsize = plotsizeC,$
                         ysize = plotsizeC,$
                         retain=info.retn)

pix_num_base2 = widget_base(graphID21,row=1)
labelID = widget_label(pix_num_base2,value="X->",font=info.font4)
rowslice_xlabel[2,0] = cw_field(pix_num_base2,title="min:",font=info.font4, $
                                        uvalue="srow_3x1",/float,/return_events, $
                                        value=rowslice_xrange[2,0], $
                                        xsize=xsize_label,fieldfont=info.font4)

rowslice_xlabel[2,1] = cw_field(pix_num_base2,title="max:",font=info.font4, $
                                        uvalue="srow_3x2",/float,/return_events, $
                                        value=rowslice_xrange[2,1],xsize=xsize_label,$
                                        fieldfont=info.font4)

rowslice_recomputeID[2,0] = widget_button(pix_num_base2,value=' Plot Range ',$
                                               font=info.font4,$
                                               uvalue = 'hdx3',/dynamic_resize)


pix_num_base3 = pix_num_base2

labelID = widget_label(pix_num_base3,value="Y->",font=info.font4)
rowslice_ylabel[2,0] = cw_field(pix_num_base3,title="min:",font=info.font4, $
                                        uvalue="srow_3y1",/float,/return_events, $
                                        value=rowslice_yrange[2,0],xsize=xsize_label,$
                                        fieldfont=info.font4)

rowslice_ylabel[2,1] = cw_field(pix_num_base3,title="max:",font=info.font4, $
                                        uvalue="srow_3y2",/float,/return_events, $
                                        value=rowslice_yrange[2,1],xsize=xsize_label,$
                                        fieldfont=info.font4)

rowslice_recomputeID[2,1] = widget_button(pix_num_base3,value='Plot Range ',$
                                               font=info.font4,$
                                               uvalue = 'hdy3',/dynamic_resize)


;______________________________________________________________________
; 


s = size( (*info.rcompare_image[0].pdata))
rownum= s[2]/2
	
rowstart = rownum+1
rowend = rownum+1
rownum = 1

pix_num_base = widget_base(graphID22,row=1,/align_left)
labelID = widget_button(pix_num_base,uvalue='row_move_x1',value='<',font=info.font3)
labelID = widget_button(pix_num_base,uvalue='row_move_x2',value='>',font=info.font3)


start_label = cw_field(pix_num_base,title=' Start Row',xsize=5,$
                                         value=fix(rowstart),/integer,font=info.font4,$
                                         uvalue='row_vals',/return_events)

num_label = cw_field(pix_num_base,title=' Number of Rows',xsize=5,$
                                         value=fix(rownum),/integer,font=info.font4,$
                                         uvalue='row_valn',/return_events)
Image_label1 = '                         '
Image_label2 = '                         ' 
stat_label = lonarr(3,2)

imagelabels = widget_label(graphID22,value='   ')
stat_label_Image  = 'Statistics on Plot 1:'
imagelabel1 = widget_label(graphID22,value=stat_label_image,font=info.font5,/dynamic_resize,/align_left)

stat_label[0,0] = widget_label(graphID22,value = image_label1,font=info.font5,/dynamic_resize,/align_left)
stat_label[0,1]  = widget_label(graphID22,value = image_label2,font=info.font5,/dynamic_resize,/align_left)
Image_blank = widget_label(graphID22,value = ' ') 

stat_label_Image  = 'Statistics on Plot 2:'
imagelabel1 = widget_label(graphID22,value=stat_label_image,font=info.font5,/dynamic_resize,/align_left)

stat_label[1,0] = widget_label(graphID22,value = image_label1,font=info.font5,/dynamic_resize,/align_left)
stat_label[1,1]  = widget_label(graphID22,value = image_label2,font=info.font5,/dynamic_resize,/align_left)
Image_blank = widget_label(graphID22,value = ' ') 

stat_label_Image  = 'Statistics on Plot 3:'
imagelabel1 = widget_label(graphID22,value=stat_label_image,font=info.font5,/dynamic_resize,/align_left)
stat_label[2,0] = widget_label(graphID22,value = image_label1,font=info.font5,/dynamic_resize,/align_left)
stat_label[2,1]  = widget_label(graphID22,value = image_label2,font=info.font5,/dynamic_resize,/align_left)
Image_blank = widget_label(graphID22,value = ' ') 






;______________________________________________________________________
longline  = '                                                                              '
label = widget_label(graphID_master1,value = longline)
;______________________________________________________________________

;Set up the GUI
Widget_control,RowsliceQuickLook,/Realize

XManager,'CpSrowslice',RowsliceQuickLook,/No_Block,event_handler='msql_compare_rowslice_event'


for i = 0, 2 do begin
    widget_control,graphID[i],get_value=tdraw_id
    draw_window_id[i] = tdraw_id
endfor

sint = strtrim( string (fix(info.rcompare_image[0].jintegration+1)),2)


ij = 'int' + sint 
ij = strcompress(ij,/remove_all)

outname = 'rowslice_slope_compare_' + ij + '_' 


type = 2

Widget_Control,info.QuickLook,Set_UValue=info
hinfo = {info                : info,$
         rowstart               : rowstart,$
	 rowend                 : rowend,$
	 rownum                 : rownum,$
         maxsize                : maxsize,$
	 start_label            : start_label,$
	 num_label              : num_label,$
         stat_label             : stat_label,$
         rowslice_recomputeID   : rowslice_recomputeID,$
         rowslice_xlabel        : rowslice_xlabel,$
         rowslice_ylabel        : rowslice_ylabel,$
         rowslice_xrange        : rowslice_xrange,$
         rowslice_yrange        : rowslice_yrange,$
         xrange_default      : xrange_default,$
         yrange_default      : yrange_default,$
         graphID             : graphID,$
         ftitle              : ftitle,$
         outname             : outname,$
         type                : type,$
         scaleimage          : scaleimage,$
         draw_window_id      : draw_window_id,$
         default_scale_rowslice : default_scale_rowslice}


info.RowsliceSCompareQuickLook = RowsliceQuickLook
Widget_Control,info.RowsliceSCompareQuickLook,Set_UValue=hinfo
Widget_Control,info.QuickLook,Set_UValue=info
for i = 0,2 do begin
    imageno = i
    msql_update_Compare_rowslice,imageno,hinfo
endfor
Widget_Control,info.RowsliceSCompareQuickLook,Set_UValue=hinfo





Widget_Control,info.QuickLook,Set_UValue=info

end
