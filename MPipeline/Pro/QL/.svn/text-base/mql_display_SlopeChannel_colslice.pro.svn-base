;_______________________________________________________________________
pro mql_SlopeChannel_colslice_quit,event

widget_control,event.top, Get_UValue = cinfo	
widget_control,cinfo.info.QuickLook,Get_Uvalue = info
widget_control,info.CSliceSlopeChannelQuickLook,/destroy



end
;_______________________________________________________________________
;***********************************************************************

; the event manager for the ql.pro (main base widget)
pro mql_SlopeChannel_colslice_event,event

Widget_Control,event.id,Get_uValue=event_name
widget_control,event.top, Get_UValue = cinfo
widget_control,cinfo.info.Quicklook,Get_Uvalue = minfo

cinfo.info = minfo
if (widget_info(event.id,/TLB_SIZE_EVENTS) eq 1 ) then begin
    minfo.channel_Scolslice.xwindowsize = event.x
    minfo.channel_Scolslice.ywindowsize = event.y
    minfo.channel_Scolslice.uwindowsize = 1
    widget_control,event.top,set_uvalue = cinfo
    widget_control,cinfo.info.Quicklook,set_uvalue = minfo
    mql_display_SlopeChannel_colslice,minfo
    return
endif

case 1 of

;_______________________________________________________________________
; Print to output file
;_______________________________________________________________________
    (strmid(event_name,0,6) EQ 'printP') : begin
        print_Channel_cslice,cinfo
        
    end    

    (strmid(event_name,0,6) EQ 'printD') : begin
        print_Channel_cslice_data,cinfo
        
    end    
;_______________________________________________________________________
; change x and y range of colslice graph 
;_______________________________________________________________________
    (strmid(event_name,0,1) EQ 'm') : begin
        graphno = fix(strmid(event_name,3,1))
        graphno = graphno - 1
        
        if(strmid(event_name,0,3) EQ 'mnx') then cinfo.colslice_xrange[graphno,0]  = event.value
        if(strmid(event_name,0,3) EQ 'mxx') then cinfo.colslice_xrange[graphno,1]  = event.value
        if(strmid(event_name,0,3) EQ 'mny') then cinfo.colslice_yrange[graphno,0]  = event.value
        if(strmid(event_name,0,3) EQ 'mxy') then cinfo.colslice_yrange[graphno,1]  = event.value

        if(strmid(event_name,2,1) EQ 'x') then begin
            cinfo.default_scale_colslice[graphno,0] = 0
            widget_control,cinfo.colslice_recomputeID[graphno,0],set_value=' Default '
        endif
        if(strmid(event_name,2,1) EQ 'y') then begin
            cinfo.default_scale_colslice[graphno,1] = 0
            widget_control,cinfo.colslice_recomputeID[graphno,1],set_value=' Default '
        endif


        mql_update_SlopeChannel_colslice,graphno,cinfo
        Widget_Control,event.top,Set_UValue=cinfo

    end
    
;_______________________________________________________________________
; set the Default range or user defined range for  colslicegram plot
    (strmid(event_name,0,1) EQ 'd') : begin
        graphno = fix(strmid(event_name,2,1))
        graphno = graphno -1

        if(strmid(event_name,1,1) EQ 'x') then begin
            if(cinfo.default_scale_colslice[graphno,0] eq 0 ) then begin 
                widget_control,cinfo.colslice_recomputeID[graphno,0],set_value=' Plot Range '
                cinfo.default_scale_colslice[graphno,0] = 1
            endif
        endif

        if(strmid(event_name,1,1) EQ 'y') then begin
            if(cinfo.default_scale_colslice[graphno,1] eq 0 ) then begin 
                widget_control,cinfo.colslice_recomputeID[graphno,1],set_value=' Plot Range '
                cinfo.default_scale_colslice[graphno,1] = 1
            endif
        endif

        mql_update_SlopeChannel_colslice,graphno,cinfo
        Widget_Control,event.top,Set_UValue=cinfo
    end

;_______________________________________________________________________
; show line column
;_______________________________________________________________________
    (strmid(event_name,0,3) EQ 'slc') : begin

        plot_col1 = 0 & plot_col2 = 0
        if(cinfo.showline eq 1  ) then begin ; true - turn to false
            widget_control,cinfo.showline_label,set_value='No Line'
            cinfo.showline = 0
        endif else begin        ;false then turn true
            widget_control,cinfo.showline_label,set_value='Show Line'
            cinfo.showline = 1
            plot_col1 = cinfo.colnum_start -minfo.slopechannel.xstart_zoom  
            plot_col2 = cinfo.colnum_end - minfo.slopechannel.xstart_zoom
            plot_col1 = plot_col1* minfo.slopechannel.zoom
            plot_col2 = plot_col2* minfo.slopechannel.zoom
        endelse
            mql_draw_SlopeChannel_colslice,cinfo.showline,plot_col1,plot_col2,minfo
        Widget_Control,event.top,Set_UValue=cinfo
    end


;______________________________________________________________________
; Select a different column to plot a slice through
;_______________________________________________________________________
    (strmid(event_name,0,3) EQ 'col') : begin

        minvalue = minfo.slopechannel.xstart_zoom+1
        maxvalue = minfo.slopechannel.xend_zoom+1
;________________
        if(strmid(event_name,4,4) eq 'vals') then begin
            value = float(event.value) 
            cinfo.colnum_start = value
            if(value lt minvalue) then cinfo.colnum_start = minvalue
            if(value gt maxvalue) then cinfo.colnum_start = maxvalue

            cinfo.colnum_end = cinfo.colnum_start + cinfo.colnum -1 

        endif

;________________
        if(strmid(event_name,4,4) eq 'valn') then begin
            value = float(event.value) 
            cinfo.colnum = value
            if(value le 0) then begin
    		result = dialog_message("Enter a value equal to or greater than 1",/error )		
                cinfo.colnum = 1
            endif
            value  = cinfo.colnum_start + cinfo.colnum -1
            cinfo.colnum_end = value
            cinfo.colnum = cinfo.colnum_end - cinfo.colnum_start  + 1


            if(value gt maxvalue) then begin
                cinfo.colnum_end = maxvalue
                cinfo.colnum = cinfo.colnum_end - cinfo.colnum_start  + 1
            endif
        endif

;________________
; check if the <> buttons were used

        if(strmid(event_name,4,4) eq 'move') then begin
            step = 1.0
            if(strmid(event_name,9,2) eq 'x1') then begin
                cinfo.colnum_start = cinfo.colnum_start - step
                cinfo.colnum_end = cinfo.colnum_end - step                
            endif
            if(strmid(event_name,9,2) eq 'x2') then begin
                cinfo.colnum_start = cinfo.colnum_start + step
                cinfo.colnum_end = cinfo.colnum_end + step
            endif
        endif
        
;__________________________________________________________________________

        if(cinfo.colnum_end lt cinfo.colnum_start) then begin
            ms = 'The End Column is less than the Start Column,'+ $
                 ' setting them equal'
            result = dialog_message(ms,/error ) 
            cinfo.colnum_end =  cinfo.colnum_start
        endif

        if(cinfo.colnum_start lt minvalue) then cinfo.colnum_start= minvalue
        if(cinfo.colnum_start gt maxvalue) then cinfo.colnum_start =maxvalue

        if(cinfo.colnum_end lt minvalue) then cinfo.colnum_end= minvalue
        if(cinfo.colnum_end gt maxvalue) then cinfo.colnum_end =maxvalue
;__________________________________________________________________________
        cinfo.colnum = cinfo.colnum_end - cinfo.colnum_start + 1
        widget_control,cinfo.start_col_label,set_value=cinfo.colnum_start
        widget_control,cinfo.num_col_label,set_value=cinfo.colnum
        
        for i = 0,4 do begin
            mql_update_SlopeChannel_colslice,i,cinfo
        endfor

        if(cinfo.showline eq 1) then begin
            plot_col1 = cinfo.colnum_start -minfo.slopechannel.xstart_zoom  
            plot_col2 = cinfo.colnum_end -  minfo.slopechannel.xstart_zoom
            plot_col1 = plot_col1* minfo.slopechannel.zoom
            plot_col2 = plot_col2* minfo.slopechannel.zoom

            mql_draw_SlopeChannel_colslice,cinfo.showline,plot_col1,plot_col2,minfo
        endif
        Widget_Control,event.top,Set_UValue=cinfo
        Widget_Control,cinfo.info.QuickLook,Set_UValue=info

    end



else: print," Event name not found",event_name
endcase

cinfo.info = minfo
widget_control,event.top,set_uvalue = cinfo
widget_control,cinfo.info.Quicklook,set_uvalue = minfo

end


;***********************************************************************
pro mql_draw_SlopeChannel_colslice,showline,value1,value2,info

for i = 0, 4 do begin 


    wset,info.SlopeChannel.draw_window_id[i]
    device,copy=[0,0,info.data.image_xsize/4,info.data.image_ysize, $
                 0,0,info.SlopeChannel.pixmapID[i]]
;    print,value1,value2

    if(showline eq 1) then begin
        save_color = info.col_table
        color6
        n_reads = info.slopechannel.yplotsize

        yvalues = indgen(n_reads) + 1 
        xvalues  = fltarr(n_reads) +value1
        xvalues2  = fltarr(n_reads) +value2
        plots,xvalues,yvalues,/device,color=info.white,linestyle=2
        plots,xvalues2,yvalues,/device,color=info.white,linestyle=2
        info.col_table = save_color
    endif
    
endfor
end

;***********************************************************************
pro mql_update_SlopeChannel_colslice,graphno,cinfo,ps=ps,eps=eps,ascii=ascii,unit=iunit
;***********************************************************************
hcopy = 0
if ( (keyword_set(ps)) or ( keyword_set(eps)) ) then hcopy = 1

info = cinfo.info


x1 = cinfo.colnum_start -info.slopechannel.xstart_zoom -1 
x2 = cinfo.colnum_end - info.slopechannel.xstart_zoom -1


coldataT = (*info.ChannelS[graphno].psubdata)[x1:x2,*]


s = size(coldataT)
width = s[1]
num = s[2]


coldata = fltarr(num)

for i = 0,num -1 do begin
    coldata[i] = total(coldataT[*,i])/width
endfor


if(hcopy ne 1) then wset,cinfo.draw_window_id[graphno]     


n_reads = n_elements(coldata)
xvalues = indgen(n_reads) + 1 + cinfo.info.slopechannel.ystart_zoom

minvalue = cinfo.info.slopechannel.ystart_zoom
maxvalue = cinfo.info.slopechannel.yend_zoom
pad = 0.002
xpad = pad*minvalue

;print,'min and max value',minvalue,maxvalue

if(xpad le 0 ) then xpad = 1

; get min and max of signal
get_image_stat,coldata,mean_image,std_pixel,minsignal,maxsignal,$
               min_image,max_image,median_image,stdev_mean,skew,ngood,nbad



; check if default scale is true - then reset to orginal value
if(cinfo.default_scale_colslice[graphno,0] eq 1) then begin
    cinfo.colslice_xrange[graphno,0] = minvalue-xpad
    cinfo.colslice_xrange[graphno,1] = maxvalue+xpad
    if(cinfo.colslice_xrange[graphno,0]  lt minvalue) then cinfo.colslice_xrange[graphno,0] = minvalue
    if(cinfo.colslice_xrange[graphno,1] gt maxvalue) then cinfo.colslice_xrange[graphno,1] = maxvalue
endif 
  

if(cinfo.default_scale_colslice[graphno,1] eq 1) then begin
    if( finite(min_image) eq 0 ) then min_image  = 0
    if( finite(max_image) eq 0 ) then max_image  = 0
    cinfo.colslice_yrange[graphno,0] =min_image
    cinfo.colslice_yrange[graphno,1] = max_image
endif
;print,cinfo.colslice_xrange[graphno,0],cinfo.colslice_xrange[graphno,1]

xx1 = cinfo.colslice_xrange[graphno,0]
xx2 = cinfo.colslice_xrange[graphno,1]
yy1 = cinfo.colslice_yrange[graphno,0]
yy2 = cinfo.colslice_yrange[graphno,1]
stitle = ' ' 

if(hcopy eq 1) then begin
    stitle = ' Reduced Image Row Slice for Channel ' + strcompress(string(graphno+1),/remove_all)
endif
    stitle = ' Reduced Image Row Slice for Channel ' + strcompress(string(graphno+1),/remove_all)


plot,xvalues,coldata,xtitle = "ROW  #", ytitle='DN/s',$
  xrange=[xx1,xx2],yrange=[yy1,yy2],xstyle =1,ystyle=1,title = stitle,subtitle = sstitle


widget_control,cinfo.colslice_xlabel[graphno,0],set_value=cinfo.colslice_xrange[graphno,0]
widget_control,cinfo.colslice_xlabel[graphno,1],set_value=cinfo.colslice_xrange[graphno,1]
widget_control,cinfo.colslice_ylabel[graphno,0],set_value=cinfo.colslice_yrange[graphno,0]
widget_control,cinfo.colslice_ylabel[graphno,1],set_value=cinfo.colslice_yrange[graphno,1]

smean = strcompress(string(mean_image,format="(f10.2)"),/remove_all)
sst = strcompress(string(std_pixel,format="(f12.4)"),/remove_all)
smed = strcompress(string(median_image,format="(f12.2)"),/remove_all)
smin = strcompress(string(minsignal,format="(f12.2)"),/remove_all)
smax= strcompress(string(maxsignal,format="(f12.2)"),/remove_all)
sngood = strcompress(string(ngood,format="(i8)"),/remove_all)
snbad= strcompress(string(nbad,format="(i8)"),/remove_all)

widget_control,cinfo.mean_labelID[graphno],set_value = smean
widget_control,cinfo.std_labelID[graphno],set_value = sst
widget_control,cinfo.med_labelID[graphno],set_value = smed
widget_control,cinfo.min_labelID[graphno],set_value = smin
widget_control,cinfo.max_labelID[graphno],set_value = smax
widget_control,cinfo.ngood_labelID[graphno],set_value = sngood
widget_control,cinfo.nbad_labelID[graphno],set_value = snbad

if(keyword_set(ascii)) then begin 
    if(N_elements(iunit)) then begin
        printf,iunit,'# Comment: Start Column, End Column'
        printf,iunit,'# Comment: Row #, Value'
        printf,iunit,x1+1,x2+1
        for i = 0, n_elements(coldata)-1 do begin
            printf,iunit,i+1,coldata[i]
        endfor

    endif
endif


    
xvalues = 0
coldata = 0
coldataT = 0

end


;***********************************************************************

;***********************************************************************
pro mql_display_SlopeChannel_colslice,info

window,1,/pixmap
wdelete,1
if( XRegistered ('Ccslice')) then begin
    widget_control,info.CSliceSlopeChannelQuickLook,/destroy
endif

jintegration = info.ChannelS[0].jintegration

ftitle = "Integration #: " + strtrim(string(fix(jintegration+1)),2) 

sxmin = strcompress(string(info.slopechannel.xstart_zoom+1),/remove_all)
sxmax = strcompress(string(info.slopechannel.xend_zoom+1),/remove_all)
symin = strcompress(string(info.slopechannel.ystart_zoom+1),/remove_all)
symax = strcompress(string(info.slopechannel.yend_zoom+1),/remove_all)
sregion = "Available Region to Plot : xrange: " + sxmin + " - " + sxmax + " yrange: " + $
	symin + "  - " + symax 

stitle = "MIRI Quick Look- 5 Channel Column Slice Plots for Reduced Image" + info.version
svalue = " 5 Channel Column Slice Plots for Reduced Image:  "

; widget window parameters
xwidget_size = 1300
ywidget_size = 900
xsize_scroll = 1160
ysize_scroll = 875

if(info.channel_Scolslice.uwindowsize eq 1) then begin ; user has set window size 
    xsize_scroll = info.channel_Scolslice.xwindowsize
    ysize_scroll = info.channel_Scolslice.ywindowsize
endif
if(info.control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.control.x_scroll_window
if(info.control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.control.y_scroll_window
if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10


CSliceChannelQuickLook = widget_base(title=stitle ,$
                                     col = 1,mbar = menuBar,$
                                     group_leader = info.SlopeChannelQuickLook,$
                                     xsize = xwidget_size,$
                                     ysize = ywidget_size,/scroll,$
                                     x_scroll_size= xsize_scroll,$
                                     y_scroll_size = ysize_scroll,/TLB_SIZE_EVENTS)


QuitMenu = widget_button(menuBar,value="Quit",font = info.font2)
; add quit button
quitbutton = widget_button(quitmenu,value="Quit",event_pro='mql_SlopeChannel_colslice_quit')

PMenu = widget_button(menuBar,value="Print",font = info.font2)
PbuttonR = widget_button(Pmenu,value = "Print plots to an output file ",uvalue='printP')
PbuttonD = widget_button(Pmenu,value = "Print Data to ascii file ",uvalue='printD')


title_base = widget_base(CSliceChannelQuickLook,col=3,/align_left)
tlabelID = widget_label(title_base,value =svalue,font=info.font5)
titlelabel = widget_label(title_base,value = info.control.filename_raw, font=info.font3)


blankspaces  = '                '
move_base = widget_base(CSliceChannelQuickLook,col=5,/align_left)
blanklabel = widget_label(move_base, value= blankspaces)
framelabel = widget_label(move_base, value=ftitle, font=info.font3)
blanklabel = widget_label(move_base, value= blankspaces)
rlabel = widget_label(move_base, value=sregion, font=info.font3)


colnum = info.SlopeChannel.xposfull

colnum_start = colnum+1
colnum_end = colnum+1
colnum = 1
pix_num_base = widget_base(CSliceChannelQuickLook,row=1,/align_left)

labelID = widget_button(pix_num_base,uvalue='col_move_x1',value='<',font=info.font3)
labelID = widget_button(pix_num_base,uvalue='col_move_x2',value='>',font=info.font3)

xsize_label = 6    
start_col_label = cw_field(pix_num_base,title=' Start Column',xsize=5,$
                                         value=colnum_start,font=info.font4,$
                                         uvalue='col_vals',/return_events)

num_col_label = cw_field(pix_num_base,title='Number of Columns',xsize=5,$
                                         value=colnum,font=info.font4,$
                                         uvalue='col_valn',/return_events)

showline = 0
showline_label = widget_button(pix_num_base,value=' No Line ',font=info.font3,$
                                     uvalue = 'slc')





;_______________________________________________________________________
graphID_master0 = widget_base(CSliceChannelQuickLook,row=1)
graphID_master1 = widget_base(CSliceChannelQuickLook,row=1)


graphID11 = widget_base(graphID_master0,col=1)
graphID12 = widget_base(graphID_master0,col=1)
graphID13 = widget_base(graphID_master0,col=1)

graphID21 = widget_base(graphID_master1,col=1)
graphID22 = widget_base(graphID_master1,col=1)
graphID23 = widget_base(graphID_master1,col=1)

graphID = lonarr(5)
draw_window_id = lonarr(5)
;_______________________________________________________________________
; initialize varibles 

colslice_xlabel        = lonarr(5,2) ; plot label 
colslice_ylabel        = lonarr(5,2) ; plot label 
colslice_xrange        = lonarr(5,2) ; x  plot range
colslice_yrange        = lonarr(5,2) ; x  plot range
colslice_recomputeID    = lonarr(5,2); button controlling Default scale or User Set Scale
default_scale_colslice  = intarr(5,2) ; scaling min and max display ranges 

colslice_xrange[*,*] = 0
colslice_yrange[*,*] = 0
default_scale_colslice[*,*] = 1


;_______________________________________________________________________
xsize_label = 8    

;*****
;graph 1 Column Slice for  Channel 1 
;*****


titleID = widget_label(graphID11, value = " Reduced Image Column Slice: Channel 1 ",$
                       /align_center,font=info.font3)


graphID[0] = widget_draw(graphID11,$
                         xsize = info.plotsize1*1.2,$
                         ysize=info.plotsize1,$
                         retain=info.retn)


pix_num_base2 = widget_base(graphID11,row=1)
labelID = widget_label(pix_num_base2,value="X->",font=info.font4)
colslice_xlabel[0,0] = cw_field(pix_num_base2,title="min:",font=info.font4, $
                                        uvalue="mnx1",/float,/return_events, $
                                        value=colslice_xrange[0,0], $
                                        xsize=xsize_label,fieldfont=info.font4)

colslice_xlabel[0,1] = cw_field(pix_num_base2,title="max:",font=info.font4, $
                                        uvalue="mxx1",/float,/return_events, $
                                        value=colslice_xrange[0,1],xsize=xsize_label,$
                                        fieldfont=info.font4)

colslice_recomputeID[0,0] = widget_button(pix_num_base2,value='Plot Range',$
                                          font=info.font4,uvalue = 'dx1')

pix_num_base3 = widget_base(graphID11,row=1)

labelID = widget_label(pix_num_base3,value="Y->",font=info.font4)
colslice_ylabel[0,0] = cw_field(pix_num_base3,title="min:",font=info.font4, $
                                        uvalue="mny1",/float,/return_events, $
                                        value=colslice_yrange[0,0],xsize=xsize_label,$
                                        fieldfont=info.font4)

colslice_ylabel[0,1] = cw_field(pix_num_base3,title="max:",font=info.font4, $
                                        uvalue="mxy1",/float,/return_events, $
                                        value=colslice_yrange[0,1],xsize=xsize_label,$
                                        fieldfont=info.font4)

colslice_recomputeID[0,1] = widget_button(pix_num_base3,value='Plot Range',$
                                          font=info.font4,uvalue = 'dy1')

;_______________________________________________________________________
;*****

;graph 2 Column Slice for  Channel 1 
;*****


titleID = widget_label(graphID12, value = " Reduced Image Column Slice: Channel 2 ",$
                       /align_center,font=info.font3)


graphID[1] = widget_draw(graphID12,$
                         xsize = info.plotsize1*1.2,$
                         ysize=info.plotsize1,$
                         retain=info.retn)


pix_num_base2 = widget_base(graphID12,row=1)
labelID = widget_label(pix_num_base2,value="X->",font=info.font4)
colslice_xlabel[1,0] = cw_field(pix_num_base2,title="min:",font=info.font4, $
                                        uvalue="mnx2",/float,/return_events, $
                                        value=colslice_xrange[1,0], $
                                        xsize=xsize_label,fieldfont=info.font4)

colslice_xlabel[1,1] = cw_field(pix_num_base2,title="max:",font=info.font4, $
                                        uvalue="mxx2",/float,/return_events, $
                                        value=colslice_xrange[1,1],xsize=xsize_label,$
                                        fieldfont=info.font4)

colslice_recomputeID[1,0] = widget_button(pix_num_base2,value='Plot Range',$
                                          font=info.font4,uvalue = 'dx2')

pix_num_base3 = widget_base(graphID12,row=1)

labelID = widget_label(pix_num_base3,value="Y->",font=info.font4)
colslice_ylabel[1,0] = cw_field(pix_num_base3,title="min:",font=info.font4, $
                                        uvalue="mny2",/float,/return_events, $
                                        value=colslice_yrange[1,0],xsize=xsize_label,$
                                        fieldfont=info.font4)

colslice_ylabel[1,1] = cw_field(pix_num_base3,title="max:",font=info.font4, $
                                        uvalue="mxy2",/float,/return_events, $
                                        value=colslice_yrange[1,1],xsize=xsize_label,$
                                        fieldfont=info.font4)

colslice_recomputeID[1,1] = widget_button(pix_num_base3,value='Plot Range',$
                                          font=info.font4,uvalue = 'dy2')

;_______________________________________________________________________
;*****
;graph3 Column Slice  of Channel 3 
;*****
titleID = widget_label(graphID13, value = " Reduced Image Column Slice: Channel 3 ",$
                       /align_center,font=info.font3)

graphID[2] = widget_draw(graphID13,$
                         xsize = info.plotsize1*1.2,$
                         ysize=info.plotsize1,$
                         retain=info.retn)


pix_num_base2 = widget_base(graphID13,row=1)
labelID = widget_label(pix_num_base2,value="X->",font=info.font4)
colslice_xlabel[2,0] = cw_field(pix_num_base2,title="min:",font=info.font4, $
                                        uvalue="mnx3",/float,/return_events, $
                                        value=colslice_xrange[2,0], $
                                        xsize=xsize_label,fieldfont=info.font4)

colslice_xlabel[2,1] = cw_field(pix_num_base2,title="max:",font=info.font4, $
                                        uvalue="mxx3",/float,/return_events, $
                                        value=colslice_xrange[2,1],xsize=xsize_label,$
                                        fieldfont=info.font4)

colslice_recomputeID[2,0] = widget_button(pix_num_base2,value='Plot Range',$
                                               font=info.font4,uvalue = 'dx3')

pix_num_base3 = widget_base(graphID13,row=1)

labelID = widget_label(pix_num_base3,value="Y->",font=info.font4)
colslice_ylabel[2,0] = cw_field(pix_num_base3,title="min:",font=info.font4, $
                                        uvalue="mny3",/float,/return_events, $
                                        value=colslice_yrange[2,0],xsize=xsize_label,$
                                        fieldfont=info.font4)

colslice_ylabel[2,1] = cw_field(pix_num_base3,title="max:",font=info.font4, $
                                        uvalue="mxy3",/float,/return_events, $
                                        value=colslice_yrange[2,1],xsize=xsize_label,$
                                        fieldfont=info.font4)

colslice_recomputeID[2,1] = widget_button(pix_num_base3,value='Plot Range',$
                                          font=info.font4,uvalue = 'dy3')

;_______________________________________________________________________
;*****
;graph3 Column Slice  of Channel 3 
;*****
titleID = widget_label(graphID21, value = " Reduced Image Column Slice: Channel 4 ",$
                       /align_center,font=info.font3)

graphID[3] = widget_draw(graphID21,$
                         xsize = info.plotsize1*1.2,$
                         ysize = info.plotsize1,$
                         retain=info.retn)


pix_num_base2 = widget_base(graphID21,row=1)
labelID = widget_label(pix_num_base2,value="X->",font=info.font4)
colslice_xlabel[3,0] = cw_field(pix_num_base2,title="min:",font=info.font4, $
                                        uvalue="mnx4",/float,/return_events, $
                                        value=colslice_xrange[3,0], $
                                        xsize=xsize_label,fieldfont=info.font4)

colslice_xlabel[3,1] = cw_field(pix_num_base2,title="max:",font=info.font4, $
                                        uvalue="mxx4",/float,/return_events, $
                                        value=colslice_xrange[3,1],xsize=xsize_label,$
                                        fieldfont=info.font4)

colslice_recomputeID[3,0] = widget_button(pix_num_base2,value='Plot Range',$
                                          font=info.font4,uvalue = 'dx4')

pix_num_base3 = widget_base(graphID21,row=1)

labelID = widget_label(pix_num_base3,value="Y->",font=info.font4)
colslice_ylabel[3,0] = cw_field(pix_num_base3,title="min:",font=info.font4, $
                                        uvalue="mny4",/float,/return_events, $
                                        value=colslice_yrange[3,0],xsize=xsize_label,$
                                        fieldfont=info.font4)

colslice_ylabel[3,1] = cw_field(pix_num_base3,title="max:",font=info.font4, $
                                        uvalue="mxy4",/float,/return_events, $
                                        value=colslice_yrange[3,1],xsize=xsize_label,$
                                        fieldfont=info.font4)

colslice_recomputeID[3,1] = widget_button(pix_num_base3,value='Plot Range',$
                                          font=info.font4,uvalue = 'dy4')
;_______________________________________________________________________
;*****
;graph 5 Column Slice  of Channel 5 
;*****
titleID = widget_label(graphID22, value = " Reduced Image Column Slice: Channel 5 ",$
                       /align_center,font=info.font3)

graphID[4] = widget_draw(graphID22,$
                         xsize = info.plotsize1*1.2,$
                         ysize = info.plotsize1,$
                         retain=info.retn)


pix_num_base2 = widget_base(graphID22,row=1)
labelID = widget_label(pix_num_base2,value="X->",font=info.font4)
colslice_xlabel[4,0] = cw_field(pix_num_base2,title="min:",font=info.font4, $
                                        uvalue="mnx5",/float,/return_events, $
                                        value=colslice_xrange[4,0], $
                                        xsize=xsize_label,fieldfont=info.font4)

colslice_xlabel[4,1] = cw_field(pix_num_base2,title="max:",font=info.font4, $
                                        uvalue="mxx5",/float,/return_events, $
                                        value=colslice_xrange[4,1],xsize=xsize_label,$
                                        fieldfont=info.font4)

colslice_recomputeID[4,0] = widget_button(pix_num_base2,value='Plot Range',$
                                          font=info.font4,$
                                          uvalue = 'dx5')

pix_num_base3 = widget_base(graphID22,row=1)

labelID = widget_label(pix_num_base3,value="Y->",font=info.font4)
colslice_ylabel[4,0] = cw_field(pix_num_base3,title="min:",font=info.font4, $
                                        uvalue="mny5",/float,/return_events, $
                                        value=colslice_yrange[1,0],xsize=xsize_label,$
                                        fieldfont=info.font4)

colslice_ylabel[4,1] = cw_field(pix_num_base3,title="max:",font=info.font4, $
                                        uvalue="mxy5",/float,/return_events, $
                                        value=colslice_yrange[1,1],xsize=xsize_label,$
                                        fieldfont=info.font4)

colslice_recomputeID[4,1] = widget_button(pix_num_base3,value='Plot Range',$
                                          font=info.font4,$
                                          uvalue = 'dy5')

;_______________________________________________________________________
Channel = [' 1    ', ' 2    ', ' 3    ', ' 4    ', ' 5    ' ]

blank_a = '          '

ValueTemp =  [blank_a,blank_a,blank_a,blank_a,blank_a]


imBases = lonarr(5)
slabel = widget_label(graphID23,value = 'Statistical Information on Slices',font = info.font3)
descrip = Widget_Base(graphID23,/row)
des1 = widget_label(descrip, value = "Channel   Mean   Standard Dev     Median   Minimum " + $
                    "   Maximum    NGood       NBad" ,/align_left)	


imean = lonarr(5) & istd = lonarr(5) & imed = lonarr(5) & ingood =lonarr(5) & inbad = lonarr(5)
imin  = lonarr(5) & imax = lonarr(5)



for i = 0,4 do begin
    imBases[i] = Widget_Base(graphID23,/row)

    iName = Widget_label(imbases[i],value = channel[i])
    imean[i] = Widget_label(imbases[i],value = valuetemp[i])
    istd[i] = Widget_label(imbases[i],value = valuetemp[i])
    imed[i] = Widget_label(imbases[i],value = valuetemp[i])
    imin[i] = Widget_label(imbases[i],value = valuetemp[i])
    imax[i] = Widget_label(imbases[i],value = valuetemp[i])
    ingood[i] = Widget_label(imbases[i],value = valuetemp[i])
    inbad[i] = Widget_label(imbases[i],value = valuetemp[i])

endfor




;Set up the GUI
Widget_control,CSliceChannelQuickLook,/Realize

XManager,'Ccslice',CSliceChannelQuickLook,/No_Block,$
        event_handler='mql_SlopeChannel_colslice_event'
;_______________________________________________________________________
for i = 0, 4 do begin
    widget_control,graphID[i],get_value=tdraw_id
    draw_window_id[i] = tdraw_id
endfor


ij = 'int' + string(fix(jintegration+1))
ij = strcompress(ij,/remove_all)

outname = info.output.Channelcsliceslope  + ij + '_'
type = 2

Widget_Control,info.QuickLook,Set_UValue=info
cinfo = {info                   : info,$
         colnum_start           : colnum_start,$
         colnum_end             : colnum_end,$
         colnum                : colnum ,$
         start_col_label        : start_col_label,$
         num_col_label          : num_col_label,$
         showline               : showline,$
         showline_label         : showline_label,$
         colslice_recomputeID   : colslice_recomputeID,$
         colslice_xlabel        : colslice_xlabel,$
         colslice_ylabel        : colslice_ylabel,$
         colslice_xrange        : colslice_xrange,$
         colslice_yrange        : colslice_yrange,$
         graphID                : graphID,$
         mean_labelID           : imean,$
         min_labelID            : imin,$
         max_labelID            : imax,$
         std_labelID            : istd,$
         med_labelID            : imed,$
         ngood_labelID          : ingood,$
         nbad_labelID           : inbad,$
         draw_window_id         : draw_window_id,$
         outname                : outname,$
         type                   : type,$
         default_scale_colslice : default_scale_colslice}



info.CSliceSlopeChannelQuickLook = CSliceChannelQuickLook
Widget_Control,info.CSliceSlopeChannelQuickLook,Set_UValue=cinfo
Widget_Control,info.QuickLook,Set_UValue=info
for i = 0,4 do begin
    graphno = i
    mql_update_SlopeChannel_colslice,graphno,cinfo
endfor
Widget_Control,info.CSliceSlopeChannelQuickLook,Set_UValue=cinfo





Widget_Control,info.QuickLook,Set_UValue=info

end
