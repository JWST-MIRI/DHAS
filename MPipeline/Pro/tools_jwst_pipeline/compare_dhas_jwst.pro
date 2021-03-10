@findhistogram.pro
@color6.pro
pro compare_dhas_jwst, file_dhas_lvl2, file_jwst_rate

; file_dhas_lvl2: slope image from DHAS
; First extension contains average slope
;    data: slope, error, dq
; Second extension: slope from int 1
;   data: slope, error, dq, zero pt, # good frames,
;         frame # first sat, # good segments, STD fit

; file_jwst_rate;
; first extension: average slope
; second extension: error of slope
; third extension: DQ
; forth extension: var_poisson
; fifth extension: var_rnoise

; Using the name of the rate file - form the name of the rateints file
; read in the rate ints file
;******************************************************************
;Read in the DHAS data
  
  file_exists = file_test(file_dhas_lvl2,/regular,/read)
  if(file_exists ne 1) then begin
     print,' DHAS file does not exists', file_dhas_lvl2
     stop
  endif

  file_exists = file_test(file_jwst_rate,/regular,/read)
  if(file_exists ne 1) then begin
     print,' JWST  file does not exists', file_jwst_rate
     stop
  endif

  fits_open,file_dhas_lvl2,fcb
  fits_read,fcb,ave_slope_dhas,header,exten_no = 0

  nramps = fxpar(header,'NPGROUP',count=count)
  if(count eq 0) then nramps = fxpar(header,'NGROUPS',count = count)
  if(count eq 0) then nramps = 0
  nints = fxpar(header,'NINT',count = count)
  if(count eq 0) then nints = fxpar(header,'NINT',count = count)
  if(count eq 0) then nints = 1
  if(nints eq 0) then nints  = 1
  naxis1 = fxpar(header,'NAXIS1',count = count)
  naxis2 = fxpar(header,'NAXIS2',count = count)
  slope_dhas_int = fltarr(nints, naxis1, naxis2,3)
  
  for i = 0, nints -1 do begin
     fits_read,fcb,data,header,exten_no = i+1
     slope_dhas_int[i,*,*,0:2] = data[*,*,0:2]
  endfor
  fits_close,fcb
;******************************************************************
; Read in the jwst pipeline data
  len  = strlen(file_jwst_rate)
  filebase = strmid(file_jwst_rate,0,len-5)
  st = strmid(file_jwst_rate,0,len-10)
  file_jwst_rate_ints = filebase + 'ints.fits'

;read average rate
  fits_open,file_jwst_rate,fcb
  fits_read,fcb,data,header,exten_no = 1
  naxis1_jwst = fxpar(header,'NAXIS1',count = count)
  naxis2_jwst = fxpar(header,'NAXIS2',count = count)
  if(naxis1 ne naxis1_jwst or naxis2 ne naxis2_jwst) then begin
     print,' The DHAS and JWST files are not the same size'
     print,' DHAS file has size',naxis1, naxis2
     print,' JWST file has size',naxis1_jwst, naxis2_jwst
     stop
  endif
  ave_slope_jwst = fltarr(naxis1, naxis2,3)
  ave_slope_jwst[*,*,0] =data
  fits_read,fcb,data,header,exten_no = 2
  ave_slope_jwst[*,*,1] =data
  fits_read,fcb,data,header,exten_no = 3
  ave_slope_jwst[*,*,2] =data
  fits_close,fcb
  
  slope_jwst_int = fltarr(nints, naxis1, naxis2,3)
  fits_open,file_jwst_rate_ints,fcb
  fits_read,fcb,data1,header,exten_no = 1
  fits_read,fcb,data2,header,exten_no = 2
  fits_read,fcb,data3,header,exten_no = 3
  
  for i = 0,nints -1 do begin
     slope_jwst_int[i,*, *, 0] = data1[*,*,i]
     slope_jwst_int[i,*, *, 1] = data2[*,*,i]
     slope_jwst_int[i,*, * ,2] = data3[*,*,i]
  endfor
  fits_close,fcb

; Now compare the average rate files
; find bad data in DHAS
  index = where(ave_slope_dhas[*,*,2] eq 1,nbad)
  print,'Number of unsable pixels in DHAS',nbad

  index = where(ave_slope_dhas[*,*,2] ne 1,nuse)
  print,'Number of  pixels comparing',nuse

  data_dhas = ave_slope_dhas[*,*,0]
  data_dhas = data_dhas[index]

  data_jwst = ave_slope_jwst[*,*,0]
  data_jwst = data_jwst[index]

  mean_dhas = mean(data_dhas)
  std_dhas = stddev(data_dhas)
  dmin = mean_dhas - 3*std_dhas
  dmax = mean_dhas + 3*std_dhas

  mean_jwst = mean(data_jwst)
  std_jwst = stddev(data_jwst)
  dmin2 = mean_dhas - 3*std_jwst
  dmax2 = mean_dhas + 3*std_jwst

  if(dmin2 lt dmin) then dmin  = dmin2
  if(dmax2 gt dmax) then dmax  = dmax2
  
  numbins = 500
  findhistogram_xlimits, data_dhas,xdhas, h_dhas, numbins,bins,xplot_min, xplot_max,dmin,dmax,status
  yhmax = max(h_dhas) + max(h_dhas)*0.3
  yhmin = 0   
  findhistogram_xlimits, data_jwst, xjwst,h_jwst, numbins,bins,xplot_min, xplot_max,dmin,dmax,status
  yhmax2 = max(h_dhas) + max(h_dhas)*0.3
  if(yhmax2 gt yhmax) then yhmax = yhmax2

  window,0
  color6
  !p.multi = [0,1,1]
  plot,xdhas,h_dhas,psym=10,ytitle= 'Number of Pixels',$
       xtitle=' Ave Slopes (DHAS = black, JWST = red) ',$
       title=st + ' Ave Slopes ',$
       yrange = [yhmin,yhmax],xrange=[xplot_min,xplot_max],$
       ystyle=1,xstyle = 1 ,$
       thick = 4,/nodata,$
       ytickformat='(f7.0)',$
       background = 1, color = 0,charsize = 1.5,subtitle = ss
  oplot,xdhas,h_dhas,psym=10,color=0,linestyle=0, thick=1
  oplot,xjwst,h_jwst,psym=10,color=2,linestyle=0, thick=1
  filename  = filebase + 'ave_slope_comparision'
  print,'filename',filename
  image2d = TVRead(filename=filename,/JPEG,/nodialog)
  
; Compare the integrations
  window,1
  !p.multi = [0,2,2]
  ip = 1
  iplot = 1
  for i = 0, nints -1 do begin
     ip = ip + 1
     print,'On Integration ', i + 1
     index = where(slope_dhas_int[i,*,*,2] eq 1,nbad)
     print,'Number of unsable pixels in DHAS',nbad

     index = where(slope_dhas_int[i,*,*,2] ne 1,nuse)
     print,'Number of  pixels comparing',nuse

     data_dhas = slope_dhas_int[i,*,*,0]
     data_dhas = data_dhas[index]

     data_jwst = slope_jwst_int[i,*,*,0]
     data_jwst = data_jwst[index]

     mean_dhas = mean(data_dhas)
     std_dhas = stddev(data_dhas)
     dmin = mean_dhas - 3*std_dhas
     dmax = mean_dhas + 3*std_dhas

     mean_jwst = mean(data_jwst)
     std_jwst = stddev(data_jwst)
     dmin2 = mean_dhas - 3*std_jwst
     dmax2 = mean_dhas + 3*std_jwst

     if(dmin2 lt dmin) then dmin  = dmin2
     if(dmax2 gt dmax) then dmax  = dmax2
  
     numbins = 500
     findhistogram_xlimits, data_dhas,xdhas, h_dhas, numbins,bins,xplot_min, xplot_max,dmin,dmax,status
     yhmax = max(h_dhas) + max(h_dhas)*0.3
     yhmin = 0   
     findhistogram_xlimits, data_jwst, xjwst,h_jwst, numbins,bins,xplot_min, xplot_max,dmin,dmax,status
     yhmax2 = max(h_dhas) + max(h_dhas)*0.3
     if(yhmax2 gt yhmax) then yhmax = yhmax2
     
     si = strcompress(string(i+1),/remove_all)
     plot,xdhas,h_dhas,psym=10,ytitle= 'Number of Pixels',$
          xtitle=' Slopes Int ' + si + ' (DHAS = black, JWST = red) ',$
          title=st,$
          yrange = [yhmin,yhmax],xrange=[xplot_min,xplot_max],$
          ystyle=1,xstyle = 1 ,$
          thick = 4,/nodata,$
          ytickformat='(f7.0)',$
          background = 1, color = 0,charsize = 1.2
     oplot,xdhas,h_dhas,psym=10,color=0,linestyle=0, thick=1
     oplot,xjwst,h_jwst,psym=10,color=2,linestyle=0, thick=1
     if (ip eq 4) then begin
        ip = 1 
        filename  = filebase + 'int_slope_comparision_'+strcompress(string(iplot),/remove_all)
        iplot = iplot + 1
        image2d = TVRead(filename=filename,/JPEG,/nodialog)
        print,'filename',filename
     endif
  endfor
     
  stop
  end
