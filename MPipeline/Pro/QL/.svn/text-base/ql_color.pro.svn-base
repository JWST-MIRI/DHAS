; Change the color of the graphs
; Use the xcolors routine for linux and suns (the xloadct is
; hard to test since I don't have a sun to test with easily.

pro ql_color,event
Widget_Control,event.top,Get_UValue=info
type = -1
Case !version.os of
    'linux': type = 1
    'sunos': type = 0
    else:
endcase
if(type eq -1) then begin 

    xloadct,group=info.QuickLook
    Widget_Control,event.top,Set_UValue=info
	print,colorInfoData.index

endif

;_______________________________________________________________________
if(type eq 1 or type eq 0) then begin
    Widget_Control,event.top,Get_UValue=info
    if XRegistered('XCOLORS:Load Color Tables') then begin
        print, 'XColors already loaded'
    endif else begin
        xcolors,/Block,colorinfo=colorInfoData
    help,colorInfoData,/Structure
    print," Loading Color Table", colorInfoData.name
    print,' Color Table Index',colorInfoData.index
        info.col_table = colorInfoData.index
        Widget_Control,event.top,Set_UValue=info

        if(XRegistered ('mql')) then begin
            mql_update_images,info
            mql_update_slope,info
            mql_update_zoom_image,info
        endif

        if(XRegistered ('msql')) then begin

            msql_update_slope,info.slope.plane[0],0,info
            msql_update_slope,info.slope.plane[2],2,info
            msql_update_zoom_image,info
        endif

        if(XRegistered ('miql')) then begin
            miql_update_images,info
        endif

        if(XRegistered ('misql')) then begin
            misql_update_images,info
        endif

        if(XRegistered ('misql2')) then begin
            misql2_update_images,info
        endif

        if(XRegistered ('mirql')) then begin
            mirql_update_images,info
        endif



        if(XRegistered ('mqldchr')) then begin ; channel display
            for i = 0,4 do begin
                mql_update_Channel,i,info
            endfor
        endif

        if(XRegistered ('mqldschr')) then begin ; channel display
            for i = 0,4 do begin
                mql_update_SlopeChannel,i,info
            endfor
        endif




        if(XRegistered ('mrp')) then begin ; reference pixel display
            mrp_update_refpixel,info
            mrp_update_zoom_image,info
        endif

        if(XRegistered ('mql_compare')) then begin ; compare raw images

            for i = 0,2 do begin
                mql_compare_update_images,info,i
            endfor
        endif

        Widget_Control,event.top,Set_UValue=info
    endelse




endif
end



