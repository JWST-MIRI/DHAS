;***********************************************************************
pro cv_draw_current_wavelength_copy,cinfo
    color6

; plot current wavelength plane on the spectrum plot
; green line to show current wavelength plane from cube
iwavelength = cinfo.view_cube.this_iwavelength - cinfo.cube.istart_wavelength 

if(cinfo.view_spectrum.show_value_line eq 1 ) then begin

    wset,cinfo.view_spectrum.draw_window_id
    device,copy=[0,0,cinfo.view_spectrum.plot_xsize,cinfo.view_spectrum.plot_ysize,$
                 0,0,cinfo.view_spectrum.pixmapID]
    xline = fltarr(2) & yline = fltarr(2)
    xline[*] = (*cinfo.cube.pwavelength)[iwavelength]
    yline[0] = -1000
    yline[1] = 1000


    plots,xline,yline,color=3,thick = 1.5
    oplot,xline,yline,color=3,thick = 1.5
    
endif
Widget_Control,cinfo.CubeView,Set_UValue=cinfo
end


;***********************************************************************
pro cv_draw_current_wavelength,cinfo
    color6

; plot current wavelength plane on the spectrum plot
; green line to show current wavelength plane from cube
iwavelength = cinfo.view_cube.this_iwavelength - cinfo.cube.istart_wavelength 

if(cinfo.view_spectrum.show_value_line eq 1 ) then begin

    wset,cinfo.view_spectrum.draw_window_id
;    device,copy=[0,0,cinfo.view_spectrum.plot_xsize,cinfo.view_spectrum.plot_ysize,$
;                 0,0,cinfo.view_spectrum.pixmapID]
    xline = fltarr(2) & yline = fltarr(2)
    xline[*] = (*cinfo.cube.pwavelength)[iwavelength]
    yline[0] = -1000
    yline[1] = 1000


    plots,xline,yline,color=3,thick = 1.5
    oplot,xline,yline,color=3,thick = 1.5
    
endif
Widget_Control,cinfo.CubeView,Set_UValue=cinfo
end

;***********************************************************************
pro cv_draw_coadd_lines,cinfo


wset,cinfo.view_spectrum.draw_window_id


if(cinfo.image2d.z1 ne -1) then begin
    xline = fltarr(2) & yline = fltarr(2)
    xline[*] = (*cinfo.cube.pwavelength)[cinfo.image2d.z1]
    yline[0] = -1000
    yline[1] = 1000

    plots,xline,yline,color=2,thick = 1.5
    oplot,xline,yline,color=2,thick = 1.5
endif

if(cinfo.image2d.z2 ne -1) then begin
    xline = fltarr(2) & yline = fltarr(2)
    xline[*] = (*cinfo.cube.pwavelength)[cinfo.image2d.z2]
    yline[0] = -1000
    yline[1] = 1000

    plots,xline,yline,color=4,thick = 1.5
    oplot,xline,yline,color=4,thick = 1.5
endif

if(cinfo.coadd.flag eq 2) then cv_coadd_done,cinfo   
if(XRegistered ('add')) then  widget_control,cinfo.coaddselect,/show

end

;***********************************************************************
pro cv_draw_line,event
Widget_Control,event.id,Get_uValue=event_name
Widget_Control,event.top,Get_UValue=cinfo
;***********************************************************************
if(cinfo.lock_wavelength eq 1 and cinfo.imagetype eq 0) then return 

if(cinfo.imagetype eq 0 and event.type eq 1) then begin
	cinfo.lock_wavelength = 1
	widget_control,cinfo.lock_button1,Set_Button = 1
        widget_control,cinfo.lock_button2,Set_Button = 0
        Widget_Control,cinfo.CubeView,Set_UValue=cinfo	
	return
endif		



color6
spectrum = (*cinfo.spectrum.pspectrum)
error = (*cinfo.spectrum.puncertainty)
wavelength = (*cinfo.cube.pwavelength)


wset,cinfo.view_spectrum.draw_window_id
device,copy=[0,0,cinfo.view_spectrum.plot_xsize,cinfo.view_spectrum.plot_ysize,$
             0,0,cinfo.view_spectrum.pixmapID]


min_y = min(spectrum) & max_y = max(spectrum)
min_x = min(wavelength) & max_x = max(wavelength)


cursor,x,y,/nowait


if(x lt min_x or x gt max_x or y lt min_y or y gt max_y) then begin
    x= cinfo.view_spectrum.last_x
    y = cinfo.view_spectrum.last_y
endif else begin 


    cinfo.view_spectrum.last_x = x
    cinfo.view_spectrum.last_y = y 
endelse



line_values = fltarr(3)
find_line_values,x,wavelength,spectrum,error,line_values,index_return
cinfo.view_cube.this_iwavelength = index_return



if(cinfo.view_spectrum.show_value_line eq 1 ) then begin

; plot current wavelength plane on the spectrum plot
; green line to show current wavelength plane from cube

    iwavelength = cinfo.view_cube.this_iwavelength - cinfo.cube.istart_wavelength 
                                ; update green line 

    xline = fltarr(2) & yline = fltarr(2)
    xline[*] = (*cinfo.cube.pwavelength)[iwavelength]
    yline[0] = -1000
    yline[1] = 1000

    plots,xline,yline,color=3,thick = 1.5
    oplot,xline,yline,color=3,thick = 1.5
    
endif

Widget_Control,cinfo.CubeView,Set_UValue=cinfo


;_______________________________________________________________________
; Find the values closest to line


if(x ge cinfo.view_spectrum.graph_range[0,0] && x le cinfo.view_spectrum.graph_range[0,1]) then begin 
    line_wavelength = line_values[0]
    line_flux = line_values[1]
    line_error = line_values[2]
    swavelength = 'Cursor value : Lamba :' + strcompress(string(line_wavelength))
    sflux = '   Flux:' + strcompress(string(line_flux))
    serror = '+/-' + strcompress(string(line_error))

    info_line = swavelength + sflux + serror

    widget_control,cinfo.info_spectrum_LabelID,set_value = info_line
endif


Widget_Control,cinfo.CubeView,Set_UValue=cinfo

;_______________________________________________________________________
if(cinfo.coadd.select_ranges eq 1 and cinfo.coadd.flag eq 1 and event.release ne 0 ) then begin
    iwavelength = cinfo.view_cube.this_iwavelength - cinfo.cube.istart_wavelength 
                                ; update green line 
    xline = fltarr(2) & yline = fltarr(2)
    xline[*] = (*cinfo.cube.pwavelength)[iwavelength]
    yline[0] = -1000
    yline[1] = 1000
    

    plots,xline,yline,color=4,thick = 1.5
    oplot,xline,yline,color=4,thick = 1.5
    cinfo.image2d.z2 = iwavelength
    wavelength_string = string( (*cinfo.cube.pwavelength))
    widget_control,cinfo.coadd.wavelengthID2,set_value = wavelength_string
    widget_control,cinfo.coadd.wavelengthID2,set_combobox_select=$
                   cinfo.image2d.z2
    widget_control,cinfo.coadd.waveReSelectID,sensitive = 1
    cinfo.coadd.flag = 2
    if(XRegistered ('add')) then  widget_control,cinfo.coaddselect,/show


endif


if(cinfo.coadd.select_ranges eq 1 and cinfo.coadd.flag eq 0 and event.release ne 0 ) then begin
    iwavelength = cinfo.view_cube.this_iwavelength - cinfo.cube.istart_wavelength 
                                ; update green line 

    xline = fltarr(2) & yline = fltarr(2)
    xline[*] = (*cinfo.cube.pwavelength)[iwavelength]
    yline[0] = -1000
    yline[1] = 1000
    

    plots,xline,yline,color=2,thick = 1.5
    oplot,xline,yline,color=2,thick = 1.5

    cinfo.image2d.z1 = iwavelength
    wavelength_string = string( (*cinfo.cube.pwavelength))
    widget_control,cinfo.coadd.wavelengthID1,set_value = wavelength_string
    widget_control,cinfo.coadd.wavelengthID1,set_combobox_select=$
                   cinfo.image2d.z1


    ending_wavelength = 'Click on Spectrum Plot'
    widget_control,cinfo.coadd.wavelengthID2,set_value = ending_wavelength

    cinfo.coadd.flag = 1
    if(XRegistered ('add')) then  widget_control,cinfo.coaddselect,/show
endif



if(cinfo.imagetype gt 0) then cv_draw_coadd_lines,cinfo

if(cinfo.imagetype eq 0) then cv_update_cube,cinfo        

if(cinfo.imagetype eq 1 and cinfo.coadd.flag ne 3) then cv_update_cube,cinfo        

wavelength  = 0
spectrum = 0
error = 0
line_values = 0
Widget_Control,cinfo.CubeView,Set_UValue=cinfo
end
;_______________________________________________________________________
;***********************************************************************
pro cv_update_spectrum,cinfo,ps=ps,eps = eps
;***********************************************************************

color6
hcopy =0
if ( (keyword_set(ps)) or ( keyword_set(eps)) ) then hcopy = 1

iwavelength = cinfo.view_cube.this_iwavelength - cinfo.cube.istart_wavelength 

spectrum = (*cinfo.spectrum.pspectrum)

wavelength = (*cinfo.cube.pwavelength)



if(cinfo.view_spectrum.default_range[0] eq 1) then begin
    cinfo.view_spectrum.graph_range[0,0] = cinfo.spectrum.wavelength_range[0]
    cinfo.view_spectrum.graph_range[0,1] = cinfo.spectrum.wavelength_range[1]
endif

if(cinfo.view_spectrum.default_range[1] eq 1) then begin
    cinfo.view_spectrum.graph_range[1,0] = cinfo.spectrum.flux_range[0]
    cinfo.view_spectrum.graph_range[1,1] = cinfo.spectrum.flux_range[1]
endif


x1 = cinfo.spectrum.xcube_range[0] & x2 = cinfo.spectrum.xcube_range[1]
y1 = cinfo.spectrum.ycube_range[0] & y2 = cinfo.spectrum.ycube_range[1]
alpha1 = cinfo.spectrum.alpha_range[0] & alpha2 = cinfo.spectrum.alpha_range[1]
beta1 = cinfo.spectrum.beta_range[0] & beta2 = cinfo.spectrum.beta_range[1]

if (hcopy eq 0) then begin
    stitle = ' ' 
    sstitle = ' '

endif else begin 
    stitle = 'Extracted Spectrum: '+cinfo.control.file_cube_base
    scube1 = 'Extracted region X:[' + strcompress(string(fix(x1+1))) + ',' + strcompress(string(fix(x2+1)))+'],'
    scube2 = '  Y:[' + strcompress(string(fix(y1+1))) + ',' + strcompress(string(fix(y2+1))) + '],'
    scube3 = '  Alpha:[' + strcompress(string(alpha1)) + ',' + strcompress(string(alpha2)) + '],' +$
             ' (arc sec)' 
    scube4 = '  Beta:[' + strcompress(string(beta1)) + ',' + strcompress(string(beta2))+']' +$
             ' (arc sec)' 

    sstitle = scube1 + scube2 + scube3 + scube4
endelse 




if (hcopy eq 0) then begin
    wset,cinfo.view_spectrum.pixmapID
endif

plot,wavelength,spectrum,xtitle=" Wavelength",ytitle = " Ave Flux", $
     title = stitle, subtitle = sstitle,$
     linestyle = 1,$
     xrange = [cinfo.view_spectrum.graph_range[0,0],$
               cinfo.view_spectrum.graph_range[0,1]],$
     yrange =[cinfo.view_spectrum.graph_range[1,0],$
              cinfo.view_spectrum.graph_range[1,1]],xstyle = 1, ystyle = 1

oplot,wavelength,spectrum,psym = 6, symsize = 0.2

if (hcopy eq 0) then begin
    wset,cinfo.view_spectrum.draw_window_id
endif

plot,wavelength,spectrum,xtitle=" Wavelength",ytitle = " Ave Flux", $
     title = stitle, subtitle = sstitle,$
     linestyle = 1,xstyle=1,ystyle = 1, $
     xrange = [cinfo.view_spectrum.graph_range[0,0],$
               cinfo.view_spectrum.graph_range[0,1]],$
     yrange =[cinfo.view_spectrum.graph_range[1,0],$
              cinfo.view_spectrum.graph_range[1,1]]

oplot,wavelength,spectrum,psym = 6, symsize = 0.2


widget_control,cinfo.range_x1_labelID,set_value = cinfo.view_spectrum.graph_range[0,0]
widget_control,cinfo.range_x2_labelID,set_value = cinfo.view_spectrum.graph_range[0,1]
widget_control,cinfo.range_y1_labelID,set_value = cinfo.view_spectrum.graph_range[1,0]
widget_control,cinfo.range_y2_labelID,set_value = cinfo.view_spectrum.graph_range[1,1]

widget_control,cinfo.cubeview,Set_UValue = cinfo



wavelength  = 0
spectrum = 0
Widget_Control,cinfo.CubeView,Set_UValue=cinfo
end 


;_______________________________________________________________________

