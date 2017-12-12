pro cv_read_image_file,slope_file,slope_data,naxis1,naxis2,naxis3,extno,subarray,status,error_message

status = 0

; read in the slope image file

file_exist = file_test(slope_file,/regular,/read)
if(file_exist ne 1) then begin
    status = 1
    error_message = ' Slope file does not exist'
    return
endif

print,'Reading Slope file',slope_file
fits_open,slope_file,fcb
fits_read,fcb,data,header,exten_no = extno
naxis1 = fxpar(header,'NAXIS1',count = count)
naxis2 = fxpar(header,'NAXIS2',count = count)
naxis3 = fxpar(header,'NAXIS3',count = count)
subarray = 0
if(naxis1 ne 1032 or naxis2 ne 1024) then subarray = 1

slope_data = data[*,*,0]
data = 0
 

header = 0
fits_close,fcb

end
