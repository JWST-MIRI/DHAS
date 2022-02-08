pro jwst_dqflags_quit,event
  widget_control,event.top, Get_UValue = tinfo
widget_control,tinfo.info.jwst_QuickLook,Get_UValue=info
widget_control,info.jwst_DQDisplay,/destroy
end


pro jwst_dqflags_event,event

  Widget_Control,event.id,Get_uValue=event_name
  widget_control,event.top, Get_UValue = ginfo
  widget_control,ginfo.info.jwst_QuickLook,Get_Uvalue = info

  if (widget_info(event.id,/TLB_SIZE_EVENTS) eq 1 ) then begin
     info.jwst_dqflag.xwindowsize = event.x
     info.jwst_dqflag.ywindowsize = event.y
     info.jwst_dqflag.uwindowsize = 1
     widget_control,event.top,set_uvalue = ginfo
     widget_control,ginfo.info.jwst_Quicklook,set_uvalue = info
     jwst_dqflags,info
    return
 endif
end


pro jwst_dqflags_decode,dq,ndq,dqtype
  ndq = 0
  dqtype = intarr(32)
  dqtype[*] = -1 ;set to -1 not found
  for i = 0, 31 do begin
     value = long64(2.0 ^i)

     test = dq and value
     if(test ne 0) then begin
        dqtype[i] = i
        ndq = ndq +1
     endif
  endfor
end
  
pro jwst_dqflags,info
window,1,/pixmap
wdelete,1
if(XRegistered ('jwst_dqinfo')) then begin
    widget_control,info.jwst_DQDisplay,/destroy
endif

;*********
;Setup main panel
;*********

; widget window parameters
xwidget_size = 500
ywidget_size = 800

xsize_scroll = 500
ysize_scroll = 800

if(info.jwst_dqflag.uwindowsize eq 1) then begin ; user has set window size 
    xsize_scroll = info.jwst_dqflag.xwindowsize
    ysize_scroll = info.jwst_dqflag.ywindowsize
 endif

if(info.jwst_control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.jwst_control.x_scroll_window
if(info.jwst_control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.jwst_control.y_scroll_window

if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10

jwst_DQDisplay = widget_base(title="Investigate DQ flags" + info.jwst_version,$
                             col = 1,mbar = menuBar,group_leader = info.jwst_QuickLook,$
                             xsize =  xwidget_size,$
                             ysize=   ywidget_size,/scroll,$
                             x_scroll_size= xsize_scroll,$
                             y_scroll_size = ysize_scroll,/TLB_SIZE_EVENTS)
;********
; build the menubar
;********
QuitMenu = widget_button(menuBar,value="Quit",font = info.font2)
quitbutton = widget_button(quitmenu,value="Quit",event_pro='jwst_dqflags_quit')


master1 = widget_base(jwst_DQDisplay,row=1,/align_left)
infoID1 = widget_base(master1,col=1,/align_left)
infoID2 = widget_base(master1,col=1,/align_left)
for i = 0, 31 do begin
   if(info.jwst_dqflag.type[i] ne -1) then begin 
      dq = 'DQ: ' + strcompress(string(info.jwst_dqflag.type[i]),/remove_all) +  ' = ' + info.jwst_dqflag.type_name[i]; + string(10b)
      label = widget_label(infoID1, value = dq,/align_left)
   endif
endfor


line1ID = widget_base(infoID2,row=1,/align_left)
line2ID = widget_base(infoID2,row=1,/align_left)
line3ID = widget_base(infoID2,row=1,/align_left)
line4ID = widget_base(infoID2,col=1,/align_left)
; Column 2 info on pixel
ilabel = widget_label(line1ID, value = 'For Pixel:',/align_left)

sx = 'x = '+ strcompress(string(info.jwst_dqflag.x),/remove_all)
sy = 'y = '+ strcompress(string(info.jwst_dqflag.y),/remove_all)
sdq = 'DQ = '+ strcompress(string(info.jwst_dqflag.dq),/remove_all) 

xlabel = widget_label(line2ID,value = sx,/align_left)
ylabel = widget_label(line2ID,value = sy,/align_left)
dqlabel = widget_label(line2ID,value = sdq,/align_left)

dqtype = intarr(32)

jwst_dqflags_decode,info.jwst_dqflag.dq,ndq,dqtype

ilabel = widget_label(line3ID, value = 'Pixel has the following DQW flags set :',/align_left)
for i = 0, 31 do begin
   if(dqtype[i] ne -1) then begin 
      dq = 'DQ : ' + strcompress(string(info.jwst_dqflag.type[i]),/remove_all) +  ' = ' + info.jwst_dqflag.type_name[i]; + string(10b)
      label = widget_label(line4ID, value = dq,/align_left)
   endif
endfor

longline = '                                                                                                                        '
longtag = widget_label(jwst_DQDisplay,value = longline)
info.jwst_DQDisplay  = jwst_DQDisplay

Widget_control,info.jwst_DQDisplay,/Realize

XManager,'jwst_dqinfo',info.jwst_DQDisplay,/No_Block,event_handler='jwst_dqflags_event'
Widget_Control,info.jwst_QuickLook,Set_UValue=info
cinfo = {         info            : info}

Widget_Control,info.jwst_DQDisplay,Set_UValue=cinfo
Widget_Control,info.jwst_QuickLook,Set_UValue=info


end
