pro jwst_cv_get_image_stat,image, w_map,$
                           mean_image,std,cube_sum,$
                           minsignal,maxsignal,$
                           min_image,max_image,$
                           median_image,std_mean,$
                           skewness,n_pixels,numbad

; for an image determine the mean, sigma and min and max of the values
; input : 2D image
; output: image_stat[mean,standard dev, min, max] 
;         
;       : image_range [mean*.9, mean*.1] - initial min, max for
;                                          display purposes (scaling)

n_pixels =long( 0)
indxs = where(finite(image) and w_map gt 0,n_pixels)
image_use = image[indxs]

zero = where(image eq 0,nzero)
if( nzero eq n_pixels) then begin
    mean_image = !values.F_NaN
    std = !values.F_NaN
    cube_sum = !values.F_NaN
    minsignal = !values.F_NaN
    maxsignal = !values.F_NaN
    min_image = !values.F_NaN
    max_image = !values.F_NaN
    median_image = !values.F_NaN
    std_mean = !values.F_NaN
    skewness = !values.F_NaN
    return
endif

if (n_pixels GT 1) then begin
    m = moment(image_use,/double,/nan)
    
    mean_image = m[0]
    var = m[1]

    minsignal = min(image_use)
    maxsignal = max(image_use)
    cube_sum = total(image_use)
    median_image = median(image_use)
    
    std_mean  = SQRT(m[1])/SQRT(n_pixels)
    skewness = m[2]
    if (var GT 0) then std = sqrt(var) else std = 0.0

    ; adjust the image intensities scale by removing outliers
    high = median_image +1*std
    low = median_image - 1*std

    iclean = where(image_use gt low and image_use lt high)
    clean_image = image_use[iclean]
    m = moment(clean_image,/double,/nan)
    mean_clean_image = m[0]
    median_clean_image = median(clean_image)
    var_clean = m[1]

    if (var_clean GT 0) then std_clean = sqrt(var_clean) else std_clean = 0.0


    if (std_clean GT 0) then begin
        min_image = median_clean_image - 2.0*std_clean
        max_image = median_clean_image + 2.0*std_clean
    endif else begin
        min_image = mean_clean_image*0.9
        max_image = mean_clean_image*1.1
        min_image = mean_clean_image*0.8
        max_image = mean_clean_image*1.2
    endelse


    if(min_image lt minsignal) then min_image = minsignal
    if(max_image gt maxsignal) then max_image = maxsignal
endif else begin
    min_image = 0.0
    max_image = 1.0
    mean_image = 0
    std = 0
    minsignal = 0 
    maxsignal = 1
    median_image = 0
    std_mean = 0
    skewness = 0
    cube_sum = 0

endelse


end
