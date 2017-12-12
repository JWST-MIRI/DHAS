pro mql_setup_miri_caler_names,info,status
status = 0

info.ms.dirout = info.control.dirout
if(info.control.set_scidata eq 0) then begin

    image_file = dialog_pickfile(/read,$
                                get_path=realpath,Path=info.ms.dirout,$
                                filter = '*.fits')
 

    len = strlen(realpath)
    realpath = strmid(realpath,0,len-1); just to be consistent 
    info.ms.dirout = realpath
    
    if(image_file eq '')then begin
        print,' No file selected, can not read in data'
	status = 2
        return
    endif
    if (image_file NE '') then begin
        filename = image_file
    endif
endif

;-----------------------------------------------------------------------
; the User did provide a filename on the command line - 
if(info.control.set_scidata eq 1) then begin
    filename = strcompress(info.control.filename_slope,/remove_all)
endif
;-----------------------------------------------------------------------

filename_slope = filename
info.control.filename_slope = filename_slope
file_exist1 = file_test(info.control.filename_slope,/regular,/read)
if(file_exist1 ne 1 ) then begin
    result = dialog_message(" The Slope file does not exist "+ info.control.filename_slope,/error )
    status = 1
endif


slash_str = strsplit(info.control.filename_slope,'/',/extract)
n_slash = n_elements(slash_str)
if (n_slash GT 1) then begin
    out_filebase = slash_str[n_slash-1]
endif else begin
    out_filebase = info.control.filename_slope
endelse
info.control.filename = out_filebase ; only the filename not directory
len= strlen(out_filebase)
out_file = strmid(out_filebase,0,len-10)
info.control.filebase = out_file

end
;_______________________________________________________________________
pro mql_setup_miri_caler,info,status

status = 0
; filling the  the info.mc struture - this is passed and used
; by mql_edit_miri_caler_paramters (change parameters) 
; then mql_run_miri_caler is called to spawn the miri_caler process.

mql_setup_miri_caler_names,info,status
if(status ne 0) then return

; open to read in the SCA ID
fits_open,info.control.filename_slope,fcb
fits_read,fcb,cube_slope,header,/header_only
fits_close,fcb

info.mc.apply_dark = 0
info.mc.apply_flat = 0
info.mc.apply_fringe_flat = 0

info.mc.subchannel = 0
info.mc.subchannel_flag = 0

dirlocation = strpos(info.control.filename_slope,'/',/reverse_search)
len = strlen(info.control.filename_slope)
filename_slope = strmid(info.control.filename_slope,dirlocation+1,len-1)
print,'filename slope: ',filename_slope
info.mc.filename = filename_slope
info.mc.filebase = info.control.filebase
info.mc.output_filename = info.control.filebase
info.mc.dir = info.control.dirout
info.mc.dirout = info.control.dirout
info.mc.dircal = info.control.dircal


info.mc.flat_file = ' ' 
info.mc.fringe_file = ' ' 
info.mc.dark_file = ' ' 

info.mc.flag_flatfile= 0
info.mc.flag_fringefile= 0
info.mc.flag_darkfile= 0



info.mc.flag_outputname = 0

info.mc.flag_dircal= 0
info.mc.flag_dir= 0
info.mc.flag_dirout= 0

end



;***********************************************************************
pro mql_edit_mc_parameters_done,event
widget_control,event.top, Get_UValue = tinfo
widget_control,tinfo.info.QuickLook,Get_UValue=info
    widget_control,info.EditMCParameters,/destroy
    
end

;***********************************************************************
pro mql_edit_mc_parameters_cleanup,topbaseID

; get all defined structures so they are deleted when the program
; terminates

widget_control,topbaseID,get_uvalue=ginfo
widget_control,ginfo.info.Quicklook,get_uvalue = info
widget_control,info.EditMCParameters,/destroy
end


;***********************************************************************
pro mql_edit_mc_parameters_run,event

; get all defined structures so they are deleted when the program
; terminates
widget_control,event.top, Get_UValue = tinfo
widget_control,tinfo.info.QuickLook,Get_UValue=info


widget_control,tinfo.filenameButton, get_value = temp
filein = strcompress(temp,/remove_all)
result = strcmp(filein, info.control.filename)
if(result eq 0) then begin 
    len = strlen(filein) 
    test = strmid(filein,len-1,len-1)
    info.mc.filename =filein
endif

widget_control,tinfo.outnameButton, get_value = temp
outname = strcompress(temp,/remove_all)
result = strcmp(outname, info.control.filebase)

if(result eq 0) then begin 
    info.mc.output_filename = outname
    info.mc.flag_outputname = 1
endif



widget_control,tinfo.dirinField, get_value = temp
dirin = strcompress(temp,/remove_all)
result = strcmp(dirin, info.control.dirout)
if(result eq 0) then begin 
    len = strlen(dirin) 
    test = strmid(dirin,len-1,len-1)
    if(test eq '/') then dirin = strmid(dirin,0,len-1)
    info.mc.dir =dirin
    info.mc.flag_dir = 1
endif


widget_control,tinfo.diroutField, get_value = temp
dirout = strcompress(temp,/remove_all)
result = strcmp(dirout, info.control.dirout)
if(result eq 0) then begin 
    len = strlen(dirout) 
    test = strmid(dirout,len-1,len-1)
    if(test eq '/') then dirout = strmid(dirout,0,len-1)
    info.mc.dirout =dirout
    info.mc.flag_dirout = 1
endif

widget_control,tinfo.dircalField, get_value = temp
dircal = strcompress(temp,/remove_all)
result = strcmp(dircal, info.control.dircal)
if(result eq 0) then begin
    len = strlen(dircal) 
    test = strmid(dircal,len-1,len-1)
    if(test eq '/') then dircal = strmid(dircal,0,len-1)
    info.mc.dircal =dircal
    info.mc.flag_dircal = 1
endif


widget_control,tinfo.dark_fileButton, get_value = temp
dark_file  = strcompress(temp,/remove_all)
if(strlen(dark_file) gt 5) then begin 
    info.mc.dark_file =dark_file
    info.mc.flag_darkfile = 1
    info.mc.apply_dark = 1
endif

widget_control,tinfo.flat_fileButton, get_value = temp
flat_file  = strcompress(temp,/remove_all)
if(strlen(flat_file) gt 5) then begin 
    info.mc.flat_file =flat_file
    info.mc.flag_flatfile = 1
    info.mc.apply_flat = 1
endif

widget_control,tinfo.fringe_fileButton, get_value = temp
fringe_file  = strcompress(temp,/remove_all)
if(strlen(fringe_file) gt 5) then begin 
    info.mc.fringe_file =fringe_file
    info.mc.flag_fringefile = 1
    info.mc.apply_fringe_flat = 1
endif

if(info.mc.apply_fringe_flat eq 1 and info.mc.flag_fringefile eq 0) then begin
    result = dialog_message('You need to supply a Fringe Flat calibraiton file',/error)
    return
endif

if(info.mc.apply_dark eq 1 and info.mc.flag_darkfile eq 0) then begin
    result = dialog_message('You need to supply a Dark calibraiton file',/error)
    return
endif

if(info.mc.apply_flat eq 1 and info.mc.flag_flatfile eq 0) then begin
    result = dialog_message('You need to supply a Flat calibraiton file',/error)
    return
endif


;_______________________________________________________________________
; Checks



widget_control,info.Quicklook,Set_UValue = info

widget_control,info.EditMCParameters,/destroy
mql_run_miri_caler,info


end


;***********************************************************************
pro mql_edit_mc_parameters_event,event
Widget_Control,event.id,Get_uValue=event_name
widget_control,event.top, Get_UValue = einfo	
widget_control,einfo.info.QuickLook,Get_Uvalue = info

;_______________________________________________________________________

if (widget_info(event.id,/TLB_SIZE_EVENTS) eq 1 ) then begin
    info.mc.xwindowsize = event.x
    info.mc.ywindowsize = event.y

    info.mc.uwindowsize = 1
    widget_control,event.top,set_uvalue = einfo
    widget_control,einfo.info.Quicklook,set_uvalue = info
    mql_edit_miri_caler_parameters,info
    return
endif

case event.id of
    einfo.dButton: begin
      ; Change the option for using default dark
        temp = event.value
        info.mc.apply_dark = temp 	 
    end

    einfo.fButton: begin
      ; Change the option for using default flat
        temp = event.value
        info.mc.apply_flat = temp 	 
    end


    einfo.ffButton: begin
      ; Change the option for using default fringe flat
        temp = event.value
        info.mc.apply_fringe_flat = temp 	 
    end





;    einfo.subchButton: begin
;      ; sub channel
;        temp = event.value
;        info.mc.subchannel = temp
;        info.mc.subchannel_flag = 1
;        info.mc.subchannel = info.mc.subchannel -1
;        if(info.mc.subchannel lt 0) then info.mc.subchannel_flag = 0
;    end


    einfo.dircalField: begin
      ; calibration directory
        Widget_Control, einfo.dircalField, Get_Value = temp
        dircal = temp[0]
        dircal = strcompress(dircal,/remove_all)
        len = strlen(dircal) 
        test = strmid(dircal,len-1,len-1)
        if(test eq '/') then dircal = strmid(dircal,0,len-1)
        info.mc.dircal =dircal
        info.mc.flag_dircal = 1
    end

    einfo.filenamebutton: begin
      ; input filename
        Widget_Control, einfo.filenamebutton, Get_Value = temp
        filein = temp[0]
        filein = strcompress(filein,/remove_all)
        len = strlen(filein) 
        test = strmid(filein,len-1,len-1)
        if(test eq '/') then dircal = strmid(filein,0,len-1)
        info.mc.filename =filein
    end

    einfo.outnamebutton: begin
      ; output filename
        Widget_Control, einfo.outnamebutton, Get_Value = temp
        filein = temp[0]
        filein = strcompress(filein,/remove_all)
        info.mc.output_filename =filein
        info.mc.flag_outputname = 1
    end


    einfo.dark_filebutton: begin
      ; output filename

        Widget_Control, einfo.dark_filebutton, Get_Value = temp
        filein = temp[0]
        filein = strcompress(filein,/remove_all)
        info.mc.dark_file =filein
        info.mc.flag_darkfile = 1
        info.mc.apply_dark = 1

        widget_control,einfo.dbutton,set_value = 1

    end

    einfo.flat_filebutton: begin
      ; output filename
        Widget_Control, einfo.flat_filebutton, Get_Value = temp
        filein = temp[0]
        filein = strcompress(filein,/remove_all)
        info.mc.flat_file =filein
        info.mc.flag_flatfile = 1
        info.mc.apply_flat = 1
        widget_control,einfo.fbutton,set_value = 1
    end

    einfo.fringe_filebutton: begin
      ; output filename
        Widget_Control, einfo.fringe_filebutton, Get_Value = temp
        filein = temp[0]
        filein = strcompress(filein,/remove_all)
        info.mc.fringe_file =filein
        info.mc.flag_fringefile = 1
        info.mc.apply_fringe_flat = 1
        widget_control,einfo.ffbutton,set_value = 1
    end

    einfo.changeButton: begin
        status = 0
        info.control.set_scidata = 0
        mql_setup_miri_caler_names,info
        info.mc.filename = info.control.filename
        info.mc.filebase = info.control.filebase
        info.mc.dir = info.control.dirout
        info.mc.dirout = info.control.dirout
        widget_control,einfo.filenamebutton,set_value = info.mc.filename 
        info.mc.output_filename = info.control.filebase
        widget_control,einfo.outnamebutton,set_value = info.mc.output_filename 
        widget_control,einfo.dirinField,set_value = info.mc.dir
        widget_control,einfo.diroutField,set_value = info.mc.dirout        
    end

    einfo.dirinField: begin
      ; set name input directory
        Widget_Control, einfo.dirinField, Get_Value = temp
        dirin = temp[0]
        dirin = strcompress(dirin,/remove_all)
        len = strlen(dirin) 
        test = strmid(dirin,len-1,len-1)
        if(test eq '/') then dirin = strmid(dirin,0,len-1)
        info.mc.dir =dirin
        info.mc.flag_dir = 1
    end

    einfo.diroutField: begin
      ; set name output directory
        Widget_Control, einfo.diroutField, Get_Value = temp
        dirout = temp[0]
        dirout = strcompress(dirout,/remove_all)
        len = strlen(dirout) 
        test = strmid(dirout,len-1,len-1)
        if(test eq '/') then dirout = strmid(dirout,0,len-1)
        info.mc.dirout =dirout
        info.mc.flag_dirout = 1
    end


    einfo.bbutton[0]: begin
        image_file = dialog_pickfile(/read,Title = 'Please select Pixel Flat Calibration file',$
                             get_path=realpath,Path=info.control.dircal,$
                             filter = '*.fits')

        if(image_file eq '')then begin
            print,' No file selected, can not read in data'
        endif
        if (image_file NE '') then begin
            info.mc.flat_file = image_file
            info.mc.flag_flatfile = 1
            Widget_Control, einfo.flat_filebutton, Set_Value = image_file            
            widget_control,einfo.fbutton,set_value = 1
        endif

    end

    einfo.bbutton[1]: begin
        image_file = dialog_pickfile(/read,Title = 'Please select Fringe Flat Calibration file',$
                             get_path=realpath,Path=info.control.dircal,$
                             filter = '*.fits')

        if(image_file eq '')then begin
            print,' No file selected, can not read in data'
        endif
        if (image_file NE '') then begin
            info.mc.fringe_file = image_file
            info.mc.flag_fringefile = 1
            Widget_Control, einfo.fringe_filebutton, Set_Value = image_file            
            widget_control,einfo.ffbutton,set_value = 1
        endif

    end

    einfo.bbutton[2]: begin
        image_file = dialog_pickfile(/read,Title = 'Please select Dark Calibration file',$
                             get_path=realpath,Path=info.control.dircal,$
                             filter = '*.fits')

        if(image_file eq '')then begin
            print,' No file selected, can not read in data'
        endif
        if (image_file NE '') then begin
            info.mc.dark_file = image_file
            info.mc.flag_darkfile = 1
            Widget_Control, einfo.dark_filebutton, Set_Value = image_file            
            widget_control,einfo.dbutton,set_value = 1
        endif
        
    end



    einfo.ibutton[0] : begin
        message = " The default pixel flat file is found in the calibration directory." 
        result = dialog_message(message,/information)
    end
    einfo.ibutton[1] : begin
        message = " The default fringe flat file is found in the calibration directory." 
        result = dialog_message(message,/information)
    end
    einfo.ibutton[2] : begin
        message = " The default dark calibration file is found in the calibration directory." 
        result = dialog_message(message,/information)
    end


    
    else:
  endcase

   Widget_Control,einfo.info.QuickLook,Set_UValue=info
end


;***********************************************************************
pro mql_edit_miri_caler_parameters,info


if(XRegistered ('memc')) then begin
    widget_control,info.EditMCParameters,/destroy
endif
;_______________________________________________________________________  
 ; Don't pop up if there is already an edit user preferences widget up.

;if (XRegistered('memc')) then return

ysize_scroll = 950
xsize_scroll = 1060
xwidget_size = 1250
ywidget_size = 1300



if(info.mc.uwindowsize eq 1) then begin ; user has set window size 
    xsize_scroll = info.mc.xwindowsize
    ysize_scroll = info.mc.ywindowsize
endif    
if(info.control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.control.x_scroll_window
if(info.control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.control.y_scroll_window
if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10


etitle = 'Parameters to run Miri_Caler Program on file ' 

EditParameters = Widget_base(Title = etitle, /Column, $
                             mbar = menuBar,$
                             Group_Leader = info.QuickLook, /Grid_Layout,xsize=xwidget_size,ysize=ywidget_size,$
                             /scroll,x_scroll_size = xsize_scroll,y_scroll_size = ysize_scroll,$
                            /TLB_SIZE_EVENTS)

;********
; build the menubar
;********

DoneMenu = widget_button(menuBar,value="Quit",font = info.font2)
Donebutton = widget_button(Donemenu,value="Quit",event_pro='mql_edit_mc_parameters_done')

lbase  = widget_base(EditParameters,/row,/align_center)
runbutton = widget_button(lbase, $
                        value =' Accept Values and Run the MIRI_CALER program',$
                        font=info.font5,event_pro = 'mql_edit_mc_parameters_run')


infotitle = 'MUST hit RETURN in INPUT BOXES to EFFECT change!'

tlabelID = widget_label(lbase,value =infotitle ,font=info.font5)



darkbutton = 0L
bpbutton  = 0L
dbutton  = 0L
fbutton  = 0L
ffbutton  = 0L
dark_filebutton = 0L
flat_filebutton = 0L
sat_filebutton = 0L

dircalfield = 0L
dirinfield = 0L
diroutfield = 0L
filenamebutton = 0L
changebutton = 0L
outnameButton = 0L
ibutton = lonarr(3)
bbutton = lonarr(3)
ORButton = 0L
OCButton = 0L
modelbutton = 0L
dname = info.mc.filename

print,'filename ',info.mc.filename



loadbase = Widget_Base(EditParameters, /Row, /Frame)
filenamebutton = cw_field(loadbase, value=dname, $
                          title='Filename', $
                           uvalue='dname', /Return_Events, /String,xsize=60,/noedit)
changebutton = widget_button(loadbase,value=' Change Filename ')


dname = info.mc.dir
loadbase = Widget_Base(EditParameters, /Row, /Frame)
dirinField = cw_field(loadbase, value=dname, $
                      title='Directory name for input science files (LVL2)', $
                      uvalue='dname', /Return_Events, /String,xsize=60)


dname = info.mc.dirout
loadbase = Widget_Base(EditParameters, /Row, /Frame)
diroutField = cw_field(loadbase, value=dname, $
                      title='Directory name for output science files (LVL3) ', $
                      uvalue='dname', /Return_Events, /String,xsize=60)


dname = info.mc.dircal
loadbase = Widget_Base(EditParameters, /Row, /Frame)
dircalField = cw_field(loadbase, value=dname, $
                       title='Directory name for location of calibration files', $
                       uvalue='dname', /Return_Events, /String,xsize=60)

dname = info.mc.output_filename
loadbase = Widget_Base(EditParameters, /Row, /Frame)
outnameButton = cw_field(loadbase, value=dname, $
                       title='Supply an output prefix name for the LVL3 fits file, '+ $
                       'instead of the default:', $
                       uvalue='dname', /Return_Events, /String,xsize=60)


;_______________________________________________________________________

;_______________________________________________________________________
;Pixel Flat File
loadbase = Widget_Base(EditParameters, /Row, /Frame)
bpstr = 'Apply default Pixel Flat Calibration file  ' 
bplabel = Widget_Label(loadbase, Value=bpstr)
bpnames = ['No', 'Yes']
fvalue = info.mc.apply_flat
fbutton = CW_BGroup(loadbase, bpnames, exclusive=1, row=1, $
                         Set_Value=fvalue, /No_Release)

ibutton[0] = widget_button(loadbase,value='Info',font=info.font4)    
dname = info.mc.flat_file
flat_filebutton = cw_field(loadbase, value=dname, $
                       title='Select Pixel Flat file', $
                       uvalue='dname', /Return_Events, /String,xsize=50)
bbutton[0] = widget_button(loadbase,value='Browse',font=info.font4)
;_______________________________________________________________________

;_______________________________________________________________________
; Fringe Flat File
loadbase = Widget_Base(EditParameters, /Row, /Frame)
bpstr = 'Apply default Fringe Flat Calibration file  ' 
bplabel = Widget_Label(loadbase, Value=bpstr)
bpnames = ['No', 'Yes']
fvalue = info.mc.apply_fringe_flat
ffbutton = CW_BGroup(loadbase, bpnames, exclusive=1, row=1, $
                         Set_Value=fvalue, /No_Release)
ibutton[1] = widget_button(loadbase,value='Info',font=info.font4)    

dname = info.mc.fringe_file
fringe_filebutton = cw_field(loadbase, value=dname, $
                       title='Select Pixel Flat file', $
                       uvalue='dname', /Return_Events, /String,xsize=50)
bbutton[1] = widget_button(loadbase,value='Browse',font=info.font4)
;_______________________________________________________________________


; Dark File
loadbase = Widget_Base(EditParameters, /Row, /Frame)
bpstr = 'Apply Default Dark Calibration file  ' 
bplabel = Widget_Label(loadbase, Value=bpstr)
bpnames = ['No', 'Yes']
dvalue = info.mc.apply_dark
dbutton = CW_BGroup(loadbase, bpnames, exclusive=1, row=1, $
                         Set_Value=dvalue, /No_Release)
ibutton[2] = widget_button(loadbase,value='Info',font=info.font4)    
dname = info.mc.dark_file
dark_filebutton = cw_field(loadbase, value=dname, $
                       title='Select Dark file', $
                       uvalue='dname', /Return_Events, /String,xsize=50)
bbutton[2] = widget_button(loadbase,value='Browse',font=info.font4)
;_______________________________________________________________________
;dbase = Widget_Base(EditParameters, /row, /Frame)
;dname = 'Provide the SubChannel Information instead of reading ICE files' 
;dnames = ['Unknown or Imager','Sub-Channel A', 'Sub-Channel B', 'Sub-Channel C']
;dlabel = Widget_Label(dbase, Value=dname)
;subchbutton = CW_BGroup(dbase, dnames, exclusive=1, row=1, $
;                        Set_Value=0, /No_Release)




einfo = {$
        filenamebutton    : filenamebutton,$
        changebutton      : changebutton,$
        outnameButton     : outnameButton,$
        dark_filebutton    : dark_filebutton,$
        flat_filebutton    : flat_filebutton,$
        fringe_filebutton  : fringe_filebutton,$
;        subchbutton       : subchbutton,$
	bpbutton          : bpbutton,$
	dbutton           : dbutton,$
	fbutton           : fbutton,$
	ffbutton          : ffbutton,$
	dircalfield       : dircalfield,$
        dirinfield        : dirinfield,$
        diroutfield       : diroutfield,$
        ibutton           : ibutton,$
        bbutton           : bbutton,$
        modelbutton       : modelbutton,$
         info             : info}

Widget_Control,EditParameters,Set_UValue=einfo

info.EditMCParameters = EditParameters                                                                             
widget_control,info.Quicklook,Set_UValue = info
Widget_control,info.EditMCParameters,/Realize  
XManager,'memc',info.EditMCParameters,/No_Block,cleanup='mql_edit_mc_parameters_cleanup',$
         event_handler='mql_edit_mc_parameters_event'

end



;;_______________________________________________________________________

