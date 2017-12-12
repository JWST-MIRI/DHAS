pro mql_update_images,info,ps = ps,eps = eps
hcopy = 0
loadct,info.col_table,/silent
if ( (keyword_set(ps)) or ( keyword_set(eps)) ) then hcopy = 1

n_pixels = float( (info.data.image_xsize) * (info.data.image_ysize))

i = info.image.integrationNO
j = info.image.rampNO


if(info.data.read_all eq 0) then begin
    i = 0
    if(info.data.num_frames ne info.data.nramps) then begin 
        j = info.image.rampNO- info.control.frame_start
    endif
endif

; check if default scale is true - then reset to orginal value
if(info.image.default_scale_graph[0] eq 1) then begin
    info.image.graph_range[0,0] = info.image.range[0]
    info.image.graph_range[0,1] = info.image.range[1]
endif


frame_image = fltarr(info.data.image_xsize,info.data.image_ysize)
frame_image[*,*] = (*info.data.pimagedata)[i,j,*,*]


numbad = 0
if(info.image.apply_bad) then begin
   badpixel = (*info.badpixel.pmask) 
    index = where(badpixel and  1,numbad)
    if(numbad gt 0) then frame_image[index] = !values.F_NaN
    badpixel = 0 
endif

if(info.data.subarray eq 0) then begin
    frame_image[0:3,*] =  !values.F_NaN
    frame_image[1028:1031,*] =  !values.F_NaN
endif

stitle = ' '
sstitle = ' ' 

xsize_image = fix(info.data.image_xsize/info.image.binfactor) 
ysize_image = fix(info.data.image_ysize/info.image.binfactor)
widget_control,info.image.graphID[0],draw_xsize = xsize_image,draw_ysize=ysize_image 

if(hcopy eq 0 ) then wset,info.image.pixmapID[0]	

disp_image = congrid(frame_image, $
                     xsize_image,$
                     ysize_image)
disp_image = bytscl(disp_image,min=info.image.graph_range[0,0], $
                    max=info.image.graph_range[0,1],$
                    top=info.col_max-info.col_bits-1,/nan)
frame_image = 0
tv,disp_image,0,0,/device

if( hcopy eq 0) then begin  
    wset,info.image.draw_window_id[0]
    device,copy=[0,0,$
                 xsize_image,$
                 ysize_image, $
                 0,0,info.image.pixmapID[0]]
endif


; update stats    
mean = info.image.stat[0]
st = info.image.stat[1]
min = info.image.stat[2]
max = info.image.stat[3]


smean =  strcompress(string(mean),/remove_all)
smin = strcompress(string(min),/remove_all) 
smax = strcompress(string(max),/remove_all) 

scale_min = info.image.graph_range[0,0]
scale_max = info.image.graph_range[0,1]

widget_control,info.image.slabelID[0],set_value=('Mean: ' +smean) 
widget_control,info.image.mlabelID[0],set_value=(' Min: ' +smin + ' Max: ' +smax) 
widget_control,info.image.rlabelID[0,0],set_value=scale_min
widget_control,info.image.rlabelID[0,1],set_value=scale_max


if(hcopy eq 1) then begin 
    svalue = "Science Frame Image"
    ftitle = "Frame #: " + strtrim(string(j+1),2) 
    ititle = "Integration #: " + strtrim(string(i+1),2)
    sstitle = info.control.filebase+'.fits'
    mtitle = "Mean: " + smean 
    mintitle = "Min value: " + smin
    maxtitle = "Max value: " + smax

    xyouts,0.75*!D.X_Vsize,0.95*!D.Y_VSize,sstitle,/device
    xyouts,0.75*!D.X_Vsize,0.90*!D.Y_VSize,svalue,/device
    xyouts,0.75*!D.X_Vsize,0.85*!D.Y_VSize,ftitle,/device
    xyouts,0.75*!D.X_Vsize,0.80*!D.Y_VSize,ititle,/device
    xyouts,0.75*!D.X_Vsize,0.75*!D.Y_VSize,mtitle,/device
    xyouts,0.75*!D.X_Vsize,0.70*!D.Y_VSize,mintitle,/device
    xyouts,0.75*!D.X_Vsize,0.65*!D.Y_VSize,maxtitle,/device
endif



; replot the pixel location

box_coords1 = [info.image.x_pos,(info.image.x_pos+1), $
               info.image.y_pos,(info.image.y_pos+1)]
plots,box_coords1[[0,0,1,1,0]],box_coords1[[2,3,3,2,2]],psym=0,$
      /device,color=info.white


disp_image = 0
end
