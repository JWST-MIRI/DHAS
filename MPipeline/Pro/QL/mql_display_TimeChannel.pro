;_______________________________________________________________________
pro mql_TimeChannel_quit,event


widget_control,event.top, Get_UValue = cinfo	
widget_control,cinfo.info.QuickLook,Get_Uvalue = info

widget_control,info.TimeChannelQuickLook,/destroy


end

;_______________________________________________________________________

pro mql_update_TimeChannel,info,ps = ps, eps = eps
;_______________________________________________________________________
hcopy = 0
if ( (keyword_set(ps)) or ( keyword_set(eps)) ) then hcopy = 1

save_color = info.col_table
color6
white_color = info.white
if(hcopy eq 1) then white_color = info.black
plot_refsize  = 0.2
; white = 1, red = 2, green = 3, blue = 4, yellow = 5
line_colors = [info.red,info.green,info.blue, info.yellow,info.white]

xsize_image = info.TimeChannel.xplotsize
ysize_image = info.TimeChannel.yplotsize
if(hcopy eq 0) then wset,info.Timechannel.draw_window_id


ncol = info.data.image_xsize/4 ; 

num = long (info.data.image_ysize) * long(ncol)
evenodd = fltarr(num)
nrefpixels = (info.data.image_ysize) 
evenodd_refpixels = fltarr(nrefpixels)

flagref = 1                     ; odd 
for i = 0,info.data.image_ysize-1 do begin
    j = i + 1

    istart = 0L 
    iend = 0L
    istart = long(i)*long(ncol)
    iend = long(istart) + long(ncol-1)
    flag = 0
    if(j mod 2) then flag = 1 ; odd
    evenodd[istart:iend] = flag


    evenodd_refpixels[i] = flagref
    flagref = flagref+1
    if(flagref ge 2) then flagref = 0
endfor
;

;_______________________________________________________________________
; set range of plot

ptype = [1,2,4,5,6]
time_image = (*info.ChannelT[0].ptimedata)
time = (*info.ChannelT[0].ptime)

num = max(time)
index = where(info.TimeChannel.onvalue[*] eq 1, inum)

info.TimeChannel.single_channel = 0
if(inum eq 1) then info.TimeChannel.single_channel = 1

if(inum gt 1) then begin ; turn off single channel analysis
    info.TimeChannel.plot_refpixels = 0
    widget_control,info.TimeChannel.refpixelID[0], set_button = 0
    widget_control,info.TimeChannel.refpixelID[1], set_button = 1

    info.TimeChannel.plot_odd_diff = 0
    widget_control,info.TimeChannel.oddID[0], set_button = 0
    widget_control,info.TimeChannel.oddID[1], set_button = 1

    if(info.control.file_refcorrection_exist eq 1)then begin 
        info.TimeChannel.plot_reference_corrected= 0
        widget_control,info.TimeChannel.overplotrefcorrectedID[0],set_button = 0
        widget_control,info.TimeChannel.overplotrefcorrectedID[1],set_button = 1
    endif
endif


plot_refsize = 0.2
plot_left = 1
plot_right = 4
plot_left2 = 2
if(info.TimeChannel.plot_emp eq 1) then  plot_refsize = 1.25
;_______________________________________________________________________
yrange_min = 0 & yrange_max = 0
if(inum gt 0) then begin ; find the min and max of the y axis
    yrange_min = fltarr(inum) & yrange_max = fltarr(inum)
    for i =  0,inum-1 do begin
        ij = index[i]
        time_image = (*info.ChannelT[ij].ptimedata)    
        indxs = where(finite(time_image),n_pixels)
    
        minsignal = min(time_image[indxs])
        maxsignal = max(time_image[indxs])

        yrange_min[i] = minsignal
        yrange_max[i]  =maxsignal
    endfor
endif
time_image = 0 

; check if default scale is true - then reset to orginal value
if(info.TimeChannel.default_range[0] eq 1) then begin
    info.TimeChannel.graph_range[0,0] = 0
    info.TimeChannel.graph_range[0,1] = num
endif

if(info.TimeChannel.default_range[1] eq 1) then begin
    pad = 0.20*abs(max(yrange_max))
    info.TimeChannel.graph_range[1,0] = min(yrange_min) - pad
    info.TimeChannel.graph_range[1,1] = max(yrange_max) + pad
endif


;_______________________________________________________________________
; Set up the information on the frame 
stitleF = ' '
sstitle = ' ' 

if(hcopy eq 1) then begin
    ymin_save = info.TimeChannel.graph_range[1,0] 
    ymin_save = ymin_save + abs(ymin_save)*.05
    i = info.TimeChannel.integrationNO
    j = info.TimeChannel.frameNO
    ftitle = " Frame #: " + strtrim(string(i+1),2) 
    ititle = " Integration #: " + strtrim(string(j+1),2)
    sstitle = info.control.filebase + '.fits: ' + ftitle + ititle
    stitle = " Pixels DN value vs Time (10 microseconds) :"

    if(info.TimeChannel.plotodd eq 1) then stitleF = stitle + ' Odd Rows'
    if(info.TimeChannel.ploteven eq 1) then stitleF = stitle + ' Even Rows'
    if(info.TimeChannel.plotodd eq info.TimeChannel.ploteven) then $
      stitleF = stitle + ' Even Rows & Odd Rows'
endif


tempdata = fltarr(1)
plot,tempdata,tempdata,xrange =[info.TimeChannel.graph_range[0,0],$
                       info.TimeChannel.graph_range[0,1]],title = stitleF,subtitle = sstitle,$
     yrange = [info.TimeChannel.graph_range[1,0],info.TimeChannel.graph_range[1,1]],$
     xstyle = 1, ystyle = 1; xtitle = ' Time ordered pixel #', ytitle = ' Intensity' ,$

;_______________________________________________________________________
;plot individual plots - one for each amplifier - if set to plot
;_______________________________________________________________________
for i =  0,inum-1 do begin
    ij = index[i]

; set up the color
    odd_color = line_colors[ij]
    if(info.TimeChannel.plot_odd_diff eq 1) then odd_color = info.TimeChannel.plot_odd_color

    plot_refcolor = info.TimeChannel.plot_refpixel_color 
    plot_refcorrected_color = info.TimeChannel.plot_refcorrected_color

    time_image = (*info.ChannelT[ij].ptimedata)    
    time = (*info.ChannelT[ij].ptime)    
    time_flag = (*info.ChannelT[ij].ptimeflag)

    time_bad = time_image
    time_bad[*] = 0
    if(info.TimeChannel.apply_bad) then begin
        time_bad = (*info.ChannelT[ij].pbadpixel)
    endif

;_______________________________________________________________________
 ; create a mask of data to plot
    
    ; set elements in mask to good data

    index_good = where(time_bad eq 0,ngood)
    mask = time_image
    mask[*] = 0
    mask[index_good] = 1
    ; set elements to science data or reference pixels
    index_data = where(time_flag eq 0) 


    mask_data = mask
    mask_data[*] = 0

    mask_data[index_data] = 1
    mask = mask + mask_data

; even and odd split
    
    plotodd = where(evenodd[*] eq 1)  
    ploteven = where(evenodd[*] eq 0)
     
    maskodd = mask
    maskodd[*] = 0
    maskeven = maskodd
    maskodd[plotodd] = 1
    mask_odd = mask + maskodd
    maskeven[ploteven] = 1
    mask_even = mask + maskeven

    
    ; get even science data 
    id_sci_even  = where(mask_even eq 3)
    sci_data_even = time_image[id_sci_even]
    time_even = time[id_sci_even]


    id_sci_odd  = where(mask_odd eq 3)
    sci_data_odd = time_image[id_sci_odd]
    time_odd = time[id_sci_odd]

    if(info.TimeChannel.ploteven eq 1)then  $
      oplot,time_even,sci_data_even,psym=1,symsize=.1,color=line_colors[ij]   
    
    if(info.TimeChannel.plotodd eq 1 ) then  $
      oplot,time_odd,sci_data_odd,psym=1,symsize=.1,color=odd_color   

    if(info.TimeChannel.plot_refpixels eq 1) then begin

      ; reference pixels
        index_rpl = where(time_flag eq 1)
        index_rpr = where(time_flag eq 2)


        mask_data_rpl = mask[index_rpl]
        mask_data_rpr = mask[index_rpr]
        data_rpl = time_image[index_rpl]
        data_rpr = time_image[index_rpr]
        time_rpl = time[index_rpl]
        time_rpr = time[index_rpr]


        ;left first set - odd        
        index = where(mask_data_rpl eq 1 and evenodd_refpixels eq 1) 
        xl_odd = time_rpl[index]
        yl_odd = data_rpl[index]

        ;left first set - even       
        index = where(mask_data_rpl eq 1 and evenodd_refpixels eq 0) 
        xl_even = time_rpl[index]
        yl_even = data_rpl[index]


        ;right - odd        
        index = where(mask_data_rpr eq 1 and evenodd_refpixels eq 1) 
        xr_odd = time_rpr[index]
        yr_odd = data_rpr[index]

        ;right - even       
        index = where(mask_data_rpr eq 1 and evenodd_refpixels eq 0) 
        xr_even = time_rpr[index]
        yr_even = data_rpr[index]



        ; plot left,odd


        if(info.TimeChannel.plotodd eq 1 and info.TimeChannel.plotleft eq 1 ) then begin 
                oplot,xl_odd,yl_odd,psym = plot_left, symsize = plot_refsize, color = plot_refcolor
                ;oplot,xl_odd,yl_odd,psym = plot_left, symsize = plot_refsize, color = info.red
        endif

        ; plot left,even
        
        if(info.TimeChannel.ploteven eq 1 and info.TimeChannel.plotleft eq 1 ) then begin 
                oplot,xl_even,yl_even,psym = plot_left, symsize = plot_refsize, color = plot_refcolor

        endif


        ; plot right,odd
        
        if(info.TimeChannel.plotodd eq 1 and info.TimeChannel.plotright eq 1 ) then begin 
            oplot,xr_odd,yr_odd,psym = plot_right, symsize = plot_refsize, color = plot_refcolor
            ;oplot,xr_odd,yr_odd,psym = plot_right, symsize = plot_refsize, color = info.red
        endif

        ; plot right,even
        
        if(info.TimeChannel.ploteven eq 1 and info.TimeChannel.plotright eq 1 ) then begin 
            oplot,xr_even,yr_even,psym = plot_right, symsize = plot_refsize, color = plot_refcolor
        endif

        xplot = 0
        yplot = 0
        xr_odd = 0 & yr_odd  = 0 & xl_odd = 0 & yl_odd = 0 & ix = 0 
        xr_even= 0 & yr_even  = 0 & xl_even = 0 & yl_even = 0 & ix = 0 
    endif

    if(info.TimeChannel.plot_reference_corrected eq 1) then begin
        time_image = (*info.ChannelTR[ij].ptimedata)    
        time = (*info.ChannelTR[ij].ptime)    
     
        sci_data_even = time_image[id_sci_even]
        time_even = time[id_sci_even]

        sci_data_odd = time_image[id_sci_odd]
        time_odd = time[id_sci_odd]

        if(info.TimeChannel.ploteven eq 1)then  $
          oplot,time_even,sci_data_even,psym=1,symsize=.1,color=plot_refcorrected_color
        
        if(info.TimeChannel.plotodd eq 1 ) then  $
          oplot,time_odd,sci_data_odd,psym=1,symsize=.1,color=plot_refcorrected_color

    endif


    
    time_image = 0   &  time = 0  & time_flag = 0 &  index_data = 0  & index_rp = 0
    sci_data = 0  & sci_time = 0  & sci_flag = 0   & plotodd = 0  & ploteven = 0
     
    sci_data_even = 0 &  time_even = 0  &  sci_data_odd =  0  & time_odd = 0
    mask = 0 & mask_rp = 0 & maskodd = 0 & maskeven = 0 & mask_even = 0 & mask_odd = 0 
    mask_data =0 & mask_data_rp = 0 & 
endfor


xmin = info.TimeChannel.graph_range[0,0]
xmax = info.TimeChannel.graph_range[0,1]
ymin = info.TimeChannel.graph_range[1,0]
ymax = info.TimeChannel.graph_range[1,1]

widget_control,info.TimeChannel.rangeID[0,0],set_value=xmin
widget_control,info.TimeChannel.rangeID[0,1],set_value=xmax
widget_control,info.TimeChannel.rangeID[1,0],set_value=ymin
widget_control,info.TimeChannel.rangeID[1,1],set_value=ymax


frame_image = 0
x_image = 0
time_image = 0
evenodd = 0
id_sci_even = 0 & id_sci_odd = 0
;_______________________________________________________________________

if(hcopy eq 0) then begin 

    for i = 0,4 do begin
        wset,info.Timechannel.draw_box_id[i]
        xplot = [0.1,0.3,0.5 ,0.7,0.9]
        yplot = xplot
        yplot[*] = 0.5
        plot,xplot,yplot,/normal,color=line_colors[i], $
             xstyle=4,ystyle=4,position=[0.1,0.1,0.9,0.9],xrange=[0.0,1.0], $
             yrange=[0.0,1.0],psym = 1,symsize = .2
    endfor



    for i = 0,4 do begin
        wset,info.Timechannel.draw_box_id_odd[i]
        xplot = [0.1,0.4,0.7]
        yplot = [0.5,0.5,0.5]
        plot,xplot,yplot,/normal,color=line_colors[i], $
             xstyle=4,ystyle=4,position=[0.1,0.1,0.9,0.9],xrange=[0.0,1.0], $
             yrange=[0.0,1.0],psym = 1,symsize = 0.2
    endfor

    wset,info.Timechannel.left_box_id
    xplot = [0.5]
    yplot = [0.5]
    plot,xplot,yplot,/normal, $
         xstyle=4,ystyle=4,position=[0.1,0.1,0.9,0.9],xrange=[0.0,1.0], $
         yrange=[0.0,1.0],psym = plot_left,symsize = 1, color = plot_refcolor


    wset,info.Timechannel.right_box_id
    xplot = [0.5]
    yplot = [0.5,0]
    plot,xplot,yplot,/normal, $
         xstyle=4,ystyle=4,position=[0.1,0.1,0.9,0.9],xrange=[0.0,1.0], $
         yrange=[0.0,1.0],psym = plot_right,symsize = 1, color = plot_refcolor
    

    for i = 0,4 do begin
        wset,info.Timechannel.draw_box_id_color[i]
        xplot = [0.1,0.4,0.7]
        yplot = [0.5,0.5,0.5]
        plot,xplot,yplot,/normal,color=line_colors[i], $
             xstyle=4,ystyle=4,position=[0.1,0.1,0.9,0.9],xrange=[0.0,1.0], $
             yrange=[0.0,1.0],psym = 1, symsize = 0.2
    endfor

    if(info.control.file_refcorrection_exist eq 1)then begin 
        for i = 0,4 do begin
            wset,info.Timechannel.draw_box_id_color_ref[i]
            xplot = [0.1,0.4,0.7]
            yplot = [0.5,0.5,0.5]
            plot,xplot,yplot,/normal,color=line_colors[i], $
                 xstyle=4,ystyle=4,position=[0.1,0.1,0.9,0.9],xrange=[0.0,1.0], $
                 yrange=[0.0,1.0],psym = 1, symsize = 0.2
        endfor
    endif
endif


if(hcopy eq 1) then begin
    
    xedge = info.TimeChannel.graph_range[0,0]
    xrange = info.TimeChannel.graph_range[0,1] - info.TimeChannel.graph_range[0,0]
    xincr = xrange/9
    if(info.TimeChannel.onvalue[0] eq 1) then xyouts, xedge ,ymin_save,' Channel 1',color=line_colors[0]
    if(info.TimeChannel.onvalue[1] eq 1) then xyouts,xedge+xincr,ymin_save,' Channel 2',color = line_colors[1]
    if(info.TimeChannel.onvalue[2] eq 1) then xyouts,xedge+(xincr*2),ymin_save,' Channel 3',color = line_colors[2]
    if(info.TimeChannel.onvalue[3] eq 1) then xyouts,xedge+(xincr*3),ymin_save,' Channel 4',color = line_colors[3]
    if(info.TimeChannel.onvalue[4] eq 1) then xyouts,xedge+(xincr*3),ymin_save,' Channel 5',color = line_colors[4]

    if(info.TimeChannel.plot_odd_diff eq 1) then $
      xyouts,xedge+(xincr*3.5),ymin_save,' Odd Row Color',color= odd_color
    if(info.TimeChannel.plot_refpixels eq 1) then begin    
        xyouts,xedge+(xincr*5),ymin_save,' Ref Pixels Left  Side',color= plot_refcolor
        xplot = fltarr(1) & yplot = fltarr(1)
        xplot[0] = xedge + (xincr*6)
        yplot[0] =  ymin_save
        oplot,xplot,yplot,psym = plot_left
        xyouts,xedge+(xincr*7),ymin_save,' Ref Pixel Right Side',color=plot_refcolor
        xplot[0] = xedge + (xincr*8)
        oplot,xplot,yplot,psym = plot_right
    endif
endif


ind1 = where(line_colors[*] eq info.TimeChannel.plot_refpixel_color)
widget_control,info.TimeChannel.colorbutton[ind1[0]],set_button = 1

if(info.control.file_refcorrection_exist eq 1)then begin 
    ind2 = where(line_colors[*] eq info.TimeChannel.plot_refcorrected_color)
    widget_control,info.TimeChannel.colorbutton_ref[ind2[0]],set_button = 1
endif

ind3 = where(line_colors[*] eq info.TimeChannel.plot_odd_color)
widget_control,info.TimeChannel.oddbutton[ind3[0]],set_button = 1

info.col_table = save_color
end
;***********************************************************************



;_______________________________________________________________________

;***********************************************************************

; the event manager for the ql.pro (main base widget)
pro mql_TimeChannel_event,event

Widget_Control,event.id,Get_uValue=event_name
widget_control,event.top, Get_UValue = cinfo
widget_control,cinfo.info.Quicklook,Get_Uvalue = minfo

cinfo.info = minfo
iramp = minfo.channelT[0].iramp
jintegration = minfo.channelT[0].jintegration
save_color = minfo.col_table
color6
single_channel_message = ' This option is only available when plotting a single channel' 


if (widget_info(event.id,/TLB_SIZE_EVENTS) eq 1 ) then begin
    minfo.TimeChannel.xwindowsize = event.x
    minfo.TimeChannel.ywindowsize = event.y
    minfo.TimeChannel.uwindowsize = 1
    widget_control,event.top,set_uvalue = cinfo
    widget_control,cinfo.info.Quicklook,set_uvalue = minfo
    mql_display_TimeChannel,minfo
    return
endif



    case 1 of


;_______________________________________________________________________
; Print time ordered plot
;_______________________________________________________________________

    (strmid(event_name,0,5) EQ 'print') : begin
        print_timeordered,minfo
    end

    (strmid(event_name,0,5) EQ 'stat') : begin
        mql_display_Channel_time_stat,minfo
    end

;_______________________________________________________________________
    (strmid(event_name,0,3) EQ 'bad') : begin

        num = fix(strmid(event_name,3,1))
        if(num eq 1) then begin
            minfo.TimeChannel.apply_bad = 1
            widget_control,minfo.TimeChannel.BadButton[0],set_button = 1
            widget_control,minfo.TimeChannel.BadButton[1],set_button = 0
        endif

        if(num eq 2) then begin
            minfo.TimeChannel.apply_bad = 0
            widget_control,minfo.TimeChannel.BadButton[0],set_button = 0
            widget_control,minfo.TimeChannel.BadButton[1],set_button = 1
        endif

        mql_update_TimeChannel,minfo
    end


;_______________________________________________________________________
; overplot reference corrected data

    (strmid(event_name,0,7) eq 'overref') : begin
        num = fix(strmid(event_name,7,1))
        if(num eq 1) then begin
            if(minfo.TimeChannel.single_channel eq 0) then begin 
                result = dialog_message(single_channel_message,/info)
                minfo.TimeChannel.plot_reference_corrected= 0
            endif else begin
                
                minfo.TimeChannel.plot_reference_corrected = 1
                widget_control,minfo.TimeChannel.overplotrefcorrectedID[1],set_button = 0
                widget_control,minfo.TimeChannel.overplotrefcorrectedID[0],set_button = 1
                
            endelse
        endif

        if(num eq 2) then begin
            minfo.TimeChannel.plot_reference_corrected= 0
            widget_control,minfo.TimeChannel.overplotrefcorrectedID[0],set_button = 0
            widget_control,minfo.TimeChannel.overplotrefcorrectedID[1],set_button = 1
        endif


        mql_update_TimeChannel,minfo
        
    end

;_______________________________________________________________________
; change x and y range of plot
; if change range then also change the button to 'User Set Scale'
;_______________________________________________________________________
    (strmid(event_name,0,5) EQ 'range') : begin
        num = fix(strmid(event_name,5,1)) -1

        if(minfo.TimeChannel.default_range[num] eq 0 ) then begin 
            widget_control,minfo.TimeChannel.recomputeID[num],set_value=' Plot Range'
            minfo.TimeChannel.default_range[num] = 1
        endif

        mql_update_TimeChannel,minfo

    end


    (strmid(event_name,0,2) EQ 'cr') : begin
        num = fix(strmid(event_name,2,1))-1

        widget_control,minfo.TimeChannel.rangeID[0,0],get_value = temp
        test = abs(temp - minfo.TimeChannel.graph_range[0,0])
        minfo.TimeChannel.graph_range[0,0]= temp
        if(test gt 1) then minfo.TimeChannel.default_range[0] = 0

        widget_control,minfo.TimeChannel.rangeID[0,1],get_value = temp
        test = abs(temp - minfo.TimeChannel.graph_range[0,1])
        minfo.TimeChannel.graph_range[0,1]= temp
        if(test gt 1) then minfo.TimeChannel.default_range[0] = 0

        widget_control,minfo.TimeChannel.rangeID[1,0],get_value = temp
        test = abs(temp - minfo.TimeChannel.graph_range[1,0])
        minfo.TimeChannel.graph_range[1,0]= temp
        if(test gt 1) then minfo.TimeChannel.default_range[1] = 0

        widget_control,minfo.TimeChannel.rangeID[1,1],get_value = temp
        test = abs(temp - minfo.TimeChannel.graph_range[1,1])
        minfo.TimeChannel.graph_range[1,1]= temp
        if(test gt 1) then minfo.TimeChannel.default_range[1] = 0

        if(minfo.TimeChannel.default_range[0] eq 0) then $
          widget_control,minfo.TimeChannel.recomputeID[0],set_value=' Default '

        if(minfo.TimeChannel.default_range[1] eq 0) then $
          widget_control,minfo.TimeChannel.recomputeID[1],set_value=' Default'

        mql_update_TimeChannel,minfo
       
    end

;_______________________________________________________________________
    (strmid(event_name,0,2) EQ 'on') : begin
        num = fix(strmid(event_name,2,1))-1
        minfo.TimeChannel.onvalue[num] = 1
        widget_control, minfo.TimeChannel.offButton[num],Set_Button = 0
        widget_control, minfo.TimeChannel.onButton[num],Set_Button = 1
        mql_update_TimeChannel,minfo
    end

    (strmid(event_name,0,3) EQ 'off') : begin
        num = fix(strmid(event_name,3,1))-1
        minfo.TimeChannel.onvalue[num] = 0
        widget_control, minfo.TimeChannel.onButton[num],Set_Button = 0
        widget_control, minfo.TimeChannel.offButton[num],Set_Button = 1

        mql_update_TimeChannel,minfo
    end

    (strmid(event_name,0,7) EQ 'allplot') : begin
        type = fix(strmid(event_name,7,1))
        if(type eq 1) then begin
            widget_control, minfo.TimeChannel.noneButton,Set_Button = 0
            for i = 0,4 do begin 
                minfo.TimeChannel.onvalue[i] = 1
                widget_control, minfo.TimeChannel.onButton[i],Set_Button = 1
                widget_control, minfo.TimeChannel.offButton[i],Set_Button = 0
            endfor
        endif
        if(type eq 2) then begin
            widget_control, minfo.TimeChannel.allButton,Set_Button = 0
            for i = 0,4 do begin 
                minfo.TimeChannel.onvalue[i] = 0
                widget_control, minfo.TimeChannel.onButton[i],Set_Button = 0
                widget_control, minfo.TimeChannel.offButton[i],Set_Button = 1
            endfor
        endif
            
        mql_update_TimeChannel,minfo

    end

;_______________________________________________________________________
    (strmid(event_name,0,4) EQ 'trow') : begin
        idata=  strmid(event_name,4,1) 
	if(idata eq 'a') then begin 	
	    minfo.TimeChannel.ploteven = 1
	    minfo.TimeChannel.plotodd = 1
            ploteven = 0
            plotodd = 0
            plotall = 1
	endif

	if(idata eq 'e') then begin 	
	    minfo.TimeChannel.ploteven = 1
	    minfo.TimeChannel.plotodd = 0
            ploteven = 1
            plotodd = 0
            plotall = 0
	endif
	if(idata eq 'o') then begin 	
	    minfo.TimeChannel.ploteven = 0
	    minfo.TimeChannel.plotodd = 1
            ploteven = 0
            plotodd =1
            plotall = 0
	endif


	widget_control,minfo.TimeChannel.abutton,set_button =  plotall 
	widget_control,minfo.TimeChannel.ebutton,set_button = ploteven
	widget_control,minfo.TimeChannel.obutton,set_button = plotodd


        mql_update_TimeChannel,minfo    

    end


;_______________________________________________________________________
; Plot reference pixels
;_______________________________________________________________________

    (strmid(event_name,0,2) EQ 'rp') : begin

        if(minfo.TimeChannel.single_channel eq 0) then begin 
            result = dialog_message(single_channel_message,/info)
            minfo.TimeChannel.plot_refpixels = 0
            widget_control,minfo.TimeChannel.refpixelID[0],set_button = 0
            widget_control,minfo.TimeChannel.refpixelID[1],set_button = 1

        endif else begin 
            
            ii=  strmid(event_name,2,1)
            if(ii eq '1') then begin

                minfo.TimeChannel.plot_refpixels = 1
                widget_control,minfo.TimeChannel.refpixelID[0],set_button = 1
                widget_control,minfo.TimeChannel.refpixelID[1],set_button = 0
            endif

            if(ii eq '2') then begin 
                minfo.TimeChannel.plot_refpixels = 0
                widget_control,minfo.TimeChannel.refpixelID[0],set_button = 0
                widget_control,minfo.TimeChannel.refpixelID[1],set_button = 1
            endif
            mql_update_TimeChannel,minfo    
        endelse
    end

;_______________________________________________________________________
    (strmid(event_name,0,4) EQ 'lset') : begin

        ii=  strmid(event_name,4,1)
        if(ii eq '1') then begin 
            minfo.TimeChannel.LeftPixelSet = 0
            widget_control,minfo.TimeChannel.LeftDataID[0],set_button = 1
            widget_control,minfo.TimeChannel.LeftDataID[1],set_button = 0
            widget_control,minfo.TimeChannel.LeftDataID[2],set_button = 0
        endif

        if(ii eq '2') then begin 
            minfo.TimeChannel.LeftPixelSet = 1
            widget_control,minfo.TimeChannel.LeftDataID[0],set_button = 0
            widget_control,minfo.TimeChannel.LeftDataID[1],set_button = 1
            widget_control,minfo.TimeChannel.LeftDataID[2],set_button = 0
        endif

        if(ii eq '3') then begin 
            minfo.TimeChannel.LeftPixelSet = 2
            widget_control,minfo.TimeChannel.LeftDataID[0],set_button = 0
            widget_control,minfo.TimeChannel.LeftDataID[1],set_button = 0
            widget_control,minfo.TimeChannel.LeftDataID[2],set_button = 1
        endif

        mql_update_TimeChannel,minfo

    end

;_______________________________________________________________________

    (strmid(event_name,0,2) EQ 'lr') : begin

        idata=  strmid(event_name,2,1) 
	if(idata eq '1') then begin 	

	    minfo.TimeChannel.plotright = 1
	    minfo.TimeChannel.plotleft = 1
            widget_control,minfo.TimeChannel.rightleftButton[0],set_button = 1
            widget_control,minfo.TimeChannel.rightleftButton[1],set_button = 0
            widget_control,minfo.TimeChannel.rightleftButton[2],set_button = 0

	endif
	if(idata eq '2') then begin 	
	    minfo.TimeChannel.plotright = 0
	    minfo.TimeChannel.plotleft = 1
            widget_control,minfo.TimeChannel.rightleftButton[0],set_button = 0
            widget_control,minfo.TimeChannel.rightleftButton[1],set_button = 1
            widget_control,minfo.TimeChannel.rightleftButton[2],set_button = 0
	endif
	if(idata eq '3') then begin 	

	    minfo.TimeChannel.plotright= 1
	    minfo.TimeChannel.plotleft = 0
            widget_control,minfo.TimeChannel.rightleftButton[0],set_button = 0
            widget_control,minfo.TimeChannel.rightleftButton[1],set_button = 0
            widget_control,minfo.TimeChannel.rightleftButton[2],set_button = 1
	endif


        mql_update_TimeChannel,minfo    
    end

;_______________________________________________________________________
; Plot - emphasize reference pixels
;_______________________________________________________________________

    (strmid(event_name,0,2) EQ 'em') : begin

        if(minfo.TimeChannel.single_channel eq 0) then begin 
            result = dialog_message(single_channel_message,/info)
            minfo.TimeChannel.plot_emp = 0
            widget_control,minfo.TimeChannel.empID[0],set_button = 0
            widget_control,minfo.TimeChannel.empID[1],set_button = 1

        endif else begin 
            ii=  strmid(event_name,2,1)
            if(ii eq '1') then begin 
                minfo.TimeChannel.plot_emp = 1
                widget_control,minfo.TimeChannel.empID[0],set_button = 1
                widget_control,minfo.TimeChannel.empID[1],set_button = 0
            endif

            if(ii eq '2') then begin 
                minfo.TimeChannel.plot_emp = 0
                widget_control,minfo.TimeChannel.empID[0],set_button = 0
                widget_control,minfo.TimeChannel.empID[1],set_button = 1
            endif
            mql_update_TimeChannel,minfo    
        endelse
    end

;_______________________________________________________________________
; reference pixel color
;_______________________________________________________________________

    (strmid(event_name,0,5) EQ 'color') : begin
        if(minfo.TimeChannel.single_channel eq 0) then begin 
            result = dialog_message(single_channel_message,/info)
            minfo.TimeChannel.plot_refpixels = 0

        endif else begin 

            ii=  strmid(event_name,5,1)
            if(ii eq '1') then begin 
                minfo.TimeChannel.plot_refpixel_color = 2
                widget_control,minfo.TimeChannel.colorbutton[0],set_button = 1
                widget_control,minfo.TimeChannel.colorbutton[1],set_button = 0
                widget_control,minfo.TimeChannel.colorbutton[2],set_button = 0
                widget_control,minfo.TimeChannel.colorbutton[3],set_button = 0
                widget_control,minfo.TimeChannel.colorbutton[4],set_button = 0
            endif
            
            if(ii eq '2') then begin 
                minfo.TimeChannel.plot_refpixel_color = 3
                widget_control,minfo.TimeChannel.colorbutton[0],set_button = 0
                widget_control,minfo.TimeChannel.colorbutton[1],set_button = 1
                widget_control,minfo.TimeChannel.colorbutton[2],set_button = 0
                widget_control,minfo.TimeChannel.colorbutton[3],set_button = 0
                widget_control,minfo.TimeChannel.colorbutton[4],set_button = 0
            endif

            if(ii eq '3') then begin 
                minfo.TimeChannel.plot_refpixel_color = 4
                widget_control,minfo.TimeChannel.colorbutton[0],set_button = 0
                widget_control,minfo.TimeChannel.colorbutton[1],set_button = 0
                widget_control,minfo.TimeChannel.colorbutton[2],set_button = 1
                widget_control,minfo.TimeChannel.colorbutton[3],set_button = 0
                widget_control,minfo.TimeChannel.colorbutton[4],set_button = 0
            endif

            if(ii eq '4') then begin 
                minfo.TimeChannel.plot_refpixel_color = 5
                widget_control,minfo.TimeChannel.colorbutton[0],set_button = 0
                widget_control,minfo.TimeChannel.colorbutton[1],set_button = 0
                widget_control,minfo.TimeChannel.colorbutton[2],set_button = 0
                widget_control,minfo.TimeChannel.colorbutton[3],set_button = 1
                widget_control,minfo.TimeChannel.colorbutton[4],set_button = 0
            endif


            if(ii eq '5') then begin 
                minfo.TimeChannel.plot_refpixel_color = 1
                widget_control,minfo.TimeChannel.colorbutton[0],set_button = 0
                widget_control,minfo.TimeChannel.colorbutton[1],set_button = 0
                widget_control,minfo.TimeChannel.colorbutton[2],set_button = 0
                widget_control,minfo.TimeChannel.colorbutton[3],set_button = 0
                widget_control,minfo.TimeChannel.colorbutton[4],set_button = 1
            endif
            mql_update_TimeChannel,minfo
        endelse
    end




;_______________________________________________________________________
; reference pixel color
;_______________________________________________________________________

    (strmid(event_name,0,6) EQ 'Rcolor') : begin

        if(minfo.TimeChannel.single_channel eq 0) then begin 
            result = dialog_message(single_channel_message,/info)
            minfo.TimeChannel.plot_reference_corrected= 0

        endif else begin 
            
            ii=  strmid(event_name,6,1)
            if(ii eq '1') then begin 
                minfo.TimeChannel.plot_refcorrected_color = 2
                widget_control,minfo.TimeChannel.colorbutton_ref[0],set_button = 1
                widget_control,minfo.TimeChannel.colorbutton_ref[1],set_button = 0
                widget_control,minfo.TimeChannel.colorbutton_ref[2],set_button = 0
                widget_control,minfo.TimeChannel.colorbutton_ref[3],set_button = 0
                widget_control,minfo.TimeChannel.colorbutton_ref[4],set_button = 0
            endif
            
            if(ii eq '2') then begin 
                minfo.TimeChannel.plot_refcorrected_color = 3
                widget_control,minfo.TimeChannel.colorbutton_ref[0],set_button = 0
                widget_control,minfo.TimeChannel.colorbutton_ref[1],set_button = 1
                widget_control,minfo.TimeChannel.colorbutton_ref[2],set_button = 0
                widget_control,minfo.TimeChannel.colorbutton_ref[3],set_button = 0
                widget_control,minfo.TimeChannel.colorbutton_ref[4],set_button = 0
            endif

            if(ii eq '3') then begin 
                minfo.TimeChannel.plot_refcorrected_color = 4
                widget_control,minfo.TimeChannel.colorbutton_ref[0],set_button = 0
                widget_control,minfo.TimeChannel.colorbutton_ref[1],set_button = 0
                widget_control,minfo.TimeChannel.colorbutton_ref[2],set_button = 1
                widget_control,minfo.TimeChannel.colorbutton_ref[3],set_button = 0
                widget_control,minfo.TimeChannel.colorbutton_ref[4],set_button = 0
            endif

            if(ii eq '4') then begin 
                minfo.TimeChannel.plot_refcorrected_color = 5
                widget_control,minfo.TimeChannel.colorbutton_ref[0],set_button = 0
                widget_control,minfo.TimeChannel.colorbutton_ref[1],set_button = 0
                widget_control,minfo.TimeChannel.colorbutton_ref[2],set_button = 0
                widget_control,minfo.TimeChannel.colorbutton_ref[3],set_button = 1
                widget_control,minfo.TimeChannel.colorbutton_ref[4],set_button = 0
            endif


            if(ii eq '5') then begin 
                minfo.TimeChannel.plot_refcorrected_color = 1
                widget_control,minfo.TimeChannel.colorbutton_ref[0],set_button = 0
                widget_control,minfo.TimeChannel.colorbutton_ref[1],set_button = 0
                widget_control,minfo.TimeChannel.colorbutton_ref[2],set_button = 0
                widget_control,minfo.TimeChannel.colorbutton_ref[3],set_button = 0
                widget_control,minfo.TimeChannel.colorbutton_ref[4],set_button = 1
            endif
            mql_update_TimeChannel,minfo
        endelse
    end



;_______________________________________________________________________
; Plot odd rows a difference color
;_______________________________________________________________________

    (strmid(event_name,0,3) EQ 'odd') : begin

        if(minfo.TimeChannel.single_channel eq 0) then begin 
            result = dialog_message(single_channel_message,/info)
            minfo.TimeChannel.plot_odd_diff = 0
            widget_control,minfo.TimeChannel.oddID[0],set_button = 0
            widget_control,minfo.TimeChannel.oddID[1],set_button = 1
        endif else begin 
            ii=  strmid(event_name,3,1)
            if(ii eq '1') then begin 
                minfo.TimeChannel.plot_odd_diff = 1
                widget_control,minfo.TimeChannel.oddID[0],set_button = 1
                widget_control,minfo.TimeChannel.oddID[1],set_button = 0
            endif
            
            if(ii eq '2') then begin 
                minfo.TimeChannel.plot_odd_diff = 0
                widget_control,minfo.TimeChannel.oddID[0],set_button = 0
                widget_control,minfo.TimeChannel.oddID[1],set_button = 1
            endif
            mql_update_TimeChannel,minfo    
        endelse
    end


;_______________________________________________________________________
; odd row color
;_______________________________________________________________________

    (strmid(event_name,0,6) EQ 'ocolor') : begin

        if(minfo.TimeChannel.single_channel eq 0) then begin 
            result = dialog_message(single_channel_message,/info)
            minfo.TimeChannel.plot_odd_diff = 0

        endif else begin 
            
            ii=  strmid(event_name,6,1)
            if(ii eq '1') then begin 
                minfo.TimeChannel.plot_odd_color = 2
                widget_control,minfo.TimeChannel.oddbutton[0],set_button = 1
                widget_control,minfo.TimeChannel.oddbutton[1],set_button = 0
                widget_control,minfo.TimeChannel.oddbutton[2],set_button = 0
                widget_control,minfo.TimeChannel.oddbutton[3],set_button = 0
                widget_control,minfo.TimeChannel.oddbutton[4],set_button = 0
            endif
            
            if(ii eq '2') then begin 
                minfo.TimeChannel.plot_odd_color = 3
                widget_control,minfo.TimeChannel.oddbutton[0],set_button = 0
                widget_control,minfo.TimeChannel.oddbutton[1],set_button = 1
                widget_control,minfo.TimeChannel.oddbutton[2],set_button = 0
                widget_control,minfo.TimeChannel.oddbutton[3],set_button = 0
                widget_control,minfo.TimeChannel.oddbutton[4],set_button = 0
            endif

            if(ii eq '3') then begin 
                minfo.TimeChannel.plot_odd_color = 4
                widget_control,minfo.TimeChannel.oddbutton[0],set_button = 0
                widget_control,minfo.TimeChannel.oddbutton[1],set_button = 0
                widget_control,minfo.TimeChannel.oddbutton[2],set_button = 1
                widget_control,minfo.TimeChannel.oddbutton[3],set_button = 0
                widget_control,minfo.TimeChannel.oddbutton[4],set_button = 0
            endif
            
            if(ii eq '4') then begin 
                minfo.TimeChannel.plot_odd_color = 5
                widget_control,minfo.TimeChannel.oddbutton[0],set_button = 0
                widget_control,minfo.TimeChannel.oddbutton[1],set_button = 0
                widget_control,minfo.TimeChannel.oddbutton[2],set_button = 0
                widget_control,minfo.TimeChannel.oddbutton[3],set_button = 1
                widget_control,minfo.TimeChannel.oddbutton[4],set_button = 0
            endif

            if(ii eq '5') then begin 
                minfo.TimeChannel.plot_odd_color = 1
                widget_control,minfo.TimeChannel.oddbutton[0],set_button = 0
                widget_control,minfo.TimeChannel.oddbutton[1],set_button = 0
                widget_control,minfo.TimeChannel.oddbutton[2],set_button = 0
                widget_control,minfo.TimeChannel.oddbutton[3],set_button = 0
                widget_control,minfo.TimeChannel.oddbutton[4],set_button = 1
            endif
            mql_update_TimeChannel,minfo   
        endelse 
    end

;_______________________________________________________________________
; Change the Integration # or Frame # of image displayed
;_______________________________________________________________________
    (strmid(event_name,0,6) EQ 'integr') : begin
;	print, ' integration ' , jintegration
	if (strmid(event_name,6,1) EQ 'e') then begin 
           this_value = event.value-1
           jintegration = this_value
;	print, ' integration ' , jintegration
	endif

; check if the <> buttons were used
       if (strmid(event_name,6,5) EQ '_move')then begin
          if(strmid(event_name,12,2) eq 'dn') then begin
             jintegration = jintegration -1
          endif
          if(strmid(event_name,12,2) eq 'up') then begin
             jintegration = jintegration+1
          endif
       endif

; do some checks 
       if(jintegration lt 0) then jintegration = minfo.data.nints-1
       if(jintegration gt minfo.data.nints-1  ) then  jintegration = 0



        setup_ChannelTime,minfo,jintegration,iramp	
        mql_update_TimeChannel,minfo
        widget_control,minfo.TimeChannel.integration_label,set_value= fix(jintegration+1)
        widget_control,minfo.TimeChannel.frame_label,set_value= fix(iramp+1)
    end

;_______________________________________________________________________
;  Frame Button
    (strmid(event_name,0,4) EQ 'fram') : begin

	if (strmid(event_name,4,1) EQ 'e') then begin 
           this_value = event.value-1
           iramp = this_value
       endif
; check if the <> buttons were used
        if (strmid(event_name,4,5) EQ '_move')then begin

            if(strmid(event_name,10,2) eq 'dn') then begin
              iramp = iramp -1
            endif
            if(strmid(event_name,10,2) eq 'up') then begin
              iramp = iramp +1
            endif
	endif
; do some checks	

        if(iramp lt 0) then iramp = minfo.data.nramps-1
        if(iramp gt minfo.data.nramps-1  ) then iramp = 0 

        setup_ChannelTime,minfo,jintegration,iramp	
        mql_update_TimeChannel,minfo
        widget_control,minfo.TimeChannel.integration_label,set_value= fix(jintegration+1)
        widget_control,minfo.TimeChannel.frame_label,set_value= fix(iramp+1)
    end	
;_______________________________________________________________________

;_______________________________________________________________________

endcase
cinfo.info = minfo
widget_control,event.top,set_uvalue = cinfo
widget_control,cinfo.info.Quicklook,set_uvalue = minfo
minfo.col_table = save_color
end

;***********************************************************************
;***********************************************************************
pro mql_display_TimeChannel,info

save_color = info.col_table
color6
window,1,/pixmap
wdelete,1
iramp = info.channelT[0].iramp
jintegration = info.channelT[0].jintegration

xplotsize = 750
yplotsize = 800

info.TimeChannel.plot_reference_corrected = 0

if(info.control.file_refcorrection_exist eq 1) then begin 
    info.TimeChannel.plot_reference_corrected = 1
    setup_ChannelTimeRefcorrected,info,info.image.integrationNO, info.image.rampNO
endif

stitle = "MIRI Quick Look- 5 Channel Plots of Data Values in readout order" + info.version
svalue = " 5 Channel Plots of Science Frame Image:   " + info.control.filename_raw


if( XRegistered ('mqlTC')) then begin
    widget_control,info.TimeChannelQuickLook,/destroy
endif

; widget window parameters
xwidget_size = 1400
ywidget_size = 1050

xsize_scroll = 1240
ysize_scroll = 900


if(info.control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.control.x_scroll_window
if(info.control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.control.y_scroll_window
if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10


TimeChannelQuickLook = widget_base(title=stitle ,$
                                   col = 1,mbar = menuBar,group_leader = info.QuickLook,$
                                   xsize =  xwidget_size,$
                                   ysize=   ywidget_size,/scroll,$
                                   x_scroll_size= xsize_scroll,$
                                   y_scroll_size = ysize_scroll,/TLB_SIZE_EVENTS,/align_right)


QuitMenu = widget_button(menuBar,value="Quit",font = info.font2)
; add quit button
quitbutton = widget_button(quitmenu,value="Quit",event_pro='mql_TimeChannel_quit')


statMenu = widget_button(menuBar,value="Statistics",font = info.font2)
statbutton = widget_button(statmenu,value="Get Statistics on Image ",uvalue='stat')

PrintMenu = widget_button(menuBar,value="Print",font = info.font2)
printbutton = widget_button(Printmenu,value="Print Time Ordered Plot ",uvalue='print')


tlabelID = widget_label(TimeChannelQuickLook,$
                        value =svalue ,/align_center,$
                        font=info.font5)





;_______________________________________________________________________
graphID_master0 = widget_base(TimeChannelQuickLook,row=1)
graphID_master1 = widget_base(TimeChannelQuickLook,row=1)


graphID11 = widget_base(graphID_master0,col=1)
InfoID11 = widget_base(graphID_master0,col=1)
graphID = lonarr(1)
;_______________________________________________________________________
;*****
;Plot values verse time
;*****

graphID[0] = widget_draw(graphID11,$
                         xsize = xplotsize,$
                         ysize=yplotsize,$
                         retain=info.retn)

;_______________________________________________________________________
integrationNO = info.image.integrationNO
frameNO = info.image.rampNO

move_base = widget_base(InfoID11,/row,/align_left)

integration_label = cw_field(move_base,$
                    title=" Integration # ",font=info.font5, $
                    uvalue="integration",/integer,/return_events, $
                    value=integrationNO+1,xsize=4,$
                    fieldfont=info.font3)

labelID = widget_button(move_base,uvalue='integr_move_dn',value='<',font=info.font3)
labelID = widget_button(move_base,uvalue='integr_move_up',value='>',font=info.font3)
;move_base = widgt_base(InfoID11,/row,/align_left)
frame_label = cw_field(move_base,$
              title=" Frame # ",font=info.font5, $
              uvalue="frame",/integer,/return_events, $
              value=frameNO+1,xsize=4,fieldfont=info.font3)
labelID = widget_button(move_base,uvalue='fram_move_dn',value='<',font=info.font3)
labelID = widget_button(move_base,uvalue='fram_move_up',value='>',font=info.font3)

default_range = intarr(2)
default_range[*] = 1

graph_range = fltarr(2,2)


graph_range[0,0] = 0
graph_range[0,1] = 269.0*1024.0
pad = 0.20*max(abs(info.channelT[*].max))

graph_range[1,0] = min(info.channelT[*].min) -pad
graph_range[1,1] = max(info.channelT[*].max ) +pad


rangeID = lonarr(2,2)
recomputeID = lonarr(2)


xrange = widget_label(InfoID11, value =' Change Plot range', /align_left,font=info.font5,/sunken_frame)
xlabel_base = widget_base(InfoID11,col=3,/align_left)

recomputeID[0] = widget_button(xlabel_base,value=' Plot Range',$font=info.font4,$
                                                uvalue = 'range1')
rangeID[0,0] = cw_field(Xlabel_base,$
                  title=" X Min ",font=info.font5, $
                  uvalue="cr1_b",/float,/return_events, $
                  value=graph_range[0,0],xsize=9,$
                  fieldfont=info.font3)

rangeID[0,1] = cw_field(Xlabel_base,$
                  title=" X Max ",font=info.font5, $
                  uvalue="cr1_t",/float,/return_events, $
                  value=graph_range[0,1],xsize=9,$
                  fieldfont=info.font3)


ylabel_base = widget_base(InfoID11,col=3,/align_left)

recomputeID[1] = widget_button(ylabel_base,value=' Plot Range',$font=info.font4,$
                                                uvalue = 'range2')
rangeID[1,0] = cw_field(ylabel_base,$
                  title=" Y Min ",font=info.font5, $
                  uvalue="cr2_b",/float,/return_events, $
                  value=graph_range[1,0],xsize=9,$
                  fieldfont=info.font3)

rangeID[1,1] = cw_field(ylabel_base,$
                  title=" Y Max ",font=info.font5, $
                  uvalue="cr2_t",/float,/return_events, $
                  value=graph_range[1,1],xsize=9,$
                  fieldfont=info.font3)




apply_bad = info.control.display_apply_bad
BadButton = lonarr(2)
if(apply_bad) then begin 
    apply_bad_pixel = intarr(2)
    apply_bad_pixel[0] = 1
    BadBase1 = Widget_base(infoID11,/row)
    blabel = widget_label (BadBase1, value = 'Apply Bad Pixel Mask: ',/align_left,font=info.font5)
    BadBase2 = Widget_base(BadBase1,/row,/nonexclusive)


    BadButton[0] = Widget_button(BadBase2, Value = 'YES',uvalue = 'bad1',font=info.font5)
    widget_control, BadButton[0],Set_Button =apply_bad_pixel[0] 


    BadButton[1] = Widget_Button(BadBase2, Value = ' NO ',uvalue = 'bad2',font=info.font5)
    widget_control, BadButton[1],Set_Button = apply_bad_pixel[1]
endif



;_______________________________________________________________________
Name = ["Channel 1" ,"Channel 2" ,"Channel 3" ,"Channel 4" ,"Channel 5" ]
imBases = lonarr(5)
onButton  = lonarr(5)
offButton = lonarr(5)
onvalue = intarr(5) 
offvalue = intarr(5)
onvalue(*) = 1

all_base = widget_base(InfoID11,col=3,/align_left)
amp = widget_label(all_base, value =' Select Channel to Plot', $
                      /align_left,font=info.font5,/sunken_frame)

allbutton = widget_button(all_base,Value = ' Select All',uvalue='allplot1')
widget_control,allbutton,Set_Button = 1
nonebutton = widget_button(all_base,Value = ' Select None',uvalue='allplot2')
widget_control,nonebutton,Set_Button = 0

boxID = lonarr(5)
for i = 0,4 do begin
    imBases[i] = Widget_Base(InfoID11,/row)

    iName = Widget_label(imbases[i],value = Name[i])
    onBase = Widget_base(imBases[i],/row,/nonexclusive)
    suvalue = strcompress('on'+ string(i+1),/remove_all)
    onButton[i] = Widget_button(onBase, Value = ' ON ',uvalue = suvalue)
    widget_control, onButton[i],Set_Button = onvalue[i]

    offBase = Widget_base(imBases[i],/row,/nonexclusive)
    suvalue = strcompress('off'+ string(i+1),/remove_all)
    offButton[i] = Widget_Button(offBase, Value = ' OFF ',uvalue = suvalue)
    widget_control, offButton[i],Set_Button = offvalue[i]

    boxID[i] = widget_draw(imBases[i],scr_xsize=50,scr_ysize=20, $
                               frame=1)
endfor




;_______________________________________________________________________

amp = widget_label(InfoID11,value = ' Single Channel Plotting Tools', /align_center,/sunken_frame,font = info.font5)


all_base = widget_base(infoID11,/row,/align_left)
ploteven = 1
plotodd = 1
base1 = Widget_Base(all_base,/row,/exclusive)
abutton = widget_button(base1,Value=' All rows',uvalue ='trowa')
widget_control,abutton,set_button = 1

base1 = Widget_Base(all_base,/row,/exclusive)
ebutton = widget_button(base1,Value=' Even Rows Only ',uvalue ='trowe')
widget_control,ebutton,set_button = 0

base1 = Widget_Base(all_base,/row,/exclusive)
obutton = widget_button(base1, Value=' Odd Rows Only ',uvalue ='trowo')
widget_control,obutton,set_button = 0

Base = Widget_base(InfoID11,/row)
rp = widget_label(Base, value = 'Plot odd rows Science Data in a different color',/align_left)
oBase = Widget_base(Base,/row,/nonexclusive)

plot_odd_diff = 0
plot_odd_color = 1
oddID = lonarr(2)
oddID[0] = Widget_button(oBase, Value = ' Yes ',uvalue = 'odd1')
widget_control,oddID[0],Set_Button = 0

oddID[1] = Widget_Button(oBase, Value = ' No ',uvalue = 'odd2')
widget_control,oddID[1],Set_Button = 1

boxIDodd = lonarr(5)
oddbutton = lonarr(5)
Base = Widget_base(InfoID11,/row)
oddlabel = widget_label(base,value = 'Odd Rows',/align_left)

oBase = Widget_base(Base,/row,/nonexclusive)
oddButton[0] = Widget_Button(obase, Value = ' ',uvalue = 'ocolor1')
widget_control, oddButton[0],Set_Button = 0
boxIDodd[0] = widget_draw(base,scr_xsize=30,scr_ysize=20, frame=1)

oBase = Widget_base(Base,/row,/nonexclusive)
oddButton[1] = Widget_Button(obase, Value = ' ',uvalue = 'ocolor2')
widget_control, oddButton[1],Set_Button = 0
boxIDodd[1] = widget_draw(base,scr_xsize=30,scr_ysize=20, frame=1)


oBase = Widget_base(Base,/row,/nonexclusive)
oddButton[2] = Widget_Button(obase, Value = ' ',uvalue = 'ocolor3')
widget_control, oddButton[2],Set_Button = 0
boxIDodd[2] = widget_draw(base,scr_xsize=30,scr_ysize=20, frame=1)

oBase = Widget_base(Base,/row,/nonexclusive)
boxIDodd[3] = widget_draw(base,scr_xsize=30,scr_ysize=20, frame=1)
oddButton[3] = Widget_Button(obase, Value = ' ',uvalue = 'ocolor4')
widget_control, oddButton[3],Set_Button = 0

oBase = Widget_base(Base,/row,/nonexclusive)
boxIDodd[4] = widget_draw(base,scr_xsize=30,scr_ysize=20, frame=1)
oddButton[4] = Widget_Button(obase, Value = ' ',uvalue = 'ocolor5')
widget_control, oddButton[4],Set_Button = 0


;-----------------------------------------------------------------------


Base = Widget_base(InfoID11,/row)
rp = widget_label(Base, value = 'Plot reference pixels',/align_left)
oBase = Widget_base(Base,/row,/nonexclusive)


plot_refpixels = 0
plot_refpixel_color = 1
refpixelID = lonarr(2)
refpixelID[0] = Widget_button(oBase, Value = ' Yes ',uvalue = 'rp1')
widget_control,refpixelID[0],Set_Button = 0

refpixelID[1] = Widget_Button(oBase, Value = ' No ',uvalue = 'rp2')
widget_control,refpixelID[1],Set_Button = 1

left = widget_label(base,value = 'Left')
leftbox = widget_draw(base,scr_xsize=20,scr_ysize=20, frame=1)
right = widget_label(base,value = 'Right')
rightbox = widget_draw(base,scr_xsize=20,scr_ysize=20, frame=1)



boxIDcolor = lonarr(5)
colorbutton = lonarr(5)
Base = Widget_base(InfoID11,/row)
colorlabel = widget_label(base,value = 'Ref Pixels',/align_left)

oBase = Widget_base(Base,/row,/nonexclusive)
colorButton[0] = Widget_Button(obase, Value = ' ',uvalue = 'color1')
widget_control, colorButton[0],Set_Button = 0
boxIDcolor[0] = widget_draw(base,scr_xsize=30,scr_ysize=20, frame=1)

oBase = Widget_base(Base,/row,/nonexclusive)
colorButton[1] = Widget_Button(obase, Value = ' ',uvalue = 'color2')
widget_control, colorButton[1],Set_Button = 0
boxIDcolor[1] = widget_draw(base,scr_xsize=30,scr_ysize=20, frame=1)

oBase = Widget_base(Base,/row,/nonexclusive)
colorButton[2] = Widget_Button(obase, Value = ' ',uvalue = 'color3')
widget_control, colorButton[2],Set_Button = 0
boxIDcolor[2] = widget_draw(base,scr_xsize=30,scr_ysize=20, frame=1)

oBase = Widget_base(Base,/row,/nonexclusive)
colorButton[3] = Widget_Button(obase, Value = ' ',uvalue = 'color4')
boxIDcolor[3] = widget_draw(base,scr_xsize=30,scr_ysize=20, frame=1)
widget_control, colorButton[3],Set_Button = 0

oBase = Widget_base(Base,/row,/nonexclusive)
colorButton[4] = Widget_Button(obase, Value = ' ',uvalue = 'color5')
boxIDcolor[4] = widget_draw(base,scr_xsize=30,scr_ysize=20, frame=1)
widget_control, colorButton[4],Set_Button = 0

;;;;
LeftPixelSet = 0


LeftDataID = lonarr(3)



plotright = 1
plotleft = 1
base = widget_base(infoID11,/row,/nonexclusive)
rightleftbutton = lonarr(3)

rightleftbutton[0] = Widget_button(Base, Value = 'Left and Right Ref Data',uvalue = 'lr1')	
widget_control, rightleftbutton[0],Set_Button = 1

rightleftbutton[1] = widget_button(base,Value=' Left Side Only',uvalue ='lr2')
widget_control,rightleftbutton[1],set_button = 0

rightleftbutton[2] = widget_button(base,Value=' Right Side Only',uvalue ='lr3')
widget_control,rightleftbutton[2],set_button = 0



;;;

plot_emp = 0
empID = lonarr(2)
Base = Widget_base(InfoID11,/row)
rp = widget_label(Base, value = 'Increase symbol size of ref pixels',/align_left)
oBase = Widget_base(Base,/row,/nonexclusive)
empID = lonarr(2)
empID[0] = Widget_button(oBase, Value = ' Yes ',uvalue = 'em1')
widget_control,empID[0],Set_Button = 0

empID[1] = Widget_Button(oBase, Value = ' No ',uvalue = 'em2')
widget_control,empID[1],Set_Button = 1


overplotRefCorrectedID = lonarr(2)
plot_refcorrected_color = 1
RboxIDcolor = lonarr(5)
Rcolorbutton = lonarr(5)

if(info.control.file_refcorrection_exist eq 1)then begin 
    Base = Widget_base(InfoID11,/row)
    overplot = widget_label(base,value = 'Over-plot Reference Corrected Data',/sunken_frame,$
                            font = info.font5,/align_left)

    oBase = Widget_base(base,/row,/nonexclusive)

    OverplotRefCorrectedID[0] = Widget_button(oBase, Value = ' Yes ',uvalue = 'overref1')
    widget_control,OverplotRefCorrectedID[0],Set_Button = 1

    OverplotRefCorrectedID[1] = Widget_Button(oBase, Value = ' No ',uvalue = 'overref2')
    widget_control,OverplotRefCorrectedID[1],Set_Button = 0

    Base = Widget_base(InfoID11,/row)
    colorlabel = widget_label(base,value = 'Ref Corrected',/align_left)
    
    oBase = Widget_base(Base,/row,/nonexclusive)
    RcolorButton[0] = Widget_Button(obase, Value = ' ',uvalue = 'Rcolor1')
    widget_control, RcolorButton[0],Set_Button = 0
    RboxIDcolor[0] = widget_draw(base,scr_xsize=30,scr_ysize=20, frame=1)

    oBase = Widget_base(Base,/row,/nonexclusive)
    RcolorButton[1] = Widget_Button(obase, Value = ' ',uvalue = 'Rcolor2')
    widget_control, RcolorButton[1],Set_Button = 0
    RboxIDcolor[1] = widget_draw(base,scr_xsize=30,scr_ysize=20, frame=1)


    oBase = Widget_base(Base,/row,/nonexclusive)
    RcolorButton[2] = Widget_Button(obase, Value = ' ',uvalue = 'Rcolor3')
    widget_control, RcolorButton[2],Set_Button = 0
    RboxIDcolor[2] = widget_draw(base,scr_xsize=30,scr_ysize=20, frame=1)

    oBase = Widget_base(Base,/row,/nonexclusive)
    RboxIDcolor[3] = widget_draw(base,scr_xsize=30,scr_ysize=20, frame=1)
    RcolorButton[3] = Widget_Button(obase, Value = ' ',uvalue = 'Rcolor4')
    widget_control, RcolorButton[3],Set_Button = 0

    oBase = Widget_base(Base,/row,/nonexclusive)
    RboxIDcolor[4] = widget_draw(base,scr_xsize=30,scr_ysize=20, frame=1)
    RcolorButton[4] = Widget_Button(obase, Value = ' ',uvalue = 'Rcolor5')
    widget_control, RcolorButton[4],Set_Button = 0

endif

info.TimeChannel.overplotRefcorrectedID = overplotRefCorrectedID


;_______________________________________________________________________



; initialize varibles 

;Set up the GUI
Widget_control,TimeChannelQuickLook,/Realize

XManager,'mqlTC',TimeChannelQuickLook,/No_Block,$
        event_handler='mql_TimeChannel_event'

draw_box_id = lonarr(5)
widget_control,graphID[0],get_value=tdraw_id
draw_window_id = tdraw_id
for i = 0,4 do begin
  widget_control,boxID[i],get_value=tdraw_id
  draw_box_id[i] = tdraw_id
endfor

draw_box_id_color = lonarr(5)
for i = 0,4 do begin
  widget_control,boxIDcolor[i],get_value=tdraw_id
  draw_box_id_color[i] = tdraw_id
endfor

draw_box_id_color_ref = lonarr(5)
if(info.control.file_refcorrection_exist eq 1)then begin 
    for i = 0,4 do begin
        widget_control,RboxIDcolor[i],get_value=tdraw_id
        draw_box_id_color_ref[i] = tdraw_id
    endfor
endif

draw_box_id_odd = lonarr(5)
for i = 0,4 do begin
  widget_control,boxIDodd[i],get_value=tdraw_id
  draw_box_id_odd[i] = tdraw_id
endfor


widget_control,leftbox, get_value= tdraw_id
left_box_id = tdraw_id

left_box_id2 = 0


widget_control,rightbox, get_value= tdraw_id
right_box_id = tdraw_id

longline = '                                                                                                                        '
longtag = widget_label(TimeChannelQuicklook,value = longline)
;_______________________________________________________________________

info.TimeChannel.integrationNO     = integrationNO
info.TimeChannel.frameNO           = frameNO
info.TimeChannel.integration_label = integration_label
info.TimeChannel.frame_label       = frame_label
info.TimeChannel.graphID           = graphID
info.TimeChannel.draw_window_id    = draw_window_id
info.TimeChannel.draw_box_id     = draw_box_id
info.TimeChannel.graph_range     = graph_range
info.TimeChannel.default_range   = default_range
info.TimeChannel.xplotsize       = xplotsize
info.TimeChannel.yplotsize       = yplotsize
info.TimeChannel.rangeID         = rangeID
info.TimeChannel.recomputeID     = recomputeID
info.TimeChannel.allbutton       = allbutton
info.TimeChannel.nonebutton       = nonebutton
info.TimeChannel.onbutton        = onbutton
info.TimeChannel.offbutton       = offbutton
info.TimeChannel.onvalue         = onvalue
info.TimeChannel.offvalue        = offvalue
info.TimeChannel.refpixelID      = refpixelID
info.TimeChannel.oddID           = oddID
info.TimeChannel.plot_odd_color           = plot_odd_color
info.TimeChannel.colorbutton     = colorbutton
info.TimeChannel.colorbutton_ref     = Rcolorbutton
info.TimeChannel.oddbutton       = oddbutton
info.TimeChannel.draw_box_id_color     = draw_box_id_color
info.TimeChannel.draw_box_id_color_ref     = draw_box_id_color_ref
info.TimeChannel.draw_box_id_odd     = draw_box_id_odd
info.TimeChannel.plot_refpixels     = plot_refpixels
info.TimeChannel.plot_odd_diff     = plot_odd_diff
info.TimeChannel.single_channel = 0
info.TimeChannel.plot_emp = plot_emp
info.TimeChannel.empID = empID
info.TimeCHannel.left_box_id = left_box_id
info.TimeCHannel.left_box_id2 = left_box_id2
info.TimeCHannel.right_box_id = right_box_id
info.TimeChannel.ploteven = ploteven
info.TimeChannel.plotodd = plotodd
info.TimeChannel.abutton = abutton
info.TimeChannel.ebutton = ebutton
info.TimeChannel.obutton = obutton
info.TimeChannel.apply_bad = apply_bad
info.TimeChannel.BadButton = BadButton
info.TimeChannel.plot_refpixel_color = plot_refpixel_color 
info.TimeChannel.plot_refcorrected_color = plot_refcorrected_color 
info.TimeChannel.LeftDataID = LeftDataID
info.TimeChannel.RightLeftButton = RightLeftButton
info.TimeChannel.LeftDataID = LeftDataID
info.TimeChannel.LeftPixelSet = LeftPixelSet
info.TimeChannel.plotright = plotright
info.TimeChannel.plotleft = plotleft

Widget_Control,info.QuickLook,Set_UValue=info
cinfo = { info            : info}



info.TimeChannelQuickLook = TimeChannelQuickLook
Widget_Control,info.TimeChannelQuickLook,Set_UValue=cinfo
mql_update_TimeChannel,info


Widget_Control,info.TimeChannelQuickLook,Set_UValue=cinfo
Widget_Control,info.QuickLook,Set_UValue=info

info.col_table = save_color
end
