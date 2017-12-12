@extract_value_preferences.pro 
pro wcal_read_inputs,infile,cubefile_a,cubefile_b,d2cfile_in,d2cfile_out,status

status= 1
get_lun,unit
openr,unit,infile,error = err
if(err NE 0) then begin
    print,!ERROR_STATE.MSG
    stop
endif
line = 'g'
if(err eq 0) then begin
    status = 0
    for i = 0,5 do begin
        line = strarr(1)
        readf,unit,line
        if(i eq 2) then begin
            extract_value,line,value,flag
            if(flag eq 1) then cubefile_a = value[0]
            cubefile_a = strcompress(cubefile_a,/remove_all)
        endif

        if(i eq 3) then begin
            extract_value,line,value,flag
            if(flag eq 1) then cubefile_b = value[0]
            cubefile_b = strcompress(cubefile_b,/remove_all)
        endif

        if(i eq 4) then begin
            extract_value,line,value,flag
            if(flag eq 1) then d2cfile_in = value[0]
            d2cfile_in = strcompress(d2cfile_in,/remove_all)
        endif

        if(i eq 5) then begin
            extract_value,line,value,flag
            if(flag eq 1) then d2cfile_out = value[0]
            d2cfile_out = strcompress(d2cfile_out,/remove_all)
        endif


    endfor
endif

close,unit
free_lun,unit
print,' Original Cube:                 ',cubefile_a
print,' New Wavelength Cube:           ',cubefile_b
print,' Input D2C Calibration file:    ',d2cfile_in
print,' Output D2C Calibration file:   ',d2cfile_out

end
