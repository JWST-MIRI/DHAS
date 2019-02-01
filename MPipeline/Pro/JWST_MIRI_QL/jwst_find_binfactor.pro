pro jwst_find_image_binfactor,info

info.jwst_image.scale_zoom = 1.0
info.jwst_image.scale_inspect = 1.0
info.jwst_image.binfactor = info.binfactor ; set default 
if(info.jwst_data.subarray ne 0) then begin
 image_size = info.jwst_data.image_xsize
 if(info.jwst_data.image_ysize gt image_size) then image_size = info.jwst_data.image_ysize

   ; default for subarray less than or =  256
    if(image_size le 256) then info.jwst_image.binfactor = 1.0 

   ; default for subarray greater than  256
    if(image_size gt 256 ) then begin
	info.jwst_image.binfactor = image_size/256
    endif

    if(image_size lt  256 ) then begin
	info.jwst_image.binfactor = 256/image_size
    endif

; look at specific subarrays smaller than 256
    if(image_size eq 16) then begin
        info.jwst_image.binfactor = 1.0/16.0
        info.jwst_image.scale_zoom = 16
    endif
    if(image_size eq 32 or image_size eq 36) then begin
        info.jwst_image.binfactor = 1.0/8.0
        info.jwst_image.scale_zoom = 8
    endif

    if(image_size eq 64 or image_size eq 68) then begin
        info.jwst_image.binfactor = 1.0/4.0
        info.jwst_image.scale_zoom = 4
    endif

    if(image_size eq 128 or image_size eq 132) then begin
        info.jwst_image.binfactor = 1.0/2.0
        info.jwst_image.scale_zoom = 2
    endif

	print,info.jwst_image.binfactor
    if(image_size eq 864) then begin
        info.jwst_image.binfactor = 4.0
    endif

endif 


end

;***********************************************************************

pro jwst_find_slope_binfactor,info

info.jwst_slope.scale_zoom = 1.0
info.jwst_slope.scale_inspect = 1.0

info.jwst_slope.binfactor = info.binfactor ; set default 

if(info.jwst_data.subarray ne 0) then begin
 image_size = info.jwst_data.slope_xsize
 if(info.jwst_data.slope_ysize gt image_size) then image_size = info.jwst_data.slope_ysize

   ; default for subarray less than or =  256
    if(image_size le 256) then info.jwst_slope.binfactor = 1.0

    if(image_size gt 256 ) then begin
	info.jwst_slope.binfactor = image_size/256
    endif

    if(image_size lt  256 ) then begin
	info.jwst_slope.binfactor = 256/image_size
    endif

; look at specific subarrays smaller than 256
    if(image_size eq 16 ) then begin
        info.jwst_slope.binfactor = 1.0/16.0
        info.jwst_slope.scale_zoom = 16
    endif
    if(image_size eq 32 or image_size eq 36) then begin
        info.jwst_slope.binfactor = 1.0/8.0
        info.jwst_slope.scale_zoom = 8
    endif

    if(image_size eq 64 or image_size eq 68) then begin
        info.jwst_slope.binfactor = 1.0/4.0
        info.jwst_slope.scale_zoom = 4
    endif

    if(image_size eq 128 or image_size eq 132) then begin
        info.jwst_slope.binfactor = 1.0/2.0
        info.jwst_slope.scale_zoom = 2
    endif
    if(image_size eq 864) then begin
        info.jwst_slope.binfactor = 4.0
    endif
endif 

end

;_______________________________________________________________________


pro jwst_find_binfactor,subarray,image_xsize,image_ysize,binfactor

binfactor =4


if(subarray ne 0) then begin
 image_size = image_xsize
 if(image_ysize gt image_size) then image_size = image_ysize

   ; default for subarray less than or =  256
    if(image_size le 256) then binfactor = 1.0

    if(image_size gt 256 ) then begin
	binfactor = image_size/256
    endif

    if(image_size lt  256 ) then begin
	binfactor = 256/image_size
    endif

   ; default for subarray greater than  256
    if(image_size gt 256 ) then ibinfactor = 2.0

; look at specific subarrays smaller than 256
    if(image_size eq 16) then begin
        binfactor = 1.0/16.0
    endif
    if(image_size eq 32 or image_size eq 36) then begin
        binfactor = 1.0/8.0
    endif

    if(image_size eq 64 or image_size eq 68) then begin
        binfactor = 1.0/4.0
    endif

    if(image_size eq 128 or image_size eq 132) then begin
        binfactor = 1.0/2.0
    endif
    if(image_size eq 864) then begin
        binfactor = 4.0
    endif
endif 

end

;_______________________________________________________________________
pro find_zoom,xsize,ysize,zoom



large_size = ysize
if(xsize gt ysize) then large_size = xsize
zoom = fix(1024/large_size)

zoom_test = float(zoom/2.0) - fix(zoom/2)
;if(zoom_test ne 0) then begin
    if(zoom ge 1 and zoom lt 2) then zoom = 1    
    if(zoom ge 2 and zoom lt 4) then zoom = 2    
    if(zoom ge 4 and zoom lt 8) then zoom = 4    
    if(zoom ge 8 and zoom lt 16) then zoom = 8    
    if(zoom ge 16 and zoom lt 32) then zoom = 16
    if(zoom ge 32) then zoom =32
;endif 


end

        
    


