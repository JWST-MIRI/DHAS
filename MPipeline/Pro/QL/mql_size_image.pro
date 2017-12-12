
pro mql_size_image,igraphnum,itype,info
ij = igraphnum -1
ij = igraphnum 
widget_control,info.image.image_recomputeID[ij],/DESTROY
widget_control,info.image.rlabelID[ij,0],/DESTROY
widget_control,info.image.rlabelID[ij,1],/DESTROY
widget_control,info.image.graphid[ij],/DESTROY



; type 0 =  scaled full image
; type 1 = unscaled full image - through scroll bar 
;_______________________________________________________________________
if(ij eq 0) then begin ; raw image
    sc = "scale1"
    sr1 = "sr1_b"
    sr2 = "sr1_t"
    mp = "mqlpixel1"
; default back to orginal plotting 
    if(itype eq 0) then begin 
        xdsize = info.image.xplot_size
        ydsize = info.image.yplot_size
    endif
    if(itype eq 1) then begin
        xdsize = info.data.image_xsize
        ydsize = info.data.image_ysize
    endif
endif
    

;if(ij eq 2) then begin ; reference image
;    sc = "scale3"
;    sr1 = "sr3_b"
;    sr2 = "sr3_t"
;    mp = "mqlpixel3"
;    if(itype eq 0) then begin
;        xdsize = info.data.ref_xsize/info.image.scale[2,0]
;        ydsize = info.data.ref_ysize/info.image.scale[2,1]
;    endif
;    if(itype eq 1) then begin
;        xdsize = info.data.ref_xsize
;        ydsize = info.data.ref_ysize
;    endif
;endif    


if(ij eq 2) then begin ; slope image
    sc = "scale3"
    sr1 = "sr3_b"
    sr2 = "sr3_t"
    mp = "mqlpixel3"
    
    if(itype eq 0) then begin
        xdsize = info.image.xplot_size
        ydsize = info.image.yplot_size
    endif
    if(itype eq 1) then begin 
        xdsize = info.data.slope_xsize
        ydsize = info.data.slope_ysize
    endif
endif
;_______________________________________________________________________
if(itype eq 0) then begin ; plot binned image
    
    info.image.graphID[ij] = widget_draw(info.image.plot_base[ij],$
                                         xsize =xdsize,$
                                         ysize =ydsize,$
                                         /Button_Events,$
                                         retain=info.retn,uvalue=mp)
endif

; plot the full unbinned image
if(itype eq 1) then begin
    info.image.graphID[ij] = widget_draw(info.image.plot_base[ij],$
                                         xsize = xdsize,$
                                         ysize= ydsize,$
                                         x_scroll_size=info.plotsize1,$ 
                                         y_scroll_size= info.plotsize1,$
                                         /scroll,/Button_Events,$
                                         retain=retn,uvalue=mp)
endif



;_______________________________________________________________________

info.image.image_recomputeID[ij] = widget_button(info.image.srange_base[ij],value='Default Scale',$
                                                font=info.font4,$
                                                uvalue = sc)

info.image.rlabelID[ij,0] = cw_field(info.image.srange_base[ij],title="min",font=info.font4,$
                                    uvalue=sr1,/float,/return_events,$
                                    xsize=info.xsize_label,value =0,$
                                    fieldfont = info.font4)

info.image.rlabelID[ij,1] = cw_field(info.image.srange_base[ij],title="max",font=info.font4,$
                                    uvalue=sr2,/float,/return_events,$
                                    xsize = info.xsize_label,value =0,$
                                   fieldfont=info.font4)
;_______________________________________________________________________

;_______________________________________________________________________
widget_control,info.image.graphID[ij],get_value=tdraw_id
info.image.draw_window_id[ij] = tdraw_id
window,/pixmap,xsize=xdsize,ysize=ydsize,/free
info.image.pixmapID[ij] = !D.WINDOW

end
