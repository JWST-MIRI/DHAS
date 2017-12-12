
pro jwst_reading_slope_processing,filename,slope_exist,fit_start,fit_end,frametime

  

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
complete= 'COMPLETE'
file_exist1 = file_test(filename,/regular,/read)
if(file_exist1 ne 1 ) then begin
    slope_exist = 0
    return
endif 

fits_open,filename,fcb
fits_read,fcb,cube_raw,header_raw,/header_only,exten_no = 0
fits_close,fcb
ngroups = fxpar(header_raw,'NGROUPS',count = count)
slope_unit = 1

slope_unit = fxpar(header_raw,'SUNITS',count = count)
if(count eq 0) then slope_unit = 1
frametime = fxpar(header_raw,'TGROUP',count = count)
if(count eq 0) then frametime = 2.775
gain = fxpar(header_raw,'GAIN',count = count)
if(count eq 0) then gain = 5.95



fit_start = 0
fit_end  = ngroups
last_frame_status = fxpar(header_raw,'S_LASTFR',count = count)
result = strcmp(last_frame_status,complete)
if(result eq 1) then fit_end = ngroups -1



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


end
