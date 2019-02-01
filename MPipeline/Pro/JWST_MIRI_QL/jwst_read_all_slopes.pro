pro jwst_read_all_slopes,info, slopedata,status,error_message

message = info.jwst_data.nints
imessage = 0
if(message gt 300) then imessage = 1
if(imessage ) then begin 
    widget_control,/hourglass
    progressBar = Obj_New("ShowProgress", color = 150, $
                          message = " Reading in Slope Data ",$
                          xsize = 250, ysize = 40)
    progressBar -> Start
endif
; _______________________________________________________________________

slopedata = fltarr(info.jwst_data.slope_xsize,$
                   info.jwst_data.slope_ysize,$
                   info.jwst_data.nints+1)

fits_open,info.jwst_control.filename_slope,fcb
fits_read,fcb,data,header,exten_no = 1
slopedata[*,*,0] = data

fits_close,fcb

if(info.jwst_control.file_slope_int_exist eq 1) then begin 
   fits_open,info.jwst_control.filename_slope_int,fcb
   fits_read,fcb,data,header,exten_no = 1
   slopedata[*,*,1:info.jwst_data.nints] = data
   fits_close,fcb
endif
end

