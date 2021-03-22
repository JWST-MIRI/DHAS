pro jwst_read_single_cal,filename,exists,$
                         subarray,cal_data,$
                         image_xsize,image_ysize,stats_image,$
                         status,error_message

status = 0
error_message = ''
cal_data = 0

exists = 1
file_exist1 = file_test(filename,/regular,/read)
if(file_exist1 ne 1 ) then begin
    error_message = 'The cal file does not exist, looking for ' + filename
    status = 1
    exists = 0
    return
endif
;_______________________________________________________________________
; read in Calibrated data
;_______________________________________________________________________
fits_open,filename,fcb
print,' Reading cal data ',filename
fits_read,fcb,cdata,header,exten_no = 1
naxis1 = fxpar(header,'NAXIS1',count = count)
naxis2 = fxpar(header,'NAXIS2',count = count)

fits_read,fcb,edata,header,exten_no = 2
fits_read,fcb,dqdata,header,exten_no = 3

image_xsize = naxis1
image_ysize = naxis2

subarray = 0
if(naxis1 ne 1032) then begin
    subarray = 1
endif

cal_data  = fltarr(naxis1,naxis2,3)
cal_data[*,*,0] = cdata
cal_data[*,*,1] = edata
cal_data[*,*,2] = float(dqdata)
cdata =0 
edata = 0 
dqdata = 0 

fits_close,fcb
stats_image = fltarr(8,3)
for i = 0,2 do begin
    data = cal_data[*,*,i]

    if(subarray eq 0) then begin  
        data_noref = fltarr(1024,1024)
        data_noref[0:1023,*]  = data[4:1027,*]
    endif else begin 
        data_noref = data
    endelse

    jwst_get_image_stat,data_noref,image_mean,stdev_pixel,image_min,image_max,$
                   irange_min,irange_max,image_median,stdev_mean

    stats_image[0,i] = image_mean
    stats_image[1,i] = image_median
    stats_image[2,i] = stdev_pixel
    stats_image[3,i]  = image_min
    stats_image[4,i] = image_max
    stats_image[5,i] = irange_min
    stats_image[6,i] = irange_max
    stats_image[7,i] = stdev_mean
    if(i eq 2) then begin       ; DQ image change how it is displayed
       stats_image[5,i] = 0
       stats_image[6,i] = 32
    endif
endfor
data = 0
data_noref = 0
end

