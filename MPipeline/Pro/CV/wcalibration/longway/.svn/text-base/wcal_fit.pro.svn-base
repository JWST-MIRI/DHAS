function wcal_fit,C

COMMON FUNC_DATA, x,y,lamba

n = n_elements(x)
sumsq = 0.0


yresid = lamba - c[0] - c[1]*y - c[2]*x- c[3]*y^2 - c[4]*x*y -c[5]*y^2  - $
         c[6]*y^3 - c[7]*y^2*x -c[8]*y*x^2 - c[9]*x^3


sumsq = sumsq + yresid^2 

return,total(sumsq)
end


pro result_fit,x,y,R,result

result = R[0] + R[1]*y + R[2]*x + R[3]*y^2 + R[4]*x*y +R[5]*y^2 + $
          R[6]*y^3 + R[6]*y^2*x + R[8]*y*x^2 + R[9]*x^3



end

;_______________________________________________________________________
function par_fit,C

COMMON FUNC_DATA, x,y,lamba

n = n_elements(x)
sumsq = 0.0


yresid = lamba - c[0] - c[1]*y - c[2]*x  - c[3]*x^2 


sumsq = sumsq + yresid^2 

return,total(sumsq)
end


pro result_par_fit,x,y,R,result

result = R[0] + R[1]*y + R[2]*x + R[3]*x^2



end


;_______________________________________________________________________
function par_fit2,C

COMMON FUNC_DATA, x,y,lamba

n = n_elements(x)
sumsq = 0.0


yresid = lamba - c[0] - c[1]*y - c[2]*x  - c[3]*y^2 


sumsq = sumsq + yresid^2 

return,total(sumsq)
end


pro result_par_fit2,x,y,R,result

result = R[0] + R[1]*y + R[2]*x + R[3]*y^2 



end




;_______________________________________________________________________
function par_fity,C

COMMON FUNC_DATA, x,y,lamba

n = n_elements(x)
sumsq = 0.0


yresid = lamba - c[0] - c[1]*y - c[2]*x  - c[3]*y^2  -c[4]*y^3


sumsq = sumsq + yresid^2 

return,total(sumsq)
end


pro result_par_fity,x,y,R,result

result = R[0] + R[1]*y + R[2]*x + R[3]*y^2  + R[4]*y^3



end
