;_______________________________________________________________________
pro jwst_mql_read_rampdata,xvalue,yvalue,pixeldata,info
; x_pos, y_pos starts at 0

if(info.jwst_data.read_all eq 0) then begin
    x = intarr(1) & y = intarr(1)
    pixeldata = fltarr(info.jwst_data.nints,info.jwst_data.ngroups,1)
    x[0] = xvalue & y[0]  = yvalue
    jwst_get_pixeldata,info,1,x,y,pixeldata
endif else begin
    pixeldata = (*info.jwst_data.pimagedata)[*,*,xvalue,yvalue]
endelse
end

;_______________________________________________________________________
; read in reduced values for pixel
pro jwst_mql_read_slopedata,x,y,info
slope_exist = info.jwst_control.file_slope_exist
if(slope_exist eq 0) then return

slopes = fltarr(info.jwst_data.nints+1)

jwst_get_slopepixel,info,x,y,slopedata,slopefinal,status
slopes[0] = slopefinal
slopes[1:info.jwst_data.nints] = slopedata
if(ptr_valid(info.jwst_image.pslope_pixeldata)) then ptr_free, info.jwst_image.pslope_pixeldata
info.jwst_image.pslope_pixeldata = ptr_new(slopes)

end

;_______________________________________________________________________
pro jwst_mql_read_refpix_data,xvalue,yvalue,info
; x_pos, y_pos starts at 0
x = intarr(1) & y = intarr(1)
pixeldata = fltarr(info.jwst_data.nints,info.jwst_data.ngroups,1)
x[0] = xvalue & y[0]  = yvalue
jwst_get_refpix_pixeldata,info,1,x,y,pixeldata
if(ptr_valid(info.jwst_image.prefpix_pixeldata)) then ptr_free, info.jwst_image.prefpix_pixeldata

info.jwst_image.prefpix_pixeldata = ptr_new(pixeldata)
end
;_______________________________________________________________________
pro jwst_mql_read_lin_data,xvalue,yvalue,info
; x_pos, y_pos starts at 0
x = intarr(1) & y = intarr(1)
pixeldata = fltarr(info.jwst_data.nints,info.jwst_data.ngroups,1)
x[0] = xvalue & y[0]  = yvalue
jwst_get_lin_pixeldata,info,1,x,y,pixeldata

if(ptr_valid(info.jwst_image.plin_pixeldata)) then ptr_free, info.jwst_image.plin_pixeldata
info.jwst_image.plin_pixeldata = ptr_new(pixeldata)
end
;_______________________________________________________________________
pro jwst_mql_read_dark_data,xvalue,yvalue,info
; x_pos, y_pos starts at 0
x = intarr(1) & y = intarr(1)
pixeldata = fltarr(info.jwst_data.nints,info.jwst_data.ngroups,1)
x[0] = xvalue & y[0]  = yvalue
jwst_get_dark_pixeldata,info,1,x,y,pixeldata

if(ptr_valid(info.jwst_image.pdark_pixeldata)) then ptr_free, info.jwst_image.pdark_pixeldata
info.jwst_image.pdark_pixeldata = ptr_new(pixeldata)
end
;_______________________________________________________________________
pro jwst_mql_read_reset_data,xvalue,yvalue,info
; x_pos, y_pos starts at 0
x = intarr(1) & y = intarr(1)
pixeldata = fltarr(info.jwst_data.nints,info.jwst_data.ngroups,1)
x[0] = xvalue & y[0]  = yvalue
jwst_get_reset_pixeldata,info,1,x,y,pixeldata
if(ptr_valid(info.jwst_image.preset_pixeldata)) then ptr_free, info.jwst_image.preset_pixeldata
info.jwst_image.preset_pixeldata = ptr_new(pixeldata)
end

;_______________________________________________________________________%
pro jwst_mql_read_rscd_data,xvalue,yvalue,info
; x_pos, y_pos starts at 0
x = intarr(1) & y = intarr(1)
pixeldata = fltarr(info.jwst_data.nints,info.jwst_data.ngroups,1)
x[0] = xvalue & y[0]  = yvalue
jwst_get_rscd_pixeldata,info,1,x,y,pixeldata
if(ptr_valid(info.jwst_image.prscd_pixeldata)) then ptr_free, info.jwst_image.prscd_pixeldata
info.jwst_image.prscd_pixeldata = ptr_new(pixeldata)
end

;_______________________________________________________________________
pro jwst_mql_read_lastframe_data,xvalue,yvalue,info
; x_pos, y_pos starts at 0
x = intarr(1) & y = intarr(1)
pixeldata = fltarr(info.jwst_data.nints,1)
x[0] = xvalue & y[0]  = yvalue
jwst_get_lastframe_pixeldata,info,1,x,y,pixeldata
if(ptr_valid(info.jwst_image.plastframe_pixeldata)) then ptr_free, info.jwst_image.plastframe_pixeldata
info.jwst_image.plastframe_pixeldata = ptr_new(pixeldata)
end

;_______________________________________________________________________
pro jwst_get_pixeldata,info,num,x,y,pixeldata
; x,y start at 0 (included reference pixel values)

message = info.jwst_data.nints*info.jwst_data.ngroups
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
if(info.jwst_control.file_raw_exist eq 0 )then begin
    pixeldata[*,*] = 0
    if(imessage) then begin 
        progressBar -> Destroy
        obj_destroy, progressBar
    endif
    return
endif
; for the selected pixels - find the frame values for the entire exposure
fits_open,info.jwst_control.filename_raw,fcb
im_raw = readfits(info.jwst_control.filename_raw,/silent,exten_no=1) 
fits_close,fcb
ngroups = info.jwst_data.ngroups

for integ = 0, info.jwst_data.nints -1 do begin
    if(imessage) then begin
        percent = (float(integ)/float(info.jwst_data.nints) * 99)
        progressBar -> Update,percent
    endif

   for iramp = 0,ngroups -1 do begin
      for k = 0,num -1 do begin
         xvalue = x[0]          ; 
         yvalue = y[0] 
         value  = im_raw[xvalue,yvalue,iramp,integ]
         pixeldata[integ,iramp,k] = value
      endfor
   endfor
endfor
im_raw = 0

if(imessage) then begin 
    progressBar -> Destroy
    obj_destroy, progressBar
endif

end

; _______________________________________________________________________
pro jwst_get_slopepixel,info,x,y,slopepixel,slopefinal,status
; x,y start at 0 (included reference pixel values)

message = info.jwst_data.nints
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

fits_open,info.jwst_control.filename_slope,fcb
fits_read,fcb,data,header,exten_no = 1
slopefinal = data[x,y,0]
fits_close,fcb

slopepixel = fltarr(info.jwst_data.nints)
if(info.jwst_control.file_slope_int_exist eq 1) then begin 
   fits_open,info.jwst_control.filename_slope_int,fcb
   fits_read,fcb,data,header,exten_no = 1
   for integ =0,info.jwst_data.nints-1 do begin
      slopepixel[integ] = data[x,y,integ]
   endfor
   fits_close,fcb
endif
end

;_______________________________________________________________________
pro jwst_get_refpix_pixeldata,info,num,x,y,pixeldata
; x,y start at 0 (included reference pixel values)

message = info.jwst_data.nints*info.jwst_data.ngroups
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

fits_open,info.jwst_control.filename_refpix,fcb
im_raw = readfits(info.jwst_control.filename_refpix,/silent,exten_no=1)
ngroups = info.jwst_data.ngroups
fits_close,fcb 
for integ = 0, info.jwst_data.nints -1 do begin
    if(imessage) then begin 
        percent = (float(integ)/float(info.jwst_data.nints) * 99)
        progressBar -> Update,percent
    endif

   for iramp = 0,ngroups -1 do begin
       for k = 0, num-1 do begin
           xvalue = x[k]        ; 
           yvalue = y[k] 
           value  = im_raw[x,y,iramp,integ]
           pixeldata[integ,iramp,k] = value
       endfor
   endfor

endfor
im_raw = 0
if(imessage) then begin
    progressBar -> Destroy
    obj_destroy, progressBar
endif
end
;_______________________________________________________________________

;_______________________________________________________________________
pro jwst_get_lin_pixeldata,info,num,x,y,pixeldata
; x,y start at 0 (included reference pixel values)

message = info.jwst_data.nints*info.jwst_data.ngroups
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

im_raw = readfits(info.jwst_control.filename_linearity,/silent,exten_no=1)
ngroups = info.jwst_data.ngroups

for integ = 0, info.jwst_data.nints -1 do begin
    if(imessage) then begin 
        percent = (float(integ)/float(info.jwst_data.nints) * 99)
        progressBar -> Update,percent
    endif
   for iramp = 0,ngroups -1 do begin
       for k = 0, num-1 do begin
           xvalue = x[k]        ; 
           yvalue = y[k] 
           value  = im_raw[xvalue,yvalue]
           pixeldata[integ,iramp,k] = value
       endfor
   endfor
endfor
im_raw = 0
if(imessage) then begin
    progressBar -> Destroy
    obj_destroy, progressBar
endif
end

;_______________________________________________________________________
pro jwst_get_dark_pixeldata,info,num,x,y,pixeldata
; x,y start at 0 (included reference pixel values)

message = info.jwst_data.nints*info.jwst_data.ngroups
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
im_raw = readfits(info.jwst_control.filename_dark,/silent,exten_no=1) 
for integ = 0, info.jwst_data.nints -1 do begin
    if(imessage) then begin 
        percent = (float(integ)/float(info.jwst_data.nints) * 99)
        progressBar -> Update,percent
    endif
   ngroups = info.jwst_data.ngroups

   for iramp = 0,ngroups -1 do begin
       for k = 0, num-1 do begin

           xvalue = x[k]        ; 
           yvalue = y[k] 
;           nxy = long(info.jwst_data.dark_xsize) * long(info.jwst_data.dark_ysize)
;           firstvalue = long(yvalue)*long(info.jwst_data.id_xsize) + long(xvalue)
;           istart = long(nxy) * long(iramp) + (  long(integ) * long(ngroups) * long(nxy))
;           firstvalue = firstvalue + istart
;           lastvalue  = long(firstvalue)
;           if(lastvalue le 1) then begin ; fits_read will fail for this case
;               im_raw = readfits(info.jwst_control.filename_dark,nslice = j,/silent) 
               value  = im_raw[xvalue,yvalue]
               pixeldata[integ,iramp,k] = value
               
;           endif else begin 
;               if(j gt 500) then begin ; 2 gigabyte limit for bitpix = 32
;                   im_raw = readfits(info.jwst_control.filename_dark,nslice = j,/silent) 
;                   dn  = im_raw[xvalue,yvalue]
;               endif else begin 
;                   fits_read,fcb,dn,hdr,first = firstvalue,last = lastvalue,exten_no = 1
;               endelse
;               pixeldata[integ,iramp,k] = dn
;           endelse
       endfor
   endfor

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
pro jwst_get_reset_pixeldata,info,num,x,y,pixeldata
; x,y start at 0 (included reference pixel values)

message = info.jwst_data.nints*info.jwst_data.ngroups
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

ngroups = info.jwst_data.ngroups
im_raw = readfits(info.jwst_control.filename_reset,/silent) 
for integ = 0, info.jwst_data.nints -1 do begin
    if(imessage) then begin 
        percent = (float(integ)/float(info.jwst_data.nints) * 99)
        progressBar -> Update,percent
    endif

   for iramp = 0,ngroups -1 do begin
       for k = 0, num-1 do begin
           xvalue = x[k]        ; 
           yvalue = y[k] 
           value  = im_raw[xvalue,yvalue]
           pixeldata[integ,iramp,k] = value
       endfor
   endfor
endfor
im_raw = 0

if(imessage) then begin
    progressBar -> Destroy
    obj_destroy, progressBar
endif

end




;_______________________________________________________________________
pro jwst_get_rscd_pixeldata,info,num,x,y,pixeldata
; x,y start at 0 (included reference pixel values)

message = info.jwst_data.nints*info.jwst_data.ngroups
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

im_raw = readfits(info.jwst_control.filename_rscd,exten_no=1,/silent)
for integ = 0, info.jwst_data.nints -1 do begin
    if(imessage) then begin 
        percent = (float(integ)/float(info.jwst_data.nints) * 99)
        progressBar -> Update,percent
    endif

   ngroups = info.jwst_data.ngroups
   for iramp = 0,ngroups -1 do begin
       for k = 0, num-1 do begin
           xvalue = x[k]        ; 
           yvalue = y[k] 
           value  = im_raw[xvalue,yvalue]
           pixeldata[integ,iramp,k] = value
       endfor
   endfor
endfor
im_raw = 0

if(imessage) then begin
    progressBar -> Destroy
    obj_destroy, progressBar
endif

end



;_______________________________________________________________________
pro jwst_get_lastframe_pixeldata,info,num,x,y,pixeldata
; x,y start at 0 (included reference pixel values)

; _______________________________________________________________________
; for the selected pixels - find the frame values for the entire exposure

  im = readfits(info.jwst_control.filename_lastframe,exten_no=1,/silent) 
for integ = 0, info.jwst_data.nints -1 do begin
   for k = 0, num-1 do begin
      
      xvalue = x[k]             ; 
      yvalue = y[k] 
      
      value  = im[xvalue,yvalue]
      pixeldata[integ,k] = value
   endfor
endfor
im_raw = 0
end

