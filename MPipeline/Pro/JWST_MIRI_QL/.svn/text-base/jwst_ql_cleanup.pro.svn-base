
pro jwst_ql_cleanup,topbaseID

; get all defined structures so they are deleted when the program
; terminates

widget_control,topbaseID,get_uvalue=info,/no_copy

; close the open files file



; delete the pixmaps


if(XRegistered ('miql')) then begin
    wdelete,info.inspect.pixmapID
    widget_control,info.InspectImage,/destroy
endif

if(XRegistered ('msql')) then begin
    num = n_elements(info.slope.pixmapID)	
    for i = 0,num-1 do begin
        wdelete,info.slope.pixmapID[i]
    endfor
    widget_control,info.SlopeQuickLook,/destroy
endif


if(XRegistered ('mql')) then begin
    num = n_elements(info.image.pixmapID)	
    for i = 0,num-1 do begin
        wdelete,info.image.pixmapID[i]
    endfor
    widget_control,info.RawQuickLook,/destroy
endif




if(XRegistered ('ql')) then begin
  num = n_elements(info.image.pixmapID)
endif



if (n_elements(info) EQ 0) then heap_gc

end

