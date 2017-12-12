

;***********************************************************************
;_______________________________________________________________________
@file_decompose.pro

pro spec_print_data, event

  Widget_Control, event.top, Get_UValue=printinfo
  Widget_Control, printinfo.info.CubeView, Get_UValue=info


                                ; Get the file name the user typed in.
  Widget_Control, printinfo.selectfile, Get_Value = filename
  printinfo.filename = filename
  Widget_Control, event.top, Set_UValue=printinfo

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
        Widget_Control, printinfo.selectfile, Set_Value = filename
        cube = info.cube
        spectrum = info.spectrum

        print_spectrum_data,filename,cube,spectrum
        cube = 0
        spectrum = 0
   endelse

   if printfil eq 1 then Widget_Control, info.Cubeview, Set_UValue=info
   Widget_Control, event.top, /Destroy
end  
;_______________________________________________________________________

;_______________________________________________________________________
pro spec_print_data_event, event

  Widget_Control, event.top, Get_UValue=printinfo
  Widget_Control, printinfo.info.CubeView, Get_UValue=info
  case event.id of
      
      printinfo.browseButton: begin
          pout = strcompress(info.control.dirps + '/',/remove_all)
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
;_______________________________________________________________________
pro cv_spec_print_data, info


if(XRegistered("cv_printspecdata")) then return


w = get_screen_size()
xwidget_size = w[0]*.7
ywidget_size = 100

  
otype = 0
path = info.control.dirps
slash = '/'
if(path eq "") then slash = ''
outname = "_extracted_spectra"

print,info.control.file_cube_base

filename = info.control.dirps + slash + info.control.file_cube_base + $
             outname  + '.txt'

  title      = 'MIRI CubeView Print Spectral Data'
  pntrbase   = Widget_Base  (Title=title, /Column,Group_Leader=info.CubeView, $
                           xsize = xwidget_size,$
                           ysize = ywidget_size)

  pntr1base =  Widget_Base(pntrbase, /Row)
  label      = Widget_Label (pntr1base, Value='Output file name:') 
  selectfile = Widget_Text  (pntr1base, Value = filename, XSize = 120, /Edit, $
		    Event_Pro = 'spec_print_data')
  pntr2base  = Widget_Base  (pntrbase, /Row)
  label3     = Widget_Label (pntr2base, Value = '     ')
  browseButton = Widget_Button(pntr2base, Value = ' Browse ')
  printButton = Widget_Button(pntr2base, Value = ' Print ', $
		   Event_Pro = 'spec_print_data')
  cancelButton = Widget_Button(pntr2base, Value = ' Cancel ')

  dirps = info.control.dirps 
  printinfo = {selectfile    :     selectfile,   $
               browseButton  :     browseButton, $
               cancelButton  :     cancelButton, $
               otype         :     otype,        $
               filename      :     filename,     $
               info          :     info        }

  Widget_Control, pntrbase, set_uvalue = printinfo
  Widget_Control, pntrbase, /Realize

  XManager, "cv_printspecdata", pntrbase, Event_Handler = "spec_print_data_event"
          
end
;***********************************************************************
;***********************************************************************


