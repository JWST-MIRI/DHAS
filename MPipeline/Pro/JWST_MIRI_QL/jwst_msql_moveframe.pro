pro jwst_msql_moveframe,info


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
    
jwst_msql_cleanup_widgets,info
 
jintegration = info.jwst_slope.integrationNO

jwst_read_single_slope,info.jwst_control.filename_slope_int,slope_exists,$
                       info.jwst_slope.integrationNO,$
                       subarray,slopedata,$
                       slope_xsize,slope_ysize,$
                       stats,$
                       status,$
                       error_message

if ptr_valid (info.jwst_data.prateint) then ptr_free,info.jwst_data.prateint
info.jwst_data.prateint = ptr_new(slopedata)

if(info.jwst_slope.plane[0] eq 3) then begin ; update this rate int 
   info.jwst_data.rateint_stat = stats
   jwst_msql_update_slope,info.jwst_slope.plane[0],0,info
endif

if(info.jwst_slope.plane[1] eq 3) then begin ; update this rate int 
   info.jwst_data.rateint_stat = stats
   jwst_msql_update_slope,info.jwst_slope.plane[1],1,info
endif

slopedata = 0
stats = 0

jwst_msql_update_zoom_image,info

;info.jwst_slope.int_range[*] = jintegration+1
;widget_control,info.jwst_slope.IrangeID[0],set_value=info.jwst_slope.int_range[0]
;widget_control,info.jwst_slope.IrangeID[1],set_value=info.jwst_slope.int_range[1]

jwst_msql_update_pixel_stat_slope,info

widget_control,info.jwst_slope.integration_label,set_value= fix(jintegration+1)
Widget_Control,info.jwst_QuickLook,Set_UValue=info	
;____________________

        
; if inspect images open then update
if(XRegistered ('misql')) then begin
    jwst_misql_update_images,info
    jwst_misql_update_pixel_location,info
    Widget_Control,info.jwst_QuickLook,Set_UValue=info
endif
    

Widget_Control,info.jwst_QuickLook,Set_UValue=info


end


