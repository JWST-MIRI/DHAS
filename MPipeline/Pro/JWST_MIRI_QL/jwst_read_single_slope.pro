
pro jwst_read_single_slope,filename,exists,this_integration,$
                           subarray,slope_data,$
                           image_xsize,image_ysize,stats_image,$
                           status,error_message

status = 0
error_message = ''
slope_data = 0

exists = 1
file_exist1 = file_test(filename,/regular,/read)

if(file_exist1 ne 1 ) then begin
    error_message = 'The slope file does not exist, run calwebb_detector1' + filename
    status = 1
    exists = 0
    print,error_message
    return
endif

;_______________________________________________________________________
; read in Reduced data - rate_int
;_______________________________________________________________________
;
fits_open,filename,fcb
fits_read,fcb,cube,header,/header_only,exten_no = 0

ngroups = fxpar(header,'NGROUPS',count=count)
if(count eq 0) then ngroups = fxpar(header,'NGROUPS',count = count)
if(count eq 0) then ngroups = 0
nints = fxpar(header,'NINTS',count = count)
if(count eq 0) then nints = fxpar(header,'NINT',count = count)
if(count eq 0) then nints = 1
if(nints eq 0) then nints  = 1

colstart = fxpar(header,'SUBSTRT1',count=count) 
if(count eq 0) then colstart = 1
;_______________________________________________________________________
; test if selected integration  out of bounds of file. 

if(this_integration+1 gt nints) then begin
    sint = strcompress(string(this_integration+1),/remove_all)
    serror = "The requested integration (" + sint+ ") for file" + filename + $
             " is out of bounds"
    error_message = serror
    status = 2
    return
endif

;_______________________________________________________________________

fits_read,fcb,sdata_all,header,exten_no = 1
naxis1 = fxpar(header,'NAXIS1',count = count)
naxis2 = fxpar(header,'NAXIS2',count = count)
image_xsize = naxis1
image_ysize = naxis2
fits_read,fcb,edata_all,header,exten_no = 2
fits_read,fcb,dqdata_all,header,exten_no =3

fits_close,fcb

sdata = sdata_all[*,*,this_integration]
dqdata = dqdata_all[*,*,this_integration]
edata = edata_all[*,*,this_integration]

slope_data  = fltarr(naxis1,naxis2,3)
slope_data[*,*,0] = sdata
slope_data[*,*,1] = edata
slope_data[*,*,2] = float(dqdata)

sdata_all = 0 & dqdata_all = 0 & edata_all = 0
sdata=0 & dqdata = 0 & edata = 0 

subarray = 0
if(naxis1 ne 1032) then begin
    subarray = 1
endif 

print,' Reading Slope data ',filename
print,' Number of Integrations:',nints
print,' Number of frames/int:  ',ngroups
print,' Requested integration ',this_integration+1
print,'size of science image',image_xsize,image_ysize
;_______________________________________________________________________

image_zsize = 1
stats_image = fltarr(8,3)
for i = 0,2 do begin

    data = slope_data[*,*,i]
    data_noref = data

    if(subarray eq 0) then data_noref = data[4:1027,*]
    if(subarray eq  1 and colstart eq 1) then data_noref = data[4:*,*]

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

    data_noref = 0
    
    if(finite(irange_min) ne 1) then stats_image[5,i] = 0
    if(finite(irange_max) ne 1) then stats_image[6,i] = 0
 endfor


data = 0
data_noref = 0

;_______________________________________________________________________
;


end

