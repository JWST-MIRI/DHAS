

;***********************************************************************
pro cv_box_stat,x1,x2,y1,y2,iwavelength,cube,box_stat
;***********************************************************************
box_stat = strarr(6)
beta1 = (*cube.pbeta)[y1]
beta2 = (*cube.pbeta)[y2]
alpha1 = (*cube.palpha)[x1]
alpha2 = (*cube.palpha)[x2]


box_stat[0] = 'X:[' + strcompress(string(x1+1)) + ',' + strcompress(string(x2+1))+'],'
box_stat[1]= '  Y:[' + strcompress(string(y1+1)) + ',' + strcompress(string(y2+1)) + ']'
box_stat[2] = '  Alpha:[' + strcompress(string(alpha1)) + ',' + strcompress(string(alpha2)) + '],'
box_stat[3] = '  Beta:[' + strcompress(string(beta1)) + ',' + strcompress(string(beta2))+']'


cube_image = (*cube.pcubedata)[x1:x2,y1:y2,iwavelength]


num  = n_elements(cube_image)
if(num gt 1) then begin 
    get_image_stat,cube_image,cube_mean,cube_std,image_min,$
                   image_max,range_min,range_max,$
                   cube_median,std_mean,skew,n_pixels,numbad

    cube_sum = total(cube_image,/nan)
    box_stat[4] = 'Mean: '+ strcompress(string(cube_mean,format="(f12.5)")) + ',  Std:' + $
	strcompress(string(cube_std,format="(f15.8)")) + $
	          ',  Sum: ' + strcompress(string(cube_sum,format="(f12.5)"))
	
    box_stat[5] = ',  Min:  '+ strcompress(string(image_min,format="(f12.5)")) + $
                  ',  Max' + strcompress(string(image_max,format="(f12.5)"  ))
endif else begin 
    
    box_stat[4] = 'Mean: NA,  Std: NA'
    box_stat[5] = 'Min: NA,  Max: NA'
endelse

cube_image = 0
end







;***********************************************************************
pro cv_box_stat_image,x1,x2,y1,y2,image2d,cube,box_stat_image
;***********************************************************************
box_stat_image = strarr(6)
beta1 = (*cube.pbeta)[y1]
beta2 = (*cube.pbeta)[y2]
alpha1 = (*cube.palpha)[x1]
alpha2 = (*cube.palpha)[x2]


box_stat_image[0] = 'X:[' + strcompress(string(x1+1)) + ',' + strcompress(string(x2+1))+'],'
box_stat_image[1]= '  Y:[' + strcompress(string(y1+1)) + ',' + strcompress(string(y2+1)) + ']'
box_stat_image[2] = '  Alpha:[' + strcompress(string(alpha1)) + ',' + strcompress(string(alpha2)) + '],'
box_stat_image[3] = '  Beta:[' + strcompress(string(beta1)) + ',' + strcompress(string(beta2))+']'


image = (*image2d.psubdata)


num  = n_elements(image)
if(num gt 1) then begin 
    get_image_stat,image,cube_mean,cube_std,image_min,$
                   image_max,range_min,range_max,$
                   cube_median,std_mean,skew,n_pixels,numbad

    cube_sum = total(image,/nan)
    box_stat_image[4] = 'Mean: '+ strcompress(string(cube_mean,format="(f12.5)")) + ',  Std:' + $
	strcompress(string(cube_std,format="(f15.8)")) + $
	          ',  Sum: ' + strcompress(string(cube_sum,format="(f12.5)"))
	
    box_stat_image[5] = ',  Min:  '+ strcompress(string(image_min,format="(f12.5)")) + $
                  ',  Max' + strcompress(string(image_max,format="(f12.5)"  ))
endif else begin 
    
    box_stat_image[4] = 'Mean: NA,  Std: NA'
    box_stat_image[5] = 'Min: NA,  Max: NA'
endelse

image = 0
end




