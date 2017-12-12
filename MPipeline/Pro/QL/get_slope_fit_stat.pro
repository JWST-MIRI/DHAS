pro get_slope_fit_stat,info,this_integration,slope_fit


widget_control,/hourglass
progressBar = Obj_New("ShowProgress", color = 150, $
                      message = " Reading in Data to Find Slope Fit Image",$
                      xsize = 250, ysize = 40)
progressBar -> Start    

slope_fit = fltarr(info.data.image_xsize,info.data.image_ysize,2)
if(info.data.slope_exist eq 1) then begin 
    
    file_exist1 = file_test(info.control.filename_slope,/regular,/read)

    if(file_exist1 ne 1 ) then begin
        error_message = 'The slope file does not exist, run miri_sloper first ' + filename
        status = 1
        exists = 0
        print,error_message
        return
    endif
    
    fits_open,info.control.filename_slope,fcb

    fits_read,fcb,slopedata,header,exten_no = this_integration+1
    naxis1 = fxpar(header,'NAXIS1',count = count)
    naxis2 = fxpar(header,'NAXIS2',count = count)
    naxis3 = fxpar(header,'NAXIS3',count = count)
    frametime = fxpar(header,'FRMTIME',count = count)
    if(count eq 0) then frametime = 2.775

    fit_start = fxpar(header,'NSFITS',count = count)
    if(count eq 0) then fit_start = 0
    fit_end = fxpar(header,'NSFITE',count = count)
    if(count eq 0) then fit_end = 0


    slope = slopedata[*,*,0]
    if(naxis3 eq 2) then begin
        zeropt = slopedata[*,*,1]
    endif else begin
        zeropt = slopedata[*,*,3]
    endelse

    fits_close,fcb
    slopedata = 0
    header = 0

;_______________________________________________________________________
; dataset to make comparison (raw file, reference corrected, or
 ; linearity corrected)

    filename = info.control.filename_raw

    if(info.control.file_refcorrection_exist eq 1) then $
      filename = info.control.filename_refcorrection

    if(info.control.file_lc_exist eq 1) then $ 
      filename = info.control.filename_LC

    print,' Slope Fit comparison filename',filename

    file_exist1 = file_test(filename,/regular,/read)

    if(file_exist1 ne 1 ) then begin
        error_message = 'The  file does not exist' + filename
        status = 1
        exists = 0
        print,error_message
        return
    endif

    fits_open,filename,fcb
    

    
    fits_read,fcb,cube,header


    this_num_frames = info.data.nramps


    m = (this_integration * info.data.nramps) + fit_start 

    if(fit_end eq 0) then fit_end = info.data.nramps

    print,'Reading integration #',this_integration+1
    print,'Reading frame - to - ',fit_start,fit_end

    ii = 0
    this_num_frames = fit_end - fit_start + 1
    endtest = m + this_num_frames
    


    for i = 0,this_num_frames-1 do begin 
        if(m+i lt endtest) then begin 
            print,'reading slice',m+i 
        
            percent = (float(i)/float(this_num_frames) * 90)
            progressBar -> Update,percent

;            im_raw = readfits_miri(filename,nslice = m+i,/silent)        
            im_raw = readfits(filename,nslice = m+i,/silent)        

            xsize = info.data.image_xsize
            ysize = info.data.image_ysize
            comparedata = im_raw[0:xsize-1,0:ysize-1]
            
            this_frame  = i +fit_start
            fit = slope*this_frame + zeropt
            diff = comparedata
            diff[*,*] = 0
            index = where(finite(slope) eq 1)
            diff[index] = (comparedata[index] - fit[index]) 
            slope_fit[index,0] = (diff[index]* diff[index] ) + slope_fit[index,0] 
            slope_fit[index,1] = slope_fit[index,1] + 1
            ;stop
        endif
    endfor

            
    fits_close,fcb

    index = where(slope_fit[*,*,1] gt 0)
    slope_fit[index,0] = slope_fit[index,0]/slope_fit[index,1]
    
endif

help,slope_fit



progressBar -> Destroy
obj_destroy, progressBar
end
