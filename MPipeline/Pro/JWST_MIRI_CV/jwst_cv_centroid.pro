pro jwst_cv_image_fill, image,new_image,status,error_message

status = 0
new_image = image
s = size(image)
nx = s[1]
ny = s[2]
error_message = " "
if(nx lt 3 or ny lt 3) then begin
    status = 1
    error_message = " Select a larger region"
    return
end

temp_image = image

in = where(finite(temp_image) eq 1,ngood)
index = where(finite(temp_image) eq 0,n)
ntotal = nx * ny
if(ngood lt ntotal*.75) then begin
    status = 1
    error_message = " Select a difference region, too many nans in image"
    return
end

is = 2
ir = 2
if(n ne 0) then print,' The image to be centroided contains Nans, cleaning image' 


for i = 0, n-1 do begin
    ynan = fix(index[i]/nx)
    xnan = index[i] - (ynan * nx)
    
    xstart = xnan - is
    if(xstart lt 0) then xstart = 0
    xend = xstart + ir
    if(xend gt (nx-1) ) then xend = nx-1

    ystart = ynan - is
    if(ystart lt 0) then ystart = 0
    yend = ystart + ir
    if(yend gt (ny-1) ) then yend = ny-1

    xrange = xend -xstart + 1
    yrange = yend - ystart + 1

    igood = 0
    total_distance = 0
    av = 0

    for ix = 0,xrange -1 do begin
        for iy = 0, yrange-1 do begin
            xx = xstart + ix
            yy = ystart + iy
            xdist  = xnan - xx 
            ydist  = ynan - yy
            
            distance = float(sqrt(xdist*xdist + ydist*ydist))
            if( finite(temp_image[xx,yy]) eq 1) then begin
                av = av + temp_image[xx,yy]/distance
                total_distance = total_distance + distance
                igood = igood + 1
            endif
        endfor
    endfor


    if(igood lt 2) then begin
        status = 3
        error_message = " Select a different region, too many nans in image can not clean"
        return
    endif

    av = av/ total_distance
    new_image[xnan,ynan] = av
endfor


index = where(finite(new_image) eq 0,n)


if(n ne 0) then begin 
    status = 4
    error_message = " Can not remove nans from image"
    return
endif
 temp_image = 0


end

;***********************************************************************
pro jwst_cv_cleanup_centroid,cinfo

cinfo.do_centroid = 0
widget_control,cinfo.cenID[0],set_value = '  ' 
widget_control,cinfo.cenID[1],set_value = '  '
widget_control,cinfo.cenID[2],set_value = '  '
widget_control,cinfo.cenID[3],set_value = '  '
widget_control,cinfo.cenID[4],set_value = '  '
widget_control,cinfo.cenID[5],set_value = '  '
widget_control,cinfo.cenID[6],set_value = '  '
end



;***********************************************************************
pro jwst_cv_centroid_setup_image,cinfo

status = 0
cinfo.jwst_centroid.fail = 0

if(cinfo.imagetype eq 0) then begin
    image = (*cinfo.jwst_cube.psubdata)
    xstart = cinfo.view_cube.xstart 
    ystart = cinfo.view_cube.ystart 
    zoom = cinfo.view_cube.zoom 
endif

if(cinfo.imagetype ge 1) then begin 
    if ptr_valid(cinfo.jwst_image2d.psubdata) then begin
        image = (*cinfo.jwst_image2d.psubdata) 
        xstart = cinfo.view_image2d.xstart 
        ystart = cinfo.view_image2d.ystart
        zoom = cinfo.view_image2d.zoom  
    endif else begin
        result = dialog_message(" You have not selected the wavelength range properly ",/info)
        cv_coadd_options,cinfo
        cinfo.jwst_centroid.fail = 1
        return
    endelse
endif


indx = where(finite(image) eq 0,nnan)

status = 0
if(nnan ne 0) then begin
    cv_image_fill,image,new_image,status,error_message
    image = new_image
    new_image  = 0
endif

if(status ne 0) then begin
    result = dialog_message(" Problem with region " + error_message, /info)
    return
endif


if ptr_valid(cinfo.jwst_centroid.pimage) then ptr_free,cinfo.jwst_centroid.pimage
cinfo.jwst_centroid.pimage = ptr_new(image)

if ptr_valid(cinfo.jwst_centroid.porg_image) then ptr_free,cinfo.jwst_centroid.porg_image
cinfo.jwst_centroid.porg_image = ptr_new(image)

cinfo.jwst_centroid.zoom = zoom
cinfo.jwst_centroid.xstart = xstart
cinfo.jwst_centroid.ystart = ystart



end
;***********************************************************************

pro jwst_cv_centroid,cinfo

if(cinfo.jwst_centroid.fail eq 1) then return
xstart = cinfo.jwst_centroid.xstart
ystart = cinfo.jwst_centroid.ystart
zoom = cinfo.jwst_centroid.zoom
image = (*cinfo.jwst_centroid.pimage)

;print,'xstart ystart',xstart,ystart

s = size(image)
if(s[1] * s[2] lt 8) then begin
    result = dialog_message(" Image to centroid must have 8 elements ", /info)
    return
endif



Cfit = mpfit2dpeak(image,a,x,y,/tilt,/lorentzian)


a[2:5] = a[2:5]/cinfo.jwst_centroid.rebin_factor

;print,'centroid parameters',a[4],a[5]
; routine assume the center of the pixel is an integer With first
 ; pixel centered at 0.0. Essentially the first pixel starts at -0.5

; for plotting first pixel starts at 0.0

cinfo.jwst_centroid.xcenter_plot = a[4] + 0.5 
cinfo.jwst_centroid.ycenter_plot = a[5] + 0.5

; for reporting results first pixel is centered at 1.0
cinfo.jwst_centroid.xcenter = a[4] + xstart + 1.0
cinfo.jwst_centroid.ycenter = a[5] + ystart + 1.0


jwst_cv_color6
wset,cinfo.draw_window_id
device,copy=[0,0,$
             cinfo.view_cube.plot_xsize,$
             cinfo.view_cube.plot_ysize, $
             0,0,cinfo.pixmapID]


plots,cinfo.jwst_centroid.xcenter_plot*zoom,$
      cinfo.jwst_centroid.ycenter_plot*zoom,$
      psym=1,/device,color=4,symsize = 1
        

sx = strcompress(string(cinfo.jwst_centroid.xcenter, format="(f9.2)"),/remove_all)
sy = strcompress(string(cinfo.jwst_centroid.ycenter,format="(f9.2)"),/remove_all)
shwx = strcompress(string(a[2] ,format="(f9.2)"),/remove_all)
shwy = strcompress(string(a[3] ,format="(f9.2)"),/remove_all)
widget_control,cinfo.cenID[0],set_value = ' Centroid Values' 
widget_control,cinfo.cenID[1],set_value = ' X center: ' + sx
widget_control,cinfo.cenID[2],set_value = ' Y center: '+ sy
widget_control,cinfo.cenID[3],set_value = ' Gaussian Sigma X: ' + shwx
widget_control,cinfo.cenID[4],set_value = ' Gaussian Sigma Y: ' + shwy
widget_control,cinfo.cenID[5],set_value = '  [Pixel Coordinates: the center of the pixel is an integer] 
widget_control,cinfo.cenID[6],set_value = '  [Center of first pixel has coordinate = 1,1]. 



end
