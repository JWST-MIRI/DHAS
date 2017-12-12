
;***********************************************************************
pro display_header_done,event
 Widget_Control, event.top, /Destroy
end

;***********************************************************************
;_______________________________________________________________________

; Set up the structure to display a header
; If type = 0, the only make it large enough to hold the a single raw
; science frame
; If type = 1, then make it large enough to hold the slope headers 
;               (as many headers as integrations)
; If type = 2, then make it large enough to hold the slope and cal  headers 
;               (as many headers as integrations)
; Also read in the science header
;***********************************************************************
pro header_setup,type,info ; default type = 0 (only set up for Primary header
                           ; raw science image



intnum = 0
framenum = 0
shead = 0
rhead = 1
chead = 0
if(type eq 1) then begin
    intnum = info.data.nints
    framenum = info.data.nramps

    shead = 1
endif

if(type eq 2) then begin
    intnum = info.data.nints
    framenum = info.data.nramps

    shead = 1
    chead = 1
endif

num = intnum*( shead  + chead) + rhead
;print,'number of headers',num,info.data.nints,intnum,framenum

if (ptr_valid ( (*info.viewhead)[0] )) then   begin
    old_num = (*(*info.viewhead)[0]).num
    for ii = 0,old_num -1 do begin
        wname = 'ql_viewhead' + strtrim(string(ii),2)
        hptr = (*info.viewhead)[ii]
        if XRegistered(wname) then begin
            widget_control,(*hptr).viewwin,/destroy
        endif
    endfor

    ptr_free,info.viewhead
endif



info.viewhead = ptr_new()
for i = 0,num-1 do begin 
;    print,'new header pointer'
    newhdr = ptr_new({vheadi})
    (*newhdr).viewtxt = 0
    (*newhdr).viewwin = 0
    (*newhdr).num = num
    if(i eq 0) then begin
        temphdr = newhdr
    endif else begin
        temphdr = [*info.viewhead,newhdr]
        ptr_free,info.viewhead
    endelse
    info.viewhead = ptr_new(temphdr)
    temphdr = 0
endfor


; load Primary Science Image header

if(info.data.raw_exist eq 1 ) then begin 
    fits_open,info.control.filename_raw,fcb
    fits_read,fcb,cube_raw,header_raw,/header_only
endif else begin
    header_raw = 0
endelse

if ptr_valid ((*(*info.viewhead)[0]).phead) then ptr_free,$
  (*(*info.viewhead)[0]).phead
(*(*info.viewhead)[0]).phead= ptr_new(header_raw)
    
header_raw = 0 

fits_close,fcb




widget_control,info.QuickLook,Set_Uvalue = info
end




;***********************************************************************
pro header_setup_slope,info

file_exist2 = file_test(info.control.filename_slope,/regular,/read)
if(file_exist2 ne  1)then begin
    return
endif else begin
    fits_open,info.control.filename_slope,fcb

    fits_read,fcb,cube_raw,header_raw,/header_only,exten_no = 1
    nint = fxpar(header_raw,'NPINT',count = count)
    nframe = fxpar(header_raw,'NPGROUP',count = count)
    info.data.nslopes = nint
    if(nframe eq 1 and nint gt 1) then info.data.nslopes = 1
    
    header_raw = 0
    fits_close,fcb

    
    fits_open,info.control.filename_slope,fcb
    for i = 0,info.data.nslopes-1 do begin 
        fits_read,fcb,cube,header,exten_no = i + 1

        if ptr_valid ((*(*info.viewhead)[i+1]).phead) then ptr_free,$
          (*(*info.viewhead)[i+1]).phead
        (*(*info.viewhead)[i+1]).phead= ptr_new(header)
    endfor
    fits_close,fcb
    cube = 0
    header = 0
endelse

Widget_Control,info.Quicklook,Set_UValue=info

end




;***********************************************************************
pro header_setup_cal,info

file_exist2 = file_test(info.control.filename_cal,/regular,/read)
if(file_exist2 ne  1)then begin
    return
endif else begin
    fits_open,info.control.filename_cal,fcb

    fits_read,fcb,cube_raw,header_raw,/header_only,exten_no = 0

    nint = fxpar(header_raw,'NCINT',count = count)
    nframe = fxpar(header_raw,'NCGROUP',count = count)
    nslopes = nint
    if(nframe eq 1 and nint gt 1) then nslopes = 1
    fits_close,fcb
    header_raw = 0
    fits_open,info.control.filename_cal,fcb
    start = 1 + nslopes
    for i = 0,nslopes-1 do begin 
        fits_read,fcb,cube,header,exten_no = i + 1

        if ptr_valid ((*(*info.viewhead)[start+i]).phead) then ptr_free,$
          (*(*info.viewhead)[i+start]).phead
        (*(*info.viewhead)[i+start]).phead= ptr_new(header)
    endfor
    fits_close,fcb
    cube = 0
    header = 0
endelse

Widget_Control,info.Quicklook,Set_UValue=info

end







;***********************************************************************
; the event manager for the display_header.pro (comparing widget)
pro display_header_event,event

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


;_______________________________________________________________________

pro display_header,info,ii


hptr = (*info.viewhead)[ii]
hdr = [*(*hptr).phead]



wname = 'ql_viewhead' + strtrim(string(ii),2)
if XRegistered(wname) then begin
;    Widget_Control, (*hptr).viewtxt, Set_Value = hdr
    widget_control,(*hptr).viewwin,/destroy
    ;return
endif

; Pop up a widget to show the reference image header and allow
; the user to scroll through it.

  height = info.viewhdrysize

  thename = info.control.filename_raw
  width = 90

  title = 'QL Header for '+thename
xwidget_size = 800
ywidget_size = 800
xsize_scroll = 600
ysize_scroll = 600

if(info.control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.control.x_scroll_window
if(info.control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.control.y_scroll_window

if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10

  vhWindow = Widget_Base(group_leader=info.QuickLook, $
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
               Event_Pro = 'display_header_done')

  if(ii gt 0) then begin
      sint = "  Slope Header for Integration " + strcompress(string(ii),/remove_all)
      intnum  = widget_label(headerbase,value = sint)
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
           info         : info          $
           }

  Widget_Control, vhWindow, Set_UValue=vhinfo
  Widget_Control, vhWindow, /Realize

  XManager, wname, vhWindow, /No_Block, $
                Event_Handler = "display_header_event"

end
