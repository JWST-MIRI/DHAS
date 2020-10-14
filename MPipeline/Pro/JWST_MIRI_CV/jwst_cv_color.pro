; Change the color of the graphs
; Use the xcolors routine for linux and suns (the xloadct is
; hard to test since I don't have a sun to test with easily.

pro jwst_cv_color,event
Widget_Control,event.top,Get_UValue=cinfo
type = -1

Case !version.os of
    'linux': type = 1
    'sunos': type = 0
    else:
endcase
;if(type eq -1) then begin 
;
;    xloadct,group=cinfo.QuickLook
;    Widget_Control,event.top,Set_UValue=cinfo
;	print,colorInfoData.index
;endif

;_______________________________________________________________________
if(type eq 1 or type eq 0) then begin
    Widget_Control,event.top,Get_UValue=cinfo
    if XRegistered('XCOLORS:Load Color Tables') then begin
        print, 'XColors already loaded'
    endif else begin
        xcolors,/Block,colorinfo=colorInfoData
        print," Loading Color Table: ", colorInfoData.name
        print,' Color Table Index',colorInfoData.index
        if(colorInfoData.index eq -1) then begin

            print,' Color table unknown, not changing color table'
            colorInfodata.index = cinfo.col_table
        endif
    
        cinfo.col_table = colorInfoData.index
        Widget_Control,event.top,Set_UValue=cinfo

        jwst_cv_update_cube,cinfo
        Widget_Control,event.top,Set_UValue=cinfo
    endelse
endif
end



