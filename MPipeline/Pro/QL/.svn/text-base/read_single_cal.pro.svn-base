
pro read_single_cal,filename,exists,this_integration,$
  subarray,caldata,image_xsize,image_ysize,image_zsize,stats_image,$
  status,error_message

status = 0
error_message = ''
slopedata = 0

exists = 1
file_exist1 = file_test(filename,/regular,/read)


if(file_exist1 ne 1 ) then begin
    error_message = 'The cal file does not exist, run miri_caler first ' + filename
    status = 1
    exists = 0
    return
endif

;_______________________________________________________________________
; read in Reduced data
;_______________________________________________________________________
;

fits_open,filename,fcb
fits_read,fcb,cube,header,/header_only,exten_no = 0


nints = fxpar(header,'NCINT',count = count)
if(count eq 0) then nints = 0


    
;_______________________________________________________________________
; test if selected integration out of bounds of file. 

if(this_integration+1 gt nints) then begin
    sint = strcompress(string(this_integration+1),/remove_all)
    serror = "The requested integration (" + sint+ ") for file" + filename + $
             " is out of bounds"
    error_message = serror
    status = 2
    return
endif

;_______________________________________________________________________

fits_read,fcb,caldata,header,exten_no = this_integration+1
naxis1 = fxpar(header,'NAXIS1',count = count)
naxis2 = fxpar(header,'NAXIS2',count = count)
naxis3 = fxpar(header,'NAXIS3',count = count)
image_xsize = naxis1
image_ysize = naxis2
image_zsize = naxis3

subarray = 0
if(naxis1 ne 1032) then begin
    subarray = 1
endif

print,' Reading cal data ',filename
print,' Number of Integrations:',nints
print,' Requested integration ',this_integration+1
print,'size of science image',image_xsize,image_ysize
print,' Number of planes ', image_zsize

fits_close,fcb
;_______________________________________________________________________
;
; stats on images, image_stat[mean,sigma,min,max]
;                  image_range[min,max] starting values for min,max
;                  dsplay range


stats_image = fltarr(11,image_zsize)
for i = 0,image_zsize -1 do begin
    data = caldata[*,*,i]

    if(subarray eq 0) then begin  
        data_noref = fltarr(1024,1024)
        data_noref[0:1023,*]  = data[4:1027,*]
    endif else begin 
        data_noref = data
    endelse

    get_image_stat,data_noref,image_mean,stdev_pixel,image_min,image_max,$
                   irange_min,irange_max,image_median,stdev_mean,skew,ngood,nbad


    stats_image[0,i] = image_mean
    stats_image[1,i] = image_median
    stats_image[2,i] = stdev_pixel
    stats_image[3,i]  = image_min
    stats_image[4,i] = image_max
    stats_image[5,i] = irange_min
    stats_image[6,i] = irange_max
    stats_image[7,i] = stdev_mean
    stats_image[8,i] = skew
    stats_image[9,i] = ngood
    stats_image[10,i] = nbad

endfor
data = 0
data_noref = 0
;_______________________________________________________________________
;


end

