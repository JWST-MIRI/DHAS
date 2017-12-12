;***********************************************************************
;_______________________________________________________________________
pro msql_draw_zoom_box,info
;_______________________________________________________________________


ij = info.slope.zoom_window-1
wset,info.slope.draw_window_id[ij]

xstart_plot = info.slope.x_zoom_start/info.slope.binfactor
xrange  = info.slope.x_zoom_end - info.slope.x_zoom_start + 1
xend_plot = xstart_plot + (xrange/info.slope.binfactor)


ystart_plot = info.slope.y_zoom_start/info.slope.binfactor
yrange  = info.slope.y_zoom_end - info.slope.y_zoom_start + 1
yend_plot = ystart_plot + (yrange/info.slope.binfactor) 
box_coords1 = [xstart_plot,xend_plot, $
               ystart_plot,yend_plot]


plots,box_coords1[[0,0,1,1,0]],box_coords1[[2,3,3,2,2]],psym=0,/device



end


;***********************************************************************
;_______________________________________________________________________
pro msql_update_zoom_image,info,ps = ps,eps = eps
;_______________________________________________________________________
loadct,info.col_table,/silent

hcopy = 0
if ( (keyword_set(ps)) or ( keyword_set(eps)) ) then hcopy = 1

planenum = info.slope.plane[1] 


zoom = info.slope.scale_zoom
i = info.slope.integrationNO

xdata_end = info.data.slope_xsize
ydata_end = info.data.slope_ysize
frame_image = fltarr(info.data.slope_xsize,info.data.slope_ysize)


if(info.slope.plane_cal eq planenum ) then begin 
    frame_image[*,*] = (*info.data.pcaldata)[*,*,0]
    if(info.slope.default_scale_graph[1] eq 1) then begin    

        info.slope.graph_range[1,0] = info.slope.graph_range[info.slope.zoom_window-1,0]
        info.slope.graph_range[1,1] = info.slope.graph_range[info.slope.zoom_window-1,1]
    endif
endif else begin
    frame_image[*,*] = (*info.data.pslopedata)[*,*,planenum]
    if(info.slope.default_scale_graph[1] eq 1) then begin    

        info.slope.graph_range[1,0] = info.slope.graph_range[info.slope.zoom_window-1,0]
        info.slope.graph_range[1,1] = info.slope.graph_range[info.slope.zoom_window-1,1]
    endif
endelse

if(planenum eq 0) then szoom = "Zoom Centered on Slope image     " 

if(planenum eq 1) then szoom = "Zoom Centered on Uncertainty Image" 

if(planenum eq 2) then szoom = "Zoom Centered on Data Quality Flag" 

if(planenum eq 3) then szoom = "Zoom Centered on Zero Pt" 

if(planenum eq 4) then szoom = "Zoom Centered on # Good Reads" 

if(planenum eq 5) then szoom = "Zoom Centered on Read # 1st Sat Frame" 

if(planenum eq 6) then szoom = "Zoom Centered on # of Good Segments "
 
if(info.data.slope_zsize gt 7) then begin 

  if(planenum eq 7) then szoom = "Emp Uncertainty"   
  if(planenum eq 8) then szoom = "Zoom Centered on Max 2pt Diff"   
  if(planenum eq 9) then szoom = "Zoom Centered on Read # of Max  2pt Diff"   
  if(planenum eq 10) then szoom = "Zoom Centered on Standard Dev of 2pt Diff"   
  if(planenum eq 11) then szoom = "Zoom Centered on Slope of 2pt Diff"   
  if(planenum eq 12) then szoom = "Zoom Centered on Calibrated image "    
endif




x = info.slope.x_zoom
y = info.slope.y_zoom



; initialize the x and y pos to be the center of the image

info.slope.x_zoom_pos = info.slope.x_zoom
info.slope.y_zoom_pos = info.slope.y_zoom


widget_control,info.slope.graph_label[1], set_value=szoom


xsize = info.plotsize1
ysize = info.plotsize1
xsize = xsize/zoom 
ysize = ysize/zoom

info.slope.zoom_xplot_size = xsize
info.slope.zoom_yplot_size = ysize
; ixstart and iystart are the starting points for the zoom imnage
; xstart and ystart are the starting points for the orginal image


xstart = fix(x - xsize/2)
ystart = fix(y - ysize/2)

; check if x or y start < 0
if(xstart lt 0) then xstart = 0
if(ystart lt 0) then ystart = 0

xend  = xstart + xsize-1
yend  = ystart + ysize-1

if(xend ge xdata_end) then begin
    xend =  xdata_end -1   
    xstart  = xend - xsize +1
endif

if(yend ge ydata_end) then begin
    yend =  ydata_end  -1  
    ystart  = yend - ysize +1
endif


if(xstart lt 0) then xstart = 0
if(ystart lt 0) then ystart = 0


ix = xend - xstart
iy = yend - ystart

ixstart = 0
iystart = 0
ixend = ixstart + ix
iyend = iystart + iy


;print,'ixstart, ixend ',ixstart,ixend
;print,'iystart, iyend ',iystart,iyend

;print,'xstart xend ',xstart,xend
;print,'ystart yend ',ystart,yend

info.slope.x_zoom_start = xstart
info.slope.y_zoom_start = ystart
info.slope.y_zoom_end = yend
info.slope.x_zoom_end = xend

;sub_image = fltarr(xsize,ysize)   
xrange = ixend-ixstart+1
yrange = iyend-iystart+1
sub_image = fltarr(xrange,yrange)
sub_image = frame_image[xstart:xend,ystart:yend]

;sub_image[ixstart:ixend,iystart:iyend] = frame_image[xstart:xend,ystart:yend]
stat_data = sub_image[ixstart:ixend,iystart:iyend] 

get_image_stat,stat_data,image_mean,stdev_pixel,image_min,image_max,$
               irange_min,irange_max,image_median,stdev_mean,skew,ngood,nbad
stat_data = 0
;_______________________________________________________________________
if ptr_valid (info.slope.pzoomdata) then ptr_free,info.slope.pzoomdata
info.slope.pzoomdata = ptr_new(sub_image)

info.slope.zoom_stat[0] = image_mean
info.slope.zoom_stat[1] = stdev_pixel
info.slope.zoom_stat[2] = image_min
info.slope.zoom_stat[3] = image_max
info.slope.zoom_stat[4] = image_median
info.slope.zoom_stat[5] = stdev_mean
info.slope.zoom_stat[6] = skew
info.slope.zoom_stat[7] = ngood
info.slope.zoom_stat[8] = nbad
info.slope.zoom_range[0] = irange_min
info.slope.zoom_range[1] = irange_max



widget_control,info.slope.graphID[1],draw_xsize = xrange*zoom,draw_ysize=yrange*zoom 



;print,'size',xrange*zoom, yrange*zoom
;print,'size',xsize*zoom, ysize*zoom
if(hcopy eq 0) then wset,info.slope.pixmapID[1]
disp_image = congrid(sub_image, xsize*zoom,ysize*zoom)
disp_image = bytscl(disp_image,min=info.slope.graph_range[1,0], $
                    max=info.slope.graph_range[1,1],$
                    top=info.col_max-info.col_bits-1,/nan)

frame_image = 0 ; free memory
sub_image = 0
tv,disp_image,0,0,/device
if(hcopy eq 0) then begin 
    wset,info.slope.draw_window_id[1]
    device,copy=[0,0,$
                 xsize*zoom,$
                 ysize*zoom, $
                 0,0,info.slope.pixmapID[1]]
endif else begin
    stitle = "Zoom " + szoom
    ftitle = "Frame #: " + strtrim(string(j+1),2) 
    ititle = "Integration #: " + strtrim(string(i+1),2)
    sstitle = info.control.filebase+'.fits'

    xyouts,0.75*!D.X_Vsize,0.95*!D.Y_VSize,sstitle,/device
    xyouts,0.75*!D.X_Vsize,0.90*!D.Y_VSize,stitle,/device
    xyouts,0.75*!D.X_Vsize,0.85*!D.Y_VSize,ftitle,/device
    xyouts,0.75*!D.X_Vsize,0.80*!D.Y_VSize,ititle,/device
endelse


; update stats    

scale_min = info.slope.graph_range[1,0]
scale_max = info.slope.graph_range[1,1]

widget_control,info.slope.rlabelID[1,0],set_value=scale_min
widget_control,info.slope.rlabelID[1,1],set_value=scale_max

smean =  strcompress(string(image_mean),/remove_all)
smin = strcompress(string(image_min),/remove_all) 
smax = strcompress(string(image_max),/remove_all) 

widget_control,info.slope.slabelID[1],set_value=('Mean: ' +smean) 
widget_control,info.slope.mlabelID[1],set_value=(' Min: ' +smin + '  Max: ' +smax) 

; replot the pixel location


xvalue = (x - xstart + ixstart)*info.slope.scale_zoom
yvalue = (y - ystart + iystart)*info.slope.scale_zoom


info.slope.ixstart_zoom = ixstart
info.slope.xstart_zoom = xstart

info.slope.iystart_zoom = iystart
info.slope.ystart_zoom = ystart


pixelsize  = 1.0 * info.slope.scale_zoom
;print,'in mql_update_zoom_image x y plot value',xvalue,yvalue

info.slope.x_zoom_plotpt = xvalue
info.slope.y_zoom_plotpt = yvalue
xcenter = fix(xvalue/info.slope.scale_zoom)* info.slope.scale_zoom + pixelsize/2.0
ycenter = fix(yvalue/info.slope.scale_zoom)* info.slope.scale_zoom + pixelsize/2.0

xstart = xcenter - pixelsize/2
xend = xcenter +pixelsize/2
ystart = ycenter - pixelsize/2
yend = ycenter + pixelsize/2

box_coords = [xstart,xend,ystart,yend]


plots,box_coords[[0,0,1,1,0]],box_coords[[2,3,3,2,2]],psym=0,/device,color=info.white


end


;***********************************************************************
;_______________________________________________________________________
pro msql_update_zoom_pixel_location,xvalue,yvalue,info
;_______________________________________________________________________

zoom = info.slope.scale_zoom

xsize = info.plotsize1
ysize = info.plotsize1

wset,info.slope.draw_window_id[1]
device,copy=[0,0,$
             xsize,$
             ysize, $
             0,0,info.slope.pixmapID[1]]


; if the x_pos and y_pos need to be determined (x and y plot
; screen value in  raw and slope plots) 
x = (xvalue)/info.slope.scale_zoom
y = (yvalue)/info.slope.scale_zoom
x = x + info.slope.x_zoom_start - info.slope.ixstart_zoom
y = y + info.slope.y_zoom_start - info.slope.iystart_zoom

info.slope.x_pos = x/info.slope.binfactor
info.slope.y_pos = y/info.slope.binfactor

pixelsize  = 1.0 * info.slope.scale_zoom

;print,'xvalue',xvalue,yvalue
xcenter = fix(xvalue/info.slope.scale_zoom)* info.slope.scale_zoom + pixelsize/2.0
ycenter = fix(yvalue/info.slope.scale_zoom)* info.slope.scale_zoom + pixelsize/2.0

info.slope.x_zoom_plotpt = xvalue
info.slope.y_zoom_plotpt = yvalue

info.slope.x_zoom_pos  = info.slope.x_pos * info.slope.binfactor
info.slope.y_zoom_pos  = info.slope.y_pos * info.slope.binfactor


halfpixel = 0.5*  info.slope.scale_zoom

xpos1 = xcenter-halfpixel
xpos2 = xcenter+halfpixel

ypos1 = ycenter-halfpixel
ypos2 = ycenter+halfpixel

box_coords1 = [xpos1,xpos2,ypos1,ypos2]
plots,box_coords1[[0,0,1,1,0]],box_coords1[[2,3,3,2,2]],psym=0,/device


end


