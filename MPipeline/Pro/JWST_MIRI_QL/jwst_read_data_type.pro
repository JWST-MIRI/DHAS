pro jwst_read_data_type,filename,type

; read in the header and determine what kind of data it is
; type = 0 for raw science data
; type = 1 for  rate science data 
; type = 1 for  rate_int science data 
; type = 3 for LVL3 data
type = 0 ; default to raw files 
file_exist1 = file_test(filename,/read,/regular)

if(file_exist1 ne 1 ) then begin
    result = dialog_message(" The file does not exist "+ filename,/error )
    type = -1
    return
endif
;_______________________________________________________________________
;
fits_open,filename,fcb
fits_read,fcb,cube,header,/header_only,exten_no = 0
fits_read,fcb,cube,header1,/header_only,exten_no = 1

check1 = fxpar(header,'FILETYPE',count = count1)
check2 = fxpar(header,'S_RAMP',count = count2)
check3 = fxpar(header,'S_PHOTOM',count = count3)
nsize = fxpar(header1,'NAXIS',count=count4)

check_type = 'UNCALIBRATED'
result = strcmp(check1,check_type,/FOLD_CASE)
result = 1 ; this does not seem to be working
           ; for some simulated data
           ; FILETYPE is not read in correctly
;print,count2,count3,result,check1
if(count2 eq 0 and result eq 1 ) then  type  = 0
if(count2 ne 0 and count3 eq  0 and result eq 1 ) then  type  = 1
if(count2 ne 0 and count3 eq  1 and result eq 1 ) then  type  = 3

;if(type eq 1 and nsize eq 3) then type = 2
cube = 0
header = 0
fits_close,fcb
end
