pro delay_event,event
Widget_Control,event.top,Get_UValue=winfo
widget_control,winfo.cinfo.CubeView,Get_UValue=cinfo
cinfo.wave_play.delay = (100.0 - float(event.value))/50.0 ; max delay of 2 sec
widget_control,winfo.cinfo.cubeview,Set_Uvalue = cinfo
end 

;_______________________________________________________________________
pro wave_play_quit,event
widget_control,event.top, Get_UValue = tinfo
widget_control,tinfo.cinfo.CubeView,Get_UValue=cinfo
widget_control,cinfo.WavePlay,/destroy
end
;_______________________________________________________________________
pro wave_play_event, event
Widget_Control,event.id,Get_uValue=event_name
Widget_Control,event.top,Get_UValue=winfo
widget_control,winfo.cinfo.CubeView,Get_UValue=cinfo
eventName = TAG_NAMES(event,/STRUCTURE_NAME)
;print,'Event name ' ,eventname,event.id

if(eventName eq 'WIDGET_BUTTON') then begin 
    case event.id of
        cinfo.wave_play.PrevButton: begin
            cinfo.view_cube.this_iwavelength = cinfo.view_cube.this_iwavelength-1
            if(cinfo.view_cube.this_iwavelength lt 0) then cinfo.view_cube.this_iwavelength = 0
            widget_control,cinfo.wave_play.wavelengthID,set_combobox_select=$
                           cinfo.view_cube.this_iwavelength
            cv_update_cube,cinfo
            cv_update_spectrum,cinfo
            cv_draw_current_wavelength,cinfo 
        end
;_______________________________________________________________________
        cinfo.wave_play.NextButton: begin
            cinfo.view_cube.this_iwavelength = cinfo.view_cube.this_iwavelength+1
            if(cinfo.view_cube.this_iwavelength gt cinfo.cube.naxis3) then $
              cinfo.view_cube.this_iwavelength = cinfo.cube.naxis3-1
            widget_control,cinfo.wave_play.wavelengthID,set_combobox_select=$
                           cinfo.view_cube.this_iwavelength

            cv_update_cube,cinfo 
            cv_update_spectrum,cinfo
            cv_draw_current_wavelength,cinfo 
        end
;_______________________________________________________________________
        cinfo.wave_play.PlayButton: begin
            if(cinfo.wave_play.stopflag eq 0) then begin ; this is executed first  time
                                ; play button is pushed. Then the
                                ; timer is set and WIDGET_TIMER is executed 
                                

                cinfo.view_cube.this_iwavelength = cinfo.view_cube.this_iwavelength+1

                if(cinfo.view_cube.this_iwavelength gt cinfo.cube.naxis3) then $
                  cinfo.view_cube.this_iwavelength = cinfo.cube.naxis3-1
                widget_control,cinfo.wave_play.wavelengthID,set_combobox_select=$
                               cinfo.view_cube.this_iwavelength


                cv_update_cube,cinfo
                cv_update_spectrum,cinfo
                cv_draw_current_wavelength,cinfo 
            endif
            widget_control,event.id,timer= 0
            cinfo.wave_play.stopflag = 0
        end
        cinfo.wave_play.StopButton: begin
            cinfo.wave_play.stopflag= 1
        end
else: print,'Event name not found"
    endcase

endif

;_______________________________________________________________________
if (eventName eq 'WIDGET_TIMER') then begin
    if(cinfo.wave_play.stopflag eq 0) then begin
        wait,cinfo.wave_play.delay

        cinfo.view_cube.this_iwavelength = cinfo.view_cube.this_iwavelength+1
        if(cinfo.view_cube.this_iwavelength ge cinfo.cube.naxis3) then begin
            cinfo.view_cube.this_iwavelength = cinfo.cube.naxis3-1
            cinfo.wave_play.stopflag= 1 
        endif else begin 
            widget_control,cinfo.wave_play.wavelengthID,set_combobox_select=$
                           cinfo.view_cube.this_iwavelength

            cv_update_cube,cinfo
            cv_update_spectrum,cinfo            
            cv_draw_current_wavelength,cinfo
            widget_control,event.id, timer=0
        endelse
    endif
endif


if (eventName eq 'WIDGET_COMBOBOX') then begin
;_______________________________________________________________________

    case event.id of

        cinfo.wave_play.WavelengthID: begin 
            cinfo.view_cube.this_iwavelength = event.index

            cv_update_cube,cinfo
            cv_update_spectrum,cinfo
            cv_draw_current_wavelength,cinfo 

        end
    endcase
endif



widget_control,winfo.cinfo.cubeview,Set_Uvalue = cinfo

end


;_______________________________________________________________________
;***********************************************************************
pro cv_wavelength_options,cinfo

window,4,/pixmap
wdelete,4

w = get_screen_size()
x_offset = w[0] - 350
if(x_offset lt 0) then x_offset = 50

y_offset = w[1] - 200
if(y_offset lt 0) then y_offset = 50

if(XRegistered ('wplay')) then begin
    widget_control,cinfo.WavePlay,/destroy
endif

WavePlay = widget_base(title = 'Select Wavelength', col =1 , mbar = menuBar,$
                       group_leader = cinfo.CubeView,$
                       xsize = 250,ysize = 200,/base_align_right,xoffset = x_offset,$
                      yoffset= y_offset)


QuitMenu = widget_button(menuBar,value="Quit",font = cinfo.font2)
quitbutton = widget_button(quitmenu,value="Quit",event_pro='wave_play_quit')




info_box = widget_base(waveplay,/col,/frame,/align_left)
wavelength_box = widget_base(info_box,row=1,/align_left)
wavelength_label = widget_label(wavelength_box,value='Wavelength',/align_left,$
                                font  = cinfo.font5)
wavelengths = ['              ','              ']
cinfo.wave_play.wavelengthID = widget_combobox(wavelength_box,value = wavelengths,uvalue='wave',$
                               font = cinfo.font5,/dynamic_resize)

wavelength_string = strcompress(string( (*cinfo.cube.pwavelength)),/remove_all)
nw = n_elements(wavelength_string)
for i = 0, nw -1 do begin
    wavelength_string[i] = strcompress(string(i+1)) + ":   " + wavelength_string[i]

endfor
widget_control,cinfo.wave_play.wavelengthID,set_value = wavelength_string

widget_control,cinfo.wave_play.wavelengthID,set_combobox_select=$
               cinfo.view_cube.this_iwavelength

info_box = widget_base(waveplay,/col,/frame,/align_left)
buttonIDs = widget_base(info_box,/row)
cinfo.wave_play.PrevButton = widget_button(buttonIDs,value='Prev') 
cinfo.wave_play.NextButton = widget_button(buttonIDs,value='Next') 
cinfo.wave_play.PlayButton = widget_button(buttonIDs,value='Play')
cinfo.wave_play.StopButton = widget_button(buttonIDs,value='Stop')
 
sIDs = widget_base(info_box,/row)
cinfo.wave_play.Slider = widget_slider(sIDs,/drag,title='Play Speed',maximum = 100,minimum =10,$
                       /suppress_value,value = 50,event_pro ='delay_event')


cinfo.WavePlay = waveplay

wave = {cinfo                  : cinfo}



Widget_Control,cinfo.Waveplay,Set_UValue=wave
widget_control,cinfo.Waveplay,/realize

XManager,'wplay',waveplay,/No_Block,event_handler = 'wave_play_event'

Widget_Control,cinfo.CubeView,Set_UValue=cinfo

end
