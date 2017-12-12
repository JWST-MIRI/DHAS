pro centroid, image, Hw, Threshold, xCen,yCen

;Floating centroid based on A Gibberd's implemetation of the STSci floating window algorithm. 
;
  ;  Initialize variables
  Ysum=0.0 & Xsum=0.0 & l=0 & SUM = 0.0 & Xcen=0.0 & Ycen=0.0 & Xmax=0.0 & Ymax=0.0
  ;  Maximum recorded pixel value
  Peak = -1000  
  ;  Create new cropped image for floater
  Box=findgen((2*hw)+3,(2*hw)+3)
  ImgSize = size(Image)
  ;  ImgSize_x = ImgSize[1] & ImgSize_y= ImgSize[2]
  ;  Search image for brightest pixel
  for i = 1, (ImgSize[1]-1) do begin
    for j = 1,  (ImgSize[2]-1) do begin
      if (image[i,j] gt Peak) then begin
      Peak=image[i,j]
      Xmax=i
      Ymax=j
      endif
    endfor
  endfor
  ; Weight the pixels in square aperture with half width hw
  i=0 & j=0
  for i = Xmax-hw,Xmax+hw do begin
    if (i+1) ge ImgSize[1]-1 then begin
      comment=1
      goto,crash 
    endif
    for j = Ymax-hw,Ymax+hw do begin
      if (j+1) ge ImgSize[2]-1 then begin
        comment=2
        goto,crash
      endif
      SUM = SUM + image[i,j]
      Xcen = Xcen + i*image[i,j]
      Ycen = Ycen + j*image[i,j]
    endfor
  endfor
  ;  Populate the cropped image
  Box=image[(Xmax-hw-1):(Xmax+hw+1),(Ymax-hw-1):(Ymax+hw+1)]
  Xcen = Xcen/SUM
  Ycen = Ycen/SUM
  ; Adjusts Xcen/Ycen for box Coordinates
  Xcen=Xcen-Xmax+hw+1.5
  Ycen=Ycen-Ymax+hw+1.5
  Xcenold=hw+1.5
  Ycenold=hw+1.5
  ;  Creates Weighting array
  xweight=findgen(2*(hw)+3,2*(hw)+3)
  yweight=findgen(2*(hw)+3,2*(hw)+3)
  weight=findgen(2*(hw)+3,2*(hw)+3)
  ;  MAIN LOOP moving aperture to new centroid
  ;  Set r to start off as something large such that r initally > threshold
  r=1000
  while (r gt threshold)  do begin
    Ycenold = Ycen
    Xcenold = Xcen
    ;  Temporary variable to keep track of Sum of weights
    Xcent=0.0
    Ycent=0.0
    ;  Limits to 100 iterations incase of bug
    if l eq 100 then break
    l ++
    xweight[*,*]=0
    yweight[*,*]=0
    weight[*,*]=0
    ;  Corrected half width adds 0.5 a pixel because hw is a measure of pixels either side of centre
    hwc=hw+0.5
    for i=0,(2*(hwc))+1 do begin
      for j=0,(2*(hwc))+1 do begin
        ; Draws the imaginery sub-pixel aperture
        if (i lt xcen) then begin
          xweight[i,j]=(1-(Xcen-hwc-i))
        endif else begin
          xweight[i,j]=(Xcen+hwc-i)
        endelse
        if xweight[i,j] gt 1 then xweight[i,j]=1 
        if xweight[i,j] lt 0 then xweight[i,j]=0.0
        ;Now for the column pixels
        if j lt Ycen then begin
          yweight[i,j]=(1-(Ycen-hwc-j))
        endif else begin
          yweight[i,j]=(Ycen+hwc-j)
        endelse
        if yweight[i,j] gt 1 then yweight[i,j]=1 
        if yweight[i,j] lt 0 then yweight[i,j]=0.0
        ; Combine weighting
        weight[i,j]=xweight[i,j]*yweight[i,j]
        Xcent = Xcent + (i+1)*box[i,j]*weight[i,j]
        Ycent = Ycent + (j+1)*box[i,j]*weight[i,j]
      endfor
    endfor

    ; Calculates new centroid in X/Y directions
    sum=total(weight*box)
    Ycen = (Ycent/sum)-0.5
    Xcen = (Xcent/sum)-0.5
    ;  Converts error to radial
    r=sqrt((xcen-xcenold)^2+(ycen-ycenold)^2)
  endwhile
  ;  Reforms X/Ycen coord in terms of the orignal 200x200 image
  Xcen = Xcen+Xmax-hw-1.5
  Ycen = Ycen+Ymax-hw-1.5
  ;  Jump to here if Error
crash:
   fini:
end
