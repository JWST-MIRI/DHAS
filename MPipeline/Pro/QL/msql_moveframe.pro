pro msql_moveframe,info


; If integration update to followingplots (if the widget is up);
; From main msql window: slope image, zoom image, and uncertainty
; If inspect science image is up - update.
; All other minor plots kill: histogram, column slice, row slice 
;_______________________________________________________________________
; Integration Button


; 1. update main display images
; 2. clean up extra widgets that might of been openned - histogram, inspect, ect.
; 3. update plots

;____________________
; kill single widget plots 
    
msql_cleanup_widgets,info
 
jintegration = info.slope.integrationNO

read_single_slope,info.control.filename_slope,slope_exists,$
                  info.slope.integrationNO,subarray,slopedata,$
                  slope_xsize,slope_ysize,slope_zsize,stats,status,$
                  error_message

if ptr_valid (info.data.pslopedata) then ptr_free,info.data.pslopedata
info.data.pslopedata = ptr_new(slopedata)

info.data.slope_stat = stats
slopedata = 0
stats = 0


msql_update_slope,info.slope.plane[0],0,info
msql_update_slope,info.slope.plane[2],2,info
msql_update_zoom_image,info

info.slope.int_range[*] = jintegration+1
widget_control,info.slope.IrangeID[0],set_value=info.slope.int_range[0]
widget_control,info.slope.IrangeID[1],set_value=info.slope.int_range[1]

msql_update_rampread,info
msql_update_pixel_stat_slope,info

widget_control,info.slope.integration_label,set_value= fix(jintegration+1)
Widget_Control,info.QuickLook,Set_UValue=info	
;____________________

        
; if inspect images open then update
if(XRegistered ('misql')) then begin
    misql_update_images,info
    misql_update_pixel_location,info
    Widget_Control,info.QuickLook,Set_UValue=info
endif
    

;_______________________________________________________________________


Widget_Control,info.QuickLook,Set_UValue=info


end


