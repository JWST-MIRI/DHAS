pro read_extract_files,inlist,nx,ny,nz,wavenew

openr,lun,inlist,/get_lun

list = strarr(1200)
i = 0
infile  = 'abc'
while (not eof(lun)) do begin
readf,lun,infile
list[i] = infile
print,infile

i = i + 1

endwhile

close, lun
free_lun,lun

numfiles = i


for i = 0,numfiles -1 do begin 
   close,10
   
   openr,10,list[i]
   line = 'a' 
   readf,10,line
   readf,10,line
   sxpos = 'FOV X-position'
   sypos = 'FOV Y-position'
   readf,10,format= '(a22,i4)',sxpos,x
   readf,10,format= '(a22,i4)',sypos,y
   print,list[i],x,y
   for j = 0,nz -1 do begin
	readf,10,xx,w
	wavenew[x-1,y-1,j] = w
   endfor	
   close,10
   
endfor


end



