; Plots the slope image for the Science Image display
; Plots a 1032 X 1024 image (includes reference output pixels)

pro jwst_mql_update_slope,info

loadct,info.col_table,/silent

;plane = 0 final rate image
;plane = 1 rate int image
;plane = 2 cal image 
; set up default size
frame_image = fltarr(info.jwst_data.image_xsize,info.jwst_data.image_ysize)
file_exist = 0

if(info.jwst_image.plane eq 0) then begin
   file_exist = info.jwst_control.file_slope_exist
   if(file_exist eq 0) then begin
      frame_image[*,*] = 0
      stat = fltarr(8,3)
   endif
   if(file_exist eq 1) then begin
      frame_image[*,*] = (*info.jwst_data.preduced)[*,*,0]
      stat = info.jwst_data.reduced_stat
   endif
endif


if(info.jwst_image.plane eq 1) then  begin
   file_exist = info.jwst_control.file_slope_int_exist
   if(file_exist eq 0) then begin
      frame_image[*,*] = 0
      stat = fltarr(8,3)
   endif
   if(file_exist eq 1) then begin
      frame_image[*,*] = (*info.jwst_data.preducedint)[*,*,0] 
      stat = info.jwst_data.reducedint_stat
   endif
endif
if(info.jwst_image.plane eq 2) then  begin
   file_exist = info.jwst_control.file_cal_exist
   if(file_exist eq 0) then begin
      frame_image[*,*] = 0
      stat = fltarr(8,3)
   endif
   if(file_exist eq 1) then begin
      frame_image[*,*] = (*info.jwst_data.preduced_cal)[*,*,0] 
      stat = info.jwst_data.reduced_cal_stat
   endif
endif

;_______________________________________________________________________

if(info.jwst_image.default_scale_graph[2] eq 1) then begin
   info.jwst_image.graph_range[2,0] = stat[5,0]
   info.jwst_image.graph_range[2,1] = stat[6,0]
endif

n_pixels = float( (info.jwst_data.slope_xsize) * (info.jwst_data.slope_ysize))
indxs = where(finite(frame_image),n_pixels)

mean = stat[0,0]
min = stat[3,0]
max = stat[4,0]

smean =  strcompress(string(mean),/remove_all)
smin = strcompress(string(min),/remove_all) 
smax = strcompress(string(max),/remove_all) 

ssmean = string('Mean: ' + smean )    
sminmax = string(' Min: ' + smin + ' Max: ' + smax) 
;_______________________________________________________________________
;xsize_image = fix(info.jwst_data.slope_xsize/info.jwst_image.binfactor) 
;ysize_image = fix(info.jwst_data.slope_ysize/info.jwst_image.binfactor)

xsize_image = fix(info.jwst_data.image_xsize/info.jwst_image.binfactor) 
ysize_image = fix(info.jwst_data.image_ysize/info.jwst_image.binfactor)
widget_control,info.jwst_image.graphID[2],draw_xsize = xsize_image,draw_ysize=ysize_image 

; Display the image
wset,info.jwst_image.pixmapID[2]
disp_image = congrid(frame_image, $
                     xsize_image,ysize_image)

disp_image = bytscl(disp_image,min=info.jwst_image.graph_range[2,0], $
                    max=info.jwst_image.graph_range[2,1],$
                    top=info.col_max-info.col_bits -1 ,/nan)
tv,disp_image,0,0,/device
frame_image = 0

wset,info.jwst_image.draw_window_id[2]
device,copy=[0,0,xsize_image,$
             ysize_image, $
             0,0,info.jwst_image.pixmapID[2]]

; update stats    

range1 = info.jwst_image.graph_range[2,0] 
range2 = info.jwst_image.graph_range[2,1] 

if(file_exist eq 0 ) then begin
	ssmean = '   Mean:  NA        '
        sminmax = '   Min and Max:  NA  '
        range1 = " NA"
        range2 = " NA"
endif

widget_control,info.jwst_image.slabelID[2], set_value=ssmean
widget_control,info.jwst_image.mlabelID[2],set_value=sminmax
widget_control,info.jwst_image.rlabelID[2,0],set_value=range1
widget_control,info.jwst_image.rlabelID[2,1],set_value=range2

; replot the pixel location

; info.jwst_image.x_pos,y_pos based on Raw image plot 1 
xvalue_raw = info.jwst_image.x_pos * info.jwst_image.binfactor
yvalue_raw = info.jwst_image.y_pos * info.jwst_image.binfactor

xvalue = xvalue_raw/info.jwst_image.binfactor
yvalue = yvalue_raw/info.jwst_image.binfactor

box_coords1 = [xvalue,(xvalue+1), $
               yvalue,(yvalue+1)]
box_coords2 = [xvalue+1,(xvalue+1)-1, $
               yvalue+1,(yvalue+1)-1]
plots,box_coords1[[0,0,1,1,0]],box_coords1[[2,3,3,2,2]],psym=0,/device,color=info.white

disp_image = 0


; check if need update the zoom image. This zoom image plotting this
; window
if(info.jwst_image.graph_mpixel eq 3) then jwst_mql_update_zoom_image,info
end
