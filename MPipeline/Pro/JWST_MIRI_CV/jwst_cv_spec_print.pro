;***********************************************************************
;_______________________________________________________________________
@file_decompose.pro

pro jwst_spec_print, event

  Widget_Control, event.top, Get_UValue=printinfo
  Widget_Control, printinfo.info.CubeView, Get_UValue=info


                                ; Get the file name the user typed in.
  Widget_Control, printinfo.selectfile, Get_Value = filename
  printinfo.filename = filename
  Widget_Control, event.top, Set_UValue=printinfo

  filename = strtrim(filename[0], 2)
  file_decompose, filename, disk,path, name, extn, version
  if strlen(extn) eq 0 then filename = filename + '.ps'

  IF (!D.Flags AND 256) NE 0 THEN BEGIN
      Device, Get_Decomposed=theDecomposedState, Get_Visual_Depth=theDepth
      IF theDepth GT 8 THEN BEGIN
          Device, Decomposed=1
          color24 = 1
      ENDIF ELSE truecolor = 0
  ENDIF ELSE BEGIN
      color24 = 0
      theDepth = 8
  ENDELSE

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
        
        Case (printinfo.otype) of
            
	  0: Begin  ; write postscript
              set_plot, 'ps', /copy
	     filename = disk + path + name + '.ps'
	     Widget_Control, printinfo.selectfile, Set_Value = filename
             device, /landscape, file=filename, /color, encapsulated=0
             jwst_cv_update_spectrum,printinfo.info,/ps
             device,/close
             set_plot, 'x'
           end

          1: Begin  ; write encapsulated postscript
	     set_plot, 'ps', /copy
	     filename = disk + path + name + '.eps'
	     Widget_Control, printinfo.selectfile, Set_Value = filename
             device, /landscape, file=filename, /color, encapsulated=1
             jwst_cv_update_spectrum,printinfo.info,/eps
             device,/close
             set_plot, 'x'
           end

           2: Begin             ; write JPEG
             filename = disk + path + name + '.jpg'
             Widget_Control, printinfo.selectfile, Set_Value = filename
             wset,printinfo.info.view_spectrum.draw_window_id
             image = TVRD(True=color24)
             IF color24 THEN BEGIN
                 image3D = image
             ENDIF ELSE BEGIN
                 TVLCT, r, g, b, /Get
                 image3D = [ [[r[image]]], [[g[image]]], [[b[image]]] ]
                 image3D = Transpose(image3d,[2,0,1])
             ENDELSE
             Write_JPEG, filename, image3D, True=1, Quality=quality, _Extra=extra

         end

         3: Begin               ; write PNG
             filename = disk + path + name + '.png'
             Widget_Control, printinfo.selectfile, Set_Value = filename
             wset,printinfo.info.view_spectrum.draw_window_id
             image = TVRD(True=color24)
             IF color24 THEN BEGIN
                 Write_PNG, filename, image, _Extra=extra
             ENDIF ELSE BEGIN
                 TVLCT, r, g, b, /Get
                 image2D = image
                 Write_PNG, filename, Reverse(image2D,2), r, g, b, _Extra=extra
             ENDELSE
         end
         4: Begin               ; write GIF
             filename = disk + path + name + '.gif'
             Widget_Control, printinfo.selectfile, Set_Value = filename
             wset,printinfo.info.view_spectrum.draw_window_id
             Write_gif, filename, tvrd()
             write_gif,filename,/close
         end
           else:
       endcase
   endelse
    if color24 then device, Decomposed=0
      if printfil eq 1 then Widget_Control, info.Cubeview, Set_UValue=info
      Widget_Control, event.top, /Destroy
  end  
;_______________________________________________________________________

;_______________________________________________________________________
pro jwst_spec_print_event, event

  Widget_Control, event.top, Get_UValue=printinfo
  Widget_Control, printinfo.info.CubeView, Get_UValue=info
  case event.id of
      printinfo.otypeButtons: begin
          otype = event.value
          printinfo.otype = otype

          fileold = printinfo.filename
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

          printinfo.filename = filenew
          Widget_Control, printinfo.selectfile, set_value=filenew
      end
      
      printinfo.browseButton: begin
          pout = strcompress(info.cv_control.dirps + '/',/remove_all)
          Pathvalue = Dialog_Pickfile(/read,Title='Please select output file path', $
                                      Path=pout, Get_Path=realpath,filter='*.fits')

          Widget_Control, printinfo.selectfile, set_value=realpath
          printinfo.filename = realpath
      end

      printinfo.cancelButton: begin
          ptype = 'x'
          set_plot, ptype
          Widget_Control, info.CubeView, Set_UValue=info
          Widget_Control, event.top, /Destroy
          return
      end

  endcase

  Widget_Control, event.top, Set_UValue=printinfo
  Widget_Control, printinfo.info.CubeView, Set_UValue=info

end


;_______________________________________________________________________
pro jwst_cv_spec_print, info


if(XRegistered("jwst_cv_printspec")) then return

w = get_screen_size()
xwidget_size = w[0]*.7
ywidget_size = 100

  
otype = 0
path = info.cv_control.dirps
slash = '/'
if(path eq "") then slash = ''
outname = "_extracted_spectra"

filename = info.cv_control.dirps + slash + info.cv_control.file_cube_base + $
             outname  + '.ps'

  title      = 'MIRI CubeView Print Spectrum'
  pntrbase   = Widget_Base  (Title=title, /Column,Group_Leader=info.CubeView, $
                           xsize = xwidget_size,$
                           ysize = ywidget_size)

  pntr1base =  Widget_Base(pntrbase, /Row)
  label      = Widget_Label (pntr1base, Value='Output file name:') 
  selectfile = Widget_Text  (pntr1base, Value = filename, XSize = 120, /Edit, $
		    Event_Pro = 'spec_print')
  pntr2base  = Widget_Base  (pntrbase, /Row)
  tnames = ['PostScript', 'Encapsulated Postscript', 'JPEG', 'PNG', 'GIF']
  otypeButtons = cw_bgroup(pntr2base, tnames, row=1, label_left='File type:', $
	      uvalue='obutton', set_value=otype, exclusive=1, $
	      /no_release)
  label3     = Widget_Label (pntr2base, Value = '     ')
  browseButton = Widget_Button(pntr2base, Value = ' Browse ')
  printButton = Widget_Button(pntr2base, Value = ' Print ', $
		   Event_Pro = 'spec_print')
  cancelButton = Widget_Button(pntr2base, Value = ' Cancel ')

  dirps = info.cv_control.dirps 
  printinfo = {selectfile    :     selectfile,   $
               browseButton  :     browseButton, $
               cancelButton  :     cancelButton, $
               otypeButtons  :     otypeButtons, $
               otype         :     otype,        $
               dirps         :     dirps,        $
               filename      :     filename,     $
               info          :     info        }

  Widget_Control, pntrbase, set_uvalue = printinfo
  Widget_Control, pntrbase, /Realize

  XManager, "jwst_cv_printspec", pntrbase, Event_Handler = "jwst_spec_print_event"
          
end
;***********************************************************************
;***********************************************************************


