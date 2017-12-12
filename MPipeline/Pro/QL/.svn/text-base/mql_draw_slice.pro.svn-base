pro mql_draw_slice,typeplot,typeslice,showline,value1,value2,info

save_color = info.col_table
color6
; typeplot: 0 raw image, 1 zoom image, 2 slope image
; typeslice: 0 column slice, 1 row slice

if(not XRegistered ('mql')) then begin
    Print,' Main Display Widget does not exist'
    return
endif
ij = typeplot

wset,info.image.draw_window_id[ij]
xsize_image = fix(info.data.image_xsize/info.image.binfactor) 
ysize_image = fix(info.data.image_ysize/info.image.binfactor)

device,copy=[0,0,xsize_image,ysize_image,0,0,info.image.pixmapID[ij]]



zwindow = info.image.graph_mpixel-1
if(zwindow eq typeplot) then begin 
    wset,info.image.draw_window_id[1]
    zoom = info.image.scale_zoom
    device,copy=[0,0,$
                 info.plotsize1*zoom,$
                 info.plotsize1*zoom, $
                 0,0,info.image.pixmapID[1]]
endif


if(typeslice eq 0 and  showline eq 1) then begin
    wset,info.image.draw_window_id[ij]
    n_reads = info.plotsize1
    
    if(ij eq 0 ) then n_reads = info.data.image_ysize
    if(ij eq 1 ) then n_reads = info.data.image_ysize
    if(ij eq 2 ) then n_reads = info.data.slope_ysize
    yvalues = indgen(n_reads) + 1
    xvalues  = fltarr(n_reads) +value1
    xvalues2  = fltarr(n_reads) +value2
    if(ij eq 1) then begin
        xvalues = xvalues - info.image.y_zoom_start/info.image.scale_zoom
        xvalues2 = xvalues2 - info.image.y_zoom_start/info.image.scale_zoom
    endif
    plots,xvalues,yvalues,/device,color=info.white,linestyle=2
    plots,xvalues2,yvalues,/device,color=info.white,linestyle=2



    if(zwindow eq typeplot) then begin

        wset,info.image.draw_window_id[1] 
        n_reads =  info.plotsize1
        yvalues = indgen(n_reads) + 1
        pos1 =(value1*info.image.binfactor )-info.image.xstart_zoom
        pos2 =(value2*info.image.binfactor )-info.image.xstart_zoom

        pos1 = pos1*zoom +info.image.ixstart_zoom*zoom
        pos2 = pos2*zoom +info.image.ixstart_zoom*zoom
        xvalues  = fltarr(n_reads) +pos1
        xvalues2  = fltarr(n_reads) +pos2

        plots,xvalues,yvalues,/device,color=info.white,linestyle=2
        plots,xvalues2,yvalues,/device,color=info.white,linestyle=2
    endif
endif

if(typeslice eq 1 and showline eq 1) then begin
    wset,info.image.draw_window_id[ij]
    n_reads = info.plotsize1
    if(ij eq 0 ) then n_reads = info.data.image_xsize
    if(ij eq 1 ) then n_reads = info.data.image_xsize
    if(ij eq 2 ) then n_reads = info.data.slope_xsize


    xvalues = indgen(n_reads) + 1
    yvalues  = fltarr(n_reads) + value1
    yvalues2  = fltarr(n_reads) + value2
    if(ij eq 1) then begin
        yvalues = yvalues - info.image.x_zoom_start/info.image.scale_zoom
        yvalues2 = yvalues2 - info.image.x_zoom_start/info.image.scale_zoom
    endif
    plots,xvalues,yvalues,/device,color=info.white,linestyle=2
    plots,xvalues,yvalues2,/device,color=info.white,linestyle=2

    if(zwindow eq typeplot) then begin 
        wset,info.image.draw_window_id[1]
        n_reads =  info.plotsize1
        xvalues = indgen(n_reads) + 1
        pos1 =(value1*info.image.binfactor )-info.image.ystart_zoom
        pos2 =(value2*info.image.binfactor)-info.image.ystart_zoom


        pos1 = pos1*zoom +info.image.iystart_zoom*zoom
        pos2 = pos2*zoom +info.image.iystart_zoom*zoom
        yvalues  = fltarr(n_reads) +pos1
        yvalues2  = fltarr(n_reads) +pos2

        plots,xvalues,yvalues,/device,color=info.white,linestyle=2
        plots,xvalues,yvalues2,/device,color=info.white,linestyle=2

    endif

endif

info.col_table = save_color
end
