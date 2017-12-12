@cv_read_calibration_file.pro
@cv_find_xrange_channel.pro
@skycube2detector.pro
@cfit.pro


pro cal_fit

COMMON FUNC_DATA, x,y,alpha,lamba


@cube_structs ; hold cube structures

d2cfile = '/home/morrison/DHAS/MPipeline/Cal/Lab/VM/ch12b_d2c_VM00006.fits'

calibration = {calibration_datai}


cv_read_calibration_file,d2cfile,alpha,lamba,sliceno,status,error_message
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
    
calibration.filename = d2cfile
alpha = 0
sliceno = 0
lamba = 0

x = fltarr(1033,1025)
y = x
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

cv_find_xrange_channel,1,d2cfile,xrange
calibration.xrange = xrange

print,'Xrange of calibration file', xrange 

;_______________________________________________________________________
; Loop over cube pixels - with in a slice 

plate_scale = 0.0596574
dispersion = 0.000291030
for i = 0,20 do begin
    slice_channel =(*calibration.psliceno)[xrange[0,0]:xrange[0,1],*]
    x_channel = (*calibration.px)[xrange[0,0]:xrange[0,1],*]
    y_channel = (*calibration.py)[xrange[0,0]:xrange[0,1],*]
    alpha_channel = (*calibration.palpha)[xrange[0,0]:xrange[0,1],*]
    lamba_channel = (*calibration.pwavelength)[xrange[0,0]:xrange[0,1],*]


    index = where(slice_channel eq i+1 and y_channel lt 100,num)
    x = x_channel[index]
    y = y_channel[index]
    alpha =alpha_channel[index]
    lamba =lamba_channel[index]
 

    ii= where( abs(alpha) eq min(abs(alpha)))
    x = x - x[ii[0]]    

    
    
 ;   y = y - 512
 ;   jj = where( y eq min(y))
 ;   lamba = lamba - lamba[jj[0]]


    
     C = dblarr(20)
     CRANGE = dblarr(20)
     C =[ 1.0,1.0,0.0003,0.06,0.0,0.0,$
          0.0,0.0,0.0,0.0,0.0,0.0,$
          0.0,0.0,0.0,0.0,$
          0.0,0.0,0.0,0.0]
     CRANGE = [1.e1,$
               1.e1,$
               1.e-1,$
               1.e-1,$
               1.e-1,$
               1.e-1,$
               1.e-2,$
               1.e-2,$
               1.e-4,$
               1.e-4,$
               1.e-4,$
               1.e-4,$
               1.e-6,$
               1.e-6,$
               1.e-6,$
               1.e-6,$
               1.e-6,$
               1.e-6,$
               1.e-6,$
               1.e-6]




     R = amoeba(1.0e-6, scale= CRANGE, P0 = C,$
                function_value = fval, function_name = 'cfit',$
                NCALLS = nums, NMAX = 50000)

    if(n_elements(R) eq 1) then MESSAGE, 'AMOEBA failed to converge'



    
     print,' Number of calls',nums
     print,R
     result_fit,x,y,R,xresult,yresult
     lamba_diff = lamba - yresult
     alpha_diff = alpha - xresult

    
     stop
endfor
                 
end
