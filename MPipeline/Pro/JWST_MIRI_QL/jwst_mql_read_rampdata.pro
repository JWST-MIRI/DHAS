;_______________________________________________________________________
pro jwst_mql_read_rampdata,xvalue,yvalue,pixeldata,info
; x_pos, y_pos starts at 0

if(info.jwst_data.read_all eq 0) then begin
    x = intarr(1) & y = intarr(1)
    pixeldata = fltarr(info.jwst_data.nints,info.jwst_data.ngroups,1)
    x[0] = xvalue & y[0]  = yvalue
    
    jwst_get_pixeldata,info,1,x,y,pixeldata
endif else begin
    pixeldata = (*info.jwst_data.pimagedata)[*,*,xvalue,yvalue]
endelse

end


; read in reduced values for pixel
pro jwst_mql_read_slopedata,x,y,info
slope_exist = info.jwst_data.slope_int_exist
if(slope_exist eq 0) then return


slopedata = fltarr(info.jwst_data.nints,2)
jwst_get_slopepixel,info,x,y,slopedata,slopefinal,status
if(ptr_valid(info.jwst_image.pslope_pixeldata)) then ptr_free, info.jwst_image.pslope_pixeldata

info.jwst_image.pslope_pixeldata = ptr_new(slopedata)

end

;_______________________________________________________________________
pro jwst_msql_read_rampdata,xvalue,yvalue,pixeldata,info
; x_pos, y_pos starts at 0

x = intarr(1) & y = intarr(1)
pixeldata = fltarr(info.jwst_data.nints,info.jwst_data.ngroups,1)
x[0] = xvalue & y[0]  = yvalue
jwst_get_pixeldata,info,1,x,y,pixeldata

end

;_______________________________________________________________________
pro not_converted_mql_read_refcorrected_data,xvalue,yvalue,info
; x_pos, y_pos starts at 0

x = intarr(1) & y = intarr(1)
pixeldata = fltarr(info.jwst_data.nints,info.jwst_data.ngroups,1)
x[0] = xvalue & y[0]  = yvalue
get_refcorrected_pixeldata,info,1,x,y,pixeldata
if(ptr_valid(info.jwst_image.prefcorrected_pixeldata)) then ptr_free, info.jwst_image.prefcorrected_pixeldata

info.jwst_image.prefcorrected_pixeldata = ptr_new(pixeldata)
end



;_______________________________________________________________________
pro not_converted_msql_read_refcorrected_data,xvalue,yvalue,info
; x_pos, y_pos starts at 0

x = intarr(1) & y = intarr(1)
pixeldata = fltarr(info.jwst_data.nints,info.jwst_data.ngroups,1)
x[0] = xvalue & y[0]  = yvalue
get_refcorrected_pixeldata,info,1,x,y,pixeldata
if(ptr_valid(info.jwst_slope.prefcorrected_pixeldata)) then ptr_free, info.jwst_slope.prefcorrected_pixeldata

info.jwst_slope.prefcorrected_pixeldata = ptr_new(pixeldata)
end



;_______________________________________________________________________
pro not_converted_mql_read_id_data,xvalue,yvalue,info
; x_pos, y_pos starts at 0


x = intarr(1) & y = intarr(1)
pixeldata = fltarr(info.jwst_data.nints,info.jwst_data.ngroups,1)
x[0] = xvalue & y[0]  = yvalue
get_id_pixeldata,info,1,x,y,pixeldata

if(ptr_valid(info.jwst_image.pid_pixeldata)) then ptr_free, info.jwst_image.pid_pixeldata

info.jwst_image.pid_pixeldata = ptr_new(pixeldata)
end


;_______________________________________________________________________

pro not_converted_msql_read_id_data,xvalue,yvalue,info
; x_pos, y_pos starts at 0

x = intarr(1) & y = intarr(1)
pixeldata = fltarr(info.jwst_data.nints,info.jwst_data.ngroups,1)
x[0] = xvalue & y[0]  = yvalue
get_id_pixeldata,info,1,x,y,pixeldata
if(ptr_valid(info.jwst_slope.pid_pixeldata)) then ptr_free, info.jwst_slope.pid_pixeldata

info.jwst_slope.pid_pixeldata = ptr_new(pixeldata)
end

;_______________________________________________________________________

pro not_converted_mql_read_lc_data,xvalue,yvalue,info
; x_pos, y_pos starts at 0


x = intarr(1) & y = intarr(1)
pixeldata = fltarr(info.jwst_data.nints,info.jwst_data.ngroups,1)

x[0] = xvalue & y[0]  = yvalue
get_lc_pixeldata,info,1,x,y,pixeldata

if(ptr_valid(info.jwst_image.plc_pixeldata)) then ptr_free, info.jwst_image.plc_pixeldata
info.jwst_image.plc_pixeldata = ptr_new(pixeldata)


end
;_______________________________________________________________________

pro not_converted_msql_read_lc_data,xvalue,yvalue,info
; x_pos, y_pos starts at 0

x = intarr(1) & y = intarr(1)
pixeldata = fltarr(info.jwst_data.nints,info.jwst_data.ngroups,1)

x[0] = xvalue & y[0]  = yvalue
get_lc_pixeldata,info,1,x,y,pixeldata

if(ptr_valid(info.jwst_slope.plc_pixeldata)) then ptr_free, info.jwst_slope.plc_pixeldata
info.jwst_slope.plc_pixeldata = ptr_new(pixeldata)

end


;_______________________________________________________________________
pro not_converted_mql_read_mdc_data,xvalue,yvalue,info
; x_pos, y_pos starts at 0


x = intarr(1) & y = intarr(1)
pixeldata = fltarr(info.jwst_data.nints,info.jwst_data.ngroups,1)
x[0] = xvalue & y[0]  = yvalue
get_mdc_pixeldata,info,1,x,y,pixeldata


if(ptr_valid(info.jwst_image.pmdc_pixeldata)) then ptr_free, info.jwst_image.pmdc_pixeldata
info.jwst_image.pmdc_pixeldata = ptr_new(pixeldata)


end



;_______________________________________________________________________
pro not_converted_msql_read_mdc_data,xvalue,yvalue,info
; x_pos, y_pos starts at 0

x = intarr(1) & y = intarr(1)
pixeldata = fltarr(info.jwst_data.nints,info.jwst_data.ngroups,1)
x[0] = xvalue & y[0]  = yvalue
get_mdc_pixeldata,info,1,x,y,pixeldata

if(ptr_valid(info.jwst_slope.pmdc_pixeldata)) then ptr_free, info.jwst_slope.pmdc_pixeldata
info.jwst_slope.pmdc_pixeldata = ptr_new(pixeldata)
end
;_______________________________________________________________________
pro not_converted_mql_read_reset_data,xvalue,yvalue,info
; x_pos, y_pos starts at 0
x = intarr(1) & y = intarr(1)
pixeldata = fltarr(info.jwst_data.nints,info.jwst_data.ngroups,1)
x[0] = xvalue & y[0]  = yvalue

get_reset_pixeldata,info,1,x,y,pixeldata

if(ptr_valid(info.jwst_image.preset_pixeldata)) then ptr_free, info.jwst_image.preset_pixeldata
info.jwst_image.preset_pixeldata = ptr_new(pixeldata)

end

;_______________________________________________________________________
pro not_converted_msql_read_reset_data,xvalue,yvalue,info
; x_pos, y_pos starts at 0

x = intarr(1) & y = intarr(1)
pixeldata = fltarr(info.jwst_data.nints,info.jwst_data.ngroups,1)
x[0] = xvalue & y[0]  = yvalue
get_reset_pixeldata,info,1,x,y,pixeldata


if(ptr_valid(info.jwst_slope.preset_pixeldata)) then ptr_free, info.jwst_slope.preset_pixeldata
info.jwst_slope.preset_pixeldata = ptr_new(pixeldata)

end
;_______________________________________________________________________%
pro not_converted_mql_read_rscd_data,xvalue,yvalue,info
; x_pos, y_pos starts at 0
x = intarr(1) & y = intarr(1)
pixeldata = fltarr(info.jwst_data.nints,info.jwst_data.ngroups,1)
x[0] = xvalue & y[0]  = yvalue

get_rscd_pixeldata,info,1,x,y,pixeldata

if(ptr_valid(info.jwst_image.prscd_pixeldata)) then ptr_free, info.jwst_image.prscd_pixeldata
info.jwst_image.prscd_pixeldata = ptr_new(pixeldata)

end

;_______________________________________________________________________
pro not_converted_msql_read_rscd_data,xvalue,yvalue,info
; x_pos, y_pos starts at 0

x = intarr(1) & y = intarr(1)
pixeldata = fltarr(info.jwst_data.nints,info.jwst_data.ngroups,1)
x[0] = xvalue & y[0]  = yvalue
get_rscd_pixeldata,info,1,x,y,pixeldata


if(ptr_valid(info.jwst_slope.prscd_pixeldata)) then ptr_free, info.jwst_slope.prscd_pixeldata
info.jwst_slope.prscd_pixeldata = ptr_new(pixeldata)

end

;_______________________________________________________________________
pro not_converted_mql_read_lastframe_data,xvalue,yvalue,info
; x_pos, y_pos starts at 0
x = intarr(1) & y = intarr(1)
pixeldata = fltarr(info.jwst_data.nints,1)
x[0] = xvalue & y[0]  = yvalue
get_lastframe_pixeldata,info,1,x,y,pixeldata


if(ptr_valid(info.jwst_image.plastframe_pixeldata)) then ptr_free, info.jwst_image.plastframe_pixeldata
info.jwst_image.plastframe_pixeldata = ptr_new(pixeldata)
end

;_______________________________________________________________________
pro not_converted_msql_read_lastframe_data,xvalue,yvalue,info
; x_pos, y_pos starts at 0

x = intarr(1) & y = intarr(1)
pixeldata = fltarr(info.jwst_data.nints,info.jwst_data.ngroups,1)
x[0] = xvalue & y[0]  = yvalue
get_lastframe_pixeldata,info,1,x,y,pixeldata

if(ptr_valid(info.jwst_slope.plastframe_pixeldata)) then ptr_free, info.jwst_slope.plastframe_pixeldata
info.jwst_slope.plastframe_pixeldata = ptr_new(pixeldata)

end

;_______________________________________________________________________


;_______________________________________________________________________
pro not_converted_msql_read_slopedata,x,y,info


slopedata = fltarr(info.jwst_data.nints,2)

get_slopepixel,info,x,y,slopedata,slopefinal,status

if(ptr_valid(info.jwst_slope.pslope_pixeldata)) then ptr_free, info.jwst_slope.pslope_pixeldata
info.jwst_slope.pslope_pixeldata = ptr_new(slopedata)
info.jwst_slope.slope_final= slopefinal

end
