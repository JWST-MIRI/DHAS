pro msql_event,event

Widget_Control,event.id,Get_uValue=event_name
widget_control,event.top, Get_UValue = ginfo	
widget_control,ginfo.info.QuickLook,Get_Uvalue = info
;print,' msql  event name: ',event_name

jintegration = info.slope.integrationNO

if (widget_info(event.id,/TLB_SIZE_EVENTS) eq 1 ) then begin
    info.slope.xwindowsize = event.x
    info.slope.ywindowsize = event.y
    info.slope.uwindowsize = 1
    widget_control,event.top,set_uvalue = ginfo
    widget_control,ginfo.info.Quicklook,set_uvalue = info
    msql_display_slope,info
    return
endif

    case 1 of

;_______________________________________________________________________
; Display statistics on the image 
;_______________________________________________________________________
    (strmid(event_name,0,4) EQ 'Stat') : begin
	msql_display_stat,info
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end

;_______________________________________________________________________
; Display Frames
;_______________________________________________________________________
    (strmid(event_name,0,5) EQ 'frame') : begin
        info.image.integrationNO = info.slope.integrationNO
        info.image.rampNO = info.control.frame_start_save
        info.control.int_num = info.slope.integrationNO
        info.image.x_pos = info.slope.x_pos
        info.image.y_pos = info.slope.y_pos


        setup_frame_image_StepA,info


        info.image.overplot_slope = 1 
        info.image.start_fit = info.slope.start_fit
        info.image.end_fit = info.slope.end_fit
        info.image.frame_time = info.slope.frame_time


        slopedata = (*info.data.pslopedata)

        if ptr_valid (info.data.preduced) then ptr_free,info.data.preduced
        info.data.preduced = ptr_new(slopedata)

        info.data.reduced_stat =         info.data.slope_stat 

        find_image_binfactor,info
        xvalue = info.image.x_pos * info.image.binfactor
        yvalue = info.image.y_pos * info.image.binfactor

        setup_frame_pixelvalues,info
        mql_read_slopedata,xvalue,yvalue,info
 
	mql_display_images,info
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end
;_______________________________________________________________________
; slope header

    (strmid(event_name,0,7) EQ 'sheader') : begin
        j = info.slope.IntegrationNO
        display_header,info,j+1
    end

; calibrated header 
    (strmid(event_name,0,7) EQ 'cheader') : begin
        if(not info.data.cal_exist) then begin
            ok = dialog_message(" No calibration image exists",/Information)
        endif else begin
            j = info.slope.IntegrationNO
            display_header,info,info.data.nslopes+j+1
        endelse

    end
;_______________________________________________________________________
    (strmid(event_name,0,7) EQ 'compare') : begin
        info.rcompare.uwindowsize = 0
        info.crinspect[*].uwindowsize = 1

        image_file = dialog_pickfile(/read,$
                                     get_path=realpath,Path=info.control.dir,$
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
            result = dialog_message(" The file does not exist "+ filename,/error )
            print,'Image file does not exist'
            ok = dialog_message(" Image File does not exist, select filename again",/Information)
            status = 1
            return
        endif

        info.rcompare_image[0].filename  = info.control.filename_slope
        info.rcompare_image[1].filename  = filename


        read_data_type,info.rcompare_image[1].filename,type

        if(type eq 7) then type = 1
        if(type ne 1) then begin 
            error = dialog_message(" The file must be a reduced science file, select file again",/error)
            return
        endif

        info.rcompare_image[0].jintegration = info.slope.integrationNO
        info.rcompare_image[1].jintegration = info.slope.integrationNO

        info.rcompare_image[0].plane = info.slope.plane[0]
        info.rcompare_image[1].plane = info.slope.plane[0]
	msql_compare_display,info
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end


;_______________________________________________________________________
; Compare current frame to another frame 
    (strmid(event_name,0,8) EQ 'fcompare') : begin

        info.rcompare.uwindowsize = 0
        info.crinspect[*].uwindowsize = 1
        this_int = event.value-1

        if(this_int lt -1) then this_int = -1 ; primary image 

        if(this_int gt info.data.nints-1  ) then this_int = 0 ; wrap


        if(info.slope.plane[0] gt 2 and this_int eq -1) then begin

            if(info.slope.plane[0] eq 3) then slabela = " Zero Pt of fit"
            if(info.slope.plane[0] eq 4) then slabela = " # of Good Reads"
            if(info.slope.plane[0] eq 5) then slabela = " Read # of 1st Sat Frame"
            if(info.slope.plane[0] eq 6) then slabela = " # of good segments"
            if(info.slope.plane[0] eq 7) then slabela = " Emperical Uncer"
            if(info.slope.plane[0] eq 8) then slabela = " Max 2pt diff"
            if(info.slope.plane[0] eq 9) then slabela = " Frame # Max 2pt diff"
            if(info.slope.plane[0] eq 10) then slabela = " STDEV 2pt diff"
            if(info.slope.plane[0] eq 11) then slabela = " Slope 2pt diff"            

            mess = " The " + slabela+ " plane, is not in the final averaged result. The first image must be " +$
                   " the slope, uncertainty or data quality flag in order to compare to the final average result"
            result = dialog_message(mess,/error)
            return
        endif

        info.rcompare_image[0].filename  = info.control.filename_slope
        info.rcompare_image[1].filename  = info.control.filename_slope
        info.rcompare_image[0].jintegration = info.slope.integrationNO 
        info.rcompare_image[1].jintegration = fix(this_int)
        info.rcompare_image[0].plane = info.slope.plane[0]
        info.rcompare_image[1].plane = info.slope.plane[0]

	msql_compare_display,info
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end


    
;_______________________________________________________________________
; channel plots
    (strmid(event_name,0,7) EQ 'channel') : begin
        
        status = 0
        setup_SlopeChannel,info,info.slope.integrationNO,status,error_message
        if(status ne 0) then begin 
            ok = dialog_message(error_message,/Information)
            return
        endif
        info.Slopechannel.uwindowsize = 0
        mql_display_SlopeChannel,info

    end
;_______________________________________________________________________
; print

    (strmid(event_name,0,5) EQ 'print') : begin
        if(strmid(event_name,6,1) eq 'S') then type = 0
        if(strmid(event_name,6,1) eq 'Z') then type = 1
        if(strmid(event_name,6,1) eq 'U') then type = 2
        if(strmid(event_name,6,1) eq 'P') then type = 3
        if(strmid(event_name,6,1) eq 'E') then type = 4 

        print_slope_images,info,type
    end
;_______________________________________________________________________
; inspect image
    (strmid(event_name,0,7) EQ 'inspect') : begin
        if(not info.data.slope_exist) then begin
            ok = dialog_message(" No slope image exists",/Information)
            return
        endif
        type = fix(strmid(event_name,8,1))
	if(type eq 1) then begin 

            i = info.slope.integrationNO
            info.inspect_slope.integrationNO = info.slope.integrationNO
            frame_image = fltarr(info.data.slope_xsize,info.data.slope_ysize)
            if(info.slope.plane[0]  eq info.slope.plane_cal) then begin 
                frame_image[*,*] = (*info.data.pcaldata)[*,*,0]
            endif else begin
                frame_image[*,*] = (*info.data.pslopedata)[*,*,info.slope.plane[0]]
            endelse
            if ptr_valid (info.inspect_slope.pdata) then ptr_free,info.inspect_slope.pdata
            info.inspect_slope.pdata = ptr_new(frame_image)
            frame_image = 0


            all_data = (*info.data.pslopedata)
            if ptr_valid (info.inspect_slope.preduced) then ptr_free,info.inspect_slope.preduced
            info.inspect_slope.preduced = ptr_new(all_data)
            all_data = 0

            if(info.data.cal_exist) then begin 
                cal = (*info.data.pcaldata)[*,*,0]
                if ptr_valid (info.inspect_slope.pcaldata) then ptr_free,info.inspect_slope.pcaldata
                info.inspect_slope.pcaldata = ptr_new(cal)
                cal = 0
            endif


            Widget_Control,ginfo.info.QuickLook,Set_UValue=info
            info.inspect_slope.plane = info.slope.plane[0]

            info.inspect_slope.zoom = 1
            info.inspect_slope.zoom_x = 1
            info.inspect_slope.x_pos =(info.data.slope_xsize)/2.0
            info.inspect_slope.y_pos = (info.data.slope_ysize)/2.0
            
            info.inspect_slope.xposful = info.inspect_slope.x_pos
            info.inspect_slope.yposful = info.inspect_slope.y_pos

            info.inspect_slope.start_fit = info.slope.start_fit
            info.inspect_slope.end_fit = info.slope.end_fit


            info.inspect_slope.limit_low = -5000.0
            info.inspect_slope.limit_high = 70000.0
            info.inspect_slope.limit_low_num = 0
            info.inspect_slope.limit_high_num = 0
            info.inspect_slope.graph_range[0] = info.slope.graph_range[0,0]
            info.inspect_slope.graph_range[1] = info.slope.graph_range[0,1]
            info.inspect_slope.default_scale_graph = info.slope.default_scale_graph[0]
            misql_display_images,info
            Widget_Control,ginfo.info.QuickLook,Set_UValue=info

        endif
	if(type eq 3) then  begin

            i = info.slope.integrationNO
            info.inspect_slope2.integrationNO = info.slope.integrationNO
            info.inspect_slope2.start_fit = info.slope.start_fit
            info.inspect_slope2.end_fit = info.slope.end_fit
            frame_image = fltarr(info.data.slope_xsize,info.data.slope_ysize)
            if(info.slope.plane[2] eq info.slope.plane_cal) then begin 
                frame_image[*,*] = (*info.data.pcaldata)[*,*,0]
            endif else begin
                frame_image[*,*] = (*info.data.pslopedata)[*,*,info.slope.plane[2]]
            endelse


            if ptr_valid (info.inspect_slope2.pdata) then ptr_free,info.inspect_slope2.pdata
            info.inspect_slope2.pdata = ptr_new(frame_image)
            frame_image = 0

            all_data = (*info.data.pslopedata)
            if ptr_valid (info.inspect_slope2.preduced) then ptr_free,info.inspect_slope2.preduced
            info.inspect_slope2.preduced = ptr_new(all_data)
            all_data = 0

            if(info.data.cal_exist) then begin 
                cal = (*info.data.pcaldata)[*,*,0]
                if ptr_valid (info.inspect_slope2.pcaldata) then ptr_free,info.inspect_slope2.pcaldata
                info.inspect_slope2.pcaldata = ptr_new(cal)
                cal = 0
            endif

            info.inspect_slope2.plane = info.slope.plane[2]
            info.inspect_slope2.zoom = 1
            info.inspect_slope2.zoom_x = 1
            info.inspect_slope2.x_pos =(info.data.slope_xsize)/2.0
            info.inspect_slope2.y_pos = (info.data.slope_ysize)/2.0

            info.inspect_slope2.xposful = info.inspect_slope.x_pos
            info.inspect_slope2.yposful = info.inspect_slope.y_pos

            info.inspect_slope2.graph_range[0] = 0.0
            info.inspect_slope2.graph_range[1] = 0.0
            info.inspect_slope2.limit_low = -5000.0
            info.inspect_slope2.limit_high = 70000.0
            info.inspect_slope2.limit_low_num = 0
            info.inspect_slope2.limit_high_num = 0
            info.inspect_slope2.graph_range[0] = info.slope.graph_range[2,0]
            info.inspect_slope2.graph_range[1] = info.slope.graph_range[2,1]
            info.inspect_slope2.default_scale_graph = info.slope.default_scale_graph[2]

            Widget_Control,ginfo.info.QuickLook,Set_UValue=info
            misql2_display_images,info
        endif
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end


;_______________________________________________________________________
; inspect image
    (strmid(event_name,0,13) EQ 'final_inspect') : begin
        
       
        info.inspect_final.integrationNO = -1
        read_single_slope,info.control.filename_slope,slope_exists,$
                          -1,subarray,slopedata,$
                          slope_xsize,slope_ysize,slope_zsize,stats,status,$
                          error_message

        
        if ptr_valid (info.inspect_final.pdata) then ptr_free,info.inspect_final.pdata
        info.inspect_final.pdata = ptr_new(slopedata)
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info

        info.inspect_final.default_scale_graph = 1
        info.inspect_final.zoom = 1
        info.inspect_final.zoom_x = 1
        info.inspect_final.x_pos =(info.data.slope_xsize)/2.0
        info.inspect_final.y_pos = (info.data.slope_ysize)/2.0
        
        info.inspect_final.xposful = info.inspect_slope.x_pos
        info.inspect_final.yposful = info.inspect_slope.y_pos
        
        info.inspect_final.graph_range[0] = 0.0
        info.inspect_final.graph_range[1] = 0.0
        info.inspect_final.limit_low = -5000.0
        info.inspect_final.limit_high = 70000.0
        info.inspect_final.limit_low_num = 0
        info.inspect_final.limit_high_num = 0
        misfql_display_images,info
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info

    end
;_______________________________________________________________________
; Change the Integration #  of image displayed
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


; do some checks - wrap around if necessary
        if(jintegration lt 0) then begin
            jintegration = info.data.nints-1
        endif
        if(jintegration gt info.data.nints-1  ) then begin
            jintegration = 0
        endif

        widget_control,info.slope.integration_label,set_value = jintegration+1
        info.slope.integrationNO = jintegration
        msql_moveframe,info
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end


;_______________________________________________________________________
; clicked on images - update pixel information

   (strmid(event_name,0,6) EQ 'spixel') : begin
       if(event.type eq 1) then begin
           graphnum = fix(strmid(event_name,6,1))
           info.slope.plane[1] = info.slope.plane[graphnum-1]

           xvalue = event.x     ; starts at 0
           yvalue = event.y     ; starts at 0
; did not click on zoom image- so update the zoom image
           if(graphnum ne 2) then  begin 
               info.slope.zoom_window = graphnum
               info.slope.x_zoom = xvalue * info.slope.binfactor
               info.slope.y_zoom = yvalue * info.slope.binfactor

               msql_update_zoom_image,info

               info.slope.x_pos = xvalue 
               info.slope.y_pos = yvalue 
           endif

; clicked on the zoom image - so update the pixel in the zoom image 
           if(graphnum eq 2) then  begin
;;;
               x = (xvalue)/info.slope.scale_zoom
               y = (yvalue)/info.slope.scale_zoom
               if(x gt info.data.slope_xsize) then x = info.data.slope_xsize-1
               if(y gt info.data.slope_ysize) then y = info.data.slope_ysize-1
               xvalue = x * info.slope.scale_zoom
               yvalue = y * info.slope.scale_zoom
;;;
               msql_update_zoom_pixel_location,xvalue,yvalue,info

               ; redefine the center of the zoom image - if later
               ; want to zoom 

               x = (xvalue)/info.slope.scale_zoom
               y = (yvalue)/info.slope.scale_zoom
               x = x + info.slope.x_zoom_start - info.slope.ixstart_zoom
               y = y + info.slope.y_zoom_start - info.slope.iystart_zoom

               if(x gt info.data.slope_xsize) then x = info.data.slope_xsize-1
               if(y gt info.data.slope_ysize) then y = info.data.slope_ysize-1


               info.slope.x_zoom_pos = x
               info.slope.y_zoom_pos = y


           endif
; update the pixel locations in graphs 1, 3
           graphno = [0,2]
           for i = 0,1 do begin 
               info.slope.current_graph = graphno[i]
               msql_update_pixel_location,info
           endfor

           ; set current graph to the one clicked on
           if(graphnum eq 1) then info.slope.current_graph = 0
           if(graphnum eq 3) then info.slope.current_graph = 2


           msql_update_pixel_stat_slope,info

	   x = info.slope.x_pos * info.slope.binfactor	
	   y = info.slope.y_pos * info.slope.binfactor	
	   widget_control,info.slope.pix_label[0],set_value = x+1
	   widget_control,info.slope.pix_label[1],set_value = y+1


; Draw a box around the pixel - showing the zoom window size 
           if(info.slope.zoom_window ne 2) then  begin ;
               msql_draw_zoom_box,info
           endif

; load individual ramp graph - based on x_pos, y_pos
           x = info.slope.x_pos * info.slope.binfactor	
           y = info.slope.y_pos * info.slope.binfactor

           if(info.slope.autopixelupdate eq 1) then begin 
               msql_read_rampdata,x,y,pixeldata,info
               if ptr_valid (info.slope.pixeldata) then ptr_free,info.slope.pixeldata
               info.slope.pixeldata = ptr_new(pixeldata)
           endif
           msql_read_slopedata,x,y,info


; if refecorrection file exist
           if(info.control.file_refcorrection_exist eq 1 and $
              info.slope.overplot_reference_corrected eq 1 and $
             info.slope.autopixelupdate eq 1) then  $
             msql_read_refcorrected_data,x,y,info

; fill in the frame IDS, if the file was written
        if(info.control.file_ids_exist eq 1 and $
           info.slope.overplot_cr and $
          info.slope.autopixelupdate eq 1 ) then $
            msql_read_id_data,x,y,info

; fill in the linearity corrected data, if the file was written
        if(info.control.file_lc_exist eq 1 and $
           info.slope.overplot_lc and $
          info.slope.autopixelupdate eq 1 ) then $
            msql_read_lc_data,x,y,info

; fill in the mean  dark corrected data, if the file was written
        if(info.control.file_mdc_exist eq 1 and $
           info.slope.overplot_mdc and $
          info.slope.autopixelupdate eq 1 ) then $
            msql_read_mdc_data,x,y,info

; fill in the reset corrected data, if the file was written
        if(info.control.file_reset_exist eq 1 and $
           info.slope.overplot_reset and $
          info.slope.autopixelupdate eq 1 ) then $
            msql_read_reset_data,x,y,info

; fill in the rscd corrected data, if the file was written
        if(info.control.file_rscd_exist eq 1 and $
           info.slope.overplot_rscd and $
          info.slope.autopixelupdate eq 1 ) then $
            msql_read_rscd_data,x,y,info

; fill in the lastframe corrected data, if the file was written
        if(info.control.file_lastframe_exist eq 1 and $
           info.slope.overplot_lastframe and $
          info.slope.autopixelupdate eq 1 ) then $
            msql_read_lastframe_data,x,y,info


; update ramp plot for pixel
           msql_update_rampread,info                          
           msql_update_slopepixel,info

; If the Frame values for pixel window is open - update
           if(XRegistered ('mpixel')) then begin
               widget_control,info.RPixelInfo,/destroy

           endif

           Widget_Control,ginfo.info.QuickLook,Set_UValue=info
       endif
   end
;_______________________________________________________________________
   
   (strmid(event_name,0,8) EQ 'getframe') : begin
	x = info.slope.x_pos * info.slope.binfactor
	y = info.slope.y_pos * info.slope.binfactor

        ; check and see if read in all frame values for pixel
        ; if not then read in

        pixeldata = (*info.slope.pixeldata)

        size_data = size(pixeldata)
        if(size_data[0] eq 0) then return

        if ptr_valid (info.image_pixel.pixeldata) then ptr_free,info.image_pixel.pixeldata
        info.image_pixel.pixeldata = ptr_new(pixeldata)

; reference corrected data
        refcorrected_data = pixeldata
        refcorrected_data[*,*] = 0 
        id_data = refcorrected_data
        lc_data = refcorrected_data

        if(info.control.file_refcorrection_exist eq 1) then  begin
            refcorrected_data = (*info.slope.prefcorrected_pixeldata)
        endif
        if ptr_valid (info.image_pixel.refcorrected_pixeldata) then $
          ptr_free,info.image_pixel.refcorrected_pixeldata
        info.image_pixel.refcorrected_pixeldata = ptr_new(refcorrected_data)        

; fill in the frame IDS, if the file was written
        if(info.control.file_ids_exist eq 1) then begin 
            id_data = (*info.slope.pid_pixeldata)
        endif
        if ptr_valid (info.image_pixel.id_pixeldata) then $
          ptr_free,info.image_pixel.id_pixeldata
        info.image_pixel.id_pixeldata = ptr_new(id_data)        

; fill in linearity corrected, if the file was written
        if(info.control.file_lc_exist eq 1) then begin 
            lc_data = (*info.slope.plc_pixeldata)
        endif

        if ptr_valid (info.image_pixel.lc_pixeldata) then $
          ptr_free,info.image_pixel.lc_pixeldata
        info.image_pixel.lc_pixeldata = ptr_new(lc_data)        

; fill in the dark corrected data, if the file was written

        if(info.control.file_mdc_exist eq 1) then begin
            if (ptr_valid(info.slope.pmdc_pixeldata) eq 0) then begin ; has not been read in 
                msql_read_mdc_data,x,y,info
            endif
 
            mdc_data = (*info.slope.pmdc_pixeldata)

            if ptr_valid (info.image_pixel.mdc_pixeldata) then $
              ptr_free,info.image_pixel.mdc_pixeldata
            info.image_pixel.mdc_pixeldata = ptr_new(mdc_data)
            
            mdc_data = 0
         endif


; fill in the rscd corrected data, if the file was written

        if(info.control.file_rscd_exist eq 1) then begin
            if (ptr_valid(info.slope.prscd_pixeldata) eq 0) then begin ; has not been read in 
                msql_read_rscd_data,x,y,info
            endif
            rscd_data = (*info.slope.prscd_pixeldata)
            if ptr_valid (info.image_pixel.rscd_pixeldata) then $
              ptr_free,info.image_pixel.rscd_pixeldata
            info.image_pixel.rscd_pixeldata = ptr_new(rscd_data)
            rscd_data = 0
         endif

; fill in the lastframe corrected data, if the file was written

        if(info.control.file_lastframe_exist eq 1) then begin
            if (ptr_valid(info.slope.plastframe_pixeldata) eq 0) then begin ; has not been read in 
                msql_read_lastframe_data,x,y,info
            endif
            lastframe_data = (*info.slope.plastframe_pixeldata)
            if ptr_valid (info.image_pixel.lastframe_pixeldata) then $
              ptr_free,info.image_pixel.lastframe_pixeldata
            info.image_pixel.lastframe_pixeldata = ptr_new(lastframe_data)
            lastframe_data = 0
         endif



        ref_pixeldata = fltarr(info.data.nints,info.data.nramps,1)
        get_ref_pixeldata,info,1,x,y,ref_pixeldata
        if ptr_valid (info.image_pixel.ref_pixeldata) then $
          ptr_free,info.image_pixel.ref_pixeldata
        info.image_pixel.ref_pixeldata = ptr_new(ref_pixeldata)

        info.image_pixel.file_ids_exist = info.control.file_ids_exist
        info.image_pixel.file_lc_exist = info.control.file_lc_exist
        info.image_pixel.file_refcorrection_exist  =  info.control.file_refcorrection_exist 
        info.image_pixel.file_mdc_exist  = info.control.file_mdc_exist 
        info.image_pixel.file_reset_exist  = info.control.file_reset_exist 
        info.image_pixel.file_rscd_exist  = info.control.file_rscd_exist 
        info.image_pixel.file_lastframe_exist  = info.control.file_lastframe_exist 


        info.image_pixel.start_fit = info.slope.start_fit
        info.image_pixel.end_fit = info.slope.end_fit
        info.image_pixel.nints = info.data.nints
        info.image_pixel.integrationNo = info.slope.integrationNO
        info.image_pixel.nframes = info.data.nramps
        info.image_pixel.nslopes = info.data.nslopes
        info.image_pixel.slope_exist = info.data.slope_exist
        info.image_pixel.slope = (*info.data.pslopedata)[x,y,0]

        if(info.data.slope_zsize eq 2 or info.data.slope_zsize eq 3) then begin
            info.image_pixel.zeropt =  (*info.data.pslopedata)[x,y,1]
            info.image_pixel.uncertainty  =0
            info.image_pixel.quality_flag = 0
            info.image_pixel.ngood =  0
            info.image_pixel.nframesat = 0
            info.image_pixel.ngoodseg = 0
        endif else begin 
            info.image_pixel.uncertainty  = (*info.data.pslopedata)[x,y,1]
            info.image_pixel.quality_flag =  (*info.data.pslopedata)[x,y,2]
            info.image_pixel.zeropt =  (*info.data.pslopedata)[x,y,3]
            info.image_pixel.ngood =  (*info.data.pslopedata)[x,y,4]
            info.image_pixel.nframesat =  (*info.data.pslopedata)[x,y,5]
            info.image_pixel.ngoodseg = 0
            info.image_pixel.filename = info.control.filename_slope
            info.image_pixel.ngoodseg =  (*info.data.pslopedata)[x,y,6]
        endelse


	display_frame_values,x,y,info,0
    end
;_______________________________________________________________________
    (strmid(event_name,0,8) EQ 'datainfo') : begin


        data_id ='ID flag '+ strcompress(string(info.dqflag.Unusable),/remove_all) +  ' = ' + info.dqflag.Sunusable +  string(10b) + $
                 'ID flag '+ strcompress(string(info.dqflag.Saturated),/remove_all) +  ' = ' + info.dqflag.SSaturated +  string(10b) + $
                 'ID flag '+ strcompress(string(info.dqflag.CosmicRay),/remove_all) +  ' = ' + info.dqflag.SCosmicRay +  string(10b) + $
                 'ID flag '+ strcompress(string(info.dqflag.NoiseSpike),/remove_all) +  ' = ' + info.dqflag.SNoiseSpike +  string(10b) + $
                 'ID flag '+ strcompress(string(info.dqflag.NegCosmicRay),/remove_all) +  ' = ' + info.dqflag.SNegCosmicRay +  string(10b) + $
                 'ID flag '+ strcompress(string(info.dqflag.NoReset),/remove_all) +  ' = ' + info.dqflag.SNoReset +  string(10b) + $
                 'ID flag '+ strcompress(string(info.dqflag.NoDark),/remove_all) +  ' = ' + info.dqflag.SNoDark +  string(10b) + $
                 'ID flag '+ strcompress(string(info.dqflag.NoLin),/remove_all) +  ' = ' + info.dqflag.SNoLin +  string(10b) + $
;                 'ID flag '+ strcompress(string(info.dqflag.OutLinRange),/remove_all) +  ' = ' + info.dqflag.SOutLinRange +  string(10b) + $
                 'ID flag '+ strcompress(string(info.dqflag.NoLastFrame),/remove_all) +  ' = ' + info.dqflag.SNoLastFrame +  string(10b) + $ 
                 'ID flag '+ strcompress(string(info.dqflag.Min_Frame_Failure),/remove_all) +  ' = ' + info.dqflag.SMin_Frame_Failure +  string(10b) 


        result = dialog_message(data_id,/information)
    end
;_______________________________________________________________________
; scaling images
;_______________________________________________________________________
    (strmid(event_name,0,5) EQ 'scale') : begin

        graphno = fix(strmid(event_name,5,1))
        if(info.slope.default_scale_graph[graphno-1] eq 0 ) then begin ; true - turn to false
            widget_control,info.slope.image_recomputeID[graphno-1],set_value=' Image Scale '
            info.slope.default_scale_graph[graphno-1] = 1
        endif

	if(graphno eq 1)then  $
        msql_update_slope,info.slope.plane[0],0,info
	if(graphno eq 2)then  $
        msql_update_zoom_image,info
	if(graphno eq 3)then  $
        msql_update_slope,info.slope.plane[2],2,info
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end

;_______________________________________________________________________
; change range of image graphs
; if change range then also change the scale button to 'Default Set
; Scale'
;_______________________________________________________________________
    (strmid(event_name,0,2) EQ 'cr') : begin
        graph_num = fix(strmid(event_name,2,1))
        
        if(strmid(event_name,4,1) EQ 'b') then begin ;bottom
            info.slope.graph_range[graph_num-1,0] = event.value
            widget_control,info.slope.rlabelID[graph_num-1,1],get_value = temp
            info.slope.graph_range[graph_num-1,1] = temp
        endif
        if(strmid(event_name,4,1) EQ 't') then begin ;top
            info.slope.graph_range[graph_num-1,1] = event.value
            widget_control,info.slope.rlabelID[graph_num-1,0],get_value = temp
            info.slope.graph_range[graph_num-1,0] = temp
        endif
                        
        info.slope.default_scale_graph[graph_num-1] = 0
        widget_control,info.slope.image_recomputeID[graph_num-1],set_value='Default Scale'

	if(graph_num eq 1) then $
          msql_update_slope,info.slope.plane[0],0,info
	if(graph_num eq 2) then $
          msql_update_zoom_image,info
	if(graph_num eq 3) then $
          msql_update_slope,info.slope.plane[2],2,info
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end

;_______________________________________________________________________
;  Change the Zoom level for window 2
;_______________________________________________________________________

    (strmid(event_name,0,5) EQ 'zsize') : begin
        zsize = fix(strmid(event_name,5,1))
        if(zsize eq 1) then info.slope.scale_zoom= 1.0
        if(zsize eq 2) then info.slope.scale_zoom = 2.0
        if(zsize eq 3) then info.slope.scale_zoom = 4.0
        if(zsize eq 4) then info.slope.scale_zoom = 8.0
        if(zsize eq 5) then info.slope.scale_zoom = 16.0
        if(zsize eq 6) then info.slope.scale_zoom = 32.0
        info.slope.x_zoom = info.slope.x_zoom_pos
        info.slope.y_zoom = info.slope.y_zoom_pos
        msql_update_zoom_image,info
    
; redraw box

        if(info.slope.current_graph eq 0) then msql_update_slope,info.slope.plane[0],0,info
        if(info.slope.current_graph eq 2) then msql_update_slope,info.slope.plane[2],2,info


        msql_draw_zoom_box,info

        widget_control,event.top,Set_UValue = ginfo
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info    
    end

;_______________________________________________________________________
;_______________________________________________________________________
; change x and y range of ramp graph 
;_______________________________________________________________________
    (strmid(event_name,0,7) EQ 'ramp_mm') : begin
        if(strmid(event_name,7,1) EQ 'x') then graphno = 0 else graphno = 1 
        if(strmid(event_name,7,2) EQ 'x1') then begin
            info.slope.ramp_range[0,0]  = event.value
            widget_control,info.slope.ramp_mmlabel[0,1], get_value = temp
            info.slope.ramp_range[0,1]  = temp
        endif

        if(strmid(event_name,7,2) EQ 'x2') then begin 
            info.slope.ramp_range[0,1]  = event.value
            widget_control,info.slope.ramp_mmlabel[0,0], get_value = temp
            info.slope.ramp_range[0,0]  = temp
        endif

        if(strmid(event_name,7,2) EQ 'y1') then  begin
            info.slope.ramp_range[1,0]  = event.value
            widget_control,info.slope.ramp_mmlabel[1,1], get_value = temp
            info.slope.ramp_range[1,1]  = temp
        endif
        if(strmid(event_name,7,2) EQ 'y2') then begin
            info.slope.ramp_range[1,1]  = event.value
            widget_control,info.slope.ramp_mmlabel[1,0], get_value = temp
            info.slope.ramp_range[1,0]  = temp
        endif

        info.slope.default_scale_ramp[graphno] = 0
        widget_control,info.slope.ramp_recomputeID[graphno],set_value='Default Range'

        msql_update_rampread,info
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end
    
;_______________________________________________________________________
; set the Default range or user defined range for ramp plot
    (strmid(event_name,0,1) EQ 'r') : begin
        graphno = fix(strmid(event_name,1,1))
        if(info.slope.default_scale_ramp[graphno-1] eq 0 ) then begin ; true - turn to false
            widget_control,info.slope.ramp_recomputeID[graphno-1],set_value='  Plot Range '
            info.slope.default_scale_ramp[graphno-1] = 1
        endif

        msql_update_rampread,info
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end
;_______________________________________________________________________
; overplot slope
    (strmid(event_name,0,9) eq 'overslope') : begin
        num = fix(strmid(event_name,9,1))
; plot fit
        if(num eq 1) then begin
            info.slope.overplot_fit = 1
            widget_control,info.slope.overplotSlopeID[0],set_button = 1
            widget_control,info.slope.overplotSlopeID[1],set_button = 0
        endif

; do not plot
        if(num eq 2) then begin
            info.slope.overplot_fit= 0
            widget_control,info.slope.overplotSlopeID[0],set_button = 0
            widget_control,info.slope.overplotSlopeID[1],set_button = 1
        endif
        msql_update_rampread,info
    end
;_______________________________________________________________________


;_______________________________________________________________________
; overplot reference corrected data

    (strmid(event_name,0,7) eq 'overref') : begin
        num = fix(strmid(event_name,7,1))
        if(num eq 1) then begin
            info.slope.overplot_reference_corrected = 1
            widget_control,info.slope.overplotrefcorrectedID[1],set_button = 0
            widget_control,info.slope.overplotrefcorrectedID[0],set_button = 1

        endif

        if(num eq 2) then begin
            info.slope.overplot_reference_corrected= 0
            widget_control,info.slope.overplotrefcorrectedID[0],set_button = 0
            widget_control,info.slope.overplotrefcorrectedID[1],set_button = 1
        endif


        msql_update_rampread,info
        
    end

;_______________________________________________________________________
; overplot noise and cosmic rays

    (strmid(event_name,0,6) eq 'overcr') : begin
        num = fix(strmid(event_name,6,1))
        if(num eq 1) then begin
            info.slope.overplot_cr = 1
            widget_control,info.slope.overplotcrID[1],set_button = 0
            widget_control,info.slope.overplotcrID[0],set_button = 1

        endif

        if(num eq 2) then begin
            info.slope.overplot_cr= 0
            widget_control,info.slope.overplotcrID[0],set_button = 0
            widget_control,info.slope.overplotcrID[1],set_button = 1
        endif


        msql_update_rampread,info
        
    end



;_______________________________________________________________________
; overplot mean dark  corrected data

    (strmid(event_name,0,7) eq 'overmdc') : begin
        num = fix(strmid(event_name,7,1))
        if(num eq 1) then begin
            info.slope.overplot_mdc = 1
            widget_control,info.slope.overplotmdcID[1],set_button = 0
            widget_control,info.slope.overplotmdcID[0],set_button = 1

        endif

        if(num eq 2) then begin
            info.slope.overplot_mdc= 0
            widget_control,info.slope.overplotmdcID[0],set_button = 0
            widget_control,info.slope.overplotmdcID[1],set_button = 1
        endif


        msql_update_rampread,info
        
     end

;_______________________________________________________________________
; overplot reset corrected data

    (strmid(event_name,0,9) eq 'overreset') : begin
        num = fix(strmid(event_name,9,1))
        if(num eq 1) then begin
            info.slope.overplot_reset = 1
            widget_control,info.slope.overplotresetID[1],set_button = 0
            widget_control,info.slope.overplotresetID[0],set_button = 1

        endif

        if(num eq 2) then begin
            info.slope.overplot_reset= 0
            widget_control,info.slope.overplotresetID[0],set_button = 0
            widget_control,info.slope.overplotresetID[1],set_button = 1
        endif


        msql_update_rampread,info
        
     end

;_______________________________________________________________________
; overplot rscd corrected data

    (strmid(event_name,0,8) eq 'overrscd') : begin
        num = fix(strmid(event_name,8,1))
        if(num eq 1) then begin
            info.slope.overplot_rscd = 1
            widget_control,info.slope.overplotrscdID[1],set_button = 0
            widget_control,info.slope.overplotrscdID[0],set_button = 1

        endif

        if(num eq 2) then begin
            info.slope.overplot_rscd= 0
            widget_control,info.slope.overplotrscdID[0],set_button = 0
            widget_control,info.slope.overplotrscdID[1],set_button = 1
        endif

        msql_update_rampread,info
        
     end
;_______________________________________________________________________

; overplot lasrframe corrected data

    (strmid(event_name,0,13) eq 'overlastframe') : begin
        num = fix(strmid(event_name,13,1))
        if(num eq 1) then begin
            info.slope.overplot_lastframe = 1
            widget_control,info.slope.overplotlastframeID[1],set_button = 0
            widget_control,info.slope.overplotlastframeID[0],set_button = 1

        endif

        if(num eq 2) then begin
            info.slope.overplot_lastframe= 0
            widget_control,info.slope.overplotlastframeID[0],set_button = 0
            widget_control,info.slope.overplotlastframeID[1],set_button = 1
        endif


        msql_update_rampread,info
        
    end
;_______________________________________________________________________
; overplot linearity corrected data

    (strmid(event_name,0,6) eq 'overlc') : begin
        num = fix(strmid(event_name,6,1))
        if(num eq 1) then begin
            info.slope.overplot_lc = 1
            widget_control,info.slope.overplotlcID[1],set_button = 0
            widget_control,info.slope.overplotlcID[0],set_button = 1

        endif

        if(num eq 2) then begin
            info.slope.overplot_lc= 0
            widget_control,info.slope.overplotlcID[0],set_button = 0
            widget_control,info.slope.overplotlcID[1],set_button = 1
        endif


        msql_update_rampread,info
        
    end



;_______________________________________________________________________

; Change automatically reading pixels values and plotting ramp data
;_______________________________________________________________________

    (strmid(event_name,0,4) EQ 'auto') : begin
        if(event.index eq 0) then begin
            info.slope.autopixelupdate = 1
            widget_control,info.slope.updatingID, set_value = 'Click on a pixel to plot ramp'
        endif

        if(event.index ne 0) then begin
            info.slope.autopixelupdate = 0
            widget_control,info.slope.updatingID, set_value = 'Not updating plot'
        endif
    end
;_______________________________________________________________________
;_______________________________________________________________________
; Change Integration Range  For Ramp Plots
;_______________________________________________________________________

    (strmid(event_name,0,3) EQ 'int') : begin
; changed by typing a new value
        
        if(strmid(event_name,4,4) eq 'chng') then begin
            num = fix(strmid(event_name,9,1))-1
            info.slope.int_range[num] = event.value
        endif


; check if the <> buttons were used
        if(strmid(event_name,4,4) eq 'move') then begin
            value = intarr(2)
            value[0] = info.slope.int_range[0]
            value[1] = info.slope.int_range[1]

            if(strmid(event_name,9,1) eq 'u') then begin
                value[0] = value[0] + 1
                value[1] = value[1] + 1
            endif
            if(strmid(event_name,9,1) eq 'd') then begin
                value[0] = value[0] - 1
                value[1] = value[1] -1
            endif

            info.slope.int_range[0] = value[0]            
            info.slope.int_range[1] = value[1]            
        endif

; check if plot all integrations is typed

        if(strmid(event_name,4,4) eq 'grab') then begin
            info.slope.int_range[0] = 1            
            info.slope.int_range[1] = info.data.nints
            info.slope.overplot_pixel_int = 0
        endif            

; check if overplot integrations 

        if(strmid(event_name,4,4) eq 'over') then begin
            info.slope.int_range[0] = 1            
            info.slope.int_range[1] = info.data.nints
            info.slope.overplot_pixel_int = 1
        endif            
; Check limits for the above options for changing the integration range
; lower limit 1
; upper limit minfo.data.nints

        for i = 0,1 do begin
            if(info.slope.int_range[i] le 0) then info.slope.int_range[i] = info.data.nints
            if(info.slope.int_range[i] gt info.data.nints) then $
              info.slope.int_range[i] = 1
        endfor
        if(info.slope.int_range[0] gt info.slope.int_range[1] ) then begin
            temp = info.slope.int_range[0]
            info.slope.int_range[0] = info.slope.int_range[1]
            info.slope.int_range[1] = temp
        endif	
	
        msql_update_rampread,info

        widget_control,info.slope.IrangeID[0],set_value=info.slope.int_range[0]
        widget_control,info.slope.IrangeID[1],set_value=info.slope.int_range[1]
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end


;_______________________________________________________________________
; change x and y range of slope pixel  graph
;_______________________________________________________________________
    (strmid(event_name,0,7) EQ 'slop_mm') : begin
        if(strmid(event_name,7,1) EQ 'x') then graphno = 0 else graphno = 1
        if(strmid(event_name,7,2) EQ 'x1') then begin
            info.slope.slope_range[0,0]  = event.value
            widget_control,info.slope.slope_mmlabel[0,1], get_value  = temp
            info.slope.slope_range[0,1] = temp
        endif
        if(strmid(event_name,7,2) EQ 'x2') then begin
            info.slope.slope_range[0,1]  = event.value
            widget_control,info.slope.slope_mmlabel[0,0], get_value  = temp
            info.slope.slope_range[0,0] = temp
        endif
        if(strmid(event_name,7,2) EQ 'y1') then begin
            info.slope.slope_range[1,0]  = event.value
            widget_control,info.slope.slope_mmlabel[1,1], get_value  = temp
            info.slope.slope_range[1,1] = temp
        endif
        if(strmid(event_name,7,2) EQ 'y2') then begin
            info.slope.slope_range[1,1]  = event.value
            widget_control,info.slope.slope_mmlabel[1,0], get_value  = temp
            info.slope.slope_range[1,0] = temp
        endif


        info.slope.default_scale_slope[graphno] = 0
        widget_control,info.slope.slope_recomputeID[graphno],set_value='Default Range'


        msql_update_slopepixel,info
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end

;_______________________________________________________________________
; set the Default range or user defined range for ramp plot
    (strmid(event_name,0,1) EQ 'e') : begin
        graphno = fix(strmid(event_name,1,1))

        if(info.slope.default_scale_slope[graphno-1] eq 0 ) then begin ; true - turn to false
            widget_control,info.slope.slope_recomputeID[graphno-1],set_value='   Plot Range '
            info.slope.default_scale_slope[graphno-1] = 1
        endif

        msql_update_slopepixel,info
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end

;_______________________________________________________________________
; Select a different pixel 
;_______________________________________________________________________
    (strmid(event_name,0,3) EQ 'pix') : begin

        xsize = info.data.slope_xsize
        ysize = info.data.slope_ysize
        xvalue = info.slope.x_pos* info.slope.binfactor
        yvalue = info.slope.y_pos* info.slope.binfactor
        xstart = xvalue
        ystart = yvalue


        pixel_xvalue = xvalue
        pixel_yvalue = yvalue
; ++++++++++++++++++++++++++++++
        if(strmid(event_name,4,1) eq 'x') then  begin
            xvalue = event.value ; event value - user input starts at 1 

            if(xvalue lt 1) then xvalue = 1
            
            if(xvalue gt xsize) then xvalue = xsize

            pixel_xvalue = float(xvalue)-1.0

            ; check what is in y box 
            widget_control,info.slope.pix_label[1],get_value =  ytemp
            yvalue = ytemp
            if(yvalue lt 1) then yvalue = 1
            
            if(yvalue gt ysize) then yvalue = ysize
          
            pixel_yvalue = float(yvalue)-1


        endif
        if(strmid(event_name,4,1) eq 'y') then begin
            yvalue = event.value ; event value - user input starts at 1
            if(yvalue lt 1) then yvalue = 1
            if(yvalue gt ysize) then yvalue = ysize
            
            pixel_yvalue = float(yvalue)-1

            ; check what is in x box 
            widget_control,info.slope.pix_label[0], get_value= xtemp
            xvalue = xtemp
            if(xvalue lt 1) then xvalue = 1
            
            if(xvalue gt xsize) then xvalue = xsize
           
            pixel_xvalue = float(xvalue)-1.0
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

            pixel_xvalue= xvalue
            pixel_yvalue = yvalue

            widget_control,info.slope.pix_label[0],set_value=pixel_xvalue+1
            widget_control,info.slope.pix_label[1],set_value=pixel_yvalue+1

        endif

; ++++++++++++++++++++++++++++++

        info.slope.x_pos = float(pixel_xvalue)/float(info.slope.binfactor)
        info.slope.y_pos = float(pixel_yvalue)/float(info.slope.binfactor)

        msql_update_pixel_stat_slope,info
        xmove = (pixel_xvalue - xstart)/info.slope.binfactor
        ymove = (pixel_yvalue - ystart)/info.slope.binfactor



        current_graph_save = info.slope.current_graph
        graphno = [0,2]
        for i = 0,1  do begin 
            info.slope.current_graph = graphno[i]
            msql_update_pixel_location,info
        endfor
           ; set current graph to the one clicked on
        info.slope.current_graph = current_graph_save
        
        x = info.slope.x_pos * info.slope.binfactor	
        y = info.slope.y_pos * info.slope.binfactor
        msql_read_rampdata,x,y,pixeldata,info
        if ptr_valid (info.slope.pixeldata) then ptr_free,info.slope.pixeldata
        info.slope.pixeldata = ptr_new(pixeldata)
        msql_read_slopedata,x,y,info


; if refecorrection file exist
           if(info.control.file_refcorrection_exist eq 1 and $
              info.slope.overplot_reference_corrected eq 1) then  $
             msql_read_refcorrected_data,x,y,info

; fill in the frame IDS, if the file was written
        if(info.control.file_ids_exist eq 1 and info.slope.overplot_cr) then $
            msql_read_id_data,x,y,info

; fill in the linearity corrected data
        if(info.control.file_lc_exist eq 1 and info.slope.overplot_lc) then $
            msql_read_lc_data,x,y,info

; fill in the mean dark corrected data
        if(info.control.file_mdc_exist eq 1 and info.slope.overplot_mdc) then $
            msql_read_mdc_data,x,y,info

; fill in the reset corrected data
        if(info.control.file_reset_exist eq 1 and info.slope.overplot_reset) then $
            msql_read_reset_data,x,y,info

; fill in the rscd corrected data
        if(info.control.file_rscd_exist eq 1 and info.slope.overplot_rscd) then $
            msql_read_rscd_data,x,y,info

; fill in the lastframe corrected data
        if(info.control.file_lastframe_exist eq 1 and info.slope.overplot_lastframe) then $
            msql_read_lastframe_data,x,y,info


        msql_update_rampread,info                          
        msql_update_slopepixel,info



        current_graph_save = info.slope.current_graph        
; update the pixel in the zoom window
            
        info.slope.x_zoom = pixel_xvalue
        info.slope.y_zoom = pixel_yvalue
        msql_update_zoom_image,info

; Draw a box around the pixel - showing the zoom window size 
           if(info.slope.zoom_window ne 2) then  begin ;
               msql_draw_zoom_box,info
           endif
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info


; If the Frame values for pixel window is open - update
        if(XRegistered ('mpixel')) then begin
            widget_control,info.RPixelInfo,/destroy

        endif
        
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end

;_______________________________________________________________________
;_______________________________________________________________________
    (strmid(event_name,0,7) EQ 'voption') : begin
        graphnum = fix(strmid(event_name,7,1))
        if(graphnum eq 1) then begin
            info.slope.plane[0] = event.index
            info.slope.default_scale_graph[0] = 1
            msql_update_slope,info.slope.plane[0],0,info
        endif

        if(graphnum eq 2) then begin
            info.slope.plane[2] = event.index
            info.slope.default_scale_graph[2] = 1
            msql_update_slope,info.slope.plane[2],2,info
        endif
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end

;_______________________________________________________________________
;_______________________________________________________________________
; Plotting options: histogram: column slice: comparison to test image
;_______________________________________________________________________

    (strmid(event_name,0,6) EQ 'option') : begin

        graphnum = fix(strmid(event_name,6,1))
        type = graphnum -1 

        
        if(event.index eq 1) then begin ; histogram
            msql_setup_hist,graphnum,info
            msql_display_histo,graphnum,info

        endif
        if(event.index eq 2) then begin ; column slice
            msql_setup_colslice,graphnum,info
            msql_display_colslice,graphnum,info  

        endif
        if(event.index eq 3) then begin  ; row slice 
            msql_setup_rowslice,graphnum,info
            msql_display_rowslice,graphnum,info

        endif
        if(event.index eq 4) then begin
            ok = dialog_message(" Comparsion to Test Image, coming soon, waiting for test image",/Information)
        endif

        widget_control,info.slope.optionMenu[type],set_droplist_select=0
    end

; ----------------------------------------------------------------------



else: print,' msql_event: Event name not found: ',event_name
endcase
Widget_Control,ginfo.info.QuickLook,Set_UValue=info
end
