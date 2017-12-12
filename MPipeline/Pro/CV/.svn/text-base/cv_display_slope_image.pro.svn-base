;_______________________________________________________________________
;***********************************************************************
pro cv_display_slope_image_quit,event
;_______________________________________________________________________
widget_control,event.top, Get_UValue = ginfo	
widget_control,ginfo.cinfo.cubeview,Get_Uvalue = cinfo

wdelete,cinfo.image.pixmapID
widget_control,cinfo.ViewSlope,/destroy

end
;_______________________________________________________________________
;***********************************************************************
;_______________________________________________________________________
;***********************************************************************
pro viewslope_event,event
;_______________________________________________________________________
Widget_Control,event.id,Get_uValue=event_name
widget_control,event.top, Get_UValue = ginfo	
widget_control,ginfo.cinfo.cubeview,Get_Uvalue = cinfo

if (widget_info(event.id,/TLB_SIZE_EVENTS) eq 1 ) then begin

    cinfo.image.xwindowsize = event.x
    cinfo.image.ywindowsize = event.y
    cinfo.image.uwindowsize = 1
    widget_control,event.top,set_uvalue = ginfo
    widget_control,ginfo.cinfo.cubeview,set_uvalue = cinfo
    cv_display_slope_image,cinfo

    return
endif
    case 1 of
;_______________________________________________________________________

    (strmid(event_name,0,5) EQ 'print') : begin
;        print_inspect_slope_images,cinfo
    end    
;_______________________________________________________________________
; scaling image
;_______________________________________________________________________
    (strmid(event_name,0,8) EQ 'sinspect') : begin
        if(cinfo.image.default_scale_graph eq 0 ) then begin ; true - turn to false
            widget_control,cinfo.image.image_recomputeID,set_value='Default Scale'
            cinfo.image.default_scale_graph = 1
        endif

        cv_update_slope_image,cinfo
        Widget_Control,ginfo.cinfo.CubeView,Set_UValue=cinfo

    end
;_______________________________________________________________________
;_______________________________________________________________________
; change range of image graphs
; if change range then also change the scale button to 'User Set
; Scale'
;_______________________________________________________________________
    (strmid(event_name,0,3) EQ 'isr') : begin

        if(strmid(event_name,4,1) EQ 'b') then begin
            cinfo.image.graph_range[0] = event.value
            widget_control,cinfo.image.rlabelID[1],get_value = temp
            cinfo.image.graph_range[1] = temp
        endif


        if(strmid(event_name,4,1) EQ 't') then begin
            cinfo.image.graph_range[1] = event.value
            widget_control,cinfo.image.rlabelID[0],get_value = temp
            cinfo.image.graph_range[0] = temp
        endif
                        
        cinfo.image.default_scale_graph = 0
        widget_control,cinfo.image.image_recomputeID,set_value='User Set Scale'

        cv_update_slope_image,cinfo
        Widget_Control,ginfo.cinfo.CubeView,Set_UValue=cinfo
    end

    
;_______________________________________________________________________

; zoom images
;_______________________________________________________________________
   (strmid(event_name,0,4) EQ 'zoom') : begin

       zoom = fix(strmid(event_name,4,1))
       cinfo.image.zoom = 2^zoom

         ; redefine the xpos and y pos value in new zoom window

         cv_update_slope_image,cinfo
         
         ; xposful, uposful - x,y location in full image
         ; x_pos, y_pos = x and y location on the image screen

         xpos_new = cinfo.image.xposful -cinfo.image.xstart_zoom 
         ypos_new = cinfo.image.yposful -cinfo.image.ystart_zoom
         cinfo.image.x_pos = (xpos_new+0.5)*cinfo.image.zoom_x
         cinfo.image.y_pos = (ypos_new+0.5)*cinfo.image.zoom
         cv_update_pixel_location,cinfo

     end
;_______________________________________________________________________
; Select a different pixel
;_______________________________________________________________________
    (strmid(event_name,0,3) EQ 'pix') : begin
        xsize = cinfo.slope.naxis1
        ysize = cinfo.slope.naxis2
        xvalue = cinfo.image.xposful
        yvalue = cinfo.image.yposful
        xstart = xvalue
        ystart = yvalue
; ++++++++++++++++++++++++++++++
        if(strmid(event_name,4,1) eq 'x') then  begin
            xvalue = event.value ; event value - user input starts at 1 

            if(xvalue lt 0) then begin
                print,' Trying to query pixels less than 1',xvalue
    	        result = dialog_message(" Trying to query pixels less than 1 ",/error )	
                xvalue = 0
            endif
            if(xvalue gt xsize) then begin
                print,' Trying to query past image size'
    	        result = dialog_message(" Trying to query pixels greater than image size ",/error )	
                xvalue = xsize
            endif
            xvalue = xvalue -1
            ; check what is in y box 
            widget_control,cinfo.image.pix_label[1],get_value =  ytemp
            yvalue = ytemp
            if(yvalue lt 1) then begin
                print,' Trying to query pixels less than 1'
    	    result = dialog_message(" Trying to query pixels less than 1 ",/error )	
                yvalue = 1
            endif
            if(yvalue gt ysize) then begin
                print,' Trying to query past image size'
    	    result = dialog_message(" Trying to query pixels greater than image size ",/error )	
                yvalue = ysize
            endif
            
            yvalue = float(yvalue)-1
        endif
        if(strmid(event_name,4,1) eq 'y') then begin
            yvalue = event.value ; event value - user input starts at 1
            if(yvalue lt 1) then begin
                print,' Trying to query pixels less than 1'
    	    result = dialog_message(" Trying to query pixels less than 1 ",/error )	
                yvalue = 1
            endif
            if(yvalue gt ysize) then begin
                print,' Trying to query past image size'
    	    result = dialog_message(" Trying to query pixels greater than image size ",/error )	
                yvalue = ysize
            endif
            yvalue = yvalue -1

            ; check what is in x box 
            widget_control,cinfo.image.pix_label[0], get_value= xtemp
            xvalue = xtemp
            if(xvalue lt 1) then begin
                print,' Trying to query pixels less than 1',xvalue
    	        result = dialog_message(" Trying to query pixels less than 1 ",/error )	
                xvalue = 1
            endif
            if(xvalue gt xsize) then begin
                print,' Trying to query past image size'
    	        result = dialog_message(" Trying to query pixels greater than image size ",/error )	
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
            if(xvalue ge  cinfo.slope.naxis1) then xvalue = info.slope.naxis1-1
            if(yvalue ge  cinfo.slope.naxis2) then yvalue = info.slope.naxis2-1

        endif

; ++++++++++++++++++++++++++++++

        xmove = xvalue - xstart
        ymove = yvalue - ystart
        

        cinfo.image.xposful = cinfo.image.xposful + xmove
        cinfo.image.yposful = cinfo.image.yposful + ymove

         xpos_new = cinfo.image.xposful -cinfo.image.xstart_zoom 
         ypos_new = cinfo.image.yposful -cinfo.image.ystart_zoom

; update screen coor x_pos,y_pos
         cinfo.image.x_pos = (xpos_new+0.5)*cinfo.image.zoom_x
         cinfo.image.y_pos = (ypos_new+0.5)*cinfo.image.zoom

        widget_control,cinfo.image.pix_label[0],set_value=cinfo.image.xposful+1
        widget_control,cinfo.image.pix_label[1],set_value=cinfo.image.yposful+1

        cv_update_pixel_location,cinfo
        Widget_Control,ginfo.cinfo.CubeView,Set_UValue=cinfo
    end

;_______________________________________________________________________
; click on a  different pixel to query the values

    (strmid(event_name,0,10) EQ 'imagepixel') : begin
        if(event.type eq 1) then begin 
            xvalue = event.x    ; starts at 0
            yvalue = event.y    ; starts at 0
            
            cinfo.image.x_pos = xvalue ;value in image screen 
            cinfo.image.y_pos = yvalue ;


            xposful = (event.x/cinfo.image.zoom_x)+ cinfo.image.xstart_zoom
            yposful = (event.y/cinfo.image.zoom)+ cinfo.image.ystart_zoom

            cinfo.image.xposful = xposful
            cinfo.image.yposful = yposful

            if(xposful gt cinfo.slope.naxis1 or yposful gt cinfo.slope.naxis2) then begin
                ok = dialog_message(" Area out of range",/Information)
                return
            endif

; update screen coor x_pos,y_pos            
            xnew = fix(event.x/cinfo.image.zoom_x)
            ynew = fix(event.y/cinfo.image.zoom)

            cinfo.image.x_pos = (xnew+0.5)*cinfo.image.zoom_x
            cinfo.image.y_pos = (ynew+0.5)*cinfo.image.zoom

            widget_control,cinfo.image.pix_label[0],set_value = cinfo.image.xposful+1
            widget_control,cinfo.image.pix_label[1],set_value = cinfo.image.yposful+1

            cv_update_pixel_location,cinfo

        endif
        Widget_Control,ginfo.cinfo.cubeview,Set_UValue=cinfo
    end
;_______________________________________________________________________


else: print,event_name
endcase
end

;_______________________________________________________________________
;***********************************************************************
pro cv_update_slope_image,cinfo,ps = ps,eps = eps
;_______________________________________________________________________
hcopy = 0
if ( (keyword_set(ps)) or ( keyword_set(eps)) ) then hcopy = 1

n_pixels = float( (cinfo.slope.naxis1) * (cinfo.slope.naxis2))

zoom = cinfo.image.zoom

x = cinfo.image.xposful ; xposful = x location in full image
y = cinfo.image.yposful ; yposful = y location in full image


if(zoom eq 1) then begin
    x =cinfo.slope.naxis1
    y = cinfo.slope.naxis2
endif
xsize_org =  cinfo.image.xplotsize
ysize_org =  cinfo.image.yplotsize

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

if(zoom eq 64) then begin
  xsize = xsize_org/64
  ysize = ysize_org/64
endif

if(zoom eq 128) then begin
  xsize = xsize_org/128
  ysize = ysize_org/128
endif

; ixstart and iystart are the starting points for the zoom image
; xstart and ystart are the starting points for the orginal image

xdata_end = cinfo.slope.naxis1
ydata_end = cinfo.slope.naxis2
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

cinfo.image.ixstart_zoom = ixstart
cinfo.image.xstart_zoom = xstart

cinfo.image.iystart_zoom = iystart
cinfo.image.ystart_zoom = ystart

cinfo.image.yend_zoom = yend
cinfo.image.xend_zoom = xend

slope_image = (*cinfo.slope.pslope)
sub_image = fltarr(xsize,ysize)   

sub_image[ixstart:ixend,iystart:iyend] =slope_image[xstart:xend,ystart:yend]
stat_data =     sub_image

x_zoom_start = ixstart
x_zoom_end = ixend
if(cinfo.slope.subarray eq 0) then begin
    if(x_zoom_start lt 4) then x_zoom_start = 4 
    if(x_zoom_end gt 1027 ) then x_zoom_end = 1027
    x2 = ixend - x_zoom_end
    stat_noref = stat_data[x_zoom_start:xsize-x2-1,*]
    stat_data = 0
    stat_data = stat_noref
    stat_noref = 0
endif
    

get_image_stat,stat_data,image_mean,stdev,image_min,image_max,$
               irange_min,irange_max,image_median,stdev_mean,skew,ngood,nbad

stat_data = 0
;_______________________________________________________________________
if ptr_valid (cinfo.image.psubdata) then ptr_free,cinfo.image.psubdata
cinfo.image.psubdata = ptr_new(sub_image)

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


if(cinfo.slope.subarray eq 0) then begin  
    slope_image_noref  = slope_image[4:1027,*]
endif else begin 
    slope_image_noref = slope_image
endelse

get_image_stat,slope_image_noref,image_mean,stdev,image_min,image_max,$
               irange_min,irange_max,image_median,stdev_mean,skew,ngood,nbad
slope_image = 0                 ; free memory
slope_image_noref = 0
;_______________________________________________________________________
widget_control,cinfo.image.graphID,draw_xsize=cinfo.image.xplotsize,$
               draw_ysize=cinfo.image.yplotsize
if(hcopy eq 0 ) then wset,cinfo.image.pixmapID

xsize_image = fix(cinfo.slope.naxis1) 
ysize_image = fix(cinfo.slope.naxis2)
if(xsize_image lt 256) then begin
    xsize_image = cinfo.image.xplotsize 
    ysize_image  = cinfo.image.yplotsize 
endif

;_______________________________________________________________________
; check if default scale is true - then reset to orginal value
if(cinfo.image.default_scale_graph eq 1) then begin
    cinfo.image.graph_range[0] = irange_min
    cinfo.image.graph_range[1] = irange_max
endif


disp_image = congrid(sub_image, $
                     xsize_image,ysize_image)

test_image = disp_image

disp_image = bytscl(disp_image,min=cinfo.image.graph_range[0], $
                    max=cinfo.image.graph_range[1],top=cinfo.col_max,/nan)
tv,disp_image,0,0,/device

if( hcopy eq 0) then begin  
    wset,cinfo.image.draw_window_id
    device,copy=[0,0,xsize_image,ysize_image, $
                 0,0,cinfo.image.pixmapID]
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
cinfo.image.zoom_x = xzoom; off from zoom a bit because of 1032 image


if(hcopy eq 1) then begin 
    svalue = "Science Image"
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



; full image stats

widget_control,cinfo.image.slabelID[0],set_value=cinfo.image.sname[0]+ strtrim(string(mean,format="(g14.6)"),2) 
widget_control,cinfo.image.slabelID[1],set_value=cinfo.image.sname[1]+ strtrim(string(stdev,format="(g14.6)"),2) 
widget_control,cinfo.image.slabelID[2],set_value=cinfo.image.sname[2]+ strtrim(string(median,format="(g14.6)"),2) 
widget_control,cinfo.image.slabelID[3],set_value=cinfo.image.sname[3]+ strtrim(string(min,format="(g14.6)"),2) 
widget_control,cinfo.image.slabelID[4],set_value=cinfo.image.sname[4]+ strtrim(string(max,format="(g14.6)"),2) 

widget_control,cinfo.image.slabelID[5],set_value=cinfo.image.sname[5]+ strtrim(string(skew,format="(g14.6)"),2) 
widget_control,cinfo.image.slabelID[6],set_value=cinfo.image.sname[6]+ strtrim(string(ngood,format="(i10)"),2) 
widget_control,cinfo.image.slabelID[7],set_value=cinfo.image.sname[7]+ strtrim(string(nbad,format="(i10)"),2) 

widget_control,cinfo.image.rlabelID[0],set_value=cinfo.image.graph_range[0]
widget_control,cinfo.image.rlabelID[1],set_value=cinfo.image.graph_range[1]


; zoom image stats


widget_control,cinfo.image.zslabelID[0],$
               set_value=cinfo.image.sname[0]+ strtrim(string(z_mean,format="(g14.6)"),2) 
widget_control,cinfo.image.zslabelID[1],$
               set_value=cinfo.image.sname[1]+ strtrim(string(z_stdev,format="(g14.6)"),2) 
widget_control,cinfo.image.zslabelID[2],$
               set_value=cinfo.image.sname[2]+ strtrim(string(z_median,format="(g14.6)"),2) 
widget_control,cinfo.image.zslabelID[3],$
               set_value=cinfo.image.sname[3]+ strtrim(string(z_min,format="(g14.6)"),2) 
widget_control,cinfo.image.zslabelID[4],$
               set_value=cinfo.image.sname[4]+ strtrim(string(z_max,format="(g14.6)"),2) 

widget_control,cinfo.image.zslabelID[5],$
               set_value=cinfo.image.sname[5]+ strtrim(string(z_skew,format="(g14.6)"),2) 
widget_control,cinfo.image.zslabelID[6],$
               set_value=cinfo.image.sname[6]+ strtrim(string(z_good,format="(i10)"),2) 
widget_control,cinfo.image.zslabelID[7],$
               set_value=cinfo.image.sname[7]+ strtrim(string(z_bad,format="(i10)"),2) 



; replot the pixel location

halfpixelx = 0.5* cinfo.image.zoom_x
halfpixely = 0.5* cinfo.image.zoom
xpos1 = cinfo.image.x_pos-halfpixelx
xpos2 = cinfo.image.x_pos+halfpixelX

ypos1 = cinfo.image.y_pos-halfpixely
ypos2 = cinfo.image.y_pos+halfpixely

box_coords1 = [xpos1,xpos2,ypos1,ypos2]
plots,box_coords1[[0,0,1,1,0]],box_coords1[[2,3,3,2,2]],psym=0,/device


sub_image = 0
test_image = 0
widget_control,cinfo.cubeview,set_uvalue = cinfo
end



;_______________________________________________________________________
;***********************************************************************
pro cv_update_pixel_location,cinfo
;***********************************************************************

xvalue = cinfo.image.xposful ; location in image 
yvalue = cinfo.image.yposful

ss = 'NA'
slopevalue = (*cinfo.slope.pslope)[xvalue,yvalue,0]

widget_control,cinfo.image.pix_statID,$
                   set_value= cinfo.image.pix_statLabel + ' = ' + $
                   strtrim(string(slopevalue,format="("+cinfo.image.pix_statFormat+")"),2)


wset,cinfo.image.draw_window_id



xsize_image = fix(cinfo.slope.naxis1) 
ysize_image = fix(cinfo.slope.naxis2)
if(xsize_image lt 256) then begin
    xsize_image = cinfo.image.xplotsize 
    ysize_image  = cinfo.image.yplotsize 
endif
device,copy=[0,0,xsize_image,ysize_image, $
             0,0,cinfo.image.pixmapID]

save_color = cinfo.col_table
color6
halfpixelx = 0.5* cinfo.image.zoom_x
halfpixely = 0.5* cinfo.image.zoom
xpos1 = cinfo.image.x_pos-halfpixelx
xpos2 = cinfo.image.x_pos+halfpixelX

ypos1 = cinfo.image.y_pos-halfpixely
ypos2 = cinfo.image.y_pos+halfpixely

;print,'in cv_display_slope_image ',xpos1,xpos2,ypos1,ypos2
box_coords1 = [xpos1,xpos2,ypos1,ypos2]
plots,box_coords1[[0,0,1,1,0]],box_coords1[[2,3,3,2,2]],psym=0,/device,color = 4


xcorner_new = cinfo.image.xcorner
ycorner_new = cinfo.image.ycorner
for i = 0, 3 do begin 
    xcorner_new[i] = cinfo.image.xcorner[i] -cinfo.image.xstart_zoom -0.5
    ycorner_new[i] = cinfo.image.ycorner[i] -cinfo.image.ystart_zoom -0.5
    xcorner_new[i] = (xcorner_new[i])*cinfo.image.zoom_x
    ycorner_new[i] = (ycorner_new[i])*cinfo.image.zoom
endfor

plots,[xcorner_new[0],xcorner_new[1],xcorner_new[2],xcorner_new[3],xcorner_new[0]],$
     [ycorner_new[0],ycorner_new[1],ycorner_new[2],ycorner_new[3],ycorner_new[0]],$
	linestyle=0,/device,color=3,thick = 2

widget_control,cinfo.CubeView,set_uvalue = cinfo
cinfo.col_table = save_color

end





;***********************************************************************
pro cv_update_cube_corners,cinfo
;***********************************************************************
; the corner values are on a system of 0.5 to 1.5 for pixel 1 so
 ; subtract 0.5 to get on system 0 to 1032 for plotting 
xcorner_new = cinfo.image.xcorner*0.0
ycorner_new = cinfo.image.ycorner*0.0

off_plot = 0
for i = 0, 3 do begin 
    xcorner_new[i] = cinfo.image.xcorner[i] -cinfo.image.xstart_zoom -0.5 
    ycorner_new[i] = cinfo.image.ycorner[i] -cinfo.image.ystart_zoom -0.5
    xcorner_new[i] = (xcorner_new[i])*cinfo.image.zoom_x
    ycorner_new[i] = (ycorner_new[i])*cinfo.image.zoom
    if(xcorner_new[i] lt 0 or ycorner_new[i] lt 0) then off_plot = off_plot + 1 
;	print,'x y  ',cinfo.image.xcorner[i],cinfo.image.ycorner[i]
;	print,'start',cinfo.image.xstart_zoom,cinfo.image.ystart_zoom
;	print,xcorner_new[i],ycorner_new[i]
endfor

wset,cinfo.image.draw_window_id

xsize_image = fix(cinfo.slope.naxis1) 
ysize_image = fix(cinfo.slope.naxis2)
if(xsize_image lt 256) then begin
    xsize_image = cinfo.image.xplotsize 
    ysize_image  = cinfo.image.yplotsize 
endif
device,copy=[0,0,xsize_image,ysize_image, $
             0,0,cinfo.image.pixmapID]


save_color = cinfo.col_table
color6
plots,[xcorner_new[0],xcorner_new[1],xcorner_new[2],xcorner_new[3],xcorner_new[0]],$
     [ycorner_new[0],ycorner_new[1],ycorner_new[2],ycorner_new[3],ycorner_new[0]],linestyle=0,/device,$
      color = 3,thick=2
if(cinfo.image.gap eq 1) then $
xyouts,xcorner_new[0],ycorner_new[1],'Approximate Location, Pixel is Located in Slice Gap',/device,color=3

if(off_plot eq 4) then print,' Cube pixel off Detector '




cinfo.col_table = save_color
widget_control,cinfo.CubeView,set_uvalue = cinfo
end



;_______________________________________________________________________
;***********************************************************************
pro cv_display_slope_image,cinfo
;_______________________________________________________________________


if(cinfo.image.uwindowsize eq 0) then begin ; user changed the widget window size - only redisplay

; labels used for the Pixel Statistics Table
    cinfo.image.draw_window_id = 0
    cinfo.image.pixmapID = 0
    cinfo.image.graphID = 0
    cinfo.image.graph_range[*] = 0
    cinfo.image.default_scale_graph = 0
    cinfo.image.image_recomputeID=0
    cinfo.image.slabelID[*] = 0L
    cinfo.image.rlabelID[*] = 0L
    cinfo.image.x_pos = 0
    cinfo.image.y_pos = 0
    cinfo.image.default_scale_graph = 1
    cinfo.image.zoom = 1
    cinfo.image.zoom_x = 1
    cinfo.image.x_pos =(cinfo.slope.naxis1)/2.0
    cinfo.image.y_pos = (cinfo.slope.naxis2)/2.0

    cinfo.image.xposful = cinfo.image.x_pos
    cinfo.image.yposful = cinfo.image.y_pos

    range_min = 0.0
    range_max = 0.0
    cinfo.image.graph_range[0] = range_min
    cinfo.image.graph_range[1] = range_max
endif
;*********
;Setup main panel
;*********

window,1,/pixmap
wdelete,1


if(XRegistered ('viewslope')) then begin
    widget_control,cinfo.ViewSlope,/destroy
endif


; widget window parameters
xwidget_size = 1400
ywidget_size = 1100

w = get_screen_size()
xsize_scroll = w[0]*.95
ysize_scroll = w[1]*.85

if(cinfo.slope.subarray ne 0) then begin
    xwidget_size = 900
    ywidget_size = 900

endif



if(cinfo.image.uwindowsize eq 1) then begin ; user has set window size 
    xsize_scroll = cinfo.image.xwindowsize
    ysize_scroll = cinfo.image.ywindowsize
endif

if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-20
if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-20



cinfo.ViewSlope = widget_base(title=" Viewing Slope Image" + cinfo.version,$
                                mbar = menuBar,/row,group_leader = cinfo.cubeview,$
                                xsize =  xwidget_size,$
                                ysize=   ywidget_size,/scroll,$
                                x_scroll_size= xsize_scroll,$
                                y_scroll_size = ysize_scroll,/TLB_SIZE_EVENTS)

;********
; build the menubar
;********
QuitMenu = widget_button(menuBar,value="Quit",font = cinfo.font2)

; add quit button
quitbutton = widget_button(quitmenu,value="Quit",event_pro='cv_display_slope_image_quit')

; zoom button
ZoomMenu = widget_button(menuBar,value="Zoom",font = cinfo.font2)

; add quit button
zbutton = widget_button(Zoommenu,value="No Zoom",uvalue='zoom0')
zbutton = widget_button(Zoommenu,value="Zoom 2x",uvalue='zoom1')
zbutton = widget_button(Zoommenu,value="Zoom 4x",uvalue='zoom2')
zbutton = widget_button(Zoommenu,value="Zoom 8x",uvalue='zoom3')
zbutton = widget_button(Zoommenu,value="Zoom 16x",uvalue='zoom4')
zbutton = widget_button(Zoommenu,value="Zoom 32x",uvalue='zoom5')
zbutton = widget_button(Zoommenu,value="Zoom 64x",uvalue='zoom6')
zbutton = widget_button(Zoommenu,value="Zoom 128x",uvalue='zoom7')

;PMenu = widget_button(menuBar,value="Print",font = cinfo.font2)
;PbuttonR = widget_button(Pmenu,value = "Print Science Image to output file",uvalue='prints')
;*****
; setup the image windows
;*****
; set up for Raw image widget window

graphID_master1 = widget_base(cinfo.ViewSlope,row=1)
graphID1 = widget_base(graphID_master1,col=1)
graphID2  = widget_base(graphID_master1,col=1)
;_______________________________________________________________________  

;*****
;graph full images
;*****



xplotsize = cinfo.slope.naxis1
yplotsize = cinfo.slope.naxis2
if (xplotsize lt 256) then begin
    xplotsize = 256
    yplotsize = 256
endif

cinfo.image.xplotsize = xplotsize
cinfo.image.yplotsize = yplotsize

cinfo.image.graphID = widget_draw(graphID1,$
                              xsize = xplotsize,$
                              ysize = yplotsize,$
                              /Button_Events,$
                              retain=cinfo.retn,uvalue='imagepixel')

;_______________________________________________________________________
;  Information on the image

xsize_label = 8
; 
; statistical information - next column

blank = '                                               '
ttitle = cinfo.slope.filename 

         
graph_label = widget_label(graphID2,value=ttitle,/align_left,font = cinfo.font5)
ss = "Image Size [" + strtrim(string(cinfo.slope.naxis1),2) + ' x ' +$
        strtrim(string(cinfo.slope.naxis2),2) + ']'

size_label= widget_label(graphID2,value = ss,/align_left)

base1 = widget_base(graphID2,row= 1,/align_left)

blank10 = '               '

;-----------------------------------------------------------------------
; min and max scale of  image

base1 = widget_base(graphID2,row= 1,/align_left)
r_label1 = widget_label(base1,value="Change Image Scale" ,/align_left,font=cinfo.font5,$
                       /sunken_frame)

cinfo.image.image_recomputeID = widget_button(base1,value='Default Scale',font=cinfo.font3,$
                                          uvalue = 'sinspect',/align_left)
base1 = widget_base(graphID2,row= 1,/align_left)
cinfo.image.rlabelID[0] = cw_field(base1,title="Minimum",font=cinfo.font3,uvalue="isr_b",$
                              /float,/return_events,xsize=xsize_label,value =range_min)

cinfo.image.rlabelID[1] = cw_field(base1,title="Maximum",font=cinfo.font3,uvalue="isr_t",$
                         /float,/return_events,xsize = xsize_label,value =range_max)


;-----------------------------------------------------------------------

general_label= widget_label(graphID2,$
                            value=" Pixel Information (Image: 1032 X 1024)",/align_left,$
                            font=cinfo.font5,/sunken_frame)

pix_num_base = widget_base(graphID2,row=1,/align_left)
labelID = widget_button(pix_num_base,uvalue='pix_move_x1',value='<',font=cinfo.font3)
labelID = widget_button(pix_num_base,uvalue='pix_move_x2',value='>',font=cinfo.font3)

xvalue = cinfo.image.xposful
yvalue = cinfo.image.yposful

cinfo.image.pix_label[0] = cw_field(pix_num_base,title="x",font=cinfo.font4, $
                                   uvalue="pix_x_val",/integer,/return_events, $
                                   value=fix(xvalue+1),xsize=6,$  ; xvalue + 1 -4 (reference pixel)
                                   fieldfont=cinfo.font3)



pix_num_base = widget_base(graphID2,row=1,/align_left)
labelID = widget_button(pix_num_base,uvalue='pix_move_y1',value='<',font=cinfo.font3)
labelID = widget_button(pix_num_base,uvalue='pix_move_y2',value='>',font=cinfo.font3)
cinfo.image.pix_label[1] = cw_field(pix_num_base,title="y",font=cinfo.font4, $
                                   uvalue="pix_y_val",/integer,/return_events, $
                                   value=fix(yvalue+1),xsize=6,$
                                   fieldfont=cinfo.font3)


pix_num_base = widget_base(graphid2,/col,/align_left)

cinfo.image.pix_statLabel = [ "Slope (DN/s)"]

cinfo.image.pix_statFormat = ["F12.5" ]

cinfo.image.pix_statID=widget_label(pix_num_base,value = cinfo.image.pix_statLabel+$
                                                  ' = ' ,/align_left,/dynamic_resize)

; stats
b_label = widget_label(graphID2,value=blank)
s_label = widget_label(graphID2,value="Statisical Information" ,/align_left,/sunken_frame,$
                       font=cinfo.font5)
s_label = widget_label(graphID2,value="Reference Pixels  NOT Included" ,/align_left)




cinfo.image.sname = ['Mean:              ',$
                      'Standard Deviation ',$
                      'Median:            ',$
                      'Min:               ',$
                      'Max:               ',$
                      'Skew:              ',$
                      '# of Good Pixels   ',$
                      '# of Bad Pixels    ']
cinfo.image.slabelID[0] = widget_label(graphID2,value=cinfo.image.sname[0] +blank10,/align_left)
cinfo.image.slabelID[1] = widget_label(graphID2,value=cinfo.image.sname[1] +blank10,/align_left)
cinfo.image.slabelID[2] = widget_label(graphID2,value=cinfo.image.sname[2] +blank10,/align_left)
cinfo.image.slabelID[3] = widget_label(graphID2,value=cinfo.image.sname[3] +blank10,/align_left)
cinfo.image.slabelID[4] = widget_label(graphID2,value=cinfo.image.sname[4] +blank10,/align_left)
cinfo.image.slabelID[5] = widget_label(graphID2,value=cinfo.image.sname[5] +blank10,/align_left)
cinfo.image.slabelID[6] = widget_label(graphID2,value=cinfo.image.sname[6] +blank10,/align_left)
cinfo.image.slabelID[7] = widget_label(graphID2,value=cinfo.image.sname[7] +blank10,/align_left)





; stats on zoom window
;*****
;graph 1,2; Zoom window of reference image
;*****

 subt = "Statisical Information for Zoom Region"

zgraph_label = widget_label(graphID2,value=subt,/align_left,$
                            font=cinfo.font5,/sunken_frame)
s_label = widget_label(graphID2,value="Reference Pixels NOT Included" ,/align_left)

cinfo.image.zslabelID[0] = widget_label(graphID2,value=cinfo.image.sname[0] +blank10,/align_left)
cinfo.image.zslabelID[1] = widget_label(graphID2,value=cinfo.image.sname[1] +blank10,/align_left)
cinfo.image.zslabelID[2] = widget_label(graphID2,value=cinfo.image.sname[2] +blank10,/align_left)
cinfo.image.zslabelID[3] = widget_label(graphID2,value=cinfo.image.sname[3] +blank10,/align_left)
cinfo.image.zslabelID[4] = widget_label(graphID2,value=cinfo.image.sname[4] +blank10,/align_left)
cinfo.image.zslabelID[5] = widget_label(graphID2,value=cinfo.image.sname[5] +blank10,/align_left)
cinfo.image.zslabelID[6] = widget_label(graphID2,value=cinfo.image.sname[6] +blank10,/align_left)
cinfo.image.zslabelID[7] = widget_label(graphID2,value=cinfo.image.sname[7] +blank10,/align_left)

;_______________________________________________________________________
longline = '                              '
longtag = widget_label(cinfo.ViewSlope,value = longline)

; realize main panel
Widget_control,cinfo.ViewSlope,/Realize
XManager,'viewslope',cinfo.ViewSlope,/No_Block,event_handler='viewslope_event'

; get the window ids of the draw windows

widget_control,cinfo.image.graphID,get_value=tdraw_id
cinfo.image.draw_window_id = tdraw_id

window,/pixmap,xsize=cinfo.image.xplotsize,ysize=cinfo.image.yplotsize,/free
cinfo.image.pixmapID = !D.WINDOW

cv_update_slope_image,cinfo

cv_update_pixel_location,cinfo

Widget_Control,cinfo.CubeView,Set_UValue=cinfo
iinfo = {cinfo        : cinfo}

Widget_Control,cinfo.ViewSlope,Set_UValue=iinfo
Widget_Control,cinfo.CubeView,Set_UValue=cinfo
end

