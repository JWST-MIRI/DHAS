pro read_multi_frames,info

widget_control,/hourglass
progressBar = Obj_New("ShowProgress", color = 150, $
                      message = " Reading in Raw Data",$
                      xsize = 250, ysize = 40)
progressBar -> Start
this_integration = info.data.nints
if(info.data.read_all eq 0) then begin
    this_integration = 1
endif
this_num_frames = info.data.nramps

image_cube = fltarr(this_integration,info.data.num_frames,info.data.image_xsize,info.data.image_ysize)
image_stat = fltarr(this_integration,info.data.num_frames,9)
image_range = fltarr(this_integration,info.data.num_frames,2)


numbad = 0
if(info.control.display_apply_bad) then begin
    badmask = (*info.badpixel.pmask)[*,*]
    index_bad = where(badmask  and 1,numbad)
    badmask = 0 
endif
nvalid = long(1024) * long(1024)
if(info.data.subarray eq 1) then nvalid= long(info.data.image_xsize) * long(info.data.image_ysize)


; read all set to true - so read in all the images
;  _______________________________________________________________________
if(info.data.read_all eq 1) then begin ; read all the data in

;    print,'reading all the  images'
    fits_open,info.control.filename_raw,fcb
    
    fits_read,fcb,cube_raw,header_raw
    itot = 0

    ntot = info.data.nints * info.data.nramps
    nupdate = 0
    nint = info.data.nints
    for integ = 0, nint -1 do begin 
        nramps = info.data.nramps
        for iramp = 0, nramps -1 do begin
            nupdate = nupdate + 1
            percent = (float(nupdate)/float(ntot) * 90)
            progressBar -> Update,percent
            ip = 0              ;
            il = 0;
            ir = 0
            j = iramp
            itot = (integ ) * info.data.nramps +iramp

            xsize = info.data.image_xsize
            ysize = info.data.image_ysize
            image_cube[integ,iramp,*,*] = cube_raw[0:xsize-1,0:ysize-1,itot]



            image_frame = fltarr(info.data.image_xsize,info.data.image_ysize)
            image_frame[*,*] = image_cube[integ,iramp,*,*]

            if(numbad gt 0) then image_frame[index_bad] = !values.F_NaN ; set bad pixels to NAN            

            image_noref_data= image_frame[*,*]
            if(info.data.subarray eq 0) then image_noref_data = image_frame[4:1027,*]
            if(info.data.subarray ne 0 and  info.data.colstart eq 1) then $
              image_noref_data= image_frame[4:*,*]


            image_frame = 0
;_______________________________________________________________________
            get_image_stat,image_noref_data,image_mean,stdev_pixel,image_min,image_max,$
                           irange_min,irange_max,image_median,stdev_mean,skew,ngood,nbad
            image_stat[integ,j,0] = image_mean
            image_stat[integ,j,1] = stdev_pixel
            image_stat[integ,j,2] = image_min
            image_stat[integ,j,3] = image_max
            image_stat[integ,j,4] = image_median
            image_stat[integ,j,5] = stdev_mean
            image_stat[integ,j,6] = skew
            image_stat[integ,j,7] = ngood
            image_stat[integ,j,8] = nvalid - ngood


            image_range[integ,j,0] = irange_min
            image_range[integ,j,1] = irange_max

            image_noref_data = 0      ; free memory

        endfor
    endfor
    cube_raw = 0
    header_raw = 0
endif

fits_close,fcb
;_______________________________________________________________________
if(info.data.read_all eq 0) then begin ; only read a portion of the data in

; frame start counts from 0
    m = (info.control.int_num * info.data.nramps) + info.control.frame_start


    print,'Reading integration #',info.control.int_num+1
    print,'Reading frame - to - ',info.control.frame_start+1, ' ' ,info.control.frame_end+1

    ii = 0
    this_num_frames = info.control.frame_end - info.control.frame_start +1 
    endtest = info.data.nramps*(info.control.int_num+1)


    for i = 0,this_num_frames-1 do begin 
        if(m+ i lt endtest) then begin 

        
            percent = (float(i)/float(info.control.read_limit) * 90)
            progressBar -> Update,percent

;            im_raw = readfits_miri(info.control.filename_raw,nslice = m+i,/silent)        
            im_raw = readfits(info.control.filename_raw,nslice = m+i,/silent)        

            xsize = info.data.image_xsize
            ysize = info.data.image_ysize
            image_cube[0,ii,*,*] = im_raw[0:xsize-1,0:ysize-1]

            
            image_frame = fltarr(info.data.image_xsize,info.data.image_ysize)
            image_frame[*,*] = image_cube[0,ii,*,*]
            

            if(numbad gt 0) then image_frame[index_bad] = !values.F_NaN ; set bad pixels to NAN            

            image_noref_data= image_frame[*,*]

            
            if(info.data.subarray eq 0) then image_noref_data = image_frame[4:1027,*]
            if(info.data.subarray ne 0 and  info.data.colstart eq 1) then $
              image_noref_data= image_frame[4:*,*]


            image_frame = 0
            
;_______________________________________________________________________
            get_image_stat,image_noref_data,image_mean,stdev_pixel,image_min,image_max,$
                           irange_min,irange_max,image_median,stdev_mean,skew,ngood,nbad
            image_stat[0,i,0] = image_mean
            image_stat[0,i,1] = stdev_pixel
            image_stat[0,i,2] = image_min
            image_stat[0,i,3] = image_max
            image_stat[0,i,4] = image_median
            image_stat[0,i,5] = stdev_mean
            image_stat[0,i,6] = skew
            image_stat[0,i,7] = ngood
            image_stat[0,i,8] = nvalid - ngood
            

            image_range[0,i,0] = irange_min
            image_range[0,i,1] = irange_max

            image_noref_data = 0      ; free memory
            ii = ii + 1
            im_raw = 0
        endif
    endfor                   ; end looping over ramps
endif
;_______________________________________________________________________
if ptr_valid (info.data.pimagedata) then ptr_free,info.data.pimagedata
info.data.pimagedata = ptr_new(image_cube)
image_cube = 0 ; free memory

if ptr_valid (info.image.pstat) then ptr_free,info.image.pstat
info.image.pstat = ptr_new(image_stat)
image_stat = 0 ; free memory

if ptr_valid (info.image.prange) then ptr_free,info.image.prange
info.image.prange = ptr_new(image_range)
image_range = 0 ; free memory


;_______________________________________________________________________
;
; stats on images, image_stat[mean,sigma,min,max]
;                  image_range[min,max] starting values for min,max dsplay range

percent = 99
progressBar -> Update,percent






;_______________________________________________________________________

progressBar -> Destroy
obj_destroy, progressBar

end
