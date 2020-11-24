pro jwst_msql_moveframe,info,win


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
 
jintegration = info.jwst_slope.integrationNO[win]
data_type = info.jwst_slope.data_type[win]

if(data_type eq 1) then begin 
   jwst_read_final_slope,info.jwst_control.filename_slope,slope_exists,$
                         info.jwst_data.subarray,slopedata,$
                         slope_xsize,slope_ysize,$
                         stats,$
                         status,$
                         error_message
endif else begin 
   jwst_read_single_slope,info.jwst_control.filename_slope_int,slope_exists,$
                          info.jwst_slope.integrationNO[win],$
                          subarray,slopedata,$
                          slope_xsize,slope_ysize,$
                          stats,$
                          status,$
                          error_message
endelse

if(win eq 0) then begin
   if ptr_valid (info.jwst_data.prate1) then ptr_free,info.jwst_data.prate1
   info.jwst_data.prate1 = ptr_new(slopedata)
   info.jwst_data.rate1_stat = stats
   jwst_msql_update_slope,0,info
   widget_control,info.jwst_slope.integration_label[0],set_value= fix(jintegration+1)
endif

if(win eq 1) then begin
   if ptr_valid (info.jwst_data.prate2) then ptr_free,info.jwst_data.prate2
   info.jwst_data.prate2 = ptr_new(slopedata)
   info.jwst_data.rate2_stat = stats
   jwst_msql_update_slope,1,info
   widget_control,info.jwst_slope.integration_label[1],set_value= fix(jintegration+1)
endif

slopedata = 0
stats = 0

jwst_msql_update_zoom_image,info
jwst_msql_update_pixel_stat_slope,info


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


