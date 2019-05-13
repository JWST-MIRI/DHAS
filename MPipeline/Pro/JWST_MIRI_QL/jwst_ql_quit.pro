
pro jwst_ql_quit,event
widget_control,event.top, Get_UValue = info

print,'in jwst_ql_quit'
if(XRegistered ('jwst_miql')) then begin
    widget_control,info.jwst_InspectImage,/destroy
endif

if(XRegistered ('jwst_misql')) then begin
    widget_control,info.jwst_InspectSlope,/destroy
endif


if(XRegistered ('jwst_msql')) then begin
    print,'Exiting MIRI QuickLook - Slope Images'
    widget_control,info.jwst_SlopeQuickLook,/destroy
endif

if(XRegistered ('jwst_mql')) then begin
    print,'Exiting JWST MIRI QuickLook - Raw Images'
    widget_control,info.jwst_RawQuickLook,/destroy
endif


if(XRegistered ('miri_ql')) then begin
    print,'Exiting MIRI QuickLook'
    widget_control,info.jwst_QuickLook,/destroy
endif



if (n_elements(info) EQ 0) then heap_gc


end


