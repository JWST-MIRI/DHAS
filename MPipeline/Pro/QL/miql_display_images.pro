;_______________________________________________________________________
;***********************************************************************
pro miql_quit,event
;_______________________________________________________________________
widget_control,event.top, Get_UValue = ginfo	
widget_control,ginfo.info.QuickLook,Get_Uvalue = info

;    print,'Exiting MIRI InspectImage'
wdelete,info.inspect.pixmapID
widget_control,info.inspectImage,/destroy

end
;_______________________________________________________________________
;***********************************************************************
;_______________________________________________________________________
;***********************************************************************
pro miql_event,event
;_______________________________________________________________________
Widget_Control,event.id,Get_uValue=event_name
widget_control,event.top, Get_UValue = ginfo	
widget_control,ginfo.info.QuickLook,Get_Uvalue = info

if (widget_info(event.id,/TLB_SIZE_EVENTS) eq 1 ) then begin

    info.inspect.xwindowsize = event.x
    info.inspect.ywindowsize = event.y
    info.inspect.uwindowsize = 1
    widget_control,event.top,set_uvalue = ginfo
    widget_control,ginfo.info.Quicklook,set_uvalue = info
    miql_display_images,info

    return
endif
    case 1 of
;_______________________________________________________________________

    (strmid(event_name,0,5) EQ 'print') : begin
        print_inspect_images,info
    end    
;_______________________________________________________________________
; scaling image
;_______________________________________________________________________
    (strmid(event_name,0,8) EQ 'sinspect') : begin
        if(info.inspect.default_scale_graph eq 0 ) then begin ; true - turn to false
            widget_control,info.inspect.image_recomputeID,set_value=' Image  Scale'
            info.inspect.default_scale_graph = 1
        endif

        miql_update_images,info
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info

    end
;_______________________________________________________________________
; change range of image graphs
; if change range then also change the scale button to 'User Set
; Scale'
;_______________________________________________________________________
    (strmid(event_name,0,3) EQ 'isr') : begin

        if(strmid(event_name,4,1) EQ 'b') then begin
            info.inspect.graph_range[0] = event.value
            widget_control,info.inspect.rlabelID[1],get_value = temp
            info.inspect.graph_range[1] = temp
        endif


        if(strmid(event_name,4,1) EQ 't') then begin
            info.inspect.graph_range[1] = event.value
            widget_control,info.inspect.rlabelID[0],get_value = temp
            info.inspect.graph_range[0] = temp
        endif
                        
        info.inspect.default_scale_graph = 0
        widget_control,info.inspect.image_recomputeID,set_value=' Default Scale'

        miql_update_images,info
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end

    
;_______________________________________________________________________
; Change limits

    (strmid(event_name,0,5) EQ 'limit') : begin

        if(strmid(event_name,6,1) EQ 'l') then begin
            info.inspect.limit_low = event.value

            widget_control,info.inspect.limit_highID,get_value = temp
            info.inspect.limit_high = temp
        endif


        if(strmid(event_name,6,1) EQ 'h') then begin
            info.inspect.limit_high = event.value
            widget_control,info.inspect.limit_lowID,get_value = temp
            info.inspect.limit_low = temp
        endif
        info.inspect.limit_low_default = 0
        info.inspect.limit_high_default = 0

        miql_update_images,info
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end

;_______________________________________________________________________e
; zoom images
;_______________________________________________________________________
   (strmid(event_name,0,4) EQ 'zoom') : begin

       zoom = fix(strmid(event_name,4,1))
       info.inspect.zoom = 2^zoom

         ; redefine the xpos and y pos value in new zoom window
         miql_update_images,info

         
         ; xposful, uposful - x,y location in full image
         ; x_pos, y_pos = x and y location on the image screen

         xpos_new = info.inspect.xposful -info.inspect.xstart_zoom 
         ypos_new = info.inspect.yposful -info.inspect.ystart_zoom
         info.inspect.x_pos = (xpos_new+0.5)*info.inspect.zoom_x
         info.inspect.y_pos = (ypos_new+0.5)*info.inspect.zoom
         miql_update_pixel_location,info
         for i = 0,5 do begin
             widget_control,info.inspect.zbutton[i],set_button = 0
         endfor
         widget_control,info.inspect.zbutton[zoom],set_button = 1


     end
;_______________________________________________________________________
; Select a different pixel
;_______________________________________________________________________
    (strmid(event_name,0,3) EQ 'pix') : begin
        xsize = info.data.image_xsize
        ysize = info.data.image_ysize
        xvalue = info.inspect.xposful
        yvalue = info.inspect.yposful
        xstart = xvalue
        ystart = yvalue


; ++++++++++++++++++++++++++++++
        if(strmid(event_name,4,1) eq 'x') then  begin
            xvalue = event.value ; event value - user input starts at 1 

            if(xvalue lt 1) then begin
                xvalue = 1
            endif
            if(xvalue gt xsize) then begin
                xvalue = xsize
            endif
            xvalue = xvalue -1
            ; check what is in y box 
            widget_control,info.inspect.pix_label[1],get_value =  ytemp
            yvalue = ytemp
            if(yvalue lt 1) then begin
                yvalue = 1
            endif
            if(yvalue gt ysize) then begin
                yvalue = ysize
            endif
            
            yvalue = float(yvalue)-1
        endif
        if(strmid(event_name,4,1) eq 'y') then begin
            yvalue = event.value ; event value - user input starts at 1
            if(yvalue lt 1) then begin
                yvalue = 1
            endif
            if(yvalue gt ysize) then begin
                yvalue = ysize
            endif
            yvalue = yvalue -1

            ; check what is in x box 
            widget_control,info.inspect.pix_label[0], get_value= xtemp
            xvalue = xtemp
            if(xvalue lt 1) then begin
                xvalue = 1
            endif
            if(xvalue gt xsize) then begin
                xvalue = xsize
            endif
            xvalue = float(xvalue)-1.0

        endif
; check if the <> buttons were used

        if(strmid(event_name,4,4) eq 'move') then begin
            if(strmid(event_name,9,2) eq 'x1') then xvalue = xvalue - 1
            if(strmid(event_name,9,2) eq 'x2') then xvalue = xvalue + 1
            if(strmid(event_name,9,2) eq 'y1') then yvalue = yvalue - 1
            if(strmid(event_name,9,2) eq 'y2') then yvalue = yvalue + 1

            if(xvalue le 0) then xvalue = 0
            if(yvalue le 0) then yvalue  = 0
            if(xvalue ge  info.data.image_xsize) then xvalue = info.data.image_xsize-1
            if(yvalue ge  info.data.image_ysize) then yvalue = info.data.image_ysize-1

        endif

; ++++++++++++++++++++++++++++++

        xmove = xvalue - xstart
        ymove = yvalue - ystart
        

        info.inspect.xposful = info.inspect.xposful + xmove
        info.inspect.yposful = info.inspect.yposful + ymove

         xpos_new = info.inspect.xposful -info.inspect.xstart_zoom 
         ypos_new = info.inspect.yposful -info.inspect.ystart_zoom

; update screen coor x_pos,y_pos
         info.inspect.x_pos = (xpos_new+0.5)*info.inspect.zoom_x
         info.inspect.y_pos = (ypos_new+0.5)*info.inspect.zoom

        widget_control,info.inspect.pix_label[0],set_value=info.inspect.xposful+1
        widget_control,info.inspect.pix_label[1],set_value=info.inspect.yposful+1

        miql_update_pixel_location,info




; If the Frame values for pixel window is open - destroy
        if(XRegistered ('mpixel')) then begin
            widget_control,info.RPixelInfo,/destroy
        endif

        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end

;_______________________________________________________________________
; click on a  different pixel to query the values

    (strmid(event_name,0,9) EQ 'miqlpixel') : begin
        if(event.type eq 1) then begin 
            xvalue = event.x    ; starts at 0
            yvalue = event.y    ; starts at 0

;; test for out of bounds area
            x = (xvalue)/info.inspect.zoom
            y = (yvalue)/info.inspect.zoom
            if(x gt info.data.image_xsize) then x = info.data.image_xsize-1
            if(y gt info.data.image_ysize) then y = info.data.image_ysize-1

            xvalue = x * info.inspect.zoom
            yvalue = y * info.inspect.zoom
;;
            info.inspect.x_pos = xvalue ;value in image screen 
            info.inspect.y_pos = yvalue ;


            xposful = (xvalue/info.inspect.zoom_x)+ info.inspect.xstart_zoom
            yposful = (yvalue/info.inspect.zoom)+ info.inspect.ystart_zoom

            info.inspect.xposful = xposful
            info.inspect.yposful = yposful

            if(xposful gt info.data.image_xsize or yposful gt info.data.image_ysize) then begin
                ok = dialog_message(" Area out of range",/Information)
                return
            endif
; update screen coor x_pos,y_pos            
            xnew = fix(xvalue/info.inspect.zoom_x)
            ynew = fix(yvalue/info.inspect.zoom)

            info.inspect.x_pos = (xnew+0.5)*info.inspect.zoom_x
            info.inspect.y_pos = (ynew+0.5)*info.inspect.zoom

            widget_control,info.inspect.pix_label[0],set_value = info.inspect.xposful+1
            widget_control,info.inspect.pix_label[1],set_value = info.inspect.yposful+1

            miql_update_pixel_location,info

; If the Frame values for pixel window is open - update
                if(XRegistered ('mpixel')) then begin
                    widget_control,info.RPixelInfo,/destroy
                endif
        endif

        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end
;_______________________________________________________________________

   (strmid(event_name,0,8) EQ 'getframe') : begin
       

	x = info.inspect.xposful 
	y = info.inspect.yposful
; pixel frame sdata
        mql_read_rampdata,x,y,pixeldata,info
        if ptr_valid (info.image_pixel.pixeldata) then ptr_free,info.image_pixel.pixeldata
        info.image_pixel.pixeldata = ptr_new(pixeldata)

        ref_pixeldata = fltarr(info.data.nints,info.data.nramps,1)
        get_ref_pixeldata,info,1,x,y,ref_pixeldata
        if ptr_valid (info.image_pixel.ref_pixeldata) then $
          ptr_free,info.image_pixel.ref_pixeldata
        info.image_pixel.ref_pixeldata = ptr_new(ref_pixeldata)


; reference corrected data
        refcorrected_data = pixeldata
        refcorrected_data[*,*] = 0
        id_data = refcorrected_data
        lc_data = refcorrected_data
; fill in reference corrected data, if the file was written
        if(info.control.file_refcorrection_exist eq 1) then begin 
            mql_read_refcorrected_data,x,y,info
            refcorrected_data = (*info.image.prefcorrected_pixeldata)
        endif
        if ptr_valid (info.image_pixel.refcorrected_pixeldata) then $
          ptr_free,info.image_pixel.refcorrected_pixeldata
        info.image_pixel.refcorrected_pixeldata = ptr_new(refcorrected_data)        


; fill in the frame IDS, if the file was written
        if(info.control.file_ids_exist eq 1) then begin 
            mql_read_id_data,x,y,info
            id_data = (*info.image.pid_pixeldata)
        endif
        if ptr_valid (info.image_pixel.id_pixeldata) then $
          ptr_free,info.image_pixel.id_pixeldata
        info.image_pixel.id_pixeldata = ptr_new(id_data)        


; fill in linearity corrected, if the file was written
        if(info.control.file_lc_exist eq 1) then begin
            mql_read_lc_data,x,y,info
            lc_data = (*info.image.plc_pixeldata) 
        endif

        if ptr_valid (info.image_pixel.lc_pixeldata) then $
          ptr_free,info.image_pixel.lc_pixeldata
        info.image_pixel.lc_pixeldata = ptr_new(lc_data)

; fill in mean dark  corrected, if the file was written
        if(info.control.file_mdc_exist eq 1) then begin
            mql_read_mdc_data,x,y,info
            mdc_data = (*info.image.pmdc_pixeldata) 
        endif

        if ptr_valid (info.image_pixel.mdc_pixeldata) then $
          ptr_free,info.image_pixel.mdc_pixeldata
        info.image_pixel.mdc_pixeldata = ptr_new(mdc_data)

; fill in reset  corrected, if the file was written
        if(info.control.file_reset_exist eq 1) then begin
            mql_read_reset_data,x,y,info
            reset_data = (*info.image.preset_pixeldata)
        endif

        if ptr_valid (info.image_pixel.reset_pixeldata) then $
          ptr_free,info.image_pixel.reset_pixeldata
        info.image_pixel.reset_pixeldata = ptr_new(reset_data)

; fill in lastframe  corrected, if the file was written
        if(info.control.file_lastframe_exist eq 1) then begin
            mql_read_lastframe_data,x,y,info
            lastframe_data = (*info.image.plastframe_pixeldata) 

        endif

        if ptr_valid (info.image_pixel.lastframe_pixeldata) then $
          ptr_free,info.image_pixel.lastframe_pixeldata
        info.image_pixel.lastframe_pixeldata = ptr_new(lastframe_data)
        

        

        info.image_pixel.file_ids_exist  = info.control.file_ids_exist 
        info.image_pixel.file_refcorrection_exist = info.control.file_refcorrection_exist 


        info.image_pixel.file_lc_exist  = info.control.file_lc_exist 
        info.image_pixel.file_mdc_exist  = info.control.file_mdc_exist 
        info.image_pixel.file_reset_exist  = info.control.file_reset_exist 
        info.image_pixel.file_lastframe_exist  = info.control.file_lastframe_exist 


        info.image_pixel.start_fit = info.image.start_fit
        info.image_pixel.end_fit = info.image.end_fit
        info.image_pixel.nints = info.data.nints
        info.image_pixel.integrationNo = info.image.integrationNO
        info.image_pixel.nframes = info.data.nramps
        info.image_pixel.nslopes = info.data.nslopes
        info.image_pixel.filename = info.control.filename_raw
        info.image_pixel.slope_exist = info.data.slope_exist
        if(info.image_pixel.slope_exist) then begin
            info.image_pixel.slope = (*info.data.preduced)[x,y,0]

            if(info.data.slope_zsize eq 2 or info.data.slope_zsize eq 3) then begin
                info.image_pixel.zeropt =  (*info.data.preduced)[x,y,1]
                info.image_pixel.uncertainty  = 0.0
                info.image_pixel.quality_flag =  0.0
                info.image_pixel.ngood =  0.0
                info.image_pixel.nframesat =  0.0
                info.image_pixel.ngoodseg = 0
                info.image_pixel.ngoodseg =  0.0
            endif else begin 
                info.image_pixel.uncertainty  = (*info.data.preduced)[x,y,1]
                info.image_pixel.quality_flag =  (*info.data.preduced)[x,y,2]
                info.image_pixel.zeropt =  (*info.data.preduced)[x,y,3]
                info.image_pixel.ngood =  (*info.data.preduced)[x,y,4]
                info.image_pixel.nframesat =  (*info.data.preduced)[x,y,5]
                info.image_pixel.ngoodseg = 0
                info.image_pixel.ngoodseg =  (*info.data.preduced)[x,y,6]
            endelse
        endif else begin
        
            info.image_pixel.slope = 0
            info.image_pixel.uncertainty  =0
            info.image_pixel.quality_flag =-1
            info.image_pixel.zeropt =  0
            info.image_pixel.ngood =  0
            info.image_pixel.nframesat = 0
            info.image_pixel.ngoodseg = 0

        endelse 


  
	display_frame_values,x,y,info,0
    end

else: print,event_name
endcase
end

;_______________________________________________________________________
;***********************************************************************
pro miql_update_images,info,ps = ps,eps = eps
;_______________________________________________________________________
hcopy = 0
loadct,info.col_table,/silent
if ( (keyword_set(ps)) or ( keyword_set(eps)) ) then hcopy = 1

n_pixels = float( (info.data.image_xsize) * (info.data.image_ysize))

ititle =  "Integration #: " + strtrim(string(info.inspect.integrationNO+1),2) 
ftitle = "Frame #: " + strtrim(string(info.inspect.FrameNO+1),2)   
         
widget_control,info.inspect.iLabelID,set_value= ititle
widget_control,info.inspect.fLabelID,set_value= ftitle

i = info.inspect.integrationNO
j = info.inspect.FrameNO

zoom = info.inspect.zoom

x = info.inspect.xposful ; xposful = x location in full image
y = info.inspect.yposful ; yposful = y location in full image


if(zoom eq 1) then begin
    x = info.data.image_xsize/2
    y = info.data.image_ysize/2

endif
xsize_org =  info.inspect.xplotsize
ysize_org =  info.inspect.yplotsize

  xsize = xsize_org
  ysize = ysize_org


if(zoom eq 2) then begin
  xsize = xsize_org/2
  ysize = ysize_org/2
endif
if(zoom eq 4) then begin
  xsize = xsize_org/4
  ysize = ysize_org/4
endif
if(zoom eq 8) then begin
  xsize = xsize_org/8
  ysize = ysize_org/8
endif
if(zoom eq 16) then begin
  xsize = xsize_org/16
  ysize = ysize_org/16
endif

if(zoom eq 32) then begin
  xsize = xsize_org/32
  ysize = ysize_org/32
endif


; ixstart and iystart are the starting points for the zoom image
; xstart and ystart are the starting points for the orginal image

xdata_end = info.data.image_xsize
ydata_end = info.data.image_ysize
xstart = fix(x - xsize/2)
ystart = fix(y - ysize/2)
if(xstart lt 0) then xstart = 0
if(ystart lt 0) then ystart = 0

xend  = xstart + xsize-1
yend  = ystart + ysize -1

ixstart = 0
iystart = 0
ixend = (xsize)-1
iyend = (ysize)-1

if(xend ge xdata_end) then begin
    xend =  xdata_end-1
    xstart = xend - (xsize-1)
endif
if(yend ge ydata_end) then begin
    yend = ydata_end-1
    ystart = yend- (ysize-1)
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
;;

;print,'ixstart, ixend ',ixstart,ixend,ixend - ixstart
;print,'iystart, iyend ',iystart,iyend,iyend - iystart
;print,'xstart xend ',xstart,xend,xend-xstart
;print,'ystart yend ',ystart,yend,yend-ystart

info.inspect.ixstart_zoom = ixstart
info.inspect.xstart_zoom = xstart

info.inspect.iystart_zoom = iystart
info.inspect.ystart_zoom = ystart

info.inspect.yend_zoom = yend
info.inspect.xend_zoom = xend

frame_image = (*info.inspect.pdata)

sub_image = fltarr(xsize,ysize)   

sub_image[ixstart:ixend,iystart:iyend] =frame_image[xstart:xend,ystart:yend]
stat_data =     sub_image

if(info.image.apply_bad) then begin 
    bad_sub_mask  = fltarr(xsize,ysize)
    bad_sub_mask[ixstart:ixend,iystart:iyend] =(*info.badpixel.pmask)[xstart:xend,ystart:yend]
    index = where(bad_sub_mask and 1,numbad)
    if(numbad gt 0) then stat_data[index] = !values.F_NaN
    bad_sub_mask = 0
endif 
x_zoom_start = ixstart
x_zoom_end = ixend
if(info.data.colstart eq 1 and xstart eq 0) then x_zoom_start = x_zoom_start +4
if(info.data.subarray eq 0 and xend ge 1028) then begin
    factor = xend - 1028 + 1
    x_zoom_end = x_zoom_end - factor
endif

;print,'x_zoom_start,x_zoom_end',x_zoom_start,x_zoom_end

stat_noref = stat_data[x_zoom_start:x_zoom_end,*]
stat_data = 0
stat_data = stat_noref
stat_noref = 0
       
get_image_stat,stat_data,image_mean,stdev,image_min,image_max,$
               irange_min,irange_max,image_median,stdev_mean,skew,ngood,nbad

stat_data = 0
;_______________________________________________________________________
if ptr_valid (info.inspect.psubdata) then ptr_free,info.inspect.psubdata
info.inspect.psubdata = ptr_new(sub_image)

z_mean  = image_mean
z_stdev  = stdev
z_median  = image_median
z_skew  = skew
z_min  = image_min
z_max  = image_max
z_good = ngood
z_bad  = nbad
;_______________________________________________________________________
; get stats on full image - no reference pixels


if(info.image.apply_bad) then begin 
    index = where( (*info.badpixel.pmask) and 1,numbad)
    if(numbad gt 0) then frame_image[index] = !values.F_NaN
endif    

if(info.data.subarray eq 0) then begin  
    frame_image_noref  = frame_image[4:1027,*]
endif else begin 
    frame_image_noref = frame_image
endelse

get_image_stat,frame_image_noref,image_mean,stdev,image_min,image_max,$
               irange_min,irange_max,image_median,stdev_mean,skew,ngood,nbad
frame_image = 0                 ; free memory
frame_image_noref = 0
;_______________________________________________________________________
widget_control,info.inspect.graphID,draw_xsize=info.inspect.xplotsize,$
               draw_ysize=info.inspect.yplotsize
if(hcopy eq 0 ) then wset,info.inspect.pixmapID


xsize_image = info.inspect.xplotsize
ysize_image = info.inspect.yplotsize

;_______________________________________________________________________
; check if default scale is true - then reset to orginal value
if(info.inspect.default_scale_graph eq 1) then begin
    info.inspect.graph_range[0] = irange_min
    info.inspect.graph_range[1] = irange_max
endif


disp_image = congrid(sub_image, $
                     xsize_image,ysize_image)

test_image = disp_image

disp_image = bytscl(disp_image,min=info.inspect.graph_range[0], $
                    max=info.inspect.graph_range[1],top=info.col_max,/nan)
tv,disp_image,0,0,/device

if( hcopy eq 0) then begin  
    wset,info.inspect.draw_window_id
    device,copy=[0,0,xsize_image,ysize_image, $
                 0,0,info.inspect.pixmapID]
endif

mean = image_mean
stdev = stdev
min = image_min
max = image_max
median = image_median
st_mean = stdev_mean
skew = skew



low_limit_value = info.inspect.limit_low
high_limit_value = info.inspect.limit_high
    

index_low = where(sub_image lt low_limit_value,num_low)
index_high = where(sub_image gt high_limit_value,num_high)


info.inspect.limit_low_num = num_low
info.inspect.limit_high_num = num_high

size_sub = size(sub_image)
size_test = size(test_image)

xzoom = float(size_test[1])/float(size_sub[1])
yzoom = float(size_test[2])/float(size_sub[2])
info.inspect.zoom_x = xzoom

if(num_low ge 1 or num_high ge 1) then begin
    save_color = info.col_table

    if(num_low ge 1) then begin 
       color6
       yvalue = index_low/xsize
       xvalue = index_low - (yvalue*xsize)
       xvalue = xvalue + 0.5
       yvalue = yvalue + 0.5
       yvalue = yvalue*yzoom
       xvalue = xvalue*xzoom
       plots,xvalue,yvalue,color=2,psym=1,/device

        if ptr_valid (info.inspect.plowx) then ptr_free,info.inspect.plowx
        info.inspect.plowx = ptr_new(xvalue)
        xvalue = 0

        if ptr_valid (info.inspect.plowy) then ptr_free,info.inspect.plowy
        info.inspect.plowy = ptr_new(yvalue)
        yvalue = 0
    endif

    if(num_high ge 1) then begin 
       color6
        yvalue = index_high/xsize
        xvalue = index_high - (yvalue*xsize)

        xvalue = xvalue + 0.5
        yvalue = yvalue + 0.5
        yvalue = yvalue*yzoom
        xvalue = xvalue*xzoom

        plots,xvalue,yvalue,color=4,psym=1,/device
        if ptr_valid (info.inspect.phighx) then ptr_free,info.inspect.phighx
        info.inspect.phighx = ptr_new(xvalue)
        xvalue = 0

        if ptr_valid (info.inspect.phighy) then ptr_free,info.inspect.phighy
        info.inspect.phighy = ptr_new(yvalue)
        yvalue = 0
    endif

info.col_table = save_color
endif


if(hcopy eq 1) then begin 
    svalue = "Science Image"
    ftitle = "Frame #: " + strtrim(string(j+1),2) 
    ititle = "Integration #: " + strtrim(string(i+1),2)
    sstitle = info.control.filebase+'.fits'
    mtitle = "Mean: " + strtrim(string(mean,format="(g14.6)"),2) 
    mintitle = "Min value: " + strtrim(string(min,format="(g14.6)"),2) 
    maxtitle = "Max value: " + strtrim(string(max,format="(g14.6)"),2) 

    xyouts,0.75*!D.X_Vsize,0.95*!D.Y_VSize,sstitle,/device
    xyouts,0.75*!D.X_Vsize,0.90*!D.Y_VSize,svalue,/device
    xyouts,0.75*!D.X_Vsize,0.85*!D.Y_VSize,ftitle,/device
    xyouts,0.75*!D.X_Vsize,0.80*!D.Y_VSize,ititle,/device
    xyouts,0.75*!D.X_Vsize,0.75*!D.Y_VSize,mtitle,/device
    xyouts,0.75*!D.X_Vsize,0.70*!D.Y_VSize,mintitle,/device
    xyouts,0.75*!D.X_Vsize,0.65*!D.Y_VSize,maxtitle,/device
endif


widget_control,info.inspect.low_foundID,set_value='# ' + strcompress(string(num_low),/remove_all)
widget_control,info.inspect.high_foundID,set_value='# ' + strcompress(string(num_high),/remove_all)

; full image stats

widget_control,info.inspect.slabelID[0],set_value=info.inspect.sname[0]+ strtrim(string(mean,format="(g14.6)"),2) 
widget_control,info.inspect.slabelID[1],set_value=info.inspect.sname[1]+ strtrim(string(stdev,format="(g14.6)"),2) 
widget_control,info.inspect.slabelID[2],set_value=info.inspect.sname[2]+ strtrim(string(median,format="(g14.6)"),2) 
widget_control,info.inspect.slabelID[3],set_value=info.inspect.sname[3]+ strtrim(string(min,format="(g14.6)"),2) 
widget_control,info.inspect.slabelID[4],set_value=info.inspect.sname[4]+ strtrim(string(max,format="(g14.6)"),2) 

widget_control,info.inspect.slabelID[5],set_value=info.inspect.sname[5]+ strtrim(string(skew,format="(g14.6)"),2) 
widget_control,info.inspect.slabelID[6],set_value=info.inspect.sname[6]+ strtrim(string(ngood,format="(i10)"),2) 
widget_control,info.inspect.slabelID[7],set_value=info.inspect.sname[7]+ strtrim(string(nbad,format="(i10)"),2) 

widget_control,info.inspect.rlabelID[0],set_value=info.inspect.graph_range[0]
widget_control,info.inspect.rlabelID[1],set_value=info.inspect.graph_range[1]


; zoom image stats

if(info.inspect.zoom gt info.inspect.set_zoom) then begin 

 subt = "Statisical Information for Zoom Region"
 widget_control,info.inspect.zlabelID,set_value = subt

 sf = ' ' 
 if(info.image.apply_bad eq 0) then sf = "Reference Pixels NOT Included" 
 if(info.image.apply_bad eq 1) then sf = "Reference Pixels & Bad Pixels  NOT Included" 

 widget_control,info.inspect.zlabel1,set_value = sf


 widget_control,info.inspect.zslabelID[0],$
                set_value=info.inspect.sname[0]+ strtrim(string(z_mean,format="(g14.6)"),2) 
 widget_control,info.inspect.zslabelID[1],$
                set_value=info.inspect.sname[1]+ strtrim(string(z_stdev,format="(g14.6)"),2) 
 widget_control,info.inspect.zslabelID[2],$
                set_value=info.inspect.sname[2]+ strtrim(string(z_median,format="(g14.6)"),2) 
 widget_control,info.inspect.zslabelID[3],$
                set_value=info.inspect.sname[3]+ strtrim(string(z_min,format="(g14.6)"),2) 
 widget_control,info.inspect.zslabelID[4],$
                set_value=info.inspect.sname[4]+ strtrim(string(z_max,format="(g14.6)"),2) 
 
 widget_control,info.inspect.zslabelID[5],$
                set_value=info.inspect.sname[5]+ strtrim(string(z_skew,format="(g14.6)"),2) 
 widget_control,info.inspect.zslabelID[6],$
                set_value=info.inspect.sname[6]+ strtrim(string(z_good,format="(i10)"),2) 
 widget_control,info.inspect.zslabelID[7],$
                set_value=info.inspect.sname[7]+ strtrim(string(z_bad,format="(i10)"),2) 
 
endif else begin

 widget_control,info.inspect.zlabelID,set_value = ''
 widget_control,info.inspect.zlabel1,set_value = ''


 widget_control,info.inspect.zslabelID[0],set_value = ' ' 
 widget_control,info.inspect.zslabelID[1],set_value = ' ' 
 widget_control,info.inspect.zslabelID[2],set_value = ' ' 
 widget_control,info.inspect.zslabelID[3],set_value = ' ' 
 widget_control,info.inspect.zslabelID[4],set_value = ' ' 
 widget_control,info.inspect.zslabelID[5],set_value = ' ' 
 widget_control,info.inspect.zslabelID[6],set_value = ' ' 
 widget_control,info.inspect.zslabelID[7],set_value = ' ' 


endelse

; replot the pixel location


halfpixelx = 0.5* info.inspect.zoom_x
halfpixely = 0.5* info.inspect.zoom
xpos1 = info.inspect.x_pos-halfpixelx
xpos2 = info.inspect.x_pos+halfpixelX

ypos1 = info.inspect.y_pos-halfpixely
ypos2 = info.inspect.y_pos+halfpixely

box_coords1 = [xpos1,xpos2,ypos1,ypos2]
plots,box_coords1[[0,0,1,1,0]],box_coords1[[2,3,3,2,2]],psym=0,/device





sub_image = 0
test_image = 0
widget_control,info.Quicklook,set_uvalue = info
end






;_______________________________________________________________________
;***********************************************************************
pro miql_update_pixel_location,info
;***********************************************************************

xvalue = info.inspect.xposful ; location in image 
yvalue = info.inspect.yposful

pixelvalue = (*info.inspect.pdata)[xvalue,yvalue]
dead_pixel = 0
dead_pixel = (*info.badpixel.pmask)[xvalue,yvalue]
dead_str = 'No '
if(dead_pixel ne 0) then dead_str = 'Yes' 
if(info.control.display_apply_bad eq 0) then dead_str = 'NA ' 

widget_control,info.inspect.pix_statID[0],set_value= info.inspect.pix_statLabel[0] + ' = ' + $
  strtrim(string(dead_str,format="("+info.inspect.pix_statFormat[0]+")"),2)

widget_control,info.inspect.pix_statID[1],$
               set_value= info.inspect.pix_statLabel[1] + ' = ' + $
               strtrim(string(pixelvalue,format="("+info.inspect.pix_statFormat[1]+")"),2)

wset,info.inspect.draw_window_id


xsize_image = info.inspect.xplotsize 
ysize_image  = info.inspect.yplotsize 

device,copy=[0,0,xsize_image,ysize_image, $
             0,0,info.inspect.pixmapID]


halfpixelx = 0.5* info.inspect.zoom_x
halfpixely = 0.5* info.inspect.zoom
xpos1 = info.inspect.x_pos-halfpixelx
xpos2 = info.inspect.x_pos+halfpixelX

ypos1 = info.inspect.y_pos-halfpixely
ypos2 = info.inspect.y_pos+halfpixely

box_coords1 = [xpos1,xpos2,ypos1,ypos2]
plots,box_coords1[[0,0,1,1,0]],box_coords1[[2,3,3,2,2]],psym=0,/device
plots,box_coords1[[0,0,1,1,0]],box_coords1[[2,3,3,2,2]],psym=0,/device


if(info.inspect.limit_low_num gt 0) then begin
    color6
    xvalue = (*info.inspect.plowx)
    yvalue = (*info.inspect.plowy)
    plots,xvalue,yvalue,color=1,psym=1,/device
    xvalue = 0
    yvalue = 0
endif

if(info.inspect.limit_high_num gt 0) then begin 
    color6
    xvalue = (*info.inspect.phighx)
    yvalue = (*info.inspect.phighy)
    plots,xvalue,yvalue,color=255,psym=1,/device
    xvalue = 0
    yvalue = 0
endif


widget_control,info.Quicklook,set_uvalue = info
end



;_______________________________________________________________________
;***********************************************************************
pro miql_display_images,info
;_______________________________________________________________________


if(info.inspect.uwindowsize eq 0) then begin ; user changed the widget window size - only redisplay

; labels used for the Pixel Statistics Table
    info.inspect.draw_window_id = 0
    info.inspect.pixmapID = 0
    info.inspect.graphID = 0
    info.inspect.graph_range[*] = info.image.graph_range[0,*]
    info.inspect.default_scale_graph = info.image.default_scale_graph[0]
    info.inspect.image_recomputeID=0
    info.inspect.slabelID[*] = 0L
    info.inspect.rlabelID[*] = 0L
    info.inspect.x_pos = 0
    info.inspect.y_pos = 0
    info.inspect.limit_high_default = 1
    info.inspect.limit_low_default = 1

    info.inspect.zoom = 1
    info.inspect.zoom_x = 1
    info.inspect.x_pos =(info.data.image_xsize)/2.0
    info.inspect.y_pos = (info.data.image_ysize)/2.0

    info.inspect.xposful = info.inspect.x_pos
    info.inspect.yposful = info.inspect.y_pos


    info.inspect.limit_low = -5000.0
    info.inspect.limit_high = 65535
    info.inspect.limit_low_num = 0
    info.inspect.limit_high_num = 0
endif
;*********
;Setup main panel
;*********

window,1,/pixmap
wdelete,1

if(XRegistered ('miql')) then begin
    widget_control,info.InspectImage,/destroy
endif
; widget window parameters

xwidget_size = 1550
ywidget_size = 1200
xsize_scroll = 1450
ysize_scroll = 1100



if(info.inspect.uwindowsize eq 1) then begin ; user has set window size 
    xsize_scroll = info.inspect.xwindowsize
    ysize_scroll = info.inspect.ywindowsize
endif



if(info.control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.control.x_scroll_window
if(info.control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.control.y_scroll_window

if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10


InspectImage = widget_base(title="MIRI Quick Look- Inspect Image" + info.version,$
                                mbar = menuBar,/row,group_leader = info.RawQuicklook,$
                                xsize =  xwidget_size,$
                                ysize=   ywidget_size,/scroll,$
                                x_scroll_size= xsize_scroll,$
                                y_scroll_size = ysize_scroll,/TLB_SIZE_EVENTS)




;********
; build the menubar
;********
QuitMenu = widget_button(menuBar,value="Quit",font = info.font2)

; add quit button
quitbutton = widget_button(quitmenu,value="Quit",event_pro='miql_quit')

; zoom button
ZoomMenu = widget_button(menuBar,value="Zoom",font = info.font2)

; add quit button
info.inspect.zbutton[0] = widget_button(Zoommenu,value="No Zoom",uvalue='zoom0',/checked_menu)
info.inspect.zbutton[1] = widget_button(Zoommenu,value="Zoom 2x",uvalue='zoom1',/checked_menu)
info.inspect.zbutton[2] = widget_button(Zoommenu,value="Zoom 4x",uvalue='zoom2',/checked_menu)
info.inspect.zbutton[3] = widget_button(Zoommenu,value="Zoom 8x",uvalue='zoom3',/checked_menu)
info.inspect.zbutton[4] = widget_button(Zoommenu,value="Zoom 16x",uvalue='zoom4',/checked_menu)
info.inspect.zbutton[5]=  widget_button(Zoommenu,value="Zoom 32x",uvalue='zoom5',/checked_menu)

PMenu = widget_button(menuBar,value="Print",font = info.font2)
PbuttonR = widget_button(Pmenu,value = "Print Science Image to output file",uvalue='prints')
;*****
; setup the image windows
;*****
; set up for Raw image widget window

graphID_master1 = widget_base(InspectImage,row=1)
graphID1 = widget_base(graphID_master1,col=1)
graphID2  = widget_base(graphID_master1,col=1)
;_______________________________________________________________________  

;*****
;graph full images
;*****

xplotsize = info.data.image_xsize
yplotsize = info.data.image_ysize
info.inspect.set_zoom = 1
if (xplotsize lt 1032) then begin
    find_zoom,xplotsize,yplotsize,zoom
;    print,zoom
    info.inspect.zoom = zoom
    info.inspect.set_zoom = zoom


    xplotsize = info.data.image_xsize * zoom
    yplotsize = info.data.image_ysize * zoom
endif

if(info.inspect.zoom eq 1) then widget_control,info.inspect.zbutton[0],set_button = 1
if(info.inspect.zoom eq 2) then widget_control,info.inspect.zbutton[1],set_button = 1
if(info.inspect.zoom eq 4) then widget_control,info.inspect.zbutton[2],set_button = 1
if(info.inspect.zoom eq 8) then widget_control,info.inspect.zbutton[3],set_button = 1
if(info.inspect.zoom eq 16) then widget_control,info.inspect.zbutton[4],set_button = 1
if(info.inspect.zoom eq 32) then widget_control,info.inspect.zbutton[5],set_button = 1



info.inspect.xplotsize = xplotsize
info.inspect.yplotsize = yplotsize

info.inspect.graphID = widget_draw(graphID1,$
                              xsize = xplotsize,$
                              ysize = yplotsize,$
                              /Button_Events,$
                              retain=info.retn,uvalue='miqlpixel')

;_______________________________________________________________________
;  Information on the image

xsize_label = 8
; 
; statistical information - next column

blank = '                                               '

ttitle = info.control.filename_raw 

ititle =  "Integration #: " + strtrim(string(info.inspect.integrationNO+1),2) 
ftitle = "Frame #: " + strtrim(string(info.inspect.frameNO+1),2)   
         
graph_label = widget_label(graphID2,value=ttitle,/align_left,font = info.font5)
base1 = widget_base(graphID2,row= 1,/align_left)
info.inspect.iLabelID = widget_label(base1,value= ititle,/align_left)
info.inspect.fLabelID = widget_label(base1,value= ftitle,/align_left)

blank10 = '               '

;-----------------------------------------------------------------------
; min and max scale of  image


base1 = widget_base(graphID2,row= 1,/align_left)
r_label1 = widget_label(base1,value="Change Image Scale" ,/align_left,font=info.font5,$
                       /sunken_frame)


info.inspect.image_recomputeID = widget_button(base1,value='Image Scale',font=info.font3,$
                                          uvalue = 'sinspect',/align_left)
base1 = widget_base(graphID2,row= 1,/align_left)
info.inspect.rlabelID[0] = cw_field(base1,title="Minimum",font=info.font3,uvalue="isr_b",$
                              /float,/return_events,xsize=xsize_label,value =range_min)

info.inspect.rlabelID[1] = cw_field(base1,title="Maximum",font=info.font3,uvalue="isr_t",$
                         /float,/return_events,xsize = xsize_label,value =range_max)


base1 = widget_base(graphID2,row= 1,/align_left)
info.inspect.limit_lowID = cw_field(base1,title="Mark Values below (Red)",font=info.font3,uvalue="limit_low",$
                         /float,/return_events,xsize = xsize_label,value =info.inspect.limit_low)


info.inspect.low_foundID=widget_label(base1,value = '# =         ' ,/align_left)


base1 = widget_base(graphID2,row= 1,/align_left)
info.inspect.limit_highID = cw_field(base1,title="Mark Values above (Blue)",font=info.font3,uvalue="limit_high",$
                         /float,/return_events,xsize = xsize_label,value =info.inspect.limit_high)

info.inspect.high_foundID=widget_label(base1,value = '# =         ' ,/align_left)
;-----------------------------------------------------------------------

general_label= widget_label(graphID2,$
                            value=" Pixel Information (Image: 1032 X 1024)",/align_left,$
                            font=info.font5,/sunken_frame)

pix_num_base = widget_base(graphID2,row=1,/align_left)
labelID = widget_button(pix_num_base,uvalue='pix_move_x1',value='<',font=info.font3)
labelID = widget_button(pix_num_base,uvalue='pix_move_x2',value='>',font=info.font3)

xvalue = info.inspect.xposful
yvalue = info.inspect.yposful

info.inspect.pix_label[0] = cw_field(pix_num_base,title="x",font=info.font4, $
                                   uvalue="pix_x_val",/integer,/return_events, $
                                   value=fix(xvalue+1),xsize=6,$  ; xvalue + 1 -4 (reference pixel)
                                   fieldfont=info.font3)



pix_num_base = widget_base(graphID2,row=1,/align_left)
labelID = widget_button(pix_num_base,uvalue='pix_move_y1',value='<',font=info.font3)
labelID = widget_button(pix_num_base,uvalue='pix_move_y2',value='>',font=info.font3)
info.inspect.pix_label[1] = cw_field(pix_num_base,title="y",font=info.font4, $
                                   uvalue="pix_y_val",/integer,/return_events, $
                                   value=fix(yvalue+1),xsize=6,$
                                   fieldfont=info.font3)

info.inspect.pix_statLabel[0] = "Dead/hot/noisy Pixel"
info.inspect.pix_statFormat[0] = "A4"
info.inspect.pix_statID[0] = widget_label(graphid2,$
                                            value = info.inspect.pix_statLabel[0]+$
                                            ' =        ',/align_left)

info.inspect.pix_statLabel[1] = "Frame Value"
info.inspect.pix_statFormat[1]= "F10.2" 
info.inspect.pix_statID[1]=widget_label(graphID2,value = info.inspect.pix_statLabel[1]+$
                                        ' =         ' ,/align_left)

flabel = widget_button(graphID2,value="Get All Frame Values",/align_left,$
                         uvalue = "getframe")

; stats
b_label = widget_label(graphID2,value=blank)
s_label = widget_label(graphID2,value="Statisical Information" ,/align_left,/sunken_frame,font=info.font5)
if(info.image.apply_bad eq 0) then $
  s_label = widget_label(graphID2,value="Reference Pixels  NOT Included" ,/align_left)
if(info.image.apply_bad eq 1) then $
  s_label = widget_label(graphID2,value="Reference Pixels & Bad Pixels  NOT Included" ,/align_left)


info.inspect.sname = ['Mean:              ',$
                      'Standard Deviation ',$
                      'Median:            ',$
                      'Min:               ',$
                      'Max:               ',$
                      'Skew:              ',$
                      '# of Good Pixels   ',$
                      '# of Bad Pixels    ']
info.inspect.slabelID[0] = widget_label(graphID2,value=info.inspect.sname[0] +blank10,/align_left)
info.inspect.slabelID[1] = widget_label(graphID2,value=info.inspect.sname[1] +blank10,/align_left)
info.inspect.slabelID[2] = widget_label(graphID2,value=info.inspect.sname[2] +blank10,/align_left)
info.inspect.slabelID[3] = widget_label(graphID2,value=info.inspect.sname[3] +blank10,/align_left)
info.inspect.slabelID[4] = widget_label(graphID2,value=info.inspect.sname[4] +blank10,/align_left)
info.inspect.slabelID[5] = widget_label(graphID2,value=info.inspect.sname[5] +blank10,/align_left)
info.inspect.slabelID[6] = widget_label(graphID2,value=info.inspect.sname[6] +blank10,/align_left)
info.inspect.slabelID[7] = widget_label(graphID2,value=info.inspect.sname[7] +blank10,/align_left)





; stats on zoom window
;*****
;graph 1,2; Zoom window of reference image
;*****

 subt = ""

info.inspect.zlabelID = widget_label(graphID2,value=subt,/align_left,$
                            font=info.font5,/sunken_frame,/dynamic_resize)
info.inspect.zlabel1 = widget_label(graphID2,value="      " ,/align_left,/dynamic_resize)


info.inspect.zslabelID[0] = widget_label(graphID2,value=blank10,/align_left,/dynamic_resize)
info.inspect.zslabelID[1] = widget_label(graphID2,value=blank10,/align_left,/dynamic_resize)
info.inspect.zslabelID[2] = widget_label(graphID2,value=blank10,/align_left,/dynamic_resize)
info.inspect.zslabelID[3] = widget_label(graphID2,value=blank10,/align_left,/dynamic_resize)
info.inspect.zslabelID[4] = widget_label(graphID2,value=blank10,/align_left,/dynamic_resize)
info.inspect.zslabelID[5] = widget_label(graphID2,value=blank10,/align_left,/dynamic_resize)
info.inspect.zslabelID[6] = widget_label(graphID2,value=blank10,/align_left,/dynamic_resize)
info.inspect.zslabelID[7] = widget_label(graphID2,value=blank10,/align_left,/dynamic_resize)

;_______________________________________________________________________
longline = '                              '
longtag = widget_label(InspectImage,value = longline)

; realize main panel
Widget_control,InspectImage,/Realize


info.InspectImage = InspectImage

XManager,'miql',info.InspectImage,/No_Block,event_handler='miql_event'


; get the window ids of the draw windows

widget_control,info.inspect.graphID,get_value=tdraw_id
info.inspect.draw_window_id = tdraw_id

window,/pixmap,xsize=info.inspect.xplotsize,ysize=info.inspect.yplotsize,/free
info.inspect.pixmapID = !D.WINDOW
loadct,info.col_table,/silent

miql_update_images,info

miql_update_pixel_location,info

Widget_Control,info.QuickLook,Set_UValue=info
iinfo = {info        : info}


Widget_Control,info.InspectImage,Set_UValue=iinfo
Widget_Control,info.QuickLook,Set_UValue=info
end

