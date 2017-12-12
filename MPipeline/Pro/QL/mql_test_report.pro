@file_decompose.pro
;_______________________________________________________________________
pro print_test_report_automatic,info
breakline = '--------------------------------------------------------'

outname = info.output.test_report
path = info.control.dirps
slash = '/'
print,'path ',path
if(path eq "") then slash = ''
filename = info.control.dirps + slash + info.control.filebase + $
           outname + '.txt'

print,' Printing file',filename

openw,lun,filename,/GET_LUN,error=err ; check valid directory
if( err ne 0) then begin
    print,' Can not open the file for writing, Invalid Path ?'
    return
endif else begin 
      ; every thing ok now write to file 

    widget_control,/hourglass
    progressBar = Obj_New("ShowProgress", color = 150, $
                          message = " Creating Report",$
                          xsize = 250, ysize = 40)
    progressBar -> Start

    printf,lun,'Test Report for file: ',filename
    printf,lun,' '

    test_report_get_stats,info,lun


                     ; end looping over slopes
endelse
progressBar -> Destroy
obj_destroy, progressBar

close,lun
free_lun,lun

end
;***********************************************************************
pro test_report_get_stats,info,lun

itotal = info.data.nslopes * info.data.nramps
ithis  = 0
reading_slope_processing,info.control.filename_slope,slope_exist,$
  fit_start,fit_end,low_sat,$
  high_sat,do_bad,use_psm,use_rscd,use_lin,use_dark,subrp,deltarp,even_odd,$
                             bad_file,psm_file,rscd_file,$
                             lin_file,dark_file,$
                             slope_unit,frametime,gain


space = '     '
breakline = '--------------------------------------------------------'
for ii = 0, info.data.nslopes-1 do begin 
    si = strtrim(string(ii+1),2)
    st = 'Integration: ' + si
    stitle = " Statistics on Reduced Image "
    printf,lun,breakline
    printf,lun,stitle,'  ',st
    stitle = ' '
    if(slope_exist eq 0) then printf,lun, ' Reduced data does not exist'
    if(slope_exist eq 1) then begin
        subarray = 0
        read_single_slope,info.control.filename_slope,exists,ii,$
                          subarray,slopedata,image_xsize,image_ysize,image_zsize,$
                          stats_image,do_bad,bad_file,status,error_message
        if(status ne 0) then begin
            print,error_message
            print,info.control.log_unit,error_message
            return
        endif
        slope = slopedata[*,*,0]
        slopedata = 0 
        get_image_stat,slope,image_mean,stdev_pixel,image_min,image_max,$
                       irange_min,irange_max,image_median,stdev_mean,skew,ngood,nbad
        
        slope = 0

        var = stdev_pixel*stdev_pixel
        
        smean =    '         Mean:    ' + strtrim(string(image_mean,format="(g14.6)"),2) 
        svar =     '     Variance:    '+  strtrim(string(var,format="(g14.6)"),2)
        sdpixel =  'STDEV (Pixel):    ' +  strtrim(string(stdev_pixel,format="(g14.6)"),2)
        sdmean =   ' STDEV (Mean):    '+ strtrim( string(stdev_mean,format="(g14.6)"),2)
        smin =     '          Min:    '+ strtrim(string(image_min,format="(g14.6)"),2) 
        smax =     '          Max:    '+strtrim( string(image_max,format="(g14.6)"),2)
        smed     = '       Median:    '+strtrim( string(image_median,format="(g14.6)"),2)
        sskew =    '         Skew:    '+strtrim( string(skew,format="(g14.6)"),2)
        sgood =    '# of Good Pixels: '+strtrim( string(ngood,format="(i10)"),2)
        sbad  =    '# of Bad Pixels:  '+strtrim( string(nbad,format="(i10)"),2)
            
        printf,lun,smean
        printf,lun,svar
        printf,lun,sdpixel
        printf,lun,sdmean
        printf,lun,smin
        printf,lun,smax
        printf,lun,smed
        printf,lun,sskew
        printf,lun,sgood
        printf,lun,sbad
    endif


    printf,lun,breakline
    for jj = 0,info.data.nramps-1 do begin 
        
        ithis = ithis + 1

            
        get_stat_single_image,info,ii,jj,$
          mean,st_pixel,min,max,$
          irange_min,irange_max,median,st_mean,skew,ngood,nbad
        
        var = st_pixel*st_pixel
        sj = strtrim(string(jj+1),2)
        st = ' Frame: ' + sj                
        stitle= " Statistics on Science Frame "
        
        smean = '         Mean:  '+strtrim(string(mean,format="(g14.6)"),2) 
        svar =  '     Variance:  '+strtrim(string(var,format="(g14.6)"),2)
        sdpixel='STDEV (Pixel):  '+strtrim(string(st_pixel,format="(g14.6)"),2)
        sdmean =' STDEV (Mean):  '+strtrim( string(st_mean,format="(g14.6)"),2)
        smin =  '          Min:  '+strtrim(string(min,format="(g14.6)"),2) 
        smax =  '          Max:  '+strtrim(string(max,format="(g14.6)"),2)
        smed  = '       Median:  '+strtrim(string(median,format="(g14.6)"),2)
        sskew = '         Skew:  '+strtrim(string(skew,format="(g14.6)"),2)
        sgood =    '# of Good Pixels: '+strtrim( string(ngood,format="(i10)"),2)
        sbad  =    '# of Bad Pixels:  '+strtrim( string(nbad,format="(i10)"),2)
            
        printf,lun, ' '
        printf,lun,space,stitle,'  ',st
        printf,lun,space,smean
        printf,lun,space,svar
        printf,lun,space,sdpixel
        printf,lun,space,sdmean
        printf,lun,space,smin
        printf,lun,space,smax
        printf,lun,space,smed
        printf,lun,space,sskew
        printf,lun,sgood
        printf,lun,sbad
        
    endfor                      ; end looping over ramps

endfor
                     ; end looping over slopes
end

;***********************************************************************
pro mql_test_report_quit,event
widget_control,event.top, Get_UValue = tinfo
widget_control,tinfo.info.QuickLook,Get_UValue=info
widget_control,info.StatInfo,/destroy
end
;***********************************************************************



pro test_report, event

breakline = '--------------------------------------------------------'

Widget_Control, event.top, Get_UValue=testreportinfo
Widget_Control, testreportinfo.info.Quicklook, Get_UValue=info

; Get the file name the user typed in.
Widget_Control, testreportinfo.selectfile, Get_Value = filename
testreportinfo.filename = filename
Widget_Control, event.top, Set_UValue=testreportinfo


filename = strtrim(filename[0], 2)
file_decompose, filename, disk,path, name, extn, version
if strlen(extn) eq 0 then filename = filename + '.txt'

temp = file_search (filename, Count = fcount)
 
  ; fcount > 0 if there is an existing file
if fcount gt 0 then begin
    ql_selectval, event.top, 'Do you wish to overwrite existing file?',$
                  ['no','yes'], printfil
    if printfil eq 0 then begin
        temp = Widget_Message('Enter new name for output file or Cancel')
    endif else begin
         ; check if path is valid
        openw, lun, filename, error=err, /get_lun
        if err eq 0 then begin
            close, lun
            free_lun, lun
            printfil = 1
        endif else begin
            temp=Widget_Message('Cannot open file for writing - Invalid Path?')
            printfil = 0
        endelse
    endelse
endif else printfil = 1         ; no existing files with that name 

if printfil eq 0 then begin
    print, 'Cannot print'
    return
endif else begin
    openw,lun,filename,/GET_LUN,error=err ; check valid directory
    if( err ne 0) then begin
        temp=Widget_Message('Cannot open file for writing - Invalid Path?')
        return
    endif else begin 
      ; every thing ok now write to file 

        widget_control,/hourglass
        progressBar = Obj_New("ShowProgress", color = 150, $
                              message = " Creating Report",$
                              xsize = 250, ysize = 40)
        progressBar -> Start

        printf,lun,'Test Report for file: ',filename
        printf,lun,' '


        test_report_get_stats,info,lun

    endelse
endelse
progressBar -> Destroy
obj_destroy, progressBar

close,lun
free_lun,lun
if printfil eq 1 then Widget_Control, info.Quicklook, Set_UValue=info
Widget_Control, event.top, /Destroy
end
;_______________________________________________________________________
pro test_report_event, event

  Widget_Control, event.top, Get_UValue=testreportinfo
  Widget_Control, testreportinfo.info.QuickLook, Get_UValue=info
  case event.id of
      testreportinfo.browseButton: begin
          pout = strcompress(info.control.dirps + '/',/remove_all)
          Pathvalue = Dialog_Pickfile(/read,Title='Please select output file path', $
                                      Path=pout, Get_Path=realpath,filter='*.txt')

          Widget_Control, testreportinfo.selectfile, set_value=realpath
          testreportinfo.filename = realpath
      end

      testreportinfo.cancelButton: begin
          Widget_Control, info.Quicklook, Set_UValue=info
          Widget_Control, event.top, /Destroy
          return
      end

  endcase
 Widget_Control, event.top, Set_UValue=testreportinfo
  Widget_Control, testreportinfo.info.Quicklook, Set_UValue=info

end



;***********************************************************************
;_______________________________________________________________________
;_______________________________________________________________________
; This program produceds an ascii "test report" file containing basic
;stats on the slope image (if it exists) and frame images 

pro mql_test_report,info
if(XRegistered("mql_testreport")) then return

; widget window parameters
  xwidget_size = 900
  ywidget_size = 110

  xsize_scroll = 700
  ysize_scroll = 110


if(info.control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.control.x_scroll_window
if(info.control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.control.y_scroll_window
if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10

  ; Pop up a small widget so the user can type in a file name.
  ; Wait for the user to type a carriage-return.


outname = info.output.test_report

path = info.control.dirps
slash = '/'
print,'path ',path
if(path eq "") then slash = ''
filename = info.control.dirps + slash + info.control.filebase + $
           outname + '.txt'


pntrbase   = Widget_Base  (Title = mtitle, /Column, $
                           Group_Leader=info.RawQuicklook, $
;			      /Modal)
                           xsize = xwidget_size,$
                           ysize = ywidget_size,/scroll,$
                           x_scroll_size= xsize_scroll,$
                           y_scroll_size = ysize_scroll)                           
pntr1base =  Widget_Base(pntrbase, /Row)
label      = Widget_Label (pntr1base, Value='Output file name:')
selectfile = Widget_Text  (pntr1base, Value = filename, XSize = 100, /Edit, $
                           Event_Pro = 'test_report')
pntr2base  = Widget_Base  (pntrbase, /Row)

browseButton = Widget_Button(pntr2base, Value = ' Browse ')
printButton = Widget_Button(pntr2base, Value = ' Print ', $
                            Event_Pro = 'test_report')
cancelButton = Widget_Button(pntr2base, Value = ' Cancel ')

testreportinfo = {selectfile    :     selectfile,   $
                  browseButton  :     browseButton, $
                  cancelButton  :     cancelButton, $
                  filename      :     filename,     $
                  info         :     info        }

Widget_Control, pntrbase, set_uvalue = testreportinfo
Widget_Control, pntrbase, /Realize

XManager, "mql_testreport", pntrbase, Event_Handler = "test_report_event"

end

;_______________________________________________________________________
