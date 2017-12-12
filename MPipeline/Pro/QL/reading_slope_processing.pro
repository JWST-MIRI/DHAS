
pro reading_slope_processing,filename,slope_exist,fit_start,fit_end,low_sat,$
  high_sat,do_bad,use_psm,use_rscd,use_lin,use_dark,subrp,deltarp,even_odd,$
                             bad_file,psm_file,rscd_file,$
                             lin_file,dark_file,$
                             slope_unit,frametime,gain
  

low_sat = 0
fit_start = 0
fit_end = 0
subro = 0
subrp =0
high_sat = 0.0

slope_exist = 1
frametime = 0
use_psm = 0
use_rscd = 0 
do_bad = 0
use_lin = 0 
use_dark = 0 
psm_file = ''
bad_file = '' 
dark_file = ''
lin_file = ''
rscd_file = ''

yes_string = 'yes'
file_exist1 = file_test(filename,/regular,/read)
if(file_exist1 ne 1 ) then begin
    slope_exist = 0
    return
endif 

fits_open,filename,fcb
fits_read,fcb,cube_raw,header_raw,/header_only,exten_no = 0
fits_close,fcb
slope_unit = 1
slope_unit = fxpar(header_raw,'SUNITS',count = count)
if(count eq 0) then slope_unit = 1
frametime = fxpar(header_raw,'FRMTIME',count = count)
if(count eq 0) then frametime = 2.775
gain = fxpar(header_raw,'GAIN',count = count)
if(count eq 0) then gain = 5.95


fit_start = fxpar(header_raw,'NSFITS',count = count)
if(count eq 0) then fit_start = 0
fit_end = fxpar(header_raw,'NSFITE',count = count)
if(count eq 0) then fit_end = 0

low_sat = fxpar(header_raw,'LOWSAT',count = count)
if (count eq 0) then low_sat = 0
high_sat = fxpar(header_raw,'HIGHSAT',count = count)
if( count eq 0)then high_sat = 0



subpr = 0
subrp1_str = fxpar(header_raw,'SUBRP3',count = count)
subrp1_str = strcompress(strlowcase(subrp1_str),/remove_all)
result = strcmp(subrp1_str,yes_string)
if(result eq 1) then subrp = 3

subrp2_str = fxpar(header_raw,'SUBRP2',count = count)
subrp2_str = strcompress(strlowcase(subrp2_str),/remove_all)
result = strcmp(subrp2_str,yes_string)
if(result eq 1) then subrp = 2

subrp3_str = fxpar(header_raw,'SUBRP5',count = count)
subrp3_str = strcompress(strlowcase(subrp3_str),/remove_all)
result = strcmp(subrp3_str,yes_string)
if(result eq 1) then subrp = 5

subrp4_str = fxpar(header_raw,'SUBRP6',count = count)
subrp4_str = strcompress(strlowcase(subrp4_str),/remove_all)
result = strcmp(subrp4_str,yes_string)
if(result eq 1) then subrp = 6

subrp5_str = fxpar(header_raw,'SUBRP7',count = count)
subrp5_str = strcompress(strlowcase(subrp5_str),/remove_all)
result = strcmp(subrp5_str,yes_string)
if(result eq 1) then subrp = 7

even_odd = 1; now we always break down between even and odd rows
;even_odd = fxpar(header_raw,'DELTAEO',count = count)
;if(count eq 0)then even_odd = 0

deltarp = 0
deltarp = fxpar(header_raw,'DELTARP',count = count)
if(count eq 0) then deltarp = 0


use_psm_string = fxpar(header_raw,'USE_PSM',count = count)
use_psm_str = strcompress(strlowcase(use_psm_string),/remove_all)
result = strcmp(use_psm_str,yes_string)

if(result eq 1) then begin
    psm_file  = fxpar(header_raw,'PSM',count = count)
    psm_file = strcompress(psm_file,/remove_all)
    use_psm  = 1
    if(count = 0) then begin
        psm_file = ''
        use_psm = 0
    endif
endif 

use_lin_string = fxpar(header_raw,'USE_LIN',count = count)
use_lin_str = strcompress(strlowcase(use_lin_string),/remove_all)
result = strcmp(use_lin_str,yes_string)

if(result eq 1) then begin
    use_lin  = 1
    lin_file  = fxpar(header_raw,'LIN',count = count)
    lin_file = strcompress(lin_file,/remove_all)
    if(count = 0) then begin
        lin_file = ''
        use_lin = 0
    endif
endif 
 
use_rscd_string = fxpar(header_raw,'USE_RSCD',count = count)
use_rscd_str = strcompress(strlowcase(use_rscd_string),/remove_all)
result = strcmp(use_rscd_str,yes_string)
if(result eq 1) then begin
    use_rscd  = 1
    rscd_file  = fxpar(header_raw,'RSCD',count = count)
    rscd_file = strcompress(rscd_file,/remove_all)
    if(count = 0) then begin
        rscd_file = ''
        use_rscd = 0
    endif
endif 

use_dark_string = fxpar(header_raw,'USE_DARK',count = count)
use_dark_str = strcompress(strlowcase(use_dark_string),/remove_all)
result = strcmp(use_dark_str,yes_string)
if(result eq 1) then begin
    use_dark  = 1
    dark_file  = fxpar(header_raw,'DARK',count = count)
    dark_file = strcompress(dark_file,/remove_all)
    if(count = 0) then begin
        dark_file = ''
        use_dark = 0
    endif
endif 

do_bad_string = fxpar(header_raw,'RMBADPIX',count = count)
do_bad_str = strcompress(strlowcase(do_bad_string),/remove_all)
result = strcmp(do_bad_str,yes_string)

if(result eq 1) then begin
    bad_file  = fxpar(header_raw,'BADPFILE',count = count)
    do_bad = 1
    if(count = 0) then begin
        bad_file = ''
        do_bad = 0
    endif
endif 


end
