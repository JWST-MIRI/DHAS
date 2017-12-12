pro determine_detector,detector, origin,detector_code

;	detector_code     IM = 0, LW  = 1, SW = 2, JPL = 3
 found = 0
detector_code = -1
 if(origin eq "JPL"  )then begin 
    detector_code = 3
    found = 1                   ;
 endif else begin 

   if(strcmp(origin,"RAL",/FOLD_CASE) eq 1 or strcmp(origin,"STScI",/FOLD_CASE) eq 1 ) then begin
       if(strcmp(detector,"IM",/FOLD_CASE) eq 1 or strcmp(detector,"MIRIMAGE",/FOLD_CASE) eq 1 ) then begin
          detector_code = 0
          found = 1             ;
      endif
       if(strcmp(detector,"LW",/FOLD_CASE) eq 1 or strcmp(detector,"MIRIFULONG",/FOLD_CASE) eq 1 ) then begin
          detector_code = 1
          found = 1              ;
      endif
       if(strcmp(detector,"SW",/FOLD_CASE) eq 1 or strcmp(detector,"MIRIFUSHORT",/FOLD_CASE) eq 1 ) then begin
          detector_code = 2
          found = 1              ;
       endif
    endif
 endelse

 print , "Data is for detector: ", detector 
 print,  "Origin of data: " , origin ;
 print, 'Detector code',detector_code

end


pro determine_CDP_list,im_list,lw_list,sw_list,jpl_list,detector_code,return_list

return_list = 'NULL'
if(detector_code eq 0) then return_list = im_list
if(detector_code eq 1) then return_list = lw_list
if(detector_code eq 2) then return_list = sw_list
if(detector_code eq 3) then return_list = jpl_list

end

;______________________________________________________________________
; For JPL data fix the COLSTART header parameter.

pro fix_colstart, detector_code,colstart


if(detector_code eq 3) then begin

   corrected_value  = (colStart -1)*4/5 + 1
   print,' Adjusting COLSTART value from the header (in memory)', colstart,corrected_value
   colstart = corrected_value

endif  
end
