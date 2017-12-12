;______________________________________________________________________
pro mql_compare_histo_quit,event

widget_control,event.top, Get_UValue = hinfo	
widget_control,hinfo.info.QuickLook,Get_Uvalue = info
widget_control,info.HistoCompareQuickLook,/destroy



end
;_______________________________________________________________________
;***********************************************************************

; the event manager for the ql.pro (main base widget)
pro mql_compare_histo_event,event

Widget_Control,event.id,Get_uValue=event_name
widget_control,event.top, Get_UValue = hinfo
widget_control,hinfo.info.Quicklook,Get_Uvalue = minfo

hinfo.info = minfo

if (widget_info(event.id,/TLB_SIZE_EVENTS) eq 1 ) then begin
    minfo.compare_histo.xwindowsize = event.x
    minfo.compare_histo.ywindowsize = event.y
    minfo.compare_histo.uwindowsize = 1
    widget_control,event.top,set_uvalue = hinfo
    widget_control,hinfo.info.Quicklook,set_uvalue = minfo
    mql_compare_histo,minfo
    return
endif

case 1 of
    (strmid(event_name,0,3) EQ 'Bin') : begin
        graphno = fix(strmid(event_name,3,1))-1
        hinfo.histo_binnum[graphno] = event.value
        mql_update_compare_histo,graphno,hinfo

    end


    (strmid(event_name,0,6) EQ 'printP') : begin
        print_compare_histo,hinfo
        
    end    

    (strmid(event_name,0,6) EQ 'printD') : begin
        print_compare_histo_data,hinfo
        
    end    
;_______________________________________________________________________
; change x and y range of histo graph 
;_______________________________________________________________________
(strmid(event_name,0,5) EQ 'hist_') : begin

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
                hinfo.histo_xrange[k,p] = event.value
                widget_control,hinfo.histo_xlabel[k,pp],get_value = temp
                hinfo.histo_xrange[k,pp] = temp

                hinfo.default_scale_histo[k,0] = 0
                widget_control,hinfo.histo_recomputeID[k,0],set_value='Default Range'
            endif

            if(strmid(event_name,6,1) EQ 'y') then begin
                hinfo.histo_yrange[k,p] = event.value
                widget_control,hinfo.histo_ylabel[k,pp],get_value = temp
                hinfo.histo_yrange[k,pp] = temp
                hinfo.default_scale_histo[k,1] = 0
                widget_control,hinfo.histo_recomputeID[k,1],set_value='Default Range'

            endif
            mql_update_compare_histo,k,hinfo
        endif else begin 

;        if(hinfo.scaleimage-1 ne 3) then begin

            index = hinfo.scaleimage-1

            if(k eq index)then begin
                if(strmid(event_name,6,1) EQ 'x') then begin
                    hinfo.histo_xrange[k,p] = event.value
                    widget_control,hinfo.histo_xlabel[k,pp],get_value = temp
                    hinfo.histo_xrange[k,pp] = temp
                    hinfo.default_scale_histo[k,0] = 0
                    widget_control,hinfo.histo_recomputeID[k,0],set_value='Default Range'
                endif

                if(strmid(event_name,6,1) EQ 'y') then begin
                    hinfo.histo_yrange[k,p] = event.value
                    widget_control,hinfo.histo_ylabel[k,pp],get_value = temp
                    hinfo.histo_yrange[k,pp] = temp
                    hinfo.default_scale_histo[k,1] = 0
                    widget_control,hinfo.histo_recomputeID[k,1],set_value='Default Range'
                    
                endif
                mql_update_compare_histo,k,hinfo
            endif
            

            for i = 0,1 do begin
                hinfo.histo_xrange[i,*] = hinfo.histo_xrange[index,*]
                hinfo.histo_yrange[i,*] = hinfo.histo_yrange[index,*]
                hinfo.default_scale_histo[i,*] = hinfo.default_scale_histo[index,*]

                hinfo.info = minfo
                widget_control,event.top,set_uvalue = hinfo
                widget_control,hinfo.info.Quicklook,set_uvalue = minfo
                mql_update_compare_histo,i,hinfo
            endfor
;        endif
        endelse
    end
    
;_______________________________________________________________________
; set the Default range or user defined range for  histogram plot
;_______________________________________________________________________
 (strmid(event_name,0,2) EQ 'hd') : begin
        if(strmid(event_name,2,1) EQ 'x') then xy = 0 else xy = 1
        graphno = fix(strmid(event_name,3,1))-1

        if(hinfo.scaleimage-1 eq 3 or graphno eq 2) then begin
            widget_control,hinfo.histo_recomputeID[graphno,xy],set_value='Plot Range '
            hinfo.default_scale_histo[graphno,xy] = 1
            mql_update_compare_histo,graphno,hinfo

        endif else begin
            if(graphno eq hinfo.scaleimage -1) then begin
                widget_control,hinfo.histo_recomputeID[graphno,xy],set_value='Plot Range '
                hinfo.default_scale_histo[graphno,xy] = 1
                for i = 0,2 do begin
                    mql_update_compare_histo,i,hinfo
                endfor
            endif
        endelse



    end

;_______________________________________________________________________

    (strmid(event_name,0,6) EQ 'ascale') : begin

        hinfo.scaleimage = fix(strmid(event_name,6,1))

        for i = 0,2 do begin

            if(hinfo.scaleimage-1 eq 3) then begin
                widget_control,hinfo.histo_recomputeID[i,0],set_value=' Plot Range '
                hinfo.default_scale_histo[i,0] = 1
                widget_control,hinfo.histo_recomputeID[i,1],set_value=' Plot Range '
                hinfo.default_scale_histo[i,1] = 1
            endif

            if(i lt 2 and hinfo.scaleimage-1 eq i) then begin
                widget_control,hinfo.histo_recomputeID[i,0],set_value=' Plot Range '
                hinfo.default_scale_histo[i,0] = 1
                widget_control,hinfo.histo_recomputeID[i,1],set_value=' Plot Range '
                hinfo.default_scale_histo[i,1] = 1
            endif


            mql_update_compare_histo,i,hinfo
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
pro mql_update_compare_histo,imageno,hinfo,ps=ps,eps=eps,ascii=ascii,unit=iunit


tick_no = 3
if(imageno eq 2) then tick_no = 5
hcopy = 0
if ( (keyword_set(ps)) or ( keyword_set(eps)) ) then hcopy = 1

info = hinfo.info


ximage_size = info.compare_image[imageno].xsize
yimage_size = info.compare_image[imageno].ysize
n_pixels = float( ximage_size*yimage_size)


; check if default scale is true - then reset to orginal value
if(info.compare.default_scale_graph[imageno] eq 1) then begin
    info.compare.graph_range[imageno,0] = info.compare_image[imageno].range_min
    info.compare.graph_range[imageno,1] = info.compare_image[imageno].range_max
endif

frame_image = fltarr(ximage_size,yimage_size)
frame_image[*,*] = (*info.compare_image[imageno].pdata)
indxs = where(finite(frame_image),n_pixels)

numbins = hinfo.histo_binnum[imageno]



smedian = strcompress(string(info.compare_image[imageno].median),/remove_all) 

index = hinfo.scaleimage -1
if(index eq 3) then index = imageno
if(imageno eq 2) then index = imageno


if(hinfo.default_scale_histo[index] eq 0) then begin
    xhistomin = hinfo.histo_xrange[imageno,0]
    xhistomax = hinfo.histo_xrange[imageno,1]

    findhistogram_xlimits,frame_image,xnew,h,numbins,bins,xplot_min,xplot_max,xhistomin,xhistomax,status


endif else begin


    xhistomin = info.compare_image[imageno].median - info.compare_image[imageno].stdev*3
    xhistomax = info.compare_image[imageno].median + info.compare_image[imageno].stdev*3

    findhistogram_xlimits,frame_image,xnew,h,numbins,bins,xplot_min,xplot_max,xhistomin,xhistomax,status

endelse



if(hcopy eq 0) then wset,hinfo.draw_window_id[imageno]     

xmin = xplot_min
xmax = xplot_max
min_value = min(h)
max_value = max(h)

hinfo.xrange_default[imageno,0] = xmin
hinfo.xrange_default[imageno,1] = xmax
hinfo.yrange_default[imageno,0] = min_value
hinfo.yrange_default[imageno,1] = max_value



hinfo.histo_xrange[imageno,*] = hinfo.histo_xrange[index,*]
hinfo.histo_yrange[imageno,*] = hinfo.histo_yrange[index,*]



xt = 'Pixel Values'
yt = 'Number of Pixels'

if(hinfo.default_scale_histo[index,0] eq 1) then begin
    hinfo.histo_xrange[imageno,0] = hinfo.xrange_default[index,0]
    hinfo.histo_xrange[imageno,1] = hinfo.xrange_default[index,1]
endif 
 
if(hinfo.default_scale_histo[index,1] eq 1) then begin
    hinfo.histo_yrange[imageno,0] = hinfo.yrange_default[index,0]
    hinfo.histo_yrange[imageno,1] = hinfo.yrange_default[index,1]
endif

x1 = hinfo.histo_xrange[imageno,0]
x2 = hinfo.histo_xrange[imageno,1]
y1 = hinfo.histo_yrange[imageno,0]
y2 = hinfo.histo_yrange[imageno,1]




stitle = hinfo.ftitle[imageno]


plot,xnew,h,psym=10,xtitle= xt,ytitle=yt,$
        yrange = [y1,y2],xrange=[x1,x2],$
        ystyle=1,xstyle = 1,title = stitle
;        ystyle=1,xstyle = 1,xticks = tick_no,title = stitle

if(status ne 0) then begin
    print,'All the values were the same for the histogram plot'
    ypt = (y2 + y1)/2.0
    xyouts,xmin,ypt,'  All Values = ' + string(xmin)
endif
widget_control,hinfo.median_labelID[imageno],set_value=('Median ' +smedian) 
widget_control,hinfo.histo_binlabel[imageno],$
               set_value=hinfo.histo_binnum[imageno]
widget_control,hinfo.histo_xlabel[imageno,0],$
               set_value=hinfo.histo_xrange[imageno,0]
widget_control,hinfo.histo_xlabel[imageno,1],$
               set_value=hinfo.histo_xrange[imageno,1]
widget_control,hinfo.histo_ylabel[imageno,0],$
               set_value=hinfo.histo_yrange[imageno,0]
widget_control,hinfo.histo_ylabel[imageno,1],$
               set_value=hinfo.histo_yrange[imageno,1]

index = hinfo.scaleimage -1
scale_name = ['Image 1','Image 2','Image 3']

if(index ne 3) then begin
    if(index ne imageno and imageno ne 2) then begin
                                                                                
        widget_control,hinfo.histo_recomputeID[imageno,0],set_value=scale_name[index]
        widget_control,hinfo.histo_recomputeID[imageno,1],set_value=scale_name[index]
    endif
endif

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

;***********************************************************************
pro mql_compare_histo,info

window,1,/pixmap
wdelete,1
if( XRegistered ('Cphisto')) then begin
    widget_control,info.HistoCompareQuickLook,/destroy
endif

ftitle = strarr(3)
ftitle[0] = "Integration #: " + strtrim( string (fix(info.compare_image[0].jintegration+1)),2)  +$
          "   Frame #: " + strtrim( string(fix(info.compare_image[0].iramp+1)),2)

ftitle[1] = "Integration #: " + strtrim( string (fix(info.compare_image[1].jintegration+1)),2)  +$
          "   Frame #: " + strtrim( string(fix(info.compare_image[1].iramp+1)),2)

ftitle[2] = info.compare.compareoptions[info.compare.compare_type] 


stitle = "MIRI Quick Look- Histogram of Comparison Science Frame Images" + info.version

; widget window parameters
xwidget_size = 1350
ywidget_size = 1200
xsize_scroll = 1250
ysize_scroll = 1100

if(info.compare_histo.uwindowsize eq 1) then begin ; user has set window size 
    xsize_scroll = info.compare_histo.xwindowsize
    ysize_scroll = info.compare_histo.ywindowsize
endif

if(info.control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.control.x_scroll_window
if(info.control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.control.y_scroll_window

if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10


HistoQuickLook = widget_base(title=stitle ,$
                             col = 1,mbar = menuBar,$
                             group_leader = info.CompareDisplay,$
                             xsize = xwidget_size,$
                             ysize = ywidget_size,/scroll,$
                             x_scroll_size= xsize_scroll,$
                             y_scroll_size = ysize_scroll,/TLB_SIZE_EVENTS)


QuitMenu = widget_button(menuBar,value="Quit",font = info.font2)

quitbutton = widget_button(quitmenu,value="Quit",event_pro='mql_compare_histo_quit')

scaleMenu = widget_button(menuBar,value="Lock Plot Ranges",font = info.font2)
scalebutton1 = widget_button(scalemenu,value=" Scale Plots 1 and 2 to Image 1",uvalue = 'ascale1')
scalebutton2 = widget_button(scalemenu,value=" Scale Plots 1 and 2 to Image 2",uvalue = 'ascale2')
scalebutton4 = widget_button(scalemenu,value=" Scale All Plot Individually",uvalue = 'ascale4')
scaleimage = 4


PMenu = widget_button(menuBar,value="Print",font = info.font2)
PbuttonR = widget_button(Pmenu,value = "Print Histogram plots to an output file ",uvalue='printP')
PbuttonD = widget_button(Pmenu,value = "Print Histogram Data to ascii file ",uvalue='printD')


move_base = widget_base(HistoQuickLook,/row,/align_left)

;_______________________________________________________________________
graphID_master0 = widget_base(HistoQuickLook,row=1)
graphID_master1 = widget_base(HistoQuickLook,row=1)
graphID11 = widget_base(graphID_master0,col=1)
graphID12 = widget_base(graphID_master0,col=1)
graphID21 = widget_base(graphID_master1,col=1)
graphID22 = widget_base(graphID_master1,col=1)


graphID = lonarr(3)
draw_window_id = lonarr(3)
;_______________________________________________________________________
; initialize varibles 
histo_binnum = intarr(3)
histo_binnum[*] = 500
rawmedian = 0
histo_xlabel        = lonarr(3,2) ; plot label 
histo_ylabel        = lonarr(3,2) ; plot label 
histo_xrange        = lonarr(3,2) ; x  plot range
histo_yrange        = lonarr(3,2) ; x  plot range

xrange_default        = lonarr(3,2) ; x  plot range
yrange_default        = lonarr(3,2) ; x  plot range

histo_recomputeID    = lonarr(3,2); button controlling Default scale or User Set Scale
default_scale_histo  = intarr(3,2) ; scaling min and max display ranges 

histo_xrange[*,*] = 0
histo_yrange[*,*] = 0
histo_binlabel = lonarr(3)
median_labelID = lonarr(3)
default_scale_histo[*] = 1

xsize_label = 7    
plotsizex = 600
plotsizey = 310
plotsizeC = 400
;_______________________________________________________________________
;*****
;graph 1 Histrogram of Image 1
;*****
;titleID = widget_label(graphID11, value = " Histogram: Image 1: " + ftitle1,$
;                       /align_center,font=info.font3)

label1 = widget_base(graphID11, row = 1) 
histo_binlabel[0] = cw_field(label1,title='# of Bins',xsize=4,$
                                         value=histo_binnum[0],font=info.font4,$
                                         uvalue='Bin1',/return_events)

rawmedian = info.compare_image[0].median
median_labelID[0] = widget_label(label1,$
                         value='Median ' + strcompress(string(rawmedian),/remove_all))

graphID[0] = widget_draw(graphID11,$
                         xsize = plotsizex,$
                         ysize = plotsizey,$
                         retain=info.retn)


pix_num_base2 = widget_base(graphID11,row=1)
labelID = widget_label(pix_num_base2,value="X->",font=info.font4)
histo_xlabel[0,0] = cw_field(pix_num_base2,title="min:",font=info.font4, $
                                        uvalue="hist_1x1",/float,/return_events, $
                                        value=histo_xrange[0,0], $
                                        xsize=xsize_label,fieldfont=info.font4)

histo_xlabel[0,1] = cw_field(pix_num_base2,title="max:",font=info.font4, $
                                        uvalue="hist_1x2",/float,/return_events, $
                                        value=histo_xrange[0,1],xsize=xsize_label,$
                                        fieldfont=info.font4)

histo_recomputeID[0,0] = widget_button(pix_num_base2,value=' Plot Range ',$
                                               font=info.font4,$
                                               uvalue = 'hdx1',/dynamic_resize)


pix_num_base3 = pix_num_base2

labelID = widget_label(pix_num_base3,value="Y->",font=info.font4)
histo_ylabel[0,0] = cw_field(pix_num_base3,title="min:",font=info.font4, $
                                        uvalue="hist_1y1",/float,/return_events, $
                                        value=histo_yrange[0,0],xsize=xsize_label,$
                                        fieldfont=info.font4)

histo_ylabel[0,1] = cw_field(pix_num_base3,title="max:",font=info.font4, $
                                        uvalue="hist_1y2",/float,/return_events, $
                                        value=histo_yrange[0,1],xsize=xsize_label,$
                                        fieldfont=info.font4)

histo_recomputeID[0,1] = widget_button(pix_num_base3,value=' Plot Range ',$
                                               font=info.font4,$
                                               uvalue = 'hdy1',/dynamic_resize)

;_______________________________________________________________________
;*****
;graph 2 Histrogram of Image
;*****
;titleID = widget_label(graphID12, value = " Histogram:  Image  2: " + ftitle2,$
;                       /align_center,font=info.font3)

label2 = widget_base(graphID12, row = 1) 
histo_binlabel[1] = cw_field(label2,title='# of Bins',xsize=4,$
                                         value=histo_binnum[1],font=info.font4,$
                                         uvalue='Bin2',/return_events)
rawmedian = info.compare_image[1].median
median_labelID[1] = widget_label(label2,$
                         value='Median ' + strtrim(string(rawmedian),2),font=info.font3)

graphID[1] = widget_draw(graphID12,$
                         xsize = plotsizex,$
                         ysize = plotsizey,$
                         retain=info.retn)


pix_num_base2 = widget_base(graphID12,row=1)
labelID = widget_label(pix_num_base2,value="X->",font=info.font4)
histo_xlabel[1,0] = cw_field(pix_num_base2,title="min:",font=info.font4, $
                                        uvalue="hist_2x1",/float,/return_events, $
                                        value=histo_xrange[1,0], $
                                        xsize=xsize_label,fieldfont=info.font4)

histo_xlabel[1,1] = cw_field(pix_num_base2,title="max:",font=info.font4, $
                                        uvalue="hist_2x2",/float,/return_events, $
                                        value=histo_xrange[1,1],xsize=xsize_label,$
                                        fieldfont=info.font4)

histo_recomputeID[1,0] = widget_button(pix_num_base2,value=' Plot Range ',$
                                               font=info.font4,$
                                               uvalue = 'hdx2',/dynamic_resize)


pix_num_base3 = pix_num_base2

labelID = widget_label(pix_num_base3,value="Y->",font=info.font4)
histo_ylabel[1,0] = cw_field(pix_num_base3,title="min:",font=info.font4, $
                                        uvalue="hist_2y1",/float,/return_events, $
                                        value=histo_yrange[1,0],xsize=xsize_label,$
                                        fieldfont=info.font4)

histo_ylabel[1,1] = cw_field(pix_num_base3,title="max:",font=info.font4, $
                                        uvalue="hist_2y2",/float,/return_events, $
                                        value=histo_yrange[1,1],xsize=xsize_label,$
                                        fieldfont=info.font4)

histo_recomputeID[1,1] = widget_button(pix_num_base3,value=' Plot Range',$
                                               font=info.font4,$
                                               uvalue = 'hdy2',/dynamic_resize)

;_______________________________________________________________________
;*****
;graph 2 Histrogram of Image 3 
;*****

label3 = widget_base(graphID21, row = 1) 
histo_binlabel[2] = cw_field(label3,title='# of Bins',xsize=4,$
                                         value=histo_binnum[2],font=info.font4,$
                                         uvalue='Bin3',/return_events)
rawmedian = info.compare_image[2].median
median_labelID[2] = widget_label(label3,$
                         value='Median ' + strtrim(string(rawmedian),2),font=info.font3)

graphID[2] = widget_draw(graphID21,$
                         xsize = plotsizex,$
                         ysize=plotsizeC,$
                         retain=info.retn)


pix_num_base2 = widget_base(graphID21,row=1)
labelID = widget_label(pix_num_base2,value="X->",font=info.font4)
histo_xlabel[2,0] = cw_field(pix_num_base2,title="min:",font=info.font4, $
                                        uvalue="hist_3x1",/float,/return_events, $
                                        value=histo_xrange[2,0], $
                                        xsize=xsize_label,fieldfont=info.font4)

histo_xlabel[2,1] = cw_field(pix_num_base2,title="max:",font=info.font4, $
                                        uvalue="hist_3x2",/float,/return_events, $
                                        value=histo_xrange[2,1],xsize=xsize_label,$
                                        fieldfont=info.font4)

histo_recomputeID[2,0] = widget_button(pix_num_base2,value=' Plot Range ',$
                                               font=info.font4,$
                                               uvalue = 'hdx3',/dynamic_resize)


pix_num_base3 = pix_num_base2

labelID = widget_label(pix_num_base3,value="Y->",font=info.font4)
histo_ylabel[2,0] = cw_field(pix_num_base3,title="min:",font=info.font4, $
                                        uvalue="hist_3y1",/float,/return_events, $
                                        value=histo_yrange[2,0],xsize=xsize_label,$
                                        fieldfont=info.font4)

histo_ylabel[2,1] = cw_field(pix_num_base3,title="max:",font=info.font4, $
                                        uvalue="hist_3y2",/float,/return_events, $
                                        value=histo_yrange[2,1],xsize=xsize_label,$
                                        fieldfont=info.font4)

histo_recomputeID[2,1] = widget_button(pix_num_base3,value='Plot Range ',$
                                               font=info.font4,$
                                               uvalue = 'hdy3',/dynamic_resize)


;______________________________________________________________________
; 
label = widget_label(graphID22,value = ' Statistics on Images',font=info.font5,/sunken_frame,/align_left)
	

image_median = strcompress(string(info.compare_image[0].median),/remove_all)
image_mean = strcompress(string(info.compare_image[0].mean),/remove_all)
image_stdev = strcompress(string(info.compare_image[0].stdev),/remove_all)
image_min = strcompress(string(info.compare_image[0].min),/remove_all)
image_max = strcompress(string(info.compare_image[0].max),/remove_all)


Image1_label1 = 'Image 1:  Median: ' + image_median + '  Mean: ' + image_mean + '  Standard Dev: ' + image_stdev
Image1_label2 = '          Min:  ' + image_min + ' Max: ' + image_max 
label1 = widget_label(graphID22,value = image1_label1,font=info.font5)
label2 = widget_label(graphID22,value = image1_label2,font=info.font5)

image_median = strcompress(string(info.compare_image[1].median),/remove_all)
image_mean = strcompress(string(info.compare_image[1].mean),/remove_all)
image_stdev = strcompress(string(info.compare_image[1].stdev),/remove_all)
image_min = strcompress(string(info.compare_image[1].min),/remove_all)
image_max = strcompress(string(info.compare_image[1].max),/remove_all)

Image_label = widget_label(graphID22,value = ' ' )

Image1_label1 = 'Image 2:  Median: ' + image_median + '  Mean: ' + image_mean + '  Standard Dev: ' + image_stdev
Image1_label2 = '          Min:  ' + image_min + ' Max: ' + image_max 
label1 = widget_label(graphID22,value = image1_label1,font=info.font5)
label2 = widget_label(graphID22,value = image1_label2,font=info.font5)

image_median = strcompress(string(info.compare_image[2].median),/remove_all)
image_mean = strcompress(string(info.compare_image[2].mean),/remove_all)
image_stdev = strcompress(string(info.compare_image[2].stdev),/remove_all)
image_min = strcompress(string(info.compare_image[2].min),/remove_all)
image_max = strcompress(string(info.compare_image[2].max),/remove_all)

Image_label = widget_label(graphID22,value = ' ' )
Image1_label1 = 'Image 3:  Median: ' + image_median + '  Mean: ' + image_mean + '  Standard Dev: ' + image_stdev
Image1_label2 = '          Min:  ' + image_min + ' Max: ' + image_max 
label1 = widget_label(graphID22,value = image1_label1,font=info.font5)
label2 = widget_label(graphID22,value = image1_label2,font=info.font5)

;______________________________________________________________________
longline  = '                                                                              '
label = widget_label(graphID_master1,value = longline)
;______________________________________________________________________

;Set up the GUI
Widget_control,HistoQuickLook,/Realize

XManager,'Cphisto',HistoQuickLook,/No_Block,event_handler='mql_compare_histo_event'


for i = 0, 2 do begin
    widget_control,graphID[i],get_value=tdraw_id
    draw_window_id[i] = tdraw_id
endfor

sint = strtrim( string (fix(info.compare_image[0].jintegration+1)),2)
sframe1 = strtrim( string(fix(info.compare_image[0].iramp+1)),2) 
sframe2 = strtrim( string(fix(info.compare_image[1].iramp+1)),2)

ij = 'int' + sint + '_frame_' + sframe1 + '_' + sframe2  
ij = strcompress(ij,/remove_all)

outname = 'histo_compare' + ij + '_' 


type  = 1

Widget_Control,info.QuickLook,Set_UValue=info
hinfo = {info                : info,$
         histo_binnum   :  histo_binnum,$
         histo_binlabel      : histo_binlabel,$
         median_labelID      : median_labelID,$
         histo_recomputeID   : histo_recomputeID,$
         histo_xlabel        : histo_xlabel,$
         histo_ylabel        : histo_ylabel,$
         histo_xrange        : histo_xrange,$
         histo_yrange        : histo_yrange,$
         xrange_default      : xrange_default,$
         yrange_default      : yrange_default,$
         graphID             : graphID,$
         ftitle              : ftitle,$
         outname             : outname,$
         type                : type,$
         scaleimage          : scaleimage,$
         draw_window_id      : draw_window_id,$
         default_scale_histo : default_scale_histo}






info.HistoCompareQuickLook = HistoQuickLook
Widget_Control,info.HistoCompareQuickLook,Set_UValue=hinfo
Widget_Control,info.QuickLook,Set_UValue=info
for i = 0,2 do begin
    imageno = i
    mql_update_Compare_histo,imageno,hinfo
endfor
Widget_Control,info.HistoCompareQuickLook,Set_UValue=hinfo





Widget_Control,info.QuickLook,Set_UValue=info

end
