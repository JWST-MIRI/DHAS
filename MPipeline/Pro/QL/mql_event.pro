@setup_Channel.pro
@mql_display_Channel.pro
@mql_display_histo.pro
; the event manager for the ql.pro (main base widget)
pro mql_event,event

Widget_Control,event.id,Get_uValue=event_name
widget_control,event.top, Get_UValue = ginfo
widget_control,ginfo.info.QuickLook,Get_Uvalue = info
update_single_plots =0
update_slope_plots = 0
iramp = info.image.rampNO
jintegration = info.image.integrationNO


if (widget_info(event.id,/TLB_SIZE_EVENTS) eq 1 ) then begin
    info.image.xwindowsize = event.x
    info.image.ywindowsize = event.y
    info.image.uwindowsize = 1
    widget_control,event.top,set_uvalue = ginfo
    widget_control,ginfo.info.Quicklook,set_uvalue = info
    mql_display_images,info
    return
endif
;    print,'event_name',event_name
    case 1 of

        
;_______________________________________________________________________
; analyze the slope image
    (strmid(event_name,0,5) EQ 'LoadS') : begin
        if(info.data.slope_exist eq 0) then begin 
            ok = dialog_message(" A Slope Image Does not exist",/Information)
        endif else begin
            slopedata = *info.data.preduced
            if ptr_valid (info.data.pslopedata) then ptr_free,info.data.pslopedata
            info.data.pslopedata = ptr_new(slopedata)
            slopedata  = 0
            info.data.slope_stat = info.data.reduced_stat
            msql_display_slope,info
        endelse
    end
;_______________________________________________________________________
; run pixel look
    (strmid(event_name,0,5) EQ 'PLook') : begin

        mpl_display,info
    end
;run miri_sloper 
    (strmid(event_name,0,9) EQ 'CalQSlope') : begin
        info.control.set_scidata = 1
	mql_setup_miri_sloper,info
        info.ms.quickslope = 1

        mql_run_miri_sloper,info,status
        if(status ne 0) then return

        info.image.integrationNO = info.control.int_num
        info.image.rampNO = info.control.frame_start
        reading_header,info,status,error_message	
        status = 0
        if(status eq 1) then return

        setup_frame_image_stepA,info
        info.image.x_pos =(info.data.image_xsize/info.image.binfactor)/2.0
        info.image.y_pos = (info.data.image_ysize/info.image.binfactor)/2.0
        setup_frame_pixelvalues,info
        setup_frame_image_stepB,info

        mql_display_images,info

    end


    (strmid(event_name,0,9) EQ 'CalDSlope') : begin
        info.control.set_scidata = 1
	mql_setup_miri_sloper,info

        mql_run_miri_sloper,info,status
        if(status ne 0) then return
        info.image.integrationNO = info.control.int_num
        info.image.rampNO = info.control.frame_start
        reading_header,info,status,error_message	
        status = 0
        if(status eq 1) then return

        setup_frame_image_stepA,info
        info.image.x_pos =(info.data.image_xsize/info.image.binfactor)/2.0
        info.image.y_pos = (info.data.image_ysize/info.image.binfactor)/2.0
        setup_frame_pixelvalues,info
        setup_frame_image_stepB,info

        mql_display_images,info

    end


    (strmid(event_name,0,8) EQ 'CalSlope') : begin

        info.control.set_scidata =1
	mql_setup_miri_sloper,info
        info.display_widget = 1
	mql_edit_miri_sloper_parameters,info
        return
    end


;_______________________________________________________________________

; display heder
    (strmid(event_name,0,7) EQ 'rheader') : begin
        display_header,info,0
    end

    (strmid(event_name,0,7) EQ 'sheader') : begin
        if(not info.data.slope_exist) then begin
            ok = dialog_message(" No slope image exists",/Information)
        endif else begin
            j = info.image.IntegrationNO
            display_header,info,j+1
        endelse

    end

    (strmid(event_name,0,7) EQ 'cheader') : begin
        if(not info.data.cal_exist) then begin
            ok = dialog_message(" No calibration image exists",/Information)
        endif else begin
            j = info.image.IntegrationNO
            display_header,info,info.data.nslopes+j+1
        endelse

    end
;_______________________________________________________________________
; analyze the reference output image
    (strmid(event_name,0,5) EQ 'LoadR') : begin

        i = info.image.integrationNO
        j = info.image.rampNO
        mirql_display_images,info.control.filename_raw,i,j,info
    end

    
;_______________________________________________________________________
; analyze border reference pixel data
    (strmid(event_name,0,5) EQ 'LoadP') : begin
        if(info.data.subarray ne 0 and info.data.colstart ne 1 ) then begin
            ok = dialog_message(" No reference pixels for this Subarray data",/Information)
        endif else begin
          read_refpixel,info
          info.refp.integrationNO = info.control.int_num
          info.refp.rampNO = info.control.frame_start
          mrp_setup_channel,info
          mrp_display,info
       endelse
    end
;_______________________________________________________________________
; Display science image split into 5 channel amplifier
    (strmid(event_name,0,10) EQ 'DisplayCHR') : begin

        info.channel.uwindowsize = 0
        setup_Channel,info,info.image.integrationNO, info.image.rampNO
        mql_display_Channel,info
    end


;_______________________________________________________________________

; Display slope image split into 5 channel amplifier
    (strmid(event_name,0,10) EQ 'DisplayCHS') : begin

        if(not info.data.slope_exist) then begin
            ok = dialog_message(" No slope image exists",/Information)
            ;return
        endif else begin

        if(info.data.nslopes lt info.image.integrationNO+1 ) then begin
            ok = dialog_message(" Partial Integration, no slope for this integration",/Information)
            return
        endif else begin
            status = 0
            setup_SlopeChannel,info,info.image.integrationNO,status,error_message
            if(status ne 0) then begin 
                ok = dialog_message(error_message,/Information)
                return
            endif
            info.Slopechannel.uwindowsize = 0
            mql_display_SlopeChannel,info
        endelse
        endelse
    end

;_______________________________________________________________________
;Subarray Geometry 
    (strmid(event_name,0,9) EQ 'sgeometry') : begin

        mql_plot_subarray_geo,info
    end

;_______________________________________________________________________
; Plot data value into of read out for each l amplifier
    (strmid(event_name,0,8) EQ 'ChannelT') : begin

        if(info.data.subarray ne 0) then begin
            ok = dialog_message(" Plotting Subarray data by readout time is not allowed now.  (Jane Morrison does not know the correct time to associate with each readout, if you do tell her: morrison@as.arizona.edu)",/Information)
            ;return
        endif else begin
        setup_ChannelTime,info,info.image.integrationNO, info.image.rampNO
        mql_display_TimeChannel,info
        endelse
    end

;_______________________________________________________________________
; Compare to another data file
    (strmid(event_name,0,7) EQ 'compare') : begin
        info.compare.uwindowsize = 0
        info.cinspect[*].uwindowsize = 1

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
            ok = dialog_message(" Image File does not exist, select filename again",/Information)
            status = 1
        endif else begin

        info.compare_image[0].filename  = info.control.filename_raw
        info.compare_image[1].filename  = filename

        read_data_type,info.compare_image[1].filename,type

        if(type ne 0) then begin 
            error = dialog_message(" The file must be a raw science file, select file again",/error)
            return
        endif
        
        info.compare_image[0].jintegration = info.image.integrationNO
        info.compare_image[1].jintegration = info.image.integrationNO

        info.compare_image[0].iramp = info.image.rampNO
        info.compare_image[1].iramp = info.image.rampNO
	mql_compare_display,info
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
	endelse
    end



;_______________________________________________________________________
; Compare current frame to another frame 
    (strmid(event_name,0,8) EQ 'fcompare') : begin

        info.compare.uwindowsize = 0
        info.cinspect[*].uwindowsize = 1
        this_frame = event.value-1
        if(this_frame lt 0) then this_frame = 0
        if(this_frame gt info.data.nramps-1  ) then this_frame = info.data.nramps-1
        info.compare_image[0].filename  = info.control.filename_raw
        info.compare_image[1].filename  = info.control.filename_raw
        info.compare_image[0].jintegration = info.image.integrationNO 
        info.compare_image[1].jintegration = info.image.integrationNO

        info.compare_image[0].iramp = info.image.rampNO 
        info.compare_image[1].iramp = this_frame

        print,'compare images',info.compare_image[0].iramp,info.compare_image[1].iramp
	mql_compare_display,info
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end
;_______________________________________________________________________
; Display statistics on the image 
    (strmid(event_name,0,4) EQ 'Stat') : begin
	mql_display_stat,info
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end
;_______________________________________________________________________
; Make a test report
    (strmid(event_name,0,7) EQ 'treport') : begin
        mql_test_report,info
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end
;_______________________________________________________________________
; print
    (strmid(event_name,0,5) EQ 'print') : begin
        if(strmid(event_name,6,1) eq 'R') then type = 0
        if(strmid(event_name,6,1) eq 'Z') then type = 1
        if(strmid(event_name,6,1) eq 'S') then type = 2
        if(strmid(event_name,6,1) eq 'P') then type = 3

        print_images,info,type
    end
;_______________________________________________________________________
; overplot slope
    (strmid(event_name,0,9) eq 'overslope') : begin
        num = fix(strmid(event_name,9,1))
        if(num eq 1) then begin
            if(info.data.slope_zsize le 1) then begin
                result = dialog_message(" Zero-pt plane does not exist in slope file, re-run miri_sloper",/info )

                widget_control,info.image.overplotSlopeID[0],set_button = 0
                widget_control,info.image.overplotSlopeID[1],set_button = 1
            endif else begin 
                info.image.overplot_slope = 1
                widget_control,info.image.overplotSlopeID[1],set_button = 0
                widget_control,info.image.overplotSlopeID[0],set_button = 1
            endelse
        endif

        if(num eq 2) then begin
            info.image.overplot_slope= 0
            widget_control,info.image.overplotSlopeID[0],set_button = 0
            widget_control,info.image.overplotSlopeID[1],set_button = 1
        endif
        mql_update_rampread,info
    end
;_______________________________________________________________________
; overplot reference corrected data

    (strmid(event_name,0,7) eq 'overref') : begin
        num = fix(strmid(event_name,7,1))
        if(num eq 1) then begin
            info.image.overplot_reference_corrected = 1
            widget_control,info.image.overplotrefcorrectedID[1],set_button = 0
            widget_control,info.image.overplotrefcorrectedID[0],set_button = 1

        endif

        if(num eq 2) then begin
            info.image.overplot_reference_corrected= 0
            widget_control,info.image.overplotrefcorrectedID[0],set_button = 0
            widget_control,info.image.overplotrefcorrectedID[1],set_button = 1
        endif

        mql_update_rampread,info
    end
;_______________________________________________________________________
; overplot noise and cosmic rays

    (strmid(event_name,0,6) eq 'overcr') : begin
        num = fix(strmid(event_name,6,1))
        if(num eq 1) then begin
            info.image.overplot_cr = 1
            widget_control,info.image.overplotcrID[1],set_button = 0
            widget_control,info.image.overplotcrID[0],set_button = 1

        endif

        if(num eq 2) then begin
            info.image.overplot_cr= 0
            widget_control,info.image.overplotcrID[0],set_button = 0
            widget_control,info.image.overplotcrID[1],set_button = 1
        endif


        mql_update_rampread,info
        
    end



;_______________________________________________________________________
; overplot linearity corrected data

    (strmid(event_name,0,6) eq 'overlc') : begin
        num = fix(strmid(event_name,6,1))
        if(num eq 1) then begin
            info.image.overplot_lc = 1
            widget_control,info.image.overplotLCID[1],set_button = 0
            widget_control,info.image.overplotLCID[0],set_button = 1

        endif

        if(num eq 2) then begin
            info.image.overplot_lc= 0
            widget_control,info.image.overplotLCID[0],set_button = 0
            widget_control,info.image.overplotLCID[1],set_button = 1
        endif
        mql_update_rampread,info
    end
;_______________________________________________________________________
; Plot linearity corrected data Result

    (strmid(event_name,0,7) eq 'plotrlc') : begin
        num = fix(strmid(event_name,7,1))
        if(num eq 1) then begin
            info.image.plot_lc_results = 1
            widget_control,info.image.plotRLCID[1],set_button = 0
            widget_control,info.image.plotRLCID[0],set_button = 1
        endif

        if(num eq 2) then begin
            info.image.plot_lc_results= 0
            widget_control,info.image.plotRLCID[0],set_button = 0
            widget_control,info.image.plotRLCID[1],set_button = 1
            return
        endif


        linearity_setup_pixel,info
        display_linearity_correction_results,info
    end
;_______________________________________________________________________
; overplot mean dark  corrected data

    (strmid(event_name,0,6) eq 'overmd') : begin
        num = fix(strmid(event_name,6,1))
        if(num eq 1) then begin
            info.image.overplot_mdc = 1
            widget_control,info.image.overplotMDCID[1],set_button = 0
            widget_control,info.image.overplotMDCID[0],set_button = 1

        endif

        if(num eq 2) then begin
            info.image.overplot_mdc= 0
            widget_control,info.image.overplotMDCID[0],set_button = 0
            widget_control,info.image.overplotMDCID[1],set_button = 1
        endif


        mql_update_rampread,info
        
    end
;_______________________________________________________________________
; overplot reset corrected data

    (strmid(event_name,0,9) eq 'overreset') : begin
        num = fix(strmid(event_name,9,1))
        if(num eq 1) then begin
            info.image.overplot_reset = 1
            widget_control,info.image.overplotresetID[1],set_button = 0
            widget_control,info.image.overplotresetID[0],set_button = 1

        endif
        if(num eq 2) then begin
            info.image.overplot_reset = 0
            widget_control,info.image.overplotresetID[0],set_button = 0
            widget_control,info.image.overplotresetID[1],set_button = 1
        endif
        mql_update_rampread,info
    end


;_______________________________________________________________________
; overplot rscd corrected data

    (strmid(event_name,0,8) eq 'overrscd') : begin
        num = fix(strmid(event_name,8,1))
        if(num eq 1) then begin
            info.image.overplot_rscd = 1
            widget_control,info.image.overplotrscdID[1],set_button = 0
            widget_control,info.image.overplotrscdID[0],set_button = 1

        endif
        if(num eq 2) then begin
            info.image.overplot_rscd = 0
            widget_control,info.image.overplotrscdID[0],set_button = 0
            widget_control,info.image.overplotrscdID[1],set_button = 1
        endif
        mql_update_rampread,info
    end


;_______________________________________________________________________
; overplot lastframe corrected data

    (strmid(event_name,0,13) eq 'overlastframe') : begin
        num = fix(strmid(event_name,13,1))
        if(num eq 1) then begin
            info.image.overplot_lastframe = 1
            widget_control,info.image.overplotlastframeID[1],set_button = 0
            widget_control,info.image.overplotlastframeID[0],set_button = 1

        endif
        if(num eq 2) then begin
            info.image.overplot_lastframe = 0
            widget_control,info.image.overplotlastframeID[0],set_button = 0
            widget_control,info.image.overplotlastframeID[1],set_button = 1
        endif
        mql_update_rampread,info
    end



;_______________________________________________________________________

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
;_______________________________________________________________________
   (strmid(event_name,0,8) EQ 'getframe') : begin
	x = info.image.x_pos * info.image.binfactor
	y = info.image.y_pos * info.image.binfactor


        ; check and see if read in all frame values for pixel
        ; if not then read in

; pixel frame sdata
        if (ptr_valid(info.image.pixeldata) eq 0) then begin ; has not been read in 
            mql_read_rampdata,x,y,pixeldata,info  
            info.image.pixeldata = ptr_new(pixeldata)
        endif

        pixeldata = (*info.image.pixeldata)
        size_data = size(pixeldata)
        if(size_data[0] eq 0) then return


        if ptr_valid (info.image_pixel.pixeldata) then ptr_free,info.image_pixel.pixeldata
        info.image_pixel.pixeldata = ptr_new(pixeldata)
        pixeldata = 0
        
; reference corrected data
        refcorrected_data = pixeldata
        refcorrected_data[*,*] = 0
        id_data = refcorrected_data
        lc_data = refcorrected_data
; fill in reference corrected data, if the file was written
        if(info.control.file_refcorrection_exist eq 1 ) then begin 
            if (ptr_valid(info.image.prefcorrected_pixeldata) eq 0) then begin ; has not been read in 
                mql_read_refcorrected_data,x,y,info
            endif
            refcorrected_data = (*info.image.prefcorrected_pixeldata)

            if ptr_valid (info.image_pixel.refcorrected_pixeldata) then $
              ptr_free,info.image_pixel.refcorrected_pixeldata
            info.image_pixel.refcorrected_pixeldata = ptr_new(refcorrected_data)        
            refcorrected_data = 0
        endif



; fill in the frame IDS, if the file was written
        if(info.control.file_ids_exist eq 1) then begin
            if (ptr_valid(info.image.pid_pixeldata) eq 0) then begin ; has not been read in 
                mql_read_id_data,x,y,info
            endif

 
            id_data = (*info.image.pid_pixeldata)
       
            if ptr_valid (info.image_pixel.id_pixeldata) then $
              ptr_free,info.image_pixel.id_pixeldata
            info.image_pixel.id_pixeldata = ptr_new(id_data)        
            id_data = 0
        endif        
; fill in the dark corrected data, if the file was written

        if(info.control.file_mdc_exist eq 1) then begin
            if (ptr_valid(info.image.pmdc_pixeldata) eq 0) then begin ; has not been read in 
                mql_read_mdc_data,x,y,info
            endif
 
            mdc_data = (*info.image.pmdc_pixeldata)

            if ptr_valid (info.image_pixel.mdc_pixeldata) then $
              ptr_free,info.image_pixel.mdc_pixeldata
            info.image_pixel.mdc_pixeldata = ptr_new(mdc_data)
            
            mdc_data = 0
         endif

; fill in the reset corrected data, if the file was written

        if(info.control.file_reset_exist eq 1) then begin
            if (ptr_valid(info.image.preset_pixeldata) eq 0) then begin ; has not been read in 
                mql_read_reset_data,x,y,info
            endif
            reset_data = (*info.image.preset_pixeldata)
            if ptr_valid (info.image_pixel.reset_pixeldata) then $
              ptr_free,info.image_pixel.reset_pixeldata
            info.image_pixel.reset_pixeldata = ptr_new(reset_data)
            reset_data = 0
         endif

; fill in the rscd corrected data, if the file was written

        if(info.control.file_rscd_exist eq 1) then begin
            if (ptr_valid(info.image.prscd_pixeldata) eq 0) then begin ; has not been read in 
                mql_read_rscd_data,x,y,info
            endif
            rscd_data = (*info.image.prscd_pixeldata)
            if ptr_valid (info.image_pixel.rscd_pixeldata) then $
              ptr_free,info.image_pixel.rscd_pixeldata
            info.image_pixel.rscd_pixeldata = ptr_new(rscd_data)
            rscd_data = 0
         endif

; fill in the lastframe corrected data, if the file was written

        if(info.control.file_lastframe_exist eq 1) then begin
            if (ptr_valid(info.image.plastframe_pixeldata) eq 0) then begin ; has not been read in 
                mql_read_lastframe_data,x,y,info
            endif
            lastframe_data = (*info.image.plastframe_pixeldata)
            if ptr_valid (info.image_pixel.lastframe_pixeldata) then $
              ptr_free,info.image_pixel.lastframe_pixeldata
            info.image_pixel.lastframe_pixeldata = ptr_new(lastframe_data)
            lastframe_data = 0
         endif

; fill in the linearity corrected data, if the file was written
        if(info.control.file_lc_exist eq 1) then begin 
            if (ptr_valid(info.image.plc_pixeldata) eq 0) then begin ; has not been read in 
                mql_read_lc_data,x,y,info
            endif
            lc_data = (*info.image.plc_pixeldata)

            if ptr_valid (info.image_pixel.lc_pixeldata) then $
              ptr_free,info.image_pixel.lc_pixeldata
            info.image_pixel.lc_pixeldata = ptr_new(lc_data)        
            lc_data = 0
            
        endif

; read in reference pixel data 
        ref_pixeldata = fltarr(info.data.nints,info.data.nramps,1)
        get_ref_pixeldata,info,1,x,y,ref_pixeldata
        if ptr_valid (info.image_pixel.ref_pixeldata) then $
          ptr_free,info.image_pixel.ref_pixeldata
        info.image_pixel.ref_pixeldata = ptr_new(ref_pixeldata)
        


        info.image_pixel.file_ids_exist  = info.control.file_ids_exist 
        info.image_pixel.file_lc_exist  = info.control.file_lc_exist 
        info.image_pixel.file_mdc_exist  = info.control.file_mdc_exist 
        info.image_pixel.file_reset_exist  = info.control.file_reset_exist 
        info.image_pixel.file_rscd_exist  = info.control.file_rscd_exist 
        info.image_pixel.file_lastframe_exist  = info.control.file_lastframe_exist 
        info.image_pixel.file_refcorrection_exist = info.control.file_refcorrection_exist 

        info.image_pixel.start_fit = info.image.start_fit
        info.image_pixel.end_fit = info.image.end_fit
        info.image_pixel.nints = info.data.nints
        info.image_pixel.integrationNo = info.image.integrationNO
        info.image_pixel.nframes = info.data.nramps
        info.image_pixel.nslopes = info.data.nslopes
        info.image_pixel.slope_exist = info.data.slope_exist
        info.image_pixel.filename = info.control.filename_raw
        if(info.image_pixel.slope_exist) then begin 
            info.image_pixel.slope = (*info.data.preduced)[x,y,0]
            if(info.data.slope_zsize eq 2) or info.data.slope_zsize eq 3 then begin
                info.image_pixel.zeropt =  (*info.data.preduced)[x,y,1]

                info.image_pixel.uncertainty  =0
                info.image_pixel.quality_flag = 0
                info.image_pixel.ngood =  0
                info.image_pixel.nframesat = 0
                info.image_pixel.ngoodseg = 0
            endif else begin 
                info.image_pixel.uncertainty  = (*info.data.preduced)[x,y,1]
                info.image_pixel.quality_flag =  (*info.data.preduced)[x,y,2]
                info.image_pixel.zeropt =  (*info.data.preduced)[x,y,3]
                info.image_pixel.ngood =  (*info.data.preduced)[x,y,4]
                info.image_pixel.nframesat =  (*info.data.preduced)[x,y,5]
                info.image_pixel.ngoodseg = 0
                info.image_pixel.ngoodseg =  (*info.data.preduced)[x,y,6]
            endelse

        endif
        display_frame_values,x,y,info,0
        
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
       if(jintegration lt 0) then jintegration = info.data.nints-1 ; loop back around
       if(jintegration gt info.data.nints-1 ) then jintegration = 0 ; loop back
       
        widget_control,info.image.integration_label,set_value= fix(jintegration+1)

	; check the frame value
        widget_control,info.image.frame_label,get_value =  temp
	temp = temp-1	
        if(temp lt 0) then temp = info.data.nramps-1 ; loop back around
        if(temp gt info.data.nramps-1  ) then  temp = 0 ; loop back around 
	iramp = temp
	widget_control,info.image.frame_label,set_value = iramp+1
	

	mql_moveframe,jintegration,iramp,info
        
        mql_update_pixel_stat,info
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
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

        if(iramp lt 0) then iramp = info.data.nramps-1 ; loop back around
        if(iramp gt info.data.nramps-1  ) then  iramp = 0 ; loop back around 

        widget_control,info.image.frame_label,set_value= fix(iramp+1)

	; check the integration value
        widget_control,info.image.integration_label,get_value =  temp
	temp = temp-1	
        if(temp lt 0) then temp = info.data.nints-1 ; loop back around
        if(temp gt info.data.nints-1  ) then  temp = 0 ; loop back around 
	jintegraion = temp
	widget_control,info.image.integration_label,set_value = jintegration+1


	mql_moveframe,jintegration,iramp,info
        mql_update_pixel_stat,info
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end	

;_______________________________________________________________________
; Select a different pixel 
;_______________________________________________________________________
    (strmid(event_name,0,3) EQ 'pix') : begin

        xsize = info.data.image_xsize
        ysize = info.data.image_ysize

        xvalue = info.image.x_pos* info.image.binfactor
        yvalue = info.image.y_pos* info.image.binfactor
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
            widget_control,info.image.pix_label[1],get_value =  ytemp
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
            widget_control,info.image.pix_label[0], get_value= xtemp
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
            if(xvalue ge  info.data.image_xsize) then xvalue = info.data.image_xsize-1
            if(yvalue ge  info.data.image_ysize) then yvalue = info.data.image_ysize-1

            pixel_xvalue= xvalue
            pixel_yvalue = yvalue

            widget_control,info.image.pix_label[0],set_value=pixel_xvalue+1
            widget_control,info.image.pix_label[1],set_value=pixel_yvalue+1

        endif

; ++++++++++++++++++++++++++++++

        info.image.x_pos = float(pixel_xvalue)/float(info.image.binfactor)
        info.image.y_pos = float(pixel_yvalue)/float(info.image.binfactor)

        mql_update_pixel_stat,info
        xmove = (pixel_xvalue - xstart)/float(info.image.binfactor)
        ymove = (pixel_yvalue - ystart)/float(info.image.binfactor)

        graphno = [0,2]
        for i = 0,1  do begin 
            info.image.current_graph = graphno[i]
            mql_update_pixel_location,info  ; update pixel location on graph windows
        endfor

; read information on the new pixel 
        if(info.image.autopixelupdate eq 1)then begin
            mql_read_rampdata,pixel_xvalue,pixel_yvalue,pixeldata,info  

            if ptr_valid (info.image.pixeldata) then ptr_free,info.image.pixeldata
            info.image.pixeldata = ptr_new(pixeldata)
        endif

; read slope data for pixel
        mql_read_slopedata,pixel_xvalue,pixel_yvalue,info  
        
; read reference corrected data if file was created
        if(info.control.file_refcorrection_exist eq 1)then $
          mql_read_refcorrected_data,pixel_xvalue,pixel_yvalue,info

; fill in the frame IDS, if the file was written
        if(info.control.file_ids_exist eq 1) then begin
            mql_read_id_data,pixel_xvalue,pixel_yvalue,info
        endif


; fill in the frame LC , if the file was written
        if(info.control.file_lc_exist eq 1)then begin
            mql_read_lc_data,pixel_xvalue,pixel_yvalue,info
        endif

; fill in the frame MCD, if the file was written
        if(info.control.file_mdc_exist eq 1)then begin
            mql_read_mdc_data,pixel_xvalue,pixel_yvalue,info
        endif

         mql_update_rampread,info                     

; fill in the reset, if the file was written
        if(info.control.file_reset_exist eq 1)then begin
            mql_read_reset_data,pixel_xvalue,pixel_yvalue,info
         endif

; fill in the reset, if the file was written
        if(info.control.file_rscd_exist eq 1)then begin
            mql_read_rscd_data,pixel_xvalue,pixel_yvalue,info
         endif

; fill in the lastframe, if the file was written
        if(info.control.file_lastframe_exist eq 1)then begin
            mql_read_lastframe_data,pixel_xvalue,pixel_yvalue,info
        endif
         mql_update_rampread,info                     

; update the pixel in the zoom window
        
        info.image.x_zoom = pixel_xvalue 
        info.image.y_zoom = pixel_yvalue 
        
        if(info.image.x_zoom ge xsize) then info.image.x_zoom = xsize -1 
        if(info.image.y_zoom ge ysize) then info.image.y_zoom = ysize - 1
         mql_update_zoom_image,info

; If the Frame values for pixel window is open - destroy
        if(XRegistered ('mpixel')) then begin
            widget_control,info.RPixelInfo,/destroy

        endif

       if(XRegistered ('lcr')) then begin
           linearity_setup_pixel,info
           update_info,info
           update_linearity_difference,info
           update_linearity_result,info
       endif


        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end

;_______________________________________________________________________
; change range of image graphs
; if change range then also change the scale button to 'User Set
; Scale'
;_______________________________________________________________________
    (strmid(event_name,0,2) EQ 'sr') : begin
        graph_num = fix(strmid(event_name,2,1))-1
        
        if(strmid(event_name,4,1) EQ 'b') then begin ; min
            info.image.graph_range[graph_num,0] = event.value
            widget_control,info.image.rlabelID[graph_num,1],get_value = temp
            info.image.graph_range[graph_num,1] = temp
        endif

        if(strmid(event_name,4,1) EQ 't') then begin ; max
            info.image.graph_range[graph_num,1] = event.value
            widget_control,info.image.rlabelID[graph_num,0],get_value = temp
            info.image.graph_range[graph_num,0] = temp
        endif
        info.image.default_scale_graph[graph_num] = 0
        widget_control,info.image.image_recomputeID[graph_num],set_value='Default Scale'

        if(graph_num eq 0) then mql_update_images,info
        if(graph_num eq 1) then mql_update_zoom_image,info
        if(graph_num eq 2) then mql_update_slope,info
    end

;_______________________________________________________________________
; scaling image and slope
;_______________________________________________________________________
    (strmid(event_name,0,5) EQ 'scale') : begin

        graphno = fix(strmid(event_name,5,1))

        if(info.image.default_scale_graph[graphno-1] eq 0 ) then begin ; true - turn to false
            widget_control,info.image.image_recomputeID[graphno-1],set_value='Image Scale'
            info.image.default_scale_graph[graphno-1] = 1
        endif

	if(graphno eq 1)then  $
        mql_update_images,info
	if(graphno eq 2)then  $
        mql_update_zoom_image,info
	if(graphno eq 3)then  $
        mql_update_slope,info
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end

;_______________________________________________________________________
;_______________________________________________________________________
; change x and y range of ramp graph 
;_______________________________________________________________________
    (strmid(event_name,0,7) EQ 'ramp_mm') : begin
        if(strmid(event_name,7,1) EQ 'x') then graphno = 0 else graphno = 1 
        if(strmid(event_name,7,2) EQ 'x1') then begin
            info.image.ramp_range[0,0]  = event.value
            widget_control,info.image.ramp_mmlabel[0,1],get_value = temp
            info.image.ramp_range[0,1]  = temp
        endif
        if(strmid(event_name,7,2) EQ 'x2') then begin
            info.image.ramp_range[0,1]  = event.value
            widget_control,info.image.ramp_mmlabel[0,0],get_value = temp
            info.image.ramp_range[0,0]  = temp
        endif
        if(strmid(event_name,7,2) EQ 'y1') then begin
            info.image.ramp_range[1,0]  = event.value
            widget_control,info.image.ramp_mmlabel[1,1],get_value = temp
            info.image.ramp_range[1,1]  = temp
        endif
        if(strmid(event_name,7,2) EQ 'y2') then  begin
            info.image.ramp_range[1,1]  = event.value
            widget_control,info.image.ramp_mmlabel[1,0],get_value = temp
            info.image.ramp_range[1,0]  = temp
        endif

        info.image.default_scale_ramp[graphno] = 0
        widget_control,info.image.ramp_recomputeID[graphno],set_value='Default Range'

        mql_update_rampread,info
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end
    
;_______________________________________________________________________
; set the Default range or user defined range for ramp plot
    (strmid(event_name,0,1) EQ 'r') : begin
        graphno = fix(strmid(event_name,1,1))
        if(info.image.default_scale_ramp[graphno-1] eq 0 ) then begin ; true - turn to false
            widget_control,info.image.ramp_recomputeID[graphno-1],set_value=' Plot Range '
            info.image.default_scale_ramp[graphno-1] = 1
        endif

        mql_update_rampread,info
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end
;_______________________________________________________________________
; Change Integration Range  For Ramp Plots
;_______________________________________________________________________

    (strmid(event_name,0,3) EQ 'int') : begin
; changed by typing a new value
        
        if(strmid(event_name,4,4) eq 'chng') then begin
            num = fix(strmid(event_name,9,1))-1
            info.image.int_range[num] = event.value
        endif


; check if the <> buttons were used
        if(strmid(event_name,4,4) eq 'move') then begin
            value = intarr(2)
            value[0] = info.image.int_range[0]
            value[1] = info.image.int_range[1]

            if(strmid(event_name,9,1) eq 'u') then begin
                value[0] = value[0] + 1
                value[1] = value[1] + 1
            endif
            if(strmid(event_name,9,1) eq 'd') then begin
                value[0] = value[0] - 1
                value[1] = value[1] -1
            endif

            info.image.int_range[0] = value[0]            
            info.image.int_range[1] = value[1]            
        endif

; check if plot all integrations is typed

        if(strmid(event_name,4,4) eq 'grab') then begin
            info.image.int_range[0] = 1            
            info.image.int_range[1] = info.data.nints
            info.image.overplot_pixel_int = 0
        endif            

; check if overplot integrations 

        if(strmid(event_name,4,4) eq 'over') then begin
            info.image.int_range[0] = 1            
            info.image.int_range[1] = info.data.nints
            info.image.overplot_pixel_int = 1
        endif            


; Check limits for the above options for changing the integration range
; lower limit 1
; upper limit ginfo.data.nints

        for i = 0,1 do begin
            if(info.image.int_range[i] le 0) then info.image.int_range[i] = 1
            if(info.image.int_range[i] gt info.data.nints) then $
              info.image.int_range[i] = info.data.nints
        endfor
        if(info.image.int_range[0] gt info.image.int_range[1] ) then begin
            info.image.int_range[*] = 1
        endif	
	
        mql_update_rampread,info
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end

;_______________________________________________________________________
; Select a different pixel to report the values of
; event is generated for button pushing down and button release.
; only need this called once
;_______________________________________________________________________

   (strmid(event_name,0,8) EQ 'mqlpixel') : begin
       if(event.type eq 1) then begin
           graphnum = fix(strmid(event_name,8,1))

           if(graphnum ne 2) then info.image.graph_mpixel=graphnum 

           xvalue = event.x     ; starts at 0
           yvalue = event.y     ; starts at 0

           xlimit = info.data.image_xsize/info.image.binfactor
           ylimit = info.data.image_ysize/info.image.binfactor
           if(xvalue ge xlimit) then xvalue = xlimit-1
           if(yvalue ge ylimit) then yvalue = ylimit-1

; did not click on zoom image- so update the zoom image
           if(graphnum ne 2) then  begin 
               info.image.x_zoom = xvalue * info.image.binfactor
               info.image.y_zoom = yvalue * info.image.binfactor

               if(info.image.x_zoom ge info.data.image_xsize) then $
                 info.image.x_zoom = info.data.image_xsize-1
               if(info.image.y_zoom ge info.data.image_ysize) then $
                 info.image.y_zoom = info.data.image_ysize -1
              mql_update_zoom_image,info

               info.image.x_pos = xvalue 
               info.image.y_pos = yvalue
           endif


; clicked on the zoom image - so update the pixel in the zoom image 
           if(graphnum eq 2) then  begin
               x = (xvalue)/info.image.scale_zoom
               y = (yvalue)/info.image.scale_zoom
               if(x ge info.data.image_xsize) then x = info.data.image_xsize-1
               if(y ge info.data.image_ysize) then y = info.data.image_ysize-1
               xvalue = x * info.image.scale_zoom
               yvalue = y * info.image.scale_zoom

               update = 1

               mql_update_zoom_pixel_location,xvalue,yvalue,update,info

               ; redefine the center of the zoom image - if later
               ; want to zoom: x_zoom_pos & y_zoom_pos  
               
               x = (xvalue)/info.image.scale_zoom
               y = (yvalue)/info.image.scale_zoom
               x = x + info.image.x_zoom_start - info.image.ixstart_zoom
               y = y + info.image.y_zoom_start - info.image.iystart_zoom

               if(x gt info.data.image_xsize) then  x = info.data.image_xsize
               if(y gt info.data.image_ysize) then y = info.data.image_ysize

               info.image.x_zoom_pos = x
               info.image.y_zoom_pos = y

               if(info.image.x_zoom_pos ge info.data.image_xsize) then $
               info.image.x_zoom_pos = info.data.image_xsize
               if(info.image.y_zoom_pos ge info.data.image_ysize) then $
                 info.image.y_zoom_pos = info.data.image_ysize

           endif
; update the pixel locations in graphs 1, 3

           graphno = [0,2]
           for i = 0,1 do begin 
               info.image.current_graph = graphno[i]
               mql_update_pixel_location,info
           endfor

; update the pixel information on main window
           mql_update_pixel_stat,info
	   x = info.image.x_pos * info.image.binfactor	
	   y = info.image.y_pos * info.image.binfactor	
	   widget_control,info.image.pix_label[0],set_value = x+1
	   widget_control,info.image.pix_label[1],set_value = y+1

; If the Frame values for pixel window is open - destroy
           if(XRegistered ('mpixel')) then begin
               widget_control,info.RPixelInfo,/destroy
           endif

; Draw a box around the pixel - showing the zoom window size 

           if(info.image.graph_mpixel ne 2) then  begin ;
               info.image.current_graph = info.image.graph_mpixel-1
               mql_draw_zoom_box,info
           endif

; load individual ramp graph - based on x_pos, y_pos
           xvalue = info.image.x_pos*info.image.binfactor
           yvalue = info.image.y_pos*info.image.binfactor
           if(info.image.autopixelupdate eq 1) then begin
               mql_read_rampdata,xvalue,yvalue,pixeldata,info
               if ptr_valid (info.image.pixeldata) then ptr_free,info.image.pixeldata
               info.image.pixeldata = ptr_new(pixeldata)
           endif

           
           mql_read_slopedata,xvalue,yvalue,info

; read reference corrected data if file was created
           if(info.control.file_refcorrection_exist eq 1) then $
             mql_read_refcorrected_data,xvalue,yvalue,info

; fill in the frame IDS, if the file was written
        if(info.control.file_ids_exist eq 1 ) then begin
            mql_read_id_data,xvalue,yvalue,info
        endif

; fill in the linearity corrected data, if the file was written
        if(info.control.file_lc_exist eq 1) then begin
            mql_read_lc_data,xvalue,yvalue,info
        endif

        if(info.control.file_mdc_exist eq 1) then begin
            mql_read_mdc_data,xvalue,yvalue,info
         endif

        if(info.control.file_reset_exist eq 1) then begin
            mql_read_reset_data,xvalue,yvalue,info
         endif

        if(info.control.file_rscd_exist eq 1) then begin
            mql_read_rscd_data,xvalue,yvalue,info
         endif

        if(info.control.file_lastframe_exist eq 1) then begin
            mql_read_lastframe_data,xvalue,yvalue,info
        endif

        mql_update_rampread,info

           Widget_Control,ginfo.info.QuickLook,Set_UValue=info
       endif

       if(XRegistered ('lcr')) then begin
           linearity_setup_pixel,info
           update_info,info
           update_linearity_difference,info
           update_linearity_result,info
       endif
   end
   
;_______________________________________________________________________
; Plotting options: histogram: column slice: comparison to test image
;_______________________________________________________________________

    (strmid(event_name,0,6) EQ 'option') : begin
        graphnum = fix(strmid(event_name,6,1))
        type = graphnum -1 
        slope_exist = info.data.slope_exist
        if(info.image.integrationNO+1 gt info.data.nslopes) then slope_exist = 0


        if(type eq 2 and not slope_exist) then begin
            ok = dialog_message(" A Slope Image Does not exist",/Information)
            return
        endif
        
        if(event.index eq 1) then begin ; histogram
            mql_setup_hist,type,info
            mql_display_histo,type,info

        endif
        if(event.index eq 2) then begin ; column slice
            mql_setup_colslice,type,info
            mql_display_colslice,type,info  

        endif
        if(event.index eq 3) then begin  ; row slice 
            mql_setup_rowslice,type,info
            mql_display_rowslice,type,info

        endif


        if(event.index eq 4) then begin
            ok = dialog_message(" Comparsion to Test Image, coming soon, waiting for test image",/Information)
        endif

        widget_control,info.image.optionMenu[type],set_droplist_select=0
    end
    
;_______________________________________________________________________
; Change automatically reading pixels values and plotting ramp data
;_______________________________________________________________________

    (strmid(event_name,0,4) EQ 'auto') : begin
        if(event.index eq 0) then begin 
            info.image.autopixelupdate = 1
                xs = 'Click on a pixel to plot ramp'
                ys = ' '
                widget_control,info.image.ramp_x_label, set_value=xs
                widget_control,info.image.ramp_y_label, set_value=ys    
            endif
        if(event.index ne 0) then info.image.autopixelupdate = 0

    end
;_______________________________________________________________________
;_______________________________________________________________________
;  Change the Zoom level for window 2
;_______________________________________________________________________
    (strmid(event_name,0,5) EQ 'zsize') : begin
        zsize = fix(strmid(event_name,5,1))
        if(zsize eq 1) then info.image.scale_zoom= 1.0
        if(zsize eq 2) then info.image.scale_zoom = 2.0
        if(zsize eq 3) then info.image.scale_zoom = 4.0
        if(zsize eq 4) then info.image.scale_zoom = 8.0
        if(zsize eq 5) then info.image.scale_zoom = 16.0
        if(zsize eq 6) then info.image.scale_zoom = 32.0
        info.image.x_zoom = info.image.x_zoom_pos
        info.image.y_zoom = info.image.y_zoom_pos

        mql_update_zoom_image,info
    
; need to redraw box (so redisplay with no box)
        if(info.image.current_graph eq 0) then mql_update_images,info
        if(info.image.current_graph eq 2) then mql_update_slope,info


        mql_draw_zoom_box,info

        widget_control,event.top,Set_UValue = ginfo
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info    
    end
;_______________________________________________________________________
; inspect image
    (strmid(event_name,0,9) EQ 'inspect_i') : begin

        i = info.image.integrationNO
        j = info.image.rampNO
        if(info.data.read_all eq 0) then begin
            i = 0
            if(info.data.num_frames ne info.data.nramps) then begin 
                j = info.image.rampNO- info.control.frame_start
            endif
        endif

        info.inspect.integrationNO = info.image.integrationNO
        info.inspect.frameNO = info.image.rampNO
        frame_image = fltarr(info.data.image_xsize,info.data.image_ysize)
        frame_image[*,*] = (*info.data.pimagedata)[i,j,*,*]


        if ptr_valid (info.inspect.pdata) then ptr_free,info.inspect.pdata
        info.inspect.pdata = ptr_new(frame_image)
        frame_image = 0

        info.inspect.default_scale_graph = info.image.default_scale_graph[0]
        info.inspect.zoom = 1
        info.inspect.zoom_x = 1
        info.inspect.x_pos =(info.data.image_xsize)/2.0
        info.inspect.y_pos = (info.data.image_ysize)/2.0

        info.inspect.xposful = info.inspect.x_pos
        info.inspect.yposful = info.inspect.y_pos

        info.inspect.graph_range[0] = info.image.graph_range[0,0]
        info.inspect.graph_range[1] = info.image.graph_range[0,1]
        info.inspect.limit_low = -5000.0
        info.inspect.limit_high = 60000.0
        info.inspect.limit_low_num = 0
        info.inspect.limit_high_num = 0

        Widget_Control,ginfo.info.QuickLook,Set_UValue=info

	miql_display_images,info
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end

; inspect slope  image
    (strmid(event_name,0,9) EQ 'inspect_s') : begin
        if(not info.data.slope_exist) then begin
            ok = dialog_message(" No slope image exists",/Information)
            return
        endif

        i = info.image.integrationNO
        info.inspect_slope.integrationNO = info.image.integrationNO

        info.slope.plane_cal = -1
        image = fltarr(info.data.slope_xsize,info.data.slope_ysize)
        image[*,*] = (*info.data.preduced)[*,*,0]

        if ptr_valid (info.inspect_slope.pdata) then ptr_free,info.inspect_slope.pdata
        info.inspect_slope.pdata = ptr_new(image)
        image = 0


        all_data = (*info.data.preduced)
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

        info.inspect_slope.zoom = 1
        info.inspect_slope.zoom_x = 1
        info.inspect_slope.x_pos =(info.data.slope_xsize)/2.0
        info.inspect_slope.y_pos = (info.data.slope_ysize)/2.0

        info.inspect_slope.xposful = info.inspect_slope.x_pos
        info.inspect_slope.yposful = info.inspect_slope.y_pos

        info.inspect_slope.graph_range[0] = info.image.graph_range[2,0]
        info.inspect_slope.graph_range[1] = info.image.graph_range[2,1]
        info.inspect_slope.default_scale_graph = info.image.default_scale_graph[2]

        info.inspect_slope.limit_low = -5000.0
        info.inspect_slope.limit_high = 70000.0
        info.inspect_slope.limit_low_num = 0
        info.inspect_slope.limit_high_num = 0
        info.inspect_slope.start_fit = info.image.start_fit
        info.inspect_slope.end_fit = info.image.end_fit
        info.inspect_slope.integrationNO = info.image.integrationNO
        info.inspect_slope.plane = 0
	misql_display_images,info
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end


;_______________________________________________________________________

    (strmid(event_name,0,3) EQ 'bad') : begin

        num = fix(strmid(event_name,3,1))
        if(num eq 1) then begin
            info.image.apply_bad = 1
            widget_control,info.image.BadButton[0],set_button = 1
            widget_control,info.image.BadButton[1],set_button = 0
        endif

        if(num eq 2) then begin
            info.image.apply_bad = 0
            widget_control,info.image.BadButton[0],set_button = 0
            widget_control,info.image.BadButton[1],set_button = 1
        endif


; if appying dead pixel mask and 
; if the dead pixel mask has not been read in read it in
        if(info.image.apply_bad eq 1 and info.badpixel.readin eq 0) then begin 
            read_dead_pixels,info,info.badpixel.file,bad_file_exist,$
                             numbad,bad_mask,status,error_message

            info.badpixel.file_exist = bad_file_exist
            if(status eq 0) then begin 
                info.badpixel.num = numbad
                if prt_valid(info.badpixel.pmask) then ptr_free,info.badpixel.pmask
                info.badpixel.pmask = ptr_new(bad_mask)
                bad_mask = 0 

            endif 
            if(status ne 0) then begin
                info.image.apply_bad=0
                print,'Turning off Apply bad Pixel Mask'
            endif
        endif

        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
        mql_update_images,info
        mql_update_zoom_image,info
        mql_update_pixel_stat,info
    end

;_______________________________________________________________________

else: print," Event name not found:", event_name
endcase

Widget_Control,ginfo.info.QuickLook,Set_UValue=info
; update single widget plots
;_______________________________________________________________________
; if histogram plots up - replot

if(update_single_plots) then begin 
    if(XRegistered ('mqlhr')) then begin
        type = 0
        mql_setup_hist,type,info
        mql_display_histo,type,info
    endif
    
; if column slice  plots up - replot
    if(XRegistered ('mqlcsr')) then begin
        type = 0
        mql_setup_colslice,type,info
        mql_display_colslice,type,info
    endif
; if row slice  plots up - replot

    if(XRegistered ('mqlrsr')) then begin
        type = 0
        mql_setup_rowslice,type,info
        mql_display_rowslice,type,info
    endif

    if(XRegistered ('mqlhs')) then begin
        type = 2
        mql_setup_hist,type,info
        mql_display_histo,type,info
    endif
    
; if column slice  plots up - replot
    if(XRegistered ('mqlcss')) then begin
        type = 2
        mql_setup_colslice,type,info
        mql_display_colslice,type,info
    endif

; if row slice  plots up - replot
    if(XRegistered ('mqlrss')) then begin
        type = 2
        mql_setup_rowslice,type,info
        mql_display_colslice,type,info
    endif

endif


end
