
pro ql_quit,event
widget_control,event.top, Get_UValue = info


if(XRegistered ('miql')) then begin
    widget_control,info.InspectImage,/destroy
endif

if(XRegistered ('mirql')) then begin
    widget_control,info.InspectRefImage,/destroy
endif

if(XRegistered ('mtql')) then begin
    print,'Exiting MIRI QuickLook - Telemetry'
    widget_control,info.telemetryLook,/destroy
endif

if(XRegistered ('msql')) then begin
    print,'Exiting MIRI QuickLook - Slope Images'
    widget_control,info.SlopeQuickLook,/destroy
endif

if(XRegistered ('mql')) then begin
    print,'Exiting MIRI QuickLook - Raw Images'
    widget_control,info.RawQuickLook,/destroy
endif


if(XRegistered ('ql')) then begin
    print,'Exiting MIRI QuickLook'
    widget_control,info.QuickLook,/destroy
endif



if (n_elements(info) EQ 0) then heap_gc


end


