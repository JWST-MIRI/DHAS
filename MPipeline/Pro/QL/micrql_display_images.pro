;_______________________________________________________________________
;***********************************************************************
pro micrql_quit,event
;_______________________________________________________________________
widget_control,event.top, Get_UValue = ginfo	
widget_control,ginfo.info.QuickLook,Get_Uvalue = info
widget_control,info.CRinspectImage[ginfo.imageno],/destroy
wdelete,info.crinspect[ginfo.imageno].pixmapID

end
;_______________________________________________________________________
;***********************************************************************
;_______________________________________________________________________
;***********************************************************************
pro micrql_event,event
;_______________________________________________________________________
Widget_Control,event.id,Get_uValue=event_name
widget_control,event.top, Get_UValue = ginfo	
widget_control,ginfo.info.QuickLook,Get_Uvalue = info

imageno = ginfo.imageno

if (widget_info(event.id,/TLB_SIZE_EVENTS) eq 1 ) then begin

    info.crinspect[imageno].xwindowsize = event.x
    info.crinspect[imageno].ywindowsize = event.y
    info.crinspect[imageno].uwindowsize = 1
    widget_control,event.top,set_uvalue = ginfo
    widget_control,ginfo.info.Quicklook,set_uvalue = info
    micrql_display_images,info,imageno

    return
endif
    case 1 of
;_______________________________________________________________________

    (strmid(event_name,0,5) EQ 'print') : begin
        print_crinspect_images,info,imageno
    end    
;_______________________________________________________________________
; scaling image
;_______________________________________________________________________
    (strmid(event_name,0,8) EQ 'sinspect') : begin
        if(info.crinspect[imageno].default_scale_graph eq 0 ) then begin ; true - turn to false
            widget_control,info.crinspect[imageno].image_recomputeID,set_value=' Image Scale '
            info.crinspect[imageno].default_scale_graph = 1
        endif

        micrql_update_images,info,imageno
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info

    end
;_______________________________________________________________________
; change range of image graphs
; if change range then also change the scale button to 'User Set
; Scale'
;_______________________________________________________________________
    (strmid(event_name,0,3) EQ 'isr') : begin

        if(strmid(event_name,4,1) EQ 'b') then begin
            info.crinspect[imageno].graph_range[0] = event.value
            widget_control,info.crinspect[imageno].rlabelID[1],get_value = temp
            info.crinspect[imageno].graph_range[1] = temp
        endif


        if(strmid(event_name,4,1) EQ 't') then begin
            info.crinspect[imageno].graph_range[1] = event.value
            widget_control,info.crinspect[imageno].rlabelID[0],get_value = temp
            info.crinspect[imageno].graph_range[0] = temp
        endif
                        
        info.crinspect[imageno].default_scale_graph = 0
        widget_control,info.crinspect[imageno].image_recomputeID,set_value='Default Scale'

        micrql_update_images,info,imageno
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end

    
;_______________________________________________________________________
; Change limits

    (strmid(event_name,0,5) EQ 'limit') : begin

        if(strmid(event_name,6,1) EQ 'l') then begin
            info.crinspect[imageno].limit_low = event.value

            widget_control,info.crinspect[imageno].limit_highID,get_value = temp
            info.crinspect[imageno].limit_high = temp
        endif


        if(strmid(event_name,6,1) EQ 'h') then begin
            info.crinspect[imageno].limit_high = event.value
            widget_control,info.crinspect[imageno].limit_lowID,get_value = temp
            info.crinspect[imageno].limit_low = temp
        endif
        info.crinspect[imageno].limit_low_default = 0
        info.crinspect[imageno].limit_high_default = 0

        micrql_update_images,info,imageno
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end

;_______________________________________________________________________e
; zoom images
;_______________________________________________________________________
   (strmid(event_name,0,4) EQ 'zoom') : begin

       zoom = fix(strmid(event_name,4,1))
       info.crinspect[imageno].zoom = 2^zoom

         ; redefine the xpos and y pos value in new zoom window
         micrql_update_images,info,imageno

         
         ; xposful, uposful - x,y location in full image
         ; x_pos, y_pos = x and y location on the image screen

         xpos_new = info.crinspect[imageno].xposful -info.crinspect[imageno].xstart_zoom 
         ypos_new = info.crinspect[imageno].yposful -info.crinspect[imageno].ystart_zoom
         info.crinspect[imageno].x_pos = (xpos_new+0.5)*info.crinspect[imageno].zoom_x
         info.crinspect[imageno].y_pos = (ypos_new+0.5)*info.crinspect[imageno].zoom
         micrql_update_pixel_location,info,imageno

         for i = 0,5 do begin
             widget_control,info.crinspect[imageno].zbutton[i],set_button = 0
         endfor
         widget_control,info.crinspect[imageno].zbutton[zoom],set_button = 1
     end
;_______________________________________________________________________
; Select a different pixel
;_______________________________________________________________________
    (strmid(event_name,0,3) EQ 'pix') : begin
        xsize = info.rcompare_image[imageno].xsize
        ysize = info.rcompare_image[imageno].ysize
        xvalue = info.crinspect[imageno].xposful
        yvalue = info.crinspect[imageno].yposful
        xstart = xvalue
        ystart = yvalue


; ++++++++++++++++++++++++++++++
        if(strmid(event_name,4,1) eq 'x') then  begin
            xvalue = event.value ; event value - user input starts at 1 

            if(xvalue lt 0) then xvalue = 0
            if(xvalue gt xsize) then xvalue = xsize
            xvalue = xvalue -1
            ; check what is in y box 
            widget_control,info.crinspect[imageno].pix_label[1],get_value =  ytemp
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
            widget_control,info.crinspect[imageno].pix_label[0], get_value= xtemp
            xvalue = xtemp
            if(xvalue lt 1) then  xvalue = 1
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
            if(xvalue ge  info.rcompare_image[imageno].xsize) then xvalue = info.rcompare_image[imageno].xsize-1
            if(yvalue ge  info.rcompare_image[imageno].ysize) then yvalue = info.rcompare_image[imageno].ysize-1

        endif

; ++++++++++++++++++++++++++++++

        xmove = xvalue - xstart
        ymove = yvalue - ystart
        

        info.crinspect[imageno].xposful = info.crinspect[imageno].xposful + xmove
        info.crinspect[imageno].yposful = info.crinspect[imageno].yposful + ymove


         xpos_new = info.crinspect[imageno].xposful -info.crinspect[imageno].xstart_zoom 
         ypos_new = info.crinspect[imageno].yposful -info.crinspect[imageno].ystart_zoom

; update screen coor x_pos,y_pos
         info.crinspect[imageno].x_pos = (xpos_new+0.5)*info.crinspect[imageno].zoom_x
         info.crinspect[imageno].y_pos = (ypos_new+0.5)*info.crinspect[imageno].zoom

        widget_control,info.crinspect[imageno].pix_label[0],set_value=info.crinspect[imageno].xposful+1
        widget_control,info.crinspect[imageno].pix_label[1],set_value=info.crinspect[imageno].yposful+1

        micrql_update_pixel_location,info,imageno

        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end

;_______________________________________________________________________
; click on a  different pixel to query the values

    (strmid(event_name,0,6) EQ 'mpixel') : begin
        if(event.type eq 1) then begin 
            xvalue = event.x    ; starts at 0
            yvalue = event.y    ; starts at 0
;; test for out of bounds area
            x = (xvalue)/info.crinspect[imageno].zoom
            y = (yvalue)/info.crinspect[imageno].zoom

            if(x gt info.rcompare_image[imageno].xsize) then x = info.rcompare_image[imageno].xsize -1
            if(y gt info.rcompare_image[imageno].ysize) then y = info.rcompare_image[imageno].ysize -1

            xvalue = x * info.crinspect[imageno].zoom
            yvalue = y * info.crinspect[imageno].zoom
            
            info.crinspect[imageno].x_pos = xvalue ;value in image screen 
            info.crinspect[imageno].y_pos = yvalue ;


            xposful = (xvalue/info.crinspect[imageno].zoom_x)+ info.crinspect[imageno].xstart_zoom
            yposful = (yvalue/info.crinspect[imageno].zoom)+ info.crinspect[imageno].ystart_zoom

            info.crinspect[imageno].xposful = xposful
            info.crinspect[imageno].yposful = yposful


            if(xposful gt info.rcompare_image[imageno].xsize or $
               yposful gt info.rcompare_image[imageno].ysize) then begin
                ok = dialog_message(" Area out of range",/Information)
                return
            endif
; update screen coor x_pos,y_pos            
            xnew = fix(xvalue/info.crinspect[imageno].zoom_x)
            ynew = fix(yvalue/info.crinspect[imageno].zoom)

            info.crinspect[imageno].x_pos = (xnew+0.5)*info.crinspect[imageno].zoom_x
            info.crinspect[imageno].y_pos = (ynew+0.5)*info.crinspect[imageno].zoom

            widget_control,info.crinspect[imageno].pix_label[0],set_value = info.crinspect[imageno].xposful+1
            widget_control,info.crinspect[imageno].pix_label[1],set_value = info.crinspect[imageno].yposful+1

            micrql_update_pixel_location,info,imageno


        endif

        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end
;_______________________________________________________________________

else: print,event_name
endcase
end

;_______________________________________________________________________
;***********************************************************************
pro micrql_update_images,info,imageno,ps = ps,eps = eps
;_______________________________________________________________________
hcopy = 0
loadct,info.col_table,/silent
if ( (keyword_set(ps)) or ( keyword_set(eps)) ) then hcopy = 1

n_pixels = float( (info.rcompare_image[imageno].xsize) * (info.rcompare_image[imageno].ysize))

ititle =  "Integration #: " + strtrim(string(info.crinspect[imageno].integrationNO+1),2) 
         
if(imageno le 1) then begin
    widget_control,info.crinspect[imageno].iLabelID,set_value= ititle

endif

i = info.crinspect[imageno].integrationNO


zoom = info.crinspect[imageno].zoom

x = info.crinspect[imageno].xposful ; xposful = x location in full image
y = info.crinspect[imageno].yposful ; yposful = y location in full image


if(zoom eq 1) then begin
    x = info.rcompare_image[imageno].xsize/2
    y = info.rcompare_image[imageno].ysize/2

endif
xsize_org =  info.crinspect[imageno].xplotsize
ysize_org =  info.crinspect[imageno].yplotsize

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

xdata_end = info.rcompare_image[imageno].xsize
ydata_end = info.rcompare_image[imageno].ysize
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

info.crinspect[imageno].ixstart_zoom = ixstart
info.crinspect[imageno].xstart_zoom = xstart

info.crinspect[imageno].iystart_zoom = iystart
info.crinspect[imageno].ystart_zoom = ystart

info.crinspect[imageno].yend_zoom = yend
info.crinspect[imageno].xend_zoom = xend

frame_image = (*info.crinspect[imageno].pdata)
sub_image = fltarr(xsize,ysize)   

sub_image[ixstart:ixend,iystart:iyend] =frame_image[xstart:xend,ystart:yend]
stat_data =     sub_image

if(info.image.apply_bad) then begin 
    bad_sub_mask  = fltarr(xsize,ysize)
    bad_sub_mask[ixstart:ixend,iystart:iyend] = (*info.badpixel.pmask)[xstart:xend,ystart:yend]
    index = where(bad_sub_mask and 1,numbad)
    if(numbad gt 0) then stat_data[index] = !values.F_NaN
    bad_sub_mask = 0
endif    

    
x_zoom_start = ixstart
x_zoom_end = ixend
if(info.rcompare_image[imageno].colstart eq 1 and xstart eq 0) then x_zoom_start = x_zoom_start +4
if(info.rcompare_image[imageno].subarray eq 0 and xend ge 1028) then begin
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
if ptr_valid (info.crinspect[imageno].psubdata) then ptr_free,info.crinspect[imageno].psubdata
info.crinspect[imageno].psubdata = ptr_new(sub_image)

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


if(info.rcompare_image[imageno].subarray eq 0) then begin  
    frame_image_noref  = frame_image[4:1027,*]
endif else begin 
    if(info.rcompare_image[imageno].colstart eq 1) then begin
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
widget_control,info.crinspect[imageno].graphID,draw_xsize=info.crinspect[imageno].xplotsize,$
               draw_ysize=info.crinspect[imageno].yplotsize
if(hcopy eq 0 ) then wset,info.crinspect[imageno].pixmapID


xsize_image = info.crinspect[imageno].xplotsize 
ysize_image  = info.crinspect[imageno].yplotsize 


;_______________________________________________________________________
; check if default scale is true - then reset to orginal value
if(info.crinspect[imageno].default_scale_graph eq 1) then begin
    
    info.crinspect[imageno].graph_range[0] =info.rcompare.graph_range[imageno,0] 
    info.crinspect[imageno].graph_range[1] =info.rcompare.graph_range[imageno,1] 
endif


disp_image = congrid(sub_image, $
                     xsize_image,ysize_image)

test_image = disp_image

min_image = info.crinspect[imageno].graph_range[0]
max_image = info.crinspect[imageno].graph_range[1]
if(finite(min_image) ne 1) then min_image  = 0
if(finite(max_image) ne 1) then max_image  = 1
disp_image = bytscl(disp_image,min=min_image,$
                    max=max_image,top=info.col_max,/nan)
tv,disp_image,0,0,/device

if( hcopy eq 0) then begin  
    wset,info.crinspect[imageno].draw_window_id
    device,copy=[0,0,xsize_image,ysize_image, $
                 0,0,info.crinspect[imageno].pixmapID]
endif

mean = image_mean
stdev = stdev
min = image_min
max = image_max
median = image_median
st_mean = stdev_mean
skew = skew



low_limit_value = info.crinspect[imageno].limit_low
high_limit_value = info.crinspect[imageno].limit_high

index_low = where(sub_image le low_limit_value,num_low)
index_high = where(sub_image ge high_limit_value,num_high)



info.crinspect[imageno].limit_low_num = num_low
info.crinspect[imageno].limit_high_num = num_high

size_sub = size(sub_image)
size_test = size(test_image)

xzoom = float(size_test[1])/float(size_sub[1])
yzoom = float(size_test[2])/float(size_sub[2])
info.crinspect[imageno].zoom_x = xzoom
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

        if ptr_valid (info.crinspect[imageno].plowx) then ptr_free,info.crinspect[imageno].plowx
        info.crinspect[imageno].plowx = ptr_new(xvalue)
        xvalue = 0

        if ptr_valid (info.crinspect[imageno].plowy) then ptr_free,info.crinspect[imageno].plowy
        info.crinspect[imageno].plowy = ptr_new(yvalue)
        yvalue = 0
    endif

    if(num_high ge 1) then begin 
        yvalue = index_high/xsize
        xvalue = index_high - (yvalue*xsize)

        xvalue = xvalue + 0.5
        yvalue = yvalue + 0.5
        yvalue = yvalue*yzoom
        xvalue = xvalue*xzoom

        plots,xvalue,yvalue,color=4,psym=1,/device;,symsize=10
        if ptr_valid (info.crinspect[imageno].phighx) then ptr_free,info.crinspect[imageno].phighx
        info.crinspect[imageno].phighx = ptr_new(xvalue)
        xvalue = 0

        if ptr_valid (info.crinspect[imageno].phighy) then ptr_free,info.crinspect[imageno].phighy
        info.crinspect[imageno].phighy = ptr_new(yvalue)
        yvalue = 0
    endif

endif


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


widget_control,info.crinspect[imageno].low_foundID,set_value='# ' + strcompress(string(num_low),/remove_all)
widget_control,info.crinspect[imageno].high_foundID,set_value='# ' + strcompress(string(num_high),/remove_all)

; full image stats

widget_control,info.crinspect[imageno].slabelID[0],set_value=info.crinspect[imageno].sname[0]+ strtrim(string(mean,format="(g14.6)"),2) 
widget_control,info.crinspect[imageno].slabelID[1],set_value=info.crinspect[imageno].sname[1]+ strtrim(string(stdev,format="(g14.6)"),2) 
widget_control,info.crinspect[imageno].slabelID[2],set_value=info.crinspect[imageno].sname[2]+ strtrim(string(median,format="(g14.6)"),2) 
widget_control,info.crinspect[imageno].slabelID[3],set_value=info.crinspect[imageno].sname[3]+ strtrim(string(min,format="(g14.6)"),2) 
widget_control,info.crinspect[imageno].slabelID[4],set_value=info.crinspect[imageno].sname[4]+ strtrim(string(max,format="(g14.6)"),2) 

widget_control,info.crinspect[imageno].slabelID[5],set_value=info.crinspect[imageno].sname[5]+ strtrim(string(skew,format="(g14.6)"),2) 
widget_control,info.crinspect[imageno].slabelID[6],set_value=info.crinspect[imageno].sname[6]+ strtrim(string(ngood,format="(i10)"),2) 
widget_control,info.crinspect[imageno].slabelID[7],set_value=info.crinspect[imageno].sname[7]+ strtrim(string(nbad,format="(i10)"),2) 

widget_control,info.crinspect[imageno].rlabelID[0],set_value=info.crinspect[imageno].graph_range[0]
widget_control,info.crinspect[imageno].rlabelID[1],set_value=info.crinspect[imageno].graph_range[1]


; zoom image stats

if(info.crinspect[imageno].zoom gt info.crinspect[imageno].set_zoom) then begin 

 subt = "Statisical Information for Zoom Region"
 widget_control,info.crinspect[imageno].zlabelID,set_value = subt

 sf = ' ' 
 if(info.image.apply_bad eq 0) then sf = "Reference Pixels NOT Included" 
 if(info.image.apply_bad eq 1) then sf = "Reference Pixels & Bad Pixels  NOT Included" 

 widget_control,info.crinspect[imageno].zlabel1,set_value = sf


 widget_control,info.crinspect[imageno].zslabelID[0],$
                set_value=info.crinspect[imageno].sname[0]+ strtrim(string(z_mean,format="(g14.6)"),2) 
 widget_control,info.crinspect[imageno].zslabelID[1],$
                set_value=info.crinspect[imageno].sname[1]+ strtrim(string(z_stdev,format="(g14.6)"),2) 
 widget_control,info.crinspect[imageno].zslabelID[2],$
                set_value=info.crinspect[imageno].sname[2]+ strtrim(string(z_median,format="(g14.6)"),2) 
 widget_control,info.crinspect[imageno].zslabelID[3],$
                set_value=info.crinspect[imageno].sname[3]+ strtrim(string(z_min,format="(g14.6)"),2) 
 widget_control,info.crinspect[imageno].zslabelID[4],$
                set_value=info.crinspect[imageno].sname[4]+ strtrim(string(z_max,format="(g14.6)"),2) 
 
 widget_control,info.crinspect[imageno].zslabelID[5],$
                set_value=info.crinspect[imageno].sname[5]+ strtrim(string(z_skew,format="(g14.6)"),2) 
 widget_control,info.crinspect[imageno].zslabelID[6],$
                set_value=info.crinspect[imageno].sname[6]+ strtrim(string(z_good,format="(i10)"),2) 
 widget_control,info.crinspect[imageno].zslabelID[7],$
                set_value=info.crinspect[imageno].sname[7]+ strtrim(string(z_bad,format="(i10)"),2) 
 
endif else begin

 widget_control,info.crinspect[imageno].zlabelID,set_value = ''
 widget_control,info.crinspect[imageno].zlabel1,set_value = ''


 widget_control,info.crinspect[imageno].zslabelID[0],set_value = ' ' 
 widget_control,info.crinspect[imageno].zslabelID[1],set_value = ' ' 
 widget_control,info.crinspect[imageno].zslabelID[2],set_value = ' ' 
 widget_control,info.crinspect[imageno].zslabelID[3],set_value = ' ' 
 widget_control,info.crinspect[imageno].zslabelID[4],set_value = ' ' 
 widget_control,info.crinspect[imageno].zslabelID[5],set_value = ' ' 
 widget_control,info.crinspect[imageno].zslabelID[6],set_value = ' ' 
 widget_control,info.crinspect[imageno].zslabelID[7],set_value = ' ' 

endelse



; replot the pixel location


halfpixelx = 0.5* info.crinspect[imageno].zoom_x
halfpixely = 0.5* info.crinspect[imageno].zoom
xpos1 = info.crinspect[imageno].x_pos-halfpixelx
xpos2 = info.crinspect[imageno].x_pos+halfpixelX

ypos1 = info.crinspect[imageno].y_pos-halfpixely
ypos2 = info.crinspect[imageno].y_pos+halfpixely

box_coords1 = [xpos1,xpos2,ypos1,ypos2]
plots,box_coords1[[0,0,1,1,0]],box_coords1[[2,3,3,2,2]],psym=0,/device


sub_image = 0
test_image = 0
widget_control,info.Quicklook,set_uvalue = info
end





;_______________________________________________________________________
;***********************************************************************
pro micrql_update_pixel_location,info,imageno
;***********************************************************************

xvalue = info.crinspect[imageno].xposful ; location in image 
yvalue = info.crinspect[imageno].yposful

pixelvalue = (*info.crinspect[imageno].pdata)[xvalue,yvalue]
dead_pixel = 0
dead_pixel = (*info.badpixel.pmask)[xvalue,yvalue]
dead_str = 'No '
if(dead_pixel and 1) then dead_str = 'Yes' 
if(info.control.display_apply_bad eq 0) then dead_str = 'NA ' 

widget_control,info.crinspect[imageno].pix_statID[0],set_value= info.crinspect[imageno].pix_statLabel[0] + ' = ' + $
  strtrim(string(dead_str,format="("+info.crinspect[imageno].pix_statFormat[0]+")"),2)

widget_control,info.crinspect[imageno].pix_statID[1],$
               set_value= info.crinspect[imageno].pix_statLabel[1] + ' = ' + $
               strtrim(string(pixelvalue,format="("+info.crinspect[imageno].pix_statFormat[1]+")"),2)

wset,info.crinspect[imageno].draw_window_id



xsize_image = info.crinspect[imageno].xplotsize 
ysize_image  = info.crinspect[imageno].yplotsize 

device,copy=[0,0,xsize_image,ysize_image, $
             0,0,info.crinspect[imageno].pixmapID]


halfpixelx = 0.5* info.crinspect[imageno].zoom_x
halfpixely = 0.5* info.crinspect[imageno].zoom
xpos1 = info.crinspect[imageno].x_pos-halfpixelx
xpos2 = info.crinspect[imageno].x_pos+halfpixelX

ypos1 = info.crinspect[imageno].y_pos-halfpixely
ypos2 = info.crinspect[imageno].y_pos+halfpixely

box_coords1 = [xpos1,xpos2,ypos1,ypos2]
plots,box_coords1[[0,0,1,1,0]],box_coords1[[2,3,3,2,2]],psym=0,/device
plots,box_coords1[[0,0,1,1,0]],box_coords1[[2,3,3,2,2]],psym=0,/device


if(info.crinspect[imageno].limit_low_num gt 0) then begin
    color6
    xvalue = (*info.crinspect[imageno].plowx)
    yvalue = (*info.crinspect[imageno].plowy)
    plots,xvalue,yvalue,color=2,psym=1,/device
    xvalue = 0
    yvalue = 0
endif

if(info.crinspect[imageno].limit_high_num gt 0) then begin 
    color6
    xvalue = (*info.crinspect[imageno].phighx)
    yvalue = (*info.crinspect[imageno].phighy)
    plots,xvalue,yvalue,color=4,psym=1,/device
    xvalue = 0
    yvalue = 0
endif


widget_control,info.Quicklook,set_uvalue = info
end



;_______________________________________________________________________
;***********************************************************************
pro micrql_display_images,info,imageno
;_______________________________________________________________________


if(info.crinspect[imageno].uwindowsize eq 0) then begin ; user changed the widget window size - only redisplay

; labels used for the Pixel Statistics Table
    info.crinspect[imageno].draw_window_id = 0
    info.crinspect[imageno].pixmapID = 0
    info.crinspect[imageno].graphID = 0

    info.crinspect[imageno].default_scale_graph = 0
    info.crinspect[imageno].image_recomputeID=0
    info.crinspect[imageno].slabelID[*] = 0L
    info.crinspect[imageno].rlabelID[*] = 0L
    info.crinspect[imageno].x_pos = 0
    info.crinspect[imageno].y_pos = 0
    info.crinspect[imageno].limit_high_default = 1
    info.crinspect[imageno].limit_low_default = 1


    info.crinspect[imageno].default_scale_graph = 1
    info.crinspect[imageno].zoom = 1
    info.crinspect[imageno].zoom_x = 1
    info.crinspect[imageno].x_pos =(info.rcompare_image[imageno].xsize)/2.0
    info.crinspect[imageno].y_pos = (info.rcompare_image[imageno].ysize)/2.0

    info.crinspect[imageno].xposful = info.crinspect[imageno].x_pos
    info.crinspect[imageno].yposful = info.crinspect[imageno].y_pos

    mean = info.rcompare_image[imageno].mean
    std = info.rcompare_image[imageno].stdev
    
    info.crinspect[imageno].limit_low = mean - std*20.0
    info.crinspect[imageno].limit_high = 65535

    info.crinspect[imageno].limit_low_num = 0
    info.crinspect[imageno].limit_high_num = 0
endif
;*********
;Setup main panel
;*********



if(imageno eq 0) then begin 
    stit = " Inspect Reduced Image 1"
    if(XRegistered ('micrql1')) then begin
        widget_control,info.CRInspectImage[imageno],/destroy
    endif
    sfile = info.rcompare_image[0].filename
    ttitle = strcompress(sfile,/remove_all)
endif

if(imageno eq 1) then begin 
    stit = " Inspect Reduced Image 2"
    if(XRegistered ('micrql2')) then begin
        widget_control,info.CRInspectImage[imageno],/destroy
    endif
    sfile = info.rcompare_image[1].filename
    ttitle = strcompress(sfile,/remove_all)
endif

if(imageno eq 2) then begin 

    if (info.rcompare.compare_type eq 0) then stit = " Difference Image (A-B)" 
    if (info.rcompare.compare_type eq 1) then stit = " Difference Image (B-A)" 
    if (info.rcompare.compare_type eq 2) then stit = " Ratio Image (A/B)" 
    if (info.rcompare.compare_type eq 3) then stit = " Ratio Image (B/A)" 
    if (info.rcompare.compare_type eq 4) then stit = " Addition Image" 
    if(XRegistered ('micrql3')) then begin
        widget_control,info.CRInspectImage[imageno],/destroy
    endif
    sfile = stit
    ttitle = sfile
endif

window,1,/pixmap
wdelete,1

; widget window parameters
xwidget_size = 1500
ywidget_size = 1100
xsize_scroll = 1400
ysize_scroll = 1050



if(info.crinspect[imageno].uwindowsize eq 1) then begin ; user has set window size 
    xsize_scroll = info.crinspect[imageno].xwindowsize
    ysize_scroll = info.crinspect[imageno].ywindowsize
endif

if(info.control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.control.x_scroll_window
if(info.control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.control.y_scroll_window

if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10


InspectImage = widget_base(title="MIRI Quick Look- "+ stit + info.version,$
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
quitbutton = widget_button(quitmenu,value="Quit",event_pro='micrql_quit')

; zoom button
ZoomMenu = widget_button(menuBar,value="Zoom",font = info.font2)

; add quit button

info.crinspect[imageno].zbutton[0] = widget_button(Zoommenu,value="No Zoom",uvalue='zoom0',/checked_menu)
info.crinspect[imageno].zbutton[1] = widget_button(Zoommenu,value="Zoom 2x",uvalue='zoom1',/checked_menu)
info.crinspect[imageno].zbutton[2] = widget_button(Zoommenu,value="Zoom 4x",uvalue='zoom2',/checked_menu)
info.crinspect[imageno].zbutton[3] = widget_button(Zoommenu,value="Zoom 8x",uvalue='zoom3',/checked_menu)
info.crinspect[imageno].zbutton[4] = widget_button(Zoommenu,value="Zoom 16x",uvalue='zoom4',/checked_menu)
info.crinspect[imageno].zbutton[5] = widget_button(Zoommenu,value="Zoom 32x",uvalue='zoom5',/checked_menu)
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



xplotsize = info.rcompare_image[imageno].xsize
yplotsize = info.rcompare_image[imageno].ysize
info.crinspect[imageno].set_zoom = 1
if (xplotsize lt 1032) then begin
    find_zoom,xplotsize,yplotsize,zoom
    info.crinspect[imageno].zoom = zoom
    info.crinspect[imageno].set_zoom = zoom
    xplotsize = info.rcompare_image[imageno].xsize * zoom
    yplotsize = info.rcompare_image[imageno].ysize * zoom
endif



if(info.crinspect[imageno].zoom eq 1) then widget_control,info.crinspect[imageno].zbutton[0],set_button = 1
if(info.crinspect[imageno].zoom eq 2) then widget_control,info.crinspect[imageno].zbutton[1],set_button = 1
if(info.crinspect[imageno].zoom eq 4) then widget_control,info.crinspect[imageno].zbutton[2],set_button = 1
if(info.crinspect[imageno].zoom eq 8) then widget_control,info.crinspect[imageno].zbutton[3],set_button = 1
if(info.crinspect[imageno].zoom eq 16) then widget_control,info.crinspect[imageno].zbutton[4],set_button = 1
if(info.crinspect[imageno].zoom eq 32) then widget_control,info.crinspect[imageno].zbutton[5],set_button = 1

info.crinspect[imageno].xplotsize = xplotsize
info.crinspect[imageno].yplotsize = yplotsize

info.crinspect[imageno].graphID = widget_draw(graphID1,$
                              xsize = xplotsize,$
                              ysize = yplotsize,$
                              /Button_Events,$
                              retain=info.retn,uvalue='mpixel')

;_______________________________________________________________________
;  Information on the image

xsize_label = 8
; 
; statistical information - next column

blank = '                                               '



ititle =  "Integration #: " + strtrim(string(info.crinspect[imageno].integrationNO+1),2) 
         
graph_label = widget_label(graphID2,value=ttitle,/align_left,font = info.font5)
base1 = widget_base(graphID2,row= 1,/align_left)
if(imageno le 1) then begin
    info.crinspect[imageno].iLabelID = widget_label(base1,value= ititle,/align_left)
endif

;-----------------------------------------------------------------------
; min and max scale of  image


base1 = widget_base(graphID2,row= 1,/align_left)
r_label1 = widget_label(base1,value="Change Image Scale" ,/align_left,font=info.font5,$
                       /sunken_frame)


info.crinspect[imageno].image_recomputeID = widget_button(base1,value=' Image Scale',font=info.font3,$
                                          uvalue = 'sinspect',/align_left)
base1 = widget_base(graphID2,row= 1,/align_left)
info.crinspect[imageno].rlabelID[0] = cw_field(base1,title="Minimum",font=info.font3,uvalue="isr_b",$
                              /float,/return_events,xsize=xsize_label,value =range_min)

info.crinspect[imageno].rlabelID[1] = cw_field(base1,title="Maximum",font=info.font3,uvalue="isr_t",$
                         /float,/return_events,xsize = xsize_label,value =range_max)


base1 = widget_base(graphID2,row= 1,/align_left)
info.crinspect[imageno].limit_lowID = cw_field(base1,title="Mark Values below (Red)",font=info.font3,uvalue="limit_low",$
                         /float,/return_events,xsize = xsize_label,value =info.crinspect[imageno].limit_low)


info.crinspect[imageno].low_foundID=widget_label(base1,value = '# =         ' ,/align_left)


base1 = widget_base(graphID2,row= 1,/align_left)
info.crinspect[imageno].limit_highID = cw_field(base1,title="Mark Values above (Blue)",font=info.font3,uvalue="limit_high",$
                         /float,/return_events,xsize = xsize_label,value =info.crinspect[imageno].limit_high)

info.crinspect[imageno].high_foundID=widget_label(base1,value = '# =         ' ,/align_left)
;-----------------------------------------------------------------------

general_label= widget_label(graphID2,$
                            value=" Pixel Information (Image: 1032 X 1024)",/align_left,$
                            font=info.font5,/sunken_frame)

pix_num_base = widget_base(graphID2,row=1,/align_left)
labelID = widget_button(pix_num_base,uvalue='pix_move_x1',value='<',font=info.font3)
labelID = widget_button(pix_num_base,uvalue='pix_move_x2',value='>',font=info.font3)

xvalue = info.crinspect[imageno].xposful
yvalue = info.crinspect[imageno].yposful

info.crinspect[imageno].pix_label[0] = cw_field(pix_num_base,title="x",font=info.font4, $
                                   uvalue="pix_x_val",/integer,/return_events, $
                                   value=fix(xvalue+1),xsize=6,$  ; xvalue + 1 -4 (reference pixel)
                                   fieldfont=info.font3)



pix_num_base = widget_base(graphID2,row=1,/align_left)
labelID = widget_button(pix_num_base,uvalue='pix_move_y1',value='<',font=info.font3)
labelID = widget_button(pix_num_base,uvalue='pix_move_y2',value='>',font=info.font3)
info.crinspect[imageno].pix_label[1] = cw_field(pix_num_base,title="y",font=info.font4, $
                                   uvalue="pix_y_val",/integer,/return_events, $
                                   value=fix(yvalue+1),xsize=6,$
                                   fieldfont=info.font3)

info.crinspect[imageno].pix_statLabel[0] = "Dead/hot/noisy Pixel"
info.crinspect[imageno].pix_statFormat[0] = "A4"
info.crinspect[imageno].pix_statID[0] = widget_label(graphid2,$
                                            value = info.crinspect[imageno].pix_statLabel[0]+$
                                            ' =        ',/align_left)

info.crinspect[imageno].pix_statLabel[1] = "Pixel Value"
info.crinspect[imageno].pix_statFormat[1]= "F16.8" 
info.crinspect[imageno].pix_statID[1]=widget_label(graphID2,value = info.crinspect[imageno].pix_statLabel[1]+$
                                        ' =' ,/align_left,/dynamic_resize)

; stats
b_label = widget_label(graphID2,value=blank)
s_label = widget_label(graphID2,value="Statisical Information" ,/align_left,/sunken_frame,font=info.font5)
if(info.image.apply_bad eq 0) then $
  s_label = widget_label(graphID2,value="Reference Pixels  NOT Included" ,/align_left)
if(info.image.apply_bad eq 1) then $
  s_label = widget_label(graphID2,value="Reference Pixels & Bad Pixels  NOT Included" ,/align_left)


info.crinspect[imageno].sname = ['Mean:              ',$
                      'Standard Deviation ',$
                      'Median:            ',$
                      'Min:               ',$
                      'Max:               ',$
                      'Skew:              ',$
                      '# of Good Pixels   ',$
                      '# of Bad Pixels    ']
info.crinspect[imageno].slabelID[0] = widget_label(graphID2,value=info.crinspect[imageno].sname[0],/align_left,/dynamic_resize)
info.crinspect[imageno].slabelID[1] = widget_label(graphID2,value=info.crinspect[imageno].sname[1],/dynamic_resize,/align_left)
info.crinspect[imageno].slabelID[2] = widget_label(graphID2,value=info.crinspect[imageno].sname[2],/dynamic_resize,/align_left)
info.crinspect[imageno].slabelID[3] = widget_label(graphID2,value=info.crinspect[imageno].sname[3],/dynamic_resize,/align_left)
info.crinspect[imageno].slabelID[4] = widget_label(graphID2,value=info.crinspect[imageno].sname[4],/dynamic_resize,/align_left)
info.crinspect[imageno].slabelID[5] = widget_label(graphID2,value=info.crinspect[imageno].sname[5],/dynamic_resize,/align_left)
info.crinspect[imageno].slabelID[6] = widget_label(graphID2,value=info.crinspect[imageno].sname[6],/dynamic_resize,/align_left)
info.crinspect[imageno].slabelID[7] = widget_label(graphID2,value=info.crinspect[imageno].sname[7],/dynamic_resize,/align_left)


; stats on zoom window
;*****
;graph 1,2; Zoom window of reference image
;*****


info.crinspect[imageno].zlabelID = widget_label(graphID2,value="",/align_left,$
                            font=info.font5,/sunken_frame,/dynamic_resize)
info.crinspect[imageno].zlabel1 = widget_label(graphID2,value="" ,/align_left,/dynamic_resize)

info.crinspect[imageno].zslabelID[0] = widget_label(graphID2,value="",/dynamic_resize,/align_left)
info.crinspect[imageno].zslabelID[1] = widget_label(graphID2,value="",/dynamic_resize,/align_left)
info.crinspect[imageno].zslabelID[2] = widget_label(graphID2,value="",/dynamic_resize,/align_left)
info.crinspect[imageno].zslabelID[3] = widget_label(graphID2,value="",/dynamic_resize,/align_left)
info.crinspect[imageno].zslabelID[4] = widget_label(graphID2,value="",/dynamic_resize,/align_left)
info.crinspect[imageno].zslabelID[5] = widget_label(graphID2,value="",/dynamic_resize,/align_left)
info.crinspect[imageno].zslabelID[6] = widget_label(graphID2,value="",/dynamic_resize,/align_left)
info.crinspect[imageno].zslabelID[7] = widget_label(graphID2,value="",/dynamic_resize,/align_left)


; get the window ids of the draw windows


longline = '                              '
longtag = widget_label(InspectImage,value = longline)

; realize main panel
Widget_control,InspectImage,/Realize

info.CRInspectImage[imageno] = InspectImage
if(imageno eq 0)then  XManager,'micrql1',info.CRInspectImage[imageno],/No_Block,event_handler='micrql_event'
if(imageno eq 1) then XManager,'micrql2',info.CRInspectImage[imageno],/No_Block,event_handler='micrql_event'
if(imageno eq 2) then XManager,'micrql3',info.CRInspectImage[imageno],/No_Block,event_handler='micrql_event'

widget_control,info.crinspect[imageno].graphID,get_value=tdraw_id
info.crinspect[imageno].draw_window_id = tdraw_id

window,/pixmap,xsize=info.crinspect[imageno].xplotsize,ysize=info.crinspect[imageno].yplotsize,/free
info.crinspect[imageno].pixmapID = !D.WINDOW

Widget_Control,info.QuickLook,Set_UValue=info
iinfo = {imageno          : imageno,$
         info        : info}

micrql_update_images,info,imageno

micrql_update_pixel_location,info,imageno



Widget_Control,info.CRInspectImage[imageno],Set_UValue=iinfo

end

