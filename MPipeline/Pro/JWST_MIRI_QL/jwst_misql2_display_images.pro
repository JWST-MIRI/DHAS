;_______________________________________________________________________
pro jwst_misql2_quit,event
;_______________________________________________________________________
widget_control,event.top, Get_UValue = ginfo
widget_control,ginfo.info.jwst_QuickLook,Get_Uvalue = info
wdelete,info.jwst_inspect_slope2.pixmapID
widget_control,info.jwst_inspectSlope2,/destroy

end
;_______________________________________________________________________

pro jwst_misql2_event,event
;_______________________________________________________________________
Widget_Control,event.id,Get_uValue=event_name
widget_control,event.top, Get_UValue = ginfo	
widget_control,ginfo.info.jwst_QuickLook,Get_Uvalue = info

if (widget_info(event.id,/TLB_SIZE_EVENTS) eq 1 ) then begin

    info.jwst_inspect_slope2.xwindowsize = event.x
    info.jwst_inspect_slope2.ywindowsize = event.y
    info.jwst_inspect_slope2.uwindowsize = 1
    widget_control,event.top,set_uvalue = ginfo
    widget_control,ginfo.info.jwst_Quicklook,set_uvalue = info
    jwst_misql2_display_images,info

    return
endif
    case 1 of
;_______________________________________________________________________

;    (strmid(event_name,0,5) EQ 'print') : begin
;        print_inspect_slope2,info
;    end    
;_______________________________________________________________________
; scaling image
;_______________________________________________________________________
    (strmid(event_name,0,8) EQ 'sinspect') : begin
        if(info.jwst_inspect_slope2.default_scale_graph eq 0 ) then begin ; true - turn to false
            widget_control,info.jwst_inspect_slope2.image_recomputeID,set_value=' Image Scale'
            info.jwst_inspect_slope2.default_scale_graph = 1
        endif

        jwst_misql2_update_images,info
        Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info
    end
;_______________________________________________________________________
    (strmid(event_name,0,8) EQ 'datainfo') : begin
       jwst_dqflags,info
    end
;_______________________________________________________________________
; change range of image graphs
; if change range then also change the scale button to 'User Set
; Scale'
;_______________________________________________________________________
    (strmid(event_name,0,3) EQ 'isr') : begin

        if(strmid(event_name,4,1) EQ 'b') then begin
            info.jwst_inspect_slope2.graph_range[0] = event.value
            widget_control,info.jwst_inspect_slope2.rlabelID[1],get_value = temp
            info.jwst_inspect_slope2.graph_range[1] = temp
        endif

        if(strmid(event_name,4,1) EQ 't') then begin
            info.jwst_inspect_slope2.graph_range[1] = event.value
            widget_control,info.jwst_inspect_slope2.rlabelID[0],get_value = temp
            info.jwst_inspect_slope2.graph_range[0] = temp
        endif
                        
        info.jwst_inspect_slope2.default_scale_graph = 0
        widget_control,info.jwst_inspect_slope2.image_recomputeID,set_value='Default Scale'

        jwst_misql2_update_images,info
        Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info
    end

;_______________________________________________________________________
; Change limits

    (strmid(event_name,0,5) EQ 'limit') : begin

        if(strmid(event_name,6,1) EQ 'l') then begin
            info.jwst_inspect_slope2.limit_low = event.value

            widget_control,info.jwst_inspect_slope2.limit_highID,get_value = temp
            info.jwst_inspect_slope2.limit_high = temp
        endif

        if(strmid(event_name,6,1) EQ 'h') then begin
            info.jwst_inspect_slope2.limit_high = event.value
            widget_control,info.jwst_inspect_slope2.limit_lowID,get_value = temp
            info.jwst_inspect_slope2.limit_low = temp
        endif
        info.jwst_inspect_slope2.limit_low_default = 0
        info.jwst_inspect_slope2.limit_high_default = 0

        jwst_misql2_update_images,info
        Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info
    end
;_______________________________________________________________________e
; zoom images
;_______________________________________________________________________
   (strmid(event_name,0,4) EQ 'zoom') : begin

       zoom = fix(strmid(event_name,4,1))
       info.jwst_inspect_slope2.zoom = 2^zoom

         ; redefine the xpos and y pos value in new zoom window
         jwst_misql2_update_images,info

         ; xposful, uposful - x,y location in full image
         ; x_pos, y_pos = x and y location on the image screen

         xpos_new = info.jwst_inspect_slope2.xposful -info.jwst_inspect_slope2.xstart_zoom 
         ypos_new = info.jwst_inspect_slope2.yposful -info.jwst_inspect_slope2.ystart_zoom
         info.jwst_inspect_slope2.x_pos = (xpos_new+0.5)*info.jwst_inspect_slope2.zoom_x
         info.jwst_inspect_slope2.y_pos = (ypos_new+0.5)*info.jwst_inspect_slope2.zoom
         jwst_misql2_update_pixel_location,info

         for i = 0,5 do begin
             widget_control,info.jwst_inspect_slope2.zbutton[i],set_button = 0
         endfor
         widget_control,info.jwst_inspect_slope2.zbutton[zoom],set_button = 1
     end
;_______________________________________________________________________
; Select a different pixel
;_______________________________________________________________________
    (strmid(event_name,0,3) EQ 'pix') : begin
        xsize = info.jwst_data.image_xsize
        ysize = info.jwst_data.image_ysize
        xvalue = info.jwst_inspect_slope2.xposful
        yvalue = info.jwst_inspect_slope2.yposful
        xstart = xvalue
        ystart = yvalue

; ++++++++++++++++++++++++++++++
        if(strmid(event_name,4,1) eq 'x') then  begin
            xvalue = event.value ; event value - user input starts at 1 

            if(xvalue lt 0) then xvalue = 0
            if(xvalue gt xsize) then xvalue = xsize

            xvalue = xvalue -1
            ; check what is in y box 
            widget_control,info.jwst_inspect_slope2.pix_label[1],get_value =  ytemp
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
            widget_control,info.jwst_inspect_slope2.pix_label[0], get_value= xtemp
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
            if(xvalue ge  info.jwst_data.slope_xsize) then xvalue = info.jwst_data.slope_xsize-1
            if(yvalue ge  info.jwst_data.slope_ysize) then yvalue = info.jwst_data.slope_ysize-1
        endif

; ++++++++++++++++++++++++++++++
        xmove = xvalue - xstart
        ymove = yvalue - ystart
        
        info.jwst_inspect_slope2.xposful = info.jwst_inspect_slope2.xposful + xmove
        info.jwst_inspect_slope2.yposful = info.jwst_inspect_slope2.yposful + ymove

        xpos_new = info.jwst_inspect_slope2.xposful -info.jwst_inspect_slope2.xstart_zoom 
        ypos_new = info.jwst_inspect_slope2.yposful -info.jwst_inspect_slope2.ystart_zoom

; update screen coor x_pos,y_pos
        info.jwst_inspect_slope2.x_pos = (xpos_new+0.5)*info.jwst_inspect_slope2.zoom_x
        info.jwst_inspect_slope2.y_pos = (ypos_new+0.5)*info.jwst_inspect_slope2.zoom

        widget_control,info.jwst_inspect_slope2.pix_label[0],set_value=info.jwst_inspect_slope2.xposful+1
        widget_control,info.jwst_inspect_slope2.pix_label[1],set_value=info.jwst_inspect_slope2.yposful+1

        jwst_misql2_update_pixel_location,info
    end

;_______________________________________________________________________
; click on a  different pixel to query the values

    (strmid(event_name,0,6) EQ 'npixel') :  begin
        if(event.type eq 1) then begin 
            xvalue = event.x    ; starts at 0
            yvalue = event.y    ; starts at 0

;; test for out of bounds area
            x = (xvalue)/info.jwst_inspect_slope2.zoom
            y = (yvalue)/info.jwst_inspect_slope2.zoom
            if(x gt info.jwst_data.slope_xsize) then x = info.jwst_data.slope_xsize-1
            if(y gt info.jwst_data.slope_ysize) then y = info.jwst_data.slope_ysize-1
            xvalue = x * info.jwst_inspect_slope2.zoom
            yvalue = y * info.jwst_inspect_slope2.zoom
            
            info.jwst_inspect_slope2.x_pos = xvalue ;value in image screen 
            info.jwst_inspect_slope2.y_pos = yvalue ;

            xposful = (xvalue/info.jwst_inspect_slope2.zoom_x)+ info.jwst_inspect_slope2.xstart_zoom
            yposful = (yvalue/info.jwst_inspect_slope2.zoom)+ info.jwst_inspect_slope2.ystart_zoom

            info.jwst_inspect_slope2.xposful = xposful
            info.jwst_inspect_slope2.yposful = yposful

            if(xposful gt info.jwst_data.slope_xsize or yposful gt info.jwst_data.slope_ysize) then begin
                ok = dialog_message(" Area out of range",/Information)
                return
            endif

; update screen coor x_pos,y_pos            
            xnew = fix(xvalue/info.jwst_inspect_slope2.zoom_x)
            ynew = fix(yvalue/info.jwst_inspect_slope2.zoom)

            info.jwst_inspect_slope2.x_pos = (xnew+0.5)*info.jwst_inspect_slope2.zoom_x
            info.jwst_inspect_slope2.y_pos = (ynew+0.5)*info.jwst_inspect_slope2.zoom
            widget_control,info.jwst_inspect_slope2.pix_label[0],set_value = info.jwst_inspect_slope2.xposful+1
            widget_control,info.jwst_inspect_slope2.pix_label[1],set_value = info.jwst_inspect_slope2.yposful+1

            jwst_misql2_update_pixel_location,info
        endif
        Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info
    end
;_______________________________________________________________________

else: print,event_name
endcase
end

;_______________________________________________________________________
;***********************************************************************
pro jwst_misql2_update_images,info,ps = ps,eps = eps
;_______________________________________________________________________
hcopy = 0
loadct,info.col_table,/silent
if ( (keyword_set(ps)) or ( keyword_set(eps)) ) then hcopy = 1

n_pixels = float( (info.jwst_data.slope_xsize) * (info.jwst_data.slope_ysize))

ititle =  "Integration #: " + strtrim(string(info.jwst_inspect_slope2.integrationNO+1),2) 
         
widget_control,info.jwst_inspect_slope2.iLabelID,set_value= ititle

i = info.jwst_inspect_slope2.integrationNO

zoom = info.jwst_inspect_slope2.zoom

x = info.jwst_inspect_slope2.xposful ; xposful = x location in full image
y = info.jwst_inspect_slope2.yposful ; yposful = y location in full image

if(zoom eq 1) then begin
    x = info.jwst_data.slope_xsize/2
    y = info.jwst_data.slope_ysize/2

endif
xsize_org =  info.jwst_inspect_slope2.xplotsize
ysize_org =  info.jwst_inspect_slope2.yplotsize

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

xdata_end = info.jwst_data.slope_xsize
ydata_end = info.jwst_data.slope_ysize
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

info.jwst_inspect_slope2.ixstart_zoom = ixstart
info.jwst_inspect_slope2.xstart_zoom = xstart

info.jwst_inspect_slope2.iystart_zoom = iystart
info.jwst_inspect_slope2.ystart_zoom = ystart

info.jwst_inspect_slope2.yend_zoom = yend
info.jwst_inspect_slope2.xend_zoom = xend

frame_image = (*info.jwst_inspect_slope2.pdata)[*,*,info.jwst_inspect_slope2.plane]

sub_image = fltarr(xsize,ysize)   

sub_image[ixstart:ixend,iystart:iyend] =frame_image[xstart:xend,ystart:yend]
stat_data =     sub_image
    
x_zoom_start = ixstart
x_zoom_end = ixend
if(info.jwst_data.colstart eq 1 and xstart eq 0) then x_zoom_start = x_zoom_start +4
if(info.jwst_data.subarray eq 0 and xend ge 1028) then begin
    factor = xend - 1028 + 1
    x_zoom_end = x_zoom_end - factor
endif

;print,'x_zoom_start,x_zoom_end',x_zoom_start,x_zoom_end

stat_noref = stat_data[x_zoom_start:x_zoom_end,*]
stat_data = 0
stat_data = stat_noref
stat_noref = 0

jwst_get_image_stat,stat_data,image_mean,stdev,image_min,image_max,$
               irange_min,irange_max,image_median,stdev_mean

stat_data = 0
;_______________________________________________________________________
if ptr_valid (info.jwst_inspect_slope2.psubdata) then ptr_free,info.jwst_inspect_slope2.psubdata
info.jwst_inspect_slope2.psubdata = ptr_new(sub_image)

z_mean  = image_mean
z_stdev  = stdev
z_median  = image_median
z_min  = image_min
z_max  = image_max
;_______________________________________________________________________
; get stats on full image - no reference pixels

if(info.jwst_data.subarray eq 0) then begin  
    frame_image_noref  = frame_image[4:1027,*]
endif else begin 
    frame_image_noref = frame_image
endelse

jwst_get_image_stat,frame_image_noref,image_mean,stdev,image_min,image_max,$
                    irange_min,irange_max,image_median,stdev_mean

if(info.jwst_inspect_slope2.plane eq 2) then begin ; DQ plane
   irange_min = 0
   irange_max = 32
endif
frame_image = 0                 ; free memory
frame_image_noref = 0
;_______________________________________________________________________
widget_control,info.jwst_inspect_slope2.graphID,draw_xsize=info.jwst_inspect_slope2.xplotsize,$
               draw_ysize=info.jwst_inspect_slope2.yplotsize
if(hcopy eq 0 ) then wset,info.jwst_inspect_slope2.pixmapID


xsize_image = info.jwst_inspect_slope2.xplotsize 
ysize_image  = info.jwst_inspect_slope2.yplotsize 
;_______________________________________________________________________
; check if default scale is true - then reset to orginal value
if(info.jwst_inspect_slope2.default_scale_graph eq 1) then begin
    info.jwst_inspect_slope2.graph_range[0] = irange_min
    info.jwst_inspect_slope2.graph_range[1] = irange_max
endif

disp_image = congrid(sub_image, $
                     xsize_image,ysize_image)

test_image = disp_image

disp_image = bytscl(disp_image,min=info.jwst_inspect_slope2.graph_range[0], $
                    max=info.jwst_inspect_slope2.graph_range[1],top=info.col_max,/nan)
tv,disp_image,0,0,/device

if( hcopy eq 0) then begin  
    wset,info.jwst_inspect_slope2.draw_window_id
    device,copy=[0,0,xsize_image,ysize_image, $
                 0,0,info.jwst_inspect_slope2.pixmapID]
endif

mean = image_mean
stdev = stdev
min = image_min
max = image_max
median = image_median
st_mean = stdev_mean

low_limit_value = info.jwst_inspect_slope2.limit_low
high_limit_value = info.jwst_inspect_slope2.limit_high

index_low = where(sub_image lt low_limit_value,num_low)
index_high = where(sub_image gt high_limit_value,num_high)

size_sub = size(sub_image)
size_test = size(test_image)

xzoom = float(size_test[1])/float(size_sub[1])
yzoom = float(size_test[2])/float(size_sub[2])
info.jwst_inspect_slope2.zoom_x = xzoom; off from zoom a bit because of 1032 image
info.jwst_inspect_slope2.limit_low_num = num_low
info.jwst_inspect_slope2.limit_high_num = num_high
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

        if ptr_valid (info.jwst_inspect_slope2.plowx) then ptr_free,info.jwst_inspect_slope2.plowx
        info.jwst_inspect_slope2.plowx = ptr_new(xvalue)
        xvalue = 0

        if ptr_valid (info.jwst_inspect_slope2.plowy) then ptr_free,info.jwst_inspect_slope2.plowy
        info.jwst_inspect_slope2.plowy = ptr_new(yvalue)
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
        if ptr_valid (info.jwst_inspect_slope2.phighx) then ptr_free,info.jwst_inspect_slope2.phighx
        info.jwst_inspect_slope2.phighx = ptr_new(xvalue)
        xvalue = 0

        if ptr_valid (info.jwst_inspect_slope2.phighy) then ptr_free,info.jwst_inspect_slope2.phighy
        info.jwst_inspect_slope2.phighy = ptr_new(yvalue)
        yvalue = 0
    endif

endif


if(hcopy eq 1) then begin 
    svalue = "Science Image"
    ftitle = "Frame #: " + strtrim(string(j+1),2) 
    ititle = "Integration #: " + strtrim(string(i+1),2)
    sstitle = info.jwst_control.filebase+'.fits'
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


widget_control,info.jwst_inspect_slope2.low_foundID,set_value='# ' + strcompress(string(num_low),/remove_all)
widget_control,info.jwst_inspect_slope2.high_foundID,set_value='# ' + strcompress(string(num_high),/remove_all)

; full image stats

widget_control,info.jwst_inspect_slope2.slabelID[0],set_value=info.jwst_inspect_slope2.sname[0]+ strtrim(string(mean,format="(g14.6)"),2) 
widget_control,info.jwst_inspect_slope2.slabelID[1],set_value=info.jwst_inspect_slope2.sname[1]+ strtrim(string(stdev,format="(g14.6)"),2) 
widget_control,info.jwst_inspect_slope2.slabelID[2],set_value=info.jwst_inspect_slope2.sname[2]+ strtrim(string(median,format="(g14.6)"),2) 
widget_control,info.jwst_inspect_slope2.slabelID[3],set_value=info.jwst_inspect_slope2.sname[3]+ strtrim(string(min,format="(g14.6)"),2) 
widget_control,info.jwst_inspect_slope2.slabelID[4],set_value=info.jwst_inspect_slope2.sname[4]+ strtrim(string(max,format="(g14.6)"),2) 


widget_control,info.jwst_inspect_slope2.rlabelID[0],set_value=info.jwst_inspect_slope2.graph_range[0]
widget_control,info.jwst_inspect_slope2.rlabelID[1],set_value=info.jwst_inspect_slope2.graph_range[1]


; zoom image stats

if(info.jwst_inspect_slope2.zoom gt info.jwst_inspect_slope2.set_zoom) then begin 

 subt = "Statisical Information for Zoom Region"
 widget_control,info.jwst_inspect_slope2.zlabelID,set_value = subt

 sf = ' ' 
 widget_control,info.jwst_inspect_slope2.zlabel1,set_value = sf

 widget_control,info.jwst_inspect_slope2.zslabelID[0],$
                set_value=info.jwst_inspect_slope2.sname[0]+ strtrim(string(z_mean,format="(g14.6)"),2) 
 widget_control,info.jwst_inspect_slope2.zslabelID[1],$
                set_value=info.jwst_inspect_slope2.sname[1]+ strtrim(string(z_stdev,format="(g14.6)"),2) 
 widget_control,info.jwst_inspect_slope2.zslabelID[2],$
                set_value=info.jwst_inspect_slope2.sname[2]+ strtrim(string(z_median,format="(g14.6)"),2) 
 widget_control,info.jwst_inspect_slope2.zslabelID[3],$
                set_value=info.jwst_inspect_slope2.sname[3]+ strtrim(string(z_min,format="(g14.6)"),2) 
 widget_control,info.jwst_inspect_slope2.zslabelID[4],$
                set_value=info.jwst_inspect_slope2.sname[4]+ strtrim(string(z_max,format="(g14.6)"),2) 
 
endif else begin

 widget_control,info.jwst_inspect_slope2.zlabelID,set_value = ''
 widget_control,info.jwst_inspect_slope2.zlabel1,set_value = ''


 widget_control,info.jwst_inspect_slope2.zslabelID[0],set_value = ' ' 
 widget_control,info.jwst_inspect_slope2.zslabelID[1],set_value = ' ' 
 widget_control,info.jwst_inspect_slope2.zslabelID[2],set_value = ' ' 
 widget_control,info.jwst_inspect_slope2.zslabelID[3],set_value = ' ' 
 widget_control,info.jwst_inspect_slope2.zslabelID[4],set_value = ' ' 
 widget_control,info.jwst_inspect_slope2.zslabelID[5],set_value = ' ' 
 widget_control,info.jwst_inspect_slope2.zslabelID[6],set_value = ' ' 
 widget_control,info.jwst_inspect_slope2.zslabelID[7],set_value = ' ' 

endelse
; replot the pixel location
halfpixelx = 0.5* info.jwst_inspect_slope2.zoom_x
halfpixely = 0.5* info.jwst_inspect_slope2.zoom
xpos1 = info.jwst_inspect_slope2.x_pos-halfpixelx
xpos2 = info.jwst_inspect_slope2.x_pos+halfpixelX

ypos1 = info.jwst_inspect_slope2.y_pos-halfpixely
ypos2 = info.jwst_inspect_slope2.y_pos+halfpixely

box_coords1 = [xpos1,xpos2,ypos1,ypos2]
plots,box_coords1[[0,0,1,1,0]],box_coords1[[2,3,3,2,2]],psym=0,/device

sub_image = 0
test_image = 0
widget_control,info.jwst_Quicklook,set_uvalue = info
end

;_______________________________________________________________________
pro jwst_misql2_update_pixel_location,info
;_______________________________________________________________________

xvalue = info.jwst_inspect_slope2.xposful ; location in image 
yvalue = info.jwst_inspect_slope2.yposful
i = info.jwst_inspect_slope2.integrationNO


ss = 'NA'


slopevalue = (*info.jwst_inspect_slope2.pdata)[xvalue,yvalue,0]
ss =  strtrim(string(slopevalue,format="("+info.jwst_inspect_slope2.pix_statFormat[0]+")"),2)

error = (*info.jwst_inspect_slope2.pdata)[xvalue,yvalue,1]
se =  strtrim(string(error,format="("+info.jwst_inspect_slope2.pix_statFormat[1]+")"),2)

dq = (*info.jwst_inspect_slope2.pdata)[xvalue,yvalue,2]
sdq =  strtrim(string(dq,format="("+info.jwst_inspect_slope2.pix_statFormat[2]+")"),2)


widget_control,info.jwst_inspect_slope2.pix_statID[0],$
               set_value= info.jwst_inspect_slope2.pix_statLabel[0] + ' = ' + ss
widget_control,info.jwst_inspect_slope2.pix_statID[1],$
               set_value= info.jwst_inspect_slope2.pix_statLabel[1] + ' = ' + se
widget_control,info.jwst_inspect_slope2.pix_statID[2],$
               set_value= info.jwst_inspect_slope2.pix_statLabel[2] + ' = ' + sdq

wset,info.jwst_inspect_slope2.draw_window_id

xsize_image = info.jwst_inspect_slope2.xplotsize 
ysize_image  = info.jwst_inspect_slope2.yplotsize 

device,copy=[0,0,xsize_image,ysize_image, $
             0,0,info.jwst_inspect_slope2.pixmapID]


halfpixelx = 0.5* info.jwst_inspect_slope2.zoom_x
halfpixely = 0.5* info.jwst_inspect_slope2.zoom
xpos1 = info.jwst_inspect_slope2.x_pos-halfpixelx
xpos2 = info.jwst_inspect_slope2.x_pos+halfpixelX

ypos1 = info.jwst_inspect_slope2.y_pos-halfpixely
ypos2 = info.jwst_inspect_slope2.y_pos+halfpixely

box_coords1 = [xpos1,xpos2,ypos1,ypos2]
plots,box_coords1[[0,0,1,1,0]],box_coords1[[2,3,3,2,2]],psym=0,/device


if(info.jwst_inspect_slope2.limit_low_num gt 0) then begin
    color6
    xvalue = (*info.jwst_inspect_slope2.plowx)
    yvalue = (*info.jwst_inspect_slope2.plowy)
    plots,xvalue,yvalue,color=2,psym=1,/device
    xvalue = 0
    yvalue = 0
endif

if(info.jwst_inspect_slope2.limit_high_num gt 0) then begin 
    color6
    xvalue = (*info.jwst_inspect_slope2.phighx)
    yvalue = (*info.jwst_inspect_slope2.phighy)
    plots,xvalue,yvalue,color=4,psym=1,/device
    xvalue = 0
    yvalue = 0
endif


widget_control,info.jwst_Quicklook,set_uvalue = info
end

;_______________________________________________________________________
pro jwst_misql2_display_images,info
;_______________________________________________________________________

if(info.jwst_inspect_slope2.uwindowsize eq 0) then begin ; user changed the widget window size - only redisplay

; labels used for the Pixel Statistics Table
    info.jwst_inspect_slope2.draw_window_id = 0
    info.jwst_inspect_slope2.pixmapID = 0
    info.jwst_inspect_slope2.graphID = 0

    info.jwst_inspect_slope2.image_recomputeID=0
    info.jwst_inspect_slope2.slabelID[*] = 0L
    info.jwst_inspect_slope2.rlabelID[*] = 0L
    info.jwst_inspect_slope2.x_pos = 0
    info.jwst_inspect_slope2.y_pos = 0
    info.jwst_inspect_slope2.limit_high_default = 1
    info.jwst_inspect_slope2.limit_low_default = 1

    info.jwst_inspect_slope2.zoom = 1
    info.jwst_inspect_slope2.zoom_x = 1
    info.jwst_inspect_slope2.x_pos =(info.jwst_data.slope_xsize)/2.0
    info.jwst_inspect_slope2.y_pos = (info.jwst_data.slope_ysize)/2.0

    info.jwst_inspect_slope2.xposful = info.jwst_inspect_slope2.x_pos
    info.jwst_inspect_slope2.yposful = info.jwst_inspect_slope2.y_pos

    info.jwst_inspect_slope2.limit_low = -5000.0
    info.jwst_inspect_slope2.limit_high = 65535
    if(info.jwst_inspect_slope2.plane eq 2) then  info.jwst_inspect_slope2.limit_high = ulong64(2.0^30)
    info.jwst_inspect_slope2.limit_low_num = 0
    info.jwst_inspect_slope2.limit_high_num = 0
endif
;*********
;Setup main panel
;*********

window,1,/pixmap
wdelete,1

if(XRegistered ('jwst_misql2')) then begin
    widget_control,info.jwst_InspectSlope2,/destroy
endif

; widget window parameters
xwidget_size = 1500
ywidget_size = 1100
xsize_scroll = 1450
ysize_scroll = 1050

if(info.jwst_inspect_slope2.uwindowsize eq 1) then begin ; user has set window size 
    xsize_scroll = info.jwst_inspect_slope2.xwindowsize
    ysize_scroll = info.jwst_inspect_slope2.ywindowsize
endif

if(info.jwst_control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.jwst_control.x_scroll_window
if(info.jwst_control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.jwst_control.y_scroll_window


if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10

info.jwst_InspectSlope2 = widget_base(title="JWST MIRI Quick Look- Inspect Rate Output  (Image 2) " + info.jwst_version,$
                                mbar = menuBar,/row,group_leader = info.jwst_SlopeQuicklook,$
                                xsize =  xwidget_size,$
                                ysize=   ywidget_size,/scroll,$
                                x_scroll_size= xsize_scroll,$
                                y_scroll_size = ysize_scroll,/TLB_SIZE_EVENTS)

;********
; build the menubar
;********
QuitMenu = widget_button(menuBar,value="Quit",font = info.font2)

; add quit button
quitbutton = widget_button(quitmenu,value="Quit",event_pro='jwst_misql2_quit')

; zoom button
ZoomMenu = widget_button(menuBar,value="Zoom",font = info.font2)

; add quit button
info.jwst_inspect_slope2.zbutton[0] = widget_button(Zoommenu,value="No Zoom",uvalue='zoom0',/checked_menu)
info.jwst_inspect_slope2.zbutton[1] = widget_button(Zoommenu,value="Zoom 2x",uvalue='zoom1',/checked_menu)
info.jwst_inspect_slope2.zbutton[2] = widget_button(Zoommenu,value="Zoom 4x",uvalue='zoom2',/checked_menu)
info.jwst_inspect_slope2.zbutton[3] = widget_button(Zoommenu,value="Zoom 8x",uvalue='zoom3',/checked_menu)
info.jwst_inspect_slope2.zbutton[4] = widget_button(Zoommenu,value="Zoom 16x",uvalue='zoom4',/checked_menu)
info.jwst_inspect_slope2.zbutton[5] = widget_button(Zoommenu,value="Zoom 32x",uvalue='zoom5',/checked_menu)

;PMenu = widget_button(menuBar,value="Print",font = info.font2)
;PbuttonR = widget_button(Pmenu,value = "Print Science Image to output file",uvalue='prints')
;*****
; setup the image windows
;*****
; set up for Raw image widget window

graphID_master1 = widget_base(info.jwst_InspectSlope2,row=1)
graphID1 = widget_base(graphID_master1,col=1)
graphID2  = widget_base(graphID_master1,col=1)
;_______________________________________________________________________  

;*****
;graph full images
;*****

xplotsize = info.jwst_data.slope_xsize
yplotsize = info.jwst_data.slope_ysize

info.jwst_inspect_slope2.set_zoom = 1
if (xplotsize lt 1032) then begin
    find_zoom,xplotsize,yplotsize,zoom
    info.jwst_inspect_slope2.zoom = zoom
    info.jwst_inspect_slope2.zoom = zoom
    xplotsize = info.jwst_data.slope_xsize * zoom
    yplotsize = info.jwst_data.slope_ysize * zoom
endif

if(info.jwst_inspect_slope2.zoom eq 1) then widget_control,info.jwst_inspect_slope2.zbutton[0],set_button = 1
if(info.jwst_inspect_slope2.zoom eq 2) then widget_control,info.jwst_inspect_slope2.zbutton[1],set_button = 1
if(info.jwst_inspect_slope2.zoom eq 4) then widget_control,info.jwst_inspect_slope2.zbutton[2],set_button = 1
if(info.jwst_inspect_slope2.zoom eq 8) then widget_control,info.jwst_inspect_slope2.zbutton[3],set_button = 1
if(info.jwst_inspect_slope2.zoom eq 16) then widget_control,info.jwst_inspect_slope2.zbutton[4],set_button = 1
if(info.jwst_inspect_slope2.zoom eq 32) then widget_control,info.jwst_inspect_slope2.zbutton[5],set_button = 1

info.jwst_inspect_slope2.xplotsize = xplotsize
info.jwst_inspect_slope2.yplotsize = yplotsize

info.jwst_inspect_slope2.graphID = widget_draw(graphID1,$
                              xsize = xplotsize,$
                              ysize = yplotsize,$
                              /Button_Events,$
                              retain=info.retn,uvalue='npixel')

;_______________________________________________________________________
;  Information on the image

xsize_label = 12
; 
; statistical information - next column

blank = '                                               '
ttitle = ' '
ititle =  "Integration #: " + strtrim(string(info.jwst_inspect_slope2.integrationNO+1),2) 
svalue = ' '
data_plane = info.jwst_slope.plane[1]
data_type = info.jwst_slope.data_type[1]

if(data_type eq 1) then begin
   ttitle = info.jwst_control.filename_slope 
   if(data_plane eq 0) then svalue = 'Rate Image'
   if(data_plane eq 1) then svalue = 'Rate Error Image'
   if(data_plane eq 2) then svalue = 'Rate DQ Image'
endif

if(data_type eq 2) then begin
   ttitle = info.jwst_control.filename_slope_int
   if(data_plane eq 0) then svalue = 'Int Rate Image'
   if(data_plane eq 1) then svalue = 'Int Rate Error Image'
   if(data_plane eq 2) then svalue = 'Int Rate DQ Image'
endif
graph_label = widget_label(graphID2,value=ttitle,/align_left,font = info.font5)

s_label= widget_label(graphID2,value = svalue,/align_left,font=info.font5)
ss = "Image Size [" + strtrim(string(info.jwst_data.slope_xsize),2) + ' x ' +$
        strtrim(string(info.jwst_data.slope_ysize),2) + ']'

size_label= widget_label(graphID2,value = ss,/align_left)

base1 = widget_base(graphID2,row= 1,/align_left)
info.jwst_inspect_slope2.iLabelID = widget_label(base1,value= ititle,/align_left)

blank10 = '               '

;-----------------------------------------------------------------------
; min and max scale of  image

base1 = widget_base(graphID2,row= 1,/align_left)
r_label1 = widget_label(base1,value="Change Image Scale" ,/align_left,font=info.font5,$
                       /sunken_frame)

info.jwst_inspect_slope2.image_recomputeID = widget_button(base1,value=' Image Scale',font=info.font3,$
                                          uvalue = 'sinspect',/align_left)
base1 = widget_base(graphID2,row= 1,/align_left)
info.jwst_inspect_slope2.rlabelID[0] = cw_field(base1,title="Minimum",font=info.font3,uvalue="isr_b",$
                              /float,/return_events,xsize=xsize_label,value =range_min)

info.jwst_inspect_slope2.rlabelID[1] = cw_field(base1,title="Maximum",font=info.font3,uvalue="isr_t",$
                         /float,/return_events,xsize = xsize_label,value =range_max)


base1 = widget_base(graphID2,row= 1,/align_left)
info.jwst_inspect_slope2.limit_lowID = cw_field(base1,title="Mark Values below (Red)",font=info.font3,uvalue="limit_low",$
                         /float,/return_events,xsize = xsize_label,value =info.jwst_inspect_slope2.limit_low)


info.jwst_inspect_slope2.low_foundID=widget_label(base1,value = '# =         ' ,/align_left)


base1 = widget_base(graphID2,row= 1,/align_left)
info.jwst_inspect_slope2.limit_highID = cw_field(base1,title="Mark Values above (Blue)",font=info.font3,uvalue="limit_high",$
                         /float,/return_events,xsize = xsize_label,value =info.jwst_inspect_slope2.limit_high)

info.jwst_inspect_slope2.high_foundID=widget_label(base1,value = '# =         ' ,/align_left)
;-----------------------------------------------------------------------

general_label= widget_label(graphID2,$
                            value=" Pixel Information (Image: 1032 X 1024)",/align_left,$
                            font=info.font5,/sunken_frame)

pix_num_base = widget_base(graphID2,row=1,/align_left)
labelID = widget_button(pix_num_base,uvalue='pix_move_x1',value='<',font=info.font3)
labelID = widget_button(pix_num_base,uvalue='pix_move_x2',value='>',font=info.font3)

xvalue = info.jwst_inspect_slope2.xposful
yvalue = info.jwst_inspect_slope2.yposful

info.jwst_inspect_slope2.pix_label[0] = cw_field(pix_num_base,title="x",font=info.font4, $
                                   uvalue="pix_x_val",/integer,/return_events, $
                                   value=fix(xvalue+1),xsize=6,$  ; xvalue + 1 -4 (reference pixel)
                                   fieldfont=info.font3)


pix_num_base = widget_base(graphID2,row=1,/align_left)
labelID = widget_button(pix_num_base,uvalue='pix_move_y1',value='<',font=info.font3)
labelID = widget_button(pix_num_base,uvalue='pix_move_y2',value='>',font=info.font3)
info.jwst_inspect_slope2.pix_label[1] = cw_field(pix_num_base,title="y",font=info.font4, $
                                   uvalue="pix_y_val",/integer,/return_events, $
                                   value=fix(yvalue+1),xsize=6,$
                                   fieldfont=info.font3)


pix_num_base = widget_base(graphid2,col=1,/align_left)

info.jwst_inspect_slope2.pix_statLabel = ["Rate (DN/s)","Error","DQ Flag" ]

info.jwst_inspect_slope2.pix_statFormat = ["F16.5","F16.8","I16"]


for i = 0,1 do begin 
    info.jwst_inspect_slope2.pix_statID[i]=widget_label(pix_num_base,$
                                                        value = info.jwst_inspect_slope2.pix_statLabel[i]+$
                                                        ' =               ' ,/align_left)
endfor

info_base = widget_base(graphid2,row=1,/align_left)

info.jwst_inspect_slope2.pix_statID[2] = widget_label(info_base,value = info.jwst_inspect_slope2.pix_statLabel[2]+$
                                        ' =  ' ,/align_left,/dynamic_resize)                                       
info_label = widget_button(info_base,value = 'Info',uvalue = 'datainfo')


; stats
b_label = widget_label(graphID2,value=blank)
s_label = widget_label(graphID2,value="Statisical Information" ,/align_left,/sunken_frame,font=info.font5)
s_label = widget_label(graphID2,value="Reference Pixels  NOT Included" ,/align_left)

info.jwst_inspect_slope2.sname = ['Mean:              ',$
                      'Standard Deviation ',$
                      'Median:            ',$
                      'Min:               ',$
                      'Max:               ']
info.jwst_inspect_slope2.slabelID[0] = widget_label(graphID2,value=info.jwst_inspect_slope2.sname[0] +blank10,/align_left)
info.jwst_inspect_slope2.slabelID[1] = widget_label(graphID2,value=info.jwst_inspect_slope2.sname[1] +blank10,/align_left)
info.jwst_inspect_slope2.slabelID[2] = widget_label(graphID2,value=info.jwst_inspect_slope2.sname[2] +blank10,/align_left)
info.jwst_inspect_slope2.slabelID[3] = widget_label(graphID2,value=info.jwst_inspect_slope2.sname[3] +blank10,/align_left)
info.jwst_inspect_slope2.slabelID[4] = widget_label(graphID2,value=info.jwst_inspect_slope2.sname[4] +blank10,/align_left)

; stats on zoom window
;*****
;graph 1,2; Zoom window of reference image
;*****

info.jwst_inspect_slope2.zlabelID = widget_label(graphID2,value="",/align_left,$
                            font=info.font5,/sunken_frame,/dynamic_resize)
info.jwst_inspect_slope2.zlabel1 = widget_label(graphID2,value="" ,/align_left,/dynamic_resize)

info.jwst_inspect_slope2.zslabelID[0] = widget_label(graphID2,value=blank10,/align_left,/dynamic_resize)
info.jwst_inspect_slope2.zslabelID[1] = widget_label(graphID2,value=blank10,/align_left,/dynamic_resize)
info.jwst_inspect_slope2.zslabelID[2] = widget_label(graphID2,value=blank10,/align_left,/dynamic_resize)
info.jwst_inspect_slope2.zslabelID[3] = widget_label(graphID2,value=blank10,/align_left,/dynamic_resize)
info.jwst_inspect_slope2.zslabelID[4] = widget_label(graphID2,value=blank10,/align_left,/dynamic_resize)
info.jwst_inspect_slope2.zslabelID[5] = widget_label(graphID2,value=blank10,/align_left,/dynamic_resize)
info.jwst_inspect_slope2.zslabelID[6] = widget_label(graphID2,value=blank10,/align_left,/dynamic_resize)
info.jwst_inspect_slope2.zslabelID[7] = widget_label(graphID2,value=blank10,/align_left,/dynamic_resize)
;_______________________________________________________________________
longline = '                              '
longtag = widget_label(info.jwst_InspectSlope2,value = longline)

; realize main panel
Widget_control,info.jwst_InspectSlope2,/Realize
XManager,'jwst_misql2',info.jwst_InspectSlope2,/No_Block,event_handler='jwst_misql2_event'
; get the window ids of the draw windows
loadct,info.col_table,/silent
widget_control,info.jwst_inspect_slope2.graphID,get_value=tdraw_id
info.jwst_inspect_slope2.draw_window_id = tdraw_id

window,/pixmap,xsize=info.jwst_inspect_slope2.xplotsize,ysize=info.jwst_inspect_slope2.yplotsize,/free
info.jwst_inspect_slope2.pixmapID = !D.WINDOW

jwst_misql2_update_images,info

jwst_misql2_update_pixel_location,info

Widget_Control,info.jwst_QuickLook,Set_UValue=info
iinfo = {info        : info}

Widget_Control,info.jwst_InspectSlope2,Set_UValue=iinfo

end

