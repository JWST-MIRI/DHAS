;_______________________________________________________________________
;_______________________________________________________________________
;***********************************************************************
pro mrp_update_TimeChannel,info,ps = ps, eps = eps
;_______________________________________________________________________
hcopy = 0
if ( (keyword_set(ps)) or ( keyword_set(eps)) ) then hcopy = 1

save_color = info.col_table
color6
line_colors = [info.red,info.green,info.blue, info.yellow,info.white]

xsize_image = 500
ysize_image = 300
if(hcopy eq 0) then wset,info.refp.draw_window_id[2]
ssize = 0.5
;
;_______________________________________________________________________
; set range of plot


time_image = (*info.ChannelRP[0].ptimedata)
time = (*info.ChannelRP[0].ptime) ; time is RTI - which is 10 microseconds


num = max(time) 
indexon = where(info.refp.onvalue[*] eq 1, inum)

xsize = size(*info.ChannelRP[0].ptimedata)
plottest = indgen(xsize)

ploteven = intarr(xsize)
plotodd = intarr(xsize)
for i = 0, xsize[1]-4,4 do begin
    plotodd[i:i+1] = 1
    ploteven[i+2:i+3] = 1
endfor



if(inum gt 0) then begin 
    yrange_min = fltarr(inum) & yrange_max = fltarr(inum)
    yrange_min = min(info.ChannelRP[indexon].min)
    yrange_max  =max(info.ChannelRP[indexon].max)
endif else begin
    yrange_min = min(info.ChannelRP[*].min)
    yrange_max  =max(info.ChannelRP[*].max)
endelse


; check if default scale is true - then reset to orginal value
if(info.refp.time_default_range[0] eq 1) then begin
    info.refp.time_range[0,0] = 0
    info.refp.time_range[0,1] = num
endif

if(info.refp.time_default_range[1] eq 1) then begin
    info.refp.time_range[1,0] =yrange_min 
    info.refp.time_range[1,1] =yrange_max 
endif


stitle = ' '
sstitle = ' ' 

if(hcopy eq 1) then begin
    ymin_save = info.refp.time_range[1,0] 
    ymin_save = ymin_save + abs(ymin_save)*.02
    i = info.refp.integrationNO
    j = info.refp.rampNO
    ftitle = " Frame #: " + strtrim(string(i+1),2) 
    ititle = " Integration #: " + strtrim(string(j+1),2)
    sstitle = info.control.filebase + '.fits: ' + ftitle + ititle
    stitle = "Reference Pixels DN value vs Time (10 microseconds) :"
endif

tempdata = fltarr(1)




plot,tempdata,tempdata,xrange =[info.refp.time_range[0,0],$
                       info.refp.time_range[0,1]],$
     yrange = [info.refp.time_range[1,0],info.refp.time_range[1,1]],$
     xstyle = 1, ystyle = 1, xtitle = ' Time (RTI = 10 microseconds)', ytitle = ' DN' ,$
     title = stitle, subtitle = sstitle,/nodata,ytickformat = '(f7.0)'
;_______________________________________________________________________
;plot individual plots - one for each amplifier - if set to plot
;_______________________________________________________________________
for i =  0,inum-1 do begin
    ij = indexon[i]
    time_image = (*info.ChannelRP[ij].ptimedata)    
    time_image2 = time_image

    time = (*info.ChannelRP[ij].ptime)    



    index = where(ploteven eq 1,num) 
    time_data_even = fltarr(num)
    time_data_even = time_image[index]
    time_data_even2 = time_image2[index]
    x_data_even = fltarr(num)
    x_data_even = time[index]

    index = where(plotodd eq 1,num) 
    time_data_odd = fltarr(num)
    time_data_odd = time_image[index]
    time_data_odd2 = time_image2[index]
    x_data_odd = fltarr(num)
    x_data_odd = time[index]
;_______________________________________________________________________
    ii = 1
    while(ii le 2) do begin 
        if(info.refp.LeftPixelSetB eq 0) then begin
            time_odd = time_data_odd
            time_even = time_data_even
            ii = 3
            plottype = 1
        endif


        if(info.refp.LeftPixelSetB eq 1) then begin
            time_odd = time_data_odd2
            time_even = time_data_even2
            ii = 3
            plottype = 6
        endif

        if(info.refp.LeftPixelSetB eq 2) then begin
            if(ii eq 1)  then begin
                time_odd = time_data_odd
                time_even = time_data_even
                plottype = 1
            endif

            if(ii eq 2)  then begin
                time_odd = time_data_odd2
                time_even = time_data_even2
                plottype = 6
            endif
        endif

        plotodd_color = line_colors[ij]
        if(info.refp.plotwhite eq 1) then plotodd_color = info.white
        
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        num = n_elements(time_odd)
        plotlr_odd = indgen(num)
        index_left_odd = where( plotlr_odd mod 2 eq 0)
        index_right_odd = where( plotlr_odd mod 2 eq 1)
            
        num = n_elements(time_even)
        plotlr_even = indgen(num)
        index_left_even = where( plotlr_even mod 2 eq 0)
        index_right_even = where( plotlr_even mod 2 eq 1)


        if(info.refp.plotrightleft) then begin 
            ; plot odd
            if(info.refp.plotodd eq 1) then begin 
                oplot,x_data_odd[index_left_odd],time_odd[index_left_odd],psym=plottype,symsize=ssize,color=plotodd_color
                oplot,x_data_odd[index_right_odd],time_odd[index_right_odd],psym=2,symsize=ssize,color=plotodd_color
                if(info.refp.overplotline eq 1) then oplot,x_data_odd,time_odd,color=plotodd_color,linestyle = 1
            endif

            ; plot even 
            if(info.refp.ploteven eq 1) then begin 
                oplot,x_data_even[index_left_even],time_even[index_left_even],psym=plottype,symsize=ssize,color=line_colors[ij]
                oplot,x_data_even[index_right_even],time_even[index_right_even],psym=2,symsize=ssize,color=line_colors[ij]
                if(info.refp.overplotline eq 1) then oplot,x_data_even,time_even,color=line_colors[ij],linestyle = 1
            endif
        endif
       
        ; only plot right side
        if(info.refp.plotright) then begin 
            ; plot odd
            if(info.refp.plotodd eq 1) then begin 
                oplot,x_data_odd[index_right_odd],time_odd[index_right_odd],psym=2,symsize=ssize,color=plotodd_color
                if(info.refp.overplotline eq 1) then $
                  oplot,x_data_odd[index_right_odd],time_odd[index_right_odd],color=plotodd_color,linestyle = 1
            endif

            ; plot even 
            if(info.refp.ploteven eq 1) then begin 
                oplot,x_data_even[index_right_even],time_even[index_right_even],psym=2,symsize=ssize,color=line_colors[ij]
                if(info.refp.overplotline eq 1) then $                 
                  oplot,x_data_even[index_right_even],time_even[index_right_even],color=line_colors[ij],linestyle = 1
            endif
        endif


        ; only plot left 
        if(info.refp.plotleft) then begin 
            ; plot odd 
            if(info.refp.plotodd eq 1) then begin 
                oplot,x_data_odd[index_left_odd],time_odd[index_left_odd],psym=plottype,symsize=ssize,color=plotodd_color
                if(info.refp.overplotline eq 1) then $
                  oplot,x_data_odd[index_left_odd],time_odd[index_left_odd],color=plotodd_color,linestyle = 1
            endif
            ; plot even 
            if(info.refp.ploteven eq 1) then begin 
                oplot,x_data_even[index_left_even],time_even[index_left_even],psym=plottype,symsize=ssize,color=line_colors[ij]

                if(info.refp.overplotline eq 1) then $
                  oplot,x_data_even[index_left_even],time_even[index_left_even],color=line_colors[ij],linestyle = 1
            endif
                
        endif

        ii = ii + 1
    endwhile 
endfor


if(hcopy eq 1) then begin
    
    xedge = info.refp.time_range[0,0]
    xrange = info.refp.time_range[0,1] - info.refp.time_range[0,0]
    xincr = xrange/9
    xyouts, xedge ,ymin_save,' Channel 1',color=line_colors[0]
    xyouts,xedge+xincr,ymin_save,' Channel 2',color = line_colors[1]
    xyouts,xedge+(xincr*2),ymin_save,' Channel 3',color = line_colors[2]
    xyouts,xedge+(xincr*3),ymin_save,' Channel 4',color = line_colors[3]
    xyouts,xedge+(xincr*5),ymin_save,' Left Side'
    xplot = fltarr(1) & yplot = fltarr(1)
    xplot[0] = xedge + (xincr*6)
    yplot[0] =  ymin_save
    oplot,xplot,yplot,psym = 2
    xyouts,xedge+(xincr*7),ymin_save,' Right Side'
    xplot[0] = xedge + (xincr*8)
    oplot,xplot,yplot,psym = 1

endif

xmin = info.refp.time_range[0,0]
xmax = info.refp.time_range[0,1]
ymin = info.refp.time_range[1,0]
ymax = info.refp.time_range[1,1]


widget_control,info.refp.trangeID[0,0],set_value=long(xmin)
widget_control,info.refp.trangeID[0,1],set_value=long(xmax)
widget_control,info.refp.trangeID[1,0],set_value=ymin
widget_control,info.refp.trangeID[1,1],set_value=ymax



frame_image = 0
x_image = 0
time_image = 0


if(hcopy eq 0) then begin 
    for i = 0,3 do begin

        wset,info.refp.draw_box_left[i]
        xplot = findgen(5)/5
        xplot = [0.1,0.4,0.7]
        yplot = [0.5,0.5,0.5]

        plot,xplot,yplot,/normal,color=line_colors[i], $
             xstyle=4,ystyle=4,position=[0.1,0.1,0.9,0.9],xrange=[0.0,1.0], $
             yrange=[0.0,1.0],psym = 1,symsize = 0.8

        wset,info.refp.draw_box_right[i]
        plot,xplot,yplot,/normal,color=line_colors[i], $
             xstyle=4,ystyle=4,position=[0.1,0.1,0.9,0.9],xrange=[0.0,1.0], $
             yrange=[0.0,1.0],psym = 2,symsize = 0.8


    endfor
endif


info.col_table = save_color

end
;***********************************************************************
