
;***********************************************************************
pro cv_display_header_done,event
 Widget_Control, event.top, /Destroy
end

;***********************************************************************
;_______________________________________________________________________

; Set up the structure to display a header
; If type = 0, only make it large enough to hold the cube 
; If type = 1, then make it large enough to hold the slope headers 
;               (as many headers as integrations)
; Also read in the science header
;***********************************************************************
pro cv_header_setup,type,cinfo ; default type = 0 (only set up for Primary header
                           ; raw science image


intnum = 0
framenum = 0
shead = 0
rhead = 1
chead = 0
if(type eq 1) then begin
    shead = 1
endif


num = intnum*( shead  + chead) + rhead
;print,' number of headers',num

if (ptr_valid ( (*cinfo.viewhead)[0] )) then   begin
    old_num = (*(*cinfo.viewhead)[0]).num
    for ii = 0,old_num -1 do begin
        wname = 'cv_viewhead' + strtrim(string(ii),2)
        hptr = (*cinfo.viewhead)[ii]
        if XRegistered(wname) then begin
            widget_control,(*hptr).viewwin,/destroy
        endif
    endfor
    ptr_free,cinfo.viewhead
endif



cinfo.viewhead = ptr_new()
for i = 0,num-1 do begin 
;    print,'new header pointer'
    newhdr = ptr_new({vheadi})
    (*newhdr).viewtxt = 0
    (*newhdr).viewwin = 0
    (*newhdr).num = num
    if(i eq 0) then begin
        temphdr = newhdr
    endif else begin
        temphdr = [*cinfo.viewhead,newhdr]
        ptr_free,cinfo.viewhead
    endelse
    cinfo.viewhead = ptr_new(temphdr)
    temphdr = 0
endfor


; load Primary Science Image header
;print,'Opening fits file and reading in


fits_open,cinfo.control.filename_cube,fcb
fits_read,fcb,cube,header,/header_only


if ptr_valid ((*(*cinfo.viewhead)[0]).phead) then ptr_free,$
  (*(*cinfo.viewhead)[0]).phead
(*(*cinfo.viewhead)[0]).phead= ptr_new(header)
    
header = 0 

fits_close,fcb

widget_control,cinfo.CubeView,Set_Uvalue = cinfo
end




;***********************************************************************
pro cv_header_setup_slope,cinfo

file_exist2 = file_test(cinfo.control.filename_slope,/regular,/read)
if(file_exist2 ne  1)then begin
    return
endif else begin
;    fits_open,cinfo.control.filename_slope,fcb

    fits_read,fcb,cube_raw,header_raw,/header_only,exten_no = 1
    nint = fxpar(header_raw,'NPINT',count = count)
    nframe = fxpar(header_raw,'NPGROUP',count = count)
    cinfo.data.nslopes = nint
    if(nframe eq 1 and nint gt 1) then cinfo.data.nslopes = 1
    
    header_raw = 0
    fits_close,fcb
    fits_open,cinfo.control.filename_slope,fcb
    for i = 0,cinfo.data.nslopes-1 do begin 
        fits_read,fcb,cube,header,exten_no = i + 1

        if ptr_valid ((*(*cinfo.viewhead)[i+1]).phead) then ptr_free,$
          (*(*cinfo.viewhead)[i+1]).phead
        (*(*cinfo.viewhead)[i+1]).phead= ptr_new(header)
    endfor
    fits_close,fcb
    cube = 0
    header = 0
endelse

Widget_Control,cinfo.CubeView,Set_UValue=cinfo

end



;***********************************************************************
; the event manager for the cv_display_header.pro (comparing widget)
pro cv_display_header_event,event

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

pro cv_display_header,cinfo,ii


hptr = (*cinfo.viewhead)[ii]
hdr = [*(*hptr).phead]



wname = 'cv_viewhead' + strtrim(string(ii),2)
if XRegistered(wname) then begin
;    Widget_Control, (*hptr).viewtxt, Set_Value = hdr
    widget_control,(*hptr).viewwin,/destroy
    ;return
endif

; Pop up a widget to show the reference image header and allow
; the user to scroll through it.

  height = cinfo.viewhdrysize

  thename = cinfo.control.filename_cube
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
           cinfo         : cinfo          $
           }

  Widget_Control, vhWindow, Set_UValue=vhinfo
  Widget_Control, vhWindow, /Realize

  XManager, wname, vhWindow, /No_Block, $
                Event_Handler = "cv_display_header_event"

end
