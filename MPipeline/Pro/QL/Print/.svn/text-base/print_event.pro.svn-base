pro print_event, event

  Widget_Control, event.top, Get_UValue=printinfo
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
          pout = strcompress(printinfo.dirps + '/',/remove_all)
          Pathvalue = Dialog_Pickfile(/read,Title='Please select output file path', $
                                      Path=pout, Get_Path=realpath)

          if(pathvalue ne '') then begin 
              Widget_Control, printinfo.selectfile, set_value=realpath
              printinfo.filename = realpath
          endif
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


;_______________________________________________________________________

pro print_data_event, event

  Widget_Control, event.top, Get_UValue=printinfo
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

