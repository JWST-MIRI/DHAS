;______________________________________________________________________
pro jwst_amplifier_histo_quit,event

widget_control,event.top, Get_UValue = hinfo	
widget_control,hinfo.info.jwst_QuickLook,Get_Uvalue = info
widget_control,info.jwst_AmpHistoDisplay,/destroy
end
;_______________________________________________________________________

; the event manager for the ql.pro (main base widget)
pro jwst_amplifier_histo_event,event

Widget_Control,event.id,Get_uValue=event_name
widget_control,event.top, Get_UValue = hinfo
widget_control,hinfo.info.jwst_Quicklook,Get_Uvalue = minfo

hinfo.info = minfo

if (widget_info(event.id,/TLB_SIZE_EVENTS) eq 1 ) then begin
    minfo.amplifier_histo.xwindowsize = event.x
    minfo.amplifier_histo.ywindowsize = event.y
    minfo.amplifier_histo.uwindowsize = 1
    widget_control,event.top,set_uvalue = hinfo
    widget_control,hinfo.info.jwst_Quicklook,set_uvalue = minfo
    jwst_display_amplifier_histo,minfo
    return
endif

case 1 of
    (strmid(event_name,0,3) EQ 'Bin') : begin
        graphno = fix(strmid(event_name,3,1))-1
        hinfo.histo_binnum[graphno] = event.value
        jwst_update_amplifier_histo,graphno,hinfo
    end

    (strmid(event_name,0,6) EQ 'printP') : begin
        jwst_print_amplifier_histo,hinfo
    end    

    (strmid(event_name,0,6) EQ 'printD') : begin
        jwst_print_amplifier_histo_data,hinfo
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
        if(hinfo.scalechannel-1 eq 5) then begin
            if(strmid(event_name,6,1) EQ 'x') then begin
                hinfo.histo_xrange[k,p] = event.value
                widget_control,hinfo.histo_xlabel[k,pp],get_value = temp
                hinfo.histo_xrange[k,pp] = temp
                hinfo.default_scale_histo[k,0] = 0
                widget_control,hinfo.histo_recomputeID[k,0],set_value=' Default'
            endif

            if(strmid(event_name,6,1) EQ 'y') then begin
                hinfo.histo_yrange[k,p] = event.value
                widget_control,hinfo.histo_ylabel[k,pp],get_value = temp
                hinfo.histo_yrange[k,pp] = temp
                hinfo.default_scale_histo[k,1] = 0
                widget_control,hinfo.histo_recomputeID[k,1],set_value=' Default'
            endif

            jwst_update_amplifier_histo,k,hinfo
        endif

        if(hinfo.scalechannel-1 ne 5) then begin
            index = hinfo.scalechannel-1
            if(k eq index)then begin
                if(strmid(event_name,6,1) EQ 'x') then begin
                    hinfo.histo_xrange[k,p] = event.value
                    widget_control,hinfo.histo_xlabel[k,pp],get_value = temp
                    hinfo.histo_xrange[k,pp] = temp
                    hinfo.default_scale_histo[k,0] = 0
                    widget_control,hinfo.histo_recomputeID[k,0],set_value=' Default '
                endif

                if(strmid(event_name,6,1) EQ 'y') then begin
                    hinfo.histo_yrange[k,p] = event.value
                    widget_control,hinfo.histo_ylabel[k,pp],get_value = temp
                    hinfo.histo_yrange[k,pp] = temp
                    hinfo.default_scale_histo[k,1] = 0
                    widget_control,hinfo.histo_recomputeID[k,1],set_value=' Default '
                endif

                jwst_update_amplifier_histo,k,hinfo
            endif

            for i = 0,4 do begin
                hinfo.histo_xrange[i,*] = hinfo.histo_xrange[index,*]
                hinfo.histo_yrange[i,*] = hinfo.histo_yrange[index,*]
                hinfo.default_scale_histo[i,*] = hinfo.default_scale_histo[index,*]

                hinfo.info = minfo
                widget_control,event.top,set_uvalue = hinfo
                widget_control,hinfo.info.Quicklook,set_uvalue = minfo
               jwst_update_amplifier_histo,i,hinfo
            endfor
        endif
    end
;_______________________________________________________________________
; set the Default range or user defined range for  histogram plot
;_______________________________________________________________________
 (strmid(event_name,0,2) EQ 'hd') : begin
        if(strmid(event_name,2,1) EQ 'x') then xy = 0 else xy = 1
        graphno = fix(strmid(event_name,3,1))-1

        if(hinfo.scalechannel-1 eq 5) then begin
            widget_control,hinfo.histo_recomputeID[graphno,xy],set_value=' Plot Range'
            hinfo.default_scale_histo[graphno,xy] = 1
            jwst_update_amplifier_histo,graphno,hinfo

        endif else begin
            if(graphno eq hinfo.scalechannel -1) then begin
                widget_control,hinfo.histo_recomputeID[graphno,xy],set_value=' Plot Range '
                hinfo.default_scale_histo[graphno,xy] = 1
                for i = 0,4 do begin
                    jwst_update_amplifier_histo,i,hinfo
                endfor
            endif
        endelse
    end
;_______________________________________________________________________
    (strmid(event_name,0,6) EQ 'ascale') : begin
        hinfo.scalechannel = event.index+1
        for i = 0,4 do begin
            if(hinfo.scalechannel-1 eq 5) then begin
                widget_control,hinfo.histo_recomputeID[i,0],set_value=' Plot Range '
                hinfo.default_scale_histo[i,0] = 1
                widget_control,hinfo.histo_recomputeID[i,1],set_value=' Plot Range '
                hinfo.default_scale_histo[i,1] = 1
            endif

            if(hinfo.scalechannel-1 eq i) then begin
                widget_control,hinfo.histo_recomputeID[i,0],set_value=' Plot Range '
                hinfo.default_scale_histo[i,0] = 1
                widget_control,hinfo.histo_recomputeID[i,1],set_value=' Plot Range '
                hinfo.default_scale_histo[i,1] = 1
            endif

        endfor
        ; only call if scaling to a particular channel
        if(hinfo.scalechannel-1 ne 5) then  mql_update_amplifier_histo,hinfo.scalechannel-1,hinfo
        
	for i = 0, 4 do begin 
            jwst_update_amplifier_histo,i,hinfo
        endfor
    end
;_______________________________________________________________________
; Display statistics on the image 
;_______________________________________________________________________
    (strmid(event_name,0,4) EQ 'stat') : begin
	jwst_display_amplifier_stat,minfo
    end

else: print," Event name not found",event_name
endcase

hinfo.info = minfo
widget_control,event.top,set_uvalue = hinfo
widget_control,hinfo.info.jwst_Quicklook,set_uvalue = minfo
end

;***********************************************************************
pro jwst_update_amplifier_histo,graphno,hinfo,ps=ps,eps=eps,ascii=ascii,unit=iunit
; info.ChannelR[graphno].psubdata is filled in in mql_grab_Channel_images.pro 

hcopy = 0
if ( (keyword_set(ps)) or ( keyword_set(eps)) ) then hcopy = 1

;jwst_AmpFrame_image = replicate(jwst_cimage,5)
info = hinfo.info
numbins = hinfo.histo_binnum[graphno]
frame_image = (*info.jwst_AmpFrame_image[graphno].psubdata_noref) ; we do not what the reference pixels in histogram

xstart_new = info.jwst_ampframe.xstart_zoom+1
xend_new = info.jwst_ampframe.xend_zoom+1
if(xstart_new eq 1) then xstart_new = 2
if(xend_new eq 258) then xend_new = 257

sxmin = strcompress(string(xstart_new),/remove_all)
sxmax = strcompress(string(xend_new),/remove_all)
symin = strcompress(string(info.jwst_ampframe.ystart_zoom+1),/remove_all)
symax = strcompress(string(info.jwst_ampframe.yend_zoom+1),/remove_all)
sregion = "Plot Region: xrange: " + sxmin + " - " + sxmax + " yrange: " + $
	symin + "  - " + symax 
widget_control,hinfo.rlabel,set_value = sregion

md = info.jwst_AmpFrame_image[graphno].sd_median
smedian = strcompress(string(md),/remove_all) 

index = hinfo.scalechannel -1
if(index eq 5) then index = graphno

sd = info.jwst_AmpFrame_image[index].sd_stdev
md_use = info.jwst_AmpFrame_image[index].sd_median

if(hinfo.default_scale_histo[index,0] eq 0) then begin
    xhistomin = hinfo.histo_xrange[index,0]
    xhistomax = hinfo.histo_xrange[index,1]

    jwst_findhistogram_xlimits,frame_image,xnew,h,numbins,bins,xplot_min,xplot_max,xhistomin,xhistomax,status
endif else begin
    xhistomin = md_use- sd*3
    xhistomax = md_use +sd*3
    if(finite(xhistomin) eq 0) then xhistomin = 0 
    if(finite(xhistomax) eq 0) then xhistomax = 1
    jwst_findhistogram_xlimits,frame_image,xnew,h,numbins,bins,xplot_min,xplot_max,xhistomin,xhistomax,status
endelse

if(hcopy eq 0) then wset,hinfo.draw_window_id[graphno]     
if(index eq graphno ) then begin
    if(hinfo.default_scale_histo[index,1] eq 0) then begin 
        min_value = hinfo.histo_yrange[index,0]
        max_value = hinfo.histo_yrange[index,1]
    endif else begin
        min_value = min(h)
        max_value = max(h)
    endelse
    hinfo.histo_yrange[index,0] = min_value 
    hinfo.histo_yrange[index,1] = max_value

endif

xt = 'Pixel Values'
yt = 'Number of Pixels'

hinfo.histo_xrange[graphno,0] = xplot_min
hinfo.histo_xrange[graphno,1] = xplot_max

hinfo.histo_yrange[graphno,0] = hinfo.histo_yrange[index,0]
hinfo.histo_yrange[graphno,1] = hinfo.histo_yrange[index,1]

x1 = hinfo.histo_xrange[graphno,0]
x2 = hinfo.histo_xrange[graphno,1]
y1 = hinfo.histo_yrange[graphno,0]
y2 = hinfo.histo_yrange[graphno,1]

stitle = ' ' 
stitle = ' Histogram for Amplifier ' + strcompress(string(graphno+1),/remove_all)

plot,xnew,h,psym=10,xtitle= xt,ytitle=yt,$
        yrange = [y1,y2],xrange=[x1,x2],$
        ystyle=1,xstyle = 1,xticks = 3,title = stitle,xtickformat = '(f8.0)'

if(status ne 0) then begin
    ypt = (y2 + y1)/2.0
    xyouts,xplot_min,ypt,'  All Values = ' + string(xplot_min)
endif
widget_control,hinfo.median_labelID[graphno],set_value=('Median ' +smedian) 
widget_control,hinfo.histo_binlabel[graphno],$
               set_value=hinfo.histo_binnum[graphno]
widget_control,hinfo.histo_xlabel[graphno,0],$
               set_value=hinfo.histo_xrange[graphno,0]
widget_control,hinfo.histo_xlabel[graphno,1],$
               set_value=hinfo.histo_xrange[graphno,1]
widget_control,hinfo.histo_ylabel[graphno,0],$
               set_value=hinfo.histo_yrange[graphno,0]
widget_control,hinfo.histo_ylabel[graphno,1],$
               set_value=hinfo.histo_yrange[graphno,1]

index = hinfo.scalechannel -1
scale_name = ['Amp 1','Amp 2','Amp 3', 'Amp 4', 'Amp 5']
if(index ne 5) then begin
    if(index ne graphno) then begin
        widget_control,hinfo.histo_recomputeID[graphno,0],set_value=scale_name[index]
        widget_control,hinfo.histo_recomputeID[graphno,1],set_value=scale_name[index]
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
pro jwst_display_amplifier_histo,info

window,1,/pixmap
wdelete,1
if( XRegistered ('Amphisto')) then begin
   widget_control,info.jwst_AmpHistoDisplay,/destroy
endif

igroup = info.jwst_AmpFrame_image[0].igroup
jintegration = info.jwst_AmpFrame_image[0].jintegration

ftitle = "Integration #: " + strtrim(string(fix(jintegration+1)),2) + $
            "   Frame #: " + strtrim(string(fix(igroup+1)),2)     

sregion = "Plot Region:                                                   "
stitle = "MIRI Quick Look- 5 Amplifier Histogram of Science Frame Image" + info.jwst_version
svalue = " 5 Amplifier Histogram of Scinece Frame Values:  "

; widget window parameters
xwidget_size = 1050
ywidget_size = 950
xsize_scroll = 1000
ysize_scroll = 920

if(info.amplifier_histo.uwindowsize eq 1) then begin ; user has set window size 
    xsize_scroll = info.amplifier_histo.xwindowsize
    ysize_scroll = info.amplifier_histo.ywindowsize
endif

if(info.jwst_control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.jwst_control.x_scroll_window
if(info.jwst_control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.jwst_control.y_scroll_window
if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10


HistoQuickLook = widget_base(title=stitle ,$
                             col = 1,mbar = menuBar,$
                             group_leader = info.jwst_quicklook,$
                             xsize = xwidget_size,$
                             ysize = ywidget_size,/scroll,$
                             x_scroll_size= xsize_scroll,$
                             y_scroll_size = ysize_scroll,/TLB_SIZE_EVENTS)


QuitMenu = widget_button(menuBar,value="Quit",font = info.font2)
; add quit button
quitbutton = widget_button(quitmenu,value="Quit",event_pro='jwst_amplifier_histo_quit')


;PMenu = widget_button(menuBar,value="Print",font = info.font2)
;PbuttonR = widget_button(Pmenu,value = "Print Histogram plots to an output file ",uvalue='printP')
;PbuttonD = widget_button(Pmenu,value = "Print Histogram Data to ascii file ",uvalue='printD')

title_base = widget_base(HistoQuickLook,col=3,/align_left)
tlabelID = widget_label(title_base,value =svalue,font=info.font5)
titlelabel = widget_label(title_base,value = info.jwst_control.filename_raw, font=info.font3)

blankspaces  = '                '
move_base = widget_base(HistoQuickLook,/row,/align_left)
moveframe_label = widget_button(move_base,value='Get Statistics',uvalue='stat',font=info.font5)

scalechannel = 1
scaledisplay = ['Scale All to Amplifier 1', 'Scale All to Amplifier 2', $
                'Scale All to Amplifier 3', 'Scale All to Amplifier 4', $
                'Scale All to Amplifier 5', 'Scale to Individual Amplifier']

scale_label  = widget_droplist(move_base,value=scaledisplay,uvalue='ascale',font= info.font5)

blanklabel = widget_label(move_base, value= blankspaces)
framelabel = widget_label(move_base, value=ftitle, font=info.font3)
blanklabel = widget_label(move_base, value= blankspaces)
rlabel = widget_label(move_base, value=sregion, font=info.font3)
;_______________________________________________________________________
graphID_master0 = widget_base(HistoQuickLook,row=1)
graphID_master1 = widget_base(HistoQuickLook,row=1)

graphID11 = widget_base(graphID_master0,col=1)
graphID12 = widget_base(graphID_master0,col=1)
graphID13 = widget_base(graphID_master0,col=1)

graphID21 = widget_base(graphID_master1,col=1)
graphID22 = widget_base(graphID_master1,col=1)
graphID23 = widget_base(graphID_master1,col=1)

graphID = lonarr(5)
draw_window_id = lonarr(5)
;_______________________________________________________________________
; initialize varibles 
histo_binnum = intarr(5)
histo_binnum[*] = 500
rawmedian = 0
histo_xlabel        = lonarr(5,2) ; plot label 
histo_ylabel        = lonarr(5,2) ; plot label 
histo_xrange        = lonarr(5,2) ; x  plot range
histo_yrange        = lonarr(5,2) ; x  plot range

histo_recomputeID    = lonarr(5,2); button controlling Default scale or User Set Scale
default_scale_histo  = intarr(5,2) ; scaling min and max display ranges 

histo_xrange[*,*] = 0
histo_yrange[*,*] = 0
histo_binlabel = lonarr(5)
median_labelID = lonarr(5)
default_scale_histo[*] = 1

xsize_label = 9    
;_______________________________________________________________________
;*****
;graph 1 Histrogram of Amplifier 1 
;*****
titleID = widget_label(graphID11, value = " Histogram: Amplifier 1 ",$
                       /align_center,font=info.font3)

label1 = widget_base(graphID11, row = 1) 
histo_binlabel[0] = cw_field(label1,title='# of Bins',xsize=4,$
                                         value=histo_binnum[0],font=info.font4,$
                                         uvalue='Bin1',/return_events)

rawmedian = info.jwst_AmpFrame_image[0].median
median_labelID[0] = widget_label(label1,$
                         value='Median ' + strcompress(string(rawmedian),/remove_all))

graphID[0] = widget_draw(graphID11,$
                         xsize = info.jwst_plotsize1*1.25,$
                         ysize = info.jwst_plotsize1,$
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
                                               uvalue = 'hdx1')

pix_num_base3 = widget_base(graphID11,row=1)

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
                                               uvalue = 'hdy1')
;_______________________________________________________________________
;*****
;graph 2 Histrogram of Amplifier 2 
;****y
titleID = widget_label(graphID12, value = " Histogram: Amplifier 2 ",$
                       /align_center,font=info.font3)

label2 = widget_base(graphID12, row = 1) 
histo_binlabel[1] = cw_field(label2,title='# of Bins',xsize=4,$
                                         value=histo_binnum[1],font=info.font4,$
                                         uvalue='Bin2',/return_events)
rawmedian = info.jwst_AmpFrame_image[1].median
median_labelID[1] = widget_label(label2,$
                         value='Median ' + strtrim(string(rawmedian),2),font=info.font3)

graphID[1] = widget_draw(graphID12,$
                         xsize = info.jwst_plotsize1*1.25,$
                         ysize=info.jwst_plotsize1,$
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
                                               uvalue = 'hdx2')

pix_num_base3 = widget_base(graphID12,row=1)

labelID = widget_label(pix_num_base3,value="Y->",font=info.font4)
histo_ylabel[1,0] = cw_field(pix_num_base3,title="min:",font=info.font4, $
                                        uvalue="hist_2y1",/float,/return_events, $
                                        value=histo_yrange[1,0],xsize=xsize_label,$
                                        fieldfont=info.font4)

histo_ylabel[1,1] = cw_field(pix_num_base3,title="max:",font=info.font4, $
                                        uvalue="hist_2y2",/float,/return_events, $
                                        value=histo_yrange[1,1],xsize=xsize_label,$
                                        fieldfont=info.font4)

histo_recomputeID[1,1] = widget_button(pix_num_base3,value=' Plot Range ',$
                                               font=info.font4,$
                                               uvalue = 'hdy2')
;_______________________________________________________________________
;*****
;graph 2 Histrogram of Amplifier 3 
;*****
titleID = widget_label(graphID13, value = " Histogram: Channel 3 ",$
                       /align_center,font=info.font3)

label3 = widget_base(graphID13, row = 1) 
histo_binlabel[2] = cw_field(label3,title='# of Bins',xsize=4,$
                                         value=histo_binnum[2],font=info.font4,$
                                         uvalue='Bin3',/return_events)
rawmedian = info.jwst_AmpFrame_image[2].median
median_labelID[2] = widget_label(label3,$
                         value='Median ' + strtrim(string(rawmedian),2),font=info.font3)

graphID[2] = widget_draw(graphID13,$
                         xsize = info.jwst_plotsize1*1.25,$
                         ysize=info.jwst_plotsize1,$
                         retain=info.retn)

pix_num_base2 = widget_base(graphID13,row=1)
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
                                               uvalue = 'hdx3')
pix_num_base3 = widget_base(graphID13,row=1)

labelID = widget_label(pix_num_base3,value="Y->",font=info.font4)
histo_ylabel[2,0] = cw_field(pix_num_base3,title="min:",font=info.font4, $
                                        uvalue="hist_3y1",/float,/return_events, $
                                        value=histo_yrange[2,0],xsize=xsize_label,$
                                        fieldfont=info.font4)

histo_ylabel[2,1] = cw_field(pix_num_base3,title="max:",font=info.font4, $
                                        uvalue="hist_3y2",/float,/return_events, $
                                        value=histo_yrange[2,1],xsize=xsize_label,$
                                        fieldfont=info.font4)

histo_recomputeID[2,1] = widget_button(pix_num_base3,value=' Plot Range ',$
                                               font=info.font4,$
                                               uvalue = 'hdy3')
;_______________________________________________________________________
;*****
;graph 3 Histrogram of Amplifier 4 
;*****
titleID = widget_label(graphID21, value = " Histogram:  Amplifier 4 ",$
                       /align_center,font=info.font3)

label4 = widget_base(graphID21, row = 1) 
histo_binlabel[3] = cw_field(label4,title='# of Bins',xsize=4,$
                                         value=histo_binnum[3],font=info.font4,$
                                         uvalue='Bin4',/return_events)
rawmedian = info.jwst_AmpFrame_image[3].median
median_labelID[3] = widget_label(label4,$
                         value='Median ' + strtrim(string(rawmedian),2),font=info.font3)

graphID[3] = widget_draw(graphID21,$
                         xsize = info.jwst_plotsize1*1.25,$
                         ysize=info.jwst_plotsize1,$
                         retain=info.retn)

pix_num_base2 = widget_base(graphID21,row=1)
labelID = widget_label(pix_num_base2,value="X->",font=info.font4)
histo_xlabel[3,0] = cw_field(pix_num_base2,title="min:",font=info.font4, $
                                        uvalue="hist_4x1",/float,/return_events, $
                                        value=histo_xrange[3,0], $
                                        xsize=xsize_label,fieldfont=info.font4)

histo_xlabel[3,1] = cw_field(pix_num_base2,title="max:",font=info.font4, $
                                        uvalue="hist_4x2",/float,/return_events, $
                                        value=histo_xrange[3,1],xsize=xsize_label,$
                                        fieldfont=info.font4)

histo_recomputeID[3,0] = widget_button(pix_num_base2,value=' Plot Range ',$
                                               font=info.font4,$
                                               uvalue = 'hdx4')

pix_num_base3 = widget_base(graphID21,row=1)

labelID = widget_label(pix_num_base3,value="Y->",font=info.font4)
histo_ylabel[3,0] = cw_field(pix_num_base3,title="min:",font=info.font4, $
                                        uvalue="hist_4y1",/float,/return_events, $
                                        value=histo_yrange[3,0],xsize=xsize_label,$
                                        fieldfont=info.font4)

histo_ylabel[3,1] = cw_field(pix_num_base3,title="max:",font=info.font4, $
                                        uvalue="hist_4y2",/float,/return_events, $
                                        value=histo_yrange[3,1],xsize=xsize_label,$
                                        fieldfont=info.font4)

histo_recomputeID[3,1] = widget_button(pix_num_base3,value=' Plot Range ',$
                                               font=info.font4,$
                                               uvalue = 'hdy4')
;_______________________________________________________________________
;*****
;graph 5 Histrogram of Amplifier 5 - Reference Image
;*****
titleID = widget_label(graphID22, value = " Histogram: Amplifier 5 ",$
                       /align_center,font=info.font3)

label5 = widget_base(graphID22, row = 1) 
histo_binlabel[4] = cw_field(label5,title='# of Bins',xsize=4,$
                                         value=histo_binnum[4],font=info.font4,$
                                         uvalue='Bin5',/return_events)
rawmedian = info.jwst_AmpFrame_image[4].median
median_labelID[4] = widget_label(label5,$
                         value='Median ' + strtrim(string(rawmedian),2),font=info.font3)

graphID[4] = widget_draw(graphID22,$
                         xsize = info.jwst_plotsize1*1.25,$
                         ysize=info.jwst_plotsize1,$
                         retain=info.retn)

pix_num_base2 = widget_base(graphID22,row=1)
labelID = widget_label(pix_num_base2,value="X->",font=info.font4)
histo_xlabel[4,0] = cw_field(pix_num_base2,title="min:",font=info.font4, $
                                        uvalue="hist_5x1",/float,/return_events, $
                                        value=histo_xrange[4,0], $
                                        xsize=xsize_label,fieldfont=info.font4)

histo_xlabel[4,1] = cw_field(pix_num_base2,title="max:",font=info.font4, $
                                        uvalue="hist_5x2",/float,/return_events, $
                                        value=histo_xrange[4,1],xsize=xsize_label,$
                                        fieldfont=info.font4)

histo_recomputeID[4,0] = widget_button(pix_num_base2,value=' Plot Range ',$
                                               font=info.font4,$
                                               uvalue = 'hdx5')

pix_num_base3 = widget_base(graphID22,row=1)

labelID = widget_label(pix_num_base3,value="Y->",font=info.font4)
histo_ylabel[4,0] = cw_field(pix_num_base3,title="min:",font=info.font4, $
                                        uvalue="hist_5y1",/float,/return_events, $
                                        value=histo_yrange[1,0],xsize=xsize_label,$
                                        fieldfont=info.font4)

histo_ylabel[4,1] = cw_field(pix_num_base3,title="max:",font=info.font4, $
                                        uvalue="hist_5y2",/float,/return_events, $
                                        value=histo_yrange[1,1],xsize=xsize_label,$
                                        fieldfont=info.font4)

histo_recomputeID[4,1] = widget_button(pix_num_base3,value=' Plot Range ',$
                                               font=info.font4,$
                                       uvalue = 'hdy5')

longline  = '                                                                              '
label = widget_label(graphID_master1,value = longline)
;______________________________________________________________________

;Set up the GUI
Widget_control,HistoQuickLook,/Realize
XManager,'Amphisto',HistoQuickLook,/No_Block,event_handler='jwst_amplifier_histo_event'

for i = 0, 4 do begin
    widget_control,graphID[i],get_value=tdraw_id
    draw_window_id[i] = tdraw_id
endfor

ij = 'int' + string(fix(jintegration+1)) + '_frame' + string(fix(igroup+1))  
ij = strcompress(ij,/remove_all)

outname = info.jwst_output.histoAmp  + ij + '_'

type  = 1
Widget_Control,info.jwst_QuickLook,Set_UValue=info
hinfo = {info                : info,$
         histo_binnum        :  histo_binnum,$
         histo_binlabel      : histo_binlabel,$
         rlabel              : rlabel,$
         median_labelID      : median_labelID,$
         histo_recomputeID   : histo_recomputeID,$
         histo_xlabel        : histo_xlabel,$
         histo_ylabel        : histo_ylabel,$
         histo_xrange        : histo_xrange,$
         histo_yrange        : histo_yrange,$
         graphID             : graphID,$
         outname             : outname,$
         type                : type,$
         scalechannel        : scalechannel,$
         draw_window_id      : draw_window_id,$
         default_scale_histo : default_scale_histo}

for i = 0,4 do begin
    graphno = i
    jwst_update_amplifier_histo,graphno,hinfo
 endfor
info.jwst_AmpHistoDisplay = HistoQuicklook
Widget_Control,info.jwst_AmpHistoDisplay,Set_UValue=hinfo
Widget_Control,info.jwst_QuickLook,Set_UValue=info

end
