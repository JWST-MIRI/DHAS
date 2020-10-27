
pro jwst_centroid_surface_quit,event
widget_control,event.top, Get_UValue = tinfo
widget_control,tinfo.cinfo.CubeView,Get_UValue=cinfo
widget_control,cinfo.SurfacePlot,/destroy
end
;_______________________________________________________________________
pro jwst_surface_event, event
Widget_Control,event.id,Get_uValue=event_name
Widget_Control,event.top,Get_UValue=winfo
widget_control,winfo.cinfo.CubeView,Get_UValue=cinfo
if (widget_info(event.id,/TLB_MOVE_EVENTS) eq 1 ) then begin
    cinfo.jwst_centroid.xoffset_surface =  event.x
    cinfo.jwst_centroid.yoffset_surface =  event.y
    cinfo.jwst_centroid.uoffset_surface =  1
    widget_control,event.top,set_uvalue = winfo
    widget_control,winfo.cinfo.cubeview,set_uvalue = info
    jwst_cv_centroid_surface_display,cinfo
    return
endif

case 1 of 
;_______________________________________________________________________
    (strmid(event_name,0,5) EQ 'rebin'): begin 
        if(event.index eq 0) then begin
            image = (*cinfo.jwst_centroid.porg_image)
            if ptr_valid(cinfo.jwst_centroid.pimage) then ptr_free,cinfo.jwst_centroid.pimage
            cinfo.jwst_centroid.pimage = ptr_new(image)
            cinfo.jwst_centroid.rebin_factor = 1
        endif 
        
        if(event.index eq 1) then begin 

            image = (*cinfo.jwst_centroid.pimage)
            sz = size(image) 
            new_image = rebin(image,sz[1]*2,sz[2]*2)
            sz = size(new_image)
            new_image = smooth(new_image,2) 
            if ptr_valid(cinfo.jwst_centroid.pimage) then ptr_free,cinfo.jwst_centroid.pimage
            cinfo.jwst_centroid.pimage = ptr_new(new_image)
            cinfo.jwst_centroid.rebin_factor = 2 * cinfo.jwst_centroid.rebin_factor
        endif
        jwst_cv_centroid_surface_update,cinfo
    end
;_______________________________________________________________________
    (strmid(event_name,0,6) EQ 'rotate'): begin 
        angles = [0,30,45,60,90,120,180,270]

        cinfo.jwst_centroid.angle =  angles[event.index]

        jwst_cv_centroid_surface_update,cinfo
    end
;_______________________________________________________________________
    (strmid(event_name,0,3) EQ 'cen'): begin
        jwst_cv_centroid, cinfo
    end
endcase

widget_control,winfo.cinfo.cubeview,Set_Uvalue = cinfo

end

;_______________________________________________________________________
;***********************************************************************
pro jwst_cv_centroid_surface_display,cinfo

window,1
wdelete,1
w = get_screen_size()
x_offset = w[0] - 350
if(x_offset lt 0) then x_offset = 50
y_offset = 0


if(cinfo.jwst_centroid.uoffset_surface eq 1) then begin
    x_offset = cinfo.jwst_centroid.xoffset_surface
    y_offset = cinfo.jwst_centroid.yoffset_surface
endif

if(XRegistered ('surface')) then begin
    widget_control,cinfo.SurfacePlot,/destroy
endif

SurfacePlot = widget_base(title = 'Surface Plot', col =1 , mbar = menuBar,$
                       group_leader = cinfo.CubeView,$
                       xsize = 850,ysize = 600,/column,$
                          xoffset = x_offset, yoffset = y_offset,/tlb_move_events)

QuitMenu = widget_button(menuBar,value="Quit",font = cinfo.font2)
quitbutton = widget_button(quitmenu,value="Quit",event_pro='jwst_centroid_surface_quit')
graphID_master0 = widget_base(SurfacePlot,row=1)
graphID0 = widget_base(graphID_master0,col=1)
graphID1 = widget_base(graphID_master0,col=1)

SurfaceDraw = Widget_Draw(graphID0, XSize = 600, YSize = 600, Retain=2)

baseID = widget_base(graphID1,row=1)
rebinOptions = ['No Rebinning or Smoothing',' Rebin factor of 2 and Smooth']
RebinSmoothID = Widget_combobox(baseID, value = rebinOptions,uvalue = 'rebin')

cinfo.jwst_centroid.angle = 30
cinfo.jwst_centroid.do_rebinsmooth = 0
cinfo.jwst_centroid.rebin_factor = 1

baseID = widget_base(graphID1,row=1)
Angles=['No Rotation','30 degrees (Default)','45 Degrees','60 Degreens', '90 Degrees', '120 Degrees', '180 Degrees','270 Degrees']
RotateID = widget_combobox(baseID,value = Angles,$
                               font = fontname5,/dynamic_resize,uvalue = 'rotate')
baseID = widget_base(graphID1,row=1)
cenID = widget_button(baseID,value ='Re-centroid',font=fontname5,uvalue ='cen')

surfacep = {cinfo                  : cinfo}

Widget_Control,SurfacePlot,Set_UValue=surfacep
widget_control,SurfacePlot,/realize
XManager,'surface',SurfacePLot,/No_Block,event_handler = 'jwst_surface_event'


widget_control,SurfaceDraw,get_value=tdraw_id
cinfo.jwst_centroid.draw_window_id = tdraw_id

cinfo.SurfacePLot = SurfacePlot
Widget_Control,cinfo.CubeView,Set_UValue=cinfo

jwst_cv_centroid_setup_image,cinfo
jwst_cv_centroid_surface_update,cinfo
Widget_Control,cinfo.CubeView,Set_UValue=cinfo
end

;_______________________________________________________________________
pro jwst_cv_centroid_surface_update,cinfo

xstart = cinfo.jwst_centroid.xstart
ystart = cinfo.jwst_centroid.ystart
wset,cinfo.jwst_centroid.draw_window_id
image = (*cinfo.jwst_centroid.pimage)

sz = size(image)
x = findgen(sz[1]) + xstart +1
y = findgen(sz[2]) + ystart +1

az_rot = cinfo.jwst_centroid.angle 

surface,image,x,y,az = az_rot,charsize = 2,title="Surface Plot of Centroided Image",$
        xtitle = 'X Pixel Values',ytitle = 'Y Pixel Values', ztitle = ' Flux Measure'

wset,cinfo.view_spectrum.draw_window_id
device,copy=[0,0,cinfo.view_spectrum.plot_xsize,cinfo.view_spectrum.plot_ysize,$
             0,0,cinfo.view_spectrum.pixmapID]

jwst_cv_update_spectrum,cinfo ; added this line if the surface plot is up

if(cinfo.imagetype eq 1) then jwst_cv_draw_coadd_lines,cinfo
if(cinfo.imagetype eq 0) then  jwst_cv_draw_current_wavelength,cinfo
image = 0

end

