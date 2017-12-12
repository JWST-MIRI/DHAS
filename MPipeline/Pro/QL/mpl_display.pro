
@display_header.pro
;_______________________________________________________________________
;***********************************************************************
pro mpl_quit,event
;_______________________________________________________________________

widget_control,event.top, Get_UValue = cinfo	
widget_control,cinfo.info.QuickLook,Get_Uvalue = info

widget_control,info.PixelLook,/destroy


end
;_______________________________________________________________________

pro mpl_update_display,info


    reading_slope_processing,info.control.filename_slope,$
                             slope_exists,start_fit,end_fit,low_sat,$
                             high_sat,do_bad,use_psm,use_rscd,use_lin,use_dark,$
                             subrp,deltarp,even_odd,$
                             badfile,psm_file, rscd_file,$
                             lin_file,dark_file,$
                             slope_unit,frame_time,gain



    info.pl.slope_unit = slope_unit
    info.pl.frame_time = frame_time
    info.pl.gain = gain
    info.pl.start_fit = start_fit
    info.pl.end_fit = end_fit

    info.pl.use_rscd = use_rscd
    info.pl.use_rscd_file = rscd_file

    info.pl.use_lin = use_lin
    info.pl.use_lin_file = lin_file

    info.pl.use_dark = use_dark
    info.pl.use_dark_file = dark_file


    info.pl.deltarow_evenodd_flag = even_odd
    info.pl.refpixel_option = subrp
    
    info.pl.high_sat = float(high_sat)
    info.pl.delta_row_even_odd = deltarp

    info.pl.use_bad_pixel_file = do_bad
    info.pl.bad_file = badfile

    info.pl.use_psm = use_psm
    info.pl.use_psm_file = psm_file

    slope_exist = ' Reduction Parameters: '
   
    slope_frame_a = 'Frame to Start Fit on ' + strcompress(string(start_fit),/remove_all)
    slope_frame_b = 'Frame to End Fit on   ' + strcompress(string(end_fit),/remove_all)

    if(info.data.coadd eq 1) then begin 
        slope_frame_a = 'Int to Start Coadding ' + strcompress(string(info.pl.start_fit),/remove_all)
        slope_frame_b = 'Int to End Coadding   ' + strcompress(string(info.pl.end_fit),/remove_all)
    endif

    slope_high_dn = 'Drop Values greater than (DN) ' + strcompress(string(info.pl.high_sat),/remove_all)

    lin = ' ' 
    if(info.pl.use_lin  eq 1) then $
      lin ="Applied linearity correction: " + info.pl.use_lin_file

    psm =' ' 
    if(info.pl.use_psm  eq 1) then $
      psm ="Applied the pixel saturation mask " + info.pl.use_psm_file
    
    bad_pixel = ' ' 
    if(info.pl.use_bad_pixel_file eq 1 ) then $ 
        bad_pixel ="Applied file containing list of Bad pixels" + badfile

widget_control,info.pl.SlopeLabel,set_value = slope_exist
widget_control,info.pl.SlopeViewButton, sensitive=1

widget_control,info.pl.slope_param[0],set_value = slope_frame_a
widget_control,info.pl.slope_param[1],set_value = slope_frame_b
widget_control,info.pl.slope_param[2],set_value = slope_high_dn
widget_control,info.pl.slope_param[3],set_value = psm
widget_control,info.pl.slope_param[4],set_value = lin
widget_control,info.pl.slope_param[5],set_value = bad_pixel

end
;_______________________________________________________________________
;***********************************************************************
pro mpl_calculate_ramp,ind,info

iramp = info.data.nramps
nint = info.data.nints
num = info.pltrack.num_group[ind]

slope = (*info.pltrack.pslope)
zeropt = (*info.pltrack.pzeropt)
calramp = (*info.pltrack.pcalramp)                
xvalue = findgen(info.data.nramps) + 1 


for k = 0,num-1 do begin ; 

    for i = 0, nint - 1 do begin
        for j = 0, iramp-1 do begin
            if(info.data.coadd ne 1) then begin 
                if( finite(slope[ind,i,k]) ) then begin
                    slope_dn_frame = slope[ind,i,k]* info.pl.frame_time

                    calramp[ind,i,j,k] = xvalue[j] * slope_dn_frame + zeropt[ind,i,k]
                    ;print,'slope',slope[ind,i,k],slope_dn_frame,zeropt[ind,i,k],info.pl.frame_time, calramp[ind,i,j,k]
                endif else begin
                    calramp[ind,i,j,k] = zeropt[ind,i,k]
                endelse
            endif else begin
                calramp[ind,i,j,k] =slope[ind,0,k]
            endelse
                
        endfor


    endfor
endfor




stat = (*info.pltrack.pstatcalramp)
for integ = 0, info.data.nints -1 do begin
    for k = 0, num-1 do begin
        sdata = calramp[ind,integ,*,k]
        smax = max(sdata)
        smin = min(sdata)
        stat[ind,integ,k,0] = smin
        stat[ind,integ,k,1] = smax
    endfor
endfor

if ptr_valid (info.pltrack.pstatcalramp) then ptr_free,info.pltrack.pstatcalramp
info.pltrack.pstatcalramp = ptr_new(stat)
stat= 0 ; free memory


if ptr_valid (info.pltrack.pcalramp) then ptr_free,info.pltrack.pcalramp
info.pltrack.pcalramp = ptr_new(calramp)
calramp= 0 ; free memory

end



;_______________________________________________________________________
;***********************************************************************
;***********************************************************************
pro mpl_get_randomset, info
; get a random set of pixels
;_______________________________________________________________________

info.pl.group = 2
seed = info.pl.randomstart
info.pl.randomstart = info.pl.randomstart + 1

limit = 1023
ranvalue = 10

if(info.data.subarray ne 0) then limit = info.data.image_xsize-1

if(info.data.subarray eq 6 ) then ranvalue = 4
if(info.data.subarray eq 7 ) then ranvalue = 2


x = randomu(seed)

x1 = fix(x * limit)
ch = 0
get_channel,x1,ch

base = [1,2,3,4,5]
xvalue= intarr(5) & yvalue = intarr(5) 
for i = 0,4 do begin
  y = randomu(seed+ranvalue)
  ytest =  fix(y * limit)


  if(ytest gt limit) then begin
     while(ytest gt limit) do begin
       z = fix( randomu(seed)* ranvalue)
       ytest  = ytest - (4 * z) 
     endwhile
 endif
 if(ytest le 0) then ytest = i+1
  yvalue[i] = ytest


  z = fix( randomu(seed)* ranvalue)
  z = z + (ranvalue * i)

  x  = 4 * z + (ch - i)
  chnew = 0
  get_channel,x, chnew

  if(x gt limit) then begin
     ;print,' Greater than',limit,x
     while(x gt limit) do begin
       z = fix( randomu(seed)* ranvalue)
       x  = x - (4 * z) 
       ;print,'new x',x
     endwhile
 endif
 if(x le 0) then x = i+1
  xvalue[i] = x
endfor

;print,' random set ',xvalue,yvalue

xdata = (*info.pltrack.px)
ydata = (*info.pltrack.py)
ch = (*info.pltrack.pch)
ref = (*info.pltrack.pref)

xdata[2,0:4] = xvalue[*]  
ydata[2,0:4] = yvalue[*]
ch[2,0:4] = chnew[*]
ref[2,0:4] = 0 ; set then to regular pixels


;get_channel should never return channel 5 - but it I change this in
;the future need to remember to set ref to 1
 
index = where(chnew eq 5,nch5)
if(nch5 gt 1) then ref[2,index] = 1



info.pltrack.num_group[2] = 5

if ptr_valid (info.pltrack.px) then ptr_free,info.pltrack.px
info.pltrack.px = ptr_new(xdata)
xdata = 0 ; free memory    
xvalue = 0

if ptr_valid (info.pltrack.py) then ptr_free,info.pltrack.py
info.pltrack.py= ptr_new(ydata)
ydata = 0 ; free memory    
yvalue = 0


if ptr_valid (info.pltrack.pref) then ptr_free,info.pltrack.pref
info.pltrack.pref = ptr_new(ref)
ref = 0 ; free memory    


if ptr_valid (info.pltrack.pch) then ptr_free,info.pltrack.pch
info.pltrack.pch = ptr_new(ch)
chnew = 0 ; free memory    
ch= 0

get_pltracking,2,info

if(info.pl.slope_exists) then begin
    get_pltracking_slope,info.pl.group, info
    for k = 0, 3 do begin
        mpl_calculate_ramp,k,info
    endfor
endif

if(info.control.file_refcorrection_exist eq 1) then $
  get_pltracking_refcorrected,2,info

if(info.control.file_ids_exist eq 1) then $
  get_pltracking_ids,2,info

if(info.control.file_lc_exist eq 1) then $
  get_pltracking_lc,2,info

if(info.control.file_mdc_exist eq 1) then $
  get_pltracking_mdc,2,info

if(info.control.file_reset_exist eq 1) then $
  get_pltracking_reset,2,info

if(info.control.file_lastframe_exist eq 1) then $
  get_pltracking_lastframe,2,info



end


;_______________________________________________________________________
;***********************************************************************
pro mpl_event,event
;_______________________________________________________________________
; the event manager for the mpl_display.pro (first look base widget)

Widget_Control,event.id,Get_uValue=event_name
widget_control,event.top, Get_UValue = cinfo
widget_control,cinfo.info.Quicklook,Get_Uvalue = minfo

; if the user has changed the size of the widget window - resize
if (widget_info(event.id,/TLB_SIZE_EVENTS) eq 1) then begin
    minfo.pl.xwindowsize = event.x
    minfo.pl.ywindowsize = event.y
    minfo.pl.uwindowsize = 1
    widget_control,event.top,set_uvalue = cinfo
    widget_control,cinfo.info.Quicklook,set_uvalue = minfo
    mpl_display,minfo,status
    return
endif
cinfo.info = minfo
    case 1 of
    (strmid(event_name,0,7) EQ 'vheader') : begin
        display_header,minfo,0
    end

    (strmid(event_name,0,7) EQ 'sheader') : begin
        if(not minfo.pl.slope_exists) then begin
            ok = dialog_message(" No slope image exists",/Information)
        endif else begin
            j = minfo.pl.int_range[0]
            display_header,minfo,j
        endelse

    end

    (strmid(event_name,0,7) EQ 'vrefout') : begin
        mirql_display_images,minfo.control.filename_raw,minfo.pl.int_range[0]-1,0,minfo
    end

    (strmid(event_name,0,7) EQ 'vrefpix') : begin
        if(minfo.data.subarray ne 0 and minfo.data.colstart ne 1 ) then begin
            result = dialog_message(" This subarray Data does not have reference pixels ",/error )
            return
        endif
        read_refpixel,minfo
        mrp_setup_channel,minfo
        mrp_display,minfo
    end

    (strmid(event_name,0,7) EQ 'print_P') : begin
        print_pixel_look,minfo
        
    end



    (strmid(event_name,0,9) EQ 'ViewSlope') : begin
        setup_slope_image,minfo
        msql_display_slope,minfo
    end

    (strmid(event_name,0,9) EQ 'ViewFrame') : begin

        minfo.image.integrationNO = minfo.control.int_num_save
        minfo.image.rampNO = minfo.control.frame_start_save
        minfo.control.int_num = minfo.control.int_num_save

        find_image_binfactor,minfo

        minfo.image.x_pos =(minfo.data.image_xsize/minfo.image.binfactor)/2.0
        minfo.image.y_pos = (minfo.data.image_ysize/minfo.image.binfactor)/2.0
        setup_frame_image_StepA,minfo
        setup_frame_pixelvalues,minfo
        setup_frame_image_StepB,minfo


        mql_display_images,minfo
    end


    (strmid(event_name,0,9) EQ 'CalQSlope') : begin
        minfo.control.set_scidata = 1
	mql_setup_miri_sloper,minfo,status
        if(status ne 0) then return
        minfo.ms.quickslope = 1
        mql_run_miri_sloper,minfo,status
        if(status eq 1) then return 

        minfo.pl.slope_exists = 1
        mpl_update_display,minfo

        widget_control,minfo.pl.OverPlotSlopeLabel, set_value = 'Plot Fitted Slope'
        
        minfo.pl.OverplotSlopeID[0] = Widget_button(minfo.pl.OverPlotSlopeBase, Value = 'Yes',uvalue = 'overslope1')
        minfo.pl.OverplotSlopeID[1] = Widget_Button(minfo.pl.OverPlotSlopeBase, Value = 'No',uvalue = 'overslope2')
        widget_control,minfo.pl.OverplotSlopeID[0],Set_Button = 0
        widget_control,minfo.pl.OverplotSlopeID[1],Set_Button = 1

        get_pltracking_slope,minfo.pl.group, minfo
        for k = 0, 3 do begin
            mpl_calculate_ramp,k,minfo
        endfor


        mpl_update_plot,minfo
        setup_slope_image,minfo
        msql_display_slope,minfo
    end

    (strmid(event_name,0,9) EQ 'CalDSlope') : begin
        minfo.control.set_scidata = 1
	mql_setup_miri_sloper,minfo,status
        if(status ne 0) then return
        minfo.control.set_scidata = 0
        mql_run_miri_sloper,minfo,status
        if(status eq 1) then return
 
        minfo.pl.slope_exists = 1
        get_pltracking_slope,minfo.pl.group, minfo
        for k = 0, 3 do begin
            mpl_calculate_ramp,k,minfo
        endfor
        mpl_update_display,minfo
        mpl_update_plot,minfo
        setup_slope_image,minfo
        msql_display_slope,minfo
    end


    (strmid(event_name,0,8) EQ 'CalSlope') : begin
        minfo.control.set_scidata = 1
	mql_setup_miri_sloper,minfo,status
        if(status ne 0) then return
        minfo.control.set_scidata = 0
        minfo.display_widget = 2
        mql_edit_miri_sloper_parameters,minfo
        mpl_update_display,minfo
        widget_control,event.top,set_uvalue = cinfo
        widget_control,cinfo.info.Quicklook,set_uvalue = minfo

        return

    end
;_______________________________________________________________________
; change x and y range of plot
; if change range then also change the button to 'User Set Scale'
;_______________________________________________________________________
    (strmid(event_name,0,5) EQ 'range') : begin
        num = fix(strmid(event_name,5,1)) -1

        if(minfo.pl.default_range[num] eq 0 ) then begin 
            widget_control,minfo.pl.recomputeID[num],set_value=' Plot  Range'
            minfo.pl.default_range[num] = 1
        endif
        mpl_update_plot,minfo

    end

    (strmid(event_name,0,2) EQ 'cr') : begin
        num = fix(strmid(event_name,2,1))-1
        if(strmid(event_name,4,1) EQ 'b') then begin ; check bottom
            minfo.pl.graph_range[num,0] = event.value
            widget_control,minfo.pl.rangeID[num,1],get_value=itemp
            minfo.pl.graph_range[num,1] = itemp
        endif

        if(strmid(event_name,4,1) EQ 't') then begin ; check bottom
            minfo.pl.graph_range[num,1] = event.value
            widget_control,minfo.pl.rangeID[num,0],get_value=itemp
            minfo.pl.graph_range[num,0] = itemp
        endif

        minfo.pl.default_range[num] = 0
        widget_control,minfo.pl.recomputeID[num],set_value='Default Range'

	for i = 0,1 do begin
	  if(minfo.pl.graph_range[i,0] gt minfo.pl.graph_range[i,1] ) then begin

            widget_control,minfo.pl.recomputeID[i],set_value=' Plot Range '	
	     minfo.pl.default_range[i]=1 
          endif	
	endfor

        mpl_update_plot,minfo
       
    end
;_______________________________________________________________________
; Change Integration Range 

    (strmid(event_name,0,3) EQ 'int') : begin
; changed by typing a new value
        
        if(strmid(event_name,4,4) eq 'chng') then begin
            num = fix(strmid(event_name,9,1))-1
            minfo.pl.int_range[num] = event.value
        endif


; check if the <> buttons were used
        if(strmid(event_name,4,4) eq 'move') then begin
            value = intarr(2)
            value[0] = minfo.pl.int_range[0]
            value[1] = minfo.pl.int_range[1]

            if(strmid(event_name,9,1) eq 'u') then begin
                value[0] = value[0] + 1
                value[1] = value[1] + 1
            endif
            if(strmid(event_name,9,1) eq 'd') then begin
                value[0] = value[0] - 1
                value[1] = value[1] -1
            endif

            if(value[0] le 0 ) then value[0] = minfo.data.nints
            if(value[1] le 0 ) then value[1] = minfo.data.nints

            if(value[0] gt  minfo.data.nints ) then value[0] =1
            if(value[1] gt  minfo.data.nints ) then value[1] = 1

            minfo.pl.int_range[0] = value[0]            
            minfo.pl.int_range[1] = value[1]            
        endif

; check if plot all integrations is typed

        if(strmid(event_name,4,4) eq 'grab') then begin
            minfo.pl.int_range[0] = 1            
            minfo.pl.int_range[1] = minfo.data.nints
            
            minfo.pl.overplot_pixel_int = 0

            if(minfo.data.coadd eq 1) then begin 
                minfo.pl.int_range[0] = minfo.pl.start_fit            
                minfo.pl.int_range[1] = minfo.pl.end_fit            
            endif
                
        endif            

; overplot integrations

        if(strmid(event_name,4,4) eq 'over') then begin
            minfo.pl.int_range[0] = 1            
            minfo.pl.int_range[1] = minfo.data.nints
            minfo.pl.overplot_pixel_int = 1

            if(minfo.data.coadd eq 1) then begin 
                minfo.pl.int_range[0] = minfo.pl.start_fit            
                minfo.pl.int_range[1] = minfo.pl.end_fit            
            endif
        endif            


; Check limits for the above options for changing the integration range
; lower limit 1
; upper limit minfo.data.nints

        for i = 0,1 do begin
            if(minfo.pl.int_range[i] le 0) then minfo.pl.int_range[i] = 1
            if(minfo.pl.int_range[i] gt minfo.data.nints) then $
              minfo.pl.int_range[i] = minfo.data.nints
        endfor
        if(minfo.pl.int_range[0] gt minfo.pl.int_range[1] ) then begin
            minfo.pl.int_range[*] = 1
        endif	
	
        mpl_update_plot,minfo

        widget_control,minfo.pl.IrangeID[0],set_value=minfo.pl.int_range[0]
        widget_control,minfo.pl.IrangeID[1],set_value=minfo.pl.int_range[1]

    	s1 = strcompress( string ( fix(minfo.pl.int_range[0])),/remove_all)
    	s2 = strcompress( string ( fix(minfo.pl.int_range[1])),/remove_all)
       iramp = minfo.data.nramps	
        ftitle = "Integration #: " + s1 + ' to '  + s2 +  $	
         "  Num of Frames/Integration: " + strtrim(string(fix(iramp)),2)     
	widget_control,minfo.pl.frametitle_label,set_value = ftitle

    end
;_______________________________________________________________________
    (strmid(event_name,0,2) EQ 'on') : begin
        num = fix(strmid(event_name,2,1))-1
        minfo.pl.onvalue[num] = 1
        widget_control, minfo.pl.offButton[num],Set_Button = 0
        widget_control, minfo.pl.onButton[num],Set_Button = 1
        mpl_update_plot,minfo
    end

    (strmid(event_name,0,3) EQ 'off') : begin
        num = fix(strmid(event_name,3,1))-1
        minfo.pl.onvalue[num] = 0
        widget_control, minfo.pl.onButton[num],Set_Button = 0
        widget_control, minfo.pl.offButton[num],Set_Button = 1

        mpl_update_plot,minfo
    end


    (strmid(event_name,0,7) EQ 'allplot') : begin
        type = fix(strmid(event_name,7,1))
        if(type eq 1) then begin
            widget_control, minfo.pl.noneButton,Set_Button = 0
            for i = 0,4 do begin 
                minfo.pl.onvalue[i] = 1
                widget_control, minfo.pl.onButton[i],Set_Button = 1
                widget_control, minfo.pl.offButton[i],Set_Button = 0
            endfor
        endif
        if(type eq 2) then begin
            widget_control, minfo.pl.allButton,Set_Button = 0
            for i = 0,4 do begin 
                minfo.pl.onvalue[i] = 0
                widget_control, minfo.pl.onButton[i],Set_Button = 0
                widget_control, minfo.pl.offButton[i],Set_Button = 1
            endfor
        endif
            
        mpl_update_plot,minfo

    end
;_______________________________________________________________________
; Get a different Pixel set - containing 4 pixels
; Set A, Set B, Random and User Slected

    (strmid(event_name,0,4) EQ 'pset') : begin
        num = fix(strmid(event_name,4,1))
       
	if(num eq 2 and minfo.pl.read_setB eq 0) then begin 
              minfo.pl.group = 1
              get_pltracking,minfo.pl.group,minfo
              if(minfo.pl.slope_exists eq 1) then begin 
                  get_pltracking_slope,1, minfo

                  mpl_calculate_ramp,1,minfo
              endif

              minfo.pl.read_setB = 1


              if(minfo.control.file_refcorrection_exist eq 1) then $
                get_pltracking_refcorrected,1,minfo

              if(minfo.control.file_ids_exist eq 1) then $
                get_pltracking_ids,1,minfo

              if(minfo.control.file_lc_exist eq 1) then $
                get_pltracking_lc,1,minfo

              if(minfo.control.file_mdc_exist eq 1) then $
                get_pltracking_mdc,1,minfo

              if(minfo.control.file_reset_exist eq 1) then $
                get_pltracking_reset,1,minfo

              if(minfo.control.file_lastframe_exist eq 1) then $
                get_pltracking_lastframe,1,minfo
        endif

        if(num eq 4) then begin
            display_userset,1,minfo.pl.group,minfo
        endif



        if(num ne 4) then minfo.pl.group = num -1
	if(num eq 3) then  begin
            mpl_get_randomset,minfo

        endif

        if(num ne 4) then mpl_update_plot,minfo

    end

    
;_______________________________________________________________________
; Print the pixel values out
    (strmid(event_name,0,8) eq 'pixprint') : begin

        if(minfo.data.subarray eq 0) then read_pltracking_refpixel,minfo
        if(minfo.data.subarray ne 0) then get_pltracking,minfo.pl.group,minfo

        mpl_display_pixel_values,minfo
    end
;_______________________________________________________________________
; Print the slope values out
    (strmid(event_name,0,6) eq 'getall') : begin
        mpl_display_slope_values,minfo
    end
    
;_______________________________________________________________________

    (strmid(event_name,0,7) eq '2ptdiff') : begin
        mpl_2pt_diff,minfo
    end
;_______________________________________________________________________
; overplot frame values

    (strmid(event_name,0,9) eq 'overframe') : begin
        num = fix(strmid(event_name,9,1))
        if(num eq 1) then begin
            minfo.pl.overplot_frame = 1
            widget_control,minfo.pl.overplotFrameID[0],set_button = 1
            widget_control,minfo.pl.overplotFrameID[1],set_button = 0

        endif

        if(num eq 2) then begin
            minfo.pl.overplot_frame = 0
            widget_control,minfo.pl.overplotFrameID[0],set_button = 0
            widget_control,minfo.pl.overplotFrameID[1],set_button = 1
        endif

        mpl_update_plot,minfo
    end


;_______________________________________________________________________
; overplot slope

    (strmid(event_name,0,9) eq 'overslope') : begin
        num = fix(strmid(event_name,9,1))
        if(num eq 1) then begin
            minfo.pl.overplot_slope = 1
            widget_control,minfo.pl.overplotSlopeID[1],set_button = 0
            widget_control,minfo.pl.overplotSlopeID[0],set_button = 1
        endif

        if(num eq 2) then begin
            minfo.pl.overplot_slope= 0
            widget_control,minfo.pl.overplotSlopeID[0],set_button = 0
            widget_control,minfo.pl.overplotSlopeID[1],set_button = 1
        endif


        mpl_update_plot,minfo
    end

;_______________________________________________________________________
; overplot reference Corrected data 

    (strmid(event_name,0,7) eq 'overref') : begin
        num = fix(strmid(event_name,7,1))
        if(num eq 1) then begin
            minfo.pl.overplot_refcorrect = 1
            widget_control,minfo.pl.overplotRefID[0],set_button = 1
            widget_control,minfo.pl.overplotRefID[1],set_button = 0
        endif

        if(num eq 2) then begin
            minfo.pl.overplot_refcorrect= 0
            widget_control,minfo.pl.overplotRefID[0],set_button = 0
            widget_control,minfo.pl.overplotRefID[1],set_button = 1
        endif

        mpl_update_plot,minfo
    end
    
;_______________________________________________________________________

;_______________________________________________________________________
; Mark cosmic rays and noise

    (strmid(event_name,0,6) eq 'overcr') : begin
        num = fix(strmid(event_name,6,1))
        if(num eq 1) then begin
            minfo.pl.overplot_ids = 1
            widget_control,minfo.pl.overplotcrID[0],set_button = 1
            widget_control,minfo.pl.overplotcrID[1],set_button = 0
        endif

        if(num eq 2) then begin
            minfo.pl.overplot_ids= 0
            widget_control,minfo.pl.overplotcrID[0],set_button = 0
            widget_control,minfo.pl.overplotcrID[1],set_button = 1
        endif

        mpl_update_plot,minfo
    end


;_______________________________________________________________________
; Plot linearity corrected data

    (strmid(event_name,0,6) eq 'overlc') : begin
        num = fix(strmid(event_name,6,1))
        if(num eq 1) then begin
            minfo.pl.overplot_lc = 1
            widget_control,minfo.pl.overplotlcID[0],set_button = 1
            widget_control,minfo.pl.overplotlcID[1],set_button = 0
        endif

        if(num eq 2) then begin
            minfo.pl.overplot_lc= 0
            widget_control,minfo.pl.overplotlcID[0],set_button = 0
            widget_control,minfo.pl.overplotlcID[1],set_button = 1
        endif

        mpl_update_plot,minfo
    end

;_______________________________________________________________________
; Plot dark corrected data

    (strmid(event_name,0,7) eq 'overmdc') : begin
        num = fix(strmid(event_name,7,1))
        if(num eq 1) then begin
            minfo.pl.overplot_mdc = 1
            widget_control,minfo.pl.overplotmdcID[0],set_button = 1
            widget_control,minfo.pl.overplotmdcID[1],set_button = 0
        endif

        if(num eq 2) then begin
            minfo.pl.overplot_mdc= 0
            widget_control,minfo.pl.overplotmdcID[0],set_button = 0
            widget_control,minfo.pl.overplotmdcID[1],set_button = 1
        endif

        mpl_update_plot,minfo
    end

;_______________________________________________________________________
; Plot reset corrected data
    (strmid(event_name,0,9) eq 'overreset') : begin
        num = fix(strmid(event_name,9,1))
        if(num eq 1) then begin
            minfo.pl.overplot_reset = 1
            widget_control,minfo.pl.overplotresetID[0],set_button = 1
            widget_control,minfo.pl.overplotresetID[1],set_button = 0
        endif

        if(num eq 2) then begin
            minfo.pl.overplot_reset= 0
            widget_control,minfo.pl.overplotresetID[0],set_button = 0
            widget_control,minfo.pl.overplotresetID[1],set_button = 1
        endif
        mpl_update_plot,minfo
    end
;_______________________________________________________________________
; Plot lastframe corrected data
    (strmid(event_name,0,13) eq 'overlastframe') : begin
        num = fix(strmid(event_name,13,1))
        if(num eq 1) then begin
            minfo.pl.overplot_lastframe = 1
            widget_control,minfo.pl.overplotlastframeID[0],set_button = 1
            widget_control,minfo.pl.overplotlastframeID[1],set_button = 0
        endif

        if(num eq 2) then begin
            minfo.pl.overplot_lastframe= 0
            widget_control,minfo.pl.overplotlastframeID[0],set_button = 0
            widget_control,minfo.pl.overplotlastframeID[1],set_button = 1
        endif

        mpl_update_plot,minfo
    end
;_______________________________________________________________________
endcase
widget_control,event.top,set_uvalue = cinfo
cinfo.info = minfo

widget_control,cinfo.info.Quicklook,set_uvalue = minfo
end



; _______________________________________________________________________
;***********************************************************************
pro mpl_display,info,rstatus

color6
rstatus = 0
;info.control.frame_start = info.control.frame_start_save
;info.control.int_num = info.control.int_num_save

; _______________________________________________________________________
; This is the main widget program controlling first look parameters

; _______________________________________________________________________
status = 0
; group : 0 pixel file first 4, 1 pixel file second 4,  2 random set, 3 user defined
info.pl.group = 0 ; default to pixel file

if(info.pl.uwindowsize eq 0) then begin ; info.pl.usizewindow=0 default calling
                                ; info.pl.usizewindow=1 user resized
                                ; window- so no need to call
                                ; setup/reading routines 


; set - if using default pixel file values - set A or set B

    reading_header,info,status ; read header first - need to know subarray type
    header_setup,1,info
    read_pixel_tracking_file,info,status,error_message
    if(status ne 0) then begin 
        result = dialog_message(error_message,/error)
        return
    endif


    reading_pltracking,info,status


    slope_exist = 0
    do_bad = 0
    use_psm = 0
    use_rscd = 0 
    bad_file = '' 
    psm_file = ''
    rscd_file = ' ' 
    lin_file = ' ' 
    dark_file = ' ' 
    subro = 0
    subrp = 0
    refcorrection = 0
    even_odd = 0
    delta_row  = 0
    slope_unit  = 0
    start_fit = 0 & end_fit = 0
    low_sat = 0 & high_sat = 0
    gain = 0.0
    deltarp = 0
    frame_time = 0.0



    reading_slope_processing,info.control.filename_slope,$
                             slope_exists,start_fit,end_fit,low_sat,$
                             high_sat,do_bad,use_psm,use_rscd,use_lin,use_dark,$
                             subrp,deltarp,even_odd,$
                             bad_file,psm_file, rscd_file,$
                             lin_file,dark_file,$
                             slope_unit,frame_time,gain
    
    info.pl.slope_unit = slope_unit
    info.pl.frame_time = frame_time
    info.pl.gain = gain
    info.pl.start_fit = start_fit
    info.pl.end_fit = end_fit

    info.pl.high_sat = high_sat


    info.pl.deltarow_evenodd_flag = even_odd
    info.pl.refpixel_option = subrp
    
    info.pl.delta_row_even_odd = deltarp

    info.pl.use_bad_pixel_file = do_bad
    info.pl.bad_file = bad_file


    info.pl.use_psm_file = use_psm
    info.pl.use_psm_file = psm_file

    info.pl.use_rscd = use_rscd
    info.pl.use_rscd_file = rscd_file
        
    info.pl.use_lin = use_lin
    info.pl.use_lin_file = lin_file
    info.pl.use_dark = use_dark
    info.pl.use_dark_file = dark_file




    if(slope_exists eq 1) then begin 

        get_pltracking_slope,0, info
        mpl_calculate_ramp,0,info

        header_setup_slope,info
    endif else begin
        info.pl.start_fit = 1
        info.pl.end_fit = info.data.nramps
    endelse

    if(info.control.file_refcorrection_exist eq 1) then begin
        get_pltracking_refcorrected,0,info
    endif

    if(info.control.file_ids_exist eq 1)  then begin
        get_pltracking_ids,0,info
    endif

    if(info.control.file_lc_exist eq 1)  then begin
        get_pltracking_lc,0,info
    endif

    if(info.control.file_mdc_exist eq 1)  then begin
        get_pltracking_mdc,0,info
     endif

    if(info.control.file_reset_exist eq 1)  then begin
        get_pltracking_reset,0,info
     endif

    if(info.control.file_lastframe_exist eq 1)  then begin
        get_pltracking_lastframe,0,info
    endif

endif else slope_exists  = info.pl.slope_exists


; _______________________________________________________________________
window,1
wdelete,1
if(XRegistered ('mpl')) then begin

    widget_control,info.PixelLook,/destroy
endif

; widget window parameters
xwidget_size = 1550
ywidget_size = 1000

xsize_scroll = 1300
ysize_scroll = 1000


if(info.pl.uwindowsize eq 1) then begin
    xsize_scroll = info.pl.xwindowsize
    ysize_scroll = info.pl.ywindowsize
endif


if(info.control.x_scroll_window lt xsize_scroll) then xsize_scroll = info.control.x_scroll_window
if(info.control.y_scroll_window lt ysize_scroll) then ysize_scroll = info.control.y_scroll_window

if(xsize_scroll ge xwidget_size) then  xsize_scroll = xwidget_size-10
if(ysize_scroll ge ywidget_size) then  ysize_scroll = ywidget_size-10


stitle = "MIRI Pixel Look Tool " + info.version
PixelLook = widget_base(title=stitle,$
                        col = 1,mbar = menuBar,group_leader = info.QuickLook,$
                        xsize =  xwidget_size,$
                        ysize=   ywidget_size,/scroll,$
                        x_scroll_size= xsize_scroll,$
                        y_scroll_size = ysize_scroll,$
                        xoffset = 100, /TLB_SIZE_EVENTS)

info.PixelLook = PixelLook
;_______________________________________________________________________
;********
; build the menubar
;********
QuitMenu = widget_button(menuBar,value="Quit",font = info.font2)
quitbutton = widget_button(quitmenu,value="Quit",event_pro='mpl_quit')


hMenu = widget_button(menuBar,value="View FITS Header",font = info.font2)
hrMenu = widget_button(hmenu,value="View Science Image Header",uvalue = 'vheader')
hsMenu = widget_button(hmenu,value="View Slope Header",uvalue='sheader')
ROMenu = widget_button(menuBar,value="View Reference Output Image",font = info.font2)

ROButton = widget_button(ROMenu,$
                         value="View Reference Output Image",font = info.font2,$
                         uvalue = 'vrefout')

RPMenu = widget_button(menubar,value = "View Reference Pixels",font=info.font2)

RPbutton = widget_button(RPMenu,$
                         value = "View Reference Pixels",font=info.font2,$
                         uvalue='vrefpix')

Fbutton = widget_button(menubar,value = "View Frames",font=info.font2)
VFbutton = widget_button(Fbutton,$
                         value = "View Frames",font=info.font2,$
                         uvalue='ViewFrame')


PMenu = widget_button(menuBar,value="Print",font = info.font2)
PbuttonR = widget_button(Pmenu,value = "Print Pixel Plot",uvalue='print_P')


PipeMenu = widget_button(menuBar,value="Pipeline",/Menu,font=info.font2)

;findQuickDefaultButton = widget_button(PipeMenu,$
;                                value="Quick Slope processing",$
;                                uvalue='CalQSlope',font=info.font2)

findSlopeDefaultButton = widget_button(PipeMenu,$
                                value=" Default Slope processing",$
                                uvalue='CalDSlope',font=info.font2)

findSlopeButton = widget_button(PipeMenu,$
                                value=" User selects options for slope processing",$
                                uvalue='CalSlope',font=info.font2)

;_______________________________________________________________________
; defaults to start with  
int_range = intarr(2) 
int_range[0] = 1  ; initialize to look at first integration
int_range[1] = 1

if(info.data.coadd eq 1) then begin
	int_range[0] = info.pl.start_fit
	int_range[1] = info.pl.end_fit
endif

info.pl.int_range[*] = int_range[*]


;_______________________________________________________________________  
info.refpixel.readin =0
;_______________________________________________________________________  


svalue = " A sample of pixel values through an integration:  " + info.control.filename_raw
tlabelID = widget_label(PixelLook,value =svalue ,/align_left,$
                        font=info.font5)
iramp = info.data.nramps
istart =1
iend = 1
if(info.data.coadd) then begin 
    istart = 2
    iend = info.data.nints
endif
ftitle = "Integration #:  " + strcompress(string(istart),/remove_all)  + $
" to" +  strcompress(string(iend),/remove_all)   + $
         "  Num of Frames/Integration: " + strtrim(string(fix(iramp)),2)     

;_______________________________________________________________________
widget_control,info.filetag[0] ,set_value = 'Raw File name: ' + info.control.filename_raw 
widget_control,info.typetag, set_value ='Science Image ' 

si = strcompress(string(info.data.nints),/remove_all)
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


graphID_master1 = widget_base(info.PixelLook,row=1)
graphID_master22 = widget_base(info.PixelLook,row=1)
graphID_master2 = widget_base(info.PixelLook,row=1)


info.pl.graphID1 = widget_base(graphID_master1,col=1)
SoptionID =widget_base(graphID_master1,col=1) 
ChangeID = widget_base(graphID_master2,col=1)

;_______________________________________________________________________  

;*****
;graph 1,1
;*****

info.pl.graphID = widget_draw(info.pl.graphID1,$
                              xsize =info.plotsize1*2.5,$ 
                              ysize =info.plotsize1*2,$
                              retain=info.retn)
;_______________________________________________________________________
; Change values - section
;_______________________________________________________________________
; button to change integrations

info.pl.frametitle_label = widget_label(SoptionID, $
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


IAllButton = Widget_button(move_base, Value = 'Plot All Integrations',uvalue = 'int_grab_all')
widget_control,IAllButton,Set_Button = 0

info.pl.overplot_pixel_int = 0

IAllButton = Widget_button(move_base, Value = 'Over Plot Integrations',uvalue = 'int_over_plot')
widget_control,IAllButton,Set_Button = 0

info.pl.IrangeID = IrangeID

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

recomputeID[0] = widget_button(xlabel_base,value=' Plot Range ',$font=info.font4,$
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

recomputeID[1] = widget_button(ylabel_base,value=' Plot Range ',$font=info.font4,$
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

info.pl.rangeID = rangeID
info.pl.recomputeID = recomputeID
info.pl.default_range[*] = 1
info.pl.graph_range = graph_range

;_______________________________________________________________________

slope_exist = 'No Reduced Slope File Exists  '
slope_frame_a = '                            '
slope_frame_b = '                            '

slope_high_dn = '                            '
psm = '                                 '    
lin = '                                 '
rscd = '                                 '

bad_pixel ='                                                                 '
if(slope_exists eq 1) then begin 
    slope_exist = ' Reduction Paramters:'
   
    slope_frame_a = 'Frame to Start Fit on ' + strcompress(string(info.pl.start_fit),/remove_all)
    slope_frame_b = 'Frame to End Fit on   ' + strcompress(string(info.pl.end_fit),/remove_all)

    if(info.data.coadd eq 1) then begin 
        slope_frame_a = 'Int to Start Coadding ' + strcompress(string(info.pl.start_fit),/remove_all)
        slope_frame_b = 'Int to End Coadding   ' + strcompress(string(info.pl.end_fit),/remove_all)
    endif

    slope_high_dn = 'Drop Values greater than (DN) ' + strcompress(string(info.pl.high_sat),/remove_all)



    if(info.pl.use_psm  eq 1) then $
      psm ="Applied the pixel saturation mask " + info.pl.use_psm_file

    if(info.pl.use_lin  eq 1) then $
      lin ="Applied linearity correction: " + info.pl.use_lin_file

    if(info.pl.use_rscd  eq 1) then $
      rscd ="Applied RSCD correction: " + info.pl.use_rscd_file
                          
    if(info.pl.use_bad_pixel_file eq 1 ) then $ 
        bad_pixel ="Applied file containing list of Bad pixels" + info.pl.bad_file

endif



dbase = widget_base(SoptionID,/row)
info.pl.SlopeLabel = widget_label(dbase,value= slope_exist,$
                          /align_center,font=info.font5,/sunken_frame)

info.pl.SlopeViewButton = widget_button(dbase,value = 'View Slope Data',uvalue = 'ViewSlope')

ViewButton = widget_button(dbase,value = 'View Frame Data',uvalue = 'ViewFrame')

if(slope_exists eq 0) then widget_control,info.pl.SlopeViewButton,sensitive = 0


info.pl.slope_param[0] = widget_label(SoptionID,value= slope_frame_a,/align_left,$
                                      font = info.font3,/dynamic_resize)
info.pl.slope_param[1] = widget_label(SoptionID,value= slope_frame_b,/align_left,$
                                      font = info.font3,/dynamic_resize)
info.pl.slope_param[2] = widget_label(SoptionID,value= slope_high_dn,/align_left,$
                                      font = info.font3,/dynamic_resize)
info.pl.slope_param[3] = widget_label(SoptionID,value=psm,/align_left,$
                                      font = info.font3,/dynamic_resize)
info.pl.slope_param[4] = widget_label(SoptionID,value = lin,/align_left,$
                                      font=info.font3,/dynamic_resize)
info.pl.slope_param[5] = widget_label(SoptionID,value = bad_pixel,/align_left,$
                                      font = info.font3,/dynamic_resize)

;_______________________________________________________________________
; Select Pixels to Plot Section
;_______________________________________________________________________
set_base = widget_base(ChangeID,col=8,/align_left)
amp = widget_label(set_base, value =' Grab a New Set of 5 Pixels to Plot', $
                      /align_left,font=info.font5,/sunken_frame)


setbutton = lonarr(4)
setbutton[0] = widget_button(set_base,Value = ' Set A',uvalue='pset1')
widget_control,setbutton[0],Set_Button = 1
setbutton[1] = widget_button(set_base,Value = ' Set B',uvalue='pset2')
widget_control,setbutton[1],Set_Button = 0
setbutton[2] = widget_button(set_base,Value = ' Random',uvalue='pset3')
widget_control,setbutton[2],Set_Button = 0
setbutton[3] = widget_button(set_base,Value = ' User Selected',uvalue='pset4')
widget_control,setbutton[3],Set_Button = 0
info.pl.setbutton= setbutton

space = widget_label(set_base,value = '     ')

info.pl.PIuwindowsize = 0
info.pl.PIhex = 0
info.pl.PIintegrationNO = 0
printbutton = widget_button(set_base,Value = ' Print Pixel Values',uvalue='pixprint')
widget_control,printbutton,Set_Button = 0

twoptbutton = widget_button(set_base,Value = ' Plot 2 Point Differences',$
                            uvalue='2ptdiff')



;_______________________________________________________________________
    
Name = ["Pixel A" ,"Pixel B" ,"Pixel C" ,"Pixel D", "Pixel E" ]
ValueX = ['0000' ,'0000' ,'0000' ,'0000','0000']
ValueY = ['0000', '0000', '0000', '0000','0000' ]
Channel = [' 1', ' 2', ' 3', ' 4', ' 5' ]


blank_a = '          '
blank_b = '          '
blank_c = '                  '
ValueSlope =  [blank_a,blank_a,blank_a,blank_a,blank_a]
ValueUnc =  [blank_b,blank_b,blank_b,blank_b,blank_b]
Value2 =  [blank_c,blank_c,blank_c,blank_c,blank_c]

imBases = lonarr(5)
onButton  = lonarr(5)
offButton = lonarr(5)

onvalue = intarr(5) 
offvalue = intarr(5)

onvalue(*) = 1

all_base = widget_base(ChangeID,/row,/align_left)


overplot_slope = 0
overplot_frame = 1
overplot_refcorrect = 0
overplot_ids = 0
overplot_lc = 0
overplot_mdc = 0
overplot_reset = 0
overplot_lastframe = 0

overplot = widget_label(all_base,value = 'Plot Frame Values',/sunken_frame, font = info.font5)
oBase = Widget_base(all_base,/row,/nonexclusive)
overplotFrameID = lonarr(2)
OverplotFrameID[0] = Widget_button(oBase, Value = 'Yes',uvalue = 'overframe1')
widget_control,OverplotFrameID[0],Set_Button = 1

OverplotFrameID[1] = Widget_Button(oBase, Value = 'No',uvalue = 'overframe2')
widget_control,OverplotFrameID[1],Set_Button = 0



overplotSlopeID = lonarr(2)


OverSlope = ' ' 
if(slope_exists ) then     OverSlope = 'Plot Fitted Slope'
OverPlotSlopeLabel = widget_label(all_base,value = OverSlope, font = info.font5,/dynamic_resize)
OverPlotSlopeBase = Widget_base(all_base,/row,/nonexclusive)

if(slope_exists ) then begin 
    OverplotSlopeID[0] = Widget_button(OverPlotSlopeBase, Value = 'Yes',uvalue = 'overslope1')
    OverplotSlopeID[1] = Widget_Button(OverPlotSlopeBase, Value = 'No',uvalue = 'overslope2')
    widget_control,OverplotSlopeID[0],Set_Button = 0
    widget_control,OverplotSlopeID[1],Set_Button = 1
endif


overplotcrID = lonarr(2)
if(info.control.file_ids_exist eq 1)then begin 
    overplot = widget_label(all_base,value = 'Mark Noise, Cosmic Rays, Corrupted Frames',$
                            /sunken_frame, font = info.font5,/align_left)
    oBase = Widget_base(all_base,/row,/nonexclusive)

    OverplotcrID[0] = Widget_button(oBase, Value = 'Yes',uvalue = 'overcr1')
    widget_control,OverplotcrID[0],Set_Button = 0

    OverplotcrID[1] = Widget_Button(oBase, Value = 'No',uvalue = 'overcr2')
    widget_control,OverplotcrID[1],Set_Button = 1
endif


overplotRefID = lonarr(2)

if(info.control.file_refcorrection_exist eq 1 )then begin 
    overplot = widget_label(all_base,value = 'Plot Ref Corrected Data',$
                            /sunken_frame, font = info.font5,/align_left)
    oBase = Widget_base(all_base,/row,/nonexclusive)

    OverplotRefID[0] = Widget_button(oBase, Value = 'Yes',uvalue = 'overref1')
    widget_control,OverplotRefID[0],Set_Button = 0

    OverplotRefID[1] = Widget_Button(oBase, Value = 'No',uvalue = 'overref2')
    widget_control,OverplotRefID[1],Set_Button = 1
endif



overplotlcID = lonarr(2)

if(info.control.file_lc_exist eq 1)then begin 
    overplot = widget_label(all_base,value = 'Plot Lin Corrected Data',$
                            /sunken_frame, font = info.font5,/align_left)
    oBase = Widget_base(all_base,/row,/nonexclusive)

    OverplotlcID[0] = Widget_button(oBase, Value = 'Yes',uvalue = 'overlc1')
    widget_control,OverplotlcID[0],Set_Button = 0

    OverplotlcID[1] = Widget_Button(oBase, Value = 'No',uvalue = 'overlc2')
    widget_control,OverplotlcID[1],Set_Button = 1

endif

overplotmdcID = lonarr(2)
if(info.control.file_mdc_exist eq 1)then begin 
    overplot = widget_label(all_base,value = 'Plot Dark Corrected Data',$
                            /sunken_frame, font = info.font5,/align_left)
    oBase = Widget_base(all_base,/row,/nonexclusive)

    OverplotmdcID[0] = Widget_button(oBase, Value = 'Yes',uvalue = 'overmdc1')
    widget_control,OverplotmdcID[0],Set_Button = 0

    OverplotmdcID[1] = Widget_Button(oBase, Value = 'No',uvalue = 'overmdc2')
    widget_control,OverplotmdcID[1],Set_Button = 1


 endif

overplotresetID = lonarr(2)
if(info.control.file_reset_exist eq 1)then begin 
    overplot = widget_label(all_base,value = 'Plot Reset Corrected Data',$
                            /sunken_frame, font = info.font5,/align_left)
    oBase = Widget_base(all_base,/row,/nonexclusive)

    OverplotresetID[0] = Widget_button(oBase, Value = 'Yes',uvalue = 'overreset1')
    widget_control,OverplotresetID[0],Set_Button = 0

    OverplotresetID[1] = Widget_Button(oBase, Value = 'No',uvalue = 'overreset2')
    widget_control,OverplotresetID[1],Set_Button = 1
 endif

overplotlastframeID = lonarr(2)
if(info.control.file_lastframe_exist eq 1)then begin 
    overplot = widget_label(all_base,value = 'Plot Lastframe Corrected Data',$
                            /sunken_frame, font = info.font5,/align_left)
    oBase = Widget_base(all_base,/row,/nonexclusive)

    OverplotlastframeID[0] = Widget_button(oBase, Value = 'Yes',uvalue = 'overlastframe1')
    widget_control,OverplotlastframeID[0],Set_Button = 0

    OverplotlastframeID[1] = Widget_Button(oBase, Value = 'No',uvalue = 'overlastframe2')
    widget_control,OverplotlastframeID[1],Set_Button = 1
endif


all_base = widget_base(ChangeID,/row,/align_left)
amp = widget_label(all_base, value =' Select Pixel to Plot', $
                      /align_left,font=info.font5,/sunken_frame)


allbutton = widget_button(all_base,Value = ' Select All',uvalue='allplot1')
widget_control,allbutton,Set_Button = 1
nonebutton = widget_button(all_base,Value = ' Select None',uvalue='allplot2')
widget_control,nonebutton,Set_Button = 0


desa= widget_label(all_base,value ="          Reduced Results are for  Starting Integration Number set above    ")

slope_all = widget_button(all_base,value=" Get Results for All Integrations" ,uvalue = 'getall') 

descrip = Widget_Base(ChangeID,/row)
if(info.data.coadd ne 1) then $
  des1 = widget_label(descrip, value = "Name     X    Y Channel   "$
                    + "  Plot            Reads  Cal Slope  Rejected" + $
                      "    Slope(DN/s) Uncertainity   Quality Flag  # Good Reads  Zero-Pt       " +$
                      " Read # First Sat    # Good Segments     STD Fit (DN) ",/align_left)	

if (info.data.coadd eq 1) then $
  des1 = widget_label(descrip, value = "Name     X    Y Channel   "$
                      + "  Plot            Reads  Coadd    Rejected" + $
                      "    Average  Uncertainity   Quality Flag  Num Good Reads  Zero-Pt       Read # First Sat",/align_left)	


x1 = info.data.colstart
x2 = info.data.colstart + info.data.image_xsize -1
y1 = info.data.rowstart
y2 = info.data.rowstart + info.data.image_ysize -1
descrip = Widget_Base(ChangeID,/row)
srangex = 'Valid X range: ' +strcompress(string(x1),/remove_all) + ' to ' + $
         strcompress(string(x2),/remove_all) 
srangey = 'Valid Y range: ' +strcompress(string(y1),/remove_all) + ' to ' + $
         strcompress(string(y2),/remove_all) 
range= widget_label(descrip,value = srangex + ' ' + srangey)
 
ix = lonarr(5) & iy = lonarr(5) & ic = lonarr(5) 
islope = lonarr(5) & iunc = lonarr(5) & iquality = lonarr(5) & inumgood =lonarr(5) & izeropt = lonarr(5)
ifirstsat  = lonarr(5) & inseg = lonarr(5)
istd = lonarr(5)

boxID = lonarr(5)
boxIDs = lonarr(5)
boxIDreject = lonarr(5)
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
    boxIDs[i] = widget_draw(imBases[i],scr_xsize=50,scr_ysize=20, $
                               frame=1)

    boxIDreject[i] = widget_draw(imBases[i],scr_xsize=50,scr_ysize=20, $
                               frame=1)


    islope[i] = Widget_label(imbases[i],value = valueslope[i])
    iunc[i] = Widget_label(imbases[i],value = valueunc[i])
    iquality[i] = Widget_label(imbases[i],value = valueunc[i])
    inumgood[i] = Widget_label(imbases[i],value = value2[i])
    izeropt[i] = Widget_label(imbases[i],value = value2[i])
    ifirstsat[i] = Widget_label(imbases[i],value = value2[i])
    inseg[i] = Widget_label(imbases[i],value = value2[i])
    istd[i] = Widget_label(imbases[i],value = value2[i])
endfor


;_______________________________________________________________________
longline = '                                                                                                                                                                 '
longtag = widget_label(Pixellook,value = longline)
Widget_control,info.PixelLook,/Realize
XManager,'mpl',info.PixelLook,/No_Block,event_handler='mpl_event'
;_______________________________________________________________________
draw_box_id = lonarr(5)
draw_box_ids = lonarr(5)
draw_box_idreject = lonarr(5)
for i = 0,4 do begin
  widget_control,boxID[i],get_value=tdraw_id
  draw_box_id[i] = tdraw_id

  widget_control,boxIDs[i],get_value=tdraw_id
  draw_box_ids[i] = tdraw_id

  widget_control,boxIDreject[i],get_value=tdraw_id
  draw_box_idreject[i] = tdraw_id
endfor




;_______________________________________________________________________

info.pl.randomstart = 1
info.pl.slope_exists = slope_exists
info.pl.nonebutton = nonebutton
info.pl.allbutton = nonebutton
info.pl.offbutton = offbutton
info.pl.onbutton = onbutton
info.pl.onvalue = onvalue
info.pl.draw_box_id = draw_box_id
info.pl.draw_box_ids = draw_box_ids
info.pl.draw_box_idreject = draw_box_idreject
info.pl.xpixel_label = ix
info.pl.ypixel_label = iy
info.pl.channel_label = ic
info.pl.info_label1 = islope
info.pl.info_label2 = iunc
info.pl.info_label3 = iquality
info.pl.info_label4 = inumgood
info.pl.info_label5 = izeropt
info.pl.info_label6 = ifirstsat
info.pl.info_label7 = inseg
info.pl.info_label8 = istd

info.pl.overplot_slope = overplot_slope
info.pl.overplot_frame = overplot_frame
info.pl.overplot_refcorrect = overplot_refcorrect
info.pl.overplot_ids = overplot_ids
info.pl.overplot_lc = overplot_lc
info.pl.overplot_mdc = overplot_mdc
info.pl.overplot_reset = overplot_reset
info.pl.overplot_lastframe = overplot_lastframe

info.pl.overplotSlopeID = overplotSlopeID
info.pl.overplotFrameID = overplotFrameID
info.pl.overplotRefID = overplotRefID
info.pl.overplotcrID = overplotcrID
info.pl.overplotmdcID = overplotmdcID

info.pl.overplotresetID = overplotresetID
info.pl.overplotlastframeID = overplotlastframeID
info.pl.overplotlcID = overplotlcID


info.pl.overplotSlopeLabel  = OverPlotSlopeLabel
info.pl.overplotSlopeBase = OverPlotSlopeBase


;Set up the GUI




; get the window id of the draw window
widget_control,info.pl.graphID,get_value=tdraw_id
info.pl.draw_window_id = tdraw_id

info.pl.group = 0 ; default to plot first set of pixels

 mpl_update_plot,info


Widget_Control,info.QuickLook,Set_UValue=info
sinfo = {info        : info}

Widget_Control,info.PixelLook,Set_UValue=sinfo
Widget_Control,info.QuickLook,Set_UValue=info


end
