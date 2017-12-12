pro read_pixel_tracking_file,info,status,error_message
;_______________________________________________________________________
; Read in the pixel tracking file defined in the preferences file
; read in the x,y pixel values. This program is only set up to read
; in 8 pixels. The 8 pixels are split into 2 groups; each with 4 pixel
; This routine intializes tje size and values for the ptrack.px, .py
; .pch values

; read the header of the data file to
; determine how many integrations and frames the file contains. Then
; the varibles: ptrack.pixeldata, .refdata, .pixelstat, .dataro,
; .statro, .datarp, .statrp are set up
; (they are initialized to the correct size but the values are not
; read in yet)
; pixeldata, refdata and pixelstat are filled in get_pltracking
; dataro, datarp are filled in mfl_correct_pixels

;_______________________________________________________________________
status = 0
get_lun,iunit
;file = info.control.dircal + '/' + info.control.tracking_file
file = info.control.miri_dir + 'Preferences/'+info.control.tracking_file
print,info.control.dircal
file = strcompress(file,/remove_all)
file_exist1 = file_test(file,/regular,/read)
if(file_exist1 ne 1 ) then begin
    error_message = "The file does not exist: " +file
    status = 1
    free_lun,iunit
    return
endif

Print,' Reading Pixel Tracking file',file

openr,iunit,file,error=err
if(err ne 0) then print, " Error opening file ", file + "  " +$
!ERROR_STATE.MSG
free_lun,iunit


data = read_ascii (file,comment_symbol="#")
temp = data.(0)

imode = temp[0,*]
ixall = temp[1,*]
iyall = temp[2,*]
refall = temp[3,*] 

index = where(imode eq info.data.subarray,inum)

if(inum gt 1) then begin
    ix = ixall[index]
    iy = iyall[index]
    iref = refall[index]
endif
; problem with file:

if(inum lt 1) then begin
    index = where(imode eq 0,inum); could not find info.data.subarray type
                                ; so hard code it to 

    ix_middle = info.data.image_xsize/2
    ix_shift = info.data.image_xsize/8
    ix_left = info.data.image_xsize/4
    ix_right  = ix_left + ix_middle

    ix_middle2 = ix_middle + ix_shift
    ix_left2 = ix_left - ix_shift
    ix_right2 = ix_right + ix_shift
    
    iy_middle = info.data.image_ysize/2
    iy_shift = info.data.image_ysize/8
    iy_left = info.data.image_ysize/4
    iy_right  = iy_left + iy_middle

    iy_middle2 = iy_middle + iy_shift
    iy_left2 = iy_left - iy_shift
    iy_right2 = iy_right + iy_shift


        ix = [ix_middle,ix_left,ix_left,ix_right,ix_right,$
              ix_middle2,ix_left2,ix_left2,ix_right2,ix_right2]
        iy = [iy_middle,iy_left,iy_right,iy_left,iy_right,$
              iy_middle2,iy_left2,iy_right2,iy_left2,iy_right2]
        iref =[0,0,0,0,0,0,0,0,0,0]
endif

num = n_elements(ix)
if(num gt 10) then num = 10 ; only set up to read 10 pixels
                          ; group 1 with 5 pixels
                          ; group 2 with 5 pixels


info.pltrack.num = 5            ; hard coded to only hold- plot 5 values at a time
info.pltrack.num_group[0] = 0
info.pltrack.num_group[0] = 5
if(num lt 5) then info.pltrack.num_group[0] = num
if(num gt 5) then info.pltrack.num_group[1] = num -5
num_group = info.pltrack.num_group[0]

; 4 groups - set A, set B, Random and User Defined
; 4 pixels

ixx = intarr(4,5)
iyy = intarr(4,5)
ch = intarr(4,5) ; set size and initialize to zero
jref = intarr(4,5)


ixx[0,*] = ix[ 0:num_group-1 ]
iyy[0,*] = iy[ 0:num_group-1 ]
jref[0,*] = iref[ 0:num_group-1 ]
if(num gt 5) then begin
    
    ixx[1,*] = ix[ 5 :num-1 ]
    iyy[1,*] = iy[ 5 :num-1 ]
    jref[1,*] = iref[ 5 :num-1 ]
endif


if ptr_valid (info.pltrack.px) then ptr_free,info.pltrack.px
info.pltrack.px = ptr_new(ixx)

if ptr_valid (info.pltrack.py) then ptr_free,info.pltrack.py
info.pltrack.py = ptr_new(iyy)

if ptr_valid (info.pltrack.pref) then ptr_free,info.pltrack.pref
info.pltrack.pref = ptr_new(jref)

if ptr_valid (info.pltrack.pch) then ptr_free,info.pltrack.pch
info.pltrack.pch = ptr_new(ch)


ch = 0 ; free memory

ix = 0 ; free memory
ixx = 0

iy= 0 ; free memory
iyy = 0

iref= 0 ; free memory
jref = 0
imode = 0
ixall = 0
iyall = 0
refall = 0

end
