
pro reading_pltracking,info,status ; called from Pixel Look
;_______________________________________________________________________
; The varibles
; pltrack.pixeldata, .refdata, .pixelstat, .dataro, .statro, .datarp,
; .statrp 
; are intialized to the correct size. 
; The routine - get_ptracking is called to fill in the data 
;_______________________________________________________________________

; _______________________________________________________________________
; initialize the size of the pixeldata,ref data 
; the last index of 3 -;holds the different kinds of data
; 0 : pixel file values
; 1 : random values
; 2 : user defined values
;_______________________________________________________________________  
; initialze the size of the arrays to use in the program
; dimensions as follows:
; 1. group type of  x,y points: set in pixel file (1 and 2) , random (3) or user defined (4)
; 2. number of ints
; 3. number of frames
; 4. number of points in set

; raw data
pixeldata = fltarr(4,info.data.nints,info.data.nramps,info.pltrack.num)
refdata = fltarr(4,info.data.nints,info.data.nramps,info.pltrack.num)
pixelstat = fltarr(4,info.data.nints,info.pltrack.num,2)

; reference output subtracted data
dataro = fltarr(4,info.data.nints,info.data.nramps,info.pltrack.num)
statro = fltarr(4,info.data.nints,info.pltrack.num,2)

; reference pixel subtracted data
datarp = fltarr(4,info.data.nints,info.data.nramps,info.pltrack.num)
statrp = fltarr(4,info.data.nints,info.pltrack.num,2)

; reference corrected data
refcorrect_data = fltarr(4,info.data.nints,info.data.nramps,info.pltrack.num)
refpL =  fltarr(4,info.data.nints,info.data.nramps,info.pltrack.num)
refpR =  fltarr(4,info.data.nints,info.data.nramps,info.pltrack.num)

;data quality flags
id_data = fltarr(4,info.data.nints,info.data.nramps,info.pltrack.num)

;dark corrected
mdc_data = fltarr(4,info.data.nints,info.data.nramps,info.pltrack.num)

;reset corrected
reset_data = fltarr(4,info.data.nints,info.data.nramps,info.pltrack.num)

;rscd corrected
rscd_data = fltarr(4,info.data.nints,info.data.nramps,info.pltrack.num)

;lastframe corrected
lastframe_data = fltarr(4,info.data.nints,info.pltrack.num)

;linearity corrected
lc_data = fltarr(4,info.data.nints,info.data.nramps,info.pltrack.num)


; calculated slope values
slope = fltarr(4,info.data.nints,info.pltrack.num)
unc = fltarr(4,info.data.nints,info.pltrack.num)
zeropt = fltarr(4,info.data.nints,info.pltrack.num)
numgood = fltarr(4,info.data.nints,info.pltrack.num)
id = intarr(4,info.data.nints,info.pltrack.num)
firstsat = fltarr(4,info.data.nints,info.pltrack.num)
nseg = fltarr(4,info.data.nints,info.pltrack.num)
calramp = fltarr(4,info.data.nints,info.data.nramps,info.pltrack.num)

statcalramp = fltarr(4,info.data.nints,info.pltrack.num,2)

rms = fltarr(4,info.data.nints,info.pltrack.num)
max2pt = fltarr(4,info.data.nints,info.pltrack.num)
imax2pt = fltarr(4,info.data.nints,info.pltrack.num)
stdev2pt = fltarr(4,info.data.nints,info.pltrack.num)
slope2pt = fltarr(4,info.data.nints,info.pltrack.num)

; store the reference pixel corrections (to be displayed later - if
;                                                                desired)

if ptr_valid (info.pltrack.pdata) then ptr_free,info.pltrack.pdata
info.pltrack.pdata = ptr_new(pixeldata)
pixeldata = 0 ; free memory

if ptr_valid (info.pltrack.pcalramp) then ptr_free,info.pltrack.pcalramp
info.pltrack.pcalramp = ptr_new(calramp)
calramp = 0 ; free memory

if ptr_valid (info.pltrack.prefdata) then ptr_free,info.pltrack.prefdata
info.pltrack.prefdata = ptr_new(refdata)
refdata = 0 ; free memory

if ptr_valid (info.pltrack.pstat) then ptr_free,info.pltrack.pstat
info.pltrack.pstat = ptr_new(pixelstat)
pixelstat= 0 ; free memory

if ptr_valid (info.pltrack.pdataro) then ptr_free,info.pltrack.pdataro
info.pltrack.pdataro = ptr_new(dataro)
dataro = 0 ; free memory

if ptr_valid (info.pltrack.pstatro) then ptr_free,info.pltrack.pstatro
info.pltrack.pstatro = ptr_new(statro)
statro= 0 ; free memory

if ptr_valid (info.pltrack.pdatarp) then ptr_free,info.pltrack.pdatarp
info.pltrack.pdatarp = ptr_new(datarp)
datarp = 0 ; free memory

if ptr_valid (info.pltrack.pstatrp) then ptr_free,info.pltrack.pstatrp
info.pltrack.pstatrp = ptr_new(statrp)
statrp= 0 ; free memory

if ptr_valid (info.pltrack.pslope) then ptr_free,info.pltrack.pslope
info.pltrack.pslope = ptr_new(slope)
slope = 0 ; free memory

if ptr_valid (info.pltrack.punc) then ptr_free,info.pltrack.punc
info.pltrack.punc = ptr_new(unc)
unc = 0 ; free memory

if ptr_valid (info.pltrack.pzeropt) then ptr_free,info.pltrack.pzeropt
info.pltrack.pzeropt = ptr_new(zeropt)
zeropt = 0 ; free memory

if ptr_valid (info.pltrack.pid) then ptr_free,info.pltrack.pid
info.pltrack.pid = ptr_new(id)
id = 0 ; free memory

if ptr_valid (info.pltrack.pnumgood) then ptr_free,info.pltrack.pnumgood
info.pltrack.pnumgood = ptr_new(numgood)

numgood = 0 ; free memory

if ptr_valid (info.pltrack.pfirstsat) then ptr_free,info.pltrack.pfirstsat
info.pltrack.pfirstsat = ptr_new(firstsat)
firstsat = 0 ; free memory

if ptr_valid (info.pltrack.pnseg) then ptr_free,info.pltrack.pnseg
info.pltrack.pnseg = ptr_new(nseg)
nseg = 0 ; free memory


if ptr_valid (info.pltrack.pstatcalramp) then ptr_free,info.pltrack.pstatcalramp
info.pltrack.pstatcalramp = ptr_new(statcalramp)
statcalramp= 0 ; free memory


if ptr_valid (info.pltrack.prms) then ptr_free,info.pltrack.prms
info.pltrack.prms = ptr_new(rms)
rms = 0 ; free memory


if ptr_valid (info.pltrack.pmax2ptdiff) then ptr_free,info.pltrack.pmax2ptdiff
info.pltrack.pmax2ptdiff = ptr_new(max2pt)
max2pt = 0 ; free memory

if ptr_valid (info.pltrack.pimax2ptdiff) then ptr_free,info.pltrack.pimax2ptdiff
info.pltrack.pimax2ptdiff = ptr_new(imax2pt)
imax2pt = 0 ; free memory

if ptr_valid (info.pltrack.pstdev2ptdiff) then ptr_free,info.pltrack.pstdev2ptdiff
info.pltrack.pstdev2ptdiff = ptr_new(stdev2pt)
stdev2pt = 0 ; free memory

if ptr_valid (info.pltrack.pslope2ptdiff) then ptr_free,info.pltrack.pslope2ptdiff
info.pltrack.pslope2ptdiff = ptr_new(slope2pt)
slope2pt = 0 ; free memory


if ptr_valid (info.pltrack.prefcorrectdata) then ptr_free,info.pltrack.prefcorrectdata
info.pltrack.prefcorrectdata = ptr_new(refcorrect_data)
refcorrect_data = 0 ; free memory


if ptr_valid (info.pltrack.pmdcdata) then ptr_free,info.pltrack.pmdcdata
info.pltrack.pmdcdata = ptr_new(mdc_data)
mdc_data = 0 ; free memory

if ptr_valid (info.pltrack.presetdata) then ptr_free,info.pltrack.presetdata
info.pltrack.presetdata = ptr_new(reset_data)
reset_data = 0 ; free memory

if ptr_valid (info.pltrack.prscddata) then ptr_free,info.pltrack.prscddata
info.pltrack.prscddata = ptr_new(rscd_data)
rscd_data = 0 ; free memory

if ptr_valid (info.pltrack.plastframedata) then ptr_free,info.pltrack.plastframedata
info.pltrack.plastframedata = ptr_new(lastframe_data)
lastframe_data = 0 ; free memory

if ptr_valid (info.pltrack.plcdata) then ptr_free,info.pltrack.plcdata
info.pltrack.plcdata = ptr_new(lc_data)
lc_data = 0 ; free memory


if ptr_valid (info.pltrack.piddata) then ptr_free,info.pltrack.piddata
info.pltrack.piddata = ptr_new(id_data)
id_data = 0 ; free memory

if ptr_valid (info.pltrack.prefpL) then ptr_free,info.pltrack.prefpL
info.pltrack.prefpL = ptr_new(refpL)
refpL = 0 ; free memory

if ptr_valid (info.pltrack.prefpR) then ptr_free,info.pltrack.prefpR
info.pltrack.prefpR = ptr_new(refpR)
refpR = 0 ; free memory

;_______________________________________________________________________  
; 
for i = 0, 0 do begin
    info.pl.group = i
    get_pltracking,info.pl.group,info
endfor



Widget_Control,info.QuickLook,Set_UValue=info

end

;_______________________________________________________________________  
