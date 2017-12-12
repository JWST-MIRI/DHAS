
pro cv_cleanup,topbaseID

; get all defined structures so they are deleted when the program
; terminates

widget_control,topbaseID,get_uvalue=cinfo,/no_copy

; close the open files file


;if(XRegistered ('ql')) then begin
;  num = n_elements(info.image.pixmapID)
;endif



if (n_elements(info) EQ 0) then heap_gc

end

