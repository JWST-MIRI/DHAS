; Find the slope - run miri_sloper - invoked when "Calculate Slope" button is pushed 

pro mql_run_miri_caler,info

if(info.mc.apply_dark eq 0 and info.mc.apply_flat eq 0 and info.mc.apply_fringe_flat eq 0) then begin
    error = dialog_message(' You need to apply a pixel flat, fringe flat or dark image, try again',/error)
    return
    
endif

widget_control,/hourglass
progressBar = Obj_New("ShowProgress", color = 150, $
                      message = " Running Miri_caler program",$
                      xsize = 250, ysize = 40)


progressBar -> Start


setdiag = ' -d '
setcr =  ' +C '
setsubA = ' -A '
setsubB = ' -B '
setsubC = ' -C '
setFM = ' -FM'
setVM = ' -VM'

setdark = ' +d '
setdarkf = ' -df ' + info.mc.dark_file
setflat = ' +f '
setflatf = ' -ff ' + info.mc.flat_file
setfringe = ' +r '
setfringef = ' -rf ' + info.mc.fringe_file

setdin =  ' -DI ' + info.mc.dir
setdcal = ' -DC ' + info.mc.dircal
setout  = ' -o ' + info.mc.output_filename
setPF  = ' -p ' + info.control.pref_filename


filename_LVL2 = info.control.filebase + '_LVL2.fits'

print,'Spawning the cpp program miri_caler for',info.control.filename_slope
print,' '


caler_line = 'miri_caler ' + filename_LVL2 + setdin 
if(info.control.user_pref_file eq 1) then begin
    caler_line = caler_line + setPF 
endif

if(info.mc.flag_dircal eq 1) then caler_line = caler_line + setdcal 
if(info.mc.flag_outputname eq 1) then caler_line = caler_line + setout

if(info.mc.apply_dark eq 1 ) then caler_line = caler_line + setdark
if(info.mc.flag_darkfile eq 1) then caler_line = caler_line + setdarkf

if(info.mc.apply_flat eq 1 ) then caler_line = caler_line + setflat
if(info.mc.flag_flatfile eq 1) then caler_line = caler_line + setflatf

if(info.mc.apply_fringe_flat eq 1 ) then caler_line = caler_line + setfringe
if(info.mc.flag_fringefile eq 1) then caler_line = caler_line + setfringef
if(info.mc.subchannel_flag eq 1 and info.mc.subchannel eq 0 ) then caler_line = caler_line  + setsubA
if(info.mc.subchannel_flag eq 1 and info.mc.subchannel eq 1 ) then caler_line = caler_line  + setsubB
if(info.mc.subchannel_flag eq 1 and info.mc.subchannel eq 2 ) then caler_line = caler_line  + setsubC



print, caler_line
spawn, caler_line,exit_status = etype



percent = 100.0
progressBar -> Update,percent

progressBar -> Destroy
obj_destroy, progressBar
if(etype ne 0) then begin
    results = dialog_message(" There was a problem running miri_caker. CHECK ERROR on SCREEN" )
    return

endif

;_______________________________________________________________________


; is not changed by miri_caler processes 
;info.control.dir

dir = info.control.dir
len = strlen(dir) 
test = strmid(dir,len-1,len-1)
if(test ne '/') then dir = dir + '/'
info.control.dir = dir

dirout = info.mc.dirout
len = strlen(dirout) 
test = strmid(dirout,len-1,len-1)
if(test ne '/') then dirout = dirout + '/'
info.control.dirout = dirout


info.control.filebase = info.mc.output_filename
info.control.dircal = info.mc.dircal
info.control.filename_slope = info.mc.filename


filename_slope = info.control.filename_slope
len = strlen(filename_slope)
fitname = strmid(filename_slope,len-5,5)
fits = strpos(filename_slope,fitname)
fitlv12 = strmid(filename_slope,len-10,10)
lv12 = strpos(filename_slope,fitlv12)
info.control.filename_raw = strmid(filename_slope,0,lv12) +fitname

filename_raw = info.control.dir + info.control.filename_raw

file_exist1 = file_test(filename_raw,/regular,/read)
if(file_exist1 ne 1) then begin
    filename_raw = info.control.dirout + info.control.filename_raw

    file_exist1 = file_test(filename_raw,/regular,/read)

    if(file_exist1) then begin 
        info.control.filename_raw = filename_raw

    endif
endif else begin
    info.control.filename_raw = filename_raw
endelse



filename = info.mc.output_filename
filename = strcompress(info.control.dirout  + filename,/remove_all)
coadd_file = filename + '_FASTSHORT_MEAN.fits'
info.control.filename_slope = info.control.dirout+info.control.filename_slope
info.control.filename_refcorrection =filename + '_RefCorrection.fits'
info.control.filename_IDS = filename + '_IDS.fits'
info.control.filename_log = filename + '.log'
info.control.filename_slope_refimage = filename + '_LVL2_REF.fits'
info.control.filename_cal = filename + '_LVL3.fits'

status = 0
reading_slope_header,info,status,error_message
if(status eq 1) then begin
    result = dialog_message(error_message,/error)
    return
endif


subarray = 0
bad_file  = ''
do_bad = 0
integrationNO = info.control.int_num
read_single_slope,info.control.filename_slope,slope_exists,$
                  integrationNO,subarray,slopedata,$
                  slope_xsize,slope_ysize,slope_zsize,stats,$
                  do_bad,bad_file,$
                  status,error_message
info.data.slope_xsize = slope_xsize
info.data.slope_ysize = slope_ysize
info.data.slope_zsize = slope_zsize

if ptr_valid (info.data.pslopedata) then ptr_free,info.data.pslopedata
info.data.pslopedata = ptr_new(slopedata)
info.data.slope_stat = stats
slopedata = 0
stats = 0
;info.control.apply_bad = do_bad
if(do_bad eq 1) then  info.control.bad_file[*] = bad_file  


if(status ne 0) then begin
    ok = dialog_message(error_message,/Information)
    return
endif
info.control.int_num = info.control.int_num_save


;_______________________________________________________________________
info.data.cal_exist = 0
cal_exists = 0
status = 0 & error_message = " " 
read_single_cal,info.control.filename_cal,cal_exists,$
                info.image.integrationNO,info.data.subarray,caldata,$
                cal_xsize,cal_ysize,cal_zsize,stats,$
                status,error_message
info.data.cal_exist = cal_exists
if(cal_exists eq 1) then begin 
    info.data.cal_xsize = cal_xsize
    info.data.cal_ysize = cal_ysize
    info.data.cal_zsize = cal_zsize
    if ptr_valid (info.data.pcaldata) then ptr_free,info.data.pcaldata
    info.data.pcaldata = ptr_new(caldata)
    info.data.cal_stat = stats
    caldata = 0
    stats = 0
endif

file_exist1 = file_test(info.control.filename_raw,/regular,/read)
info.data.raw_exist = file_exist1
if(file_exist1 ne 1 ) then begin
    error_message  = " The raw science file does not exist. "
    status = 3
endif

Widget_Control,info.QuickLook,Set_UValue=info

if(status eq 3) then begin
    info.loadfile.uwindowsize = 0
    load_file,info
endif else begin 
    header_setup,2,info
    header_setup_slope,info
    if(cal_exists eq 1) then header_setup_cal,info 
    
    reading_header,info         ; read in raw header 
    msql_display_slope,info
endelse




end
