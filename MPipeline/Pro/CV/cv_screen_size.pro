pro cv_screen_size,max_x_window, max_y_window,$
                   xsize_image, ysize_image,$
                   zoom,$
                   xsize_screen, ysize_screen



xzoom = floor(max_x_window/xsize_image) ; go back to maximum size of cube window
yzoom = floor(max_y_window/ysize_image)


zoom = xzoom
if(yzoom lt xzoom) then zoom = yzoom
if(zoom lt 1) then zoom  = 1


xsize_screen = xsize_image*zoom
ysize_screen = ysize_image*zoom

end
