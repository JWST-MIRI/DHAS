pro cube_help, cubename



len= strlen(cubename)
endname = strmid(cubename,len-9,9)


basename = strmid(cubename,0,len-13)

mapping_file = basename + 'Mapping_Overlap' + endname


file_exist = file_test(mapping_file,/regular,/read)

if(file_exist ne 1) then begin
    mapping_file =  dialog_pickfile(/read,$
                                 get_path=realpath,$
                                 filter = '*.fits',title='Select the mapping file')
endif

print,'Mapping file',mapping_file 




fits_open,mapping_file,fcb
fits_read,fcb,data,header,exten_no = 0
nx = fxpar(header,'NX',count=count)
ny = fxpar(header,'NY',count=count)
nz = fxpar(header,'NZ',count=count)
print,'nx, ny, nz',nx,ny,nz
nplane = nx * ny

fits_read,fcb,data,header2,exten_no = 1

naxis1 = fxpar(header2,'NAXIS1',count=count)
naxis2 = fxpar(header2,'NAXIS2',count=count)
naxis3 = fxpar(header2,'NAXIS3',count=count)

num = naxis3/2
index_cube = lonarr(naxis1,naxis2,num)
overlap = fltarr(naxis1,naxis2,num)

ii = 0
ij = 0
for i = 0,naxis3-1 do begin
    rem = i mod 2

    if(rem eq 0) then begin
        index_cube[*,*,ii] = data[*,*,i]
        ii = ii + 1
    endif else begin 
        overlap[*,*,ij] = data[*,*,i]
        ij = ij + 1
        
    endelse
endfor
data = 0

;print,index_cube[32,0,*]
;print,overlap[32,0,*]



nmapxy = long(naxis1 * naxis2)

continue = 1

while(continue eq 1) do begin  
    print, 'Enter cube pixel x,y,z, when finished enter 0,0,0'

    read,x,y,z
    print,'Finding the detector pixels which fall on cube pixel x,y,z',x,y,z


    index = (z-1)*nplane + (y-1)*nx + (x-1)

    if(x eq 0 or y eq 0 or z eq 0) then continue = 0
    if(continue eq 0) then stop
    print,'Searching for index',index

    ifound = where(index eq index_cube,num)
    print,'number found matching cube pixel',num
    if (num gt 0) then begin
        for i = 0,num-1 do begin

            zz = long(ifound[i])/nmapxy
            ixy = ifound[i] - (long(zz) * long(nmapxy))
            yy = fix(ixy)/naxis1
            xx = ixy - (yy * naxis1)
            print,' detector pixel',xx+1,yy+1
            print,' overlapping amount',overlap[ifound[i]]
            print,' plane in overlapping file',zz+1

        endfor
    endif

endwhile



end
