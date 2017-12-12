@file_decompose.pro

pro rslice_print, event

  Widget_Control, event.top, Get_UValue=printrsliceinfo
  Widget_Control, printrsliceinfo.cinfo.info.Quicklook, Get_UValue=info

      ; Get the file name the user typed in.
  Widget_Control, printrsliceinfo.selectfile, Get_Value = filename
  printrsliceinfo.filename = filename
  Widget_Control, event.top, Set_UValue=printrsliceinfo

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
        
        Case (printrsliceinfo.otype) of
            
	  0: Begin  ; write postscript
              set_plot, 'ps', /copy
	     filename = disk + path + name + '.ps'
	     Widget_Control, printrsliceinfo.selectfile, Set_Value = filename
             device, /landscape, file=filename, /color, encapsulated=0

             if(printrsliceinfo.type le 2) then mql_update_rowslice,printrsliceinfo.cinfo,/ps
             if(printrsliceinfo.type ge 3) then msql_update_rowslice,printrsliceinfo.cinfo,/ps
             device,/close
             set_plot, 'x'
           end

          1: Begin  ; write encapsulated postscript
	     set_plot, 'ps', /copy
	     filename = disk + path + name + '.eps'
	     Widget_Control, printrsliceinfo.selectfile, Set_Value = filename
             device, /landscape, file=filename, /color, encapsulated=1
             if(printrsliceinfo.type le 2) then mql_update_rowslice,printrsliceinfo.cinfo,/eps
             if(printrsliceinfo.type ge 3) then msql_update_rowslice,printrsliceinfo.cinfo,/eps

             device,/close
             set_plot, 'x'
           end

           2: Begin             ; write JPEG
             filename = disk + path + name + '.jpg' 
             Widget_Control, printrsliceinfo.selectfile, Set_Value = filename
             wset,printrsliceinfo.cinfo.draw_window_id
;             image3d = TVRead(filename=filename,/JPEG,/nodialog)
	     image3d = tvrd(true=1)
	     write_jpeg,filename,image3d,true=1
         end

         3: Begin               ; write PNG

             filename = disk + path + name
             Widget_Control, printrsliceinfo.selectfile, Set_Value = filename
             wset,printrsliceinfo.cinfo.draw_window_id
             image3d = TVRead(filename=filename,/PNG,/nodialog)
             

         end
         4: Begin               ; write GIF
             filename = disk + path + name 
             Widget_Control, printrsliceinfo.selectfile, Set_Value = filename
             wset,printrsliceinfo.cinfo.draw_window_id

             image3d = TVRead(filename=filename,/GIF,/nodialog)
         end

           else:
       endcase
   endelse

      if printfil eq 1 then Widget_Control, info.Quicklook, Set_UValue=info
      Widget_Control, event.top, /Destroy
      end  
;_______________________________________________________________________
;_______________________________________________________________________
pro print_rslice, cinfo

Widget_Control, cinfo.info.QuickLook, Get_UValue=info
type = cinfo.type
outname = cinfo.outname
if(type eq 0) then grouplead =  info.RSRawQuickLook
if(type eq 1) then grouplead =  info.RSZoomQuickLook
if(type eq 2) then grouplead =  info.RSSlopeQuickLook
if(type eq 3) then grouplead =  info.RS1_SlopeQuickLook
if(type eq 4) then grouplead =  info.RS2_SlopeQuickLook
if(type eq 5) then grouplead =  info.RS3_SlopeQuickLook

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
  cr = strcompress(string(fix(cinfo.rownum_start)),/remove_all)

  filename = info.control.dirps + '/' + info.control.filebase + $
             outname  + cr + '.ps'

  title      = 'MIRI Quicklook Print Column Slice'
  pntrbase   = Widget_Base  (Title = title, /Column, Group_Leader=grouplead, $
                           xsize = xwidget_size,$
                           ysize = ywidget_size,/scroll,$
                           x_scroll_size= xsize_scroll,$
                           y_scroll_size = ysize_scroll)			      
  pntr1base =  Widget_Base(pntrbase, /Row)
  label      = Widget_Label (pntr1base, Value='Output file name:') 
  selectfile = Widget_Text  (pntr1base, Value = filename, XSize = 120, /Edit, $
		    Event_Pro = 'rslice_print')
  pntr2base  = Widget_Base  (pntrbase, /Row)
  tnames = ['PostScript', 'Encapsulated Postscript', 'JPEG', 'PNG', 'GIF']
  otypeButtons = cw_bgroup(pntr2base, tnames, row=1, label_left='File type:', $
	      uvalue='obutton', set_value=otype, exclusive=1, $
	      /no_release)
  label3     = Widget_Label (pntr2base, Value = '     ')
  browseButton = Widget_Button(pntr2base, Value = ' Browse ')
  printButton = Widget_Button(pntr2base, Value = ' Print ', $
		   Event_Pro = 'rslice_print')
  cancelButton = Widget_Button(pntr2base, Value = ' Cancel ')

  dirps = info.control.dirps
  printrsliceinfo = {selectfile    :     selectfile,   $
 		   browseButton  :     browseButton, $
		   cancelButton  :     cancelButton, $
		   otypeButtons  :     otypeButtons, $
                   otype         :     otype,        $
                   dirps         :     dirps,        $
                   filename      :     filename,     $
                   type          :     type,         $ 
		   cinfo         :     cinfo        }

  Widget_Control, pntrbase, set_uvalue = printrsliceinfo
  Widget_Control, pntrbase, /Realize

  XManager, "mql_printrslice", pntrbase, Event_Handler = "print_event"
          
end




;***********************************************************************
pro rslice_print_data, event

  Widget_Control, event.top, Get_UValue=printrsliceinfo
  Widget_Control, printrsliceinfo.cinfo.info.Quicklook, Get_UValue=info

      ; Get the file name the user typed in.
  Widget_Control, printrsliceinfo.selectfile, Get_Value = filename
  printrsliceinfo.filename = filename
  Widget_Control, event.top, Set_UValue=printrsliceinfo

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
        Widget_Control, printrsliceinfo.selectfile, Set_Value = filename
        
        openw,lun,filename,error=err,/get_lun

        if(printrsliceinfo.type le 2) then mql_update_rowslice,printrsliceinfo.cinfo,/ascii,unit=lun
        if(printrsliceinfo.type ge 3) then msql_update_rowslice,printrsliceinfo.cinfo,/ascii,unit=lun
        close,lun
        free_lun,lun

   endelse

      if printfil eq 1 then Widget_Control, info.Quicklook, Set_UValue=info
      Widget_Control, event.top, /Destroy
      end  
;_______________________________________________________________________

pro print_rslice_data, cinfo

Widget_Control, cinfo.info.QuickLook, Get_UValue=info
type = cinfo.type
outname = cinfo.outname
if(type eq 0) then grouplead =  info.RSRawQuickLook
if(type eq 1) then grouplead =  info.RSZoomQuickLook
if(type eq 2) then grouplead =  info.RSSlopeQuickLook
if(type eq 3) then grouplead =  info.RS1_SlopeQuickLook
if(type eq 4) then grouplead =  info.RS2_SlopeQuickLook
if(type eq 5) then grouplead =  info.RS3_SlopeQuickLook

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
  filename = info.control.dirps + '/' + info.control.filebase + $
             outname  + '.txt'

  title      = 'MIRI Quicklook Print Column Slice'
  pntrbase   = Widget_Base  (Title = title, /Column, Group_Leader=grouplead, $
                           xsize = xwidget_size,$
                           ysize = ywidget_size,/scroll,$
                           x_scroll_size= xsize_scroll,$
                           y_scroll_size = ysize_scroll)			      
  pntr1base =  Widget_Base(pntrbase, /Row)
  label      = Widget_Label (pntr1base, Value='Output file name:') 
  selectfile = Widget_Text  (pntr1base, Value = filename, XSize = 120, /Edit, $
		    Event_Pro = 'rslice_print_data')
  pntr2base  = Widget_Base  (pntrbase, /Row)

  label3     = Widget_Label (pntr2base, Value = '     ')
  browseButton = Widget_Button(pntr2base, Value = ' Browse ')
  printButton = Widget_Button(pntr2base, Value = ' Print ', $
		   Event_Pro = 'rslice_print_data')
  cancelButton = Widget_Button(pntr2base, Value = ' Cancel ')


  printrsliceinfo = {selectfile    :     selectfile,   $
 		   browseButton  :     browseButton, $
		   cancelButton  :     cancelButton, $
                   dirps         :     info.control.dirps,$
                   filename      :     filename,     $
                   type          :     type,         $ 
		   cinfo         :     cinfo        }

  Widget_Control, pntrbase, set_uvalue = printrsliceinfo
  Widget_Control, pntrbase, /Realize

  XManager, "mql_printrslicedata", pntrbase, Event_Handler = "print_data_event"
          
end
