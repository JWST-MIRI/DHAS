;_______________________________________________________________________
pro setup_slope_image,info

status = 0
reading_slope_header,info,status,error_message

if(status eq 1) then begin
    result = dialog_message(error_message,/error)
    return
endif


subarray = 0
bad_file  = ''
do_bad = 0
integrationNO = info.control.int_num
read_single_slope,info.control.filename_slope,slope_exists,$
                  integrationNO,subarray,slopedata,$
                  slope_xsize,slope_ysize,slope_zsize,stats,$
                  do_bad,bad_file,$
                  status,error_message
info.data.slope_xsize = slope_xsize
info.data.slope_ysize = slope_ysize
info.data.slope_zsize = slope_zsize
info.data.slope_exist  = slope_exists

if ptr_valid (info.data.pslopedata) then ptr_free,info.data.pslopedata
info.data.pslopedata = ptr_new(slopedata)
info.data.slope_stat = stats

slopedata = 0
stats = 0


if(status ne 0) then begin
    ok = dialog_message(error_message,/Information)
    return
endif
info.control.int_num = info.control.int_num_save

info.data.cal_exist = 0
header_setup,2,info
header_setup_slope,info
reading_header,info             ; read in raw header 
end


;_______________________________________________________________________

pro setup_cal_image,info
info.data.cal_exist = 0
cal_exists = 0
status = 0 & error_message = " " 
read_single_cal,info.control.filename_cal,cal_exists,$
                info.image.integrationNO,info.data.subarray,caldata,$
                cal_xsize,cal_ysize,cal_zsize,stats,$
                status,error_message
info.data.cal_exist = cal_exists
if(cal_exists eq 1) then begin 
    info.data.cal_xsize = cal_xsize
    info.data.cal_ysize = cal_ysize
    info.data.cal_zsize = cal_zsize
    if ptr_valid (info.data.pcaldata) then ptr_free,info.data.pcaldata
    info.data.pcaldata = ptr_new(caldata)
    info.data.cal_stat = stats
    caldata = 0
    stats = 0
            
    header_setup_cal,info 
    
endif

end
