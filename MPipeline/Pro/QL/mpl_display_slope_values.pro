;***********************************************************************
pro mpl_slope_values_quit,event
widget_control,event.top, Get_UValue = tinfo
widget_control,tinfo.info.QuickLook,Get_UValue=info
widget_control,info.PLSLOPEInfo,/destroy
end
;***********************************************************************
;_______________________________________________________________________
;***********************************************************************
pro mpl_slope_values_event,event

Widget_Control,event.id,Get_uValue=event_name
widget_control,event.top, Get_UValue = ginfo
widget_control,ginfo.info.QuickLook,Get_Uvalue = info


if (widget_info(event.id,/TLB_SIZE_EVENTS) eq 1 ) then begin
    info.pl.PIxwindowsize = event.x
    info.pl.PIywindowsize = event.y
    info.pl.PIuwindowsize = 1
    widget_control,event.top,set_uvalue = ginfo
    widget_control,ginfo.info.Quicklook,set_uvalue = info
    mpl_display_slope_values,info
    return
endif

end
;_______________________________________________________________________
; The parameters for this widget are contained in the image_slope
; structure, rather than a local imbedded structure because
; mql_event.pro also calls to update the slope info widget

pro mpl_display_slope_values,info

window,4,/pixmap
wdelete,4
if(XRegistered ('plslope')) then begin
    widget_control,info.PLSlopeInfo,/destroy
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
    xsize_scroll = info.pl.PIxwindowsize
    ysize_scroll = info.pl.PIywindowsize
    
endif

if(info.control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.control.x_scroll_window
if(info.control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.control.y_scroll_window

if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10


SlopeInfo = widget_base(title=" Values for Pixels",$
                         col = 1,mbar = menuBar,group_leader = info.PixelLook,$
                        xsize = xwidget_size,ysize =ywidget_size,/base_align_right,$
                        /scroll,y_scroll_size= ysize_scroll,$
                        x_scroll_size= xsize_scroll,$
                        yoffset=100,/TLB_SIZE_EVENT)

;********
; build the menubar
;********
QuitMenu = widget_button(menuBar,value="Quit",font = info.font2)
quitbutton = widget_button(quitmenu,value="Quit",event_pro='mpl_slope_values_quit')



ind = info.pl.group ; 0 slope tracking file first 4 slopes
                    ; 1 slope tracking file second 4 slopes
                    ; 2 random
	            ; 3 user defined

num = info.pltrack.num_group[ind]

xdata = (*info.pltrack.px)[ind,0:num-1]              ; typeof data, num slopes
ydata = (*info.pltrack.py)[ind,0:num-1]              ; typeof data, num slopes


slope = (*info.pltrack.pslope)[ind,*,0:num-1]              
unc = (*info.pltrack.punc)[ind,*,0:num-1]
quality = (*info.pltrack.pid)[ind,*,0:num-1] ; 
numgood = (*info.pltrack.pnumgood)[ind,*,0:num-1] ; 
zeropt = (*info.pltrack.pzeropt)[ind,*,0:num-1] ; 
firstsat = (*info.pltrack.pfirstsat)[ind,*,0:num-1] ; 
nseg = (*info.pltrack.pnseg)[ind,*,0:num-1] ; 

             
;_______________________________________________________________________
; Pixel Statistics Display
;*********


ii = info.data.nslopes
ij= info.data.nramps


si = strtrim(string(ii),2)
sj = strtrim(string(ij),2)


fLabel =widget_label(slopeinfo,value='Number of Frames/Int '+sj,/dynamic_resize,/align_left)

pixFormat = ["F10.2"]

master1 = widget_base(slopeinfo,row=1,/align_left)
master2 = widget_base(slopeinfo,row=1,/align_left)
master3 = widget_base(slopeinfo,row=1,/align_left)
pixel_base = lonarr(5)
pixel_base[0] = widget_base(master1,col=1,/align_left)
pixel_base[1] = widget_base(master1,col=1,/align_left)
pixel_base[2] = widget_base(master2,col=1,/align_left)
pixel_base[3] = widget_base(master2,col=1,/align_left)
pixel_base[4] = widget_base(master3,col=1,/align_left)

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

slopevalue = strarr(ii+2)
uncvalue = strarr(ii+2)
zerovalue = strarr(ii+2)
firstsatvalue = strarr(ii+2)
nsegvalue = strarr(ii+2)
idvalue = strarr(ii+2)
goodvalue = strarr(ii+2)

for k = 0, num -1 do begin 
    for j = 0,ii+1 do begin
        if(j le  1) then begin
            svalue  =  ' '
            uvalue = ' ' 
            ivalue = ' ' 
            zvalue = ' '
            fvalue = ' '
            gvalue = ' '   
            segvalue = ' ' 
            if(j eq 0) then begin 
                slope_no = 'Slope'
                unc_no = 'Uncertainity'
                id_no = 'Quality Flag '
                good_no = '# Good '
                zeropt_no= 'Zero Pt '
                firstsat_no ='1st Sat Read' 
                seg_no = ' # of Segments'

            endif

            if(j eq 1) then begin 
                slope_no = 'for int #'
                unc_no = 'for int #'
                id_no = 'for int #'
                good_no = 'for int #'
                zeropt_no= 'for int#'
                firstsat_no ='for int #'
                seg_no ='for int #'
            endif

        endif else begin 
            
            dataV3 = slope[*,j-2,k]
            dataV4 = unc[*,j-2,k]
            dataV5 = quality[*,j-2,k]
            dataV6 = numgood[*,j-2,k]
            dataV7 = zeropt[*,j-2,k]
            dataV8 = firstsat[*,j-2,k]
            dataV9 = nseg[*,j-2,k]


            svalue = strtrim(string(dataV3,format="(f11.3)"),2) 
            uvalue = strtrim(string(dataV4,format="(f11.3)"),2) 
            ivalue = strtrim(string(dataV5,format="(i3)"),2)
            gvalue = strtrim(string(dataV6,format="(f5.0)"),2)
            zvalue = strtrim(string(dataV7,format="(f11.3)"),2)   
            Fvalue = strtrim(string(dataV8,format="(f5.0)"),2) 
            Segvalue = strtrim(string(dataV9,format="(i4)"),2) 

            if(dataV4 eq -99) then uvalue = 'NA'

            int_no = strcompress(string(fix(j-1)),/remove_all)+ " = " 

            slope_no = int_no
            unc_no = int_no
            id_no = int_no
            good_no = int_no
            zeropt_no= int_no
            firstsat_no =int_no
            seg_no = int_no

        endelse
        slopevalue[j] = slope_no + svalue

        uncvalue[j] = unc_no + uvalue
        idvalue[j] = id_no + ivalue
        zerovalue[j] = zeropt_no + zvalue
        goodvalue[j] = good_no + gvalue
        firstsatvalue[j] = firstsat_no + fvalue
        nsegvalue[j] = seg_no + Segvalue
    endfor
    


    pix2 = widget_base(pixel_base[k],row=1,/align_left)
    pixID1 = widget_list(pix2,$
                         value=slopevalue,/align_left,$
                         scr_ysize=150)

    pixID2 = widget_list(pix2,$
                         value=uncvalue,/align_left,$
                         scr_ysize=150)

    pixID3 = widget_list(pix2,$
                         value=idvalue,/align_left,$
                         scr_ysize=150)

    pixID4 = widget_list(pix2,$
                         value=goodvalue,/align_left,$
                         scr_ysize=150)
    pixID5 = widget_list(pix2,$
                         value=zerovalue,/align_left,$
                         scr_ysize=150)
    pixID6 = widget_list(pix2,$
                         value=firstsatvalue,/align_left,$
                         scr_ysize=150)

    pixID6 = widget_list(pix2,$
                         value=nsegvalue,/align_left,$
                         scr_ysize=150)

                                                     
                                                      
endfor
info.PLSLOPEInfo = slopeinfo

slope = {info                  : info}	



Widget_Control,info.PLSLOPEInfo,Set_UValue=slope
widget_control,info.PLSLOPEInfo,/realize

XManager,'plslope',slopeinfo,/No_Block,event_handler = 'mpl_slope_values_event'

Widget_Control,info.QuickLook,Set_UValue=info

end
