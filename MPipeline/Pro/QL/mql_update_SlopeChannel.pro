pro mql_grab_SlopeChannel_images,info
loadct,info.col_table,/silent
;print,' Loading the sub image into channel structure ' 
zoom = info.SlopeChannel.zoom


if(info.SlopeChannel.zoom eq 1) then widget_control,info.SlopeChannel.zoom_labelID,set_droplist_select =0 
if(info.SlopeChannel.zoom eq 2) then widget_control,info.SlopeChannel.zoom_labelID,set_droplist_select =1 
if(info.SlopeChannel.zoom eq 4) then widget_control,info.SlopeChannel.zoom_labelID,set_droplist_select =2 
if(info.SlopeChannel.zoom eq 8) then widget_control,info.SlopeChannel.zoom_labelID,set_droplist_select =3 
if(info.SlopeChannel.zoom eq 16) then widget_control,info.SlopeChannel.zoom_labelID,set_droplist_select =4 

x = info.SlopeChannel.xposfull
y = info.SlopeChannel.yposfull

;print,' In mql_update_SlopeChannel ', x,y
if(zoom eq 1) then begin
;    print, '  Reset to center'

    x = info.data.image_xsize/8
    y = info.data.image_ysize/2
endif
xsize_org =  info.SlopeChannel.xplotsize
ysize_org =  info.SlopeChannel.yplotsize

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

xdata_end = info.data.slope_xsize/4	
ydata_end = info.data.slope_ysize
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



;print,'ixstart, ixend ',ixstart,ixend
;print,'iystart, iyend ',iystart,iyend

;print,'xstart xend ',xstart,xend
;print,'ystart yend ',ystart,yend

info.SlopeChannel.ixstart_zoom = ixstart
info.SlopeChannel.xstart_zoom = xstart

info.SlopeChannel.iystart_zoom = iystart
info.SlopeChannel.ystart_zoom = ystart

info.SlopeChannel.yend_zoom = yend
info.SlopeChannel.xend_zoom = xend

for graphno = 0,4 do begin 
    frame_image = (*info.ChannelS[graphno].pdata)
    sub_image = fltarr(xsize,ysize)   
    sub_image[ixstart:ixend,iystart:iyend] = frame_image[xstart:xend,ystart:yend]

    if(ixend+1 lt xsize) then sub_image[ixend+1:xsize-1,*] = !values.F_NaN
    if(iyend+1 lt ysize) then sub_image[*,iyend+1:ysize-1] = !values.F_NaN

    data_noref = sub_image

    xstart_new = xstart
    xend_new  = xend
    if(xstart eq 0 and info.data.colstart eq 1 ) then xstart_new = 1 
    if(xend eq 257 and info.data.subarray eq 0) then xend_new = 256 ; full array
    data_noref = frame_image[xstart_new:xend_new,ystart:yend]



    get_image_stat,data_noref,image_mean,stdev_pixel,image_min,image_max,$
                   irange_min,irange_max,image_median,stdev_mean,skew,ngood,nbad


;_______________________________________________________________________
   if ptr_valid (info.ChannelS[graphno].psubdata) then $
     ptr_free,info.ChannelS[graphno].psubdata
    info.ChannelS[graphno].psubdata = ptr_new(sub_image)


    if ptr_valid (info.ChannelS[graphno].psubdata_noref) then $
      ptr_free,info.ChannelS[graphno].psubdata_noref
    info.ChannelS[graphno].psubdata_noref = ptr_new(data_noref)

    data_noref = 0
   info.ChannelS[graphno].sd_mean  = image_mean
   info.ChannelS[graphno].sd_stdev  = stdev_pixel
   info.ChannelS[graphno].sd_median  = image_median
   info.ChannelS[graphno].sd_skew  = skew
   info.ChannelS[graphno].sd_ngood  = ngood
   info.ChannelS[graphno].sd_nbad = nbad


   info.ChannelS[graphno].sd_min  = image_min
   info.ChannelS[graphno].sd_max  = image_max
   info.ChannelS[graphno].sd_range_max  = irange_max
   info.ChannelS[graphno].sd_range_min  = irange_min
   info.ChannelS[graphno].sd_stdev_mean  = stdev_mean
   info.ChannelS[graphno].sd_ximage_range[0] = xstart+1
   info.ChannelS[graphno].sd_ximage_range[1] = xend+1

   info.ChannelS[graphno].sd_yimage_range[0] = ystart+1
   info.ChannelS[graphno].sd_yimage_range[1] = yend+1

endfor

frame_image = 0                 ; free memory
sub_image = 0


end
;_______________________________________________________________________
;***********************************************************************
;_______________________________________________________________________

pro mql_update_SlopeChannel,graphno,info,ps = ps, eps = eps

hcopy = 0
if ( (keyword_set(ps)) or ( keyword_set(eps)) ) then hcopy = 1

xsize_org =  info.SlopeChannel.xplotsize
ysize_org =  info.SlopeChannel.yplotsize

iramp = info.ChannelS[0].iramp
jintegration = info.ChannelS[0].jintegration


sub_image = (*info.ChannelS[graphno].psubdata)


mean = info.ChannelS[graphno].sd_mean
st = info.ChannelS[graphno].sd_stdev
min = info.ChannelS[graphno].sd_min
max = info.ChannelS[graphno].sd_max


index = info.SlopeChannel.scalechannel-1
if(index eq 5) then index = graphno


range_max = info.ChannelS[index].sd_range_max
range_min = info.ChannelS[index].sd_range_min

info.SlopeChannel.graph_range[graphno,0] = info.Slopechannel.graph_range[index,0]
info.SlopeChannel.graph_range[graphno,1] = info.Slopechannel.graph_range[index,1]

; check if default scale is true - then reset to orginal value
if(info.SlopeChannel.default_scale[index] eq 1) then begin
    info.SlopeChannel.graph_range[graphno,0] = range_min
    info.SlopeChannel.graph_range[graphno,1] = range_max
endif


min_scale = info.SlopeChannel.graph_range[graphno,0]
max_scale = info.SlopeChannel.graph_range[graphno,1]
if( finite(min_scale) eq 0) then min_scale =0
if(finite(max_scale) eq 0) then max_scale = 1
if(hcopy eq 0 ) then wset,info.SlopeChannel.pixmapID[graphno]
disp_image = congrid(sub_image, xsize_org,ysize_org)
disp_image = bytscl(disp_image,min= min_scale, $
                    max=max_scale,$
                    top=info.col_max-info.col_bits-1,/nan)
;
;_______________________________________________________________________
; Plot to screen
if(hcopy eq 0) then begin 
    tv,disp_image,0,0,/device
    wset,info.SlopeChannel.draw_window_id[graphno]
    device,copy=[0,0,$
             xsize_org,$
             ysize_org, $
             0,0,info.SlopeChannel.pixmapID[graphno]]
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
        if ptr_valid (info.SlopeChannel.pplot_image) then ptr_free,info.SlopeChannel.pplot_image
        info.SlopeChannel.pplot_image = ptr_new(plot_image)
        plot_image = 0
    endif
    if(graphno gt 0) then begin
        simage = size(disp_image)
        ix = (simage[1]+5) * graphno
        plot_image = (*info.SlopeChannel.pplot_image)
        plot_image[ix:ix+simage[1]-1,*] = disp_image
;        if ptr_valid (info.SlopeChannel.pplot_image) then ptr_free,info.SlopeChannel.pplot_image
        ptr_free,info.SlopeChannel.pplot_image
        info.SlopeChannel.pplot_image = ptr_new(plot_image)
        plot_image = 0
    endif
endif
;_______________________________________________________________________
sub_image = 0


; update stats    
smean =  strcompress(string(mean),/remove_all)
smin = strcompress(string(min),/remove_all) 
smax = strcompress(string(max),/remove_all) 

scale_min = info.SlopeChannel.graph_range[graphno,0]
scale_max = info.SlopeChannel.graph_range[graphno,1]


widget_control,info.SlopeChannel.slabelID[graphno],set_value=('Mean: ' +smean) 
widget_control,info.SlopeChannel.mlabelID[graphno],set_value=(' Min: ' +smin + '  Max:' +smax) 
widget_control,info.SlopeChannel.rlabelID[graphno,0],set_value=scale_min
widget_control,info.SlopeChannel.rlabelID[graphno,1],set_value=scale_max

scale_name = ['Chan 1','Chan 2','Chan 3', 'Chan 4', 'Chan 5']

if(index ne 5) then begin
    if(index ne graphno) then begin
        widget_control,info.Slopechannel.recomputeID[graphno],set_value=scale_name[index]
        widget_control,info.Slopechannel.recomputeID[graphno],set_value=scale_name[index]
    endif
endif


end
;***********************************************************************
