pro cv_restore_full_image,cinfo

widget_control,cinfo.roi_button1,Set_Button = 0
widget_control,cinfo.roi_button2,Set_Button = 1
cinfo.roi_image = 0

widget_control,cinfo.zoom1,set_button=1            
widget_control,cinfo.zoom2,set_button=0
widget_control,cinfo.zoom4,set_button=0
widget_control,cinfo.zoom8,set_button=0
widget_control,cinfo.zoom16,set_button=0

(*cinfo.roi).roix1 = cinfo.cube.x1 
(*cinfo.roi).roiy1 = cinfo.cube.y1
(*cinfo.roi).roix2 = cinfo.cube.x2
(*cinfo.roi).roiy2 = cinfo.cube.y2
x1 = cinfo.cube.x1
x2 = cinfo.cube.x2
y1 = cinfo.cube.y1
y2 = cinfo.cube.y2
cinfo.view_cube.zoom_user = 1
cinfo.view_image2d.zoom_user = 1

cinfo.view_image2d.xpos = (x2 - x1)/2 + x1 
cinfo.view_image2d.ypos = (y2 - y1)/2 + y1

cinfo.view_cube.xpos_cube = cinfo.view_image2d.xpos
cinfo.view_cube.ypos_cube = cinfo.view_image2d.ypos


if(cinfo.do_centroid eq 1) then cv_cleanup_centroid,cinfo
if(XRegistered ('surface')) then widget_control,cinfo.SurfacePlot,/destroy
if(cinfo.imagetype eq 0) then begin

    cv_update_cube,cinfo
    cube = cinfo.cube
    spectrum = cinfo.spectrum
    extract_spectrum_from_cube,x1,x2,y1,y2,cube,spectrum,status
    cinfo.cube = cube
    cinfo.spectrum = spectrum
    cv_update_spectrum,cinfo
    cv_draw_current_wavelength,cinfo
endif


if(cinfo.imagetype ge 1) then begin
    if(XRegistered ('add') and cinfo.coadd.flag ne 3) then begin
        result = dialog_message(" You have not selected the wavelength range properly ",/info)
        cv_coadd_options,cinfo
        return
    endif


    
    cube = cinfo.cube
    image2d = cinfo.image2d
    z1 = cinfo.image2d.z1
    z2 = cinfo.image2d.z2
    if(z1 eq -1 or z2 eq -1) then begin
        result = dialog_message(" You have not selected the wavelength range properly ",/info)
        cv_coadd_options,cinfo
        return
    endif
    collapse_wavelength,x1,x2,y1,y2,cube,image2d,status,iw1=z1,iw2=z2
    
    cinfo.cube = cube
    cinfo.image2d = image2d
    cv_coadd_done,cinfo
endif

if(XRegistered ('surface')) then begin
                                ;widget_control,cinfo.SurfacePlot,/destroy
    cv_centroid_setup_image,cinfo
    cv_centroid_surface_update,cinfo
endif


end
