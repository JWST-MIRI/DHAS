@file_decompose.pro

pro timeordered_print, event

  Widget_Control, event.top, Get_UValue=printimageinfo
  Widget_Control, printimageinfo.info.Quicklook, Get_UValue=info


      ; Get the file name the user typed in.
  Widget_Control, printimageinfo.selectfile, Get_Value = filename
  printimageinfo.filename = filename
  Widget_Control, event.top, Set_UValue=printimageinfo

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
        
        Case (printimageinfo.otype) of
            
	  0: Begin  ; write postscript
              set_plot, 'ps', /copy
	     filename = disk + path + name + '.ps'
	     Widget_Control, printimageinfo.selectfile, Set_Value = filename
             device, file=filename, /landscape,/color, encapsulated=0


             mql_update_TimeChannel,info,/ps

             device,/close
             set_plot, 'x'
           end

          1: Begin  ; write encapsulated postscript
	     set_plot, 'ps', /copy
	     filename = disk + path + name + '.eps'
	     Widget_Control, printimageinfo.selectfile, Set_Value = filename
             device,  file=filename, /color,/landscape, encapsulated=1

             mql_update_TimeChannel,info,/ps

             device,/close
             set_plot, 'x'
         end

          2: Begin  ; write JPEG
	     filename = disk + path + name 
	     Widget_Control, printimageinfo.selectfile, Set_Value = filename
             wset,info.TimeChannel.draw_window_id
             image3d = TVRead(filename=filename,/JPEG,/nodialog)
             image3d = 0
         end

         3: Begin               ; write PNG
             filename = disk + path + name 
             Widget_Control, printimageinfo.selectfile, Set_Value = filename
             wset,info.TimeChannel.draw_window_id
             image3d = TVRead(filename=filename,/PNG,/nodialog)
             image3d = 0

         end

          4: Begin  ; write GIF
	     filename = disk + path + name 
	     Widget_Control, printimageinfo.selectfile, Set_Value = filename
             wset,info.TimeChannel.draw_window_id
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
pro print_timeordered_event, event

  Widget_Control, event.top, Get_UValue=printimageinfo
  Widget_Control, printimageinfo.info.QuickLook, Get_UValue=info
  case event.id of
      printimageinfo.otypeButtons: begin
          otype = event.value
          printimageinfo.otype = otype

          fileold = printimageinfo.filename
          filenew = fileold

          len = strlen(fileold)          
          test2 = strmid(fileold,len-3,1)
          test3 = strmid(fileold,len-4,1)
          lenback = len - 3
          if(test2 eq '.' ) then lenback = len - 2
          
          if(otype eq 0) then filenew = strmid(fileold,0,lenback) + 'ps'
          if(otype eq 1) then filenew = strmid(fileold,0,lenback) + 'eps'
          if(otype eq 2) then filenew = strmid(fileold,0,lenback) + 'jpg'
          if(otype eq 3) then filenew = strmid(fileold,0,lenback) + 'png'
          if(otype eq 4) then filenew = strmid(fileold,0,lenback) + 'gif'

          printimageinfo.filename = filenew
          Widget_Control, printimageinfo.selectfile, set_value=filenew
      end
      
      printimageinfo.browseButton: begin
          pout = strcompress(info.control.dirps + '/',/remove_all)
          Pathvalue = Dialog_Pickfile(/read,Title='Please select output file path', $
                                      Path=pout, Get_Path=realpath,filter='*.fits')

          Widget_Control, printimageinfo.selectfile, set_value=realpath
          printimageinfo.filename = realpath
      end

      printimageinfo.cancelButton: begin
          ptype = 'x'
          set_plot, ptype
          Widget_Control, info.Quicklook, Set_UValue=info
          Widget_Control, event.top, /Destroy
          return
      end

  endcase

  Widget_Control, event.top, Set_UValue=printimageinfo
  Widget_Control, printimageinfo.info.Quicklook, Set_UValue=info

end

;_______________________________________________________________________
pro print_timeordered,info


  ; Pop up a small widget so the user can type in a file name.
  ; Wait for the user to type a carriage-return.
if(XRegistered("mrp_printtime")) then return

iframe = info.TimeChannel.frameNO+1


jintegration = info.TimeChannel.integrationNO+1

ij = 'int' + string(jintegration) + '_frame' + string(iframe)  
ij = strcompress(ij,/remove_all)



mtitle = ' ' 

outname = info.output.timeorder + '_' + ij
mtitle = 'MIRI Quicklook Print Pixels in time order'


	  
otype = 0
path = info.control.dirps
slash = '/'
if(path eq "") then slash = ''
filename = info.control.dirps + slash + info.control.filebase + $
           outname + '.ps'


; widget window parameters
  xwidget_size = 1200
  ywidget_size = 110

  xsize_scroll = 900
  ysize_scroll = 110


  if(info.control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.control.x_scroll_window
  if(info.control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.control.y_scroll_window
  if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
  if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10

pntrbase   = Widget_Base  (Title = mtitle, /Column, $
                           Group_Leader=info.TimeChannelQuickLook, $
                           xsize = xwidget_size,$
                           ysize = ywidget_size,/scroll,$
                           x_scroll_size= xsize_scroll,$
                           y_scroll_size = ysize_scroll)                          
pntr1base =  Widget_Base(pntrbase, /Row)
label      = Widget_Label (pntr1base, Value='Output file name:') 
selectfile = Widget_Text  (pntr1base, Value = filename, XSize = 150, /Edit, $
                           Event_Pro = 'timeordered_print')
pntr2base  = Widget_Base  (pntrbase, /Row)

tnames = ['PostScript', 'Encapsulated Postscript', 'JPEG', 'PNG', 'GIF']
otypeButtons = cw_bgroup(pntr2base, tnames, row=1, label_left='File type:', $
                         uvalue='obutton', set_value=otype, exclusive=1, $
                         /no_release)
label3     = Widget_Label (pntr2base, Value = '     ')
browseButton = Widget_Button(pntr2base, Value = ' Browse ')
printButton = Widget_Button(pntr2base, Value = ' Print ', $
                            Event_Pro = 'timeordered_print')
cancelButton = Widget_Button(pntr2base, Value = ' Cancel ')

printimageinfo = {selectfile    :     selectfile,   $
                  browseButton  :     browseButton, $
                  cancelButton  :     cancelButton, $
                  otypeButtons  :     otypeButtons, $
                  otype         :     otype,        $
                  filename      :     filename,     $
                  info         :     info        }

Widget_Control, pntrbase, set_uvalue = printimageinfo
Widget_Control, pntrbase, /Realize

XManager, "mrp_printtime", pntrbase, Event_Handler = "print_timeordered_event"

end
