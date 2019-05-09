;_______________________________________________________________________
;***********************************************************************
pro mirql_quit,event
;_______________________________________________________________________
widget_control,event.top, Get_UValue = ginfo	
widget_control,ginfo.info.QuickLook,Get_Uvalue = info
wdelete,info.inspect_ref.pixmapID
widget_control,info.inspectRefImage,/destroy

end
;_______________________________________________________________________
;***********************************************************************
;_______________________________________________________________________
;***********************************************************************
pro mirql_event,event
;_______________________________________________________________________
Widget_Control,event.id,Get_uValue=event_name
widget_control,event.top, Get_UValue = ginfo	
widget_control,ginfo.info.QuickLook,Get_Uvalue = info
iramp = info.inspect_ref.FrameNO

if (widget_info(event.id,/TLB_SIZE_EVENTS) eq 1 ) then begin

    info.inspect_ref.xwindowsize = event.x
    info.inspect_ref.ywindowsize = event.y
    info.inspect_ref.uwindowsize = 1
    widget_control,event.top,set_uvalue = ginfo
    widget_control,ginfo.info.Quicklook,set_uvalue = info
    mirql_display_images,info.control.filename,info.inspect_ref.integrationNO,$
                         info.inspect_ref.frameNO,info

    return
endif

jintegration = info.inspect_ref.integrationNO
    case 1 of
;_______________________________________________________________________

    (strmid(event_name,0,5) EQ 'print') : begin
        print_inspect_ref_images,info
    end    


;_______________________________________________________________________
; Change the Integration # or Frame # of image displayed
;_______________________________________________________________________
    (strmid(event_name,0,6) EQ 'integr') : begin

        if (strmid(event_name,6,1) EQ 'a') then begin 
           this_value = event.value-1
           jintegration = this_value
        endif

; check if the <> buttons were used
       if (strmid(event_name,6,5) EQ '_move')then begin
          if(strmid(event_name,12,2) eq 'dn') then begin
             jintegration = jintegration -1
          endif
          if(strmid(event_name,12,2) eq 'up') then begin
             jintegration = jintegration+1
          endif
       endif
; do some checks wrap around

       if(jintegration lt 0) then begin
            jintegration = info.data.nints-1 ; wrap around
        endif 
       if(jintegration gt info.data.nints-1  ) then begin
            jintegration = 0
        endif


        move = 0
        if(jintegration ne info.inspect_ref.integrationNO) then move = 1


        widget_control,info.inspect_ref.integration_label, set_value = jintegration+1

        if(move eq 1) then begin
            info.inspect_ref.integrationNO = jintegration

            read_single_refimage,info.control.filename_raw,jintegration,iramp,subarray,$
                                 refdata,ref_xsize,ref_ysize,$
                                 stats_ref,status,error_message

            if ptr_valid (info.inspect_ref.pdataimage) then ptr_free,info.inspect_ref.pdataimage
            info.inspect_ref.pdataimage = ptr_new(refdata)


            read_single_ref_slope,info.control.filename_slope_refimage,exists,this_int, subarray,$
              ref_image,ref_xsize,ref_ysize,ref_zsize,stats_image,status,error_message
            if (exists eq 0) then begin
                ref_image = 0
            endif
            info.data.sloperef_exist =exists
            
            if ptr_valid (info.inspect_ref.preduced) then ptr_free,info.inspect_ref.preduced
            info.inspect_ref.preduced = ptr_new(ref_image)
            ref_image = 0


            mirql_expand_data,info
            mirql_update_images,info
            mirql_update_pixel_location,info

            widget_control,info.inspect_ref.integration_label, set_value = jintegration+1
        endif
       Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end

;_______________________________________________________________________
;  Frame Button
    (strmid(event_name,0,4) EQ 'fram') : begin

        if (strmid(event_name,4,1) EQ 'e') then begin 
           this_value = event.value-1
           iramp = this_value

        endif
; check if the <> buttons were used
        if (strmid(event_name,4,5) EQ '_move')then begin

            if(strmid(event_name,10,2) eq 'dn') then begin
              iramp = iramp -1
            endif
            if(strmid(event_name,10,2) eq 'up') then begin
              iramp = iramp +1
            endif
        endif
; do some checks wrap around

        if(iramp lt 0) then begin
            iramp = info.data.nramps-1
        endif 
        if(iramp gt info.data.nramps-1  ) then begin
            iramp = 0	
        endif

        move = 0
        if(iramp ne info.inspect_ref.FrameNO) then move = 1

        if(move eq 1 ) then begin 

            info.inspect_ref.FrameNO= iramp            


            read_single_refimage,info.control.filename_raw,jintegration,iramp,subarray,$
                                 refdata,ref_xsize,ref_ysize,$
                                 stats_ref,status,error_message

            if ptr_valid (info.inspect_ref.pdataimage) then ptr_free,info.inspect_ref.pdataimage
            info.inspect_ref.pdataimage = ptr_new(refdata)


            mirql_expand_data,info
            mirql_update_images,info
            mirql_update_pixel_location,info

            widget_control,info.inspect_ref.frame_label, set_value = iramp+1
        endif

        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end
;_______________________________________________________________________

;_______________________________________________________________________
; scaling image
;_______________________________________________________________________
    (strmid(event_name,0,8) EQ 'sinspect') : begin
        if(info.inspect_ref.default_scale_graph eq 0 ) then begin ; true - turn to false
            widget_control,info.inspect_ref.image_recomputeID,set_value=' Image Scale'
            info.inspect_ref.default_scale_graph = 1
        endif

        mirql_update_images,info
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info

    end
;_______________________________________________________________________
; change range of image graphs
; if change range then also change the scale button to 'User Set
; Scale'
;_______________________________________________________________________
    (strmid(event_name,0,3) EQ 'isr') : begin

        if(strmid(event_name,4,1) EQ 'b') then begin
            info.inspect_ref.graph_range[0] = event.value
            widget_control,info.inspect_ref.rlabelID[1],get_value = temp
            info.inspect_ref.graph_range[1] = temp
        endif


        if(strmid(event_name,4,1) EQ 't') then begin
            info.inspect_ref.graph_range[1] = event.value
            widget_control,info.inspect_ref.rlabelID[0],get_value = temp
            info.inspect_ref.graph_range[0] = temp
        endif
                        
        info.inspect_ref.default_scale_graph = 0
        widget_control,info.inspect_ref.image_recomputeID,set_value=' Default Scale'

        mirql_update_images,info
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end

    
;_______________________________________________________________________
; Change limits

    (strmid(event_name,0,5) EQ 'limit') : begin

        if(strmid(event_name,6,1) EQ 'l') then begin
            info.inspect_ref.limit_low = event.value

            widget_control,info.inspect_ref.limit_highID,get_value = temp
            info.inspect_ref.limit_high = temp
        endif


        if(strmid(event_name,6,1) EQ 'h') then begin
            info.inspect_ref.limit_high = event.value
            widget_control,info.inspect_ref.limit_lowID,get_value = temp
            info.inspect_ref.limit_low = temp
        endif
        info.inspect_ref.limit_low_default = 0
        info.inspect_ref.limit_high_default = 0

        mirql_update_images,info
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end

;_______________________________________________________________________e
; zoom images
;_______________________________________________________________________
   (strmid(event_name,0,4) EQ 'zoom') : begin

       zoom = fix(strmid(event_name,4,1))
       info.inspect_ref.zoom = 2^zoom

         ; redefine the xpos and y pos value in new zoom window
         mirql_update_images,info

         
         ; xposful, uposful - x,y location in full image
         ; x_pos, y_pos = x and y location on the image screen

         xpos_new = info.inspect_ref.xposful -info.inspect_ref.xstart_zoom 
         ypos_new = info.inspect_ref.yposful -info.inspect_ref.ystart_zoom
         info.inspect_ref.x_pos = (xpos_new+0.5)*info.inspect_ref.zoom_x
         info.inspect_ref.y_pos = (ypos_new+0.5)*info.inspect_ref.zoom
         mirql_update_pixel_location,info

         for i = 0,5 do begin
             widget_control,info.inspect_ref.zbutton[i],set_button = 0
         endfor
         widget_control,info.inspect_ref.zbutton[zoom],set_button = 1
     end
;_______________________________________________________________________
; Select a different pixel
;_______________________________________________________________________
    (strmid(event_name,0,3) EQ 'pix') : begin
        xsize = info.data.ref_xsize*4
        ysize = info.data.ref_ysize
        xvalue = info.inspect_ref.xposful
        yvalue = info.inspect_ref.yposful
        xstart = xvalue
        ystart = yvalue


; ++++++++++++++++++++++++++++++
        if(strmid(event_name,4,1) eq 'x') then  begin
            xvalue = event.value ; event value - user input starts at 1 

            if(xvalue lt 0) then xvalue = 0
            if(xvalue gt xsize) then xvalue = xsize
            
            xvalue = xvalue -1
            ; check what is in y box 
            widget_control,info.inspect_ref.pix_label[1],get_value =  ytemp
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
            widget_control,info.inspect_ref.pix_label[0], get_value= xtemp
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
            if(xvalue ge  info.data.ref_xsize*4) then xvalue = info.data.ref_xsize*4-1
            if(yvalue ge  info.data.ref_ysize) then yvalue = info.data.ref_ysize-1

        endif

; ++++++++++++++++++++++++++++++

        xmove = xvalue - xstart
        ymove = yvalue - ystart
        

        info.inspect_ref.xposful = info.inspect_ref.xposful + xmove
        info.inspect_ref.yposful = info.inspect_ref.yposful + ymove

         xpos_new = info.inspect_ref.xposful -info.inspect_ref.xstart_zoom 
         ypos_new = info.inspect_ref.yposful -info.inspect_ref.ystart_zoom

; update screen coor x_pos,y_pos
         info.inspect_ref.x_pos = (xpos_new+0.5)*info.inspect_ref.zoom_x
         info.inspect_ref.y_pos = (ypos_new+0.5)*info.inspect_ref.zoom

        widget_control,info.inspect_ref.pix_label[0],set_value=info.inspect_ref.xposful+1
        widget_control,info.inspect_ref.pix_label[1],set_value=info.inspect_ref.yposful+1

        mirql_update_pixel_location,info




; If the Frame values for pixel window is open - destroy
        if(XRegistered ('mpixel')) then begin
            widget_control,info.RPixelInfo,/destroy
        endif

        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end

;_______________________________________________________________________
; click on a  different pixel to query the values

    (strmid(event_name,0,6) EQ 'npixel') : begin
        if(event.type eq 1) then begin 
            xvalue = event.x    ; starts at 0
            yvalue = event.y    ; starts at 0
;; test for out of bounds area
            x = (xvalue)/info.inspect_ref.zoom
            y = (yvalue)/info.inspect_ref.zoom
            if(x gt info.data.image_xsize) then x = info.data.image_xsize-1
            if(y gt info.data.image_ysize) then y = info.data.image_ysize-1
            xvalue = x * info.inspect_ref.zoom
            yvalue = y * info.inspect_ref.zoom
;;            


            info.inspect_ref.x_pos = xvalue ;value in image screen 
            info.inspect_ref.y_pos = yvalue ;


            xposful = (xvalue/info.inspect_ref.zoom_x)+ info.inspect_ref.xstart_zoom
            yposful = (yvalue/info.inspect_ref.zoom)+ info.inspect_ref.ystart_zoom

            info.inspect_ref.xposful = xposful
            info.inspect_ref.yposful = yposful

            if(xposful gt info.data.image_xsize )then  xposful = info.data.image_xsize
            if(yposful gt info.data.image_ysize) then   yposful = info.data.image_ysize


; update screen coor x_pos,y_pos            
            xnew = fix(xvalue/info.inspect_ref.zoom_x)
            ynew = fix(yvalue/info.inspect_ref.zoom)

            info.inspect_ref.x_pos = (xnew+0.5)*info.inspect_ref.zoom_x
            info.inspect_ref.y_pos = (ynew+0.5)*info.inspect_ref.zoom

            widget_control,info.inspect_ref.pix_label[0],set_value = info.inspect_ref.xposful+1
            widget_control,info.inspect_ref.pix_label[1],set_value = info.inspect_ref.yposful+1

            mirql_update_pixel_location,info


; If the Frame values for pixel window is open - destroy
            if(XRegistered ('mpixel')) then begin
                widget_control,info.RPixelInfo,/destroy
            endif


        endif

        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end
;_______________________________________________________________________

   (strmid(event_name,0,8) EQ 'getframe') : begin

	x = info.inspect_ref.xposful 
	y = info.inspect_ref.yposful

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
	
        if ptr_valid (info.image_pixel.id_pixeldata) then $
          ptr_free,info.image_pixel.id_pixeldata
        info.image_pixel.id_pixeldata = ptr_new(id_data)        

        if ptr_valid (info.image_pixel.lc_pixeldata) then $
          ptr_free,info.image_pixel.lc_pixeldata
        info.image_pixel.lc_pixeldata = ptr_new(lc_data)
        if ptr_valid (info.image_pixel.refcorrected_pixeldata) then $
          ptr_free,info.image_pixel.refcorrected_pixeldata
        info.image_pixel.refcorrected_pixeldata = ptr_new(refcorrected_data)                

        info.image_pixel.file_ids_exist  = 0
        info.image_pixel.file_lc_exist  = 0
        info.image_pixel.file_refcorrection_exist = 0
        info.image_pixel.start_fit = info.image.start_fit
        info.image_pixel.end_fit = info.image.end_fit
        info.image_pixel.nints = info.data.nints
        info.image_pixel.integrationNo = info.image.integrationNO
        info.image_pixel.nframes = info.data.nramps
        info.image_pixel.nslopes = info.data.nslopes
        info.image_pixel.slope_exist = info.data.sloperef_exist
        if(info.image_pixel.slope_exist and ptr_valid(info.inspect_ref.preduced)) then begin 
            xslope = x/4
            info.image_pixel.slope = (*info.inspect_ref.preduced)[xslope,y,0]
            info.image_pixel.uncertainty  = 0
            info.image_pixel.quality_flag =  0
            info.image_pixel.zeropt =  0
            info.image_pixel.ngood =  0
            info.image_pixel.nframesat =  0
            info.image_pixel.ngoodseg = 0
            info.image_pixel.ngoodseg =  0
        endif else begin
            info.image_pixel.slope = 0
            info.image_pixel.uncertainty  = 0
            info.image_pixel.quality_flag = -1
            info.image_pixel.zeropt =  0
            info.image_pixel.ngood =  0
            info.image_pixel.nframesat = 0
            info.image_pixel.ngoodseg = 0
            
        endelse

        info.image_pixel.filename = info.control.filename_raw

; Two options: 

        if( strmid(event_name,8,4) EQ 'plot') then begin

            mirql_plot_frames,x,y,info
        endif else begin 
        
            
            display_frame_values,x,y,info,1
        endelse
        
    end

else: print,'event_name not found',event_name
endcase
end
; _______________________________________________________________________
;***********************************************************************
pro mirql_expand_data,info
; _______________________________________________________________________
frame_data  = fltarr(info.data.ref_xsize*4,info.data.ref_ysize)

i = info.inspect_ref.integrationNO
j = info.inspect_ref.FrameNO


ref_data = fltarr(info.data.ref_xsize,info.data.ref_ysize)
ref_data[*,*] = (*info.inspect_ref.pdataimage)[*,*]
frame_data = fltarr(info.data.ref_xsize*4,info.data.ref_ysize)
ij = 0
ik = 0
for ii = 0,info.data.ref_xsize*4 -1 do begin
     frame_data[ii,*] = ref_data[ij,*]
     ik = ik + 1
     if(ik eq 4) then begin
         ik = 0
         ij = ij + 1
     endif
endfor

if ptr_valid (info.inspect_ref.pdata) then ptr_free,info.inspect_ref.pdata
info.inspect_ref.pdata = ptr_new(frame_data)
frame_data = 0
ref_data = 0


end


;_______________________________________________________________________
;***********************************************************************
pro mirql_update_images,info,ps = ps,eps = eps
;_______________________________________________________________________
hcopy = 0
loadct,info.col_table,/silent
if ( (keyword_set(ps)) or ( keyword_set(eps)) ) then hcopy = 1

n_pixels = float( (info.data.ref_xsize*4) * (info.data.ref_ysize))

ititle =  "Integration #: " + strtrim(string(info.inspect_ref.integrationNO+1),2) 
ftitle = "Frame #: " + strtrim(string(info.inspect_ref.FrameNO+1),2)   
         

i = info.inspect_ref.integrationNO
j = info.inspect_ref.FrameNO
widget_control,info.inspect_ref.integration_label,set_value= i+1
widget_control,info.inspect_ref.frame_label,set_value= j+1

zoom = info.inspect_ref.zoom

x = info.inspect_ref.xposful ; xposful = x location in full image
y = info.inspect_ref.yposful ; yposful = y location in full image


if(zoom eq 1) then begin
    x = info.data.image_xsize/2
    y = info.data.image_ysize/2

endif
xsize_org =  info.inspect_ref.xplotsize
ysize_org =  info.inspect_ref.yplotsize

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

xdata_end = info.data.ref_xsize*4
ydata_end = info.data.ref_ysize
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

info.inspect_ref.ixstart_zoom = ixstart
info.inspect_ref.xstart_zoom = xstart

info.inspect_ref.iystart_zoom = iystart
info.inspect_ref.ystart_zoom = ystart

info.inspect_ref.yend_zoom = yend
info.inspect_ref.xend_zoom = xend

frame_image = (*info.inspect_ref.pdata)

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
if ptr_valid (info.inspect_ref.psubdata) then ptr_free,info.inspect_ref.psubdata
info.inspect_ref.psubdata = ptr_new(sub_image)

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
    frame_image_noref = frame_image
endelse

get_image_stat,frame_image_noref,image_mean,stdev,image_min,image_max,$
               irange_min,irange_max,image_median,stdev_mean,skew,ngood,nbad
frame_image = 0                 ; free memory
frame_image_noref = 0
;_______________________________________________________________________
widget_control,info.inspect_ref.graphID,draw_xsize=info.inspect_ref.xplotsize,$
               draw_ysize=info.inspect_ref.yplotsize
if(hcopy eq 0 ) then wset,info.inspect_ref.pixmapID

;xsize_image = fix(info.data.image_xsize) 
;ysize_image = fix(info.data.image_ysize)
;if(xsize_image lt 256) then begin
    xsize_image = info.inspect_ref.xplotsize 
    ysize_image  = info.inspect_ref.yplotsize 
;endif

;_______________________________________________________________________
; check if default scale is true - then reset to orginal value
if(info.inspect_ref.default_scale_graph eq 1) then begin
    info.inspect_ref.graph_range[0] = irange_min
    info.inspect_ref.graph_range[1] = irange_max
endif


disp_image = congrid(sub_image, $
                     xsize_image,ysize_image)

test_image = disp_image

disp_image = bytscl(disp_image,min=info.inspect_ref.graph_range[0], $
                    max=info.inspect_ref.graph_range[1],top=info.col_max,/nan)
tv,disp_image,0,0,/device

if( hcopy eq 0) then begin  
    wset,info.inspect_ref.draw_window_id
    device,copy=[0,0,xsize_image,ysize_image, $
                 0,0,info.inspect_ref.pixmapID]
endif

mean = image_mean
stdev = stdev
min = image_min
max = image_max
median = image_median
st_mean = stdev_mean
skew = skew



low_limit_value = info.inspect_ref.limit_low

high_limit_value = info.inspect_ref.limit_high


index_low = where(sub_image lt low_limit_value,num_low)
index_high = where(sub_image gt high_limit_value,num_high)


info.inspect_ref.limit_low_num = num_low
info.inspect_ref.limit_high_num = num_high

size_sub = size(sub_image)
size_test = size(test_image)

xzoom = float(size_test[1])/float(size_sub[1])
yzoom = float(size_test[2])/float(size_sub[2])
info.inspect_ref.zoom_x = xzoom
if(num_low ge 1 or num_high ge 1) then begin
    color6

    if(num_low ge 1) then begin 
        yvalue = index_low/xsize
        xvalue = index_low - (yvalue*xsize)
        xvalue = xvalue + 0.5
        yvalue = yvalue + 0.5
        yvalue = yvalue*yzoom
        xvalue = xvalue*xzoom
        plots,xvalue,yvalue,color=2,psym=1,/device

        if ptr_valid (info.inspect_ref.plowx) then ptr_free,info.inspect_ref.plowx
        info.inspect_ref.plowx = ptr_new(xvalue)
        xvalue = 0

        if ptr_valid (info.inspect_ref.plowy) then ptr_free,info.inspect_ref.plowy
        info.inspect_ref.plowy = ptr_new(yvalue)
        yvalue = 0
    endif

    if(num_high ge 1) then begin 
        yvalue = index_high/xsize
        xvalue = index_high - (yvalue*xsize)

        xvalue = xvalue + 0.5
        yvalue = yvalue + 0.5
        yvalue = yvalue*yzoom
        xvalue = xvalue*xzoom

        plots,xvalue,yvalue,color=4,psym=1,/device
        if ptr_valid (info.inspect_ref.phighx) then ptr_free,info.inspect_ref.phighx
        info.inspect_ref.phighx = ptr_new(xvalue)
        xvalue = 0

        if ptr_valid (info.inspect_ref.phighy) then ptr_free,info.inspect_ref.phighy
        info.inspect_ref.phighy = ptr_new(yvalue)
        yvalue = 0
    endif

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


widget_control,info.inspect_ref.low_foundID,set_value='# ' + strcompress(string(num_low),/remove_all)
widget_control,info.inspect_ref.high_foundID,set_value='# ' + strcompress(string(num_high),/remove_all)

; full image stats

widget_control,info.inspect_ref.slabelID[0],set_value=info.inspect_ref.sname[0]+ strtrim(string(mean,format="(g14.6)"),2) 
widget_control,info.inspect_ref.slabelID[1],set_value=info.inspect_ref.sname[1]+ strtrim(string(stdev,format="(g14.6)"),2) 
widget_control,info.inspect_ref.slabelID[2],set_value=info.inspect_ref.sname[2]+ strtrim(string(median,format="(g14.6)"),2) 
widget_control,info.inspect_ref.slabelID[3],set_value=info.inspect_ref.sname[3]+ strtrim(string(min,format="(g14.6)"),2) 
widget_control,info.inspect_ref.slabelID[4],set_value=info.inspect_ref.sname[4]+ strtrim(string(max,format="(g14.6)"),2) 

widget_control,info.inspect_ref.slabelID[5],set_value=info.inspect_ref.sname[5]+ strtrim(string(skew,format="(g14.6)"),2) 
widget_control,info.inspect_ref.slabelID[6],set_value=info.inspect_ref.sname[6]+ strtrim(string(ngood,format="(i10)"),2) 
widget_control,info.inspect_ref.slabelID[7],set_value=info.inspect_ref.sname[7]+ strtrim(string(nbad,format="(i10)"),2) 

widget_control,info.inspect_ref.rlabelID[0],set_value=info.inspect_ref.graph_range[0]
widget_control,info.inspect_ref.rlabelID[1],set_value=info.inspect_ref.graph_range[1]


; zoom image stats

if(info.inspect_ref.zoom gt info.inspect_ref.set_zoom) then begin 

 subt = "Statisical Information for Zoom Region"
 widget_control,info.inspect_ref.zlabelID,set_value = subt

 sf = ' ' 
 if(info.image.apply_bad eq 0) then sf = "Reference Pixels NOT Included" 
 if(info.image.apply_bad eq 1) then sf = "Reference Pixels & Bad Pixels  NOT Included" 

 widget_control,info.inspect_ref.zlabel1,set_value = sf


 widget_control,info.inspect_ref.zslabelID[0],$
                set_value=info.inspect_ref.sname[0]+ strtrim(string(z_mean,format="(g14.6)"),2) 
 widget_control,info.inspect_ref.zslabelID[1],$
                set_value=info.inspect_ref.sname[1]+ strtrim(string(z_stdev,format="(g14.6)"),2) 
 widget_control,info.inspect_ref.zslabelID[2],$
                set_value=info.inspect_ref.sname[2]+ strtrim(string(z_median,format="(g14.6)"),2) 
 widget_control,info.inspect_ref.zslabelID[3],$
                set_value=info.inspect_ref.sname[3]+ strtrim(string(z_min,format="(g14.6)"),2) 
 widget_control,info.inspect_ref.zslabelID[4],$
                set_value=info.inspect_ref.sname[4]+ strtrim(string(z_max,format="(g14.6)"),2) 
 
 widget_control,info.inspect_ref.zslabelID[5],$
                set_value=info.inspect_ref.sname[5]+ strtrim(string(z_skew,format="(g14.6)"),2) 
 widget_control,info.inspect_ref.zslabelID[6],$
                set_value=info.inspect_ref.sname[6]+ strtrim(string(z_good,format="(i10)"),2) 
 widget_control,info.inspect_ref.zslabelID[7],$
                set_value=info.inspect_ref.sname[7]+ strtrim(string(z_bad,format="(i10)"),2) 
 
endif else begin

 widget_control,info.inspect_ref.zlabelID,set_value = ''
 widget_control,info.inspect_ref.zlabel1,set_value = ''


 widget_control,info.inspect_ref.zslabelID[0],set_value = ' ' 
 widget_control,info.inspect_ref.zslabelID[1],set_value = ' ' 
 widget_control,info.inspect_ref.zslabelID[2],set_value = ' ' 
 widget_control,info.inspect_ref.zslabelID[3],set_value = ' ' 
 widget_control,info.inspect_ref.zslabelID[4],set_value = ' ' 
 widget_control,info.inspect_ref.zslabelID[5],set_value = ' ' 
 widget_control,info.inspect_ref.zslabelID[6],set_value = ' ' 
 widget_control,info.inspect_ref.zslabelID[7],set_value = ' ' 

endelse





; replot the pixel location


halfpixelx = 0.5* info.inspect_ref.zoom_x
halfpixely = 0.5* info.inspect_ref.zoom
xpos1 = info.inspect_ref.x_pos-halfpixelx
xpos2 = info.inspect_ref.x_pos+halfpixelX

ypos1 = info.inspect_ref.y_pos-halfpixely
ypos2 = info.inspect_ref.y_pos+halfpixely

box_coords1 = [xpos1,xpos2,ypos1,ypos2]
plots,box_coords1[[0,0,1,1,0]],box_coords1[[2,3,3,2,2]],psym=0,/device





sub_image = 0
test_image = 0
widget_control,info.Quicklook,set_uvalue = info
end






;_______________________________________________________________________
;***********************************************************************
pro mirql_update_pixel_location,info
;***********************************************************************

xvalue = info.inspect_ref.xposful ; location in image 
yvalue = info.inspect_ref.yposful

pixelvalue = (*info.inspect_ref.pdata)[xvalue,yvalue]
dead_pixel = 0

dead_str = 'NA ' 

widget_control,info.inspect_ref.pix_statID[0],set_value= info.inspect_ref.pix_statLabel[0] + ' = ' + $
  strtrim(string(dead_str,format="("+info.inspect_ref.pix_statFormat[0]+")"),2)

widget_control,info.inspect_ref.pix_statID[1],$
               set_value= info.inspect_ref.pix_statLabel[1] + ' = ' + $
               strtrim(string(pixelvalue,format="("+info.inspect_ref.pix_statFormat[1]+")"),2)

wset,info.inspect_ref.draw_window_id


;xsize_image = fix(info.data.image_xsize) 
;ysize_image = fix(info.data.image_ysize)
;if(xsize_image lt 256) then begin
    xsize_image = info.inspect_ref.xplotsize 
    ysize_image  = info.inspect_ref.yplotsize 
;endif
device,copy=[0,0,xsize_image,ysize_image, $
             0,0,info.inspect_ref.pixmapID]


halfpixelx = 0.5* info.inspect_ref.zoom_x
halfpixely = 0.5* info.inspect_ref.zoom
xpos1 = info.inspect_ref.x_pos-halfpixelx
xpos2 = info.inspect_ref.x_pos+halfpixelX

ypos1 = info.inspect_ref.y_pos-halfpixely
ypos2 = info.inspect_ref.y_pos+halfpixely

box_coords1 = [xpos1,xpos2,ypos1,ypos2]
plots,box_coords1[[0,0,1,1,0]],box_coords1[[2,3,3,2,2]],psym=0,/device
plots,box_coords1[[0,0,1,1,0]],box_coords1[[2,3,3,2,2]],psym=0,/device


if(info.inspect_ref.limit_low_num gt 0) then begin
    color6
    xvalue = (*info.inspect_ref.plowx)
    yvalue = (*info.inspect_ref.plowy)
    plots,xvalue,yvalue,color=2,psym=1,/device
    xvalue = 0
    yvalue = 0
endif

if(info.inspect_ref.limit_high_num gt 0) then begin 
    color6
    xvalue = (*info.inspect_ref.phighx)
    yvalue = (*info.inspect_ref.phighy)
    plots,xvalue,yvalue,color=4,psym=1,/device
    xvalue = 0
    yvalue = 0
endif


widget_control,info.Quicklook,set_uvalue = info
end



;_______________________________________________________________________
;***********************************************************************
pro mirql_display_images,filename,this_int,this_frame,info
;_______________________________________________________________________


if(info.inspect_ref.uwindowsize eq 0) then begin ; user changed the widget window size - only redisplay

    read_single_refimage,filename,this_int,this_frame,subarray,refdata,ref_xsize,ref_ysize,$
                         stats_ref,status,error_message

    if ptr_valid (info.inspect_ref.pdataimage) then ptr_free,info.inspect_ref.pdataimage
    info.inspect_ref.pdataimage = ptr_new(refdata)


    read_single_ref_slope,info.control.filename_slope_refimage,exists,this_int, subarray,$
      ref_image,ref_xsize,ref_ysize,ref_zsize,stats_image,status,error_message
    if (exists eq 0) then begin
        ref_image = 0
    endif
    info.data.sloperef_exist =exists

    if ptr_valid (info.inspect_ref.preduced) then ptr_free,info.inspect_ref.preduced
    info.inspect_ref.preduced = ptr_new(ref_image)
    ref_image = 0
    

; labels used for the Pixel Statistics Table
    info.inspect_ref.draw_window_id = 0
    info.inspect_ref.pixmapID = 0
    info.inspect_ref.graphID = 0
    info.inspect_ref.graph_range[*] = 0
    info.inspect_ref.default_scale_graph = 0
    info.inspect_ref.image_recomputeID=0
    info.inspect_ref.slabelID[*] = 0L
    info.inspect_ref.rlabelID[*] = 0L
    info.inspect_ref.x_pos = 0
    info.inspect_ref.y_pos = 0
    info.inspect_ref.limit_high_default = 1
    info.inspect_ref.limit_low_default = 1

    info.inspect_ref.default_scale_graph = 1
    info.inspect_ref.zoom = 1
    info.inspect_ref.zoom_x = 1
    info.inspect_ref.x_pos =(info.data.image_xsize)/2.0
    info.inspect_ref.y_pos = (info.data.image_ysize)/2.0

    info.inspect_ref.xposful = info.inspect_ref.x_pos
    info.inspect_ref.yposful = info.inspect_ref.y_pos

    range_min = 0.0
    range_max = 0.0
    info.inspect_ref.graph_range[0] = range_min
    info.inspect_ref.graph_range[1] = range_max
    info.inspect_ref.limit_low = -5000.0
    info.inspect_ref.limit_high = 65535
    info.inspect_ref.limit_low_num = 0
    info.inspect_ref.limit_high_num = 0
endif
;*********
;Setup main panel
;*********

window,1,/pixmap
wdelete,1

; widget window parameters
xwidget_size = 1500
ywidget_size = 1100
xsize_scroll = 1450
ysize_scroll = 1050


if(XRegistered ('mirql')) then begin
    widget_control,info.InspectRefImage,/destroy
endif

if(info.inspect_ref.uwindowsize eq 1) then begin ; user has set window size 
    xsize_scroll = info.inspect_ref.xwindowsize
    ysize_scroll = info.inspect_ref.ywindowsize
endif

if(info.control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.control.x_scroll_window
if(info.control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.control.y_scroll_window

if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10



info.InspectRefImage = widget_base(title="MIRI Quick Look- Inspect Reference Ouptut Image" + info.version,$
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
quitbutton = widget_button(quitmenu,value="Quit",event_pro='mirql_quit')

; zoom button
ZoomMenu = widget_button(menuBar,value="Zoom",font = info.font2)

; add quit button


info.inspect_ref.zbutton[0] = widget_button(Zoommenu,value="No Zoom",uvalue='zoom0',/checked_menu)
info.inspect_ref.zbutton[1] = widget_button(Zoommenu,value="Zoom 2x",uvalue='zoom1',/checked_menu)
info.inspect_ref.zbutton[2] = widget_button(Zoommenu,value="Zoom 4x",uvalue='zoom2',/checked_menu)
info.inspect_ref.zbutton[3] = widget_button(Zoommenu,value="Zoom 8x",uvalue='zoom3',/checked_menu)
info.inspect_ref.zbutton[4] = widget_button(Zoommenu,value="Zoom 16x",uvalue='zoom4',/checked_menu)
info.inspect_ref.zbutton[5] = widget_button(Zoommenu,value="Zoom 32x",uvalue='zoom5',/checked_menu)

PMenu = widget_button(menuBar,value="Print",font = info.font2)
PbuttonR = widget_button(Pmenu,value = "Print Science Image to output file",uvalue='prints')
;*****
; setup the image windows
;*****
; set up for Raw image widget window

graphID_master1 = widget_base(info.InspectRefImage,row=1)
graphID1 = widget_base(graphID_master1,col=1)
graphID2  = widget_base(graphID_master1,col=1)
;_______________________________________________________________________  

;*****
;graph full images
;*****

info.inspect_ref.x_pos =(info.data.ref_xsize*4)/2.0
info.inspect_ref.y_pos = (info.data.ref_ysize)/2.0

info.inspect_ref.xposful = info.inspect_ref.x_pos
info.inspect_ref.yposful = info.inspect_ref.y_pos

xplotsize = info.data.ref_xsize*4
yplotsize = info.data.ref_ysize

info.inspect_ref.set_zoom = 1
if  (xplotsize lt 1032) then begin
    find_zoom,xplotsize,yplotsize,zoom
    info.inspect_ref.zoom = zoom
    info.inspect_ref.set_zoom = zoom
    xplotsize = info.data.ref_xsize *4* zoom
    yplotsize = info.data.ref_ysize * zoom
endif

if(info.inspect_ref.zoom eq 1) then widget_control,info.inspect_ref.zbutton[0],set_button = 1
if(info.inspect_ref.zoom eq 2) then widget_control,info.inspect_ref.zbutton[1],set_button = 1
if(info.inspect_ref.zoom eq 4) then widget_control,info.inspect_ref.zbutton[2],set_button = 1
if(info.inspect_ref.zoom eq 8) then widget_control,info.inspect_ref.zbutton[3],set_button = 1
if(info.inspect_ref.zoom eq 16) then widget_control,info.inspect_ref.zbutton[4],set_button = 1
if(info.inspect_ref.zoom eq 32) then widget_control,info.inspect_ref.zbutton[5],set_button = 1

info.inspect_ref.xplotsize = xplotsize
info.inspect_ref.yplotsize = yplotsize

info.inspect_ref.graphID = widget_draw(graphID1,$
                              xsize = xplotsize,$
                              ysize = yplotsize,$
                              /Button_Events,$
                              retain=info.retn,uvalue='npixel')

;_______________________________________________________________________
;  Information on the image
ttitle = info.control.filename_raw 
xsize_label = 8
; 
; statistical information - next column
longline = '                                                '
longtag = widget_label(graphid2,value = longline)

info.inspect_ref.integrationNO = this_int
info.inspect_ref.FrameNO = this_frame


iramp = info.inspect_ref.FrameNO
jintegration = info.inspect_ref.IntegrationNO

move_base1 = widget_base(graphid2,row=1,/align_left)
info.inspect_ref.integration_label = cw_field(move_base1,$
                    title="Integration # ",font=info.font5, $
                    uvalue="integration",/integer,/return_events, $
                    value=jintegration+1,xsize=4,$
                    fieldfont=info.font4)

labelID = widget_button(move_base1,uvalue='integr_move_dn',value='<',font=info.font4)
labelID = widget_button(move_base1,uvalue='integr_move_up',value='>',font=info.font4)
move_base2 = widget_base(graphid2,row=1,/align_left)
info.inspect_ref.frame_label = cw_field(move_base2,$
              title="Frame # ",font=info.font5, $
              uvalue="frame",/integer,/return_events, $
              value=iramp+1,xsize=4,fieldfont=info.font4)
labelID = widget_button(move_base2,uvalue='fram_move_dn',value='<',font=info.font4)
labelID = widget_button(move_base2,uvalue='fram_move_up',value='>',font=info.font4)



i = info.inspect_ref.integrationNO 
j = info.inspect_ref.FrameNO 

blank = '                                               '


blank10 = '               '

;-----------------------------------------------------------------------
; min and max scale of  image


base1 = widget_base(graphID2,row= 1,/align_left)
r_label1 = widget_label(base1,value="Change Image Scale" ,/align_left,font=info.font5,$
                       /sunken_frame)


info.inspect_ref.image_recomputeID = widget_button(base1,value=' Image Scale',font=info.font3,$
                                          uvalue = 'sinspect',/align_left)
base1 = widget_base(graphID2,row= 1,/align_left)
info.inspect_ref.rlabelID[0] = cw_field(base1,title="Minimum",font=info.font3,uvalue="isr_b",$
                              /float,/return_events,xsize=xsize_label,value =range_min)

info.inspect_ref.rlabelID[1] = cw_field(base1,title="Maximum",font=info.font3,uvalue="isr_t",$
                         /float,/return_events,xsize = xsize_label,value =range_max)


base1 = widget_base(graphID2,row= 1,/align_left)
info.inspect_ref.limit_lowID = cw_field(base1,title="Mark Values below (Red)",font=info.font3,uvalue="limit_low",$
                         /float,/return_events,xsize = xsize_label,value =info.inspect_ref.limit_low)


info.inspect_ref.low_foundID=widget_label(base1,value = '# =         ' ,/align_left)


base1 = widget_base(graphID2,row= 1,/align_left)
info.inspect_ref.limit_highID = cw_field(base1,title="Mark Values above (Blue)",font=info.font3,uvalue="limit_high",$
                         /float,/return_events,xsize = xsize_label,value =info.inspect_ref.limit_high)

info.inspect_ref.high_foundID=widget_label(base1,value = '# =         ' ,/align_left)
;-----------------------------------------------------------------------

general_label= widget_label(graphID2,$
                            value=" Pixel Information (Image: 1032 X 1024)",/align_left,$
                            font=info.font5,/sunken_frame)

pix_num_base = widget_base(graphID2,row=1,/align_left)
labelID = widget_button(pix_num_base,uvalue='pix_move_x1',value='<',font=info.font3)
labelID = widget_button(pix_num_base,uvalue='pix_move_x2',value='>',font=info.font3)

xvalue = info.inspect_ref.xposful
yvalue = info.inspect_ref.yposful

info.inspect_ref.pix_label[0] = cw_field(pix_num_base,title="x",font=info.font4, $
                                   uvalue="pix_x_val",/integer,/return_events, $
                                   value=fix(xvalue+1),xsize=6,$  ; xvalue + 1 -4 (reference pixel)
                                   fieldfont=info.font3)



pix_num_base = widget_base(graphID2,row=1,/align_left)
labelID = widget_button(pix_num_base,uvalue='pix_move_y1',value='<',font=info.font3)
labelID = widget_button(pix_num_base,uvalue='pix_move_y2',value='>',font=info.font3)
info.inspect_ref.pix_label[1] = cw_field(pix_num_base,title="y",font=info.font4, $
                                   uvalue="pix_y_val",/integer,/return_events, $
                                   value=fix(yvalue+1),xsize=6,$
                                   fieldfont=info.font3)

info.inspect_ref.pix_statLabel[0] = "Dead/hot/noisy Pixel"
info.inspect_ref.pix_statFormat[0] = "A4"
info.inspect_ref.pix_statID[0] = widget_label(graphid2,$
                                            value = info.inspect_ref.pix_statLabel[0]+$
                                            ' =        ',/align_left)

info.inspect_ref.pix_statLabel[1] = "Ref Value"
info.inspect_ref.pix_statFormat[1]= "F10.2" 
info.inspect_ref.pix_statID[1]=widget_label(graphID2,value = info.inspect_ref.pix_statLabel[1]+$
                                        ' =         ' ,/align_left)



flabel = widget_button(graphID2,value="Get All Frame Values",/align_left,$
                        uvalue = "getframe")

glabel = widget_button(graphID2,value="Plot All Frame Values",/align_left,$
                        uvalue = "getframeplot")

; stats
;b_label = widget_label(graphID2,value=blank)
s_label = widget_label(graphID2,value="Statisical Information" ,/align_left,/sunken_frame,font=info.font5)
s_label = widget_label(graphID2,value="Reference Pixels  NOT Included" ,/align_left)



info.inspect_ref.sname = ['Mean:              ',$
                      'Standard Deviation ',$
                      'Median:            ',$
                      'Min:               ',$
                      'Max:               ',$
                      'Skew:              ',$
                      '# of Good Pixels   ',$
                      '# of Bad Pixels    ']
info.inspect_ref.slabelID[0] = widget_label(graphID2,value=info.inspect_ref.sname[0] +blank10,/align_left)
info.inspect_ref.slabelID[1] = widget_label(graphID2,value=info.inspect_ref.sname[1] +blank10,/align_left)
info.inspect_ref.slabelID[2] = widget_label(graphID2,value=info.inspect_ref.sname[2] +blank10,/align_left)
info.inspect_ref.slabelID[3] = widget_label(graphID2,value=info.inspect_ref.sname[3] +blank10,/align_left)
info.inspect_ref.slabelID[4] = widget_label(graphID2,value=info.inspect_ref.sname[4] +blank10,/align_left)
info.inspect_ref.slabelID[5] = widget_label(graphID2,value=info.inspect_ref.sname[5] +blank10,/align_left)
info.inspect_ref.slabelID[6] = widget_label(graphID2,value=info.inspect_ref.sname[6] +blank10,/align_left)
info.inspect_ref.slabelID[7] = widget_label(graphID2,value=info.inspect_ref.sname[7] +blank10,/align_left)





; stats on zoom window
;*****
;graph 1,2; Zoom window of reference image
;*****
info.inspect_ref.zlabelID = widget_label(graphID2,value="",/align_left,$
                            font=info.font5,/sunken_frame,/dynamic_resize)
info.inspect_ref.zlabel1 = widget_label(graphID2,value="" ,/align_left,/dynamic_resize)


info.inspect_ref.zslabelID[0] = widget_label(graphID2,value=blank10,/align_left,/dynamic_resize)
info.inspect_ref.zslabelID[1] = widget_label(graphID2,value=blank10,/align_left,/dynamic_resize)
info.inspect_ref.zslabelID[2] = widget_label(graphID2,value=blank10,/align_left,/dynamic_resize)
info.inspect_ref.zslabelID[3] = widget_label(graphID2,value=blank10,/align_left,/dynamic_resize)
info.inspect_ref.zslabelID[4] = widget_label(graphID2,value=blank10,/align_left,/dynamic_resize)
info.inspect_ref.zslabelID[5] = widget_label(graphID2,value=blank10,/align_left,/dynamic_resize)
info.inspect_ref.zslabelID[6] = widget_label(graphID2,value=blank10,/align_left,/dynamic_resize)
info.inspect_ref.zslabelID[7] = widget_label(graphID2,value=blank10,/align_left,/dynamic_resize)
;_______________________________________________________________________

longline = '                              '
longtag = widget_label(info.InspectRefImage,value = longline)

; realize main panel
Widget_control,info.InspectRefImage,/Realize
XManager,'mirql',info.InspectREfImage,/No_Block,event_handler='mirql_event'
; get the window ids of the draw windows

widget_control,info.inspect_ref.graphID,get_value=tdraw_id
info.inspect_ref.draw_window_id = tdraw_id

window,/pixmap,xsize=info.inspect_ref.xplotsize,ysize=info.inspect_ref.yplotsize,/free
info.inspect_ref.pixmapID = !D.WINDOW
loadct,info.col_table,/silent
mirql_expand_data,info

mirql_update_images,info

mirql_update_pixel_location,info

Widget_Control,info.QuickLook,Set_UValue=info
iinfo = {info        : info}

Widget_Control,info.InspectRefImage,Set_UValue=iinfo

end

