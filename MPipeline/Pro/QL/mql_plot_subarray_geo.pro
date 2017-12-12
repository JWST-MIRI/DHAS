
;***********************************************************************
;_______________________________________________________________________
pro mql_plot_subarray_geo_quit,event
;_______________________________________________________________________
widget_control,event.top, Get_UValue = tinfo
widget_control,tinfo.info.QuickLook,Get_UValue=info
widget_control,info.subarrayGeo,/destroy
end


;***********************************************************************
;_______________________________________________________________________
pro mql_plot_subarray_event,event
;_______________________________________________________________________


Widget_Control,event.id,Get_uValue=event_name
widget_control,event.top, Get_UValue = ginfo
widget_control,ginfo.info.QuickLook,Get_Uvalue = info


    case 1 of
;_______________________________________________________________________
;oplot subarray locations

    (strmid(event_name,0,5) EQ 'oplot') : begin

        xmask1550 = fltarr(5)
        ymask1550 = fltarr(5)
        xmask1550 =[1,256,256,1,1]
        ymask1550 = [1,1,256,256,1]
        oplot,xmask1550,ymask1550, color = info.white,linestyle = 1
        xcenter = (xmask1550[0] + xmask1550[1])/2
        ycenter = (ymask1550[0] + ymask1550[2])/2
        xyouts,xcenter,ycenter,' Mask 1550',alignment = 0.5 
        
        xmask1140 = fltarr(5)
        ymask1140 = fltarr(5)
        xmask1140 =[1,256,256,1,1]
        ymask1140 = [229,229,484,484,229]
        oplot,xmask1140,ymask1140, color = info.blue,linestyle = 1
        xcenter = (xmask1140[0] + xmask1140[1])/2
        ycenter = (ymask1140[0] + ymask1140[2])/2
        xyouts,xcenter,ycenter,' Mask 1140' ,alignment = 0.5


        xmask1065 = fltarr(5)
        ymask1065 = fltarr(5)
        xmask1065 =[1,256,256,1,1]
        ymask1065 = [452,452,707,707,452]
        oplot,xmask1065,ymask1065, color = info.yellow,linestyle = 1
        xcenter = (xmask1065[0] + xmask1065[1])/2
        ycenter = (ymask1065[0] + ymask1065[2])/2
        xyouts,xcenter,ycenter,' Mask 1065' ,alignment = 0.5


        xmasklyot = fltarr(5)
        ymasklyot = fltarr(5)
        xmasklyot =[1,256,256,1,1]
        ymasklyot = [705,705,1024,1024,705]
        oplot,xmasklyot,ymasklyot, color = info.red,linestyle = 1

        xcenter = (xmasklyot[0] + xmasklyot[1])/2
        ycenter = (ymasklyot[0] + ymasklyot[2])/2
        xyouts,xcenter,ycenter,' Mask LYOT' ,alignment = 0.5

        xBS = fltarr(5)
        yBS = fltarr(5)
        xBS =[350,861,861,350,350]
        yBS = [1,1,512,512,1]
        oplot,xBS,yBS, color = info.white,linestyle = 1
        
        xcenter = (xBS[0] + xBS[1])/2
        ycenter = (yBS[0] + yBS[2])/2
        xyouts,xcenter,ycenter,' Bright Source' ,alignment = 0.5
    end
else: print," Event name not found",event_name
endcase
end
;***********************************************************************
;_______________________________________________________________________

pro mql_plot_subarray_geo,info
;_______________________________________________________________________

window,3,/pixmap
wdelete,3
if(XRegistered ('subarray')) then begin
    widget_control,info.SubarrayGeo,/destroy
endif
color6


;_______________________________________________________________________
;*********
;Setup main panel
;*********
xwidget_size = 530
ywidget_size = 530
xplotsize = 450
yplotsize = 450

SubarrayGeo = widget_base(title=" Subarry Geometry",$
                         col = 1,mbar = menuBar,group_leader = info.RawQuickLook,$
                           xsize = xwidget_size,ysize=ywidget_size)

;********
; build the menubar
;********
QuitMenu = widget_button(menuBar,value="Quit",font = info.font2)
quitbutton = widget_button(quitmenu,value="Quit",event_pro='mql_plot_subarray_geo_quit')

;_______________________________________________________________________
; 
;*********
graphID1 = widget_base(subarrayGeo,row=1)
graphID2 = widget_base(subarrayGeo,row=1)

infoID1 = widget_base(graphID1,col=1)
infoID2 = widget_base(graphID1,col=1)
sxsize = strcompress(string(info.data.image_xsize),/remove_all)
sysize = strcompress(string(info.data.image_ysize),/remove_all)
scolstart = strcompress(string(info.data.colstart),/remove_all)
srowstart = strcompress(string(info.data.rowstart),/remove_all)
ssize = 'Subarray size: ' + sxsize +  ' X ' + sysize

stitle = Widget_label(infoID1,value=ssize,/align_center,font=info.font3)
;subbutton = widget_button(infoID2,value= ' Overplot All Subarray Locations',uvalue = 'oplot')


sl = ' Lower Left Corner location (colstart,rowstart): '+ scolstart + ','+srowstart 
sloc = widget_label(infoID1,value= sl,font = info.font3,/align_Center)




;_______________________________________________________________________
graphID = widget_draw(graphID2,$
                      xsize =xplotsize, ysize =yplotsize,$
                      retain=info.retn)


info.SubarrayGeo = SubarrayGeo
widget_control,info.SubarrayGeo,/realize
XManager,'subarray',SubarrayGeo,/No_Block,event_handler='mql_plot_subarray_event'


widget_control,graphID,get_value=tdraw_id
draw_window_id = tdraw_id



xplot = fltarr(1) & yplot = fltarr(1)
plot,xplot,yplot,xrange=[1,1024],yrange=[1,1024],ystyle=1,xstyle =1,/nodata,$
     xtitle = 'Pixels',ytitle = 'Pixels'


xsubarray = fltarr(5)
ysubarray = fltarr(5)
xsubarray[0] = info.data.colstart
xsubarray[1] = info.data.colstart + info.data.image_xsize
xsubarray[2] = xsubarray[1]
xsubarray[3] = xsubarray[0]
xsubarray[4] = xsubarray[0]

ysubarray[0] = info.data.rowstart
ysubarray[1] = ysubarray[0]
ysubarray[2] = info.data.rowstart + info.data.image_ysize
ysubarray[3] = ysubarray[2]
ysubarray[4] = ysubarray[0]
oplot,xsubarray,ysubarray, color = info.green




Sinfo = {         info                  : info}	



Widget_Control,info.SubarrayGeo,Set_UValue=sinfo
Widget_Control,info.QuickLook,Set_UValue=info

Widget_Control,info.QuickLook,Set_UValue=info
end



