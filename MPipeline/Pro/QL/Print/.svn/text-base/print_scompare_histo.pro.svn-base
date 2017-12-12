@file_decompose.pro

pro acompare_hist_print, event


  Widget_Control, event.top, Get_UValue=printhistinfo
  Widget_Control, printhistinfo.hinfo.info.Quicklook, Get_UValue=info

      ; Get the file name the user typed in.
  Widget_Control, printhistinfo.selectfile, Get_Value = filename
  printhistinfo.filename = filename
  Widget_Control, event.top, Set_UValue=printhistinfo

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
        
        Case (printhistinfo.otype) of
            
	  0: Begin  ; write postscript
              set_plot, 'ps', /copy

              for i = 0,2 do begin
                  len = strlen(name)
                  newname = strmid(name,0,len-1)
                  newname = newname + strcompress(string(i+1),/remove_all)
                  filename = disk + path + newname + '.ps'
                  print,newname
                  Widget_Control, printhistinfo.selectfile, Set_Value = filename
                  device, /landscape, file=filename, /color, encapsulated=0
                  
                  graphno = i
                  if(printhistinfo.type eq 1)then $
                    msql_update_compare_histo,graphno,printhistinfo.hinfo,/ps
                  if(printhistinfo.type eq 2)then $
                    mql_update_Slopecompare_histo,graphno,printhistinfo.hinfo,/ps
              endfor
             


             device,/close
             set_plot, 'x'
           end

          1: Begin  ; write encapsulated postscript
	     set_plot, 'ps', /copy
             
             for i = 0,2 do begin
                 len = strlen(name)
                 newname = strmid(name,0,len-1)
                 newname = newname + strcompress(string(i+1),/remove_all)
                 filename = disk + path + newname + '.eps'
                 Widget_Control, printhistinfo.selectfile, Set_Value = filename
                 device, /landscape, file=filename, /color, encapsulated=1
                 graphno = i
                 if(printhistinfo.type eq 1)then $
                   mql_update_compare_histo,graphno,printhistinfo.hinfo,/eps

                 if(printhistinfo.type eq 2)then $
                   mql_update_Slopecompare_histo,graphno,printhistinfo.hinfo,/eps

             endfor

             device,/close
             set_plot, 'x'
           end


          2: Begin  ; write JPEG
              
                 for i = 0,2 do begin
                     len = strlen(name)
                     newname = strmid(name,0,len-1)
                     newname = newname + strcompress(string(i+1),/remove_all)
                     filename = disk + path + newname 

                     Widget_Control, printhistinfo.selectfile, Set_Value = filename
                     wset,printhistinfo.hinfo.draw_window_id[i]
                     image3d = TVRead(filename=filename,/JPEG,/nodialog)                     

                 endfor
                 image3D = 0
                 image = 0
         end

         3: Begin               ; write PNG

             for i = 0,2 do begin
                 len = strlen(name)
                 newname = strmid(name,0,len-1)
                 newname = newname + strcompress(string(i+1),/remove_all)
                 filename = disk + path + newname
                 
                 Widget_Control, printhistinfo.selectfile, Set_Value = filename
                 wset,printhistinfo.hinfo.draw_window_id[i]
                 image3d = TVRead(filename=filename,/PNG,/nodialog)
             endfor
             image2d = 0
             image = 0

         end

          4: Begin  ; write GIF
              
              for i = 0,2 do begin
                  len = strlen(name)
                  newname = strmid(name,0,len-1)
                  newname = newname + strcompress(string(i+1),/remove_all)
                  filename = disk + path + newname 
                  Widget_Control, printhistinfo.selectfile, Set_Value = filename
                  wset,printhistinfo.hinfo.draw_window_id[i]
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
; Main Print graphs
pro print_compare_histo,hinfo

Widget_Control, hinfo.info.QuickLook, Get_UValue=info
type = hinfo.type
outname = hinfo.outname

  ; Pop up a small widget so the user can type in a file name.
  ; Wait for the user to type a carriage-return.
  if(XRegistered("mql_printCphist")) then return

; widget window parameters
  xwidget_size = 900
  ywidget_size = 110

  xsize_scroll = 700
  ysize_scroll = 110


  if(info.control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.control.x_scroll_window
  if(info.control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.control.y_scroll_window
  if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
  if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10

  if(type eq 1) then grouplead =  info.HistocompareQuickLook
  if(type eq 2) then grouplead =  info.HistoSlopecompareQuickLook

  otype = 0
  path = info.control.dirps
  slash = '/'
  if(path eq "") then slash = ''


  
  filename = info.control.dirps + slash  + $
             outname + '.ps'

  title      = 'MIRI Quicklook Print Histogram'
  pntrbase   = Widget_Base  (Title = title, /Column, Group_Leader=grouplead, $
                           xsize = xwidget_size,$
                           ysize = ywidget_size,/scroll,$
                           x_scroll_size= xsize_scroll,$
                           y_scroll_size = ysize_scroll)			    
  pntr1base =  Widget_Base(pntrbase, /Row)
  label      = Widget_Label (pntr1base, Value='Output file name:') 
  selectfile = Widget_Text  (pntr1base, Value = filename, XSize = 120, /Edit, $
		    Event_Pro = 'compare_hist_print')
  pntr2base  = Widget_Base  (pntrbase, /Row)

  tnames = ['PostScript', 'Encapsulated Postscript', 'JPEG', 'PNG', 'GIF']
  otypeButtons = cw_bgroup(pntr2base, tnames, row=1, label_left='File type:', $
	      uvalue='obutton', set_value=otype, exclusive=1, $
	      /no_release)
  label3     = Widget_Label (pntr2base, Value = '     ')
  browseButton = Widget_Button(pntr2base, Value = ' Browse ')
  printButton = Widget_Button(pntr2base, Value = ' Print ', $
		   Event_Pro = 'compare_hist_print')
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

  XManager, "mql_printCphist", pntrbase, Event_Handler = "print_event"
          
end

;***********************************************************************

pro compare_hist_print_data, event


  Widget_Control, event.top, Get_UValue=printhistinfo
  Widget_Control, printhistinfo.hinfo.info.Quicklook, Get_UValue=info

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


        for i = 0,2 do begin
            len = strlen(name)
            newname = strmid(name,0,len-1)
            newname = newname + strcompress(string(i+1),/remove_all)

            filename = disk + path + newname + '.txt'
            Widget_Control, printhistinfo.selectfile, Set_Value = filename
            openw,lun,filename,error=err,/get_lun
            graphno = i
            if(printhistinfo.type eq 1)then $
              mql_update_compare_histo,graphno,printhistinfo.hinfo,/ascii,unit=lun

            if(printhistinfo.type eq 2)then $
              mql_update_Slopecompare_histo,graphno,printhistinfo.hinfo,/ascii,unit=lun
            close,lun
            free_lun,lun
        endfor
        

    endelse
      if printfil eq 1 then Widget_Control, info.Quicklook, Set_UValue=info
      Widget_Control, event.top, /Destroy
end
;_______________________________________________________________________

;_______________________________________________________________________
; Main print routine for data
pro print_compare_histo_data,hinfo

Widget_Control, hinfo.info.QuickLook, Get_UValue=info
type = hinfo.type
outname = hinfo.outname

  ; Pop up a small widget so the user can type in a file name.
  ; Wait for the user to type a carriage-return.
  if(XRegistered("mql_printCphist_data")) then return

; widget window parameters
  xwidget_size = 900
  ywidget_size = 110

  xsize_scroll = 700
  ysize_scroll = 110

  if(type eq 1) then grouplead =  info.HistocompareQuickLook
  if(type eq 2) then grouplead =  info.HistoSlopecompareQuickLook


  if(info.control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.control.x_scroll_window
  if(info.control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.control.y_scroll_window
  if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
  if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10

  otype = 0
  path = info.control.dirps
  slash = '/'
  if(path eq "") then slash = ''


  filename = info.control.dirps + slash  + $
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
		    Event_Pro = 'compare_hist_print_data')
  pntr2base  = Widget_Base  (pntrbase, /Row)


  label3     = Widget_Label (pntr2base, Value = '     ')
  browseButton = Widget_Button(pntr2base, Value = ' Browse ')
  printButton = Widget_Button(pntr2base, Value = ' Print ', $
		   Event_Pro = 'compare_hist_print_data')
  cancelButton = Widget_Button(pntr2base, Value = ' Cancel ')

  printhistinfo = {selectfile    :     selectfile,   $
 		   browseButton  :     browseButton, $
		   cancelButton  :     cancelButton, $
                   filename      :     filename,     $
                   dirps         :     info.control.dirps,$
                   type          :     type,         $
		   hinfo          :     hinfo        }

  Widget_Control, pntrbase, set_uvalue = printhistinfo
  Widget_Control, pntrbase, /Realize

  XManager, "mql_printCphist_data", pntrbase, Event_Handler = "print_data_event"
          
end
