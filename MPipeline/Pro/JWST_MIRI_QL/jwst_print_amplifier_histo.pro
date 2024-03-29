@file_decompose.pro


pro jwst_amplifier_hist_cancel, event

  Widget_Control, event.top, Get_UValue=printhistinfo
  Widget_Control, printhistinfo.hinfo.info.jwst_Quicklook, Get_UValue=info
   Widget_Control, event.top, /Destroy
end

pro amplifier_hist_print_file, event

  Widget_Control, event.top, Get_UValue=printhistinfo
  Widget_Control, printhistinfo.hinfo.info.jwst_Quicklook, Get_UValue=info

      ; Get the file name the user typed in.
  Widget_Control, printhistinfo.selectfile, Get_Value = filename
  printhistinfo.filename = filename
  Widget_Control, event.top, Set_UValue=printhistinfo

;  filename = strtrim(filename[0], 2)
;  file_decompose, filename, disk,path, name, extn, version
;  if strlen(extn) eq 0 then filename = filename + '.jpg'

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

    Widget_Control, printhistinfo.otypebuttons, Get_Value = otype
    printhistinfo.otype = otype
    Case (printhistinfo.otype) of
     0: Begin                   ; write JPEG

        Widget_Control, printhistinfo.selectfile, Get_Value = filename
        len = strlen(filename)
        filename = strmid(filename,0,len-5)
        for i = 0, 4 do begin 
           file = filename+strcompress(string(fix(i+1)),/remove_all) + '.jpg'
           wset,printhistinfo.hinfo.draw_window_id[i]
           image3d = tvrd(true=1)
           write_jpeg,file,image3d,true=1
        endfor
     end

     1: Begin                   ; write PNG

        Widget_Control, printhistinfo.selectfile, Get_Value = filename
        len = strlen(filename)
        filename = strmid(filename,0,len-5)
        for i = 0, 4 do begin 
           file = filename+strcompress(string(fix(i+1)),/remove_all); + '.png'
           wset,printhistinfo.hinfo.draw_window_id[i]
           image3d = TVRead(filename=file,/PNG,/nodialog)
        endfor
     end

     2: Begin                   ; write GIF
        
        Widget_Control, printhistinfo.selectfile, Get_Value = filename
        len = strlen(filename)
        filename = strmid(filename,0,len-5)
        for i = 0, 4 do begin 
           file = filename+strcompress(string(fix(i+1)),/remove_all) ;+ '.gif'
           wset,printhistinfo.hinfo.draw_window_id[i]
           image3d = TVRead(filename=file,/GIF,/nodialog)
        endfor
     end

    endcase
    widget_control,event.top, /Destroy
 end

pro amplifier_hist_print, event

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


pro jwst_print_amplifier_histo,hinfo

Widget_Control, hinfo.info.jwst_QuickLook, Get_UValue=info
type = hinfo.type
outname = hinfo.outname

  ; Pop up a small widget so the user can type in a file name.
  ; Wait for the user to type a carriage-return.
  if(XRegistered("PAmphisto")) then return

; widget window parameters
  xwidget_size = 900
  ywidget_size = 110

  xsize_scroll = 700
  ysize_scroll = 110

  if(info.jwst_control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.jwst_control.x_scroll_window
  if(info.jwst_control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.jwst_control.y_scroll_window
  if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
  if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10

  if(type eq 1) then grouplead =  info.jwst_AmpHistoDisplay
  ;if(type eq 2) then grouplead =  info.HistoSlopeChannelQuickLook

  otype = 0
  path = info.jwst_control.dirps
  slash = '/'
  if(path eq "") then slash = ''

  outname = outname + 'Amplifier_1'
  
  filename = info.jwst_control.dirps + slash + info.jwst_control.filebase + $
             outname + '.jpg'

  title      = 'MIRI Quicklook Print Histogram'
  pntrbase   = Widget_Base  (Title = title, /Column, Group_Leader=grouplead, $
                           xsize = xwidget_size,$
                           ysize = ywidget_size,/scroll,$
                           x_scroll_size= xsize_scroll,$
                           y_scroll_size = ysize_scroll)			    
  pntr1base =  Widget_Base(pntrbase, /Row)
  label      = Widget_Label (pntr1base, Value='Output file name:') 
  selectfile = Widget_Text  (pntr1base, Value = filename, XSize = 120, /Edit, $
		    Event_Pro = 'amplifier_hist_print')
  pntr2base  = Widget_Base  (pntrbase, /Row)

  tnames = [ 'JPEG', 'PNG', 'GIF']
  otypeButtons = cw_bgroup(pntr2base, tnames, row=1, label_left='File type:', $
	      uvalue='obutton', set_value=otype, exclusive=1, $
	      /no_release)
  label3     = Widget_Label (pntr2base, Value = '     ')
  browseButton = Widget_Button(pntr2base, Value = ' Browse ')
  printButton = Widget_Button(pntr2base, Value = ' Print ', $
		   Event_Pro = 'amplifier_hist_print_file')
  cancelButton = Widget_Button(pntr2base, Value = ' Cancel ', event_pro = 'jwst_amplifier_hist_cancel')


  printhistinfo = {selectfile    :     selectfile,   $
 		   browseButton  :     browseButton, $
		   cancelButton  :     cancelButton, $
		   otypeButtons  :     otypeButtons, $
                   otype         :     otype,        $
                   filename      :     filename,     $
                   dirps         :     info.jwst_control.dirps,$
                   type          :     type,         $
		   hinfo          :     hinfo        }

  Widget_Control, pntrbase, set_uvalue = printhistinfo
  Widget_Control, pntrbase, /Realize

  XManager, "PAmphisto", pntrbase, Event_Handler = "amplifier_hist_print"
          
end

;***********************************************************************

pro jwst_amplifier_hist_print_data, event

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

        for i = 0,4 do begin
            len = strlen(name)
            newname = strmid(name,0,len-1)
            newname = newname + strcompress(string(i+1),/remove_all)

            filename = disk + path + newname + '.txt'
            Widget_Control, printhistinfo.selectfile, Set_Value = filename
            openw,lun,filename,error=err,/get_lun
            graphno = i
            if(printhistinfo.type eq 1)then $
              jwst_update_amplider_histo,graphno,printhistinfo.hinfo,/ascii,unit=lun

           ; if(printhistinfo.type eq 2)then $
           ;   jwst_update_SlopeChannel_histo,graphno,printhistinfo.hinfo,/ascii,unit=lun
            close,lun
            free_lun,lun
        endfor
        

    endelse
      if printfil eq 1 then Widget_Control, info.jwst_Quicklook, Set_UValue=info
      Widget_Control, event.top, /Destroy
end
;_______________________________________________________________________

pro print_amplifier_histo_data,hinfo

Widget_Control, hinfo.info.jwst_QuickLook, Get_UValue=info
type = hinfo.type
outname = hinfo.outname

  ; Pop up a small widget so the user can type in a file name.
  ; Wait for the user to type a carriage-return.
  if(XRegistered("mql_printChist_data")) then return

; widget window parameters
  xwidget_size = 900
  ywidget_size = 110

  xsize_scroll = 700
  ysize_scroll = 110

  if(type eq 1) then grouplead =  info.jwst_AmpHistoDisplay
  ;if(type eq 2) then grouplead =  info.HistoSlopeChannelQuickLook

  if(info.jwst_control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.jwst_control.x_scroll_window
  if(info.jwst_control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.jwst_control.y_scroll_window
  if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
  if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10

  otype = 0
  path = info.control.dirps
  slash = '/'
  if(path eq "") then slash = ''

  outname = outname + 'Channel_1'
  filename = info.jwst_control.dirps + slash + info.jwst_control.filebase + $
             outname + '.txt'

  title      = 'MIRI Quicklook Print Histogram Data to File'
  pntrbase   = Widget_Base  (Title = title, /Column, Group_Leader=grouplead, $
                           xsize = xwidget_size,$
                           ysize = ywidget_size,/scroll,$
                           x_scroll_size= xsize_scroll,$
                           y_scroll_size = ysize_scroll)			    
  pntr1base =  Widget_Base(pntrbase, /Row)
  label      = Widget_Label (pntr1base, Value='Output file name:') 
  selectfile = Widget_Text  (pntr1base, Value = filename, XSize = 120, /Edit, $
		    Event_Pro = 'amplifier_hist_print_data')
  pntr2base  = Widget_Base  (pntrbase, /Row)


  label3     = Widget_Label (pntr2base, Value = '     ')
  browseButton = Widget_Button(pntr2base, Value = ' Browse ')
  printButton = Widget_Button(pntr2base, Value = ' Print ', $
		   Event_Pro = 'amplifier_hist_print_data')
  cancelButton = Widget_Button(pntr2base, Value = ' Cancel ')

  printhistinfo = {selectfile    :     selectfile,   $
 		   browseButton  :     browseButton, $
                   cancelButton  :     cancelButton, $
                   otypeButtons  :     otypeButtons, $
                   otype         :     otype,        $
                   filename      :     filename,     $
                   dirps         :     info.control.dirps,$
                   type          :     type,         $
		   hinfo          :     hinfo        }

  Widget_Control, pntrbase, set_uvalue = printhistinfo
  Widget_Control, pntrbase, /Realize

  XManager, "PAmphistoData", pntrbase, Event_Handler = "print_data_event"
          
end
