pro mql_grab_Channel_images,info
; Fills in the Channel Data. Which can be full channels or zoomed channels

loadct,info.col_table,/silent
;print,' Loading the sub image into channel structure ' 
zoom = float(info.channel.zoom)


if(info.Channel.zoom eq 1) then widget_control,info.Channel.zoom_labelID,set_droplist_select =0 
if(info.Channel.zoom eq 2) then widget_control,info.Channel.zoom_labelID,set_droplist_select =1 
if(info.Channel.zoom eq 4) then widget_control,info.Channel.zoom_labelID,set_droplist_select =2 
if(info.Channel.zoom eq 8) then widget_control,info.Channel.zoom_labelID,set_droplist_select =3 
if(info.Channel.zoom eq 16) then widget_control,info.Channel.zoom_labelID,set_droplist_select =4 

x = info.channel.xposfull
y = info.channel.yposfull


if(zoom eq 1) then begin
;    print, '  Reset to center'
    x = info.data.image_xsize/8
    y = info.data.image_ysize/2
endif


xsize_org =  info.Channel.xplotsize
ysize_org =  info.Channel.yplotsize


if(zoom eq 1) then begin 
  xsize = xsize_org
  ysize = ysize_org
endif
if(zoom eq 2) then begin
  xsize = xsize_org/zoom
  ysize = ysize_org/zoom
endif
if(zoom eq 4) then begin
  xsize = xsize_org/zoom
  ysize = ysize_org/zoom
endif
if(zoom eq 8) then begin
  xsize = xsize_org/zoom
  ysize = ysize_org/zoom
endif
if(zoom eq 16) then begin
  xsize = xsize_org/zoom
  ysize = ysize_org/zoom
endif


; ixstart and iystart are the starting points for the zoom image
; xstart and ystart are the starting points for the orginal image

xdata_end = info.data.image_xsize/4	
ydata_end = info.data.image_ysize



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
;;

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
;print,'xstart xend ',xstart,xend,xend-xstart
;print,'ystart yend ',ystart,yend,yend-ystart

info.channel.ixstart_zoom = ixstart
info.channel.xstart_zoom = xstart

info.channel.iystart_zoom = iystart
info.channel.ystart_zoom = ystart

info.channel.yend_zoom = yend
info.channel.xend_zoom = xend


for graphno = 0,4 do begin 
    frame_image = (*info.ChannelR[graphno].pdata)
    sub_image = fltarr(xsize,ysize)   


    sub_image[ixstart:ixend,iystart:iyend] = frame_image[0,xstart:xend,ystart:yend]


    if(ixend+1 lt xsize) then sub_image[ixend+1:xsize-1,*] = !values.F_NaN
    if(iyend+1 lt ysize) then sub_image[*,iyend+1:ysize-1] = !values.F_NaN

    sub_badpixel = sub_image
    sub_badpixel[*,*] = 0
    badpixel = (*info.ChannelR[graphno].pbadpixel)
    sub_badpixel[ixstart:ixend,iystart:iyend] = badpixel[0,xstart:xend,ystart:yend]
    index = where(sub_badpixel eq 1,nbadpixels)
    if(info.channel.apply_bad eq 1 and nbadpixels gt 0) then begin
         sub_image[index] = !values.F_NaN
    endif
    ngoodpixels = n_elements(sub_image)

    ngoodpixels = ngoodpixels - nbadpixels

    
    data_noref = sub_image
    
    xstart_new = xstart
    xend_new  = xend
    if(xstart eq 0 and info.data.colstart eq 1 ) then xstart_new = 1 
    if(xend eq 257 and info.data.subarray eq 0) then xend_new = 256 ; full array
    data_noref = frame_image[0,xstart_new:xend_new,ystart:yend]

    get_image_stat,data_noref,image_mean,stdev_pixel,image_min,image_max,$
                   irange_min,irange_max,image_median,stdev_mean,skew,ngood,nbad




;_______________________________________________________________________
   if ptr_valid (info.ChannelR[graphno].psubdata) then $
     ptr_free,info.ChannelR[graphno].psubdata
    info.ChannelR[graphno].psubdata = ptr_new(sub_image)

;   if ptr_valid (info.ChannelR[graphno].psubbadpixel) then $
;     ptr_free,info.ChannelR[graphno].psubbadpixel
;    info.ChannelR[graphno].psubbadpixel = ptr_new(sub_badpixel)


   if ptr_valid (info.ChannelR[graphno].psubdata_noref) then $
     ptr_free,info.ChannelR[graphno].psubdata_noref
    info.ChannelR[graphno].psubdata_noref = ptr_new(data_noref)

    data_noref = 0
   info.ChannelR[graphno].sd_mean  = image_mean
   info.ChannelR[graphno].sd_stdev  = stdev_pixel
   info.ChannelR[graphno].sd_median  = image_median
   info.ChannelR[graphno].sd_skew  = skew
   info.ChannelR[graphno].sd_ngood  = ngoodpixels
   info.ChannelR[graphno].sd_ngood  = ngood
   info.ChannelR[graphno].sd_nbad = nbadpixels
   info.ChannelR[graphno].sd_nbad = nbad

   info.ChannelR[graphno].sd_min  = image_min
   info.ChannelR[graphno].sd_max  = image_max
   info.ChannelR[graphno].sd_range_max  = irange_max
   info.ChannelR[graphno].sd_range_min  = irange_min
   info.ChannelR[graphno].sd_stdev_mean  = stdev_mean
   info.ChannelR[graphno].sd_ximage_range[0] = xstart+1
   info.ChannelR[graphno].sd_ximage_range[1] = xend+1

   info.ChannelR[graphno].sd_yimage_range[0] = ystart+1
   info.ChannelR[graphno].sd_yimage_range[1] = yend+1

   
endfor

frame_image = 0                 ; free memory
sub_image = 0
stat_data_noref  = 0

end
;_______________________________________________________________________
;***********************************************************************
;_______________________________________________________________________

pro mql_update_Channel,graphno,info,ps = ps, eps = eps

hcopy = 0
if ( (keyword_set(ps)) or ( keyword_set(eps)) ) then hcopy = 1

xsize_org =  info.Channel.xplotsize
ysize_org =  info.Channel.yplotsize

iramp = info.ChannelR[0].iramp
jintegration = info.ChannelR[0].jintegration


sub_image = (*info.ChannelR[graphno].psubdata)

    
mean = info.ChannelR[graphno].sd_mean
st = info.ChannelR[graphno].sd_stdev
min = info.ChannelR[graphno].sd_min
max = info.ChannelR[graphno].sd_max


index = info.Channel.scalechannel-1
if(index eq 5) then index = graphno


range_max = info.ChannelR[index].sd_range_max
range_min = info.ChannelR[index].sd_range_min


info.Channel.graph_range[graphno,0] = info.channel.graph_range[index,0]
info.Channel.graph_range[graphno,1] = info.channel.graph_range[index,1]



; check if default scale is true - then reset to orginal value
if(info.Channel.default_scale[index] eq 1) then begin
    info.Channel.graph_range[graphno,0] = range_min
    info.Channel.graph_range[graphno,1] = range_max
endif



if(hcopy eq 0 ) then wset,info.Channel.pixmapID[graphno]
disp_image = congrid(sub_image, xsize_org,ysize_org)
disp_image = bytscl(disp_image,min=info.Channel.graph_range[graphno,0], $
                    max=info.Channel.graph_range[graphno,1],$
                    top=info.col_max-info.col_bits-1,/nan)
;
;_______________________________________________________________________
; Plot to screen
if(hcopy eq 0) then begin 
    tv,disp_image,0,0,/device
    wset,info.Channel.draw_window_id[graphno]
    device,copy=[0,0,$
             xsize_org,$
             ysize_org, $
             0,0,info.Channel.pixmapID[graphno]]
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
        if ptr_valid (info.channel.pplot_image) then ptr_free,info.channel.pplot_image
        info.channel.pplot_image = ptr_new(plot_image)
        plot_image = 0
    endif
    if(graphno gt 0) then begin
        simage = size(disp_image)
        ix = (simage[1]+5) * graphno
        plot_image = (*info.channel.pplot_image)
        plot_image[ix:ix+simage[1]-1,*] = disp_image
;        if ptr_valid (info.channel.pplot_image) then ptr_free,info.channel.pplot_image
        ptr_free,info.channel.pplot_image
        info.channel.pplot_image = ptr_new(plot_image)
        plot_image = 0
    endif
endif
;_______________________________________________________________________
sub_image = 0


; update stats    
smean =  strcompress(string(mean),/remove_all)
smin = strcompress(string(min),/remove_all) 
smax = strcompress(string(max),/remove_all) 

scale_min = info.Channel.graph_range[graphno,0]
scale_max = info.Channel.graph_range[graphno,1]



widget_control,info.Channel.slabelID[graphno],set_value=('Mean: ' +smean) 
widget_control,info.Channel.mlabelID[graphno],set_value=(' Min: ' +smin + '  Max: ' +smax) 
widget_control,info.Channel.rlabelID[graphno,0],set_value=scale_min
widget_control,info.Channel.rlabelID[graphno,1],set_value=scale_max



scale_name = ['Chan 1','Chan 2','Chan 3', 'Chan 4', 'Chan 5']
if(index ne 5) then begin
    if(index ne graphno) then begin
        widget_control,info.channel.recomputeID[graphno],set_value=scale_name[index]
        widget_control,info.channel.recomputeID[graphno],set_value=scale_name[index]
    endif
endif


end
;***********************************************************************
