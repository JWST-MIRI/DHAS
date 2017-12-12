pro create_new_cube,cubefile,sav,new_wave

; Read in the cube and read in the saveset - Rafael created. 
; Replace the wavelengths in the cube with the ones from the Save
; set.

initial = -9999.9
; read in cube
filein = strcompress(cubefile,/remove_all)
file_exist1 = file_test(cubefile,/regular,/read)
if(file_exist1 ne 1 ) then begin
    result = dialog_message(" The input cube file does not exist "+ filein,/error )
    retall
    return
endif

fits_open,filein,fcb
fits_read,fcb,cube,header,exten_no = 0
fits_close,fcb
naxis1 =  fxpar(header,'NAXIS1',count=count)
naxis2 =  fxpar(header,'NAXIS2',count=count)
naxis3 =  fxpar(header,'NAXIS3',count=count)
nints = fxpar(header,'NINTS',count = count)
if(count eq 0) then nints = fxpar(header,'NINT',count = count)
if(count eq 0) then nints = 1

len = strlen(filein)
base = strmid(filein,0,len-5)
newfile = base + '_WaveCalibrated.fits'
print,newfile

new_cube = cube
new_cube[*,*,*] = initial 

restore,sav

npixels = n_elements(spx_arr.xpix)

x = spx_arr.xpix
y = spx_arr.ypix
  
for i =0, npixels - 1 do begin
    ;print,'*************************'
    ;print,x[i],y[i]
    wave = spx_arr[i].wave
    ;print,wave
    new_cube[x[i]-1,y[i]-1,*] = wave
    
endfor

sxaddhist,' Wavelengths contain Calibrated values',header
sxaddpar,header,'WCAL',1,' Wavelengths are Calibrated'

mwrfits,new_cube,newfile,header,/create
new_wave  = new_cube
new_cube[*,*,*] = 1.0 ; for fake uncertainty 
mwrfits,new_cube,newfile,header ; writing extension for fake uncertainity 
new_cube = 0
end
