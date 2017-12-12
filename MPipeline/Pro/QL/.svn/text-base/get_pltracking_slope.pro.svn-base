pro get_pltracking_slope,group,info ; called from Pixel Look
; always run get_pltracking before getting the slope

; arrays (x,y,ch)  initialized to correct size in read_pixel_tracking_file 
; arrays (data,refdata)  initialized to correct size in read_pixel_tracking_file 


widget_control,/hourglass
if(group eq 0 ) then report = "Reading in Pixel slope data for First Set of Pixels"
if(group eq 1) then report = "Reading in Pixel slope data for Second Set of Pixels"
if(group eq 2) then report = "Reading in Pixel slope data for Random Set of Pixels"
if(group eq 3) then report = "Reading in Pixel slope data for User Set of Pixels"

progressBar = Obj_New("ShowProgress", color = 150, $
                      message = report,xsize = 250, ysize = 40)

progressBar -> Start


ind = group ; 0 pixel tracking file first 4 pixels
                    ; 1 pixel tracking file second  4 pixels
                    ; 2 random
	            ; 3 user defined
 

xdata = (*info.pltrack.px)[ind,*]
ydata = (*info.pltrack.py)[ind,*]
channel5 = (*info.pltrack.pref)[ind,*] ; 0 or 1 - 1 indicates get the
                                ; reference value for pixel
num = info.pltrack.num_group[ind]

; values to fill in - some of which may already be filled in 
slope  = (*info.pltrack.pslope)
unc = (*info.pltrack.punc)
id = (*info.pltrack.pid)
zeropt = (*info.pltrack.pzeropt)
numgood = (*info.pltrack.pnumgood)
firstsat = (*info.pltrack.pfirstsat)
nseg = (*info.pltrack.pnseg)


rms = (*info.pltrack.prms)

max2pt = (*info.pltrack.pmax2ptdiff)
imax2pt = (*info.pltrack.pimax2ptdiff)
stdev2pt = (*info.pltrack.pstdev2ptdiff)
slope2pt = (*info.pltrack.pslope2ptdiff)
              
; check to see if slope image of reference image exists

file_exist2 = file_test(info.control.filename_slope_refimage,/regular,/read)
; _______________________________________________________________________
; for the selected pixels - find the frame values for the entire exposure
ntot = info.data.nslopes * info.data.nramps
nupdate = 0


fits_open,info.control.filename_slope,fcb
if(file_exist2)then  fits_open,info.control.filename_slope_refimage,fcb2


for integ = 0, info.data.nslopes -1 do begin
    nupdate = nupdate + 1

    percent = (float(nupdate)/float(ntot) * 90)
    progressBar -> Update,percent


    fits_read,fcb,slope_image,exten_no = integ+1
    if(file_exist2) then fits_read,fcb2,ref_image,exten_no = integ+ 1

    b = size(slope_image)
    info.pltrack.xsize_data = b[1]
    info.pltrack.ysize_data = b[2]
    info.pltrack.zsize_data = b[3]

    for k = 0, num-1 do begin
        if(channel5[0,k] eq 0) then begin ; not a reference output pixel

            xvalue = xdata[0,k]  -1 ; 
            yvalue = ydata[0,k] -1

            unc[ind,integ,k] = -99
            id[ind,integ,k] = -99
            zeropt[ind,integ,k] = -99.0
            numgood[ind,integ,k] = -99
            nseg[ind,integ,k] = -99
            firstsat[ind,integ,k] = -99
            rms[ind,integ,k] = -99
            max2pt[ind,integ,k] = -99
            imax2pt[ind,integ,k] = -99
            stdev2pt[ind,integ,k] = -99
            slope2pt[ind,integ,k] = -99
            

            
            slope[ind,integ,k] = slope_image[xvalue,yvalue,0] 
            if(b[3] eq 2) then begin
                zeropt[ind,integ,k] = slope_image[xvalue,yvalue,1]
            endif

            if(b[3] eq 3) then begin
                zeropt[ind,integ,k] = slope_image[xvalue,yvalue,1]
                rms[ind,integ,k] = slope_image[xvalue,yvalue,2] 
            endif

            if(b[3] gt 3 ) then begin 
                unc[ind,integ,k] = slope_image[xvalue,yvalue,1] 
                id[ind,integ,k] = slope_image[xvalue,yvalue,2]
                zeropt[ind,integ,k] = slope_image[xvalue,yvalue,3] 
                numgood[ind,integ,k] = slope_image[xvalue,yvalue,4] 
                firstsat[ind,integ,k] = slope_image[xvalue,yvalue,5]
                if(b[3] gt 6) then  nseg[ind,integ,k] = slope_image[xvalue,yvalue,6]

                if(b[3] gt 7) then  rms[ind,integ,k] = slope_image[xvalue,yvalue,7] 
 

                if(b[3] gt 8) then begin 

                    max2pt[ind,integ,k] = slope_image[xvalue,yvalue,8] 
                    imax2pt[ind,integ,k] = slope_image[xvalue,yvalue,9] 
                    stdev2pt[ind,integ,k] = slope_image[xvalue,yvalue,10] 
                    slope2pt[ind,integ,k] = slope_image[xvalue,yvalue,11] 
                endif
            endif 

        endif
           
        if(channel5[0,k] eq 1) then begin ; reference output pixel
            if(file_exist2) then begin
                xvalue = xdata[0,k]  -1
                xvalue = xvalue/4 ; working with reference output image
                yvalue = ydata[0,k] -1

                slope[ind,integ,k] = -99.0
                unc[ind,integ,k] = -99.9
                id[ind,integ,k] = -99
                zeropt[ind,integ,k] = -99.0
                numgood[ind,integ,k] = -99
                firstsat[ind,integ,k] = -99

                max2pt[ind,integ,k] = -99
                imax2pt[ind,integ,k] = -99
                stdev2pt[ind,integ,k] = -99
                slope2pt[ind,integ,k] = -99

                slope[ind,integ,k] = ref_image[xvalue,yvalue,0] 
                if(b[3] eq 2) then begin
                    zeropt[ind,integ,k] = ref_image[xvalue,yvalue,1] 
                endif else begin 
                    unc[ind,integ,k] = ref_image[xvalue,yvalue,1] 
                    id[ind,integ,k] = ref_image[xvalue,yvalue,2]
                endelse
                if(b[3] gt 3) then begin 
                    zeropt[ind,integ,k] = ref_image[xvalue,yvalue,3] 
                    numgood[ind,integ,k] = ref_image[xvalue,yvalue,4] 
                    firstsat[ind,integ,k] = ref_image[xvalue,yvalue,5]
                    max2pt[ind,integ,k] = -99
                    imax2pt[ind,integ,k] = -99
                    stdev2pt[ind,integ,k] = -99
                    slope2pt[ind,integ,k] = -99
                endif
            endif 

        endif


    endfor ; loop over k
        
    slope_image = 0
    ref_image= 0
endfor


fits_close,fcb
if(file_exist2)then  fits_close,fcb2
;_______________________________________________________________________


;_______________________________________________________________________

if ptr_valid (info.pltrack.pslope) then ptr_free,info.pltrack.pslope
info.pltrack.pslope = ptr_new(slope)
    
if ptr_valid (info.pltrack.punc) then ptr_free,info.pltrack.punc
info.pltrack.punc = ptr_new(unc)
    
if ptr_valid (info.pltrack.pid) then ptr_free,info.pltrack.pid
info.pltrack.pid = ptr_new(id)
    
if ptr_valid (info.pltrack.pzeropt) then ptr_free,info.pltrack.pzeropt
info.pltrack.pzeropt = ptr_new(zeropt)

if ptr_valid (info.pltrack.pnumgood) then ptr_free,info.pltrack.pnumgood
info.pltrack.pnumgood = ptr_new(numgood)

if ptr_valid (info.pltrack.pfirstsat) then ptr_free,info.pltrack.pfirstsat
info.pltrack.pfirstsat = ptr_new(firstsat)

if ptr_valid (info.pltrack.pnseg) then ptr_free,info.pltrack.pnseg
info.pltrack.pnseg = ptr_new(nseg)

if ptr_valid (info.pltrack.prms) then ptr_free,info.pltrack.prms
info.pltrack.prms = ptr_new(rms)

if ptr_valid (info.pltrack.pmax2ptdiff) then ptr_free,info.pltrack.pmax2ptdiff
info.pltrack.pmax2ptdiff = ptr_new(max2pt)

if ptr_valid (info.pltrack.pimax2ptdiff) then ptr_free,info.pltrack.pimax2ptdiff
info.pltrack.pimax2ptdiff = ptr_new(imax2pt)

if ptr_valid (info.pltrack.pslope2ptdiff) then ptr_free,info.pltrack.pslope2ptdiff
info.pltrack.pslope2ptdiff = ptr_new(slope2pt)

if ptr_valid (info.pltrack.pstdev2ptdiff) then ptr_free,info.pltrack.pstdev2ptdiff
info.pltrack.pstdev2ptdiff = ptr_new(stdev2pt)

pfirstsat = 0 ; free memory
pnseg = 0 ; free memory
prms = 0 ; free memory
pnumgood = 0 ; free memory
pzeropt = 0 ; free memory
pid = 0 ; free memory
unc = 0 ; free memory
slope = 0
max2pt = 0
imax2pt = 0
stdev2pt = 0
slope2pt = 0
progressBar -> Destroy
obj_destroy, progressBar

end


;***************************************************************************************
pro get_pltracking_refcorrected,group,info
; arrays (x,y,ch)  initialized to correct size in read_pixel_tracking_file 
; arrays (data,refdata)  initialized to correct size in read_pixel_tracking_file 

widget_control,/hourglass
if(group eq 0 ) then report = "Reading in Reference Corrected Pixel data for First Set of Pixels"
if(group eq 1) then report = "Reading in Reference Corrected Pixel data for Second Set of Pixels"
if(group eq 2) then report = "Reading in Reference Corrected Pixel data for Random Set of Pixels"
if(group eq 3) then report = "Reading in Reference Corrected Pixel  data for User Set of Pixels"

progressBar = Obj_New("ShowProgress", color = 150, $
                      message = report,xsize = 250, ysize = 40)

progressBar -> Start


ind = group ; 0 pixel tracking file first 4 pixels
                    ; 1 pixel tracking file second  4 pixels
                    ; 2 random
	            ; 3 user defined



    xdata = (*info.pltrack.px)[ind,*]
    ydata = (*info.pltrack.py)[ind,*]
    channel5 = (*info.pltrack.pref)[ind,*] ; 0 or 1 - 1 indicates get the
                                      ; reference value for pixel
    num = info.pltrack.num_group[ind]


    refcorrected_data  = (*info.pltrack.prefcorrectdata)

;print,' num going to get values for',num
;_______________________________________________________________________




; _______________________________________________________________________
; for the selected pixels - find the frame values for the entire exposure
j = 0
ntot = info.data.nslopes * info.data.nramps
nupdate = 0


for integ = 0, info.data.nslopes -1 do begin
    for iramp = 0, info.data.nramps -1 do begin
        nupdate = nupdate + 1
        percent = (float(nupdate)/float(ntot)) * 90
        progressBar -> Update,percent


;        im_raw = readfits_miri(info.control.filename_refcorrection,nslice = j,/silent) 
        im_raw = readfits(info.control.filename_refcorrection,nslice = j,/silent) 

        b = size(im_raw)

        xsize = info.data.image_xsize
        ystart = info.data.image_ysize
        
       for k = 0, num-1 do begin
           
           if(channel5[0,k] eq 0) then begin ; not a reference output pixel
               xvalue = xdata[0,k] -1 ;
               yvalue = ydata[0,k] -1
               value  = im_raw[xvalue,yvalue]
               refcorrected_data[ind,integ,iramp,k] = value
                                ; find corresponding reference output
           endif
           
           if(channel5[0,k] eq 1) then begin ; reference output pixel
               refcorrected_data[ind,integ,iramp,k] = -99.9
           endif
        endfor
        j = j + 1
        im_raw = 0

    endfor
endfor



fits_close,fcb
;_______________________________________________________________________
if ptr_valid (info.pltrack.prefcorrectdata) then ptr_free,info.pltrack.prefcorrectdata
info.pltrack.prefcorrectdata = ptr_new(refcorrected_data)

refcorrected_data = 0 ; free memory

progressBar -> Destroy
obj_destroy, progressBar

end


;***********************************************************************
pro get_pltracking_ids,group,info
; arrays (x,y,ch)  initialized to correct size in read_pixel_tracking_file 
; arrays (data,refdata)  initialized to correct size in read_pixel_tracking_file 

widget_control,/hourglass
if(group eq 0 ) then report = "Reading in Data Quality flag  for First Set of Pixels"
if(group eq 1) then report = "Reading in Data Quality flag for Second Set of Pixels"
if(group eq 2) then report = "Reading in Data Quality flag for Random Set of Pixels"
if(group eq 3) then report = "Reading in Data Quality flag  for User Set of Pixels"

progressBar = Obj_New("ShowProgress", color = 150, $
                      message = report,xsize = 250, ysize = 40)

progressBar -> Start


ind = group ; 0 pixel tracking file first 4 pixels
                    ; 1 pixel tracking file second  4 pixels
                    ; 2 random
	            ; 3 user defined



    xdata = (*info.pltrack.px)[ind,*]
    ydata = (*info.pltrack.py)[ind,*]
    channel5 = (*info.pltrack.pref)[ind,*] ; 0 or 1 - 1 indicates get the
                                      ; reference value for pixel
    num = info.pltrack.num_group[ind]


    id_data  = (*info.pltrack.piddata)

;print,' num going to get values for',num
;_______________________________________________________________________




; _______________________________________________________________________
; for the selected pixels - find the frame values for the entire exposure
j = 0
ntot = info.data.nslopes * info.data.nramps
nupdate = 0


for integ = 0, info.data.nslopes -1 do begin
    for iramp = 0, info.data.nramps -1 do begin
        nupdate = nupdate + 1
        percent = (float(nupdate)/float(ntot)) * 90
        progressBar -> Update,percent


;        im_raw = readfits_miri(info.control.filename_IDS,nslice = j,/silent) 
        im_raw = readfits(info.control.filename_IDS,nslice = j,/silent) 

        b = size(im_raw)

        xsize = info.data.image_xsize
        ystart = info.data.image_ysize
        
       for k = 0, num-1 do begin
           
           if(channel5[0,k] eq 0) then begin ; not a reference output pixel
               xvalue = xdata[0,k] -1 ;
               yvalue = ydata[0,k] -1
               value  = im_raw[xvalue,yvalue]
               id_data[ind,integ,iramp,k] = value
                                ; find corresponding reference output
           endif
           
           if(channel5[0,k] eq 1) then begin ; reference output pixel
               id_data[ind,integ,iramp,k] = -99.9
           endif
        endfor
        j = j + 1
        im_raw = 0

    endfor
endfor



fits_close,fcb
;_______________________________________________________________________
if ptr_valid (info.pltrack.piddata) then ptr_free,info.pltrack.piddata
info.pltrack.piddata = ptr_new(id_data)

id_data = 0 ; free memory

progressBar -> Destroy
obj_destroy, progressBar

end



;***********************************************************************
pro get_pltracking_lc,group,info
; arrays (x,y,ch)  initialized to correct size in read_pixel_tracking_file 
; arrays (data,refdata)  initialized to correct size in read_pixel_tracking_file 

widget_control,/hourglass
if(group eq 0 ) then report = "Reading in Data Quality flag  for First Set of Pixels"
if(group eq 1) then report = "Reading in Data Quality flag for Second Set of Pixels"
if(group eq 2) then report = "Reading in Data Quality flag for Random Set of Pixels"
if(group eq 3) then report = "Reading in Data Quality flag  for User Set of Pixels"

progressBar = Obj_New("ShowProgress", color = 150, $
                      message = report,xsize = 250, ysize = 40)

progressBar -> Start


ind = group ; 0 pixel tracking file first 4 pixels
                    ; 1 pixel tracking file second  4 pixels
                    ; 2 random
	            ; 3 user defined


    xdata = (*info.pltrack.px)[ind,*]
    ydata = (*info.pltrack.py)[ind,*]
    channel5 = (*info.pltrack.pref)[ind,*] ; 0 or 1 - 1 indicates get the
                                      ; reference value for pixel
    num = info.pltrack.num_group[ind]


    lc_data  = (*info.pltrack.plcdata)

;print,' num going to get values for',num
;_______________________________________________________________________




; _______________________________________________________________________
; for the selected pixels - find the frame values for the entire exposure
j = 0
ntot = info.data.nslopes * info.data.nramps
nupdate = 0


for integ = 0, info.data.nslopes -1 do begin
    for iramp = 0, info.data.nramps -1 do begin
        nupdate = nupdate + 1
        percent = (float(nupdate)/float(ntot)) * 90
        progressBar -> Update,percent

;        im_raw = readfits_miri(info.control.filename_LC,nslice = j,/silent) 
        im_raw = readfits(info.control.filename_LC,nslice = j,/silent) 

        b = size(im_raw)

        xsize = info.data.image_xsize
        ystart = info.data.image_ysize
        
       for k = 0, num-1 do begin
           
           if(channel5[0,k] eq 0) then begin ; not a reference output pixel
               xvalue = xdata[0,k] -1 ;
               yvalue = ydata[0,k] -1
               value  = im_raw[xvalue,yvalue]
               lc_data[ind,integ,iramp,k] = value
                                ; find corresponding reference output
           endif
           
           if(channel5[0,k] eq 1) then begin ; reference output pixel
               lc_data[ind,integ,iramp,k] = -99.9
           endif



        endfor
        j = j + 1
        im_raw = 0

    endfor
endfor



fits_close,fcb
;_______________________________________________________________________
if ptr_valid (info.pltrack.plcdata) then ptr_free,info.pltrack.plcdata
info.pltrack.plcdata = ptr_new(lc_data)


lc_data = 0 ; free memory


progressBar -> Destroy
obj_destroy, progressBar

end

;_______________________________________________________________________

pro get_pltracking_mdc,group,info
; arrays (x,y,ch)  initialized to correct size in read_pixel_tracking_file 
; arrays (data,refdata)  initialized to correct size in read_pixel_tracking_file 

widget_control,/hourglass
if(group eq 0 ) then report = "Reading in Data Quality flag  for First Set of Pixels"
if(group eq 1) then report = "Reading in Data Quality flag for Second Set of Pixels"
if(group eq 2) then report = "Reading in Data Quality flag for Random Set of Pixels"
if(group eq 3) then report = "Reading in Data Quality flag  for User Set of Pixels"

progressBar = Obj_New("ShowProgress", color = 150, $
                      message = report,xsize = 250, ysize = 40)

progressBar -> Start

   fits_open,info.control.filename_mdc,fcb
   fits_read,fcb,data,header,/header_only
   


   ind = group                  ; 0 pixel tracking file first 4 pixels
                    ; 1 pixel tracking file second  4 pixels
                    ; 2 random
	            ; 3 user defined


    xdata = (*info.pltrack.px)[ind,*]
    ydata = (*info.pltrack.py)[ind,*]
    channel5 = (*info.pltrack.pref)[ind,*] ; 0 or 1 - 1 indicates get the
                                      ; reference value for pixel
    num = info.pltrack.num_group[ind]


    mdc_data  = (*info.pltrack.pmdcdata)


;print,' num going to get values for',num

; _______________________________________________________________________
; for the selected pixels - find the frame values for the entire exposure
j = 0
ntot = info.data.nslopes * info.data.nramps
nupdate = 0


for integ = 0, info.data.nslopes -1 do begin
    for iramp = 0, info.data.nramps -1 do begin
        nupdate = nupdate + 1
        percent = (float(nupdate)/float(ntot)) * 90
        progressBar -> Update,percent


        im_raw = readfits(info.control.filename_mdc,nslice = j,/silent) 

        b = size(im_raw)

        xsize = info.data.image_xsize
        ystart = info.data.image_ysize
        
        for k = 0, num-1 do begin
           
           if(channel5[0,k] eq 0) then begin ; not a reference output pixel
               xvalue = xdata[0,k] -1 ;
               yvalue = ydata[0,k] -1
               value  = im_raw[xvalue,yvalue]
               mdc_data[ind,integ,iramp,k] = value
                                ; find corresponding reference output
           endif
           if(channel5[0,k] eq 1) then begin ; reference output pixel
               mdc_data[ind,integ,iramp,k] = -99.9
           endif
;           if(iramp eq 0) then begin 
;               im = readfits(info.control.filename_mdc,exten_no=integ+1,/silent) 
;               dn  = im[xvalue,yvalue]
;               im = 0
;           endif
        endfor
        j = j + 1
        im_raw = 0

    endfor
endfor



fits_close,fcb
;_______________________________________________________________________
if ptr_valid (info.pltrack.pmdcdata) then ptr_free,info.pltrack.pmdcdata
info.pltrack.pmdcdata = ptr_new(mdc_data)



mdc_data = 0 ; free memory


progressBar -> Destroy
obj_destroy, progressBar

end


;_______________________________________________________________________
pro get_pltracking_reset,group,info
; arrays (x,y,ch)  initialized to correct size in read_pixel_tracking_file 
; arrays (data,refdata)  initialized to correct size in read_pixel_tracking_file 

widget_control,/hourglass
if(group eq 0 ) then report = "Reading in Reset Corrected  for First Set of Pixels"
if(group eq 1) then report = "Reading in Reset Corrected  for Second Set of Pixels"
if(group eq 2) then report = "Reading in Reset Corrected for Random Set of Pixels"
if(group eq 3) then report = "Reading in Reset Corrected for User Set of Pixels"

progressBar = Obj_New("ShowProgress", color = 150, $
                      message = report,xsize = 250, ysize = 40)

progressBar -> Start

   fits_open,info.control.filename_reset,fcb
   fits_read,fcb,data,header,/header_only

   ind = group                  ; 0 pixel tracking file first 4 pixels
                    ; 1 pixel tracking file second  4 pixels
                    ; 2 random
	            ; 3 user defined


    xdata = (*info.pltrack.px)[ind,*]
    ydata = (*info.pltrack.py)[ind,*]
    channel5 = (*info.pltrack.pref)[ind,*] ; 0 or 1 - 1 indicates get the
                                      ; reference value for pixel
    num = info.pltrack.num_group[ind]
    reset_data  = (*info.pltrack.presetdata)
; _______________________________________________________________________
; for the selected pixels - find the frame values for the entire exposure
j = 0
ntot = info.data.nslopes * info.data.nramps
nupdate = 0
for integ = 0, info.data.nslopes -1 do begin
    for iramp = 0, info.data.nramps -1 do begin
        nupdate = nupdate + 1
        percent = (float(nupdate)/float(ntot)) * 90
        progressBar -> Update,percent
        im_raw = readfits(info.control.filename_reset,nslice = j,/silent) 

        b = size(im_raw)

        xsize = info.data.image_xsize
        ystart = info.data.image_ysize
        
        for k = 0, num-1 do begin
           
           if(channel5[0,k] eq 0) then begin ; not a reference output pixel
               xvalue = xdata[0,k] -1 ;
               yvalue = ydata[0,k] -1
               value  = im_raw[xvalue,yvalue]
               reset_data[ind,integ,iramp,k] = value
                                ; find corresponding reference output
           endif
           
           if(channel5[0,k] eq 1) then begin ; reference output pixel
               reset_data[ind,integ,iramp,k] = -99.9
           endif


;           if(iramp eq 0) then begin 
;               im = readfits(info.control.filename_reset,exten_no=integ+1,/silent) 
;               dn  = im[xvalue,yvalue]
;                im = 0
;           endif


        endfor
        j = j + 1
        im_raw = 0

    endfor
endfor



fits_close,fcb
;_______________________________________________________________________
if ptr_valid (info.pltrack.presetdata) then ptr_free,info.pltrack.presetdata
info.pltrack.presetdata = ptr_new(reset_data)

reset_data = 0 ; free memory
progressBar -> Destroy
obj_destroy, progressBar

end


;_______________________________________________________________________

pro get_pltracking_rscd,group,info
; arrays (x,y,ch)  initialized to correct size in read_pixel_tracking_file 
; arrays (data,refdata)  initialized to correct size in read_pixel_tracking_file 

widget_control,/hourglass
if(group eq 0 ) then report = "Reading in RSCD Corrected  for First Set of Pixels"
if(group eq 1) then report = "Reading in RSCD Corrected  for Second Set of Pixels"
if(group eq 2) then report = "Reading in RSCD Corrected for Random Set of Pixels"
if(group eq 3) then report = "Reading in RSCD Corrected for User Set of Pixels"

progressBar = Obj_New("ShowProgress", color = 150, $
                      message = report,xsize = 250, ysize = 40)

progressBar -> Start

   fits_open,info.control.filename_reset,fcb
   fits_read,fcb,data,header,/header_only

   ind = group                  ; 0 pixel tracking file first 4 pixels
                    ; 1 pixel tracking file second  4 pixels
                    ; 2 random
	            ; 3 user defined


    xdata = (*info.pltrack.px)[ind,*]
    ydata = (*info.pltrack.py)[ind,*]
    channel5 = (*info.pltrack.pref)[ind,*] ; 0 or 1 - 1 indicates get the
                                      ; reference value for pixel
    num = info.pltrack.num_group[ind]
    rscd_data  = (*info.pltrack.prscddata)
; _______________________________________________________________________
; for the selected pixels - find the frame values for the entire exposure
j = 0
ntot = info.data.nslopes * info.data.nramps
nupdate = 0
for integ = 0, info.data.nslopes -1 do begin
    for iramp = 0, info.data.nramps -1 do begin
        nupdate = nupdate + 1
        percent = (float(nupdate)/float(ntot)) * 90
        progressBar -> Update,percent
        im_raw = readfits(info.control.filename_rscd,nslice = j,/silent) 

        b = size(im_raw)

        xsize = info.data.image_xsize
        ystart = info.data.image_ysize
        
        for k = 0, num-1 do begin
           
           if(channel5[0,k] eq 0) then begin ; not a reference output pixel
               xvalue = xdata[0,k] -1 ;
               yvalue = ydata[0,k] -1
               value  = im_raw[xvalue,yvalue]
               rscd_data[ind,integ,iramp,k] = value
                                ; find corresponding reference output
           endif
           
           if(channel5[0,k] eq 1) then begin ; reference output pixel
               rscd_data[ind,integ,iramp,k] = -99.9
           endif

        endfor
        j = j + 1
        im_raw = 0

    endfor
endfor

fits_close,fcb
;_______________________________________________________________________
if ptr_valid (info.pltrack.prscddata) then ptr_free,info.pltrack.prscddata
info.pltrack.prscddata = ptr_new(rscd_data)

rscd_data = 0 ; free memory
progressBar -> Destroy
obj_destroy, progressBar

end


;_______________________________________________________________________
pro get_pltracking_lastframe,group,info
; arrays (x,y,ch)  initialized to correct size in read_pixel_tracking_file 
; arrays (data,refdata)  initialized to correct size in read_pixel_tracking_file 

print,'Reading in lastframe corrected data'


fits_open,info.control.filename_lastframe,fcb

ind = group                     ; 0 pixel tracking file first 4 pixels
                    ; 1 pixel tracking file second  4 pixels
                    ; 2 random
	            ; 3 user defined


xdata = (*info.pltrack.px)[ind,*]
ydata = (*info.pltrack.py)[ind,*]
channel5 = (*info.pltrack.pref)[ind,*] ; 0 or 1 - 1 indicates get the
                                      ; reference value for pixel
num = info.pltrack.num_group[ind]
lastframe_data  = (*info.pltrack.plastframedata)
; _______________________________________________________________________
; for the selected pixels - find the frame values for the entire exposure

for integ = 0, info.data.nslopes -1 do begin
   im = readfits(info.control.filename_lastframe,exten_no=integ+1,/silent) 
   for k = 0, num-1 do begin
      if(channel5[0,k] eq 0) then begin ; not a reference output pixel
         xvalue = xdata[0,k] -1         ;
         yvalue = ydata[0,k] -1
         value  = im[xvalue,yvalue]
         lastframe_data[ind,integ,k] = value
         value = 0 
      endif
           
      if(channel5[0,k] eq 1) then begin ; reference output pixel
         lastframe_data[ind,integ,k] = -99.9
      endif
   endfor
   im= 0
endfor

fits_close,fcb
;_______________________________________________________________________
if ptr_valid (info.pltrack.plastframedata) then ptr_free,info.pltrack.plastframedata
info.pltrack.plastframedata = ptr_new(lastframe_data)

lastframe_data = 0 ; free memory

end
