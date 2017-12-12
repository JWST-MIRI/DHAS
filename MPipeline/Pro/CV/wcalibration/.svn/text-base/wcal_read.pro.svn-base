@extract_value_preferences.pro 
pro wcal_read,infile,slopefile,cubefile,d2cfile,channel,saveset,peaksfile,polyfit,status
method = 1
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
    for i = 0,8 do begin
        line = strarr(1)
        readf,unit,line

        if(i eq 2) then begin
            extract_value,line,value,flag
            if(flag eq 1) then slopefile = value[0]
            slopefile = strcompress(slopefile,/remove_all)
        endif
        if(i eq 3) then begin
            extract_value,line,value,flag
            if(flag eq 1) then cubefile = value[0]
            cubefile = strcompress(cubefile,/remove_all)
        endif
        if(i eq 4) then begin
            extract_value,line,value,flag
            if(flag eq 1) then d2cfile = value[0]
            d2cfile = strcompress(d2cfile,/remove_all)
        endif

        if(i eq 5) then begin
            extract_value,line,value,flag
            if(flag eq 1) then channel = value[0]
        endif

        if(i eq 6) then begin
            extract_value,line,value,flag
            if(flag eq 1) then saveset = value[0]
            saveset = strcompress(saveset,/remove_all)
        endif



        if(i eq 7) then begin
            extract_value,line,value,flag
            if(flag eq 1) then peaksfile = value[0]
            peaksfile = strcompress(peaksfile,/remove_all)
        endif

        if(i eq 8) then begin
            extract_value,line,value,flag
            if(flag eq 1) then polyfit = value[0]
            polyfit = strcompress(polyfit,/remove_all)
        endif



    endfor
endif

close,unit
free_lun,unit
print,' Slope (LVL2 or LVL3):          ',slopefile
print,' Original Cube:                 ',cubefile
print,' Saveset:                       ',saveset
print,' Peaks file:                    ',peaksfile
print,' Input D2C Calibration file:    ',d2cfile
print,' Working on channel:            ',channel
print,' Output file: ', polyfit

end
