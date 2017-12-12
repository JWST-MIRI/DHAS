;_______________________________________________________________________
;***********************************************************************
pro mrp_update_row_info,info
;_______________________________________________________________________

row = info.refp.row

i = info.refp.integrationNO
j = info.refp.rampNO

pleft = fltarr(4)
pright = fltarr(4)


pleft  = (*info.refpixel_data.prefpixelL)[i,j,*,row]

pright  = (*info.refpixel_data.prefpixelR)[i,j,*,row]
delta = pright  - pleft

slab = strarr(4)

;_______________________________________________________________________
for i = 0,3 do begin
    inum = strcompress(string(i+1),/remove_all)


    spleft =   strtrim(string(pleft[i],format="(f7.1)"),2) 
    spright =   strtrim(string(pright[i],format="(f7.1)"),2) 
    sdelta =   strtrim(string(delta[i],format="(f7.1)"),2) 
    if(info.data.subarray ne 0) then begin
        spright = 'NA'
        sdelta = 'NA'
    endif


    slab[i] = ' ' + inum + '         ' + $
              spleft +    '         ' +$
              spright +   '          ' +$
              sdelta
    widget_control,info.refp.clabelID[i],set_value = slab[i]
endfor

end

;_______________________________________________________________________
;***********************************************************************
pro mrp_update_pixel_location,x_pos,y_pos,info
save_color = info.col_table
color6
;_______________________________________________________________________
wset,info.refp.draw_window_id[0]

device,copy=[0,0,40,info.data.image_ysize, 0,0,info.refp.pixmapID[0]]
box_coords1 = [x_pos,(x_pos+1), y_pos,(y_pos+1)]
plots,box_coords1[[0,0,1,1,0]],box_coords1[[2,3,3,2,2]],psym=0,$
      /device,color=info.white
info.col_table = save_color

end

;_______________________________________________________________________
;***********************************************************************
pro mrp_update_refpixel,info
;_______________________________________________________________________
; check if default scale is true - then reset to orginal value
i = info.refp.integrationNO
j = info.refp.rampNO


loadct,info.col_table,/silent
pixelL  = (*info.refpixel_data.prefpixelL)[i,j,*,*]
pixelR  = (*info.refpixel_data.prefpixelR)[i,j,*,*]
range_min = (*info.refpixel_data.prange)(i,j,0)
range_max = (*info.refpixel_data.prange)(i,j,1)

rawmean = (*info.refpixel_data.pstat)(i,j,0)
min = (*info.refpixel_data.pstat)(i,j,2)
max = (*info.refpixel_data.pstat)(i,j,3)


    
if(info.refp.default_scale_graph[0] eq 1) then begin
    info.refp.graph_range[0,0] = range_min
    info.refp.graph_range[0,1] = range_max
endif



xsize_image = 40
ysize_image = info.data.image_ysize
refpixel = fltarr(40,ysize_image)
for i = 0,3 do begin 
    refpixel[i,*] =    pixelL[0,0,0,*]
    refpixel[i+4,*] =  pixelL[0,0,1,*]
    refpixel[i+8,*] =  pixelL[0,0,2,*]
    refpixel[i+12,*] = pixelL[0,0,3,*]
    ; gap of 8 pixels from 16 to 24
    refpixel[i+24,*] = pixelR[0,0,0,*]
    refpixel[i+28,*] = pixelR[0,0,1,*]
    refpixel[i+32,*] = pixelR[0,0,2,*]
    refpixel[i+36,*] = pixelR[0,0,3,*]
endfor

widget_control,info.refp.graphID[0],draw_xsize = xsize_image,draw_ysize=ysize_image 

wset,info.refp.pixmapID[0]
disp_image = congrid(refpixel,xsize_image,ysize_image)

scale_min = info.refp.graph_range[0,0]
scale_max = info.refp.graph_range[0,1]

disp_image = bytscl(disp_image,min=scale_min, max=scale_max,$
                    top=info.col_max-info.col_bits-1,/nan)
tv,disp_image,0,0,/device
frame_image = 0
wset,info.refp.draw_window_id[0]
device,copy=[0,0,xsize_image,ysize_image, 0,0,info.refp.pixmapID[0]]


widget_control,info.refp.rlabelID[0,0],set_value=scale_min
widget_control,info.refp.rlabelID[0,1],set_value=scale_max


smean =  strcompress(string(rawmean),/remove_all)
smin =  strcompress(string(min),/remove_all)
smax =  strcompress(string(max),/remove_all)

sinfo = 'Mean: ' + smean + '  Min: ' + smin + '   Max: ' + smax
widget_control,info.refp.mlabelID[0],set_value = sinfo



; replot the row location location

color6
x_pos = 20
y_pos = info.refp.row
box_coords1 = [x_pos,(x_pos+1), y_pos,(y_pos+1)]
plots,box_coords1[[0,0,1,1,0]],box_coords1[[2,3,3,2,2]],psym=0,$
      /device,color=255



end
