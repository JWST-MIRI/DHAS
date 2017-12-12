;***********************************************************************
pro cv_roi_geometry,info
;***********************************************************************

x1 = (*info.roi).roixorig 
y1 = (*info.roi).roiyorig
x2 = (*info.roi).roixend 
y2 = (*info.rot).roiyend 


beta1 = (*info.cube.pbeta)[y1]
beta2 = (*info.cube.pbeta)[y2]
alpha1 = (*info.cube.palpha)[x1]
alpha2 = (*info.cube.palpha)[x2]

print,'in cv_roi_geometry',x1,x2,y1,y2
print,alpha1,alpha2,beta1,beta2

scube1 = 'Cube Pixel X range:[' + strcompress(string(x1)) + ',' + strcompress(string(x2))+'],'
scube2 = '  Y range:[' + strcompress(string(y1)) + ',' + strcompress(string(y2)) + '],'
scube3 = '  Alpha range:[' + strcompress(string(alpha1)) + ',' + strcompress(string(alpha2)) + '],'
scube4 = '  Beta range:[' + strcompress(string(beta1)) + ',' + strcompress(string(beta2))+']'

info_line = scube1 + scube2 + scube3 + scube4

print,scube1,scube2,scube3,scube4
info.region.xbox=[x1,x2]
info.region.ybox=[y1,y2]
info.region.alphabox=[alpha1,alpha2]
info.region.betabox=[beta1,beta2]
widget_control,info.region.box_LabelID,set_value = info_line

wave_line = 'Wavelength ' + strcompress(string(info.cube.this_iwavelength),/remove_all)
widget_control,info.region.wave_LabelID,set_value  = wave_line



end



;_______________________________________________________________________
; extract the data from the file
;***********************************************************************
pro extract_region,x1,x2,y1,y2,cube,region,status
;***********************************************************************
status = 0

region = (*info.data.pcubedata)[x1:x2,y1:y2,*]
region.x1 = x1
region.x2 = x2
region.y1 = y1
region.y2 = y2

region.beta1 = (*cube.pbeta)[y1]
region.beta2 = (*cube.pbeta)[y2]
region.alpha1 = (*cube.palpha)[x1]
region.alpha2 = (*cube.palpha)[x2]


if ptr_valid(region.pdata) then ptr_free,info.region.pdata
info.region.pdata = ptr_new(region)


region = 0


end
