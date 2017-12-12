@wcal_read_inputs.pro
@read_cube.pro
@cv_read_calibration_file.pro
@cv_find_xrange_channel.pro
@skycube2detector.pro
@wcal_fit.pro
@color6.pro

pro wcal

COMMON FUNC_DATA, x,y,lamba

color6
input_file = 'wcal.input'
wcal_read_inputs,input_file,cubefile_a,cubefile_b,d2cfile_in,d2cfile_out,status

Rfailed = fltarr(5)

close,12
openw,12,'wcal_fit_test.txt'

close,11
openw,11, 'wcal.log'

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
;print,'Xrange of calibration file', xrange 
;_______________________________________________________________________
; Loop over cube pixels - with in a slice 

minpoints = cube.naxis3*0.25

middle = fix(cube.naxis1/2.0)

printf,12,cube.naxis2,cube.naxis1

for irow = 0,cube.naxis2 -1 do begin ; naxis2 is across slices (irow = constant = same slice no)
;for irow = 1,cube.naxis2 -1 do begin ; naxis2 is across slices (irow = constant = same slice no)
    nslice = long(cube.naxis3)* long(cube.naxis1)
    xfinal = fltarr(nslice)
    yfinal = fltarr(nslice)
    lfinal = fltarr(nslice)
    xmin_final = 10000
    xmax_final = -10000
    
    in = long(0)


    for icol = 0,cube.naxis1 -1 do begin
        npoints = long(cube.naxis3) 
        xx = fltarr(npoints)
        yy = fltarr(npoints)
        llamba = fltarr(npoints)
        lamba_diff = fltarr(npoints)
        idiff = long(0)

        ip = long(0)

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
            
                ; skycube2detector
                if(xdet lt 0 or xdet gt 1032 or ydet lt 0 or ydet gt 1024) then status = 2

                if(status eq 0) then begin
                    xx[ip] = xdet - 0.5
                    yy[ip ] =  ydet - 0.5

                    llamba[ip] = wavelength
                    xcheck = fix(xdet-0.5)
                    ycheck = fix(ydet-0.5)
                    lamba_check = (*calibration.pwavelength)[xcheck,ycheck]

                    if(lamba_check ne 0) then begin 
                        lamba_diff[idiff] = abs(wavelength - lamba_check)
                        idiff = long(idiff) + long(1)
                        
                        if(idiff lt -120) then begin 
                            print,'Cube pixel ',ip,xcube,ycube,zcube
                            print,alpha,beta,wavelength
                            print,' X,Y detector', xdet-0.5,ydet-0.5,wavelength
                            print,xcheck,ycheck,lamba_check,abs(wavelength - lamba_check)
                            print,'************************************'
                        endif
                        
                    endif

                    ip = long(ip) + long(1)
                endif
            endif
        endfor

        print,' Number of ip points',ip,minpoints

            
        if(ip le minpoints) then  printf,12,format='(i3,i3,i3,1x,5f12.6,1x, 6(e11.4,2x))',$
          irow,icol,0,0.0,0.0,0.0,0.0,0.0,Rfailed
      
        if(ip gt minpoints) then begin 
            print,' Col, row ',icol+1,irow + 1
            printf,11,'Col Row',icol+1,irow+1
            if(idiff gt 0) then begin 
                lamba_dif = fltarr(idiff)
                lamba_dif = lamba_diff[0:idiff-1]
                mean_diff = mean (lamba_dif)
                stdev_diff = stddev(lamba_dif)
                print,'Lamba check (rough)  mean, stdev,max',mean_diff,stdev_diff,max(lamba_dif)
                printf,11,'Lamba check  mean, stdev,max',mean_diff,stdev_diff,max(lamba_dif)

                lamba_diff = 0 
            endif

            x = fltarr(ip)
            y = fltarr(ip)
            lamba = fltarr(ip)

            x = xx[0:ip-1]
            y = yy[0:ip-1]
            lamba = llamba[0:ip-1]
            ;xx = 0 & yy = 0 & llamba = 0

            set_plot,'x'
            window,2,xsize=400,ysize=1024
            st = ' Slice ' + strcompress(string(irow+1),/remove_all) +  $ 
                 ' Column ' + strcompress(string(icol+1),/remove_all)




            xmin = min(x)
            xmax = max(x)
            xr = xmax - xmin + 2
            if(xmin lt xmin_final) then  xmin_final = xmin
            if(xmax gt xmax_final) then xmax_final = xmax
            
            plot,x,y,psym=3,yrange =[-100,1100],ystyle=1,title = st,xrange = [xmin-1,xmax+1],xstyle=1

            ymid = (max(y) - min(y))/2.0
            diff = abs(y - ymid)
            index = where(diff eq min(diff))

            xmiddle = x[index[0]]
            ymiddle = y[index[0]]
            wmiddle = lamba[index[0]]

            xplot= fltarr(1) & yplot = fltarr(1)
            xplot[0] = xmiddle & yplot[0] = ymiddle
            oplot,xplot,yplot,color= 2, psym = 6

            x = x - xmiddle
            y = y - ymiddle

            print,' Middle value',xmiddle,ymiddle

            lamba = lamba - wmiddle

            xmax2 = max(x) 
            set_plot,'x' 
            window,1,xsize=400,ysize=1024
            plot,x,y,psym=3,yrange =[-600,600],ystyle=1,title = ' Subtracted ' + st, $
                 xrange = [xmax2-xr, xmax2+1],xstyle = 1
            
            scale = (max(lamba) - min(lamba))/( max(y) - min(y))
            print,'scale',scale
            printf,11,'scale',scale
;_______________________________________________________________________

            fit1 = 1
            C = dblarr(5)
            CRANGE = dblarr(5)
            C = [0.0,scale,0.007,0.0,0.0]
            CRANGE = [1.e-4,$
                      1.e-4,$
                      1.e-4,$
                      1.e-6,$
                      1.e-6]

            R = amoeba(1.0e-5, scale= CRANGE, P0 = C,$
                       function_value = fval, function_name = 'par_fity',$
                       NCALLS = nums, NMAX = 50000)


            

            if(n_elements(R) eq 1) then begin
                print,' First Fit failed, trying second fit'
                fit1 = 0

                C = dblarr(4)
                CRANGE = dblarr(4)
                C = [0.0,scale,0.007,0.0]
                CRANGE = [1.e-4,$
                          1.e-4,$
                          1.e-4,$
                          1.e-4]

                R = amoeba(1.0e-5, scale= CRANGE, P0 = C,$
                           function_value = fval, function_name = 'par_fit2',$
                           NCALLS = nums, NMAX = 50000)


                
                if(n_elements(R) eq 1) then begin
                    print,' Higher order failed- stopping'
                    printf,12,format='(i3,i3,i3,1x,5f12.6,1x 6(e11.4,2x))',$
                           irow,icol,0,0.0,0.0,0.0,0.0,0.0,Rfailed
                endif else begin 

                    print,R
                    result_par_fit2,x,y,R,result
                    lamba_diff = lamba - result
                    mean_lamba_diff = mean(abs(lamba_diff))
                    stdev_lamba_diff= stddev(abs(lamba_diff)) 
                    max_lamba_diff = max(abs(lamba_diff))
                    print,' Test 2: Mean Abs(lamba_diff) ',mean_lamba_diff
                    print,' Test 2: Stdev abs(lamba_diff)',stdev_lamba_diff
                    print,' Test 2: Max lamba_diff', max_lamba_diff
                    
                    printf,11,' Test 2: Mean Abs(lamba_diff) ',mean_lamba_diff
                    printf,11,' Test 2: Stdev abs(lamba_diff)',stdev_lamba_diff
                    printf,11,' Test 2: Max lamba_diff', max_lamba_diff
                endelse

;_______________________________________________________________________
                
            endif else begin
                print,R
                print,' Number of calls',nums
                result_par_fity,x,y,R,result
                lamba_diff = lamba - result
                mean_lamba_diff = mean(abs(lamba_diff))
                stdev_lamba_diff= stddev(abs(lamba_diff)) 
                max_lamba_diff = max(abs(lamba_diff))

                print,'Test 1: Mean Abs(lamba_diff) ',mean_lamba_diff
                print,'Test 1:  Stdev abs(lamba_diff)',stdev_lamba_diff
                print,'Test 1:  Max lamba_diff', max_lamba_diff

                printf,11,'Test 1: Mean Abs(lamba_diff) ',mean_lamba_diff
                printf,11,'Test 1:  Stdev abs(lamba_diff)',stdev_lamba_diff
                printf,11,'Test 1:  Max lamba_diff', max_lamba_diff
            endelse
            nfit = n_elements(R)
            
            printf,12,format='(i3,i3,i3,1x,5f12.6,1x, 6(e11.4,2x))',$
                   irow,icol,nfit,xmin,xmax,xmiddle,ymiddle,wmiddle,R
;_______________________________________________________________________
;_______________________________________________________________________
; Plot results
            
            mlamba = strcompress(string(mean_lamba_diff),/remove_all)
            slamba = strcompress(string(stdev_lamba_diff),/remove_all)
            xlamba = strcompress(string(max_lamba_diff),/remove_all)

            num = n_elements(lamba)
            scale_plot = 500000.0
            for k = 0,num - 1 ,2 do begin
                xplot = fltarr(2) & yplot = fltarr(2)
                xplot[*] = x[k]
                yplot[0] = y[k]
                yplot[1]  = yplot[0] + lamba_diff[k]* scale_plot
                oplot,xplot,yplot,color=2

                xfinal[in] = xx[k]
                yfinal[in] = yy[k]
                lfinal[in] = lamba_diff[k]
                in = long(in) + long(1)                
                
            endfor

            xscale = fltarr(2)
            yscale = fltarr(2)
            xscale[*] = -1
            yscale[0] = -480
            yscale[1] =  yscale[0] + (.0001 * scale_plot)
            oplot,xscale,yscale,color= 4
            xyouts,-1,-490,'0.0001 microns',alignment=0.5
            xyouts,-6,50,'Mean abs diff '+ mlamba
            xyouts,-6,0,'Stdev         ' +slamba
            xyouts,-6,-50,'Max abs diff  '+ xlamba
;_______________________________________________________________________
            set_plot,'ps' 
            filename = 'PolyResult_' + strcompress(string(icol+1),/remove_all) +$
                       '_' + strcompress(string(irow+1),/remove_all) + '.ps'
            device,file=filename,/color,/inches,ysize= 10,xsize=4,/encapsulated
            plot,x,y,psym=3,yrange =[-600,600],ystyle=1,title = ' Subtracted ' + st, $
                 xrange = [xmax2-xr, xmax2+1],xstyle = 1
            

            for k = 0,num - 1 ,2 do begin
                xplot = fltarr(2) & yplot = fltarr(2)
                xplot[*] = x[k]
                yplot[0] = y[k]
                yplot[1]  = yplot[0] + lamba_diff[k]* scale_plot
                oplot,xplot,yplot,color=2
            endfor
            oplot,xscale,yscale,color= 4
            xyouts,-1,-490,'0.0001 microns',alignment=0.5
            xyouts,-6,50,'Mean abs diff '+mlamba
            xyouts,-6,0,'Stdev         '+slamba
            xyouts,-6,-50,'Max abs diff  '+xlamba
            device,/close

        
        
        endif; have to have points in column and slice
;_______________________________________________________________________
    endfor



    set_plot,'x'
    window,3,xsize=400,ysize=1024
    xplot = fltarr(1) & yplot = fltarr(1)
    plot,xplot,yplot,/nodata,yrange = [-100,1100],xrange = [xmin_final,xmax_final],$
         xstyle = 1, ystyle =1

    scale_plot = 50000.0    
    for k = long(0),long(in) - 1 ,2 do begin
        xplot = fltarr(2) & yplot = fltarr(2)
        xplot[*] = xfinal[k]
        yplot[0] = yfinal[k]
        yplot[1]  = yplot[0] + lfinal[k]* scale_plot
        oplot,xplot,yplot,color=2

        xscale = fltarr(2)
        yscale = fltarr(2)
        xscale[*] = xmin_final+1
        yscale[0] = -50
        yscale[1] =  yscale[0] + (.0001 * scale_plot)
        oplot,xscale,yscale,color= 4
        xyouts,xmin_final+1,-60,'0.0001 microns',alignment=0.5                
    endfor


endfor

close,11                 
close,12                 
end
