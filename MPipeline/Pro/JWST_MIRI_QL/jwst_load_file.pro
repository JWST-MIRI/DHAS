;***********************************************************************
pro load_file_quit,event
widget_control,event.top, Get_UValue = tinfo
widget_control,tinfo.info.QuickLook,Get_UValue=info
widget_control,info.LoadFile,/destroy
end
;***********************************************************************



;***********************************************************************
;_______________________________________________________________________
;***********************************************************************
pro load_file_event,event

Widget_Control,event.id,Get_uValue=event_name
widget_control,event.top, Get_UValue = ginfo
widget_control,ginfo.info.QuickLook,Get_Uvalue = info


if (widget_info(event.id,/TLB_SIZE_EVENTS) eq 1 ) then begin
    info.loadfile.xwindowsize = event.x
    info.loadfile.ywindowsize = event.y
    info.loadfile.uwindowsize = 1
    widget_control,event.top,set_uvalue = ginfo
    widget_control,ginfo.info.Quicklook,set_uvalue = info
    load_file,info
    return
endif

    case 1 of
;_______________________________________________________________________

; change the display type: decimal, hex
;_______________________________________________________________________

    (strmid(event_name,0,6) EQ 'ignore') : begin
        
        
        info.data.raw_exist = 0

        header_setup,2,info
        header_setup_slope,info
        if(info.data.cal_exist eq 1) then header_setup_cal,info 
        msql_display_slope,info
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
        Widget_Control,info.QuickLook,Set_UValue=info
        widget_control,info.LoadFileInfo,/destroy

    end

    (strmid(event_name,0,6) EQ 'select') : begin
        image_file = dialog_pickfile(/read,$
                                 get_path=realpath,Path=info.control.dir,$
                                filter = '*.fits')
        info.control.filename_raw = image_file
        file_exist1 = file_test(info.control.filename_raw,/regular,/read)
        info.data.raw_exist = file_exist1


        status = 0
        reading_header,info,status,error_message

        if(status eq 1) then begin
            result = dialog_message(error_message,/error)
            return
        endif


        header_setup,2,info
        header_setup_slope,info
        if(info.data.cal_exist eq 1) then header_setup_cal,info 
        msql_display_slope,info
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
        Widget_Control,info.QuickLook,Set_UValue=info
        widget_control,info.LoadFileInfo,/destroy



    end
;_______________________________________________________________________

else: ;print," Event name not found ",event_name
endcase
end


;_______________________________________________________________________
; Load a raw file, this only occurs if displaying reduced data and
; the raw science file has a different prefix than the slope file,
; or the raw file does not exist. 

pro load_file,info
info.loadfile.status = 0

window,4,/pixmap
wdelete,4
if(XRegistered ('loadf')) then begin
    widget_control,info.LoadFileInfo,/destroy
endif

;_______________________________________________________________________
;*********
;Setup main panel
;*********

; widget window parameters
xwidget_size = 800
ywidget_size = 300

xsize_scroll = 500
ysize_scroll = 200


if(info.loadfile.uwindowsize eq 1) then begin
    xsize_scroll = info.loadfile.xwindowsize
    ysize_scroll = info.loadfile.ywindowsize
    
endif 
if(info.control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.control.x_scroll_window
if(info.control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.control.y_scroll_window

if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10


LoadFileInfo = widget_base(title=" Load File",$
                         col = 1,mbar = menuBar,group_leader = info.QuickLook,$
                        xsize = xwidget_size,ysize =ywidget_size,/base_align_right,$
                        /scroll,y_scroll_size= ysize_scroll,$
                        x_scroll_size= xsize_scroll,$
                        yoffset=100,/TLB_SIZE_EVENT)

;********
; build the menubar
;********
QuitMenu = widget_button(menuBar,value="Quit",font = info.font2)
quitbutton = widget_button(quitmenu,value="Quit",event_pro='load_file_quit')


file = strcompress(info.control.filename_raw,/remove_all)
info_label = widget_label (LoadFileInfo,$
                           value = " The default raw science file does not exist: " + file,$
                           /align_left,font=info.font5)

info_label = widget_label(LoadFileInfo,value = " Choose one of the following options : ",$
                          /align_left,font=info.font3)

ignore_label = widget_button(LoadFileInfo,uvalue = 'ignore',$
                             value = " Continue  and do not read in pixel frame values",$
                             /align_left,font = info.font3)
select_label = widget_button(LoadFileInfo,uvalue = 'select',value = "Select the correct file",$
                             /align_left,font=info.font3)

info.LoadFileInfo = LoadfileInfo

load = {info                  : info}	



Widget_Control,info.LoadfileInfo,Set_UValue=load
widget_control,info.LoadFileInfo,/realize

XManager,'loadf',info.LoadFileInfo,/No_Block,event_handler = 'load_file_event'

Widget_Control,info.QuickLook,Set_UValue=info

end


;_______________________________________________________________________
