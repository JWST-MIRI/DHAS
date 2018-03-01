
pro read_single_slope,filename,exists,this_integration,$
  subarray,slopedata,image_xsize,image_ysize,image_zsize,stats_image,$
  do_bad,bad_file,status,error_message

status = 0
error_message = ''
slopedata = 0
do_bad = 0
bad_file = ''


exists = 1
file_exist1 = file_test(filename,/regular,/read)


if(file_exist1 ne 1 ) then begin
    error_message = 'The slope file does not exist, run miri_sloper first ' + filename
    status = 1
    exists = 0
    print,error_message
    return
endif

;_______________________________________________________________________
; read in Reduced data
;_______________________________________________________________________
;

fits_open,filename,fcb
fits_read,fcb,cube,header,/header_only,exten_no = 0

nramps = fxpar(header,'NPGROUP',count=count)
if(count eq 0) then nramps = fxpar(header,'NGROUPS',count = count)
if(count eq 0) then nramps = 0
nints = fxpar(header,'NPINT',count = count)
if(count eq 0) then nints = fxpar(header,'NINT',count = count)
if(count eq 0) then nints = 1
if(nints eq 0) then nints  = 1

framediv = 1
framediv = fxpar(header,'FRMDIVSR',count=count)
if(framediv ne 1 and count ne 0 ) then begin
   print,' FRMDIVSR is not 1, this is FASTGRPAVG data, adjusting NGroups for QL tool'
   nramps = nramps/framediv
endif

colstart = fxpar(header,'COLSTART',count=count) ; for JPL data this value is not correct for values >1
                                ; for this routine is does not matter
                                ; what the exact value of colstart is
                                ; for values > 1 
if(count eq 0) then colstart = 1

do_bad_string = fxpar(header,'RMBADPIX',count = count)
do_bad_str = strcompress(strlowcase(do_bad_string),/remove_all)
yes_string = 'yes'
;print,'Apply bad pixels',do_bad_str
result = strcmp(do_bad_str,yes_string)
if(result eq 1) then begin
    bad_file  = fxpar(header,'BADPFILE',count = count)
    do_bad = 1
      file_decompose, bad_file, disk,path, name, extn, version	

      bad_file = name+extn

    if(count = 0) then begin
        bad_file = ''
        do_bad = 0
    endif
endif 
    
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

fits_read,fcb,slopedata,header,exten_no = this_integration+1
naxis1 = fxpar(header,'NAXIS1',count = count)
naxis2 = fxpar(header,'NAXIS2',count = count)
naxis3 = fxpar(header,'NAXIS3',count = count)
image_xsize = naxis1
image_ysize = naxis2
image_zsize = naxis3

if(image_zsize eq 0) then begin ; Quick slope processing will an image of 1032 X 1024 X 2
                                ; image of 1032 X 1024 only
    image_zsize = 1
    data = slopedata
    slopedata = fltarr(naxis1,naxis2,1)
    slopedata[*,*,0] = data
    data = 0
endif
    


subarray = 0
if(naxis1 ne 1032) then begin
    subarray = 1
endif 

print,' Reading Slope data ',filename
print,' Number of Integrations:',nints
print,' Number of frames/int:  ',nramps
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

    data = slopedata[*,*,i]
    data_noref = data

    if(subarray eq 0) then data_noref = data[4:1027,*]
    if(subarray eq  1 and colstart eq 1) then data_noref = data[4:*,*]

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
    data_noref = 0

    if(finite(irange_min) ne 1) then stats_image[5,i] = 0
    if(finite(irange_max) ne 1) then stats_image[6,i] = 0
endfor
data = 0
data_noref = 0

;_______________________________________________________________________
;


end

