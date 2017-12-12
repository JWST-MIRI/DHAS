@wfit.pro

pro    find_wavelength_region,slope_slice,sliceno,region,nregions,xstart,$
  alpha,beta,lamba,cube,new_wave,verbose=verbose

COMMON FUNC_DATA, xdet,ydet

do_verbose = 0
if keyword_set(verbose) then do_verbose = 1
color6
col_max =  min([!d.n_colors, 255])
col_bits = 6
loadct,3
expand = 20
no_value = -9999.90
cubedata = (*cube.pcubedata)
lamba_peak = fltarr(nregions) 
lamba_det = fltarr(nregions) 
; _______________________________________________________________________
; Loop over region
; _______________________________________________________________________
for i = 0,nregions -1 do begin
    print,' slice, region',sliceno,i+1
    x1 = region[0,i] -1
    x2 = region[1,i] -1
    y1 = region[2,i] -1
    y2 = region[3,i] -1

    kstart = region[0,i] - xstart
    kend = region[1,i] -xstart 
    yregion_min = region[2,i] -1 
    yregion_max = region[3,i] -1 

    wset,2
    lexpand = 4
    xcorner = [kstart*lexpand,kend*lexpand,kend*lexpand,kstart*lexpand,kstart*lexpand]
    ycorner = [yregion_min-1,yregion_min-1,yregion_max-1,yregion_max-1,yregion_min-1]

    plots,xcorner,ycorner,/device,color = 4,psym=0

    xm = (x2 - x1)/2
    sx = (x2 - x1)+1
    sy = (y2 - y1) + 1
    slope_region = slope_slice[kstart:kend,y1:y2]
    limit = mean(slope_region) + stddev(slope_region)
    print,'Location of region',x1,x2,y1,y2

    xxdet = fltarr(sx) & yydet = fltarr(sx) 
; display region 
;_______________________________________________________________________

    sxE = sx*expand
    syE = sy*expand

    disp_image = congrid(slope_region,sxE,syE)
    in = where(finite(slope_region),npixels)
    image_min = min(slope_region[in])
    image_max = max(slope_region[in])
    
    window,3,/pixmap,xsize=sxE,ysize=syE,/free
    window,3,/pixmap,xsize=sxE,ysize =syE
    pixmapID= !D.WINDOW
    disp_image = bytscl(disp_image,min=image_min, $
                        max=image_max,$
                        top= col_max-col_bits-1,/nan)

    print,'min and max of image',image_min,image_max
    tv,disp_image,0,0,/device
    window,0, xsize = sxE,ysize = syE,xpos = 150,ypos = 600
    device,copy=[0,0,sxE,syE,0,0,pixmapID]
    color6
	
    wave = fltarr(sx)
    nwave  = 0
    p = 0  ; counter on if peak value found in column

    for k = 0, sx -1 do begin
        col = slope_region[k,*]

        maxcol = max(col)
;_______________________________________________________________________
; Brighter than limit
; check that the max value in the column is above a limit - this is to 
; get rid of noisy data on edges.

        if(maxcol gt limit) then begin
	
            ss = size(col)
            xs = findgen(ss[2])
            num = n_elements(xs) 
;
; fit a gaussian to data to find peak
;
            yfit = gaussfit(xs,col,coeff,nterms = 3)
            if(do_verbose eq 1) then begin 
                window, 3,xpos = 500
                plot,xs,col
                oplot,xs,yfit,color = 2,linestyle = 3
                wait,0
            endif
            xpeak = k
            ypeak = coeff[1]
            
            xxdet[k] = xpeak
            yydet[k] = ypeak
            p = p + 1
            if(do_verbose eq 1) then print,'xpeak ypeak', xpeak,ypeak
            xfull = xpeak + x1 +1
            yfull = ypeak + y1 + 1
            if(do_verbose) then begin
                print,' ' 
                print,'Peak at location ',xpeak,ypeak,maxcol
                print,' In Full slope image peak flux for line occurs at',xfull,yfull,slope_region[xpeak,ypeak]
            endif

            x = intarr(4) & y = intarr(4)
            acorner = fltarr(4) & wcorner = fltarr(4) & bcorner = fltarr(4) 

	   ; corners of the peak pixel 
            x[0] = xpeak +x1
            y[0] = ypeak +y1
            x[1] = x[0] + 1
            y[1] = y[0]
            x[2] = x[1]
            y[2] = y[1] +1
            x[3] = x[0]
            y[3] = y[2]
	
	    ;print,xpeak,x1,x[0],x[1],x[2],x[3]
	    ;print,ypeak,y1,y[0],y[1],y[2],y[3]
	              
            inslice = 1

            wave_old = 0.0
            wave_new = 0.0 
	    weight = 0.0
;_______________________________________________________________________
	; for peak pixel find the alpha, beta and wavelength from the D2c files
	

            for j = 0, 3 do begin
                acorner[j] = alpha[x[j],y[j]]
                wcorner[j] = lamba[x[j],y[j]]
                bcorner[j] = beta[x[j],y[j]]
                if(bcorner[j] ne sliceno) then inslice = 0
                ; not in slice 
                if(inslice eq 1 ) then begin
;_______________________________________________________________________ 
; convert acorner and wcorner to cube values
;_______________________________________________________________________ 

                    a = (acorner[j] - cube.crval1)/cube.cdelt1
                    w = (wcorner[j] - cube.crval3)/cube.cdelt3

;_______________________________________________________________________ 
; find xc, yc, zc - cube pixel values.
; Then use NEW WAVELENGTH cube to find new WAVELENGTH
;_______________________________________________________________________ 

                    xc = fix(a)
                    yc = fix(sliceno-1)
                    zc = fix(w)

                    cal_wave = new_wave[xc,yc,zc]
	            ;print,cal_wave
                    if(do_verbose) then begin
                        print,'cube pixel ',a+1,w+1
                        print,'alpha,lamba,beta',acorner[j],wcorner[j],bcorner[j]
                        print,' new wave', xc+1,yc+1,zc+1,cal_wave
                    endif
                    if(cal_wave gt no_value) then begin
; _______________________________________________________________________
; Find wavelength associated with peak value
; _______________________________________________________________________
	              ydiff = ypeak -y[j]
	              w = sqrt(ydiff*ydiff) 
                      wave_old = wave_old  + wcorner[j]*w
                      wave_new = wave_new + cal_wave*w
	              weight = weight + w
	              ;print,'weight',w,ypeak,y[j]

                    endif
                endif
            endfor ; endfor over 4 corners. 
            if(weight gt 0) then begin
                wave_old = wave_old/weight
                wave_new = wave_new/weight
                if(do_verbose) then print,' Old Wave, New Wave',wave_old,wave_new
	        wave[nwave] = wave_new

	        nwave = nwave + 1

            endif
;_______________________________________________________________________            
; plot location of peak value found
;_______________________________________________________________________            

            if(inslice eq 1) then begin 
                xpeak_image = fltarr(1) & ypeak_image = fltarr(1) 
                xpeak_image[0] = xpeak*expand + (expand/2) 
                ypeak_image[0] = ypeak*expand + (expand/2) 
                wset,0
                plots,xpeak_image,ypeak_image,/device,color = 4,psym=1,thick = 2
            endif
            
        endif; maxcol  gt limit


    endfor
    if(nwave gt 2) then begin	
	avewave = mean(wave[0:nwave-1])
	std = stddev(wave[0:nwave-1])
	print,'Average wavelength, std', avewave,std
        llamba_det[i] = avewave
        ; call routine to find closest value in peaks file

    endif	
    wait,0   
    
    
;_______________________________________________________________________
;    do fit - setting all wavelength = same wavelenth
; just for peak values
;_______________________________________________________________________
    result_fail = 1
    xdet = xxdet[0:p-1]
    ydet = yydet[0:p-1]
    lamba_det = llamba_det[i]
;_______________________________________________________________________
;    do fit - setting all wavelength = same wavelenth
; just corner values
;_______________________________________________________________________

 
    print,'Number of points',p
    C = dblarr(6)
    CRANGE = dblarr(6)
    C = [0.0,1.0,0.00,0.0,0.0,0.0]
    CRANGE = [1.e-5,$
              1.e-5,$
              1.e-5,$
              1.e-5,$
              1.e-6,$
              1.e-6]


    R = amoeba(1.0e-12, scale= CRANGE, P0 = C,$
               function_value = fval, function_name = 'wfit',$
               NCALLS = nums, NMAX = 50000)

;    C = dblarr(4)
;    CRANGE = dblarr(4)
;    C = [0.0,1.0,0.00,0.0]
;    CRANGE = [1.e-5,$
;              1.e-5,$
;              1.e-6,$
;              1.e-6]
;    R = amoeba(1.0e-12, scale= CRANGE, P0 = C,$
;               function_value = fval, function_name = 'par_fit2',$
;               NCALLS = nums, NMAX = 50000)

;
 ;_______________________________________________________________________
; First fit failed trying second fit

    if(n_elements(R) eq 1) then begin
        print,' First Fit failed, trying second fit'

        C = dblarr(5)
        CRANGE = dblarr(5)
        C = [0.0,1.0,0.00,0.0,0.0]
        CRANGE = [1.e-5,$
                  1.e-5,$
                  1.e-5,$
                  1.e-6,$
                  1.e-6]


        R = amoeba(1.0e-12, scale= CRANGE, P0 = C,$
                   function_value = fval, function_name = 'par_fity',$
                   NCALLS = nums, NMAX = 50000)
 ;_______________________________________________________________________
; second  fit failed trying third  fit
        if(n_elements(R) eq 1) then begin

            print,' Second attempt failed'
            C = dblarr(3)
            CRANGE = dblarr(3)
            C = [0.0,1.0,0.00]
            CRANGE = [1.e-5,$
                      1.e-5,$
                      1.e-5]

            R = amoeba(1.0e-12, scale= CRANGE, P0 = C,$
                       function_value = fval, function_name = 'par_fit',$
                       NCALLS = nums, NMAX = 50000)
 ;_______________________________________________________________________
            if(n_elements(R) eq 1) then begin
                print,' Third attempt failed'
            endif else begin
;_______________________________________________________________________
; result of third fit
;_______________________________________________________________________
                result_fail = 0
                result_par_fit,xdet,ydet,R,result
                lamba_diff = lamba_det - result
                mean_lamba_diff = mean(abs(lamba_diff))
                stdev_lamba_diff= stddev(abs(lamba_diff)) 
                max_lamba_diff = max(abs(lamba_diff))
                print,'Lamba diff: mean,stdev,max',mean_lamba_diff,stdev_lamba_diff,max_lamba_diff
            endelse
;_______________________________________________________________________
; result of second fit
;_______________________________________________________________________
        endif else begin
            result_fail = 0
            result_par_fity,xdet,ydet,R,result
            lamba_diff = lamba_det - result
            mean_lamba_diff = mean(abs(lamba_diff))
            stdev_lamba_diff= stddev(abs(lamba_diff)) 
            max_lamba_diff = max(abs(lamba_diff))
            print,'Lamba diff: mean,stdev,max',mean_lamba_diff,stdev_lamba_diff,max_lamba_diff
        endelse
    endif  else begin 
;_______________________________________________________________________
; result of first fit
;_______________________________________________________________________
        print,R
        result_fail = 0
;        result_par_fit2,xdet,ydet,R,result
        result_fit,xdet,ydet,R,result
        lamba_diff = lamba_det - result
        mean_lamba_diff = mean(abs(lamba_diff))
        stdev_lamba_diff= stddev(abs(lamba_diff)) 
        max_lamba_diff = max(abs(lamba_diff))
        print,'Lamba diff: mean,stdev,max',mean_lamba_diff,stdev_lamba_diff,max_lamba_diff
    endelse


    printf,10,'Slice #, region ',sliceno,i+1
    printf,10,' X region',x1+1, x2+ 1
    printf,10,' Y region',y1+1, y2+ 1
    if(result_fail eq 0) then begin 
        printf,10,' Lamba',avewave
        printf,10,' Result',R
        printf,10,' Result Stats (mean,std,max)', mean_lamba_diff,stdev_lamba_diff,max_lamba_diff
        printf,10,'  '
	;if(mean_lamba_diff gt .05) then stop
    endif else begin
        
        printf,10,' Lamba',avewave
        printf,10,' Fit Failed'
        printf,10,'  '
    endelse
;if(i eq 1) then stop

;_______________________________________________________________________
; end looping over regions
;_______________________________________________________________________
endfor

print,'exiting find_wavelength_region'
;stop
end

