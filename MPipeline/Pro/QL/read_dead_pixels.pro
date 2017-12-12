pro read_dead_pixels,info,bad_file,bad_file_exist,$
                     numbad,bad_mask,status, error_message
bad_mask = fltarr(1032,1024); initialize bad pixel file to = 0

status = 0
error_message = ' ' 
null = ""
dead_file = null
bad_file_exist = 0
numbad = 0

print,' Reading Bad Pixelfile ', bad_file

file_exist = file_test(bad_file,/regular,/read)
if(file_exist ne 1) then begin
    error_message = ' Dead Pixel mask not found ' + bad_file 
    
    print,error_message
    status = 1
    bad_file_exist = 0
    return
endif

info.badpixel.readin = 1


bad_pixels = fltarr(1032,1024)
nbad = long(1032) *long( 1024)
ibad = long(0)
bad_file_exist = 1
; read a FITS bad pixel file

; read in fits file data
fits_open,bad_file,fcb
fits_read,fcb,bad_data,header,/header_only,exten_no = 0  ; primary header check  
naxis = fxpar(header,'NAXIS',count = count)

if(naxis ne 0 )then begin
    print,' The Bad Pixel Mask is of wrong format'
    print,' Check bad pixel mask name and directory in preferences file'
    print,' Turning off applying bad pixel mask'
    return
endif

fits_read,fcb,bad_mask,header ,exten_no = 1 ; First extension holds data   
naxis2 = fxpar(header,'NAXIS2',count = count)
naxis1 = fxpar(header,'NAXIS1',count = count)
if(naxis2 ne 1024 or naxis1 ne 1032 )then begin
    print,' The Bad Pixel Mask is of wrong format'
    print,' Check bad pixel mask name and directory in preferences file'
    print,' Turning off applying bad pixel mask'
    return
endif


index = where(bad_mask[*,*] ne 0,numbad)

print,'Number of bad/noisy pixels read in',numbad
;_______________________________________________________________________
; adjust bad pixels is in subarray

if(info.data.subarray ne 0) then begin
	newmask =  fltarr(info.data.image_xsize,info.data.image_ysize)
	ibad = 0
	ix1 = info.data.colstart-1
	ix2 = ix1 + info.data.image_xsize-1
	iy1 = info.data.rowstart-1
	iy2 = iy1 + info.data.image_ysize-1

;        print,ix1,ix2,iy1,iy2
;        print,'colstart rowstart image size',info.data.colstart, info.data.rowstart, info.data.image_xsize, info.data.image_ysize


        newmask[*, *] = bad_mask[ix1:ix2,iy1:iy2]

        bad_mask = 0
        bad_mask = newmask
        new_mask = 0
        
    endif

end
