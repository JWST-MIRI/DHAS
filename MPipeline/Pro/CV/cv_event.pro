;_______________________________________________________________________

; the event manager for the cv.pro (main base widget)
pro cv_event,event


Widget_Control,event.id,Get_uValue=event_name
Widget_Control,event.top,Get_UValue=cinfo
eventName = TAG_NAMES(event,/STRUCTURE_NAME)
if (widget_info(event.id,/TLB_SIZE_EVENTS) eq 1 ) then begin
    
    xsize = event.x
    ysize = event.y
    if(xsize gt cinfo.control.max_x_screen) then xsize = cinfo.control.max_x_screen
    if(ysize gt cinfo.control.max_y_screen) then ysize = cinfo.control.max_y_screen


    widget_control,cinfo.cubeview,draw_xsize = xsize, draw_ysize=ysize
    Widget_Control,event.top,Set_UValue=cinfo

endif
if(eventName eq 'WIDGET_BUTTON') then begin 
    case event.id of
        cinfo.LoadCubeButton: begin

            
            if(XRegistered ('cv')) then begin
                print,'Exiting MIRI CubeView'
                close,/all
                widget_control,cinfo.CubeView,/destroy
            endif
            if (n_elements(info) EQ 0) then heap_gc
            cv
            return

        end

        
;_______________________________________________________________________

        cinfo.WaveButton: begin

            status = 0
            if(XRegistered ('surface')) then widget_control,cinfo.SurfacePlot,/destroy

            if(cinfo.do_centroid eq 1) then cv_cleanup_centroid,cinfo
            cinfo.imagetype = 0

            if(XRegistered ('add')) then widget_control,cinfo.CoaddSelect,/destroy
            widget_control,cinfo.imageDID, set_combobox_select = 0
            
            cinfo.lock_wavelength = 0
            widget_control,cinfo.lock_button1,Set_Button=0
            widget_control,cinfo.lock_button2,Set_Button=1

            cv_wavelength_options, cinfo

        end
;_______________________________________________________________________
; centroiding options

        cinfo.CentroidID: begin 

            if(XRegistered ('add') and cinfo.coadd.flag ne 3) then begin
                result = dialog_message(" You have not selected the wavelength range properly ",/info)
                cv_coadd_options,cinfo
                return
            endif

            cinfo.do_centroid = 1
            cinfo.centroid.rebin_factor = 1
            cv_centroid_setup_image,cinfo
            cv_centroid, cinfo
            if(XRegistered ('surface')) then cv_centroid_surface_display,cinfo
        end
        
        cinfo.CentroidParamID: begin
            if(XRegistered ('add') and cinfo.coadd.flag ne 3) then begin
                result = dialog_message(" You have not selected the wavelength range properly ",/info)
                cv_coadd_options,cinfo
                return
            endif

            if(cinfo.do_centroid eq 0) then begin
                cv_centroid_setup_image,cinfo 
                cv_centroid,cinfo 
            endif
            cinfo.centroid.rebin_factor = 1
            cv_centroid_surface_display,cinfo

        end



        cinfo.InfoCentroidID: begin 
            
            result= dialog_message(" Centroding works best from a Region of Interest that contains no NaN values." +$
                                   " Centroiding Algorithm written by  Craig B. Markward",/info) 
        end

        cinfo.InfoLockID: begin 
            
            result= dialog_message(" To lock the wavelength slice, use the mouse and click on desired wavelength in spectrum plot.")
        end


;_______________________________________________________________________
;_______________________________________________________________________
        cinfo.default_ScaleID: begin

            if(cinfo.default_scale eq 1) then begin ; true - turn to false
                widget_control,cinfo.default_scaleID,set_value = 'Default'
                if(cinfo.imagetype eq 0) then cinfo.default_scale = 0
                if(cinfo.imagetype ge 1) then cinfo.view_image2d.default_scale = 0
            endif

            if(cinfo.default_scale eq 0) then begin ; false - turn to true
                widget_control,cinfo.default_scaleID,set_value = 'Image Scale'
                if(cinfo.imagetype eq 0) then cinfo.default_scale = 1
                if(cinfo.imagetype ge 1) then cinfo.view_image2d.default_scale = 1
                
            endif
            if(cinfo.imagetype eq 0) then cv_update_cube,cinfo
            if(cinfo.imagetype ge 1) then cv_update_image2d,cinfo
        end

;_______________________________________________________________________
        cinfo.zoom1: begin
            widget_control,cinfo.zoom1,set_button=1            
            widget_control,cinfo.zoom2,set_button=0
            widget_control,cinfo.zoom4,set_button=0
            widget_control,cinfo.zoom8,set_button=0
            widget_control,cinfo.zoom16,set_button=0

            if(cinfo.imagetype eq 0) then begin 
                cinfo.view_cube.zoom_user = 1
                cv_update_cube,cinfo
                x1 = cinfo.spectrum.xcube_range[0]
                x2= cinfo.spectrum.xcube_range[1]
                y1 = cinfo.spectrum.ycube_range[0]
                y2= cinfo.spectrum.ycube_range[1]
                cube = cinfo.cube
                spectrum = cinfo.spectrum
                extract_spectrum_from_cube,x1,x2,y1,y2,cube,spectrum,status
            
                cinfo.cube = cube
                cinfo.spectrum = spectrum
                cv_update_spectrum,cinfo
            endif


            if(cinfo.imagetype ge 1) then begin
                cinfo.view_image2d.zoom_user =  1
                cv_update_image2d,cinfo
            endif
            if(XRegistered ('surface')) then begin
                cv_centroid_setup_image,cinfo
                cv_centroid_surface_update,cinfo
            endif

        end
       cinfo.zoom2: begin
           widget_control,cinfo.zoom1,set_button=0            
           widget_control,cinfo.zoom2,set_button=1
           widget_control,cinfo.zoom4,set_button=0
           widget_control,cinfo.zoom8,set_button=0
           widget_control,cinfo.zoom16,set_button=0

            if(cinfo.imagetype eq 0) then begin 
                cinfo.view_cube.zoom_user = 2
                cv_update_cube,cinfo
                x1 = cinfo.spectrum.xcube_range[0]
                x2= cinfo.spectrum.xcube_range[1]
                y1 = cinfo.spectrum.ycube_range[0]
                y2 =cinfo.spectrum.ycube_range[1]
                cube = cinfo.cube
                spectrum = cinfo.spectrum
                extract_spectrum_from_cube,x1,x2,y1,y2,cube,spectrum,status
                cinfo.cube = cube
                cinfo.spectrum = spectrum
                cv_update_spectrum,cinfo
            endif

            if(cinfo.imagetype ge 1) then begin 
                cinfo.view_image2d.zoom_user =  2
                cv_update_image2d,cinfo
            endif
            if(XRegistered ('surface')) then begin
                cv_centroid_setup_image,cinfo
                cv_centroid_surface_update,cinfo
            endif
        end
        cinfo.zoom4: begin
            widget_control,cinfo.zoom1,set_button=0            
            widget_control,cinfo.zoom2,set_button=0
            widget_control,cinfo.zoom4,set_button=1
            widget_control,cinfo.zoom8,set_button=0
            widget_control,cinfo.zoom16,set_button=0

            if(cinfo.imagetype eq 0) then begin 
                cinfo.view_cube.zoom_user = 4
                cv_update_cube,cinfo
                x1 = cinfo.spectrum.xcube_range[0]
                x2= cinfo.spectrum.xcube_range[1]
                y1 = cinfo.spectrum.ycube_range[0]
                y2= cinfo.spectrum.ycube_range[1]
                cube = cinfo.cube
                spectrum = cinfo.spectrum
                extract_spectrum_from_cube,x1,x2,y1,y2,cube,spectrum,status
                cinfo.cube = cube
                cinfo.spectrum = spectrum
                cv_update_spectrum,cinfo
            endif

            if(cinfo.imagetype ge 1) then begin 
                cinfo.view_image2d.zoom_user =  4
                cv_update_image2d,cinfo
            endif
            if(XRegistered ('surface')) then begin
                cv_centroid_setup_image,cinfo
                cv_centroid_surface_update,cinfo
            endif

        end
        cinfo.zoom8: begin
            widget_control,cinfo.zoom1,set_button=0            
            widget_control,cinfo.zoom2,set_button=0
            widget_control,cinfo.zoom4,set_button=0
            widget_control,cinfo.zoom8,set_button=1
            widget_control,cinfo.zoom16,set_button=0

            if(cinfo.imagetype eq 0) then begin 
                cinfo.view_cube.zoom_user = 8
                cv_update_cube,cinfo
                x1 = cinfo.spectrum.xcube_range[0]
                x2= cinfo.spectrum.xcube_range[1]
                y1 = cinfo.spectrum.ycube_range[0]
                y2= cinfo.spectrum.ycube_range[1]
                cube = cinfo.cube
                spectrum = cinfo.spectrum
                extract_spectrum_from_cube,x1,x2,y1,y2,cube,spectrum,status
                cinfo.cube = cube
                cinfo.spectrum = spectrum
                cv_update_spectrum,cinfo
            endif

            if(cinfo.imagetype ge 1) then begin 
                cinfo.view_image2d.zoom_user =  8
                cv_update_image2d,cinfo
            endif

            if(XRegistered ('surface')) then begin
                cv_centroid_setup_image,cinfo
                cv_centroid_surface_update,cinfo
            endif
        end
        cinfo.zoom16: begin
            widget_control,cinfo.zoom1,set_button=0            
            widget_control,cinfo.zoom2,set_button=0
            widget_control,cinfo.zoom4,set_button=0
            widget_control,cinfo.zoom8,set_button=0
            widget_control,cinfo.zoom16,set_button=1

            if(cinfo.imagetype eq 0) then begin
                cinfo.view_cube.zoom_user = 16
                cv_update_cube,cinfo
                x1 = cinfo.spectrum.xcube_range[0]
                x2= cinfo.spectrum.xcube_range[1]
                y1 = cinfo.spectrum.ycube_range[0]
                y2 =cinfo.spectrum.ycube_range[1]
                cube = cinfo.cube
                spectrum = cinfo.spectrum
                extract_spectrum_from_cube,x1,x2,y1,y2,cube,spectrum,status
                cinfo.cube = cube
                cinfo.spectrum = spectrum
                cv_update_spectrum,cinfo
            endif


            if(cinfo.imagetype ge 1) then begin 
                cinfo.view_image2d.zoom_user =  16
                cv_update_image2d,cinfo
            endif


            if(XRegistered ('surface')) then begin
                cv_centroid_setup_image,cinfo
                cv_centroid_surface_update,cinfo
            endif
        end


;_______________________________________________________________________
        cinfo.ViewHeaderButton: begin 
            cv_display_header,cinfo,0
                
        end
;_______________________________________________________________________
        cinfo.OptionsButton2: begin 
            if(cinfo.imagetype eq 0) then begin
                cinfo.view_cube.plot_pixel = 0
                cv_update_cube,cinfo
            endif

            if(cinfo.imagetype ge 1) then begin 
                cinfo.view_image2d.plot_pixel = 0
                cv_update_image2d,cinfo
            endif
        end
;-----------------------------------------------------------------------
        cinfo.OptionsButton1b: begin
            if(cinfo.view_cube.details_detector_coordinates eq 1) then begin
                cinfo.view_cube.details_detector_coordinates = 0
                widget_control,cinfo.optionsButton1b,set_button = 0
            endif else begin 
                if(cinfo.imagetype gt 0) then begin
                    result = dialog_message(" This option is not possible with a co-added wavelength image, only wavelength slice images",/info)
                    
                    return
                endif
                widget_control,cinfo.optionsButton1b,set_button = 1
                cinfo.view_cube.details_detector_coordinates = 1
            endelse
        end


;-----------------------------------------------------------------------
        cinfo.OptionsButton1: begin
            if(cinfo.view_cube.detector_coordinates eq 1) then begin
                cinfo.view_cube.detector_coordinates = 0
                cinfo.view_cube.plot_slope_image = 0
                widget_control,cinfo.optionsButton1,set_button = 0
            endif else begin 
;_______________________________________________________________________
                if(cinfo.imagetype ge 1) then begin
                    result = dialog_message(" This option is not possible with a co-added wavelength image, only wavelength slice images",/info)
                    
                    return
                endif

                if(cinfo.cube.Testmodel eq -1) then begin
                    result = dialog_message(" This is not possible with this cube. Re-run miri_cube with version 4.9 or higher. ",/info)
                    
                    return
                endif
                
                cinfo.view_cube.detector_coordinates = 1
                widget_control,cinfo.optionsButton1,set_button = 1
                if(cinfo.view_cube.read_d2c eq 0) then  begin
                    cfile = 'unknown'
                    cv_find_calibration_file, cinfo,cfile,status
                    if(status eq 0) then begin 
                        cv_read_calibration_file, cfile,alpha,lamba,sliceno,status
                        if(status eq 0) then begin 
                            if ptr_valid(cinfo.calibration.palpha) then ptr_free,cinfo.calibration.palpha
                            cinfo.calibration.palpha = ptr_new(alpha)
                            
                            if ptr_valid(cinfo.calibration.pwavelength) then ptr_free,cinfo.calibration.pwavelength
                            cinfo.calibration.pwavelength = ptr_new(lamba)
                            
                            if ptr_valid(cinfo.calibration.psliceno) then ptr_free,cinfo.calibration.psliceno
                            cinfo.calibration.psliceno = ptr_new(sliceno)

                            cinfo.view_cube.read_d2c = 1
                            cinfo.calibration.filename = cfile
                            alpha = 0
                            sliceno = 0
                            lamba = 0

                            x = fltarr(1033,1025)
                            y = x
                            for i = 0,1032 do begin
                                x[i,*] = i 
                            endfor
                            for i = 0,1024 do begin
                                y[*,i] = i 
                            endfor
                            if ptr_valid(cinfo.calibration.px) then ptr_free,cinfo.calibration.px
                            cinfo.calibration.px = ptr_new(x)
                            if ptr_valid(cinfo.calibration.py) then ptr_free,cinfo.calibration.py
                            cinfo.calibration.py = ptr_new(y)
                            x = 0
                            y = 0
                            

                            cv_find_xrange_channel,cinfo.cube.channel,cfile,xrange
                            cinfo.calibration.xrange = xrange
                        endif
                    endif else begin
                        cinfo.view_cube.detector_coordinates = 0
                    endelse
                endif

;_______________________________________________________________________
                if(cinfo.view_cube.read_slope_image eq 0) then  begin
                    sfile = 'unknown'
                    cv_find_image_file, cinfo,sfile,status
                    if(status eq 0) then begin 
                        cv_read_image_file, sfile, slopedata,naxis1,naxis2,naxis3,$
                                            cinfo.cube.extno,subarray,status
                        if(status eq 0) then begin 
                            if ptr_valid(cinfo.slope.pslope) then ptr_free,cinfo.slope.pslope
                            cinfo.slope.pslope = ptr_new(slopedata)
                            cinfo.slope.naxis1 = naxis1
                            cinfo.slope.naxis2 = naxis2
                            cinfo.slope.naxis3 = naxis3
                            cinfo.slope.subarray = subarray
                            cinfo.slope.filename = sfile
                            cinfo.view_cube.plot_slope_image = 1
                            slopedata = 0
                        endif else begin
                            cinfo.view_cube.plot_slope_image = 0
                        endelse
                    endif else begin
                        cinfo.view_cube.detector_coordinates = 0
                    endelse
                        

                endif
;_______________________________________________________________________
            endelse
        end
                            
;_______________________________________________________________________
        cinfo.roi_button1: begin

            widget_control,cinfo.roi_button2,Set_Button = 0
            cv_cleanup_centroid,cinfo
            if(XRegistered ('surface')) then widget_control,cinfo.SurfacePlot,/destroy
            cv_restore_full_image,cinfo
            cinfo.roi_image = 1
            widget_control,cinfo.roi_button1,Set_Button = 1
            widget_control,cinfo.roi_button2,Set_Button = 0
        end    

        cinfo.roi_button2: begin
            cinfo.roi_image = 0
            widget_control,cinfo.roi_button1,Set_Button = 0
        end    

        cinfo.roi_adjust_button: begin
            cv_adjust_roi,cinfo
        end    
        
        cinfo.full_cube_button: begin

            cv_restore_full_image,cinfo

        end    

;_______________________________________________________________________
; lock wavelength button 

        cinfo.lock_button1: begin

            cinfo.lock_wavelength = 1
            widget_control,cinfo.lock_button1,Set_Button = 1
            widget_control,cinfo.lock_button2,Set_Button = 0
        end    

        cinfo.lock_button2: begin
            cinfo.lock_wavelength = 0

            widget_control,cinfo.lock_button1,Set_Button = 0
            widget_control,cinfo.lock_button2,Set_Button = 1
        end    

;_______________________________________________________________________

    cinfo.PrintButtonP: begin 
        cv_spec_print,cinfo
    end    
;_______________________________________________________________________
    cinfo.PrintButtonD: begin 
        cv_spec_print_data,cinfo
    end    
;_______________________________________________________________________
    cinfo.PrintButtonI: begin 
        type = 0
        if(cinfo.imagetype eq 0) then type = 0
        if(cinfo.imagetype gt 0) then type = 1
        cv_print_image,cinfo,type
    end    
;_______________________________________________________________________

    cinfo.default_x_ID: begin 
        if(cinfo.view_spectrum.default_range[0] eq 1) then begin ; 
            widget_control,cinfo.default_x_ID,set_value = 'D efault    '
            cinfo.view_spectrum.default_range[0] = 0
        endif else begin
            widget_control,cinfo.default_x_ID,set_value = ' Plot Range '
            cinfo.view_spectrum.default_range[0] = 1
        endelse
        cv_update_spectrum,cinfo
    end

    cinfo.default_y_ID: begin 
        if(cinfo.view_spectrum.default_range[1] eq 1) then begin ; 
            widget_control,cinfo.default_y_ID,set_value = ' Default    '
            cinfo.view_spectrum.default_range[1] = 0
        endif else begin
            widget_control,cinfo.default_y_ID,set_value = ' Plot Range '
            cinfo.view_spectrum.default_range[1] = 1
        endelse
        cv_update_spectrum,cinfo
    end

;_______________________________________________________________________
else: print,'Event name not found"
    endcase

endif

;_______________________________________________________________________

;_______________________________________________________________________
if(eventName eq '') then begin
    case event.id of
        cinfo.rminLabelID: begin

            if(cinfo.imagetype eq 0) then begin 
                cinfo.graph_range[0] = event.value
                widget_control,cinfo.rmaxLabelID,get_value  = temp
                cinfo.graph_range[1] = temp
                cinfo.default_scale = 0
                widget_control,cinfo.default_scaleID,set_value = 'Default   '
                cv_update_cube,cinfo                              
            endif

            if(cinfo.imagetype gt 0) then begin 
                cinfo.view_image2d.image_scale[0] = event.value
                widget_control,cinfo.rmaxLabelID,get_value = temp
                cinfo.view_image2d.image_scale[1] = temp
                cinfo.view_image2d.default_scale = 0
                widget_control,cinfo.default_scaleID,set_value = 'Default   '
                cv_update_image2d,cinfo
            endif
        end
        cinfo.rmaxLabelID: begin
            if(cinfo.imagetype eq 0) then begin
                cinfo.graph_range[1] = event.value
                widget_control,cinfo.rminLabelID,get_value  = temp
                cinfo.graph_range[0] = temp
                cinfo.default_scale = 0
                widget_control,cinfo.default_scaleID,set_value = 'Default   '
                cv_update_cube,cinfo 
            endif

            if(cinfo.imagetype ge 1)then begin
                cinfo.view_image2d.image_scale[1] = event.value
                widget_control,cinfo.rminLabelID,get_value = temp
                cinfo.view_image2d.image_scale[0] = temp
                cinfo.view_image2d.default_scale = 0
                widget_control,cinfo.default_scaleID,set_value = 'Default   '
                cv_update_image2d,cinfo
            endif
        end

; Change the extracted spectrum graph ranges

    cinfo.range_x1_labelID: begin 
        cinfo.view_spectrum.graph_range[0,0] = event.value
        widget_control,cinfo.range_x2_labelID,get_value = temp
        cinfo.view_spectrum.graph_range[0,1] = temp

        cinfo.view_spectrum.default_range[0] = 0
        widget_control,cinfo.default_x_ID,set_value = 'Default'
        cv_update_spectrum,cinfo
    end

    cinfo.range_x2_labelID: begin 
        cinfo.view_spectrum.graph_range[0,1] = event.value
        widget_control,cinfo.range_x1_labelID,get_value = temp
        cinfo.view_spectrum.graph_range[0,0] = temp

        cinfo.view_spectrum.default_range[0] = 0
        widget_control,cinfo.default_x_ID,set_value = 'Default'
        cv_update_spectrum,cinfo
    end


    cinfo.range_y1_labelID: begin 
        cinfo.view_spectrum.graph_range[1,0] = event.value
        widget_control,cinfo.range_y2_labelID,get_value = temp
        cinfo.view_spectrum.graph_range[1,1] = temp

        cinfo.view_spectrum.default_range[1] = 0
        widget_control,cinfo.default_y_ID,set_value = 'Default'
        cv_update_spectrum,cinfo
    end

    cinfo.range_y2_labelID: begin 
        cinfo.view_spectrum.graph_range[1,1] = event.value
        widget_control,cinfo.range_y1_labelID,get_value = temp
        cinfo.view_spectrum.graph_range[1,0] = temp

        cinfo.view_spectrum.default_range[1] = 0
        widget_control,cinfo.default_y_ID,set_value = 'Default'
        cv_update_spectrum,cinfo
    end

    
;_______________________________________________________________________


    endcase
    
endif

;_______________________________________________________________________
if (eventName eq 'WIDGET_COMBOBOX') then begin
;_______________________________________________________________________

    case event.id of

        cinfo.ImageDID: begin 
            if(XRegistered ('surface')) then widget_control,cinfo.SurfacePlot,/destroy

            if(cinfo.do_centroid eq 1) then cv_cleanup_centroid,cinfo

            cinfo.imagetype = event.index

;-----------------------------------------------------------------------
            if(cinfo.imagetype eq 0) then begin 
                cinfo.imagetype = 0
	        cinfo.lock_wavelength  = 0
                if(XRegistered ('add')) then begin
                    widget_control,cinfo.CoaddSelect,/destroy
                endif
                if(XRegistered ('adjust')) then begin
                    widget_control,cinfo.AdjustROI,/destroy
                endif
                cinfo.default_scale = 1
                cv_update_cube,cinfo
                cv_draw_current_wavelength_copy,cinfo
            endif

;-----------------------------------------------------------------------
            if(cinfo.imagetype eq 1) then begin 

                if(XRegistered ('adjust')) then begin
                    widget_control,cinfo.AdjustROI,/destroy
                endif
                cinfo.view_image2d.default_scale = 1
                cv_coadd_options,cinfo
            endif

;-----------------------------------------------------------------------
            if(cinfo.imagetype eq 2) then begin 
                if(XRegistered ('adjust')) then begin
                    widget_control,cinfo.AdjustROI,/destroy
                endif
                if(XRegistered ('add')) then begin
                    widget_control,cinfo.CoaddSelect,/destroy
                endif
                x1 = (*cinfo.roi).roix1 
                y1 = (*cinfo.roi).roiy1 
                x2 = (*cinfo.roi).roix2 
                y2 = (*cinfo.roi).roiy2 

                x1_full = cinfo.cube.x1
                x2_full = cinfo.cube.x2
                y1_full = cinfo.cube.y1
                y2_full = cinfo.cube.y2

                cube = cinfo.cube
                image2d = cinfo.image2d
                collapse_wavelength,x1_full,x2_full,y1_full,y2_full,cube,image2d,status
                spectrum = cinfo.spectrum
                extract_spectrum_from_cube,x1,x2,y1,y2,cube,spectrum,status
                cinfo.cube = cube
                cinfo.image2d = image2d
                cinfo.spectrum = spectrum

                cinfo.view_image2d.image_min = cinfo.image2d.image_min
                cinfo.view_image2d.image_max = cinfo.image2d.image_max
                cinfo.coadd.flag = 3    
                cinfo.imagetype = 2        
                cv_display_image2d,cinfo

                
                cv_update_spectrum,cinfo
                cv_draw_coadd_lines,cinfo

                if(XRegistered ('surface')) then begin
                    cv_centroid_setup_image,cinfo
                    cv_centroid_surface_update,cinfo
                endif

            endif

            widget_control,cinfo.default_scaleID,set_value = 'Image Scale'



        end

;_______________________________________________________________________
        cinfo.value_lineID: begin 
            cinfo.view_spectrum.show_value_line = event.index + 1
            cv_update_spectrum,cinfo
        end



;_______________________________________________________________________
    cinfo.error_barsID: begin
        cinfo.view_spectrum.show_error_bars = event.index ; 
        cv_update_spectrum,cinfo
    end


;_______________________________________________________________________
    endcase
endif


;_______________________________________________________________________



widget_control,event.top,Set_UValue = cinfo
end

