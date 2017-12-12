; Display the Two point difference values of the pixels (between frames)

;_______________________________________________________________________
;***********************************************************************
pro mpl_2pt_diff_quit,event
;_______________________________________________________________________

widget_control,event.top, Get_UValue = cinfo	
widget_control,cinfo.info.QuickLook,Get_Uvalue = info

widget_control,info.twoptdiff,/destroy


end
;_______________________________________________________________________
;***********************************************************************


;_______________________________________________________________________
;***********************************************************************
pro mpl_2pt_diff_event,event
;_______________________________________________________________________
; the event manager for the mpl_display.pro (first look base widget)

Widget_Control,event.id,Get_uValue=event_name
widget_control,event.top, Get_UValue = cinfo
widget_control,cinfo.info.Quicklook,Get_Uvalue = minfo

; if the user has changed the size of the widget window - resize
if (widget_info(event.id,/TLB_SIZE_EVENTS) eq 1) then begin
    minfo.pl2.xwindowsize = event.x
    minfo.pl2.ywindowsize = event.y
    minfo.pl2.uwindowsize = 1
    widget_control,event.top,set_uvalue = cinfo
    widget_control,cinfo.info.Quicklook,set_uvalue = minfo
    mpl_2pt_diff,minfo
    return
endif
cinfo.info = minfo

    case 1 of
;_______________________________________________________________________
; change x and y range of plot
; if change range then also change the button to 'User Set Scale'
;_______________________________________________________________________
    (strmid(event_name,0,5) EQ 'range') : begin
        num = fix(strmid(event_name,5,1)) -1

        if(minfo.pl2.default_range[num] eq 0 ) then begin 

            widget_control,minfo.pl2.recomputeID[num],set_value='Plot Range'
            minfo.pl2.default_range[num] = 1
        endif
        mpl_2pt_plot,minfo

    end

    (strmid(event_name,0,2) EQ 'cr') : begin
        num = fix(strmid(event_name,2,1))-1
        if(strmid(event_name,4,1) EQ 'b') then mm_val = 0 else mm_val = 1 ; b for min, t for max
        minfo.pl2.graph_range[num,mm_val] = event.value
        minfo.pl2.default_range[num] = 0
        widget_control,minfo.pl2.recomputeID[num],set_value='Default'

	for i = 0,1 do begin
	  if(minfo.pl2.graph_range[i,0] gt minfo.pl2.graph_range[i,1] ) then begin
    	     result = dialog_message(" Graph range incorrect, reseting to default ",/error )
            widget_control,minfo.pl2.recomputeID[i],set_value='Plot Range'	
	     minfo.pl2.default_range[i]=1 
          endif	
	endfor

        mpl_2pt_plot,minfo
       
    end
;_______________________________________________________________________
    (strmid(event_name,0,7) EQ 'print_P') : begin
        print_pixel_2pt,minfo
        
    end
;_______________________________________________________________________
; Change Integration Range 

    (strmid(event_name,0,3) EQ 'int') : begin
; changed by typing a new value
        
        if(strmid(event_name,4,4) eq 'chng') then begin
            num = fix(strmid(event_name,9,1))-1
            minfo.pl2.int_range[num] = event.value
        endif


; check if the <> buttons were used
        if(strmid(event_name,4,4) eq 'move') then begin
            value = intarr(2)
            value[0] = minfo.pl2.int_range[0]
            value[1] = minfo.pl2.int_range[1]

            if(strmid(event_name,9,1) eq 'u') then begin
                value[0] = value[0] + 1
                value[1] = value[1] + 1
            endif
            if(strmid(event_name,9,1) eq 'd') then begin
                value[0] = value[0] - 1
                value[1] = value[1] -1
            endif

            minfo.pl2.int_range[0] = value[0]            
            minfo.pl2.int_range[1] = value[1]            
        endif

; check if plot all integrations is typed

        if(strmid(event_name,4,4) eq 'grab') then begin
            minfo.pl2.int_range[0] = 1            
            minfo.pl2.int_range[1] = minfo.data.nslopes
            if(minfo.data.coadd eq 1) then  minfo.pl2.int_range[1] = minfo.data.nints
        endif            

; Check limits for the above options for changing the integration range
; lower limit 1
; upper limit minfo.data.nslopes



        for i = 0,1 do begin

            if(minfo.pl2.int_range[i] le 0) then minfo.pl2.int_range[i] = 1
            if(minfo.pl2.int_range[i] gt minfo.data.nints) then $
              minfo.pl2.int_range[i] = minfo.data.nints
        endfor
        if(minfo.pl2.int_range[0] gt minfo.pl2.int_range[1] ) then begin
            result = dialog_message(" Integration range incorrect, reseting to first integration ",/error )
            minfo.pl2.int_range[*] = 1
        endif	

        if(minfo.data.coadd and minfo.pl2.int_range[1] eq minfo.pl2.int_range[0] ) then begin
            result = dialog_message(" For coadded data must have more than 1 integration",/error )
            minfo.pl2.int_range[0] = 1
            minfo.pl2.int_range[1] = minfo.data.nints
        endif
            

        widget_control,minfo.pl2.IrangeID[0],set_value=minfo.pl2.int_range[0]
        widget_control,minfo.pl2.IrangeID[1],set_value=minfo.pl2.int_range[1]
	
        mpl_2pt_plot,minfo



    	s1 = strcompress( string ( fix(minfo.pl2.int_range[0])),/remove_all)
    	s2 = strcompress( string ( fix(minfo.pl2.int_range[1])),/remove_all)
       iramp = minfo.data.nramps	
        ftitle = "Integration #: " + s1 + ' to '  + s2 +  $	
         "  Num of Frames/Integration: " + strtrim(string(fix(iramp)),2)     
	widget_control,minfo.pl2.frametitle_label,set_value = ftitle

    end
;_______________________________________________________________________
    (strmid(event_name,0,2) EQ 'on') : begin
        num = fix(strmid(event_name,2,1))-1
        minfo.pl2.onvalue[num] = 1
        widget_control, minfo.pl2.offButton[num],Set_Button = 0
        widget_control, minfo.pl2.onButton[num],Set_Button = 1
        mpl_2pt_plot,minfo
    end

    (strmid(event_name,0,3) EQ 'off') : begin
        num = fix(strmid(event_name,3,1))-1
        minfo.pl2.onvalue[num] = 0
        widget_control, minfo.pl2.onButton[num],Set_Button = 0
        widget_control, minfo.pl2.offButton[num],Set_Button = 1

        mpl_2pt_plot,minfo
    end


    (strmid(event_name,0,7) EQ 'allplot') : begin
        type = fix(strmid(event_name,7,1))
        if(type eq 1) then begin
            widget_control, minfo.pl2.noneButton,Set_Button = 0
            for i = 0,4 do begin 
                minfo.pl2.onvalue[i] = 1
                widget_control, minfo.pl2.onButton[i],Set_Button = 1
                widget_control, minfo.pl2.offButton[i],Set_Button = 0
            endfor
        endif
        if(type eq 2) then begin
            widget_control, minfo.pl2.allButton,Set_Button = 0
            for i = 0,4 do begin 
                minfo.pl2.onvalue[i] = 0
                widget_control, minfo.pl2.onButton[i],Set_Button = 0
                widget_control, minfo.pl2.offButton[i],Set_Button = 1
            endfor
        endif
            
        mpl_2pt_plot,minfo

    end
;_______________________________________________________________________

;_______________________________________________________________________
; overplot frame values

    (strmid(event_name,0,9) eq 'overframe') : begin
        num = fix(strmid(event_name,9,1))
        if(num eq 1) then begin
            minfo.pl2.overplot_frame = 1
            widget_control,minfo.pl2.overplotFrameID[0],set_button = 1
            widget_control,minfo.pl2.overplotFrameID[1],set_button = 0

        endif

        if(num eq 2) then begin
            minfo.pl2.overplot_frame = 0
            widget_control,minfo.pl2.overplotFrameID[0],set_button = 0
            widget_control,minfo.pl2.overplotFrameID[1],set_button = 1
        endif

        mpl_2pt_plot,minfo
    end


;_______________________________________________________________________

; overplot reference Corrected data 

    (strmid(event_name,0,7) eq 'overref') : begin
        num = fix(strmid(event_name,7,1))
        if(num eq 1) then begin
            minfo.pl2.overplot_refcorrect = 1
            widget_control,minfo.pl2.overplotRefID[0],set_button = 1
            widget_control,minfo.pl2.overplotRefID[1],set_button = 0
        endif

        if(num eq 2) then begin
            minfo.pl2.overplot_refcorrect= 0
            widget_control,minfo.pl2.overplotRefID[0],set_button = 0
            widget_control,minfo.pl2.overplotRefID[1],set_button = 1
        endif
        
        widget_control,event.top,set_uvalue = cinfo
        widget_control,cinfo.info.Quicklook,set_uvalue = minfo
        mpl_2pt_plot,minfo

    end


;_______________________________________________________________________
; Plot linearity corrected data

    (strmid(event_name,0,6) eq 'overlc') : begin
        num = fix(strmid(event_name,6,1))
        if(num eq 1) then begin
            minfo.pl2.overplot_lc = 1
            widget_control,minfo.pl2.overplotlcID[0],set_button = 1
            widget_control,minfo.pl2.overplotlcID[1],set_button = 0
        endif

        if(num eq 2) then begin
            minfo.pl2.overplot_lc= 0
            widget_control,minfo.pl2.overplotlcID[0],set_button = 0
            widget_control,minfo.pl2.overplotlcID[1],set_button = 1
        endif
        mpl_2pt_plot,minfo
    end
;_______________________________________________________________________
; overplot linear fit of frame data 

    (strmid(event_name,0,7) eq 'overlff') : begin
        num = fix(strmid(event_name,7,1))
        if(num eq 1) then begin
            minfo.pl2.overplot_lfit_frame = 1
            widget_control,minfo.pl2.overplotLFFID[0],set_button = 1
            widget_control,minfo.pl2.overplotLFFID[1],set_button = 0
        endif

        if(num eq 2) then begin
            minfo.pl2.overplot_lfit_frame= 0
            widget_control,minfo.pl2.overplotLFFID[0],set_button = 0
            widget_control,minfo.pl2.overplotLFFID[1],set_button = 1
        endif
        
        widget_control,event.top,set_uvalue = cinfo
        widget_control,cinfo.info.Quicklook,set_uvalue = minfo
        mpl_2pt_plot,minfo

    end

;_______________________________________________________________________
; overplot linear fit of reference corrected data

    (strmid(event_name,0,7) eq 'overlfr') : begin
        num = fix(strmid(event_name,7,1))
        if(num eq 1) then begin
            minfo.pl2.overplot_lfit_refcorect = 1
            widget_control,minfo.pl2.overplotLFRID[0],set_button = 1
            widget_control,minfo.pl2.overplotLFRID[1],set_button = 0
        endif

        if(num eq 2) then begin
            minfo.pl2.overplot_lfit_refcorrect= 0
            widget_control,minfo.pl2.overplotLFRID[0],set_button = 0
            widget_control,minfo.pl2.overplotLFRID[1],set_button = 1
        endif
        
        widget_control,event.top,set_uvalue = cinfo
        widget_control,cinfo.info.Quicklook,set_uvalue = minfo
        mpl_2pt_plot,minfo

    end

;_______________________________________________________________________
; overplot linear fit of linear corrected data 

    (strmid(event_name,0,7) eq 'overlfl') : begin
        num = fix(strmid(event_name,7,1))
        if(num eq 1) then begin
            minfo.pl2.overplot_lfit_lc = 1
            widget_control,minfo.pl2.overplotLFLID[0],set_button = 1
            widget_control,minfo.pl2.overplotLFLID[1],set_button = 0
        endif

        if(num eq 2) then begin
            minfo.pl2.overplot_lfit_lc= 0
            widget_control,minfo.pl2.overplotLFLID[0],set_button = 0
            widget_control,minfo.pl2.overplotLFLID[1],set_button = 1
        endif
        
        widget_control,event.top,set_uvalue = cinfo
        widget_control,cinfo.info.Quicklook,set_uvalue = minfo
        mpl_2pt_plot,minfo

    end

;_______________________________________________________________________


;_______________________________________________________________________
; Print the slope values out
    (strmid(event_name,0,6) eq 'getall') : begin
        mpl_display_2pt_values,minfo
    end
endcase
cinfo.info = minfo
widget_control,event.top,set_uvalue = cinfo
widget_control,cinfo.info.Quicklook,set_uvalue = minfo
end



; _______________________________________________________________________
;***********************************************************************
pro mpl_2pt_diff,info

; _______________________________________________________________________
; This is the main widget program controlling 2 point difference plot

; _______________________________________________________________________
status = 0

; _______________________________________________________________________
window,1
wdelete,1
if(XRegistered ('mpl2')) then begin
    print,'Exiting MIRI QuickLook -Pixel Look 2 Point Differences'
    widget_control,info.TwoPtDiff,/destroy
endif

; widget window parameters
xwidget_size = 1300
ywidget_size = 1100

xsize_scroll = 1220
ysize_scroll = 1000


if(info.pl2.uwindowsize eq 1) then begin
    xsize_scroll = info.pl2.xwindowsize
    ysize_scroll = info.pl2.ywindowsize
endif

if(info.control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.control.x_scroll_window
if(info.control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.control.y_scroll_window

if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10

stitle = "MIRI 2 Point Difference Pixel Look Tool " + info.version
TwoPtDiff = widget_base(title=stitle,$
                        col = 1,mbar = menuBar,group_leader = info.PixelLook,$
                        xsize =  xwidget_size,$
                        ysize=   ywidget_size,/scroll,$
                        x_scroll_size= xsize_scroll,$
                        y_scroll_size = ysize_scroll,/TLB_SIZE_EVENTS)

info.TwoPtDiff = TwoPtDiff
;_______________________________________________________________________
;********
; build the menubar
;********
QuitMenu = widget_button(menuBar,value="Quit",font = info.font2)
quitbutton = widget_button(quitmenu,value="Quit",event_pro='mpl_2pt_diff_quit')


PMenu = widget_button(menuBar,value="Print",font = info.font2)
PbuttonR = widget_button(Pmenu,value = "Print 2pt Differences Plot",uvalue='print_P')
;_______________________________________________________________________
; defaults to start with  
int_range = intarr(2) 
int_range[0] = 1  ; initialize to look at first integration
int_range[1] = 1
if(info.data.coadd eq 1) then begin
    int_range[1] = info.pl.end_fit
    int_range[0] = info.pl.start_fit

    int_range[1] = info.data.nints
    int_range[0] = 1
endif

info.pl2.int_range[*] = int_range[*]


;_______________________________________________________________________  


svalue = " A sample of pixel values through an integration:  " + info.control.filename_raw
tlabelID = widget_label(TwoPtDiff,value =svalue ,/align_left,$
                        font=info.font5)
iramp = info.data.nramps
ftitle = "Integrationa #:  1 to 1 "  + $
         "  Num of Frames/Integration: " + strtrim(string(fix(iramp)),2)     

;_______________________________________________________________________
widget_control,info.filetag[0] ,set_value = 'Raw File name: ' + info.control.filename_raw 
widget_control,info.typetag, set_value ='Science Image ' 

si = strcompress(string(info.data.nslopes),/remove_all)
sr = strcompress(string(info.data.nramps),/remove_all)
sx = strcompress(string(info.data.image_xsize),/remove_all)
sy = strcompress(string(info.data.image_ysize),/remove_all)

widget_control,info.line_tag[0],set_value = '# of Integrations: ' + si 
widget_control,info.line_tag[1],set_value = '# of Samples/Integrations: ' + sr
widget_control,info.line_tag[2],set_value = ' Image Size ' + sx + ' X ' + sy 

if(info.data.ref_exist eq 0) then $
widget_control,info.line_tag[3],set_value = ' No reference image exists' 


;_______________________________________________________________________
;*********
;Setup main panel
;*********


graphID_master1 = widget_base(info.TwoPtDiff,row=1)
graphID_master22 = widget_base(info.TwoPtDiff,row=1)
graphID_master2 = widget_base(info.TwoPtDiff,row=1)


info.pl2.graphID1 = widget_base(graphID_master1,col=1)
SoptionID =widget_base(graphID_master1,col=1) 
ChangeID = widget_base(graphID_master2,col=1)

;_______________________________________________________________________  

;*****
;graph 1,1
;*****

info.pl2.graphID = widget_draw(info.pl2.graphID1,$
                              xsize =info.plotsize1*2.5,$ 
                              ysize =info.plotsize1*2,$
                              retain=info.retn)
;_______________________________________________________________________
; Change values - section
;_______________________________________________________________________
; button to change integrations

info.pl2.frametitle_label = widget_label(SoptionID, $
                           value=ftitle,/align_left, $
                           font=info.font3,/dynamic_resize)
integrationNO = info.image.integrationNO
frameNO = info.image.rampNO
change_int_label = widget_label(SoptionID,value='Integration Range',$
	font=info.font5,/align_left,/sunken_frame)

move_base = widget_base(SoptionID,/row,/align_left)

IrangeID = lonarr(2)

IrangeID[0] = cw_field(move_base,$
                  title=" Start ",font=info.font5, $
                  uvalue="int_chng_1",/integer,/return_events, $
                  value=int_range[0],xsize=4,$
                  fieldfont=info.font3)
IrangeID[1] = cw_field(move_base,$
                  title=" End ",font=info.font5, $
                  uvalue="int_chng_2",/integer,/return_events, $
                  value=int_range[1],xsize=4,$
                  fieldfont=info.font3)

labelID = widget_button(move_base,uvalue='int_move_d',value='<',font=info.font3)
labelID = widget_button(move_base,uvalue='int_move_u',value='>',font=info.font3)


IAllButton = Widget_button(move_base, Value = 'Plot All',uvalue = 'int_grab_all')
widget_control,IAllButton,Set_Button = 0
info.pl2.IrangeID = IrangeID

; change the range of the plot

graph_range = fltarr(2,2)

; xrange of plot
graph_range[0,0] = 0
graph_range[0,1] = info.data.nramps

; yrange of plot - figure out 
graph_range[1,0] = 0
graph_range[1,1] = 0

rangeID = lonarr(2,2)
recomputeID = lonarr(2)

xrange = widget_label(SoptionID, value =' Change Plot range', /align_left,$
                      font=info.font5,/sunken_frame)

xlabel_base = widget_base(SoptionID,col=3,/align_left)

recomputeID[0] = widget_button(xlabel_base,value='Plot Range',$font=info.font4,$
                                                uvalue = 'range1')
rangeID[0,0] = cw_field(Xlabel_base,$
                  title=" X Min ",font=info.font5, $
                  uvalue="cr1_b",/integer,/return_events, $
                  value=fix(graph_range[0,0]),xsize=9,$
                  fieldfont=info.font3)

rangeID[0,1] = cw_field(Xlabel_base,$
                 title=" X Max ",font=info.font5, $
                  uvalue="cr1_t",/integer,/return_events, $
                  value=fix(graph_range[0,1]),xsize=9,$
                  fieldfont=info.font3)


ylabel_base = widget_base(SoptionID,col=3,/align_left)

recomputeID[1] = widget_button(ylabel_base,value='Plot Range',$font=info.font4,$
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

info.pl2.rangeID = rangeID
info.pl2.recomputeID = recomputeID
info.pl2.default_range[*] = 1
info.pl2.graph_range = graph_range

;_______________________________________________________________________

    
Name = ["Pixel A" ,"Pixel B" ,"Pixel C" ,"Pixel D", "Pixel E" ]
ValueX = ['0000' ,'0000' ,'0000' ,'0000','0000']
ValueY = ['0000', '0000', '0000', '0000','0000' ]
Channel = [' 1', ' 2', ' 3', ' 4', ' 5' ]


blank_a = '           '
blank_b = '              '
Value2 =  [blank_b,blank_b,blank_b,blank_b,blank_b]
Value1 =  [blank_a,blank_a,blank_a,blank_a,blank_a]

imBases = lonarr(5)
onButton  = lonarr(5)
offButton = lonarr(5)

onvalue = intarr(5) 
offvalue = intarr(5)

onvalue(*) = 1

;-----------------------------------------------------------------------
overplot_frame = 1
overplot_lfit_frame = 0

all_base = widget_base(ChangeID,/row,/align_left)

overplot = widget_label(all_base,value = 'Plot 2pt-diff Frame Values',/sunken_frame, font = info.font5)
oBase = Widget_base(all_base,/row,/nonexclusive)
overplotFrameID = lonarr(2)
OverplotFrameID[0] = Widget_button(oBase, Value = 'Yes',uvalue = 'overframe1')
widget_control,OverplotFrameID[0],Set_Button = 1

OverplotFrameID[1] = Widget_Button(oBase, Value = 'No',uvalue = 'overframe2')
widget_control,OverplotFrameID[1],Set_Button = 0



overplot = widget_label(all_base,value = 'Plot Linear Fit to Frame Data',$
                        /sunken_frame, font = info.font5,/align_left)
oBase = Widget_base(all_base,/row,/nonexclusive)
overplotLFFID = lonarr(2)
OverplotLFFID[0] = Widget_button(oBase, Value = 'Yes',uvalue = 'overlff1')
widget_control,OverplotLFFID[0],Set_Button = 0

OverplotLFFID[1] = Widget_Button(oBase, Value = 'No',uvalue = 'overlff2')
widget_control,OverplotLFFID[1],Set_Button = 1
;-----------------------------------------------------------------------

overplot_refcorrect = 0
overplot_lfit_refcorrect = 0

overplotRefID = lonarr(2)
overplotLFRID = lonarr(2)
if(info.control.file_refcorrection_exist eq 1)then begin 
    overplot = widget_label(all_base,value = 'Plot 2pt-diff Ref Corrected Data',$
                            /sunken_frame, font = info.font5,/align_left)
    oBase = Widget_base(all_base,/row,/nonexclusive)

    OverplotRefID[0] = Widget_button(oBase, Value = 'Yes',uvalue = 'overref1')
    widget_control,OverplotRefID[0],Set_Button = 0

    OverplotRefID[1] = Widget_Button(oBase, Value = 'No',uvalue = 'overref2')
    widget_control,OverplotRefID[1],Set_Button = 1

    overplot = widget_label(all_base,value = 'Plot Linear Fit to Ref. Corr. Data',$
                        /sunken_frame, font = info.font5,/align_left)
    oBase = Widget_base(all_base,/row,/nonexclusive)

    OverplotLFRID[0] = Widget_button(oBase, Value = 'Yes',uvalue = 'overlfr1')
    widget_control,OverplotLFRID[0],Set_Button = 0

    OverplotLFRID[1] = Widget_Button(oBase, Value = 'No',uvalue = 'overlfr2')
    widget_control,OverplotLFRID[1],Set_Button = 1
endif

overplot_lc = 0
overplot_lfit_lc = 0
overplotlcID = lonarr(2)
overplotLFLID = lonarr(2)
if(info.control.file_lc_exist eq 1)then begin 
    overplot = widget_label(all_base,value = 'Plot 2pt-diff Lin. Corrected Data',$
                            /sunken_frame, font = info.font5,/align_left)
    oBase = Widget_base(all_base,/row,/nonexclusive)

    OverplotlcID[0] = Widget_button(oBase, Value = 'Yes',uvalue = 'overlc1')
    widget_control,OverplotlcID[0],Set_Button = 0

    OverplotlcID[1] = Widget_Button(oBase, Value = 'No',uvalue = 'overlc2')
    widget_control,OverplotlcID[1],Set_Button = 1


    overplot = widget_label(all_base,value = 'Plot Linear Fit to Lin. Corr. Data',$
                        /sunken_frame, font = info.font5,/align_left)
    oBase = Widget_base(all_base,/row,/nonexclusive)

    OverplotLFLID[0] = Widget_button(oBase, Value = 'Yes',uvalue = 'overlfl1')
    widget_control,OverplotLFLID[0],Set_Button = 0

    OverplotLFLID[1] = Widget_Button(oBase, Value = 'No',uvalue = 'overlfl2')
    widget_control,OverplotLFLID[1],Set_Button = 1

endif
;-----------------------------------------------------------------------
all_base = widget_base(ChangeID,/row,/align_left)
amp = widget_label(all_base, value =' Select Pixel to Plot', $
                      /align_left,font=info.font5,/sunken_frame)


allbutton = widget_button(all_base,Value = ' Select All',uvalue='allplot1')
widget_control,allbutton,Set_Button = 1
nonebutton = widget_button(all_base,Value = ' Select None',uvalue='allplot2')
widget_control,nonebutton,Set_Button = 0


getbase = Widget_Base(ChangeID,/row)
desa= widget_label(getbase,value ="                                                  "+$
                   "Values given below are for  Integration Range set above ")

slope_all = widget_button(getbase,value=" Get Results for All Integrations" ,uvalue = 'getall') 


label_name= "Name     X    Y Channel   "$
            + "  Plot      Raw Frame  Ref Corrected" + $
            "   Max 2pt    Imax 2pt      Slope 2pt      STDEV 2pt"
            
label_name2 = "                                                                     Raw Frame Values" 
if(info.control.file_refcorrection_exist eq 1 )then begin 
    label_name= "Name     X    Y Channel   "$
              + "  Plot      Raw Frame  Ref Corrected" + $
                "   Max 2pt    Imax 2pt      Slope 2pt      STDEV 2pt"+ $
                "       Max 2pt     Imax 2pt      Slope 2pt      STDEV 2pt " 
    label_name2 = "                                                                     Raw Frame Values" + $
                  "                                    Reference Corrected Values"
    
endif


if(info.control.file_lc_exist eq 1 )then begin 
    label_name= "Name     X    Y Channel   "$
              + "  Plot      Raw Frame  Lin Corrected" + $
                "   Max 2pt    Imax 2pt      Slope 2pt      STDEV 2pt"+ $
                "       Max 2pt     Imax 2pt      Slope 2pt      STDEV 2pt " 
    label_name2 = "                                                                     Raw Frame Values" + $
                  "                                    Linearity Corrected Values"
    
endif
descrip = Widget_Base(ChangeID,/row)	
des2 = widget_label(descrip, value = label_name2,/align_left)	

descrip = Widget_Base(ChangeID,/row)
des1 = widget_label(descrip, value = label_name,/align_left)


ix = lonarr(5) & iy = lonarr(5) & ic = lonarr(5) 
imax = lonarr(5) & iread = lonarr(5) & islope = lonarr(5) & istdev =lonarr(5)
imax2 = lonarr(5) & iread2 = lonarr(5) & islope2 = lonarr(5) & istdev2 =lonarr(5)



boxID = lonarr(5)
boxIDc = lonarr(5)
for i = 0,4 do begin
    imBases[i] = Widget_Base(ChangeID,/row)

    iName = Widget_label(imbases[i],value = Name[i])
    ix[i] = Widget_label(imbases[i],value = ValueX[i])
    iy[i] = Widget_label(imbases[i],value = ValueY[i])
    ic[i] = Widget_label(imbases[i],value = Channel[i])


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
    boxIDc[i] = widget_draw(imBases[i],scr_xsize=50,scr_ysize=20, $
                               frame=1)


    imax[i] = Widget_label(imbases[i],value = value1[i])
    iread[i] = Widget_label(imbases[i],value = value1[i])
    islope[i] = Widget_label(imbases[i],value = value2[i])
    istdev[i] = Widget_label(imbases[i],value = value2[i])

    imax2[i] = Widget_label(imbases[i],value = value1[i])
    iread2[i] = Widget_label(imbases[i],value = value1[i])
    islope2[i] = Widget_label(imbases[i],value = value2[i])
    istdev2[i] = Widget_label(imbases[i],value = value2[i])

endfor


;_______________________________________________________________________
longline = '                                                                                                                                                                 '
longtag = widget_label(TwoPtDiff,value = longline)
Widget_control,info.TwoPtDiff,/Realize

;_______________________________________________________________________
draw_box_id = lonarr(5)
draw_box_ids = lonarr(5)
draw_box_idreject = lonarr(5)
for i = 0,4 do begin
  widget_control,boxID[i],get_value=tdraw_id
  draw_box_id[i] = tdraw_id

  widget_control,boxIDc[i],get_value=tdraw_id
  draw_box_ids[i] = tdraw_id

endfor




;_______________________________________________________________________


info.pl2.nonebutton = nonebutton
info.pl2.allbutton = nonebutton
info.pl2.offbutton = offbutton
info.pl2.onbutton = onbutton
info.pl2.onvalue = onvalue
info.pl2.draw_box_id = draw_box_id
info.pl2.draw_box_ids = draw_box_ids

info.pl2.xpixel_label = ix
info.pl2.ypixel_label = iy
info.pl2.channel_label = ic

info.pl2.info_label1 = imax
info.pl2.info_label2 = iread
info.pl2.info_label3 = islope
info.pl2.info_label4 = istdev

info.pl2.info_label5 = imax2
info.pl2.info_label6 = iread2
info.pl2.info_label7 = islope2
info.pl2.info_label8 = istdev2

info.pl2.overplot_frame = overplot_frame
info.pl2.overplot_lfit_frame = overplot_lfit_frame

info.pl2.overplot_refcorrect = overplot_refcorrect
info.pl2.overplot_lfit_refcorrect = overplot_lfit_refcorrect

info.pl2.overplot_lc = overplot_lc
info.pl2.overplot_lfit_lc = overplot_lfit_lc

info.pl2.overplotFrameID = overplotFrameID
info.pl2.overplotRefID = overplotRefID
info.pl2.overplotlcID = overplotlcID
info.pl2.overplotLFFID = overplotLFFID
info.pl2.overplotLFRID = overplotLFRID
info.pl2.overplotLFLID = overplotLFLID

;Set up the GUI


XManager,'mpl2',info.TwoPtDiff,/No_Block,event_handler='mpl_2pt_diff_event'

; get the window id of the draw window
widget_control,info.pl2.graphID,get_value=tdraw_id
info.pl2.draw_window_id = tdraw_id


mpl_2pt_plot,info



Widget_Control,info.QuickLook,Set_UValue=info
sinfo = {info        : info}

Widget_Control,info.TwoPtDiff,Set_UValue=sinfo
Widget_Control,info.QuickLook,Set_UValue=info


end

;***********************************************************************
; plot the results from the Pixel look 2 point difference program
; Circles for data points
; Dashed line for reference output image subtraction results
; Solid line for reference pixel applied
 ; order of corrections: 

pro mpl_2pt_plot,info,ps = ps, eps = eps
save_color = info.col_table
color6
line_colors = [info.red,info.green,info.blue, info.yellow,info.white]
linetype1 = 5
linetype2 = 0
linetype3 = 2


hcopy = 0
if ( (keyword_set(ps)) or ( keyword_set(eps)) ) then hcopy = 1
stitle = ' '
sstitle = ' ' 



ind = info.pl.group ; 0 pixel tracking file first 4 pixels
                    ; 1 pixel tracking file second 4 pixels
                    ; 2 random
	            ; 3 user defined

num = info.pltrack.num_group[ind]

ii = info.pl2.int_range[0]-1
ij = info.pl2.int_range[1]-1
num_int = info.data.nslopes 
num_int = ij -ii + 1
if(info.data.coadd eq 1) then num_int = 1

xdata = (*info.pltrack.px)[ind,0:num-1]              ; typeof data, num pixels
ydata = (*info.pltrack.py)[ind,0:num-1]              ; typeof data, num pixels
ch = (*info.pltrack.pch)[ind,0:num-1]                ; typeof data, num pixels
data = (*info.pltrack.pdata)[ind,ii:ij,*,0:num-1]    ; typeof data, num integ, num frames, num pixels
;data = (*info.pltrack.plcdata)[ind,ii:ij,*,0:num-1]    ; typeof data, num integ, num frames, num pixels
stat = (*info.pltrack.pstat)[ind,ii:ij,0:num-1,*]    ; typeof data, num integ, num pixels, (min or max)

refcorrect_data = (*info.pltrack.prefcorrectdata)[ind,ii:ij,*,0:num-1]   
                                ; typeof data, num integ, num frames,
                                ; num pixels

lc_data = (*info.pltrack.plcdata)[ind,ii:ij,*,0:num-1]   
                                ; typeof data, num integ, num frames,
                                ; num pixels
;_______________________________________________________________________
; raw data twopt differences 

istart = info.pl.start_fit-1
iend = info.pl.end_fit-1
if(info.data.coadd eq 1) then begin
    istart = info.pl2.int_range[0] -1
    iend  = info.pl2.int_range[1] -1
endif



nvalid = (iend - istart)
xvalues_plot = indgen(nvalid) + info.pl.start_fit

twopt_diff = fltarr(1,num_int,nvalid,num)

lin_fit = fltarr(2,num_int,num)
max2pt = fltarr(num_int,num)
iread = intarr(num_int,num)
stdev2pt = fltarr(num_int,num)
jj = 0


for j = istart, iend-1 do begin
    if(info.data.coadd ne 1) then twopt_diff[0,*,jj,*] = data[0,*,j+1,*] - data[0,*,j,*]
    if(info.data.coadd eq 1) then twopt_diff[0,*,jj,*] = data[0,j+1,*,*] - data[0,j,*,*]
    jj  = jj + 1
endfor


yfit = fltarr(num_int,nvalid,num)
;linfit : y = A + Bx
yvalues_fit = xvalues_plot
for k = 0,num_int-1 do begin
    for i = 0,num -1 do begin
        yvalues_fit[*] = twopt_diff[0,k,*,i]
        
        stdev2pt[k,i] = stddev(yvalues_fit)
        max2pt[k,i] = max(abs(yvalues_fit))
        ii = where(max2pt[k,i] eq abs(yvalues_fit))
        max2pt[k,i] = yvalues_fit[ii[0]]
        iread[k,i] = ii[0]+ info.pl.start_fit

        result = linfit(xvalues_plot,yvalues_fit)
        lin_fit[0,k,i] = result[0]
        lin_fit[1,k,i] = result[1]
        yfit[k,*,i] = lin_fit[0,k,i] + lin_fit[1,k,i]*xvalues_plot
        
    endfor
endfor

twopt_diff_corrected = twopt_diff
lin_fit_corrected = lin_fit
yfit_corrected = yfit
max2pt_corrected = fltarr(num_int,num)
iread_corrected = intarr(num_int,num)
stdev2pt_corrected = fltarr(num_int,num)


if(info.control.file_refcorrection_exist eq 1 )then begin 
    jj = 0
    for j = istart, iend-1 do begin
        if(info.data.coadd ne 1) then $
          twopt_diff_corrected[0,*,jj,*] = refcorrect_data[0,*,j+1,*] - refcorrect_data[0,*,j,*]
        if(info.data.coadd ne 1) then $
          twopt_diff_corrected[0,*,jj,*] = refcorrect_data[0,*,j+1,*] - refcorrect_data[0,*,j,*]
        jj  = jj + 1
    endfor


;linfit : y = A + Bx
    yvalues_fit = xvalues_plot
    for k = 0,num_int-1 do begin
        for i = 0,num -1 do begin
                yvalues_fit[*] = twopt_diff_corrected[0,k,*,i]
                stdev2pt_corrected[k,i] = stddev(yvalues_fit)
                max2pt_corrected[k,i] = max(abs(yvalues_fit))
                ii = where(max2pt_corrected[k,i] eq abs(yvalues_fit))
                max2pt_corrected[k,i] = yvalues_fit[ii[0]]
                iread_corrected[k,i] = ii[0] 
                result = linfit(xvalues_plot,yvalues_fit)
                lin_fit_corrected[0,k,i] = result[0]
                lin_fit_corrected[1,k,i] = result[1]
            
                yfit_corrected[k,*,i] = lin_fit_corrected[0,k,i] + lin_fit_corrected[1,k,i]*xvalues_plot

        endfor
    endfor
endif



twopt_diff_lcorrected = twopt_diff
lin_fit_lcorrected = lin_fit
yfit_lcorrected = yfit
max2pt_lcorrected = fltarr(num_int,num)
iread_lcorrected = intarr(num_int,num)
stdev2pt_lcorrected = fltarr(num_int,num)

if(info.control.file_lc_exist eq 1)then begin 
    jj = 0
    for j = istart, iend-1 do begin
          twopt_diff_lcorrected[0,*,jj,*] = lc_data[0,*,j+1,*] - lc_data[0,*,j,*]
        jj  = jj + 1
    endfor


;linfit : y = A + Bx
    yvalues_fit = xvalues_plot
    for k = 0,num_int-1 do begin
        for i = 0,num -1 do begin
                 values = twopt_diff_lcorrected[0,k,*,i]
                 iv = where(finite(values))
                 
                 yvalues_fit = values[iv] 
                 xvalues_fit = xvalues_plot[iv]
                stdev2pt_lcorrected[k,i] = stddev(yvalues_fit)
                max2pt_lcorrected[k,i] = max(abs(yvalues_fit))
                ii = where(max2pt_lcorrected[k,i] eq abs(yvalues_fit))
                max2pt_lcorrected[k,i] = yvalues_fit[ii[0]]
                iread_lcorrected[k,i] = ii[0] 
                result = linfit(xvalues_fit,yvalues_fit)
                lin_fit_lcorrected[0,k,i] = result[0]
                lin_fit_lcorrected[1,k,i] = result[1]
            
                yfit_lcorrected[k,*,i] = lin_fit_lcorrected[0,k,i] + lin_fit_lcorrected[1,k,i]*xvalues_plot
        endfor
    endfor
endif

;---------------------------------------------------------------------------
; Now are we limited in which pixels we want to plot
index = where(info.pl2.onvalue[*] eq 1, inum)


ymin = min(twopt_diff)
ymax = max(twopt_diff)

snum = 0
Ymin_total = fltarr(3) & Ymax_total = fltarr(3)

if(inum gt 0) then begin 
    ymin = min(twopt_diff[0,*,*,index])
    ymax = max(twopt_diff[0,*,*,index])
endif

ymin_total[0] = ymin
ymax_total[0] = ymax



if(info.pl2.overplot_refcorrect eq 1) then begin
    ymin1 = min( twopt_diff_corrected)
    ymax1 = max( twopt_diff_corrected)
    snum = snum + 1

    if(inum gt 0) then begin 
        ymin = min(twopt_diff_corrected[0,*,*,index])
        ymax = max(twopt_diff_corrected[0,*,*,index])
    endif

    ymin_total[snum] = ymin1
    ymax_total[snum] = ymax1

endif

ymin = min (ymin_total[0:snum])
ymax = max (ymax_total[0:snum])

if(hcopy eq 0 ) then wset,info.pl2.draw_window_id
if(hcopy eq 1) then begin
    ititle = " Integration #: " + strtrim(string(ii+1),2) + ' to ' + $
             strtrim(string(ij+1),2)
    sstitle = info.control.filebase + '.fits: ' + ititle
    stitle = "Values for Selected Pixels :"  
endif


nreads = info.data.nramps*num_int
if(info.data.coadd) then nreads = info.pl2.int_range[1]- info.pl2.int_range[0] + 1
xvalues = indgen(nreads) + 1

xmin = min(xvalues)
xmax = max(xvalues)

ypad = (ymin + ymax)*.10
if(ypad le 1 ) then ypad = 1


; check if default scale is true - then reset to orginal value
if(info.pl2.default_range[0] eq 1) then begin
    info.pl2.graph_range[0,0] = xmin-1 
    info.pl2.graph_range[0,1] = xmax+1
endif 
  
if(info.pl2.default_range[1] eq 1) then begin
    info.pl2.graph_range[1,0] = ymin-ypad 
    info.pl2.graph_range[1,1] = ymax+ypad
endif

x1 = info.pl2.graph_range[0,0]
x2 = info.pl2.graph_range[0,1]
y1 = info.pl2.graph_range[1,0]
y2 = info.pl2.graph_range[1,1]
;_______________________________________________________________________

;_______________________________________________________________________
if(hcopy eq 0) then begin
    plot,xvalues,data,xtitle = '1st point Frame #', ytitle='Difference (DN) ',$
         xrange=[x1,x2],yrange=[y1,y2],title = stitle, subtitle = sstitle,/nodata,$
         xstyle = 1, ystyle = 1
endif

if(hcopy eq 1) then begin
    plot,position = [0.1,0.35,0.95,0.95], xvalues,data,xtitle = '1st point Frame #', ytitle='DN/frame',$
         xrange=[x1,x2],yrange=[y1,y2],title = stitle, subtitle = sstitle,/nodata,$
         xstyle = 1, ystyle = 1
endif


if(info.pl2.overplot_frame eq 1 or info.pl2.overplot_lfit_frame eq 1 ) then begin 
    for k = 0,num_int-1 do begin
        ic = 0
        for i = 0, num-1 do begin
            if(info.pl2.onvalue[i] eq 1) then begin 

                ixvalues = xvalues_plot + info.data.nramps*(k)
                if(info.pl2.overplot_frame eq 1) then begin 
                    yvalues = twopt_diff[0,k,*,i]
                    oplot,ixvalues,yvalues,psym = 6,symsize = 1.0,color=line_colors[ic]
                endif
                
                if(info.pl2.overplot_lfit_frame eq 1) then begin 
                    yvalues_fit= yfit[k,*,i] 
                    oplot,ixvalues,yvalues_fit,linestyle = 1,color=line_colors[ic]
                endif
            endif
            ic = ic + 1
            if(ic eq 5) then ic = 0
        endfor

; box showing limits of integration
        if(num_int gt 1) then begin
            yline = fltarr(2) & xline = fltarr(2)
            yline[0] = -1000000 & yline[1] = 100000
            xline[*] = info.data.nramps* (k+1)
            oplot,xline,yline,linestyle=3
        endif  
    endfor
endif


;_______________________________________________________________________
; plot reference corrected data 
if(info.pl2.overplot_refcorrect eq 1 or info.pl2.overplot_lfit_refcorrect eq 1) then begin 
    for k = 0,num_int-1 do begin
        ic = 0
        for i = 0, num-1 do begin
            
            if(info.pl2.onvalue[i] eq 1 and ch[0,i] ne 5) then begin 

                ixvalues = xvalues_plot + info.data.nramps*(k)
                if(info.pl2.overplot_refcorrect eq 1) then begin 
                    yvalues = twopt_diff_corrected[0,k,*,i]
                    oplot,ixvalues,yvalues,psym = 2,symsize = 1.0,color=line_colors[ic]
                endif
            
                if(info.pl2.overplot_lfit_refcorrect eq 1) then begin
                    yvalues_fit= yfit_corrected[k,*,i] 
                    oplot,ixvalues,yvalues_fit,linestyle = 3,color=line_colors[ic]
                endif
            endif
            ic = ic + 1
            if(ic eq 5) then ic = 0
        endfor

; box showing limits of integration
        if(num_int gt 1) then begin
            yline = fltarr(2) & xline = fltarr(2)
            yline[0] = -1000000 & yline[1] = 100000
            xline[*] = info.data.nramps* (k+1)
            oplot,xline,yline,linestyle=3
        endif  
    endfor
endif

;_______________________________________________________________________
; plot linearity corrected - 

if(info.pl2.overplot_lc eq 1 or info.pl2.overplot_lfit_lc eq 1) then begin 
    for k = 0,num_int-1 do begin
        ic = 0
        for i = 0, num-1 do begin
            
            if(info.pl2.onvalue[i] eq 1 and ch[0,i] ne 5) then begin 
                ixvalues = xvalues_plot + info.data.nramps*(k)
                 values = twopt_diff_lcorrected[0,k,*,i]
                 
                 iv = where(finite(values))

                 if(info.pl2.overplot_lc eq 1) then begin 
                     yyvalues = values[iv]
                     xxvalues = ixvalues[iv]
                     oplot,xxvalues,yyvalues,psym = 2,symsize = 1.0,color=line_colors[ic]
                 endif
                if(info.pl2.overplot_lfit_lc eq 1) then begin
                    yvalues_fit= yfit_lcorrected[k,*,i] 
                    oplot,ixvalues,yvalues_fit,linestyle = 2,color=line_colors[ic]
                endif
            endif
            ic = ic + 1
            if(ic eq 5) then ic = 0
        endfor

; box showing limits of integration
        if(num_int gt 1) then begin
            yline = fltarr(2) & xline = fltarr(2)
            yline[0] = -1000000 & yline[1] = 100000
            xline[*] = info.data.nramps* (k+1)
            oplot,xline,yline,linestyle=3
        endif  
    endfor
endif

;_______________________________________________________________________
widget_control,info.pl2.rangeID[0,0],set_value=fix(x1)
widget_control,info.pl2.rangeID[0,1],set_value=fix(x2)
widget_control,info.pl2.rangeID[1,0],set_value=y1
widget_control,info.pl2.rangeID[1,1],set_value=y2


;_______________________________________________________________________
if(hcopy eq 0) then begin  
; draw boxes- raw data 
    xpt =findgen(4)/4+ 0.1 & ypt = fltarr(4) + 0.5
    for i = 0,4  do begin
        wset,info.pl2.draw_box_id[i]
        plot,xpt,ypt,color=line_colors[i], $
             xstyle=4,ystyle=4,position=[0.1,0.1,0.9,0.9],xrange=[0.0,1.0], $
             yrange=[0.0,1.0],psym=6, symsize=1.0
    endfor



; draw boxes= rejected data
    for i = 0,4  do begin
        wset,info.pl2.draw_box_ids[i]
        plot,xpt, ypt,color=line_colors[i], $
             xstyle=4,ystyle=4,position=[0.1,0.1,0.9,0.9],xrange=[0.0,1.0], $
             yrange=[0.0,1.0],psym = 2, symsize = 1.0
    endfor

endif

;_______________________________________________________________________
if(hcopy eq 1) then begin
    x = findgen(10) & y = findgen(10)
    plot,position = [0.1,0.1,0.95,0.25],x,y,/noerase,/nodata,xstyle=4,ystyle=4
    xyouts, 0.2,9,' Pixel Name   X      Y    Channel      Raw Frame      Ref Corrected ' 
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
        
    widget_control,info.pl2.xpixel_label[i],set_value=sx
    widget_control,info.pl2.ypixel_label[i],set_value=sy
    widget_control,info.pl2.channel_label[i],set_value=sc
endfor



maxvalue = max2pt[0,*] ; typeof data, num pixels
imaxvalue = iread[0,*] ; typeof data, num pixels
slopevalue = lin_fit[1,0,*] ; typeof data, num pixels
stdevvalue = stdev2pt[0,*]


maxvalue2 = max2pt_corrected[0,*] ; typeof data, num pixels
imaxvalue2 = iread_corrected[0,*] ; typeof data, num pixels
slopevalue2 = lin_fit_corrected[1,0,*] ; typeof data, num pixels
stdevvalue2 = stdev2pt_corrected[0,*]


maxvalue3 = max2pt_lcorrected[0,*] ; typeof data, num pixels
imaxvalue3 = iread_lcorrected[0,*] ; typeof data, num pixels
slopevalue3 = lin_fit_lcorrected[1,0,*] ; typeof data, num pixels
stdevvalue3 = stdev2pt_lcorrected[0,*]


   

for i = 0,4 do begin

    s1 = string ( maxvalue[0,i],format="(f7.1)")
    s2 = string ( imaxvalue[0,i],format="(i4)")
    s3 = string ( slopevalue[0,0,i],format="(f10.2)")
    s4 = string ( stdevvalue[0,i],format="(f10.1)")
    
    widget_control,info.pl2.info_label1[i],set_value=s1
    widget_control,info.pl2.info_label2[i],set_value=s2
    widget_control,info.pl2.info_label3[i],set_value=s3
    widget_control,info.pl2.info_label4[i],set_value=s4

    if(info.control.file_refcorrection_exist eq 1 )then begin 
        s1 = string ( maxvalue2[0,i],format="(f7.1)")
        s2 = string ( imaxvalue2[0,i],format="(i4)")
        s3 = string ( slopevalue2[0,0,i],format="(f10.2)")
        s4 = string ( stdevvalue2[0,i],format="(f10.1)")
    
        if(ch[0,i] eq 5) then begin 
            s1 = '  NA'
            s2 = '  NA'
            s3 = '  NA'
            s4 = '  NA'
        endif
        widget_control,info.pl2.info_label5[i],set_value=s1
        widget_control,info.pl2.info_label6[i],set_value=s2
        widget_control,info.pl2.info_label7[i],set_value=s3
        widget_control,info.pl2.info_label8[i],set_value=s4
    endif


    if(info.control.file_lc_exist eq 1 )then begin 
        s1 = string ( maxvalue3[0,i],format="(f7.1)")
        s2 = string ( imaxvalue3[0,i],format="(i4)")
        s3 = string ( slopevalue3[0,0,i],format="(f10.2)")
        s4 = string ( stdevvalue3[0,i],format="(f10.1)")
    
        if(ch[0,i] eq 5) then begin 
            s1 = '  NA'
            s2 = '  NA'
            s3 = '  NA'
            s4 = '  NA'
        endif
        widget_control,info.pl2.info_label5[i],set_value=s1
        widget_control,info.pl2.info_label6[i],set_value=s2
        widget_control,info.pl2.info_label7[i],set_value=s3
        widget_control,info.pl2.info_label8[i],set_value=s4
    endif
endfor


data = 0
stat = 0
xdata = 0
ydata = 0
dataslope = 0
statslope = 0
ch = 0

save_color = info.col_table
widget_control,info.Quicklook,set_uvalue = info


end



;***********************************************************************

