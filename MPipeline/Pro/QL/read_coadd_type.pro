pro read_coadd_type,filename,type
; read in the header and determine what kind of data it is
; type = 1 for coadded data
; type = 0 for non-coadded data


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

nframes = fxpar(header,'NGROUPS',count=count)
if(count eq 0) then nframes = fxpar(header,'NGROUP',count = count)
nints = fxpar(header,'NINTS',count = count)
if(count eq 0) then nints = fxpar(header,'NINT',count = count)

;if(nframes eq 1 and nints gt 1) then type = 1


cube = 0
header = 0
fits_close,fcb
end
