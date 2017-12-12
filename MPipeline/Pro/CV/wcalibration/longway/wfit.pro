function wfit,C

COMMON FUNC_DATA, xdet,ydet

n = n_elements(xdet)
sumsq = 0.0


yresid = ydet - c[0] - c[1]*ydet - c[2]*xdet- c[3]*ydet^2 - c[4]*xdet*ydet -c[5]*ydet^2 


sumsq = sumsq + yresid^2 

return,total(sumsq)
end


pro result_fit,xdet,ydet,R,result

result = R[0] + R[1]*ydet + R[2]*xdet + R[3]*ydet^2 + R[4]*xdet*ydet +R[5]*ydet^2 



end

;_______________________________________________________________________
function par_fit2,C

COMMON FUNC_DATA, xdet,ydet

n = n_elements(xdet)
sumsq = 0.0


yresid = ydet - c[0] - c[1]*ydet - c[2]*xdet  - c[3]*ydet^2 


sumsq = sumsq + yresid^2 

return,total(sumsq)
end


pro result_par_fit2,xdet,ydet,R,result

result = R[0] + R[1]*ydet + R[2]*xdet + R[3]*ydet^2 



end




;_______________________________________________________________________
function par_fity,C

COMMON FUNC_DATA, xdet,ydet,lamba_det

n = n_elements(xdet)
sumsq = 0.0


yresid = lamba_det - c[0] - c[1]*ydet - c[2]*xdet  - c[3]*ydet^2  -c[4]*ydet^3


sumsq = sumsq + yresid^2 

return,total(sumsq)
end


pro result_par_fity,xdet,ydet,R,result

result = R[0] + R[1]*ydet + R[2]*xdet + R[3]*ydet^2  + R[4]*ydet^3



end


;_______________________________________________________________________
function par_fit,C

COMMON FUNC_DATA, xdet,ydet,lamba_det

n = n_elements(xdet)
sumsq = 0.0


yresid = lamba_det - c[0] - c[1]*ydet - c[2]*xdet  


sumsq = sumsq + yresid^2 

return,total(sumsq)
end


pro result_par_fit,xdet,ydet,R,result

result = R[0] + R[1]*ydet + R[2]*xdet


end
