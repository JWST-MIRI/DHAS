pro jwst_msql_cleanup_widgets,info

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

end
