@file_decompose.pro

pro jwst_hist_cancel, event

  Widget_Control, event.top, Get_UValue=printhistinfo
  Widget_Control, printhistinfo.hinfo.info.jwst_Quicklook, Get_UValue=info
   Widget_Control, event.top, /Destroy
end

pro jwst_hist_print_file, event

  Widget_Control, event.top, Get_UValue=printhistinfo
  Widget_Control, printhistinfo.hinfo.info.jwst_Quicklook, Get_UValue=info

      ; Get the file name the user typed in.
  Widget_Control, printhistinfo.selectfile, Get_Value = filename
  printhistinfo.filename = filename
  Widget_Control, event.top, Set_UValue=printhistinfo

  filename = strtrim(filename[0], 2)
  file_decompose, filename, disk,path, name, extn, version
  if strlen(extn) eq 0 then filename = filename + '.jpg'

  printdone = 0
  temp = file_search (filename, Count = fcount)

  if fcount gt 0 then begin
      ql_selectval, event.top, 'Do you wish to overwrite existing file?',$
                    ['no','yes'], printfil
      if printfil eq 0 then begin
          temp = Widget_Message('Enter new name for output file or Cancel')
      endif else begin
	  ; check if path is valid
          openw, lun, filename, error=err, /get_lun
          if err eq 0 then begin
	    close, lun
	    free_lun, lun
	    printfil = 1
          endif else begin
	    temp=Widget_Message('Cannot open file for writing - Invalid Path?')
            printfil = 0
        endelse
      endelse
    endif else printfil = 1
    if printfil eq 0 then begin
        print, 'Cannot print'
        return
     endif

  Case (printhistinfo.otype) of
     0: Begin                   ; write JPEG
       ; filename = disk + path + name + '.jpg'
        Widget_Control, printhistinfo.selectfile, Get_Value = filename
        wset,printhistinfo.hinfo.draw_window_id
        image3d = tvrd(true=1)
        write_jpeg,filename,image3d,true=1
     end

     1: Begin                   ; write PNG
       ; filename = disk + path + name
        Widget_Control, printhistinfo.selectfile, Get_Value = filename
        wset,printhistinfo.hinfo.draw_window_id
        image3d = TVRead(filename=filename,/PNG,/nodialog)
     end

     2: Begin                   ; write GIF
       ; filename = disk + path + name
        Widget_Control, printhistinfo.selectfile, Get_Value = filename
        wset,printhistinfo.hinfo.draw_window_id
        image3d = TVRead(filename=filename,/GIF,/nodialog)
     end

    endcase

    Widget_Control, event.top, /Destroy
end

pro jwst_hist_print, event

  Widget_Control, event.top, Get_UValue=printhistinfo
  Widget_Control, printhistinfo.hinfo.info.jwst_Quicklook, Get_UValue=info

      ; Get the file name the user typed in.
  Widget_Control, printhistinfo.selectfile, Get_Value = filename
  printhistinfo.filename = filename

  filename = strtrim(filename[0], 2)
  file_decompose, filename, disk,path, name, extn, version

  Widget_Control, printhistinfo.otypebuttons, Get_Value = otype
  printhistinfo.otype = otype

  Case (printhistinfo.otype) of
     0: Begin                   ; write JPEG
        filename = disk + path + name + '.jpg'
        Widget_Control, printhistinfo.selectfile, Set_Value = filename
     end

     1: Begin                   ; write PNG
        filename = disk + path + name +'.png'
        Widget_Control, printhistinfo.selectfile, Set_Value = filename
     end

     2: Begin                   ; write GIF
        filename = disk + path + name+ '.gif'
        Widget_Control, printhistinfo.selectfile, Set_Value = filename
     end
    
  endcase
  
  end  
;_______________________________________________________________________

pro jwst_print_histo,hinfo

  Widget_Control, hinfo.info.jwst_QuickLook, Get_UValue=info
  win = hinfo.win
  outname = hinfo.outname

  ; Pop up a small widget so the user can type in a file name.
  ; Wait for the user to type a carriage-return.
  if(XRegistered("jwst_mql_printhist")) then return

; widget window parameters
  xwidget_size = 900
  ywidget_size = 110

  xsize_scroll = 900
  ysize_scroll = 110

  if(info.jwst_control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.jwst_control.x_scroll_window
  if(info.jwst_control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.jwst_control.y_scroll_window
  if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
  if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10

  otype = 0
  path = info.jwst_control.dirps
  slash = '/'
  if(path eq "") then slash = ''

  filename = info.jwst_control.dirps + slash + info.jwst_control.filebase + $
             outname + '.jpg'

  title      = 'MIRI JWST Quicklook Print Histogram'

  pntrbase   = Widget_Base  (Title = title, /Column, $
                           xsize = xwidget_size,$
                           ysize = ywidget_size,/scroll,$
                           x_scroll_size= xsize_scroll,$
                           y_scroll_size = ysize_scroll)			    
  pntr1base =  Widget_Base(pntrbase, /Row)
  label      = Widget_Label (pntr1base, Value='Output file name:') 
  selectfile = Widget_Text  (pntr1base, Value = filename, XSize = 120, /Edit, $
		    Event_Pro = 'jwst_hist_print')
  pntr2base  = Widget_Base  (pntrbase, /Row)

  tnames = ['JPEG', 'PNG', 'GIF']
  otypeButtons = cw_bgroup(pntr2base, tnames, row=1, label_left='File type:', $
	      uvalue='obutton', set_value=otype, exclusive=1, $
	      /no_release)
  label3     = Widget_Label (pntr2base, Value = '     ')
  printButton = Widget_Button(pntr2base, Value = ' Print ', $
		   Event_Pro = 'jwst_hist_print_file')
  cancelButton = Widget_Button(pntr2base, Value = ' Cancel ', Event_Pro='jwst_hist_cancel')

  type=0
  dirps = info.jwst_control.dirps 
  printhistinfo = {selectfile    :     selectfile,   $
		   cancelButton  :     cancelButton, $
		   otypeButtons  :     otypeButtons, $
                   otype         :     otype,        $
                   dirps         :     dirps,        $
                   filename      :     filename,     $
                   type          :     type,         $
		   hinfo          :     hinfo        }

  Widget_Control, pntrbase, set_uvalue = printhistinfo
  Widget_Control, pntrbase, /Realize

  XManager, "jwst_mql_printhist", pntrbase, Event_Handler = "jwst_hist_print"
end

;***********************************************************************
pro jwst_hist_print_data, event
  
  Widget_Control, event.top, Get_UValue=printhistinfo
  Widget_Control, printhistinfo.hinfo.info.jwst_Quicklook, Get_UValue=info

      ; Get the file name the user typed in.
  Widget_Control, printhistinfo.selectfile, Get_Value = filename
  printhistinfo.filename = filename
  Widget_Control, event.top, Set_UValue=printhistinfo

  filename = strtrim(filename[0], 2)
  file_decompose, filename, disk,path, name, extn, version
  if strlen(extn) eq 0 then filename = filename + '.txt'

  printdone = 0
  temp = file_search (filename, Count = fcount)
  if fcount gt 0 then begin
      ql_selectval, event.top, 'Do you wish to overwrite existing file?',$
                    ['no','yes'], printfil
      if printfil eq 0 then begin
          temp = Widget_Message('Enter new name for output file or Cancel')
      endif else begin
	  ; check if path is valid
          openw, lun, filename, error=err, /get_lun
          if err eq 0 then begin
	    close, lun
	    free_lun, lun
	    printfil = 1
          endif else begin
	    temp=Widget_Message('Cannot open file for writing - Invalid Path?')
            printfil = 0
        endelse
      endelse
    endif else printfil = 1
    if printfil eq 0 then begin
        print, 'Cannot print'
        return
    endif else begin

        filename = disk + path + name + '.txt'
        Widget_Control, printhistinfo.selectfile, Set_Value = filename
        openw,lun,filename,error=err,/get_lun
        
        if(printhistinfo.type le 2)then  jwst_mql_update_histo,printhistinfo.hinfo,/ascii,unit=lun
        if(printhistinfo.type ge 3) then jwst_msql_update_histo,printhistinfo.hinfo,/ascii,unit=lun

        close,lun
        free_lun,lun
    endelse
      if printfil eq 1 then Widget_Control, info.jwst_Quicklook, Set_UValue=info
      Widget_Control, event.top, /Destroy
end
;_______________________________________________________________________


pro jwst_print_histo_data,hinfo
Widget_Control, hinfo.info.jwst_QuickLook, Get_UValue=info
;type = hinfo.type
outname = hinfo.outname

  ; Pop up a small widget so the user can type in a file name.
  ; Wait for the user to type a carriage-return.
  if(XRegistered("jwst_mql_printhist_data")) then return

; widget window parameters
  xwidget_size = 900
  ywidget_size = 110

  xsize_scroll = 900
  ysize_scroll = 110

  if(info.jwst_control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.jwst_control.x_scroll_window
  if(info.jwst_control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.jwst_control.y_scroll_window
  if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
  if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10

  otype = 0
  path = info.jwst_control.dirps
  slash = '/'
  if(path eq "") then slash = ''

  filename = info.jwst_control.dirps + slash + info.jwst_control.filebase + $
             outname + '.txt'

  title      = 'MIRI JWST Quicklook Print Histogram Data to File'
  pntrbase   = Widget_Base  (Title = title, /Column, $
                           xsize = xwidget_size,$
                           ysize = ywidget_size,/scroll,$
                           x_scroll_size= xsize_scroll,$
                           y_scroll_size = ysize_scroll)			    
  pntr1base =  Widget_Base(pntrbase, /Row)
  label      = Widget_Label (pntr1base, Value='Output file name:') 
  selectfile = Widget_Text  (pntr1base, Value = filename, XSize = 120, /Edit, $
		    Event_Pro = 'jwst_hist_print_data')
  pntr2base  = Widget_Base  (pntrbase, /Row)

  label3     = Widget_Label (pntr2base, Value = '     ')
  printButton = Widget_Button(pntr2base, Value = ' Print ', $
		   Event_Pro = 'jwst_hist_print_data')
  cancelButton = Widget_Button(pntr2base, Value = ' Cancel', Event_Pro='jwst_hist_cancel')

  type = 0 
  dirps = info.jwst_control.dirps 
  printhistinfo = {selectfile    :     selectfile,   $
		   cancelButton  :     cancelButton, $
                   dirps         :     dirps,        $
                   filename      :     filename,     $
                   type          :     type,         $
		   hinfo         :     hinfo        }

  Widget_Control, pntrbase, set_uvalue = printhistinfo
  Widget_Control, pntrbase, /Realize

  XManager, "jwst_mql_printhist_data", pntrbase, Event_Handler = "jwst_hist_print_data"
end
