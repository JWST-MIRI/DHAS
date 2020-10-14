pro jwst_find_line_values,x,wavelength,spectrum,error,line_values,index_wave


nwave = n_elements(wavelength)
findwave = wavelength - x
findwave  = findwave*findwave
index = where(findwave eq min(findwave))
index_wave = index[0]


imiddle = index[0]
istart = imiddle -1
iend = imiddle + 1
if(istart lt 0) then begin
    iend = iend + abs(istart)
    istart = 0
    if(iend ge nwave) then iend = nwave-1
endif

if(iend ge nwave) then begin
    addon = nwave - iend
    istart = istart - addon
    iend = nwave-1
    if(istart lt 0) then istart  = 0
endif

wave = wavelength[istart:iend]
flux = spectrum[istart:iend]
err = error[istart:iend]
n = n_elements(wave)


yflux = 0
weight = 0
errvalue = 0

for i = 0,n -1 do begin
    distance = (abs( x - wave[i]))/wave[i]
    if(distance eq 0) then distance = 1
    yflux= yflux + flux[i]/distance
    weight = weight + 1/distance
    errvalue = errvalue + (err[i]* err[i])/distance
endfor

yflux = yflux/weight
err = err/weight
errvalue = sqrt(errvalue)

line_values[0] = x
line_values[1] = yflux
line_values[2] = errvalue


wave = 0 & flux = 0  & err = 0

end
