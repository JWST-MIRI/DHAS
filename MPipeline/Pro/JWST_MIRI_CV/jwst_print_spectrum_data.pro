
pro jwst_print_spectrum_data,filename,cube,spectrum

print,filename

openw,lun,filename,error=err,/get_lun

spectrumdata = (*spectrum.pspectrum)
wavelength = (*cube.pwavelength)

x1 = spectrum.xcube_range[0] & x2 = spectrum.xcube_range[1]
y1 = spectrum.ycube_range[0] & y2 = spectrum.ycube_range[1]
ra1 = spectrum.ra_range[0] & ra2 = spectrum.dec_range[1]
dec1 = spectrum.dec_range[0] & dec2 = spectrum.dec_range[1]

printf,lun,'# Comment: Extracted spectrum from ' + cube.filename
printf,lun,'# Comment: Row 1 , Cube Pixel extracted box: x1+1,x2+1,y1+1,y2+1
printf,lun,'# Comment: Row 2 , Sky Coordinates Extracted box: ra1,ra2,dec1,dec2'
printf,lun,'# Comment: Row 3-end , Data: wavelength, flux'
printf,lun,x1,x2,y1,y2
printf,lun,ra1,ra2,dec1,dec2
for i = 0, n_elements(wavelength)-1 do begin
    printf,lun,wavelength[i],spectrumdata[i]
endfor


close,lun
free_lun,lun

end
