pro msql_cleanup_widgets,info

; clean up widgets whose parent is info.SlopeQuickLook



if(XRegistered ('mstat_slope')) then begin           ; stat info widget
    widget_control,info.Slope_StatInfo,/destroy
endif

if(XRegistered ('msgetframe')) then begin          ; frame values  widget
    widget_control,info.SPixelInfo,/destroy
endif

if(XRegistered ('misgetframe')) then begin          ; frame values  inspect widget
    widget_control,info.SIPixelInfo,/destroy
endif



if( XRegistered ('msqlh1')) then begin          ; histogram plot slope
    widget_control,info.Histo1_SlopeQuickLook,/destroy
endif

if( XRegistered ('msqlh2')) then begin          ; histogram plot Zoom
    widget_control,info.Histo2_SlopeQuickLook,/destroy
endif


if(XRegistered ('msqlh3')) then begin           ; histogram plot slope uncertainty
    widget_control,info.Histo3_SlopeQuickLook,/destroy
endif

if(XRegistered ('msqlcs1')) then begin          ; column slice plot slope
    widget_control,info.CS1_SlopeQuickLook,/destroy
endif

if( XRegistered ('msqlcs2')) then begin         ; column slice plot zoom
    widget_control,info.CS2_SlopeQuickLook,/destroy
endif

if(XRegistered ('msqlcs3')) then begin          ; column slice plot slope
    widget_control,info.CS3_SlopeQuickLook,/destroy
endif


if( XRegistered ('msqlrs1')) then begin        ; row slice plot slope
    widget_control,info.RS1_SlopeQuickLook,/destroy
endif

if(XRegistered ('msqlrs2')) then begin         ; row slice plot zoom
    widget_control,info.RS2_SlopeQuickLook,/destroy
endif

if(XRegistered ('msqlrs3')) then begin         ; row slice plot slope uncertainty
    widget_control,info.RS3_slopeQuickLook,/destroy
endif

;_______________________________________________________________________

end
