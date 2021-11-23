;***********************************************************************
;_______________________________________________________________________
pro jwst_mcql_update_images,win,info,ps = ps,eps = eps
;_______________________________________________________________________
loadct,info.col_table,/silent
; data plane 0  rate or cal
; data plane 1  error
; data plane 2  dq
; data_type = 3 for  cal
; data_type = 1 for slope
data_plane = info.jwst_cal.plane[win]
data_type = info.jwst_cal.data_type[win]

;print,'data plane and data_type',win,data_plane, data_type
hcopy = 0
if ( (keyword_set(ps)) or ( keyword_set(eps)) ) then hcopy = 1
frame_image = fltarr(info.jwst_data.slope_xsize,info.jwst_data.slope_ysize)

if(data_type eq 3) then begin 
   stat = info.jwst_data.cal1_stat[*,data_plane]
   frame_image[*,*] = (*info.jwst_data.pcal1)[*,*,data_plane]
endif
if(data_type eq 1) then begin 
   stat = info.jwst_data.cal2_stat[*,data_plane]
   frame_image[*,*] = (*info.jwst_data.pcal2)[*,*,data_plane]
endif

hcopy = 0
if ( (keyword_set(ps)) or ( keyword_set(eps)) ) then hcopy = 1

mean = stat[0]
min = stat[3]
max = stat[4]

n_pixels = float( (info.jwst_data.slope_xsize) * (info.jwst_data.slope_ysize))
indxs = where(finite(frame_image),n_pixels)

xsize_image = fix(info.jwst_data.slope_xsize/info.jwst_cal.binfactor)
ysize_image = fix(info.jwst_data.slope_ysize/info.jwst_cal.binfactor)
widget_control,info.jwst_cal.graphID[win],draw_xsize = xsize_image,draw_ysize=ysize_image

; Display the image
if(hcopy eq 0 ) then wset,info.jwst_cal.pixmapID[win]	

disp_image = congrid(frame_image, $
                     xsize_image,ysize_image)

disp_image = bytscl(disp_image,min=info.jwst_cal.graph_range[win,0], $
                    max=info.jwst_cal.graph_range[win,1],top=info.col_max,/nan)
tv,disp_image,/device
if( hcopy eq 0) then begin  
    wset,info.jwst_cal.draw_window_id[win]
    device,copy=[0,0,xsize_image,ysize_image, $
                 0,0,info.jwst_cal.pixmapID[win]]
endif

smean =  strcompress(string(mean),/remove_all)
smin = strcompress(string(min),/remove_all) 
smax = strcompress(string(max),/remove_all) 

widget_control,info.jwst_cal.slabelID[win],set_value=('Mean: ' +smean) 
widget_control,info.jwst_cal.mlabelID[win],set_value=(' Min: ' +smin + ' Max: ' +smax) 


widget_control,info.jwst_cal.rlabelID[win,0],set_value=info.jwst_cal.graph_range[win,0]
widget_control,info.jwst_cal.rlabelID[win,1],set_value=info.jwst_cal.graph_range[win,1]
; replot the pixel location

box_coords1 = [info.jwst_cal.x_pos,(info.jwst_cal.x_pos+1), $
               info.jwst_cal.y_pos,(info.jwst_cal.y_pos+1)]

plots,box_coords1[[0,0,1,1,0]],box_coords1[[2,3,3,2,2]],psym=0,/device

if(hcopy eq 1) then begin 
    svalue = "Slope Image"
    ititle = "Integration #: " + strtrim(string(i+1),2)
    sstitle = info.control.filename_slope
    mtitle = "Mean: " + smean 
    mintitle = "Min value: " + smin
    maxtitle = "Max value: " + smax

    xyouts,0.75*!D.X_Vsize,0.95*!D.Y_VSize,sstitle,/device
    xyouts,0.75*!D.X_Vsize,0.90*!D.Y_VSize,svalue,/device
    xyouts,0.75*!D.X_Vsize,0.80*!D.Y_VSize,ititle,/device
    xyouts,0.75*!D.X_Vsize,0.75*!D.Y_VSize,mtitle,/device
    xyouts,0.75*!D.X_Vsize,0.70*!D.Y_VSize,mintitle,/device
    xyouts,0.75*!D.X_Vsize,0.65*!D.Y_VSize,maxtitle,/device
endif

frame_image = 0
disp_image = 0

end
