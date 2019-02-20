;
; pick a name using the IDL dialog_pickfile routine.
; setup_names takes a raw science file as the input and pulls out the
; base name and figures out the slope name and other intermediate
; files that might exist. 
;_______________________________________________________________________
pro jwst_setup_names,info,type,status,error_message
; type = 0 input is uncal file
; type = 1 input is rate file 
status = 0
error_message = ' ' 
;_______________________________________________________________________
; routine which sets up the names of the raw images, slope images

; This will be the case if called after  mql_run_miri_sloper
;_______________________________________________________________________
status = 0

image_file = dialog_pickfile(/read,$
                             get_path=realpath,Path=info.jwst_control.dir,$
                             filter = '*.fits',/fix_filter)
 
len = strlen(realpath)
realpath = strmid(realpath,0,len-1) ; just to be consistent 

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
fitname = '.fits'

;_______________________________________________________________________
if(type eq 0) then begin ; working with uncal - raw file 
   uncal = '_uncal'
   info.jwst_control.dir = realpath
   check = strpos(out_filebase,uncal)
   if(check gt 0) then begin
      out_file = strmid(out_filebase,0,check)
   endif else begin 
      len= strlen(out_filebase)
      out_file = strmid(out_filebase,0,len-5)
   endelse 
   info.jwst_control.filebase = out_file
   len = strlen(filename)

   fits = strpos(filename,fitname)
   info.jwst_control.filename_raw = filename
   jwst_read_data_type,info.jwst_control.filename_raw,type_error
   if(type_error ne 0) then begin
      error_message = ' You did not open a Science Frame data File, try again'
      status = 1
      return
   endif

endif
if (type eq 1) then begin       ; working with rate file  
   rate = '_rate'
   info.jwst_control.dirout = realpath    
   check = strpos(out_filebase,rate)
   if(check gt 0) then begin
      out_file = strmid(out_filebase,0,check)
   endif else begin 
      len= strlen(out_filebase)
      out_file = strmid(out_filebase,0,len-5)
   endelse 
   info.jwst_control.filebase = out_file
   info.jwst_control.filename_slope = filename
   jwst_read_data_type,info.jwst_control.filename_slope,type_error

   if(type_error ne 1 ) then begin
      flag = 1
      error_message = ' You did NOT open a SLOPE file, input file name again '
      print,error_message
      status = 1
      return
   endif

endif
;_______________________________________________________________________

dirlocation = strpos(filename,'/',/reverse_search)

print,'The base filename: ',info.jwst_control.filebase

info.jwst_control.filename_slope = info.jwst_control.filebase + '_rate'+fitname
info.jwst_control.filename_slope_int = info.jwst_control.filebase + '_rateints'+fitname
info.jwst_control.filename_cal = info.jwst_control.filebase + '_cal'+fitname
info.jwst_control.filename_linearity = info.jwst_control.filebase + '_linearity'+fitname
info.jwst_control.filename_dark = info.jwst_control.filebase + '_dark_current'+fitname
info.jwst_control.filename_reset = info.jwst_control.filebase + '_reset'+fitname
info.jwst_control.filename_rscd = info.jwst_control.filebase + '_rscd'+fitname
info.jwst_control.filename_refpix = info.jwst_control.filebase + '_rscd'+fitname
info.jwst_control.filename_lastframe = info.jwst_control.filebase + '_lastframe'+fitname
info.jwst_control.filename_fitopt = info.jwst_control.filebase + '_fitopt'+fitname
info.jwst_control.filename_slope_refimage = 'none'
info.jwst_control.filename_cal = info.jwst_control.filebase + '_cal'+fitname

;_______________________________________________________________________
; jwst_control.dir and  jwst_control.dirout orginally defined in
; preference file 

info.jwst_control.filename_slope = strcompress(info.jwst_control.dirout+'/'+info.jwst_control.filename_slope,/remove_all)
info.jwst_control.filename_slope_int = strcompress(info.jwst_control.dirout+'/'+info.jwst_control.filename_slope_int,/remove_all)
info.jwst_control.filename_cal = strcompress(info.jwst_control.dirout+'/'+info.jwst_control.filename_cal,/remove_all)



info.jwst_control.filename_refpix = $
  strcompress(info.jwst_control.dirout+'/'+info.jwst_control.filename_refpix,/remove_all)

info.jwst_control.filename_linearity = strcompress(info.jwst_control.dirout+'/'+info.jwst_control.filename_linearity,/remove_all)
info.jwst_control.filename_dark = strcompress(info.jwst_control.dirout+'/'+info.jwst_control.filename_dark,/remove_all)
info.jwst_control.filename_reset = strcompress(info.jwst_control.dirout+'/'+info.jwst_control.filename_reset,/remove_all)
info.jwst_control.filename_rscd = strcompress(info.jwst_control.dirout+'/'+info.jwst_control.filename_rscd,/remove_all)
info.jwst_control.filename_fitopt = strcompress(info.jwst_control.dirout+'/'+info.jwst_control.filename_fitopt,/remove_all)
info.jwst_control.filename_lastframe = strcompress(info.jwst_control.dirout+'/'+info.jwst_control.filename_lastframe,/remove_all)

info.jwst_control.filename_slope_refimage = $
  strcompress(info.jwst_control.dirout+'/'+info.jwst_control.filename_slope_refimage,/remove_all)


info.jwst_control.file_raw_exist = 0
info.jwst_control.file_raw_exist = file_test(info.jwst_control.filename_raw,/regular,/read)

complete_string = 'complete'
refpix_step = 0 
linearity_step  = 0
dark_step = 0
reset_step = 0
rscd_step = 0 
lastframe_step = 0
;fitopt = 0

file_exist1 = file_test(info.jwst_control.filename_slope,/regular,/read)

; First check which steps have been run on the rate file
if(file_exist1 eq 1) then begin
   info.jwst_control.file_slope_exist =1 
   fits_open,info.jwst_control.filename_slope,fcb
   fits_read,fcb,data,header,/header_only,exten_no = 0
   fits_close,fcb

   data = 0 
   ; check if ref pixel correction was run
   rc_str = fxpar(header,'S_REFPIX',count = count)
   rc_str = strcompress(strlowcase(rc_str),/remove_all)
   result = strcmp(rc_str,complete_string)
   if(result eq 1) then refpix_step= 1
        
   lc_str = fxpar(header,'S_LINEAR',count = count)
   lc_str = strcompress(strlowcase(lc_str),/remove_all)
   result = strcmp(lc_str,complete_string)
   if(result eq 1) then linearity_step = 1 
   
   d_str = fxpar(header,'S_DARK',count = count)
   d_str = strcompress(strlowcase(d_str),/remove_all)
   result = strcmp(d_str,complete_string)
   if(result eq 1) then dark_step = 1 

   reset_str = fxpar(header,'S_RESET',count = count)
   reset_str = strcompress(strlowcase(reset_str),/remove_all)
   result = strcmp(reset_str,complete_string)
   if(result eq 1) then reset_step = 1 

   rscd_str = fxpar(header,'S_RSCD',count = count)
   rscd_str = strcompress(strlowcase(rscd_str),/remove_all)
   result = strcmp(rscd_str,complete_string)
   if(result eq 1) then rscd_step = 1

;   fitopt_str = fxpar(header,'S_FITOPT',count = count)
;   fitopt_str = strcompress(strlowcase(fitopt_str),/remove_all)
;   result = strcmp(fitopt_str,complete_string)
;   if(result eq 1) then fitopt = 1

   lastframe_str = fxpar(header,'S_LASTFR',count = count)
   lastframe_str = strcompress(strlowcase(lastframe_str),/remove_all)
   result = strcmp(lastframe_str,complete_string)
   if(result eq 1) then lastframe_step = 1 

   file_exist1 = file_test(info.jwst_control.filename_slope_int,/regular,/read)
   if(file_exist1 eq 1) then info.jwst_control.file_slope_int_exist =1 

   file_exist1 = file_test(info.jwst_control.filename_cal,/regular,/read)
   if(file_exist1 eq 1) then info.jwst_control.file_cal_exist =1 
endif

info.jwst_control.file_refpix_exist = 0
if(refpix_step eq 1) then   info.jwst_control.file_refpix_exist = file_test(info.jwst_control.filename_refpix,/regular,/read)

info.jwst_control.file_linearity_exist = 0
if(linearity_step eq 1) then info.jwst_control.file_linearity_exist = file_test(info.jwst_control.filename_linearity,/regular,/read)

info.jwst_control.file_dark_exist = 0
if(dark_step eq 1) then info.jwst_control.file_dark_exist = file_test(info.jwst_control.filename_dark,/regular,/read)

info.jwst_control.file_reset_exist = 0
if(reset_step eq 1) then info.jwst_control.file_reset_exist = file_test(info.jwst_control.filename_reset,/regular,/read)

info.jwst_control.file_rscd_exist = 0
if(rscd_step eq 1) then info.jwst_control.file_rscd_exist = file_test(info.jwst_control.filename_rscd,/regular,/read)

info.jwst_control.file_fitopt_exist = 0
;if(fitopt eq 1) then info.jwst_control.file_fitopt_exist = file_test(info.jwst_control.filename_fitopt,/regular,/read)
info.jwst_control.file_fitopt_exist = file_test(info.jwst_control.filename_fitopt,/regular,/read)

info.jwst_control.file_lastframe_exist = 0
if(lastframe_step eq 1) then info.jwst_control.file_lastframe_exist = file_test(info.jwst_control.filename_lastframe,/regular,/read)

header = 0
;_______________________________________________________________________  
if(info.jwst_control.file_raw_exist eq 1) then $
   print,' Science frame input file name    ',info.jwst_control.filename_raw

if(info.jwst_control.file_slope_exist) then $
   print,' Slope file                    ',info.jwst_control.filename_slope

if(info.jwst_control.file_slope_int_exist) then $
   print,' Slope int file                ',info.jwst_control.filename_slope_int
if(info.jwst_control.file_cal_exist) then $
   print,' Calibrated file               ',info.jwst_control.filename_cal

if(info.jwst_control.file_refpixel_exist eq 1) then $
  print,' Reference pixel corrected file ',info.jwst_control.filename_refpix
if(info.jwst_control.file_linearity_exist) then $
   print,' Linearity Corrected File      ',info.jwst_control.filename_linearity

if(info.jwst_control.file_dark_exist) then $
   print,' Dark Corrected File           ',info.jwst_control.filename_dark

if(info.jwst_control.file_reset_exist) then $
   print,' Reset Corrected File          ',info.jwst_control.filename_reset

if(info.jwst_control.file_rscd_exist) then $
   print,' RSCD Corrected File           ',info.jwst_control.filename_rscd

if(info.jwst_control.file_fitopt_exist) then $
   print,' Ramp Fit Intermediate file    ',info.jwst_control.filename_fitopt

if(info.jwst_control.file_lastframe_exist) then $
   print,' LastFrame Corrected File      ',info.jwst_control.filename_lastframe

print,' File base                       ',info.jwst_control.filebase

end
;_______________________________________________________________________  

