pro pscoords,image,norder,origin,dimen,trueval
; Writes an image to the postscript file and sets up coordinate systems for 
; subsequent graphics overlay.  Does not erase first.
; norder =0 (default) for origin in the lower left, 
; norder =1 for origin in the upper left
; "origin", if set, is a 2-element array containing the inch coordinates of
; the lower-left corner of the image.  Default is [1.0,1.0]
; "dimen", if set, is a 2-element array containing the x and y dimensions
; of the image in inches.  If dimen(1) is zero, the true aspect ratio is
; preserved.  If dimen is not set at all, aspect ratio is preserved and
; a margin of width "origin" is left in the "tightest" direction
; 
; If trueval ne 0, will print true color (trueval = "true" parameter

; Notes: 

; Works in either portrait or landscape mode.

; Margins are set with respect to the plot area defined in the "device"
; statement, not the edges of the paper.

; Coordinates are set from zero to the number of pixels, so coordinate
; (nx,ny) is at the lower left corner of pixel(nx,ny) (IDL convention), for
; norder=0, and in the upper left for norder=1.

; To plot axes on the image after calling this routine, use e.g.,
; plot,[0],/noerase,/nodata
; or, for instance to show arcseconds...
; plot,[0],/noerase,/nodata,xrange=!x.range*platescl,yrange=!y.range*platescl

; To use !p.multi and scaling for future plots, 
; set !p.position,!x.range,!y.range=0 first

imsize=size(image)
aspect=1.0*imsize(2)/imsize(1)

pixinch=[!d.x_px_cm,!d.y_px_cm]*2.54   ; Pixels per inch

xinches=!d.x_size/pixinch(0)
yinches=!d.y_size/pixinch(1)

if n_elements(norder) eq 0 then norder=0

if n_elements(origin) eq 0 then origin=[1.0,1.0]

if n_elements(dimen) eq 0 then dimen = [xinches-2*origin(0),0.0]

if n_elements(trueval) eq 0 then trueval = 0

dimen=1.0*dimen
origin=1.0*origin

if dimen(1) eq 0 then begin
   if dimen(0) eq 0 then testy=yinches-2*origin(1) else testy=yinches-origin(1)
   if aspect gt testy/dimen(0) then begin
      print,'Image size is constrained by y extent'
      dimen(1)=testy
      dimen(0)=dimen(1)/aspect
   endif else begin
      print,'Image size is constrained by x extent'
      dimen(1)=dimen(0)*aspect
   endelse
endif

print,'Printed image size = ',dimen(0),' x ',dimen(1),' inches', $
 format="(a,f6.3,a,f6.3,a)"

;tv,image,origin(0)*pixinch(0),origin(1)*pixinch(1),order=norder, $
; xsize=dimen(0)/pixinch(0), ysize=dimen(1)/pixinch(1),/device

tv,image,origin(0)/xinches,origin(1)/yinches,order=norder, $
 xsize=dimen(0)/xinches, ysize=dimen(1)/yinches,/norm,true=trueval

; Redefine the plot window to coincide with the displayed image:
!p.position(0)=origin(0)*pixinch(0)/!d.x_size
!p.position(1)=origin(1)*pixinch(1)/!d.y_size
!p.position(2)=(origin(0)+dimen(0))*pixinch(0)/!d.x_size
!p.position(3)=(origin(1)+dimen(1))*pixinch(1)/!d.y_size

; Redefine the plot data range to coincide with pixel coordinates:
!x.range=[0,imsize(1)]
if norder eq 0 then !y.range=[0,imsize(2)]
if norder eq 1 then !y.range=[imsize(2),0]

; Draw invisible plot to set up axis ranges:
plot,[0],xstyle=5,ystyle=5,/noerase,/nodata

; Set axes styles to 1 to force subsequent plots to use this exact axis range:
!x.style=1
!y.style=1

return

end
