
;_______________________________________________________________________
pro jwst_adjust_quit,event
widget_control,event.top, Get_UValue = tinfo
widget_control,tinfo.cinfo.CubeView,Get_UValue=cinfo
widget_control,cinfo.AdjustROI,/destroy
end
;_______________________________________________________________________
pro jwst_adjust_event, event
Widget_Control,event.id,Get_uValue=event_name
Widget_Control,event.top,Get_UValue=winfo
widget_control,winfo.cinfo.CubeView,Get_UValue=cinfo

x1_full = cinfo.jwst_cube.x1
x2_full = cinfo.jwst_cube.x2
y1_full = cinfo.jwst_cube.y1
y2_full = cinfo.jwst_cube.y2

case 1 of 
    (strmid(event_name,0,4) EQ 'done'): begin 
        widget_control,cinfo.adjust_roi.x1ID,get_value  = temp
        cinfo.adjust_roi.x1 = temp
        widget_control,cinfo.adjust_roi.x2ID,get_value  = temp
        xlength = temp
        x2 = cinfo.adjust_roi.x1 + xlength
        cinfo.adjust_roi.x2 = x2

        widget_control,cinfo.adjust_roi.y1ID,get_value  = temp
        cinfo.adjust_roi.y1 = temp

        widget_control,cinfo.adjust_roi.y2ID,get_value  = temp
        ylength = temp 
        y2 = cinfo.adjust_roi.y1 + ylength
        cinfo.adjust_roi.y2 = y2

        out_of_range = 0
        if(cinfo.adjust_roi.x1 lt 1) then begin
            cinfo.adjust_roi.x1 = 1
            out_of_range = 1
            widget_control,cinfo.adjust_roi.x1ID,set_value = cinfo.adjust_roi.x1
        endif

        if(cinfo.adjust_roi.x2 gt x2_full+1) then begin
            cinfo.adjust_roi.x2 = x2_full+1
            out_of_range = 1
            widget_control,cinfo.adjust_roi.x2ID,set_value = cinfo.adjust_roi.x2
        endif

        if(cinfo.adjust_roi.y1 lt 1) then begin
            cinfo.adjust_roi.y1 = 1
            out_of_range = 1
            widget_control,cinfo.adjust_roi.y1ID,set_value = cinfo.adjust_roi.y1
        endif

        if(cinfo.adjust_roi.y2 gt y2_full+1) then begin
            cinfo.adjust_roi.y2 = y2_full+1
            out_of_range = 1
            widget_control,cinfo.adjust_roi.x2ID,set_value = cinfo.adjust_roi.x2
        endif


        x1 = cinfo.adjust_roi.x1 - 1
        x2 = cinfo.adjust_roi.x2 - 1
        y1 = cinfo.adjust_roi.y1 - 1
        y2 = cinfo.adjust_roi.y2 - 1


        (*cinfo.roi).roix1 = x1
        (*cinfo.roi).roix2 = x2
        (*cinfo.roi).roiy1 = y1
        (*cinfo.roi).roiy2 = y2
        if(cinfo.imagetype eq 0) then begin 
            cinfo.view_cube.xpos_cube = (x2 - x1)/2 + x1 
            cinfo.view_cube.ypos_cube = (y2 - y1)/2 + y1
            jwst_cv_update_cube,cinfo
        endif

        if(cinfo.imagetype ge 1) then begin 
            cinfo.view_image2d.xpos = (x2 - x1)/2 + x1 
            cinfo.view_image2d.ypos = (y2 - y1)/2 + y1
            jwst_cv_update_image2d,cinfo
        endif

    end


    (strmid(event_name,0,2) EQ 'x1') : begin
        cinfo.adjust_roi.x1 = event.value
        xlength = event.value 
        x2 = cinfo.adjust_roi.x1 + xlength
        if(x2 gt x2_full) then x2 = x2_full
        cinfo.adjust_roi.x2 = x2
    end

    (strmid(event_name,0,2) EQ 'x2') : begin
       
    end

    (strmid(event_name,0,2) EQ 'y1') : begin
        cinfo.adjust_roi.y1 = event.value
    end

    (strmid(event_name,0,2) EQ 'y2') : begin
        xlength = event.value 
        y2 = cinfo.adjust_roi.y1 + xlength
        if(y2 gt y2_full) then y2 = y2_full
        cinfo.adjust_roi.y2 = y2
    end



    else: print,'Event Name not found ',event_name
endcase




widget_control,winfo.cinfo.cubeview,Set_Uvalue = cinfo

end

;_______________________________________________________________________

;_______________________________________________________________________
;***********************************************************************
pro jwst_cv_adjust_roi,cinfo

window,3,/pixmap
wdelete,3
w = get_screen_size()
x_offset = w[0] - 350
if(x_offset lt 0) then x_offset = 50

if(XRegistered ('ajust')) then begin
    widget_control,cinfo.AdjustROI,/destroy
endif

cinfo.AdjustROI = widget_base(title = 'Adjust Region of Interest', col =1 , mbar = menuBar,$
                       group_leader = cinfo.CubeView,$
                       xsize = 350,ysize = 200,/column, xoffset = x_offset, yoffset = 200)


QuitMenu = widget_button(menuBar,value="Quit",font = cinfo.font2)
quitbutton = widget_button(quitmenu,value="Quit",event_pro='jwst_adjust_quit')

graphID_master = widget_base(cinfo.AdjustROI,row=1)
graphID1 = widget_base(graphID_master,col= 1)
;_______________________________________________________________________


;_______________________________________________________________________
; select wavelengths by clicking - selecttype = 1

titlelabel = widget_label(graphID1,value = ' X and Y Cube Pixel Limits of Region of Interest',/align_left,$
                         font=cinfo.font2)



if(cinfo.imagetype eq 0) then begin
    cinfo.adjust_roi.x1 = cinfo.view_cube.xstart
    cinfo.adjust_roi.y1 = cinfo.view_cube.ystart
    cinfo.adjust_roi.y2 = cinfo.view_cube.yend
    cinfo.adjust_roi.x2 =  cinfo.view_cube.xend
endif

if(cinfo.imagetype ge 1) then begin
    cinfo.adjust_roi.x1 = cinfo.view_image2d.xstart
    cinfo.adjust_roi.y1 = cinfo.view_image2d.ystart
    cinfo.adjust_roi.y2 = cinfo.view_image2d.yend
    cinfo.adjust_roi.x2 =  cinfo.view_image2d.xend
endif
    
xlength = cinfo.adjust_roi.x2 - cinfo.adjust_roi.x1 
ylength = cinfo.adjust_roi.y2 - cinfo.adjust_roi.y1 

xID = widget_base(graphID1,row=1)

cinfo.adjust_roi.x1ID = cw_field(xID,title="X minimum",font=cinfo.font3,$
                                 /float,/return_events,$
                                 xsize= 6,value =cinfo.adjust_roi.x1+1,$
                                 fieldfont = cinfo.font3,uvalue = 'x1')

cinfo.adjust_roi.x2ID = cw_field(xID,title=" + NX pixels",font=cinfo.font3,$
                                 /float,/return_events,$
                                 xsize= 6,value =xlength,$
                                 fieldfont = cinfo.font3,uvalue = 'x2')
xlabel = widget_label(graphID1,value = ' To get these exact #s choose an even # for NX pixels')
yID = widget_base(graphID1,row=1)

cinfo.adjust_roi.y1ID = cw_field(yID,title="Y minimum",font=cinfo.font3,$
                                 /float,/return_events,$
                                 xsize= 6,value =cinfo.adjust_roi.y1+1,$
                                 fieldfont = cinfo.font3,uvalue = 'y1')

cinfo.adjust_roi.y2ID = cw_field(yID,title="+ NY Pixels",font=cinfo.font3,$
                                 /float,/return_events,$
                                 xsize= 6,value =ylength,$
                                 fieldfont = cinfo.font3,uvalue = 'y2')
ylabel = widget_label(graphID1,value = ' To get these exact #s choose an even # for NY pixels')

done_box = widget_base(graphID1,/row)
cinfo.jwst_coadd.doneID = widget_button(done_box, value ='Done', uvalue= 'done',font=cinfo.font5)

adjust = {cinfo                  : cinfo}

Widget_Control,cinfo.AdjustROI,Set_UValue=adjust
widget_control,cinfo.AdjustROI,/realize

XManager,'adjust',cinfo.AdjustROI,/No_Block,event_handler = 'jwst_adjust_event'
Widget_Control,cinfo.CubeView,Set_UValue=cinfo

end
