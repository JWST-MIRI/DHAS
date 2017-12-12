@file_decompose.pro

pro print_pixel_values_event, event

  Widget_Control, event.top, Get_UValue=printinfo
  Widget_Control, printinfo.info.QuickLook, Get_UValue=info
  case event.id of

      
      printinfo.browseButton: begin
          pout = strcompress(printinfo.dirps + '/',/remove_all)
          Pathvalue = Dialog_Pickfile(/read,Title='Please select output file path', $
                                      Path=pout, Get_Path=realpath,filter='*.fits')

          Widget_Control, printinfo.selectfile, set_value=realpath
          printinfo.filename = realpath
      end

      printinfo.cancelButton: begin
          ptype = 'x'
          set_plot, ptype
          Widget_Control, event.top, /Destroy
          return
      end

  endcase

  Widget_Control, event.top, Set_UValue=printinfo

end


;***********************************************************************
pro pixel_values_print, event

  Widget_Control, event.top, Get_UValue=printinfo
  Widget_Control, printinfo.info.Quicklook, Get_UValue=info

      ; Get the file name the user typed in.
  Widget_Control, printinfo.selectfile, Get_Value = filename
  printinfo.filename = filename
  Widget_Control, event.top, Set_UValue=printinfo

  filename = strtrim(filename[0], 2)
  file_decompose, filename, disk,path, name, extn, version
  if strlen(extn) eq 0 then filename = filename + '.ps'

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
        Widget_Control, printinfo.selectfile, Set_Value = filename
        
        openw,lun,filename,error=err,/get_lun

          mpl_print_pixel_values,printinfo.info,/ascii,unit=lun

        close,lun
        free_lun,lun

   endelse

      if printfil eq 1 then Widget_Control, info.Quicklook, Set_UValue=info
      Widget_Control, event.top, /Destroy
      end  
;_______________________________________________________________________

pro print_pixel_values, info



grouplead =  info.PixelLook

; widget window parameters
  xwidget_size = 900
  ywidget_size = 110

  xsize_scroll = 900
  ysize_scroll = 110

  if(info.control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.control.x_scroll_window
  if(info.control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.control.y_scroll_window
  if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
  if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10
  
  otype = 0
  path = info.control.dirps
  filename = info.control.dirps + '/' + info.control.filebase + '_pixel_values.txt'

  title      = 'MIRI Print Pixel Vlues'
  pntrbase   = Widget_Base  (Title = title, /Column, Group_Leader=grouplead, $
                           xsize = xwidget_size,$
                           ysize = ywidget_size,/scroll,$
                           x_scroll_size= xsize_scroll,$
                           y_scroll_size = ysize_scroll)			      
  pntr1base =  Widget_Base(pntrbase, /Row)
  label      = Widget_Label (pntr1base, Value='Output file name:') 
  selectfile = Widget_Text  (pntr1base, Value = filename, XSize = 120, /Edit, $
		    Event_Pro = 'pixel_values_print')
  pntr2base  = Widget_Base  (pntrbase, /Row)

  label3     = Widget_Label (pntr2base, Value = '     ')
  browseButton = Widget_Button(pntr2base, Value = ' Browse ')
  printButton = Widget_Button(pntr2base, Value = ' Print ', $
		   Event_Pro = 'pixel_values_print')
  cancelButton = Widget_Button(pntr2base, Value = ' Cancel ')


  printinfo = {selectfile    :     selectfile,   $
 		   browseButton  :     browseButton, $
		   cancelButton  :     cancelButton, $
                   dirps         :     info.control.dirps,$
                   filename      :     filename,     $
		   info          :     info        }

  Widget_Control, pntrbase, set_uvalue = printinfo
  Widget_Control, pntrbase, /Realize

  XManager, "printpixelvalues", pntrbase, Event_Handler = "print_pixel_values_event"
          
end
