pro jwst_get_image_stat,image,mean_image,std,minsignal,maxsignal,$
                   min_image,max_image,median_image,std_mean

; for an image determine the mean, sigma and min and max of the values
; input : 2D image
; output: image_stat[mean,standard dev, min, max] 
;         
;       : image_range [mean*.9, mean*.1] - initial min, max for
;                                          display purposes (scaling)

n_pixels =long( 0)
indxs = where(finite(image),n_pixels)

zero = where(image eq 0,nzero)
if( nzero eq n_pixels) then begin
    mean_image = !values.F_NaN
    std = !values.F_NaN
    minsignal = !values.F_NaN
    maxsignal = !values.F_NaN
    min_image = !values.F_NaN
    max_image = !values.F_NaN
    median_image = !values.F_NaN
    std_mean = !values.F_NaN
    return
endif

if (n_pixels GT 1) then begin

    ;m = moment(image,/double,/nan)
    med  = median(image)
    std1  = stddev(image,/nan)
    low  = med - std1*5
    high  = med + std1*5
    igood = where(image gt low and image lt high,ngood)
    image_good = image[igood]
    m = moment(image_good,/double,/nan)

    mean_image = m[0]

    var = m[1]
    std_mean  = SQRT(m[1])/SQRT(n_pixels)

    minsignal = min(image[indxs])
    maxsignal = max(image[indxs])
    median_image = median(image[indxs])
  
    if (var GT 0) then std = sqrt(var) else std = 0.0


    if (std GT 0) then begin
        min_image = mean_image - 2.0*std
        max_image = mean_image + 2.0*std
    endif else begin
        min_image = mean_image*0.9
        max_image = mean_image*1.1
        min_image = mean_image*0.8
        max_image = mean_image*1.2
    endelse
   
endif else begin
    min_image = 0.0
    max_image = 1.0
    mean_image = 0
    std = 0
    minsignal = 0 
    maxsignal = 1
    median_image = 0
    std_mean = 0
endelse

end
