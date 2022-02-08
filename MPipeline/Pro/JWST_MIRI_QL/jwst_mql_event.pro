; the event manager for the ql.pro (main base widget)
pro jwst_mql_event,event

Widget_Control,event.id,Get_uValue=event_name
widget_control,event.top, Get_UValue = ginfo
widget_control,ginfo.info.jwst_QuickLook,Get_Uvalue = info
update_slope_plots = 0
iramp = info.jwst_image.frameNO
jintegration = info.jwst_image.integrationNO


if (widget_info(event.id,/TLB_SIZE_EVENTS) eq 1 ) then begin
    info.jwst_image.xwindowsize = event.x
    info.jwst_image.ywindowsize = event.y
    info.jwst_image.uwindowsize = 1
    widget_control,event.top,set_uvalue = ginfo
    widget_control,ginfo.info.jwst_Quicklook,set_uvalue = info
    jwst_mql_display_images,info
    return
endif
;    print,'event_name',event_name
    case 1 of
;_______________________________________________________________________
       (strmid(event_name,0,7) EQ 'voption') : begin ; this is only for graph 2,1
                                ;  data_type = 1 rate
                                ; data_type = 2 rate_int
                                ; data_type = 3 cal
       info.jwst_image.data_type[2] = event.index + 1
       info.jwst_image.plane = 0 
       info.jwst_image.default_scale_graph[2] = 1
       error = 0 
       if(info.jwst_image.data_type[2] eq 1 and info.jwst_control.file_slope_exist eq 0) then error = 1
       if(info.jwst_image.data_type[2] eq 2 and info.jwst_control.file_slope_int_exist eq 0) then error = 1
       if(info.jwst_image.data_type[2] eq 3 and info.jwst_control.file_cal_exist eq 0) then error = 1
       if(error eq 1) then begin 
          ok = dialog_message("  Image type does not exist",/Information)
       endif else begin 
          jwst_mql_update_slope,info
       endelse 
     end
;_______________________________________________________________________
; display heder
    (strmid(event_name,0,7) EQ 'rheader') : begin
        jwst_display_header,info,0
    end

    (strmid(event_name,0,7) EQ 'sheader') : begin
       if(info.jwst_control.file_slope_exist eq 0 ) then begin
          ok = dialog_message(" No slope image exists",/Information)
       endif else begin
          jwst_display_header,info,1
       endelse
    end

    (strmid(event_name,0,7) EQ 'cheader') : begin
       if(info.jwst_control.file_cal_exist eq 0 ) then begin
          ok = dialog_message(" No calibration image exists",/Information)
       endif else begin
          jwst_display_header,info,2
       endelse
    end

;_______________________________________________________________________
;Subarray Geometry 
    (strmid(event_name,0,9) EQ 'sgeometry') : begin
       print,'Geometry function not ported to miri_ql yet'
;        jwst_mql_plot_subarray_geo,info
    end
;_______________________________________________________________________
; Compare to another data file
    (strmid(event_name,0,7) EQ 'compare') : begin
        info.jwst_compare.uwindowsize = 0
        info.jwst_cinspect[*].uwindowsize = 1

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
            ok = dialog_message(" Image File does not exist, select filename again",/Information)
            status = 1
        endif else begin

        info.jwst_compare_image[0].filename  = info.jwst_control.filename_raw
        info.jwst_compare_image[1].filename  = filename

        read_data_type,info.jwst_compare_image[1].filename,type

        if(type ne 0) then begin 
            error = dialog_message(" The file must be a raw science file, select file again",/error)
            return
        endif
        
        info.jwst_compare_image[0].jintegration = info.jwst_image.integrationNO
        info.jwst_compare_image[1].jintegration = info.jwst_image.integrationNO

        info.jwst_compare_image[0].igroup = info.jwst_image.frameNO
        info.jwst_compare_image[1].igroup = info.jwst_image.frameNO
	jwst_mql_compare_display,info
        Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info
	endelse
    end
;_______________________________________________________________________
; Compare current frame to another frame 
    (strmid(event_name,0,8) EQ 'fcompare') : begin

        info.jwst_compare.uwindowsize = 0
        info.jwst_cinspect[*].uwindowsize = 1
        this_frame = event.value-1

        if(this_frame lt 0) then this_frame = 0
        
        if(this_frame gt info.jwst_data.ngroups-1  ) then this_frame = info.jwst_data.ngroups-1

        info.jwst_compare_image[0].filename  = info.jwst_control.filename_raw
        info.jwst_compare_image[1].filename  = info.jwst_control.filename_raw
        info.jwst_compare_image[0].jintegration = info.jwst_image.integrationNO 
        info.jwst_compare_image[1].jintegration = info.jwst_image.integrationNO

        info.jwst_compare_image[0].igroup= info.jwst_image.frameNO 
        info.jwst_compare_image[1].igroup = this_frame

       	jwst_mql_compare_display,info
        Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info
    end
;_______________________________________________________________________
; Display statistics on the image 
    (strmid(event_name,0,4) EQ 'Stat') : begin
	jwst_mql_display_stat,info
        Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info
     end
;_______________________________________________________________________
;Display science image split into 5 channel amplifier
    (strmid(event_name,0,10) EQ 'DisplayAmp') : begin

        info.jwst_AmpFrame.uwindowsize = 0
        setup_amplifier,info,info.jwst_image.integrationNO, info.jwst_image.frameNO
        jwst_display_amplifier,info
    end

;_______________________________________________________________________

; Display slope image split into 5 channel amplifier
    (strmid(event_name,0,11) EQ 'DisplayRAmp') : begin

       if(info.jwst_control.file_slope_exist eq 0) then begin
          ok = dialog_message(" No slope image exists",/Information)
          return
       endif else begin
          status = 0
          setup_AmplifierRate,info,info.jwst_image.integrationNO,status,error_message
          if(status ne 0) then begin 
             ok = dialog_message(error_message,/Information)
             return
          endif
          info.jwst_AmpRate.uwindowsize = 0
           jwst_display_RateAmplifier,info
        endelse
    end


    ; Display slope image split into 5 channel amplifier
    (strmid(event_name,0,11) EQ 'DisplayTAmp') : begin

       ok = dialog_message(" Feauture in next release",/Information)
       return

    end
;_______________________________________________________________________
; print

    (strmid(event_name,0,5) EQ 'print') : begin
        if(strmid(event_name,6,1) eq 'R') then type = 0
        if(strmid(event_name,6,1) eq 'Z') then type = 1
        if(strmid(event_name,6,1) eq 'S') then type = 2
        if(strmid(event_name,6,1) eq 'P') then type = 3

        jwst_print_images,info,type
    end
;_______________________________________________________________________
; overplot slope
    (strmid(event_name,0,9) eq 'overslope') : begin
        num = fix(strmid(event_name,9,1))
        if(num eq 1) then begin
            if(info.jwst_data.slope_zsize le 1) then begin
                result = dialog_message(" Zero-pt plane does not exist in slope file, re-run miri_sloper",/info )

                widget_control,info.jwst_image.overplotFitID[0],set_button = 0
                widget_control,info.jwst_image.overplotFitID[1],set_button = 1
            endif else begin 
                info.jwst_image.overplot_fit = 1
                widget_control,info.jwst_image.overplotFitID[1],set_button = 0
                widget_control,info.jwst_image.overplotFitID[0],set_button = 1
            endelse
        endif

        if(num eq 2) then begin
            info.jwst_image.overplot_fit= 0
            widget_control,info.jwst_image.overplotFitID[0],set_button = 0
            widget_control,info.jwst_image.overplotFitID[1],set_button = 1
        endif
        jwst_mql_update_rampread,info
    end
;_______________________________________________________________________
; overplot reference corrected data

    (strmid(event_name,0,7) eq 'overref') : begin
        num = fix(strmid(event_name,7,1))
        if(num eq 1) then begin
            info.jwst_image.overplot_refpix = 1
            widget_control,info.jwst_image.overplotrefpixID[1],set_button = 0
            widget_control,info.jwst_image.overplotrefpixID[0],set_button = 1

        endif

        if(num eq 2) then begin
            info.jwst_image.overplot_refpix= 0
            widget_control,info.jwst_image.overplotrefpixID[0],set_button = 0
            widget_control,info.jwst_image.overplotrefpixID[1],set_button = 1
        endif

        jwst_mql_update_rampread,info
    end
;_______________________________________________________________________
; overplot linearity corrected data

    (strmid(event_name,0,6) eq 'overlc') : begin
        num = fix(strmid(event_name,6,1))
        if(num eq 1) then begin
            info.jwst_image.overplot_lin = 1
            widget_control,info.jwst_image.overplotlinID[1],set_button = 0
            widget_control,info.jwst_image.overplotlinID[0],set_button = 1
        endif

        if(num eq 2) then begin
            info.jwst_image.overplot_lin= 0
            widget_control,info.jwst_image.overplotlinID[0],set_button = 0
            widget_control,info.jwst_image.overplotlinID[1],set_button = 1
        endif
        jwst_mql_update_rampread,info
    end
;_______________________________________________________________________
; overplot mean dark  corrected data

    (strmid(event_name,0,6) eq 'overmd') : begin
        num = fix(strmid(event_name,6,1))
        if(num eq 1) then begin
            info.jwst_image.overplot_dark = 1
            widget_control,info.jwst_image.overplotdarkID[1],set_button = 0
            widget_control,info.jwst_image.overplotdarkID[0],set_button = 1

        endif

        if(num eq 2) then begin
            info.jwst_image.overplot_dark= 0
            widget_control,info.jwst_image.overplotdarkID[0],set_button = 0
            widget_control,info.jwst_image.overplotdarkID[1],set_button = 1
        endif
        jwst_mql_update_rampread,info
    end

;_______________________________________________________________________
; overplot reset corrected data

    (strmid(event_name,0,9) eq 'overreset') : begin
        num = fix(strmid(event_name,9,1))
        if(num eq 1) then begin
            info.jwst_image.overplot_reset = 1
            widget_control,info.jwst_image.overplotresetID[1],set_button = 0
            widget_control,info.jwst_image.overplotresetID[0],set_button = 1

        endif
        if(num eq 2) then begin
            info.jwst_image.overplot_reset = 0
            widget_control,info.jwst_image.overplotresetID[0],set_button = 0
            widget_control,info.jwst_image.overplotresetID[1],set_button = 1
        endif
        jwst_mql_update_rampread,info
    end
;_______________________________________________________________________
; overplot rscd corrected data

    (strmid(event_name,0,8) eq 'overrscd') : begin
        num = fix(strmid(event_name,8,1))
        if(num eq 1) then begin
            info.jwst_image.overplot_rscd = 1
            widget_control,info.jwst_image.overplotrscdID[1],set_button = 0
            widget_control,info.jwst_image.overplotrscdID[0],set_button = 1
        endif
        if(num eq 2) then begin
            info.jwst_image.overplot_rscd = 0
            widget_control,info.jwst_image.overplotrscdID[0],set_button = 0
            widget_control,info.jwst_image.overplotrscdID[1],set_button = 1
        endif
        jwst_mql_update_rampread,info
    end
;_______________________________________________________________________
; overplot lastframe corrected data
    (strmid(event_name,0,13) eq 'overlastframe') : begin
        num = fix(strmid(event_name,13,1))
        if(num eq 1) then begin
            info.jwst_image.overplot_lastframe = 1
            widget_control,info.jwst_image.overplotlastframeID[1],set_button = 0
            widget_control,info.jwst_image.overplotlastframeID[0],set_button = 1

        endif
        if(num eq 2) then begin
            info.jwst_image.overplot_lastframe = 0
            widget_control,info.jwst_image.overplotlastframeID[0],set_button = 0
            widget_control,info.jwst_image.overplotlastframeID[1],set_button = 1
        endif
        jwst_mql_update_rampread,info
    end
;_______________________________________________________________________
    (strmid(event_name,0,8) EQ 'datainfo') : begin

       type =strmid(event_name,8,1)
       x = info.jwst_image.x_pos * info.jwst_image.binfactor
       y = info.jwst_image.y_pos * info.jwst_image.binfactor

       if (type  eq '1') then $
          dq = (*info.jwst_data.preduced)[x,y,2]
       if (type  eq '2')  then $
          dq = (*info.jwst_data.preducedint)[x,y,2]
       if (type  eq '3') then $
          dq = (*info.jwst_data.preduced_cal)[x,y,2]
       info.jwst_dqflag.x = x
       info.jwst_dqflag.y = y
       info.jwst_dqflag.dq = dq
       ;print,'DQ',type,info.jwst_dqflag.x,info.jwst_dqflag.y,info.jwst_dqflag.dq
       jwst_dqflags,info

    end
;_______________________________________________________________________
;_______________________________________________________________________
   (strmid(event_name,0,8) EQ 'getframe') : begin
	x = info.jwst_image.x_pos * info.jwst_image.binfactor
	y = info.jwst_image.y_pos * info.jwst_image.binfactor

        ; check and see if read in all frame values for pixel
        if (ptr_valid(info.jwst_image.ppixeldata) eq 0) then begin ; has not been read in 
            jwst_mql_read_rampdata,x,y,pixeldata,info  
            info.jwst_image.ppixeldata = ptr_new(ppixeldata)
        endif

        pixeldata = (*info.jwst_image.ppixeldata)
        if ptr_valid (info.jwst_image_pixel.ppixeldata) then ptr_free,info.jwst_image_pixel.ppixeldata
        info.jwst_image_pixel.ppixeldata = ptr_new(pixeldata)
        pixeldata = 0
        
; fill in reference corrected data, if the file was written
        if(info.jwst_control.file_refpix_exist eq 1 ) then begin 
            if (ptr_valid(info.jwst_image.prefpix_pixeldata) eq 0) then begin ; has not been read in 
                jwst_mql_read_refpix_data,x,y,info
            endif
            refcorrected_data = (*info.jwst_image.prefpix_pixeldata)

            if ptr_valid (info.jwst_image_pixel.prefpix_pixeldata) then $
              ptr_free,info.jwst_image_pixel.prefpix_pixeldata
            info.jwst_image_pixel.prefpix_pixeldata = ptr_new(refcorrected_data)        
            refcorrected_data = 0
        endif

; fill in the dark corrected data, if the file was written
        if(info.jwst_control.file_dark_exist eq 1) then begin
            if (ptr_valid(info.jwst_image.pdark_pixeldata) eq 0) then begin ; has not been read in 
                jwst_mql_read_dark_data,x,y,info
            endif
 
            mdc_data = (*info.jwst_image.pdark_pixeldata)
            if ptr_valid (info.jwst_image_pixel.pdark_pixeldata) then $
              ptr_free,info.jwst_image_pixel.pdark_pixeldata
            info.jwst_image_pixel.pdark_pixeldata = ptr_new(mdc_data)
            mdc_data = 0
         endif

; fill in the reset corrected data, if the file was written
        if(info.jwst_control.file_reset_exist eq 1) then begin
            if (ptr_valid(info.jwst_image.preset_pixeldata) eq 0) then begin ; has not been read in 
                jwst_mql_read_reset_data,x,y,info
            endif
            reset_data = (*info.jwst_image.preset_pixeldata)
            if ptr_valid (info.jwst_image_pixel.preset_pixeldata) then $
              ptr_free,info.jwst_image_pixel.preset_pixeldata
            info.jwst_image_pixel.preset_pixeldata = ptr_new(reset_data)
            reset_data = 0
         endif

; fill in the rscd corrected data, if the file was written
        if(info.jwst_control.file_rscd_exist eq 1) then begin
            if (ptr_valid(info.jwst_image.prscd_pixeldata) eq 0) then begin ; has not been read in 
                jwst_mql_read_rscd_data,x,y,info
            endif
            rscd_data = (*info.jwst_image.prscd_pixeldata)
            if ptr_valid (info.jwst_image_pixel.prscd_pixeldata) then $
              ptr_free,info.jwst_image_pixel.prscd_pixeldata
            info.jwst_image_pixel.prscd_pixeldata = ptr_new(rscd_data)
            rscd_data = 0
         endif

; fill in the lastframe corrected data, if the file was written
        if(info.jwst_control.file_lastframe_exist eq 1) then begin
            if (ptr_valid(info.jwst_image.plastframe_pixeldata) eq 0) then begin ; has not been read in 
                jwst_mql_read_lastframe_data,x,y,info
            endif
            lastframe_data = (*info.jwst_image.plastframe_pixeldata)
            if ptr_valid (info.jwst_image_pixel.plastframe_pixeldata) then $
              ptr_free,info.jwst_image_pixel.plastframe_pixeldata
            info.jwst_image_pixel.plastframe_pixeldata = ptr_new(lastframe_data)
            lastframe_data = 0
         endif

; fill in the linearity corrected data, if the file was written
        if(info.jwst_control.file_linearity_exist eq 1) then begin 
            if (ptr_valid(info.jwst_image.plin_pixeldata) eq 0) then begin ; has not been read in 
                jwst_mql_read_lin_data,x,y,info
            endif
            lc_data = (*info.jwst_image.plin_pixeldata)

            if ptr_valid (info.jwst_image_pixel.plin_pixeldata) then $
              ptr_free,info.jwst_image_pixel.plin_pixeldata
            info.jwst_image_pixel.plin_pixeldata = ptr_new(lc_data)        
            lc_data = 0
            
        endif

        info.jwst_image_pixel.integrationNo = info.jwst_image.integrationNO
        if(info.jwst_control.file_slope_exist eq 1) then begin 
            info.jwst_image_pixel.slope = (*info.jwst_data.preduced)[x,y,0]
            info.jwst_image_pixel.zeropt =  0
            info.jwst_image_pixel.error  =(*info.jwst_data.preduced)[x,y,2]
            info.jwst_image_pixel.quality_flag = (*info.jwst_data.preduced)[x,y,1]

        endif
        jwst_display_frame_values,x,y,info
        
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
       if(jintegration lt 0) then jintegration = info.jwst_data.nints-1 ; loop back around
       if(jintegration gt info.jwst_data.nints-1 ) then jintegration = 0 ; loop back
       
        widget_control,info.jwst_image.integration_label,set_value= fix(jintegration+1)

	; check the frame value
        widget_control,info.jwst_image.frame_label,get_value =  temp
	temp = temp-1	
        if(temp lt 0) then temp = info.jwst_data.ngroups-1 ; loop back around
        if(temp gt info.jwst_data.ngroups-1  ) then  temp = 0 ; loop back around 
	iramp = temp
	widget_control,info.jwst_image.frame_label,set_value = iramp+1

	jwst_mql_moveframe,jintegration,iramp,info ; also reads in new slope integration if needed
        
        jwst_mql_update_pixel_stat,info
        Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info
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
            if(strmid(event_name,10,2) eq 'dn') then iramp = iramp -1
            if(strmid(event_name,10,2) eq 'up') then iramp = iramp +1            
	endif
; do some checks	wrap around

        if(iramp lt 0) then iramp = info.jwst_data.ngroups-1 ; loop back around
        if(iramp gt info.jwst_data.ngroups-1  ) then  iramp = 0 ; loop back around 

        widget_control,info.jwst_image.frame_label,set_value= fix(iramp+1)

	; check the integration value
        widget_control,info.jwst_image.integration_label,get_value =  temp
	temp = temp-1	
        if(temp lt 0) then temp = info.jwst_data.nints-1 ; loop back around
        if(temp gt info.jwst_data.nints-1  ) then  temp = 0 ; loop back around 
	jintegraion = temp
	widget_control,info.jwst_image.integration_label,set_value = jintegration+1

	jwst_mql_moveframe,jintegration,iramp,info
        jwst_mql_update_pixel_stat,info
        Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info
    end	
;_______________________________________________________________________
; Select a different pixel 
;_______________________________________________________________________
    (strmid(event_name,0,3) EQ 'pix') : begin

        xsize = info.jwst_data.image_xsize
        ysize = info.jwst_data.image_ysize

        xvalue = info.jwst_image.x_pos* info.jwst_image.binfactor
        yvalue = info.jwst_image.y_pos* info.jwst_image.binfactor
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
            widget_control,info.jwst_image.pix_label[1],get_value =  ytemp
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
            widget_control,info.jwst_image.pix_label[0], get_value= xtemp
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
            if(xvalue ge  info.jwst_data.image_xsize) then xvalue = info.jwst_data.image_xsize-1
            if(yvalue ge  info.jwst_data.image_ysize) then yvalue = info.jwst_data.image_ysize-1

            pixel_xvalue= xvalue
            pixel_yvalue = yvalue

            widget_control,info.jwst_image.pix_label[0],set_value=pixel_xvalue+1
            widget_control,info.jwst_image.pix_label[1],set_value=pixel_yvalue+1
        endif
; ++++++++++++++++++++++++++++++
        info.jwst_image.x_pos = float(pixel_xvalue)/float(info.jwst_image.binfactor)
        info.jwst_image.y_pos = float(pixel_yvalue)/float(info.jwst_image.binfactor)

        jwst_mql_update_pixel_stat,info
        xmove = (pixel_xvalue - xstart)/float(info.jwst_image.binfactor)
        ymove = (pixel_yvalue - ystart)/float(info.jwst_image.binfactor)

        graphno = [0,2]
        for i = 0,1  do begin 
            info.jwst_image.current_graph = graphno[i]
            jwst_mql_update_pixel_location,info  ; update pixel location on graph windows
        endfor

; read information on the new pixel 
        if(info.jwst_image.autopixelupdate eq 1)then begin
            jwst_mql_read_rampdata,pixel_xvalue,pixel_yvalue,pixeldata,info  

            if ptr_valid (info.jwst_image.ppixeldata) then ptr_free,info.jwst_image.ppixeldata
            info.jwst_image.ppixeldata = ptr_new(pixeldata)
        endif

; read slope data for pixel
        jwst_mql_read_slopedata,pixel_xvalue,pixel_yvalue,info  
        
; read reference corrected data if file was created
        if(info.jwst_control.file_refpix_exist eq 1)then $
          jwst_mql_read_refpix_data,pixel_xvalue,pixel_yvalue,info

; fill in the frame LC , if the file was written
        if(info.jwst_control.file_linearity_exist eq 1)then begin
            jwst_mql_read_lin_data,pixel_xvalue,pixel_yvalue,info
        endif

; fill in the frame MCD, if the file was written
        if(info.jwst_control.file_dark_exist eq 1)then begin
            jwst_mql_read_dark_data,pixel_xvalue,pixel_yvalue,info
        endif

         jwst_mql_update_rampread,info                     

; fill in the reset, if the file was written
        if(info.jwst_control.file_reset_exist eq 1)then begin
            jwst_mql_read_reset_data,pixel_xvalue,pixel_yvalue,info
         endif

; fill in the reset, if the file was written
        if(info.jwst_control.file_rscd_exist eq 1)then begin
            jwst_mql_read_rscd_data,pixel_xvalue,pixel_yvalue,info
         endif

; fill in the lastframe, if the file was written
        if(info.jwst_control.file_lastframe_exist eq 1)then begin
            jwst_mql_read_lastframe_data,pixel_xvalue,pixel_yvalue,info
        endif

         jwst_mql_update_rampread,info                     

; update the pixel in the zoom window        
        info.jwst_image.x_zoom = pixel_xvalue 
        info.jwst_image.y_zoom = pixel_yvalue 
        
        if(info.jwst_image.x_zoom ge xsize) then info.jwst_image.x_zoom = xsize -1 
        if(info.jwst_image.y_zoom ge ysize) then info.jwst_image.y_zoom = ysize - 1
        jwst_mql_update_zoom_image,info

; If the Frame values for pixel window is open - destroy
        if(XRegistered ('mpixel')) then begin
            widget_control,info.jwst_RPixelInfo,/destroy
        endif

        Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info
    end


;_______________________________________________________________________
; change range of image graphs
; if change range then also change the scale button to 'User Set
; Scale'
;_______________________________________________________________________
    (strmid(event_name,0,2) EQ 'sr') : begin
        graph_num = fix(strmid(event_name,2,1))-1
        

        if(strmid(event_name,4,1) EQ 'b') then begin ; min
            info.jwst_image.graph_range[graph_num,0] = event.value
            widget_control,info.jwst_image.rlabelID[graph_num,1],get_value = temp
            info.jwst_image.graph_range[graph_num,1] = temp
        endif

        if(strmid(event_name,4,1) EQ 't') then begin ; max
            info.jwst_image.graph_range[graph_num,1] = event.value
            widget_control,info.jwst_image.rlabelID[graph_num,0],get_value = temp
            info.jwst_image.graph_range[graph_num,0] = temp
        endif
        info.jwst_image.default_scale_graph[graph_num] = 0
        widget_control,info.jwst_image.image_recomputeID[graph_num],set_value='Default Scale'

        if(graph_num eq 0) then jwst_mql_update_images,info
        if(graph_num eq 1) then jwst_mql_update_zoom_image,info
        if(graph_num eq 2) then jwst_mql_update_slope,info
    end

;_______________________________________________________________________
; scaling image and slope
;_______________________________________________________________________
    (strmid(event_name,0,5) EQ 'scale') : begin

        graphno = fix(strmid(event_name,5,1))

        if(info.jwst_image.default_scale_graph[graphno-1] eq 0 ) then begin ; true - turn to false
            widget_control,info.jwst_image.image_recomputeID[graphno-1],set_value='Image Scale'
            info.jwst_image.default_scale_graph[graphno-1] = 1
        endif

	if(graphno eq 1)then jwst_mql_update_images,info
	if(graphno eq 2)then jwst_mql_update_zoom_image,info
	if(graphno eq 3)then jwst_mql_update_slope,info
        Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info
    end
;_______________________________________________________________________
; change x and y range of ramp graph 
;_______________________________________________________________________
    (strmid(event_name,0,7) EQ 'ramp_mm') : begin
        if(strmid(event_name,7,1) EQ 'x') then graphno = 0 else graphno = 1 
        if(strmid(event_name,7,2) EQ 'x1') then begin
            info.jwst_image.ramp_range[0,0]  = event.value
            widget_control,info.jwst_image.ramp_mmlabel[0,1],get_value = temp
            info.jwst_image.ramp_range[0,1]  = temp
        endif
        if(strmid(event_name,7,2) EQ 'x2') then begin
            info.jwst_image.ramp_range[0,1]  = event.value
            widget_control,info.jwst_image.ramp_mmlabel[0,0],get_value = temp
            info.jwst_image.ramp_range[0,0]  = temp
        endif
        if(strmid(event_name,7,2) EQ 'y1') then begin
            info.jwst_image.ramp_range[1,0]  = event.value
            widget_control,info.jwst_image.ramp_mmlabel[1,1],get_value = temp
            info.jwst_image.ramp_range[1,1]  = temp
        endif
        if(strmid(event_name,7,2) EQ 'y2') then  begin
            info.jwst_image.ramp_range[1,1]  = event.value
            widget_control,info.jwst_image.ramp_mmlabel[1,0],get_value = temp
            info.jwst_image.ramp_range[1,0]  = temp
        endif

        info.jwst_image.default_scale_ramp[graphno] = 0
        widget_control,info.jwst_image.ramp_recomputeID[graphno],set_value='Default Range'

        jwst_mql_update_rampread,info
        Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info
    end
;_______________________________________________________________________
; set the Default range or user defined range for ramp plot
    (strmid(event_name,0,1) EQ 'r') : begin
        graphno = fix(strmid(event_name,1,1))
        if(info.jwst_image.default_scale_ramp[graphno-1] eq 0 ) then begin ; true - turn to false
            widget_control,info.jwst_image.ramp_recomputeID[graphno-1],set_value=' Plot Range '
            info.jwst_image.default_scale_ramp[graphno-1] = 1
        endif

        jwst_mql_update_rampread,info
        Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info
    end

;_______________________________________________________________________
; Change Integration Range  For Ramp Plots
;_______________________________________________________________________

    (strmid(event_name,0,3) EQ 'int') : begin
; changed by typing a new value
        
        if(strmid(event_name,4,4) eq 'chng') then begin
            num = fix(strmid(event_name,9,1))-1
            info.jwst_image.int_range[num] = event.value
        endif

; check if the <> buttons were used
        if(strmid(event_name,4,4) eq 'move') then begin
            value = intarr(2)
            value[0] = info.jwst_image.int_range[0]
            value[1] = info.jwst_image.int_range[1]

            if(strmid(event_name,9,1) eq 'u') then begin
                value[0] = value[0] + 1
                value[1] = value[1] + 1
            endif
            if(strmid(event_name,9,1) eq 'd') then begin
                value[0] = value[0] - 1
                value[1] = value[1] -1
            endif

            info.jwst_image.int_range[0] = value[0]            
            info.jwst_image.int_range[1] = value[1]            
        endif

; check if plot all integrations is typed

        if(strmid(event_name,4,4) eq 'grab') then begin
            info.jwst_image.int_range[0] = 1            
            info.jwst_image.int_range[1] = info.jwst_data.nints
            info.jwst_image.overplot_pixel_int = 0
        endif            
; check if overplot integrations 

        if(strmid(event_name,4,4) eq 'over') then begin
            info.jwst_image.int_range[0] = 1            
            info.jwst_image.int_range[1] = info.jwst_data.nints
            info.jwst_image.overplot_pixel_int = 1
        endif            

; Check limits for the above options for changing the integration range
; lower limit 1
; upper limit ginfo.jwst_data.nints

        for i = 0,1 do begin
            if(info.jwst_image.int_range[i] le 0) then info.jwst_image.int_range[i] = 1
            if(info.jwst_image.int_range[i] gt info.jwst_data.nints) then $
              info.jwst_image.int_range[i] = info.jwst_data.nints
        endfor
        if(info.jwst_image.int_range[0] gt info.jwst_image.int_range[1] ) then begin
            info.jwst_image.int_range[*] = 1
        endif	
	
        jwst_mql_update_rampread,info
        Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info
    end

;_______________________________________________________________________
; Select a different pixel to report the values of
; event is generated for button pushing down and button release.
; only need this called once
;_______________________________________________________________________

   (strmid(event_name,0,8) EQ 'mqlpixel') : begin
      if(event.type eq 1) then begin
         graphnum = fix(strmid(event_name,8,1))

         if(graphnum ne 2) then info.jwst_image.graph_mpixel=graphnum 

         xvalue = event.x       ; starts at 0
         yvalue = event.y       ; starts at 0

         if(xvalue ge 258) then xvalue = 257
         if(yvalue ge 256) then yvalue = 255
; did not click on zoom image- so update the zoom image
         if(graphnum ne 2) then  begin 
            info.jwst_image.x_zoom = xvalue * info.jwst_image.binfactor
            info.jwst_image.y_zoom = yvalue * info.jwst_image.binfactor

            if(info.jwst_image.x_zoom ge info.jwst_data.image_xsize) then $
               info.jwst_image.x_zoom = info.jwst_data.image_xsize-1
            if(info.jwst_image.y_zoom ge info.jwst_data.image_ysize) then $
               info.jwst_image.y_zoom = info.jwst_data.image_ysize -1
            jwst_mql_update_zoom_image,info

            info.jwst_image.x_pos = xvalue 
            info.jwst_image.y_pos = yvalue
         endif

; clicked on the zoom image - so update the pixel in the zoom image 
         if(graphnum eq 2) then  begin
            x = (xvalue)/info.jwst_image.scale_zoom
            y = (yvalue)/info.jwst_image.scale_zoom
            if(x ge info.jwst_data.image_xsize) then x = info.jwst_data.image_xsize-1
            if(y ge info.jwst_data.image_ysize) then y = info.jwst_data.image_ysize-1
            xvalue = x * info.jwst_image.scale_zoom
            yvalue = y * info.jwst_image.scale_zoom

            update = 1

            jwst_mql_update_zoom_pixel_location,xvalue,yvalue,update,info

             ; redefine the center of the zoom image - if later
             ; want to zoom: x_zoom_pos & y_zoom_pos  
               
            x = (xvalue)/info.jwst_image.scale_zoom
            y = (yvalue)/info.jwst_image.scale_zoom
            x = x + info.jwst_image.x_zoom_start - info.jwst_image.ixstart_zoom
            y = y + info.jwst_image.y_zoom_start - info.jwst_image.iystart_zoom

            if(x gt info.jwst_data.image_xsize) then  x = info.jwst_data.image_xsize
            if(y gt info.jwst_data.image_ysize) then y = info.jwst_data.image_ysize

            info.jwst_image.x_zoom_pos = x
            info.jwst_image.y_zoom_pos = y

            if(info.jwst_image.x_zoom_pos ge info.jwst_data.image_xsize) then $
               info.jwst_image.x_zoom_pos = info.jwst_data.image_xsize
            if(info.jwst_image.y_zoom_pos ge info.jwst_data.image_ysize) then $
               info.jwst_image.y_zoom_pos = info.jwst_data.image_ysize
         endif
; update the pixel locations in graphs 1, 3
         graphno = [0,2]
         for i = 0,1 do begin 
            info.jwst_image.current_graph = graphno[i]
            jwst_mql_update_pixel_location,info
         endfor
         
; update the pixel information on main window
         jwst_mql_update_pixel_stat,info
         x = info.jwst_image.x_pos * info.jwst_image.binfactor	
         y = info.jwst_image.y_pos * info.jwst_image.binfactor	
         widget_control,info.jwst_image.pix_label[0],set_value = x+1
         widget_control,info.jwst_image.pix_label[1],set_value = y+1

; If the Frame values for pixel window is open - destroy
         if(XRegistered ('mpixel')) then begin
            widget_control,info.jwst_RPixelInfo,/destroy
         endif

; Draw a box around the pixel - showing the zoom window size 
         if(info.jwst_image.graph_mpixel ne 2) then  begin ;
            info.jwst_image.current_graph = info.jwst_image.graph_mpixel-1
            jwst_mql_draw_zoom_box,info
         endif

; load individual ramp graph - based on x_pos, y_pos
         xvalue = info.jwst_image.x_pos*info.jwst_image.binfactor
         yvalue = info.jwst_image.y_pos*info.jwst_image.binfactor
         if(info.jwst_image.autopixelupdate eq 1) then begin
            jwst_mql_read_rampdata,xvalue,yvalue,pixeldata,info
            if ptr_valid (info.jwst_image.ppixeldata) then ptr_free,info.jwst_image.ppixeldata
            info.jwst_image.ppixeldata = ptr_new(pixeldata)
         endif
           
         jwst_mql_read_slopedata,xvalue,yvalue,info

; read reference corrected data if file was created

         if(info.jwst_control.file_refpix_exist eq 1) then $
            jwst_mql_read_refpix_data,xvalue,yvalue,info

; fill in the linearity corrected data, if the file was written
         if(info.jwst_control.file_linearity_exist eq 1) then begin
            jwst_mql_read_lin_data,xvalue,yvalue,info
         endif

         if(info.jwst_control.file_dark_exist eq 1) then begin
            jwst_mql_read_dark_data,xvalue,yvalue,info
         endif

         if(info.jwst_control.file_reset_exist eq 1) then begin
            jwst_mql_read_reset_data,xvalue,yvalue,info
         endif

         if(info.jwst_control.file_rscd_exist eq 1) then begin
            jwst_mql_read_rscd_data,xvalue,yvalue,info
         endif

         if(info.jwst_control.file_lastframe_exist eq 1) then begin
            jwst_mql_read_lastframe_data,xvalue,yvalue,info
        endif

         jwst_mql_update_rampread,info

         Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info
      endif
   end
;_______________________________________________________________________
; Change automatically reading pixels values and plotting ramp data
;_______________________________________________________________________

    (strmid(event_name,0,4) EQ 'auto') : begin
        if(event.index eq 0) then begin 
            info.jwst_image.autopixelupdate = 1
                xs = 'Click on a pixel to plot ramp'
                ys = ' '
                widget_control,info.jwst_image.ramp_x_label, set_value=xs
                widget_control,info.jwst_image.ramp_y_label, set_value=ys    
            endif
        if(event.index ne 0) then info.jwst_image.autopixelupdate = 0

    end
;_______________________________________________________________________
;  Change the Zoom level for window 2
;_______________________________________________________________________

    (strmid(event_name,0,5) EQ 'zsize') : begin
        zsize = fix(strmid(event_name,5,1))
        if(zsize eq 1) then info.jwst_image.scale_zoom= 1.0
        if(zsize eq 2) then info.jwst_image.scale_zoom = 2.0
        if(zsize eq 3) then info.jwst_image.scale_zoom = 4.0
        if(zsize eq 4) then info.jwst_image.scale_zoom = 8.0
        if(zsize eq 5) then info.jwst_image.scale_zoom = 16.0
        if(zsize eq 6) then info.jwst_image.scale_zoom = 32.0
        info.jwst_image.x_zoom = info.jwst_image.x_zoom_pos
        info.jwst_image.y_zoom = info.jwst_image.y_zoom_pos

        jwst_mql_update_zoom_image,info
    
; need to redraw box (so redisplay with no box)
        if(info.jwst_image.current_graph eq 0) then jwst_mql_update_images,info
        if(info.jwst_image.current_graph eq 2) then jwst_mql_update_slope,info

        jwst_mql_draw_zoom_box,info

        widget_control,event.top,Set_UValue = ginfo
        Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info    
    end
;_______________________________________________________________________
; inspect image
    (strmid(event_name,0,9) EQ 'inspect_i') : begin

        i = info.jwst_image.integrationNO
        j = info.jwst_image.frameNO
        if(info.jwst_data.read_all eq 0) then begin
            i = 0
            if(info.jwst_data.num_frames ne info.jwst_data.ngroups) then begin 
                j = info.jwst_image.frameNO- info.jwst_control.frame_start
            endif
        endif

        info.jwst_inspect.integrationNO = info.jwst_image.integrationNO
        info.jwst_inspect.frameNO = info.jwst_image.frameNO
        frame_image = fltarr(info.jwst_data.image_xsize,info.jwst_data.image_ysize)
        frame_image[*,*] = (*info.jwst_data.pimagedata)[i,j,*,*]

        if ptr_valid (info.jwst_inspect.pdata) then ptr_free,info.jwst_inspect.pdata
        info.jwst_inspect.pdata = ptr_new(frame_image)
        frame_image = 0

        info.jwst_inspect.default_scale_graph = info.jwst_image.default_scale_graph[0]
        info.jwst_inspect.zoom = 1
        info.jwst_inspect.zoom_x = 1
        info.jwst_inspect.x_pos =(info.jwst_data.image_xsize)/2.0
        info.jwst_inspect.y_pos = (info.jwst_data.image_ysize)/2.0

        info.jwst_inspect.xposful = info.jwst_inspect.x_pos
        info.jwst_inspect.yposful = info.jwst_inspect.y_pos

        info.jwst_inspect.graph_range[0] = info.jwst_image.graph_range[0,0]
        info.jwst_inspect.graph_range[1] = info.jwst_image.graph_range[0,1]
        info.jwst_inspect.limit_low = -5000.0
        info.jwst_inspect.limit_high = 60000.0
        info.jwst_inspect.limit_low_num = 0
        info.jwst_inspect.limit_high_num = 0

        Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info

	jwst_miql_display_images,info
        Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info
    end

; inspect slope, slope int or calibration 
    (strmid(event_name,0,9) EQ 'inspect_s') : begin

       if(info.jwst_control.file_slope_exist eq 0 and info.jwst_image.data_type[2] eq 1) then begin
          ok = dialog_message(" No slope image exists",/Information)
          return
       endif

       if(info.jwst_control.file_slope_int_exist eq 0 and info.jwst_image.data_type[2] eq 2) then begin
          ok = dialog_message(" No slope int image exists",/Information)
          return
       endif

       if(info.jwst_control.file_cal_exist eq 0 and info.jwst_image.data_type[2] eq 3) then begin
          ok = dialog_message(" No calibration image exists",/Information)
          return
       endif

       i = info.jwst_image.integrationNO
       info.jwst_inspect_slope.integrationNO = info.jwst_image.integrationNO

       frame_image = fltarr(info.jwst_data.image_xsize,info.jwst_data.image_ysize)
       if(info.jwst_image.data_type[2] eq 1 ) then begin
          frame_image = (*info.jwst_data.preduced)
          info.jwst_inspect_slope.data_type = 1
          info.jwst_inspect_slope.plane = 0
       endif
       if(info.jwst_image.data_type[2] eq 2) then begin
          frame_image = (*info.jwst_data.preducedint)
          info.jwst_inspect_slope.data_type = 2
          info.jwst_inspect_slope.plane = 0
       endif
       if(info.jwst_image.data_type[2] eq 3) then begin
          frame_image = (*info.jwst_data.preduced_cal)
          info.jwst_inspect_slope.data_type = 3
          info.jwst_inspect_slope.plane = 0
       endif
       if ptr_valid (info.jwst_inspect_slope.pdata) then ptr_free,info.jwst_inspect_slope.pdata
       info.jwst_inspect_slope.pdata = ptr_new(frame_image)
       frame_image = 0

       Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info

       info.jwst_inspect_slope.zoom = 1
       info.jwst_inspect_slope.zoom_x = 1
       info.jwst_inspect_slope.x_pos =(info.jwst_data.slope_xsize)/2.0
       info.jwst_inspect_slope.y_pos = (info.jwst_data.slope_ysize)/2.0
        
       info.jwst_inspect_slope.xposful = info.jwst_inspect_slope.x_pos
       info.jwst_inspect_slope.yposful = info.jwst_inspect_slope.y_pos

       info.jwst_inspect_slope.graph_range[0] = info.jwst_image.graph_range[2,0]
       info.jwst_inspect_slope.graph_range[1] = info.jwst_image.graph_range[2,1]
       info.jwst_inspect_slope.default_scale_graph = info.jwst_image.default_scale_graph[2]
       
       info.jwst_inspect_slope.limit_low = -5000.0
       info.jwst_inspect_slope.limit_high = 70000.0
       info.jwst_inspect_slope.limit_low_num = 0
       info.jwst_inspect_slope.limit_high_num = 0

       info.jwst_inspect_slope.integrationNO = info.jwst_image.integrationNO
	jwst_misql_display_images,info
        Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info
    end
    
;_______________________________________________________________________
; histogram image raw
    (strmid(event_name,0,7) EQ 'histo_i') : begin
       win = 1
       jwst_mql_setup_histo,win,info
       jwst_mql_display_histo,win,info
        Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info
    end

    ; histogram zoom image
    (strmid(event_name,0,7) EQ 'histo_z') : begin
      
       win = 2
       jwst_mql_setup_histo,win,info
       jwst_mql_display_histo,win,info
        Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info
     end

    ; histogram rate image
    (strmid(event_name,0,7) EQ 'histo_s') : begin

       if(info.jwst_control.file_slope_exist eq 0 and info.jwst_image.data_type[2] eq 1) then begin
          ok = dialog_message(" No slope image exists",/Information)
          return
         endif
       
       if(info.jwst_control.file_slope_int_exist eq 0 and info.jwst_image.data_type[2] eq 2) then begin
          ok = dialog_message(" No slope int image exists",/Information)
          return
       endif

       if(info.jwst_control.file_cal_exist eq 0 and info.jwst_image.data_type[2] eq 3) then begin
          ok = dialog_message(" No calibration image exists",/Information)
          return
       endif
       win = 3

       jwst_mql_setup_histo,win,info
       jwst_mql_display_histo,win,info
        Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info
    end

else: print," Event name not found:", event_name
endcase

Widget_Control,ginfo.info.jwst_QuickLook,Set_UValue=info



end
