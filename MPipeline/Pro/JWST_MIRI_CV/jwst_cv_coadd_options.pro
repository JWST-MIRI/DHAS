;_______________________________________________________________________
pro jwst_coadd_quit,event
widget_control,event.top, Get_UValue = tinfo
widget_control,tinfo.cinfo.CubeView,Get_UValue=cinfo
widget_control,cinfo.CoaddSelect,/destroy
end
;_______________________________________________________________________
pro jwst_coadd_event, event
Widget_Control,event.id,Get_uValue=event_name
Widget_Control,event.top,Get_UValue=winfo
widget_control,winfo.cinfo.CubeView,Get_UValue=cinfo

case 1 of 
    (strmid(event_name,0,4) EQ 'done'): begin 
        jwst_cv_coadd_done,cinfo
    end

    (strmid(event_name,0,4) EQ 'wave') : begin
        jwst_cv_color6
        wset,cinfo.view_spectrum.draw_window_id
        device,copy=[0,0,cinfo.view_spectrum.plot_xsize,cinfo.view_spectrum.plot_ysize,$
                     0,0,cinfo.view_spectrum.pixmapID]

        if(strmid(event_name,4,1) eq '1') then  cinfo.jwst_image2d.z1 =  event.index
        if(strmid(event_name,4,1) eq '2') then  cinfo.jwst_image2d.z2 =  event.index

        xline = fltarr(2) & yline = fltarr(2)
        yline[0] = -1000
        yline[1] = 1000
        xline[*] = (*cinfo.jwst_cube.pwavelength)[cinfo.jwst_image2d.z1]
        plots,xline,yline,color=2,thick = 1.5
        ;print,xline
        xline[*] = (*cinfo.jwst_cube.pwavelength)[cinfo.jwst_image2d.z2]
        plots,xline,yline,color=4,thick = 1.5
        ;print,xline
        widget_control,cinfo.jwst_coadd.doneID, sensitive = 1
    end
;_______________________________________________________________________
    (strmid(event_name,0,5) EQ 'rwave') : begin
        cinfo.jwst_coadd.select_ranges = 1
        cinfo.jwst_coadd.flag = 0

        wavelengths = ['Click on Spectrum Plot']
        widget_control,cinfo.jwst_coadd.wavelengthID1,set_value = wavelengths
        widget_control,cinfo.jwst_coadd.wavelengthID2,set_value = '               ' 
        widget_control,cinfo.jwst_coadd.doneID, sensitive = 0
    end

    (strmid(event_name,0,6) EQ 'cancel'): begin 
        widget_control,cinfo.imageDID, set_combobox_select = 2
        x1 = (*cinfo.roi).roix1 
        y1 = (*cinfo.roi).roiy1 
        x2 = (*cinfo.roi).roix2 
        y2 = (*cinfo.roi).roiy2 

        x1_full = cinfo.jwst_cube.x1
        x2_full = cinfo.jwst_cube.x2
        y1_full = cinfo.jwst_cube.y1
        y2_full = cinfo.jwst_cube.y2

        cube = cinfo.jwst_cube
        image2d = cinfo.jwst_image2d
        jwst_collapse_wavelength,x1_full,x2_full,y1_full,y2_full,cube,image2d,status
        cinfo.imagetype = 2
        spectrum = cinfo.jwst_spectrum
        jwst_extract_spectrum_from_cube,x1,x2,y1,y2,cube,spectrum,status
        cinfo.jwst_cube = cube
        cinfo.jwst_image2d = image2d
        cinfo.jwst_spectrum = spectrum
        
        cinfo.view_image2d.image_min = cinfo.jwst_image2d.image_min
        cinfo.view_image2d.image_max = cinfo.jwst_image2d.image_max
        cinfo.jwst_coadd.flag = 3        
        jwst_cv_display_image2d,cinfo
        if(XRegistered ('add')) then  widget_control,cinfo.coaddselect,/show
 
        jwst_cv_update_spectrum,cinfo
        jwst_cv_draw_coadd_lines,cinfo
        
        if(XRegistered ('surface')) then widget_control,cinfo.SurfacePlot,/destroy
        widget_control,cinfo.CoaddSelect,/destroy
    end


    else: print,'Event Name not found',event_name
endcase

widget_control,winfo.cinfo.cubeview,Set_Uvalue = cinfo

end

;_______________________________________________________________________
;***********************************************************************
pro jwst_cv_coadd_done,cinfo

if(cinfo.jwst_image2d.z1 eq -1) then begin
    result = dialog_message(' Select starting wavelength first',/info)
    return
endif

if(cinfo.jwst_image2d.z2 eq -1) then begin
    result = dialog_message(' Select ending wavelength first',/info)
    return
endif
                                ; roi initialized in setup_cube.pro
                                ; and updated in cube_pixel.pro
cinfo.jwst_coadd.select_ranges = 0
x1 = (*cinfo.roi).roix1 
y1 = (*cinfo.roi).roiy1 
x2 = (*cinfo.roi).roix2 
y2 = (*cinfo.roi).roiy2 

x1_full = cinfo.jwst_cube.x1
x2_full = cinfo.jwst_cube.x2
y1_full = cinfo.jwst_cube.y1
y2_full = cinfo.jwst_cube.y2

cube = cinfo.jwst_cube
image2d = cinfo.jwst_image2d
z1 = cinfo.jwst_image2d.z1
z2 = cinfo.jwst_image2d.z2
jwst_collapse_wavelength,x1_full,x2_full,y1_full,y2_full,cube,image2d,status,iw1=z1,iw2=z2

spectrum = cinfo.jwst_spectrum
jwst_extract_spectrum_from_cube,x1,x2,y1,y2,cube,spectrum,status
cinfo.jwst_cube = cube
cinfo.jwst_image2d = image2d
cinfo.jwst_spectrum = spectrum

cinfo.view_image2d.image_min = cinfo.jwst_image2d.image_min
cinfo.view_image2d.image_max = cinfo.jwst_image2d.image_max
cinfo.jwst_coadd.flag = 3            
jwst_cv_display_image2d,cinfo
if(XRegistered ('add')) then  widget_control,cinfo.coaddselect,/show
                
jwst_cv_update_spectrum,cinfo
jwst_cv_draw_coadd_lines,cinfo

if(XRegistered ('surface')) then begin
    jwst_cv_centroid_setup_image,cinfo
    jwst_cv_centroid_surface_update,cinfo
endif

end

;_______________________________________________________________________
;***********************************************************************
pro jwst_cv_coadd_options,cinfo

window,3,/pixmap
wdelete,3
w = get_screen_size()
x_offset = w[0] - 350
if(x_offset lt 0) then x_offset = 50

if(XRegistered ('add')) then begin
    widget_control,cinfo.CoaddSelect,/destroy
endif

cinfo.CoaddSelect = widget_base(title = 'Select Wavelengths', col =1 , mbar = menuBar,$
                       group_leader = cinfo.CubeView,$
                       xsize = 350,ysize = 200,/column, xoffset = x_offset, yoffset = 50)

QuitMenu = widget_button(menuBar,value="Quit",font = cinfo.font2)
quitbutton = widget_button(quitmenu,value="Quit",event_pro='jwst_coadd_quit')

graphID_master = widget_base(cinfo.CoaddSelect,row=1)
graphID1 = widget_base(graphID_master,col= 1)
;_______________________________________________________________________
; wavelength ranges of 2d image

cinfo.jwst_coadd.flag = 0
cinfo.jwst_coadd.select_ranges = 1
;_______________________________________________________________________
; select wavelengths by clicking - selecttype = 1

cinfo.jwst_image2d.z1 = -1
cinfo.jwst_image2d.z2 = -1

wavelength_box = widget_base(graphID1,row=1)
wavelength_label = widget_label(wavelength_box,value='Starting Wavelength',/align_left,$
                                font  = cinfo.font5)
wavelengths = ['Click on Spectrum Plot']

cinfo.jwst_coadd.wavelengthID1 = widget_combobox(wavelength_box,value = wavelengths,uvalue='wave1',$
                               font = cinfo.font5,/dynamic_resize)

wavelength_box = widget_base(graphID1,row=1)
wavelength_label = widget_label(wavelength_box,value='Ending Wavelength  ',/align_left,$
                                font  = cinfo.font5)

wavelengths = ['                      ']
cinfo.jwst_coadd.wavelengthID2 = widget_combobox(wavelength_box,value = wavelengths,uvalue='wave2',$
                               font = cinfo.font5,/dynamic_resize)


reselect_box = widget_base(graphID1,/row)
cinfo.jwst_coadd.waveReSelectID = widget_button(reselect_box,value = 'Re-select wavelengths',uvalue='rwave',$
                              /sensitive)

widget_control,cinfo.jwst_coadd.waveReSelectID,sensitive = 0


done_box = widget_base(graphID1,/row)
cinfo.jwst_coadd.doneID = widget_button(done_box, value =' Finished Selecting Wavelengths --> Co-add ', uvalue= 'done',font=cinfo.font5)


cancel_box = widget_base(graphID1,/row)
cinfo.jwst_coadd.cancelID = widget_button(cancel_box, value ='Cancel selection- coadd all wavelengths', uvalue= 'cancel',font=cinfo.font5)

widget_control,cinfo.jwst_coadd.doneID,sensitive = 0

add = {cinfo                  : cinfo}



Widget_Control,cinfo.CoaddSelect,Set_UValue=add
widget_control,cinfo.CoaddSelect,/realize

XManager,'add',cinfo.CoaddSelect,/No_Block,event_handler = 'jwst_coadd_event'
Widget_Control,cinfo.CubeView,Set_UValue=cinfo

end
