pro jwst_mql_update_images,info

loadct,info.col_table,/silent

n_pixels = float( (info.jwst_data.image_xsize) * (info.jwst_data.image_ysize))

i = info.jwst_image.integrationNO
j = info.jwst_image.frameNO

if(info.jwst_data.read_all eq 0) then begin
    i = 0
    if(info.jwst_data.num_frames ne info.jwst_data.ngroups) then begin 
        j = info.jwst_image.frameNO- info.jwst_control.frame_start
    endif
endif

; check if default scale is true - then reset to orginal value
if(info.jwst_image.default_scale_graph[0] eq 1) then begin
    info.jwst_image.graph_range[0,0] = info.jwst_image.range[0]
    info.jwst_image.graph_range[0,1] = info.jwst_image.range[1]
endif


frame_image = fltarr(info.jwst_data.image_xsize,info.jwst_data.image_ysize)
frame_image[*,*] = (*info.jwst_data.pimagedata)[i,j,*,*]


if(info.jwst_data.subarray eq 0) then begin
    frame_image[0:3,*] =  !values.F_NaN
    frame_image[1028:1031,*] =  !values.F_NaN
endif

stitle = ' '
sstitle = ' ' 

xsize_image = fix(info.jwst_data.image_xsize/info.jwst_image.binfactor) 
ysize_image = fix(info.jwst_data.image_ysize/info.jwst_image.binfactor)
widget_control,info.jwst_image.graphID[0],draw_xsize = xsize_image,draw_ysize=ysize_image 

wset,info.jwst_image.pixmapID[0]	

disp_image = congrid(frame_image, $
                     xsize_image,$
                     ysize_image)
disp_image = bytscl(disp_image,min=info.jwst_image.graph_range[0,0], $
                    max=info.jwst_image.graph_range[0,1],$
                    top=info.col_max-info.col_bits-1,/nan)
frame_image = 0
tv,disp_image,0,0,/device

wset,info.jwst_image.draw_window_id[0]
device,copy=[0,0,$
             xsize_image,$
             ysize_image, $
             0,0,info.jwst_image.pixmapID[0]]

; update stats    
mean = info.jwst_image.stat[0]
st = info.jwst_image.stat[1]
min = info.jwst_image.stat[2]
max = info.jwst_image.stat[3]

smean =  strcompress(string(mean),/remove_all)
smin = strcompress(string(min),/remove_all) 
smax = strcompress(string(max),/remove_all) 

scale_min = info.jwst_image.graph_range[0,0]
scale_max = info.jwst_image.graph_range[0,1]

widget_control,info.jwst_image.slabelID[0],set_value=('Mean: ' +smean) 
widget_control,info.jwst_image.mlabelID[0],set_value=(' Min: ' +smin + ' Max: ' +smax) 
widget_control,info.jwst_image.rlabelID[0,0],set_value=scale_min
widget_control,info.jwst_image.rlabelID[0,1],set_value=scale_max

; replot the pixel location
box_coords1 = [info.jwst_image.x_pos,(info.jwst_image.x_pos+1), $
               info.jwst_image.y_pos,(info.jwst_image.y_pos+1)]
plots,box_coords1[[0,0,1,1,0]],box_coords1[[2,3,3,2,2]],psym=0,$
      /device,color=info.white


disp_image = 0
end
