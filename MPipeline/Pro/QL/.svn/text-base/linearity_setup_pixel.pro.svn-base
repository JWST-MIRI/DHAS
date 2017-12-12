pro linearity_setup_pixel,info

info.lincor.xvalue = fix(  (info.image.x_pos) *info.image.binfactor)
info.lincor.yvalue = fix(  (info.image.y_pos) *info.image.binfactor)

            
;_______________________________________________________________________        
if(ptr_valid(info.image.pslope_pixeldata) eq 0) then begin
    mql_read_slopedata,info.lincor.xvalue,info.lincor.yvalue,info
endif

; already read in slope data
if(ptr_valid(info.lincor.pslopedata)) then ptr_free, info.lincor.pslopedata
info.lincor.pslopedata = ptr_new(*info.image.pslope_pixeldata)
        

;_______________________________________________________________________
 ;
if(ptr_valid(info.image.plc_pixeldata) eq 0) then begin
    mql_read_lc_data,info.lincor.xvalue,info.lincor.yvalue,info
endif

if(ptr_valid(info.lincor.plcdata)) then ptr_free, info.lincor.plcdata
info.lincor.plcdata = ptr_new(*info.image.plc_pixeldata)


;_______________________________________________________________________
 ;

if(info.control.file_ids_exist eq 1 ) then begin 
    if(ptr_valid(info.image.pid_pixeldata) eq 0) then begin
        mql_read_id_data,info.lincor.xvalue,info.lincor.yvalue,info
    endif

    if(ptr_valid(info.lincor.piddata)) then ptr_free, info.lincor.piddata
    info.lincor.piddata = ptr_new(*info.image.pid_pixeldata)
        
endif    


info.lincor.integration = info.image.integrationNO
info.lincor.frame_time = info.image.frame_time

Widget_Control,info.QuickLook,Set_UValue=info
end
