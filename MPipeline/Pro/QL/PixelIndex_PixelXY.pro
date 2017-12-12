pro PixelIndex_PixelXY, xsize, index, x, y
;**********************************************************************/
; Purpose:
; Given a one dimensional pixel index starting at 0- convert this to the pixel
; location in x and y (starting at 1,1) 
;
; Inputs:
; Index - one dim array index
; xsize - number of pixel in x direction

; 
; OUTPUTS:
;  X - x pixel location (starts at 1)
;  Y - y pixel location  (starts at 1) 
;**********************************************************************/
y = long(index)/xsize + 1
x = long(index) - ( (y -1)*xsize);
x = x + 1
end
