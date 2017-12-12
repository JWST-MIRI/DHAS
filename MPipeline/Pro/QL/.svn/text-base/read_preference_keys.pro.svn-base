@extract_value_preferences.pro

pro read_preference_keys,filename,miri_dir,$
                         dirin,dirout,dirtel,dirps,$
                         int_num,frame_num,read_limit,frame_limit, subset_size,$
                         tracking_file,start_fit,end_fit,$
                         highDN,$
                         apply_rscd,refpixel_option,delta_row_even_odd,$
                         gain, frametime, display_apply_bad,readnoise, UncertaintyMethod,$
                         cdp_im,cdp_lw,cdp_sw,cdp_jpl,apply_bad,apply_lastframe,$
                         apply_dark,apply_lin,apply_pixel_sat,status


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
if(ifound eq 0) then print,'DID not find Directory for Science LVL1 files' 
;_______________________________________________________________________
ifound = 0 
this_key = 'LVL2DIR'
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
if(ifound eq 0) then print,'DID not find Directory for Science LVL2 files' 
;_______________________________________________________________________
ifound = 0 
this_key = 'TELDIR'
i = 0 
while(ifound eq 0 and i lt ik) do begin
   key_compare = key[i] 
   if(strcmp(this_key,key_compare,/FOLD_CASE) eq 1 ) then begin
      ifound = 1
      dirtel = value[i]
      len = strlen(dirtel) 
      test = strmid(dirtel,len-1,len-1)
      if(test eq '/') then dirtel = strmid(dirtel,0,len-1)
   endif
   i = i + 1
endwhile
if(ifound eq 0) then print,'DID not find Directory for Telemetry files' 
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
this_key = 'CALIM_JPL3'
i = 0 
while(ifound eq 0 and i lt ik) do begin
   key_compare = key[i] 
   if(strcmp(this_key,key_compare,/FOLD_CASE) eq 1 ) then begin
      ifound = 1
      cdp_im = value[i]
   endif
   i = i + 1
endwhile
if(ifound eq 0) then print,'DID not find Imager Calibration List' 

ifound = 0 
this_key = 'CALLW_JPL3'
i = 0 
while(ifound eq 0 and i lt ik) do begin
   key_compare = key[i] 
   if(strcmp(this_key,key_compare,/FOLD_CASE) eq 1 ) then begin
      ifound = 1
      cdp_lw = value[i]

   endif
   i = i + 1
endwhile
if(ifound eq 0) then print,'DID not find LW Calibration List' 

ifound = 0 
this_key = 'CALSW_JPL3'
i = 0 
while(ifound eq 0 and i lt ik) do begin
   key_compare = key[i] 
   if(strcmp(this_key,key_compare,/FOLD_CASE) eq 1 ) then begin
      ifound = 1
      cdp_sw = value[i]
   endif
   i = i + 1
endwhile
if(ifound eq 0) then print,'DID not find SW Calibration List' 


;_______________________________________________________________________
ifound = 0 
this_key = 'FRAME_LIMIT'
i = 0 
while(ifound eq 0 and i lt ik) do begin
   key_compare = key[i] 
   if(strcmp(this_key,key_compare,/FOLD_CASE) eq 1 ) then begin
      ifound = 1
      frame_limit = fix(value[i])
   endif
   i = i + 1
endwhile
if(ifound eq 0) then print,'Missing Keyword in preference file',this_key 
;_______________________________________________________________________
ifound = 0 
this_key = 'ROW_LIMIT'
i = 0 
while(ifound eq 0 and i lt ik) do begin
   key_compare = key[i] 
   if(strcmp(this_key,key_compare,/FOLD_CASE) eq 1 ) then begin
      ifound = 1
      subset_size = fix(value[i])
   endif
   i = i + 1
endwhile
if(ifound eq 0) then print,'Missing Keyword in preference file',this_key 
;_______________________________________________________________________
ifound = 0 
this_key = 'APPLY_RSCD'
i = 0 
while(ifound eq 0 and i lt ik) do begin
   key_compare = key[i] 
   if(strcmp(this_key,key_compare,/FOLD_CASE) eq 1 ) then begin
      ifound = 1
      apply_rscd = fix(value[i])
   endif
   i = i + 1
endwhile
if(ifound eq 0) then print,'Missing Keyword in preference file',this_key 
;_______________________________________________________________________
ifound = 0 
this_key = 'APPLY_PIXEL_SAT'
i = 0 
while(ifound eq 0 and i lt ik) do begin
   key_compare = key[i] 
   if(strcmp(this_key,key_compare,/FOLD_CASE) eq 1 ) then begin
      ifound = 1
      apply_pixel_sat = fix(value[i])
   endif
   i = i + 1
endwhile
if(ifound eq 0) then print,'Missing Keyword in preference file',this_key 
;_______________________________________________________________________
ifound = 0 
this_key = 'APPLY_REF_PIX'
i = 0 
while(ifound eq 0 and i lt ik) do begin
   key_compare = key[i] 
   if(strcmp(this_key,key_compare,/FOLD_CASE) eq 1 ) then begin
      ifound = 1
      refpixel_option = fix(value[i])
   endif
   i = i + 1
endwhile
if(ifound eq 0) then print,'Missing Keyword in preference file',this_key 
;_______________________________________________________________________
ifound = 0 
this_key = 'REF_PIX_DELTA'
i = 0 
while(ifound eq 0 and i lt ik) do begin
   key_compare = key[i] 
   if(strcmp(this_key,key_compare,/FOLD_CASE) eq 1 ) then begin
      ifound = 1
      delta_row_even_odd = fix(value[i])
   endif
   i = i + 1
endwhile
if(ifound eq 0) then print,'Missing Keyword in preference file',this_key 
;_______________________________________________________________________
ifound = 0 
this_key = 'FIT_A'
i = 0 
while(ifound eq 0 and i lt ik) do begin
   key_compare = key[i] 
   if(strcmp(this_key,key_compare,/FOLD_CASE) eq 1 ) then begin
      ifound = 1
      start_fit = fix(value[i])
   endif
   i = i + 1
endwhile
if(ifound eq 0) then print,'Missing Keyword in preference file',this_key 
;_______________________________________________________________________
ifound = 0 
this_key = 'FIT_N'
i = 0 
while(ifound eq 0 and i lt ik) do begin
   key_compare = key[i] 
   if(strcmp(this_key,key_compare,/FOLD_CASE) eq 1 ) then begin
      ifound = 1
      end_fit = fix(value[i])
   endif
   i = i + 1
endwhile
if(ifound eq 0) then print,'Missing Keyword in preference file',this_key 
;_______________________________________________________________________
ifound = 0 
this_key = 'HIGH_SAT'
i = 0 
while(ifound eq 0 and i lt ik) do begin
   key_compare = key[i] 
   if(strcmp(this_key,key_compare,/FOLD_CASE) eq 1 ) then begin
      ifound = 1
      highDN = float(value[i])
   endif
   i = i + 1
endwhile

if(ifound eq 0) then print,'Missing Keyword in preference file',this_key 
;_______________________________________________________________________
ifound = 0 
this_key = 'READ_NOISE'
i = 0 
while(ifound eq 0 and i lt ik) do begin
   key_compare = key[i] 
   if(strcmp(this_key,key_compare,/FOLD_CASE) eq 1 ) then begin
      ifound = 1
      readnoise = float(value[i])
   endif
   i = i + 1
endwhile
if(ifound eq 0) then print,'Missing Keyword in preference file',this_key 
;_______________________________________________________________________
ifound = 0 
this_key = 'GAIN'
i = 0 
while(ifound eq 0 and i lt ik) do begin
   key_compare = key[i] 
   if(strcmp(this_key,key_compare,/FOLD_CASE) eq 1 ) then begin
      ifound = 1
      gain = float(value[i])
   endif
   i = i + 1
endwhile
if(ifound eq 0) then print,'Missing Keyword in preference file',this_key 
;_______________________________________________________________________
ifound = 0 
this_key = 'METHOD_UNCER'
i = 0 
while(ifound eq 0 and i lt ik) do begin
   key_compare = key[i] 
   if(strcmp(this_key,key_compare,/FOLD_CASE) eq 1 ) then begin
      ifound = 1
      UncertaintyMethod = fix(value[i])
   endif
   i = i + 1
endwhile
if(ifound eq 0) then print,'Missing Keyword in preference file',this_key 
;_______________________________________________________________________
ifound = 0 
this_key = 'QL_USE_BADPIXEL'
i = 0 
while(ifound eq 0 and i lt ik) do begin
   key_compare = key[i] 
   if(strcmp(this_key,key_compare,/FOLD_CASE) eq 1 ) then begin
      ifound = 1
      display_apply_bad = fix(value[i])
   endif
   i = i + 1
endwhile
if(ifound eq 0) then print,'Missing Keyword in preference file',this_key 


;_______________________________________________________________________
ifound = 0 
this_key = 'APPLY_BAD_PIX'
i = 0 
while(ifound eq 0 and i lt ik) do begin
   key_compare = key[i] 
   if(strcmp(this_key,key_compare,/FOLD_CASE) eq 1 ) then begin
      ifound = 1
      apply_bad = fix(value[i])
   endif
   i = i + 1
endwhile
if(ifound eq 0) then print,'Missing Keyword in preference file',this_key 

;_______________________________________________________________________

ifound = 0 
this_key = 'APPLY_LASTFRAME'
i = 0 
while(ifound eq 0 and i lt ik) do begin
   key_compare = key[i] 
   if(strcmp(this_key,key_compare,/FOLD_CASE) eq 1 ) then begin
      ifound = 1
      apply_lastframe = fix(value[i])
   endif
   i = i + 1
endwhile
if(ifound eq 0) then print,'Missing Keyword in preference file',this_key 

;_______________________________________________________________________
ifound = 0 
this_key = 'APPLY_DARK'
i = 0 
while(ifound eq 0 and i lt ik) do begin
   key_compare = key[i] 
   if(strcmp(this_key,key_compare,/FOLD_CASE) eq 1 ) then begin
      ifound = 1
      apply_dark = fix(value[i])
   endif
   i = i + 1
endwhile
if(ifound eq 0) then print,'Missing Keyword in preference file',this_key 


;_______________________________________________________________________
ifound = 0 
this_key = 'APPLY_LIN'
i = 0 
while(ifound eq 0 and i lt ik) do begin
   key_compare = key[i] 
   if(strcmp(this_key,key_compare,/FOLD_CASE) eq 1 ) then begin
      ifound = 1
      apply_lin = fix(value[i])
   endif
   i = i + 1
endwhile
if(ifound eq 0) then print,'Missing Keyword in preference file',this_key 

;_______________________________________________________________________
ifound = 0 
this_key = 'QL_FIRST_INT'
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
this_key = 'QL_FIRST_FRAME'
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
this_key = 'QL_NFRAME_READ'
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
ifound = 0 
this_key = 'QL_PIXELS_TRACK'
i = 0 
while(ifound eq 0 and i lt ik) do begin
   key_compare = key[i] 
   if(strcmp(this_key,key_compare,/FOLD_CASE) eq 1 ) then begin
      ifound = 1
      tracking_file = value[i]
   endif
   i = i + 1
endwhile
if(ifound eq 0) then print,'Missing Keyword in preference file',this_key 


end
