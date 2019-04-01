;***********************************************************************
pro jwst_msql_compare_display_quit,event
widget_control,event.top, Get_UValue = tinfo
widget_control,tinfo.info.jwst_QuickLook,Get_UValue=info
widget_control,info.jwst_RCompareDisplay,/destroy
end

;_______________________________________________________________________
pro jwst_msql_compare_display_cleanup,topbaseID

; get all defined structures so they are deleted when the program
; terminates

widget_control,topbaseID,get_uvalue=ginfo
widget_control,ginfo.info.QuickLook,get_uvalue = info
widget_control,info.jwst_RCompareDisplay,/destroy
end

;***********************************************************************
; the event manager for the jwst_msql_compare_display.pro (comparing widget)
pro jwst_msql_compare_test,info,status
;_______________________________________________________________________
; Done selecting the images, do some checks that the data is of the
; same type, then read in the data

status = 0
;type = 1 rate final
;type  =2 rate int
type_a = info.jwst_rcompare_image[0].type 
type_b = info.jwst_rcompare_image[1].type 

if(type_a eq 0 or type_a eq 3) then begin
    mess1 = 'Files must be rate images' 
    mess2 = 'Pick  file again' 
    print,mess1
    print,mess2    
    ok = dialog_message(mess1 + string(10B) + mess2,/Information)

    status = 1
    return
 endif
if(type_b eq 0 or type_b eq 3) then begin
    mess1 = 'Files must be rate images' 
    mess2 = 'Pick file again' 
    print,mess1
    print,mess2    
    ok = dialog_message(mess1 + string(10B) + mess2,/Information)

    status = 1
    return
endif

if(status eq 0) then begin 
; check that image sizes are the same
    status = 0
    if( info.jwst_rcompare_image[0].xsize ne info.jwst_rcompare_image[1].xsize) then begin
        status = 1
        mess = ' X image size of two images are not the same size, Reload images. X Image sizes : '+ $
	strcompress(string(info.jwst_rcompare_image[0].xsize),/remove_all) + ' ' + $
	strcompress(string(info.jwst_rcompare_image[1].xsize),/remove_all)
	
        print,mess
        ok = dialog_message(mess ,/Information)
        return
    endif

    if(info.jwst_rcompare_image[0].ysize ne info.jwst_rcompare_image[1].ysize) then begin
        status = 1
        mess = ' Y image size of two images are not the same size, Reload images. Y Image sizes : '+ $
	strcompress(string(info.jwst_rcompare_image[0].ysize),/remove_all) + ' ' + $
	strcompress(string(info.jwst_rcompare_image[1].ysize),/remove_all)
        print,mess
        ok = dialog_message(mess ,/Information)
        return
    endif
    if( info.jwst_rcompare_image[0].subarray ne info.jwst_rcompare_image[1].subarray) then begin
        status = 1
        mess = ' One image subarray data and the other is not'
        print,mess
        ok = dialog_message(mess ,/Information)
        return
    endif
endif

Widget_Control,info.jwst_QuickLook,Set_UValue=info        
end


;_______________________________________________________________________
pro jwst_msql_compare_read_image,info,i,status
widget_control,/hourglass
progressBar = Obj_New("ShowProgress", color = 150, $
                      message = " Reading in Comparison Data",$
                      xsize = 250, ysize = 40)
progressBar -> Start

type_a = info.jwst_rcompare_image[0].type 
filename = info.jwst_rcompare_image[i].filename
this_integration = info.jwst_rcompare_image[i].jintegration

if(type_a eq 1 or type_a eq 2) then $
jwst_read_single_slope,filename,exists,this_integration,$
                  subarray,imagedata,image_xsize,image_ysize,$
                  stats_image,status,error_message

    
if(status ne 0) then begin
    result = dialog_message(error_message,/error )
    return
endif

jwst_read_image_info,filename,nints,nframes,subarray,xxsize,yysize,colstart
info.jwst_rcompare_image[i].nints= nints
info.jwst_rcompare_image[i].subarray = subarray
info.jwst_rcompare_image[i].colstart = colstart

info.jwst_rcompare_image[i].xsize = image_xsize
info.jwst_rcompare_image[i].ysize = image_ysize

plane = info.jwst_rcompare_image[i].plane

reduced_data = imagedata[*,*,plane]

if ptr_valid (info.jwst_rcompare_image[i].pdata) then ptr_free,$
  info.jwst_rcompare_image[i].pdata
info.jwst_rcompare_image[i].pdata= ptr_new(reduced_data)


info.jwst_rcompare_image[i].mean = stats_image[0]
info.jwst_rcompare_image[i].median = stats_image[1]
info.jwst_rcompare_image[i].stdev = stats_image[2]
info.jwst_rcompare_image[i].min = stats_image[3]
info.jwst_rcompare_image[i].max = stats_image[4]
info.jwst_rcompare_image[i].range_min = stats_image[5]
info.jwst_rcompare_image[i].range_max = stats_image[6]
info.jwst_rcompare_image[i].stdev_mean = stats_image[7]

progressBar -> Destroy
obj_destroy, progressBar
end
;_______________________________________________________________________
pro jwst_msql_compare_update_pixel_location,info

for i = 0,2 do begin
    wset,info.jwst_rcompare.draw_window_id[i]

    device,copy=[0,0,info.jwst_rcompare.xplot_size,info.jwst_rcompare.yplot_size, $
                 0,0,info.jwst_rcompare.pixmapID[i]]

    box_coords1 = [info.jwst_rcompare.x_pos,(info.jwst_rcompare.x_pos+1), $
                   info.jwst_rcompare.y_pos,(info.jwst_rcompare.y_pos+1)]
    box_coords2 = [info.jwst_rcompare.x_pos+1,(info.jwst_rcompare.x_pos+1)-1, $
                   info.jwst_rcompare.y_pos+1,(info.jwst_rcompare.y_pos+1)-1]
    plots,box_coords1[[0,0,1,1,0]],box_coords1[[2,3,3,2,2]],psym=0,/device

endfor
end
;***********************************************************************
pro jwst_msql_compare_update_pixel_info,info

xvalue = fix(info.jwst_rcompare.x_pos*info.jwst_rcompare.binfactor)
yvalue = fix(info.jwst_rcompare.y_pos*info.jwst_rcompare.binfactor)

widget_control,info.jwst_rcompare.pix_label[0],set_value=xvalue+1
widget_control,info.jwst_rcompare.pix_label[1],set_value=yvalue+1

value1 = (*info.jwst_rcompare_image[0].pdata)[xvalue,yvalue]
value2 = (*info.jwst_rcompare_image[1].pdata)[xvalue,yvalue]
value3 = (*info.jwst_rcompare_image[2].pdata)[xvalue,yvalue]

svalue1 = info.jwst_rcompare.pix_statLabel[0]+' = '+$
          strtrim(string(value1,format="("+info.jwst_rcompare.pix_statFormat[0]+")"),2)
svalue2 = info.jwst_rcompare.pix_statLabel[1]+' = '+$
          strtrim(string(value2,format="("+info.jwst_rcompare.pix_statFormat[1]+")"),2)
svalue3 = info.jwst_rcompare.pix_statLabel[2]+' = '+$
          strtrim(string(value3,format="("+info.jwst_rcompare.pix_statFormat[2]+")"),2)

widget_control,info.jwst_rcompare.pix_statLabelID[0],set_value= svalue1
widget_control,info.jwst_rcompare.pix_statLabelID[1],set_value= svalue2
widget_control,info.jwst_rcompare.pix_statLabelID[2],set_value= svalue3
end
;_______________________________________________________________________
pro jwst_msql_compare_update_images,info,imageno

loadct,info.col_table,/silent
ximage_size = info.jwst_rcompare_image[imageno].xsize
yimage_size = info.jwst_rcompare_image[imageno].ysize
n_pixels = float( ximage_size*yimage_size)

; check if default scale is true - then reset to orginal value
if(info.jwst_rcompare.default_scale_graph[imageno] eq 1) then begin
    info.jwst_rcompare.graph_range[imageno,0] = info.jwst_rcompare_image[imageno].range_min
    info.jwst_rcompare.graph_range[imageno,1] = info.jwst_rcompare_image[imageno].range_max
endif

frame_image = fltarr(ximage_size,yimage_size)
frame_image[*,*] = (*info.jwst_rcompare_image[imageno].pdata)
indxs = where(finite(frame_image),n_pixels)

widget_control,info.jwst_rcompare.graphID[imageno],$
	draw_xsize = info.jwst_rcompare.xplot_size,draw_ysize=info.jwst_rcompare.yplot_size 
     
wset,info.jwst_rcompare.pixmapID[imageno]
disp_image = congrid(frame_image, $
                     info.jwst_rcompare.xplot_size,$
                     info.jwst_rcompare.yplot_size)

min_image = info.jwst_rcompare.graph_range[imageno,0]
max_image = info.jwst_rcompare.graph_range[imageno,1]

if( finite(max_image) ne 1) then max_image = 1
if( finite(min_image) ne 1) then min_image = 0
 
disp_image = bytscl(disp_image,min=min_image, $
                    max=max_image,$
                    top=info.col_max-info.col_bits-1,/nan)

tv,disp_image,0,0,/device
wset,info.jwst_rcompare.draw_window_id[imageno]
device,copy=[0,0,$
             info.jwst_rcompare.xplot_size,$
             info.jwst_rcompare.yplot_size, $
             0,0,info.jwst_rcompare.pixmapID[imageno]]
; update stats    

rawmean = info.jwst_rcompare_image[imageno].mean
rawmedian = info.jwst_rcompare_image[imageno].median
st = info.jwst_rcompare_image[imageno].stdev
rawmin  = info.jwst_rcompare_image[imageno].min
rawmax  = info.jwst_rcompare_image[imageno].max

smean = strtrim(string(rawmean,format="(E16.4)"),2) 
smedian = strtrim(string(rawmedian,format="(E16.4)"),2) 
sst = strtrim(string(st,format="(E16.4)"),2)
smin = strtrim(string(rawmin,format="(E16.4)"),2) 
smax = strtrim( string(rawmax,format="(E16.4)"),2)

scale_min = info.jwst_rcompare.graph_range[imageno,0]
scale_max = info.jwst_rcompare.graph_range[imageno,1]

widget_control,info.jwst_rcompare.slabelID[imageno,0],set_value=(info.jwst_rcompare.sname[0] + smean)
widget_control,info.jwst_rcompare.slabelID[imageno,1],set_value=(info.jwst_rcompare.sname[1] + sst)
widget_control,info.jwst_rcompare.slabelID[imageno,2],set_value=(info.jwst_rcompare.sname[2] + smedian) 
widget_control,info.jwst_rcompare.slabelID[imageno,3],set_value=(info.jwst_rcompare.sname[3] + smin) 
widget_control,info.jwst_rcompare.slabelID[imageno,4],set_value=(info.jwst_rcompare.sname[4] + smax) 

widget_control,info.jwst_rcompare.rlabelID[imageno,0],set_value=scale_min
widget_control,info.jwst_rcompare.rlabelID[imageno,1],set_value=scale_max

; replot the pixel location
box_coords1 = [info.jwst_rcompare.x_pos,(info.jwst_rcompare.x_pos+1), $
               info.jwst_rcompare.y_pos,(info.jwst_rcompare.y_pos+1)]
box_coords2 = [info.jwst_rcompare.x_pos+1,(info.jwst_rcompare.x_pos+1)-1, $
               info.jwst_rcompare.y_pos+1,(info.jwst_rcompare.y_pos+1)-1]
plots,box_coords1[[0,0,1,1,0]],box_coords1[[2,3,3,2,2]],psym=0,/device
end
;_______________________________________________________________________
; the event manager for the ql.pro (main base widget)
pro jwst_msql_compare_display_event,event

Widget_Control,event.id,Get_uValue=event_name
widget_control,event.top, Get_UValue = ginfo
widget_control,ginfo.info.jwst_QuickLook,Get_Uvalue = info

if (widget_info(event.id,/TLB_SIZE_EVENTS) eq 1 ) then begin
    info.jwst_rcompare.xwindowsize = event.x
    info.jwst_rcompare.ywindowsize = event.y
    info.jwst_rcompare.uwindowsize = 1
    widget_control,event.top,set_uvalue = ginfo
    widget_control,ginfo.info.jwst_Quicklook,set_uvalue = info
    jwst_msql_compare_display,info
    return
endif

    case 1 of
;_______________________________________________________________________
; load a new comparison image
    (strmid(event_name,0,7) EQ 'loadnew') : begin
        image_file = dialog_pickfile(/read,$
                                     get_path=realpath,Path=info.jwst_control.dir,$
                                     filter = '*.fits',title='Select Comparison File')
        
        if(image_file eq '')then begin
            print,' No file selected, can not read in data'
            status = 1
            return
        endif
        if (image_file NE '') then begin
            filename = image_file
        endif

        file_exist1 = file_test(filename,/read,/regular)
        if(file_exist1 ne 1 ) then begin
            print,'Image file does not exist'
            ok = dialog_message(" Image File does not exist, select filename again",/Information)
            status = 1
            return
        endif

        info.jwst_rcompare_image[1].filename  = filename
        info.jwst_rcompare_image[1].jintegration = info.jwst_rcompare_image[0].jintegration
        info.jwst_rcompare_image[1].plane = info.jwst_rcompare_image[0].plane
    
        jwst_read_data_type,info.jwst_rcompare_image[1].filename,type
        if(type eq 0 or type eq 3) then begin 
            error = dialog_message(" The file must be a rate science file, select file again",/error)
            return
        endif

        info.jwst_rcompare_image[1].type = type
        jwst_msql_compare_read_image,info,1,status
        jwst_msql_compare_test,info,status
        if(status ne 0) then return

        nints = info.jwst_rcompare_image[1].nints
        tlabel = "Total # " + strcompress(string(nints),/remove_all)
        widget_control,info.jwst_rcompare.total_ilabel[1], set_value = tlabel

        sfile = info.jwst_rcompare_image[1].filename
        sfind = strpos(sfile,'/',/reverse_search)
        if(sfind gt 0) then begin
            len = strlen(sfile)
            onlyfile = strmid(sfile,sfind+1,len)
        endif else begin
            onlyfile = sfile
        endelse
        widget_control,info.jwst_rcompare.filename_title[1], set_value = onlyfile  

        sint = strtrim( string (fix(info.jwst_rcompare_image[1].jintegration+1)),2)
        sinfo = ' Integration # ' + sint
        widget_control,info.jwst_rcompare.info_label[1], set_value = sinfo
;_______________________________________________________________________
        widget_control,info.jwst_rcompare.integration_label[1],set_value = info.jwst_rcompare_image[1].jintegration+1

        jwst_difference_reduced_images,info,0,1,2
         for i = 1, 2 do begin 
             jwst_msql_compare_update_images,info,i
         endfor
         jwst_msql_compare_update_pixel_info,info
         jwst_msql_compare_update_pixel_location,info

        Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info
    end

;_______________________________________________________________________
; Select a different pixel from the 
;_______________________________________________________________________
   (strmid(event_name,0,6) EQ 'cpixel') : begin
     info.jwst_rcompare.x_pos = event.x
     info.jwst_rcompare.y_pos = event.y
     jwst_msql_compare_update_pixel_info,info
     jwst_msql_compare_update_pixel_location,info
    Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info
end
;_______________________________________________________________________
; Select a different pixel to display information for
;_______________________________________________________________________
    (strmid(event_name,0,3) EQ 'pix') : begin
        xsize = info.jwst_rcompare.image_xsize
        ysize = info.jwst_rcompare.image_ysize

        pixel_xvalue = fix(info.jwst_rcompare.x_pos*info.jwst_rcompare.binfactor)
        pixel_yvalue = fix(info.jwst_rcompare.y_pos*info.jwst_rcompare.binfactor)

        xscale = float(info.jwst_rcompare.binfactor)
        yscale = float(info.jwst_rcompare.binfactor)

; first check if have uvalue = pix_x_value, pix_y_value (user input
; pixel value
; ++++++++++++++++++++++++++++++
        if(strmid(event_name,4,1) eq 'x') then  begin
            xvalue = event.value ; event value - user input starts at 1 

            if(xvalue lt 1) then begin
                xvalue = 1
            endif
            if(xvalue gt xsize) then begin
                xvalue = xsize
            endif
            pixel_xvalue = xvalue-1

            ;check what is in the ybox
            widget_control,info.jwst_rcompare.pix_label[1],get_value =  ytemp
            yvalue = ytemp
            if(yvalue lt 1) then begin
                yvalue = 1
            endif
            if(yvalue gt ysize) then begin
                yvalue = ysize
            endif
            pixel_yvalue = yvalue-1
        endif
; ++++++++++++++++++++++++++++++
        if(strmid(event_name,4,1) eq 'y') then begin
            yvalue = event.value ; event value - user input starts at 1
            if(yvalue lt 1) then begin
                yvalue = 1
            endif
            if(yvalue gt ysize) then begin
                yvalue = ysize
            endif
            pixel_yvalue = yvalue-1

            ;check what is in the xbox
            widget_control,info.jwst_rcompare.pix_label[0],get_value =  ytemp
            xvalue = ytemp
            if(xvalue lt 1) then begin
                xvalue = 1
            endif
            if(xvalue gt xsize) then begin
                xvalue = xsize
            endif
            pixel_xvalue = xvalue-1

        endif
; check if the <> buttons were used
; ++++++++++++++++++++++++++++++
        if(strmid(event_name,4,4) eq 'move') then begin
            if(strmid(event_name,9,2) eq 'x1') then pixel_xvalue = pixel_xvalue - 1
            if(strmid(event_name,9,2) eq 'x2') then pixel_xvalue = pixel_xvalue + 1
            if(strmid(event_name,9,2) eq 'y1') then pixel_yvalue = pixel_yvalue - 1
            if(strmid(event_name,9,2) eq 'y2') then pixel_yvalue = pixel_yvalue + 1

            if(pixel_xvalue le 0) then pixel_xvalue = 0
            if(pixel_yvalue le 0) then pixel_yvalue  = 0
            if(pixel_xvalue ge  xsize) then pixel_xvalue = xsize-1
            if(pixel_yvalue ge  ysize) then pixel_yvalue = ysize-1
        endif

; ++++++++++++++++++++++++++++++
        info.jwst_rcompare.x_pos = pixel_xvalue/xscale
        info.jwst_rcompare.y_pos = pixel_yvalue/yscale
        
        jwst_msql_compare_update_pixel_info,info
        jwst_msql_compare_update_pixel_location,info

        Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info
end
;_______________________________________________________________________
; scaling image,ref and slope
;_______________________________________________________________________
    (strmid(event_name,0,5) EQ 'scale') : begin

        graphno = fix(strmid(event_name,5,1))
        if(info.jwst_rcompare.default_scale_graph[graphno-1] eq 0 ) then begin ; true - turn to false
            widget_control,info.jwst_rcompare.image_recomputeID[graphno-1],set_value=' Image Scale '
            info.jwst_rcompare.default_scale_graph[graphno-1] = 1
        endif
        Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info
        jwst_msql_compare_update_images,info,graphno-1
    end
;_______________________________________________________________________
; change range of image graphs
; if change range then also change the scale button to 'User Set
; Scale'
;_______________________________________________________________________
    (strmid(event_name,0,2) EQ 'sr') : begin
        graph_num = fix(strmid(event_name,2,1))

        if(strmid(event_name,4,1) EQ 'b') then begin
            info.jwst_rcompare.graph_range[graph_num-1,0] = event.value
            widget_control,info.jwst_rcompare.rlabelID[graph_num-1,1],get_value = temp
            info.jwst_rcompare.graph_range[graph_num-1,1] =temp
        endif

        if(strmid(event_name,4,1) EQ 't') then begin
            info.jwst_rcompare.graph_range[graph_num-1,1] = event.value
            widget_control,info.jwst_rcompare.rlabelID[graph_num-1,0],get_value = temp
            info.jwst_rcompare.graph_range[graph_num-1,0] =temp
        endif

        info.jwst_rcompare.default_scale_graph[graph_num-1] = 0
        widget_control,info.jwst_rcompare.image_recomputeID[graph_num-1],set_value='Default Scale'

        Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info
        jwst_msql_compare_update_images,info,graph_num-1
    end
;_______________________________________________________________________
   (strmid(event_name,0,7) EQ 'inspect') : begin
       imageno = fix(strmid(event_name,7,1))-1
        info.jwst_crinspect[imageno].integrationNO = info.jwst_rcompare_image[imageno].jintegration
        frame_image = fltarr(info.jwst_rcompare_image[imageno].xsize,info.jwst_rcompare_image[imageno].ysize)
        frame_image[*,*] = (*info.jwst_rcompare_image[imageno].pdata)

        if ptr_valid (info.jwst_crinspect[imageno].pdata) then ptr_free,info.jwst_crinspect[imageno].pdata
        info.jwst_crinspect[imageno].pdata = ptr_new(frame_image)
        frame_image = 0

        info.jwst_crinspect[imageno].default_scale_graph = 1
        info.jwst_crinspect[imageno].zoom = 1
        info.jwst_crinspect[imageno].zoom_x = 1
        info.jwst_crinspect[imageno].x_pos =(info.jwst_rcompare_image[imageno].xsize)/2.0
        info.jwst_crinspect[imageno].y_pos = (info.jwst_rcompare_image[imageno].ysize)/2.0

        info.jwst_crinspect[imageno].xposful = info.jwst_crinspect[imageno].x_pos
        info.jwst_crinspect[imageno].yposful = info.jwst_crinspect[imageno].y_pos

        info.jwst_crinspect[imageno].graph_range[0] =info.jwst_rcompare.graph_range[imageno,0] 
        info.jwst_crinspect[imageno].graph_range[1] =info.jwst_rcompare.graph_range[imageno,1] 

        info.jwst_crinspect[imageno].limit_low = -5000.0
        info.jwst_crinspect[imageno].limit_high = 70000.0
        info.jwst_crinspect[imageno].limit_low_num = 0
        info.jwst_crinspect[imageno].limit_high_num = 0

        Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info

        jwst_micrql_display_images,info,imageno

   end
;_______________________________________________________________________

    (strmid(event_name,0,7) EQ 'compare') : begin
        if(event.index eq 0) then begin
            info.jwst_rcompare.compare_type = 0
            jwst_difference_reduced_images,info,0,1,2
            jwst_msql_compare_update_images,info,2
            jwst_msql_compare_update_pixel_info,info
        endif

        if(event.index eq 1) then begin
            info.jwst_rcompare.compare_type = 1
            jwst_difference_reduced_images,info,1,0,2
            jwst_msql_compare_update_images,info,2
            jwst_msql_compare_update_pixel_info,info
        endif
        if(event.index eq 2) then begin
            info.jwst_rcompare.compare_type = 2
            Jwst_ratio_reduced_images,info,0,1,2
            jwst_msql_compare_update_images,info,2
            jwst_msql_compare_update_pixel_info,info
        endif

        if(event.index eq 3) then begin
            info.jwst_rcompare.compare_type = 3
            jwst_ratio_reduced_images,info,1,0,2
            jwst_msql_compare_update_images,info,2
            jwst_msql_compare_update_pixel_info,info
        endif

        if(event.index eq 4) then begin
            info.jwst_rcompare.compare_type = 4
            jwst_add_reduced_images,info,0,1,2
            jwst_msql_compare_update_images,info,2
            jwst_msql_compare_update_pixel_info,info
        endif
    end
;_______________________________________________________________________
; Change the Integration #  of image displayed
;_______________________________________________________________________
; first image. 
    (strmid(event_name,0,5) EQ 'integ') : begin
        imageno = fix(strmid(event_name,5,1))
	if (strmid(event_name,6,1) EQ 'i') then begin 
           this_value = event.value-1
           this_integration = this_value
	endif

; check if the <> buttons were used
       if (strmid(event_name,6,5) EQ '_move')then begin
           this_integration = info.jwst_rcompare_image[imageno-1].jintegration
          if(strmid(event_name,12,2) eq 'dn') then begin
             this_integration = this_integration -1
          endif
          if(strmid(event_name,12,2) eq 'up') then begin
             this_integration = this_integration+1
          endif
       endif

; do some checks 
       if(this_integration le 0) then begin
            this_integration = 0
        endif
        lastnum =  info.jwst_rcompare_image[imageno-1].nints
       if(this_integration gt lastnum-1 ) then begin
            this_integration = lastnum-1
        endif

         info.jwst_rcompare_image[imageno-1].jintegration = this_integration       
         widget_control,info.jwst_rcompare.integration_label[imageno-1],set_value = this_integration+1

        sint = strtrim( string (fix(info.jwst_rcompare_image[imageno-1].jintegration+1)),2)
        sinfo = ' Integration # ' + sint
        widget_control,info.jwst_rcompare.info_label[imageno-1], set_value = sinfo
         
         jwst_msql_compare_read_image,info,imageno-1,status

	 jwst_msql_compare_test,info,status
         if(status ne 0) then return

         jwst_difference_reduced_images,info,0,1,2
         for i = 0, 2 do begin 
             jwst_msql_compare_update_images,info,i
         endfor
         jwst_msql_compare_update_pixel_info,info

        Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info
    end

else: print," Event name not found",event_name
endcase
Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info
end

;_______________________________________________________________________
pro jwst_msql_compare_display,info
;_______________________________________________________________________
widget_control,/hourglass
progressBar = Obj_New("ShowProgress", color = 150, $
                      message = " Reading in Comparison Data",$
                      xsize = 250, ysize = 40)
progressBar -> Start
window,1,/pixmap
wdelete,1
if(XRegistered ('jwst_msql_compare')) then begin
    widget_control,info.jwst_RcompareDisplay,/destroy
endif


if(XRegistered ('jwst_loadcompare')) then begin ; if loaded images from load_compare - get rid of window
    widget_control,info.jwst_load2Display,/destroy
endif

this_integration = info.jwst_slope.integrationNO

if(info.jwst_rcompare.uwindowsize eq 0) then begin

    info.jwst_crinspect[*].uwindowsize = 0
    ; commenting out code for now

;    jwst_read_data_type,info.jwst_rcompare_image[0].filename,type
;    info.jwst_rcompare_image[0].type = type

;    jwst_read_data_type,info.jwst_rcompare_image[1].filename,type
;    info.jwst_rcompare_image[1].type = type


    status = 0
    for i = 0,1 do begin 
        jwst_msql_compare_read_image,info,i,status
    endfor

    jwst_msql_compare_test,info,status
    if(status ne 0) then begin
        progressBar -> Destroy
        obj_destroy, progressBar
        return
    endif
;    info.rcompare.compare_type = 0 ; difference image
;_______________________________________________________________________
    jwst_difference_reduced_images,info,0,1,2
    info.jwst_rcompare.image_xsize = info.jwst_rcompare_image[0].xsize
    info.jwst_rcompare.image_ysize = info.jwst_rcompare_image[0].ysize
    info.jwst_rcompare.subarray = info.jwst_rcompare_image[0].subarray
    jwst_find_binfactor,info.jwst_rcompare_image[0].subarray,$
	info.jwst_rcompare_image[0].xsize,info.jwst_rcompare_image[0].ysize,binfactor

    info.jwst_rcompare.binfactor = binfactor
endif

;*********
;Setup main panel
;*********

; widget window parameters
xwidget_size = 1400
ywidget_size = 1400

xsize_scroll = 1200
ysize_scroll = 1200

if(info.jwst_rcompare.uwindowsize eq 1) then begin ; user has set window size 
    xsize_scroll = info.jwst_rcompare.xwindowsize
    ysize_scroll = info.jwst_rcompare.ywindowsize
endif
if(info.jwst_control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.jwst_control.x_scroll_window
if(info.jwst_control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.jwst_control.y_scroll_window
if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10
    
CompareDisplay = widget_base(title="MIRI Quick Look- Compare Two Reduced Images" + info.jwst_version,$
                           col = 1,mbar = menuBar,group_leader = info.jwst_QuickLook,$
                           xsize =  xwidget_size,$
                           ysize=   ywidget_size,/scroll,$
                           x_scroll_size= xsize_scroll,$
                           y_scroll_size = ysize_scroll,/TLB_SIZE_EVENTS)


info.jwst_RCompareDisplay = CompareDisplay

;********
; build the menubar
;********ql.p
QuitMenu = widget_button(menuBar,value="Quit",font = info.font2)
quitbutton = widget_button(quitmenu,value="Quit",event_pro='jwst_msql_compare_display_quit')

;_______________________________________________________________________
; window size is based on 1032 X 1024 image
; The default scale is 4 so the window (on the analyze raw images
; window) is 258 X 256

info.jwst_rcompare.xplot_size = 258
info.jwst_rcompare.yplot_size = 256
if(info.jwst_rcompare.subarray ne 0) then info.jwst_rcompare.xplot_size = 256
xsize_image = fix(info.jwst_rcompare.image_xsize/info.jwst_rcompare.binfactor) 
ysize_image = fix(info.jwst_rcompare.image_ysize/info.jwst_rcompare.binfactor)
info.jwst_rcompare.xplot_size = xsize_image
info.jwst_rcompare.yplot_size = ysize_image
;_______________________________________________________________________
; defaults to start with 

info.jwst_rcompare.default_scale_graph[*] = 1
info.jwst_rcompare.graph_range[*,*] = 0.0

info.jwst_rcompare.x_pos =0.0
info.jwst_rcompare.y_pos = 0.0
;****
; setup the image windows
;*****

graphID_master00 = widget_base(info.jwst_RCompareDisplay,row=1,/align_center)
graphID_master0 = widget_base(info.jwst_RCompareDisplay,row=1)
graphID_master1 = widget_base(info.jwst_RCompareDisplay,row=1)

info.jwst_rcompare.graphID11 = widget_base(graphID_master0,col=1)
info.jwst_rcompare.graphID12 = widget_base(graphID_master0,col=1)
info.jwst_rcompare.graphID13 = widget_base(graphID_master0,col=1) 
    
;graphID21 = widget_base(graphID_master1,col=1) 


info.jwst_rcompare.x_pos =(info.jwst_rcompare.image_xsize/info.jwst_rcompare.binfactor)/2.0
info.jwst_rcompare.y_pos = (info.jwst_rcompare.image_ysize/info.jwst_rcompare.binfactor)/2.0

;_______________________________________________________________________
; binning information
scale_i = strcompress(string(info.jwst_rcompare.binfactor,format='(f5.2)'),/remove_all)
sizevalues = 'Bin X Y ['+ scale_i + ','+ scale_i+']'


if( info.jwst_rcompare_image[0].ysize gt 258 ) then begin 
    screen_label= widget_label(graphid_master00,$
                               value="Binning of Images: " + sizevalues,/align_center,$
                               font=info.font5,/sunken_frame)
endif else begin
    blank = widget_label(graphid_master00,$
                         value='  ',/align_left,font=info.font5)
endelse


;*****
;graph 1,1
;*****

xsize_label = 8
slabela = " Rate "
if(info.jwst_rcompare_image[0].plane eq 1) then slabela = " Error "
if(info.jwst_rcompare_image[0].plane eq 2) then slabela = " Data Quality Flag "


slabel_A =  slabela +  "A: "  + " [" + strtrim(string(info.jwst_rcompare.image_xsize),2) + ' x ' +$
        strtrim(string(info.jwst_rcompare.image_ysize),2) + ']'

slabel_B =  slabela + "B: " +  " [" + strtrim(string(info.jwst_rcompare.image_xsize),2) + ' x ' +$
        strtrim(string(info.jwst_rcompare.image_ysize),2) + ']'



sfile = info.jwst_rcompare_image[0].filename
sfind = strpos(sfile,'/',/reverse_search)
if(sfind gt 0) then begin
    len = strlen(sfile)
    onlyfile = strmid(sfile,sfind+1,len)
endif else begin
    onlyfile = sfile
endelse
info.jwst_rcompare.filename_title[0] = widget_label(info.jwst_rcompare.graphID11,$
                                         value=onlyfile,/align_left,$
                                        font=info.font5)
graph_label = widget_label(info.jwst_rcompare.graphID11,$
                                         value=slabel_A,/align_left,$
                                        font=info.font5)
sint = strtrim( string (fix(info.jwst_rcompare_image[0].jintegration+1)),2)

sinfo = ' Integration #      ' + sint 

sbase = widget_base(info.jwst_rcompare.graphID11,row=1)

info.jwst_rcompare.info_label[0] = widget_label(sbase,$
                                 value =sinfo,/align_left,font=info.font5)

inspect_label = widget_button(sbase,value='Inspect',uvalue = 'inspect1')
; statistical information


; min and max scale of  image
r13_base = widget_base(info.jwst_rcompare.graphID11,row=1)
info.jwst_rcompare.image_recomputeID[0] = widget_button(r13_base,value=' Image Scale ',$
                                                font=info.font4,$
                                                uvalue = 'scale1') 


blank10 = '                '

info.jwst_rcompare.rlabelID[0,0] = cw_field(r13_base,title="min",font=info.font4,$
                                    uvalue="sr1_b",/float,/return_events,$
                                    xsize=xsize_label,$
                                    value =blank10,$
                                    fieldfont = info.font4)

info.jwst_rcompare.rlabelID[0,1] = cw_field(r13_base,title="max",font=info.font4,$
                                    uvalue="sr1_t",/float,/return_events,$
                                    xsize = xsize_label,value =blank10,$
                                   fieldfont=info.font4)


info.jwst_rcompare.graphID[0] = widget_draw(info.jwst_rcompare.graphID11,$
                                    xsize =info.jwst_rcompare.xplot_size,$ 
                                    ysize =info.jwst_rcompare.yplot_size,$
                                    /Button_Events,$
                                    retain=info.retn,uvalue='cpixel')

    

;*****

noref = widget_label(info.jwst_rcompare.graphID11,value='No reference Pixels included in stats',/align_left)
info.jwst_rcompare.sname = ['Mean:              ',$
                      'Standard Deviation ',$
                      'Median:            ',$
                      'Min:               ',$
                      'Max:               ']

info.jwst_rcompare.slabelID[0,0] = widget_label(info.jwst_rcompare.graphID11,value=info.jwst_rcompare.sname[0] +blank10,/align_left)
info.jwst_rcompare.slabelID[0,1] = widget_label(info.jwst_rcompare.graphID11,value=info.jwst_rcompare.sname[1] +blank10,/align_left)
info.jwst_rcompare.slabelID[0,2] = widget_label(info.jwst_rcompare.graphID11,value=info.jwst_rcompare.sname[2] +blank10,/align_left)
info.jwst_rcompare.slabelID[0,3] = widget_label(info.jwst_rcompare.graphID11,value=info.jwst_rcompare.sname[3] +blank10,/align_left)
info.jwst_rcompare.slabelID[0,4] = widget_label(info.jwst_rcompare.graphID11,value=info.jwst_rcompare.sname[4] +blank10,/align_left)

if(info.jwst_rcompare_image[0].type eq 2) then begin ; must have integrations to select
   moveframe_label = widget_label(info.jwst_rcompare.graphID11,value='Change Image 1 Displayed',$
                                  font=info.font5,/sunken_frame,/align_left)
   move_base1 = widget_base(info.jwst_rcompare.graphID11,row=1,/align_left)
   int1 = fix(info.jwst_rcompare_image[0].jintegration)
   info.jwst_rcompare.integration_label[0] = cw_field(move_base1,$
                                                      title="Integration # ",font=info.font5, $
                                                      uvalue="integ1i",/integer,/return_events, $
                                                      value=int1+1,xsize=4,$
                                                      fieldfont=info.font3)

   labelID = widget_button(move_base1,uvalue='integ1_move_dn',value='<',font=info.font3)
   labelID = widget_button(move_base1,uvalue='integ1_move_up',value='>',font=info.font3)

   nints= info.jwst_rcompare_image[0].nints
   tlabel = "Total # " + strcompress(string(nints),/remove_all)
   info.jwst_rcompare.total_ilabel[0] = widget_label( move_base1,value = tlabel,/align_left)

endif

;_______________________________________________________________________
;graph 1,2
;*****
sfile = info.jwst_rcompare_image[1].filename
sfind = strpos(sfile,'/',/reverse_search)
if(sfind gt 0) then begin
    len = strlen(sfile)
    onlyfile = strmid(sfile,sfind+1,len)
endif else begin
    onlyfile = sfile
endelse

sint = strtrim( string (fix(info.jwst_rcompare_image[1].jintegration+1)),2)
sinfo = ' Integration #      ' + sint
info.jwst_rcompare.filename_title[1] = widget_label(info.jwst_rcompare.graphID12,$
                                         value=onlyfile,/align_left,$
                                        font=info.font5)
graph_label = widget_label(info.jwst_rcompare.graphID12,$
                                         value=slabel_B,/align_left,$
                                        font=info.font5)
sbase = widget_base(info.jwst_rcompare.graphID12,row=1)
info.jwst_rcompare.info_label[1] = widget_label(sbase,$
                                 value =sinfo,/align_left,font=info.font5)
inspect_label = widget_button(sbase,value='Inspect',uvalue = 'inspect2')


; min and max scale of  image
r13_base = widget_base(info.jwst_rcompare.graphID12,row=1)
info.jwst_rcompare.image_recomputeID[1] = widget_button(r13_base,value=' Image Scale ',$
                                                font=info.font4,$
                                                uvalue = 'scale2')


info.jwst_rcompare.rlabelID[1,0] = cw_field(r13_base,title="min",font=info.font4,$
                                    uvalue="sr2_b",/float,/return_events,$
                                    xsize=xsize_label,$
                                    value =blank10,$
                                    fieldfont = info.font4)

info.jwst_rcompare.rlabelID[1,1] = cw_field(r13_base,title="max",font=info.font4,$
                                    uvalue="sr2_t",/float,/return_events,$
                                    xsize = xsize_label,value =blank10,$
                                   fieldfont=info.font4)


info.jwst_rcompare.graphID[1] = widget_draw(info.jwst_rcompare.graphID12,$
                                    xsize =info.jwst_rcompare.xplot_size,$ 
                                    ysize =info.jwst_rcompare.yplot_size,$
                                    /Button_Events,$
                                    retain=info.retn,uvalue='cpixel')
;_______________________________________________________________________
noref = widget_label(info.jwst_rcompare.graphID12,value='No reference Pixels included in stats',/align_left)

info.jwst_rcompare.slabelID[1,0] = widget_label(info.jwst_rcompare.graphID12,value=info.jwst_rcompare.sname[0] +blank10,/align_left)
info.jwst_rcompare.slabelID[1,1] = widget_label(info.jwst_rcompare.graphID12,value=info.jwst_rcompare.sname[1] +blank10,/align_left)
info.jwst_rcompare.slabelID[1,2] = widget_label(info.jwst_rcompare.graphID12,value=info.jwst_rcompare.sname[2] +blank10,/align_left)
info.jwst_rcompare.slabelID[1,3] = widget_label(info.jwst_rcompare.graphID12,value=info.jwst_rcompare.sname[3] +blank10,/align_left)
info.jwst_rcompare.slabelID[1,4] = widget_label(info.jwst_rcompare.graphID12,value=info.jwst_rcompare.sname[4] +blank10,/align_left)

if(info.jwst_rcompare_image[1].type eq 2) then begin ; the data is rate_int type and we can change the integration #
   moveframe_label = widget_label(info.jwst_rcompare.graphID12,value='Change Image 2 Displayed',$
                                  font=info.font5,/sunken_frame,/align_left)
   move_base1 = widget_base(info.jwst_rcompare.graphID12,row=1,/align_left)
   int1 = fix(info.jwst_rcompare_image[1].jintegration)
   info.jwst_rcompare.integration_label[1] = cw_field(move_base1,$
                                                      title="Integration # ",font=info.font5, $
                                                      uvalue="integ2i",/integer,/return_events, $
                                                      value=int1+1,xsize=4,$
                                                      fieldfont=info.font3)

   labelID = widget_button(move_base1,uvalue='integ2_move_dn',value='<',font=info.font3)
   labelID = widget_button(move_base1,uvalue='integ2_move_up',value='>',font=info.font3)

   nints = info.jwst_rcompare_image[1].nints
   tlabel = "Total # " + strcompress(string(nints),/remove_all)
   info.jwst_rcompare.total_ilabel[1] = widget_label( move_base1,value = tlabel,/align_left)

   ilabel = widget_label(info.jwst_rcompare.graphID12,value = ' Enter 0 for Combinded Rate Image',/align_left)
endif
load_label = widget_button(info.jwst_rcompare.graphID12,value='Load a Different Comparison Image',$
                                uvalue='loadnew')
;_______________________________________________________________________
;graph 1,3 - the difference plot

info.jwst_rcompare.compareoptions = ['Difference Images (A-B)', $
                  'Difference Images (B-A)', $
                  'Ratio Images (A/B)',$
                  'Ratio Images (B/A)',$
                  'Add Images (A+B) ']

    blank = widget_label(info.jwst_rcompare.graphID13,$
                         value='  ',/align_left,font=info.font5)
size_base = widget_base(info.jwst_rcompare.graphID13,row=1)
info.jwst_rcompare.compareID = widget_droplist(size_base,value=info.jwst_rcompare.compareoptions,$
                                       uvalue='compare',font=font4,/align_left)

inspect_label = widget_button(size_base,value='Inspect',uvalue = 'inspect3')

; min and max scale of  image
r13_base = widget_base(info.jwst_rcompare.graphID13,row=1)
info.jwst_rcompare.image_recomputeID[2] = widget_button(r13_base,value=' Image Scale',$
                                                font=info.font4,$
                                                uvalue = 'scale3')

info.jwst_rcompare.rlabelID[2,0] = cw_field(r13_base,title="min",font=info.font4,$
                                    uvalue="sr3_b",/float,/return_events,$
                                    xsize=xsize_label,$
                                    value =blank10,$
                                    fieldfont = info.font4)

info.jwst_rcompare.rlabelID[2,1] = cw_field(r13_base,title="max",font=info.font4,$
                                    uvalue="sr3_t",/float,/return_events,$
                                    xsize = xsize_label,value =blank10,$
                                   fieldfont=info.font4)

info.jwst_rcompare.graphID[2] = widget_draw(info.jwst_rcompare.graphID13,$
                                    xsize =info.jwst_rcompare.xplot_size,$ 
                                    ysize =info.jwst_rcompare.yplot_size,$
                                    /Button_Events,$
                                      retain=info.retn,uvalue='cpixel')

noref = widget_label(info.jwst_rcompare.graphID13,value='No reference Pixels included in stats',/align_left)

info.jwst_rcompare.slabelID[2,0] = widget_label(info.jwst_rcompare.graphID13,value=info.jwst_rcompare.sname[0] +blank10,/align_left)
info.jwst_rcompare.slabelID[2,1] = widget_label(info.jwst_rcompare.graphID13,value=info.jwst_rcompare.sname[1] +blank10,/align_left)
info.jwst_rcompare.slabelID[2,2] = widget_label(info.jwst_rcompare.graphID13,value=info.jwst_rcompare.sname[2] +blank10,/align_left)
info.jwst_rcompare.slabelID[2,3] = widget_label(info.jwst_rcompare.graphID13,value=info.jwst_rcompare.sname[3] +blank10,/align_left)
info.jwst_rcompare.slabelID[2,4] = widget_label(info.jwst_rcompare.graphID13,value=info.jwst_rcompare.sname[4] +blank10,/align_left)

;______________________________________________________________________


tlabelID = widget_label(info.jwst_rcompare.graphID13,$
          value="Information on Pixels for Images- Includes Border Pixels",/align_left, font=info.font5,$
                       /sunken_frame)

xvalue = fix(info.jwst_rcompare.x_pos*info.jwst_rcompare.binfactor)
yvalue = fix(info.jwst_rcompare.y_pos*info.jwst_rcompare.binfactor)

; button to change 
pix_num_base = widget_base(info.jwst_rcompare.graphID13,row=1,/align_left)
labelID = widget_button(pix_num_base,uvalue='pix_move_x1',value='<',font=info.font3)
labelID = widget_button(pix_num_base,uvalue='pix_move_x2',value='>',font=info.font3)

info.jwst_rcompare.pix_label[0] = cw_field(pix_num_base,title="x",font=info.font4, $
                                   uvalue="pix_x_val",/integer,/return_events, $
                                   value=xvalue+1,xsize=6,$
                                   fieldfont=info.font3)

info.jwst_rcompare.pix_label[1] = cw_field(pix_num_base,title="y",font=info.font4, $
                                   uvalue="pix_y_val",/integer,/return_events, $
                                   value=yvalue+1,xsize=6,$
                                   fieldfont=info.font3)

labelID = widget_button(pix_num_base,uvalue='pix_move_y1',value='<',font=info.font3)
labelID = widget_button(pix_num_base,uvalue='pix_move_y2',value='>',font=info.font3)


pix_statlabel = strarr(3)
pixel_statformat = strarr(3)

pix_statLabel = [" Image Value 1", " Image Value 2", " Compare Value"]
pix_statFormat = ["F16.8","F16.8","F16.8"]

pix_statLabelID = lonarr(3)

svalue1 = pix_statLabel[0]+' = '+ blank10
svalue1 = pix_statLabel[1]+' = '+ blank10
svalue1 = pix_statLabel[2]+' = '+ blank10
pix_statLabelID[0] = widget_label(info.jwst_rcompare.graphID13,$
                                 value=svalue1,/dynamic_resize,/align_left)
pix_statLabelID[1] = widget_label(info.jwst_rcompare.graphID13,$
                                  value=svalue2,/dynamic_resize,/align_left)
pix_statLabelID[2] = widget_label(info.jwst_rcompare.graphID13,$
                                  value=svalue3,/dynamic_resize,/align_left)
                                             

info.jwst_rcompare.pix_statLabelID = pix_statLabelID
info.jwst_rcompare.pix_statLabel = pix_statLabel 
info.jwst_rcompare.pix_statFormat = pix_statFormat
;_______________________________________________________________________

;Set up the GUI
Widget_control,info.jwst_RCompareDisplay,/Realize
XManager,'jwst_msql_compare',info.jwst_RCompareDisplay,/No_Block,$
        event_handler='jwst_msql_compare_display_event'    
longline = '                                                                                                                        '
longtag = widget_label(info.jwst_RcompareDisplay,value = longline)
; realize main panel


; get the window ids of the draw windows

for i = 0,2 do begin
    widget_control,info.jwst_rcompare.graphID[i],get_value=tdraw_id
    info.jwst_rcompare.draw_window_id[i] = tdraw_id
    window,/pixmap,xsize=info.jwst_rcompare.xplot_size,ysize=info.jwst_rcompare.yplot_size,/free
    info.jwst_rcompare.pixmapID[i] = !D.WINDOW
endfor


; load the first image into the graph windows
for i = 0,2 do begin
    jwst_msql_compare_update_images,info,i
endfor

jwst_msql_compare_update_pixel_location,info
jwst_msql_compare_update_pixel_info,info

Widget_Control,info.jwst_QuickLook,Set_UValue=info
sinfo = {info        : info}

Widget_Control,info.jwst_RcompareDisplay,Set_UValue=sinfo
Widget_Control,info.jwst_QuickLook,Set_UValue=info

progressBar -> Destroy
obj_destroy, progressBar
end






