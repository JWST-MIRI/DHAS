pro read_all_slopes,filename, slopedata,exists,status,error_message

 exists = file_test(filename,/regular,/read)
 status = 0
if(exists ne  1)then begin
    status = 1
    error_message = ' No slope image exists: ' +filename
    slopedata = fltarr(1,1,1)
    slopedata[*,*,*] =0.0

endif else begin
    exist = 1 
    fits_open,filename,fcb
    fits_read,fcb,cube_raw,header_raw,/header_only,exten_no = 0
    nint = fxpar(header_raw,'NPINT',count = count)
    if(count eq 0) then     nint = fxpar(header_raw,'NINT',count = count)
    if(count eq 0 ) then nint = 1
    if(nint eq 0) then nint = 1

    nframe = fxpar(header_raw,'NPGROUP',count = count)
    if(count eq 0) then nframe = fxpar(header_raw,'NGROUPS',count = count)

    framediv = 1
    framediv = fxpar(header_raw,'FRMDIVSR',count=count)
    if(framediv ne 1 and count ne 0) then begin
       print,' FRMDIVSR is not 1, this is FASTGRPAVG data, adjusting NGroups for QL tool'
       nframe = nframe/framediv
    endif

    nslopes = nint
    if(nframe eq 1 and nint gt 1) then nslopes = 1

    fits_read,fcb,cube_raw,header_raw,/header_only,exten_no = 1
    xsize = fxpar(header_raw,'NAXIS1',count = count)
    ysize = fxpar(header_raw,'NAXIS2',count = count)

    slopedata = fltarr(xsize,ysize,nslopes+1)
    for i =0, nslopes do begin 
       fits_read,fcb,cube,header,exten_no = i 
        size_cube = size(cube)
        slopedata[*,*,i] = cube[*,*,0]
    endfor
    fits_close,fcb
;_______________________________________________________________________

endelse


end
