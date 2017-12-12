;***********************************************************************
;_______________________________________________________________________
pro linearity_correction_quit,event
;_______________________________________________________________________

widget_control,event.top, Get_UValue = cinfo	
widget_control,cinfo.info.QuickLook,Get_Uvalue = info


if(XRegistered ('lcr')) then begin
    widget_control,info.LinCorResults,/destroy
endif



end
;***********************************************************************
;***********************************************************************
pro lin_cor_event,event

Widget_Control,event.id,Get_uValue=event_name
widget_control,event.top, Get_UValue = ginfo
widget_control,ginfo.info.QuickLook,Get_Uvalue = info

if (widget_info(event.id,/TLB_SIZE_EVENTS) eq 1 ) then begin
    info.lincor.xwindowsize = event.x
    info.lincor.ywindowsize = event.y
    info.lincor.uwindowsize = 1
    widget_control,event.top,set_uvalue = ginfo
    widget_control,ginfo.info.Quicklook,set_uvalue = info
    display_linearity_correction_results,info

    return
endif
;    print,'event_name',event_name
    case 1 of
;_______________________________________________________________________
;_______________________________________________________________________
; change x and y range of difference graph 
;_______________________________________________________________________
    (strmid(event_name,0,7) EQ 'diff_mm') : begin
        if(strmid(event_name,7,1) EQ 'x') then graphno = 0 else graphno = 1 
        if(strmid(event_name,7,2) EQ 'x1') then begin
            info.lincor.diff_range[0,0]  = event.value
            widget_control,info.lincor.diff_mmlabel[0,1],get_value = temp
            info.lincor.diff_range[0,1]  = temp
        endif
        if(strmid(event_name,7,2) EQ 'x2') then begin
            info.lincor.diff_range[0,1]  = event.value
            widget_control,info.lincor.diff_mmlabel[0,0],get_value = temp
            info.lincor.diff_range[0,0]  = temp
        endif
        if(strmid(event_name,7,2) EQ 'y1') then begin
            info.lincor.diff_range[1,0]  = event.value
            widget_control,info.lincor.diff_mmlabel[1,1],get_value = temp
            info.lincor.diff_range[1,1]  = temp
        endif
        if(strmid(event_name,7,2) EQ 'y2') then  begin
            info.lincor.diff_range[1,1]  = event.value
            widget_control,info.lincor.diff_mmlabel[1,0],get_value = temp
            info.lincor.diff_range[1,0]  = temp
        endif

        info.lincor.default_scale_diff[graphno] = 0
        widget_control,info.lincor.diff_recomputeID[graphno],set_value='Default Range'

        update_linearity_difference,info

        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end
    
;_______________________________________________________________________
; set the Default range or user defined range for diff plot
    (strmid(event_name,0,1) EQ 'r') : begin
        graphno = fix(strmid(event_name,1,1))
        if(info.lincor.default_scale_diff[graphno-1] eq 0 ) then begin ; true - turn to false
            widget_control,info.lincor.diff_recomputeID[graphno-1],set_value=' Plot Range '
            info.lincor.default_scale_diff[graphno-1] = 1
        endif

        update_linearity_difference,info
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end




;_______________________________________________________________________
; change x and y range of Linearity Results graph 
;_______________________________________________________________________
    (strmid(event_name,0,7) EQ 'plot_mm') : begin
        print,event_name
        if(strmid(event_name,7,1) EQ 'x') then graphno = 0 else graphno = 1 
        if(strmid(event_name,7,2) EQ 'x1') then begin
            info.lincor.plot_range[0,0]  = event.value
            widget_control,info.lincor.plot_mmlabel[0,1],get_value = temp
            info.lincor.plot_range[0,1]  = temp
        endif
        if(strmid(event_name,7,2) EQ 'x2') then begin
            info.lincor.plot_range[0,1]  = event.value
            widget_control,info.lincor.plot_mmlabel[0,0],get_value = temp
            info.lincor.plot_range[0,0]  = temp
        endif
        if(strmid(event_name,7,2) EQ 'y1') then begin
            info.lincor.plot_range[1,0]  = event.value
            widget_control,info.lincor.plot_mmlabel[1,1],get_value = temp
            info.lincor.plot_range[1,1]  = temp
        endif
        if(strmid(event_name,7,2) EQ 'y2') then  begin
            info.lincor.plot_range[1,1]  = event.value
            widget_control,info.lincor.plot_mmlabel[1,0],get_value = temp
            info.lincor.plot_range[1,0]  = temp
        endif


        info.lincor.default_scale_plot[graphno] = 0
        widget_control,info.lincor.plot_recomputeID[graphno],set_value='Default Range'

        update_linearity_result,info
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end
    
;_______________________________________________________________________
; set the Default range or user defined range for plot plot
    (strmid(event_name,0,1) EQ 'p') : begin
        graphno = fix(strmid(event_name,1,1))
        if(info.lincor.default_scale_plot[graphno-1] eq 0 ) then begin ; true - turn to false
            widget_control,info.lincor.plot_recomputeID[graphno-1],set_value=' Plot Range '
            info.lincor.default_scale_plot[graphno-1] = 1
        endif


        update_linearity_result,info
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end



;_______________________________________________________________________
; Change Integration Range  For Ramp Plots
;_______________________________________________________________________

    (strmid(event_name,0,3) EQ 'int') : begin
; changed by typing a new value
        
        if(strmid(event_name,4,4) eq 'chng') then begin
            num = fix(strmid(event_name,9,1))-1
            info.lincor.int_range[num] = event.value
        endif


; check if the <> buttons were used
        if(strmid(event_name,4,4) eq 'move') then begin
            value = intarr(2)
            value[0] = info.lincor.int_range[0]
            value[1] = info.lincor.int_range[1]

            if(strmid(event_name,9,1) eq 'u') then begin
                value[0] = value[0] + 1
                value[1] = value[1] + 1
            endif
            if(strmid(event_name,9,1) eq 'd') then begin
                value[0] = value[0] - 1
                value[1] = value[1] -1
            endif
            if(value[0] lt 1) then value[0] = 1
            if(value[1] lt 1) then value[1] = 1

            if(value[0] gt info.data.nints) then value[0] = info.data.nints
            if(value[1] gt info.data.nints)then value[1]  = info.data.nints

            info.lincor.int_range[0] = value[0]            
            info.lincor.int_range[1] = value[1]            
            widget_control,info.lincor.IrangeID[0],set_value=info.lincor.int_range[0]
            widget_control,info.lincor.IrangeID[1],set_value=info.lincor.int_range[1]
        endif

; check if overplot integrations 

        if(strmid(event_name,4,4) eq 'over') then begin
            if(info.lincor.overplot_pixel_int eq 0) then begin 
                info.lincor.int_range[0] = 1            
                info.lincor.int_range[1] = info.data.nints
                info.lincor.overplot_pixel_int = 1
                widget_control,info.lincor.OverplotID,set_value=' Plot 1 integration     '
                widget_control,info.lincor.IrangeID[0],set_value=info.lincor.int_range[0]
                widget_control,info.lincor.IrangeID[1],set_value=info.lincor.int_range[1]
            endif else begin 
                info.lincor.int_range[0] = 1            
                info.lincor.int_range[1] = 1
                info.lincor.overplot_pixel_int = 0
                widget_control,info.lincor.OverplotID,set_value=' Over Plot Integrations '
                widget_control,info.lincor.IrangeID[0],set_value=info.lincor.int_range[0]
                widget_control,info.lincor.IrangeID[1],set_value=info.lincor.int_range[1]

            endelse
                
        endif            


; Check limits for the above options for changing the integration range
; lower limit 1
; upper limit ginfo.data.nints

        for i = 0,1 do begin
            if(info.lincor.int_range[i] le 0) then info.lincor.int_range[i] = 1
            if(info.lincor.int_range[i] gt info.data.nints) then $
              info.lincor.int_range[i] = info.data.nints
        endfor
        if(info.lincor.int_range[0] gt info.lincor.int_range[1] ) then begin
            info.lincor.int_range[*] = 1
        endif	
	
        update_linearity_difference,info
        update_linearity_result,info
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info
    end

else: print," Event name not found",event_name
endcase

Widget_Control,ginfo.info.QuickLook,Set_UValue=info
end

;***********************************************************************
pro update_info,info

yvalue = fix(  info.lincor.yvalue)
xvalue = fix(  info.lincor.xvalue)
xpixel = xvalue + 1
ypixel = yvalue + 1
xs = ' x: '+ strcompress(string(fix(xpixel)),/remove_all)
ys = ' y: '+ strcompress(string(fix(ypixel)),/remove_all)


info.lincor.xs = xs
info.lincor.ys = ys
widget_control,info.lincor.diff_x_label, set_value=xs
widget_control,info.lincor.diff_y_label, set_value=ys

ii = info.lincor.int_range[0]-1
ij = info.lincor.int_range[1]-1


widget_control,info.lincor.IrangeID[0],set_value=info.lincor.int_range[0]
widget_control,info.lincor.IrangeID[1],set_value=info.lincor.int_range[1]

Widget_Control,info.QuickLook,Set_UValue=info

end
;***********************************************************************
pro update_linearity_difference,info,ps = ps, eps = eps
save_color = info.col_table
color6
!p.multi = 0

hcopy = 0
if ( (keyword_set(ps)) or ( keyword_set(eps)) ) then hcopy = 1
stitle = ' '
sstitle = ' ' 

yvalue = fix(  info.lincor.yvalue)
xvalue = fix(  info.lincor.xvalue)


badpixel = 0
if( (*info.badpixel.pmask)[xvalue,yvalue] and 1 ) then badpixel =1

ii = info.lincor.int_range[0]-1
ij = info.lincor.int_range[1]-1
num_int = info.lincor.int_range[1] - info.lincor.int_range[0] + 1


lc_data = (*info.lincor.plcdata)[ii:ij,*,0]
lc_diff = fltarr(num_int,info.data.nramps-1)

if(info.control.file_ids_exist eq 1) then begin
    cr_data = (*info.lincor.piddata)[ii:ij,*,0]
endif else begin
    cr_data = lc_data ; 
    cr_data[*] = 0
endelse


xmax = 0


ymin = 10000
ymax = -10000

for k = 0,num_int-1 do begin
    for j= 0,info.data.nramps-2 do begin
        lc_diff[k,j] = lc_data[k,j+1] - lc_data[k,j]
;        print,'lin data',lc_diff[k,j], lc_data[k,j+1] , lc_data[k,j]
        if(j+1 ge info.image.start_fit and j+2 le info.image.end_fit) then begin
            if(lc_diff[k,j] gt ymax) then ymax = lc_diff[k,j]
            if(lc_diff[k,j] lt ymin) then ymin = lc_diff[k,j]
        endif
        
        if(finite(lc_diff[k,j]) eq 1) then xmax = j
    endfor
endfor 

;-----------------------------------------------------------------------
; find x and y min/max
xmin = 0
xvalues = findgen(xmax) + 1 ;
 

if(badpixel eq 1) then begin
    ymin = 0
    ymax = 1
endif

ypad = (ymax)*.05

; check if default scale is true - then reset to orginal value
if(info.lincor.default_scale_diff[0] eq 1) then begin
    info.lincor.diff_range[0,0] = xmin-1
    info.lincor.diff_range[0,1] = xmax+1
endif 
  
if(info.lincor.default_scale_diff[1] eq 1) then begin

    if(ypad gt 0) then begin 
        info.lincor.diff_range[1,0] = ymin-ypad 
        info.lincor.diff_range[1,1] = ymax+ypad
    endif else begin
        info.lincor.diff_range[1,0] = ymin+ypad 
        info.lincor.diff_range[1,1] = ymax-ypad
    endelse

endif


if(hcopy eq 1) then begin
    sstitle = info.control.filebase + '.fits: ' 
    pvalue = strtrim(xvalue+1,2) + ' ' + strtrim(yvalue+1,2)
    stitle = "Frames values for selected pixel :"  +  pvalue
endif

x1 = info.lincor.diff_range[0,0]
x2 = info.lincor.diff_range[0,1]
y1 = info.lincor.diff_range[1,0]
y2 = info.lincor.diff_range[1,1]
if(badpixel eq 1) then  begin
    xpt = (x2 - x1)/2.0
    ypt = (y2 - y1)/2.0
    pixeldata = fltarr(2) 
endif

xs = "Frame #" + info.lincor.xs + info.lincor.ys
ys = " Adjacent Frame differences "


if(hcopy eq 0 ) then wset,info.lincor.draw_window_id1    
;_______________________________________________________________________
plot,xvalues,xvalues,xtitle = xs, ytitle=ys,$
  xrange=[x1,x2],yrange=[y1,y2],title = stitle, subtitle = sstitle,$
     xstyle = 1, ystyle = 1,/nodata,ytickformat = '(f8.0)'


if(badpixel eq 1) then begin
    xyouts,xpt,ypt,' BAD PIXEL'
    return
endif

ptype = [1,2,4,5,6]


BAD_FRAME = info.dqflag.CorruptFrame
BAD_FRAME_SYM = 5

NOISE_SPIKE = info.dqflag.NoiseSpike
COSMICRAY_SLOPE_FAILURE = info.dqflag.cr_slope_failure
REJECT_AFTER_NOISE_SPIKE = info.dqflag.reject_after_noise
REJECT_AFTER_CR = info.dqflag.reject_after_cr
SEG_MIN_FAILURE = info.dqflag.cr_seg_min
NOISE_FLAG = noise_spike

COSMICRAY = info.dqflag.CosmicRay
COSMICRAY_NEG =info.dqflag.NegCosmicRay

isp =0 
for k = 0,num_int-1 do begin
    n_noise = 0
    n_cr = 0
    n_corrupt = 0
    marked = intarr(info.data.nramps)

    index_noise = where(cr_data[k,*] eq  NOISE_SPIKE or cr_data[k,*] eq COSMICRAY_SLOPE_FAILURE $
                        or cr_data[k,*] eq REJECT_AFTER_NOISE_SPIKE  or cr_data[k,*] eq REJECT_AFTER_CR  $
                        or cr_data[k,*]  eq SEG_MIN_FAILURE, n_noise)
    index_cr  = where(cr_data[k,*] eq COSMICRAY or cr_data[k,*] eq COSMICRAY_NEG, n_cr)
    index_corrupt = where(cr_data[k,*] eq BAD_FRAME, n_corrupt)
    if(n_noise gt 0)  then marked[index_noise] =NOISE_FLAG
    if(n_cr gt 0) then marked[index_cr] = COSMICRAY
    if(n_corrupt gt 0) then marked[index_corrupt] = BAD_FRAME

    xvalues = indgen(info.data.nramps)+1
    xgood = intarr(info.data.nramps)
    valid = where(finite(lc_diff[k,*]) eq 1,nvalid)
    xgood[valid] = 1

    ydiff = lc_diff[k,valid]
    xvalues_diff = xvalues[valid]
    

;    for i = 0, info.data.nramps-1 do begin
    for i = 0, nvalid-1 do begin
        if(xvalues_diff[i] ge info.image.start_fit and xvalues[i] le info.image.end_fit)then begin
            xplot = fltarr(1) & yplot = fltarr(1)
            xplot[0] = xvalues_diff[i] 
            yplot[0] = ydiff[i]

            oplot,xplot,yplot,psym = ptype[isp],symsize = 0.8,color= info.green

            if(marked[i]  eq  16) then $
              oplot,xplot,yplot,psym = ptype[isp],symsize = 0.8,color= info.yellow
            
            if(marked[i]  eq  32) then $
              oplot,xplot,yplot,psym = ptype[isp],symsize = 0.8,color= info.yellow
            
            if(marked[i]  eq  -2) then $
              oplot,xplot,yplot,psym = 6,symsize = 1.2,color= info.yellow
        endif 
    endfor


    isp = isp + 1
    if(isp gt 4) then isp = 0
    
    

endfor

widget_control,info.lincor.diff_mmlabel[0,0],set_value=fix(info.lincor.diff_range[0,0])
widget_control,info.lincor.diff_mmlabel[0,1],set_value=fix(info.lincor.diff_range[0,1])
widget_control,info.lincor.diff_mmlabel[1,0],set_value=info.lincor.diff_range[1,0]
widget_control,info.lincor.diff_mmlabel[1,1],set_value=info.lincor.diff_range[1,1]
    
pixeldata = 0
slopedata = 0

ydiff = 0 & xvalues =0 & xgood = 0 & valid = 0 
yvalues = 0
xvalues = 0
info.col_table = save_color
end

;_______________________________________________________________________

pro update_linearity_result,info,ps = ps, eps = eps
save_color = info.col_table
color6
!p.multi = 0

hcopy = 0
if ( (keyword_set(ps)) or ( keyword_set(eps)) ) then hcopy = 1
stitle = ' '
sstitle = ' ' 

yvalue = fix(  info.lincor.yvalue)
xvalue = fix(  info.lincor.xvalue)

badpixel = 0

if( (*info.badpixel.pmask)[xvalue,yvalue] and 1 ) then badpixel =1

ii = info.lincor.int_range[0]-1
ij = info.lincor.int_range[1]-1
num_int = info.lincor.int_range[1] - info.lincor.int_range[0] + 1

slopedata = (*info.lincor.pslopedata)[ii:ij,*]
lc_data = (*info.lincor.plcdata)[ii:ij,*,0]

xnew = findgen(info.data.nramps) + 1 ; 
ylinear = fltarr(num_int,info.data.nramps)


yresult = fltarr(num_int,info.data.nramps)    
for k = 0,num_int-1 do begin
    slope = slopedata[k,0]*info.lincor.frame_time
    ;print,'slope',slope
    yint = slopedata[k,1]
    ylinear[k,*] = slope*xnew[*] + yint


    for i = 0, info.data.nramps-1 do begin
        if(xnew[i] lt info.image.start_fit or xnew[i] gt info.image.end_fit)then begin
            yresult[k,i] = -99.9
        endif else begin
            
            yresult[k,i] = (lc_data[k,i] - ylinear[k,i])/ylinear[k,i]
            yresult[k,i] = yresult[k,i] * 100.0
            if(  finite(lc_data[k,i]) eq 0) then yresult[k,i] = -99.9
        endelse
    endfor
endfor

;for i = 0,info.data.nramps-1 do begin
;        print,yresult[0,i],lc_data[0,i],ylinear[0,i]
;endfor


if(hcopy eq 0 ) then wset,info.lincor.draw_window_id2


xvalues = indgen(info.data.nramps) + 1
yfirst = yresult[0,*]
index = where( yfirst ne -99.9) 


ymin = min(yfirst[index])
ymax = max(yfirst[index])
ypad = (ymax)*.05

if(info.lincor.overplot_pixel_int) then xvalues = indgen(info.data.nramps)+1 
xmin = min(xvalues[index])
xmax = max(xvalues[index])

if(badpixel eq 1) then begin
    ymin = 0
    ymax = 1
endif


; check if default scale is true - then reset to orginal value
if(info.lincor.default_scale_plot[0] eq 1) then begin
    info.lincor.plot_range[0,0] = xmin-1
    info.lincor.plot_range[0,1] = xmax+1
endif 
  
if(info.lincor.default_scale_plot[1] eq 1) then begin

    if(ypad gt 0) then begin 
        info.lincor.plot_range[1,0] = ymin-ypad 
        info.lincor.plot_range[1,1] = ymax+ypad
    endif else begin
        info.lincor.plot_range[1,0] = ymin+ypad 
        info.lincor.plot_range[1,1] = ymax-ypad
    endelse

endif


if(hcopy eq 1) then begin
    sstitle = info.control.filebase + '.fits: ' 
    pvalue = strtrim(xvalue+1,2) + ' ' + strtrim(yvalue+1,2)
    stitle = "Frames values for selected pixel :"  +  pvalue
endif

x1 = info.lincor.plot_range[0,0]
x2 = info.lincor.plot_range[0,1]
y1 = info.lincor.plot_range[1,0]
y2 = info.lincor.plot_range[1,1]



if(badpixel eq 1) then  begin
    xpt = (x2 - x1)/2.0
    ypt = (y2 - y1)/2.0
    pixeldata = fltarr(2) 
endif

xs = "Frame #" + info.lincor.xs + info.lincor.ys
ys = " (Linear Corrected - Linear Fit)/Linear Fit  X 100 "

plot,xvalues,xvalues,xtitle = xs, ytitle=ys,$
  xrange=[x1,x2],yrange=[y1,y2],title = stitle, subtitle = sstitle,$
     xstyle = 1, ystyle = 1,/nodata,ytickformat = '(f7.3)'



if(badpixel eq 1) then begin
    xyouts,xpt,ypt,' BAD PIXEL'
    return
endif

ptype = [1,2,4,5,6]

isp = 4
for k = 0,num_int-1 do begin

    xplot = xnew + info.data.nramps*k
    if(info.lincor.overplot_pixel_int eq 1) then xplot = xnew

    yplot = yresult[k,*] ; slope data
    index = where(yresult[k,*] ne -99.9)
;    print,k,xplot[index],yplot[index]


    oplot,xplot[index],yplot[index],psym=ptype[isp],color= info.blue,thick = 2

    xnew_plot = 0 & ynew_plot = 0
    isp = isp + 1
    if(isp gt 4) then isp = 0
    
    
 if(num_int gt 1 and info.lincor.overplot_pixel_int eq 0) then begin
     yline = fltarr(2) & xline = fltarr(2)
     yline[0] = -1000000 & yline[1] = 100000
     xline[*] = info.data.nramps* (k+1)
     oplot,xline,yline,linestyle=3
 endif
endfor


yline = fltarr(2) & xline = fltarr(2)
xline[1] = info.data.nramps* (k+1)

yline[0] = 0.25 & yline[1] = 0.25

oplot,xline,yline,linestyle=3

yline[0] = -0.25 & yline[1] = -0.25

oplot,xline,yline,linestyle=3

widget_control,info.lincor.plot_mmlabel[0,0],set_value=fix(info.lincor.plot_range[0,0])
widget_control,info.lincor.plot_mmlabel[0,1],set_value=fix(info.lincor.plot_range[0,1])
widget_control,info.lincor.plot_mmlabel[1,0],set_value=info.lincor.plot_range[1,0]
widget_control,info.lincor.plot_mmlabel[1,1],set_value=info.lincor.plot_range[1,1]



slopedata = 0
xnew = 0
ynew = 0
yvalues = 0
xvalues = 0
info.col_table = save_color


end



;***********************************************************************
;***********************************************************************
pro display_linearity_correction_results,info


window,1,/pixmap
wdelete,1
if(XRegistered ('lcr')) then begin
    widget_control,info.LinCorResults,/destroy
endif

; widget window parameters
xwidget_size = 850
ywidget_size = 920
xsize_scroll = 780
ysize_scroll =900

if(info.lincor.uwindowsize eq 1) then begin ; user has set window size 
    xsize_scroll =info.lincor.xwindowsize
    ysize_scroll =info.lincor.ywindowsize
endif

if(info.control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.control.x_scroll_window
if(info.control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.control.y_scroll_window
if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-20
if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-20




LinCorResults = widget_base(title='MIRI Quick Look - Linearity Correction Results' ,$
                          col = 1,mbar = menuBar,group_leader = info.QuickLook,$
                          xsize = xwidget_size,$
                          ysize= ywidget_size,/scroll,$
                          x_scroll_size=xsize_scroll,y_scroll_size=ysize_scroll,/TLB_SIZE_EVENTS)



QuitMenu = widget_button(menuBar,value="Quit",font = info.font2)
; add quit button
quitbutton = widget_button(quitmenu,value="Quit",event_pro='linearity_correction_quit')
;PMenu = widget_button(menuBar,value="Print",font = info.font2)
;PbuttonR = widget_button(Pmenu,value = "Print Column Slice Plot to an output file",uvalue='printP')
;PbuttonD = widget_button(Pmenu,value = "Print Column Slice Data to ascii file ",uvalue='printD')

;********
; build the menubar
;********


tlabelID = widget_label(LinCorResults,$
                        value = " Linearity Corrected & Linear Values for Selected Pixel for Given " $
                        + "Integration Range",$
                        /align_center,$
                        font=info.font5,/sunken_frame)

;_______________________________________________________________________

diff_range = fltarr(2,2)        ; plot range for the diff plot, 

; button to change selected pixel

pix_num_base = widget_base(LinCorResults,row=1,/align_center)

xs = ' x: '+ strcompress(string(fix(info.lincor.xvalue) +1),/remove_all)
ys = ' y: '+ strcompress(string(fix(info.lincor.yvalue)+ 1),/remove_all)

int_range = intarr(2) 
int_range[0] = 1  ; initialize to look at first integration
int_range[1] = 1
info.lincor.int_range[*] = int_range[*]

move_base = widget_base(LinCorResults,/row,/align_left)


IrangeID = lonarr(2)
info.lincor.IrangeID[0] = cw_field(move_base,$
                  title="Integration range: Start", $
                  uvalue="int_chng_1",/integer,/return_events, $
                  value=info.lincor.int_range[0],xsize=4,$
                  fieldfont=info.font3)
info.lincor.IrangeID[1] = cw_field(move_base,$
                  title="End", $
                  uvalue="int_chng_2",/integer,/return_events, $
                  value=info.lincor.int_range[1],xsize=4,$
                  fieldfont=info.font3)

labelID = widget_button(move_base,uvalue='int_move_d',value='<',font=info.font3)
labelID = widget_button(move_base,uvalue='int_move_u',value='>',font=info.font3)

info.lincor.diff_x_label = widget_label (move_base,value=xs,/dynamic_resize)
info.lincor.diff_y_label = widget_label (move_base,value=ys,/dynamic_resize)


info.lincor.OverPlotID = Widget_button(move_base, Value = 'Over plot Integrations',$
                           uvalue = 'int_overplot',/align_left)
;widget_control,IAllButton,Set_Button = 0
;_______________________________________________________________________

graph_master1 = widget_base(LinCorResults,row=1)
graph_master2 = widget_base(LinCorResults,row=1)
graphID1 = widget_base(graph_master1,col=1)
graphID12 = widget_base(graph_master1,col=1)
graphID2 = widget_base(graph_master2,col=1)
graphID22 = widget_base(graph_master2,col=1)




info.lincor.graphID1 = widget_draw(graphID1,$
                                    xsize = info.plotsize2,$
                                    ysize = info.plotsize3,$
                                    retain=info.retn)

;_______________________________________________________________________

info.lincor.default_scale_diff[*] = 1
pix_num_base2 = widget_base(graphID1,row=1)
labelID = widget_label(pix_num_base2,value="X->",font=info.font4)
info.lincor.diff_mmlabel[0,0] = cw_field(pix_num_base2,title="min:",font=info.font4, $
                                        uvalue="diff_mmx1",/integer,/return_events, $
                                        value=fix(diff_range[0,0]), $
                                        xsize=info.xsize_label,fieldfont=info.font4)

info.lincor.diff_mmlabel[0,1] = cw_field(pix_num_base2,title="max:",font=info.font4, $
                                        uvalue="diff_mmx2",/integer,/return_events, $
                                        value=fix(diff_range[0,1]),xsize=info.xsize_label,$
                                        fieldfont=info.font4)

info.lincor.diff_recomputeID[0] = widget_button(pix_num_base2,value='  Plot Range  ',$
                                               font=info.font4,$
                                               uvalue = 'r1')


labelID = widget_label(pix_num_base2,value="Y->",font=info.font4)
info.lincor.diff_mmlabel[1,0] = cw_field(pix_num_base2,title="min:",font=info.font4, $
                                        uvalue="diff_mmy1",/float,/return_events, $
                                        value=diff_range[1,0],xsize=info.xsize_label,$
                                        fieldfont=info.font4)

info.lincor.diff_mmlabel[1,1] = cw_field(pix_num_base2,title="max:",font=info.font4, $
                                        uvalue="diff_mmy2",/float,/return_events, $
                                        value=diff_range[1,1],xsize=info.xsize_label,$
                                        fieldfont=info.font4)

info.lincor.diff_recomputeID[1] = widget_button(pix_num_base2,value='  Plot Range  ',$
                                               font=info.font4,$
                                               uvalue = 'r2')

info.lincor.diff_range = diff_range


;_______________________________________________________________________
; Second plot


info.lincor.graphID2 = widget_draw(graphID2,$
                                    xsize = info.plotsize2,$
                                    ysize = info.plotsize3,$
                                    retain=info.retn)


;buttons to  change the x and y ranges

info.lincor.default_scale_plot[*] = 1
pix_num_base2 = widget_base(graphID2,row=1)
labelID = widget_label(pix_num_base2,value="X->",font=info.font4)
info.lincor.plot_mmlabel[0,0] = cw_field(pix_num_base2,title="min:",font=info.font4, $
                                        uvalue="plot_mmx1",/integer,/return_events, $
                                        value=fix(diff_range[0,0]), $
                                        xsize=info.xsize_label,fieldfont=info.font4)

info.lincor.plot_mmlabel[0,1] = cw_field(pix_num_base2,title="max:",font=info.font4, $
                                        uvalue="plot_mmx2",/integer,/return_events, $
                                        value=fix(diff_range[0,1]),xsize=info.xsize_label,$
                                        fieldfont=info.font4)

info.lincor.plot_recomputeID[0] = widget_button(pix_num_base2,value='  Plot Range  ',$
                                               font=info.font4,$
                                               uvalue = 'p1')


labelID = widget_label(pix_num_base2,value="Y->",font=info.font4)
info.lincor.plot_mmlabel[1,0] = cw_field(pix_num_base2,title="min:",font=info.font4, $
                                        uvalue="plot_mmy1",/float,/return_events, $
                                        value=diff_range[1,0],xsize=info.xsize_label,$
                                        fieldfont=info.font4)

info.lincor.plot_mmlabel[1,1] = cw_field(pix_num_base2,title="max:",font=info.font4, $
                                        uvalue="plot_mmy2",/float,/return_events, $
                                        value=diff_range[1,1],xsize=info.xsize_label,$
                                        fieldfont=info.font4)

info.lincor.plot_recomputeID[1] = widget_button(pix_num_base2,value='  Plot Range  ',$
                                               font=info.font4,$
                                               uvalue = 'p2')

info.lincor.plot_range = diff_range

Widget_control,LinCorResults,/Realize

XManager,'lcr',LinCorResults,/No_Block,event_handler='lin_cor_event'

widget_control,info.lincor.graphID1,get_value=tdraw_id
info.lincor.draw_window_id1 = tdraw_id

widget_control,info.lincor.graphID2,get_value=tdraw_id
info.lincor.draw_window_id2 = tdraw_id


info.LinCorResults = LinCorResults

Widget_Control,info.QuickLook,Set_UValue=info
sinfo = {info        : info}

Widget_Control,info.LincorResults,Set_UValue=sinfo
Widget_Control,info.QuickLook,Set_UValue=info


update_info,info
update_linearity_difference,info
update_linearity_result,info

Widget_Control,info.QuickLook,Set_UValue=info


end
