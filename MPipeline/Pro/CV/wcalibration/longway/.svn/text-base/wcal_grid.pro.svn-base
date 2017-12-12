@wcal_read_inputs.pro
@read_cube.pro
@read_extract_files.pro
@cv_read_calibration_file.pro
@cv_find_xrange_channel.pro
@skycube2detector.pro
@color6.pro
@wcal_fit.pro

pro wcal_grid,verbose = verbose

do_verbose = 0
if keyword_set(verbose) then do_verbose = 1

if(do_verbose eq 1) then begin
	close,11
	openw,11,'test_wcal_grid.txt'
endif	
ignore = -9999.9
color6
input_file = 'wcal_grid.input'
wcal_read_inputs,input_file,cubefile_a,cubefile_b,d2cfile_in,d2cfile_out,status

@cube_structs ; hold cube structures

status = 0
file_exist1 = file_test(cubefile_a,/regular,/read)
if(file_exist1 ne 1 ) then begin
    result = dialog_message(" The input cube does not exist "+ cubefile_a,/error )
    retall
endif

xgrid = fltarr(1033,1025)
ygrid = fltarr(1033,1025)


for i = 0,1032 do begin
    xgrid[i,*] = i 
endfor
for i = 0,1024 do begin
    ygrid[*,i] =i 
endfor

; create and initialize "cube" structure
cube = {cubei}
cube.istart_wavelength = 0
cube.testmodel = -1

wcube = {cubei}
wcube.istart_wavelength = 0
wcube.testmodel = -1

calibration = {calibration_datai}
calibration_out = {calibration_datai}

; read_cube - reads in cube
; also calls read_cube_header  defines cube.pbeta, cube.palpha
; could also do this from cubefile_b because they have the same header
 
read_cube,cubefile_a,cube,status,error_message
if(status eq 1) then begin
    result = dialog_message(error_message,/error)
    stop
endif


read_cube,cubefile_b,wcube,status,error_message
if(status ne 1) then print,error_message
wavenew = (*wcube.pcubedata)


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


gridout = fltarr(1033,1025)

for irow = 0,cube.naxis2 -1 do begin ; naxis2 is across slices (irow = constant = same slice no)
; zero out before each slice- no bleeding over from one slice to the
 ;                            next
    grid = fltarr(1033,1025,15)
    ngrid = intarr(1033,1025)

    grid2 = fltarr(1033,1025,15)
    ngrid2 = intarr(1033,1025)

    nslice = long(cube.naxis3)* long(cube.naxis1)    
    is = long(0)
    xslice = fltarr(nslice) 
    yslice = fltarr(nslice) 
    lamba_slice = fltarr(nslice) 
    islice = fltarr(nslice)
    minlamba = 20000.0
;_______________________________________________________________________
    ; find x,y detector values for all the point in a SLICE 
    
    for icol = 0,cube.naxis1 -1 do begin
        for iwave = 0,cube.naxis3 -1 do begin   ; loop over wavelengths 
            xcube = icol
            ycube = irow
            zcube = iwave

            if(wavenew[xcube,ycube,zcube] ne ignore) then begin ; check the value in the new wavlength cube

                beta = (*cube.pbeta)[ycube]
                alpha = (*cube.palpha)[xcube]
                ;wavelength = (*cube.pwavelength)[zcube]
                wavelength = wavenew[xcube,ycube,zcube]
                xdet = 0 & ydet = 0 & status = 0
                ; map from cube to detector
                skycube2detector,calibration,cube.channel,alpha,wavelength,ycube+1,xdet,ydet,status;,/verbose

                if(xdet lt 0 or xdet gt 1032 or ydet lt 0 or ydet gt 1024) then status = 2

                if(status eq 0) then begin
                    xslice[is] = xdet -0.5  ; coordinate system starting at 0
                    yslice[is] = ydet -0.5
                    lamba_slice[is] = wavelength
                    if(lamba_slice[is] lt minlamba) then minlamba = lamba_slice[is]
                    ; store min and max x along the slice
                    xpos = fix(xdet - 0.5)
                    ypos = fix(ydet - 0.5)
                    islice[is] = icol
;	            if(xslice[is] lt 431) then begin
;	             print,' look here' ,icol,irow,iwave,alpha,beta,wavelength,xdet,ydet
;
;	            endif

	            if(do_verbose and irow lt 2) then begin
	             printf,11,icol,irow,iwave,alpha,beta,wavelength,xdet,ydet
	            endif	
                    is = long(is) + long(1)
                endif
            endif
        endfor ; looping over naxes3 - wavelength

        print,'on slice icol',irow+1,icol,is
;_______________________________________________________________________
    endfor ; looping over naxis1 - alpha
    
    print,'Number of points in slice',is

    if(is eq 0) then begin
        print,' NO POINTS FOUND IN SLICE',irow+1
    endif else begin 
        set_plot,'x'
        window,3,xsize=500,ysize=1024

        xs = xslice[0:is -1]
        ys = yslice[0:is -1]
        ls = lamba_slice[0:is-1]
        s = islice[0:is -1]

        xmin = floor(min(xs))
        xmax = ceil(max(xs))
        plot,xs,ys,/nodata,yrange = [-100,1100],xrange = [xmin,xmax],$
             xstyle = 1, ystyle =1,title ='Slice '+strcompress(string(irow+1),/remove_all)
        oplot,xgrid,ygrid,psym=3,color=3
        
        oplot,xs,ys,psym=1,symsize=0.5

	
;_______________________________________________________________________
	iflag = intarr(is)
       
	for ig = 0,is-1 do begin
	    xdistance = (xs[ig] - xs) 
	    ydistance = (ys[ig] - ys)
	    distance = sqrt(xdistance*xdistance + ydistance*ydistance)
	    ind = where(distance lt 1,dnum)
	   ; print,dnum
	    if(dnum lt 3) then begin
	       iflag[ig] = 1
	       print,' Not using point',xs[ig],ys[ig]
	       xplot = fltarr(1) & yplot = fltarr(1)
	       xplot[0] = xs[ig]
	       yplot[0] = ys[ig]
	       oplot,xplot,yplot,color=3,psym=6,symsize = 0.75
	;       stop
	    endif	
	endfor
	index  = where(iflag eq 0,nflag)
        print,'Number of points flag = 0',nflag
	xxss = xs[index]
	yyss = ys[index]
	xs = xxss & xxss = 0
	ys = yyss & yyss = 0
;_______________________________________________________________________
       ; break up slice in to sections to run interpolation routine over
        yrange = 1025

        nstep_y = 5
        nsize_y = nstep_y/2

        nstep_x = 4
        nsize_x = nstep_x/2

        if(is lt 1300) then begin	
            nsize_x = 1
            nstep_x = 1
            nsize_y = 1
            nstep_y = 1
        endif

        ysize = ceil(yrange/nsize_y)
        yincr = yrange/nstep_y
        c = [2,4,5]
        ic = 0
        ystart = 0
        print,'nstep_y ', nstep_y
        for i = 0,nstep_y -1 do begin ; i controls y chops
            yend = ystart + ysize
           if(yend gt 1024) then yend = 1024
            index1= where( ys ge ystart and ys le yend,num)
            print,'Y section',ystart,yend
            if(num gt 0) then begin
                xnew = xs[index1]
            
                xmin =floor( min(xnew))
                xmax =ceil( max(xnew))
                index1 = 0
                xnew = 0

                xrange = xmax -xmin +1
                xsize = ceil(xrange/nsize_x)
                if(xsize eq 0) then stop

                xincr = xrange/nstep_x
                
                xstart = xmin - xincr/2.0

                if(is lt 1300) then xstart = xmin

                j = 0 
                print,'xmin and xmax for section',xmin,xmax,xsize

                while(j le nstep_x) do begin 
                    xend = xstart + xsize
                    xdone = 0
                    if(xend gt xmax) then xend = xmax
                    index= where(xs ge xstart and xs le xend and ys ge ystart and ys le yend,num)
                    if(num lt 1) then begin
                        print,' Region does not have enough points',xstart,xend,ystart,yend,num
                        print,j
                        xdone = 1
                    endif
                    if(xdone eq 0) then begin 
                        print,'Region: ',i,j,xstart,xend,ystart,yend,num
                        x = xs[index]
                        y = ys[index]
                        l = ls[index]

                        xmindata = floor(min(x))
                        xmaxdata = ceil(max(x))
                        
                        xstart = xmindata
                        xend = xmaxdata
                        
                        print,' min of data',min(x), max(x),xstart,xend 
                        oplot,x,y,psym = 1,color=c[ic],symsize=0.5
                        ic = ic + 1
                        if(ic gt 2) then ic = 0
                        
                        xnum = xend- xstart
                        ynum = yend - ystart
; _______________________________________________________________________
; grid TPS seems to be the best interpolation routine to use
                        ll = grid_tps(x,y,l,ngrid=[xnum+1,ynum+1],start=[xstart,ystart],delta=[1,1])
                        ivalue = 0
                        
;_________________________________________________________________________________
;                        nosuccess = 0
;                        if (nosuccess eq 1) then begin
;                            stop
;                            triangulate,x,y,tr,bounds
;                            l2 = trigrid(x,y,l,tr,[1,1],[xstart,ystart,xend,yend],$
;                                         extrapolate=bounds,xgrid=gridx,ygrid=gridy,$
;                                         min_value = fix(minlamba))
;                            print,'trying triangulate'
;                            for ii = xstart,xend do begin
;                                jvalue = 0
;                                for jj = ystart,yend do begin
;                                    location = ngrid2[ii,jj]
;                                    if(l2[ivalue,jvalue] ne 0) then begin
;                                        grid2[ii,jj,location] = l2[ivalue,jvalue]
;                                        ngrid2[ii,jj] = ngrid2[ii,jj] + 1

;                                        grid[ii,jj,location] = l2[ivalue,jvalue]
;                                        ngrid[ii,jj] = ngrid2[ii,jj] + 1
;                                    endif
;                                    jvalue = jvalue + 1
;                                endfor
;                                ivalue = ivalue + 1
;                            endfor
;                        endif  else begin
;_________________________________________________________________________________
                            print,' tps_grid worked'
                            for ii = xstart,xend do begin
                                jvalue = 0
                                for jj = ystart,yend do begin
                                    location = ngrid[ii,jj]
                                    grid[ii,jj,location] = ll[ivalue,jvalue]
                                    ngrid[ii,jj] = ngrid[ii,jj] + 1
                                    jvalue = jvalue + 1
                                endfor
                                ivalue = ivalue + 1
                            endfor
;                        endelse
;_________________________________________________________________________________
                    endif
                    xstart = xstart + xincr
                    j = j + 1
                endwhile
            endif
            ystart = ystart + yincr
        endfor                  ; end y chops in slice

        for j = 0,1024 do begin
            for i = 0, 1032 do begin
                if(ngrid[i,j] ne 0 ) then begin
                    ave = 0.0d0
                    for mm = 0,ngrid[i,j]-1 do begin
                        ave = ave + grid[i,j,mm]
                    endfor            
                    if(ngrid[i,j] gt 0) then gridout[i,j] = ave/float(ngrid[i,j])
                    ave = 0.0d0
	         endif
            endfor


        endfor

    endelse; end if is = 0 (number of points in slice = 0) 
endfor                          ; end loop over different slices


index = where(sliceno eq 0)
gridout[index] = 0
index = 0


fits_open,d2cfile_out,ofcb,/write
fits_write,ofcb,gridout
fits_close,ofcb

gridout = 0

close,11                 
stop
end
