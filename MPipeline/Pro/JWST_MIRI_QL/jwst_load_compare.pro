;***********************************************************************
pro jwst_load_compare_quit,event
widget_control,event.top, Get_UValue = tinfo
widget_control,tinfo.info.jwst_QuickLook,Get_UValue=info
widget_control,info.jwst_load2Display,/destroy
end
;_______________________________________________________________________
pro jwst_load_compare_cleanup,topbaseID

; get all defined structures so they are deleted when the program
; terminates
widget_control,topbaseID,get_uvalue=ginfo
widget_control,ginfo.info.jwst_QuickLook,get_uvalue = info
widget_control,info.jwst_load2Display,/destroy
end

;***********************************************************************
; the event manager for the load_compare.pro (comparing widget)
pro jwst_load_compare_event,event
Widget_Control,event.id,Get_uValue=event_name
widget_control,event.top, Get_UValue = ginfo
widget_control,ginfo.info.jwst_QuickLook,Get_Uvalue = info

if (widget_info(event.id,/TLB_SIZE_EVENTS) eq 1 ) then begin
    info.jwst_compare_load.xwindowsize = event.x
    info.jwst_compare_load.ywindowsize = event.y
    info.jwst_compare_load.uwindowsize = 1
    widget_control,event.top,set_uvalue = ginfo
    widget_control,ginfo.info.jwst_Quicklook,set_uvalue = info
    jwst_load_compare,info
    return
endif
;_______________________________________________________________________
case 1 of
; Image Button
    (strmid(event_name,0,5) EQ 'image') : begin
        imageno = strmid(event_name,5,1)
        image_file = dialog_pickfile(/read,$
                                get_path=realpath,Path=info.jwst_control.dir,$
                                filter = '*.fits')
        if(image_file eq '')then begin
            print,' No file selected, can not read in data'
            status = 1
            return
        endif
        if (image_file NE '') then begin
            if(imageno eq 1) then ginfo.filename1 = image_file
            if(imageno eq 2) then ginfo.filename2 = image_file

        endif
        len = strlen(realpath)
        realpath = strmid(realpath,0,len-1) ; just to be consistent 
        info.jwst_control.dir = realpath
        widget_control,ginfo.flabelID[imageno-1],set_value = image_file
        widget_control,event.top,Set_Uvalue = ginfo
        widget_control,ginfo.info.jwst_QuickLook,Set_Uvalue = info
    end
;_______________________________________________________________________

; Done selecting the images, do some checks that the data is of the
; same type, then read in the data

    (strmid(event_name,0,4) EQ 'load') : begin
        status = 0
        
        filename1 = ginfo.filename1
        filename2 = ginfo.filename2
        
        jwst_read_data_type,filename1,type1
        jwst_read_data_type,filename2,type2
        print,'type of data',type1, type2
        if(type1 ne type2) then begin
            mess1 = 'The files are not the same type. They both have to be either raw science data, rate or cal file' 
            mess2 = 'Hit re-load button  and choose the same type of data' 
            ok = dialog_message(mess1 + string(10B) + mess2,/Information)
            return
        endif

       if(type1 eq 0 or type1 eq 1 or type1 eq 3) then begin
       endif else begin
            mess1 = " The files do not contain the correct data, they must be either "
            mess2 = "a) raw science data or b) rate file c) cal file.   Select the files again"
            ok = dialog_message(mess1 + string(10B) + mess2,/Information)
            return
        endelse

       if(type1 eq 0) then begin 

            info.jwst_compare_image[0].filename  = filename1
            info.jwst_compare_image[1].filename  = filename2

            info.jwst_compare_image[0].jintegration = 0
            info.jwst_compare_image[1].jintegration = 0

            info.jwst_compare_image[0].iramp = 0
            info.jwst_compare_image[1].iramp = 0
            
            widget_control,event.top,Set_Uvalue = ginfo
            widget_control,ginfo.info.jwst_QuickLook,Set_Uvalue = info

            jwst_mql_compare_display,info
        endif

        if(type1 eq 1 or type1 eq 6 or type1 eq 7) then begin 

            info.jwst_rcompare_image[0].filename  = filename1
            info.jwst_rcompare_image[1].filename  = filename2

            info.jwst_rcompare_image[0].jintegration = 0
            info.jwst_rcompare_image[1].jintegration = 0

            widget_control,event.top,Set_Uvalue = ginfo
            widget_control,ginfo.info.jwst_QuickLook,Set_Uvalue = info

            jwst_msql_compare_display,info

            print,' Going to load comparing Slope data'
        endif
        
    end
;_______________________________________________________________________

else: print," Event name not found",event_name
endcase

end

;_______________________________________________________________________
pro jwst_load_compare,info
window,1,/pixmap
wdelete,1
if(XRegistered ('jwst_loadcompare')) then begin
    widget_control,info.jwst_load2Display,/destroy
endif

;*********
;Setup main panel
;*********

; widget window parameters
xwidget_size = 1400
ywidget_size = 300

xsize_scroll = 600
ysize_scroll = 200

if(info.jwst_compare_load.uwindowsize eq 1) then begin ; user has set window size 
    xsize_scroll = info.jwst_compare_load.xwindowsize
    ysize_scroll = info.jwst_compare_load.ywindowsize
endif
if(info.jwst_control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.jwst_control.x_scroll_window
if(info.jwst_control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.jwst_control.y_scroll_window

if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10


jwst_load2Display = widget_base(title="Select Files to compare images" + info.jwst_version,$
                           col = 1,mbar = menuBar,group_leader = info.jwst_QuickLook,$
                           xsize =  xwidget_size,$
                           ysize=   ywidget_size,/scroll,$
                           x_scroll_size= xsize_scroll,$
                           y_scroll_size = ysize_scroll,/TLB_SIZE_EVENTS)


;********
; build the menubar
;********
QuitMenu = widget_button(menuBar,value="Quit",font = info.font2)
quitbutton = widget_button(quitmenu,value="Quit",event_pro='jwst_load_compare_quit')
;_______________________________________________________________________
;*********
; Draw Main Display Window
;*********

flabelID = lonarr(2)
filename1 = ' ' 
filename2  = ' ' 

labelID = widget_label(jwst_load2Display,value='Select Image 1',/align_left,font=info.font1)
r11_base = widget_base(jwst_load2Display,row=1)

jwst_loadimage = widget_button(r11_base,value=' Select Filename ',$
                                                font=info.font4,$
                                                uvalue = 'image1')
flabelID[0] = widget_label(r11_base,value='File name:   ',/align_center,font=info.font3,/dynamic_resize)
r12_base = widget_base(jwst_load2Display,row=1)
;_______________________________________________________________________

blankID = widget_label(jwst_load2Display,value='         ',/align_center,font=info.font3)
labelID = widget_label(jwst_load2Display,value='Select Image 2',/align_left,font=info.font1)
r21_base = widget_base(jwst_load2Display,row=1)

jwst_loadimage = widget_button(r21_base,value=' Select Filename ',$
                                                font=info.font4,$
                                                uvalue = 'image2')
flabelID[1] = widget_label(r21_base,value='File name:      ',/align_center,font=info.font3,/dynamic_resize)

r13_base = widget_base(jwst_load2Display,row=1)
jwst_loadimage = widget_button(r13_base,value=' Done Selecting options- jwst_load images ',$
                                                font=info.font3,$
                                                uvalue = 'load')

; create 2 new images to hold 2 raw images and a third for the
; difference image

info.jwst_load2Display = Jwst_Load2Display

jwst_load2 = {flabelID         : flabelID,$
              filename1         : filename1,$
              filename2         : filename2,$
              info             : info}	

Widget_Control,info.Jwst_Load2Display,Set_UValue=jwst_load2
widget_control,info.Jwst_Load2Display,/realize

XManager,'jwst_loadcompare',jwst_load2Display,/No_Block,cleanup='jwst_load_compare_cleanup',$
	event_handler='jwst_load_compare_event'
Widget_Control,info.jwst_QuickLook,Set_UValue=info
end
