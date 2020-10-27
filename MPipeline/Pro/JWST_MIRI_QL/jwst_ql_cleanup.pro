
pro jwst_ql_cleanup,topbaseID

; get all defined structures so they are deleted when the program
; terminates

widget_control,topbaseID,get_uvalue=info,/no_copy

; close the open files file

; delete the pixmaps


if(XRegistered ('jwst_miql')) then begin
    wdelete,info.jwst_inspect.pixmapID
    widget_control,info.jwst_InspectImage,/destroy
endif

if(XRegistered ('jwst_msql')) then begin
    num = n_elements(info.slope.pixmapID)	
    for i = 0,num-1 do begin
        wdelete,info.jwst_slope.pixmapID[i]
    endfor
    widget_control,info.jwst_SlopeQuickLook,/destroy
endif


if(XRegistered ('jwst_mql')) then begin
    num = n_elements(info.jwst_image.pixmapID)	
    for i = 0,num-1 do begin
        wdelete,info.jwst_image.pixmapID[i]
    endfor
    widget_control,info.jwst_RawQuickLook,/destroy
endif


if(XRegistered ('miri_ql')) then begin
  num = n_elements(info.jwst_image.pixmapID)
endif



if (n_elements(info) EQ 0) then heap_gc

end

