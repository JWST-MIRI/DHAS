
;***********************************************************************
pro jwst_display_header_done,event
 Widget_Control, event.top, /Destroy
end

;***********************************************************************
; Set up the structure to display a header
; If type = 0 called from image display. 
; Raw Header, Final Slope Header, Int Slope header, Calibrated header

; If type = 1 callled from rate & rate int   display. 
;Display rate (if exist)  

; If type = 2 callled from rate & cal 
;  Display rate + cal (if exist)  

;***********************************************************************
pro jwst_header_setup,type,info ; default type = 0 (only set up for Primary header
                           ; raw science image
; set up size of header
intnum = 0
framenum = 0
rhead = 0
shead = 0
chead = 0 

if(type eq 0) then begin ; called from Image Frame Display
    rhead = 1
    shead = 1
    chead = 1
    num = 4
    ;if(info.jwst_control.file_slope_exist) then shead = 1
    ;if(info.jwst_control.file_cal_exist) then chead = 1
endif

if(type eq 2) then begin ; final slope + calibration image
    shead = 1
    chead = 1
    num = 2 
 endif

if(type eq 1) then begin ; final slope +  slope integration  image
    shead = 1
    num = 1
endif

; clean up header info already loaded
if (ptr_valid ( (*info.jwst_viewhead)[0] )) then   begin
    old_num = (*(*info.jwst_viewhead)[0]).num
    for ii = 0,old_num -1 do begin
        wname = 'jwst_viewhead' + strtrim(string(ii),2)
        hptr = (*info.jwst_viewhead)[ii]
        if XRegistered(wname) then begin
            widget_control,(*hptr).viewwin,/destroy
        endif
    endfor
    ptr_free,info.jwst_viewhead
endif

; set up new header information
info.jwst_viewhead = ptr_new()
for i = 0,num-1 do begin 
    newhdr = ptr_new({jwst_vheadi})
    (*newhdr).viewtxt = 0
    (*newhdr).viewwin = 0
    (*newhdr).num = num
    if(i eq 0) then begin
        temphdr = newhdr
    endif else begin
        temphdr = [*info.jwst_viewhead,newhdr]
        ptr_free,info.jwst_viewhead
    endelse
    info.jwst_viewhead = ptr_new(temphdr)
    temphdr = 0
endfor

widget_control,info.jwst_QuickLook,Set_Uvalue = info
end

;________________________________________________________________________________
pro jwst_header_setup_image,info
; load Primary Science Image header
if(info.jwst_control.file_raw_exist eq 0 ) then begin
   return
endif

fits_open,info.jwst_control.filename_raw,fcb
fits_read,fcb,cube_raw,header_raw,/header_only,exten_no=0

if ptr_valid ((*(*info.jwst_viewhead)[0]).phead) then ptr_free,$
  (*(*info.jwst_viewhead)[0]).phead
(*(*info.jwst_viewhead)[0]).phead= ptr_new(header_raw)
    
header_raw = 0 
fits_close,fcb

end
 
;***********************************************************************
pro jwst_header_setup_slope,type,info

; type = 0 calling for Frame display, slope header = 1
; type = 2 slope and cal display, slope header = 0
; type = 1 calling for Slope display and slope integration,slope header = 0



file_exist2 = file_test(info.jwst_control.filename_slope,/regular,/read)
if(file_exist2 ne  1)then begin
    return
endif
fits_open,info.jwst_control.filename_slope,fcb
fits_read,fcb,slope,header_slope,/header_only,exten_no = 0
nint = fxpar(header_slope,'NINTS',count = count)
nframe = fxpar(header_slope,'NGROUPS',count = count)
info.jwst_data.nints = nint
if(nframe eq 1 and nint gt 1) then begin
   print,' This tool does not support co-added data'
   stop
endif
    
if(type eq 0) then begin  ; 0 = raw, 1 = final slope, 2 = calibration
   if ptr_valid ((*(*info.jwst_viewhead)[1]).phead) then ptr_free,$
      (*(*info.jwst_viewhead)[1]).phead
   (*(*info.jwst_viewhead)[1]).phead= ptr_new(header_slope)
endif


if(type eq 2) then begin  ; 1 = final slope, 0= calibrated
   if ptr_valid ((*(*info.jwst_viewhead)[1]).phead) then ptr_free,$
      (*(*info.jwst_viewhead)[1]).phead
   (*(*info.jwst_viewhead)[1]).phead= ptr_new(header_slope)
endif

if(type eq 1 ) then begin  ; 0 = final slope
   if ptr_valid ((*(*info.jwst_viewhead)[0]).phead) then ptr_free,$
      (*(*info.jwst_viewhead)[0]).phead
   (*(*info.jwst_viewhead)[0]).phead= ptr_new(header_slope)
endif

fits_close,fcb
slope = 0
header_slope = 0
Widget_Control,info.jwst_Quicklook,Set_UValue=info
end

;***********************************************************************
pro jwst_header_setup_cal,type,info

file_exist2 = file_test(info.jwst_control.filename_cal,/regular,/read)
if(file_exist2 ne  1)then begin
    return
endif 
fits_open,info.jwst_control.filename_cal,fcb
fits_read,fcb,cube,header_cal,/header_only,exten_no = 0

nint = fxpar(header_cal,'NINTS',count = count)
nframe = fxpar(header_cal,'NGROUPS',count = count)
if(nframe eq 1 and nint gt 1) then begin
   print,'This tool does not support co-added data'
   stop
endif


if(type eq 0) then begin ; raw =0, slope = 1, cal = 2
   if ptr_valid ((*(*info.jwst_viewhead)[2]).phead) then ptr_free,$
      (*(*info.jwst_viewhead)[2]).phead
   (*(*info.jwst_viewhead)[2]).phead= ptr_new(header_cal)
endif


if(type eq 2) then begin 
   if ptr_valid ((*(*info.jwst_viewhead)[0]).phead) then ptr_free,$
      (*(*info.jwst_viewhead)[0]).phead
   (*(*info.jwst_viewhead)[0]).phead= ptr_new(header_cal)
endif

    
fits_close,fcb
cube = 0
header_cal = 0


Widget_Control,info.jwst_Quicklook,Set_UValue=info

end







;***********************************************************************
; the event manager for the display_header.pro (comparing widget)
pro jwst_display_header_event,event

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
pro jwst_display_header,info,ii

; ii = 0 raw data
; ii = 1 rate file (all integrations have the same header. Read *rate.fits
; ii = 2 cal file 
hptr = (*info.jwst_viewhead)[ii]
hdr = [*(*hptr).phead]

wname = 'jwst_viewhead' + strtrim(string(ii),2)
if XRegistered(wname) then begin
    widget_control,(*hptr).viewwin,/destroy
endif

; Pop up a widget to show the reference image header and allow
; the user to scroll through it.

height = info.viewhdrysize
thename = info.jwst_control.filename_raw
width = 90

title = ' Header for '+thename
xwidget_size = 800
ywidget_size = 800
xsize_scroll = 600
ysize_scroll = 600

if(info.jwst_control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.jwst_control.x_scroll_window
if(info.jwst_control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.jwst_control.y_scroll_window

if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10

vhWindow = Widget_Base(group_leader=info.jwst_QuickLook, $
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
                           Event_Pro = 'jwst_display_header_done')

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
          Event_Handler = "jwst_display_header_event"

end
