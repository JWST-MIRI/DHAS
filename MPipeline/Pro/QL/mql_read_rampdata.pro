;_______________________________________________________________________
pro mql_read_rampdata,xvalue,yvalue,pixeldata,info
; x_pos, y_pos starts at 0

if(info.data.read_all eq 0) then begin
    x = intarr(1) & y = intarr(1)
    pixeldata = fltarr(info.data.nints,info.data.nramps,1)
    x[0] = xvalue & y[0]  = yvalue
    
    get_pixeldata,info,1,x,y,pixeldata
endif else begin
    pixeldata = (*info.data.pimagedata)[*,*,xvalue,yvalue]
endelse
end



;_______________________________________________________________________
pro msql_read_rampdata,xvalue,yvalue,pixeldata,info
; x_pos, y_pos starts at 0

x = intarr(1) & y = intarr(1)
pixeldata = fltarr(info.data.nints,info.data.nramps,1)
x[0] = xvalue & y[0]  = yvalue
get_pixeldata,info,1,x,y,pixeldata
end

;_______________________________________________________________________
pro mql_read_refcorrected_data,xvalue,yvalue,info
; x_pos, y_pos starts at 0

x = intarr(1) & y = intarr(1)
pixeldata = fltarr(info.data.nints,info.data.nramps,1)
x[0] = xvalue & y[0]  = yvalue
get_refcorrected_pixeldata,info,1,x,y,pixeldata
if(ptr_valid(info.image.prefcorrected_pixeldata)) then ptr_free, info.image.prefcorrected_pixeldata
info.image.prefcorrected_pixeldata = ptr_new(pixeldata)
end

;_______________________________________________________________________
pro msql_read_refcorrected_data,xvalue,yvalue,info
; x_pos, y_pos starts at 0

x = intarr(1) & y = intarr(1)
pixeldata = fltarr(info.data.nints,info.data.nramps,1)
x[0] = xvalue & y[0]  = yvalue
get_refcorrected_pixeldata,info,1,x,y,pixeldata
if(ptr_valid(info.slope.prefcorrected_pixeldata)) then ptr_free, info.slope.prefcorrected_pixeldata

info.slope.prefcorrected_pixeldata = ptr_new(pixeldata)
end

;_______________________________________________________________________
pro mql_read_id_data,xvalue,yvalue,info
; x_pos, y_pos starts at 0

x = intarr(1) & y = intarr(1)
pixeldata = fltarr(info.data.nints,info.data.nramps,1)
x[0] = xvalue & y[0]  = yvalue
get_id_pixeldata,info,1,x,y,pixeldata
if(ptr_valid(info.image.pid_pixeldata)) then ptr_free, info.image.pid_pixeldata
info.image.pid_pixeldata = ptr_new(pixeldata)
end

;_______________________________________________________________________
pro msql_read_id_data,xvalue,yvalue,info
; x_pos, y_pos starts at 0

x = intarr(1) & y = intarr(1)
pixeldata = fltarr(info.data.nints,info.data.nramps,1)
x[0] = xvalue & y[0]  = yvalue
get_id_pixeldata,info,1,x,y,pixeldata
if(ptr_valid(info.slope.pid_pixeldata)) then ptr_free, info.slope.pid_pixeldata

info.slope.pid_pixeldata = ptr_new(pixeldata)
end

;_______________________________________________________________________

pro mql_read_lc_data,xvalue,yvalue,info
; x_pos, y_pos starts at 0
x = intarr(1) & y = intarr(1)
pixeldata = fltarr(info.data.nints,info.data.nramps,1)

x[0] = xvalue & y[0]  = yvalue
get_lc_pixeldata,info,1,x,y,pixeldata

if(ptr_valid(info.image.plc_pixeldata)) then ptr_free, info.image.plc_pixeldata
info.image.plc_pixeldata = ptr_new(pixeldata)


end
;_______________________________________________________________________

pro msql_read_lc_data,xvalue,yvalue,info
; x_pos, y_pos starts at 0

x = intarr(1) & y = intarr(1)
pixeldata = fltarr(info.data.nints,info.data.nramps,1)

x[0] = xvalue & y[0]  = yvalue
get_lc_pixeldata,info,1,x,y,pixeldata

if(ptr_valid(info.slope.plc_pixeldata)) then ptr_free, info.slope.plc_pixeldata
info.slope.plc_pixeldata = ptr_new(pixeldata)

end


;_______________________________________________________________________
pro mql_read_mdc_data,xvalue,yvalue,info
; x_pos, y_pos starts at 0


x = intarr(1) & y = intarr(1)
pixeldata = fltarr(info.data.nints,info.data.nramps,1)
x[0] = xvalue & y[0]  = yvalue
get_mdc_pixeldata,info,1,x,y,pixeldata


if(ptr_valid(info.image.pmdc_pixeldata)) then ptr_free, info.image.pmdc_pixeldata
info.image.pmdc_pixeldata = ptr_new(pixeldata)


end



;_______________________________________________________________________
pro msql_read_mdc_data,xvalue,yvalue,info
; x_pos, y_pos starts at 0

x = intarr(1) & y = intarr(1)
pixeldata = fltarr(info.data.nints,info.data.nramps,1)
x[0] = xvalue & y[0]  = yvalue
get_mdc_pixeldata,info,1,x,y,pixeldata

if(ptr_valid(info.slope.pmdc_pixeldata)) then ptr_free, info.slope.pmdc_pixeldata
info.slope.pmdc_pixeldata = ptr_new(pixeldata)
end
;_______________________________________________________________________
pro mql_read_reset_data,xvalue,yvalue,info
; x_pos, y_pos starts at 0
x = intarr(1) & y = intarr(1)
pixeldata = fltarr(info.data.nints,info.data.nramps,1)
x[0] = xvalue & y[0]  = yvalue

get_reset_pixeldata,info,1,x,y,pixeldata
;print,'pixeldata from mql_read_rampdata',pixeldata
if(ptr_valid(info.image.preset_pixeldata)) then ptr_free, info.image.preset_pixeldata
info.image.preset_pixeldata = ptr_new(pixeldata)

end

;_______________________________________________________________________
pro msql_read_reset_data,xvalue,yvalue,info
; x_pos, y_pos starts at 0

x = intarr(1) & y = intarr(1)
pixeldata = fltarr(info.data.nints,info.data.nramps,1)
x[0] = xvalue & y[0]  = yvalue
get_reset_pixeldata,info,1,x,y,pixeldata


if(ptr_valid(info.slope.preset_pixeldata)) then ptr_free, info.slope.preset_pixeldata
info.slope.preset_pixeldata = ptr_new(pixeldata)

end
;_______________________________________________________________________%
pro mql_read_rscd_data,xvalue,yvalue,info
; x_pos, y_pos starts at 0
x = intarr(1) & y = intarr(1)
pixeldata = fltarr(info.data.nints,info.data.nramps,1)
x[0] = xvalue & y[0]  = yvalue

get_rscd_pixeldata,info,1,x,y,pixeldata

if(ptr_valid(info.image.prscd_pixeldata)) then ptr_free, info.image.prscd_pixeldata
info.image.prscd_pixeldata = ptr_new(pixeldata)

end

;_______________________________________________________________________
pro msql_read_rscd_data,xvalue,yvalue,info
; x_pos, y_pos starts at 0

x = intarr(1) & y = intarr(1)
pixeldata = fltarr(info.data.nints,info.data.nramps,1)
x[0] = xvalue & y[0]  = yvalue
get_rscd_pixeldata,info,1,x,y,pixeldata


if(ptr_valid(info.slope.prscd_pixeldata)) then ptr_free, info.slope.prscd_pixeldata
info.slope.prscd_pixeldata = ptr_new(pixeldata)

end

;_______________________________________________________________________
pro mql_read_lastframe_data,xvalue,yvalue,info
; x_pos, y_pos starts at 0
x = intarr(1) & y = intarr(1)
pixeldata = fltarr(info.data.nints,1)
x[0] = xvalue & y[0]  = yvalue
get_lastframe_pixeldata,info,1,x,y,pixeldata


if(ptr_valid(info.image.plastframe_pixeldata)) then ptr_free, info.image.plastframe_pixeldata
info.image.plastframe_pixeldata = ptr_new(pixeldata)
end

;_______________________________________________________________________
pro msql_read_lastframe_data,xvalue,yvalue,info
; x_pos, y_pos starts at 0

x = intarr(1) & y = intarr(1)
pixeldata = fltarr(info.data.nints,info.data.nramps,1)
x[0] = xvalue & y[0]  = yvalue
get_lastframe_pixeldata,info,1,x,y,pixeldata

if(ptr_valid(info.slope.plastframe_pixeldata)) then ptr_free, info.slope.plastframe_pixeldata
info.slope.plastframe_pixeldata = ptr_new(pixeldata)

end

;_______________________________________________________________________
; read in reduced values for pixel
pro mql_read_slopedata,x,y,info
slope_exist = info.data.slope_exist
if(slope_exist eq 0) then return


slopedata = fltarr(info.data.nints,2)
get_slopepixel,info,x,y,slopedata,slopefinal,status
if(ptr_valid(info.image.pslope_pixeldata)) then ptr_free, info.image.pslope_pixeldata

info.image.pslope_pixeldata = ptr_new(slopedata)

end


;_______________________________________________________________________
pro msql_read_slopedata,x,y,info


slopedata = fltarr(info.data.nints,2)

get_slopepixel,info,x,y,slopedata,slopefinal,status

if(ptr_valid(info.slope.pslope_pixeldata)) then ptr_free, info.slope.pslope_pixeldata
info.slope.pslope_pixeldata = ptr_new(slopedata)
info.slope.slope_final= slopefinal

end
