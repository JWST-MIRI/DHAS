
pro test_library

@cube_structs
filename = 'MIRI_VM2T00003891_1_SW_S_2008-09-20T04h48m07_CUBE_CH1.fits'

cube = {cubei}
spectrum = {spectrumi}


read_cube,filename,cube,status, error_message
if(status ne 0) then begin
    print, ' Error reading cube header ', error_message
    stop
endif
print,' Size of cube ',cube.naxis1,cube.naxis2,cube.naxis3
print,' Alpha values',(*cube.palpha)
print,' Beta values',(*cube.pbeta)
;print,' Wavelength values',(*cube.pwavelength)


if(status ne 0) then begin
    print, ' Error reading cube ', error_message
    stop
endif


; get the cube alpha and beta ranges of cube
x1 = cube.x1 
x2 = cube.x2
y1 = cube.y1
y2 = cube.y2

print,'in test library',x1,x2,y1,y2
extract_spectrum_from_cube,x1,x2,y1,y2,cube,spectrum,status

data_spectrum = (*spectrum.pspectrum)

wavelength = (*cube.pwavelength)
plot_xrange= fltarr(2) & plot_yrange = fltarr(2)

plot_xrange[0] = spectrum.wavelength_range[0]
plot_xrange[1] = spectrum.wavelength_range[1]

plot_yrange[0] = spectrum.flux_range[0]
plot_yrange[1] = spectrum.flux_range[1]

plot,wavelength,data_spectrum,xtitle=" Wavelength",ytitle = " Ave Flux", $
     title = stitle, subtitle = sstitle,$
     linestyle = 1,$
     xrange = [plot_xrange[0],plot_xrange[1]],$
     yrange = [plot_yrange[0],plot_yrange[1]]

oplot,wavelength,data_spectrum,psym = 6, symsize = 0.2

end

