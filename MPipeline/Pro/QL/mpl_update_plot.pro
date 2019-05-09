; plot the results from the Pixel look program
; Circles for data points
; Dashed line for reference output image subtraction results
; Solid line for reference pixel applied
 ; order of corrections: 

pro mpl_update_plot,info,ps = ps, eps = eps

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

color6
; white = 1, red = 2, green = 3, blue = 4, yellow = 5
line_colors = [info.red,info.green,info.blue, info.yellow,info.white]
linetype1 = 5
linetype2 = 0
linetype3 = 2
pthick = 1.0


hcopy = 0
if ( (keyword_set(ps)) or ( keyword_set(eps)) ) then hcopy = 1
stitle = ' '
sstitle = ' ' 

if(hcopy eq 1) then begin
    pthick = 3.0
    line_colors = [info.red,info.green,info.blue, info.yellow,info.black]
endif
    
ind = info.pl.group ; 0 pixel tracking file first 4 pixels
                    ; 1 pixel tracking file second 4 pixels
                    ; 2 random
	            ; 3 user defined

num = info.pltrack.num_group[ind]

ii = info.pl.int_range[0]-1
ij = info.pl.int_range[1]-1
num_int = info.pl.int_range[1] - info.pl.int_range[0] + 1

xdata = (*info.pltrack.px)[ind,0:num-1]              ; typeof data, num pixels
ydata = (*info.pltrack.py)[ind,0:num-1]              ; typeof data, num pixels
ch = (*info.pltrack.pch)[ind,0:num-1]                ; typeof data, num pixels
data = (*info.pltrack.pdata)[ind,ii:ij,*,0:num-1]    ; typeof data, num integ, num frames, num pixels
stat = (*info.pltrack.pstat)[ind,ii:ij,0:num-1,*]    ; typeof data, num integ, num pixels, (min or max)

refcorrect_data = (*info.pltrack.prefcorrectdata)[ind,ii:ij,*,0:num-1]   
                                ; typeof data, num integ, num frames,
                                ; num pixels

id_data = (*info.pltrack.piddata)[ind,ii:ij,*,0:num-1]   
                                ; typeof data, num integ, num frames,
                                ; num pixels


mdc_data = (*info.pltrack.pmdcdata)[ind,ii:ij,*,0:num-1]   
reset_data = (*info.pltrack.presetdata)[ind,ii:ij,*,0:num-1]   
lastframe_data = (*info.pltrack.plastframedata)[ind,ii:ij,0:num-1]   
lc_data = (*info.pltrack.plcdata)[ind,ii:ij,*,0:num-1]   
                                    ; typeof data, num integ, num frames, num pixels


if(info.pl.slope_exists and info.pl.overplot_slope) then begin 
    calramp = (*info.pltrack.pcalramp)[ind,ii:ij,*,0:num-1]    ; typeof data, num integ, num frames, num pixels
    slope = (*info.pltrack.pslope)[ind,ii:ij,0:num-1]    ; typeof data, num integ, num pixels
    statcalramp = (*info.pltrack.pstatcalramp)[ind,ii:ij,0:num-1,*] ; 
endif

;
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
; Now are we limited in which pixels we want to plot
index = where(info.pl.onvalue[*] eq 1, inum)


ymin = min(stat[0,*,*,0])
ymax = max(stat[0,*,*,1])

snum = 0
Ymin_total = fltarr(10) 
Ymax_total = fltarr(10)

if(inum gt 0) then begin 
    ymin = min( stat[0,*,index,0])
    ymax = max( stat[0,*,index,1])

    ymin_total[0] = ymin
    ymax_total[0] = ymax

    if(info.pl.slope_exists eq 1 and info.pl.overplot_slope eq 1) then begin
        snum = snum + 1
        ymin1 = min( statcalramp[0,*,index,0])
        ymax1 = max( statcalramp[0,*,index,1])
        ymin_total[snum] = ymin1
        ymax_total[snum] = ymax1

    endif

    if(info.pl.overplot_refcorrect eq 1) then begin
        snum = snum + 1
        ymin1 = min( refcorrect_data)
        ymax1 = max( refcorrect_data)
        ymin_total[snum] = ymin1
        ymax_total[snum] = ymax1

    endif


    if(info.pl.overplot_lc eq 1) then begin
        snum = snum + 1
        ymin1 = min( lc_data)
        ymax1 = max( lc_data)
        ymin_total[snum] = ymin1
        ymax_total[snum] = ymax1

    endif

    if(info.pl.overplot_mdc eq 1) then begin
        snum = snum + 1
        ii = where(mdc_data ne 0,cum)
        if(cum gt 1) then begin 
            ymin1 = min( mdc_data[ii])
            ymax1 = max( mdc_data[ii])
            ymin_total[snum] = ymin1
            ymax_total[snum] = ymax1
            
        endif
        ii = 0

     endif

    if(info.pl.overplot_reset eq 1) then begin
        snum = snum + 1
        ii = where(reset_data ne 0,cum)
        if(cum gt 1) then begin 
            ymin1 = min( reset_data[ii])
            ymax1 = max( reset_data[ii])
            ymin_total[snum] = ymin1
            ymax_total[snum] = ymax1
            
        endif
        ii = 0

     endif

    if(info.pl.overplot_lastframe eq 1) then begin
        snum = snum + 1
        ii = where(lastframe_data ne 0,cum)
        if(cum gt 1) then begin 
            ymin1 = min( lastframe_data[ii])
            ymax1 = max( lastframe_data[ii])
            ymin_total[snum] = ymin1
            ymax_total[snum] = ymax1
            
        endif
        ii = 0

    endif

    ymin = min (ymin_total[0:snum])
    ymax = max (ymax_total[0:snum])

endif




if(hcopy eq 0 ) then wset,info.pl.draw_window_id
if(hcopy eq 1) then begin
    ititle = " Integration #: " + strtrim(string(ii+1),2) + ' to ' + $
             strtrim(string(ij+1),2)
    sstitle = info.control.filebase + '.fits: ' + ititle
    stitle = "Values for Selected Pixels :"  
endif


nreads = info.data.nramps*num_int
xvalues = indgen(nreads) + 1

if(info.pl.overplot_pixel_int eq 1) then xvalues = indgen(info.data.nramps) + 1


xmin = min(xvalues)
xmax = max(xvalues)
if(ymax gt 70000) then ymax = 70000
ypad = (ymax)*.05
if(ypad le 1 ) then ypad = 1


if(info.pl.default_range[0] eq 1) then begin
    info.pl.graph_range[0,0] = xmin-1 
    info.pl.graph_range[0,1] = xmax+1
endif 
  
if(info.pl.default_range[1] eq 1) then begin
    info.pl.graph_range[1,0] = ymin-ypad 
    info.pl.graph_range[1,1] = ymax+ypad
endif

x1 = info.pl.graph_range[0,0]
x2 = info.pl.graph_range[0,1]
y1 = info.pl.graph_range[1,0]
y2 = info.pl.graph_range[1,1]



;_______________________________________________________________________

reject = intarr(info.data.nramps)
doreject = 0
if(info.pl.start_fit gt 1) then begin
   reject[0:info.pl.start_fit-2] = 1
   doreject = 1
endif

if(info.pl.end_fit ne info.data.nramps ) then begin
   reject[info.pl.end_fit:info.data.nramps-1] = 1
   doreject =1
endif
sxtitle = "Frame #"
;_______________________________________________________________________
if(hcopy eq 0) then begin
    
    plot,xvalues,data,xtitle = sxtitle, ytitle='DN',$
         xrange=[x1,x2],yrange=[y1,y2],title = stitle, subtitle = sstitle,/nodata,$
         xstyle = 1, ystyle = 1,ytickformat = '(f7.0)'
endif

if(hcopy eq 1) then begin
    plot,position = [0.1,0.35,0.95,0.95], xvalues,data,xtitle = sxtitle, ytitle='DN',$
         xrange=[x1,x2],yrange=[y1,y2],title = stitle, subtitle = sstitle,/nodata,$
         xstyle = 1, ystyle = 1,ytickformat = '(f7.0)'
endif



;_______________________________________________________________________
; plot raw data 
ptype = [1,2,4,5]
ip = 0
for k = 0,num_int-1 do begin


;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ic = 0
   for i = 0, num-1 do begin

      cr_data = id_data[*,k,*,i]
      n_noise = 0
      n_cr = 0
      n_corrupt = 0
      marked = intarr(info.data.nramps)
;      index_noise = where(cr_data[k,*] eq  NOISE_SPIKE or cr_data[k,*] eq COSMICRAY_SLOPE_FAILURE $
;                          or cr_data[k,*] eq REJECT_AFTER_NOISE_SPIKE  or cr_data[k,*] eq REJECT_AFTER_CR  $
;                          or cr_data[k,*]  eq SEG_MIN_FAILURE, n_noise)
;      index_cr  = where(cr_data[k,*] eq COSMICRAY or cr_data[k,*] eq COSMICRAY_NEG, n_cr)
;      index_corrupt = where(cr_data[k,*] eq BAD_FRAME, n_corrupt)

      index_noise = where(cr_data[*] eq  NOISE_SPIKE or cr_data[*] eq COSMICRAY_SLOPE_FAILURE $
                          or cr_data[*] eq REJECT_AFTER_NOISE_SPIKE  or cr_data[*] eq REJECT_AFTER_CR  $
                          or cr_data[*]  eq SEG_MIN_FAILURE, n_noise)
      index_cr  = where(cr_data[*] eq COSMICRAY or cr_data[*] eq COSMICRAY_NEG, n_cr)
      index_corrupt = where(cr_data[*] eq BAD_FRAME, n_corrupt)

      if(n_noise gt 0)  then marked[index_noise] =NOISE_FLAG
      if(n_cr gt 0) then marked[index_cr] = COSMICRAY
      if(n_corrupt gt 0) then marked[index_corrupt] = BAD_FRAME


      if(info.pl.onvalue[i] eq 1) then begin
;###############################################################################################
         
         if(info.pl.overplot_frame eq 1) then begin  
            yvalues = data[0,k,*,i]
            xvalues = indgen(info.data.nramps)+1
            if(info.pl.overplot_pixel_int eq 0) then xvalues = xvalues + info.data.nramps*(k)
            oplot,xvalues,yvalues,psym = ptype[ip],symsize = 1.2,color=line_colors[ic],thick= pthick
; plot rejected points             
            if(doreject) then begin ; plot rejected points
               for ir = 0, info.data.nramps-1 do begin
                  reject_value = reject[ir]
                   
                  if(reject_value eq 1) then begin 
                     xplot = fltarr(1) & yplot = fltarr(1)
                     xplot[*]= xvalues[ir] & yplot[*] = yvalues[ir] 
                     oplot,xplot,yplot,psym = 6 , symsize = .8
                  endif
               endfor
            endif
;plot cr hits or noise
            if(n_noise gt 0 or n_cr gt 0 or n_corrupt gt 0) then begin
               for ir = 0, info.data.nramps-1 do begin
                  xplot = fltarr(1) & yplot = fltarr(1)
                  xplot[*]= xvalues[ir] & yplot[*] = yvalues[ir] 
                   
                  if(n_noise gt 0) then oplot,xvalues[index_noise], yvalues[index_noise],$
                                              psym = 6,symsize = 0.8,color = info.yellow
                      
                  if(n_cr gt 0) then oplot,xvalues[index_cr], yvalues[index_cr],$
                                           psym = 6,symsize = 0.8,color = info.yellow

                  if(n_corrupt gt 0) then oplot,xvalues[index_corrupt], yvalues[index_corrupt],$
                                                psym = 6,symsize = 1.2,color = info.yellow
               endfor
            endif
         endif
;###############################################################################################

;slope results
         if(info.pl.slope_exists eq 1 and info.pl.overplot_slope eq 1  ) then begin 
            slopept = slope[0,k,i]
            channel = ch[0,i]
            yvalues = fltarr(info.data.nramps)
            yvalues[*] = calramp[0,k,*,i]
            xvalues = findgen(info.data.nramps) + 1
                
            index = where(xvalues ge 0 and $
                          xvalues le nreads and $
                          channel ne 5,numplot)

            if(info.pl.overplot_pixel_int eq 0) then xvalues = xvalues + info.data.nramps*(k)

            if(numplot gt 0) then begin
               xplot = xvalues[index]
               yplot = yvalues[index]

               if (finite (slopept)) then begin 
                  oplot,xplot,yplot, color = line_colors[ic],linestyle=0,thick=2
               endif
            endif
         endif
;###############################################################################################
; reference corrected data
         
         ptype2 = [2,4,5,1] 

         if(info.pl.overplot_refcorrect eq 1) then begin 
            yvalues = refcorrect_data[0,k,*,i]
            xvalues = indgen(info.data.nramps)+1


            if(info.pl.overplot_pixel_int eq 0) then xvalues = xvalues + info.data.nramps*(k)
            oplot,xvalues,yvalues,psym = ptype2[ip],symsize = 1.2,color=line_colors[ic],thick= pthick

            if(doreject) then begin
               for ir = 0, info.data.nramps-1 do begin
                  if(reject[ir] eq 0 and ch[0,i] ne 5) then begin 
                     xplot = fltarr(1) & yplot = fltarr(1)
                     xplot[*]= xvalues[ir] & yplot[*] = yvalues[ir] 
                     oplot,xplot,yplot,psym = ptype2[ip],symsize =0.8,color=line_colors[ic] 
                  endif
               endfor
            endif
            if(n_noise gt 0 or n_cr gt 0) then begin
               for ir = 0, info.data.nramps-1 do begin
                  xplot = fltarr(1) & yplot = fltarr(1)
                  xplot[*]= xvalues[ir] & yplot[*] = yvalues[ir] 
                  if(marked[i]  eq  NOISE_FLAG) then $
                     oplot,xplot,yplot,psym = 1,symsize = 0.8,color= info.yellow
                  
                  if(marked[i]  eq  COSMICRAY) then $
                     oplot,xplot,yplot,psym = 1,symsize = 0.8,color= info.yellow

                  if(marked[i]  eq  BAD_FRAME) then $
                     oplot,xplot,yplot,psym = BAD_FRAME_SYM,symsize = 1.2,color= info.yellow
               endfor
            endif            
         endif
;###############################################################################################
; linearity corrected data
         ptype3 = [6,6,6,6] 
         ip = 0
         if(info.pl.overplot_lc eq 1) then begin 
            yvalues = lc_data[0,k,*,i]
            xvalues = indgen(info.data.nramps)+1
            if(info.pl.overplot_pixel_int eq 0) then xvalues = xvalues + info.data.nramps*(k)
            oplot,xvalues,yvalues,psym = ptype3[ip],symsize = 1.2,color=line_colors[ic],thick= pthick

            if(doreject) then begin
               for ir = 0, info.data.nramps-1 do begin
                  if(reject[ir] eq 0 and ch[0,i] ne 5) then begin 
                     xplot = fltarr(1) & yplot = fltarr(1)
                     xplot[*]= xvalues[ir] & yplot[*] = yvalues[ir] 
                     oplot,xplot,yplot,psym = ptype3[ip],symsize =1.0,color=line_colors[ic] 
                  endif
               endfor
            endif
            if(n_noise gt 0 or n_cr gt 0) then begin
               for ir = 0, info.data.nramps-1 do begin
                  xplot = fltarr(1) & yplot = fltarr(1)
                  xplot[*]= xvalues[ir] & yplot[*] = yvalues[ir] 
                  if(marked[i]  eq  NOISE_FLAG) then $
                     oplot,xplot,yplot,psym = 1,symsize = 0.8,color= info.yellow
                  
                  if(marked[i]  eq  COSMICRAY) then $
                     oplot,xplot,yplot,psym = 1,symsize = 0.8,color= info.yellow
                  
                  if(marked[i]  eq  BAD_FRAME) then $
                     oplot,xplot,yplot,psym = BAD_FRAME_SYM,symsize = 1.2,color= info.yellow
               endfor
            endif            

         endif
;###############################################################################################
;dark corrected data
         ptype3 = [6,6,6,6] 
         if(info.pl.overplot_mdc eq 1) then begin 
            
            yvalues = mdc_data[0,k,*,i]
            xvalues = indgen(info.data.nramps)+1
            if(info.pl.overplot_pixel_int eq 0) then xvalues = xvalues + info.data.nramps*(k)
            oplot,xvalues,yvalues,psym = ptype3[ip],symsize = 1.2,color=line_colors[ic],thick= pthick
                
            if(doreject) then begin
               for ir = 0, info.data.nramps-1 do begin
                  if(reject[ir] eq 0 and ch[0,i] ne 5) then begin 
                     xplot = fltarr(1) & yplot = fltarr(1)
                     xplot[*]= xvalues[ir] & yplot[*] = yvalues[ir] 
                     oplot,xplot,yplot,psym = ptype3[ip],symsize =1.0,color=line_colors[ic] 
                  endif
               endfor
            endif
            if(n_noise gt 0 or n_cr gt 0) then begin
               for ir = 0, info.data.nramps-1 do begin
                  xplot = fltarr(1) & yplot = fltarr(1)
                  xplot[*]= xvalues[ir] & yplot[*] = yvalues[ir] 
                  if(marked[i]  eq  NOISE_FLAG) then $
                     oplot,xplot,yplot,psym = 1,symsize = 0.8,color= info.yellow
             
                  if(marked[i]  eq  COSMICRAY) then $
                     oplot,xplot,yplot,psym = 1,symsize = 0.8,color= info.yellow
                  
                  if(marked[i]  eq  BAD_FRAME) then $
                     oplot,xplot,yplot,psym = BAD_FRAME_SYM,symsize = 1.2,color= info.yellow
                  
               endfor
            endif            
         endif
;;###############################################################################################
; plotreset corrected
         ptype3 = [5,5,5,5] 
         if(info.pl.overplot_reset eq 1) then begin 
            yvalues = reset_data[0,k,*,i]
            xvalues = indgen(info.data.nramps)+1
            if(info.pl.overplot_pixel_int eq 0) then xvalues = xvalues + info.data.nramps*(k)
            oplot,xvalues,yvalues,psym = ptype3[ip],symsize = 1.2,color=line_colors[ic],thick= pthick
            if(doreject) then begin
               for ir = 0, info.data.nramps-1 do begin
                  if(reject[ir] eq 0 and ch[0,i] ne 5) then begin 
                     xplot = fltarr(1) & yplot = fltarr(1)
                     xplot[*]= xvalues[ir] & yplot[*] = yvalues[ir] 
                     oplot,xplot,yplot,psym = ptype3[ip],symsize =1.0,color=line_colors[ic] 
                  endif
               endfor
            endif

            if(n_noise gt 0 or n_cr gt 0) then begin
               for ir = 0, info.data.nramps-1 do begin
                  xplot = fltarr(1) & yplot = fltarr(1)
                  xplot[*]= xvalues[ir] & yplot[*] = yvalues[ir] 
                      
                  if(marked[i]  eq  NOISE_FLAG) then $
                     oplot,xplot,yplot,psym = 1,symsize = 0.8,color= info.yellow
                  
                  if(marked[i]  eq  COSMICRAY) then $
                     oplot,xplot,yplot,psym = 1,symsize = 0.8,color= info.yellow
                  
                  if(marked[i]  eq  BAD_FRAME) then $
                     oplot,xplot,yplot,psym = BAD_FRAME_SYM,symsize = 1.2,color= info.yellow

               endfor
            endif            

         endif
;###############################################################################################
; last frame 
         ptype3 = [5,5,5,5] 
         if(info.pl.overplot_lastframe eq 1) then begin 
            yvalues_lf = fltarr(1) & xvalues_lf = fltarr(1)
            yvalues_lf[0] = lastframe_data[0,k,i]
            xvalues_lf[0]  = info.data.nramps
                
            if(info.pl.overplot_pixel_int eq 0) then xvalues_lf = xvalues_lf + info.data.nramps*(k)
            oplot,xvalues_lf,yvalues_lf,psym = ptype3[ip],symsize = 1.0,color=line_colors[ic],thick= pthick

            if(doreject) then begin
               ir = info.data.nramps-1
               if(reject[ir] eq 0 and ch[0,i] ne 5) then begin 
                  xplot = fltarr(1) & yplot = fltarr(1)
                  xplot[*]= xvalues[ir] & yplot[*] = yvalues     
                  oplot,xplot,yplot,psym = ptype3[ip],symsize =1.0,color=line_colors[ic] 
               endif
            endif

            if(n_noise gt 0 or n_cr gt 0) then begin
               ir = info.data.nramps-1
               xplot = fltarr(1) & yplot = fltarr(1)
               xplot[*]= xvalues[ir] & yplot[*] = yvalues
                   
               if(marked[ir]  eq  NOISE_FLAG) then $
                  oplot,xplot,yplot,psym = 1,symsize = 0.8,color= info.yellow
               
               if(marked[ir]  eq  COSMICRAY) then $
                  oplot,xplot,yplot,psym = 1,symsize = 0.8,color= info.yellow
               
               if(marked[ir]  eq  BAD_FRAME) then $
                  oplot,xplot,yplot,psym = BAD_FRAME_SYM,symsize = 1.2,color= info.yellow
            endif            
         endif
;###############################################################################################
      endif                     ; plot pixel
      ic = ic + 1
      if(ic eq 5) then ic = 0
   endfor                       ; done looping over num


   ip = ip + 1
   if(ip gt 3) then ip = 0

; box showing limits of integration
   if(num_int gt 1 and info.pl.overplot_pixel_int eq 0) then begin
      yline = fltarr(2) & xline = fltarr(2)
      yline[0] = -1000000 & yline[1] = 100000
      xline[*] = info.data.nramps* (k+1)
      oplot,xline,yline,linestyle=3
   endif  
endfor                          ; done looping over integration



;_______________________________________________________________________
widget_control,info.pl.rangeID[0,0],set_value=fix(x1)
widget_control,info.pl.rangeID[0,1],set_value=fix(x2)
widget_control,info.pl.rangeID[1,0],set_value=y1
widget_control,info.pl.rangeID[1,1],set_value=y2


;_______________________________________________________________________
if(hcopy eq 0) then begin  
; draw boxes- raw data 
    xpt =findgen(4)/4+0.1 & ypt = fltarr(4) + 0.5
    for i = 0,4  do begin
        wset,info.pl.draw_box_id[i]
        plot,xpt,ypt,color=line_colors[i], $
             xstyle=4,ystyle=4,position=[0.1,0.1,0.9,0.9],xrange=[0.0,1.0], $
             yrange=[0.0,1.0],psym=1, symsize=1.0
    endfor


; draw boxes-  calcuated slope
    for i = 0,4  do begin
        wset,info.pl.draw_box_ids[i]
        plot,[0.0,1.0],[0.5,0.5],/normal,color=line_colors[i], $
             xstyle=4,ystyle=4,position=[0.1,0.1,0.9,0.9],xrange=[0.0,1.0], $
             yrange=[0.0,1.0],thick = 2,linestyle=1
    endfor



; draw boxes= rejected data
    for i = 0,4  do begin
        wset,info.pl.draw_box_idreject[i]
        plot,xpt, ypt,$
             xstyle=4,ystyle=4,position=[0.1,0.1,0.9,0.9],xrange=[0.0,1.0], $
             yrange=[0.0,1.0],psym = 6, symsize = .8
    endfor

endif

;_______________________________________________________________________
if(hcopy eq 1) then begin
    x = findgen(10) & y = findgen(10)
    plot,position = [0.1,0.1,0.95,0.25],x,y,/noerase,/nodata,xstyle=4,ystyle=4
    xyouts, 0.2,9,' Pixel Name   X      Y    Channel      Reads     Cal Slope    Rejected ' 
    xstart = 0.2  & ystart = 7
    xline = [3.8,5.3,7.0,8.5]

    pname = [ ' Pixel A', ' Pixel B', ' Pixel C' , ' Pixel D']
    for i = 0,3 do begin
        sx = strcompress(string (fix ( xdata[0,i])),/remove_all)
        sy = strcompress(string (fix ( ydata[0,i])),/remove_all)
        sc = strcompress(string (fix ( ch[0,i])),/remove_all)
        xyouts,xstart,ystart,pname[i] 
        xyouts,alignment = 1.0,xstart+1.5,ystart,sx 
        xyouts,alignment = 1.0,xstart+2.0,ystart,sy 
        xyouts,xstart+3.0,ystart,sc 
        for j = 0,2 do begin
            xplot = (findgen(8)*0.1 ) + xline[j]
            yplot = fltarr(8) + ystart
            if(j eq 0) then oplot,xplot,yplot,color=line_colors[i],psym = 6,symsize = 0.2
            if(j eq 1) then oplot,xplot,yplot,color=line_colors[i],linestyle= linetype1
            if(j eq 2) then oplot,xplot,yplot,psym = 6,symsize = 0.8
        endfor
        ystart = ystart -1.5
    endfor
endif


;_______________________________________________________________________
; update the pixel: x,y, channel values
for i = 0,4 do begin
    
    if(i lt num) then begin 
        sx = strcompress(string (fix ( xdata[0,i])),/remove_all)
        sy = strcompress(string (fix ( ydata[0,i])),/remove_all)
        sc = strcompress(string (fix ( ch[0,i])),/remove_all)
    endif else begin
        sx = 'NA'
        sy = 'NA'
        sc = 'NA'
    endelse
        
    widget_control,info.pl.xpixel_label[i],set_value=sx
    widget_control,info.pl.ypixel_label[i],set_value=sy
    widget_control,info.pl.channel_label[i],set_value=sc
endfor



if(info.pl.slope_exists eq 1) then begin
    ii = info.pl.int_range[0]-1

    slope = (*info.pltrack.pslope)[ind,ii,0:num-1] ; typeof data, num pixels
    unc = (*info.pltrack.punc)[ind,ii,0:num-1] ; typeof data, num pixels
    quality = (*info.pltrack.pid)[ind,ii,0:num-1] ; typeof data, num pixels
    numgood = (*info.pltrack.pnumgood)[ind,ii,0:num-1] ; typeof data, num pixels
    zeropt = (*info.pltrack.pzeropt)[ind,ii,0:num-1] ; typeof data, num pixels
    firstsat = (*info.pltrack.pfirstsat)[ind,ii,0:num-1] ; typeof data, num pixels
    nseg = (*info.pltrack.pnseg)[ind,ii,0:num-1] ; typeof data, num pixels
    rms = (*info.pltrack.prms)[ind,ii,0:num-1] ; typeof data, num pixels


    
    if(info.pl.slope_unit eq 2) then begin
        slope = slope/info.pl.gain
    endif
    for i = 0,4 do begin

        if(i lt num) then begin 
           ; if( finite(slope[0,0,i]) eq 0  ) then print, ' Found a NaN' 
            s1 = string ( slope[0,0,i],format="(f10.3)")
            s2 = string ( unc[0,0,i],format = "(f10.3)")
            s3 = string (fix (quality[0,0,i]),format="(i8)")

            s4 = string (numgood[0,0,i],format="(f5.0)")
            s5 = string (zeropt[0,0,i],format = "(f10.3)")
            s6 = string (firstsat[0,0,i],format="(f7.0)")
            s7 = string (nseg[0,0,i],format="(f7.0)")
            s8 = string (rms[0,0,i],format="(f8.3)")


            if(info.pltrack.zsize_data eq 2) then begin
                s2 = 'NA'
                s3 = 'NA'
                s4 = 'NA'
                s6 = 'NA'
                s7 = 'NA'
                s8 = 'NA'
            endif

            if(info.pltrack.zsize_data eq 3) then begin 
                s2 = 'NA'
                s3 = 'NA'
                s4 = 'NA'
        
                s6 = 'NA'
                s7 = 'NA'
                
            endif
        endif else begin
            s1 = 'NA'
            s2 = 'NA'
            s3 = 'NA'
            s4 = 'NA'
            s5 = 'NA'
            s6 = 'NA'
            s7 = 'NA'
            s8 = 'NA'
        endelse
        
        widget_control,info.pl.info_label1[i],set_value=s1
        widget_control,info.pl.info_label2[i],set_value=s2
        widget_control,info.pl.info_label3[i],set_value=s3
        widget_control,info.pl.info_label4[i],set_value=s4
        widget_control,info.pl.info_label5[i],set_value=s5
        widget_control,info.pl.info_label6[i],set_value=s6
        widget_control,info.pl.info_label7[i],set_value=s7
        widget_control,info.pl.info_label8[i],set_value=s8
    endfor
endif

data = 0
stat = 0
xdata = 0
ydata = 0
dataslope = 0
statslope = 0
ch = 0

widget_control,info.Quicklook,set_uvalue = info
end
