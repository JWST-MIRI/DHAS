;***********************************************************************
pro mpl_pixel_values_quit,event
widget_control,event.top, Get_UValue = tinfo
widget_control,tinfo.info.QuickLook,Get_UValue=info
widget_control,info.PLPixelInfo,/destroy
end
;***********************************************************************



;***********************************************************************
;_______________________________________________________________________
;***********************************************************************
pro mpl_pixel_values_event,event

Widget_Control,event.id,Get_uValue=event_name
widget_control,event.top, Get_UValue = ginfo
widget_control,ginfo.info.QuickLook,Get_Uvalue = info

jintegration = info.pl.PIintegrationNO

if (widget_info(event.id,/TLB_SIZE_EVENTS) eq 1 ) then begin
    info.pl.PIxwindowsize = event.x
    info.pl.PIywindowsize = event.y
    info.pl.PIuwindowsize = 1
    widget_control,event.top,set_uvalue = ginfo
    widget_control,ginfo.info.Quicklook,set_uvalue = info
    mpl_display_pixel_values,info
    return
endif

    case 1 of
;_______________________________________________________________________

; change the display type: decimal, hex
;_______________________________________________________________________

    (strmid(event_name,0,7) EQ 'display') : begin
        if (strmid(event_name,7,1) EQ 'D') then info.pl.PIhex = 0 
        if (strmid(event_name,7,1) EQ 'H') then info.pl.PIhex = 1 
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
        mpl_display_pixel_values,info

    end

    (strmid(event_name,0,5) EQ 'print') : begin
        print_pixel_values,info
    end
;_______________________________________________________________________
; Change the integration No

    (strmid(event_name,0,6) EQ 'integr') : begin
	if (strmid(event_name,6,1) EQ 'a') then begin 
           this_value = event.value-1
           jintegration = this_value
	endif

; check if the <> buttons were used
       if (strmid(event_name,6,5) EQ '_move')then begin
          if(strmid(event_name,12,2) eq 'dn') then begin
             jintegration = jintegration -1
          endif
          if(strmid(event_name,12,2) eq 'up') then begin
             jintegration = jintegration+1
          endif
       endif

; do some checks 
       if(jintegration lt 0) then begin
            jintegrationNO = 0
        endif 
       if(jintegration gt info.data.nslopes-1 ) then jintegration = info.data.nslopes-1



        info.pl.PIintegrationNO = jintegration

        mpl_display_pixel_values,info
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end



else: ;print," Event name not found ",event_name
endcase
end


;_______________________________________________________________________
; The parameters for this widget are contained in the image_pixel
; structure, rather than a local imbedded structure because
; mql_event.pro also calls to update the pixel info widget

pro mpl_display_pixel_values,info

window,4,/pixmap
wdelete,4
if(XRegistered ('plpixel')) then begin
    widget_control,info.PLPixelInfo,/destroy
endif

;_______________________________________________________________________
;*********
;Setup main panel
;*********

; widget window parameters
xwidget_size = 1300
ywidget_size = 900

xsize_scroll = 1100
ysize_scroll = 600



if(info.pl.PIuwindowsize eq 1) then begin
    xsize_scroll = info.pl.PIxwindowsize
    ysize_scroll = info.pl.PIywindowsize
endif    

if(info.control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.control.x_scroll_window
if(info.control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.control.y_scroll_window

if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10

PixelInfo = widget_base(title=" Values for Pixels",$
                         col = 1,mbar = menuBar,group_leader = info.PixelLook,$
                        xsize = xwidget_size,ysize =ywidget_size,/base_align_right,$
                        /scroll,y_scroll_size= ysize_scroll,$
                        x_scroll_size= xsize_scroll,$
                        yoffset=100,/TLB_SIZE_EVENT)

;********
; build the menubar
;********
QuitMenu = widget_button(menuBar,value="Quit",font = info.font2)
PrintMenu = widget_button(menuBar,value="Print",font = info.font2)
quitbutton = widget_button(quitmenu,value="Quit",event_pro='mpl_pixel_values_quit')
printbutton = widget_button(printmenu,value="Print",uvalue='print')



ind = info.pl.group ; 0 pixel tracking file first 4 pixels
                    ; 1 pixel tracking file second 4 pixels
                    ; 2 random
	            ; 3 user defined

num = info.pltrack.num_group[ind]

xdata = (*info.pltrack.px)[ind,0:num-1]              ; typeof data, num pixels
ydata = (*info.pltrack.py)[ind,0:num-1]              ; typeof data, num pixels
data = (*info.pltrack.pdata)[ind,*,*,0:num-1] ; typeof data, num integ, num frames, num pixels

refcorrect_data = (*info.pltrack.prefcorrectdata)[ind,*,*,0:num-1]   
id_data = (*info.pltrack.piddata)[ind,*,*,0:num-1]   
lc_data = (*info.pltrack.plcdata)[ind,*,*,0:num-1]   
mdc_data = (*info.pltrack.pmdcdata)[ind,*,*,0:num-1]   
reset_data = (*info.pltrack.presetdata)[ind,*,*,0:num-1]   
lastframe_data = (*info.pltrack.plastframedata)[ind,*,0:num-1]   

                                    ; typeof data, num integ, num frames, num pixels

refdata = (*info.pltrack.prefdata)[ind,*,*,0:num-1] ;

if(info.data.subarray eq 0) then begin 
    refpL = (*info.pltrack.prefpL)[ind,*,*,0:num-1] ;
    refpR = (*info.pltrack.prefpR)[ind,*,*,0:num-1] ;
endif
             
;_______________________________________________________________________
; Pixel Statistics Display
;*********

display_base = widget_base(PixelInfo,/row,/nonexclusive,/align_left)
DMenu = widget_button(display_base,value='Decimial Display',uvalue='displayD')
HMenu = widget_button(display_base,value='Hexidecimal Display',uvalue='displayH')

widget_control,DMenu,Set_Button = 0
widget_control,HMenu,Set_Button =0
if(info.pl.PIhex eq 0) then widget_control,DMenu,Set_Button = 1
if(info.pl.PIhex eq 1) then widget_control,HMenu,Set_Button = 1


ii = info.data.nints
ij= info.data.nramps
this_integration = info.pl.PIintegrationNO

si = strtrim(string(ii),2)
sj = strtrim(string(ij),2)

if(info.data.coadd ne 1) then begin 
    move_base1 = widget_base(pixelinfo,row=1,/align_left)
    integration_label = cw_field(move_base1,$
                                 title="Integration # ",font=info.font5, $
                                 uvalue="integration",/integer,/return_events, $
                                 value=this_integration+1,xsize=4,$
                                 fieldfont=info.font3)

    labelID = widget_button(move_base1,uvalue='integr_move_dn',value='<',font=info.font3)
    labelID = widget_button(move_base1,uvalue='integr_move_up',value='>',font=info.font3)
    

    tlabel = "Total # " + strcompress(string(info.data.nslopes),/remove_all)
    
    total_ilabel = widget_label( move_base1,value = tlabel,/align_left)

    fLabel =widget_label(pixelinfo,value='Number of Frames/Int '+sj,/dynamic_resize,/align_left)
endif
pixFormat = ["F10.2"]

master1 = widget_base(pixelinfo,row=1,/align_left)
master2 = widget_base(pixelinfo,row=1,/align_left)
master3 = widget_base(pixelinfo,row=1,/align_left)
master4 = widget_base(pixelinfo,row=1,/align_left)
master5 = widget_base(pixelinfo,row=1,/align_left)
master6 = widget_base(pixelinfo,row=1,/align_left)
pixel_base = lonarr(6)
pixel_base[0] = widget_base(master1,col=1,/align_left)
pixel_base[1] = widget_base(master2,col=1,/align_left)
pixel_base[2] = widget_base(master3,col=1,/align_left)
pixel_base[3] = widget_base(master4,col=1,/align_left)
pixel_base[4] = widget_base(master5,col=1,/align_left)
pixel_base[5] = widget_base(master6,col=1,/align_left)



if(num ge 1) then begin 
    PA = ' Pixel A: ' + strcompress(string(xdata[0,0]),/remove_all) + ', ' + $
         strcompress(string(ydata[0,0]),/remove_all)
    pixelaID = widget_label(pixel_base[0],value =PA,/align_left)
endif


if(num ge 2) then begin 
    PB = ' Pixel B: ' + strcompress(string(xdata[0,1]),/remove_all) + ', ' + $
         strcompress(string(ydata[0,1]),/remove_all)
    pixelbID = widget_label(pixel_base[1],value =PB,/align_left)
endif

if(num ge 3) then begin 
    PC = ' Pixel C: ' + strcompress(string(xdata[0,2]),/remove_all) + ', ' + $
         strcompress(string(ydata[0,2]),/remove_all)
    pixelcID = widget_label(pixel_base[2],value =PC,/align_left)
endif

if(num ge 4) then begin 
    PD = ' Pixel D: ' + strcompress(string(xdata[0,3]),/remove_all) + ', ' + $
         strcompress(string(ydata[0,3]),/remove_all)
    pixeldID = widget_label(pixel_base[3],value =PD,/align_left)
endif

if(num ge 5) then begin 
    PE = ' Pixel E: ' + strcompress(string(xdata[0,4]),/remove_all) + ', ' + $
         strcompress(string(ydata[0,3]),/remove_all)
    pixeldIE = widget_label(pixel_base[4],value =PE,/align_left)
endif

iend = ij
if(info.data.coadd eq 1) then iend = ii

framevalue = strarr(iend+2)
refvalue = strarr(iend+2)
refLvalue =strarr(iend+2)
refRvalue = strarr(iend+2)
refcValue = strarr(iend+2)
idValue = strarr(iend+2)
lcValue = strarr(iend+2)
mdcValue = strarr(iend+2)
resetValue = strarr(iend+2)
lastframeValue = strarr(iend+2)


for k = 0, num -1 do begin 
; loop over frames in integration
    for j = 0,iend+1 do begin
        if(j le  1) then begin
            svalue  =  ' '
            srefvalue = ' ' 
            
            srefLvalue = ' '
            srefRvalue = ' '
            srefCvalue = ' '
            sidvalue = ' '
            slcvalue = ' '
            smdcvalue = ' '
            sresetvalue = ' '
            slastframevalue = ' '
            
            if(j eq 0) then begin 
                frame_no = 'Pixel Value'
                ref_no = 'Associated'
                refL_no = "Left Reference"
                refR_no = "Right Reference"
                refc_no = "Reference Corrected"
                id_no =   "Data Quality Flag"
                mdc_no =   "Dark Corrected Data"
                reset_no =   "Reset Corrected Data"
                lastframe_no =   "Last Frame Corrected Data"
                lc_no =   "Lin Corrected Data"
            endif
            
            if(j eq 1) then begin 
                frame_no = 'for Frame #'
                if(info.data.coadd eq 1) then frame_no = ' for Int '
                ref_no = 'Reference output '
                refL_no = "Pixel
                refR_no = "Pixel
                refc_no = "Value"
                id_no =" " 
                lc_no =" " 
                mdc_no =" " 
                reset_no =" " 
                lastframe_no =" " 
            endif
        endif else begin
                
; look fast/slow mode data
            if(info.data.coadd ne 1) then begin 
                dataV1 = data[*,this_integration,j-2,k]
                dataV2 = refdata[*,this_integration,j-2,k]
                if(info.data.subarray eq 0) then begin
                    dataV3 = refpL[*,this_integration,j-2,k]
                    dataV4= refpR[*,this_integration,j-2,k]
                    srefLvalue = strtrim(string(dataV3,format="("+pixFormat[0]+")"),2) 
                    srefRvalue = strtrim(string(dataV4,format="("+pixFormat[0]+")"),2) 
                endif else begin
                    srefLvalue = 'NA'
                    srefRvalue = 'NA'
                endelse
                dataV5= refcorrect_data[*,this_integration,j-2,k]
                dataV6= id_data[*,this_integration,j-2,k]
                dataV7= lc_data[*,this_integration,j-2,k]
                dataV8= mdc_data[*,this_integration,j-2,k]
                dataV9= reset_data[*,this_integration,j-2,k]
                dataV10= lastframe_data[*,this_integration,k]
                
; grab fast-short mode data
            endif else begin
                dataV1 = data[*,j-2,0,k]
                dataV2 = refdata[*,j-2,0,k]
                if(info.data.subarray eq 0) then begin
                    dataV3 = refpL[*,j-2,0,k]
                    dataV4= refpR[*,j-2,0,k]
                    srefLvalue = strtrim(string(dataV3,format="("+pixFormat[0]+")"),2) 
                    srefRvalue = strtrim(string(dataV4,format="("+pixFormat[0]+")"),2) 
                endif else begin
                    srefLvalue = 'NA'
                    srefRvalue = 'NA'
                endelse

                dataV5= refcorrect_data[*,j-2,0,k]
                dataV6= id_data[*,j-2,0,k]
                dataV7= lc_data[*,j-2,0,k]
                dataV8= mdc_data[*,j-2,0,k]
                dataV9= reset_data[*,j-2,0,k]
                dataV10= lastframe_data[*,0,k]
            endelse
            
            svalue = strtrim(string(dataV1,format="("+pixFormat[0]+")"),2) 
            srefvalue = strtrim(string(dataV2,$
                                       format="("+pixFormat[0]+")"),2)
                
            srefCvalue = strtrim(string(dataV5,format="("+pixFormat[0]+")"),2) 
            sidvalue = strtrim(string(dataV6,format="("+pixFormat[0]+")"),2) 
            slcvalue = strtrim(string(dataV7,format="("+pixFormat[0]+")"),2) 
            smdcvalue = strtrim(string(dataV8,format="("+pixFormat[0]+")"),2) 
            sresetvalue = strtrim(string(dataV9,format="("+pixFormat[0]+")"),2) 
            slastframevalue = strtrim(string(dataV10,format="("+pixFormat[0]+")"),2) 


            if(info.pl.PIhex eq 1) then  begin
                if(dataV1 lt 0) then begin
                    svalue = " Negative Value "
                    
                endif else begin
                    dec2hex,dataV1,hdataV1,quiet=1,upper=1
                    svalue = strtrim(string(hdataV1),2) 
                endelse
                
                if(dataV2 lt 0) then begin
                    srefvalue = " Negative Value " 
                endif else begin
                    dec2hex,dataV2,hdataV2,quiet=1,upper=1
                    srefvalue = strtrim(string(hdataV2),2) 
                endelse
                
                if(dataV3 lt 0) then begin
                    srefLvalue = " Negative Value " 
                endif else begin
                    dec2hex,dataV3,hdataV3,quiet=1,upper=1
                    srefLvalue = strtrim(string(hdata32),2) 
                endelse
                
                if(dataV4 lt 0) then begin
                    srefRvalue = " Negative Value " 
                endif else begin
                    dec2hex,dataV4,hdataV4,quiet=1,upper=1
                    srefRvalue = strtrim(string(hdataV4),2) 
                endelse
            endif
            
                
            itest = (j-2+1)
            
            if(info.pl.refpixel_option eq 0 or  info.control.file_refcorrection_exist eq 0) then begin 
                srefCvalue = 'NA'
            endif else begin
                if(itest lt info.pl.start_fit or itest gt info.pl.end_fit) then begin
                    srefCvalue = 'NA'
                endif
            endelse


            if(info.control.file_ids_exist eq 0) then begin 
                sidvalue = 'NA'
            endif else begin
                if(itest lt info.pl.start_fit or itest gt info.pl.end_fit) then begin
                    sidvalue = 'NA'
                endif
            endelse


            if(info.control.file_lc_exist eq 0) then begin 
                slcvalue = 'NA'
            endif else begin
                if(itest lt info.pl.start_fit or itest gt info.pl.end_fit) then begin
                    slcvalue = 'NA'
                endif
            endelse

            if(info.control.file_mdc_exist eq 0) then begin 
                smdcvalue = 'NA'
            endif else begin
                if(itest lt info.pl.start_fit or itest gt info.pl.end_fit) then begin
                    smdcvalue = 'NA'
                endif
             endelse

            if(info.control.file_reset_exist eq 0) then begin 
                sresetvalue = 'NA'
            endif else begin
                if(itest lt info.pl.start_fit or itest gt info.pl.end_fit) then begin
                    sresetvalue = 'NA'
                endif
             endelse

            if(info.control.file_lastframe_exist eq 0) then begin 
                slastframevalue = 'NA'
            endif else begin
                if(itest lt info.pl.start_fit or itest gt info.pl.end_fit) then begin
                    slastframevalue = 'NA'
                endif
            endelse
            
            frame_no = strcompress(string(fix(j-1)),/remove_all)+ " = " 
            ref_no = frame_no
            refL_no = frame_no
            refR_no = frame_no
            refc_no = frame_no
            id_no = frame_no
            lc_no = frame_no
            mdc_no = frame_no
            reset_no = frame_no
            lastframe_no = frame_no
            
        endelse
        framevalue[j] = frame_no + svalue
        refvalue[j] = ref_no + srefvalue
        refLvalue[j] = refl_no + srefLvalue
        refRvalue[j] = refr_no + srefRvalue
        refCvalue[j] = refc_no + srefCvalue
        idvalue[j] = id_no + sidValue
        lcvalue[j] = lc_no + slcValue
        mdcvalue[j] = mdc_no + smdcValue
        resetvalue[j] = reset_no + sresetValue
        lastframevalue[j] = lastframe_no + slastframeValue
    endfor

    pix2 = widget_base(pixel_base[k],row=1,/align_left)
    pixID1 = widget_list(pix2,$
                         value=framevalue,/align_left,$
                         scr_ysize=200,uvalue ='')
    
    pixID2 = widget_list(pix2,$
                         value=refvalue,/align_left,$
                         scr_ysize=200,uvalue='')
    
    pixID3 = widget_list(pix2,$
                         value=reflvalue,/align_left,$
                         scr_ysize=200,uvalue='')
    
    pixID4 = widget_list(pix2,$
                         value=refrvalue,/align_left,$
                         scr_ysize=200,uvalue = '')
    
    pixID5 = widget_list(pix2,$
                         value=refcvalue,/align_left,$
                         scr_ysize=200,uvalue = '')

    pixID6 = widget_list(pix2,$
                         value=idvalue,/align_left,$
                         scr_ysize=200,uvalue = '')

    pixID7 = widget_list(pix2,$
                         value=lcvalue,/align_left,$
                         scr_ysize=200,uvalue = '')

    pixID8 = widget_list(pix2,$
                         value=mdcvalue,/align_left,$
                         scr_ysize=200,uvalue = '')

    pixID9 = widget_list(pix2,$
                         value=resetvalue,/align_left,$
                         scr_ysize=200,uvalue = '')


    pixID10 = widget_list(pix2,$
                         value=lastframevalue,/align_left,$
                         scr_ysize=200,uvalue = '')
    
                                                      
endfor
info.PLPixelInfo = pixelinfo

pixel = {info                  : info}	



Widget_Control,info.PLPixelInfo,Set_UValue=pixel
widget_control,info.PLPixelInfo,/realize

XManager,'plpixel',pixelinfo,/No_Block,event_handler = 'mpl_pixel_values_event'

Widget_Control,info.QuickLook,Set_UValue=info

end


;_______________________________________________________________________
pro mpl_print_pixel_values,info,ascii=ascii,unit=iunit



ind = info.pl.group ; 0 pixel tracking file first 4 pixels
                    ; 1 pixel tracking file second 4 pixels
                    ; 2 random
	            ; 3 user defined

num = info.pltrack.num_group[ind]

xdata = (*info.pltrack.px)[ind,0:num-1]              ; typeof data, num pixels
ydata = (*info.pltrack.py)[ind,0:num-1]              ; typeof data, num pixels
data = (*info.pltrack.pdata)[ind,*,*,0:num-1] ; typeof data, num integ, num frames, num pixels

refcorrect_data = (*info.pltrack.prefcorrectdata)[ind,*,*,0:num-1]   
                                ; typeof data, num integ, num frames,
                                ; num pixels

id_data = (*info.pltrack.piddata)[ind,*,*,0:num-1]   
lc_data = (*info.pltrack.plcdata)[ind,*,*,0:num-1]   
mdc_data = (*info.pltrack.pmdcdata)[ind,*,*,0:num-1]   
reset_data = (*info.pltrack.presetdata)[ind,*,*,0:num-1]   
reset_data = (*info.pltrack.presetdata)[ind,*,*,0:num-1]   
lastframe_data = (*info.pltrack.plastframedata)[ind,*,0:num-1]   
                                    ; typeof data, num integ, num frames, num pixels

refdata = (*info.pltrack.prefdata)[ind,*,*,0:num-1] ;

if(info.data.subarray eq 0) then begin 
    refpL = (*info.pltrack.prefpL)[ind,*,*,0:num-1] ;
    refpR = (*info.pltrack.prefpR)[ind,*,*,0:num-1] ;
endif

ii = info.data.nslopes
ij= info.data.nramps
this_integration = info.pl.PIintegrationNO

if(keyword_set(ascii)) then begin 
    if(N_elements(iunit)) then begin

printf,iunit,' co1 1: x pixel value, co1 2: y pixel value, col 3: integration, col 4: frame, ' + $
       'col 5: raw value , col 6: ref  image, col 7: left ref pixel, '+ $
       'col 8: right ref pixel, '+ 'col 9: ref corrected value (=-9999.00 if no correction or correction file)'+$
       'col 10: Data Quality Flag (=-99 if no file or no flag)'

        for k = 0, num -1 do begin 
            
; loop over frames in integration
            for j = 0,ij-1 do begin
                dataV1 = data[*,this_integration,j,k]

                dataV2 = refdata[*,this_integration,j,k]
                if(info.data.subarray eq 0) then begin 
                    dataV3 = refpL[*,this_integration,j,k]
                    dataV4= refpR[*,this_integration,j,k]
                endif else begin
                    dataV3 = 0
                    dataV4 = 0
                endelse
                dataV5= refcorrect_data[*,this_integration,j,k]
                if(info.pl.refpixel_option eq 0 or  info.control.file_refcorrection_exist eq 0) then dataV5 = -99999.99

                dataV6= id_data[*,this_integration,j,k]
                if(info.control.ids_file_exist eq 0) then dataV6 = -99

                dataV7= lc_data[*,this_integration,j,k]
                if(info.control.lc_file_exist eq 0) then dataV7 = -99

                dataV8= mdc_data[*,this_integration,j,k]
                if(info.control.mdc_file_exist eq 0) then dataV8 = -99

                dataV9= reset_data[*,this_integration,j,k]
                if(info.control.reset_file_exist eq 0) then dataV9 = -99

                dataV10= lastframe_data[*,this_integration,j,k]
                if(info.control.lastframe_file_exist eq 0) then dataV10 = -99


                if(j+1 lt info.pl.start_fit or j+1 gt info.pl.end_fit) then begin
                    dataV5 =  -99999.99
                    dataV6 =  -99
                    dataV7 =  -99999.99
                    dataV8 =  -99999.99
                    dataV9 =  -99999.99
                    
                endif
                    
                printf,iunit,format = '(i5,i5,i4,i5,5f12.4,i5,2f12.4)',xdata[k],ydata[k], this_integration+1,j+1,$
                       dataV1[0],dataV2[0],dataV3[0],dataV4[0],dataV5[0],dataV6[0],dataV7[0],dataV8[0],dataV9[0]

                
            endfor
        endfor
    endif
endif
end
