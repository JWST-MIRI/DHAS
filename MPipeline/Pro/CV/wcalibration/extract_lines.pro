pro extract_lines, slice,xstart,sliceno,region,nregions,beta

ignore = -9999.0
ybox_half = 4
 ;_______________________________________________________________________
; display image
 ;_______________________________________________________________________
col_max =  min([!d.n_colors, 255])
col_bits = 6
loadct,3
expand = 4

s = size(slice)
sx = s[1]
sy = s[2]


sxnew = sx*expand
disp_image = congrid(slice,sxnew,sy)
in = where(finite(slice),npixels)
mean_image = mean(slice[in])
st = stddev(slice[in])

image_min = mean_image - 2.0*st
image_max = mean_image + 2.0*st



window,/pixmap,xsize=sxnew,ysize=sy,/free
window,/pixmap,xsize = sxnew,ysize = sy
pixmapID= !D.WINDOW
disp_image = bytscl(disp_image,min=image_min, $
                    max=image_max,$
                    top= col_max-col_bits-1,/nan)


tv,disp_image,0,0,/device
window,2, xsize = sxnew,ysize = sy,xpos = 200
device,copy=[0,0,sxnew,sy,0,0,pixmapID]

;_______________________________________________________________________
color6

xmiddle = sx/2

image_middle = slice[xmiddle,*]
image_middle[0,0] =0
image_middle[0,sy-1] = 0

colplot = findgen(sy) ; starts at 0 

window,1,xsize = 1100,ysize = 400
ymin = min(image_middle)
ymax = max(image_middle)
st = 'Slice = ' + strcompress(string(sliceno),/remove_all)
plot,colplot,image_middle,xrange = [0,sy] , yrange = [ymin,ymax],xstyle =1, ystyle =1,$
     xtitle = 'Row #', ytitle = ' Flux',$
     title = st + ' Value of Flux for a line running down the Middle of the Slice' + $
     ' (Green + marks values > Mean+1.5 STDEV = center of extracted region)'

;_______________________________________________________________________
; Find the peaks
floor_image = min(image_middle[1:sy-2])
simage = image_middle - floor_image
mean_col = mean(simage,/nan)
st = stddev(simage,/nan)

;ipeak = where(image_middle gt (mean_col+ st*2.0))
ipeak = where(image_middle gt (mean_col+ st*1.5))
peak = image_middle[ipeak]
peakrow = colplot[ipeak]
n = n_elements(peakrow)
for i = 0,n-2 do begin
    
    p1 = peakrow[i]
    p2  = peakrow[i+1]
    if(p1 ne ignore and p2 ne ignore) then begin
        if( (p2 - p1 ) le 2) then  begin
            if(peak[i] gt peak[i+1] ) then begin
                peak[i+1] = ignore
                peakrow[i+1] = ignore
            endif else begin
                peak[i] = ignore
                peakrow[i] = ignore
            endelse
        endif
    endif
endfor
            
iclean = where(peak ne ignore)        
peakclean = peak[iclean]
rowclean = peakrow[iclean]
oplot,rowclean,peakclean,psym = 1,color = 3

;_______________________________________________________________________
nregions = n_elements(rowclean)

;wset,pixmapID
wset,2
for i = 0,nregions-1 do begin
    yregion_min = rowclean[i] - ybox_half
    yregion_max = rowclean[i] + ybox_half
    if(yregion_min lt 0) then yregion_min =0
    if(yregion_max ge sy) then yregion_max = sy-1
    print,'yregion',yregion_min,yregion_max

	; check x boundary 
    xa = xstart
    xb = xstart + (sx-1)
    

    yrange = yregion_max - yregion_min +1
    sno = fltarr(sx,yrange)
    for ii = 0,sx-1 do begin
        for jj = 0,yrange-1 do begin
            xx = xa +ii -1      ; xa starts at 1
            yy = yregion_min+jj ; yregion starts at 0
            sno[ii,jj] = beta[xx,yregion_min+jj]
            
        endfor	
    endfor
; check starting point
    kstart = 0
    found = 0 & k = 0
    while (found eq 0 and k lt sx-1) do begin

        col = sno[k,*]
        in = where(col ne sliceno,num)

        if(num lt 3) then begin
            found = 1
            xa = xstart + k

            kstart = k
        endif	else begin
            k = k + 1
        endelse
    endwhile

; check ending point
    kend = sxnew 
    found = 0 & k = sx-1
    while (found eq 0 and k ge 0) do begin
        col = sno[k,*]
        in = where(col ne sliceno,num)
        if(num lt 3) then begin
;        if(num eq 0) then begin
            found = 1
            xb = xstart + k
            kend = k
        endif	else begin
            k = k - 1
        endelse
    endwhile


    region[0,i] = xa            ; starts at 1
    region[1,i] = xb            ; starts at 1 
    region[2,i] = yregion_min +1 ; starts at 1  
    region[3,i] = yregion_max +1 ; starts at 1 

    
    xcorner = [kstart*expand,kend*expand,kend*expand,kstart*expand,kstart*expand]
    ycorner = [yregion_min-1,yregion_min-1,yregion_max-1,yregion_max-1,yregion_min-1]

    plots,xcorner,ycorner,/device,color = 3,psym=0

    print,'Slice, Region #,xmin,xmax,ymin,ymax ',sliceno,i+1, region[0,i],region[1,i],$
          region[2,i],region[3,i]


endfor




end

