;_______________________________________________________________________
pro jwst_mql_draw_zoom_box,info
;_______________________________________________________________________
ij = info.jwst_image.current_graph
wset,info.jwst_image.draw_window_id[ij]

xstart_plot = info.jwst_image.x_zoom_start/info.jwst_image.binfactor
xrange  = info.jwst_image.x_zoom_end - info.jwst_image.x_zoom_start + 1
xend_plot = xstart_plot + (xrange/info.jwst_image.binfactor)

ystart_plot = info.jwst_image.y_zoom_start/info.jwst_image.binfactor
yrange  = info.jwst_image.y_zoom_end - info.jwst_image.y_zoom_start + 1
yend_plot = ystart_plot + (yrange/info.jwst_image.binfactor) 

box_coords1 = [xstart_plot,xend_plot, $
               ystart_plot,yend_plot]


plots,box_coords1[[0,0,1,1,0]],box_coords1[[2,3,3,2,2]],psym=0,/device

end
;_______________________________________________________________________
pro jwst_mql_update_zoom_pixel_location,xvalue,yvalue,update,info
;_______________________________________________________________________
zoom = info.jwst_image.scale_zoom

xsize = info.jwst_plotsize1
ysize = info.jwst_plotsize1

wset,info.jwst_image.draw_window_id[1]
device,copy=[0,0,$
             xsize,$
             ysize, $
             0,0,info.jwst_image.pixmapID[1]]

; if the x_pos and y_pos need to be determined (x and y plot
; screen value in  raw and slope plots) 
if(update eq 1) then begin 
    x = (xvalue)/info.jwst_image.scale_zoom
    y = (yvalue)/info.jwst_image.scale_zoom
    x = x + info.jwst_image.x_zoom_start - info.jwst_image.ixstart_zoom
    y = y + info.jwst_image.y_zoom_start - info.jwst_image.iystart_zoom

    info.jwst_image.x_pos = x/info.jwst_image.binfactor
    info.jwst_image.y_pos = y/info.jwst_image.binfactor
endif


info.jwst_image.x_zoom_plotpt = xvalue
info.jwst_image.y_zoom_plotpt = yvalue

info.jwst_image.x_zoom_pos  = info.jwst_image.x_pos * info.jwst_image.binfactor
info.jwst_image.y_zoom_pos  = info.jwst_image.y_pos * info.jwst_image.binfactor

halfpixelx = 0.5*  info.jwst_image.scale_zoom
halfpixely = 0.5 * info.jwst_image.scale_zoom

xx = fix(xvalue/info.jwst_image.scale_zoom)+0.5
yy = fix(yvalue/info.jwst_image.scale_zoom)+0.5

xx = xx * info.jwst_image.scale_zoom 
yy = yy * info.jwst_image.scale_zoom 

xpos1 = xx-halfpixelx
xpos2 = xx+halfpixelX

ypos1 = yy-halfpixely
ypos2 = yy+halfpixely

box_coords1 = [xpos1,xpos2,ypos1,ypos2]
plots,box_coords1[[0,0,1,1,0]],box_coords1[[2,3,3,2,2]],psym=0,/device
end
;_______________________________________________________________________
pro jwst_mql_update_zoom_image,info,ps = ps,eps = eps
;_______________________________________________________________________
hcopy = 0
loadct,info.col_table,/silent
if ( (keyword_set(ps)) or ( keyword_set(eps)) ) then hcopy = 1

graphnum = info.jwst_image.graph_mpixel 

info.jwst_image.zoom_window = graphnum ; orginal window zooming in on
zoom = info.jwst_image.scale_zoom

i = info.jwst_image.integrationNO
j = info.jwst_image.frameNO

slope_exist = info.jwst_control.file_slope_exist
if(info.jwst_image.integrationNO+1 gt info.jwst_data.nints) then slope_exist = 0

; clicked on slope image - but slope image does not exist
if(graphnum eq 3 and slope_exist eq 0) then return

if(info.jwst_data.read_all eq 0) then begin
    i = 0
    if(info.jwst_data.num_frames ne info.jwst_data.ngroups) then begin 
        j = info.jwst_image.frameNO- info.jwst_control.frame_start
    endif
endif

if(graphnum eq 1) then begin 
    szoom = "Zoom Centered on Raw image     " 
    xdata_end = info.jwst_data.image_xsize
    ydata_end = info.jwst_data.image_ysize
    frame_image = fltarr(info.jwst_data.image_xsize,info.jwst_data.image_ysize)
    frame_image[*,*] = (*info.jwst_data.pimagedata)[i,j,*,*]
    if(info.jwst_image.default_scale_graph[1] eq 1) then begin    
        info.jwst_image.graph_range[1,0] = info.jwst_image.graph_range[0,0]
        info.jwst_image.graph_range[1,1] = info.jwst_image.graph_range[0,1]
    endif
endif

if(graphnum eq 3) then begin 
   if(info.jwst_image.plane eq 0) then begin 
      szoom = "Zoom Centered on Final Rate Image" 
      xdata_end = info.jwst_data.slope_xsize
      ydata_end = info.jwst_data.slope_ysize
      frame_image = fltarr(info.jwst_data.slope_xsize,info.jwst_data.slope_ysize)
      frame_image[*,*] = (*info.jwst_data.preduced)[*,*,0]
      if(info.jwst_image.default_scale_graph[1] eq 1) then begin
         info.jwst_image.graph_range[1,0] = info.jwst_image.graph_range[2,0]
         info.jwst_image.graph_range[1,1] = info.jwst_image.graph_range[2,1]
      endif
   endif

   if(info.jwst_image.plane eq 1) then begin 
      szoom = "Zoom Centered on Int Rate Image" 
      xdata_end = info.jwst_data.slope_xsize
      ydata_end = info.jwst_data.slope_ysize
      frame_image = fltarr(info.jwst_data.slope_xsize,info.jwst_data.slope_ysize)
      frame_image[*,*] = (*info.jwst_data.preducedint)[*,*,0]
      if(info.jwst_image.default_scale_graph[1] eq 1) then begin
         info.jwst_image.graph_range[1,0] = info.jwst_image.graph_range[2,0]
         info.jwst_image.graph_range[1,1] = info.jwst_image.graph_range[2,1]
      endif
   endif

   if(info.jwst_image.plane eq 2) then begin 
      szoom = "Zoom Centered on Cal Image" 
      xdata_end = info.jwst_data.slope_xsize
      ydata_end = info.jwst_data.slope_ysize
      frame_image = fltarr(info.jwst_data.slope_xsize,info.jwst_data.slope_ysize)
      frame_image[*,*] = (*info.jwst_data.preduced_cal)[*,*,0]
      if(info.jwst_image.default_scale_graph[1] eq 1) then begin
         info.jwst_image.graph_range[1,0] = info.jwst_image.graph_range[2,0]
         info.jwst_image.graph_range[1,1] = info.jwst_image.graph_range[2,1]
      endif
   endif
endif

x = info.jwst_image.x_zoom
y = info.jwst_image.y_zoom
; initialize the x and y pos to be the center of the image

info.jwst_image.x_zoom_pos = info.jwst_image.x_zoom
info.jwst_image.y_zoom_pos = info.jwst_image.y_zoom

widget_control,info.jwst_image.graph_label[1], set_value=szoom

xsize = info.jwst_plotsize1
ysize = info.jwst_plotsize1

xsize = xsize/zoom 
ysize = ysize/zoom

info.jwst_image.zoom_xplot_size = xsize
info.jwst_image.zoom_yplot_size = ysize

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

info.jwst_image.x_zoom_start = xstart
info.jwst_image.y_zoom_start = ystart
info.jwst_image.y_zoom_end = yend
info.jwst_image.x_zoom_end = xend

info.jwst_image.x_zoom_start_noref = xstart
info.jwst_image.x_zoom_end_noref = xend

;print,'in update zoom image',xstart,xend,ystart,yend
xrange = ixend-ixstart+1
yrange = iyend-iystart+1
sub_image = fltarr(xrange,yrange)
sub_image = frame_image[xstart:xend,ystart:yend]

stat_data = sub_image[ixstart:ixend,iystart:iyend]

x_zoom_start = ixstart
x_zoom_end = ixend
if(info.jwst_data.subarray eq 0) then begin
    xstart_new = xstart
    xend_new  = xend
    if(xstart lt 4) then xstart_new = 4
    if(xend gt 1027) then xend_new = 1027
    stat_noref = frame_image[xstart_new:xend_new,ystart:yend]
    info.jwst_image.x_zoom_start_noref = xstart_new
    info.jwst_image.x_zoom_end_noref = xend_new
    stat_data = 0
    stat_data = stat_noref
    stat_noref = 0
endif


jwst_get_image_stat,stat_data,image_mean,stdev_pixel,image_min,image_max,$
               irange_min,irange_max,image_median,stdev_mean
stat_data= 0
;_______________________________________________________________________
if ptr_valid (info.jwst_image.pzoomdata) then ptr_free,info.jwst_image.pzoomdata
info.jwst_image.pzoomdata = ptr_new(sub_image)

info.jwst_image.zoom_stat[0] = image_mean
info.jwst_image.zoom_stat[1] = stdev_pixel
info.jwst_image.zoom_stat[2] = image_min
info.jwst_image.zoom_stat[3] = image_max
info.jwst_image.zoom_stat[4] = image_median
info.jwst_image.zoom_stat[5] = stdev_mean
info.jwst_image.zoom_range[0] = irange_min
info.jwst_image.zoom_range[1] = irange_max

widget_control,info.jwst_image.graphID[1],draw_xsize = xrange*zoom,draw_ysize=yrange*zoom 

if(hcopy eq 0) then wset,info.jwst_image.pixmapID[1]

disp_image = congrid(sub_image, xsize*zoom,ysize*zoom)
disp_image = bytscl(disp_image,min=info.jwst_image.graph_range[1,0], $
                    max=info.jwst_image.graph_range[1,1],$
                    top=info.col_max-info.col_bits-1,/nan)

frame_image = 0 ; free memory
sub_image = 0
tv,disp_image,0,0,/device
if(hcopy eq 0) then begin 
    wset,info.jwst_image.draw_window_id[1]
    device,copy=[0,0,$
                 xsize*zoom,$
                 ysize*zoom, $
                 0,0,info.jwst_image.pixmapID[1]]
endif else begin
    stitle = szoom
    ftitle = "Frame #: " + strtrim(string(j+1),2) 
    ititle = "Integration #: " + strtrim(string(i+1),2)
    sstitle = info.jwst_control.filebase+'.fits'
    smean = strtrim(string(image_mean),2)
    smin = strtrim(string(image_min),2)
    smax = strtrim(string(image_max),2)
    mtitle = "Mean: " + smean 
    mintitle = "Min value: " + smin
    maxtitle = "Max value: " + smax
    xrg = "X pixel range: " + strtrim(string(xstart+1),2) + ' to ' + strtrim(string(xend+1),2)
    yrg = "Y pixel range: " + strtrim(string(ystart+1),2) + ' to ' + strtrim(string(yend+1),2)

    xyouts,0.75*!D.X_Vsize,0.95*!D.Y_VSize,sstitle,/device
    xyouts,0.75*!D.X_Vsize,0.90*!D.Y_VSize,stitle,/device
    xyouts,0.75*!D.X_Vsize,0.85*!D.Y_VSize,ftitle,/device
    xyouts,0.75*!D.X_Vsize,0.80*!D.Y_VSize,ititle,/device

    xyouts,0.75*!D.X_Vsize,0.75*!D.Y_VSize,mintitle,/device
    xyouts,0.75*!D.X_Vsize,0.70*!D.Y_VSize,maxtitle,/device
    xyouts,0.75*!D.X_Vsize,0.65*!D.Y_VSize,xrg,/device
    xyouts,0.75*!D.X_Vsize,0.60*!D.Y_VSize,yrg,/device

endelse
; update stats    
smean =  strcompress(string(image_mean),/remove_all)
smin = strcompress(string(image_min),/remove_all) 
smax = strcompress(string(image_max),/remove_all) 

scale_min = info.jwst_image.graph_range[1,0]
scale_max = info.jwst_image.graph_range[1,1]

widget_control,info.jwst_image.rlabelID[1,0],set_value=scale_min
widget_control,info.jwst_image.rlabelID[1,1],set_value=scale_max

widget_control,info.jwst_image.slabelID[1],set_value=('Mean: ' +smean) 
widget_control,info.jwst_image.mlabelID[1],set_value=(' Min: ' +smin + '   Max: ' +smax) 

; replot the pixel location
xvalue = (x - xstart + ixstart)*info.jwst_image.scale_zoom
yvalue = (y - ystart + iystart)*info.jwst_image.scale_zoom

info.jwst_image.ixstart_zoom = ixstart
info.jwst_image.xstart_zoom = xstart

info.jwst_image.iystart_zoom = iystart
info.jwst_image.ystart_zoom = ystart

pixelsize  = 1.0 * info.jwst_image.scale_zoom

info.jwst_image.x_zoom_plotpt = xvalue
info.jwst_image.y_zoom_plotpt = yvalue


halfpixelx = 0.5*  info.jwst_image.scale_zoom
halfpixely = 0.5 * info.jwst_image.scale_zoom

xx = fix(xvalue/info.jwst_image.scale_zoom)+0.5
yy = fix(yvalue/info.jwst_image.scale_zoom)+0.5

xx = xx * info.jwst_image.scale_zoom 
yy = yy * info.jwst_image.scale_zoom 


xpos1 = xx-halfpixelx
xpos2 = xx+halfpixelX

ypos1 = yy-halfpixely
ypos2 = yy+halfpixely

box_coords1 = [xpos1,xpos2,ypos1,ypos2]
plots,box_coords1[[0,0,1,1,0]],box_coords1[[2,3,3,2,2]],psym=0,/device

disp_image = 0

end


