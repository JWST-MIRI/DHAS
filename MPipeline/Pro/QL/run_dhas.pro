pro help_run_dhas

print,'***********************************************************************************'
print,'The input for this program is a list of fits files and the directory where these files are found.'
print,' '
print,' The program takes a list of science fits files and runs the miri_sloper program'
print,' over the data, determining the reduced slope image. This program then displays'
print,' the data to the screen and prints the results to output plots." 
print,' Below is the correct syntax for the program '
print,' ' 
print,' First parameter REQUIRED : filelist  ( list of science fits files or single filename) '
print,' dirin =  directory where science images are [default in preferences file]'
print,' dirps = directory where postscript plots are written [default in preference file]'
print,' '
print,' The parameters below describe how to run the miri_sloper program:' 
print,' '
print,' /findslope (run the miri_sloper program on the data)'
print,' /dup (ignore the first 4 columns, set them to bad pixels. The reference pixel are 5-8 and 1029-1032'
print,' ireject = number (number of initial reads to be rejected when reducing the data)'
print,' ereject = number (number of final reads to be rejected when reducing the data)'
print,' /sp1 (correct science data with ref pixels (1 value per channel)
print,' /sp2 (correct science data with ref pixels (row by row, using slope and y-intercept)
print,' low = number (reject DN values below with value'
print,' high = number (reject DN values above with value (global saturation value)'
print,' /bad (remove bad pixels using the bad pixel list)
print,' bfile = ascii file or Fits file containing bad pixels [default is in the preferences file]'
print,' /sat (using the pixel saturation mask to remove saturated data)
print,' sfile = A FITS file containing the saturation level for each pixel
print,' /dark (apply a Calibration Dark to the data)
print,' dfile = FITS file containing calibration dark image'
print,' /flat (apply a Calibration Flat to the data)
print,' ffile = FITS file containing calibration flat image'
print,' /es (convert reduced data to electrons/second'
print,' gain = gain'
print,' ft = frametime'
print,' '
print,' The parameters below describe how to run the ql tool from the command line:' 
print,' '
print,' frame = [2,3,4] (list of frames to display)'
print,' /slope (display the reduced image)
print,' /ref (display the reference output image)
print,' /channel (display the data seperated into channels'
print,' /report(make a test report over the entire FITS file'
print,' /pixelplot (plot a few  selected pixels - all the reads in the integration)'
print,' print = ps,jpg,png,gif (the type of plot to create)'
print,' wait = number (the time in seconds to wait before destroying the plot on the screen' 
print,' xsize = x dimension of windows'
print,' ysize = y dimension of windows'
print,' /batch (do a set of tasks - run miri_sloper, create test report, display output to screen'

print,'-----------------------------------------------------------------------------------'


print,'example commandline'
print," run_dhas,'miri_image.fits',dirin='input_directory',/findslope,frame=[1,2,30],/slope,/report,xsize= 650, ysize=650,wait=5"
print,'***********************************************************************************'

end

;_______________________________________________________________________
pro run_dhas, filelist,$
              dirin=dirinput,$
              dirtel=dirtelin,$
              dirps = dirpsin,$
              frame= framenum,$ 
              findslope = findslope,$
              slope = slope,$
              ref = ref,$
              report = report,$
              pixelplot = pixelplot,$
              channel = channel,$
              print = printtype, wait = waittime, batch = batch,$
              dup = dup,$
              ireject = sfit, ereject = efit,$
              sr = sr, sp1 = sp1, sp2 = sp2, es = es, $
              low = low_value, high = high_value,$
              gain = gain_value, ft = frametime_value,$
              bad = bad, bfile = bad_pixel_file, $
              sat = sat, sfile = pixel_sat_file,$
              dark = dark, dfile = dark_pixel_file, $
              flat = flat, ffile = flat_pixel_file,$
              xsize= xsize_window,ysize=ysize_window

; check that we have at least 1 parameter
if(N_params() LT 1) then begin
    help_run_dhas
    retall
endif


dir_input = ''
dirps_input = ''
frame_list = 1
xsize_scroll = 0
ysize_scroll = 0
frame_display = 0
pixel_display = 0
make_report = 0
channel_display = 0
run_sloper = 0
ref_display = 0
slope_display = 0
doprint = 0
print_type = ''  
wait_time = 0
do_batch = 0
apply_dead = 0
run_ql = 0


flag_dirin =0
if(N_elements(dirinput)) then begin
    dir_input = dirinput
    dir_input = strcompress(dir_input,/remove_all)
    len = strlen(dir_input) 
    test = strmid(dir_input,len-1,len-1)
    if(test eq '/') then dir_input = strmid(dir_input,0,len-1)
    flag_dirin =1
endif

if(N_elements(dirpsin)) then begin
    dirps_input = dirpsin
    dirps_input = strcompress(dirps_input,/remove_all)
    len = strlen(dirps_input) 
    test = strmid(dirps_input,len-1,len-1)
    if(test eq '/') then dirps_input = strmid(dirps_input,0,len-1)
endif



run_sloper = 0
start_fit = -1
if(N_elements(sfit)) then start_fit = sfit

end_fit = -1
if(N_elements(efit)) then  end_fit = efit

low_dn  = -1
if(N_elements(low_value)) then low_dn = low_value


high_dn  = -1
if(N_elements(high_value)) then high_dn = high_value

flag_gain = 0
gain = 0
if(N_elements(gain_value)) then begin
    gain = gain_value
    flag_gain = 1
endif

frametime = 0
flag_frametime = 0
if(N_elements(frametime_value)) then  begin
    frametime = frametime_value
    flag_frametime = 1
endif


refpixel_option1 = 0
if keyword_set(sp1) then refpixel_option1 = 1

refpixel_option2 = 0
if keyword_set(sp2) then refpixel_option2 = 1

ignore_col_1_4 = 0
if keyword_set(dup) then ignore_col_1_4 = 1
 
convert_electrons_per_second = 0
if keyword_set(es) then convert_electrons_per_second = 0

apply_flat = 0
if keyword_set(flat) then apply_flat = 1

apply_dark = 0
if keyword_set(dark) then apply_dark = 1

apply_bad = 0
if keyword_set(bad) then begin
	apply_bad = 1
	apply_dead = 1
endif

do_pixelsat = 0
if keyword_set(sat) then do_pixelsat = 1
    
flag_badfile = 0
if(N_elements(bad_pixel_file)) then begin
    bad_file = bad_pixel_file
    apply_bad = 1
    flag_badfile = 0
endif

flag_pixelsat = 0
if(N_elements(pixel_sat_file)) then begin
    pixel_file = pixel_sat_file
    do_pixelsat = 1
    flag_pixelsat = 1
endif

flag_darkfile = 0
if(N_elements(dark_pixel_file)) then begin
    dark_file = dark_pixel_file
    apply_dark = 1
    flag_darkfile = 0
endif

flag_flatfile = 0
if(N_elements(flat_pixel_file)) then begin
    dark_file = flat_pixel_file
    apply_flat = 1
    flag_flatfile = 0
endif

if keyword_set(batch) then begin
    framenum = [2]
    frame_display = 1
    pixel_display = 1
    make_report = 1
    channel_display = 1
    run_sloper = 1
    ref_display = 1
    slope_display = 1
    doprint = 1
    print_type = 'ps'  
    wait = 5
   run_ql = 1
endif
;_______________________________________________________________________
if(N_elements(printtype)) then begin
    doprint = 1
    print_type = 'jpg'  ; default
    type = strcompress(printtype,/remove_all)
    result = strcmp(type,'jpg',1,/fold_case)
    if(result eq 1) then      print_type = 'jpg'
    result = strcmp(type,'gif',1,/fold_case)
    if(result eq 1) then      print_type = 'gif'
    result = strcmp(type,'ps',2,/fold_case)
    if(result eq 1) then      print_type = 'ps'
    result = strcmp(type,'eps',1,/fold_case)
    if(result eq 1) then      print_type = 'eps'
    result = strcmp(type,'png',2,/fold_case)
    if(result eq 1) then      print_type = 'png'
endif

if(N_elements(waittime) ne 0) then  wait_time = waittime

if(N_elements(xsize_window)) then  xsize_scroll = xsize_window
if(N_elements(ysize_window)) then  ysize_scroll = ysize_window


if(N_elements(framenum) ne 0) then begin
    run_ql = 1
endif



if keyword_set(findslope) then begin
    slope_display = 1
    run_sloper = 1
endif

if keyword_set(slope) then begin
    slope_display = 1
	run_ql = 1
endif


if keyword_set(ref) then begin
	 ref_display = 1
	run_ql = 1
endif

if keyword_set(report) then begin
	 make_report = 1
	run_ql = 1
endif

if keyword_set(pixelplot) then begin
	 pixel_display = 1
	run_ql = 1
endif

if keyword_set(channel) then begin
	 channel_display = 1
	run_ql = 1
endif
;_______________________________________________________________________
len = strlen(filelist)
test = strlowcase(strmid(filelist,len-4,len-1))
result = strcmp(test,'fits',4)
if(result eq 1) then begin ; the list is really a single fits file
    files = strarr(1)
    files[0] = filelist
    n_files = 1
endif else begin 
;-----------------------------------------------------------------------
; check that file list exist
    if(not file_test(filelist)) then begin
        print,' The ASCII list file (' +fileist +') does not exists'
        retall
    endif

; read the file list 
    openr,list_file,filelist,/get_lun
    max_npts = 1000
    files = strarr(max_npts)
    tstr = ''
    k = 0
    while (not eof(list_file)) do begin
        readf,list_file,tstr
        tstr = strcompress(tstr,/remove_all)
        files[k] = tstr
        k = k + 1
    endwhile
    free_lun,list_file
    n_files = k
    files = files[0:n_files-1]
endelse


;
;_______________________________________________________________________
; Loop over files
for i = 0,(n_files-1) do begin
    fileinput = strcompress(files[i],/remove_all)
    print,' In run dhas looping over next file',fileinput

; Check if going to run miri_sloper
    if(run_sloper eq 1) then begin 

        widget_control,/hourglass
        progressBar = Obj_New("ShowProgress", color = 150, $
                              message = " Running Miri_sloper program",$
                              xsize = 250, ysize = 40)


        progressBar -> Start

        g = strcompress(string(gain),/remove_all)
        ftime = strcompress(string(frametime),/remove_all)
        r1 = strcompress(string(start_fit),/remove_all)
        r2 = strcompress(string(end_fit),/remove_all)
        low = strcompress(string(low_DN),/remove_all)
        high = strcompress(string(high_DN),/remove_all)

        setrp1 = ' +r1 '
        setrp2 = ' +r2 '
        setdup = ' -u '
        setes = ' -e '
        setro   = ' +ro '
        setbadp = ' +b '
        if(flag_gain) then setgain = ' -g ' + g
        if(flag_frametime) then setftime = ' -t ' + ftime

        if(flag_badfile) then setbadpf = ' -bf ' + bad_file

        setsm = ' +s '
        if(flag_pixelsat) then setsmf = ' -sf ' + pixel_file

        setdark = ' +d '
        if(flag_darkfile) then setdarkf = ' -df ' +dark_file

        setflat = ' +f '
        if(flag_flatfile) then setflatf = ' -ff ' +flat_file

        setlow = '-l '+ low
        sethigh = '-h '+ high
        setreject1 = ' -a '+ r1
        setreject2 = ' -z '+ r2
        setdin =  ' -DI ' + dir_input

        print,'Spawning the cpp program miri_sloper for',fileinput
        print,' '

        miri_line = 'miri_sloper ' + fileinput
        cal_line = 'miri_caler ' + fileinput

	if(flag_dirin eq 1) then miri_line  = miri_line + setdin
        if(apply_bad eq 1 ) then miri_line = miri_line + setbadp
        if(flag_badfile eq 1) then miri_line = miri_line + setbadpf
        if(do_pixelsat eq 1 ) then miri_line = miri_line + setsm
        if(flag_pixelsat eq 1) then miri_line = miri_line + setsmp
        if(flag_gain eq 1) then miri_line = miri_line + setgain
        if(flag_frametime eq 1) then miri_line = miri_line + setftime

        if(low_DN ne -1) then miri_line = miri_line + setlow
        if(high_DN ne -1) then miri_line = miri_line + sethigh

        if(start_fit ne -1) then miri_line = miri_line + setreject1
        if(end_fit ne -1) then miri_line = miri_line + setreject2
        if(refpixel_option1 eq 1) then miri_line = miri_line + setrp1
        if(refpixel_option2 eq 1) then miri_line = miri_line + setrp2
        if(ignore_col_1_4 eq 1) then miri_line = miri_line + setdup
        if(convert_electrons_per_second eq 1) then miri_line = miri_line + setes



        if(apply_dark eq 1 ) then caler_line = caler_line + setdark
        if(flag_darkfile eq 1) then caler_line = caler_line + setdarkf

        if(apply_flat eq 1 ) then caler_line = caler_line + setflat
        if(flag_flatfile eq 1) then caler_line = caler_line + setflatf


        print, miri_line
        spawn, miri_line

        percent = 100.0
        progressBar -> Update,percent

        progressBar -> Destroy
        obj_destroy, progressBar
    endif
;_______________________________________________________________________

if (run_ql) then begin 
    ql,scidata=fileinput,dirin=dir_input,dirps=dirps_input,frame=framenum,$
       plot_slope=slope_display,plot_ref=ref_display,apply_bad=apply_dead,$
       report= make_report,pixelplot=pixel_display,plot_channel=channel_display,$
       print = print_type,wait = wait_time, batch = do_batch,xsize=xsize_scroll,ysize=ysize_scroll
endif
    
endfor
;_______________________________________________________________________
end


