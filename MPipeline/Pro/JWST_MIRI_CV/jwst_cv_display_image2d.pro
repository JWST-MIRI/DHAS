;_______________________________________________________________________
;***********************************************************************
pro jwst_cv_image2d_quit,event
widget_control,event.top, Get_UValue = tinfo
widget_control,tinfo.cinfo.cubeview,Get_UValue=cinfo
widget_control,cinfo.Image2dDisplay,/destroy

end
;_______________________________________________________________________
;***********************************************************************

pro jwst_cv_update_image2d,cinfo,ps=ps,eps = eps

if(cinfo.jwst_coadd.flag ne 3) then begin
    result = dialog_message(" You have not selected the wavelength range properly ",/info)
    jwst_cv_coadd_options,cinfo
    return
endif

hcopy =0
if ( (keyword_set(ps)) or ( keyword_set(eps)) ) then hcopy = 1
x1 = (*cinfo.roi).roix1
x2 =  (*cinfo.roi).roix2
y1 =  (*cinfo.roi).roiy1 
y2 =  (*cinfo.roi).roiy2
naxis1 = x2 - x1 + 1
naxis2 = y2 - y1 + 1

xsize = floor(float(naxis1)/float(cinfo.view_image2d.zoom_user))
ysize = floor(float(naxis2)/float(cinfo.view_image2d.zoom_user))

xstart = fix(cinfo.view_image2d.xpos - xsize/2)
ystart = fix(cinfo.view_image2d.ypos - ysize/2)

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

xsubsize = ixend - ixstart + 1
ysubsize = iyend - iystart + 1

zoom = 1

jwst_cv_screen_size,cinfo.cv_control.max_x_window, cinfo.cv_control.max_y_window,$
               xsubsize,ysubsize,$
               zoom,$
               xscreen_size,yscreen_size

cinfo.view_image2d.plot_xsize = xscreen_size
cinfo.view_image2d.plot_ysize = yscreen_size
cinfo.view_image2d.zoom = zoom ; initialize

image = (*cinfo.jwst_image2d.pimage)
isum = (*cinfo.jwst_image2d.pisum)

sub_image = fltarr(xsubsize,ysubsize)
isub_image = intarr(xsubsize,ysubsize)

sub_image[ixstart:ixend,iystart:iyend] =image[xstart:xend,ystart:yend]
isub_image[ixstart:ixend,iystart:iyend] =isum[xstart:xend,ystart:yend]

if ptr_valid (cinfo.jwst_image2d.psubdata) then ptr_free,cinfo.jwst_image2d.psubdata
cinfo.jwst_image2d.psubdata = ptr_new(sub_image)

if ptr_valid (cinfo.jwst_image2d.pisubdata) then ptr_free,cinfo.jwst_image2d.pisubdata
cinfo.jwst_image2d.pisubdata = ptr_new(isub_image)

loadct,cinfo.col_table,/silent

jwst_cv_get_image_stat,sub_image,isub_image,$
                       sub_mean,sub_std,cube_sum,$
                       image_min,image_max,$
                       range_min,range_max,$
                       sub_median,std_mean,$
                       skew,n_pixels,numbad

if(cinfo.view_image2d.default_scale eq 1) then begin
    cinfo.view_image2d.image_scale[0] = range_min
    cinfo.view_image2d.image_scale[1] = range_max
endif

if(hcopy eq 0) then begin 
    window,/pixmap,xsize =cinfo.view_image2d.plot_xsize,ysize = cinfo.view_image2d.plot_ysize,/free
    pixmapID = !D.window
    cinfo.pixmapID = pixmapID
endif

widget_control,cinfo.plotID,draw_xsize =cinfo.view_image2d.plot_xsize,$
               draw_ysize=cinfo.view_image2d.plot_ysize 

if(hcopy eq 0 ) then wset,cinfo.pixmapID

disp_image = congrid(sub_image, $
                     cinfo.view_image2d.plot_xsize,$
                     cinfo.view_image2d.plot_ysize)

disp_image = bytscl(disp_image,min=cinfo.view_image2d.image_scale[0], $
                    max=cinfo.view_image2d.image_scale[1],$
                    top=cinfo.col_max-cinfo.col_bits-1,/nan)

image = 0
tvscl,disp_image,0,0,/device

if( hcopy eq 0) then begin  
    wset,cinfo.draw_window_id
    device,copy=[0,0,$
                 cinfo.view_image2d.plot_xsize,$
                 cinfo.view_image2d.plot_ysize, $
                 0,0,cinfo.pixmapID]
endif

w1 = (*cinfo.jwst_cube.pwavelength)[cinfo.jwst_image2d.z1]
w2 = (*cinfo.jwst_cube.pwavelength)[cinfo.jwst_image2d.z2]
swave = strcompress(string(w1),/remove_all) + ' to  ' + $
        strcompress(string(w2),/remove_all)
widget_control,cinfo.stat_label,set_value = 'Statistics for Co-Added Image, wavelength range:  ' + swave


jwst_cv_box_stat_image,xstart,xend,ystart,yend,cinfo.jwst_image2d,cinfo.jwst_cube,box_stat_image


info_box1 = box_stat_image[0] + box_stat_image[1] + box_stat_image[2] + box_stat_image[3] 
info_box2 = box_stat_image[4] + box_stat_image[5]

widget_control,cinfo.label2d[0], set_value = info_box1
widget_control,cinfo.label2d[1], set_value = info_box2

widget_control,cinfo.rminlabelID, set_value = cinfo.view_image2d.image_scale[0]
widget_control,cinfo.rmaxlabelID, set_value = cinfo.view_image2d.image_scale[1]


cinfo.view_image2d.xstart = xstart
cinfo.view_image2d.ystart = ystart
cinfo.view_image2d.xend = xend
cinfo.view_image2d.yend = yend

jwst_cv_color6

if(cinfo.view_image2d.plot_pixel eq 1) then begin

    x = (cinfo.view_image2d.xpos) - xstart
    y = (cinfo.view_image2d.ypos) - ystart

    xpos_screen = fix(x) * cinfo.view_image2d.zoom; * cinfo.view_image2d.zoom_user
    ypos_screen = fix(y) * cinfo.view_image2d.zoom; * cinfo.view_image2d.zoom_user

    pixel = 1 * cinfo.view_image2d.zoom; * cinfo.view_image2d.zoom_user
    xpos1 = xpos_screen
    xpos2 = xpos_screen + pixel
    ypos1 = ypos_screen
    ypos2 = ypos_screen + pixel
    box_coords1 = [xpos1,xpos2,ypos1,ypos2]
    plots,box_coords1[[0,0,1,1,0]],box_coords1[[2,3,3,2,2]],psym=0,/device,color=4
endif

if(cinfo.do_centroid eq 1) then begin
    zoom  = cinfo.view_image2d.zoom
    plots,(cinfo.jwst_centroid.xcenter-xstart-0.5)*zoom,$
          (cinfo.jwst_centroid.ycenter-ystart-0.5)*zoom,$
          psym=1,/device,color=4,symsize = 1
endif


widget_control,cinfo.cubeview,Set_UValue = cinfo
end 


;_______________________________________________________________________

pro jwst_cv_display_image2d, cinfo


xsize_image = cinfo.jwst_image2d.x2 - cinfo.jwst_image2d.x1 + 1
ysize_image = cinfo.jwst_image2d.y2 - cinfo.jwst_image2d.y1 + 1
cinfo.view_image2d.zoom_user = 1
widget_control,cinfo.zoom1,set_button=1            
widget_control,cinfo.zoom2,set_button=0
widget_control,cinfo.zoom4,set_button=0
widget_control,cinfo.zoom8,set_button=0
widget_control,cinfo.zoom16,set_button=0

zoom = 1
jwst_cv_screen_size,cinfo.cv_control.max_x_window, cinfo.cv_control.max_y_window,$
               xsize_image,ysize_image,$
               zoom,$
               xscreen_size,yscreen_size

cinfo.view_image2d.plot_xsize = xscreen_size
cinfo.view_image2d.plot_ysize = yscreen_size
cinfo.view_image2d.zoom = zoom ; initialize

cinfo.view_image2d.plot_xsize_org = cinfo.view_image2d.plot_xsize
cinfo.view_image2d.plot_ysize_org = cinfo.view_image2d.plot_ysize
cinfo.view_image2d.plot_pixel = 1
cinfo.view_image2d.default_scale = 1
;_______________________________________________________________________

jwst_cv_update_image2d,cinfo

Widget_Control,cinfo.cubeview,Set_UValue=cinfo
    
end
