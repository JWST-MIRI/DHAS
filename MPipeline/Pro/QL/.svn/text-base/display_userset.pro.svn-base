;***********************************************************************
pro userset_quit,event
widget_control,event.top, Get_UValue = tinfo
widget_control,tinfo.info.QuickLook,Get_UValue=info
widget_control,info.UserSetInfo,/destroy
end
;***********************************************************************



;***********************************************************************
;_______________________________________________________________________
;***********************************************************************
pro userset_event,event

Widget_Control,event.id,Get_uValue=event_name
widget_control,event.top, Get_UValue = ginfo
widget_control,ginfo.info.QuickLook,Get_UValue=info

limitx = info.data.image_xsize
limity = info.data.image_ysize
low_limit = 1


    case 1 of
;_______________________________________________________________________


    (strmid(event_name,0,5) EQ 'clear') : begin

        for i = 0,4 do begin
            ginfo.x[i] = 0
            ginfo.y[i] = 0
            widget_control,ginfo.x_label[i],set_value = 0
            widget_control,ginfo.y_label[i],set_value = 0
            widget_control,ginfo.ch_label[i],set_value = 'Channel'
            widget_control,ginfo.ref_button[i],set_button = 0
        endfor
        widget_control,event.top,Set_Uvalue = ginfo
        widget_control,ginfo.info.QuickLook,set_uvalue = info
    end

    (strmid(event_name,0,1) EQ 'x') : begin
        num = fix(strmid(event_name,1,1))-1

        if(event.value gt limitx or event.value lt low_limit) then begin
            if(event.value gt limitx) then ginfo.x[num] = limitx
            if(event.value lt low_limit) then ginfo.x[num] = low_limit
        
        endif else begin 
            ginfo.x[num] = event.value
        endelse

        widget_control,ginfo.x_label[num],set_value = ginfo.x[num]

        widget_control,event.top,Set_Uvalue = ginfo
        widget_control,ginfo.info.QuickLook,set_uvalue = info
    end

    (strmid(event_name,0,1) EQ 'y') : begin
        num = fix(strmid(event_name,1,1))-1

        if(event.value gt limity or event.value lt low_limit) then begin
            if(event.value gt limity) then ginfo.y[num] = limity
            if(event.value lt low_limit) then ginfo.y[num] = low_limit
        endif else begin 
            ginfo.y[num] = event.value
        endelse
        
        widget_control,ginfo.y_label[num],set_value = ginfo.y[num]

        widget_control,event.top,Set_Uvalue = ginfo
        widget_control,ginfo.info.QuickLook,set_uvalue = info
    end

    (strmid(event_name,0,3) EQ 'ref') : begin
        num = fix(strmid(event_name,3,1))-1

        ref = ginfo.ref_value[num]
        if (ref eq 0) then ginfo.ref_value[num] = 1
        if (ref eq 1) then ginfo.ref_value[num] = 0

        widget_control,event.top,Set_Uvalue = ginfo
        widget_control,ginfo.info.QuickLook,set_uvalue = info
    end


    (strmid(event_name,0,3) EQ 'set') : begin
        num_found = 0

        chnum  = 0
        ch = intarr(5)
        xvalue = intarr(5)
        yvalue = intarr(5)
        rvalue = intarr(5)

        for i = 0,4 do begin
            widget_control,ginfo.x_label[i],get_value = xtemp
            widget_control,ginfo.y_label[i],get_value = ytemp
            
            if(xtemp lt 1) then xtemp = 1
            if(ytemp lt 1) then ytemp = 1

            if(xtemp gt limitx) then xtemp = limitx
            if(ytemp gt limity) then ytemp = limity

            widget_control,ginfo.x_label[i],set_value = xtemp
            widget_control,ginfo.y_label[i],set_value = ytemp

            ginfo.x[i] = xtemp
            ginfo.y[i] = ytemp


            if(ginfo.ref_value[i] eq 0) then get_channel,ginfo.x[i],chnum
            if(ginfo.ref_value[i] eq 1) then chnum = 5


            xvalue[num_found] = ginfo.x[i]
            yvalue[num_found] = ginfo.y[i]
            ch[num_found] = chnum
            rvalue[num_found] = ginfo.ref_value[i]
            sch = strcompress(string(ch[num_found]),/remove_all)
            widget_control,ginfo.ch_label[i],set_value = 'Channel ' + sch
            num_found = num_found + 1
        endfor

        if(num_found eq 0) then begin
            result = dialog_message(" You must set the X and Y values to valid numbers first",/error )
            return
        endif
        



        xdata = (*info.pltrack.px)
        ydata = (*info.pltrack.py)
        ch = (*info.pltrack.pch)
        ref = (*info.pltrack.pref)

            


        xdata[3,0:num_found-1] = xvalue[0:num_found-1]  
        ydata[3,0:num_found-1] = yvalue[0:num_found-1]
        ch[3,0:num_found-1] = ch[0:num_found-1]
        ref[3,0:num_found-1] = rvalue[0:num_found-1]

        info.pltrack.num_group[3] = num_found
        if ptr_valid (info.pltrack.px) then ptr_free,info.pltrack.px
        info.pltrack.px = ptr_new(xdata)
        
        if ptr_valid (info.pltrack.py) then ptr_free,info.pltrack.py
        info.pltrack.py= ptr_new(ydata)

        if ptr_valid (info.pltrack.pch) then ptr_free,info.pltrack.pch
        info.pltrack.pch = ptr_new(ch)

        if ptr_valid (info.pltrack.pref) then ptr_free,info.pltrack.pref
        info.pltrack.pref = ptr_new(ref)

            

        xdata = 0               ; free memory    
        xvalue = 0
        ydata = 0               ; free memory    
        yvalue = 0
        chnew = 0               ; free memory    
        ch= 0
        ref = 0               ; free memory    
        rvalue= 0


        info.pl.group = 3
        info.pl.set = 1
        get_pltracking,info.pl.group,info
            
        if(info.pl.slope_exists) then begin 
            get_pltracking_slope,info.pl.group, info
            for k = 0, 3 do begin
                mpl_calculate_ramp,k,info
            endfor
        endif

        if(info.control.file_refcorrection_exist eq 1) then $
          get_pltracking_refcorrected,3,info
        
        if(info.control.file_ids_exist eq 1) then $
          get_pltracking_ids,3,info
        
        if(info.control.file_lc_exist eq 1) then $
          get_pltracking_lc,3,info
        
        mpl_update_plot,info

                
        widget_control,event.top,Set_Uvalue = ginfo
        widget_control,ginfo.info.QuickLook,set_uvalue = info

        widget_control,info.usersetInfo,/destroy
    end
;_______________________________________________________________________


else: ;print," Event name not found ",event_name
endcase


end


;_______________________________________________________________________
; The parameters for this widget are contained in the image_pixel
; structure, rather than a local imbedded structure because
; mql_event.pro also calls to update the pixel info widget

pro display_userset,type,group,info


window,4,/pixmap
wdelete,4
if(XRegistered ('userset')) then begin
    widget_control,info.usersetInfo,/destroy
endif

;_______________________________________________________________________
;*********
;Setup main panel
;*********

if(type eq 0) then info.fl.set = 0 
if(type eq 1) then info.pl.set = 0 

; widget window parameters
xwidget_size = 625
ywidget_size = 450

xsize_scroll = 625
ysize_scroll = 450


if(info.control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.control.x_scroll_window
if(info.control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.control.y_scroll_window

if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10


UserSetInfo = widget_base(title=" Select Pixels ",$
                          col = 1,mbar = menuBar,group_leader = info.quicklook,$
                          xsize = xwidget_size,ysize =ywidget_size,/base_align_right,$
                          /scroll,y_scroll_size= ysize_scroll,$
                          x_scroll_size= xsize_scroll,$
                          yoffset=100,/TLB_SIZE_EVENT)

;********
; build the menubar
;********
QuitMenu = widget_button(menuBar,value="Quit",font = info.font2)
quitbutton = widget_button(quitmenu,value="Quit",event_pro='userset_quit')




xdata = (*info.pltrack.px)
ydata = (*info.pltrack.py)
chdata = (*info.pltrack.pch)

x = intarr(5)
y = intarr(5)
ch = intarr(5)
ref_value = intarr(5)
x[*] = xdata[group,*]
y[*] = ydata[group,*]
ch[*] = chdata[group,*]




sinfo = "After all the desired pixels have been selected, Hit the 'Set Pixel Value' buttton"
info_label = widget_label(UserSetInfo,value=sinfo,/align_left,font= info.font5)
info_label = widget_label(usersetInfo,value = ' ')

sxend = strcompress(string(info.data.image_xsize),/remove_all)
syend = strcompress(string(info.data.image_ysize),/remove_all)

vlabel = ' Valid X Pixel Range is from 1 to ' + sxend + $
         ' Valid Y Pixel Range is from 1 to ' +syend
info_label = widget_label(UserSetInfo,value =vlabel ,/align_left,font=info.font5) 


clear_button = widget_button(UserSetInfo,value = 'Clear All Pixel Values',uvalue = 'clear',$
                             /align_center)

x_label = lonarr(5)
y_label = lonarr(5)
ch_label = lonarr(5)
ref_button = lonarr(5)
base1 = widget_base(UserSetInfo,row=1,/align_left)
x_label[0] = cw_field(base1,$
                   title="Pixel A:  X Pixel Value ",font=info.font5, $
                   uvalue="x1",/integer,/return_events, $
                   value=x[0],xsize=4,$
                   fieldfont=info.font3)

y_label[0] = cw_field(base1,$
                   title=" Y Pixel Value ",font=info.font5, $
                   uvalue="y1",/integer,/return_events, $
                   value=y[0],xsize=4,$
                   fieldfont=info.font3)



sch = strcompress(string(ch[0]),/remove_all)
ch_label[0] = widget_label(base1,value = ' Channel ' + sch,font=info.font3)

ref_value[0] = 0
if(ch[0] eq 5 ) then ref_value[0] = 1
onBase = Widget_base(base1,/row,/nonexclusive)
ref_button[0] = Widget_button(onBase, Value = 'Associated Reference Output',uvalue = 'ref1')
widget_control, ref_button[0],Set_Button =ref_value[0] 



base1 = widget_base(UserSetInfo,row=1,/align_left)
x_label[1] = cw_field(base1,$
                   title="Pixel B:  X Pixel Value ",font=info.font5, $
                   uvalue="x2",/integer,/return_events, $
                   value=x[1],xsize=4,$
                   fieldfont=info.font3)

y_label[1] = cw_field(base1,$
                   title=" Y Pixel Value ",font=info.font5, $
                   uvalue="y2",/integer,/return_events, $
                   value=y[1],xsize=4,$
                   fieldfont=info.font3)

sch = strcompress(string(ch[1]),/remove_all)
ch_label[1] = widget_label(base1,value = ' Channel ' + sch,font=info.font3)
ref_value[1] = 0
if(ch[1] eq 5 ) then ref_value[1] = 1
onBase = Widget_base(base1,/row,/nonexclusive)
ref_button[1] = Widget_button(onBase, Value = 'Associated Reference Output',uvalue = 'ref2')
widget_control, ref_button[1],Set_Button =ref_value[1]



base1 = widget_base(UserSetInfo,row=1,/align_left)
x_label[2] = cw_field(base1,$
                   title="Pixel C:  X Pixel Value ",font=info.font5, $
                   uvalue="x3",/integer,/return_events, $
                   value=x[2],xsize=4,$
                   fieldfont=info.font3)

y_label[2] = cw_field(base1,$
                   title=" Y Pixel Value ",font=info.font5, $
                   uvalue="y3",/integer,/return_events, $
                   value=y[2],xsize=4,$
                   fieldfont=info.font3)

sch = strcompress(string(ch[2]),/remove_all)
ch_label[2] = widget_label(base1,value = ' Channel ' + sch,font=info.font3)
ref_value[2] = 0
if(ch[2] eq 5 ) then ref_value[2] = 1
onBase = Widget_base(base1,/row,/nonexclusive)
ref_button[2] = Widget_button(onBase, Value = 'Associated Reference Output',uvalue = 'ref3')
widget_control, ref_button[2],Set_Button =ref_value[2] 



base1 = widget_base(UserSetInfo,row=1,/align_left)
x_label[3] = cw_field(base1,$
                   title="Pixel D:  X Pixel Value ",font=info.font5, $
                   uvalue="x4",/integer,/return_events, $
                   value=x[3],xsize=4,$
                   fieldfont=info.font3)

y_label[3] = cw_field(base1,$
                   title=" Y Pixel Value ",font=info.font5, $
                   uvalue="y4",/integer,/return_events, $
                   value=y[3],xsize=4,$
                   fieldfont=info.font3)


sch = strcompress(string(ch[3]),/remove_all)
ch_label[3] = widget_label(base1,value = ' Channel ' + sch,font=info.font3)
ref_value[3] = 0
if(ch[3] eq 5 ) then ref_value[3] = 1
onBase = Widget_base(base1,/row,/nonexclusive)
ref_button[3] = Widget_button(onBase, Value = 'Associated Reference Output',uvalue = 'ref4')
widget_control, ref_button[3],Set_Button =ref_value[3] 



base1 = widget_base(UserSetInfo,row=1,/align_left)
x_label[4] = cw_field(base1,$
                   title="Pixel E:  X Pixel Value ",font=info.font5, $
                   uvalue="x5",/integer,/return_events, $
                   value=x[4],xsize=4,$
                   fieldfont=info.font3)

y_label[4] = cw_field(base1,$
                   title=" Y Pixel Value ",font=info.font5, $
                   uvalue="y5",/integer,/return_events, $
                   value=y[4],xsize=4,$
                   fieldfont=info.font3)


sch = strcompress(string(ch[4]),/remove_all)
ch_label[4] = widget_label(base1,value = ' Channel ' + sch,font=info.font3)
ref_value[4] = 0
if(ch[4] eq 5 ) then ref_value[4] = 1
onBase = Widget_base(base1,/row,/nonexclusive)
ref_button[4] = Widget_button(onBase, Value = 'Associated Reference Output',uvalue = 'ref5')
widget_control, ref_button[4],Set_Button =ref_value[4] 


get_button = widget_button(UserSetInfo,value = ' Set Pixel Values ',uvalue='set',/align_center)

info.UserSetInfo = UserSetinfo

userset = {x              : x,$
           y              : y,$
           x_label        : x_label,$
           y_label        : y_label,$
           ch_label       : ch_label,$
           ref_button     : ref_button,$
           ref_value      : ref_value,$
           type           : type,$
           info           : info}	



Widget_Control,info.UserSetInfo,Set_UValue=userset
widget_control,info.UserSetInfo,/realize

XManager,'userset',UserSetinfo,/No_Block,event_handler = 'userset_event'

Widget_Control,info.QuickLook,Set_UValue=info

end
