pro cv_update_cube,cinfo,ps=ps,eps = eps
hcopy =0

if ( (keyword_set(ps)) or ( keyword_set(eps)) ) then hcopy = 1

x1 = (*cinfo.roi).roix1
x2 =  (*cinfo.roi).roix2
y1 =  (*cinfo.roi).roiy1 
y2 =  (*cinfo.roi).roiy2
naxis1 = x2 - x1 + 1
naxis2 = y2 - y1 + 1

zoom = cinfo.view_cube.zoom


xsize = floor(float(naxis1)/float(cinfo.view_cube.zoom_user))
ysize = floor(float(naxis2)/float(cinfo.view_cube.zoom_user))


;print,'x1 x2 y1 y2',x1,x2,y1,y2,xsize,ysize,xsize/2,ysize/2
xstart = fix(cinfo.view_cube.xpos_cube - xsize/2)
ystart = fix(cinfo.view_cube.ypos_cube - ysize/2)

;print,'first x start ystart',xstart,ystart

if(xstart lt 0) then xstart = 0
if(ystart lt 0) then ystart = 0

xend  = xstart + xsize-1
yend  = ystart + ysize -1

if(xend ge cinfo.cube.naxis1) then begin
    xend =  cinfo.cube.naxis1-1
    xstart = xend - (xsize-1)
endif

if(yend ge cinfo.cube.naxis2) then begin
    yend = cinfo.cube.naxis2-1
    ystart = yend- (ysize-1)
endif

if(xstart lt 0) then xstart = 0
if(ystart lt 0) then ystart = 0
ix = xend - xstart
iy = yend - ystart

ixstart = 0
iystart = 0
ixend = ixstart + ix
iyend = iystart + iy


;print,'ixstart, ixend ',ixstart,ixend,ixend - ixstart
;print,'iystart, iyend ',iystart,iyend,iyend - iystart
;print,'xstart xend ',xstart,xend,xend-xstart
;print,'ystart yend ',ystart,yend,yend-ystart


xsubsize = ixend - ixstart + 1
ysubsize = iyend - iystart + 1

cv_screen_size,cinfo.control.max_x_window, cinfo.control.max_y_window,$
               xsubsize,ysubsize,$
               zoom,$
               xscreen_size,yscreen_size

cinfo.view_cube.plot_xsize = xscreen_size
cinfo.view_cube.plot_ysize = yscreen_size
cinfo.view_cube.zoom = zoom ; initialize


iwavelength = cinfo.view_cube.this_iwavelength - cinfo.cube.istart_wavelength 
cube_image = (*cinfo.cube.pcubedata)[*,*,iwavelength]
sub_image = fltarr(xsubsize,ysubsize)   

sub_image[ixstart:ixend,iystart:iyend] =cube_image[xstart:xend,ystart:yend]

if ptr_valid (cinfo.cube.psubdata) then ptr_free,cinfo.cube.psubdata
cinfo.cube.psubdata = ptr_new(sub_image)



;help,sub_image
;print,iystart,iyend,ystart,yend

get_image_stat,cube_image,cube_mean,cube_std,image_min,$
               image_max,range_min,range_max,$
               cube_median,std_mean,skew,n_pixels,numbad


loadct,cinfo.col_table,/silent

num = n_elements(sub_image)

if(num gt 1) then begin
    
    get_image_stat,sub_image,cube_mean,cube_std,image_min,$
                   image_max,range_min,range_max,$
                   cube_median,std_mean,skew,n_pixels,numbad
    cube_sum = total(sub_image,/nan)
    box_stat4 = 'Mean: '+ strcompress(string(cube_mean,format="(f12.5)")) + ',   STD' + $
	strcompress(string(cube_std,format="(f15.8)")) + $
	        '   Sum: '+ strcompress(string(cube_sum,format="(f12.5)"))
    box_stat5 = 'Min:  '+ strcompress(string(image_min)) + ',  Max' + strcompress(string(image_max))

endif else begin 
    
    box_stat4 = 'Mean: NA,  Median: NA'
    box_stat5 = 'Min: NA,  Max: NA'
endelse



cv_box_stat,xstart,xend,ystart,yend,iwavelength,cinfo.cube,box_stat

swlength = strcompress(string((*cinfo.cube.pwavelength)[iwavelength]),/remove_all)
widget_control,cinfo.stat_label ,set_value = ' 2-D Image Statistics at Wavelength: ' + swlength


info_box1 = box_stat[0] + box_stat[1] + box_stat[2] + box_stat[3] 
info_box2 = box_stat[4] + box_stat[5]

widget_control,cinfo.label2d[0], set_value = info_box1
widget_control,cinfo.label2d[1], set_value = info_box2


if(cinfo.default_scale eq 1) then begin
    cinfo.graph_range[0] = range_min
    cinfo.graph_range[1] = range_max
endif

if(hcopy eq 0) then begin 
    window,/pixmap,xsize =cinfo.view_cube.plot_xsize,ysize = cinfo.view_cube.plot_ysize,/free
    pixmapID = !D.window
    cinfo.pixmapID = pixmapID
endif
widget_control,cinfo.plotID,draw_xsize =cinfo.view_cube.plot_xsize,draw_ysize=cinfo.view_cube.plot_ysize 


if(hcopy eq 0 ) then wset,cinfo.pixmapID

disp_image = congrid(sub_image, $
                     cinfo.view_cube.plot_xsize,$
                     cinfo.view_cube.plot_ysize)
;print,'plot xsize plot ysize',cinfo.view_cube.plot_xsize,cinfo.view_cube.plot_ysize
;print,'bytscl min max',cinfo.graph_range[0],cinfo.graph_range[1]
;print,min(disp_image,/nan),max(disp_image,/nan)

disp_image = bytscl(disp_image,min=cinfo.graph_range[0], $
                    max=cinfo.graph_range[1],$
                    top=cinfo.col_max-cinfo.col_bits-1,/nan)

;print,'min and max after bytscl',min(disp_image),max(disp_image)

cube_image = 0
sub_image = 0
tv,disp_image,0,0,/device

;help,disp_image
if( hcopy eq 0) then begin  
    wset,cinfo.draw_window_id
    device,copy=[0,0,$
                 cinfo.view_cube.plot_xsize,$
                 cinfo.view_cube.plot_ysize, $
                 0,0,cinfo.pixmapID]
endif


widget_control,cinfo.rminLabelID, set_value = cinfo.graph_range[0]
widget_control,cinfo.rmaxLabelID, set_value = cinfo.graph_range[1]

cinfo.view_cube.xstart = xstart
cinfo.view_cube.ystart = ystart
cinfo.view_cube.xend = xend
cinfo.view_cube.yend = yend

color6
if(cinfo.view_cube.plot_pixel eq 1) then begin

    x = (cinfo.view_cube.xpos_cube) - xstart
    y = (cinfo.view_cube.ypos_cube) - ystart
    xpos_screen = fix(x) * cinfo.view_cube.zoom
    ypos_screen = fix(y) * cinfo.view_cube.zoom

    pixel = 1 * cinfo.view_cube.zoom 
    xpos1 = xpos_screen
    xpos2 = xpos_screen + pixel
    ypos1 = ypos_screen
    ypos2 = ypos_screen + pixel
    box_coords1 = [xpos1,xpos2,ypos1,ypos2]
    plots,box_coords1[[0,0,1,1,0]],box_coords1[[2,3,3,2,2]],psym=0,/device,color=4

endif


; added updating cube pixel box (5/20/2011)

 iwavelength = cinfo.view_cube.this_iwavelength - cinfo.cube.istart_wavelength 
 cube_value = (*cinfo.cube.pcubedata)[cinfo.view_cube.xpos_cube,$
 	                              cinfo.view_cube.ypos_cube,$
                                      iwavelength]
                
 uncer_value = (*cinfo.cube.puncertainty)[cinfo.view_cube.xpos_cube,$
                                          cinfo.view_cube.ypos_cube,$
                                          iwavelength]

 sx = 'x: '+ strcompress(string(fix(cinfo.view_cube.xpos_cube+1)))
 sy = '  y: '+ strcompress(string(fix(cinfo.view_cube.ypos_cube+1)))
 svalue = '  Pixel Value: ' + strcompress(string(cube_value))
 suvalue = ' +/-' + strcompress(string(uncer_value))

 beta = (*cinfo.cube.pbeta)[cinfo.view_cube.ypos_cube]
 alpha = (*cinfo.cube.palpha)[cinfo.view_cube.xpos_cube]
 sbeta =  ' Beta:  ' + strcompress(string(beta)) + ' (arc sec)'
 salpha = '  Alpha ' + strcompress(string(alpha)) + '(arc sec)'
       info_line = sx + sy + svalue  +suvalue + salpha + sbeta

widget_control,cinfo.pixel_labelID,set_value = info_line

;here

; update the new region for the spectrum to be extracted from 
cinfo.spectrum.xcube_range[0] = xstart
cinfo.spectrum.xcube_range[1] = xend
cinfo.spectrum.ycube_range[0] = ystart
cinfo.spectrum.ycube_range[1] = yend


cinfo.spectrum.beta_range[0] = (*cinfo.cube.pbeta)[ystart]
cinfo.spectrum.beta_range[1] = (*cinfo.cube.pbeta)[yend]
cinfo.spectrum.alpha_range[0] = (*cinfo.cube.palpha)[xstart]
cinfo.spectrum.alpha_range[1] = (*cinfo.cube.palpha)[xend]


if(cinfo.do_centroid eq 1) then begin
    zoom  = cinfo.view_cube.zoom
    plots,(cinfo.centroid.xcenter-xstart-0.5)*zoom,$
          (cinfo.centroid.ycenter-ystart-0.5)*zoom,$
          psym=1,/device,color=4,symsize = 1
endif

widget_control,cinfo.cubeview,Set_UValue = cinfo
end 
