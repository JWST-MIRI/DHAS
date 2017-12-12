@wcal_read_inputs.pro
@read_cube.pro
@cv_read_calibration_file.pro
@cv_find_xrange_channel.pro
@skycube2detector.pro
@color6.pro

pro wcal_view


color6
input_file = 'wcal.input'
wcal_read_inputs,input_file,cubefile_a,cubefile_b,d2cfile_in,d2cfile_out,status


@cube_structs ; hold cube structures

status = 0
file_exist1 = file_test(cubefile_a,/regular,/read)
if(file_exist1 ne 1 ) then begin
    result = dialog_message(" The input cube does not exist "+ cubefile_a,/error )
    retall
endif

; create and initialize "cube" structure
cube = {cubei}
cube.istart_wavelength = 0
cube.testmodel = -1

calibration = {calibration_datai}
calibration_out = {calibration_datai}

read_cube,cubefile_a,cube,status,error_message
print,'read cube ',status,error_message
if(status eq 1) then begin
    result = dialog_message(error_message,/error)
    stop
endif


cv_read_calibration_file,d2cfile_in,alpha,lamba,sliceno,status,error_message
if(status ne 0) then begin
    print, error_message
    stop
endif


if ptr_valid(calibration.palpha) then ptr_free,calibration.palpha
calibration.palpha = ptr_new(alpha)
                            
if ptr_valid(calibration.pwavelength) then ptr_free,calibration.pwavelength
calibration.pwavelength = ptr_new(lamba)
    
if ptr_valid(calibration.psliceno) then ptr_free,calibration.psliceno
calibration.psliceno = ptr_new(sliceno)
    
lamba_out = lamba
lamba_out[*,*] = 0


calibration.filename = d2cfile_in
alpha = 0
sliceno = 0
lamba = 0

x = fltarr(1033,1025)
y = x
; x and y values first pixel 0 to 1. 
for i = 0,1032 do begin
    x[i,*] = i 
endfor
for i = 0,1024 do begin
    y[*,i] = i
endfor

if ptr_valid(calibration.px) then ptr_free,calibration.px
calibration.px = ptr_new(x)
if ptr_valid(calibration.py) then ptr_free,calibration.py
calibration.py = ptr_new(y)
x = 0
y = 0

cv_find_xrange_channel,cube.channel,d2cfile_in,xrange
calibration.xrange = xrange

minpoints = cube.naxis3*0.75

middle = fix(cube.naxis1/2.0)

for irow = 0,cube.naxis2 -1 do begin ; naxis2 is across slices (irow = constant = same slice no)

    npoints = long(cube.naxis3) 
    xx = fltarr(cube.naxis1,npoints)
    yy = fltarr(cube.naxis1,npoints)
    llamba = fltarr(cube.naxis1,npoints)
    num = lonarr(cube.naxis1)

    xmin = 10000.0 & xmax = -10000.0
    for icol = 0,cube.naxis1 -1 do begin
        ip = long(0)
        print,'Working on row and col',irow,icol,cube.naxis1

        for iwave = 0,cube.naxis3 -1 do begin
            xcube = icol
            ycube = irow
            zcube = iwave
            if( finite ((*cube.pcubedata)[xcube,ycube,zcube]) eq 1) then begin  
                beta = (*cube.pbeta)[ycube]
                alpha = (*cube.palpha)[xcube]
                wavelength = (*cube.pwavelength)[zcube]
                xdet = 0 & ydet = 0 & status = 0

                skycube2detector,calibration,cube.channel,alpha,wavelength,ycube+1,xdet,ydet,status;,/verbose
            
                if(xdet lt 0 or xdet gt 1032 or ydet lt 0 or ydet gt 1024) then status = 2

                if(status eq 0) then begin
                    xx[icol,ip] = xdet - 0.5
                    yy[icol,ip ] =  ydet - 0.5

                    llamba[icol,ip] = wavelength
                    if( xdet lt xmin) then xmin = xdet
                    if( xdet gt xmax) then xmax = xdet

                    ip = long(ip) + long(1)
                endif
            endif
        endfor
        num[icol] = ip
    endfor

    ic = 1

    st = ' Slice ' + strcompress(string(irow+1),/remove_all)
    x = fltarr(1) & y = fltarr(1) 
    set_plot,'x'
    window,2,xsize=400,ysize=1024
    plot,x,y,psym=3,yrange =[-100,1100],ystyle=1,xrange = [xmin-2,xmax+2],xstyle=1,/nodata,title = st

    yloc = -15    
    for icol = 0,cube.naxis1 -1 do begin
       
        if(num[icol] gt 0 ) then begin 
            print,' on col, row ',icol,irow,num[icol]
            ip = num[icol]
            x = fltarr(ip)
            y = fltarr(ip)
            lamba = fltarr(ip)

            x = xx[icol,0:ip-1]
            y = yy[icol,0:ip-1]
            lamba = llamba[icol,0:ip-1]
            scale = (max(lamba) - min(lamba))/( max(y) - min(y))
            print,'scale',scale

            oplot,x,y, color = ic,psym = 1,symsize = 0.2

            ic = ic + 1
            if(ic gt 5) then ic = 1
            midpt = ip/2
            xmiddle = x[midpt]
            ymiddle = y[midpt]
            wmiddle = lamba[midpt]

            xplot= fltarr(1) & yplot = fltarr(1)
            xplot[0] = xmiddle & yplot[0] = ymiddle
            oplot,xplot,yplot,color= 2, psym = 6
            sc = strcompress(string(icol+1),/remove_all)
            x0 = min(x)
            print,'x 0',x[0],x0
            xyouts,x0,yloc,sc,charsize=0.5,alignment = 0.5
            yloc = yloc - 15
            if(yloc lt -40) then yloc = -15
            
        endif; have to have points in column and slice
    endfor


    set_plot,'ps'
    filename = 'Cube_Slices_on_Detector_' + strcompress(string(irow+1),/remove_all) + '.ps'
    device,file=filename,/color,/inches,ysize= 10,xsize=4,/encapsulated
    plot,x,y,psym=3,yrange =[-100,1100],ystyle=1,xrange = [xmin-2,xmax+2],xstyle=1,/nodata,title = st
    ic = 1
    yloc = -15
    for icol = 0,cube.naxis1 -1 do begin

        if(num[icol] gt 0 ) then begin 
            print,' on col, row ',icol,irow,num[icol]
            ip = num[icol]
            x = fltarr(ip)
            y = fltarr(ip)
            lamba = fltarr(ip)

            x = xx[icol,0:ip-1]
            y = yy[icol,0:ip-1]

            oplot,x,y,psym = 1, symsize = 0.2

            midpt = ip/2
            xmiddle = x[midpt]
            ymiddle = y[midpt]
            wmiddle = lamba[midpt]

            xplot= fltarr(1) & yplot = fltarr(1)
            xplot[0] = xmiddle & yplot[0] = ymiddle
            oplot,xplot,yplot,color= 2, psym = 6
            sc = strcompress(string(icol+1),/remove_all)

            x0 = min(x)
            xyouts,x0,yloc,sc,charsize=0.5,alignment = 0.5
            yloc = yloc - 15
            if(yloc lt -40) then yloc = -15

        endif; have to have points in column and slice
    endfor

    device,/close

endfor
                 
end
