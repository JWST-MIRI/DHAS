
pro findhistogram,data_all,x_to_plot,hist_to_plot,numbins,bins,xplot_min,xplot_max,status

;_______________________________________________________________________
;xnew center of each bin pt
; h is the number of pts corresponding to values that fall in
; the bin (with center  = x)
; Modified histogram method from Fanning "IDL Programming Techniques"
; page 250 and added a bin at min and max to have 0 points (I like the
; look better. )
;_______________________________________________________________________

status = 0
indxs = where(finite(data_all),n_pixels)
data = data_all[indxs]
range = max(data) - min(data)


if(range eq 0) then begin
    status = 1
    xnew = fltarr(2)
    h = fltarr(2)

    xnew[0] = min(data)
    xnew[1] = max(data)


    h[0] = 1
    h[1] = n_elements(data)
    x_to_plot = xnew
    xplot_min = x_to_plot[0]
    xplot_max = x_to_plot[1]
    hist_to_plot = h
    return
endif else begin
    bins = float(range)/float(numbins)

    hist = histogram(data,binsize=bins,min=min(data),max=max(data),/nan)
    npts = n_elements(hist)
    
    x = findgen(n_elements(hist))*bins + min(data)
    x2 = x


    x_to_plot = [ x2[0]-bins,x2, x2[npts-1]+bins]
    hist_to_plot = [0,hist,0]

    xplot_min = x_to_plot[0]
    num = n_elements(x_to_plot)
    xplot_max = x_to_plot[num-1]



endelse
data = 0
end


;_______________________________________________________________________
;_______________________________________________________________________


pro findhistogram_xlimits,data_all,x_to_plot,hist_to_plot,numbins,bins,xplot_min,xplot_max,xmin,xmax,status
;_______________________________________________________________________
;xnew center of each bin pt
; h is the number of pts corresponding to values that fall in
; the bin (with center  = x)
; Modified histogram method from Fanning "IDL Programming Techniques"
; page 250 and added a bin at min and max to have 0 points (I like the
; look better. )
;_______________________________________________________________________

status = 0
indxs = where(finite(data_all),n_pixels)
data = data_all[indxs]
range = abs(xmax -xmin)

if(xmax lt xmin) then begin
	xmax = max(data_all)
	xmin = min(data_all)
endif
if( finite(range) eq 0) then begin
    
    status = 1
    xnew = fltarr(2)
    h = fltarr(2)

    xnew[0] = 0
    xnew[1] = 1

    h[0] = 1
    h[1] = n_elements(data)
    x_to_plot = xnew
    xplot_min = x_to_plot[0]
    xplot_max = x_to_plot[1]
    hist_to_plot = h
    return
endif
if(range eq 0) then begin 

    status = 1
    xnew = fltarr(2)
    h = fltarr(2)

    xnew[0] = min(data)
    xnew[1] = max(data)

    h[0] = 1
    h[1] = n_elements(data)
    x_to_plot = xnew
    xplot_min = x_to_plot[0]
    xplot_max = x_to_plot[1]
    hist_to_plot = h
    return
endif else begin
    bins = float(range)/float(numbins)

    hist = histogram(data,binsize=bins,min=xmin,max=xmax,locations=xnew,/nan)
                                ; xnew is the center of the bin and
                                ; the h is the number for the center
                                ; of bin (h[i] is # from
                                ; xnew[i]-bins/2 to xnew[i] + bins/2
    npts = n_elements(hist)
     
    hist_to_plot = hist
    x_to_plot = xnew
    xplot_min = xmin
    xplot_max = xmax


endelse
data = 0
end
