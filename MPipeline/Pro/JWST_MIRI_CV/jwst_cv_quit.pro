
pro jwst_cv_quit,event
widget_control,event.top, Get_UValue = cinfo

if(XRegistered ('jwst_cv')) then begin
    print,'Exiting JWST MIRI CubeView'
    widget_control,cinfo.CubeView,/destroy
endif
if (n_elements(info) EQ 0) then heap_gc


end


