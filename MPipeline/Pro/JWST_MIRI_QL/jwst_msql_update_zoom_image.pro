;_______________________________________________________________________
pro jwst_msql_draw_zoom_box,info
;_______________________________________________________________________
ij = info.jwst_slope.zoom_window-1
wset,info.jwst_slope.draw_window_id[ij]

xstart_plot = info.jwst_slope.x_zoom_start/info.jwst_slope.binfactor
xrange  = info.jwst_slope.x_zoom_end - info.jwst_slope.x_zoom_start + 1
xend_plot = xstart_plot + (xrange/info.jwst_slope.binfactor)

ystart_plot = info.jwst_slope.y_zoom_start/info.jwst_slope.binfactor
yrange  = info.jwst_slope.y_zoom_end - info.jwst_slope.y_zoom_start + 1
yend_plot = ystart_plot + (yrange/info.jwst_slope.binfactor) 
box_coords1 = [xstart_plot,xend_plot, $
               ystart_plot,yend_plot]


plots,box_coords1[[0,0,1,1,0]],box_coords1[[2,3,3,2,2]],psym=0,/device
end
;_______________________________________________________________________
pro jwst_msql_update_zoom_image,info,ps = ps,eps = eps
;_______________________________________________________________________
loadct,info.col_table,/silent

hcopy = 0
if ( (keyword_set(ps)) or ( keyword_set(eps)) ) then hcopy = 1

planenum = info.jwst_slope.plane[2] 
zoom = info.jwst_slope.scale_zoom

xdata_end = info.jwst_data.slope_xsize
ydata_end = info.jwst_data.slope_ysize
frame_image = fltarr(info.jwst_data.slope_xsize,info.jwst_data.slope_ysize)


if(info.jwst_slope.default_scale_graph[2] eq 1) then begin    
   info.jwst_slope.graph_range[2,0] = info.jwst_slope.graph_range[info.jwst_slope.zoom_window-1,0]
   info.jwst_slope.graph_range[2,1] = info.jwst_slope.graph_range[info.jwst_slope.zoom_window-1,1]
endif

if(info.jwst_slope.data_type(info.jwst_slope.zoom_window-1) eq 1) then begin
   frame_image[*,*] = (*info.jwst_data.prate1)[*,*,planenum] 
   if(planenum eq 0) then szoom = "Zoom Centered on Final Rate     " 
   if(planenum eq 1) then szoom = "Zoom Centered on Final Error    " 
   if(planenum eq 2) then szoom = "Zoom Centered on Final DQ       " 
endif else begin
   frame_image [*,*] = (*info.jwst_data.prate2)[*,*,planenum]
   if(planenum eq 0) then szoom = "Zoom Centered on Int Rate     " 
   if(planenum eq 1) then szoom = "Zoom Centered on Int Error    " 
   if(planenum eq 2) then szoom = "Zoom Centered on Int DQ       " 
endelse

x = info.jwst_slope.x_zoom
y = info.jwst_slope.y_zoom

; initialize the x and y pos to be the center of the image

info.jwst_slope.x_zoom_pos = info.jwst_slope.x_zoom
info.jwst_slope.y_zoom_pos = info.jwst_slope.y_zoom
widget_control,info.jwst_slope.graph_label[2], set_value=szoom

xsize = info.jwst_plotsize1
ysize = info.jwst_plotsize1
xsize = xsize/zoom 
ysize = ysize/zoom

info.jwst_slope.zoom_xplot_size = xsize
info.jwst_slope.zoom_yplot_size = ysize
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

info.jwst_slope.x_zoom_start = xstart
info.jwst_slope.y_zoom_start = ystart
info.jwst_slope.y_zoom_end = yend
info.jwst_slope.x_zoom_end = xend

xrange = ixend-ixstart+1
yrange = iyend-iystart+1
sub_image = fltarr(xrange,yrange)
sub_image = frame_image[xstart:xend,ystart:yend]

stat_data = sub_image[ixstart:ixend,iystart:iyend] 

jwst_get_image_stat,stat_data,image_mean,stdev_pixel,image_min,image_max,$
               irange_min,irange_max,image_median,stdev_mean
stat_data = 0
;_______________________________________________________________________
if ptr_valid (info.jwst_slope.pzoomdata) then ptr_free,info.jwst_slope.pzoomdata
info.jwst_slope.pzoomdata = ptr_new(sub_image)

info.jwst_slope.zoom_stat[0] = image_mean
info.jwst_slope.zoom_stat[1] = stdev_pixel
info.jwst_slope.zoom_stat[2] = image_min
info.jwst_slope.zoom_stat[3] = image_max
info.jwst_slope.zoom_stat[4] = image_median
info.jwst_slope.zoom_stat[5] = stdev_mean

widget_control,info.jwst_slope.graphID[2],draw_xsize = xrange*zoom,draw_ysize=yrange*zoom 

if(hcopy eq 0) then wset,info.jwst_slope.pixmapID[2]
disp_image = congrid(sub_image, xsize*zoom,ysize*zoom)
disp_image = bytscl(disp_image,min=info.jwst_slope.graph_range[2,0], $
                    max=info.jwst_slope.graph_range[2,1],$
                    top=info.col_max-info.col_bits-1,/nan)

frame_image = 0 ; free memory
sub_image = 0
tv,disp_image,0,0,/device
if(hcopy eq 0) then begin 
    wset,info.jwst_slope.draw_window_id[2]
    device,copy=[0,0,$
                 xsize*zoom,$
                 ysize*zoom, $
                 0,0,info.jwst_slope.pixmapID[2]]
endif else begin
    stitle = "Zoom " + szoom
    ftitle = "Frame #: " + strtrim(string(j+1),2) 
    ititle = "Integration #: " + strtrim(string(i+1),2)
    sstitle = info.jwst_control.filebase+'.fits'

    xyouts,0.75*!D.X_Vsize,0.95*!D.Y_VSize,sstitle,/device
    xyouts,0.75*!D.X_Vsize,0.90*!D.Y_VSize,stitle,/device
    xyouts,0.75*!D.X_Vsize,0.85*!D.Y_VSize,ftitle,/device
    xyouts,0.75*!D.X_Vsize,0.80*!D.Y_VSize,ititle,/device
endelse

; update stats    

scale_min = info.jwst_slope.graph_range[2,0]
scale_max = info.jwst_slope.graph_range[2,1]

widget_control,info.jwst_slope.rlabelID[2,0],set_value=scale_min
widget_control,info.jwst_slope.rlabelID[2,1],set_value=scale_max

smean =  strcompress(string(image_mean),/remove_all)
smin = strcompress(string(image_min),/remove_all) 
smax = strcompress(string(image_max),/remove_all) 

widget_control,info.jwst_slope.slabelID[2],set_value=('Mean: ' +smean) 
widget_control,info.jwst_slope.mlabelID[2],set_value=(' Min: ' +smin + '  Max: ' +smax) 

; replot the pixel location
xvalue = (x - xstart + ixstart)*info.jwst_slope.scale_zoom
yvalue = (y - ystart + iystart)*info.jwst_slope.scale_zoom

info.jwst_slope.ixstart_zoom = ixstart
info.jwst_slope.xstart_zoom = xstart

info.jwst_slope.iystart_zoom = iystart
info.jwst_slope.ystart_zoom = ystart

pixelsize  = 1.0 * info.jwst_slope.scale_zoom

info.jwst_slope.x_zoom_plotpt = xvalue
info.jwst_slope.y_zoom_plotpt = yvalue
xcenter = fix(xvalue/info.jwst_slope.scale_zoom)* info.jwst_slope.scale_zoom + pixelsize/2.0
ycenter = fix(yvalue/info.jwst_slope.scale_zoom)* info.jwst_slope.scale_zoom + pixelsize/2.0

xstart = xcenter - pixelsize/2
xend = xcenter +pixelsize/2
ystart = ycenter - pixelsize/2
yend = ycenter + pixelsize/2

box_coords = [xstart,xend,ystart,yend]
plots,box_coords[[0,0,1,1,0]],box_coords[[2,3,3,2,2]],psym=0,/device,color=info.white

end

;***********************************************************************
;_______________________________________________________________________
pro jwst_msql_update_zoom_pixel_location,xvalue,yvalue,info
;_______________________________________________________________________

zoom = info.jwst_slope.scale_zoom

xsize = info.jwst_plotsize1
ysize = info.jwst_plotsize1

wset,info.jwst_slope.draw_window_id[2]
device,copy=[0,0,$
             xsize,$
             ysize, $
             0,0,info.jwst_slope.pixmapID[2]]


; if the x_pos and y_pos need to be determined (x and y plot
; screen value in  raw and slope plots) 
x = (xvalue)/info.jwst_slope.scale_zoom
y = (yvalue)/info.jwst_slope.scale_zoom
x = x + info.jwst_slope.x_zoom_start - info.jwst_slope.ixstart_zoom
y = y + info.jwst_slope.y_zoom_start - info.jwst_slope.iystart_zoom

info.jwst_slope.x_pos = x/info.jwst_slope.binfactor
info.jwst_slope.y_pos = y/info.jwst_slope.binfactor

pixelsize  = 1.0 * info.jwst_slope.scale_zoom

;print,'xvalue',xvalue,yvalue
xcenter = fix(xvalue/info.jwst_slope.scale_zoom)* info.jwst_slope.scale_zoom + pixelsize/2.0
ycenter = fix(yvalue/info.jwst_slope.scale_zoom)* info.jwst_slope.scale_zoom + pixelsize/2.0

info.jwst_slope.x_zoom_plotpt = xvalue
info.jwst_slope.y_zoom_plotpt = yvalue

info.jwst_slope.x_zoom_pos  = info.jwst_slope.x_pos * info.jwst_slope.binfactor
info.jwst_slope.y_zoom_pos  = info.jwst_slope.y_pos * info.jwst_slope.binfactor


halfpixel = 0.5*  info.jwst_slope.scale_zoom

xpos1 = xcenter-halfpixel
xpos2 = xcenter+halfpixel

ypos1 = ycenter-halfpixel
ypos2 = ycenter+halfpixel

box_coords1 = [xpos1,xpos2,ypos1,ypos2]
plots,box_coords1[[0,0,1,1,0]],box_coords1[[2,3,3,2,2]],psym=0,/device

end


