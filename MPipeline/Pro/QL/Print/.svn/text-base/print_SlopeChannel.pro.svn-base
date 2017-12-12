@file_decompose.pro

;_______________________________________________________________________

pro Slopechannel_print, event

  Widget_Control, event.top, Get_UValue=printchannelinfo
  Widget_Control, printchannelinfo.info.Quicklook, Get_UValue=info

      ; Get the file name the user typed in.
  Widget_Control, printchannelinfo.selectfile, Get_Value = filename
  printchannelinfo.filename = filename
  Widget_Control, event.top, Set_UValue=printchannelinfo

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
        
        Case (printchannelinfo.otype) of
            
	  0: Begin  ; write postscript
              set_plot, 'ps', /copy
	     filename = disk + path + name + '.ps'
	     Widget_Control, printchannelinfo.selectfile, Set_Value = filename
             device, /landscape, file=filename, /color, encapsulated=0
             for i = 0,4 do begin
                 mql_update_SlopeChannel,i,info,/ps
             endfor
             plot_image = (*info.Slopechannel.pplot_image)
             iramp = info.ChannelS[0].iramp 
             jintegration = info.ChannelS[0].jintegration
             svalue = " 5 Reuced Channel Plots: " + info.control.filename_raw
             ftitle = " Frame #: " + strtrim(string(fix(iramp)+1),2) 
             ititle = " Integration #: " + strtrim(string(fix(jintegration)+1),2)
             stitle = ititle + ftitle
             pscoords,plot_image 
             plot,[0],/noerase,/nodata,title =svalue,xstyle=5,ystyle=5,charsize=0.75,subtitle=stitle
             xloc = [90,350, 600, 850, 1100]
             for i = 0, 4 do begin
                 mean = info.ChannelS[i].sd_mean
                 min = info.ChannelS[i].sd_min
                 max = info.ChannelS[i].sd_max
                 smean = "Mean: " + strcompress(string(mean),/remove_all)
                 smin =  "Min:  " + strcompress(string(min),/remove_all)
                 smax =  "Max:  "  +strcompress(string(max),/remove_all)

                 xyouts,xloc[i],-15,'SlopeChannel '+strcompress(string(fix(i+1)),/remove_all),charsize=0.75
                 xyouts,xloc[i],-100,smean,charsize=0.75
                 xyouts,xloc[i],-120,smin,charsize=0.75
                 xyouts,xloc[i],-140,smax,charsize=0.75
             endfor

             device,/close
             set_plot, 'x'
           end

          1: Begin  ; write encapsulated postscriptidl
	     set_plot, 'ps', /copy
	     filename = disk + path + name + '.eps'
	     Widget_Control, printchannelinfo.selectfile, Set_Value = filename
             device, /portrait, file=filename, /color, encapsulated=1
             for i = 0,4 do begin
                 mql_update_SlopeChannel,i,info,/eps
             endfor
             device,/close
             set_plot, 'x'
             !p.multi = 0
         end


          2: Begin  ; write JPEG
	     filename = disk + path + name + '.jpg'
	     Widget_Control, printchannelinfo.selectfile, Set_Value = filename

             wset,info.SlopeChannel.draw_window_id[0]
             im1 = tvrd(true=1)
             wset,info.SlopeChannel.draw_window_id[1]
             im2 = tvrd(true=1)
             wset,info.SlopeChannel.draw_window_id[2]
             im3 = tvrd(true=1)
             wset,info.SlopeChannel.draw_window_id[3]
             im4 = tvrd(true=1)
             wset,info.SlopeChannel.draw_window_id[4]
             im5 = tvrd(true=1)
             
             s = size(im1)
             xsize = s[2]
             im = fltarr(s[1],s[2]*5,s[3])
             im[*,0:xsize-1,*] = im1
             im[*,xsize:xsize*2-1,*] = im2
             im[*,xsize*2:xsize*3-1,*] = im3
             im[*,xsize*3:xsize*4-1,*] = im4
             im[*,xsize*4:xsize*5-1,*] = im5
             im1 = 0 & im2 = 0 & im3 = 0 & im4 = 0 & im5 = 0


             write_jpeg,filename,im,true = 1
             im = 0
         end


         3: Begin               ; write PNG

             filename = disk + path + name + '.png'
	     Widget_Control, printchannelinfo.selectfile, Set_Value = filename

             wset,info.SlopeChannel.draw_window_id[0]
             im1 = tvrd(true=1)
             wset,info.SlopeChannel.draw_window_id[1]
             im2 = tvrd(true=1)
             wset,info.SlopeChannel.draw_window_id[2]
             im3 = tvrd(true=1)
             wset,info.SlopeChannel.draw_window_id[3]
             im4 = tvrd(true=1)
             wset,info.SlopeChannel.draw_window_id[4]
             im5 = tvrd(true=1)
             
             s = size(im1)
             xsize = s[2]
             im = fltarr(s[1],s[2]*5,s[3])
             im[*,0:xsize-1,*] = im1
             im[*,xsize:xsize*2-1,*] = im2
             im[*,xsize*2:xsize*3-1,*] = im3
             im[*,xsize*3:xsize*4-1,*] = im4
             im[*,xsize*4:xsize*5-1,*] = im5
             im1 = 0 & im2 = 0 & im3 = 0 & im4 = 0 & im5 = 0


             Write_PNG, filename, im, _Extra=extra


             im = 0
         end
         4: Begin               ; write GIF
             filename = disk + path + name + '.gif'
             Widget_Control, printchannelinfo.selectfile, Set_Value = filename

             wset,info.SlopeChannel.draw_window_id[0]
             im1 = tvrd()
             wset,info.SlopeChannel.draw_window_id[1]
             im2 = tvrd()
             wset,info.SlopeChannel.draw_window_id[2]
             im3 = tvrd()
             wset,info.SlopeChannel.draw_window_id[3]
             im4 = tvrd()
             wset,info.SlopeChannel.draw_window_id[4]
             im5 = tvrd()
             
             s = size(im1)
             xsize = s[1]
             im = bytarr(s[1]*5,s[2])
             im[0:xsize-1,*] = im1
             im[xsize:xsize*2-1,*] = im2
             im[xsize*2:xsize*3-1,*] = im3
             im[xsize*3:xsize*4-1,*] = im4
             im[xsize*4:xsize*5-1,*] = im5

             TVLCT, r, g, b, /Get
             
             Write_gif, filename, im,r,g,b
             write_gif,filename,/close

             im = 0
             im1 = 0 & im2 = 0 & im3 = 0 & im4 = 0 & im5 = 0
         end

           else:
       endcase
   endelse

      if printfil eq 1 then Widget_Control, info.Quicklook, Set_UValue=info
      Widget_Control, event.top, /Destroy
      end  
;_______________________________________________________________________
pro print_SlopeChannel_event, event

  Widget_Control, event.top, Get_UValue=printchannelinfo
  Widget_Control, printchannelinfo.info.QuickLook, Get_UValue=info


  case event.id of
      printchannelinfo.otypeButtons: begin
          otype = event.value
          printchannelinfo.otype = otype
          fileold = printchannelinfo.filename
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


          printchannelinfo.filename = filenew
          Widget_Control, printchannelinfo.selectfile, set_value=filenew
      end
      
      printchannelinfo.browseButton: begin
          pout = strcompress(info.control.dirps + '/',/remove_all)
          Pathvalue = Dialog_Pickfile(/read,Title='Please select output file path', $
                                      Path=pout, Get_Path=realpath,filter='*.fits')

          Widget_Control, printchannelinfo.selectfile, set_value=realpath
          printchannelinfo.filename = realpath
      end

      printchannelinfo.cancelButton: begin
          ptype = 'x'
          set_plot, ptype
          Widget_Control, info.Quicklook, Set_UValue=info
          Widget_Control, event.top, /Destroy
          return
      end

  endcase

  Widget_Control, event.top, Set_UValue=printchannelinfo
  Widget_Control, printchannelinfo.info.Quicklook, Set_UValue=info

end

;_______________________________________________________________________
pro print_SlopeChannel, info

  ; Pop up a small widget so the user can type in a file name.
  ; Wait for the user to type a carriage-return.
  if(XRegistered("mql_printSlopeChannel")) then return

; widget window parameters
  xwidget_size = 900
  ywidget_size = 110

  xsize_scroll = 900
  ysize_scroll = 110

  if(info.control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.control.x_scroll_window
  if(info.control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.control.y_scroll_window
  if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
  if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10

  hname = ' ' 
  
  otype = 0
  path = info.control.dirps
  slash = '/'
  if(path eq "") then slash = ''


  ij = 'int' + string(info.image.integrationNO+1)+'_frame' + string(info.image.rampNo+1)
  ij = strcompress(ij,/remove_all)

  outname = info.output.slopechannel + '_' + ij

  filename = info.control.dirps + slash + info.control.filebase + $
             outname  + '.ps'

  title      = 'MIRI Quicklook Print 5 Reduced Channel Images'
  pntrbase   = Widget_Base  (Title = title, /Column, Group_Leader=info.SlopeChannelQuickLook, $
;			      /Modal)
                           xsize = xwidget_size,$
                           ysize = ywidget_size,/scroll,$
                           x_scroll_size= xsize_scroll,$
                           y_scroll_size = ysize_scroll)		      
  pntr1base =  Widget_Base(pntrbase, /Row)
  label      = Widget_Label (pntr1base, Value='Output file name:') 
  selectfile = Widget_Text  (pntr1base, Value = filename, XSize = 120, /Edit, $
		    Event_Pro = 'SlopeChannel_print')
  pntr2base  = Widget_Base  (pntrbase, /Row)
  tnames = ['PostScript', 'Encapsulated Postscript', 'JPEG', 'PNG', 'GIF']
  otypeButtons = cw_bgroup(pntr2base, tnames, row=1, label_left='File type:', $
	      uvalue='obutton', set_value=otype, exclusive=1, $
	      /no_release)
  label3     = Widget_Label (pntr2base, Value = '     ')
  browseButton = Widget_Button(pntr2base, Value = ' Browse ')
  printButton = Widget_Button(pntr2base, Value = ' Print ', $
		   Event_Pro = 'SlopeChannel_print')
  cancelButton = Widget_Button(pntr2base, Value = ' Cancel ')

  printchannelinfo = {selectfile    :     selectfile,   $
 		   browseButton  :     browseButton, $
		   cancelButton  :     cancelButton, $
		   otypeButtons  :     otypeButtons, $
                   otype         :     otype,        $
                   filename      :     filename,     $
		    info         :     info        }

  Widget_Control, pntrbase, set_uvalue = printchannelinfo
  Widget_Control, pntrbase, /Realize

  XManager, "mql_printSlopeChannel", pntrbase, Event_Handler = "print_SlopeChannel_event"
          
end
