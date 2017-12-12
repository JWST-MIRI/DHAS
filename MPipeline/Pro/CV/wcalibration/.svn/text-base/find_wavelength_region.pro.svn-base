
pro    find_wavelength_region,slope_slice,sliceno,region,nregions,xstart,$
  alpha,beta,lamba,cube,new_wave,peaks,lun,lun_full,lun_fail,waittime,verbose=verbose

COMMON FUNC_DATA, xdet,ydet

do_verbose = 0
if keyword_set(verbose) then do_verbose = 1
color6
col_max =  min([!d.n_colors, 255])
col_bits = 6
loadct,3
expand = 20
no_value = -9999.90
no_wave = -9.9

lamba_peak = fltarr(nregions) 

; _______________________________________________________________________
; Loop over region - number of lines in slice
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
    limit = mean(slope_region,/nan) + stddev(slope_region,/nan)
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
;_______________________________________________________________________
; march across line finding peaks in each col

    peak_fail = 0
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
            yfit = gaussfit(xs,col,coeff,nterms = 3,chisq=chisq)
            
;-----------------------------------------------------------------------
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; verbose = true then plot fitting window

            if(do_verbose eq 1) then begin 
                window, 3,xpos = 500
                sc = 'Chisq = ' + strcompress(string(chisq),/remove_all)
                ir = '  Slice= ' + strcompress(string(sliceno),/remove_all)  +$
                     '  Region = ' + strcompress(string(i+1),/remove_all) +$
                     '  Col    = ' + strcompress(string(k+1),/remove_all)
                plot,xs,col,xtitle = 'x pixel  detector', ytitle = ' Flux in column',$
                     title = ' Peak Flux for Column' + ir,$
                     subtitle = sc
                oplot,xs,yfit,color = 2,linestyle = 3
                wait,waittime
            endif
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++            
;-----------------------------------------------------------------------

; error peak of column not found
            if(chisq gt 1 or finite(chisq) eq 0 ) then begin
                print,'************************************'
                print,' high Chisq- Peak Fit Failed', chisq
                print,'************************************'
                xyouts, xs[0],col[0],' PEAK FIT FAILED',charsize= 4.0
	        xfail = fltarr(2) & yfail = fltarr(2)
	        xfail[*] = xs[0]
	        yfail[0] = col[0]
	        yfail[1] = col[num-1]
	        plots,xfail,yfail,/device,color = 5,psym=1,thick = 2	

                printf,lun_fail,' Peak Column Fit Failure'
                printf,lun_fail,' Slice #, region ',sliceno,i+1
                printf,lun_fail,' X region',x1+1, x2+ 1
                printf,lun_fail,' Y region',y1+1, y2+ 1
                printf,lun_fail,' Column',k+1
                printf,lun_fail,'                    '
                peak_fail = 1
                wait,1
;-----------------------------------------------------------------------
;_______________________________________________________________________
; peak found continue on 

            endif else begin

                xpeak = k
                ypeak = coeff[1]
            
                xxdet[p] = xpeak + x1 + 1 ; in full image 
                yydet[p] = ypeak + y1 + 1

                if(do_verbose eq 1) then print,'xpeak ypeak', xpeak,ypeak
                if(do_verbose) then begin
                    print,' ' 
                    print,'Peak at location ',xpeak,ypeak,maxcol
                    print,' In Full slope image peak flux for line occurs at',xxdet[p],yydet[p],$
                      slope_region[xpeak,ypeak]
                endif

                p = p + 1
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
	              
                inslice = 1
                wave_old = 0.0
                wave_new = 0.0 
                weight = 0.0
;-----------------------------------------------------------------------
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

                        if(do_verbose) then begin
                            print,'cube pixel ',a+1,w+1
                            print,'alpha,lamba,beta',acorner[j],wcorner[j],bcorner[j]
                            print,' new wave', xc+1,yc+1,zc+1,cal_wave
                        endif
                        if(cal_wave gt no_value) then begin
; _______________________________________________________________________
; Find wavelength associated with peak value
;
 ;_______________________________________________________________________
                            ydiff = ypeak -y[j]
                            w = sqrt(ydiff*ydiff) 
                            wave_old = wave_old  + wcorner[j]*w
                            wave_new = wave_new + cal_wave*w
                            weight = weight + w
                        endif
                    endif
                endfor          ; endfor over 4 corners. 
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
            endelse ; peak of column found
;_______________________________________________________________________
        endif                   ; maxcol  gt limit
        
    endfor
;_______________________________________________________________________
    ; initialize to no_wave
    peaks_wave = no_wave
    avewave = no_wave
    std = no_wave

    if(nwave le 4) then begin 
        print,'*******************************************************************************'
        print,' Number of Column peaks/line < 4, no fit possible for line, Info not in saveset'
        print,'*******************************************************************************'
        printf,lun_fail,' Line Fit Failure, too few points. Info not in SaveSet'
        printf,lun_fail,' # Peaks found',nwave
        printf,lun_fail,' Slice #, region ',sliceno,i+1
        printf,lun_fail,' X region',x1+1, x2+ 1
        printf,lun_fail,' Y region',y1+1, y2+ 1
        printf,lun_fail,'                    '
;        wait,1
    endif else begin 
        avewave = mean(wave[0:nwave-1])
        std = stddev(wave[0:nwave-1])
        ; call routine to find closest value in peaks file
        distance = abs(avewave - peaks)
        dist = where(min(distance) eq distance)
        peaks_wave = peaks[dist[0]]    
;***********************************************************************
; do the poly fit for each line 
;***********************************************************************

   ;     print,'Average wavelength, std (calculated), peaks wave', avewave,std,peaks_wave

        xdet = xxdet[0:p-1]
        ydet = yydet[0:p-1]

;_______________________________________________________________________
;    do fit - setting all wavelength = same wavelenth
; just corner values
;_______________________________________________________________________
        result = poly_fit(xdet,ydet,2,chisq=chisq, sigma=sigma,status = status)

        if(status ne 0) then begin
            print,' Fit Failed for region',sliceno,i+1
            print,' X region',x1+1, x2+ 1
            print,' Y region',y1+1, y2+ 1
            print,' Lamba',avewave

            printf,lun_fail,' Line Fit Failure'
            printf,lun_fail,' # Peaks found',nwave
            printf,lun_fail,' Slice #, region ',sliceno,i+1
            printf,lun_fail,' X region',x1+1, x2+ 1
            printf,lun_fail,' Y region',y1+1, y2+ 1
            printf,lun_fail,'                    '
            stop
        endif else begin 
            yfit = result[0] + result[1]*xdet + result[2]*xdet*xdet
            ydiff = ydet - yfit 
            mean_diff = mean(abs(ydiff))
            stdev_diff= stddev(abs(ydiff)) 
            max_diff = max(abs(ydiff))
            print,'Result diff: mean,stdev,max',mean_diff,stdev_diff,max_diff
        
            printf,lun_full,'Slice #, region ',sliceno,i+1
            printf,lun_full,' X region',x1+1, x2+ 1
            printf,lun_full,' Y region',y1+1, y2+ 1
            
            printf,lun_full,' Lamba',peaks_wave, avewave
            printf,lun_full,' N Points used for fit',p
            printf,lun_full,' Result',Result[0],Result[1],Result[2]
            printf,lun_full,' Chisq',chisq
            printf,lun_full,' Sigma Fit',sigma[0],sigma[1],sigma[2]
        
            printf,lun_full,' Result Stats (mean,std,max)', mean_diff,stdev_diff,max_diff
            printf,lun_full,'  '

            printf,lun, format = '(2(i4,1x),4(i5,1x),f9.5,1x,f9.5,1x,3(f14.8),1x,4(f14.8)  )',$
                   sliceno,i+1,x1+1, x2+ 1,y1+1, y2+ 1,avewave,peaks_wave,$
                   Result[0],Result[1],Result[2],$
                   chisq,sigma[0],sigma[1],sigma[2]
        
            wset,0
            xplot = (xdet - x1 -1) * expand + (expand/2)
            yplot =  (yfit - y1 - 1)* expand + (expand/2) 
            plots,xplot,yplot,/device,color = 3,linestyle = 3,thick = 2
            wait,waittime 
            if(peak_fail eq 1) then wait, 5
        endelse
    endelse; there are enough points in line to do the fit 
;_______________________________________________________________________
; end looping over regions
;_______________________________________________________________________


endfor

;print,'exiting find_wavelength_region'

end

