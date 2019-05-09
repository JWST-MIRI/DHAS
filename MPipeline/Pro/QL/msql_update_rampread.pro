pro msql_update_rampread,info,ps = ps, eps = eps


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


save_color = info.col_table
color6
hcopy = 0
if ( (keyword_set(ps)) or ( keyword_set(eps)) ) then hcopy = 1
stitle = ' '
sstitle = ' ' 

; do not update ramp
if(info.slope.autopixelupdate eq 0) then begin
    if(hcopy eq 0 ) then wset,info.slope.draw_window_id[3]
    xvalues = fltarr(10) & pixeldata = fltarr(10)
    x1 = info.slope.ramp_range[0,0]
    x2 = info.slope.ramp_range[0,1]
    y1 = info.slope.ramp_range[1,0]
    y2 = info.slope.ramp_range[1,1]
    plot,xvalues,pixeldata,xtitle = "Frame #", ytitle='DN/frame',$
         xrange=[x1,x2],yrange=[y1,y2],title = stitle, subtitle = sstitle,$
         xstyle = 1, ystyle = 1,/nodata,ytickformat = '(f7.0)'
    return
endif

xvalue = fix(  (info.slope.x_pos) *info.slope.binfactor)
yvalue = fix(  (info.slope.y_pos) *info.slope.binfactor)
xpixel = xvalue + 1
ypixel = yvalue + 1

ii = info.slope.int_range[0]-1
ij = info.slope.int_range[1]-1
; check for primary slope display - can not do this with this plot
if(ii eq -1) then ii = 0
if(ij eq -1) then ij = 1
num_int = ij - ii + 1

if( ptr_valid(info.slope.pixeldata) eq 0) then  begin
    print,' read in data'
    mql_read_rampdata,xvalue,yvalue,pixeldata,info  
    if ptr_valid (info.slope.pixeldata) then ptr_free,info.slope.pixeldata
    info.slope.pixeldata = ptr_new(pixeldata)    
endif

pixeldata = (*info.slope.pixeldata)[ii:ij,*,0]


slopedata = (*info.slope.pslope_pixeldata)[ii:ij,*]
nvalid = (info.slope.end_fit - info.slope.start_fit) + 1


xnew = findgen(info.data.nramps) + 1 ;
ynew = fltarr(num_int,info.data.nramps)
    
for k = 0,num_int-1 do begin
   slope = slopedata[k,0]*info.slope.frame_time
   yint = slopedata[k,1]
   ynew[k,*] = slope*xnew[*] + yint
endfor


ymin_cal = min(ynew)
ymax_cal = max(ynew)

if(info.slope.overplot_reference_corrected eq 1) then begin
    refcorrected_data = (*info.slope.prefcorrected_pixeldata)[ii:ij,*,0]
    ymin_corrected = min(refcorrected_data)
    ymax_corrected = max(refcorrected_data)
endif

if(info.slope.overplot_cr eq 1) then begin
    cr_data = (*info.slope.pid_pixeldata)[ii:ij,*,0]
endif


if(info.slope.overplot_mdc eq 1) then begin
    mdc_data = (*info.slope.pmdc_pixeldata)[ii:ij,*,0]
 endif

if(info.slope.overplot_reset eq 1) then begin
    reset_data = (*info.slope.preset_pixeldata)[ii:ij,*,0]
 endif

if(info.slope.overplot_rscd eq 1) then begin
    rscd_data = (*info.slope.prscd_pixeldata)[ii:ij,*,0]
 endif

if(info.slope.overplot_lastframe eq 1) then begin
    lastframe_data = (*info.slope.plastframe_pixeldata)[ii:ij,0]
endif

if(info.slope.overplot_lc eq 1) then begin
    lc_data = (*info.slope.plc_pixeldata)[ii:ij,*,0]
endif


if(hcopy eq 0 ) then wset,info.slope.draw_window_id[3]

n_reads = n_elements(pixeldata)
xvalues = indgen(n_reads) + 1

if(info.slope.overplot_pixel_int) then xvalues = indgen(info.data.nramps)+1
 

xmin = min(xvalues)
xmax = max(xvalues)
ymin = min(pixeldata)
ymax = max(pixeldata)
if(ymin_cal lt ymin and ymin_cal ne 0) then ymin = ymin_cal
if(ymax_cal gt ymax) then ymax = ymax_cal


if(info.slope.overplot_reference_corrected eq 1) then begin
    if(ymin_corrected lt ymin and ymin_corrected ne 0) then ymin = ymin_corrected
    if(ymax_corrected gt ymax) then ymax = ymax_corrected
endif
if(ymax gt 70000) then ymax = 70000
ypad = (ymin + ymax)*.01




; check if default scale is true - then reset to orginal value
if(info.slope.default_scale_ramp[0] eq 1) then begin
    info.slope.ramp_range[0,0] = xmin-1
    info.slope.ramp_range[0,1] = xmax+1
endif 
  

if(info.slope.default_scale_ramp[1] eq 1) then begin
    if(ypad gt 0) then begin 
        info.slope.ramp_range[1,0] = ymin-ypad 
        info.slope.ramp_range[1,1] = ymax+ypad
    endif else begin
        info.slope.ramp_range[1,0] = ymin+ypad 
        info.slope.ramp_range[1,1] = ymax-ypad
    endelse
        
endif


if(hcopy eq 1) then begin
    x = info.slope.x_pos*info.slope.binfactor
    y = info.slope.y_pos*info.slope.binfactor
    signal = (*info.data.pslopedata)[x,y,0]
    unc = (*info.data.pslopedata)[x,y,1]
    dq = (*info.data.pslopedata)[x,y,2]
    i = info.slope.integrationNO
    ititle = " Int#: " + strtrim(string(i+1),2)

    pvalue = strtrim(xvalue+1,2) + ' ' + strtrim(yvalue+1,2)
    values = " Slope: " + strtrim(string(signal),2) + " unc: " + strtrim(string(unc),2) + $
             " Flag: " + strtrim(string(fix(dq)),2)
    sstitle = info.control.filebase + '.fits: ' + ititle + values
    stitle = "Frames values for selected pixel :"   + pvalue
endif

x1 = info.slope.ramp_range[0,0]
x2 = info.slope.ramp_range[0,1]
y1 = info.slope.ramp_range[1,0]
y2 = info.slope.ramp_range[1,1]

;print,y1,y2
xs = "Frame #"
ys = "DN/frame"

plot,xvalues,pixeldata,xtitle = xs, ytitle=ys,$
  xrange=[x1,x2],yrange=[y1,y2],title = stitle, subtitle = sstitle,$
     xstyle = 1, ystyle = 1,/nodata,ytickformat = '(f7.0)'

isp2 = 0 
isp2 = 4
isp3 = 4
ptype = [1,2,4,5,6]
for k = 0,num_int-1 do begin
    n_noise = 0
    n_cr = 0
    n_corrupt = 0
    marked = intarr(info.data.nramps)
    if(info.slope.overplot_cr eq 1) then begin
        index_noise = where(cr_data[k,*] eq  NOISE_SPIKE or cr_data[k,*] eq COSMICRAY_SLOPE_FAILURE $
                            or cr_data[k,*] eq REJECT_AFTER_NOISE_SPIKE  or cr_data[k,*] eq REJECT_AFTER_CR  $
                            or cr_data[k,*]  eq SEG_MIN_FAILURE, n_noise)
        index_cr  = where(cr_data[k,*]  eq COSMICRAY or  cr_data[k,*] eq COSMICRAY_NEG, n_cr)
	index_corrupt = where(cr_data[k,*] eq BAD_FRAME, n_corrupt)

        if(n_noise gt 0)  then marked[index_noise] =NOISE_FLAG
        if(n_cr gt 0) then marked[index_cr] = COSMICRAY
	if(n_corrupt gt 0) then marked[index_corrupt] = BAD_FRAME
    endif

    yvalues = pixeldata[k,*,*]
    xvalues = indgen(info.data.nramps)+1

    if(info.slope.overplot_pixel_int eq 0) then     xvalues = xvalues + info.data.nramps*(k)

    if(info.data.raw_exist eq 1) then begin ; if  we have read in the raw frame values 

        oplot,xvalues,yvalues,psym = 6,symsize = 0.5
        oplot,xvalues,yvalues,linestyle=1

        if(n_noise gt 0) then oplot,xvalues[index_noise], yvalues[index_noise],$
          psym = 6,symsize = 0.8,color = info.yellow

        if(n_cr gt 0) then oplot,xvalues[index_cr], yvalues[index_cr],$
          psym = 6,symsize = 0.8,color = info.yellow

        if(n_corrupt gt 0) then oplot,xvalues[index_corrupt], yvalues[index_corrupt],$
          psym = 6,symsize = 1.2,color = info.yellow
    endif

; plot slope fit data

    if(info.slope.overplot_fit eq 1) then begin 
        xnew_plot = xnew+ info.data.nramps*k
        if(info.slope.overplot_pixel_int eq 1) then xnew_plot = xnew

        ynew_plot = ynew[k,*]


        oplot,xnew_plot,ynew_plot,psym = 5,symsize = 0.5,color= info.red
        oplot,xnew_plot,ynew_plot,linestyle= 1,color= info.red
    endif

 if(num_int gt 1 and info.slope.overplot_pixel_int eq 0 ) then begin
     yline = fltarr(2) & xline = fltarr(2)
     yline[0] = -1000000 & yline[1] = 100000
     xline[*] = info.data.nramps* (k+1)
     oplot,xline,yline,linestyle=3
 endif


 if(info.slope.overplot_reference_corrected eq 1) then begin
     ynew_plot = refcorrected_data[k,*]
     for i = 0, info.data.nramps-1 do begin
         if(xnew[i] ge info.slope.start_fit and xnew[i] le info.slope.end_fit)then begin
             xplot = fltarr(1) & yplot = fltarr(1)
             xplot[0] = xvalues[i] & yplot[0] = ynew_plot[i]
             
             oplot,xplot,yplot,psym = ptype[isp2],symsize = 0.8,color= info.blue

             if(marked[i]  eq  NOISE_FLAG) then $
                oplot,xplot,yplot,psym = 6,symsize = 0.8,color= info.yellow
             
             if(marked[i]  eq  COSMICRAY) then $
                oplot,xplot,yplot,psym = 6,symsize = 0.8,color= info.yellow

             if(marked[i]  eq  BAD_FRAME) then $
                oplot,xplot,yplot,psym = BAD_FRAME_SYM,symsize = 1.2,color= info.yellow

         endif 
     endfor
     xnew_plot = 0 & ynew_plot = 0
     isp2 = isp2 + 1
     if(isp2 gt 4) then isp2 = 0
 endif


 if(info.slope.overplot_lc eq 1) then begin
     ynew_plot = lc_data[k,*]
     for i = 0, info.data.nramps-1 do begin
         if(xnew[i] ge info.slope.start_fit and xnew[i] le info.slope.end_fit)then begin
             xplot = fltarr(1) & yplot = fltarr(1)
             xplot[0] = xvalues[i] & yplot[0] = ynew_plot[i]

             oplot,xplot,yplot,psym = 1,symsize = 0.8,color= info.green

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


 if(info.slope.overplot_mdc eq 1) then begin
     ynew_plot = mdc_data[k,*]
     for i = 0, info.data.nramps-1 do begin
         if(xnew[i] ge info.slope.start_fit and xnew[i] le info.slope.end_fit)then begin
             xplot = fltarr(1) & yplot = fltarr(1)
             xplot[0] = xvalues[i] & yplot[0] = ynew_plot[i]

             oplot,xplot,yplot,psym = 1,symsize = 0.8,color= info.yellow
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

 if(info.slope.overplot_reset eq 1) then begin
     ynew_plot = reset_data[k,*]
     for i = 0, info.data.nramps-1 do begin
         if(xnew[i] ge info.slope.start_fit and xnew[i] le info.slope.end_fit)then begin
             xplot = fltarr(1) & yplot = fltarr(1)
             xplot[0] = xvalues[i] & yplot[0] = ynew_plot[i]

             oplot,xplot,yplot,psym = 1,symsize = 0.8,color= info.blue

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

 if(info.slope.overplot_rscd eq 1) then begin
     ynew_plot = rscd_data[k,*]
     for i = 0, info.data.nramps-1 do begin
         if(xnew[i] ge info.slope.start_fit and xnew[i] le info.slope.end_fit)then begin
             xplot = fltarr(1) & yplot = fltarr(1)
             xplot[0] = xvalues[i] & yplot[0] = ynew_plot[i]

             oplot,xplot,yplot,psym = 2,symsize = 0.8,color= info.green

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

 if(info.slope.overplot_lastframe eq 1) then begin
     ynew_plot = lastframe_data[k,*]
     i = info.data.nramps-1
        xplot = fltarr(1) & yplot = fltarr(1)
        xplot[0] = xvalues[i] & yplot[0] = ynew_plot[k]

        oplot,xplot,yplot,psym = ptype[isp3],symsize = 0.8,color= info.blue

        if(marked[i]  eq  NOISE_FLAG) then $
           oplot,xplot,yplot,psym = ptype[isp3],symsize = 0.8,color= info.yellow

        if(marked[i]  eq  COSMICRAY) then $
           oplot,xplot,yplot,psym = ptype[isp3],symsize = 0.8,color= info.yellow
        
        if(marked[i]  eq  BAD_FRAME) then $
           oplot,xplot,yplot,psym = BAD_FRAME_SYM,symsize = 1.2,color= info.yellow

     xnew_plot = 0 & ynew_plot = 0
     isp3 = isp3 + 1
     if(isp3 gt 4) then isp3 = 0
 endif



endfor

cr_data = 0
lc_data = 0
widget_control,info.slope.ramp_mmlabel[0,0],set_value=fix(info.slope.ramp_range[0,0])
widget_control,info.slope.ramp_mmlabel[0,1],set_value=fix(info.slope.ramp_range[0,1])
widget_control,info.slope.ramp_mmlabel[1,0],set_value=info.slope.ramp_range[1,0]
widget_control,info.slope.ramp_mmlabel[1,1],set_value=info.slope.ramp_range[1,1]

info.col_table = save_color 
end
