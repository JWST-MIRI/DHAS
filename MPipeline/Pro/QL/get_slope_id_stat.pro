pro get_slope_id_stat,image,id_flags,mean_image,std_pixel,minsignal,maxsignal,min_image,max_image,id_num

; For the data quality flag of the slope image - find the number of
;                                                different IDS 
id_values = id_flags
id_num = intarr(n_elements(id_values))

indxs = where(finite(image),n_pixels)

if (n_pixels GT 0) then begin
    mean_image = total(image[indxs])/n_pixels
    std_pixel = total((image[indxs] - mean_image)^2/(n_pixels-1))

    minsignal = min(image[indxs])
    maxsignal = max(image[indxs])
    min_image = minsignal
    max_image = maxsignal
    for j = 0,n_elements(id_values) - 1 do begin
        test_value = fix(image/id_values[j])
        test = test_value/2.0
        
        rem = test -fix(test)
        ind = where(rem ne 0, numid)
        id_num[j] = numid
    endfor
endif


end
