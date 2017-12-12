pro cv_read_calibration_file,calibration_file, alpha,lamba,sliceno,status,error_message

status = 0


; read in the calibration - d2c file. 

file_exist = file_test(calibration_file,/regular,/read)
if(file_exist ne 1) then begin
    status = 1
    error_message = ' Calibration file does not exist ' + calibration_file
    return
endif

print,'Reading Calibration file',calibration_file
fits_open,calibration_file,fcb
fits_read,fcb,data,header,exten_no = 1
naxis1 = fxpar(header,'NAXIS1',count = count)
naxis2 = fxpar(header,'NAXIS2',count = count)
;naxis3 = fxpar(header,'NAXIS3',count = count)


if(naxis1 ne 1033  or naxis2 ne 1025  ) then begin
    status = 1
    error_message = ' Calibration file is not the correct size'
    print,error_message
    return
endif


lamba = data[*,*]
fits_read,fcb,data,header,exten_no = 2
alpha = data[*,*]; 
fits_read,fcb,data,header,exten_no = 3
sliceno = data[*,*]


fits_close,fcb

data = 0
header = 0


end
