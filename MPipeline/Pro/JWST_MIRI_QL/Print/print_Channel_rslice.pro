@file_decompose.pro

pro Channel_rslice_print, event


  Widget_Control, event.top, Get_UValue=printsliceinfo
  Widget_Control, printsliceinfo.cinfo.info.Quicklook, Get_UValue=info

      ; Get the file name the user typed in.
  Widget_Control, printsliceinfo.selectfile, Get_Value = filename
  printsliceinfo.filename = filename
  Widget_Control, event.top, Set_UValue=printsliceinfo

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
        
        Case (printsliceinfo.otype) of
            
	  0: Begin  ; write postscript
              set_plot, 'ps', /copy

              for i = 0,4 do begin
                  len = strlen(name)
                  newname = strmid(name,0,len-1)
                  newname = newname + strcompress(string(i+1),/remove_all)
                  filename = disk + path + newname + '.ps'
                  print,newname
                  Widget_Control, printsliceinfo.selectfile, Set_Value = filename
                  device, /landscape, file=filename, /color, encapsulated=0
                  
                  graphno = i
                  if(printsliceinfo.type eq 1)then $
                    mql_update_Channel_rowslice,graphno,printsliceinfo.cinfo,/ps
                  if(printsliceinfo.type eq 2)then $
                    mql_update_SlopeChannel_rowslice,graphno,printsliceinfo.cinfo,/ps
              endfor
             


             device,/close
             set_plot, 'x'
           end

          1: Begin  ; write encapsulated postscript
	     set_plot, 'ps', /copy
             
             for i = 0,4 do begin
                 len = strlen(name)
                 newname = strmid(name,0,len-1)
                 newname = newname + strcompress(string(i+1),/remove_all)
                 filename = disk + path + newname + '.eps'
                 Widget_Control, printsliceinfo.selectfile, Set_Value = filename
                 device, /landscape, file=filename, /color, encapsulated=1
                 graphno = i
                 if(printsliceinfo.type eq 1)then $
                   mql_update_Channel_rowslice,graphno,printsliceinfo.cinfo,/eps

                 if(printsliceinfo.type eq 2)then $
                   mql_update_SlopeChannel_rowslice,graphno,printsliceinfo.cinfo,/eps

             endfor

             device,/close
             set_plot, 'x'
           end


          2: Begin  ; write JPEG
              
                 for i = 0,4 do begin
                     len = strlen(name)
                     newname = strmid(name,0,len-1)
                     newname = newname + strcompress(string(i+1),/remove_all)
                     filename = disk + path + newname 
                     print,filename
                     Widget_Control, printsliceinfo.selectfile, Set_Value = filename
                     wset,printsliceinfo.cinfo.draw_window_id[i]
                     image3d = TVRead(filename=filename,/JPEG,/nodialog)                     

                 endfor
         end

         3: Begin               ; write PNG


             for i = 0,4 do begin
                 len = strlen(name)
                 newname = strmid(name,0,len-1)
                 newname = newname + strcompress(string(i+1),/remove_all)
                 filename = disk + path + newname 

                 Widget_Control, printsliceinfo.selectfile, Set_Value = filename
                 wset,printsliceinfo.cinfo.draw_window_id[i]
                 image3d = TVRead(filename=filename,/PNG,/nodialog)
             endfor

         end

          4: Begin  ; write GIF
              
              for i = 0,4 do begin
                  len = strlen(name)
                  newname = strmid(name,0,len-1)
                  newname = newname + strcompress(string(i+1),/remove_all)
                  filename = disk + path + newname 
                  Widget_Control, printsliceinfo.selectfile, Set_Value = filename
                  wset,printsliceinfo.cinfo.draw_window_id[i]
                  image3d = TVRead(filename=filename,/GIF,/nodialog)

              endfor
         end

           else:
       endcase
   endelse

      if printfil eq 1 then Widget_Control, info.Quicklook, Set_UValue=info
      Widget_Control, event.top, /Destroy
      end  
;_______________________________________________________________________

;_______________________________________________________________________

pro print_Channel_rslice,cinfo

Widget_Control, cinfo.info.QuickLook, Get_UValue=info
type = cinfo.type
outname = cinfo.outname

  ; Pop up a small widget so the user can type in a file name.
  ; Wait for the user to type a carriage-return.
  if(XRegistered("mql_printCrslice")) then return

; widget window parameters
  xwidget_size = 900
  ywidget_size = 110

  xsize_scroll = 700
  ysize_scroll = 110



  if(info.control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.control.x_scroll_window
  if(info.control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.control.y_scroll_window
  if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
  if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10

  if(type eq 1) then grouplead =  info.RSliceChannelRawQuickLook
  if(type eq 2) then grouplead =  info.RSliceSlopeChannelQuickLook

  otype = 0
  path = info.control.dirps
  slash = '/'
  if(path eq "") then slash = ''

  outname = outname + 'Channel_1'
  
  filename = info.control.dirps + slash + info.control.filebase + $
             outname + '.ps'

  title      = 'MIRI Quicklook Print Row Slice'
  pntrbase   = Widget_Base  (Title = title, /Column, Group_Leader=grouplead, $
                           xsize = xwidget_size,$
                           ysize = ywidget_size,/scroll,$
                           x_scroll_size= xsize_scroll,$
                           y_scroll_size = ysize_scroll)			    
  pntr1base =  Widget_Base(pntrbase, /Row)
  label      = Widget_Label (pntr1base, Value='Output file name:') 
  selectfile = Widget_Text  (pntr1base, Value = filename, XSize = 120, /Edit, $
		    Event_Pro = 'Channel_rslice_print')
  pntr2base  = Widget_Base  (pntrbase, /Row)

  tnames = ['PostScript', 'Encapsulated Postscript', 'JPEG', 'PNG', 'GIF']
  otypeButtons = cw_bgroup(pntr2base, tnames, row=1, label_left='File type:', $
	      uvalue='obutton', set_value=otype, exclusive=1, $
	      /no_release)
  label3     = Widget_Label (pntr2base, Value = '     ')
  browseButton = Widget_Button(pntr2base, Value = ' Browse ')
  printButton = Widget_Button(pntr2base, Value = ' Print ', $
		   Event_Pro = 'Channel_rslice_print')
  cancelButton = Widget_Button(pntr2base, Value = ' Cancel ')


  printsliceinfo = {selectfile    :     selectfile,   $
 		   browseButton  :     browseButton, $
		   cancelButton  :     cancelButton, $
		   otypeButtons  :     otypeButtons, $
                   otype         :     otype,        $
                   filename      :     filename,     $
                   dirps         :     info.control.dirps,$
                   type          :     type,         $
		   cinfo          :     cinfo        }

  Widget_Control, pntrbase, set_uvalue = printsliceinfo
  Widget_Control, pntrbase, /Realize

  XManager, "mql_printCrslice", pntrbase, Event_Handler = "print_event"
          
end

;***********************************************************************

pro Channel_rslice_print_data, event


  Widget_Control, event.top, Get_UValue=printsliceinfo
  Widget_Control, printsliceinfo.cinfo.info.Quicklook, Get_UValue=info

      ; Get the file name the user typed in.
  Widget_Control, printsliceinfo.selectfile, Get_Value = filename
  printsliceinfo.filename = filename
  Widget_Control, event.top, Set_UValue=printsliceinfo

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
            Widget_Control, printsliceinfo.selectfile, Set_Value = filename
            openw,lun,filename,error=err,/get_lun
            graphno = i
            if(printsliceinfo.type eq 1)then $
              mql_update_Channel_rowslice,graphno,printsliceinfo.cinfo,/ascii,unit=lun

            if(printsliceinfo.type eq 2)then $
              mql_update_SlopeChannel_rowslice,graphno,printsliceinfo.cinfo,/ascii,unit=lun
            close,lun
            free_lun,lun
        endfor
        

    endelse
      if printfil eq 1 then Widget_Control, info.Quicklook, Set_UValue=info
      Widget_Control, event.top, /Destroy
end
;_______________________________________________________________________

;_______________________________________________________________________

pro print_Channel_rslice_data,cinfo

Widget_Control, cinfo.info.QuickLook, Get_UValue=info
type = cinfo.type
outname = cinfo.outname

  ; Pop up a small widget so the user can type in a file name.
  ; Wait for the user to type a carriage-return.
  if(XRegistered("mql_printCrslice_data")) then return

; widget window parameters
  xwidget_size = 900
  ywidget_size = 110

  xsize_scroll = 700
  ysize_scroll = 110

  if(type eq 1) then grouplead =  info.RsliceChannelRawQuickLook
  if(type eq 2) then grouplead =  info.RsliceSlopeChannelQuickLook

  if(info.control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.control.x_scroll_window
  if(info.control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.control.y_scroll_window
  if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
  if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10

  otype = 0
  path = info.control.dirps
  slash = '/'
  if(path eq "") then slash = ''

  outname = outname + 'Channel_1'
  filename = info.control.dirps + slash + info.control.filebase + $
             outname + '.txt'

  title      = 'MIRI Quicklook Print Row Slice  Data to File'
  pntrbase   = Widget_Base  (Title = title, /Column, Group_Leader=grouplead, $
                           xsize = xwidget_size,$
                           ysize = ywidget_size,/scroll,$
                           x_scroll_size= xsize_scroll,$
                           y_scroll_size = ysize_scroll)			    
  pntr1base =  Widget_Base(pntrbase, /Row)
  label      = Widget_Label (pntr1base, Value='Output file name:') 
  selectfile = Widget_Text  (pntr1base, Value = filename, XSize = 120, /Edit, $
		    Event_Pro = 'Channel_rslice_print_data')
  pntr2base  = Widget_Base  (pntrbase, /Row)


  label3     = Widget_Label (pntr2base, Value = '     ')
  browseButton = Widget_Button(pntr2base, Value = ' Browse ')
  printButton = Widget_Button(pntr2base, Value = ' Print ', $
		   Event_Pro = 'Channel_rslice_print_data')
  cancelButton = Widget_Button(pntr2base, Value = ' Cancel ')

  printsliceinfo = {selectfile    :     selectfile,   $
 		   browseButton  :     browseButton, $
		   cancelButton  :     cancelButton, $
                   filename      :     filename,     $
                   dirps         :     info.control.dirps,$
                   type          :     type,         $
		   cinfo          :     cinfo        }

  Widget_Control, pntrbase, set_uvalue = printsliceinfo
  Widget_Control, pntrbase, /Realize

  XManager, "mql_printCrslice_data", pntrbase, Event_Handler = "print_data_event"
          
end
