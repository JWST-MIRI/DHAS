pro    skycube2detector,calibration,channel,alpha, wavelength,sliceno,xx,yy,status,verbose = verbose

; This routine uses the d2c calibrations file and interpolates to find
 ; an detector x,y for a given wavelength, alpha and delta
; to find the closest x and y detector value 
; 1. Look only in the slice 
; 2. Narrow down the slice region by finding a wavelength band the cube
 ; pixel comes from 
; 3. Find the alpha (afound) and wavelength (wfound) closest to the
 ; input  alpha and wavelength 
; 4. For this closest point find the corresponding x and y
; 5. Then interpolate to find the estimated x,y
; 6. The x, y found this way corresponds to an array of corner pixel
                                ; values. The definition of the pixel
                                ; corridinate system is that pixel 1
                                ; goes from 0.5 to 1.5 
status = 0
xx = 0
yy = 0
do_verbose = 0
if keyword_set(verbose) then do_verbose = 1


;_______________________________________________________________________
; based on channel mark the xmin & max region to look at in the d2c files
xmin = calibration.xrange[channel-1,0]
xmax = calibration.xrange[channel-1,1]


slice = (*calibration.psliceno)
slice[*,*] = 0

slice[xmin:xmax,*]  = (*calibration.psliceno)[xmin:xmax,*]

; find the region in the d2c file for the slice no.
index = where(slice eq sliceno,num)

if(do_verbose) then print,'channel no, slice no',channel,sliceno,xmin,xmax
if(do_verbose eq 1 ) then print,'Region of slice no',num
if(num lt 1) then begin
    status = 1
    return
endif

;_______________________________________________________________________
; narrow down the slice to wavelength area
tolerance = 0.02
diffwave = abs(wavelength - (*calibration.pwavelength)[index])
iregion = where(diffwave lt tolerance,num)
 
if(do_verbose eq 1) then print,'wavelength & #in region',wavelength,num


if(num lt 1) then begin
    status = 1
    return
endif

; look at all alpha and wavelength in that wavelength limited region
; find the distance from the alpha and wavelength of the cube pixel
 ; with all possible points in region

alphadiff = abs(alpha - (*calibration.palpha)[index[iregion]])
wavediff = abs(wavelength - (*calibration.pwavelength)[index[iregion]])

diff1 = alphadiff/(max(alphadiff))
diff2 = wavediff/(max(wavediff))
dist = sqrt(diff1*diff1 + diff2*diff2)
ifound = where(min(dist) eq dist,nfound)
if(nfound lt 1) then begin
    status = 1
    return
endif

; closest point
cpt = index[iregion[ifound[0]]]
xsize = 1033

xcpt = (*calibration.px)[cpt] 
ycpt = (*calibration.py)[cpt] 


wfound = (*calibration.pwavelength)[cpt]
afound = (*calibration.palpha)[cpt]


;; found closest grid point, now find exact x, y - by interpolating 
; how far alpha and wavelength are from the wfound and afound values

y1 = ycpt
x1 = xcpt

; look at the sign of difference: afound and alpha
; look at sign of difference: wfound and wavelength

; find wavelength range:
wdiff = wavelength - wfound
if(channel eq 1 or channel eq 2) then begin
	if(wdiff ge 0) then y2 = y1 +1
	if(wdiff lt 0) then y2 = y1 -1
endif	

if(channel eq 3 or channel eq 4) then begin
	if(wdiff ge 0) then y2 = y1 -1
	if(wdiff lt 0) then y2 = y1 +1
endif	

if(y2 lt 0) then begin
    y2 = 0
    y1 = 1
endif

;find alpha range
adiff = alpha - afound 
if(channel eq 1 or channel eq 4) then begin
	if(adiff ge 0) then x2 = x1 +1
	if(adiff lt 0) then x2 = x1-1
endif

if(channel eq 2 or channel eq 3) then begin
	if(adiff ge 0) then x2 = x1 -1
	if(adiff lt 0) then x2 = x1 +1
endif

if(x2 lt 0) then begin
    x2 = 0
    x1 = 1
endif


; check maximum boundaries
if(y2 ge 1025) then begin
    y2 = 1024
    y1 = 1023
endif


if(x2 ge 1033) then begin
    x2 = 1032
    x1 = 1031
endif


if(do_verbose eq 1 ) then begin 
    print,'searching for',alpha,wavelength
    print,'closest pt',xcpt,ycpt,x1,x2,y1,y2
    print,'afound wfound',afound,wfound
endif


; point a: x1,y1
; point b: x2,y1
; point c: x2,y2
; point d: x1,y2


if(do_verbose eq 1) then print,'searching pt',x1,x2,y1,y2
;-----------------------------------------------------------------------
; normalize wavelength from 0 to 1

index11 =   long(y1)*long(xsize) + long(x1)
index12 =   long(y1)*long(xsize) + long(x2)
index21 =   long(y2)*long(xsize) + long(x1)
index22 =   long(y2)*long(xsize) + long(x2)

if(do_verbose) then print,'indexes ',index11,index12,index21,index22
ww = fltarr(4)
ww[0] = (*calibration.pwavelength)[index11]
ww[1] =(*calibration.pwavelength)[index12] 
ww[2] = (*calibration.pwavelength)[index21] 
ww[3] = (*calibration.pwavelength)[index22]

aa = fltarr(4)
aa[0] = (*calibration.palpha)[index11] 
aa[1] =(*calibration.palpha)[index12] 
aa[2] = (*calibration.palpha)[index21] 
aa[3] =(*calibration.palpha)[index22] 

;-----------------------------------------------------------------------

x = [x1,x2,x1,x2]
y = [y1,y1,y2,y2]


index = where(ww ne 0 and aa ne 0,nn)
if(nn eq 0) then begin
	if(do_verbose eq 1) then print,'No detector value found'
	return
endif


wuse = ww[index]
ause = aa[index]
xuse = x[index]
yuse = y[index]

if(nn eq 1) then begin
	; return the point that is closest
	xx = xuse[0] +0.5
	yy = yuse[0] +0.5
        return
endif

;_______________________________________________________________________
; normalize  from 0 to 1

wmin = min(wuse)
wmax = max(wuse)
wrange = wmax - wmin
wnew = (wuse- wmin)/ wrange

wavelength_normal = (wavelength  - wmin)/(wrange)

if(do_verbose eq 1) then begin 
    for ii = 0,nn-1 do begin 
       print,format='(a13,4f12.8)','Wavelength ',wuse[ii]
    endfor	
    print,format='(f12.8)',wavelength
    print,'new w',wnew
    print,' normalized wavelength',wavelength_normal,double(wavelength)
endif

;_______________________________________________________________________
; normalize  from 0 to 1

amin = min(ause)
amax = max(ause)
arange = amax - amin
anew = (ause- amin)/arange

alpha_normal = (alpha - amin)/arange
if(do_verbose eq 1) then begin 
    for ii = 0,nn-1 do begin 
       print,format='(a6,4f12.8)','Alpha ',ause[ii]
    endfor	
    print,'new a',anew
    print,' normalized alpha',alpha_normal,alpha
endif
;_______________________________________________________________________
tolerance = 2.0


length = fltarr(4)
imin = 0
min = 10000.0
for i = 0,nn-1 do begin	
    adiff = alpha_normal - anew[i]
    wdiff = wavelength_normal - wnew[i]
    if( abs(alpha_normal) gt tolerance) then adiff = 0
    if( abs(wavelength_normal) gt tolerance) then wdiff = 0
    length[i] = sqrt( adiff^2 + wdiff^2)
    if(length[i] lt min) then begin
        min = length[i]
        imin = i
    endif
endfor

if(abs(alpha_normal) lt tolerance) then begin 
  incr_x = (alpha_normal-anew[imin])
  if(channel eq 1 or channel eq 4) then 	xx = xuse[imin] + incr_x	
  if(channel eq 3 or channel eq 2) then 	xx = xuse[imin] - incr_x	
   if(do_verbose) then print,'Found the closest point, x', imin,x[imin],incr_x

endif else begin

   if(do_verbose) then print,' In gap, X value on detector only approximate'
   adiff = abs(ause - alpha)
   aindex  =where( min(adiff) eq adiff) 
   xx = xuse[aindex[0]]
   status = 2
endelse
	

if(abs(wavelength_normal) lt tolerance) then begin 
  incr_y = (wavelength_normal-wnew[imin])
  if(channel eq 1 or channel eq 2) then yy = yuse[imin] + incr_y
  if(channel eq 3 or channel eq 4) then yy = yuse[imin] - incr_y
   if(do_verbose) then print,'Found the closest point, y', imin,y[imin],incr_y
endif else begin 
   if(do_verbose)then  print,' In gap, Y value on detector only approximate'
   wdiff = abs(wuse - wavelength)
   windex  = where(min(wdiff) eq wdiff)
   yy = yuse[windex[0]]
   status = 2
endelse


;_______________________________________________________________________
; problem arises when only 2 points are found because we are in a gap



xx = xx+ 0.5
yy = yy + 0.5


if(do_verbose eq 1) then print,'Found x,y ',xx,yy,xx-0.5,yy-0.5

length = 0
a= 0 & anew = 0
w = 0 & wnew = 0
x = 0 & y = 0
slice = 0
index  =0
diffwave = 0
iregion = 0

alphadiff = 0
wavediff = 0
diff1 = 0
diff2 = 0
dist = 0
end
