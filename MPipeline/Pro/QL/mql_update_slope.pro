; Plots the slope image for the Science Image display
; Plots a 1032 X 1024 image (includes reference output pixels)


pro mql_update_slope,info,ps=ps,eps=eps

loadct,info.col_table,/silent
hcopy = 0
if ( (keyword_set(ps)) or ( keyword_set(eps)) ) then hcopy = 1


slope_exist = info.data.slope_exist
if(slope_exist eq 0) then return

frame_image = fltarr(info.data.slope_xsize,info.data.slope_ysize)

;_______________________________________________________________________

if(slope_exist) then begin
    i = info.image.integrationNO
; if on Quicklook image: 
    if(info.image.default_scale_graph[2] eq 1) then begin
        info.image.graph_range[2,0] = info.data.reduced_stat[5,0]
        info.image.graph_range[2,1] = info.data.reduced_stat[6,0]
    endif

    frame_image[*,*] = (*info.data.preduced)[*,*,0]
    n_pixels = float( (info.data.slope_xsize) * (info.data.slope_ysize))
    indxs = where(finite(frame_image),n_pixels)

    mean = info.data.reduced_stat[0,0]
    min = info.data.reduced_stat[3,0]
    max = info.data.reduced_stat[4,0]


    smean =  strcompress(string(mean),/remove_all)
    smin = strcompress(string(min),/remove_all) 
    smax = strcompress(string(max),/remove_all) 

    ssmean = string('Mean: ' + smean )    
    sminmax = string(' Min: ' + smin + ' Max: ' + smax) 
endif


;_______________________________________________________________________
xsize_image = fix(info.data.slope_xsize/info.image.binfactor) 
ysize_image = fix(info.data.slope_ysize/info.image.binfactor)
widget_control,info.image.graphID[2],draw_xsize = xsize_image,draw_ysize=ysize_image 

; Display the image
if(hcopy eq 0) then wset,info.image.pixmapID[2]
disp_image = congrid(frame_image, $
                     xsize_image,ysize_image)

disp_image = bytscl(disp_image,min=info.image.graph_range[2,0], $
                    max=info.image.graph_range[2,1],$
                    top=info.col_max-info.col_bits -1 ,/nan)
tv,disp_image,0,0,/device
frame_image = 0
if(hcopy eq 0) then begin 
    wset,info.image.draw_window_id[2]
    device,copy=[0,0,xsize_image,$
                 ysize_image, $
                 0,0,info.image.pixmapID[2]]
endif

; update stats    


range1 = info.image.graph_range[2,0] 
range2 = info.image.graph_range[2,1] 

if(not slope_exist) then begin
	ssmean = '   Mean:  NA        '
        sminmax = '   Min and Max:  NA  '
        range1 = " NA"
        range2 = " NA"
endif



widget_control,info.image.slabelID[2], set_value=ssmean
widget_control,info.image.mlabelID[2],set_value=sminmax
widget_control,info.image.rlabelID[2,0],set_value=range1
widget_control,info.image.rlabelID[2,1],set_value=range2




if(hcopy eq 1) then begin 
    ssmean = string('Mean ' + smean)
    ssmin = strtrim(string(smin,format="(E10.2)"),2) 
    ssmax = strtrim(string(smax,format="(E10.2)"),2)
    svalue = "Slope Image"
    ititle = "Integration #: " + strtrim(string(i+1),2)
    sstitle = info.control.filebase+'.fits'
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

; info.image.x_pos,y_pos based on Raw image plot 1 
xvalue_raw = info.image.x_pos * info.image.binfactor
yvalue_raw = info.image.y_pos * info.image.binfactor

xvalue = xvalue_raw/info.image.binfactor
yvalue = yvalue_raw/info.image.binfactor

box_coords1 = [xvalue,(xvalue+1), $
               yvalue,(yvalue+1)]
box_coords2 = [xvalue+1,(xvalue+1)-1, $
               yvalue+1,(yvalue+1)-1]
plots,box_coords1[[0,0,1,1,0]],box_coords1[[2,3,3,2,2]],psym=0,/device,color=info.white

disp_image = 0

end
