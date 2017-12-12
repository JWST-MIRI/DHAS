; Find the slope - run miri_sloper - invoked when "Calculate Slope" button is pushed 

pro mql_run_miri_sloper,info,status

status = 0

print,'in run miri_sloper',info.control.filename_raw

widget_control,/hourglass
progressBar = Obj_New("ShowProgress", color = 150, $
                      message = " Running Miri_sloper program",$
                      xsize = 250, ysize = 40)


progressBar -> Start

read_noise = strcompress(string(info.ms.read_noise),/remove_all)
gain = strcompress(string(info.ms.gain),/remove_all)
ft = strcompress(string(info.ms.frametime),/remove_all)

fl = strcompress(string(info.ms.frame_limit),/remove_all)
ss = strcompress(string(info.ms.subset_size),/remove_all)
r1 = strcompress(string(info.ms.start_fit),/remove_all)
r2 = strcompress(string(info.ms.end_fit),/remove_all)

high = strcompress(string(info.ms.highDN),/remove_all)


rp = strcompress(string(info.ms.delta_row_even_odd),/remove_all)

setUU = ' -UU'
setUC = ' -UC'
setquick = ' -Q'
setwref = ' -OR'
setwID = ' -OI'
setwCR = ' -OC'
setwReset = ' -Or'

setwDark = ' -OD'
setwLast = ' -Ol'
setdiag = ' -d '
setWLC = ' -OL'
setB = ' -B'
setro1   = ' +ro1 '
setro2   = ' +ro2 '
setro3   = ' +ro3 '
setroc   = ' +roc '
setrp2  = ' +r2 '
setrp3  = ' +r3 '
setrp5  = ' +r5 '
setrp6  = ' +r6 '
setrp1  = ' +r1 '
setpc =   ' -Op '
setcr =  ' +C '
setFM = ' -FM'
setVM = ' -VM'
setgain =' -g ' + gain
setframetime= ' -t ' + ft
setrn = ' =rn ' + read_noise


setbadp = ' +b '
setbadpf = ' +b -bf ' + info.ms.bad_file
setsm = ' +s '
setsmf = ' +s -sf ' + info.ms.saturation_file
setlc = ' +L '
setlcf = ' +L -Lf ' + info.ms.lincor_file
setreset = ' +r '
setRF = ' +r -rf ' + info.ms.reset_correction_file
setrscd = ' +rd '
setrscdF = ' +rd -rdf ' + info.ms.rscd_correction_file
setdark = ' +D '
setdF = ' +D -Df ' + info.ms.dark_correction_file
setlast = ' +l '
setlF = ' +l -lf ' + info.ms.lastframe_correction_file
sethigh = ' -h '+ high
setreject1 = ' -a '+ r1
setreject2 = ' -n '+ r2
setdelta  = ' -rd ' + rp 
setdin =  ' -DI ' + info.ms.dir
setdout =  ' -DO ' + info.ms.dirout
setdcal = ' -DC ' + info.ms.dircal
setout  = ' -o ' + info.ms.output_filename
setFL =   ' -FL ' + fl
setSS =   ' -R ' + ss
setPF  = ' -p ' + info.control.pref_filename 

noref = ' -r2 -r3 -r5 -r6 -r1  '

filename = info.control.filebase + '.fits'

print,'Spawning the cpp program miri_sloper for',info.control.filename_raw
print,' '


miri_line = 'miri_sloper ' + filename  + setdin +setdout
if(info.control.user_pref_file) then begin
    miri_line  = miri_line + setPF
endif 


if(info.ms.UncertaintyMethod eq 1) then miri_line =  miri_line +setUU
if(info.ms.UncertaintyMethod eq 2) then miri_line = miri_line +setUc
if(info.ms.quickslope eq 1) then miri_line = miri_line + setquick
if(info.ms.badpixel eq 1 ) then miri_line = miri_line + setbadp
if(info.ms.flag_badfile eq 1) then miri_line = miri_line + setbadpf
if(info.ms.sat_mask eq 1 ) then miri_line = miri_line + setsm
if(info.ms.flag_satmask eq 1) then miri_line = miri_line + setsmf

if(info.ms.reset_correction eq 1 ) then miri_line = miri_line + setreset
if(info.ms.flag_reset eq 1) then miri_line = miri_line + setrf

if(info.ms.rscd_correction eq 1 ) then miri_line = miri_line + setrscd
if(info.ms.flag_rscd eq 1) then miri_line = miri_line + setrscdf

if(info.ms.lastframe_correction eq 1 ) then miri_line = miri_line + setlast
if(info.ms.flag_lastframe eq 1) then miri_line = miri_line + setlf

if(info.ms.dark_correction eq 1 ) then miri_line = miri_line + setdark
if(info.ms.flag_dark eq 1) then miri_line = miri_line + setdf

if(info.ms.lincor eq 1 ) then miri_line = miri_line + setlc
if(info.ms.flag_lincor eq 1) then miri_line = miri_line + setlcf
if(info.ms.flag_highDN eq 1) then miri_line = miri_line + sethigh


if(info.ms.flag_frame_limit eq 1 ) then miri_line = miri_line + setFL
if(info.ms.flag_subset_size eq 1 ) then miri_line = miri_line + setSS
if(info.ms.start_fit ne 0) then miri_line = miri_line + setreject1
if(info.ms.end_fit ne 0) then miri_line = miri_line + setreject2

if(info.ms.refpixel_type eq 2) then miri_line = miri_line + setrp2 + setdelta
if(info.ms.refpixel_type eq 3) then miri_line = miri_line + setrp3
if(info.ms.refpixel_type eq 1) then miri_line = miri_line + setrp1
if(info.ms.refpixel_type eq 5) then miri_line = miri_line + setrp5
if(info.ms.refpixel_type eq 6) then miri_line = miri_line + setrp6
if(info.ms.cosmic_ray_test eq 1) then miri_line = miri_line + setcr
if(info.ms.flag_dircal eq 1) then miri_line = miri_line + setdcal 
if(info.ms.write_refcorrection eq 1) then miri_line = miri_line + setpc 
if(info.ms.flag_outputname eq 1) then miri_line = miri_line + setout
if(info.ms.flag_gain eq 1) then miri_line = miri_line + setgain
if(info.ms.flag_frametime eq 1) then miri_line = miri_line + setframetime
if(info.ms.do_diagnostic eq 1) then miri_line = miri_line + setdiag
if(info.ms.write_refcorrected_data eq 1) then miri_line = miri_line + setwref
if(info.ms.write_id_data eq 1) then miri_line = miri_line + setwid
if(info.ms.write_lincor_data eq 1) then miri_line = miri_line + setwLC
if(info.ms.write_reset_corrected_data eq 1) then miri_line = miri_line + setwreset
if(info.ms.write_lastframe_corrected_data eq 1) then miri_line = miri_line + setwlast
if(info.ms.write_dark_corrected_data eq 1) then miri_line = miri_line + setwdark



print, miri_line

spawn, miri_line,exit_status = etype

percent = 100.0
progressBar -> Update,percent

progressBar -> Destroy
obj_destroy, progressBar

if(etype ne 0) then begin
    results = dialog_message(" There was a problem running miri_sloper. CHECK ERROR on SCREEN" )
    status = 1
    return
endif

;_______________________________________________________________________


dirin = info.ms.dir
len = strlen(dirin) 
test = strmid(dirin,len-1,len-1)
if(test ne '/') then dirin = dirin + '/'
info.control.dir = dirin


dirout = info.ms.dirout
len = strlen(dirout) 
test = strmid(dirout,len-1,len-1)
if(test ne '/') then dirout = dirout + '/'
control_dirout = dirout


info.control.filebase = info.ms.output_filename
info.control.dircal = info.ms.dircal
info.control.filename_raw = info.ms.filename

fitname = '.fits'
filename = info.ms.output_filename

filename = strcompress(control_dirout  + filename,/remove_all)


info.control.filename_raw =info.control.filename_raw
coadd_file = filename + '_FASTSHORT_MEAN.fits'
if(info.ms.coadd eq 1) then  info.control.filename_slope = coadd_file



info.control.set_scidata = 1
setup_names,info,status,error_message
if(status eq 2) then return

if(status eq 1) then begin
    result = dialog_message(error_message,/error)
    return
endif
info.control.set_scidata = 0

Widget_Control,info.QuickLook,Set_UValue=info



end
