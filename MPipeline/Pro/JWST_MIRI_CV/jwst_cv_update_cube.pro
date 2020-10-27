pro jwst_cv_update_cube,cinfo,ps=ps,eps = eps
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

xstart = fix(cinfo.view_cube.xpos_cube - xsize/2)
ystart = fix(cinfo.view_cube.ypos_cube - ysize/2)

if(xstart lt 0) then xstart = 0
if(ystart lt 0) then ystart = 0

xend  = xstart + xsize-1
yend  = ystart + ysize -1

if(xend ge cinfo.jwst_cube.naxis1) then begin
    xend =  cinfo.jwst_cube.naxis1-1
    xstart = xend - (xsize-1)
endif

if(yend ge cinfo.jwst_cube.naxis2) then begin
    yend = cinfo.jwst_cube.naxis2-1
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

jwst_cv_screen_size,cinfo.cv_control.max_x_window, cinfo.cv_control.max_y_window,$
                    xsubsize,ysubsize,$
                    zoom,$
                    xscreen_size,yscreen_size

cinfo.view_cube.plot_xsize = xscreen_size
cinfo.view_cube.plot_ysize = yscreen_size
cinfo.view_cube.zoom = zoom ; initialize


iwavelength = cinfo.view_cube.this_iwavelength - cinfo.jwst_cube.istart_wavelength 
cube_image = (*cinfo.jwst_cube.pcubedata)[*,*,iwavelength]
w_map = (*cinfo.jwst_cube.pw_map)[*,*,iwavelength]
sub_image = fltarr(xsubsize,ysubsize)   

sub_image[ixstart:ixend,iystart:iyend] =cube_image[xstart:xend,ystart:yend]
w_sub_map = fltarr(xsubsize,ysubsize)   
w_sub_map[ixstart:ixend,iystart:iyend] =w_map[xstart:xend,ystart:yend]


if ptr_valid (cinfo.jwst_cube.psubdata) then ptr_free,cinfo.jwst_cube.psubdata
cinfo.jwst_cube.psubdata = ptr_new(sub_image)

loadct,cinfo.col_table,/silent

jwst_cv_box_stat,xstart,xend,ystart,yend,iwavelength,cinfo.jwst_cube,range_min, range_max,box_stat

swlength = strcompress(string((*cinfo.jwst_cube.pwavelength)[iwavelength]),/remove_all)
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



disp_image = bytscl(disp_image,min=cinfo.graph_range[0], $
                    max=cinfo.graph_range[1],$
                    top=cinfo.col_max-cinfo.col_bits-1,/nan)


cube_image = 0
sub_image = 0
tvscl,disp_image,0,0,/device

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

jwst_cv_color6
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

iwavelength = cinfo.view_cube.this_iwavelength - cinfo.jwst_cube.istart_wavelength 
cube_value = (*cinfo.jwst_cube.pcubedata)[cinfo.view_cube.xpos_cube,$
                                          cinfo.view_cube.ypos_cube,$
                                          iwavelength]

w_map_value = (*cinfo.jwst_cube.pw_map)[cinfo.view_cube.xpos_cube,$
                                        cinfo.view_cube.ypos_cube,$
                                        iwavelength]

uncer_value = (*cinfo.jwst_cube.puncertainty)[cinfo.view_cube.xpos_cube,$
                                              cinfo.view_cube.ypos_cube,$
                                              iwavelength]

sx = 'x: '+ strcompress(string(fix(cinfo.view_cube.xpos_cube+1)))
sy = '  y: '+ strcompress(string(fix(cinfo.view_cube.ypos_cube+1)))
svalue = '  Pixel Value: ' + strcompress(string(cube_value))
suvalue = ' +/-' + strcompress(string(uncer_value))

swmap = ' Weight Map'+ strcompress(string(w_map_value))
dec = (*cinfo.jwst_cube.pdec)[cinfo.view_cube.ypos_cube]
ra = (*cinfo.jwst_cube.pra)[cinfo.view_cube.xpos_cube]
sdec =  ' Dec:  ' + strcompress(string(dec)) + ' (arc sec)'
sra = '  Ra ' + strcompress(string(ra)) + '(arc sec)'
info_line1 = sx + sy + svalue  + suvalue
info_line2 = swmap+ sra + sdec

widget_control,cinfo.pixel_labelID1,set_value = 'Cube Spaxel:' + info_line1
widget_control,cinfo.pixel_labelID2,set_value = info_line2

; update the new region for the spectrum to be extracted from 
cinfo.jwst_spectrum.xcube_range[0] = xstart
cinfo.jwst_spectrum.xcube_range[1] = xend
cinfo.jwst_spectrum.ycube_range[0] = ystart
cinfo.jwst_spectrum.ycube_range[1] = yend

cinfo.jwst_spectrum.dec_range[0] = (*cinfo.jwst_cube.pdec)[ystart]
cinfo.jwst_spectrum.dec_range[1] = (*cinfo.jwst_cube.pdec)[yend]
cinfo.jwst_spectrum.ra_range[0] = (*cinfo.jwst_cube.pra)[xstart]
cinfo.jwst_spectrum.ra_range[1] = (*cinfo.jwst_cube.pra)[xend]


if(cinfo.do_centroid eq 1) then begin
    zoom  = cinfo.view_cube.zoom
    plots,(cinfo.jwst_centroid.xcenter-xstart-0.5)*zoom,$
          (cinfo.jwst_centroid.ycenter-ystart-0.5)*zoom,$
          psym=1,/device,color=4,symsize = 1
endif

widget_control,cinfo.cubeview,Set_UValue = cinfo
end 
