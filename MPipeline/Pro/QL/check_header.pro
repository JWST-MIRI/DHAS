; This program reads in a FITS header and makes sure all the required
 ; inforamtion exists

pro check_header,naxis3,nints, nramps

itest = float(nints) * float(nramps) ;
;print,naxis3, itest,nints
;if(naxis3 lt itest) then begin ; not enough frames in the file
;    newINT = float(naxis3)/float(nramps)
;    nints = newINT+1;
;    print,' ************** WARNING ******************' 
;    print,' The raw data file did not have all the data corresponding to NGROUPS and NINT'
;    print,' NAXES3  ' , naxis3 
;    print,' NINTS   ',nints
;    print,' NGROUPS ', nramps 

;    print,' Setting NINTS to ', nints
;    print,' Setting NGroups to',naxis3
;    nramps = naxis3
;    
;        
;    print,' ********************** ******************' 
;endif


if(naxis3 gt itest) then begin ; not enough frames in the file

    print,' ************** WARNING ******************' 
    print,' The raw data file did not have all the data corresponding to NGROUPS and NINT'
    print,' NAXES3  ' , naxis3 
    print,' NINTS   ',nints
    print,' NGROUPS ', nramps 

;    print,' Exiting'

    print,' ********************** ******************' 
;    stop
endif
end
