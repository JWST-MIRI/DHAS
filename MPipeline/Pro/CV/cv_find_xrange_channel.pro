
pro  cv_find_xrange_channel,channel,calibration_file,xrange


file_exist = file_test(calibration_file,/regular,/read)
if(file_exist ne 1) then begin
    status = 1
    error_message = ' Calibration file does not exist'
    return
endif

xrange = intarr(4,2)

fits_open,calibration_file,fcb
fits_read,fcb,data,header,exten_no = 0,/header_only
if(channel eq 1 or channel eq 2) then begin 
    xrange[0,0] = 0.0
    xmax = fxpar(header,'XMX_1_1',count = count)
    xrange[0,1] = xmax
    

    xmin = fxpar(header,'XMN_2_1',count = count)
    xrange[1,0] = xmin
    xrange[1,1] = 1032
endif

if(channel gt 2) then begin

    xmin = fxpar(header,'XMN_3_16',count = count)
    xrange[2,0] = xmin
    xrange[2,1] = 1032
    
    xrange[3,0] = 0
    xmax = fxpar(header,'XMX_4_1',count = count)
    xrange[3,1] = xmax
endif

fits_close,fcb
end


    
