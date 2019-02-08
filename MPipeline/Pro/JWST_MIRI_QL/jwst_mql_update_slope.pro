; Plots the slope image for the Science Image display
; Plots a 1032 X 1024 image (includes reference output pixels)


pro jwst_mql_update_slope,info,ps=ps,eps=eps

loadct,info.col_table,/silent
hcopy = 0
if ( (keyword_set(ps)) or ( keyword_set(eps)) ) then hcopy = 1

;plane = 0 final rate image
;plate = 1 rate int image
if(info.jwst_control.file_slope_exist eq 0) then return

frame_image = fltarr(info.jwst_data.slope_xsize,info.jwst_data.slope_ysize)

if(info.jwst_image.plane eq 0) then begin
   slope_exist = info.jwst_control.file_slope_exist
   if(slope_exist eq 0) then return
   if(slope_exist eq 1) then begin
      frame_image[*,*] = (*info.jwst_data.preduced)[*,*,0]
      stat = info.jwst_data.reduced_stat
   endif
endif else  begin
   slope_exist = info.jwst_control.file_slope_int_exist
   if(slope_exist eq 0) then return
   if(slope_exist eq 1) then begin
      frame_image[*,*] = (*info.jwst_data.preducedint)[*,*,0] 
      stat = info.jwst_data.reducedint_stat
   endif
endelse

;_______________________________________________________________________
;i = info.jwst_image.integrationNO

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
xsize_image = fix(info.jwst_data.slope_xsize/info.jwst_image.binfactor) 
ysize_image = fix(info.jwst_data.slope_ysize/info.jwst_image.binfactor)
widget_control,info.jwst_image.graphID[2],draw_xsize = xsize_image,draw_ysize=ysize_image 

; Display the image
if(hcopy eq 0) then wset,info.jwst_image.pixmapID[2]
disp_image = congrid(frame_image, $
                     xsize_image,ysize_image)

disp_image = bytscl(disp_image,min=info.jwst_image.graph_range[2,0], $
                    max=info.jwst_image.graph_range[2,1],$
                    top=info.col_max-info.col_bits -1 ,/nan)
tv,disp_image,0,0,/device
frame_image = 0
if(hcopy eq 0) then begin 
    wset,info.jwst_image.draw_window_id[2]
    device,copy=[0,0,xsize_image,$
                 ysize_image, $
                 0,0,info.jwst_image.pixmapID[2]]
endif

; update stats    

range1 = info.jwst_image.graph_range[2,0] 
range2 = info.jwst_image.graph_range[2,1] 

if(slope_exist eq 0 ) then begin
	ssmean = '   Mean:  NA        '
        sminmax = '   Min and Max:  NA  '
        range1 = " NA"
        range2 = " NA"
endif

widget_control,info.jwst_image.slabelID[2], set_value=ssmean
widget_control,info.jwst_image.mlabelID[2],set_value=sminmax
widget_control,info.jwst_image.rlabelID[2,0],set_value=range1
widget_control,info.jwst_image.rlabelID[2,1],set_value=range2

if(hcopy eq 1) then begin 
    ssmean = string('Mean ' + smean)
    ssmin = strtrim(string(smin,format="(E10.2)"),2) 
    ssmax = strtrim(string(smax,format="(E10.2)"),2)
    svalue = "Slope Image"
    ititle = "Integration #: " + strtrim(string(i+1),2)
    sstitle = info.jwst_control.filebase+'.fits'
    mintitle = "Min value: " + ssmin
    maxtitle = "Max value: " + ssmax
    

    xyouts,0.75*!D.X_Vsize,0.95*!D.Y_VSize,sstitle,/device
    xyouts,0.75*!D.X_Vsize,0.90*!D.Y_VSize,svalue,/device
    xyouts,0.75*!D.X_Vsize,0.85*!D.Y_VSize,ititle,/device
    xyouts,0.75*!D.X_Vsize,0.80*!D.Y_VSize,ssmean,/device
    xyouts,0.75*!D.X_Vsize,0.75*!D.Y_VSize,mintitle,/device
    xyouts,0.75*!D.X_Vsize,0.70*!D.Y_VSize,maxtitle,/device
endif
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

end
