pro get_pltracking,group,info
; arrays (x,y,ch)  initialized to correct size in read_pixel_tracking_file 
; arrays (data,refdata)  initialized to correct size in read_pixel_tracking_file 

widget_control,/hourglass
if(group eq 0 ) then report = "Reading in Pixel data for First Set of Pixels"
if(group eq 1) then report = "Reading in Pixel data for Second Set of Pixels"
if(group eq 2) then report = "Reading in Pixel data for Random Set of Pixels"
if(group eq 3) then report = "Reading in Pixel  data for User Set of Pixels"

progressBar = Obj_New("ShowProgress", color = 150, $
                      message = report,xsize = 250, ysize = 40)

progressBar -> Start



ind = group ; 0 pixel tracking file first 4 pixels
                    ; 1 pixel tracking file second  4 pixels
                    ; 2 random
	            ; 3 user defined

;/Pixel Look Tool Data
xdata = (*info.pltrack.px)[ind,*]
ydata = (*info.pltrack.py)[ind,*]
channel5 = (*info.pltrack.pref)[ind,*] ; 0 or 1 - 1 indicates get the
                                      ; reference value for pixel
num = info.pltrack.num_group[ind]
; values to fill in - some of which may already be filled in 
pixeldata  = (*info.pltrack.pdata)
refdata  = (*info.pltrack.prefdata)
pixelstat = (*info.pltrack.pstat)
ch = (*info.pltrack.pch)



;_______________________________________________________________________

for i = 0, num-1 do begin
    chvalue = 0
    if(channel5[0,i] eq 0) then begin
        get_channel,xdata[0,i],chvalue	
        ch[ind,i] = chvalue

    endif else begin
        ch[ind,i] = 5
    endelse

endfor


; _______________________________________________________________________
; for the selected pixels - find the frame values for the entire exposure
j = 0
ntot = info.data.nints * info.data.nramps
nupdate = 0


; define these:


for integ = 0, info.data.nints -1 do begin
    for iramp = 0, info.data.nramps -1 do begin
        nupdate = nupdate + 1
        percent = (float(nupdate)/float(ntot) * 90)
        progressBar -> Update,percent
        im_raw = readfits(info.control.filename_raw,nslice = j,/silent) 

        b = size(im_raw)

        if(info.data.subarray eq 0 ) then begin ; not sub array data
            xsize = 1032
            ystart = 1024
            yend = 1280
        endif
        if(info.data.subarray ne 0) then begin ; sub array data
            xsize = info.data.image_xsize
            ystart = info.data.image_ysize
            yend = info.data.image_ysize + info.data.ref_xsize 
        endif

        refnew  = fltarr(info.data.ref_xsize, info.data.ref_ysize)
        ;refout = im_raw[*,info.data.image_ysize:*]
        refout = 0 
        refnew[*,*] = refout

        
        
       for k = 0, num-1 do begin
           
           if(channel5[0,k] eq 0) then begin ; not a reference output pixel
               xvalue = xdata[0,k] -1 ;
               yvalue = ydata[0,k] -1
               value  = im_raw[xvalue,yvalue]
               pixeldata[ind,integ,iramp,k] = value
                                ; find corresponding reference output
               ix = fix(  xvalue/4)

               refdata[ind,integ,iramp,k] = refnew[ix,yvalue]


               
           endif
           
           if(channel5[0,k] eq 1) then begin ; reference output pixel
               xvalue = xdata[0,k]  -1
               xvalue = xvalue/4 ; working with reference output image
               yvalue = ydata[0,k] -1
               value = refnew[xvalue,yvalue]
               pixeldata[ind,integ,iramp,k] = value
               refdata[ind,integ,iramp,k] = value
           endif
        endfor
        j = j + 1
        im_raw = 0
        refout = 0
        refnew = 0
    endfor
endfor


for integ = 0, info.data.nints -1 do begin
    for k = 0, num-1 do begin
        sdata = pixeldata[ind,integ,*,k]
        smax = max(sdata)
        smin = min(sdata)
        pixelstat[ind,integ,k,0] = smin
        pixelstat[ind,integ,k,1] = smax
    endfor
endfor

fits_close,fcb
;_______________________________________________________________________


;_______________________________________________________________________

if ptr_valid (info.pltrack.pch) then ptr_free,info.pltrack.pch
info.pltrack.pch = ptr_new(ch)

if ptr_valid (info.pltrack.pdata) then ptr_free,info.pltrack.pdata
info.pltrack.pdata = ptr_new(pixeldata)

if ptr_valid (info.pltrack.prefdata) then ptr_free,info.pltrack.prefdata
info.pltrack.prefdata = ptr_new(refdata)

if ptr_valid (info.pltrack.pstat) then ptr_free,info.pltrack.pstat
info.pltrack.pstat = ptr_new(pixelstat)

    
refnew = 0
pixelstat= 0 ; free memory
refdata = 0 ; free memory
pixeldata = 0 ; free memory
ch = 0 ; free memory
progressBar -> Destroy
obj_destroy, progressBar

end
