;_______________________________________________________________________
pro jwst_find_wavelength_index,wavelength_vector,wavelength,iwavelength

;print,' Looking for wavelength ' ,wavelength
ifound = 0
iwavelength = -1
num = n_elements(wavelength_vector)

j = 0
while(ifound eq 0 and j lt num-1) do begin
    if(wavelength ge wavelength_vector[j] and wavelength lt wavelength_vector[j+1]) then begin
        ifound = 1
        iwavelength = j
    endif
    j = j + 1
endwhile


if(ifound eq 0 and wavelength eq wavelength_vector[num-1])then begin
    iwavelength  = num -1
endif

end
