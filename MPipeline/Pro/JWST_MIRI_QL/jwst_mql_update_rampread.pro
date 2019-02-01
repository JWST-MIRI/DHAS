pro jwst_mql_update_rampread,info,ps = ps, eps = eps
save_color = info.col_table
color6
!p.multi = 0

hcopy = 0
if ( (keyword_set(ps)) or ( keyword_set(eps)) ) then hcopy = 1
stitle = ' '
sstitle = ' ' 

xvalue = fix(  (info.jwst_image.x_pos) *info.jwst_image.binfactor)
yvalue = fix(  (info.jwst_image.y_pos) *info.jwst_image.binfactor)

xpixel = xvalue + 1
ypixel = yvalue + 1
xs = ' x: '+ strcompress(string(fix(xpixel)),/remove_all)
ys = ' y: '+ strcompress(string(fix(ypixel)),/remove_all)

; do not update pixel values - clear out values
if(info.jwst_image.autopixelupdate eq 0) then begin
    xs = ' Not updating pixel values'
    ys = ' '
    widget_control,info.jwst_image.ramp_x_label, set_value=xs
    widget_control,info.jwst_image.ramp_y_label, set_value=ys    
    if(hcopy eq 0 ) then wset,info.jwst_image.draw_window_id[3]
    xvalues = fltarr(10) & pixeldata = fltarr(10)
    x1 = info.jwst_image.ramp_range[0,0]
    x2 = info.jwst_image.ramp_range[0,1]
    y1 = info.jwst_image.ramp_range[1,0]
    y2 = info.jwst_image.ramp_range[1,1]
    plot,xvalues,pixeldata,xtitle = "Frame #", ytitle='DN ',$
         xrange=[x1,x2],yrange=[y1,y2],title = stitle, subtitle = sstitle,$
         xstyle = 1, ystyle = 1,/nodata
    return
endif

ii = info.jwst_image.int_range[0]-1
ij = info.jwst_image.int_range[1]-1

widget_control,info.jwst_image.IrangeID[0],set_value=info.jwst_image.int_range[0]
widget_control,info.jwst_image.IrangeID[1],set_value=info.jwst_image.int_range[1]
num_int = info.jwst_image.int_range[1] - info.jwst_image.int_range[0] + 1

if( ptr_valid(info.jwst_image.ppixeldata) eq 0) then  begin
    mql_read_rampdata,xvalue,yvalue,pixeldata,info  

    if ptr_valid (info.jwst_image.ppixeldata) then ptr_free,info.jwst_image.ppixeldata
    info.jwst_image.ppixeldata = ptr_new(pixeldata)    
endif

pixeldata = (*info.jwst_image.ppixeldata)[ii:ij,*,0]

xnew = findgen(info.jwst_data.ngroups) + 1 ; 
if(info.jwst_image.overplot_fit eq 1) then  begin 
    slopedata = (*info.jwst_image.pslope_pixeldata)[ii:ij,*]
    ynew = fltarr(num_int,info.jwst_data.ngroups)
    
    for k = 0,num_int-1 do begin
       slope = slopedata[k,0]*info.jwst_data.frame_time
       yint = slopedata[k,1]
       ynew[k,*] = slope*xnew[*] + yint
    endfor
    ymin_cal = min(ynew,/nan)
    ymax_cal = max(ynew,/nan)
endif

if(info.jwst_control.file_refpix_exist eq 0) then info.jwst_image.overplot_refpix = 0

if(info.jwst_image.overplot_refpix eq 1) then begin
    refcorrected_data = (*info.jwst_image.prefpix_pixeldata)[ii:ij,*,0]
    ymin_corrected = min(refcorrected_data,/nan)
    ymax_corrected = max(refcorrected_data,/nan)
endif


if(info.jwst_control.file_linearity_exist eq 0) then info.jwst_image.overplot_lin = 0
if(info.jwst_image.overplot_lin eq 1) then begin
    lin_data = (*info.jwst_image.plin_pixeldata)[ii:ij,*,0]
    ymin_lin = min(lin_data,/nan)
    ymax_lin = max(lin_data,/nan)
endif

if(info.jwst_control.file_dark_exist eq 0) then info.jwst_image.overplot_dark = 0
if(info.jwst_image.overplot_dark eq 1 ) then begin
    dark_data = (*info.jwst_image.pdark_pixeldata)[ii:ij,*,0]
    ymin_dark = min(dark_data,/nan)
    ymax_dark = max(dark_data,/nan)
 endif

if(info.jwst_control.file_reset_exist eq 0) then info.jwst_image.overplot_reset = 0
if(info.jwst_image.overplot_reset eq 1 ) then begin
   reset_data = (*info.jwst_image.preset_pixeldata)[ii:ij,*,0]
   ymin_reset = min(reset_data,/nan)
   ymax_reset = max(reset_data,/nan)
endif

if(info.jwst_control.file_rscd_exist eq 0) then info.jwst_image.overplot_rscd = 0
if(info.jwst_image.overplot_rscd eq 1 ) then begin
   rscd_data = (*info.jwst_image.prscd_pixeldata)[ii:ij,*,0]
   ymin_rscd = min(rscd_data,/nan)
   ymax_rscd = max(rscd_data,/nan)
endif

if(info.jwst_control.file_lastframe_exist eq 0) then info.jwst_image.overplot_lastframe = 0
if(info.jwst_image.overplot_lastframe eq 1 ) then begin
    lastframe_data = (*info.jwst_image.plastframe_pixeldata)[ii:ij,0]
endif


widget_control,info.jwst_image.ramp_x_label, set_value=xs
widget_control,info.jwst_image.ramp_y_label, set_value=ys

if(hcopy eq 0 ) then wset,info.jwst_image.draw_window_id[3]

n_reads = n_elements(pixeldata)
xvalues = indgen(n_reads) + 1

if(info.jwst_image.overplot_pixel_int) then xvalues = indgen(info.jwst_data.ngroups)+1 
xmin = min(xvalues)
xmax = max(xvalues)
ymin = min(pixeldata,/nan)
ymax = max(pixeldata,/nan)

if(info.jwst_image.overplot_fit) then begin
    if(ymin_cal lt ymin and ymin_cal ne 0) then ymin = ymin_cal
    if(ymax_cal gt ymax) then ymax = ymax_cal
endif


if(info.jwst_image.overplot_refpix eq 1) then begin
    if(ymin_corrected lt ymin and ymin_corrected ne 0 ) then ymin = ymin_corrected
    if(ymax_corrected gt ymax) then ymax = ymax_corrected
 endif

if(info.jwst_image.overplot_dark eq 1) then begin
    if(ymin_dark lt ymin and ymin_dark ne 0 ) then ymin = ymin_dark
    if(ymax_dark gt ymax) then ymax = ymax_dark
 endif

if(info.jwst_image.overplot_reset eq 1) then begin
    if(ymin_reset lt ymin and ymin_reset ne 0 ) then ymin = ymin_reset
    if(ymax_reset gt ymax) then ymax = ymax_reset
 endif

if(info.jwst_image.overplot_lin eq 1) then begin
    if(ymin_lin lt ymin and ymin_lin ne 0 ) then ymin = ymin_lin
    if(ymax_lin gt ymax) then ymax = ymax_lin
endif

if(info.jwst_image.overplot_rscd eq 1) then begin
    if(ymin_rscd lt ymin and ymin_rscd ne 0 ) then ymin = ymin_rscd
    if(ymax_rscd gt ymax) then ymax = ymax_rscd
endif

if(ymax gt 70000) then ymax = 70000

ypad = (ymax)*.05

; check if default scale is true - then reset to orginal value
if(info.jwst_image.default_scale_ramp[0] eq 1) then begin
    info.jwst_image.ramp_range[0,0] = xmin-1
    info.jwst_image.ramp_range[0,1] = xmax+1
endif 
  
if(info.jwst_image.default_scale_ramp[1] eq 1) then begin
    if(ypad gt 0) then begin 
        info.jwst_image.ramp_range[1,0] = ymin-ypad 
        info.jwst_image.ramp_range[1,1] = ymax+ypad
    endif else begin
        info.jwst_image.ramp_range[1,0] = ymin+ypad 
        info.jwst_image.ramp_range[1,1] = ymax-ypad
    endelse
endif

if(hcopy eq 1) then begin
    i = info.jwst_image.integrationNO
    j = info.jwst_image.frameNO
    
    ftitle = " Frame #: " + strtrim(string(i+1),2) 
    ititle = " Integration #: " + strtrim(string(j+1),2)
    sstitle = info.jwst_control.filebase + '.fits: ' + ftitle + ititle
    pvalue = strtrim(xvalue+1,2) + ' ' + strtrim(yvalue+1,2)
    stitle = "Frames values for selected pixel :"  +  pvalue
endif

x1 = info.jwst_image.ramp_range[0,0]
x2 = info.jwst_image.ramp_range[0,1]
y1 = info.jwst_image.ramp_range[1,0]
y2 = info.jwst_image.ramp_range[1,1]

xs = "Frame #" + xs + ys
ys = "DN/frame"

plot,xvalues,pixeldata,xtitle = xs, ytitle=ys,$
  xrange=[x1,x2],yrange=[y1,y2],title = stitle, subtitle = sstitle,$
     xstyle = 1, ystyle = 1,/nodata,ytickformat = '(f8.0)'


ptype = [1,2,4,5,6]

for k = 0,num_int-1 do begin
    yvalues = pixeldata[k,*,*]
    xvalues = indgen(info.jwst_data.ngroups)+1
    if(info.jwst_image.overplot_pixel_int eq 0) then xvalues = xvalues + info.jwst_data.ngroups*(k)
    oplot,xvalues,yvalues,psym = 1,symsize = 0.8,color = info.white

    if(hcopy eq 1) then     oplot,xvalues,yvalues,psym = 1,symsize = 0.8,color = info.black


    if(info.jwst_image.overplot_fit) then begin
        xnew_plot = xnew + info.jwst_data.ngroups*k
        if(info.jwst_image.overplot_pixel_int eq 1) then xnew_plot = xnew
        ynew_plot = ynew[k,*]
        oplot,xnew_plot,ynew_plot,linestyle= 0,color= info.red,thick = 1.5
        xnew_plot = 0 & ynew_plot = 0
    endif

    if(info.jwst_image.overplot_refpix eq 1) then begin
        ynew_plot = refcorrected_data[k,*]
        for i = 0, info.jwst_data.ngroups-1 do begin
            if(xnew[i] ge info.jwst_data.start_fit and xnew[i] le info.jwst_data.end_fit)then begin
                xplot = fltarr(1) & yplot = fltarr(1)
                xplot[0] = xvalues[i] & yplot[0] = ynew_plot[i]
                oplot,xplot,yplot,psym = 6,symsize = 0.8,color= info.blue
            endif 
        endfor
        xnew_plot = 0 & ynew_plot = 0
    endif

    if(info.jwst_image.overplot_lin eq 1) then begin
        ynew_plot = lin_data[k,*]
        for i = 0, info.jwst_data.ngroups-1 do begin
            if(xnew[i] ge info.jwst_data.start_fit and xnew[i] le info.jwst_data.end_fit)then begin
                xplot = fltarr(1) & yplot = fltarr(1)
                xplot[0] = xvalues[i] & yplot[0] = ynew_plot[i]
                oplot,xplot,yplot,psym =1,symsize = 0.8,color= info.blue
            endif 
        endfor
        xnew_plot = 0 & ynew_plot = 0
    endif

;_______________________________________________________________________
    if(info.jwst_image.overplot_dark eq 1)  then begin
        ynew_plot = dark_data[k,*]
        for i = 0, info.jwst_data.ngroups-1 do begin
            if(xnew[i] ge info.jwst_data.start_fit and xnew[i] le info.jwst_data.end_fit)then begin
                xplot = fltarr(1) & yplot = fltarr(1)
                xplot[0] = xvalues[i] & yplot[0] = ynew_plot[i]
                oplot,xplot,yplot,psym =6,symsize = 0.5,color= info.green
            endif 
        endfor
        xnew_plot = 0 & ynew_plot = 0
    endif
;_______________________________________________________________________
    if(info.jwst_image.overplot_reset eq 1)  then begin
        ynew_plot = reset_data[k,*] ; k number of integrations

        for i = 0, info.jwst_data.ngroups-1 do begin
            if(xnew[i] ge info.jwst_data.start_fit and xnew[i] le info.jwst_data.end_fit)then begin
                xplot = fltarr(1) & yplot = fltarr(1)
                xplot[0] = xvalues[i] & yplot[0] = ynew_plot[i]
                oplot,xplot,yplot,psym =1,symsize = 1.0,color= info.green
            endif 
        endfor
        xnew_plot = 0 & ynew_plot = 0
    endif
;_______________________________________________________________________
    if(info.jwst_image.overplot_rscd eq 1)  then begin
        ynew_plot = rscd_data[k,*] ; k number of integrations
        for i = 0, info.jwst_data.ngroups-1 do begin
            if(xnew[i] ge info.jwst_data.start_fit and xnew[i] le info.jwst_data.end_fit)then begin
                xplot = fltarr(1) & yplot = fltarr(1)
                xplot[0] = xvalues[i] & yplot[0] = ynew_plot[i]
                oplot,xplot,yplot,psym =1,symsize = 1.0,color= info.green
            endif 
        endfor
        xnew_plot = 0 & ynew_plot = 0
    endif
;_______________________________________________________________________
    if(info.jwst_image.overplot_lastframe eq 1)  then begin
        ynew_plot = lastframe_data[k] ; k number of integrations

        for i = info.jwst_data.ngroups-1, info.jwst_data.ngroups-1 do begin
            if(xnew[i] ge info.jwst_data.start_fit and xnew[i] le info.jwst_data.end_fit)then begin
                xplot = fltarr(1) & yplot = fltarr(1)
                xplot[0] = xvalues[i] & yplot[0] = ynew_plot;[k]
                oplot,xplot,yplot,psym =4,symsize = 1.0,color= info.blue
            endif 
        endfor
        xnew_plot = 0 & ynew_plot = 0
     endif
;_______________________________________________________________________
 if(num_int gt 1 and info.jwst_image.overplot_pixel_int eq 0) then begin
     yline = fltarr(2) & xline = fltarr(2)
     yline[0] = -1000000 & yline[1] = 100000
     xline[*] = info.jwst_data.ngroups* (k+1)
     oplot,xline,yline,linestyle=3
 endif
endfor

widget_control,info.jwst_image.ramp_mmlabel[0,0],set_value=fix(info.jwst_image.ramp_range[0,0])
widget_control,info.jwst_image.ramp_mmlabel[0,1],set_value=fix(info.jwst_image.ramp_range[0,1])
widget_control,info.jwst_image.ramp_mmlabel[1,0],set_value=info.jwst_image.ramp_range[1,0]
widget_control,info.jwst_image.ramp_mmlabel[1,1],set_value=info.jwst_image.ramp_range[1,1]

    
pixeldata = 0
slopedata = 0
xnew = 0
ynew = 0
yvalues = 0
xvalues = 0
info.col_table = save_color
end
