@file_decompose.pro

pro jwst_slope_image_print, event

  Widget_Control, event.top, Get_UValue=printimageinfo
  Widget_Control, printimageinfo.info.jwst_Quicklook, Get_UValue=info
  type = printimageinfo.type

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
             
             if(type eq 0) then jwst_msql_update_slope,info.slope.plane[0],0,info,/ps
             if(type eq 1) then jwst_msql_update_slope,info.slope.plane[1],1,info,/ps
             if(type eq 2) then jwst_msql_update_zoom_image,info,/ps
             if(type eq 3) then jwst_msql_update_slopepixel,info,/ps
             device,/close
             set_plot, 'x'
           end

          1: Begin  ; write encapsulated postscript
	     set_plot, 'ps', /copy
	     filename = disk + path + name + '.eps'
	     Widget_Control, printimageinfo.selectfile, Set_Value = filename
             device,  file=filename, /color,/landscape, encapsulated=1

             if(type eq 0) then jwst_msql_update_slope,info.slope.plane[0],0,info,/eps
             if(type eq 1) then jwst_msql_update_slope,info.slope.plane[1],1,info,/eps
             if(type eq 2) then jwst_msql_update_zoom_image,info,/eps

             if(type eq 3) then jwst_msql_update_slopepixel,info,/eps
             device,/close
             set_plot, 'x'
           end

          2: Begin  ; write JPEG
	     filename = disk + path + name 
	     Widget_Control, printimageinfo.selectfile, Set_Value = filename

             if(type eq 0 ) then  wset,info.slope.draw_window_id[0]
             if(type eq 1) then  wset,info.slope.draw_window_id[1]
             if(type eq 2) then  wset,info.slope.draw_window_id[2]
             if(type eq 3) then  wset,info.slope.draw_window_id[3]
             image3d = TVRead(filename=filename,/JPEG,/nodialog)
             image3d = 0

         end

         3: Begin               ; write PNG
             filename = disk + path + name 
             Widget_Control, printimageinfo.selectfile, Set_Value = filename
             if(type eq 0 ) then  wset,info.slope.draw_window_id[0]
             if(type eq 1) then  wset,info.slope.draw_window_id[1]
             if(type eq 2) then  wset,info.slope.draw_window_id[2]
             if(type eq 3) then  wset,info.slope.draw_window_id[3]

             image3d = TVRead(filename=filename,/PNG,/nodialog)
             image3d = 0         
         end

          4: Begin  ; write GIF
	     filename = disk + path + name 
	     Widget_Control, printimageinfo.selectfile, Set_Value = filename

             if(type eq 0 ) then  wset,info.slope.draw_window_id[0]
             if(type eq 1) then  wset,info.slope.draw_window_id[1]
             if(type eq 2) then  wset,info.slope.draw_window_id[2]
             if(type eq 3) then  wset,info.slope.draw_window_id[3]
             image3d = TVRead(filename=filename,/GIF,/nodialog)
             image3d = 0
         end
           else:
       endcase
   endelse

      if printfil eq 1 then Widget_Control, info.jwst_Quicklook, Set_UValue=info
      Widget_Control, event.top, /Destroy
      end  
;_______________________________________________________________________
pro jwst_print_slope_image_event, event

  Widget_Control, event.top, Get_UValue=printimageinfo
  Widget_Control, printimageinfo.info.jwst_QuickLook, Get_UValue=info
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
          Widget_Control, info.jwst_Quicklook, Set_UValue=info
          Widget_Control, event.top, /Destroy
          return
      end

  endcase

  Widget_Control, event.top, Set_UValue=printimageinfo
  Widget_Control, printimageinfo.info.jwst_Quicklook, Set_UValue=info

end

;_______________________________________________________________________
pro jwst_print_slope_images,info,type 

  ; Pop up a small widget so the user can type in a file name.
  ; Wait for the user to type a carriage-return.
if(XRegistered("jwst_msql_printimage")) then return


jintegration = info.slope.integrationNO+1

ij = 'int' + string(jintegration) 
ij = strcompress(ij,/remove_all)

xvalue = fix(info.slope.x_pos*info.slope.binfactor)+1
yvalue = fix(info.slope.y_pos*info.slope.binfactor)+1
xy = strcompress(string(xvalue) + "_" + string(yvalue),/remove_all)
mtitle = ' ' 
if(type eq 0) then begin

    if(info.slope.plane[0] eq 0) then begin
        xt = ' Slope Values'
        name = 'Slope'
    endif
    if(info.slope.plane[0] eq 1) then begin
        xt = ' Uncertainty in Slope'
        name = 'Uncertainty'
    endif
    if(info.slope.plane[0] eq 2) then begin
        xt = ' Data Quality Flag'
        name = 'Data_Quality_Flag'
    endif
    if(info.slope.plane[0] eq 3) then begin
        xt = ' Zero Pt of Fit'
        name = 'Zero_Pt'
    endif
    if(info.slope.plane[0] eq 4) then begin
        xt = ' # of Good Frames'
        name = 'Good_Frames'
    endif
    if(info.slope.plane[0] eq 5) then begin
        xt = ' Frame # of 1st Saturated Value'
        name = '1st_Saturated_Frame'
    endif

    if(info.slope.plane[0] eq 6) then begin
        xt = ' Max 2 point Differences
        name = 'max_2pt_diff'
    endif

    if(info.slope.plane[0] eq 7) then begin
        xt = ' Frame # of Max 2 point Differences
        name = 'frame_max_2pt_diff'
    endif

    if(info.slope.plane[0] eq 8) then begin
        xt = ' Standard Deviation 2 point Differences
        name = 'stdev_2pt_diff'
    endif
    if(info.slope.plane[0] eq 9) then begin
        xt = ' Slope of 2 point Differences
        name = 'slope_2pt_diff'
    endif

    outname = info.output.slope_win1 + name + '_' + ij
    mtitle = 'MIRI Quicklook Print' + xt 
endif
if(type eq 1) then begin

    if(info.slope.plane[0] eq 0) then begin
        xt = ' Zoom: Slope Values'
        name = 'Zoom_Slope'
    endif
    if(info.slope.plane[0] eq 1) then begin
        xt = ' Zoom: Uncertainty in Slope'
        name = 'Zoom_Uncertainty'
    endif
    if(info.slope.plane[0] eq 2) then begin
        xt = ' Zoom: Data Quality Flag'
        name = 'Zoom_Data_Quality_Flag'
    endif
    if(info.slope.plane[0] eq 3) then begin
        xt = ' Zoom: Zero Pt of Fit'
        name = 'Zoom_Zero_Pt'
    endif
    if(info.slope.plane[0] eq 4) then begin
        xt = ' Zoom: # of Good Frames'
        name = 'Zoom_Good_Frames'
    endif
    if(info.slope.plane[0] eq 5) then begin
        xt = ' Zoom: Frame # of 1st Saturated Value'
        name = 'Zoom_1st_Saturated_Frame'
    endif

    if(info.slope.plane[0] eq 6) then begin
        xt = ' Zoom: Max 2 point Differences
        name = 'Zoom_max_2pt_diff'
    endif

    if(info.slope.plane[0] eq 7) then begin
        xt = ' Zoom: Frame # of Max 2 point Differences
        name = 'Zoom_frame_max_2pt_diff'
    endif

    if(info.slope.plane[0] eq 8) then begin
        xt = ' Zoom: Standard Deviation 2 point Differences
        name = 'Zoom_stdev_2pt_diff'
    endif
    if(info.slope.plane[0] eq 9) then begin
        xt = ' Zoom: Slope of 2 point Differences
        name = 'Zoom_slope_2pt_diff'
    endif

    outname = info.output.slope_win1 + name + '_' + ij
    mtitle = 'MIRI Quicklook Print' + xt 


endif
if(type eq 2) then begin
    if(info.slope.plane[2] eq 0) then begin
        xt = ' Slope Values'
        name = 'Slope'
    endif
    if(info.slope.plane[2] eq 1) then begin
        xt = ' Uncertainty in Slope'
        name = 'Uncertainty'
    endif
    if(info.slope.plane[2] eq 2) then begin
        xt = ' Data Quality Flag'
        name = 'Data_Quality_Flag'
    endif
    if(info.slope.plane[2] eq 3) then begin
        xt = ' Zero Pt of Fit'
        name = 'Zero_Pt'
    endif
    if(info.slope.plane[2] eq 4) then begin
        xt = ' # of Good Frames'
        name = 'Good_Frames'
    endif
    if(info.slope.plane[2] eq 5) then begin
        xt = ' Frame # of 1st Saturated Value'
        name = '1st_Saturated_Frame'
    endif

    if(info.slope.plane[2] eq 6) then begin
        xt = ' Max 2 point Differences
        name = 'max_2pt_diff'
    endif

    if(info.slope.plane[2] eq 7) then begin
        xt = ' Frame # of Max 2 point Differences
        name = 'frame_max_2pt_diff'
    endif

    if(info.slope.plane[2] eq 8) then begin
        xt = 'Standard Deviation 2 point Differences
        name = 'stdev_2pt_diff'
    endif
    if(info.slope.plane[2] eq 9) then begin
        xt = ' Slope of 2 point Differences
        name = 'slope_2pt_diff'
    endif
    outname = info.output.slope_win2+ name +'_' + ij
    mtitle = 'MIRI Quicklook Print ' + xt
endif


if(type eq 3) then begin
    outname = info.output.slope_slope_pixel + '_' + xy
    mtitle = 'MIRI Quicklook Print Slope Values for Selected Pixel '
endif

; widget window parameters
  xwidget_size = 900
  ywidget_size = 110

  xsize_scroll = 700
  ysize_scroll = 110


  if(info.control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.control.x_scroll_window
  if(info.control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.control.y_scroll_window
  if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
  if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10

otype = 0
path = info.control.dirps
slash = '/'
if(path eq "") then slash = ''

filename = info.control.dirps + slash + info.control.filebase + $
           outname + '.ps'


pntrbase   = Widget_Base  (Title = mtitle, /Column, $
                           Group_Leader=info.jwst_SlopeQuicklook, $
                           xsize = xwidget_size,$
                           ysize = ywidget_size,/scroll,$
                           x_scroll_size= xsize_scroll,$
                           y_scroll_size = ysize_scroll)                           
pntr1base =  Widget_Base(pntrbase, /Row)
label      = Widget_Label (pntr1base, Value='Output file name:') 
selectfile = Widget_Text  (pntr1base, Value = filename, XSize = 120, /Edit, $
                           Event_Pro = 'slope_image_print')
pntr2base  = Widget_Base  (pntrbase, /Row)
tnames = ['PostScript', 'Encapsulated Postscript', 'JPEG', 'PNG', 'GIF']
otypeButtons = cw_bgroup(pntr2base, tnames, row=1, label_left='File type:', $
                         uvalue='obutton', set_value=otype, exclusive=1, $
                         /no_release)
label3     = Widget_Label (pntr2base, Value = '     ')
browseButton = Widget_Button(pntr2base, Value = ' Browse ')
printButton = Widget_Button(pntr2base, Value = ' Print ', $
                            Event_Pro = 'slope_image_print')
cancelButton = Widget_Button(pntr2base, Value = ' Cancel ')

printimageinfo = {selectfile    :     selectfile,   $
                  browseButton  :     browseButton, $
                  cancelButton  :     cancelButton, $
                  otypeButtons  :     otypeButtons, $
                  otype         :     otype,        $
                  type          :     type,$
                  filename      :     filename,     $
                  info         :     info        }

Widget_Control, pntrbase, set_uvalue = printimageinfo
Widget_Control, pntrbase, /Realize

XManager, "msql_printimage", pntrbase, Event_Handler = "jwst_print_slope_image_event"

end
