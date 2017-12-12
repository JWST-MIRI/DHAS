pro jwst_read_data_type,filename,type

; read in the header and determine what kind of data it is
; type = 0 for raw science data
; type = 1 for reduced rate science data 
; type = 7 for LVL3 data
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


check = fxpar(header,'CAL_VER',count = count)
if(count ne 0) then  type  = 1

check = fxpar(header,'CALIBR',count = count)
if(count ne 0) then  type  = 7



cube = 0
header = 0
fits_close,fcb
end
