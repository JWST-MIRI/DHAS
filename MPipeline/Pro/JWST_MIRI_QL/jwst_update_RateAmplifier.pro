pro jwst_grab_RateAmplifier_images,info
loadct,info.col_table,/silent
zoom = info.jwst_AmpRate.zoom

if(info.jwst_AmpRate.zoom eq 1) then widget_control,info.jwst_AmpRate.zoom_labelID,set_droplist_select =0 
if(info.jwst_AmpRate.zoom eq 2) then widget_control,info.jwst_AmpRate.zoom_labelID,set_droplist_select =1 
if(info.jwst_AmpRate.zoom eq 4) then widget_control,info.jwst_AmpRate.zoom_labelID,set_droplist_select =2 
if(info.jwst_AmpRate.zoom eq 8) then widget_control,info.jwst_AmpRate.zoom_labelID,set_droplist_select =3 
if(info.jwst_AmpRate.zoom eq 16) then widget_control,info.jwst_AmpRate.zoom_labelID,set_droplist_select =4 
x = info.jwst_AmpRate.xposfull
y = info.jwst_AmpRate.yposfull

if(zoom eq 1) then begin
    x = info.jwst_data.image_xsize/8
    y = info.jwst_data.image_ysize/2
endif
xsize_org =  info.jwst_AmpRate.xplotsize
ysize_org =  info.jwst_AmpRate.yplotsize

if(zoom eq 1) then begin 
  xsize = xsize_org
  ysize = ysize_org
endif
if(zoom eq 2) then begin
  xsize = xsize_org/2
  ysize = ysize_org/2
endif
if(zoom eq 4) then begin
  xsize = xsize_org/4
  ysize = ysize_org/4
endif
if(zoom eq 8) then begin
  xsize = xsize_org/8
  ysize = ysize_org/8
endif
if(zoom eq 16) then begin
  xsize = xsize_org/16
  ysize = ysize_org/16
endif

; ixstart and iystart are the starting points for the zoom image
; xstart and ystart are the starting points for the orginal image

xdata_end = info.jwst_data.slope_xsize/4	
ydata_end = info.jwst_data.slope_ysize
xstart = fix(x - xsize/2)
ystart = fix(y - ysize/2)
if(xstart lt 0) then xstart = 0
if(ystart lt 0) then ystart = 0
xend  = xstart + xsize -1
yend  = ystart + ysize -1

if(xend ge xdata_end) then begin
    xend =  xdata_end -1
    xstart = xend - (xsize) +1
endif
if(yend ge ydata_end) then begin
    yend = ydata_end -1
    ystart = yend- (ysize) +1
endif

if(xstart lt 0) then xstart = 0
if(ystart lt 0) then ystart = 0
ix = xend - xstart
iy = yend - ystart

ixstart = 0
iystart = 0
ixend = ixstart + ix
iyend = iystart + iy

info.jwst_AmpRate.ixstart_zoom = ixstart
info.jwst_AmpRate.xstart_zoom = xstart

info.jwst_AmpRate.iystart_zoom = iystart
info.jwst_AmpRate.ystart_zoom = ystart

info.jwst_AmpRate.yend_zoom = yend
info.jwst_AmpRate.xend_zoom = xend

for graphno = 0,3 do begin 
    frame_image = (*info.jwst_AmpRate_image[graphno].pdata)
    sub_image = fltarr(xsize,ysize)   
    sub_image[ixstart:ixend,iystart:iyend] = frame_image[xstart:xend,ystart:yend]

    if(ixend+1 lt xsize) then sub_image[ixend+1:xsize-1,*] = !values.F_NaN
    if(iyend+1 lt ysize) then sub_image[*,iyend+1:ysize-1] = !values.F_NaN

    data_noref = sub_image

    xstart_new = xstart
    xend_new  = xend
    if(xstart eq 0 and info.jwst_data.colstart eq 1 ) then xstart_new = 1 
    if(xend eq 257 and info.jwst_data.subarray eq 0) then xend_new = 256 ; full array
    data_noref = frame_image[xstart_new:xend_new,ystart:yend]
    jwst_get_image_stat,data_noref,image_mean,stdev_pixel,image_min,image_max,$
                   irange_min,irange_max,image_median,stdev_mean
;_______________________________________________________________________
   if ptr_valid (info.jwst_AmpRate_image[graphno].psubdata) then $
     ptr_free,info.jwst_AmpRate_image[graphno].psubdata
    info.jwst_AmpRate_image[graphno].psubdata = ptr_new(sub_image)

    if ptr_valid (info.jwst_AmpRate_image[graphno].psubdata_noref) then $
      ptr_free,info.jwst_AmpRate_image[graphno].psubdata_noref
    info.jwst_AmpRate_image[graphno].psubdata_noref = ptr_new(data_noref)

    data_noref = 0
   info.jwst_AmpRate_image[graphno].sd_mean  = image_mean
   info.jwst_AmpRate_image[graphno].sd_stdev  = stdev_pixel
   info.jwst_AmpRate_image[graphno].sd_median  = image_median
   info.jwst_AmpRate_image[graphno].sd_min  = image_min
   info.jwst_AmpRate_image[graphno].sd_max  = image_max
   info.jwst_AmpRate_image[graphno].sd_range_max  = irange_max
   info.jwst_AmpRate_image[graphno].sd_range_min  = irange_min
   info.jwst_AmpRate_image[graphno].sd_stdev_mean  = stdev_mean
   info.jwst_AmpRate_image[graphno].sd_ximage_range[0] = xstart+1
   info.jwst_AmpRate_image[graphno].sd_ximage_range[1] = xend+1

   info.jwst_AmpRate_image[graphno].sd_yimage_range[0] = ystart+1
   info.jwst_AmpRate_image[graphno].sd_yimage_range[1] = yend+1
endfor

frame_image = 0                 ; free memory
sub_image = 0
end
;_______________________________________________________________________

pro jwst_update_RateAmplifier,graphno,info,ps = ps, eps = eps

hcopy = 0
if ( (keyword_set(ps)) or ( keyword_set(eps)) ) then hcopy = 1

xsize_org =  info.jwst_AmpRate.xplotsize
ysize_org =  info.jwst_AmpRate.yplotsize
sub_image = (*info.jwst_AmpRate_image[graphno].psubdata)

mean = info.jwst_AmpRate_image[graphno].sd_mean
st = info.jwst_AmpRate_image[graphno].sd_stdev
min = info.jwst_AmpRate_image[graphno].sd_min
max = info.jwst_AmpRate_image[graphno].sd_max

index = info.jwst_AmpRate.scalechannel-1
if(index eq 4) then index = graphno ; scale to each Amplifier
range_max = info.jwst_AmpRate_image[index].sd_range_max
range_min = info.jwst_AmpRate_image[index].sd_range_min

info.jwst_AmpRate.graph_range[graphno,0] = info.jwst_AmpRate.graph_range[index,0]
info.jwst_AmpRate.graph_range[graphno,1] = info.jwst_AmpRate.graph_range[index,1]

; check if default scale is true - then reset to orginal value
if(info.jwst_AmpRate.default_scale[index] eq 1) then begin
    info.jwst_AmpRate.graph_range[graphno,0] = range_min
    info.jwst_AmpRate.graph_range[graphno,1] = range_max
endif

min_scale = info.jwst_AmpRate.graph_range[graphno,0]
max_scale = info.jwst_AmpRate.graph_range[graphno,1]
if( finite(min_scale) eq 0) then min_scale =0
if(finite(max_scale) eq 0) then max_scale = 1
if(hcopy eq 0 ) then wset,info.jwst_AmpRate.pixmapID[graphno]
disp_image = congrid(sub_image, xsize_org,ysize_org)
disp_image = bytscl(disp_image,min= min_scale, $
                    max=max_scale,$
                    top=info.col_max-info.col_bits-1,/nan)

;_______________________________________________________________________
; Plot to screen
if(hcopy eq 0) then begin 
    tv,disp_image,0,0,/device
    wset,info.jwst_AmpRate.draw_window_id[graphno]
    device,copy=[0,0,$
             xsize_org,$
             ysize_org, $
             0,0,info.jwst_AmpRate.pixmapID[graphno]]
endif

;_______________________________________________________________________
; plot to output device
if(hcopy eq 1) then begin
    if(graphno eq 0) then begin
        simage = size(disp_image)
        xs = (simage[1] + 5 ) *5
        ys = simage[2]
        
        plot_image = fltarr(xs,ys)
        plot_image[0:simage[1]-1,*] = disp_image
        if ptr_valid (info.jwst_AmpRate.pplot_image) then ptr_free,info.jwst_AmpRate.pplot_image
        info.jwst_AmpRate.pplot_image = ptr_new(plot_image)
        plot_image = 0
    endif
    if(graphno gt 0) then begin
        simage = size(disp_image)
        ix = (simage[1]+5) * graphno
        plot_image = (*info.jwst_AmpRate.pplot_image)
        plot_image[ix:ix+simage[1]-1,*] = disp_image
;        if ptr_valid (info.jwst_AmpRate.pplot_image) then ptr_free,info.jwst_AmpRate.pplot_image
        ptr_free,info.jwst_AmpRate.pplot_image
        info.jwst_AmpRate.pplot_image = ptr_new(plot_image)
        plot_image = 0
    endif
endif
;_______________________________________________________________________
sub_image = 0

; update stats    
smean =  strcompress(string(mean),/remove_all)
smin = strcompress(string(min),/remove_all) 
smax = strcompress(string(max),/remove_all) 

scale_min = info.jwst_AmpRate.graph_range[graphno,0]
scale_max = info.jwst_AmpRate.graph_range[graphno,1]

widget_control,info.jwst_AmpRate.slabelID[graphno],set_value=('Mean: ' +smean) 
widget_control,info.jwst_AmpRate.mlabelID[graphno],set_value=(' Min: ' +smin + '  Max:' +smax) 
widget_control,info.jwst_AmpRate.rlabelID[graphno,0],set_value=scale_min
widget_control,info.jwst_AmpRate.rlabelID[graphno,1],set_value=scale_max

scale_name = ['Amp 1','Amp 2','Amp 3', 'Amp 4']

if(index ne 4) then begin
    if(index ne graphno) then begin
        widget_control,info.jwst_AmpRate.recomputeID[graphno],set_value=scale_name[index]
        widget_control,info.jwst_AmpRate.recomputeID[graphno],set_value=scale_name[index]
    endif
endif

end
