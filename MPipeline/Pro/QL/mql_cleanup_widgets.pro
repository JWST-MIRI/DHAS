pro mql_cleanup_widgets,type,info

; clean up widgets whose parent is info.RawQuickLook

if(type eq 0) then begin ; integration clean up
    if(XRegistered ('mpixel')) then begin ; frame values  widget
        widget_control,info.RPixelInfo,/destroy
    endif

    if(XRegistered ('mipixel')) then begin ; frame values  from Inspect widget
        widget_control,info.RIPixelInfo,/destroy
    endif

    if(XRegistered ('mirgetframe')) then begin ; frame values  from Inspect widget
        widget_control,info.RFPixelInfo,/destroy
    endif
endif


if(XRegistered ('mstat')) then begin           ; stat info widget
    widget_control,info.StatInfo,/destroy
endif


if( XRegistered ('mqlhr')) then begin          ; histogram plot Raw
    widget_control,info.HistoRawQuickLook,/destroy
endif

if( XRegistered ('mqlhz')) then begin          ; histogram plot Zoom
    widget_control,info.HistoZoomQuickLook,/destroy
endif


if(XRegistered ('mqlhs')) then begin           ; histogram plot slope
    widget_control,info.HistoSlopeQuickLook,/destroy
endif

if(XRegistered ('mqlcsr')) then begin          ; column slice plot Raw
    widget_control,info.CSRawQuickLook,/destroy
endif

if( XRegistered ('mqlcsz')) then begin         ; column slice plot zoom
    widget_control,info.CSZoomQuickLook,/destroy
endif

if(XRegistered ('mqlcss')) then begin          ; column slice plot slope
    widget_control,info.CSSlopeQuickLook,/destroy
endif


if( XRegistered ('mqlrsr')) then begin        ; row slice plot Raw
    widget_control,info.RSRawQuickLook,/destroy
endif

if(XRegistered ('mqlrsz')) then begin         ; row slice plot zoom
    widget_control,info.RSZoomQuickLook,/destroy
endif

if(XRegistered ('mqlrss')) then begin         ; row slice plot slope
    widget_control,info.RSSlopeQuickLook,/destroy
endif


if(XRegistered ('mCpixel')) then begin         ; row slice plot slope
    widget_control,info.CPixelInfo,/destroy
endif

;_______________________________________________________________________
; Channel specific widgets
; histogram channel plots
if( XRegistered ('mqlhchr')) then begin ; histo channel
   widget_control,info.HistoChannelRawQuickLook,/destroy
endif

; row slice channel plots
if( XRegistered ('mqlrchr')) then begin ; histo channelx
   widget_control,info.RSliceChannelRawQuickLook,/destroy
endif

; column slice channel plots
if( XRegistered ('mqlcchr')) then begin ; histo channel
   widget_control,info.CSliceChannelRawQuickLook,/destroy
endif

; stat plot
if(XRegistered ('mchstat')) then begin
    widget_control,info.StatChannelInfo,/destroy
endif
if(XRegistered ('mschstat')) then begin
    widget_control,info.StatSlopeChannelInfo,/destroy
endif
end
