pro get_pixeldata,info,num,x,y,pixeldata
; x,y start at 0 (included reference pixel values)



message = info.data.nints*info.data.nramps
imessage = 0
if(message gt 100) then imessage = 1

if(imessage) then begin
    widget_control,/hourglass
    progressBar = Obj_New("ShowProgress", color = 150, $
                          message = " Reading in Pixel Data",$
                          xsize = 250, ysize = 40)
    progressBar -> Start
endif
; _______________________________________________________________________
; for the selected pixels - find the frame values for the entire exposure
j = 0

if(info.data.raw_exist eq 0 )then begin
    pixeldata[*,*] = 0
    if(imessage) then begin 
        progressBar -> Destroy
        obj_destroy, progressBar
    endif
    return
endif


for integ = 0, info.data.nints -1 do begin

    if(imessage) then begin
        percent = (float(integ)/float(info.data.nslopes) * 99)
        progressBar -> Update,percent
    endif

   nramps = info.data.nramps
   fits_open,info.control.filename_raw,fcb


   header = 0 & d = 0
   for iramp = 0,nramps -1 do begin
       for k = 0, num-1 do begin
           xvalue = x[k]        ; 
           yvalue = y[k] 
           nxy = long(info.data.naxis1) * long(info.data.naxis2)
           firstvalue = long(yvalue)*long(info.data.image_xsize) + long(xvalue)
           istart = long(nxy) * long(iramp) + (  long(integ) * long(nramps) * long(nxy))
           firstvalue = firstvalue + istart
           lastvalue  = long(firstvalue)
           if(lastvalue le 1) then begin ; fits_read will fail for this case
;               im_raw = readfits_miri(info.control.filename_raw,nslice = j,/silent) 
               im_raw = readfits(info.control.filename_raw,nslice = j,/silent) 
               value  = im_raw[xvalue,yvalue]
               pixeldata[integ,iramp,k] = value
           endif else begin 
               if(j gt 800) then begin ; for bitpix = 16
;                   im_raw = readfits_miri(info.control.filename_raw,nslice = j,/silent) 
                   im_raw = readfits(info.control.filename_raw,nslice = j,/silent) 
                   dn  = im_raw[xvalue,yvalue]
               endif else begin 
                   fits_read,fcb,dn,hdr,first = firstvalue,last = lastvalue,exten_no = 0
               endelse
               pixeldata[integ,iramp,k] = dn
           endelse
            
       endfor
       j = j + 1
   endfor

   fits_close,fcb
endfor
im_raw = 0

;_______________________________________________________________________
if(imessage) then begin 
    progressBar -> Destroy
    obj_destroy, progressBar
endif
;_______________________________________________________________________
end

; _______________________________________________________________________
pro get_slopepixel,info,x,y,slopepixel,slopefinal,status
; x,y start at 0 (included reference pixel values)


message = info.data.nslopes
imessage = 0
if(message gt 300) then imessage = 1
if(imessage ) then begin 
    widget_control,/hourglass
    progressBar = Obj_New("ShowProgress", color = 150, $
                          message = " Reading in Pixel Data (output data) ",$
                          xsize = 250, ysize = 40)
    progressBar -> Start
endif
; _______________________________________________________________________
; for the selected pixels - find the frame values for the entire exposure
j = 0

fits_open,info.control.filename_slope,fcb

fits_read,fcb,slopedata,header,/header_only,exten_no = 1
naxis3 = fxpar(header,'NAXIS3',count = count)

slopedata=0
header = 0


firstvalue = long(y)*long(info.data.slope_xsize) + long(x)
lastvalue  = long(firstvalue)
if(lastvalue le 1) then begin   ; fits_read will fail for this case
    fits_read,fcb,data,header,exten_no = 0
    slopefinal = data[x,y,0]
endif else begin
    fits_read,fcb,dn,hdr,first = firstvalue,last = lastvalue,exten_no = 0
    slopefinal = dn
endelse


for integ =0,info.data.nslopes-1 do begin
    if(imessage) then begin
        percent = (float(integ)/float(info.data.nslopes) * 99)
        progressBar -> Update,percent
    endif
    firstvalue = long(y)*long(info.data.slope_xsize) + long(x)
    lastvalue  = long(firstvalue)
    if(lastvalue le 1) then begin ; fits_read will fail for this case
        fits_read,fcb,data,header,exten_no = integ+1
        slopepixel[integ,0] = data[x,y,0]
        if(naxis3 eq 3 or naxis3 eq 2)then begin
            slopepixel[integ,1] = data[x,y,1]
        endif else begin
            slopepixel[integ,1] = data[x,y,3]
        endelse 
        
    endif else begin
        fits_read,fcb,dn,hdr,first = firstvalue,last = lastvalue,exten_no = integ+1
        slopepixel[integ,0] = dn
        istart = (long(info.data.slope_xsize) * long(info.data.slope_ysize))* 3
        if(naxis3 eq 3 or naxis3 eq 2) then istart = (long(info.data.slope_xsize) * long(info.data.slope_ysize))
        firstvalue = firstvalue + istart
        lastvalue = firstvalue
        fits_read,fcb,dn,hdr,first = firstvalue,last = lastvalue,exten_no = integ+1
        slopepixel[integ,1] = dn
    endelse
endfor
fits_close,fcb
data=0
;_______________________________________________________________________
if(imessage) then begin
    progressBar -> Destroy
    obj_destroy, progressBar
endif
end




;_______________________________________________________________________
pro get_refcorrected_pixeldata,info,num,x,y,pixeldata
; x,y start at 0 (included reference pixel values)

message = info.data.nints*info.data.nramps
imessage = 0
if(message gt 300) then imessage = 1
if(imessage) then begin
    widget_control,/hourglass
    progressBar = Obj_New("ShowProgress", color = 150, $
                          message = " Reading in Reference Corrected Pixel Data",$
                          xsize = 250, ysize = 40)


    progressBar -> Start
endif
; _______________________________________________________________________
; for the selected pixels - find the frame values for the entire exposure
j = 0


for integ = 0, info.data.nints -1 do begin

    if(imessage) then begin 
        percent = (float(integ)/float(info.data.nslopes) * 99)
        progressBar -> Update,percent
    endif

   nramps = info.data.nramps
   fits_open,info.control.filename_refcorrection,fcb

   
   header = 0 & d = 0
   for iramp = 0,nramps -1 do begin
       for k = 0, num-1 do begin

           xvalue = x[k]        ; 
           yvalue = y[k] 
           nxy = long(info.data.refcorrected_xsize) * long(info.data.refcorrected_ysize)

           
           firstvalue = long(yvalue)*long(info.data.refcorrected_xsize) + long(xvalue)
           istart = long(nxy) * long(iramp) + (  long(integ) * long(nramps) * long(nxy))
           firstvalue = firstvalue + istart
           lastvalue  = long(firstvalue)
           
           if(lastvalue le 1) then begin ; fits_read will fail for this case
;               im_raw = readfits_miri(info.control.filename_refcorrection,nslice = j,/silent) 
               im_raw = readfits(info.control.filename_refcorrection,nslice = j,/silent) 
               value  = im_raw[xvalue,yvalue]
               pixeldata[integ,iramp,k] = value
               
           endif else begin 
               if(j gt 500) then begin ; over 2 GB limit for  bitpix = 32
;                   im_raw = readfits_miri(info.control.filename_refcorrection,nslice = j,/silent) 
                   im_raw = readfits(info.control.filename_refcorrection,nslice = j,/silent) 
                   dn  = im_raw[xvalue,yvalue]
               endif else begin 
                   fits_read,fcb,dn,hdr,first = firstvalue,last = lastvalue,exten_no = 0
               endelse
               pixeldata[integ,iramp,k] = dn

           endelse
           
            
       endfor
       j = j + 1
   endfor
   fits_close,fcb
endfor
im_raw = 0

;_______________________________________________________________________
if(imessage) then begin
    progressBar -> Destroy
    obj_destroy, progressBar
endif

end




;_______________________________________________________________________
pro get_id_pixeldata,info,num,x,y,pixeldata
; x,y start at 0 (included reference pixel values)

message = info.data.nints*info.data.nramps
imessage = 0
if(message gt 300) then imessage = 1
if(imessage) then begin
    widget_control,/hourglass
    progressBar = Obj_New("ShowProgress", color = 150, $
                          message = " Reading in Frame IDS Data",$
                          xsize = 250, ysize = 40)


    progressBar -> Start
endif
; _______________________________________________________________________
; for the selected pixels - find the frame values for the entire exposure
j = 0


for integ = 0, info.data.nints -1 do begin

    if(imessage) then begin 
        percent = (float(integ)/float(info.data.nslopes) * 99)
        progressBar -> Update,percent
    endif

   nramps = info.data.nramps
   fits_open,info.control.filename_IDS,fcb

   
   header = 0 & d = 0
   for iramp = 0,nramps -1 do begin
       for k = 0, num-1 do begin

           xvalue = x[k]        ; 
           yvalue = y[k] 
           nxy = long(info.data.id_xsize) * long(info.data.id_ysize)

           
           firstvalue = long(yvalue)*long(info.data.id_xsize) + long(xvalue)
           istart = long(nxy) * long(iramp) + (  long(integ) * long(nramps) * long(nxy))
           firstvalue = firstvalue + istart
           lastvalue  = long(firstvalue)
           
           if(lastvalue le 1) then begin ; fits_read will fail for this case
;               im_raw = readfits_miri(info.control.filename_ids,nslice = j,/silent) 
               im_raw = readfits(info.control.filename_ids,nslice = j,/silent) 
               value  = im_raw[xvalue,yvalue]
               pixeldata[integ,iramp,k] = value
               
           endif else begin 
               if(j gt 500) then begin ; 2 gigabyte limit for bitpix = 32
;                   im_raw = readfits_miri(info.control.filename_ids,nslice = j,/silent) 
                   im_raw = readfits(info.control.filename_ids,nslice = j,/silent) 
                   dn  = im_raw[xvalue,yvalue]
               endif else begin 
                   fits_read,fcb,dn,hdr,first = firstvalue,last = lastvalue,exten_no = 0
               endelse
               pixeldata[integ,iramp,k] = dn
           endelse
           
            
       endfor
       j = j + 1
   endfor
   fits_close,fcb
endfor
im_raw = 0

;_______________________________________________________________________
if(imessage) then begin
    progressBar -> Destroy
    obj_destroy, progressBar
endif
;_______________________________________________________________________
end



;_______________________________________________________________________
pro get_lc_pixeldata,info,num,x,y,pixeldata
; x,y start at 0 (included reference pixel values)

message = info.data.nints*info.data.nramps
imessage = 0
if(message gt 300) then imessage = 1
if(imessage) then begin
    widget_control,/hourglass
    progressBar = Obj_New("ShowProgress", color = 150, $
                          message = " Reading in Frame Linearity Corrected Data",$
                          xsize = 250, ysize = 40)


    progressBar -> Start
endif
; _______________________________________________________________________
; for the selected pixels - find the frame values for the entire exposure
j = 0


for integ = 0, info.data.nints -1 do begin

    if(imessage) then begin 
        percent = (float(integ)/float(info.data.nslopes) * 99)
        progressBar -> Update,percent
    endif

   nramps = info.data.nramps
   fits_open,info.control.filename_LC,fcb
   fits_read,fcb,data,header,/header_only
   

   header = 0 & d = 0
   for iramp = 0,nramps -1 do begin
       for k = 0, num-1 do begin

           xvalue = x[k]        ; 
           yvalue = y[k] 
           nxy = long(info.data.lc_xsize) * long(info.data.lc_ysize)

           
           firstvalue = long(yvalue)*long(info.data.id_xsize) + long(xvalue)
           istart = long(nxy) * long(iramp) + (  long(integ) * long(nramps) * long(nxy))
           firstvalue = firstvalue + istart
           lastvalue  = long(firstvalue)
           
           if(lastvalue le 1) then begin ; fits_read will fail for this case
;               im_raw = readfits_miri(info.control.filename_lc,nslice = j,/silent) 
               im_raw = readfits(info.control.filename_lc,nslice = j,/silent) 
               value  = im_raw[xvalue,yvalue]
               pixeldata[integ,iramp,k] = value
               
           endif else begin 
               if(j gt 500) then begin ; 2 gigabyte limit for bitpix = 32
;                   im_raw = readfits_miri(info.control.filename_lc,nslice = j,/silent) 
                   im_raw = readfits(info.control.filename_lc,nslice = j,/silent) 
                   dn  = im_raw[xvalue,yvalue]
               endif else begin 
                   fits_read,fcb,dn,hdr,first = firstvalue,last = lastvalue,exten_no = 0
               endelse
               pixeldata[integ,iramp,k] = dn
           endelse

       endfor
       j = j + 1
   endfor


   
   fits_close,fcb
endfor
im_raw = 0
if(imessage) then begin
    progressBar -> Destroy
    obj_destroy, progressBar
endif
;_______________________________________________________________________
end


;_______________________________________________________________________
pro get_mdc_pixeldata,info,num,x,y,pixeldata
; x,y start at 0 (included reference pixel values)

message = info.data.nints*info.data.nramps
imessage = 0
if(message gt 300) then imessage = 1
if(imessage) then begin
    widget_control,/hourglass
    progressBar = Obj_New("ShowProgress", color = 150, $
                          message = " Reading in Frame Mean Dark Corrected Data",$
                          xsize = 250, ysize = 40)


    progressBar -> Start
endif
; _______________________________________________________________________
; for the selected pixels - find the frame values for the entire exposure
j = 0


for integ = 0, info.data.nints -1 do begin

    if(imessage) then begin 
        percent = (float(integ)/float(info.data.nslopes) * 99)
        progressBar -> Update,percent
    endif

   nramps = info.data.nramps
   fits_open,info.control.filename_MDC,fcb

   fits_read,fcb,data,header,/header_only
   header = 0 & d = 0
   for iramp = 0,nramps -1 do begin
       for k = 0, num-1 do begin

           xvalue = x[k]        ; 
           yvalue = y[k] 
           nxy = long(info.data.mdc_xsize) * long(info.data.mdc_ysize)

           
           firstvalue = long(yvalue)*long(info.data.id_xsize) + long(xvalue)
           istart = long(nxy) * long(iramp) + (  long(integ) * long(nramps) * long(nxy))
           firstvalue = firstvalue + istart
           lastvalue  = long(firstvalue)
           if(lastvalue le 1) then begin ; fits_read will fail for this case
               im_raw = readfits(info.control.filename_mdc,nslice = j,/silent) 
               value  = im_raw[xvalue,yvalue]
               pixeldata[integ,iramp,k] = value
               
           endif else begin 
               if(j gt 500) then begin ; 2 gigabyte limit for bitpix = 32
                   im_raw = readfits(info.control.filename_mdc,nslice = j,/silent) 
                   dn  = im_raw[xvalue,yvalue]
               endif else begin 
                   fits_read,fcb,dn,hdr,first = firstvalue,last = lastvalue,exten_no = 0
               endelse
               pixeldata[integ,iramp,k] = dn
           endelse

           
       endfor
       j = j + 1
   endfor
   
   fits_close,fcb
endfor
im_raw = 0




;_______________________________________________________________________
if(imessage) then begin
    progressBar -> Destroy
    obj_destroy, progressBar
endif
;_______________________________________________________________________
end

;_______________________________________________________________________
pro get_reset_pixeldata,info,num,x,y,pixeldata
; x,y start at 0 (included reference pixel values)

message = info.data.nints*info.data.nramps
imessage = 0
if(message gt 300) then imessage = 1
if(imessage) then begin
    widget_control,/hourglass
    progressBar = Obj_New("ShowProgress", color = 150, $
                          message = " Reading in Frame Reset Corrected Data",$
                          xsize = 250, ysize = 40)


    progressBar -> Start
 endif
; _______________________________________________________________________
; for the selected pixels - find the frame values for the entire exposure
j = 0


for integ = 0, info.data.nints -1 do begin

    if(imessage) then begin 
        percent = (float(integ)/float(info.data.nslopes) * 99)
        progressBar -> Update,percent
    endif

   nramps = info.data.nramps
   fits_open,info.control.filename_RESET,fcb

   fits_read,fcb,data,header,/header_only
   header = 0 & d = 0
   for iramp = 0,nramps -1 do begin

       for k = 0, num-1 do begin

           xvalue = x[k]        ; 
           yvalue = y[k] 
           nxy = long(info.data.reset_xsize) * long(info.data.reset_ysize)

           
           firstvalue = long(yvalue)*long(info.data.reset_xsize) + long(xvalue)
           istart = long(nxy) * long(iramp) + (  long(integ) * long(nramps) * long(nxy))
           firstvalue = firstvalue + istart
           lastvalue  = long(firstvalue)
           if(lastvalue le 1) then begin ; fits_read will fail for this case
               im_raw = readfits(info.control.filename_reset,nslice = j,/silent) 
               value  = im_raw[xvalue,yvalue]
               pixeldata[integ,iramp,k] = value
               
           endif else begin 
               if(j gt 500) then begin ; 2 gigabyte limit for bitpix = 32
                   im_raw = readfits(info.control.filename_reset,nslice = j,/silent) 
                   dn  = im_raw[xvalue,yvalue]
               endif else begin 
                   fits_read,fcb,dn,hdr,first = firstvalue,last = lastvalue,exten_no = 0
               endelse
               pixeldata[integ,iramp,k] = dn
           endelse
       endfor
       j = j + 1
   endfor
   
   fits_close,fcb
endfor
im_raw = 0




;_______________________________________________________________________
if(imessage) then begin
    progressBar -> Destroy
    obj_destroy, progressBar
endif
;_______________________________________________________________________
end


;_______________________________________________________________________
pro get_rscd_pixeldata,info,num,x,y,pixeldata
; x,y start at 0 (included reference pixel values)

message = info.data.nints*info.data.nramps
imessage = 0
if(message gt 300) then imessage = 1
if(imessage) then begin
    widget_control,/hourglass
    progressBar = Obj_New("ShowProgress", color = 150, $
                          message = " Reading in Frame Rscd Corrected Data",$
                          xsize = 250, ysize = 40)


    progressBar -> Start
 endif
; _______________________________________________________________________
; for the selected pixels - find the frame values for the entire exposure
j = 0


for integ = 0, info.data.nints -1 do begin

    if(imessage) then begin 
        percent = (float(integ)/float(info.data.nslopes) * 99)
        progressBar -> Update,percent
    endif

   nramps = info.data.nramps
   fits_open,info.control.filename_RSCD,fcb

   fits_read,fcb,data,header,/header_only
   header = 0 & d = 0
   for iramp = 0,nramps -1 do begin

       for k = 0, num-1 do begin

           xvalue = x[k]        ; 
           yvalue = y[k] 
           nxy = long(info.data.rscd_xsize) * long(info.data.rscd_ysize)

           
           firstvalue = long(yvalue)*long(info.data.rscd_xsize) + long(xvalue)
           istart = long(nxy) * long(iramp) + (  long(integ) * long(nramps) * long(nxy))
           firstvalue = firstvalue + istart
           lastvalue  = long(firstvalue)
           if(lastvalue le 1) then begin ; fits_read will fail for this case
               im_raw = readfits(info.control.filename_rscd,nslice = j,/silent) 
               value  = im_raw[xvalue,yvalue]
               pixeldata[integ,iramp,k] = value
               
           endif else begin 
               if(j gt 500) then begin ; 2 gigabyte limit for bitpix = 32
                   im_raw = readfits(info.control.filename_rscd,nslice = j,/silent) 
                   dn  = im_raw[xvalue,yvalue]
               endif else begin 
                   fits_read,fcb,dn,hdr,first = firstvalue,last = lastvalue,exten_no = 0
               endelse
               pixeldata[integ,iramp,k] = dn
           endelse
       endfor
       j = j + 1
   endfor
   
   fits_close,fcb
endfor
im_raw = 0




;_______________________________________________________________________
if(imessage) then begin
    progressBar -> Destroy
    obj_destroy, progressBar
endif
;_______________________________________________________________________
end



;_______________________________________________________________________
pro get_lastframe_pixeldata,info,num,x,y,pixeldata
; x,y start at 0 (included reference pixel values)

; _______________________________________________________________________
; for the selected pixels - find the frame values for the entire exposure

for integ = 0, info.data.nints -1 do begin
   im = readfits(info.control.filename_lastframe,exten_no=integ+1,/silent) 
   for k = 0, num-1 do begin
      
      xvalue = x[k]             ; 
      yvalue = y[k] 
      
      value  = im[xvalue,yvalue]
      pixeldata[integ,k] = value
   endfor
   fits_close,fcb
endfor
im_raw = 0


;_______________________________________________________________________
end
