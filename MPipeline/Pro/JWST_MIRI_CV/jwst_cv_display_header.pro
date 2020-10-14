
;***********************************************************************
pro jwst_cv_display_header_done,event
 Widget_Control, event.top, /Destroy
end

;***********************************************************************
; Set up the structure to display a cube  header
; Primary header
; Science Header
;***********************************************************************
pro jwst_cv_header_setup,cinfo

if (ptr_valid ( (*cinfo.viewhead)[0] )) then   begin
   for ii = 0,1 do begin
      wname = 'cv_viewhead' + strtrim(string(ii),2)
      hptr = (*cinfo.viewhead)[ii]
      if XRegistered(wname) then begin
         widget_control,(*hptr).viewwin,/destroy
      endif
   endfor
   ptr_free,cinfo.viewhead
endif


cinfo.viewhead = ptr_new()
for i = 0,1 do begin 
    newhdr = ptr_new({vheadi})
    (*newhdr).viewtxt = 0
    (*newhdr).viewwin = 0
    if(i eq 0) then begin
        temphdr = newhdr
    endif else begin
        temphdr = [*cinfo.viewhead,newhdr]
        ptr_free,cinfo.viewhead
    endelse
    cinfo.viewhead = ptr_new(temphdr)
    temphdr = 0
endfor


; load Primary header 
fits_open,cinfo.cv_control.filename_cube,fcb
fits_read,fcb,cube,header,/header_only

if ptr_valid ((*(*cinfo.viewhead)[0]).phead) then ptr_free,$
  (*(*cinfo.viewhead)[0]).phead
(*(*cinfo.viewhead)[0]).phead= ptr_new(header)
header = 0 

; load Sci header 
fits_open,cinfo.cv_control.filename_cube,fcb
fits_read,fcb,cube,header,/header_only,exten_no = 1

if ptr_valid ((*(*cinfo.viewhead)[1]).phead) then ptr_free,$
  (*(*cinfo.viewhead)[1]).phead
(*(*cinfo.viewhead)[1]).phead= ptr_new(header)
header = 0 

fits_close,fcb

widget_control,cinfo.CubeView,Set_Uvalue = cinfo
end


;***********************************************************************
; the event manager for the jwst_cv_display_header.pro 
pro jwst_cv_display_header_event,event

Widget_Control, event.top, Get_UValue = vhinfo
  theheader = vhinfo.hdr
  nlines = vhinfo.height

  Case event.id of

  vhinfo.findkeyfield: begin
    Widget_Control, vhinfo.findkeyfield, Get_Value=thiskey
    thiskey = strtrim(strupcase(thiskey[0]),2)
    num = n_elements(theheader)
    if num gt 0 then begin
      whereitis = where(strpos(theheader[0:num-1], thiskey) ne -1, count)
      if count lt 1 then begin
        str = 'Cannot find keyword ' + thiskey
        stat = Widget_Message(str)
      endif else begin
        loc = whereitis[0] + nlines-1
        os = Widget_Info(vhinfo.wheader, Text_XY_To_offset=[0,loc])
        Widget_Control, vhinfo.wheader, Set_Text_Select=[os,80]
        os = Widget_Info(vhinfo.wheader, Text_XY_To_offset=[0,whereitis[0]])
        Widget_Control, vhinfo.wheader, Set_Text_SELECT=[os,80]
        Widget_Control, vhinfo.wheader, Set_Value=theheader[whereitis[0]], $
                 /Use_Text_Select, /No_Newline
       Widget_Control, vhinfo.wheader, /Input_Focus
      endelse
    endif
  end

vhinfo.applybutton: begin
    Widget_Control, vhinfo.findkeyfield, Get_Value=thiskey
    thiskey = strupcase(thiskey[0])
    thiskey = strtrim(strupcase(thiskey[0]),2)
    num = n_elements(theheader)
    if num gt 0 then begin
      whereitis = where(strpos(theheader[0:num-1], thiskey) ne -1, count)
      if count lt 1 then begin
        str = 'Cannot find keyword ' + thiskey
        stat = Widget_Message(str)
      endif else begin
        loc = whereitis[0] + nlines-1
        os = Widget_Info(vhinfo.wheader, Text_XY_To_offset=[0,loc])
        Widget_Control, vhinfo.wheader, Set_Text_Select=[os,80]
        os = Widget_Info(vhinfo.wheader, Text_XY_To_offset=[0,whereitis[0]])
        Widget_Control, vhinfo.wheader, Set_Text_SELECT=[os,80]
        Widget_Control, vhinfo.wheader, Set_Value=theheader[whereitis[0]], $
                 /Use_Text_Select, /No_Newline
       Widget_Control, vhinfo.wheader, /Input_Focus
      endelse
    endif
  end

  vhinfo.wheader: begin
   z=1  ; no op
  end

endcase
end

;_______________________________________________________________________

pro jwst_cv_display_header,cinfo,ii


hptr = (*cinfo.viewhead)[ii]
hdr = [*(*hptr).phead]

wname = 'cv_viewhead' + strtrim(string(ii),2)
if XRegistered(wname) then begin
    widget_control,(*hptr).viewwin,/destroy
endif

; Pop up a widget to show the reference image header and allow
; the user to scroll through it.

height = cinfo.viewhdrysize

thename = cinfo.cv_control.filename_cube
width = 90

title = 'CV Header for '+thename
xwidget_size = 800
ywidget_size = 800
xsize_scroll = 600
ysize_scroll = 600


vhWindow = Widget_Base(group_leader=cinfo.CubeView, $
                       Title = title, /Base_Align_Left, /Column,$
                       xsize = xwidget_size,$
                       ysize = ywidget_size,/scroll,$
                       x_scroll_size= xsize_scroll,$
                       y_scroll_size = ysize_scroll,/align_right)

headerbase = Widget_Base(vhWindow, /Row)
findkeyfield = CW_Field(headerbase, value=' ', row=1, return_events=1, $
                        title='Find Keyword:', xsize=11)
applybutton = Widget_Button(headerbase, uvalue='apply', Value='Search')
donebutton = Widget_Button(headerbase, uvalue='exit', Value='Done', $
                           Event_Pro = 'cv_display_header_done')

if(ii gt 0) then begin
      ss = "  Science Header " 
      intnum  = widget_label(headerbase,value = ss)
   endif
wheader = Widget_Text(vhWindow, xsize=width, ysize=height, value=hdr, $
                      /scroll, /all_events)

(*hptr).viewtxt = wheader
(*hptr).viewwin = vhWindow


vhinfo = { $
         wHeader      :  wHeader,     $
         findkeyfield : findkeyfield, $
         applybutton  : applybutton,  $
         hdr          : hdr,          $
         height       : height,       $
         cinfo         : cinfo          $
         }

Widget_Control, vhWindow, Set_UValue=vhinfo
Widget_Control, vhWindow, /Realize

XManager, wname, vhWindow, /No_Block, $
          Event_Handler = "jwst_cv_display_header_event"

end
