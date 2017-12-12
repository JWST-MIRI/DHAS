@find_slice_region.pro
@find_wavelength_region.pro
@extract_lines.pro
@create_new_cube.pro
@wcal_read.pro

pro wavecal,input_file,wait=wtime,verbose=verbose
@wave_structs

; input file: wavecal.input

waittime = 0
if N_elements(wtime) then waittime= wtime

do_verbose = 0
if keyword_set(verbose) then do_verbose = 1

;_______________________________________________________________________
; read in the input file
slopefile = ' ' & cubefile = ' ' & d2sfile = ' ' & saveset = ' ' & peaksfile = ' '  & polyfits= ' ' 
wcal_read,input_file,slopefile,cubefile,d2cfile,channel,saveset,peaksfile,polyfits,status
;_______________________________________________________________________
; read in cube 

fits_open,cubefile,cubefcb
fits_read,cubefcb,cubedata,cube_header
fits_close,cubefcb
cube = {wcubei}

cube.naxis1 =  fxpar(cube_header,'NAXIS1',count=count)
cube.naxis2 =  fxpar(cube_header,'NAXIS2',count=count)
cube.naxis3 =  fxpar(cube_header,'NAXIS3',count=count)
cube.cdelt1 =  fxpar(cube_header,'CDELT1',count=count)
cube.cdelt2 =  fxpar(cube_header,'CDELT2',count=count)
cube.cdelt3 =  fxpar(cube_header,'CDELT3',count=count)
cube.crval1 =  fxpar(cube_header,'CRVAL1',count=count)
cube.crval2 =  fxpar(cube_header,'CRVAL2',count=count)
cube.crval3 =  fxpar(cube_header,'CRVAL3',count=count)
if ptr_valid(cube.pcubedata) then ptr_free,cube.pcubedata
cube.pcubedata = ptr_new(cubedata)
cubedata = 0

;_______________________________________________________________________
; read in calibration file
calfile = d2cfile

calin = strcompress(calfile,/remove_all)
file_exist1 = file_test(calin,/regular,/read)
if(file_exist1 ne 1 ) then begin
    result = dialog_message(" The  calibration file does not exist "+ calin,/error )
    retall
    return
endif
fits_open,calin,cfcb
fits_read,cfcb,cdata,cheader,exten_no = 1 ; added for new d2c files
lamba = cdata[*,*]
fits_read,cfcb,cdata,cheader,exten_no = 2 ; added for new d2c files
alpha = cdata[*,*]
fits_read,cfcb,cdata,cheader, exten_no = 3 ; added for new d2c files
beta = cdata[*,*]

fits_close,cfcb

;-----------------------------------------------------------------------
; For a given Channel read the d2c file and fill in slice_region with
; the xmin and xmax regions for each slice in channel. 
sliceno = 21
if(channel eq 2) then sliceno = 17
if(channel eq 3) then slicenno = 16
if(channel eq 4) then sliceno = 12
slice_region = fltarr(2,sliceno)
find_slice_region, cheader,channel,sliceno, slice_region;,/verbose

;_______________________________________________________________________
; read in saveset file and pull out wavelengths
create_new_cube,cubefile,saveset,new_wave


;_______________________________________________________________________
peaks = fltarr(1000)

; read in peaks file- again provided by Rafael
openr,lun,peaksfile,/get_lun
ip = 0
line = strarr(1)
readf,lun,line
while (NOT EOF(lun)) do begin
    readf,lun,peak,error1,error2,error3
    peaks[ip] = peak
    ip = ip + 1
endwhile
peaks = peaks[0:ip-1]
close,lun
;_______________________________________________________________________
; read in slope file

filein = strcompress(slopefile,/remove_all)
file_exist1 = file_test(filein,/regular,/read)
if(file_exist1 ne 1 ) then begin
    result = dialog_message(" The input slope file does not exist "+ filein,/error )
    retall
    return
endif

fits_open,slopefile,fcb
fits_read,fcb,data,header,exten_no = 0
fits_close,fcb
naxis1 =  fxpar(header,'NAXIS1',count=count)
naxis2 =  fxpar(header,'NAXIS2',count=count)
naxis3 =  fxpar(header,'NAXIS3',count=count)
nints = fxpar(header,'NINTS',count = count)
if(count eq 0) then nints = fxpar(header,'NINT',count = count)
if(count eq 0) then nints = 1

slope = data[*,*,0]
slope[*,0] = 0.0 
slope[*,1023] = 0.0
no_value = -9999.90

polyfits_full = strcompress(polyfits+ '.explain',/remove_all)
polyfits_fail = strcompress(polyfits+ '.failure',/remove_all)
 
openw,lun,polyfits,/get_lun
openw,lun_full,polyfits_full,/get_lun
openw,lun_fail,polyfits_fail,/get_lun

printf,lun,'Slice Region Xrange       Yrange   Cube Wave  Peak Wave   PolyFit_Result' +$
       '                                 Chisq      Sigma Coefficients'
;_______________________________________________________________________
;for i = 10,sliceno-1 do begin
for i = 0,sliceno-1 do begin

;    ivalid = where( new_wave[*,i,*] gt no_value,num)
;    if(num gt 1) then  begin
        print,' Working on slice',i+1
        print,'grabbing slice located at x limits of ',slice_region[0,i]-1, slice_region[1,i]-1

        slice = slope[slice_region[0,i]-1:slice_region[1,i]-1,*]
        xstart = slice_region[0,i]
        
        region = intarr(4,500)
        extract_lines,slice ,xstart,i+1,region,nregions,beta

        if(do_verbose eq 1) then begin 
            find_wavelength_region,slice,i+1,region,nregions,xstart,alpha,beta,lamba,cube,$
              new_wave,peaks,lun,lun_full,lun_fail,waittime,/verbose
        endif else begin
            find_wavelength_region,slice,i+1,region,nregions,xstart,alpha,beta,lamba,cube,$
              new_wave,peaks,lun,lun_full,lun_fail,waittime
        endelse
        
;    endif else begin
;        print,' No Valid Wavelengths found in Calibration Wavelength Cube for this slice', i+1
;    endelse

endfor

close,lun
close,lun_full
close,lun_fail
end

