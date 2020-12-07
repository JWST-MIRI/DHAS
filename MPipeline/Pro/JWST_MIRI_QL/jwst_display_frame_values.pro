;***********************************************************************
pro jwst_frame_values_quit,event
widget_control,event.top, Get_UValue = tinfo
widget_control,tinfo.info.jwst_QuickLook,Get_UValue=info
widget_control,info.jwst_RPixelInfo,/destroy
end
;***********************************************************************

pro jwst_frame_values_event,event

Widget_Control,event.id,Get_uValue=event_name
widget_control,event.top, Get_UValue = ginfo
widget_control,ginfo.info.jwst_QuickLook,Get_Uvalue = info

    case 1 of
;_______________________________________________________________________
    (strmid(event_name,0,8) EQ 'datainfo') : begin
       jwst_dqflags,info
    end
;_______________________________________________________________________

else: ;print," Event name not found ",event_name
endcase
end


;_______________________________________________________________________
; The parameters for this widget are contained in the image_pixel
; structure, rather than a local imbedded structure because
; mql_event.pro also calls to update the pixel info widget

pro jwst_display_frame_values,xvalue,yvalue,info

window,4,/pixmap
wdelete,4
if(XRegistered ('jwst_mpixel')) then begin
    widget_control,info.jwst_RPixelInfo,/destroy
endif

;_______________________________________________________________________
;*********
;Setup main panel
;*********

PixelInfo = widget_base(title=" Frame Values for Pixel",$
                        col = 1,mbar = menuBar,group_leader = info.jwst_RawQuickLook,$
                        xsize = 1400,ysize = 500,/base_align_right,xoffset=550,yoffset=100,$
                        /scroll,x_scroll_size = 1000,y_scroll_size = 500)

;********
; build the menubar
;********
QuitMenu = widget_button(menuBar,value="Quit",font = info.font2)
quitbutton = widget_button(quitmenu,value="Quit",event_pro='jwst_frame_values_quit')

info.jwst_image_pixel.xvalue = xvalue
info.jwst_image_pixel.yvalue = yvalue
;_______________________________________________________________________
; Pixel Statistics Display
;*********
title_label = widget_label(PixelInfo,value = info.jwst_image_pixel.filename,/align_left)

pix_statLabel = strarr(7)
pix_statFormat = strarr(7)

pix_statLabel =["Integration", "X", "Y", "Signal (DN/S)", "Error (DN/S)","Data Quality Flag"]

pix_statFormat = ["I3", "I4", "I4", "F16.5","F16.5","I8"]

nend = info.jwst_data.ngroups
i = info.jwst_image_pixel.integrationNO


ssignal = 'NA'
serror = 'NA'
si = strtrim(string(i+1,format="("+pix_statFormat[0]+")"),2)
sx = strtrim(string(xvalue+1,format="("+pix_statFormat[1]+")"),2)
sy = strtrim(string(yvalue+1,format="("+pix_statFormat[2]+")"),2)

slope_exist = info.jwst_control.file_slope_exist
if(info.jwst_image_pixel.integrationNO+1 gt info.jwst_data.nints) then slope_exist = 0


if(slope_exist) then begin 
    signal  = info.jwst_image_pixel.slope
    error   = info.jwst_image_pixel.error
    id   = info.jwst_image_pixel.quality_flag

    ssignal = strtrim(string(signal,format="("+pix_statFormat[3]+")"),2)
    serror = strtrim(string(error,format="("+pix_statFormat[4]+")"),2)
    sid = strtrim(string(id,format="("+pix_statFormat[5]+")"),2)

endif else begin
    ssignal = 'NA'
    suncertianty = 'NA'
    sid = 'NA'
endelse

value = (*info.jwst_image_pixel.ppixeldata)[i,*]


value_lc  =0
if(info.jwst_control.file_linearity_exist eq 1) then begin
  value_lc = (*info.jwst_image_pixel.plin_pixeldata)[i,*]
endif

value_mdc  =0
if(info.jwst_control.file_dark_exist eq 1) then begin
  value_mdc = (*info.jwst_image_pixel.pdark_pixeldata)[i,*]
endif

value_reset  =0
if(info.jwst_control.file_reset_exist eq 1) then begin
  value_reset = (*info.jwst_image_pixel.preset_pixeldata)[i,*]
endif

value_rscd  =0
if(info.jwst_control.file_rscd_exist eq 1) then begin
  value_rscd = (*info.jwst_image_pixel.prscd_pixeldata)[i,*]
endif

value_lastframe  =0
if(info.jwst_control.file_lastframe_exist eq 1) then begin
  value_lastframe = (*info.jwst_image_pixel.plastframe_pixeldata)[i]
endif

value_refcorrected = 0
if(info.jwst_control.file_refpix_exist eq 1) then $
  value_refcorrected = (*info.jwst_image_pixel.prefpix_pixeldata)[i,*]



info_string = "Frame "


pix_statLabelID = widget_label(pixelinfo,$
                                             value= pix_statLabel[0]+' = ' + $
                                             si, $ 
                                             /dynamic_resize,/align_left)

pix_statLabelID = widget_label(pixelinfo,$
                                             value= pix_statLabel[1]+' = ' + $
                                             sx, $ 
                                             /dynamic_resize,/align_left)
pix_statLabelID = widget_label(pixelinfo,$
                                             value= pix_statLabel[2]+' = ' + $
                                             sy, $ 
                                             /dynamic_resize,/align_left)


pix_statLabelID = widget_label(pixelinfo,$
                                             value= pix_statLabel[3]+' = ' + $
                                             ssignal, $ 
                                             /dynamic_resize,/align_left)

pix_statLabelID = widget_label(pixelinfo,$
                                             value= pix_statLabel[4]+' = ' + $
                                             serror, $ 
                                             /dynamic_resize,/align_left)

info_base = widget_base(pixelinfo,row=1,/align_left)
pix_statLabelID = widget_label(info_base,$
                                             value= pix_statLabel[5]+' = ' + $
                                             sid, $ 
                                             /dynamic_resize,/align_left)
info_label = widget_button(info_base,value = 'Info',uvalue = 'datainfo')




framevalue = strarr(nend)
refcorrected_value = strarr(nend)
id_value = strarr(nend)
lc_value = strarr(nend)
mdc_value = strarr(nend)
reset_value = strarr(nend)
rscd_value = strarr(nend)
lastframe_value = strarr(nend)

for j = 0,nend-1 do begin
    svalue = strtrim(string(value[j],format="("+pix_statFormat[4]+")"),2)


    if(info.jwst_control.file_refpix_exist eq 0) then  begin
        srefcorrected_value = 'NA'
    endif else begin 
        srefcorrected_value = strtrim(string(value_refcorrected[j],format="("+pix_statFormat[4]+")"),2)
    endelse


    if(info.jwst_control.file_linearity_exist eq 0) then begin
        slc_value = 'NA'
    endif else begin 
        slc_value = strtrim(string(value_lc[j],format="("+pix_statFormat[4]+")"),2)
    endelse


    if(info.jwst_control.file_dark_exist eq 0) then begin
        smdc_value = 'NA'
    endif else begin 

        smdc_value = strtrim(string(value_mdc[j],format="("+pix_statFormat[4]+")"),2)
     endelse

    if(info.jwst_control.file_reset_exist eq 0) then begin
        sreset_value = 'NA'
    endif else begin 
        sreset_value = strtrim(string(value_reset[j],format="("+pix_statFormat[4]+")"),2)
     endelse

    if(info.jwst_control.file_rscd_exist eq 0) then begin
        srscd_value = 'NA'
    endif else begin 
        srscd_value = strtrim(string(value_rscd[j],format="("+pix_statFormat[4]+")"),2)
     endelse

    if(info.jwst_control.file_lastframe_exist eq 0 or j+1 ne nend) then begin
        slastframe_value = 'NA'
    endif else begin 

        slastframe_value = strtrim(string(value_lastframe,format="("+pix_statFormat[4]+")"),2)
    endelse

    frame_no = info_string + strcompress(string(fix(j+1)),/remove_all)+ " = " 

    if(info.jwst_data.nints eq info.jwst_image_pixel.integrationNO) then begin
        svalue = 'NA'
        srefcorrected_value= 'NA'

        slc_value = 'NA'
        smdc_value = 'NA'
        sreset_value = 'NA'
        srscd_value = 'NA'
        slastframe_value = 'NA'
    endif


    if(j+1 lt info.jwst_data.start_fit or j+1 gt info.jwst_data.end_fit) then begin
        srefcorrected_value = 'NA'
        slc_value = 'NA'
        smdc_value = 'NA'
        sreset_value = 'NA'
        srscd_value = 'NA'
        slastframe_value = 'NA'
    endif

    framevalue[j] = frame_no + svalue
        
    refcorrected_no = "Reference Corrected " + strcompress(string(fix(j+1)),/remove_all)+ " = " 
    refcorrected_value[j] = refcorrected_no + srefcorrected_value

    lc_no = "Lin Corr" + strcompress(string(fix(j+1)),/remove_all)+ " = " 
    lc_value[j] = lc_no + slc_value

    mdc_no = "Dark Corr" + strcompress(string(fix(j+1)),/remove_all)+ " = " 
    mdc_value[j] = mdc_no + smdc_value

    reset_no = "Reset Corr" + strcompress(string(fix(j+1)),/remove_all)+ " = " 
    reset_value[j] = reset_no + sreset_value

    rscd_no = "RSCD Corr" + strcompress(string(fix(j+1)),/remove_all)+ " = " 
    rscd_value[j] = rscd_no + srscd_value

    lastframe_no = "Last Frame Corr" + strcompress(string(fix(j+1)),/remove_all)+ " = " 
    lastframe_value[j] = lastframe_no + slastframe_value

endfor
pix2 = widget_base(PixelInfo,row=1,/align_left)
info.jwst_image_pixel.pix_statLabelID[0] = widget_list(pix2,$
                              value=framevalue,/align_left,scr_ysize=200)


if(info.jwst_control.file_reset_exist eq 1) then $
info.jwst_image_pixel.pix_statLabelID[1] = widget_list(pix2,$
                                                  value=reset_value,/align_left,scr_ysize=200)

if(info.jwst_control.file_linearity_exist eq 1) then $
info.jwst_image_pixel.pix_statLabelID[2] = widget_list(pix2,$
                                                  value=lc_value,/align_left,scr_ysize=200)

if(info.jwst_control.file_rscd_exist eq 1) then $
info.jwst_image_pixel.pix_statLabelID[3] = widget_list(pix2,$
                                                  value=rscd_value,/align_left,scr_ysize=200)

if(info.jwst_control.file_dark_exist eq 1) then $
info.jwst_image_pixel.pix_statLabelID[4] = widget_list(pix2,$
                                                  value=mdc_value,/align_left,scr_ysize=200)


if(info.jwst_control.file_lastframe_exist eq 1) then $
info.jwst_image_pixel.pix_statLabelID[5] = widget_list(pix2,$
                                                  value=lastframe_value,/align_left,scr_ysize=200)


if(info.jwst_control.file_refpix_exist ne 0) then $
info.jwst_image_pixel.pix_statLabelID[6] = widget_list(pix2,$
                              value=refcorrected_value,/align_left,scr_ysize=200)



info.jwst_RPixelInfo = pixelinfo

pixel = {info                  : info}	



Widget_Control,info.jwst_rPixelInfo,Set_UValue=pixel
widget_control,info.jwst_rPixelInfo,/realize

XManager,'jwst_mpixel',pixelinfo,/No_Block,event_handler = 'jwst_frame_values_event'

Widget_Control,info.jwst_QuickLook,Set_UValue=info

end
