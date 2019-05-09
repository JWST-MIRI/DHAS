;***********************************************************************
pro ref_pixel_plot_quit,event
widget_control,event.top, Get_UValue = tinfo
widget_control,tinfo.info.QuickLook,Get_UValue=info
widget_control,info.RPixelPlot,/destroy
end
;***********************************************************************

pro rpixel_plot_event, event
Widget_Control,event.id,Get_uValue=event_name
widget_control,event.top, Get_UValue = pinfo
widget_control,pinfo.info.QuickLook,Get_Uvalue = info

case 1 of

;_______________________________________________________________________
;_______________________________________________________________________
; change x and y range of ramp graph 
;_______________________________________________________________________
    (strmid(event_name,0,7) EQ 'ramp_mm') : begin
        if(strmid(event_name,7,1) EQ 'x') then graphno = 0 else graphno = 1 
        if(strmid(event_name,7,2) EQ 'x1') then begin
            pinfo.ramp_range[0,0]  = event.value
            widget_control,pinfo.ramp_mmlabel[0,1],get_value = temp
            pinfo.ramp_range[0,1]  = temp
        endif
        if(strmid(event_name,7,2) EQ 'x2') then begin
            pinfo.ramp_range[0,1]  = event.value
            widget_control,pinfo.ramp_mmlabel[0,0],get_value = temp
            pinfo.ramp_range[0,0]  = temp
        endif
        if(strmid(event_name,7,2) EQ 'y1') then begin
            pinfo.ramp_range[1,0]  = event.value
            widget_control,pinfo.ramp_mmlabel[1,1],get_value = temp
            pinfo.ramp_range[1,1]  = temp
        endif
        if(strmid(event_name,7,2) EQ 'y2') then  begin
            pinfo.ramp_range[1,1]  = event.value
            widget_control,pinfo.ramp_mmlabel[1,0],get_value = temp
            pinfo.ramp_range[1,0]  = temp
        endif

        pinfo.default_scale_ramp[graphno] = 0
        widget_control,pinfo.ramp_recomputeID[graphno],set_value=' Default '

        rpixel_update_plot,pinfo
        Widget_Control,event.top,Set_UValue=pinfo
    end
    
;_______________________________________________________________________
; set the Default range or user defined range for ramp plot
    (strmid(event_name,0,1) EQ 'r') : begin
        graphno = fix(strmid(event_name,1,1))

        if(pinfo.default_scale_ramp[graphno-1] eq 0 ) then begin ; true - turn to false
            widget_control,pinfo.ramp_recomputeID[graphno-1],set_value=' Plot Range '
            pinfo.default_scale_ramp[graphno-1] = 1
        endif


        rpixel_update_plot,pinfo
        Widget_Control,event.top,Set_UValue=pinfo
    end
;_______________________________________________________________________
; Change Integration Range  For Ramp Plots
;_______________________________________________________________________

    (strmid(event_name,0,3) EQ 'int') : begin
; changed by typing a new value
        
        if(strmid(event_name,4,4) eq 'chng') then begin
            num = fix(strmid(event_name,9,1))-1
            pinfo.int_range[num] = event.value
        endif


; check if the <> buttons were used
        if(strmid(event_name,4,4) eq 'move') then begin
            value = intarr(2)
            value[0] = pinfo.int_range[0]
            value[1] = pinfo.int_range[1]

            if(strmid(event_name,9,1) eq 'u') then begin

                value[0] = value[0] + 1
                value[1] = value[1] + 1

            endif
            if(strmid(event_name,9,1) eq 'd') then begin
                value[0] = value[0] - 1
                value[1] = value[1] -1
            endif

            pinfo.int_range[0] = value[0]            
            pinfo.int_range[1] = value[1]            
        endif

; check if plot all integrations is typed

        if(strmid(event_name,4,4) eq 'grab') then begin
            pinfo.int_range[0] = 1            
            pinfo.int_range[1] = pinfo.info.image_pixel.nints
            pinfo.overplot_pixel_int = 0
        endif            


; check if overplot integrations 

        if(strmid(event_name,4,4) eq 'over') then begin
            pinfo.int_range[0] = 1            
            pinfo.int_range[1] = pinfo.info.image_pixel.nints
            pinfo.overplot_pixel_int = 1
        endif            


; Check limits for the above options for changing the integration range
; lower limit 1
; upper limit ginfo.data.nints

        for i = 0,1 do begin
            if(pinfo.int_range[i] le 0) then pinfo.int_range[i] = 1
            if(pinfo.int_range[i] gt info.image_pixel.nints) then $
              pinfo.int_range[i] = info.image_pixel.nints
        endfor
        if(pinfo.int_range[0] gt pinfo.int_range[1] ) then begin
            result = dialog_message(" Integration range incorrect, reseting to first integration ",/error)
            pinfo.int_range[*] = 1
        endif

        rpixel_update_plot,pinfo

        Widget_Control,event.top,Set_UValue=pinfo
    end



else: print," Event name not found",event_name
endcase


Widget_Control,event.top,Set_UValue=pinfo
end


;***********************************************************************
pro rpixel_update_plot,pinfo,ps = ps, eps = eps

hcopy = 0
if ( (keyword_set(ps)) or ( keyword_set(eps)) ) then hcopy = 1
data_ref = (*pinfo.info.image_pixel.ref_pixeldata)[*,*]

if(hcopy eq 0 ) then wset,pinfo.draw_window_id

widget_control,pinfo.IrangeID[0],set_value=pinfo.int_range[0]
widget_control,pinfo.IrangeID[1],set_value=pinfo.int_range[1]

num_int = pinfo.int_range[1] - pinfo.int_range[0] + 1



n_reads = n_elements(data_ref)
xvalues = indgen(n_reads) + 1

if(pinfo.overplot_pixel_int) then xvalues = indgen(pinfo.info.image_pixel.nframes)+1 

xmin = min(xvalues)
xmax = max(xvalues)
ymin = min(data_ref)
ymax = max(data_ref)


ypad = (ymin + ymax)*.20

; check if default scale is true - then reset to orginal value
if(pinfo.default_scale_ramp[0] eq 1) then begin
    pinfo.ramp_range[0,0] = xmin-1
    pinfo.ramp_range[0,1] = xmax+1
endif 
  
if(pinfo.default_scale_ramp[1] eq 1) then begin
    if(ypad gt 0) then begin 
        pinfo.ramp_range[1,0] = ymin-ypad 
        pinfo.ramp_range[1,1] = ymax+ypad
    endif else begin
        pinfo.ramp_range[1,0] = ymin+ypad 
        pinfo.ramp_range[1,1] = ymax-ypad
    endelse
        
endif

if(hcopy eq 1) then begin
    i = pinfo.info.inspect_ref.integrationNO
    j = pinfo.info.inspect_ref.rampNO
    
    ftitle = " Frame #: " + strtrim(string(i+1),2) 
    ititle = " Integration #: " + strtrim(string(j+1),2)
    sstitle = ftitle + ititle


endif

x1 = pinfo.ramp_range[0,0]
x2 = pinfo.ramp_range[0,1]
y1 = pinfo.ramp_range[1,0]
y2 = pinfo.ramp_range[1,1]


ss = strcompress(string(pinfo.info.control.filebase)) + pinfo.xystring

plot,xvalues,data_ref,xtitle = "Frame #", ytitle='DN/frame',title = ss,$
  xrange=[x1,x2],yrange=[y1,y2], subtitle = sstitle,$
     xstyle = 1, ystyle = 1,/nodata


ptype = [1,2,4,5,6]


ip = 0
ic = 0
isp = 0
isp2 = 0
for k = 0,num_int-1 do begin


    yvalues = data_ref[k,*,*]
    xvalues = indgen(pinfo.info.image_pixel.nframes)+1



    if(pinfo.overplot_pixel_int eq 0) then     xvalues = xvalues + pinfo.info.image_pixel.nframes*(k)

    oplot,xvalues,yvalues,psym = ptype[ip],symsize = 0.8
    if(hcopy eq 1) then     oplot,xvalues,yvalues,psym = ptype[ip],symsize = 0.8

    ic = ic + 1
    if(ic gt 3) then begin
        ip = ip + 1
        ic = 0
    endif
    if(ip gt 4) then ip = 0

    
 if(num_int gt 1 and pinfo.overplot_pixel_int eq 0) then begin
     yline = fltarr(2) & xline = fltarr(2)
     yline[0] = -1000000 & yline[1] = 100000
     xline[*] = pinfo.info.image_pixel.nframes* (k+1)
     oplot,xline,yline,linestyle=3
 endif
endfor

widget_control,pinfo.ramp_mmlabel[0,0],set_value=fix(pinfo.ramp_range[0,0])
widget_control,pinfo.ramp_mmlabel[0,1],set_value=fix(pinfo.ramp_range[0,1])
widget_control,pinfo.ramp_mmlabel[1,0],set_value=pinfo.ramp_range[1,0]
widget_control,pinfo.ramp_mmlabel[1,1],set_value=pinfo.ramp_range[1,1]




    
data_ref = 0

xnew = 0
ynew = 0
yvalues = 0
xvalues = 0

end




;***********************************************************************
;_______________________________________________________________________
pro mirql_plot_frames,x,y,info

window,4,/pixmap
wdelete,4
if(XRegistered ('rpixelplot')) then begin
    widget_control,info.RPixelPlot,/destroy
endif

;_______________________________________________________________________
;*********
;Setup main panel
;*********

PixelPlot = widget_base(title=" Frame Values for Reference Ouput Pixel",$
                         col = 1,mbar = menuBar,group_leader = info.QuickLook,$
                           xsize = 600,ysize = 800,/base_align_right,xoffset=850,yoffset=100)

;********
; build the menubar
;********
QuitMenu = widget_button(menuBar,value="Quit",font = info.font2)
quitbutton = widget_button(quitmenu,value="Quit",event_pro='ref_pixel_plot_quit')

printMenu = widget_button(menuBar,value="Print",font = info.font2)
printbutton = widget_button(printmenu,value="Print",event_pro='print_reframp')


;_______________________________________________________________________
default_scale_ramp = intarr(2)
default_scale_ramp[*] = 1
ramp_range = fltarr(2,2)        ; plot range for the ramp plot, 


tlabelID = widget_label(pixelplot,$
                        value = " Frame Values in Selected Reference Output Pixel for Given " $
                        + "Integration Range",$
                        /align_center,$
                        font=info.font5,/sunken_frame)


; button to change selected pixel


pix_num_base = widget_base(pixelplot,row=1,/align_center)

xs = ' x: '+ strcompress(string(fix(x) +1),/remove_all)
ys = ' y: '+ strcompress(string(fix(y)+ 1),/remove_all)

xystring = xs + ys
ramp_x_label = widget_label (pix_num_base,value=xs)
ramp_y_label = widget_label (pix_num_base,value=ys)
int_range = intarr(2) 
int_range[0] = 1  ; initialize to look at first integration
int_range[1] = 1
int_range[*] = int_range[*]


move_base = widget_base(pixelplot,/row,/align_left)

IrangeID = lonarr(2)
IrangeID[0] = cw_field(move_base,$
                  title="Integration range: Start", $
                  uvalue="int_chng_1",/integer,/return_events, $
                  value=int_range[0],xsize=4,$
                  fieldfont=info.font3)
IrangeID[1] = cw_field(move_base,$
                  title="End", $
                  uvalue="int_chng_2",/integer,/return_events, $
                  value=int_range[1],xsize=4,$
                  fieldfont=info.font3)

labelID = widget_button(move_base,uvalue='int_move_d',value='<',font=info.font3)
labelID = widget_button(move_base,uvalue='int_move_u',value='>',font=info.font3)




graphID_master2 = widget_base(pixelplot,/row,/align_left)
graphID = widget_draw(graphID_master2,$
                      xsize = info.plotsize3*1.5,$
                      ysize = info.plotsize1*2,$
                      retain=info.retn)


;buttons to  change the x and y ranges
ramp_mmlabel = lonarr(2,2)
ramp_recomputeID  = lonarr(2)

pix_num_base2 = widget_base(pixelplot,row=1,/align_left)
labelID = widget_label(pix_num_base2,value="X->",font=info.font4)
ramp_mmlabel[0,0] = cw_field(pix_num_base2,title="min:",font=info.font4, $
                                        uvalue="ramp_mmx1",/integer,/return_events, $
                                        value=fix(ramp_range[0,0]), $
                                        xsize=info.xsize_label,fieldfont=info.font4)

ramp_mmlabel[0,1] = cw_field(pix_num_base2,title="max:",font=info.font4, $
                                        uvalue="ramp_mmx2",/integer,/return_events, $
                                        value=fix(ramp_range[0,1]),xsize=info.xsize_label,$
                                        fieldfont=info.font4)

ramp_recomputeID[0] = widget_button(pix_num_base2,value=' Plot Range',$
                                               font=info.font4,$
                                               uvalue = 'r1')

pix_num_base3 = widget_base(pixelplot,row=1,/align_left)

labelID = widget_label(pix_num_base3,value="Y->",font=info.font4)
ramp_mmlabel[1,0] = cw_field(pix_num_base3,title="min:",font=info.font4, $
                                        uvalue="ramp_mmy1",/float,/return_events, $
                                        value=ramp_range[1,0],xsize=info.xsize_label,$
                                        fieldfont=info.font4)

ramp_mmlabel[1,1] = cw_field(pix_num_base3,title="max:",font=info.font4, $
                                        uvalue="ramp_mmy2",/float,/return_events, $
                                        value=ramp_range[1,1],xsize=info.xsize_label,$
                                        fieldfont=info.font4)

ramp_recomputeID[1] = widget_button(pix_num_base3,value=' Plot Range',$
                                               font=info.font4,$
                                               uvalue = 'r2')


;_______________________________________________________________________

IAllButton = Widget_button(pixelplot, Value = 'Plot All Integrations',$
                           uvalue = 'int_grab_all',/align_left)
widget_control,IAllButton,Set_Button = 0

IAllButton = Widget_button(pixelplot, Value = 'Over plot Integrations',$
                           uvalue = 'int_overplot',/align_left)
widget_control,IAllButton,Set_Button = 0



info.RPixelplot = pixelplot
widget_control,info.rPixelPlot,/realize
XManager,'rpixelplot',pixelplot,/No_Block,event_handler = 'rpixel_plot_event'


widget_control,graphID,get_value=tdraw_id
draw_window_id = tdraw_id

overplot_pixel_int = 1
pinfo = {IrangeID              : IrangeID,$
         int_range             : int_range,$
         draw_window_id        : draw_window_id,$
         ramp_recomputeID      : ramp_recomputeID,$
         ramp_range            :  ramp_range,$
         ramp_mmlabel          : ramp_mmlabel,$
         default_scale_ramp    : default_scale_ramp,$
         overplot_pixel_int    : overplot_pixel_int,$
         xystring              : xystring,$
         info                  : info}	




Widget_Control,info.rPixelPlot,Set_UValue=pinfo

rpixel_update_plot,pinfo


Widget_Control,info.QuickLook,Set_UValue=info

end
