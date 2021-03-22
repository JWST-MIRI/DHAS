pro jwst_read_multi_frames,info

widget_control,/hourglass
progressBar = Obj_New("ShowProgress", color = 150, $
                      message = " Reading in Raw Data",$
                      xsize = 250, ysize = 40)
progressBar -> Start
this_integration = info.jwst_data.nints
if(info.jwst_data.read_all eq 0) then begin
    this_integration = 1
endif
this_num_frames = info.jwst_data.ngroups

image_cube = fltarr(this_integration,info.jwst_data.num_frames,info.jwst_data.image_xsize,info.jwst_data.image_ysize)
image_stat = fltarr(this_integration,info.jwst_data.num_frames,6)
;help,image_cube
image_range = fltarr(this_integration,info.jwst_data.num_frames,2)


nvalid = long(1024) * long(1024)
if(info.jwst_data.subarray eq 1) then nvalid= long(info.jwst_data.image_xsize) * long(info.jwst_data.image_ysize)

; read all set to true - so read in all the images
;  _______________________________________________________________________
if(info.jwst_data.read_all eq 1) then begin ; read all the data in

    fits_open,info.jwst_control.filename_raw,fcb
    fits_read,fcb,cube_raw,header_raw,exten_no = 1

    ntot = info.jwst_data.nints * info.jwst_data.ngroups
    nupdate = 0
    nint = info.jwst_data.nints
    for integ = 0, nint -1 do begin 
        ngroups = info.jwst_data.ngroups
        for iramp = 0, ngroups -1 do begin
            nupdate = nupdate + 1
            percent = (float(nupdate)/float(ntot) * 90)
            progressBar -> Update,percent
            ip = 0              ;
            il = 0;
            ir = 0
            j = iramp
            
            xsize = info.jwst_data.image_xsize
            ysize = info.jwst_data.image_ysize
            image_cube[integ,iramp,*,*] = cube_raw[*,*,iramp,integ]

            image_frame = fltarr(info.jwst_data.image_xsize,info.jwst_data.image_ysize)
            image_frame[*,*] = image_cube[integ,iramp,*,*]

            image_noref_data= image_frame[*,*]
            if(info.jwst_data.subarray eq 0) then image_noref_data = image_frame[4:1027,*]
            if(info.jwst_data.subarray ne 0 and  info.jwst_data.colstart eq 1) then $
              image_noref_data= image_frame[4:*,*]

            image_frame = 0
;_______________________________________________________________________
            jwst_get_image_stat,image_noref_data,image_mean,stdev_pixel,image_min,image_max,$
                           irange_min,irange_max,image_median,stdev_mean
            image_stat[integ,j,0] = image_mean
            image_stat[integ,j,1] = stdev_pixel
            image_stat[integ,j,2] = image_min
            image_stat[integ,j,3] = image_max
            image_stat[integ,j,4] = image_median
            image_stat[integ,j,5] = stdev_mean

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
if(info.jwst_data.read_all eq 0) then begin ; only read a portion of the data in

; frame start counts from 0
    print,'Reading integration #',info.jwst_control.int_num+1
    print,'Reading frame - to - ',info.jwst_control.frame_start+1, ' ' ,info.jwst_control.frame_end+1

    this_num_frames = info.jwst_control.frame_end - info.jwst_control.frame_start +1 

    ; read in data 
    fits_open,info.jwst_control.filename_raw,fcb
    fits_read,fcb,im_raw,header_raw,exten_no = 1

    fits_close,fcb
    ; pull out what is needed - only 1 integration 
    ; frames: frame_start:frame_end
    for j = 0,info.jwst_data.num_frames-1 do begin
       image = im_raw[*,*,j+info.jwst_control.frame_start,0]
       image_cube[0,j,*,*] = image
       image = 0 
    endfor
    
    im_raw = 0 
    ; work on stats for each frame 
    for i = 0,this_num_frames-1 do begin
       percent = (float(i)/float(info.jwst_control.read_limit) * 90)
       progressBar -> Update,percent

       xsize = info.jwst_data.image_xsize
       ysize = info.jwst_data.image_ysize
            
       image_frame = fltarr(info.jwst_data.image_xsize,info.jwst_data.image_ysize)
       image_frame[*,*] = image_cube[0,i,*,*]
       image_noref_data= image_frame[*,*]
       if(info.jwst_data.subarray eq 0) then image_noref_data = image_frame[4:1027,*]
       if(info.jwst_data.subarray ne 0 and  info.jwst_data.colstart eq 1) then $
          image_noref_data= image_frame[4:*,*]

       image_frame = 0
;_______________________________________________________________________
       jwst_get_image_stat,image_noref_data,image_mean,stdev_pixel,image_min,image_max,$
                      irange_min,irange_max,image_median,stdev_mean
       image_stat[0,i,0] = image_mean
       image_stat[0,i,1] = stdev_pixel
       image_stat[0,i,2] = image_min
       image_stat[0,i,3] = image_max
       image_stat[0,i,4] = image_median
       image_stat[0,i,5] = stdev_mean

       image_range[0,i,0] = irange_min
       image_range[0,i,1] = irange_max
       
       image_noref_data = 0          ; free memory
    endfor                   ; end looping over ramps
endif
;_______________________________________________________________________
if ptr_valid (info.jwst_data.pimagedata) then ptr_free,info.jwst_data.pimagedata
info.jwst_data.pimagedata= ptr_new(image_cube)
image_cube = 0 ; free memory

if ptr_valid (info.jwst_image.pstat) then ptr_free,info.jwst_image.pstat
info.jwst_image.pstat = ptr_new(image_stat)
image_stat = 0 ; free memory

if ptr_valid (info.jwst_image.prange) then ptr_free,info.jwst_image.prange
info.jwst_image.prange = ptr_new(image_range)
image_range = 0 ; free memory


;_______________________________________________________________________

percent = 99
progressBar -> Update,percent
;_______________________________________________________________________

progressBar -> Destroy
obj_destroy, progressBar

end
