pro PixelXY_PixelIndex, xsize, x, y, index

;**********************************************************************/
; Purpose:
; Given 2-d array index (starting at 1,1)  - convert to a 1-d index
; starting a 0
;
; InPUTS:
;  X - x pixel location (starts at 1)
;  Y - y pixel location (starts at 1)
; xsize - number of pixel in x direction

; Outputs:
; Index - one dim array index (starts at zero)
;**********************************************************************/

  
index = long(y-1)* long(xsize) + long(x)         
index = index -1                

end
