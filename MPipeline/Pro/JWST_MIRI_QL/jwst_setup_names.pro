;
; pick a name using the IDL dialog_pickfile routine.
; setup_names takes a raw science file as the input and pulls out the
; base name and figures out the slope name and other intermediate
; files that might exist. 
;_______________________________________________________________________
pro jwst_setup_names,info,status,error_message
status = 0
error_message = ' ' 
;_______________________________________________________________________
; routine which sets up the names of the raw images, slope images
; If the user provided the file name - then info.jwst_control.set_scidata=1
; This will be the case if called after  mql_run_miri_sloper
;_______________________________________________________________________
status = 0


image_file = dialog_pickfile(/read,$
                             get_path=realpath,Path=info.jwst_control.dir,$
                             filter = '*.fits',/fix_filter)
 

len = strlen(realpath)
realpath = strmid(realpath,0,len-1) ; just to be consistent 
info.jwst_control.dir = realpath
    
if(image_file eq '')then begin
   print,' No file selected, can not read in data'
   status = 2
   return
endif
if (image_file NE '') then begin
   filename = image_file
endif

;_______________________________________________________________________

slash_str = strsplit(filename,'/',/extract)
n_slash = n_elements(slash_str)
if (n_slash GT 1) then begin
    out_filebase = slash_str[n_slash-1]
endif else begin
    out_filebase = filename
endelse
info.jwst_control.filename = out_filebase ; only the filename not directory
len= strlen(out_filebase)
out_file = strmid(out_filebase,0,len-5)
info.jwst_control.filebase = out_file
;_______________________________________________________________________

len = strlen(filename)
fitname = strmid(filename,len-5,5)
fits = strpos(filename,fitname)

info.jwst_control.filename_raw = filename
dirlocation = strpos(filename,'/',/reverse_search)

info.jwst_control.filename_slope = info.jwst_control.filebase + '_rate'+fitname
info.jwst_control.filename_slope_int = info.jwst_control.filebase + '_rateints'+fitname
coadd_file = info.jwst_control.filebase + '_FASTSHORT_MEAN'+fitname
info.jwst_control.filename_refcorrection = info.jwst_control.filebase + '_RefCorrection'+fitname

info.jwst_control.filename_LC = info.jwst_control.filebase + '_LinCorrected'+fitname
info.jwst_control.filename_MDC = info.jwst_control.filebase + '_DarkCorrected'+fitname
info.jwst_control.filename_reset = info.jwst_control.filebase + '_ResetCorrected'+fitname
info.jwst_control.filename_rscd = info.jwst_control.filebase + '_RSCDCorrected'+fitname
info.jwst_control.filename_lastframe = info.jwst_control.filebase + '_LastFrameCorrected'+fitname

info.jwst_control.filename_slope_refimage = 'none'
info.jwst_control.filename_cal = info.jwst_control.filebase + '_cal'+fitname

;_______________________________________________________________________
; If the user provided the filename - then add the directory name to
; filename
;_______________________________________________________________________


info.jwst_control.filename_slope = strcompress(info.jwst_control.dirout+'/'+info.jwst_control.filename_slope,/remove_all)
info.jwst_control.filename_slope_int = strcompress(info.jwst_control.dirout+'/'+info.jwst_control.filename_slope_int,/remove_all)
coadd_file = strcompress(info.jwst_control.dirout+'/'+coadd_file,/remove_all)


info.jwst_control.filename_refcorrection = $
  strcompress(info.jwst_control.dirout+'/'+info.jwst_control.filename_refcorrection,/remove_all)

info.jwst_control.filename_cal = strcompress(info.jwst_control.dirout+'/'+info.jwst_control.filename_cal,/remove_all)
info.jwst_control.filename_LC = strcompress(info.jwst_control.dirout+'/'+info.jwst_control.filename_LC,/remove_all)
info.jwst_control.filename_MDC = strcompress(info.jwst_control.dirout+'/'+info.jwst_control.filename_MDC,/remove_all)
info.jwst_control.filename_reset = strcompress(info.jwst_control.dirout+'/'+info.jwst_control.filename_reset,/remove_all)
info.jwst_control.filename_rscd = strcompress(info.jwst_control.dirout+'/'+info.jwst_control.filename_rscd,/remove_all)
info.jwst_control.filename_lastframe = strcompress(info.jwst_control.dirout+'/'+info.jwst_control.filename_lastframe,/remove_all)

info.jwst_control.filename_slope_refimage = $
  strcompress(info.jwst_control.dirout+'/'+info.jwst_control.filename_slope_refimage,/remove_all)

;_______________________________________________________________________
; error checking - after defining names 
;_______________________________________________________________________
info.jwst_data.raw_exist =1

jwst_read_data_type,info.jwst_control.filename_raw,type

if(type ne 0) then begin
    error_message = ' You did not open a  Science Frame data File, try again'
    status = 1
    return
endif


info.jwst_data.raw_exist = 1

id_file_exist = 0
ref_corrected = 0
lc_file_exist = 0
mdc_file_exist = 0
reset_file_exist = 0
rscd_file_exist = 0
lastframe_file_exist = 0
yes_string = 'yes'


file_exist1 = file_test(info.jwst_control.filename_slope,/regular,/read)


if(file_exist1 eq 1) then begin 
   fits_open,info.jwst_control.filename_slope,fcb
   fits_read,fcb,cube_raw,header_raw,/header_only,exten_no = 0
   fits_close,fcb
   rc_str = fxpar(header_raw,'WREFPIXC',count = count)
   rc_str = strcompress(strlowcase(rc_str),/remove_all)
   result = strcmp(rc_str,yes_string)
   if(result eq 1) then ref_corrected = 1
        

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


info.jwst_control.file_refcorrection_exist = 0
if(ref_corrected eq 1) then   info.jwst_control.file_refcorrection_exist = file_test(info.jwst_control.filename_refcorrection,/regular,/read)

info.jwst_control.file_lc_exist = 0
if(lc_file_exist eq 1) then info.jwst_control.file_lc_exist = file_test(info.jwst_control.filename_LC,/regular,/read)

info.jwst_control.file_mdc_exist = 0
if(mdc_file_exist eq 1) then info.jwst_control.file_mdc_exist = file_test(info.jwst_control.filename_MDC,/regular,/read)

info.jwst_control.file_reset_exist = 0
if(reset_file_exist eq 1) then info.jwst_control.file_reset_exist = file_test(info.jwst_control.filename_reset,/regular,/read)

info.jwst_control.file_rscd_exist = 0
if(rscd_file_exist eq 1) then info.jwst_control.file_rscd_exist = file_test(info.jwst_control.filename_rscd,/regular,/read)

info.jwst_control.file_lastframe_exist = 0
if(lastframe_file_exist eq 1) then info.jwst_control.file_lastframe_exist = file_test(info.jwst_control.filename_lastframe,/regular,/read)


cube_raw = 0
header_raw = 0
;_______________________________________________________________________  
print,' Science frame input file name   ',info.jwst_control.filename_raw
if(info.jwst_control.file_refcorrection_exist eq 1) then $
  print,' Reference Correction file       ',info.jwst_control.filename_refcorrection
print,' Slope input file                ',info.jwst_control.filename_slope
print,' Calibrated file                 ',info.jwst_control.filename_cal


if(info.jwst_control.file_lc_exist) then $
print,' Linearity Corrected File        ',info.jwst_control.filename_LC

if(info.jwst_control.file_mdc_exist) then $
print,' Mean Dark Corrected File        ',info.jwst_control.filename_MDC

if(info.jwst_control.file_reset_exist) then $
print,' Reset Corrected File        ',info.jwst_control.filename_reset

if(info.jwst_control.file_rscd_exist) then $
print,' RSCD Corrected File        ',info.jwst_control.filename_rscd

if(info.jwst_control.file_lastframe_exist) then $
print,' LastFrame Corrected File        ',info.jwst_control.filename_lastframe


print,' File base                       ',info.jwst_control.filebase



end
;_______________________________________________________________________  

; This routine reads the slope name using the dialog_pick routine and
; forms the names of the other files;

pro jwst_setup_names_from_slope,info,status,error_message
status = 0
error_message = ' ' 
;_______________________________________________________________________
; routine which sets up the names of the raw images, slope images
; If the user provided the file name - then info.jwst_control.set_scidata=1
;_______________________________________________________________________
status = 0


image_file = dialog_pickfile(/read,$
                             get_path=realpath,Path=info.jwst_control.dirout,$
                             filter = '*.fits')
len = strlen(realpath)
realpath = strmid(realpath,0,len-1) ; just to be consistent 
info.jwst_control.dirout = realpath
    
if(image_file eq '')then begin
   print,' No file selected, can not read in data'
   status = 2
   return
endif
if (image_file NE '') then begin
   filename = image_file
endif

;_______________________________________________________________________

;_______________________________________________________________________
; assuming slope file of form name_rate.fits

filename_slope = filename
len = strlen(filename_slope)
fitname = strmid(filename_slope,len-5,5)
fits = strpos(filename,fitname)
fitlvl2 = strmid(filename_slope,len-10,10)
lvl2 = strpos(filename,fitlvl2)

info.jwst_control.filename_slope = filename_slope
info.jwst_control.filename_slope_int = strmid(filename,0,lvl2) + 'ints' + fitname
info.jwst_control.filename_raw = strmid(filename,0,lvl2) +fitname
info.jwst_control.filename_refcorrection = strmid(filename,0,lvl2) + '_RefCorrection'+fitname

info.jwst_control.filename_LC =  strmid(filename,0,lvl2) + '_LinCorrected'+fitname
info.jwst_control.filename_MDC = strmid(filename,0,lvl2) + '_DarkCorrected'+fitname
info.jwst_control.filename_reset = strmid(filename,0,lvl2) + '_ResetCorrected'+fitname
info.jwst_control.filename_rscd = strmid(filename,0,lvl2) + '_RSCDCorrected'+fitname
info.jwst_control.filename_lastframe = strmid(filename,0,lvl2) + '_LastFrameCorrected'+fitname

info.jwst_control.filename_slope_refimage = 'none'
info.jwst_control.filename_cal = strmid(filename,0,lvl2) + '_cal'+fitname

print,info.jwst_control.filename_raw
dirlocation = strpos(filename_slope,'/',/reverse_search)

file_exist1 = file_test(info.jwst_control.filename_raw,/regular,/read)
if(file_exist1 ne 1) then begin
    len_new = lvl2 - dirlocation -1
    file1 = info.jwst_control.dir + '/' + strmid(filename,dirlocation+1,len_new)
    test_filename = file1  +fitname

    file_exist1 = file_test(test_filename,/regular,/read)

    if(file_exist1) then begin 
        info.jwst_control.filename_raw = test_filename

    endif
endif


slash_str = strsplit(info.jwst_control.filename_slope,'/',/extract)
n_slash = n_elements(slash_str)
if (n_slash GT 1) then begin
    out_filebase = slash_str[n_slash-1]
endif else begin
    out_filebase = info.jwst_control.filename_slope
endelse

info.jwst_control.filename = out_filebase ; only the filename not directory
len= strlen(out_filebase)
out_file = strmid(out_filebase,0,len-10)
info.jwst_control.filebase = out_file


;_______________________________________________________________________

;_______________________________________________________________________
; error checking - after defining names 

;_______________________________________________________________________

; do some tests on if the file is correct:



jwst_read_data_type,info.jwst_control.filename_slope,type


if(type eq 1 ) then begin
endif else begin
    flag = 1
    error_message = ' You did NOT open a SLOPE file, input file name again '
    print,error_message
    status = 1
    return
endelse



data = 0
header_slope = 0

;*********************************************************************** 

file_exist1 = file_test(info.jwst_control.filename_slope,/regular,/read)
if(file_exist1 ne 1 ) then begin
    error_message  = " Error in slope name"+ info.jwst_control.filename_slope
    status = 1
endif


file_exist1 = file_test(info.jwst_control.filename_raw,/regular,/read)
info.jwst_data.raw_exist = file_exist1
if(file_exist1 ne 1 ) then begin
    error_message  = " The raw science file does not exist. "
    status = 3
endif


ref_corrected = 0
yes_string = 'yes'
fits_open,info.jwst_control.filename_slope,fcb
fits_read,fcb,data,header_raw,/header_only,exten_no = 0
fits_close,fcb
rc_str = fxpar(header_raw,'WREFPIXC',count = count)
rc_str = strcompress(strlowcase(rc_str),/remove_all)
result = strcmp(rc_str,yes_string)
if(result eq 1) then ref_corrected = 1



info.jwst_control.file_refcorrection_exist = 0
if(ref_corrected eq 1) then $
info.jwst_control.file_refcorrection_exist = file_test(info.jwst_control.filename_refcorrection,/regular,/read)


lc_file_exist = 0
lc_str = fxpar(header_raw,'WLINC',count = count)
lc_str = strcompress(strlowcase(lc_str),/remove_all)
result = strcmp(lc_str,yes_string)
if(result eq 1) then lc_file_exist = 1 

info.jwst_control.file_lc_exist = 0
if(lc_file_exist eq 1) then $
  info.jwst_control.file_lc_exist = file_test(info.jwst_control.filename_LC,/regular,/read)

md_file_exist = 0
md_str = fxpar(header_raw,'WMDC',count = count)
md_str = strcompress(strlowcase(md_str),/remove_all)
result = strcmp(md_str,yes_string)
if(result eq 1) then md_file_exist = 1 

info.jwst_control.file_mdc_exist = 0
if(md_file_exist eq 1) then $
  info.jwst_control.file_mdc_exist = file_test(info.jwst_control.filename_MDC,/regular,/read)


reset_file_exist = 0
reset_str = fxpar(header_raw,'WRESET',count = count)
reset_str = strcompress(strlowcase(reset_str),/remove_all)
result = strcmp(reset_str,yes_string)
if(result eq 1) then reset_file_exist = 1 

info.jwst_control.file_reset_exist = 0
if(reset_file_exist eq 1) then $
  info.jwst_control.file_reset_exist = file_test(info.jwst_control.filename_reset,/regular,/read)


rscd_file_exist = 0
rscd_str = fxpar(header_raw,'WRSCD',count = count)
rscd_str = strcompress(strlowcase(rscd_str),/remove_all)
result = strcmp(rscd_str,yes_string)
if(result eq 1) then rscd_file_exist = 1 

info.jwst_control.file_rscd_exist = 0
if(rscd_file_exist eq 1) then $
  info.jwst_control.file_rscd_exist = file_test(info.jwst_control.filename_rscd,/regular,/read)

lastframe_file_exist = 0
lastframe_str = fxpar(header_raw,'WLASTF',count = count)
lastframe_str = strcompress(strlowcase(lastframe_str),/remove_all)
result = strcmp(lastframe_str,yes_string)
if(result eq 1) then lastframe_file_exist = 1 

info.jwst_control.file_lastframe_exist = 0
if(lastframe_file_exist eq 1) then $
  info.jwst_control.file_lastframe_exist = file_test(info.jwst_control.filename_lastframe,/regular,/read)


data = 0
header_raw = 0

;_______________________________________________________________________  
print,' Science frame input file name   ',info.jwst_control.filename_raw
if(info.jwst_control.file_refcorrection_exist) then $
  print,' Reference Correction file       ',info.jwst_control.filename_refcorrection
print,' Slope input file                ',info.jwst_control.filename_slope
print,' Slope reference output          ', info.jwst_control.filename_slope_refimage

if(info.jwst_control.file_lc_exist) then $
  print,' Linearity Corrected data        ',info.jwst_control.filename_LC 
if(info.jwst_control.file_mdc_exist) then $
  print,' Mean Dark Corrected data        ',info.jwst_control.filename_MDC 

if(info.jwst_control.file_reset_exist) then $
  print,' Reset Corrected data        ',info.jwst_control.filename_reset 

if(info.jwst_control.file_rscd_exist) then $
  print,' RSCD Corrected data        ',info.jwst_control.filename_rscd 

if(info.jwst_control.file_lastframe_exist) then $
  print,' LastFrame Corrected data        ',info.jwst_control.filename_lastframe 
print,' Calibrated file                 ',info.jwst_control.filename_cal
print,' File base                       ',info.jwst_control.filebase

end
;_______________________________________________________________________  







