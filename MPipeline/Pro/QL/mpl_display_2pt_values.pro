;***********************************************************************
pro mpl_2pt_values_quit,event
widget_control,event.top, Get_UValue = tinfo
widget_control,tinfo.info.QuickLook,Get_UValue=info
widget_control,info.PL2ptInfo,/destroy
end
;***********************************************************************

;_______________________________________________________________________
;***********************************************************************
pro mpl_2pt_values_event,event

Widget_Control,event.id,Get_uValue=event_name
widget_control,event.top, Get_UValue = ginfo
widget_control,ginfo.info.QuickLook,Get_Uvalue = info


if (widget_info(event.id,/TLB_SIZE_EVENTS) eq 1 ) then begin
    info.pl.PIxwindowsize = event.x
    info.pl.PIywindowsize = event.y
    info.pl.PIuwindowsize = 1
    widget_control,event.top,set_uvalue = ginfo
    widget_control,ginfo.info.Quicklook,set_uvalue = info
    mpl_display_2pt_values,info
    return
endif

end
;_______________________________________________________________________
; The parameters for this widget are contained in the image_slope
; structure, rather than a local imbedded structure because
; mql_event.pro also calls to update the slope info widget

pro mpl_display_2pt_values,info

window,4,/pixmap
wdelete,4
if(XRegistered ('pl2pt')) then begin
    widget_control,info.PL2ptInfo,/destroy
endif

;_______________________________________________________________________
;*********
;Setup main panel
;*********

; widget window parameters
xwidget_size = 1300
ywidget_size = 900

xsize_scroll = 1200
ysize_scroll = 850


if(info.pl.PIuwindowsize eq 1) then begin
    xsize_scroll = info.fl.PIxwindowsize
    ysize_scroll = info.fl.PIywindowsize
    
endif 
if(info.control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.control.x_scroll_window
if(info.control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.control.y_scroll_window

if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10


TwoptInfo = widget_base(title=" Values for Pixels",$
                         col = 1,mbar = menuBar,group_leader = info.PixelLook,$
                        xsize = xwidget_size,ysize =ywidget_size,/base_align_right,$
                        /scroll,y_scroll_size= ysize_scroll,$
                        x_scroll_size= xsize_scroll,$
                        yoffset=100,/TLB_SIZE_EVENT)

;********
; build the menubar
;********
QuitMenu = widget_button(menuBar,value="Quit",font = info.font2)
quitbutton = widget_button(quitmenu,value="Quit",event_pro='mpl_2pt_values_quit')



ind = info.pl.group ; 0 slope tracking file first 4 slopes
                    ; 1 slope tracking file second 4 slopes
                    ; 2 random
	            ; 3 user defined

num = info.pltrack.num_group[ind]

xdata = (*info.pltrack.px)[ind,0:num-1]              ; typeof data, num slopes
ydata = (*info.pltrack.py)[ind,0:num-1]              ; typeof data, num slopes

num_int = info.data.nslopes
data = (*info.pltrack.pdata)[ind,*,*,0:num-1]    ; typeof data, num integ, num frames, num pixels
refcorrect_data = (*info.pltrack.prefcorrectdata)[ind,*,*,0:num-1]   
;_______________________________________________________________________
; raw data twopt differences 

istart = info.pl.start_fit-1
iend = info.pl.end_fit-1

nvalid = iend - istart

xvalues_plot = indgen(nvalid) + info.pl.start_fit
twopt_diff = fltarr(1,num_int,nvalid,num)
lin_fit = fltarr(2,num_int,num)
max2pt = fltarr(num_int,num)
iread = intarr(num_int,num)
stdev2pt = fltarr(num_int,num)
jj = 0
for j = istart, iend-1 do begin
    twopt_diff[0,*,jj,*] = data[0,*,j+1,*] - data[0,*,j,*]
    jj  = jj + 1
endfor


yfit = fltarr(num_int,nvalid,num)
;linfit : y = A + Bx
yvalues_fit = float(xvalues_plot)
for k = 0,num_int-1 do begin
    for i = 0,num -1 do begin
        yvalues_fit[*] = twopt_diff[0,k,*,i]
        stdev2pt[k,i] = stddev(yvalues_fit)
        max2pt[k,i] = max(abs(yvalues_fit))
        ii = where(max2pt[k,i] eq abs(yvalues_fit))
        max2pt[k,i] = yvalues_fit[ii[0]]
        iread[k,i] = ii[0]+ info.pl.start_fit

        result = linfit(xvalues_plot,yvalues_fit)
        lin_fit[0,k,i] = result[0]
        lin_fit[1,k,i] = result[1]
    endfor
    
endfor


twopt_diff_corrected = twopt_diff
lin_fit_corrected = lin_fit

yfit_corrected = yfit
max2pt_corrected = fltarr(num_int,num)
iread_corrected = intarr(num_int,num)
stdev2pt_corrected = fltarr(num_int,num)


if(info.control.file_refcorrection_exist eq 1 )then begin 
    jj = 0
    for j = istart, iend-1 do begin
       twopt_diff_corrected[0,*,jj,*] = refcorrect_data[0,*,j+1,*] - refcorrect_data[0,*,j,*]
       jj  = jj + 1
    endfor


;linfit : y = A + Bx
    yvalues_fit = xvalues_plot
    for k = 0,num_int-1 do begin
        for i = 0,num -1 do begin

                yvalues_fit[*] = twopt_diff_corrected[0,k,*,i]
        
                stdev2pt_corrected[k,i] = stddev(yvalues_fit)
                max2pt_corrected[k,i] = max(abs(yvalues_fit))
                ii = where(max2pt_corrected[k,i] eq abs(yvalues_fit))
                max2pt_corrected[k,i] = yvalues_fit[ii[0]]
                iread_corrected[k,i] = ii[0] 

                result = linfit(xvalues_plot,yvalues_fit)
                lin_fit_corrected[0,k,i] = result[0]
                lin_fit_corrected[1,k,i] = result[1]

        endfor
    endfor

endif



             
;_______________________________________________________________________
; Pixel Statistics Display
;*********


ii = info.data.nslopes
ij= info.data.nramps


si = strtrim(string(ii+1),2)
sj = strtrim(string(ij+1),2)


fLabel =widget_label(TwoptInfo,value='Number of Frames/Int '+sj,/dynamic_resize,/align_left)

pixFormat = ["F10.2"]

master1 = widget_base(TwoptInfo,row=1,/align_left)
master2 = widget_base(TwoptInfo,row=1,/align_left)
master3 = widget_base(TwoptInfo,row=1,/align_left)
master4 = widget_base(TwoptInfo,row=1,/align_left)
master5 = widget_base(TwoptInfo,row=1,/align_left)
pixel_base = lonarr(5)
pixel_base[0] = widget_base(master1,col=1,/align_left)
pixel_base[1] = widget_base(master2,col=1,/align_left)
pixel_base[2] = widget_base(master3,col=1,/align_left)
pixel_base[3] = widget_base(master4,col=1,/align_left)
pixel_base[4] = widget_base(master5,col=1,/align_left)

PA = ' Pixel A: ' + strcompress(string(xdata[0,0]),/remove_all) + ', ' + $
     strcompress(string(ydata[0,0]),/remove_all)
PB = ' Pixel B: ' + strcompress(string(xdata[0,1]),/remove_all) + ', ' + $
     strcompress(string(ydata[0,1]),/remove_all)
PC = ' Pixel C: ' + strcompress(string(xdata[0,2]),/remove_all) + ', ' + $
     strcompress(string(ydata[0,2]),/remove_all)
PD = ' Pixel D: ' + strcompress(string(xdata[0,3]),/remove_all) + ', ' + $
     strcompress(string(ydata[0,3]),/remove_all)
PE = ' Pixel E: ' + strcompress(string(xdata[0,4]),/remove_all) + ', ' + $
     strcompress(string(ydata[0,3]),/remove_all)
pixelaID = widget_label(pixel_base[0],value =PA,/align_left)
pixelbID = widget_label(pixel_base[1],value =PB,/align_left)
pixelcID = widget_label(pixel_base[2],value =PC,/align_left)
pixeldID = widget_label(pixel_base[3],value =PD,/align_left)
pixeldIE = widget_label(pixel_base[4],value =PE,/align_left)

maxvalue = strarr(ii+2)
imaxvalue = strarr(ii+2)
slopevalue = strarr(ii+2)
devvalue = strarr(ii+2)

maxvalue_corrected = strarr(ii+2)
imaxvalue_corrected = strarr(ii+2)
slopevalue_corrected = strarr(ii+2)
devvalue_corrected = strarr(ii+2)

for k = 0, num -1 do begin 
    for j = 0,ii+1 do begin
        if(j le  1) then begin
            mvalue  =  ' '
            ivalue = ' ' 
            svalue = ' ' 
            dvalue = ' '

            mvalue_corrected  =  ' '
            ivalue_corrected = ' ' 
            svalue_corrected = ' ' 
            dvalue_corrected = ' '

            
            if(j eq 0) then begin 
                max_no = 'Max 2pt'
                imax_no = 'Frame Max 2pt'
                slope_no = 'Slope 2pt '
                dev_no = '# Stdev 2 pt '

                max_no_corrected = 'Max 2pt: Corrected'
                imax_no_corrected = 'Frame Max 2pt: Corrected'
                slope_no_corrected = 'Slope 2pt: Corrrected '
                dev_no_corrected = '# Stdev 2 pt: Corrected '


            endif

            if(j eq 1) then begin 
                max_no = 'for int #'
                imax_no = 'for int #'
                slope_no = 'for int #'
                dev_no = 'for int #'

                max_no_corrected = 'for int #'
                imax_no_corrected = 'for int #'
                slope_no_corrected = 'for int #'
                dev_no_corrected = 'for int #'

            endif

        endif else begin 
            
            dataV3 = max2pt[j-2,k]
            dataV4 = iread[j-2,k]
            dataV5 = lin_fit[1,j-2,k]
            dataV6 = stdev2pt[j-2,k]

            mvalue = strtrim(string(dataV3,format="(f11.4)"),2) 
            ivalue = strtrim(string(dataV4,format="(i4)"),2) 
            svalue = strtrim(string(dataV5,format="(f11.4)"),2)
            dvalue = strtrim(string(dataV6,format="(f11.4)"),2)

            int_no = strcompress(string(fix(j-1)),/remove_all)+ " = " 

            
            max_no = int_no
            imax_no = int_no
            slope_no = int_no
            dev_no = int_no


            dataV7 = max2pt_corrected[j-2,k]
            dataV8 = iread_corrected[j-2,k]
            dataV9 = lin_fit_corrected[1,j-2,k]
            dataV10 = stdev2pt_corrected[j-2,k]

            mvalue_corrected = strtrim(string(dataV7,format="(f11.4)"),2) 
            ivalue_corrected = strtrim(string(dataV8,format="(i4)"),2) 
            svalue_corrected = strtrim(string(dataV9,format="(f11.4)"),2)
            dvalue_corrected = strtrim(string(dataV10,format="(f11.4)"),2)


            max_no_corrected = int_no
            imax_no_corrected = int_no
            slope_no_corrected = int_no
            dev_no_corrected = int_no

        endelse
        maxvalue[j] = max_no + mvalue
        imaxvalue[j] = imax_no + ivalue
        slopevalue[j] = slope_no + svalue
        devvalue[j] = dev_no + dvalue

        maxvalue_corrected[j] = max_no_corrected + mvalue_corrected
        imaxvalue_corrected[j] = imax_no_corrected + ivalue_corrected
        slopevalue_corrected[j] = slope_no_corrected + svalue_corrected
        devvalue_corrected[j] = dev_no_corrected + dvalue_corrected

    endfor
    
    
    
    pix2 = widget_base(pixel_base[k],row=1,/align_left)
    pixID1 = widget_list(pix2,$
                         value=maxvalue,/align_left,$
                         scr_ysize=150)

    pixID2 = widget_list(pix2,$
                         value=imaxvalue,/align_left,$
                         scr_ysize=150)

    pixID3 = widget_list(pix2,$
                         value=slopevalue,/align_left,$
                         scr_ysize=150)

    pixID4 = widget_list(pix2,$
                         value=devvalue,/align_left,$
                         scr_ysize=150)
                                               

    if(info.control.file_refcorrection_exist)then begin
        pixID1 = widget_list(pix2,$
                             value=maxvalue_corrected,/align_left,$
                             scr_ysize=150)

        pixID2 = widget_list(pix2,$
                             value=imaxvalue_corrected,/align_left,$
                             scr_ysize=150)

        pixID3 = widget_list(pix2,$
                             value=slopevalue_corrected,/align_left,$
                             scr_ysize=150)

        pixID4 = widget_list(pix2,$
                             value=devvalue_corrected,/align_left,$
                             scr_ysize=150)
    endif
       
endfor
info.PL2ptInfo = TwoptInfo

twopt = {info                  : info}	



Widget_Control,info.PL2ptInfo,Set_UValue=twopt
widget_control,info.PL2ptInfo,/realize

XManager,'pl2pt',TwoptInfo,/No_Block,event_handler = 'mpl_2pt_values_event'

Widget_Control,info.QuickLook,Set_UValue=info

end
