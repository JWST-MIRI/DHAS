pro convert_telemetry_string,instring,value,status
status = 0
value = -99
instring = strcompress(instring,/remove_all)
instring = strupcase(instring)
if(instring eq 'ON') then value = 1
if(instring eq 'OFF') then value = 0
if(instring eq 'FLUSH') then value = 0
if(instring eq 'TEST') then value = 1
if(instring eq 'CLOCKING') then value = 2
if(instring eq 'SCIENCE') then value = 0
if(instring eq 'HTROFF') then value = 0
 if(instring eq 'STABLE') then value = 1
if(instring eq 'COOLDN') then value = 2
if(instring eq 'ANNEAL') then value = 4
if(instring eq 'DISABLE') then value = 0
if(instring eq 'ENABLE') then value = 1
if(instring eq 'FAST') then value = 0
if(instring eq 'SLOW') then value = 1
if(instring eq 'INTERNAL') then value = 0
if(instring eq 'Ext-A') then value = 1
if(instring eq 'Ext-B') then value = 2
if(instring eq 'A') then value = 1
if(instring eq 'B') then value = 0
if(instring eq 'UNK') then value = 0
if(instring eq 'HOLE') then value = 1
if(instring eq 'ET1B') then value = 2
if(instring eq 'LWP') then value = 3
if(instring eq 'ET2A') then value = 4
if(instring eq 'SWP') then value = 5
if(instring eq 'ET2B') then value = 6
if(instring eq 'BLNK') then value = 7
if(instring eq 'ET1A') then value = 8

if(instring eq 'NONE') then value = 0
if(instring eq 'POL1') then value = 1
if(instring eq 'POL2') then value = 2
if(instring eq 'POL3') then value = 3

if(instring eq 'PNT') then value = 1
if(instring eq 'EXT') then value = 2
if(instring eq 'POL') then value = 3


if(value eq -99) then status = 1



end
;***********************************************************************
pro reading_telemetry_data,info,ext,status
status = 0
if(XRegistered ('mtql') and ext eq 1 ) then begin
    widget_control,info.telemetryLook,/destroy
endif

if(XRegistered ('mtql_raw') and ext eq 2 ) then begin
    widget_control,info.telemetryLook_raw,/destroy
endif
if(not info.control.set_teldata) then begin ; telemetry not given on command line
    fname = dialog_pickfile(/read, filter='*.fits',$
                                get_path=realpath,Path=info.control.dirtel)

    if(fname eq '')then begin
        print,' No file selected, can not read in data'
	status = 1
        return
    endif

    len =  strlen(realpath)
    realpath = strmid(realpath,0,len-1); just to be consistent
    info.control.dirtel = realpath
    Widget_Control,info.QuickLook,Set_UValue=info
    if (fname NE '') then begin
        filein = fname
    endif
    
    file_only = filein
endif else begin


    dirin = info.control.dirtel
    dirin = strcompress(dirin,/remove_all)
    len = strlen(dirin) 
    test = strmid(dirin,len-1,len-1)
    if(test ne '/') then dirin = dirin+'/'
    info.control.dirtel = dirin



    filein = strcompress(info.control.dirtel + info.control.filename_tel,/remove_all) ; use command line values
    file_only = filein

; set set_teldata to false incase want to open one after displaying
; this one - interactively

    info.control.set_teldata = 0 
endelse
file_part = strsplit(file_only,'/',/extract)
num_part = n_elements(file_part)
file_only = file_part
if(num_part ge 1)then file_only = file_part[num_part-1]

split_str = strsplit(file_only,'_',/extract)
if(ext eq 1) then info.control.filename_tel  = filein
if(ext eq 2) then info.control.filename_telraw  = filein
file_exist = file_test(filein,/read,/regular)


if(file_exist ne 1) then begin
    result = dialog_message(" Could not Open telemetry file: "+ filein ,/error )
    return
endif


split_str = strsplit(file_only,'_',/extract)
num_type = n_elements(split_str)
found = 0
i = 0
while (found eq 0 and i lt num_type) do begin
    for j = 1,6 do begin 
        test = split_str[i]
        test = strupcase(strtrim(test,2))
        if(test eq info.tel_types[j]) then found = i

    endfor
    i = i + 1
endwhile


tel_type =split_str[found]
tel_type = strupcase(strtrim(tel_type,2))

type = 0

if(tel_type EQ info.tel_types[1]) then type = 1
if(tel_type EQ info.tel_types[2]) then type = 2
if(tel_type EQ info.tel_types[3]) then type = 3
if(tel_type EQ info.tel_types[4]) then type = 4
if(tel_type EQ info.tel_types[5]) then type = 5
if(tel_type EQ info.tel_types[6]) then type = 6



if(ext eq 1) then info.telemetry.type[*]  = type
if(ext eq 2) then info.telemetry_raw.type[*] = type

telemetry_file = strarr(6,2)
telemetry_file_found = strarr(6)
if(type ne 0) then begin 
    for ii = 0,5 do begin
        telemetry_file[ii,*] = '/' + file_part[0]
        for i = 1,num_part-2 do begin
            telemetry_file[ii,0] = telemetry_file[ii,0] + '/' +file_part[i]
            telemetry_file[ii,1] = telemetry_file[ii,1] + '/' +file_part[i]
        endfor
        telemetry_file[ii,0] = telemetry_file[ii,0] + '/' + split_str[0]
        telemetry_file[ii,1] = telemetry_file[ii,1] + '/' + split_str[0]
        for i = 1,num_type -1 do begin
            if(found ne i) then begin
                telemetry_file[ii,0] = telemetry_file[ii,0] + '_' + split_str[i,*]
                telemetry_file[ii,1] = telemetry_file[ii,1] + '_' + split_str[i,*]
            endif
            if(found eq i) then begin
                telemetry_file[ii,0] = telemetry_file[ii,0] + '_' + info.tel_types[ii+1]
                lowcase = strlowcase(info.tel_types[ii+1])
                telemetry_file[ii,1] = telemetry_file[ii,1] + '_' + string(lowcase) 
            endif
        endfor

    endfor
endif else begin
    telemetry_file[0,*] = filein
endelse


;_______________________________________________________________________
reading_telemetry_files,info,telemetry_file,telemetry_file_found,status,ext

if(ext eq 1) then info.telemetry.files = telemetry_file_found
if(ext eq 2) then info.telemetry_raw.files = telemetry_file_found


end

;***********************************************************************
pro reading_telemetry_files,info,filein,filein_found,status,ext
max_nvalues = 0
max_ntimes  = 0

files_exist = intarr(6)
for i = 0,5 do begin ; 6 types of files
    file_exist = file_test(filein[i,0],/regular,/read)
    files_exist[i] = 0
    filein_found[i] = filein[i,0]
    if(file_exist eq 0) then begin
        file_exist = file_test(filein[i,1],/regular,/read)
        if(file_exist eq 1) then filein_found[i] = filein[i,1]
    endif

    if(file_exist eq 1) then begin
        files_exist[i] = 1
        fits_open,filein_found[i],fcb
        numex = fcb.nextend
        fits_close,filein_found[i]
        if(ext eq 2 and numex eq 1) then begin
            result = dialog_message(" This files does not have a raw extension table: "+ filein_found[i] ,/error )
            files_exist[i] = 0
        endif
        if( numex eq 0) then begin
            result = dialog_message(" This files does not have a telemetry table: "+ filein_found ,/error )
            files_exist[i] = 0
        endif
;_______________________________________________________________________
; read in telemetry
;_______________________________________________________________________
;
        if(ext eq 1 )then tel = mrdfits(filein_found[i],1,header_tel)
        if(ext eq 2 )then tel = mrdfits(filein_found[i],2,header_tel)
        
        nvalues= fxpar(header_tel,'TFIELDS',count=count)
        ntimes= fxpar(header_tel,'NAXIS2')
        if(nvalues gt max_nvalues) then max_nvalues = nvalues
        if(nTIMES gt max_ntimes) then max_ntimes = ntimes
        fits_close,fcb
        header_tel = 0
    endif
endfor
print,' Max nvalues, ntimes',max_nvalues,max_ntimes
fcb = 0


x_values = dblarr(max_ntimes,6)
teldata = dblarr(max_nvalues, max_ntimes,6)
teldata_org = strarr(max_nvalues, max_ntimes,6)
tname = strarr(max_nvalues,6)
telstring_final = strarr(max_nvalues,6,info.max_new_telemetry)
telstring_num_final = intarr(max_nvalues,6,info.max_new_telemetry)
teltype = intarr(max_nvalues,6)       ; 0 = not a string, ne 0 then string (# = # of string types)
for ij = 0,5 do begin ; 6 types of files

    if(files_exist[ij] eq 1) then begin 
        if(ext eq 1 )then tel = mrdfits(filein_found[ij],1,header_tel)
        if(ext eq 2 )then tel = mrdfits(filein_found[ij],2,header_tel)
        nvalues= fxpar(header_tel,'TFIELDS',count=count)
        ntimes= fxpar(header_tel,'NAXIS2')

        tname_all = strarr(nvalues)

        tform = fxpar(header_tel,'TFORM1')
        tform = strupcase(strtrim(tform,2))
        len = strlen(tform)
        test = strmid(tform,len-1)
        if(test eq 'A' ) then begin
            result = dialog_message(" This file was not created with the JPL software pacakage:FFC "+ filein_found[ij] ,/error )
            status = 4
            return
        endif


        x_vals = dblarr(ntimes) 
        timedata = dblarr(ntimes)
        tname_all = tag_names(tel)
        timedata[*] = tel.(0)

;_______________________________________________________________________
; eliminate PKT time and date
        telplot = intarr(nvalues)
        for i = 0, nvalues -1 do begin
            telplot[i] = 0
            tel_name  = strupcase(tname_all(i))
            tel_name = strcompress(tel_name,/remove_all)
            len = strlen(tel_name)
            if(len gt 8) then begin
                test = strmid(tel_name,len-8,len)
                if(test eq 'PKT_DATE' or test eq 'PKT_TIME' ) then telplot[i] = 1
            endif

            if(len gt 12) then begin
                test = strmid(tel_name,len-12,len)
                if(test eq 'EXPSTARTDATE' or test eq 'EXPSTARTTIME' ) then telplot[i] = 1
            endif

            if(len gt 11) then begin
                test = strmid(tel_name,len-11,len)
                if(test eq 'EXPSTOPDATE' or test eq 'EXPSTOPTIME' ) then telplot[i] = 1
            endif

            if(len gt 14) then begin
                test = strmid(tel_name,len-14,len)
                if(test eq 'FRAMESTARTDATE' or test eq 'FRAMESTARTTIME' ) then telplot[i] = 1
            endif

        endfor
        index = where(telplot[*] eq 0,num)
        nvalues_org = nvalues
        nvalues = num

        tname[0:num-1,ij] = tname_all[index]
        if(num lt max_nvalues)then  tname[num:max_nvalues-1,ij] = '  ' 
        tname_num = num
;_____________________________________________________________________


        time_string = strcompress(tname[0,ij],/remove_all)
        if(time_string eq 'TIME' or time_string eq 'GSETIME') then begin
            x_vals[*] = timedata[*]

        endif
        maxlen = max(strlen(tname[*,ij]))

        if(nvalues lt 4) then begin ; redefine of do not have at least 4 values to plot
                               ; at the same time
            info.telemetry.n_poss_lines = nvalues 
            info.telemetry_raw.n_poss_lines = nvalues 
        endif


        telstring =strarr(nvalues,ntimes)
        telstring_num = intarr(nvalues,ntimes)
 
        maxnumfound = 0 ; holds maximum number of string converted unique values

        ii = 0

        for i = 0, nvalues_org -1 do begin
            if(telplot[i] eq 0) then begin

                s = size(tel.(i))
                stype = s[2]
                if(s[0] eq 0)then  stype = s[1] ; catch for only 1 element in table (scalar) 
;_______________________________________________________________________
; stype = 7 , value is a string. Convert strings to integers
                teldata_org[ii,0:ntimes-1,ij] = strcompress(string(tel.(i)),/remove_all)
                if( stype  eq 7) then begin ; then value is a string
                    string_temp = strarr(ntimes)
                    value_temp = intarr(ntimes)
                    not_converted = 0
                    temp = tel.(i)

                    not_converted = 0
                    for j = 0,ntimes-1 do begin ; loop over all the ntimes values
                        convert_telemetry_string,temp[j],value,local_status
                        if(local_status eq 0) then begin
                            string_temp[j] = temp[j]
                            value_temp[j] = value
                            teldata[ii,j,ij] = value 
                        endif
                        if(local_status eq 1) then begin
                            string_temp[j] = 'unknown'
                            value_temp[j] = -99
                            not_converted = 1
                            teldata[ii,j,ij] = -99
                        endif
                    endfor
;_______________________________________________________________________
; all strings had converted values

                    if(not_converted eq 0) then begin
                        numfound = 0
                        p = 0
                        while (p le ntimes -1 and numfound eq 0) do  begin 
                            test = strcompress(string_temp[p],/remove_all)
                            result = strcmp(test,'unknown')
                            if(result ne 1) then begin
                                telstring[ii,0] = string_temp[p]
                                numfound = numfound + 1
                            endif
                            p = p + 1
                        endwhile

                        for j = 1,ntimes - 1 do begin ;loop over other strings
                            ; first see if string is "unknown"
                            test = strcompress(string_temp[j],/remove_all)
                            result = strcmp(test,'unknown')
                            if(result ne 1) then begin
                                found = 0
                                for p = 0,numfound do begin 
                                    result = strcmp(string_temp[j],telstring[ii,p])                                    
                                    if(result eq 1) then begin
                                        found = 1
                                    endif
                                endfor
                                if(found eq 0) then begin
                                    telstring[ii,numfound] = string_temp[j]
                                    telstring_num[ii,numfound] = value_temp[j]
                                    numfound = numfound + 1
                                endif
                            endif
                        endfor

                        teltype[ii,ij] = numfound
                    endif
;_______________________________________________________________________
; found some strings that where not converted

                    if(not_converted eq 1) then begin ; contains unknown strings - can not plot
                        telstring[ii,0] = 'unknown'
                        teltype[ii,ij] = -99
                        numfound = 1
                    endif
                    
;_______________________________________________________________________

                    if(numfound gt maxnumfound) then maxnumfound = numfound
                    
;_______________________________________________________________________
; not a string just continue

                endif else begin
                    teldata[ii,0:ntimes-1,ij] = tel.(i)
                    
                endelse
;-----------------------------------------------------------------------
                ii = ii + 1
            endif               ; end loop over telplot eq 1
            
        endfor


        x_values[0:ntimes-1,ij] = x_vals


        if(maxnumfound gt 0 )then begin 
            telstring_final[0:nvalues-1,ij,0:maxnumfound-1] = telstring[*,0:maxnumfound-1]
            telstring_num_final[0:nvalues-1,ij,0:maxnumfound-1] = telstring_num[*,0:maxnumfound-1]
        endif else begin
            telstring_final[*,ij,*] = 'NULL'
            telstring_num_final[*,ij,*] = 0
        endelse



        if(ext eq 1) then begin 
            info.telemetry.nvalues[ij] = nvalues
            info.telemetry.ntimes[ij] = ntimes
            info.telemetry.nstring[ij] = maxnumfound
            info.telemetry.maxlen[ij] = maxlen
            info.telemetry.tname_num[ij] = tname_num
            
        endif else if(ext eq 2) then begin
            info.telemetry_raw.nvalues[ij] = nvalues
            info.telemetry_raw.ntimes[ij] = ntimes
            info.telemetry_raw.maxlen[ij] = maxlen
            info.telemetry_raw.nstring[ij] = maxnumfound
        endif
        header_tel = 0
    endif                       ; end file exist
endfor ; end reading different files
;_______________________________________________________________________
if(ext eq 1) then begin 

    info.telemetry.file_exist = files_exist
    if ptr_valid (info.telemetry.pteltype) then ptr_free,info.telemetry.pteltype
    info.telemetry.pteltype = ptr_new(teltype)

    if ptr_valid (info.telemetry.ptelstring) then ptr_free,info.telemetry.ptelstring
    info.telemetry.ptelstring = ptr_new(telstring_final)

    if ptr_valid (info.telemetry.ptelstring_num) then ptr_free,info.telemetry.ptelstring_num
    info.telemetry.ptelstring_num = ptr_new(telstring_num_final)

    if ptr_valid (info.telemetry.pkname) then ptr_free,info.telemetry.pkname
    info.telemetry.pkname = ptr_new(tname)

    if ptr_valid (info.telemetry.pkdata) then ptr_free,info.telemetry.pkdata
    info.telemetry.pkdata = ptr_new(teldata)

    if ptr_valid (info.telemetry.pkdata_org) then ptr_free,info.telemetry.pkdata_org
    info.telemetry.pkdata_org = ptr_new(teldata_org)
    
    if ptr_valid (info.telemetry.px_vals) then ptr_free,info.telemetry.px_vals
    info.telemetry.px_vals = ptr_new(x_values)


endif else if(ext eq 2) then begin

    info.telemetry_raw.file_exist = files_exist

    if ptr_valid (info.telemetry_raw.pteltype) then ptr_free,info.telemetry_raw.pteltype
    info.telemetry_raw.pteltype = ptr_new(teltype)

    if ptr_valid (info.telemetry_raw.ptelstring) then ptr_free,info.telemetry_raw.ptelstring
    info.telemetry_raw.ptelstring = ptr_new(telstring_final)

    if ptr_valid (info.telemetry_raw.ptelstring_num) then ptr_free,info.telemetry_raw.ptelstring_num
    info.telemetry_raw.ptelstring_num = ptr_new(telstring_num_final)

    if ptr_valid (info.telemetry_raw.pkname) then ptr_free,info.telemetry_raw.pkname
    info.telemetry_raw.pkname = ptr_new(tname)

    if ptr_valid (info.telemetry_raw.pkdata) then ptr_free,info.telemetry_raw.pkdata
    info.telemetry_raw.pkdata = ptr_new(teldata)

    if ptr_valid (info.telemetry_raw.pkdata_org) then ptr_free,info.telemetry_raw.pkdata_org
    info.telemetry_raw.pkdata_org = ptr_new(teldata_org)
    
    if ptr_valid (info.telemetry_raw.px_vals) then ptr_free,info.telemetry_raw.px_vals
    info.telemetry_raw.px_vals = ptr_new(x_values)


endif


Widget_Control,info.QuickLook,Set_UValue=info
tname = 0
timedata = 0
teldata = 0
x_vals = 0
x_values = 0
tel = 0
telstring = 0
telstring_final = 0
telstring_num_final = 0
teltype = 0
telplot = 0
tname_all = 0
teldata_org = 0

end


