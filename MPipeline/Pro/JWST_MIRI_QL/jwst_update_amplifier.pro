pro jwst_grab_amplifier_images,info
; Fills in the Channel Data. Which can be full channels or zoomed channels

loadct,info.col_table,/silent
;print,' Loading the sub image into channel structure ' 
zoom = float(info.jwst_AmpFrame.zoom)


if(info.jwst_AmpFrame.zoom eq 1) then widget_control,info.jwst_AmpFrame.zoom_labelID,set_droplist_select =0 
if(info.jwst_AmpFrame.zoom eq 2) then widget_control,info.jwst_AmpFrame.zoom_labelID,set_droplist_select =1 
if(info.jwst_AmpFrame.zoom eq 4) then widget_control,info.jwst_AmpFrame.zoom_labelID,set_droplist_select =2 
if(info.jwst_AmpFrame.zoom eq 8) then widget_control,info.jwst_AmpFrame.zoom_labelID,set_droplist_select =3 
if(info.jwst_AmpFrame.zoom eq 16) then widget_control,info.jwst_AmpFrame.zoom_labelID,set_droplist_select =4 

x = info.jwst_AmpFrame.xposfull
y = info.jwst_AmpFrame.yposfull

if(zoom eq 1) then begin
    x = info.jwst_data.image_xsize/8
    y = info.jwst_data.image_ysize/2
endif


xsize_org =  info.jwst_AmpFrame.xplotsize
ysize_org =  info.jwst_AmpFrame.yplotsize

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

xdata_end = info.jwst_data.image_xsize/4	
ydata_end = info.jwst_data.image_ysize

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

info.jwst_AmpFrame.ixstart_zoom = ixstart
info.jwst_AmpFrame.xstart_zoom = xstart

info.jwst_AmpFrame.iystart_zoom = iystart
info.jwst_AmpFrame.ystart_zoom = ystart

info.jwst_AmpFrame.yend_zoom = yend
info.jwst_AmpFrame.xend_zoom = xend


for graphno = 0,4 do begin 
    frame_image = (*info.jwst_AmpFrame_image[graphno].pdata)
    sub_image = fltarr(xsize,ysize)   


    sub_image[ixstart:ixend,iystart:iyend] = frame_image[0,xstart:xend,ystart:yend]


    if(ixend+1 lt xsize) then sub_image[ixend+1:xsize-1,*] = !values.F_NaN
    if(iyend+1 lt ysize) then sub_image[*,iyend+1:ysize-1] = !values.F_NaN

    data_noref = sub_image
    
    xstart_new = xstart
    xend_new  = xend
    if(xstart eq 0 and info.jwst_data.colstart eq 1 ) then xstart_new = 1 
    if(xend eq 257 and info.jwst_data.subarray eq 0) then xend_new = 256 ; full array
    data_noref = frame_image[0,xstart_new:xend_new,ystart:yend]

    jwst_get_image_stat,data_noref,image_mean,stdev_pixel,image_min,image_max,$
                   irange_min,irange_max,image_median,stdev_mean




;_______________________________________________________________________
   if ptr_valid (info.jwst_AmpFrame_image[graphno].psubdata) then $
     ptr_free,info.jwst_AmpFrame_image[graphno].psubdata
    info.jwst_AmpFrame_image[graphno].psubdata = ptr_new(sub_image)


   if ptr_valid (info.jwst_AmpFrame_image[graphno].psubdata_noref) then $
     ptr_free,info.jwst_AmpFrame_image[graphno].psubdata_noref
    info.jwst_AmpFrame_image[graphno].psubdata_noref = ptr_new(data_noref)

    data_noref = 0
   info.jwst_AmpFrame_image[graphno].sd_mean  = image_mean
   info.jwst_AmpFrame_image[graphno].sd_stdev  = stdev_pixel
   info.jwst_AmpFrame_image[graphno].sd_median  = image_median

   info.jwst_AmpFrame_image[graphno].sd_min  = image_min
   info.jwst_AmpFrame_image[graphno].sd_max  = image_max
   info.jwst_AmpFrame_image[graphno].sd_range_max  = irange_max
   info.jwst_AmpFrame_image[graphno].sd_range_min  = irange_min
   info.jwst_AmpFrame_image[graphno].sd_stdev_mean  = stdev_mean
   info.jwst_AmpFrame_image[graphno].sd_ximage_range[0] = xstart+1
   info.jwst_AmpFrame_image[graphno].sd_ximage_range[1] = xend+1

   info.jwst_AmpFrame_image[graphno].sd_yimage_range[0] = ystart+1
   info.jwst_AmpFrame_image[graphno].sd_yimage_range[1] = yend+1

   
endfor

frame_image = 0                 ; free memory
sub_image = 0
stat_data_noref  = 0

end
;_______________________________________________________________________
;***********************************************************************
;_______________________________________________________________________

pro jwst_update_Amplifier,graphno,info,ps = ps, eps = eps

hcopy = 0
if ( (keyword_set(ps)) or ( keyword_set(eps)) ) then hcopy = 1

xsize_org =  info.jwst_AmpFrame.xplotsize
ysize_org =  info.jwst_AmpFrame.yplotsize

iframe = info.jwst_AmpFrame_image[0].igroup
jintegration = info.jwst_AmpFrame_image[0].jintegration


sub_image = (*info.jwst_AmpFrame_image[graphno].psubdata)

    
mean = info.jwst_AmpFrame_image[graphno].sd_mean
st = info.jwst_AmpFrame_image[graphno].sd_stdev
min = info.jwst_AmpFrame_image[graphno].sd_min
max = info.jwst_AmpFrame_image[graphno].sd_max


index = info.jwst_AmpFrame.scalechannel-1
if(index eq 5) then index = graphno


range_max = info.jwst_AmpFrame_image[index].sd_range_max
range_min = info.jwst_AmpFrame_image[index].sd_range_min


info.jwst_AmpFrame.graph_range[graphno,0] = info.jwst_AmpFrame.graph_range[index,0]
info.jwst_AmpFrame.graph_range[graphno,1] = info.jwst_AmpFrame.graph_range[index,1]



; check if default scale is true - then reset to orginal value
if(info.jwst_AmpFrame.default_scale[index] eq 1) then begin
    info.jwst_AmpFrame.graph_range[graphno,0] = range_min
    info.jwst_AmpFrame.graph_range[graphno,1] = range_max
endif



if(hcopy eq 0 ) then wset,info.jwst_AmpFrame.pixmapID[graphno]
disp_image = congrid(sub_image, xsize_org,ysize_org)
disp_image = bytscl(disp_image,min=info.jwst_AmpFrame.graph_range[graphno,0], $
                    max=info.jwst_AmpFrame.graph_range[graphno,1],$
                    top=info.col_max-info.col_bits-1,/nan)
;
;_______________________________________________________________________
; Plot to screen
if(hcopy eq 0) then begin 
    tv,disp_image,0,0,/device
    wset,info.jwst_AmpFrame.draw_window_id[graphno]
    device,copy=[0,0,$
             xsize_org,$
             ysize_org, $
             0,0,info.jwst_AmpFrame.pixmapID[graphno]]
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
        if ptr_valid (info.jwst_AmpFrame.pplot_image) then ptr_free,info.jwst_AmpFrame.pplot_image
        info.jwst_AmpFrame.pplot_image = ptr_new(plot_image)
        plot_image = 0
    endif
    if(graphno gt 0) then begin
        simage = size(disp_image)
        ix = (simage[1]+5) * graphno
        plot_image = (*info.jwst_AmpFrame.pplot_image)
        plot_image[ix:ix+simage[1]-1,*] = disp_image
;        if ptr_valid (info.channel.pplot_image) then ptr_free,info.channel.pplot_image
        ptr_free,info.jwst_AmpFrame.pplot_image
        info.jwst_AmpFrame.pplot_image = ptr_new(plot_image)
        plot_image = 0
    endif
endif
;_______________________________________________________________________
sub_image = 0


; update stats    
smean =  strcompress(string(mean),/remove_all)
smin = strcompress(string(min),/remove_all) 
smax = strcompress(string(max),/remove_all) 

scale_min = info.jwst_AmpFrame.graph_range[graphno,0]
scale_max = info.jwst_AmpFrame.graph_range[graphno,1]

widget_control,info.jwst_AmpFrame.slabelID[graphno],set_value=('Mean: ' +smean) 
widget_control,info.jwst_AmpFrame.mlabelID[graphno],set_value=(' Min: ' +smin + '  Max: ' +smax) 
widget_control,info.jwst_AmpFrame.rlabelID[graphno,0],set_value=scale_min
widget_control,info.jwst_AmpFrame.rlabelID[graphno,1],set_value=scale_max


scale_name = ['Amp 1','Amp 2','Amp 3', 'Amp 4', 'Amp 5']
if(index ne 5) then begin
    if(index ne graphno) then begin
        widget_control,info.jwst_AmpFrame.recomputeID[graphno],set_value=scale_name[index]
        widget_control,info.jwst_AmpFrame.recomputeID[graphno],set_value=scale_name[index]
    endif
endif


end
;***********************************************************************
