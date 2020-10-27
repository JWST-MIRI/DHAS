;***********************************************************************
pro jwst_cv_box_stat,x1,x2,y1,y2,iwavelength,jwst_cube,range_min,range_max,box_stat
;***********************************************************************
box_stat = strarr(6)
dec1 = (*jwst_cube.pdec)[y1]
dec2 = (*jwst_cube.pdec)[y2]
ra1 = (*jwst_cube.pra)[x1]
ra2 = (*jwst_cube.pra)[x2]

box_stat[0] = 'X:[' + strcompress(string(x1+1)) + ',' + strcompress(string(x2+1))+'],'
box_stat[1]= '  Y:[' + strcompress(string(y1+1)) + ',' + strcompress(string(y2+1)) + ']'
box_stat[2] = '  Ra:[' + strcompress(string(ra1)) + ',' + strcompress(string(ra2)) + '],'
box_stat[3] = '  Dec:[' + strcompress(string(dec1)) + ',' + strcompress(string(dec2))+']'

cube_image = (*jwst_cube.pcubedata)[x1:x2,y1:y2,iwavelength]
w_map = (*jwst_cube.pw_map)[x1:x2,y1:y2,iwavelength]

range_min = 0
range_max = 1
num  = n_elements(cube_image)
if(num gt 1) then begin 
    jwst_cv_get_image_stat,cube_image,w_map,$
                           cube_mean,cube_std,cube_sum,$
                           image_min,image_max,range_min,range_max,$
                           cube_median,std_mean,skew,n_pixels,numbad

    box_stat[4] = 'Mean: '+ strcompress(string(cube_mean,format="(f12.4)")) + ',  Std:' + $
	strcompress(string(cube_std,format="(f12.4)")) + $
	          ',  Sum: ' + strcompress(string(cube_sum,format="(e12.3)"))
	
    box_stat[5] = ',  Min:  '+ strcompress(string(image_min,format="(f12.4)")) + $
                  ',  Max' + strcompress(string(image_max,format="(e12.4)"  ))
endif else begin 
    
    box_stat[4] = 'Mean: NA,  Std: NA'
    box_stat[5] = 'Min: NA,  Max: NA'
endelse


cube_image = 0
w_map = 0 
end


;***********************************************************************
pro jwst_cv_box_stat_image,x1,x2,y1,y2,image2d,jwst_cube,box_stat_image
;***********************************************************************
box_stat_image = strarr(6)
dec1 = (*jwst_cube.pdec)[y1]
dec2 = (*jwst_cube.pdec)[y2]
ra1 = (*jwst_cube.pra)[x1]
ra2 = (*jwst_cube.pra)[x2]

box_stat_image[0] = 'X:[' + strcompress(string(x1+1)) + ',' + strcompress(string(x2+1))+'],'
box_stat_image[1]= '  Y:[' + strcompress(string(y1+1)) + ',' + strcompress(string(y2+1)) + ']'
box_stat_image[2] = '  Ra:[' + strcompress(string(ra1)) + ',' + strcompress(string(ra2)) + '],'
box_stat_image[3] = '  Dec:[' + strcompress(string(dec1)) + ',' + strcompress(string(dec2))+']'

image = (*image2d.psubdata)
isum = (*image2d.pisubdata)

num  = n_elements(image)
if(num gt 1) then begin 
    jwst_cv_get_image_stat,image,isum,$
                           cube_mean,cube_std,cube_sum,$
                           image_min,image_max,$
                           range_min,range_max,$
                           cube_median,std_mean,skew,n_pixels,numbad
    
    box_stat_image[4] = 'Mean: '+ strcompress(string(cube_mean,format="(f12.4)")) + ',  Std:' + $
	strcompress(string(cube_std,format="(f12.4)")) + $
	          ',  Sum: ' + strcompress(string(cube_sum,format="(f12.4)"))
	
    box_stat_image[5] = ',  Min:  '+ strcompress(string(image_min,format="(f12.4)")) + $
                  ',  Max ' + strcompress(string(image_max,format="(f12.4)"  ))
endif else begin 
    
    box_stat_image[4] = 'Mean: NA,  Std: NA'
    box_stat_image[5] = 'Min: NA,  Max: NA'
endelse

image = 0
end




