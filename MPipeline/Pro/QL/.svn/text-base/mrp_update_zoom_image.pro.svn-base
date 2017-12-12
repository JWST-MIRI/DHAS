;_______________________________________________________________________
;***********************************************************************
pro mrp_draw_zoom_box,info
;_______________________________________________________________________

wset,info.refp.draw_window_id[0]

xstart_plot = 0
xend_plot = 39

ystart_plot = info.refp.zoom_start
yend_plot = info.refp.zoom_end
box_coords1 = [xstart_plot,xend_plot, $
               ystart_plot,yend_plot]
plots,box_coords1[[0,0,1,1,0]],box_coords1[[2,3,3,2,2]],psym=0,/device

end
;_______________________________________________________________________
;***********************************************************************
pro mrp_update_zoom_pixel_location,info
;_______________________________________________________________________
loadct,info.col_table,/silent
wset,info.refp.draw_window_id[1]
device,copy=[0,0,$
             275,$
             275, $
             0,0,info.refp.pixmapID[1]]

sc = 'Channel: '+ strcompress(string(info.refp.zoom_channel),/remove_all)
widget_control,info.refp.channelID,set_value = sc



i = info.refp.integrationNO
j = info.refp.rampNO
col = fix(info.refp.zoom_xpixel/25)
pleft = fltarr(4)
pright = fltarr(4)
svalue = 'NA'
if (col le 3 ) then begin
    value  = (*info.refpixel_data.prefpixelL)[i,j,col,info.refp.row]
    svalue = strcompress(string(value),/remove_all)
endif
if (col ge 7  ) then begin
    col = col -7 
    value  = (*info.refpixel_data.prefpixelR)[i,j,col,info.refp.row]
    svalue = strcompress(string(value),/remove_all)
endif

sc = 'Value: '+ svalue
widget_control,info.refp.valueID,set_value = sc


; if the x_pos and y_pos need to be determined (x and y plot
; screen value in  raw and slope plots) 
xcenter = info.refp.zoom_xpixel
ycenter = info.refp.zoom_ypixel



color6
box_coords1 = [xcenter,(xcenter+1), $
               ycenter,(ycenter+1)]
plots,box_coords1[[0,0,1,1,0]],box_coords1[[2,3,3,2,2]],psym=0,/device,color=info.white


end
;_______________________________________________________________________



;_______________________________________________________________________
;***********************************************************************
pro mrp_update_zoom_image,info,ps = ps,eps = eps
;_______________________________________________________________________
hcopy = 0
if ( (keyword_set(ps)) or ( keyword_set(eps)) ) then hcopy = 1
loadct,info.col_table,/silent

zoom = info.refp.scale_zoom

i = info.refp.integrationNO
j = info.refp.rampNO

yplotsize = 11
limit = info.data.image_ysize -yplotsize 

;print,'limit',limit
row = info.refp.row
istart = row -5
if(istart lt 0) then istart = 0
if(istart gt limit) then istart = limit
iend = istart + 10


info.refp.zoom_start = istart
info.refp.zoom_end = iend

;print,' zoom start and end ',istart,iend,row,row
i = info.refp.integrationNO
j = info.refp.rampNO

range_min = (*info.refpixel_data.prange)[i,j,0]
range_max = (*info.refpixel_data.prange)[i,j,1]

pixelL  = (*info.refpixel_data.prefpixelL)[i,j,*,*]
pixelR  = (*info.refpixel_data.prefpixelR)[i,j,*,*]


if(info.refp.default_scale_graph[1] eq 1) then begin    
    info.refp.graph_range[1,0] = range_min
    info.refp.graph_range[1,1] = range_max
endif


xsize_image = 40
ysize_image = 1024
refpixel = fltarr(11,11)
refpixel_stat = fltarr(8,11)
for ij = 0,3 do begin 
    refpixel[0,0:10] =    pixelL[0,0,0,istart:iend]
    refpixel[1,0:10] =    pixelL[0,0,1,istart:iend]
    refpixel[2,0:10] =    pixelL[0,0,2,istart:iend]
    refpixel[3,0:10] =    pixelL[0,0,3,istart:iend]
    ; gap 4 5 6
    refpixel[7,0:10] =    pixelR[0,0,0,istart:iend]
    refpixel[8,0:10] =    pixelR[0,0,1,istart:iend]
    refpixel[9,0:10] =    pixelR[0,0,2,istart:iend]
    refpixel[10,0:10] =    pixelR[0,0,3,istart:iend]
endfor
refpixel_stat[0:3,*] = refpixel[0:3,*]
refpixel_stat[4:7,*] = refpixel[7:10,*]




get_image_stat,refpixel_stat,image_mean,stdev_pixel,image_min,image_max,$
               irange_min,irange_max,image_median,stdev_mean,skew,ngood,nbad

;_______________________________________________________________________
info.refp.zoom_stat[0] = image_mean
info.refp.zoom_stat[1] = stdev_pixel
info.refp.zoom_stat[2] = image_min
info.refp.zoom_stat[3] = image_max
info.refp.zoom_stat[4] = image_median
info.refp.zoom_stat[5] = stdev_mean
info.refp.zoom_stat[6] = skew
info.refp.zoom_range[0] = irange_min
info.refp.zoom_range[1] = irange_max

widget_control,info.refp.graphID[1],draw_xsize=275,draw_ysize=275
     
if(hcopy eq 0) then wset,info.refp.pixmapID[1]
disp_image = congrid(refpixel,275,275)

scale_min = info.refp.graph_range[1,0]
scale_max = info.refp.graph_range[1,1]

disp_image = bytscl(disp_image,min=scale_min, max=scale_max,$
                    top=info.col_max-info.col_bits-1,/nan)


widget_control,info.refp.rlabelID[1,0],set_value=scale_min
widget_control,info.refp.rlabelID[1,1],set_value=scale_max

refpixel = 0 ; free memory
refpixel_stat  = 0

tv,disp_image,0,0,/device
if(hcopy eq 0) then begin 
    wset,info.refp.draw_window_id[1]
    device,copy=[0,0,$
                 275,$
                 275, $
                 0,0,info.refp.pixmapID[1]]
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

smean =  strcompress(string(image_mean),/remove_all)
smin = strcompress(string(image_min),/remove_all) 
smax = strcompress(string(image_max),/remove_all) 


widget_control,info.refp.mlabelID[1],set_value=('Mean: ' + smean + '  Min: ' +smin + '   Max: ' +smax) 



color6
; replot the pixel location
xcenter = 137.5
ycenter = 137.5
box_coords1 = [xcenter,(xcenter+1), $
               ycenter,(ycenter+1)]
plots,box_coords1[[0,0,1,1,0]],box_coords1[[2,3,3,2,2]],psym=0,/device,color=info.white

end


