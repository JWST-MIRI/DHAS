pro read_ptracking_refpixel,info
; This program reads in the reference border pixels for the ptracking
; data and stores the information


widget_control,/hourglass
progressBar = Obj_New("ShowProgress", color = 150, $
                      message = " Reading Reference Pixels  ",$
                      xsize = 250, ysize = 40)
progressBar -> Start

ind = info.fl.group ; 0 pixel tracking file

refpL = (*info.ptrack.prefpL)
refpR = (*info.ptrack.prefpR)
ydata = (*info.ptrack.py)[ind,*]
ch = (*info.ptrack.pch)[ind,*]

total_reads = info.data.nints * info.data.nramps
ireads  = 0 
frame = 0
for integ = 0, info.data.nints -1 do begin
    for iramp = 0, info.data.nramps -1 do begin

        percent = 95.0 * float(ireads)/float(total_reads)
        ireads = ireads + 1
        progressBar -> Update,percent

;        im_raw = readfits_miri(info.control.filename_raw,nslice = frame,/silent)
        im_raw = readfits(info.control.filename_raw,nslice = frame,/silent)
	refpixel_dataL = fltarr(5,1024)
	refpixel_dataR = fltarr(5,1024)
	refpixel_dataL[0:3,*] = im_raw[0:3,0:1023]
        refpixel_dataR[0:3,*] = im_raw[1028:1031,0:1023]

        refout = fltarr(1032,256)
        refout = im_raw[*,1024:1279]
        refnew = fltarr(258,1024)
        refnew[*,*] = refout
        refout = 0

        refpixel_dataL[4,*] = refnew[0,*]
        refpixel_dataR[4,*] = refnew[257,*]
        refnew = 0
;_______________________________________________________________________


	a = indgen(1024) + 1
	index_odd = where(a mod 2)
	index_even = index_odd + 1
        for i = 0, 4 do begin
            y = ydata[0,i]
            channel = ch[0,i]
            refpL[ind,integ,iramp,i] = refpixel_dataL[channel-1,y-1]
            refpR[ind,integ,iramp,i] = refpixel_dataR[channel-1,y-1]
            ;print,'Left and Right data' , y,channel,refpixel_dataL[channel-1,y-1],refpixel_dataR[channel-1,y-1]
        endfor

        frame = frame +1
     endfor ; end looping frames
endfor ; end looping integration

percent = 99.0 
progressBar -> Update,percent


if ptr_valid (info.ptrack.prefpL) then ptr_free,info.ptrack.prefpL
info.ptrack.prefpL = ptr_new(refpL)


refpL = 0

if ptr_valid (info.ptrack.prefpR) then ptr_free,info.ptrack.prefpR
info.ptrack.prefpR = ptr_new(refpR)
refpR = 0


percent = 100.0
progressBar -> Update,percent

progressBar -> Destroy
obj_destroy, progressBar


end
;***********************************************************************

pro read_pltracking_refpixel,info
; This program reads in the reference border pixels for the ptracking
; data and stores the information


widget_control,/hourglass
progressBar = Obj_New("ShowProgress", color = 150, $
                      message = " Reading Reference Pixels  ",$
                      xsize = 250, ysize = 40)
progressBar -> Start

ind = info.pl.group ; 0 pixel tracking file

refpL = (*info.pltrack.prefpL)
refpR = (*info.pltrack.prefpR)
ydata = (*info.pltrack.py)[ind,*]
xdata = (*info.pltrack.px)[ind,*]
ch = (*info.pltrack.pch)[ind,*]


total_reads = info.data.nints * info.data.nramps
ireads  = 0 
frame = 0
for integ = 0, info.data.nints -1 do begin
    for iramp = 0, info.data.nramps -1 do begin

        percent = 95.0 * float(ireads)/float(total_reads)
        ireads = ireads + 1
        progressBar -> Update,percent

;        im_raw = readfits_miri(info.control.filename_raw,nslice = frame,/silent)
        im_raw = readfits(info.control.filename_raw,nslice = frame,/silent)
	refpixel_dataL = fltarr(5,1024)
	refpixel_dataR = fltarr(5,1024)
	refpixel_dataL[0:3,*] = im_raw[0:3,0:1023]
        refpixel_dataR[0:3,*] = im_raw[1028:1031,0:1023]

        refout = fltarr(1032,256)
        refout = im_raw[*,1024:1279]
        refnew = fltarr(258,1024)
        refnew[*,*] = refout
        refout = 0

        refpixel_dataL[4,*] = refnew[0,*]
        refpixel_dataR[4,*] = refnew[257,*]
        refnew = 0
;_______________________________________________________________________


	a = indgen(1024) + 1
	index_odd = where(a mod 2)
	index_even = index_odd + 1
        for i = 0, 4 do begin
            if(ydata[0,i] gt 0 and xdata[0,i] gt 0) then begin 
                y = ydata[0,i]
                channel = ch[0,i]
                refpL[ind,integ,iramp,i] = refpixel_dataL[channel-1,y-1]
                refpR[ind,integ,iramp,i] = refpixel_dataR[channel-1,y-1]

            endif else begin 
                refpL[ind,integ,iramp,i] = 0.0
                refpR[ind,integ,iramp,i] = 0.0
            endelse
                
        endfor

        frame = frame +1
     endfor ; end looping frames
endfor ; end looping integration

percent = 99.0 
progressBar -> Update,percent


if ptr_valid (info.pltrack.prefpL) then ptr_free,info.pltrack.prefpL
info.pltrack.prefpL = ptr_new(refpL)


refpL = 0

if ptr_valid (info.pltrack.prefpR) then ptr_free,info.pltrack.prefpR
info.pltrack.prefpR = ptr_new(refpR)
refpR = 0


percent = 100.0
progressBar -> Update,percent

progressBar -> Destroy
obj_destroy, progressBar


end


