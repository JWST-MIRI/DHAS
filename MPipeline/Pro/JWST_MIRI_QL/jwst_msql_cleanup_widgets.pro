pro jwst_msql_cleanup_widgets,info

; clean up widgets whose parent is info.SlopeQuickLook


if(XRegistered ('mstat_slope')) then begin           ; stat info widget
    widget_control,info.Slope_StatInfo,/destroy
endif


end
