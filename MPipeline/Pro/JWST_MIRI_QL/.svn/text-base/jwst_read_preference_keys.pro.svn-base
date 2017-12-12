@extract_value_preferences.pro 

pro jwst_read_preference_keys,filename,miri_dir,$
                         dirin,dirout,dirps,$
                         int_num,frame_num, $
                         read_limit,$
                         status


status = 0
get_lun,unit
openr,unit,filename,error=err
if(err NE 0) then begin
    print,'****************************************************************************'
    print,'Problem opening preference file',filename
    print,'Check that you have the correct path for the environment varible MIRI_DIR'
    print,'If it is wrong correct .bashrc or equivalent file, source file and run again'
    print,!ERROR_STATE.MSG
    print,'****************************************************************************'
    stop
endif
line = 'g'
key = strarr(100)
value = strarr(100)
ik = 0 
cdp_jpl = 'NA'
while( not eof(unit)) do begin
   line = strarr(1)
   readf,unit,line
   this_key = '' & this_value = ''
   extract_key,line,this_key,this_value
   key[ik] = this_key
   value[ik] = this_value
   ik = ik + 1
endwhile

close,unit
free_lun,unit

;_______________________________________________________________________
ifound = 0 
this_key = 'SCIDIR'
i = 0 
while(ifound eq 0 and i lt ik) do begin
   key_compare = key[i] 
   if(strcmp(this_key,key_compare,/FOLD_CASE) eq 1 ) then begin
      ifound = 1
      dirin = value[i]
      len = strlen(dirin) 
      test = strmid(dirin,len-1,len-1)
      if(test eq '/') then dirin = strmid(dirin,0,len-1)
   endif
   i = i + 1
endwhile
if(ifound eq 0) then print,'DID not find Directory for Raw Science  files' 
;_______________________________________________________________________
ifound = 0 
this_key = 'PROCESSDIR'
i = 0 
while(ifound eq 0 and i lt ik) do begin
   key_compare = key[i] 
   if(strcmp(this_key,key_compare,/FOLD_CASE) eq 1 ) then begin
      ifound = 1
      dirout = value[i]
      len = strlen(dirout) 
      test = strmid(dirout,len-1,len-1)
      if(test eq '/') then dirout = strmid(dirout,0,len-1)
   endif
   i = i + 1
endwhile
if(ifound eq 0) then print,'DID not find Directory for Rate Science files' 
;_______________________________________________________________________
ifound = 0 
this_key = 'PSDIR'
i = 0 
while(ifound eq 0 and i lt ik) do begin
   key_compare = key[i] 
   if(strcmp(this_key,key_compare,/FOLD_CASE) eq 1 ) then begin
      ifound = 1
      dirps = value[i]
      len = strlen(dirps) 
      test = strmid(dirps,len-1,len-1)
      if(test eq '/') then dirps = strmid(dirps,0,len-1)
   endif
   i = i + 1
endwhile
if(ifound eq 0) then print,'DID not find Directory to write postscript files' 
;_______________________________________________________________________
ifound = 0 
this_key = 'FIRST_INT'
i = 0 
while(ifound eq 0 and i lt ik) do begin
   key_compare = key[i] 
   if(strcmp(this_key,key_compare,/FOLD_CASE) eq 1 ) then begin
      ifound = 1
      int_num = fix(value[i])
   endif
   i = i + 1
endwhile
if(ifound eq 0) then print,'Missing Keyword in preference file',this_key 
;_______________________________________________________________________
ifound = 0 
this_key = 'FIRST_FRAME'
i = 0 
while(ifound eq 0 and i lt ik) do begin
   key_compare = key[i] 
   if(strcmp(this_key,key_compare,/FOLD_CASE) eq 1 ) then begin
      ifound = 1
      frame_num = fix(value[i])
   endif
   i = i + 1
endwhile
if(ifound eq 0) then print,'Missing Keyword in preference file',this_key 
;_______________________________________________________________________
ifound = 0 
this_key = 'NFRAME_READ'
i = 0 
while(ifound eq 0 and i lt ik) do begin
   key_compare = key[i] 
   if(strcmp(this_key,key_compare,/FOLD_CASE) eq 1 ) then begin
      ifound = 1
      read_limit = fix(value[i])
   endif
   i = i + 1
endwhile
if(ifound eq 0) then print,'Missing Keyword in preference file',this_key 
;_______________________________________________________________________


end
