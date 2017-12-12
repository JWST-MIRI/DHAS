;**************************************************************************
;+
;*NAME:
;
;   DECOMPOSE     (General IDL Library 01) 19-JUL-81
;
;*CLASS:
;
;   PARSING
; 
;*CATEGORY:
;
;*PURPOSE:
;
;   Break file name into component parts, using VMS and RSX11 punctuation rules.
; 
;*CALLING SEQUENCE:
;
;   DECOMPOSE,FILE,DISK,PATH,NAME,EXTN,VERSION
; 
;*PARAMETERS:
;
;   FILE   (REQ) (I) (0) (S)
;          Required input string variable giving the file name in RSX11
;          and VMS file description format, e.g. diska:[myaccount]file.ext;vers
; 
;   DISK   (REQ) (O) (0) (S)
;          Required output string giving the name of the disk. If not 
;          specified in FILE, the value returned will be a null string.
;   PATH    (REQ) (O) (0) (S)
;          Required output string giving the path name. If not specified
;          in FILE, the value returned will be a null string.
;   NAME   (REQ) (O) (0) (S)
;          Required output string giving the name of the file. 
;
;   EXTN   (REQ) (O) (0) (S)
;          Required output string giving the extension, or file type, 
;          associated with FILE.
;
;   VERS   (REQ) (O) (0) (S)
;          Required output string giving the version number for FILE.
;
;
;   in UNIX or ULTRIX
;   To break up '/home/iuerdaf/production/dat/ebcasc.dat'
;   DECOMPOSE,'/home/iuerdaf/production/dat/ebcasc.dat',d,path,name,e,v
;   where,
;       d   =''
;       path ='/home/iuerdaf/production/dat/'
;       name='ebcasc'
;       extn='.dat'
;       vers=''
; 
; 
;*PROCEDURE: 
;
;    DECOMPOSE looks for the '/' and '.' marks used as delimeters in
;    UNIX file names, and through string manipulations, breaks down the file 
;    name into its component parts.
;
;-
;*****************************************************************
 pro file_decompose,file,disk,path,name,extn,version
;
 npar = n_params(0)
;
 if npar eq 0 then begin
     print,'DECOMPOSE,FILE,DISK,PATH,NAME,EXTN,VERSION'
     retall
 endif                          ; npar

 len=strlen(file)
 na=file

 disk=''                        ; default disk name
 sc=strpos(na,':')
 if sc gt 0 then begin          ; parse disk
     disk=strmid(na,0,sc+1)
     len=len-sc-1
     na  =strmid(na,sc+1,len)
 endif                          ; parse disk name

 dlim = '/'
 path = ''
 a = 0
 pos = 0
 repeat begin
     sc = a
     a = strpos(na,dlim,pos)
     pos = a + 1
 end until (a eq -1)
 if (sc gt 0) then begin
     path = strmid(na,0,sc+1) 
     len = len - sc - 1
     na = strmid(na,sc+1,len)
 endif                          ; sc

  ;
 version=''                     ; default version
 sc=strpos(na,';')
 if sc gt 0 then begin          ; parse version number
     version=strmid(na,sc,len-sc)
     na =strmid(na,0,sc)
     len=sc
 endif

; parse version number
  ;
 extn=''                        ; default extension
 sc=strpos(na,'.')
 if sc gt 0 then begin          ; parse extension
     extn=strmid(na,sc,len-sc)
     na =strmid(na,0,sc)
     len=sc
 endif

                         ; parse extension
  ;
 name = na                      ; remainder after the parse = name!
  ;

 return
 end  ; decompose
