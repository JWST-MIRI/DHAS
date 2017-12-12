pro dn_search, list,dirin= dirinput
per_tolerance = 5

dir = ''
if(N_elements(dirinput)) then begin
    if(dirinput ne '') then begin 
        dir = dirinput
        dir = strcompress(dir,/remove_all)
        len = strlen(dir) 
        test = strmid(dir,len-1,len-1)
        if(test eq '/')then  dir = strmid(dir,0,len-1)
    endif
endif


caldir ='/home/morrison/DHAS/MPipeline/Cal/Lab/FM/'

bad_file_493 = caldir+'bad_pixel_file_SCE1_v2.fits'
bad_file_494 = caldir+'bad_pixel_file_SCE2_v2.fits'
bad_file_495 = caldir+'bad_pixel_file_SCE3_v2.fits'

bad_mask_493 = fltarr(1032,1024); initialize bad pixel file to = 0
bad_mask_494 = fltarr(1032,1024); initialize bad pixel file to = 0
bad_mask_495 = fltarr(1032,1024); initialize bad pixel file to = 0

;_______________________________________________________________________
print,' Reading Bad Pixelfile ', bad_file_493

file_exist = file_test(bad_file_493,/regular,/read)
if(file_exist ne 1) then begin
	Print,' Dead Pixel mask not found ' + bad_file_493 
    	stop
endif


; read in fits file data- 493
fits_open,bad_file_493,fcb
fits_read,fcb,bad_data,header
fits_close,fcb
bad_pixels_493 = bad_data
bad_data = 0

;_______________________________________________________________________
print,' Reading Bad Pixelfile ', bad_file_494

file_exist = file_test(bad_file_494,/regular,/read)
if(file_exist ne 1) then begin
	Print,' Dead Pixel mask not found ' + bad_file_494 
    	stop
endif


; read in fits file data- 494
fits_open,bad_file_494,fcb
fits_read,fcb,bad_data,header
fits_close,fcb
bad_pixels_494 = bad_data
bad_data = 0
;_______________________________________________________________________
print,' Reading Bad Pixelfile ', bad_file_495

file_exist = file_test(bad_file_495,/regular,/read)
if(file_exist ne 1) then begin
	Print,' Dead Pixel mask not found ' + bad_file_495 
    	stop
endif


; read in fits file data- 495
fits_open,bad_file_495,fcb
fits_read,fcb,bad_data,header
fits_close,fcb
bad_pixels_495 = bad_data
bad_data = 0

;_______________________________________________________________________

files = strarr(5000)
i = 0 
openr,lun,list,/get_lun
while(not eof(lun)) do begin
    a = ' '
    readf,lun,a
    files[i]  = strcompress(a,/remove_all)
    i = i + 1
endwhile

close,lun
n_files = i 
tolerance = 50000.0
tolerance_low = 9000.0
log = 'dn_data.log'
close,11
openw,11,log
printf,11,' Number of pixels greater than a DN value of ',tolerance
printf,11,' Number of pixels less than  DN value of ',tolerance_low
printf,11,' And % above number greater than  ',per_tolerance
printf,11,'Filename             ', 'Integration #','                 # above, # below ',$
       tolerance,tolerance_low


for ii = 0,n_files-1 do begin
    filein = strcompress(dir+'/'+files[ii],/remove_all)
    file_exist1 = file_test(filein,/regular,/read)
    if(file_exist1 ne 1 ) then begin

	print,       " The input file does not exist "+ filein

    endif

;    print,filein
    fits_open,filein,fcb
    fits_read,fcb,data,header,exten_no = 0, /header_only

    naxis1 =  fxpar(header,'NAXIS1',count=count)
    naxis2 =  fxpar(header,'NAXIS2',count=count)
    naxis3 =  fxpar(header,'NAXIS3',count=count)
    sca_id =  fxpar(header,'SCA_ID',count=count)

    colstart =  fxpar(header,'COLSTART',count=count)
    rowstart =  fxpar(header,'ROWSTART',count=count)

    naxis22 = naxis2 - naxis2/5

    nframes = fxpar(header,'NGROUPS',count=count)
    if(count eq 0) then nframes = fxpar(header,'NGROUP',count = count)
    if(count eq 0) then nframes = naxis3

    nints = fxpar(header,'NINTS',count = count)
    if(count eq 0) then nints = fxpar(header,'NINT',count = count)
    if(count eq 0) then nints = 1

    subarray = 0
    if(naxis1 ne 1032 and naxis2 ne 1280) then subarray = 1 

    npixels = long(naxis1 * naxis2)
    for i = 0,nints-1 do begin
        if(nframes gt 2) then begin 
            for j = nframes-2,nframes-2 do begin
                islice = i*nframes + j
                im_raw = readfits(filein,nslice = islice,/silent) 
                image_good = im_raw[*,0:naxis22-1]
                im_raw = 0
                bad_pixel = bad_pixels_493
                if(sca_id eq 494) then bad_pixel = bad_pixels_494
                if(sca_id eq 495) then bad_pixel = bad_pixels_495
                
                if(subarray ne 0) then begin
                    newmask =  fltarr(naxis1,naxis22)
                    ibad = 0
                    ix1 = colstart-1
                    ix2 = ix1 + naxis1-1
                    iy1 = rowstart-1
                    iy2 = iy1 + naxis22-1

                    newmask[*,*] = bad_pixel[ix1:ix2,iy1:iy2]
;	        print,'grabbing data from section',ix1,ix2,iy1,iy2
                    bad_pixel = 0
                    bad_pixel = newmask
                    index_bad = where(bad_pixel ne 0, nbad)           
                endif

                index_good = where(bad_pixel eq 0) 
                imgood = image_good(index_good)
                image_good = 0
                indexover = where(imgood gt tolerance,num)
                per = float(num)/float(npixels)
                per100 = per*100.0 
            endfor
; now grab second frame for low DN value
            for j = 2,2 do begin
                islice = i*nframes + j
                im_raw = readfits(filein,nslice = islice,/silent) 
                image_good = im_raw[*,0:naxis22-1]
                im_raw = 0
                bad_pixel = bad_pixels_493
                if(sca_id eq 494) then bad_pixel = bad_pixels_494
                if(sca_id eq 495) then bad_pixel = bad_pixels_495
                
                if(subarray ne 0) then begin
                    newmask =  fltarr(naxis1,naxis22)
                    ibad = 0
                    ix1 = colstart-1
                    ix2 = ix1 + naxis1-1
                    iy1 = rowstart-1
                    iy2 = iy1 + naxis22-1

                    newmask[*,*] = bad_pixel[ix1:ix2,iy1:iy2]
;	        print,'grabbing data from section',ix1,ix2,iy1,iy2
                    bad_pixel = 0
                    bad_pixel = newmask
                    index_bad = where(bad_pixel ne 0, nbad)           
                endif

                index_good = where(bad_pixel eq 0) 
                imgood = image_good(index_good)
                image_good = 0
                indexover = where(imgood lt tolerance_low,num_low)
                per = float(num_low)/float(npixels)
                per100_low = per*100.0 
            endfor

; Write out results

            if(subarray eq 0) then begin 
                if(per100 gt per_tolerance or per100_low gt per_tolerance) then begin
                    printf,11,format='(a50,i4,2i9,2f6.2)',files[ii],i+1,num,num_low,per100,per100_low
                    print,files[ii],i+1, num,num_low,per100,per100_low
                endif	
            endif
        endif
    endfor
    fits_close,fcb
endfor
close,11
end
