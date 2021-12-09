pro jwst_cube_pixel,event
jwst_cv_color6

Widget_Control,event.id,Get_uValue=event_name
Widget_Control,event.top,Get_UValue=cinfo

x = event.x
y = event.y

if(x lt 0) then x = 0
if(y lt 0) then y = 0

xpos_screen = x
ypos_screen = y

type_of_image = 0
if(cinfo.imagetype eq 0) then type_of_image = 0
if(cinfo.imagetype eq 2) then type_of_image = 1
if(cinfo.imagetype eq 1 and cinfo.jwst_coadd.flag eq 3) then type_of_image = 1

;***********************************************************************
if(type_of_image eq 0) then begin

    x = x/(cinfo.view_cube.zoom)
    y = y/(cinfo.view_cube.zoom)

; do not want to plot between pixels - start at corner of pixel go
 ;                                     from there
    xpos_screen = fix(x) * (cinfo.view_cube.zoom)
    ypos_screen = fix(y) * (cinfo.view_cube.zoom)

    xpos_cube = fix(x)+cinfo.view_cube.xstart
    ypos_cube = fix(y)+cinfo.view_cube.ystart

    if(xpos_cube ge cinfo.jwst_cube.naxis1) then xpos_cube = cinfo.jwst_cube.naxis1-1
    if(ypos_cube ge cinfo.jwst_cube.naxis2) then ypos_cube = cinfo.jwst_cube.naxis2-1

    if(ypos_cube ge cinfo.jwst_cube.naxis2) then return ; catch error outside window

    iwavelength = cinfo.view_cube.this_iwavelength - cinfo.jwst_cube.istart_wavelength 
    cube_value = (*cinfo.jwst_cube.pcubedata)[xpos_cube,$
                                              ypos_cube,$
                                              iwavelength]

    uncer_value = (*cinfo.jwst_cube.puncertainty)[xpos_cube,$
                                                  ypos_cube,$
                                                  iwavelength]


    w_map_value = (*cinfo.jwst_cube.pw_map)[xpos_cube,$
                                                  ypos_cube,$
                                                  iwavelength]

    sx = 'x: '+ strcompress(string(fix(xpos_cube+1)))
    sy = '  y: '+ strcompress(string(fix(ypos_cube+1)))
    svalue = '  Pixel Value: ' + strcompress(string(cube_value))
    suvalue = ' +/-' + strcompress(string(uncer_value))

    swmap = ' Weight Map: '+ strcompress(string(w_map_value))
    dec = (*cinfo.jwst_cube.pdec)[ypos_cube]
    ra =  (*cinfo.jwst_cube.pra)[xpos_cube] 

    sdec =  ' Dec:  ' + strcompress(string(dec)) + ' (arc sec)'
    sra = '  Ra ' + strcompress(string(ra)) + ' (arc sec)'
    info_line1 = sx + sy + svalue  +suvalue 
    info_line2 = swmap + sra + sdec
;_______________________________________________________________________

    widget_control,cinfo.pixel_labelID1,set_value = 'Cube Pixel '+ info_line1
    widget_control,cinfo.pixel_labelID2,set_value = info_line2

;_______________________________________________________________________
    if(cinfo.roi_image eq 1 ) then begin 
        roi = *cinfo.roi
        roi.color = 3
    endif

    if(event.press eq 1) then begin
        cinfo.view_cube.plot_pixel = 1
        cinfo.view_cube.xpos_cube = xpos_cube 
        cinfo.view_cube.ypos_cube = ypos_cube
        wset,cinfo.draw_window_id
        device,copy=[0,0,$
                     cinfo.view_cube.plot_xsize,$
                     cinfo.view_cube.plot_ysize, $
                     0,0,cinfo.pixmapID]

        pixel = 1.0 * cinfo.view_cube.zoom
        xpos1 = xpos_screen     ; - pixel/2.0
        xpos2 = xpos1 + pixel
        ypos1 = ypos_screen     ; - pixel/2.0
        ypos2 = ypos1 + pixel
        box_coords1 = [xpos1,xpos2,ypos1,ypos2]


        plots,box_coords1[[0,0,1,1,0]],box_coords1[[2,3,3,2,2]],psym=0,/device,color=4

        if(cinfo.do_centroid eq 1) then begin
            zoom  = cinfo.view_cube.zoom
            plots,(cinfo.jwst_centroid.xcenter-cinfo.view_cube.xstart-0.5)*zoom,$
                  (cinfo.jwst_centroid.ycenter-cinfo.view_cube.ystart-0.5)*zoom,$
                  psym=1,/device,color=4,symsize = 1
            
        endif        
        ;_______________________________________________________________________
        ; find region of interest

        if(cinfo.roi_image eq 1) then begin
            x  = event.x
            y  = event.y
            if(x lt 0) then x = 0
            if(y lt 0) then y = 0
            roi = *cinfo.roi
                                ; Remember this corner.
            roi.boxx0 = x
            roi.boxy0 = y
            
            roi.tempxbox = x
            roi.tempybox = y
            roi.pressed = 1
        endif
        ;_______________________________________________________________________
            
    endif
;*************************************************************************
    if(cinfo.roi_image eq 1) then begin

    ; User is dragging out an ROI box, erase and redraw until done.
    ; Erase the old one.
;________________________________________
        if (roi.pressed eq 1) then begin
            x = event.x
            y = event.y
            if(x lt 0) then x = 0
            if(y lt 0) then y = 0
                                ; print,' drawing box', x,y,roi.pressed,roi.color
            wset,cinfo.draw_window_id
            device,copy=[0,0,$
                         cinfo.view_cube.plot_xsize,$
                         cinfo.view_cube.plot_ysize, $
                         0,0,cinfo.pixmapID]

            plots, roi.boxx0, roi.boxy0, color=roi.color, /device
            plots, roi.boxx0, y, color=roi.color, /device, /continue
            plots, x, y, /device, color=roi.color, /continue
            plots, x, roi.boxy0, color=roi.color, /device, /continue
            plots, roi.boxx0, roi.boxy0, color=roi.color, /device, /continue
                                ; Now, remember where we are
            roi.tempxbox = x
            roi.tempybox = y
            *cinfo.roi = roi

	    ;print,'temp box',x/cinfo.view_cube.zoom,y/cinfo.view_cube.zoom
        endif
;________________________________________

        ; release the button
;________________________________________
        if(event.release eq 1) then begin

    ; Done drawing ROI, pop-up or update the widget.
            roi = *cinfo.roi
            roi.pressed = 0
            *cinfo.roi = roi            
;_______________________________________________________________________
            if(cinfo.roi_image eq 1) then begin
           ; Get various information from the ROI structure,
           ; use this information to calculate new info to store back into the ROI.
                if ( (*cinfo.roi).tempxbox gt (*cinfo.roi).boxx0 ) then begin
                    x1 = (*cinfo.roi).boxx0/(cinfo.view_cube.zoom)
                    x2 = (*cinfo.roi).tempxbox/(cinfo.view_cube.zoom)

                endif else begin
                    x2 = (*cinfo.roi).boxx0/(cinfo.view_cube.zoom)
                    x1 = (*cinfo.roi).tempxbox/(cinfo.view_cube.zoom)
                endelse
                if ((*cinfo.roi).tempybox gt (*cinfo.roi).boxy0) then begin
                    y1 = (*cinfo.roi).boxy0/(cinfo.view_cube.zoom)
                    y2 = (*cinfo.roi).tempybox/(cinfo.view_cube.zoom)
                endif else begin
                    y2 = (*cinfo.roi).boxy0/(cinfo.view_cube.zoom)
                    y1 = (*cinfo.roi).tempybox/(cinfo.view_cube.zoom)
                endelse
                
                if(x1 ge  cinfo.jwst_cube.naxis1) then x1 = cinfo.jwst_cube.naxis1-1 
                if(x2 ge  cinfo.jwst_cube.naxis1) then x2 = cinfo.jwst_cube.naxis1-1 
                if(y1 ge  cinfo.jwst_cube.naxis2) then y1 = cinfo.jwst_cube.naxis2-1 
                if(y2 ge  cinfo.jwst_cube.naxis2) then y2 = cinfo.jwst_cube.naxis2-1 
                
                (*cinfo.roi).roix1 = x1 
                (*cinfo.roi).roiy1 = y1 
                (*cinfo.roi).roix2 = x2
                (*cinfo.roi).roiy2 = y2

;_______________________________________________________________________
                                ; update the information for the center of the ROI
                cinfo.view_cube.xpos_cube = (x2 - x1)/2 + x1 
                cinfo.view_cube.ypos_cube = (y2 - y1)/2 + y1

                cinfo.view_image2d.xpos = cinfo.view_cube.xpos_cube
                cinfo.view_image2d.ypos = cinfo.view_cube.ypos_cube

                
                cube_value = (*cinfo.jwst_cube.pcubedata)[cinfo.view_cube.xpos_cube,$
                                                     cinfo.view_cube.ypos_cube,$
                                                     iwavelength]
                
                w_map_value = (*cinfo.jwst_cube.pw_map)[cinfo.view_cube.xpos_cube,$
                                                        cinfo.view_cube.ypos_cube,$
                                                        iwavelength]
                uncer_value = (*cinfo.jwst_cube.puncertainty)[cinfo.view_cube.xpos_cube,$
                                                         cinfo.view_cube.ypos_cube,$
                                                         iwavelength]

                sx = 'x: '+ strcompress(string(fix(cinfo.view_cube.xpos_cube+1)))
                sy = '  y: '+ strcompress(string(fix(cinfo.view_cube.ypos_cube+1)))
                svalue = '  Pixel Value: ' + strcompress(string(cube_value))
                suvalue = ' +/-' + strcompress(string(uncer_value))

                swmap = ' Weight Map'+ strcompress(string(w_map_value))
                dec = (*cinfo.jwst_cube.pdec)[cinfo.view_cube.ypos_cube]
                ra = (*cinfo.jwst_cube.pra)[cinfo.view_cube.xpos_cube]
                sdec =  ' Dec:  ' + strcompress(string(dec)) + ' (arc sec)'
                sra = '  Ra ' + strcompress(string(ra)) + '(arc sec)'
                info_line1 = sx + sy + svalue  +suvalue 
                info_line2 =  swmap + sra + sdec

                widget_control,cinfo.pixel_labelID1,set_value = 'Cube Spaxel ' + info_line1
                widget_control,cinfo.pixel_labelID2,set_value = info_line2
;_______________________________________________________________________

                jwst_cv_update_cube,cinfo
                cube = cinfo.jwst_cube
                spectrum = cinfo.jwst_spectrum
                jwst_extract_spectrum_from_cube,x1,x2,y1,y2,cube,spectrum,status
                cinfo.jwst_spectrum = spectrum
                cinfo.jwst_cube = cube
                cube = 0 & spectrum = 0
                widget_control,cinfo.cubeview,Set_UValue = cinfo
                jwst_cv_update_spectrum,cinfo
                jwst_cv_draw_current_wavelength,cinfo
                cinfo.roi_image = 0
   
                if(XRegistered ('surface')) then begin
                    widget_control,cinfo.SurfacePlot,/destroy
                endif
            endif
        endif

    endif                       ; end cinfo.roi_image= 1
;-----------------------------------------------------------------------



    x = 0 & y = 0 & xpos_screen = 0 & ypos_screen = 0 & sx = 0 & sy = 0 & svalue = 0
    dec = 0 & ra = 0 & sdec = 0 & sra = 0 & info_line = 0
    cube_value = 0  & box_coords = 0 & w = 0 & a = 0 & xcorner = 0 & ycorner = 0
    index_in_cube = 0 & x1 =0 & y1 =0 & x2 =0 & y2 = 0


endif


;***********************************************************************
;***********************************************************************

if(type_of_image eq 1) then begin 

    jwst_cv_color6

    x = x/(cinfo.view_image2d.zoom)
    y = y/(cinfo.view_image2d.zoom)

    xpos = fix(x)+cinfo.view_image2d.xstart  ; value in cube
    ypos = fix(y)+cinfo.view_image2d.ystart

    if(xpos ge cinfo.jwst_cube.naxis1) then xpos = cinfo.jwst_cube.naxis1-1
    if(ypos ge cinfo.jwst_cube.naxis2) then ypos = cinfo.jwst_cube.naxis2-1
    
    xsize_image = cinfo.jwst_image2d.x2 - cinfo.jwst_image2d.x1 + 1
    ysize_image = cinfo.jwst_image2d.y2 - cinfo.jwst_image2d.y1 + 1

    if(xpos ge xsize_image) then return ; catch error outside window
    if(ypos ge ysize_image) then return ; catch error outside window

    xx = x * cinfo.view_image2d.zoom
    yy = y * cinfo.view_image2d.zoom

    xpos_screen = xx
    ypos_screen = yy


    pixel_value = (*cinfo.jwst_image2d.pimage)[xpos,ypos]
    uncer_value = (*cinfo.jwst_image2d.puimage)[xpos,ypos]

    sx = 'x: '+ strcompress(string(fix(xpos+1)))
    sy = '  y: '+ strcompress(string(fix(ypos+1)))
    svalue = '  Pixel Value: ' + strcompress(string(pixel_value))
    suvalue = ' +/-' + strcompress(string(uncer_value))
    dec = (*cinfo.jwst_cube.pdec)[ypos]
    ra = (*cinfo.jwst_cube.pra)[xpos]

    sdec =  ' Dec:  ' + strcompress(string(dec))
    sra = '  Ra ' + strcompress(string(ra))
    info_line1 = sx + sy + svalue + suvalue
    info_line2 = sra + sdec

;_______________________________________________________________________
    if(cinfo.roi_image eq 1 ) then begin 
        roi = *cinfo.roi
        roi.color = 3
    endif
;_______________________________________________________________________
    if(event.press eq 1) then begin
        cinfo.view_image2d.plot_pixel = 1
        cinfo.view_image2d.xpos = x
        cinfo.view_image2d.ypos = y
        cinfo.view_image2d.xpos_screen = xpos_screen
        cinfo.view_image2d.ypos_screen = ypos_screen
        wset,cinfo.draw_window_id
        device,copy=[0,0,$
                     cinfo.view_image2d.plot_xsize,$
                     cinfo.view_image2d.plot_ysize, $
                     0,0,cinfo.pixmapID]
        pixel = 1.0 * cinfo.view_image2d.zoom 
        xpos1 = xpos_screen
        xpos2 = xpos_screen + pixel
        ypos1 = ypos_screen
        ypos2 = ypos_screen + pixel
        box_coords1 = [xpos1,xpos2,ypos1,ypos2]
        plots,box_coords1[[0,0,1,1,0]],box_coords1[[2,3,3,2,2]],psym=0,/device,color=4

        ;_______________________________________________________________________
        ; find region of interest

        if(cinfo.roi_image eq 1) then begin
            x  = event.x
            y  = event.y
            if(x lt 0) then x = 0
            if(y lt 0) then y = 0
            roi = *cinfo.roi
                                ; Remember this corner.
            roi.boxx0 = x
            roi.boxy0 = y
            
            roi.tempxbox = x
            roi.tempybox = y
            roi.pressed = 1
        endif
        ;_______________________________________________________________________

    endif

    widget_control,cinfo.pixel_labelID1,set_value = 'Cube Pixel: '+ info_line1
    widget_control,cinfo.pixel_labelID2,set_value = info_line2
    if(cinfo.roi_image eq 1) then begin

    ; User is dragging out an ROI box, erase and redraw until done.
    ; Erase the old one.
;________________________________________
        if (roi.pressed eq 1) then begin
            x = event.x
            y = event.y
            if(x lt 0) then x = 0
            if(y lt 0) then y = 0
                                ; print,' drawing box', x,y,roi.pressed,roi.color
            wset,cinfo.draw_window_id
            device,copy=[0,0,$
                         cinfo.view_image2d.plot_xsize,$
                         cinfo.view_image2d.plot_ysize, $
                         0,0,cinfo.pixmapID]

            plots, roi.boxx0, roi.boxy0, color=roi.color, /device
            plots, roi.boxx0, y, color=roi.color, /device, /continue
            plots, x, y, /device, color=roi.color, /continue
            plots, x, roi.boxy0, color=roi.color, /device, /continue
            plots, roi.boxx0, roi.boxy0, color=roi.color, /device, /continue
                                ; Now, remember where we are
            roi.tempxbox = x
            roi.tempybox = y
            *cinfo.roi = roi


            if(cinfo.do_centroid eq 1) then begin
                zoom  = cinfo.view_image2d.zoom
                plots,(cinfo.jwst_centroid.xcenter-cinfo.view_image2d.xstart-0.5)*zoom,$
                      (cinfo.jwst_centroid.ycenter-cinfo.view_image2d.ystart-0.5)*zoom,$
                      psym=1,/device,color=4,symsize = 1
            endif        
        endif
;________________________________________

        ; release the button
;________________________________________
        if(event.release eq 1) then begin

    ; Done drawing ROI, pop-up or update the widget.
            roi = *cinfo.roi
            roi.pressed = 0
            *cinfo.roi = roi            
;_______________________________________________________________________
            if(cinfo.roi_image eq 1) then begin
           ; Get various information from the ROI structure,
           ; use this information to calculate new info to store back into the ROI.
                if ( (*cinfo.roi).tempxbox gt (*cinfo.roi).boxx0 ) then begin
                    x1 = (*cinfo.roi).boxx0/(cinfo.view_image2d.zoom)
                    x2 = (*cinfo.roi).tempxbox/(cinfo.view_image2d.zoom)
                    
                endif else begin
                    x2 = (*cinfo.roi).boxx0/(cinfo.view_image2d.zoom)
                    x1 = (*cinfo.roi).tempxbox/(cinfo.view_image2d.zoom)
                endelse
                if ((*cinfo.roi).tempybox gt (*cinfo.roi).boxy0) then begin
                    y1 = (*cinfo.roi).boxy0/(cinfo.view_image2d.zoom)
                    y2 = (*cinfo.roi).tempybox/(cinfo.view_image2d.zoom)
                endif else begin
                    y2 = (*cinfo.roi).boxy0/(cinfo.view_image2d.zoom)
                    y1 = (*cinfo.roi).tempybox/(cinfo.view_image2d.zoom)
                endelse
                
                if(x1 ge  cinfo.jwst_cube.naxis1) then x1 = cinfo.jwst_cube.naxis1-1 
                if(x2 ge  cinfo.jwst_cube.naxis1) then x2 = cinfo.jwst_cube.naxis1-1 
                if(y1 ge  cinfo.jwst_cube.naxis2) then y1 = cinfo.jwst_cube.naxis2-1 
                if(y2 ge  cinfo.jwst_cube.naxis2) then y2 = cinfo.jwst_cube.naxis2-1 
                
                (*cinfo.roi).roix1 = x1 
                (*cinfo.roi).roiy1 = y1 
                (*cinfo.roi).roix2 = x2
                (*cinfo.roi).roiy2 = y2
;_______________________________________________________________________
                                ; update the information for the center of the ROI
                cinfo.view_image2d.xpos = (x2 - x1)/2 + x1 
                cinfo.view_image2d.ypos = (y2 - y1)/2 + y1
                ; testing
                cinfo.view_cube.xpos_cube = cinfo.view_image2d.xpos
                cinfo.view_cube.ypos_cube = cinfo.view_image2d.ypos

                xpos = cinfo.view_image2d.xpos
                ypos = cinfo.view_image2d.ypos
                pixel_value = (*cinfo.jwst_image2d.pimage)[xpos,ypos]
                uncer_value = (*cinfo.jwst_image2d.puimage)[xpos,ypos]
                sx = 'x: '+ strcompress(string(fix(xpos+1)))
                sy = '  y: '+ strcompress(string(fix(ypos+1)))
                svalue = '  Pixel Value: ' + strcompress(string(pixel_value))
                suvalue = ' +/-' + strcompress(string(uncer_value))
                dec = (*cinfo.jwst_cube.pdec)[ypos]
                ra = (*cinfo.jwst_cube.pra)[xpos]
                sdec =  ' Dec:  ' + strcompress(string(dec))
                sra = '  Ra ' + strcompress(string(ra))

                info_line1 = sx + sy + svalue + suvalue 
                info_line2 = sra + sdec

                widget_control,cinfo.pixel_labelID1,set_value = 'Cube: '+ info_line1
                widget_control,cinfo.pixel_labelID2,set_value = info_line2
;_______________________________________________________________________

                jwst_cv_update_image2d,cinfo

                cube = cinfo.jwst_cube
                spectrum = cinfo.jwst_spectrum
                jwst_extract_spectrum_from_cube,x1,x2,y1,y2,cube,spectrum,status
                cinfo.jwst_spectrum = spectrum
                cinfo.jwst_cube = cube
                cube = 0 & spectrum = 0
                widget_control,cinfo.cubeview,Set_UValue = cinfo
                jwst_cv_update_spectrum,cinfo
                jwst_cv_draw_coadd_lines,cinfo
                cinfo.roi_image = 0
                
                if(XRegistered ('surface')) then begin
                    widget_control,cinfo.SurfacePlot,/destroy
                endif

            endif
        endif
        
    endif                       ; end cinfo.roi_image= 1    


endif

x = 0 & y = 0 & xpos_screen = 0 & ypos_screen = 0 & sx = 0 & sy = 0 & svalue = 0
dec = 0 & ra = 0 & sdec = 0 & sra = 0 & info_line = 0
cube_value = 0  & box_coords = 0 & w = 0 & a = 0 & xcorner = 0 & ycorner = 0
index_in_cube = 0 & x1 =0 & y1 =0 & x2 =0 & y2 = 0

widget_control,event.top,Set_UValue = cinfo
end



