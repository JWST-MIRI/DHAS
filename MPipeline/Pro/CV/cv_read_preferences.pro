pro cv_read_preferences,filename,$
  miri_dir,$
  dirred,dircube,dirps,$
  calibration_version,status


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
    for i = 0,10 do begin
        line = strarr(1)
        readf,unit,line
;        print,i,line
        if(i eq 0) then print,' Version of Preferences file',line

        if(i eq 1) then begin  ; input directory for science images
            extract_value,line,value,flag
            if(flag eq 1) then dirred = value[0]
            dirred = strcompress(dirred,/remove_all)
            len = strlen(dirred) 
            test = strmid(dirred,len-1,len-1)
            if(test eq '/') then dirred = strmid(dirred,0,len-1)

        endif

        if(i eq 3) then begin  ; input directory for cube data
            extract_value,line,value,flag
            if(flag eq 1) then dircube = value[0]
            dircube = strcompress(dircube,/remove_all)
            len = strlen(dircube) 
            test = strmid(dircube,len-1,len-1)
            if(test eq '/') then dircube = strmid(dircube,0,len-1)
            

        endif

        if(i eq 4) then begin  ; output postscript directory
            extract_value,line,value,flag
            if(flag eq 1) then dirps = value[0]
            dirps = strcompress(dirps,/remove_all)
            len = strlen(dirps) 
            test = strmid(dirps,len-1,len-1)
            if(test eq '/') then dirps = strmid(dirps,0,len-1)
        endif

        if(i eq 8) then begin  ; calibration file version # for channel 1 & 2
            extract_value,line,value,flag
            if(flag eq 1) then cal_file= value[0]
            calibration_version[0] = strcompress(cal_file,/remove_all)
        endif

        if(i eq 9) then begin  ; calibration file version # for channel 3 & 4
            extract_value,line,value,flag
            if(flag eq 1) then cal_file= value[0]
            calibration_version[1] = strcompress(cal_file,/remove_all)
        endif


;_______________________________________________________________________


        
    endfor
endif
close,unit
free_lun,unit
end
