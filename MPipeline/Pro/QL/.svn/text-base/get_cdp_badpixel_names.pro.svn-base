pro get_cdp_badpixel_names,control

filename = strarr(4)

; Imager
imager_file = control.miri_dir  + 'Preferences/' + control.cdp_im
filename[0] = imager_file
; LW
lw_file = control.miri_dir + 'Preferences/' + control.cdp_lw
filename[1] = lw_file
; SW
sw_file = control.miri_dir + 'Preferences/' +control.cdp_sw
filename[2] = sw_file
; JPL
jpl_file = control.miri_dir + 'Preferences/' + control.cdp_jpl
filename[3] = jpl_file

;_______________________________________________________________________
for j= 0,2 do begin
    badpixel_file = "NULL"
    status = 0
    get_lun,unit
    openr,unit,filename[j],error=err
    if(err NE 0) then begin
        print,'****************************************************************************'
        print,'Problem opening calibration file',filename[j]
        print,!ERROR_STATE.MSG
        print,'****************************************************************************'
        stop
    endif

    line = 'g'
    key = strarr(100)
    value = strarr(100)
    ik = 0 
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


    ifound = 0 
    this_key = 'BAD'
    i = 0 
    while(ifound eq 0 and i lt ik) do begin
        key_compare = key[i] 
        if(strcmp(this_key,key_compare,/FOLD_CASE) eq 1 ) then begin
            ifound = 1
            badpixel_file = value[i]
        endif
        i = i + 1
    endwhile
    if(ifound eq 0) then print,'DID not find Bad Pixel File'
    control.bad_file[j] = badpixel_file
endfor

end
