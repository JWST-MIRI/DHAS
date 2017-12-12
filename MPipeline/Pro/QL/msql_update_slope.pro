;***********************************************************************
;_______________________________________________________________________
pro msql_update_slope,plane,win,info,ps = ps,eps = eps
;_______________________________________________________________________
loadct,info.col_table,/silent


hcopy = 0
if ( (keyword_set(ps)) or ( keyword_set(eps)) ) then hcopy = 1

i = info.slope.integrationNO

frame_image = fltarr(info.data.slope_xsize,info.data.slope_ysize)

if(plane eq info.slope.plane_cal) then begin 
    info.slope.graph_range[win,0] = info.data.cal_stat[5,0]
    info.slope.graph_range[win,1] = info.data.cal_stat[6,0]
    frame_image[*,*] = (*info.data.pcaldata)[*,*,0]

    mean = info.data.cal_stat[0,0]
    min = info.data.cal_stat[3,0]
    max = info.data.cal_stat[4,0]
endif else begin 

    if(info.slope.default_scale_graph[win] eq 1) then begin
        info.slope.graph_range[win,0] = info.data.slope_stat[5,plane]
        info.slope.graph_range[win,1] = info.data.slope_stat[6,plane]
    endif
        frame_image[*,*] = (*info.data.pslopedata)[*,*,plane]
; update stats 	   
        mean = info.data.slope_stat[0,plane]
        min = info.data.slope_stat[3,plane]
        max = info.data.slope_stat[4,plane]
endelse



n_pixels = float( (info.data.slope_xsize) * (info.data.slope_ysize))
indxs = where(finite(frame_image),n_pixels)

xsize_image = fix(info.data.slope_xsize/info.slope.binfactor)
ysize_image = fix(info.data.slope_ysize/info.slope.binfactor)
widget_control,info.slope.graphID[win],draw_xsize = xsize_image,draw_ysize=ysize_image


; Display the image
if(hcopy eq 0 ) then wset,info.slope.pixmapID[win]	

disp_image = congrid(frame_image, $
                     xsize_image,ysize_image)


disp_image = bytscl(disp_image,min=info.slope.graph_range[win,0], $
                    max=info.slope.graph_range[win,1],top=info.col_max,/nan)
tv,disp_image,/device
if( hcopy eq 0) then begin  
    wset,info.slope.draw_window_id[win]
    device,copy=[0,0,xsize_image,ysize_image, $
                 0,0,info.slope.pixmapID[win]]
endif

smean =  strcompress(string(mean),/remove_all)
smin = strcompress(string(min),/remove_all) 
smax = strcompress(string(max),/remove_all) 

widget_control,info.slope.slabelID[win],set_value=('Mean: ' +smean) 
widget_control,info.slope.mlabelID[win],set_value=(' Min: ' +smin + ' Max: ' +smax) 


widget_control,info.slope.rlabelID[win,0],set_value=info.slope.graph_range[win,0]
widget_control,info.slope.rlabelID[win,1],set_value=info.slope.graph_range[win,1]


; replot the pixel location

box_coords1 = [info.slope.x_pos,(info.slope.x_pos+1), $
               info.slope.y_pos,(info.slope.y_pos+1)]

plots,box_coords1[[0,0,1,1,0]],box_coords1[[2,3,3,2,2]],psym=0,/device

 if(info.slope.showline_col eq 1) then begin
        n_reads = info.control.yplot_size
        n_reads = info.data.slope_ysize
        yvalues = indgen(n_reads) + 1
        xvalues  = fltarr(n_reads) + info.slope.x_pos
        plots,xvalues,yvalues,/device,color=info.white
    endif
    if(info.slope.showline_row eq 1) then begin
        n_reads = info.control.xplot_size
        n_reads = info.data.slope_xsize
        xvalues = indgen(n_reads) + 1
        yvalues  = fltarr(n_reads) + info.slope.y_pos
        plots,xvalues,yvalues,/device,color=info.white
    endif

if(hcopy eq 1) then begin 
    svalue = "Slope Image"
    ititle = "Integration #: " + strtrim(string(i+1),2)
    sstitle = info.control.filename_slope
    mtitle = "Mean: " + smean 
    mintitle = "Min value: " + smin
    maxtitle = "Max value: " + smax

    xyouts,0.75*!D.X_Vsize,0.95*!D.Y_VSize,sstitle,/device
    xyouts,0.75*!D.X_Vsize,0.90*!D.Y_VSize,svalue,/device
    xyouts,0.75*!D.X_Vsize,0.80*!D.Y_VSize,ititle,/device
    xyouts,0.75*!D.X_Vsize,0.75*!D.Y_VSize,mtitle,/device
    xyouts,0.75*!D.X_Vsize,0.70*!D.Y_VSize,mintitle,/device
    xyouts,0.75*!D.X_Vsize,0.65*!D.Y_VSize,maxtitle,/device
endif


frame_image = 0
disp_image = 0

end
