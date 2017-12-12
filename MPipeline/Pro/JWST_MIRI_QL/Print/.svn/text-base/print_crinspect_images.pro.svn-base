@file_decompose.pro


;_______________________________________________________________________
pro crinspect_images_print, event

  Widget_Control, event.top, Get_UValue=printimageinfo
  Widget_Control, printimageinfo.info.Quicklook, Get_UValue=info

  imageno = printimageinfo.imageno

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
             
             micrql_update_images,info,imageno,/ps
             device,/close
             set_plot, 'x'
           end

          1: Begin  ; write encapsulated postscript
	     set_plot, 'ps', /copy
	     filename = disk + path + name + '.eps'
	     Widget_Control, printimageinfo.selectfile, Set_Value = filename
             device,  file=filename, /color,/landscape, encapsulated=1
             micrql_update_images,info,imageno,/ps

             device,/close
             set_plot, 'x'
         end


          2: Begin  ; write JPEG
	     filename = disk + path + name 
	     Widget_Control, printimageinfo.selectfile, Set_Value = filename
             wset,info.crinspect[imageno].draw_window_id
             image3d = TVRead(filename=filename,/JPEG,/nodialog)
             image3d = 0

         end

         3: Begin               ; write PNG


             filename = disk + path + name 
             Widget_Control, printimageinfo.selectfile, Set_Value = filename

             wset,info.crinspect[imageno].draw_window_id
             image3d = TVRead(filename=filename,/PNG,/nodialog)
             image3d = 0
         end

          4: Begin  ; write GIF
	     filename = disk + path + name 
	     Widget_Control, printimageinfo.selectfile, Set_Value = filename

             wset,info.crinspect[imageno].draw_window_id
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
;_______________________________________________________________________
pro print_crinspect_images,info,imageno


  ; Pop up a small widget so the user can type in a file name.
  ; Wait for the user to type a carriage-return.
if(XRegistered("mciql_printimage")) then return

jintegration = info.crinspect[imageno].integrationNO+1

ij = 'int' + string(jintegration) 
ij = strcompress(ij,/remove_all)

mtitle = ' ' 

outname = info.output.inspect_rawimage + '_' + ij
mtitle = 'MIRI Quicklook Print Science Image'
	  
otype = 0
path = info.control.dirps
slash = '/'
if(path eq "") then slash = ''
filename = info.control.dirps + slash + info.control.filebase + $
           outname + '.ps'

; widget window parameters
  xwidget_size = 900
  ywidget_size = 110

  xsize_scroll = 700
  ysize_scroll = 110

  if(info.control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.control.x_scroll_window
  if(info.control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.control.y_scroll_window
  if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
  if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10
pntrbase   = Widget_Base  (Title = mtitle, /Column, $
                           Group_Leader=info.Quicklook, $
                           ;			      /Modal)
                           xsize = xwidget_size,$
                           ysize = ywidget_size,/scroll,$
                           x_scroll_size= xsize_scroll,$
                           y_scroll_size = ysize_scroll)
pntr1base =  Widget_Base(pntrbase, /Row)
label      = Widget_Label (pntr1base, Value='Output file name:') 
selectfile = Widget_Text  (pntr1base, Value = filename, XSize = 100, /Edit, $
                           Event_Pro = 'crinspect_images_print')
pntr2base  = Widget_Base  (pntrbase, /Row)
tnames = ['PostScript', 'Encapsulated Postscript', 'JPEG', 'PNG', 'GIF']
otypeButtons = cw_bgroup(pntr2base, tnames, row=1, label_left='File type:', $
                         uvalue='obutton', set_value=otype, exclusive=1, $
                         /no_release)
label3     = Widget_Label (pntr2base, Value = '     ')
browseButton = Widget_Button(pntr2base, Value = ' Browse ')
printButton = Widget_Button(pntr2base, Value = ' Print ', $
                            Event_Pro = 'crinspect_images_print')
cancelButton = Widget_Button(pntr2base, Value = ' Cancel ')

printimageinfo = {selectfile    :     selectfile,   $
                  browseButton  :     browseButton, $
                  cancelButton  :     cancelButton, $
                  otypeButtons  :     otypeButtons, $
                  otype         :     otype,        $
                  filename      :     filename,     $
                  imageno       :      imageno,     $
                  dirps         :     info.control.dirps,$
                  info         :     info        }

Widget_Control, pntrbase, set_uvalue = printimageinfo
Widget_Control, pntrbase, /Realize

XManager, "mciql_printimage", pntrbase, Event_Handler = "print_event"

end
