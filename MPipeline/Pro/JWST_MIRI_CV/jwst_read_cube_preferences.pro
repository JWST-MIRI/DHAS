pro jwst_read_cube_preferences,filename,$
                               miri_dir,$
                               dirps,status


status = 1
get_lun,unit
openr,unit,filename,error=err

if(err NE 0) then begin
    print,!ERROR_STATE.MSG
    stop
endif
line = 'g'
if(err eq 0) then begin
    status = 0
    for i = 0,1 do begin
        line = strarr(1)
        readf,unit,line

        if(i eq 0) then print,' Version of Preferences file',line

        if(i eq 1) then begin  ; output postscript directory
            extract_value,line,value,flag
            if(flag eq 1) then dirps = value[0]
            dirps = strcompress(dirps,/remove_all)
            len = strlen(dirps) 
            test = strmid(dirps,len-1,len-1)
            if(test eq '/') then dirps = strmid(dirps,0,len-1)
        endif
        
    endfor
endif
close,unit
free_lun,unit
end
