



;_______________________________________________________________________
pro cube2sky, x,y,xsky,ysky,info

xsky = info.cube.crval1 +  (x- info.cube.crpix1) * info.cube.cdelt1 
ysky = info.cube.crval2 +  (y- info.cube.crpix2) * info.cube.cdelt2 


beta = (*cube.pbeta)[y]

alpha = (*cube.palpha)[x]


print,xsky,ysky,alpha,beta
end


;_______________________________________________________________________
pro sky2cube, xsky,ysky,x,y,info

x = (xsky - info.cube.cubecrval1)/info.cube.cdelt1
x = x + info.cube.crpix1

y = (ysky - info.cube.cubecrval2)/info.cube.cdelt2
y = y + info.cube.crpix2

end
