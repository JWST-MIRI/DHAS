function cfit,C

COMMON FUNC_DATA, x,y,alpha,lamba

n = n_elements(x)
sumsq = 0.0

yresid = lamba - c[0] - c[2]*y - c[4]*x- c[6]*y^2 - c[8]*x*y -c[10]*y^2  - $
         c[12]*y^3 - c[14]*y^2*x -c[16]*y*x^2 - c[19]*x^3

xredid = alpha - c[1] - c[3]*y - c[5]*x - c[7]*y^2 - c[9]*y*x - c[11]*y^2 - $
         c[13]*y^3 - c[15]*y^2*x -c[17]*y*x^2 - c[19]*x^3

sumsq = sumsq + yresid^2 + xredid^2

return,total(sumsq)
end
 



pro result_fit,x,y,R,xresult,yresult

yresult = R[0] + R[2]*y + R[4]*x + R[6]*y^2 + R[8]*x*y +R[10]*y^2 + $
          R[12]*y^3 + R[14]*y^2*x + R[16]*y*x^2 + R[18]*x^3

xresult = R[1] + R[3]*y + R[5]*x + R[7]*y^2 + R[9]*x*y +R[11]*y^2 + $
          R[13]*y^3 + R[15]*y^2*x + R[17]*y*x^2 + R[19]*x^3
 

end
