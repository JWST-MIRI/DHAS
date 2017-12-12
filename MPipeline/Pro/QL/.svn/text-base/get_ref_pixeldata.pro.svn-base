pro get_ref_pixeldata,info,num,x,y,ref_pixeldata
widget_control,/hourglass
progressBar = Obj_New("ShowProgress", color = 150, $
                      message = " Reading in Reference Pixel Data",$
                      xsize = 250, ysize = 40)


 progressBar -> Start
; _______________________________________________________________________
; for the selected pixels - find the frame values for the entire exposure
j = 0
for integ = 0, info.data.nints -1 do begin

   percent = (float(integ)/float(info.data.nints) * 99)
   progressBar -> Update,percent

   nramps = info.data.nramps


   ystart = info.data.image_ysize   
   yend =  info.data.naxis2
   xsize = info.data.naxis1
   ypart = yend - ystart

    for iramp = 0, nramps -1 do begin
;        im_raw = readfits_miri(info.control.filename_raw,nslice = j,/silent) 
        im_raw = readfits(info.control.filename_raw,nslice = j,/silent) 

        refout = fltarr(xsize,ypart)
        refout = im_raw[*,ystart:yend-1]
        refnew = fltarr(info.data.ref_xsize,info.data.ref_ysize)
        refnew[*,*] = refout
        refout = 0
        for k = 0, num-1 do begin
            xvalue =fix( x[k])/4
            yvalue = y[k]
            value  = refnew[xvalue,yvalue]                
            ref_pixeldata[integ,iramp,k] = value
        endfor
        j = j + 1
    endfor
endfor

refnew = 0
fits_close,fcb
;_______________________________________________________________________
progressBar -> Destroy
obj_destroy, progressBar
;_______________________________________________________________________



end
