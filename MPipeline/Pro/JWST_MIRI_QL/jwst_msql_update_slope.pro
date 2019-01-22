;***********************************************************************
;_______________________________________________________________________
pro jwst_msql_update_slope,data_plane,win,info,ps = ps,eps = eps
;_______________________________________________________________________
loadct,info.col_table,/silent


hcopy = 0
if ( (keyword_set(ps)) or ( keyword_set(eps)) ) then hcopy = 1

i = info.jwst_slope.integrationNO
frame_image = fltarr(info.jwst_data.slope_xsize,info.jwst_data.slope_ysize)


if(data_plane eq info.jwst_slope.plane_cal) then begin 
    info.jwst_slope.graph_range[win,0] = info.jwst_data.cal_stat[5,0]
    info.jwst_slope.graph_range[win,1] = info.jwst_data.cal_stat[6,0]
    frame_image[*,*] = (*info.jwst_data.pcaldata)[*,*,0]

    mean = info.jwst_data.cal_stat[0,0]
    min = info.jwst_data.cal_stat[3,0]
    max = info.jwst_data.cal_stat[4,0]
endif else begin 
    if(info.jwst_slope.default_scale_graph[win] eq 1) then begin
        info.jwst_slope.graph_range[win,0] = info.jwst_data.slope_stat[5,data_plane]
        info.jwst_slope.graph_range[win,1] = info.jwst_data.slope_stat[6,data_plane]
    endif
    frame_image[*,*] = (*info.jwst_data.pslopedata)[*,*,data_plane]
; update stats 	   
    mean = info.jwst_data.slope_stat[0,data_plane]
    min = info.jwst_data.slope_stat[3,data_plane]
    max = info.jwst_data.slope_stat[4,data_plane]
endelse

n_pixels = float( (info.jwst_data.slope_xsize) * (info.jwst_data.slope_ysize))
indxs = where(finite(frame_image),n_pixels)

xsize_image = fix(info.jwst_data.slope_xsize/info.jwst_slope.binfactor)
ysize_image = fix(info.jwst_data.slope_ysize/info.jwst_slope.binfactor)
widget_control,info.jwst_slope.graphID[win],draw_xsize = xsize_image,draw_ysize=ysize_image

; Display the image
if(hcopy eq 0 ) then wset,info.jwst_slope.pixmapID[win]	

disp_image = congrid(frame_image, $
                     xsize_image,ysize_image)

disp_image = bytscl(disp_image,min=info.jwst_slope.graph_range[win,0], $
                    max=info.jwst_slope.graph_range[win,1],top=info.col_max,/nan)
tv,disp_image,/device
if( hcopy eq 0) then begin  
    wset,info.jwst_slope.draw_window_id[win]
    device,copy=[0,0,xsize_image,ysize_image, $
                 0,0,info.jwst_slope.pixmapID[win]]
endif

smean =  strcompress(string(mean),/remove_all)
smin = strcompress(string(min),/remove_all) 
smax = strcompress(string(max),/remove_all) 

widget_control,info.jwst_slope.slabelID[win],set_value=('Mean: ' +smean) 
widget_control,info.jwst_slope.mlabelID[win],set_value=(' Min: ' +smin + ' Max: ' +smax) 

widget_control,info.jwst_slope.rlabelID[win,0],set_value=info.jwst_slope.graph_range[win,0]
widget_control,info.jwst_slope.rlabelID[win,1],set_value=info.jwst_slope.graph_range[win,1]
; replot the pixel location

box_coords1 = [info.jwst_slope.x_pos,(info.jwst_slope.x_pos+1), $
               info.jwst_slope.y_pos,(info.jwst_slope.y_pos+1)]

plots,box_coords1[[0,0,1,1,0]],box_coords1[[2,3,3,2,2]],psym=0,/device

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
