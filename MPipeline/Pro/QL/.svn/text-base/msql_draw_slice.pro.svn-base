pro msql_draw_slice,typeplot,typeslice,showline,value1,value2,info

; typeplot: which window 1,2,3
; typeslice: 0 column slice, 1 row slice

if(not XRegistered ('msql')) then begin
    Print,' Main Display Widget does not exist'
    return
endif
ij = typeplot-1


wset,info.slope.draw_window_id[ij]
xsize_image = fix(info.data.slope_xsize/info.slope.binfactor) 
ysize_image = fix(info.data.slope_ysize/info.slope.binfactor)

device,copy=[0,0,xsize_image,ysize_image,0,0,info.slope.pixmapID[ij]]



zwindow = info.slope.zoom_window

if(zwindow eq typeplot) then begin 
    wset,info.slope.draw_window_id[1]
    zoom = info.slope.scale_zoom
    device,copy=[0,0,$
                 info.plotsize1*zoom,$
                 info.plotsize1*zoom, $
                 0,0,info.slope.pixmapID[1]]
endif

if(typeslice eq 0 and  showline eq 1) then begin
    wset,info.slope.draw_window_id[ij]
    save_color = info.col_table
    color6
    n_reads = info.plotsize1
    if(ij eq 0 ) then n_reads = info.data.slope_ysize
    if(ij eq 1 ) then n_reads = info.data.slope_ysize
    if(ij eq 2 ) then n_reads = info.data.slope_ysize
    yvalues = indgen(n_reads) + 1
    xvalues  = fltarr(n_reads) +value1
    xvalues2  = fltarr(n_reads) +value2
    if(ij eq 1) then begin
        xvalues = xvalues - info.slope.y_zoom_start/info.slope.scale_zoom
        xvalues2 = xvalues2 - info.slope.y_zoom_start/info.slope.scale_zoom
    endif

    plots,xvalues,yvalues,/device,color=info.white,linestyle=2
    plots,xvalues2,yvalues,/device,color=info.white,linestyle=2

    if(zwindow eq typeplot) then begin
        wset,info.slope.draw_window_id[1] 
        n_reads =  info.plotsize1
        yvalues = indgen(n_reads) + 1
        pos1 =(value1*info.slope.binfactor )-info.slope.xstart_zoom
        pos2 =(value2*info.slope.binfactor )-info.slope.xstart_zoom

        
        pos1 = pos1*zoom +info.slope.ixstart_zoom*zoom
        pos2 = pos2*zoom +info.slope.ixstart_zoom*zoom


        xvalues  = fltarr(n_reads) +pos1
        xvalues2  = fltarr(n_reads) +pos2

        plots,xvalues,yvalues,/device,color=info.white,linestyle=2
        plots,xvalues2,yvalues,/device,color=info.white,linestyle=2
    endif
    info.col_table = save_color
endif

if(typeslice eq 1 and showline eq 1) then begin
    save_color = info.col_table
    color6
    wset,info.slope.draw_window_id[ij]
    n_reads = info.plotsize1
    if(ij eq 0 ) then n_reads = info.data.slope_xsize
    if(ij eq 1 ) then n_reads = info.data.slope_xsize
    if(ij eq 2 ) then n_reads = info.data.slope_xsize

    xvalues = indgen(n_reads) + 1
    yvalues  = fltarr(n_reads) + value1
    yvalues2  = fltarr(n_reads) + value2
    if(ij eq 1) then begin
        yvalues = yvalues - info.slope.x_zoom_start/info.slope.scale_zoom
        yvalues2 = yvalues2 - info.slope.x_zoom_start/info.slope.scale_zoom
    endif
    plots,xvalues,yvalues,/device,color=info.white,linestyle=2
    plots,xvalues,yvalues2,/device,color=info.white,linestyle=2

    if(zwindow eq typeplot) then begin 
        wset,info.slope.draw_window_id[1]
        n_reads =  info.plotsize1
        xvalues = indgen(n_reads) + 1
        pos1 =(value1*info.slope.binfactor )-info.slope.ystart_zoom
        pos2 =(value2*info.slope.binfactor)-info.slope.ystart_zoom


        pos1 = pos1*zoom +info.slope.iystart_zoom*zoom
        pos2 = pos2*zoom +info.slope.iystart_zoom*zoom

        yvalues  = fltarr(n_reads) +pos1
        yvalues2  = fltarr(n_reads) +pos2

        plots,xvalues,yvalues,/device,color=info.white,linestyle=2
        plots,xvalues,yvalues2,/device,color=info.white,linestyle=2

    endif
    info.col_table = save_color
endif


end
