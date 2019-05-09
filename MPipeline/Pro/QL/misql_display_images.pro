;_______________________________________________________________________
;***********************************************************************
pro misql_quit,event
;_______________________________________________________________________
widget_control,event.top, Get_UValue = ginfo	
widget_control,ginfo.info.QuickLook,Get_Uvalue = info

;    print,'Exiting MIRI InspectSlope'
wdelete,info.inspect_slope.pixmapID
widget_control,info.inspectSlope,/destroy

end
;_______________________________________________________________________
;***********************************************************************
;_______________________________________________________________________
;***********************************************************************
pro misql_event,event
;_______________________________________________________________________
Widget_Control,event.id,Get_uValue=event_name
widget_control,event.top, Get_UValue = ginfo	
widget_control,ginfo.info.QuickLook,Get_Uvalue = info

if (widget_info(event.id,/TLB_SIZE_EVENTS) eq 1 ) then begin

    info.inspect_slope.xwindowsize = event.x
    info.inspect_slope.ywindowsize = event.y
    info.inspect_slope.uwindowsize = 1
    widget_control,event.top,set_uvalue = ginfo
    widget_control,ginfo.info.Quicklook,set_uvalue = info
    misql_display_images,info

    return
endif
    case 1 of
;_______________________________________________________________________

    (strmid(event_name,0,5) EQ 'print') : begin
        print_inspect_slope_images,info
    end    
;_______________________________________________________________________
; scaling image
;_______________________________________________________________________
    (strmid(event_name,0,8) EQ 'sinspect') : begin
        if(info.inspect_slope.default_scale_graph eq 0 ) then begin ; true - turn to false
            widget_control,info.inspect_slope.image_recomputeID,set_value=' Image Scale'
            info.inspect_slope.default_scale_graph = 1
        endif

        misql_update_images,info
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info

    end
;_______________________________________________________________________
    (strmid(event_name,0,8) EQ 'datainfo') : begin


        data_id ='ID flag '+ strcompress(string(info.dqflag.Unusable),/remove_all) +  ' = ' + info.dqflag.Sunusable +  string(10b) + $
                 'ID flag '+ strcompress(string(info.dqflag.Saturated),/remove_all) +  ' = ' + info.dqflag.SSaturated +  string(10b) + $
                 'ID flag '+ strcompress(string(info.dqflag.CosmicRay),/remove_all) +  ' = ' + info.dqflag.SCosmicRay +  string(10b) + $
                 'ID flag '+ strcompress(string(info.dqflag.NoiseSpike),/remove_all) +  ' = ' + info.dqflag.SNoiseSpike +  string(10b) + $
                 'ID flag '+ strcompress(string(info.dqflag.Saturated),/remove_all) +  ' = ' + info.dqflag.SSaturated +  string(10b) + $
                 'ID flag '+ strcompress(string(info.dqflag.NegCosmicRay),/remove_all) +  ' = ' + info.dqflag.SNegCosmicRay +  string(10b) + $
                 'ID flag '+ strcompress(string(info.dqflag.NoReset),/remove_all) +  ' = ' + info.dqflag.SNoReset +  string(10b) + $
                 'ID flag '+ strcompress(string(info.dqflag.NoDark),/remove_all) +  ' = ' + info.dqflag.SNoDark +  string(10b) + $
                 'ID flag '+ strcompress(string(info.dqflag.NoLin),/remove_all) +  ' = ' + info.dqflag.SNoLin +  string(10b) + $
;                 'ID flag '+ strcompress(string(info.dqflag.OutLinRange),/remove_all) +  ' = ' + info.dqflag.SOutLinRange +  string(10b) + $
                 'ID flag '+ strcompress(string(info.dqflag.NoLastFrame),/remove_all) +  ' = ' + info.dqflag.SNoLastFrame +  string(10b)  + $
                 'ID flag '+ strcompress(string(info.dqflag.Min_Frame_Failure),/remove_all) +  ' = ' + info.dqflag.SMin_Frame_Failure +  string(10b) 

        
        result = dialog_message(data_id,/information)
    end
;_______________________________________________________________________
;_______________________________________________________________________
; change range of image graphs
; if change range then also change the scale button to 'User Set
; Scale'
;_______________________________________________________________________
    (strmid(event_name,0,3) EQ 'isr') : begin

        if(strmid(event_name,4,1) EQ 'b') then begin
            info.inspect_slope.graph_range[0] = event.value
            widget_control,info.inspect_slope.rlabelID[1],get_value = temp
            info.inspect_slope.graph_range[1] = temp
        endif


        if(strmid(event_name,4,1) EQ 't') then begin
            info.inspect_slope.graph_range[1] = event.value
            widget_control,info.inspect_slope.rlabelID[0],get_value = temp
            info.inspect_slope.graph_range[0] = temp
        endif
                        
        info.inspect_slope.default_scale_graph = 0
        widget_control,info.inspect_slope.image_recomputeID,set_value='Default Scale'

        misql_update_images,info
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end

    
;_______________________________________________________________________
; Change limits

    (strmid(event_name,0,5) EQ 'limit') : begin

        if(strmid(event_name,6,1) EQ 'l') then begin
            info.inspect_slope.limit_low = event.value

            widget_control,info.inspect_slope.limit_highID,get_value = temp
            info.inspect_slope.limit_high = temp
        endif


        if(strmid(event_name,6,1) EQ 'h') then begin
            info.inspect_slope.limit_high = event.value
            widget_control,info.inspect_slope.limit_lowID,get_value = temp
            info.inspect_slope.limit_low = temp
        endif
        info.inspect_slope.limit_low_default = 0
        info.inspect_slope.limit_high_default = 0
        misql_update_images,info
        misql_find_limits,info

        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end

;_______________________________________________________________________e
; zoom images
;_______________________________________________________________________
   (strmid(event_name,0,4) EQ 'zoom') : begin

       zoom = fix(strmid(event_name,4,1))
       info.inspect_slope.zoom = 2^zoom

         ; redefine the xpos and y pos value in new zoom window

         misql_update_images,info
         misql_find_limits,info
         
         ; xposful, uposful - x,y location in full image
         ; x_pos, y_pos = x and y location on the image screen

         xpos_new = info.inspect_slope.xposful -info.inspect_slope.xstart_zoom 
         ypos_new = info.inspect_slope.yposful -info.inspect_slope.ystart_zoom
         info.inspect_slope.x_pos = (xpos_new+0.5)*info.inspect_slope.zoom_x
         info.inspect_slope.y_pos = (ypos_new+0.5)*info.inspect_slope.zoom
         misql_update_pixel_location,info


         for i = 0,5 do begin
             widget_control,info.inspect_slope.zbutton[i],set_button = 0
         endfor
         widget_control,info.inspect_slope.zbutton[zoom],set_button = 1
     end
;_______________________________________________________________________
; Select a different pixel
;_______________________________________________________________________
    (strmid(event_name,0,3) EQ 'pix') : begin
        xsize = info.data.image_xsize
        ysize = info.data.image_ysize
        xvalue = info.inspect_slope.xposful
        yvalue = info.inspect_slope.yposful
        xstart = xvalue
        ystart = yvalue


; ++++++++++++++++++++++++++++++
        if(strmid(event_name,4,1) eq 'x') then  begin
            xvalue = event.value ; event value - user input starts at 1 

            if(xvalue lt 0) then xvalue = 0
            if(xvalue gt xsize) then xvalue = xsize

            xvalue = xvalue -1
            ; check what is in y box 
            widget_control,info.inspect_slope.pix_label[1],get_value =  ytemp
            yvalue = ytemp
            if(yvalue lt 1) then yvalue = 1

            if(yvalue gt ysize) then yvalue = ysize
            
            yvalue = float(yvalue)-1
        endif
        if(strmid(event_name,4,1) eq 'y') then begin
            yvalue = event.value ; event value - user input starts at 1
            if(yvalue lt 1) then yvalue = 1
            if(yvalue gt ysize) then yvalue = ysize

            yvalue = yvalue -1

            ; check what is in x box 
            widget_control,info.inspect_slope.pix_label[0], get_value= xtemp
            xvalue = xtemp
            if(xvalue lt 1) then xvalue = 1
            if(xvalue gt xsize) then xvalue = xsize

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
            if(xvalue ge  info.data.slope_xsize) then xvalue = info.data.slope_xsize-1
            if(yvalue ge  info.data.slope_ysize) then yvalue = info.data.slope_ysize-1

        endif

; ++++++++++++++++++++++++++++++

        xmove = xvalue - xstart
        ymove = yvalue - ystart
        

        info.inspect_slope.xposful = info.inspect_slope.xposful + xmove
        info.inspect_slope.yposful = info.inspect_slope.yposful + ymove

         xpos_new = info.inspect_slope.xposful -info.inspect_slope.xstart_zoom 
         ypos_new = info.inspect_slope.yposful -info.inspect_slope.ystart_zoom

; update screen coor x_pos,y_pos
         info.inspect_slope.x_pos = (xpos_new+0.5)*info.inspect_slope.zoom_x
         info.inspect_slope.y_pos = (ypos_new+0.5)*info.inspect_slope.zoom

        widget_control,info.inspect_slope.pix_label[0],set_value=info.inspect_slope.xposful+1
        widget_control,info.inspect_slope.pix_label[1],set_value=info.inspect_slope.yposful+1

        misql_update_pixel_location,info



; If the Frame values for pixel window is open - destroy
        if(XRegistered ('mpixel')) then begin
            widget_control,info.RPixelInfo,/destroy
        endif
        

        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end

;_______________________________________________________________________
; click on a  different pixel to query the values

    (strmid(event_name,0,10) EQ 'misqlpixel') : begin
        if(event.type eq 1) then begin 
            xvalue = event.x    ; starts at 0
            yvalue = event.y    ; starts at 0

;; test for out of bounds area
            x = (xvalue)/info.inspect_slope.zoom
            y = (yvalue)/info.inspect_slope.zoom
            if(x gt info.data.slope_xsize) then x = info.data.slope_xsize-1
            if(y gt info.data.slope_ysize) then y = info.data.slope_ysize-1
            xvalue = x * info.inspect_slope.zoom
            yvalue = y * info.inspect_slope.zoom
;;
            
            info.inspect_slope.x_pos = xvalue ;value in image screen 
            info.inspect_slope.y_pos = yvalue ;


            xposful = (xvalue/info.inspect_slope.zoom_x)+ info.inspect_slope.xstart_zoom
            yposful = (yvalue/info.inspect_slope.zoom)+ info.inspect_slope.ystart_zoom

            info.inspect_slope.xposful = xposful
            info.inspect_slope.yposful = yposful

            if(xposful gt info.data.slope_xsize or yposful gt info.data.slope_ysize) then begin
                ok = dialog_message(" Area out of range",/Information)
                return
            endif

; update screen coor x_pos,y_pos            
            xnew = fix(xvalue/info.inspect_slope.zoom_x)
            ynew = fix(yvalue/info.inspect_slope.zoom)

            info.inspect_slope.x_pos = (xnew+0.5)*info.inspect_slope.zoom_x
            info.inspect_slope.y_pos = (ynew+0.5)*info.inspect_slope.zoom

            widget_control,info.inspect_slope.pix_label[0],set_value = info.inspect_slope.xposful+1
            widget_control,info.inspect_slope.pix_label[1],set_value = info.inspect_slope.yposful+1

            misql_update_pixel_location,info

; If the Frame values for pixel window is open - destroy
            if(XRegistered ('mpixel')) then begin
                widget_control,info.RPixelInfo,/destroy
            endif
        endif

        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end
;_______________________________________________________________________

   (strmid(event_name,0,8) EQ 'getframe') : begin
       

	x = info.inspect_slope.xposful 
	y = info.inspect_slope.yposful


        msql_read_rampdata,x,y,pixeldata,info
        if ptr_valid (info.image_pixel.pixeldata) then ptr_free,info.image_pixel.pixeldata
        info.image_pixel.pixeldata = ptr_new(pixeldata)



; reference corrected data
        refcorrected_data = pixeldata
        refcorrected_data[*,*] = 0 
        id_data = refcorrected_data
        lc_data = refcorrected_data

;        print,info.control.file_refcorrection_exist
        if(info.control.file_refcorrection_exist eq 1) then  begin
            
            msql_read_refcorrected_data,x,y,info
            refcorrected_data = (*info.slope.prefcorrected_pixeldata)
        endif
        if ptr_valid (info.image_pixel.refcorrected_pixeldata) then $
          ptr_free,info.image_pixel.refcorrected_pixeldata
        info.image_pixel.refcorrected_pixeldata = ptr_new(refcorrected_data)        

; fill in the frame IDS, if the file was written
        if(info.control.file_ids_exist eq 1) then begin 
            msql_read_id_data,x,y,info
            id_data = (*info.slope.pid_pixeldata)
        endif
        if ptr_valid (info.image_pixel.id_pixeldata) then $
          ptr_free,info.image_pixel.id_pixeldata
        info.image_pixel.id_pixeldata = ptr_new(id_data)        


; fill in the linearity corrected data, if the file was written
        if(info.control.file_lc_exist eq 1 ) then begin 
            msql_read_lc_data,x,y,info
            lc_data = (*info.slope.plc_pixeldata)
        endif
        if ptr_valid (info.image_pixel.lc_pixeldata) then $
          ptr_free,info.image_pixel.lc_pixeldata
        info.image_pixel.lc_pixeldata = ptr_new(lc_data)        
        lc_data = 0

; ref pixel
        ref_pixeldata = fltarr(info.data.nints,info.data.nramps,1)
        get_ref_pixeldata,info,1,x,y,ref_pixeldata
        if ptr_valid (info.image_pixel.ref_pixeldata) then $
          ptr_free,info.image_pixel.ref_pixeldata
        info.image_pixel.ref_pixeldata = ptr_new(ref_pixeldata)


; fill in mean dark  corrected, if the file was written
        if(info.control.file_mdc_exist eq 1) then begin
            msql_read_mdc_data,x,y,info
            mdc_data = (*info.slope.pmdc_pixeldata) 
        endif

        if ptr_valid (info.image_pixel.mdc_pixeldata) then $
          ptr_free,info.image_pixel.mdc_pixeldata
        info.image_pixel.mdc_pixeldata = ptr_new(mdc_data)

; fill in reset  corrected, if the file was written
        if(info.control.file_reset_exist eq 1) then begin
            msql_read_reset_data,x,y,info
            reset_data = (*info.slope.preset_pixeldata)

        endif

        if ptr_valid (info.image_pixel.reset_pixeldata) then $
          ptr_free,info.image_pixel.reset_pixeldata
        info.image_pixel.reset_pixeldata = ptr_new(reset_data)


; fill in lastframe  corrected, if the file was written
        if(info.control.file_lastframe_exist eq 1) then begin
            msql_read_lastframe_data,x,y,info

            lastframe_data = (*info.slope.plastframe_pixeldata) 
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



        info.image_pixel.start_fit = info.inspect_slope.start_fit
        info.image_pixel.end_fit = info.inspect_slope.end_fit

        
        info.image_pixel.nints = info.data.nints
        info.image_pixel.integrationNo = info.inspect_slope.integrationNO
        info.image_pixel.nframes = info.data.nramps
        info.image_pixel.nslopes = info.data.nslopes
        info.image_pixel.slope_exist = info.data.slope_exist
        info.image_pixel.slope = (*info.inspect_slope.preduced)[x,y,0]

        if(info.data.slope_zsize eq 2 or info.data.slope_zsize eq 3) then begin
            info.image_pixel.zeropt =  (*info.inspect_slope.preduced)[x,y,1]
            info.image_pixel.uncertainty  = 0
            info.image_pixel.quality_flag =  0
            info.image_pixel.zeropt =  0
            info.image_pixel.ngood =  0
            info.image_pixel.nframesat =0  
            info.image_pixel.ngoodseg = 0

        endif else begin 


            info.image_pixel.uncertainty  = (*info.inspect_slope.preduced)[x,y,1]
            info.image_pixel.quality_flag =  (*info.inspect_slope.preduced)[x,y,2]
            info.image_pixel.zeropt =  (*info.inspect_slope.preduced)[x,y,3]
            info.image_pixel.ngood =  (*info.inspect_slope.preduced)[x,y,4]
            info.image_pixel.nframesat =  (*info.inspect_slope.preduced)[x,y,5]
            info.image_pixel.ngoodseg = 0
            info.image_pixel.filename = info.control.filename_slope
            info.image_pixel.ngoodseg =  (*info.inspect_slope.preduced)[x,y,6]
        endelse
	display_frame_values,x,y,info,0
    end

else: print,event_name
endcase
end

;_______________________________________________________________________
;***********************************************************************
pro misql_update_images,info,ps = ps,eps = eps
;_______________________________________________________________________
hcopy = 0
loadct,info.col_table,/silent
if ( (keyword_set(ps)) or ( keyword_set(eps)) ) then hcopy = 1

n_pixels = float( (info.data.slope_xsize) * (info.data.slope_ysize))

ititle =  "Integration #: " + strtrim(string(info.inspect_slope.integrationNO+1),2) 
         
widget_control,info.inspect_slope.iLabelID,set_value= ititle


i = info.inspect_slope.integrationNO


zoom = info.inspect_slope.zoom

x = info.inspect_slope.xposful ; xposful = x location in full image
y = info.inspect_slope.yposful ; yposful = y location in full image


if(zoom eq 1) then begin
    x = info.data.slope_xsize/2
    y = info.data.slope_ysize/2

endif
xsize_org =  info.inspect_slope.xplotsize
ysize_org =  info.inspect_slope.yplotsize

if(zoom eq 1) then begin 
  xsize = xsize_org
  ysize = ysize_org
endif
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

xdata_end = info.data.slope_xsize
ydata_end = info.data.slope_ysize
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
;    print,' need to change xstart ',xend, xend - (xsize-1)
    xstart = xend - (xsize-1)
endif
if(yend ge ydata_end) then begin
    yend = ydata_end-1
;    print,' need to change ystart ', yend,yend - (ysize-1)
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

info.inspect_slope.ixstart_zoom = ixstart
info.inspect_slope.xstart_zoom = xstart

info.inspect_slope.iystart_zoom = iystart
info.inspect_slope.ystart_zoom = ystart

info.inspect_slope.yend_zoom = yend
info.inspect_slope.xend_zoom = xend

frame_image = (*info.inspect_slope.pdata)

sub_image = fltarr(xsize,ysize)   

sub_image[ixstart:ixend,iystart:iyend] =frame_image[xstart:xend,ystart:yend]
stat_data =     sub_image


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
if ptr_valid (info.inspect_slope.psubdata) then ptr_free,info.inspect_slope.psubdata
info.inspect_slope.psubdata = ptr_new(sub_image)

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


if(info.data.subarray eq 0) then begin  
    frame_image_noref  = frame_image[4:1027,*]
endif else begin
    if(info.data.colstart eq 1) then begin
        frame_image_noref = frame_image[4:*,*]
    endif else begin
        frame_image_noref = frame_image
    endelse
endelse 
    

get_image_stat,frame_image_noref,image_mean,stdev,image_min,image_max,$
               irange_min,irange_max,image_median,stdev_mean,skew,ngood,nbad
frame_image = 0                 ; free memory
frame_image_noref = 0
;_______________________________________________________________________
widget_control,info.inspect_slope.graphID,draw_xsize=info.inspect_slope.xplotsize,$
               draw_ysize=info.inspect_slope.yplotsize
if(hcopy eq 0 ) then wset,info.inspect_slope.pixmapID


;_______________________________________________________________________
; check if default scale is true - then reset to orginal value
if(info.inspect_slope.default_scale_graph eq 1) then begin
    info.inspect_slope.graph_range[0] = irange_min
    info.inspect_slope.graph_range[1] = irange_max
endif


xsize_image = info.inspect_slope.xplotsize 
ysize_image  = info.inspect_slope.yplotsize 

disp_image = congrid(sub_image, $
                     xsize_image,ysize_image)

test_image = disp_image

disp_image = bytscl(disp_image,min=info.inspect_slope.graph_range[0], $
                    max=info.inspect_slope.graph_range[1],top=info.col_max,/nan)
tv,disp_image,0,0,/device

if( hcopy eq 0) then begin  
    wset,info.inspect_slope.draw_window_id
    device,copy=[0,0,xsize_image,ysize_image, $
                 0,0,info.inspect_slope.pixmapID]
endif

mean = image_mean
stdev = stdev
min = image_min
max = image_max
median = image_median
st_mean = stdev_mean
skew = skew




size_sub = size(sub_image)
size_test = size(test_image)

xzoom = float(size_test[1])/float(size_sub[1])
yzoom = float(size_test[2])/float(size_sub[2])
info.inspect_slope.zoom_x = xzoom; off from zoom a bit because of 1032 image


if(hcopy eq 1) then begin 
    svalue = "Science Image"
    ititle = "Integration #: " + strtrim(string(i+1),2)
    sstitle = info.control.filebase+'.fits'
    mtitle = "Mean: " + strtrim(string(mean,format="(g14.6)"),2) 
    mintitle = "Min value: " + strtrim(string(min,format="(g14.6)"),2) 
    maxtitle = "Max value: " + strtrim(string(max,format="(g14.6)"),2) 

    xyouts,0.75*!D.X_Vsize,0.95*!D.Y_VSize,sstitle,/device
    xyouts,0.75*!D.X_Vsize,0.90*!D.Y_VSize,svalue,/device
    xyouts,0.75*!D.X_Vsize,0.80*!D.Y_VSize,ititle,/device
    xyouts,0.75*!D.X_Vsize,0.75*!D.Y_VSize,mtitle,/device
    xyouts,0.75*!D.X_Vsize,0.70*!D.Y_VSize,mintitle,/device
    xyouts,0.75*!D.X_Vsize,0.65*!D.Y_VSize,maxtitle,/device
endif


;widget_control,info.inspect_slope.low_foundID,set_value='# ' + strcompress(string(num_low),/remove_all)
;widget_control,info.inspect_slope.high_foundID,set_value='# ' + strcompress(string(num_high),/remove_all)

; full image stats

widget_control,info.inspect_slope.slabelID[0],set_value=info.inspect_slope.sname[0]+ strtrim(string(mean,format="(g14.6)"),2) 
widget_control,info.inspect_slope.slabelID[1],set_value=info.inspect_slope.sname[1]+ strtrim(string(stdev,format="(g14.6)"),2) 
widget_control,info.inspect_slope.slabelID[2],set_value=info.inspect_slope.sname[2]+ strtrim(string(median,format="(g14.6)"),2) 
widget_control,info.inspect_slope.slabelID[3],set_value=info.inspect_slope.sname[3]+ strtrim(string(min,format="(g14.6)"),2) 
widget_control,info.inspect_slope.slabelID[4],set_value=info.inspect_slope.sname[4]+ strtrim(string(max,format="(g14.6)"),2) 

widget_control,info.inspect_slope.slabelID[5],set_value=info.inspect_slope.sname[5]+ strtrim(string(skew,format="(g14.6)"),2) 
widget_control,info.inspect_slope.slabelID[6],set_value=info.inspect_slope.sname[6]+ strtrim(string(ngood,format="(i10)"),2) 
widget_control,info.inspect_slope.slabelID[7],set_value=info.inspect_slope.sname[7]+ strtrim(string(nbad,format="(i10)"),2) 

widget_control,info.inspect_slope.rlabelID[0],set_value=info.inspect_slope.graph_range[0]
widget_control,info.inspect_slope.rlabelID[1],set_value=info.inspect_slope.graph_range[1]


; zoom image stats



if(info.inspect_slope.zoom gt info.inspect_slope.set_zoom) then begin 

 subt = "Statisical Information for Zoom Region"
 sf = "Reference Pixels NOT Included"
 widget_control,info.inspect_slope.zlabelID,set_value = subt
 widget_control,info.inspect_slope.zlabel1,set_value = sf

 widget_control,info.inspect_slope.zslabelID[0],$
                set_value=info.inspect_slope.sname[0]+ strtrim(string(z_mean,format="(g14.6)"),2) 
 widget_control,info.inspect_slope.zslabelID[1],$
                set_value=info.inspect_slope.sname[1]+ strtrim(string(z_stdev,format="(g14.6)"),2) 
 widget_control,info.inspect_slope.zslabelID[2],$
                set_value=info.inspect_slope.sname[2]+ strtrim(string(z_median,format="(g14.6)"),2) 
 widget_control,info.inspect_slope.zslabelID[3],$
                set_value=info.inspect_slope.sname[3]+ strtrim(string(z_min,format="(g14.6)"),2) 
 widget_control,info.inspect_slope.zslabelID[4],$
                set_value=info.inspect_slope.sname[4]+ strtrim(string(z_max,format="(g14.6)"),2) 

 widget_control,info.inspect_slope.zslabelID[5],$
                set_value=info.inspect_slope.sname[5]+ strtrim(string(z_skew,format="(g14.6)"),2) 
 widget_control,info.inspect_slope.zslabelID[6],$
                set_value=info.inspect_slope.sname[6]+ strtrim(string(z_good,format="(i10)"),2) 
 widget_control,info.inspect_slope.zslabelID[7],$
                set_value=info.inspect_slope.sname[7]+ strtrim(string(z_bad,format="(i10)"),2) 
endif else begin 
    subt = ''
    sf = ''

    widget_control,info.inspect_slope.zlabelID,set_value = subt
    widget_control,info.inspect_slope.zlabel1,set_value = sf
    widget_control,info.inspect_slope.zslabelID[0],set_value=' ' 
    widget_control,info.inspect_slope.zslabelID[1],set_value=' ' 
    widget_control,info.inspect_slope.zslabelID[2],set_value=' ' 
    widget_control,info.inspect_slope.zslabelID[3],set_value=' ' 
    widget_control,info.inspect_slope.zslabelID[4],set_value=' ' 
    widget_control,info.inspect_slope.zslabelID[5],set_value=' ' 
    widget_control,info.inspect_slope.zslabelID[6],set_value=' ' 
    widget_control,info.inspect_slope.zslabelID[7],set_value=' ' 

endelse


; replot the pixel location

halfpixelx = 0.5* info.inspect_slope.zoom_x
halfpixely = 0.5* info.inspect_slope.zoom
xpos1 = info.inspect_slope.x_pos-halfpixelx
xpos2 = info.inspect_slope.x_pos+halfpixelX

ypos1 = info.inspect_slope.y_pos-halfpixely
ypos2 = info.inspect_slope.y_pos+halfpixely

box_coords1 = [xpos1,xpos2,ypos1,ypos2]
plots,box_coords1[[0,0,1,1,0]],box_coords1[[2,3,3,2,2]],psym=0,/device


sub_image = 0
test_image = 0
widget_control,info.Quicklook,set_uvalue = info
end


;***********************************************************************
pro misql_find_limits,info
;***********************************************************************
sub_image = (*info.inspect_slope.psubdata)
asize = size(sub_image)
xsize = asize[1]


low_limit_value = info.inspect_slope.limit_low

high_limit_value = info.inspect_slope.limit_high

index_low = where(sub_image lt low_limit_value,num_low)
index_high = where(sub_image gt high_limit_value,num_high)

info.inspect_slope.limit_low_num = num_low
info.inspect_slope.limit_high_num = num_high


if(num_low ge 1 or num_high ge 1) then begin
    wset,info.inspect_slope.draw_window_id
    color6

    if(num_low ge 1) then begin 
        yvalue = index_low/xsize
        xvalue = index_low - (yvalue*xsize)
        xvalue = xvalue + 0.5
        yvalue = yvalue + 0.5
        yvalue = yvalue*info.inspect_slope.zoom
        xvalue = xvalue*info.inspect_slope.zoom_x
        plots,xvalue,yvalue,color=2,psym=1,/device

        if ptr_valid (info.inspect_slope.plowx) then ptr_free,info.inspect_slope.plowx
        info.inspect_slope.plowx = ptr_new(xvalue)
        xvalue = 0

        if ptr_valid (info.inspect_slope.plowy) then ptr_free,info.inspect_slope.plowy
        info.inspect_slope.plowy = ptr_new(yvalue)
        yvalue = 0
    endif

    if(num_high ge 1) then begin 
        yvalue = index_high/xsize
        xvalue = index_high - (yvalue*xsize)

        xvalue = xvalue + 0.5
        yvalue = yvalue + 0.5
        yvalue = yvalue*info.inspect_slope.zoom
        xvalue = xvalue*info.inspect_slope.zoom_x

        plots,xvalue,yvalue,color=4,psym=1,/device
        if ptr_valid (info.inspect_slope.phighx) then ptr_free,info.inspect_slope.phighx
        info.inspect_slope.phighx = ptr_new(xvalue)
        xvalue = 0

        if ptr_valid (info.inspect_slope.phighy) then ptr_free,info.inspect_slope.phighy
        info.inspect_slope.phighy = ptr_new(yvalue)
        yvalue = 0
    endif

endif

widget_control,info.inspect_slope.low_foundID,set_value='# ' + strcompress(string(num_low),/remove_all)
widget_control,info.inspect_slope.high_foundID,set_value='# ' + strcompress(string(num_high),/remove_all)
sub_image = 0
xvalue = 0
yvalue = 0
index_low = 0
index_high = 0
widget_control,info.Quicklook,set_uvalue = info
end
;_______________________________________________________________________
;***********************************************************************
pro misql_update_pixel_location,info
;***********************************************************************

xvalue = info.inspect_slope.xposful ; location in image 
yvalue = info.inspect_slope.yposful

i = info.inspect_slope.integrationNO

ss = 'NA'
su = 'NA'
sseg = 'NA'
sf = 'NA'
sz = 'NA'
sn = 'NA'
ssat = 'NA'
srms = 'NA'
slopevalue = (*info.inspect_slope.preduced)[xvalue,yvalue,0]
ss =  strtrim(string(slopevalue,format="("+info.inspect_slope.pix_statFormat[1]+")"),2)
if(info.data.slope_zsize eq 2) then begin
    zpt  = (*info.inspect_slope.preduced)[xvalue,yvalue,1]
endif
if(info.data.slope_zsize eq 3) then begin
    zpt  = (*info.inspect_slope.preduced)[xvalue,yvalue,1]
    rms = (*info.inspect_slope.preduced)[xvalue,yvalue,2]
    srms =   strtrim(string(rms,format="("+info.inspect_slope.pix_statFormat[5]+")"),2)
endif


if(info.data.slope_zsize gt 3) then begin
    unc = (*info.inspect_slope.preduced)[xvalue,yvalue,1]
    df = (*info.inspect_slope.preduced)[xvalue,yvalue,2]
    zpt  = (*info.inspect_slope.preduced)[xvalue,yvalue,3]
    ngood  = (*info.inspect_slope.preduced)[xvalue,yvalue,4]
    fsat  = (*info.inspect_slope.preduced)[xvalue,yvalue,5]


    su =     strtrim(string(unc,format="("+info.inspect_slope.pix_statFormat[2]+")"),2)
    sf = strtrim(string(df,format="("+info.inspect_slope.pix_statFormat[3]+")"),2)
    sn = strtrim(string(ngood,format="("+info.inspect_slope.pix_statFormat[8]+")"),2)
    ssat = strtrim(string(fsat,format="("+info.inspect_slope.pix_statFormat[6]+")"),2)
endif


sz  = strtrim(string(zpt,format="("+info.inspect_slope.pix_statFormat[4]+")"),2)

if(info.data.slope_zsize eq 7) then begin 
        gseg = (*info.inspect_slope.preduced)[xvalue,yvalue,6]
        sseg =   strtrim(string(gseg,format="("+info.inspect_slope.pix_statFormat[7]+")"),2)
    endif

if(info.data.slope_zsize eq 8) then begin 
        gseg = (*info.inspect_slope.preduced)[xvalue,yvalue,6]
        sseg =   strtrim(string(gseg,format="("+info.inspect_slope.pix_statFormat[7]+")"),2)
        rms = (*info.inspect_slope.preduced)[xvalue,yvalue,7]
        srms =   strtrim(string(rms,format="("+info.inspect_slope.pix_statFormat[5]+")"),2)
    endif

if(info.data.slope_zsize gt 8) then begin

    max2pt = (*info.inspect_slope.preduced)[xvalue,yvalue,8]
    imax2pt = (*info.inspect_slope.preduced)[xvalue,yvalue,9]
    stdev2pt=  (*info.inspect_slope.preduced)[xvalue,yvalue,10]
    slope2pt =  (*info.inspect_slope.preduced)[xvalue,yvalue,11]
endif
scal = 'NA'
if(info.data.cal_exist) then begin 
    cal = (*info.inspect_slope.pcaldata)[xvalue,yvalue,0]
    scal = strtrim(string(cal,format="("+info.inspect_slope.pix_statFormat[9]+")"),2)
endif

dead_pixel = 0
dead_pixel = (*info.badpixel.pmask)[xvalue,yvalue]
dead_str = 'No '
if(dead_pixel and 0) then dead_str = 'Yes' 
if(info.control.display_apply_bad eq 0) then dead_str = 'NA'


widget_control,info.inspect_slope.pix_statID[0],$
                   set_value= info.inspect_slope.pix_statLabel[0] + ' = ' + $
                   strtrim(string(dead_str,format="("+info.inspect_slope.pix_statFormat[0]+")"),2)

widget_control,info.inspect_slope.pix_statID[1],$
               set_value= info.inspect_slope.pix_statLabel[1] + ' = ' + ss
              

widget_control,info.inspect_slope.pix_statID[2],$
               set_value= info.inspect_slope.pix_statLabel[2] + ' = ' + su


widget_control,info.inspect_slope.pix_statID[3],$
               set_value= info.inspect_slope.pix_statLabel[3] + ' = ' + sf


widget_control,info.inspect_slope.pix_statID[4],$
               set_value= info.inspect_slope.pix_statLabel[4] + ' = ' + sz


widget_control,info.inspect_slope.pix_statID[5],$
               set_value= info.inspect_slope.pix_statLabel[5] + ' = ' + srms


widget_control,info.inspect_slope.pix_statID[6],$
               set_value= info.inspect_slope.pix_statLabel[6] + ' = ' + ssat



widget_control,info.inspect_slope.pix_statID[7],$
               set_value= info.inspect_slope.pix_statLabel[7] + ' = ' + sseg


widget_control,info.inspect_slope.pix_statID[8],$
               set_value= info.inspect_slope.pix_statLabel[8] + ' = ' + sn

widget_control,info.inspect_slope.pix_statID[9],$
               set_value= info.inspect_slope.pix_statLabel[9] + ' = ' + scal


if(info.data.slope_zsize gt 8) then begin 

;    widget_control,info.inspect_slope.pix_statID2[0],$
;                   set_value= info.inspect_slope.pix_statLabel2[0] + ' = ' + $
;                   strtrim(string(rms,format="("+info.inspect_slope.pix_statFormat2[0]+")"),2)

    widget_control,info.inspect_slope.pix_statID2[0],$
                   set_value= info.inspect_slope.pix_statLabel2[1] + ' = ' + $
                   strtrim(string(max2pt,format="("+info.inspect_slope.pix_statFormat2[1]+")"),2)

    widget_control,info.inspect_slope.pix_statID2[1],$
                   set_value= info.inspect_slope.pix_statLabel2[2] + ' = ' + $
                   strtrim(string(float(imax2pt),format="("+info.inspect_slope.pix_statFormat2[2]+")"),2)

    widget_control,info.inspect_slope.pix_statID2[2],$
                   set_value= info.inspect_slope.pix_statLabel2[3] + ' = ' + $
                   strtrim(string(slope2pt,format="("+info.inspect_slope.pix_statFormat2[3]+")"),2)

    widget_control,info.inspect_slope.pix_statID2[3],$
                   set_value= info.inspect_slope.pix_statLabel2[4] + ' = ' + $
                   strtrim(string(stdev2pt,format="("+info.inspect_slope.pix_statFormat2[4]+")"),2)

endif

wset,info.inspect_slope.draw_window_id



xsize_image = info.inspect_slope.xplotsize 
ysize_image  = info.inspect_slope.yplotsize 

device,copy=[0,0,xsize_image,ysize_image, $
             0,0,info.inspect_slope.pixmapID]


halfpixelx = 0.5* info.inspect_slope.zoom_x
halfpixely = 0.5* info.inspect_slope.zoom
xpos1 = info.inspect_slope.x_pos-halfpixelx
xpos2 = info.inspect_slope.x_pos+halfpixelX

ypos1 = info.inspect_slope.y_pos-halfpixely
ypos2 = info.inspect_slope.y_pos+halfpixely

box_coords1 = [xpos1,xpos2,ypos1,ypos2]
plots,box_coords1[[0,0,1,1,0]],box_coords1[[2,3,3,2,2]],psym=0,/device


if(info.inspect_slope.limit_low_num gt 0) then begin
    color6
    xvalue = (*info.inspect_slope.plowx)
    yvalue = (*info.inspect_slope.plowy)
    plots,xvalue,yvalue,color=2,psym=1,/device
    xvalue = 0
    yvalue = 0
endif

if(info.inspect_slope.limit_high_num gt 0) then begin 
    color6
    xvalue = (*info.inspect_slope.phighx)
    yvalue = (*info.inspect_slope.phighy)
    plots,xvalue,yvalue,color=4,psym=1,/device
    xvalue = 0
    yvalue = 0
endif


widget_control,info.Quicklook,set_uvalue = info
end



;_______________________________________________________________________
;***********************************************************************
pro misql_display_images,info
;_______________________________________________________________________


if(info.inspect_slope.uwindowsize eq 0) then begin ; user changed the widget window size - only redisplay

; labels used for the Pixel Statistics Table
    info.inspect_slope.draw_window_id = 0
    info.inspect_slope.pixmapID = 0
    info.inspect_slope.graphID = 0
    info.inspect_slope.image_recomputeID=0
    info.inspect_slope.slabelID[*] = 0L
    info.inspect_slope.rlabelID[*] = 0L
    info.inspect_slope.x_pos = 0
    info.inspect_slope.y_pos = 0
    info.inspect_slope.limit_high_default = 1
    info.inspect_slope.limit_low_default = 1

    info.inspect_slope.zoom = 1
    info.inspect_slope.zoom_x = 1
    info.inspect_slope.x_pos =(info.data.slope_xsize)/2.0
    info.inspect_slope.y_pos = (info.data.slope_ysize)/2.0

    info.inspect_slope.xposful = info.inspect_slope.x_pos
    info.inspect_slope.yposful = info.inspect_slope.y_pos

    info.inspect_slope.limit_low = -5000.0
    info.inspect_slope.limit_high = 5000.0
    info.inspect_slope.limit_low_num = 0
    info.inspect_slope.limit_high_num = 0
endif
;*********
;Setup main panel
;*********

window,1,/pixmap
wdelete,1


if(XRegistered ('misql')) then begin
    widget_control,info.InspectSlope,/destroy
endif


; widget window parameters
xwidget_size = 1500
ywidget_size = 1100
xsize_scroll = 1450
ysize_scroll = 1100


if(info.inspect_slope.uwindowsize eq 1) then begin ; user has set window size 
    xsize_scroll = info.inspect_slope.xwindowsize
    ysize_scroll = info.inspect_slope.ywindowsize
endif
if(info.control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.control.x_scroll_window
if(info.control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.control.y_scroll_window

if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10



info.InspectSlope = widget_base(title="MIRI Quick Look- Inspect Reduced Image" + info.version,$
                                mbar = menuBar,/row,group_leader = info.Quicklook,$
                                xsize =  xwidget_size,$
                                ysize=   ywidget_size,/scroll,$
                                x_scroll_size= xsize_scroll,$
                                y_scroll_size = ysize_scroll,/TLB_SIZE_EVENTS)

;********
; build the menubar
;********
QuitMenu = widget_button(menuBar,value="Quit",font = info.font2)

; add quit button
quitbutton = widget_button(quitmenu,value="Quit",event_pro='misql_quit')

; zoom button
ZoomMenu = widget_button(menuBar,value="Zoom",font = info.font2)

; add quit button
info.inspect_slope.zbutton[0] = widget_button(Zoommenu,value="No Zoom",uvalue='zoom0',/checked_menu)
info.inspect_slope.zbutton[1] = widget_button(Zoommenu,value="Zoom 2x",uvalue='zoom1',/checked_menu)
info.inspect_slope.zbutton[2] = widget_button(Zoommenu,value="Zoom 4x",uvalue='zoom2',/checked_menu)
info.inspect_slope.zbutton[3] = widget_button(Zoommenu,value="Zoom 8x",uvalue='zoom3',/checked_menu)
info.inspect_slope.zbutton[4] = widget_button(Zoommenu,value="Zoom 16x",uvalue='zoom4',/checked_menu)
info.inspect_slope.zbutton[5] = widget_button(Zoommenu,value="Zoom 32x",uvalue='zoom5',/checked_menu)

PMenu = widget_button(menuBar,value="Print",font = info.font2)
PbuttonR = widget_button(Pmenu,value = "Print Science Image to output file",uvalue='prints')
;*****
; setup the image windows
;*****
; set up for Raw image widget window

graphID_master1 = widget_base(info.InspectSlope,row=1)
graphID1 = widget_base(graphID_master1,col=1)
graphID2  = widget_base(graphID_master1,col=1)
;_______________________________________________________________________  

;*****
;graph full images
;*****



xplotsize = info.data.slope_xsize
yplotsize = info.data.slope_ysize

info.inspect_slope.set_zoom = 1


if (xplotsize lt 1032) then begin
    find_zoom,xplotsize,yplotsize,zoom
    info.inspect_slope.zoom = zoom
    info.inspect_slope.set_zoom = zoom
    xplotsize = info.data.slope_xsize * zoom
    yplotsize = info.data.slope_ysize * zoom
endif

if(info.inspect_slope.zoom eq 1) then widget_control,info.inspect_slope.zbutton[0],set_button = 1
if(info.inspect_slope.zoom eq 2) then widget_control,info.inspect_slope.zbutton[1],set_button = 1
if(info.inspect_slope.zoom eq 4) then widget_control,info.inspect_slope.zbutton[2],set_button = 1
if(info.inspect_slope.zoom eq 8) then widget_control,info.inspect_slope.zbutton[3],set_button = 1
if(info.inspect_slope.zoom eq 16) then widget_control,info.inspect_slope.zbutton[4],set_button = 1
if(info.inspect_slope.zoom eq 32) then widget_control,info.inspect_slope.zbutton[5],set_button = 1

info.inspect_slope.xplotsize = xplotsize
info.inspect_slope.yplotsize = yplotsize


info.inspect_slope.graphID = widget_draw(graphID1,$
                              xsize = xplotsize,$
                              ysize = yplotsize,$
                              /Button_Events,$
                              retain=info.retn,uvalue='misqlpixel')

;_______________________________________________________________________
;  Information on the image

xsize_label = 8
; 
; statistical information - next column

blank = '                                               '

ttitle = info.control.filename_raw 

ititle =  "Integration #: " + strtrim(string(info.inspect_slope.integrationNO+1),2) 

         
graph_label = widget_label(graphID2,value=ttitle,/align_left,font = info.font5)
ss = "Image Size [" + strtrim(string(info.data.slope_xsize),2) + ' x ' +$
        strtrim(string(info.data.slope_ysize),2) + ']'

size_label= widget_label(graphID2,value = ss,/align_left)

base1 = widget_base(graphID2,row= 1,/align_left)
info.inspect_slope.iLabelID = widget_label(base1,value= ititle,/align_left)


blank10 = '               '

;-----------------------------------------------------------------------
; min and max scale of  image


base1 = widget_base(graphID2,row= 1,/align_left)
r_label1 = widget_label(base1,value="Change Image Scale" ,/align_left,font=info.font5,$
                       /sunken_frame)


info.inspect_slope.image_recomputeID = widget_button(base1,value=' Image Scale ',font=info.font3,$
                                          uvalue = 'sinspect',/align_left)
base1 = widget_base(graphID2,row= 1,/align_left)
info.inspect_slope.rlabelID[0] = cw_field(base1,title="Minimum",font=info.font3,uvalue="isr_b",$
                              /float,/return_events,xsize=xsize_label,value =range_min)

info.inspect_slope.rlabelID[1] = cw_field(base1,title="Maximum",font=info.font3,uvalue="isr_t",$
                         /float,/return_events,xsize = xsize_label,value =range_max)


base1 = widget_base(graphID2,row= 1,/align_left)
info.inspect_slope.limit_lowID = cw_field(base1,title="Mark Values below (Red)",font=info.font3,uvalue="limit_low",$
                         /float,/return_events,xsize = xsize_label,value =info.inspect_slope.limit_low)



info.inspect_slope.low_foundID=widget_label(base1,value = '# =         ' ,/align_left)


base1 = widget_base(graphID2,row= 1,/align_left)
info.inspect_slope.limit_highID = cw_field(base1,title="Mark Values above (Blue)",font=info.font3,uvalue="limit_high",$
                         /float,/return_events,xsize = xsize_label,value =info.inspect_slope.limit_high)

info.inspect_slope.high_foundID=widget_label(base1,value = '# =         ' ,/align_left)
;-----------------------------------------------------------------------

general_label= widget_label(graphID2,$
                            value=" Pixel Information (Image: 1032 X 1024)",/align_left,$
                            font=info.font5,/sunken_frame)

pix_num_base = widget_base(graphID2,row=1,/align_left)
labelID = widget_button(pix_num_base,uvalue='pix_move_x1',value='<',font=info.font3)
labelID = widget_button(pix_num_base,uvalue='pix_move_x2',value='>',font=info.font3)

xvalue = info.inspect_slope.xposful
yvalue = info.inspect_slope.yposful

info.inspect_slope.pix_label[0] = cw_field(pix_num_base,title="x",font=info.font4, $
                                   uvalue="pix_x_val",/integer,/return_events, $
                                   value=fix(xvalue+1),xsize=6,$  ; xvalue + 1 -4 (reference pixel)
                                   fieldfont=info.font3)



pix_num_base = widget_base(graphID2,row=1,/align_left)
labelID = widget_button(pix_num_base,uvalue='pix_move_y1',value='<',font=info.font3)
labelID = widget_button(pix_num_base,uvalue='pix_move_y2',value='>',font=info.font3)
info.inspect_slope.pix_label[1] = cw_field(pix_num_base,title="y",font=info.font4, $
                                   uvalue="pix_y_val",/integer,/return_events, $
                                   value=fix(yvalue+1),xsize=6,$
                                   fieldfont=info.font3)






pix_num_base = widget_base(graphid2,/col,/align_left)

info.inspect_slope.pix_statLabel = ["Dead/hot/noisy Pixel", "Slope (DN/s)" , "Uncertainity", "Data Quality Flag" ,$
                                       "Zero Pt of Fit", "STD FIT" , "Read # 1st Sat", $
                                    "# of Good Segments" ,"# Good Frames" ,"Calibrated Value"]


info.inspect_slope.pix_statLabel2 = ["Max 2pt Diff","Read # Max 2 pt Diff",$
                                     "Slope 2pt Diff", "STDDEV 2pt diff" ]

info.inspect_slope.pix_statFormat = ["A4","F16.5" ,"F12.5" ,"I8" ,"F12.3","F12.5","F5.0","I4","F5.0","F12.5"]

info.inspect_slope.pix_statFormat2 =  ["F12.2","F7.3", "F10.5", "F12.2"]  

for i = 0,2 do begin 
    info.inspect_slope.pix_statID[i]=widget_label(pix_num_base,value = info.inspect_slope.pix_statLabel[i]+$
                                                  ' = ' ,/align_left,/dynamic_resize)
endfor

info_base = widget_base(graphid2,row=1,/align_left)

info.inspect_slope.pix_statID[3] = widget_label(info_base,value = info.inspect_slope.pix_statLabel[3]+$
                                        ' =  ' ,/align_left,/dynamic_resize)                                       
info_label = widget_button(info_base,value = 'Info',uvalue = 'datainfo')

pix_num_base = widget_base(graphid2,/col,/align_left)
for i = 4,9 do begin 
    info.inspect_slope.pix_statID[i]=widget_label(pix_num_base,value = info.inspect_slope.pix_statLabel[i]+$
                                                  ' = ' ,/align_left,/dynamic_resize)
endfor

if(info.data.slope_zsize gt 8) then begin 
    for i = 0,3 do begin 
        info.inspect_slope.pix_statID2[i]=widget_label(pix_num_base,value = info.inspect_slope.pix_statLabel2[i]+$
                                                      ' =               ' ,/align_left)
    endfor
endif

if(info.data.raw_exist eq 1) then $
  flabel = widget_button(graphID2,value="Get All Frame Values",/align_left,$
                        uvalue = "getframe")


; stats
b_label = widget_label(graphID2,value=blank)
s_label = widget_label(graphID2,value="Statisical Information" ,/align_left,/sunken_frame,font=info.font5)
s_label = widget_label(graphID2,value="Reference Pixels  NOT Included" ,/align_left)




info.inspect_slope.sname = ['Mean:              ',$
                      'Standard Deviation ',$
                      'Median:            ',$
                      'Min:               ',$
                      'Max:               ',$
                      'Skew:              ',$
                      '# of Good Pixels   ',$
                      '# of Bad/sat Pixels ']
info.inspect_slope.slabelID[0] = widget_label(graphID2,value=info.inspect_slope.sname[0] +blank10,/align_left)
info.inspect_slope.slabelID[1] = widget_label(graphID2,value=info.inspect_slope.sname[1] +blank10,/align_left)
info.inspect_slope.slabelID[2] = widget_label(graphID2,value=info.inspect_slope.sname[2] +blank10,/align_left)
info.inspect_slope.slabelID[3] = widget_label(graphID2,value=info.inspect_slope.sname[3] +blank10,/align_left)
info.inspect_slope.slabelID[4] = widget_label(graphID2,value=info.inspect_slope.sname[4] +blank10,/align_left)
info.inspect_slope.slabelID[5] = widget_label(graphID2,value=info.inspect_slope.sname[5] +blank10,/align_left)
info.inspect_slope.slabelID[6] = widget_label(graphID2,value=info.inspect_slope.sname[6] +blank10,/align_left)
info.inspect_slope.slabelID[7] = widget_label(graphID2,value=info.inspect_slope.sname[7] +blank10,/align_left)



info_label = widget_button(graphID2,value = 'Info on Bad Pixels',$
                                               event_pro = 'info_badpixel',/align_left)

; stats on zoom window
;*****
;graph 1,2; Zoom window of reference image
;*****

 subt = "Statisical Information for Zoom Region"

info.inspect_slope.zlabelID = widget_label(graphID2,value= ' ' ,/align_left,$
                            font=info.font5,/sunken_frame,/dynamic_resize)
info.inspect_slope.zlabel1 = widget_label(graphID2,value="  " ,/align_left,/dynamic_resize)

info.inspect_slope.zslabelID[0] = widget_label(graphID2,value=blank10,/align_left,/dynamic_resize)
info.inspect_slope.zslabelID[1] = widget_label(graphID2,value=blank10,/align_left,/dynamic_resize)
info.inspect_slope.zslabelID[2] = widget_label(graphID2,value=blank10,/align_left,/dynamic_resize)
info.inspect_slope.zslabelID[3] = widget_label(graphID2,value=blank10,/align_left,/dynamic_resize)
info.inspect_slope.zslabelID[4] = widget_label(graphID2,value=blank10,/align_left,/dynamic_resize)
info.inspect_slope.zslabelID[5] = widget_label(graphID2,value=blank10,/align_left,/dynamic_resize)
info.inspect_slope.zslabelID[6] = widget_label(graphID2,value=blank10,/align_left,/dynamic_resize)
info.inspect_slope.zslabelID[7] = widget_label(graphID2,value=blank10,/align_left,/dynamic_resize)

;_______________________________________________________________________
longline = '                              '
longtag = widget_label(info.InspectSlope,value = longline)

; realize main panel
Widget_control,info.InspectSlope,/Realize
XManager,'misql',info.InspectSlope,/No_Block,event_handler='misql_event'

; get the window ids of the draw windows

widget_control,info.inspect_slope.graphID,get_value=tdraw_id
info.inspect_slope.draw_window_id = tdraw_id

window,/pixmap,xsize=info.inspect_slope.xplotsize,ysize=info.inspect_slope.yplotsize,/free
info.inspect_slope.pixmapID = !D.WINDOW
loadct,info.col_table,/silent

misql_update_images,info
misql_find_limits,info

misql_update_pixel_location,info

Widget_Control,info.QuickLook,Set_UValue=info
iinfo = {info        : info}

Widget_Control,info.InspectSlope,Set_UValue=iinfo
Widget_Control,info.QuickLook,Set_UValue=info
end

