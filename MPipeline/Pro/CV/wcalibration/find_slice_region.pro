pro find_slice_region,cheader,channel,sliceno, slice_region,verbose = verbose

do_verbose = 0
if keyword_set(verbose) then do_verbose = 1

sxmin = 'XMN'
sxmax = 'XMX' 

sch = string(channel)
for i = 1, sliceno do begin
    sslice = string(fix(i))
    smn = sxmin + '_'+sch+'_'+sslice
    smx = sxmax + '_'+sch+'_'+sslice
    smn = strcompress(smn,/remove_all)
    smx = strcompress(smx,/remove_all)

    xmin =  fxpar(cheader,smn,count=count)
    if(count eq 0) then begin
        print,smn,' Not found in Calibration Header'
        stop
    endif
    xmax =  fxpar(cheader,smx,count=count)
    if(count eq 0) then begin
        print,smx,' Not found in Calibration Header'
        stop
    endif
    slice_region[0,i-1] = xmin
    slice_region[1,i-1] = xmax
    print,smn, ' ',xmin,'  ', smx, ' ',xmax
endfor


end
