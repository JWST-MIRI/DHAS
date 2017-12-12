@file_decompose.pro

pro tel_print, event

  Widget_Control, event.top, Get_UValue=printtelinfo
  Widget_Control, printtelinfo.tinfo.info.Quicklook, Get_UValue=info

      ; Get the file name the user typed in.
  Widget_Control, printtelinfo.selectfile, Get_Value = filename
  printtelinfo.filename = filename
  Widget_Control, event.top, Set_UValue=printtelinfo

  filename = strtrim(filename[0], 2)
  file_decompose, filename, disk,path, name, extn, version
  if strlen(extn) eq 0 then filename = filename + '.ps'



  type = printtelinfo.type
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
        
        Case (printtelinfo.otype) of
            
	  0: Begin  ; write postscript
              set_plot, 'ps', /copy
	     filename = disk + path + name + '.ps'
	     Widget_Control, printtelinfo.selectfile, Set_Value = filename
             device, /landscape, file=filename, /color, encapsulated=0

             if(type eq 1) then mtql_update_plot,info,1,/ps
             if(type eq 2) then mtql_update_plot,info,2,/ps
             if(type eq 3) then telemetry_update_plot,info,1,/ps
             if(type eq 4) then telemetry_update_plot,info,2,/ps
             device,/close
             set_plot, 'x'
           end

          1: Begin  ; write encapsulated postscript
	     set_plot, 'ps', /copy
	     filename = disk + path + name + '.eps'
	     Widget_Control, printtelinfo.selectfile, Set_Value = filename
             device, /landscape, file=filename, /color, encapsulated=1

             if(ext eq 1) then mtql_update_plot,info,1,/eps
             if(ext eq 2) then mtql_update_plot,info,2,/eps
             if(type eq 3) then telemetry_update_plot,info,1,/eps
             if(type eq 4) then telemetry_update_plot,info,2,/eps

             device,/close
             set_plot, 'x'
         end

           2: Begin             ; write JPEG
             filename = disk + path + name 
             Widget_Control, printtelinfo.selectfile, Set_Value = filename

             if(type eq 1) then wset,info.telemetry.draw_window_id[0]
             if(type eq 2) then wset,info.telemetry_raw.draw_window_id[0]
             if(type eq 3) then wset,info.tplot.draw_window_id[0]
             if(type eq 4) then wset,info.tplot_raw.draw_window_id[0]
             image3d = TVRead(filename=filename,/JPEG,/nodialog)
             image3d = 0

         end
         3: Begin               ; write PNG


             filename = disk + path + name 
             Widget_Control, printtelinfo.selectfile, Set_Value = filename

             if(type eq 1) then wset,info.telemetry.draw_window_id[0]
             if(type eq 2) then wset,info.telemetry_raw.draw_window_id[0]
             if(type eq 3) then wset,info.tplot.draw_window_id[0]
             if(type eq 4) then wset,info.tplot_raw.draw_window_id[0]
             image3d = TVRead(filename=filename,/PNG,/nodialog)

             image3d = 0
         end

         4: Begin               ; write GIF
             filename = disk + path + name 
             Widget_Control, printtelinfo.selectfile, Set_Value = filename

             if(type eq 1) then wset,info.telemetry.draw_window_id[0]
             if(type eq 2) then wset,info.telemetry_raw.draw_window_id[0]
             if(type eq 3) then wset,info.tplot.draw_window_id[0]
             if(type eq 4) then wset,info.tplot_raw.draw_window_id[0]
             image3d = TVRead(filename=filename,/GIF,/nodialog)
             image3d = 0
         end

           else:
       endcase
   endelse


      if printfil eq 1 then Widget_Control, info.Quicklook, Set_UValue=info
      Widget_Control, event.top, /Destroy
      end  
;_______________________________________________________________________
pro print_tel_event, event

  Widget_Control, event.top, Get_UValue=printtelinfo
  Widget_Control, printtelinfo.tinfo.info.QuickLook, Get_UValue=info
  case event.id of
      printtelinfo.otypeButtons: begin
          otype = event.value
          printtelinfo.otype = otype




          fileold = printtelinfo.filename
          filenew = fileold
          len = strlen(fileold)
          test = strmid(fileold,len-3,1)
          lenback = len - 3
          if(test eq '.' ) then lenback = len - 2

          if(otype eq 0) then filenew = strmid(fileold,0,lenback) + 'ps'
          if(otype eq 1) then filenew = strmid(fileold,0,lenback) + 'eps'
          if(otype eq 2) then filenew = strmid(fileold,0,lenback) + 'jpg'
          if(otype eq 3) then filenew = strmid(fileold,0,lenback) + 'png'
          if(otype eq 4) then filenew = strmid(fileold,0,lenback) + 'gif'
          if(test eq 'eps') then begin
              filenew = strmid(fileold,0,len-3) + 'ps'
          endif


          printtelinfo.filename = filenew

          Widget_Control, printtelinfo.selectfile, set_value=filenew
      end
      
      printtelinfo.browseButton: begin
          pout = strcompress(info.control.dirps + '/',/remove_all)
          Pathvalue = Dialog_Pickfile(/read,Title='Please select output file path', $
                                      Path=pout, Get_Path=realpath,filter='*.fits')

          Widget_Control, printtelinfo.selectfile, set_value=realpath
          printtelinfo.filename = realpath
      end

      printtelinfo.cancelButton: begin
          ptype = 'x'
          set_plot, ptype
          Widget_Control, info.Quicklook, Set_UValue=info
          Widget_Control, event.top, /Destroy
          return
      end

  endcase

  Widget_Control, event.top, Set_UValue=printtelinfo
  Widget_Control, printtelinfo.tinfo.info.Quicklook, Set_UValue=info

end

;_______________________________________________________________________
pro print_telemetry, event

  ; Pop up a small widget so the user can type in a file name.
  ; Wait for the user to type a carriage-return.
  if(XRegistered("mql_printtel")) then return

  Widget_Control, event.top, Get_UValue = tinfo
  Widget_Control, tinfo.info.Quicklook, Get_UValue = info
  hname = ' ' 


  type = 1
  otype = 0
  path = info.control.dirps

  slash_str = strsplit(info.control.filename_tel,'/',/extract)
  n_slash = n_elements(slash_str)
  if (n_slash GT 1) then begin
      out_filebase = slash_str[n_slash-1]
  endif else begin
      out_filebase = info.control.filename_tel
  endelse
  len= strlen(out_filebase)
  out_file = strmid(out_filebase,0,len-5)
  info.control.filebase_tel = out_file
  filename = info.control.dirps + '/' + out_file + '_converted.ps'

  title      = 'MIRI Quicklook Print Telemtry'
  pntrbase   = Widget_Base  (Title = title, /Column, Group_Leader=event.top, $
			      /Modal)
  pntr1base =  Widget_Base(pntrbase, /Row)
  label      = Widget_Label (pntr1base, Value='Output file name:') 
  selectfile = Widget_Text  (pntr1base, Value = filename, XSize = 100, /Edit, $
		    Event_Pro = 'tel_print')
  pntr2base  = Widget_Base  (pntrbase, /Row)
  tnames = ['PostScript', 'Encapsulated Postscript', 'JPEG', 'PNG', 'GIF']

  otypeButtons = cw_bgroup(pntr2base, tnames, row=1, label_left='File type:', $
	      uvalue='obutton', set_value=otype, exclusive=1, $
	      /no_release)
  label3     = Widget_Label (pntr2base, Value = '     ')
  browseButton = Widget_Button(pntr2base, Value = ' Browse ')
  printButton = Widget_Button(pntr2base, Value = ' Print ', $
		   Event_Pro = 'tel_print')
  cancelButton = Widget_Button(pntr2base, Value = ' Cancel ')

  printtelinfo = {selectfile    :     selectfile,   $
 		   browseButton  :     browseButton, $
		   cancelButton  :     cancelButton, $
		   otypeButtons  :     otypeButtons, $
                   otype         :     otype,        $
                   filename      :     filename,     $
                   type          :     type,          $
		   tinfo         :     tinfo        }

  Widget_Control, pntrbase, set_uvalue = printtelinfo
  Widget_Control, pntrbase, /Realize
  Widget_Control, tinfo.info.Quicklook, Set_UValue = info

  XManager, "mql_printtel", pntrbase, Event_Handler = "print_tel_event"
          
end



;_______________________________________________________________________
pro print_telemetry_raw, event

  ; Pop up a small widget so the user can type in a file name.
  ; Wait for the user to type a carriage-return.
  if(XRegistered("mql_printtel_raw")) then return

  Widget_Control, event.top, Get_UValue = tinfo
  Widget_Control, tinfo.info.Quicklook, Get_UValue = info
  hname = ' ' 


  type = 2
  otype = 0
  path = info.control.dirps

  slash_str = strsplit(info.control.filename_telraw,'/',/extract)
  n_slash = n_elements(slash_str)
  if (n_slash GT 1) then begin
      out_filebase = slash_str[n_slash-1]
  endif else begin
      out_filebase = info.control.filename_telraw
  endelse
  len= strlen(out_filebase)
  out_file = strmid(out_filebase,0,len-5)
  info.control.filebase_telraw = out_file
  filename = info.control.dirps + '/' + out_file + '_raw.ps'

  title      = 'MIRI Quicklook Print Telemtry'
  pntrbase   = Widget_Base  (Title = title, /Column, Group_Leader=event.top, $
			      /Modal)
  pntr1base =  Widget_Base(pntrbase, /Row)
  label      = Widget_Label (pntr1base, Value='Output file name:') 
  selectfile = Widget_Text  (pntr1base, Value = filename, XSize = 100, /Edit, $
		    Event_Pro = 'tel_print')
  pntr2base  = Widget_Base  (pntrbase, /Row)
  tnames = ['PostScript', 'Encapsulated Postscript', 'JPEG', 'PNG', 'GIF']

  otypeButtons = cw_bgroup(pntr2base, tnames, row=1, label_left='File type:', $
	      uvalue='obutton', set_value=otype, exclusive=1, $
	      /no_release)
  label3     = Widget_Label (pntr2base, Value = '     ')
  browseButton = Widget_Button(pntr2base, Value = ' Browse ')
  printButton = Widget_Button(pntr2base, Value = ' Print ', $
		   Event_Pro = 'tel_print')
  cancelButton = Widget_Button(pntr2base, Value = ' Cancel ')

  printtelinfo = {selectfile    :     selectfile,   $
 		   browseButton  :     browseButton, $
		   cancelButton  :     cancelButton, $
		   otypeButtons  :     otypeButtons, $
                   otype         :     otype,        $
                   type          :     type,          $
                   filename      :     filename,     $
		   tinfo         :     tinfo        }

  Widget_Control, pntrbase, set_uvalue = printtelinfo
  Widget_Control, pntrbase, /Realize
  Widget_Control, tinfo.info.Quicklook, Set_UValue = info

  XManager, "mql_printtel_raw", pntrbase, Event_Handler = "print_tel_event"
          
end


;_______________________________________________________________________
pro print_telemetry_plot, event

  ; Pop up a small widget so the user can type in a file name.
  ; Wait for the user to type a carriage-return.
  if(XRegistered("printtel")) then return

  Widget_Control, event.top, Get_UValue = tinfo
  Widget_Control, tinfo.info.Quicklook, Get_UValue = info
  hname = ' ' 


  type = 3
  otype = 0
  path = info.control.dirps

  slash_str = strsplit(info.control.filename_tel,'/',/extract)
  n_slash = n_elements(slash_str)
  if (n_slash GT 1) then begin
      out_filebase = slash_str[n_slash-1]
  endif else begin
      out_filebase = info.control.filename_tel
  endelse
  len= strlen(out_filebase)
  out_file = strmid(out_filebase,0,len-5)
  info.control.filebase_tel = out_file
  filename = info.control.dirps + '/' + out_file + '_converted_x_vs_y.ps'

  title      = 'MIRI Quicklook Print Telemtry'
  pntrbase   = Widget_Base  (Title = title, /Column, Group_Leader=event.top, $
			      /Modal)
  pntr1base =  Widget_Base(pntrbase, /Row)
  label      = Widget_Label (pntr1base, Value='Output file name:') 
  selectfile = Widget_Text  (pntr1base, Value = filename, XSize = 100, /Edit, $
		    Event_Pro = 'tel_print')
  pntr2base  = Widget_Base  (pntrbase, /Row)
  tnames = ['PostScript', 'Encapsulated Postscript', 'JPEG', 'PNG', 'GIF']

  otypeButtons = cw_bgroup(pntr2base, tnames, row=1, label_left='File type:', $
	      uvalue='obutton', set_value=otype, exclusive=1, $
	      /no_release)
  label3     = Widget_Label (pntr2base, Value = '     ')
  browseButton = Widget_Button(pntr2base, Value = ' Browse ')
  printButton = Widget_Button(pntr2base, Value = ' Print ', $
		   Event_Pro = 'tel_print')
  cancelButton = Widget_Button(pntr2base, Value = ' Cancel ')

  printtelinfo = {selectfile    :     selectfile,   $
 		   browseButton  :     browseButton, $
		   cancelButton  :     cancelButton, $
		   otypeButtons  :     otypeButtons, $
                   otype         :     otype,        $
                   filename      :     filename,     $
                   type          :     type,          $
		   tinfo         :     tinfo        }

  Widget_Control, pntrbase, set_uvalue = printtelinfo
  Widget_Control, pntrbase, /Realize
  Widget_Control, tinfo.info.Quicklook, Set_UValue = info

  XManager, "printtel", pntrbase, Event_Handler = "print_tel_event"
          
end

;_______________________________________________________________________
pro print_telemetry_plot_raw, event

  ; Pop up a small widget so the user can type in a file name.
  ; Wait for the user to type a carriage-return.
  if(XRegistered("printtel_raw")) then return

  Widget_Control, event.top, Get_UValue = tinfo
  Widget_Control, tinfo.info.Quicklook, Get_UValue = info
  hname = ' ' 


  type = 4
  otype = 0
  path = info.control.dirps

  slash_str = strsplit(info.control.filename_tel,'/',/extract)
  n_slash = n_elements(slash_str)
  if (n_slash GT 1) then begin
      out_filebase = slash_str[n_slash-1]
  endif else begin
      out_filebase = info.control.filename_tel
  endelse
  len= strlen(out_filebase)
  out_file = strmid(out_filebase,0,len-5)
  info.control.filebase_tel = out_file
  filename = info.control.dirps + '/' + out_file + '_raw_x_vs_y.ps'

  title      = 'MIRI Quicklook Print Telemtry'
  pntrbase   = Widget_Base  (Title = title, /Column, Group_Leader=event.top, $
			      /Modal)
  pntr1base =  Widget_Base(pntrbase, /Row)
  label      = Widget_Label (pntr1base, Value='Output file name:') 
  selectfile = Widget_Text  (pntr1base, Value = filename, XSize = 100, /Edit, $
		    Event_Pro = 'tel_print')
  pntr2base  = Widget_Base  (pntrbase, /Row)
  tnames = ['PostScript', 'Encapsulated Postscript', 'JPEG', 'PNG', 'GIF']

  otypeButtons = cw_bgroup(pntr2base, tnames, row=1, label_left='File type:', $
	      uvalue='obutton', set_value=otype, exclusive=1, $
	      /no_release)
  label3     = Widget_Label (pntr2base, Value = '     ')
  browseButton = Widget_Button(pntr2base, Value = ' Browse ')
  printButton = Widget_Button(pntr2base, Value = ' Print ', $
		   Event_Pro = 'tel_print')
  cancelButton = Widget_Button(pntr2base, Value = ' Cancel ')

  printtelinfo = {selectfile    :     selectfile,   $
 		   browseButton  :     browseButton, $
		   cancelButton  :     cancelButton, $
		   otypeButtons  :     otypeButtons, $
                   otype         :     otype,        $
                   filename      :     filename,     $
                   type           :     type,          $
		   tinfo         :     tinfo        }

  Widget_Control, pntrbase, set_uvalue = printtelinfo
  Widget_Control, pntrbase, /Realize
  Widget_Control, tinfo.info.Quicklook, Set_UValue = info

  XManager, "printtel_raw", pntrbase, Event_Handler = "print_tel_event"
          
end

