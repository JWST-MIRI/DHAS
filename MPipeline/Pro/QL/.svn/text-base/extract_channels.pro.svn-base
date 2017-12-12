;***********************************************************************
; Seperate the data for each channel from the entire image
; Pull out the reference pixels for the purposes of determining
; statistics and putting the data in time order
; When the data is put in time order - at the end of each row - 13
; values have to be inserted to fill the time it takes to get to the
; next row

pro extract_channels,frame_image,bad_pixel,image_xsize,image_ysize,$
                     FFT_replicate_value,subarray,$
                     ref_image,ref_xsize,ref_ysize,$
                     channel_image,channel_badpixel,$
                     channel_ximage_range,channel_yimage_range,$
                     timedata,time,timeflag,timebadpixel



channel_image = fltarr(5,image_xsize/4,image_ysize)
channel_badpixel = fltarr(5,image_xsize/4,image_ysize)

channel_ximage_range = fltarr(5,2)
channel_yimage_range = fltarr(5,2)
xsize_time = 258
if(subarray ne 0) then xsize_time = image_xsize/4
tnum = (xsize_time + 11.0) * image_ysize
timedata = fltarr(5,tnum)  
time = fltarr(5,tnum)  
timeflag = fltarr(5,tnum)  
timebadpixel = fltarr(5,tnum)

for i = 0,3 do begin 
    xsize = image_xsize/4  
    ysize = image_ysize
    channel = fltarr(image_xsize/4,image_ysize)
    bad = channel
    bad[*,*] = 0
    m =0 
    for j = i,image_xsize-1,4  do begin
        channel[m,*] = frame_image[j,*]
        bad[m,*] = bad_pixel[j,0:image_ysize-1]
        m = m + 1
    endfor
    channel_image[i,*,*] = channel
    channel_badpixel[i,*,*] = bad


    channel_ximage_range[i,0] = 1
    channel_ximage_range[i,1] = image_xsize/4
    channel_yimage_range[i,0] = 1
    channel_yimage_range[i,1] = image_ysize

;; 3 RTI rest, on 4RTI read reference pixel, next 256 RTIs read
;; science data, 3 RTI rest, read reference pixel on RTI - 5 more RTIs
;;                                                         to reset row

;for now do not work out timedata and timeflag for subarray data-
; need column and row start information found in ICE housekeeping file

    if(subarray eq 0) then begin

        RTI = 10.0              ; 10 microseconds 
        k = long(0)
        for p = 0,image_ysize -1 do begin
            for m = 0,xsize_time+10 do begin ; 269 RTI/row
                
                time[i,k] = p* 269.0 + m + 1.0
                if(m le 2 or m ge 260 ) then begin ; wait/reset time
                    timedata[i,k] = 0
                    timeflag[i,k] = -1
                    timebadpixel[i,k] = 0
                endif
                if(m eq 3) then  begin ; on a reference pixel (left)
                    timeflag[i,k] = 1 
                    timedata[i,k] = channel[0,p]
                    timebadpixel[i,k] = 0
                endif
                
                if( m eq 263) then  begin ; on a reference pixel (right)
                    timeflag[i,k] = 2
                    timedata[i,k] = channel[257,p]
                    timebadpixel[i,k] = 0
                endif
                if(m ge 4 and m le 259) then  begin ; science data
                    timeflag[i,k] = 0
                    timedata[i,k] = channel[m-3,p]
                    timebadpixel[i,k] = bad[m-3,p]
                endif

                
                k = long(k) +1
            endfor


        endfor
        index = where(timeflag[i,*] eq 0,num)
        replicate_value = mean(timedata[i,index])
        
        if(FFT_replicate_value ne -1) then $
          replicate_value = FFT_replicate_value
        index = where(timeflag[i,*] eq -1)
        timedata[i,index] = replicate_value
    endif
    channel_noref = 0
    channel = 0
endfor

; 5th channel = reference image


channel_image[4,*,*] = ref_image
channel_badpixel[4,*,*] = 0
   

channel_ximage_range[4,0] = 1
channel_ximage_range[4,1] = image_xsize/4
channel_yimage_range[4,0] = 1
channel_yimage_range[4,1] = image_ysize

;; 3 RTI rest, on 4RTI read reference pixel, next 256 RTIs read
;; science data, 3 RTI rest, read reference pixel on RTI - 5 more RTIs
;;                                                         to reset row


    if(subarray eq 0) then begin
        k = long(0)
        for p = 0,image_ysize -1 do begin
            for m = 0,xsize_time+10 do begin
                time[i,k] = p* 269.0 + m + 1.0
                if(m le 2 or m ge 260 ) then begin ; wait/reset time
                    timedata[4,k] = 0
                    timeflag[4,k] = -1
                    timebadpixel[4,k] = 0
                endif
                if(m eq 3) then  begin ; on a reference pixel
                    timeflag[4,k] = 1 
                    timedata[4,k] = ref_image[0,p]
                    timebadpixel[4,k] = 0
                endif
                
                if( m eq 263) then  begin ; on a reference pixel
                    timeflag[4,k] = 2 
                    timedata[4,k] = ref_image[257,p]
                    timebadpixel[4,k] = 0
                endif
                if(m ge 4 and m le 259) then  begin ; science data
                    timeflag[4,k] = 0
                    timedata[4,k] = ref_image[m-3,p]
                    timebadpixel[4,k] = 0
                endif
                

                k = long(k) +1
            endfor
        endfor
        index = where(timeflag[4,*] eq 0,num)
        replicate_value = mean(timedata[4,index])
        
        if(FFT_replicate_value ne -1) then $
          replicate_value = FFT_replicate_value
        index = where(timeflag[4,*] eq -1)
        timedata[4,index] = replicate_value
endif


ref_image = 0
ref_noref = 0


end

