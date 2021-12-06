pro jwst_RateAmplifier_moveframe,jintegration,info
;____________________
; kill single widget plots


widget_control,info.jwst_RateAmp.integration_label,set_value= fix(jintegration+1)
if( XRegistered ('mqlhschr')) then begin ; histo channel
    widget_control,info.Histojwst_RateAmpQuickLook,/destroy
endif


; statistics on channels
if(XRegistered ('mschstat')) then begin
    widget_control,info.StatSlopeChannelInfo,/destroy
endif
if(XRegistered ('mSCpixel')) then begin
    widget_control,info.SCPixelInfo,/destroy
endif
;____________________

; update Amplifer plots

if(info.jwst_data.nslopes lt jintegration+1) then begin
     ok = dialog_message(" Partial Integration, no slope for this integration",/Information)
    widget_control,info.jwst_RateAmpQuickLook,/destroy
endif else begin

    setup_jwst_RateAmp,info,jintegration,status,error_message
    info.ChannelS[*].jintegration = jintegration
    mql_grab_jwst_RateAmp_images,info
    for i = 0,4 do begin
        mql_update_jwst_RateAmp,i,info
    endfor
endelse
;_______________________________________________________________________

Widget_Control,info.QuickLook,Set_UValue=info


end


