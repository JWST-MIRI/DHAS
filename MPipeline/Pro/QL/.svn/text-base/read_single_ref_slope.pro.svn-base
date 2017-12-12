pro read_single_ref_slope,filename,exists,this_integration, subarray,$
  data,xsize_image,ysize_image,zsize_image,stats_image,status,error_message

 ;
file_exist2 = file_test(filename,/regular,/read)

stats_image = fltarr(9)
 exists = 0   
if(file_exist2 ne  1)then begin
;    print,' No reference slope image exists: ',filename

    data = fltarr(1,1)
    data[*] = 0
    stats_image[*] = 0


endif else begin
    exists = 1
    widget_control,/hourglass
    progressBar = Obj_New("ShowProgress", color = 150, $
                      message = " Reading in Reference Slope Data",$
                      xsize = 250, ysize = 40)


    progressBar -> Start


    fits_open,filename,fcb
    fits_read,fcb,cube_raw,header_raw,/header_only,exten_no = 0
    check = fxpar(header_raw,'MS_VER',count = count)
    if(count eq 0) then begin
        error_message = ' You did not open a slope image, try again'
        status = 1
        return
    endif


    nints = fxpar(header_raw,'NPINT',count = count)
    if(count eq 0) then     nints = fxpar(header_raw,'NINT',count = count)
    if(count eq 0) then nints = 1
    if(nints eq 0) then nints = 1



    naxis1 = fxpar(header_raw,'NAXIS1',count = count)
    naxis2 = fxpar(header_raw,'NAXIS2',count = count)
    naxis3 = fxpar(header_raw,'NAXIS3',count = count)
    colstart = fxpar(header_raw,'COLSTART',count = count) ; For JPL data this value is not correct for value > 1
                                ; for this routine is does not matter
                                ; what the exact value of colstart is
                                ; for values > 1
    if(count eq 0) then colstart = 1

    print,' Reading Reference Slope Image data ',filename

    fits_read,fcb,cube_raw,exten_no = this_integration+1
    size_cube = size(cube_raw)

    
    xsize_image = size_cube(1)
    ysize_image = size_cube(2)
    zsize_image = size_cube(3)

    fits_close,fcb

    data= fltarr(xsize_image,ysize_image)
    fits_open,filename,fcb

    percent = .98
    progressBar -> Update,percent
    
    fits_read,fcb,cube,header,exten_no = this_integration+1
    size_cube = size(cube)
    data[*,*] = cube[*,*,0]
    fits_close,fcb
    cube = 0
;_______________________________________________________________________
;
; stats on slopes, slope_stat[mean,sigma,min,max]
;                  slope_range[min,max] starting values for min,max dsplay range
    


    if(subarray eq 0) then ref = data[1:xsize_image-2,*]
    if(subarray eq 1) then begin 
        if(colstart eq 1) then ref = data[1:xsize_image-1,*]
        if(colstart ne 1) then ref  = data
    endif


    get_image_stat,ref,image_mean,stdev_pixel,image_min,image_max,$
                   irange_min,irange_max,image_median,stdev_mean,skew,ngood,nbad


    stats_image[0] = image_mean
    stats_image[1] = image_median
    stats_image[2] = stdev_pixel
    stats_image[3]  = image_min
    stats_image[4] = image_max
    stats_image[5] = irange_min
    stats_image[6] = irange_max
    stats_image[7] = stdev_mean
    stats_image[8] = skew
    ref = 0


    progressBar -> Destroy
    obj_destroy, progressBar
endelse

end
