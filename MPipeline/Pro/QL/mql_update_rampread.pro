pro mql_update_rampread,info,ps = ps, eps = eps
save_color = info.col_table
color6
!p.multi = 0


hcopy = 0
if ( (keyword_set(ps)) or ( keyword_set(eps)) ) then hcopy = 1
stitle = ' '
sstitle = ' ' 

xvalue = fix(  (info.image.x_pos) *info.image.binfactor)
yvalue = fix(  (info.image.y_pos) *info.image.binfactor)

xpixel = xvalue + 1
ypixel = yvalue + 1
xs = ' x: '+ strcompress(string(fix(xpixel)),/remove_all)
ys = ' y: '+ strcompress(string(fix(ypixel)),/remove_all)

; do not update pixel values - clear out values
if(info.image.autopixelupdate eq 0) then begin
    xs = ' Not updating pixel values'
    ys = ' '
    widget_control,info.image.ramp_x_label, set_value=xs
    widget_control,info.image.ramp_y_label, set_value=ys    
    if(hcopy eq 0 ) then wset,info.image.draw_window_id[3]
    xvalues = fltarr(10) & pixeldata = fltarr(10)
    x1 = info.image.ramp_range[0,0]
    x2 = info.image.ramp_range[0,1]
    y1 = info.image.ramp_range[1,0]
    y2 = info.image.ramp_range[1,1]
    plot,xvalues,pixeldata,xtitle = "Frame #", ytitle='DN ',$
         xrange=[x1,x2],yrange=[y1,y2],title = stitle, subtitle = sstitle,$
         xstyle = 1, ystyle = 1,/nodata
    return
endif


badpixel = 0
if( (*info.badpixel.pmask)[xvalue,yvalue] and 1 and info.image.apply_bad eq 1 ) then badpixel =1

ii = info.image.int_range[0]-1
ij = info.image.int_range[1]-1


widget_control,info.image.IrangeID[0],set_value=info.image.int_range[0]
widget_control,info.image.IrangeID[1],set_value=info.image.int_range[1]
num_int = info.image.int_range[1] - info.image.int_range[0] + 1


if( ptr_valid(info.image.pixeldata) eq 0) then  begin
    mql_read_rampdata,xvalue,yvalue,pixeldata,info  
    if ptr_valid (info.image.pixeldata) then ptr_free,info.image.pixeldata
    info.image.pixeldata = ptr_new(pixeldata)    
endif

pixeldata = (*info.image.pixeldata)[ii:ij,*,0]
xnew = findgen(info.data.nramps) + 1 ; 
if(info.image.overplot_slope eq 1) then  begin 
    slopedata = (*info.image.pslope_pixeldata)[ii:ij,*]
    ynew = fltarr(num_int,info.data.nramps)
    
    for k = 0,num_int-1 do begin
       slope = slopedata[k,0]*info.image.frame_time
       yint = slopedata[k,1]
       ynew[k,*] = slope*xnew[*] + yint
    endfor

    ymin_cal = min(ynew,/nan)
    ymax_cal = max(ynew,/nan)
endif

if(info.image.overplot_reference_corrected eq 1) then begin
    refcorrected_data = (*info.image.prefcorrected_pixeldata)[ii:ij,*,0]
    ymin_corrected = min(refcorrected_data,/nan)
    ymax_corrected = max(refcorrected_data,/nan)
endif


if(info.image.overplot_cr eq 1) then begin
   if( ptr_valid(info.image.pid_pixeldata) eq 0) then  begin
      mql_read_id_data,xvalue,yvalue,info  
   endif
   cr_data = (*info.image.pid_pixeldata)[ii:ij,*,0]
  
endif

if(info.image.overplot_lc eq 1) then begin
   if(ptr_valid(info.image.plc_pixeldata) eq 0) then begin
      mql_read_lc_data,xvalue,yvalue,info
   endif  
   lc_data = (*info.image.plc_pixeldata)[ii:ij,*,0]
endif


if(info.control.file_mdc_exist eq 0) then info.image.overplot_mdc = 0
if(info.image.overplot_mdc eq 1 ) then begin
   if(ptr_valid(info.image.pmdc_pixeldata) eq 0) then begin
      mql_read_mdc_data,xvalue,yvalue,info
   endif
    mdc_data = (*info.image.pmdc_pixeldata)[ii:ij,*,0]
 endif

if(info.control.file_reset_exist eq 0) then info.image.overplot_reset = 0
if(info.image.overplot_reset eq 1 ) then begin
   if(ptr_valid(info.image.preset_pixeldata) eq 0) then begin
      mql_read_reset_data,xvalue,yvalue,info
   endif
   reset_data = (*info.image.preset_pixeldata)[ii:ij,*,0]
endif

if(info.control.file_rscd_exist eq 0) then info.image.overplot_rscd = 0
if(info.image.overplot_rscd eq 1 ) then begin
   if(ptr_valid(info.image.prscd_pixeldata) eq 0) then begin
      mql_read_rscd_data,xvalue,yvalue,info
   endif

   rscd_data = (*info.image.prscd_pixeldata)[ii:ij,*,0]
endif

if(info.control.file_lastframe_exist eq 0) then info.image.overplot_lastframe = 0

if(info.image.overplot_lastframe eq 1 ) then begin
    lastframe_data = (*info.image.plastframe_pixeldata)[ii:ij,0]
endif


widget_control,info.image.ramp_x_label, set_value=xs
widget_control,info.image.ramp_y_label, set_value=ys

if(hcopy eq 0 ) then wset,info.image.draw_window_id[3]

n_reads = n_elements(pixeldata)
xvalues = indgen(n_reads) + 1

if(info.image.overplot_pixel_int) then xvalues = indgen(info.data.nramps)+1 
xmin = min(xvalues)
xmax = max(xvalues)
ymin = min(pixeldata,/nan)
ymax = max(pixeldata,/nan)

if(info.image.overplot_slope) then begin
    if(ymin_cal lt ymin and ymin_cal ne 0) then ymin = ymin_cal
    if(ymax_cal gt ymax) then ymax = ymax_cal
endif


if(info.image.overplot_reference_corrected eq 1) then begin
    if(ymin_corrected lt ymin and ymin_corrected ne 0 ) then ymin = ymin_corrected
    if(ymax_corrected gt ymax) then ymax = ymax_corrected
endif



;if(badpixel eq 1) then begin
;   ymin = 0
;   ymax = 1
;endif
if(ymax gt 70000) then ymax = 70000

ypad = (ymax)*.05

; check if default scale is true - then reset to orginal value
if(info.image.default_scale_ramp[0] eq 1) then begin
    info.image.ramp_range[0,0] = xmin-1
    info.image.ramp_range[0,1] = xmax+1
endif 
  
if(info.image.default_scale_ramp[1] eq 1) then begin

    if(ypad gt 0) then begin 
        info.image.ramp_range[1,0] = ymin-ypad 
        info.image.ramp_range[1,1] = ymax+ypad
    endif else begin
        info.image.ramp_range[1,0] = ymin+ypad 
        info.image.ramp_range[1,1] = ymax-ypad
    endelse

endif

if(hcopy eq 1) then begin
    i = info.image.integrationNO
    j = info.image.rampNO
    
    ftitle = " Frame #: " + strtrim(string(i+1),2) 
    ititle = " Integration #: " + strtrim(string(j+1),2)
    sstitle = info.control.filebase + '.fits: ' + ftitle + ititle
    pvalue = strtrim(xvalue+1,2) + ' ' + strtrim(yvalue+1,2)
    stitle = "Frames values for selected pixel :"  +  pvalue
endif

x1 = info.image.ramp_range[0,0]
x2 = info.image.ramp_range[0,1]
y1 = info.image.ramp_range[1,0]
y2 = info.image.ramp_range[1,1]


xs = "Frame #" + xs + ys
ys = "DN/frame"

plot,xvalues,pixeldata,xtitle = xs, ytitle=ys,$
  xrange=[x1,x2],yrange=[y1,y2],title = stitle, subtitle = sstitle,$
     xstyle = 1, ystyle = 1,/nodata,ytickformat = '(f8.0)'


if(badpixel eq 1) then  begin
    xpt = (x2 - x1)/3.0 + x1
    ypt = (y2 - y1)/3.0 + y1
    xyouts,xpt,ypt,' BAD PIXEL',charsize = 2.0

endif

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


ptype = [1,2,4,5,6]


ip = 0
ic = 0
isp = 0
isp2 = 0
isp3 = 4
for k = 0,num_int-1 do begin
    n_noise = 0
    n_cr = 0
    n_corrupt = 0
    marked = intarr(info.data.nramps)
    if(info.image.overplot_cr eq 1) then begin
        index_noise = where(cr_data[k,*] eq  NOISE_SPIKE or cr_data[k,*] eq COSMICRAY_SLOPE_FAILURE $
                            or cr_data[k,*] eq REJECT_AFTER_NOISE_SPIKE  or cr_data[k,*] eq REJECT_AFTER_CR  $
                            or cr_data[k,*]  eq SEG_MIN_FAILURE, n_noise)
        index_cr  = where(cr_data[k,*] eq COSMICRAY or cr_data[k,*] eq COSMICRAY_NEG, n_cr)
	index_corrupt = where(cr_data[k,*] eq BAD_FRAME, n_corrupt)
        if(n_noise gt 0)  then marked[index_noise] =NOISE_FLAG
        if(n_cr gt 0) then marked[index_cr] = COSMICRAY
	if(n_corrupt gt 0) then marked[index_corrupt] = BAD_FRAME

    endif

    yvalues = pixeldata[k,*,*]
    xvalues = indgen(info.data.nramps)+1

    if(info.image.overplot_pixel_int eq 0) then     xvalues = xvalues + info.data.nramps*(k)

    oplot,xvalues,yvalues,psym = 1,symsize = 0.8,color = info.white

    if(hcopy eq 1) then     oplot,xvalues,yvalues,psym = 1,symsize = 0.8,color = info.black
    if(n_noise gt 0) then oplot,xvalues[index_noise], yvalues[index_noise],$
      psym = 1,symsize = 0.8,color = info.yellow

    if(n_cr gt 0) then oplot,xvalues[index_cr], yvalues[index_cr],$
      psym = 1,symsize = 0.8,color = info.yellow

    if(n_corrupt gt 0) then oplot,xvalues[index_corrupt], yvalues[index_corrupt],$
      psym = 6,symsize = 1.2, color= info.yellow

    ic = ic + 1
    if(ic gt 3) then begin
        ip = ip + 1
        ic = 0
    endif
    if(ip gt 4) then ip = 0
    if(info.image.overplot_slope) then begin
        xnew_plot = xnew + info.data.nramps*k
        if(info.image.overplot_pixel_int eq 1) then xnew_plot = xnew

        ynew_plot = ynew[k,*]
        oplot,xnew_plot,ynew_plot,linestyle= 0,color= info.red,thick = 1.5

        xnew_plot = 0 & ynew_plot = 0
        isp = isp + 1
        if(isp gt 4) then isp = 0
    endif

    if(info.image.overplot_reference_corrected eq 1) then begin
        ynew_plot = refcorrected_data[k,*]

        for i = 0, info.data.nramps-1 do begin

            if(xnew[i] ge info.image.start_fit and xnew[i] le info.image.end_fit)then begin
                xplot = fltarr(1) & yplot = fltarr(1)
                xplot[0] = xvalues[i] & yplot[0] = ynew_plot[i]
                
                oplot,xplot,yplot,psym = 1,symsize = 0.8,color= info.blue

                if(marked[i]  eq  NOISE_FLAG) then $
                  oplot,xplot,yplot,psym = 1,symsize = 0.8,color= info.yellow

                if(marked[i]  eq  COSMICRAY) then $
                  oplot,xplot,yplot,psym = 1,symsize = 0.8,color= info.yellow

                if(marked[i]  eq  BAD_FRAME) then $
                  oplot,xplot,yplot,psym = BAD_FRAME_SYM,symsize = 1.2,color= info.yellow

            endif 
        endfor
        xnew_plot = 0 & ynew_plot = 0
        isp2 = isp2 + 1
        if(isp2 gt 4) then isp2 = 0
    endif

    if(info.image.overplot_lc eq 1) then begin
        ynew_plot = lc_data[k,*]

        for i = 0, info.data.nramps-1 do begin
            if(xnew[i] ge info.image.start_fit and xnew[i] le info.image.end_fit)then begin
                xplot = fltarr(1) & yplot = fltarr(1)
                xplot[0] = xvalues[i] & yplot[0] = ynew_plot[i]


                oplot,xplot,yplot,psym =1,symsize = 0.8,color= info.green

                if(marked[i]  eq  NOISE_FLAG) then $
                  oplot,xplot,yplot,psym = 6,symsize = 0.8,color= info.yellow

                if(marked[i]  eq  COSMICRAY) then $
                  oplot,xplot,yplot,psym = 6,symsize = 0.8,color= info.yellow

                if(marked[i]  eq  BAD_FRAME) then $
                  oplot,xplot,yplot,psym = BAD_FRAME_SYM,symsize = 1.2,color= info.yellow
            endif 
        endfor
        xnew_plot = 0 & ynew_plot = 0
        isp3 = isp3 + 1
        if(isp3 gt 4) then isp3 = 0
    endif

;_______________________________________________________________________
    if(info.image.overplot_mdc eq 1 and info.control.file_mdc_exist eq 1)  then begin
        ynew_plot = mdc_data[k,*]

        for i = 0, info.data.nramps-1 do begin
            if(xnew[i] ge info.image.start_fit and xnew[i] le info.image.end_fit)then begin
                xplot = fltarr(1) & yplot = fltarr(1)
                xplot[0] = xvalues[i] & yplot[0] = ynew_plot[i]

                oplot,xplot,yplot,psym =1,symsize = 0.5,color= info.yellow

                if(marked[i]  eq  NOISE_FLAG) then $
                  oplot,xplot,yplot,psym =6 ,symsize = 0.5,color= info.yellow

                if(marked[i]  eq  COSMICRAY) then $
                  oplot,xplot,yplot,psym = 6,symsize = 0.5,color= info.yellow

                if(marked[i]  eq  BAD_FRAME) then $
                  oplot,xplot,yplot,psym = BAD_FRAME_SYM,symsize = 1.2,color= info.yellow
            endif 
        endfor
        xnew_plot = 0 & ynew_plot = 0
        isp3 = isp3 + 1
        if(isp3 gt 4) then isp3 = 0
    endif


;_______________________________________________________________________
    if(info.image.overplot_reset eq 1 and info.control.file_reset_exist eq 1)  then begin
        ynew_plot = reset_data[k,*] ; k number of integrations

        for i = 0, info.data.nramps-1 do begin
            if(xnew[i] ge info.image.start_fit and xnew[i] le info.image.end_fit)then begin
                xplot = fltarr(1) & yplot = fltarr(1)
                xplot[0] = xvalues[i] & yplot[0] = ynew_plot[i]

                oplot,xplot,yplot,psym =1,symsize = 1.0,color= info.blue

                if(marked[i]  eq  NOISE_FLAG) then $
                  oplot,xplot,yplot,psym = 6,symsize = 0.5,color= info.yellow

                if(marked[i]  eq  COSMICRAY) then $
                  oplot,xplot,yplot,psym = 6,symsize = 0.5,color= info.yellow

                if(marked[i]  eq  BAD_FRAME) then $
                  oplot,xplot,yplot,psym = BAD_FRAME_SYM,symsize = 1.2,color= info.yellow
            endif 
        endfor
        xnew_plot = 0 & ynew_plot = 0
        isp3 = isp3 + 1
        if(isp3 gt 4) then isp3 = 0
    endif


;_______________________________________________________________________
    if(info.image.overplot_rscd eq 1 and info.control.file_rscd_exist eq 1)  then begin
        ynew_plot = rscd_data[k,*] ; k number of integrations

        for i = 0, info.data.nramps-1 do begin
            if(xnew[i] ge info.image.start_fit and xnew[i] le info.image.end_fit)then begin
                xplot = fltarr(1) & yplot = fltarr(1)
                xplot[0] = xvalues[i] & yplot[0] = ynew_plot[i]

                oplot,xplot,yplot,psym =2,symsize = 1.0,color= info.green

                if(marked[i]  eq  NOISE_FLAG) then $
                  oplot,xplot,yplot,psym = 1,symsize = 0.5,color= info.yellow

                if(marked[i]  eq  COSMICRAY) then $
                  oplot,xplot,yplot,psym = 1,symsize = 0.5,color= info.yellow

                if(marked[i]  eq  BAD_FRAME) then $
                  oplot,xplot,yplot,psym = BAD_FRAME_SYM,symsize = 1.2,color= info.yellow
            endif 
        endfor
        xnew_plot = 0 & ynew_plot = 0
        isp3 = isp3 + 1
        if(isp3 gt 4) then isp3 = 0
    endif
    

;_______________________________________________________________________
    if(info.image.overplot_lastframe eq 1 and info.control.file_lastframe_exist eq 1)  then begin
        ynew_plot = lastframe_data[k] ; k number of integrations

        for i = info.data.nramps-1, info.data.nramps-1 do begin
            if(xnew[i] ge info.image.start_fit and xnew[i] le info.image.end_fit)then begin
                xplot = fltarr(1) & yplot = fltarr(1)
                xplot[0] = xvalues[i] & yplot[0] = ynew_plot;[k]

                oplot,xplot,yplot,psym =4,symsize = 1.0,color= info.blue

                if(marked[i]  eq  NOISE_FLAG) then $
                  oplot,xplot,yplot,psym = 4,symsize = 0.5,color= info.yellow

                if(marked[i]  eq  COSMICRAY) then $
                  oplot,xplot,yplot,psym = 4,symsize = 0.5,color= info.yellow

                if(marked[i]  eq  BAD_FRAME) then $
                  oplot,xplot,yplot,psym = BAD_FRAME_SYM,symsize = 1.2,color= info.yellow
            endif 
        endfor
        xnew_plot = 0 & ynew_plot = 0
        isp3 = isp3 + 1
        if(isp3 gt 4) then isp3 = 0
     endif
;_______________________________________________________________________
 if(num_int gt 1 and info.image.overplot_pixel_int eq 0 ) then begin
     yline = fltarr(2) & xline = fltarr(2)
     yline[0] = -1000000 & yline[1] = 100000
     xline[*] = info.data.nramps* (k+1)
     oplot,xline,yline,linestyle=3
 endif
endfor

widget_control,info.image.ramp_mmlabel[0,0],set_value=fix(info.image.ramp_range[0,0])
widget_control,info.image.ramp_mmlabel[0,1],set_value=fix(info.image.ramp_range[0,1])
widget_control,info.image.ramp_mmlabel[1,0],set_value=info.image.ramp_range[1,0]
widget_control,info.image.ramp_mmlabel[1,1],set_value=info.image.ramp_range[1,1]




    
pixeldata = 0
slopedata = 0
xnew = 0
ynew = 0
yvalues = 0
xvalues = 0
info.col_table = save_color
end
