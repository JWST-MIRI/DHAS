; This program takes either a command line user input name or it
; picks a name using the IDL dialog_pickfile routine.
; setup_names takes a raw science file as the input and pulls out the
; base name and figures out the slope name and other intermediate
; files that might exist. 
;_______________________________________________________________________
pro setup_names,info,status,error_message
status = 0
error_message = ' ' 
;_______________________________________________________________________
; routine which sets up the names of the raw images, slope images
; If the user provided the file name - then info.control.set_scidata=1
; This will be the case if called after  mql_run_miri_sloper
;_______________________________________________________________________
status = 0

; The user did not provided the file name file on the command line- so
; pop up a box and let the user slect it

; When the user selects the file from the pop up box - result includes
;                                                      directory

if(info.control.set_scidata eq 0) then begin
    image_file = dialog_pickfile(/read,$
                                get_path=realpath,Path=info.control.dir,$
                                filter = '*.fits',/fix_filter)
 

    len = strlen(realpath)
    realpath = strmid(realpath,0,len-1); just to be consistent 
    info.control.dir = realpath
    
    if(image_file eq '')then begin
        print,' No file selected, can not read in data'
	status = 2
        return
    endif
    if (image_file NE '') then begin
        filename = image_file
    endif
endif

;_______________________________________________________________________
; the User did provide a filename on the command line - 
if(info.control.set_scidata eq 1) then begin
    filename = strcompress(info.control.filename_raw,/remove_all)
endif

;_______________________________________________________________________

slash_str = strsplit(filename,'/',/extract)
n_slash = n_elements(slash_str)
if (n_slash GT 1) then begin
    out_filebase = slash_str[n_slash-1]
endif else begin
    out_filebase = filename
endelse
info.control.filename = out_filebase ; only the filename not directory
len= strlen(out_filebase)
out_file = strmid(out_filebase,0,len-5)
info.control.filebase = out_file
;_______________________________________________________________________

len = strlen(filename)
fitname = strmid(filename,len-5,5)
fits = strpos(filename,fitname)

info.control.filename_raw = filename

dirlocation = strpos(filename,'/',/reverse_search)


info.control.filename_slope = info.control.filebase + '_LVL2'+fitname
info.control.filename_refcorrection = info.control.filebase + '_RefCorrection'+fitname
info.control.filename_IDS = info.control.filebase + '_IDS'+fitname
info.control.filename_LC = info.control.filebase + '_LinCorrected'+fitname
info.control.filename_MDC = info.control.filebase + '_DarkCorrected'+fitname
info.control.filename_reset = info.control.filebase + '_ResetCorrected'+fitname
info.control.filename_rscd = info.control.filebase + '_RSCDCorrected'+fitname
info.control.filename_lastframe = info.control.filebase + '_LastFrameCorrected'+fitname
info.control.filename_log = info.control.filebase + '.log'
info.control.filename_slope_refimage = info.control.filebase + '_LVL2_REF'+fitname
info.control.filename_cal = info.control.filebase + '_LVL3'+fitname

;_______________________________________________________________________
; If the user provided the filename - then add the directory name to
; filename
;_______________________________________________________________________


if(info.control.set_scidata eq 1) then begin

    dirin = info.control.dir
    dirin = strcompress(dirin,/remove_all)
    len = strlen(dirin) 
    test = strmid(dirin,len-1,len-1)
    if(test ne '/') then dirin = dirin+'/'
    info.control.dir = dirin
    info.control.filename = info.control.filename_raw
    info.control.filename_raw = strcompress(info.control.dir+info.control.filename_raw,/remove_all)
; set set_scidata to false incase want to open one after displaying
; this one - interactively
    info.control.set_scidata = 0     
endif


;;;
 ;;;_______________________________________________________________________

info.control.filename_slope = strcompress(info.control.dirout+'/'+info.control.filename_slope,/remove_all)

info.control.filename_refcorrection = $
  strcompress(info.control.dirout+'/'+info.control.filename_refcorrection,/remove_all)


info.control.filename_cal = strcompress(info.control.dirout+'/'+info.control.filename_cal,/remove_all)

info.control.filename_IDS = strcompress(info.control.dirout+'/'+info.control.filename_IDS,/remove_all)
info.control.filename_LC = strcompress(info.control.dirout+'/'+info.control.filename_LC,/remove_all)
info.control.filename_MDC = strcompress(info.control.dirout+'/'+info.control.filename_MDC,/remove_all)
info.control.filename_reset = strcompress(info.control.dirout+'/'+info.control.filename_reset,/remove_all)
info.control.filename_rscd = strcompress(info.control.dirout+'/'+info.control.filename_rscd,/remove_all)
info.control.filename_lastframe = strcompress(info.control.dirout+'/'+info.control.filename_lastframe,/remove_all)
info.control.filename_log = strcompress(info.control.dirout+'/'+info.control.filename_log,/remove_all)
info.control.filename_slope_refimage = $
  strcompress(info.control.dirout+'/'+info.control.filename_slope_refimage,/remove_all)



;_______________________________________________________________________
; error checking - after defining names (log file for error reporting)
;_______________________________________________________________________
info.data.raw_exist =1

read_data_type,info.control.filename_raw,type
read_coadd_type,info.control.filename_raw,coadd_type



if(type ne 0) then begin
    error_message = ' You did not open a  Science Frame data File, try again'
    status = 1
    return
endif


info.data.raw_exist = 1

id_file_exist = 0
ref_corrected = 0
lc_file_exist = 0
mdc_file_exist = 0
reset_file_exist = 0
rscd_file_exist = 0
lastframe_file_exist = 0
yes_string = 'yes'


if(coadd_type eq 0) then begin 

    file_exist1 = file_test(info.control.filename_slope,/regular,/read)

    if(file_exist1 eq 1) then begin 
        fits_open,info.control.filename_slope,fcb
        fits_read,fcb,cube_raw,header_raw,/header_only,exten_no = 0
        fits_close,fcb
        rc_str = fxpar(header_raw,'WREFPIXC',count = count)
        rc_str = strcompress(strlowcase(rc_str),/remove_all)
        result = strcmp(rc_str,yes_string)
        if(result eq 1) then ref_corrected = 1
        
        id_str = fxpar(header_raw,'WID',count = count)
        id_str = strcompress(strlowcase(id_str),/remove_all)
        result = strcmp(id_str,yes_string)
        if(result eq 1) then id_file_exist = 1 

        lc_str = fxpar(header_raw,'WLINC',count = count)
        lc_str = strcompress(strlowcase(lc_str),/remove_all)
        result = strcmp(lc_str,yes_string)
        if(result eq 1) then lc_file_exist = 1 

        mdc_str = fxpar(header_raw,'WMDC',count = count)
        mdc_str = strcompress(strlowcase(mdc_str),/remove_all)
        result = strcmp(mdc_str,yes_string)
        if(result eq 1) then mdc_file_exist = 1 

        reset_str = fxpar(header_raw,'WRESET',count = count)
        reset_str = strcompress(strlowcase(reset_str),/remove_all)
        result = strcmp(reset_str,yes_string)
        if(result eq 1) then reset_file_exist = 1 


        rscd_str = fxpar(header_raw,'WRSCD',count = count)
        rscd_str = strcompress(strlowcase(rscd_str),/remove_all)
        result = strcmp(rscd_str,yes_string)
        if(result eq 1) then rscd_file_exist = 1


        lastframe_str = fxpar(header_raw,'WLASTF',count = count)
        lastframe_str = strcompress(strlowcase(lastframe_str),/remove_all)
        result = strcmp(lastframe_str,yes_string)
        if(result eq 1) then lastframe_file_exist = 1 

     endif
 endif else begin
    print,'This type of data is not supported by the DHAS. It is single frame data'
endelse

info.control.file_refcorrection_exist = 0
if(ref_corrected eq 1) then   info.control.file_refcorrection_exist = file_test(info.control.filename_refcorrection,/regular,/read)

info.control.file_ids_exist = 0
if(id_file_exist eq 1) then info.control.file_ids_exist = file_test(info.control.filename_IDS,/regular,/read)


info.control.file_lc_exist = 0
if(lc_file_exist eq 1) then info.control.file_lc_exist = file_test(info.control.filename_LC,/regular,/read)

info.control.file_mdc_exist = 0
if(mdc_file_exist eq 1) then info.control.file_mdc_exist = file_test(info.control.filename_MDC,/regular,/read)

info.control.file_reset_exist = 0
if(reset_file_exist eq 1) then info.control.file_reset_exist = file_test(info.control.filename_reset,/regular,/read)

info.control.file_rscd_exist = 0
if(rscd_file_exist eq 1) then info.control.file_rscd_exist = file_test(info.control.filename_rscd,/regular,/read)

info.control.file_lastframe_exist = 0
if(lastframe_file_exist eq 1) then info.control.file_lastframe_exist = file_test(info.control.filename_lastframe,/regular,/read)


cube_raw = 0
header_raw = 0
;_______________________________________________________________________  
print,' Science frame input file name   ',info.control.filename_raw
if(info.control.file_refcorrection_exist eq 1) then $
  print,' Reference Correction file       ',info.control.filename_refcorrection
print,' Slope input file                ',info.control.filename_slope
print,' Calibrated file                 ',info.control.filename_cal
if(info.control.file_ids_exist) then $
print,' Frame ID file                   ',info.control.filename_IDS

if(info.control.file_lc_exist) then $
print,' Linearity Corrected File        ',info.control.filename_LC

if(info.control.file_mdc_exist) then $
print,' Mean Dark Corrected File        ',info.control.filename_MDC

if(info.control.file_reset_exist) then $
print,' Reset Corrected File        ',info.control.filename_reset

if(info.control.file_rscd_exist) then $
print,' RSCD Corrected File        ',info.control.filename_rscd

if(info.control.file_lastframe_exist) then $
print,' LastFrame Corrected File        ',info.control.filename_lastframe


print,' File base                       ',info.control.filebase



end
;_______________________________________________________________________  

; This routine reads the slope name using the dialog_pick routine and
; forms the names of the other files;

pro setup_names_from_slope,info,status,error_message
status = 0
error_message = ' ' 
;_______________________________________________________________________
; routine which sets up the names of the raw images, slope images
; If the user provided the file name - then info.control.set_scidata=1
;_______________________________________________________________________
status = 0

; The user did not provided the file name file on the command line- so
; pop up a box and let the user slect it

; When the user selects the file from the pop up box - result includes
;                                                      directory


if(info.control.set_scidata eq 0) then begin
    image_file = dialog_pickfile(/read,$
                                get_path=realpath,Path=info.control.dirout,$
                                filter = '*.fits')
    len = strlen(realpath)
    realpath = strmid(realpath,0,len-1); just to be consistent 
    info.control.dirout = realpath
    
    if(image_file eq '')then begin
        print,' No file selected, can not read in data'
	status = 2
        return
    endif
    if (image_file NE '') then begin
        filename = image_file
    endif
endif
;_______________________________________________________________________
;; the User did provide a filename on the command line - 
;if(info.control.set_scidata eq 1) then begin
;    filename = strcompress(info.control.filename_raw,/remove_all)
;endif

;_______________________________________________________________________

;_______________________________________________________________________
; assuming slope file of form name_LVL2.fits

filename_slope = filename
len = strlen(filename_slope)
fitname = strmid(filename_slope,len-5,5)
fits = strpos(filename,fitname)
fitlvl2 = strmid(filename_slope,len-10,10)
lvl2 = strpos(filename,fitlvl2)

info.control.filename_slope = filename_slope
info.control.filename_raw = strmid(filename,0,lvl2) +fitname
info.control.filename_refcorrection = strmid(filename,0,lvl2) + '_RefCorrection'+fitname
info.control.filename_IDS = strmid(filename,0,lvl2) + '_IDS'+fitname
info.control.filename_LC =  strmid(filename,0,lvl2) + '_LinCorrected'+fitname
info.control.filename_MDC = strmid(filename,0,lvl2) + '_DarkCorrected'+fitname
info.control.filename_reset = strmid(filename,0,lvl2) + '_ResetCorrected'+fitname
info.control.filename_rscd = strmid(filename,0,lvl2) + '_RSCDCorrected'+fitname
info.control.filename_lastframe = strmid(filename,0,lvl2) + '_LastFrameCorrected'+fitname
info.control.filename_log = strmid(filename,0,lvl2) + '.log'
info.control.filename_slope_refimage = strmid(filename,0,lvl2) + '_LVL2_REF'+fitname
info.control.filename_cal = strmid(filename,0,lvl2) + '_LVL3'+fitname

print,info.control.filename_raw
dirlocation = strpos(filename_slope,'/',/reverse_search)

file_exist1 = file_test(info.control.filename_raw,/regular,/read)
if(file_exist1 ne 1) then begin
    len_new = lvl2 - dirlocation -1
    file1 = info.control.dir + '/' + strmid(filename,dirlocation+1,len_new)
    test_filename = file1  +fitname

    file_exist1 = file_test(test_filename,/regular,/read)

    if(file_exist1) then begin 
        info.control.filename_raw = test_filename

    endif
endif


;_______________________________________________________________________
; If the user provided the filename - then add the directory name to
; filename
;_______________________________________________________________________

if(info.control.set_scidata eq 1 and info.control.added_dir eq 0) then begin

    dirin = info.control.dir
    dirin = strcompress(dirin,/remove_all)
    len = strlen(dirin) 
    test = strmid(dirin,len-1,len-1)
    if(test ne '/') then dirin = dirin+'/'
    info.control.dir = dirin
    info.control.added_dir = 1
    
    info.control.filename = info.control.filename_raw
    info.control.filename_raw = strcompress(info.control.dir+info.control.filename_raw,/remove_all)
    info.control.filename_slope = strcompress(info.control.dir+info.control.filename_slope,/remove_all)
    info.control.filename_refcorrection = $
      strcompress(info.control.dir+info.control.filename_refcorrection,/remove_all)

    info.control.filename_cal = strcompress(info.control.dir+info.control.filename_cal,/remove_all)
    info.control.filename_IDS = strcompress(info.control.dir+info.control.filename_IDS,/remove_all)
    info.control.filename_LC = strcompress(info.control.dir+info.control.filename_LC,/remove_all)
    info.control.filename_MDC = strcompress(info.control.dir+info.control.filename_MDC,/remove_all)
    info.control.filename_reset = strcompress(info.control.dir+info.control.filename_reset,/remove_all)
    info.control.filename_rscd = strcompress(info.control.dir+info.control.filename_rscd,/remove_all)
    info.control.filename_lastframe = strcompress(info.control.dir+info.control.filename_lastframe,/remove_all)
    info.control.filename_log = strcompress(info.control.dir+info.control.filename_log,/remove_all)
    info.control.filename_slope_refimage = $
      strcompress(info.control.dir+info.control.filename_slope_refimage,/remove_all)


; set set_scidata to false incase want to open one after displaying
; this one - interactively

    info.control.set_scidata = 0     
endif


slash_str = strsplit(info.control.filename_slope,'/',/extract)
n_slash = n_elements(slash_str)
if (n_slash GT 1) then begin
    out_filebase = slash_str[n_slash-1]
endif else begin
    out_filebase = info.control.filename_slope
endelse

info.control.filename = out_filebase ; only the filename not directory
len= strlen(out_filebase)
out_file = strmid(out_filebase,0,len-10)
info.control.filebase = out_file


;_______________________________________________________________________

;_______________________________________________________________________
; error checking - after defining names (log file for error reporting)

;_______________________________________________________________________

; do some tests on if the file is correct:



read_data_type,info.control.filename_slope,type


if(type eq 1 or type eq 6) then begin
endif else begin
    flag = 1
    error_message = ' You did NOT open a SLOPE file, input file name again '
    print,error_message
    status = 1
    return
endelse


if(type eq 6) then begin
    print,' This is coadded data'

    info.data.coadd = 1
    filename_slope = filename
    len = strlen(filename_slope)
    fitname = strmid(filename_slope,len-5,5)
    fits = strpos(filename,fitname)
    fitFM = strmid(filename_slope,len-20,20)
    FM = strpos(filename,fitFM)

    info.control.filename_slope = filename_slope
    info.control.filename_raw = strmid(filename,0,FM) +fitname
    info.control.filename_refcorrection = strmid(filename,0,FM) + '_RefCorrection'+fitname
    info.control.filename_log = strmid(filename,0,FM) + '.log'
    info.control.filename_cal = strmid(filename,0,FM) + '_LVL3'+fitname
    len= strlen(out_filebase)
    out_file = strmid(out_filebase,0,len-15)
    info.control.filebase = out_file
endif


data = 0
header_slope = 0

;*********************************************************************** 

file_exist1 = file_test(info.control.filename_slope,/regular,/read)
if(file_exist1 ne 1 ) then begin
    error_message  = " Error in slope name"+ info.control.filename_slope
    status = 1
endif


file_exist1 = file_test(info.control.filename_raw,/regular,/read)
info.data.raw_exist = file_exist1
if(file_exist1 ne 1 ) then begin
    error_message  = " The raw science file does not exist. "
    status = 3
endif


ref_corrected = 0
yes_string = 'yes'
fits_open,info.control.filename_slope,fcb
fits_read,fcb,data,header_raw,/header_only,exten_no = 0
fits_close,fcb
rc_str = fxpar(header_raw,'WREFPIXC',count = count)
rc_str = strcompress(strlowcase(rc_str),/remove_all)
result = strcmp(rc_str,yes_string)
if(result eq 1) then ref_corrected = 1



info.control.file_refcorrection_exist = 0
if(ref_corrected eq 1) then $
info.control.file_refcorrection_exist = file_test(info.control.filename_refcorrection,/regular,/read)


id_file_exist = 0
id_str = fxpar(header_raw,'WID',count = count)
id_str = strcompress(strlowcase(id_str),/remove_all)
result = strcmp(id_str,yes_string)
if(result eq 1) then id_file_exist = 1 

info.control.file_ids_exist = 0
if(id_file_exist eq 1) then $
  info.control.file_ids_exist = file_test(info.control.filename_IDS,/regular,/read)


lc_file_exist = 0
lc_str = fxpar(header_raw,'WLINC',count = count)
lc_str = strcompress(strlowcase(lc_str),/remove_all)
result = strcmp(lc_str,yes_string)
if(result eq 1) then lc_file_exist = 1 

info.control.file_lc_exist = 0
if(lc_file_exist eq 1) then $
  info.control.file_lc_exist = file_test(info.control.filename_LC,/regular,/read)

md_file_exist = 0
md_str = fxpar(header_raw,'WMDC',count = count)
md_str = strcompress(strlowcase(md_str),/remove_all)
result = strcmp(md_str,yes_string)
if(result eq 1) then md_file_exist = 1 

info.control.file_mdc_exist = 0
if(md_file_exist eq 1) then $
  info.control.file_mdc_exist = file_test(info.control.filename_MDC,/regular,/read)


reset_file_exist = 0
reset_str = fxpar(header_raw,'WRESET',count = count)
reset_str = strcompress(strlowcase(reset_str),/remove_all)
result = strcmp(reset_str,yes_string)
if(result eq 1) then reset_file_exist = 1 

info.control.file_reset_exist = 0
if(reset_file_exist eq 1) then $
  info.control.file_reset_exist = file_test(info.control.filename_reset,/regular,/read)


rscd_file_exist = 0
rscd_str = fxpar(header_raw,'WRSCD',count = count)
rscd_str = strcompress(strlowcase(rscd_str),/remove_all)
result = strcmp(rscd_str,yes_string)
if(result eq 1) then rscd_file_exist = 1 

info.control.file_rscd_exist = 0
if(rscd_file_exist eq 1) then $
  info.control.file_rscd_exist = file_test(info.control.filename_rscd,/regular,/read)

lastframe_file_exist = 0
lastframe_str = fxpar(header_raw,'WLASTF',count = count)
lastframe_str = strcompress(strlowcase(lastframe_str),/remove_all)
result = strcmp(lastframe_str,yes_string)
if(result eq 1) then lastframe_file_exist = 1 

info.control.file_lastframe_exist = 0
if(lastframe_file_exist eq 1) then $
  info.control.file_lastframe_exist = file_test(info.control.filename_lastframe,/regular,/read)


data = 0
header_raw = 0

;_______________________________________________________________________  
print,' Science frame input file name   ',info.control.filename_raw
if(info.control.file_refcorrection_exist) then $
  print,' Reference Correction file       ',info.control.filename_refcorrection
print,' Slope input file                ',info.control.filename_slope
print,' Slope reference output          ', info.control.filename_slope_refimage
if(info.control.file_ids_exist) then $
  print,' Frame ID file                   ',info.control.filename_IDS 
if(info.control.file_lc_exist) then $
  print,' Linearity Corrected data        ',info.control.filename_LC 
if(info.control.file_mdc_exist) then $
  print,' Mean Dark Corrected data        ',info.control.filename_MDC 

if(info.control.file_reset_exist) then $
  print,' Reset Corrected data        ',info.control.filename_reset 

if(info.control.file_rscd_exist) then $
  print,' RSCD Corrected data        ',info.control.filename_rscd 

if(info.control.file_lastframe_exist) then $
  print,' LastFrame Corrected data        ',info.control.filename_lastframe 
print,' Calibrated file                 ',info.control.filename_cal
print,' File base                       ',info.control.filebase

end
;_______________________________________________________________________  







