pro jwst_setup_cube,cv_control,view_cube,jwst_cube,spectrum,roi,status

; Load Cube
;____________________________________________________________________
cube_file = dialog_pickfile(/read,$
                            get_path=realpath,Path=cv_control.dirCube,$
                            filter = '*.fits',title='Please select Cube to Read and View')
 
status = 0
len = strlen(realpath)
realpath = strmid(realpath,0,len-1) ; just to be consistent 
cv_control.dirCube = realpath
    
if(cube_file eq '')then begin
    print,' No file selected, can not read in cube'
    status = 2
    return
endif
if (cube_file NE '') then begin
    cv_control.filename_cube = cube_file
endif
            
slash_str = strsplit(cv_control.filename_cube,'/',/extract)
n_slash = n_elements(slash_str)
if (n_slash GT 1) then begin
    out_filebase = slash_str[n_slash-1]
endif else begin
    out_filebase = cv_control.filename_cube
endelse
len = strlen(out_filebase)
out_filebase = strmid(out_filebase,0,len-5)

cv_control.file_cube_base = out_filebase ; only the filename not directory
status = 0
error_message = ' '

jwst_read_cube,cv_control.filename_cube,jwst_cube,status,error_message

if(status eq 1) then begin
    result = dialog_message(error_message,/error)
    return
endif

middle_wave = jwst_cube.iend_wavelength/2
view_cube.this_iwavelength = middle_wave
xsize_image = jwst_cube.naxis1
ysize_image = jwst_cube.naxis2
view_cube.zoom_user = 1

jwst_cv_screen_size,cv_control.max_x_window, cv_control.max_y_window,$
                      xsize_image,ysize_image,$
                      zoom,$
                      xscreen_size,yscreen_size

view_cube.zoom = zoom
view_cube.plot_xsize = xscreen_size
view_cube.plot_ysize = yscreen_size

view_cube.xpos_cube= jwst_cube.naxis1/2
view_cube.ypos_cube = jwst_cube.naxis2/2

view_cube.plot_xsize_org = view_cube.plot_xsize
view_cube.plot_ysize_org = view_cube.plot_ysize

view_cube.plot_pixel = 0

; set up defaults of the roi being the entire image

xbox = view_cube.zoom * (jwst_cube.naxis1-1)
ybox = view_cube.zoom * (jwst_cube.naxis2-1)
            
(*roi).tempxbox = xbox
(*roi).tempybox = ybox
(*roi).boxx0 = 0
(*roi).boxy0 = 0

; Get various information from the ROI structure,
; use this information to calculate new info to store back into the ROI.
if ( (*roi).tempxbox gt (*roi).boxx0 ) then begin
    x1 = (*roi).boxx0/(view_cube.zoom*view_cube.zoom_user)
    x2 = (*roi).tempxbox/(view_cube.zoom*view_cube.zoom_user)
endif else begin
    x2 = (*roi).boxx0/(view_cube.zoom*view_cube.zoom_user)
    x1 = (*roi).tempxbox/(view_cube.zoom*view_cube.zoom_user)
endelse
if ((*roi).tempybox gt (*roi).boxy0) then begin
    y1 = (*roi).boxy0/(view_cube.zoom*view_cube.zoom_user)
    y2 = (*roi).tempybox/(view_cube.zoom*view_cube.zoom_user)
endif else begin
    y2 = (*roi).boxy0/(view_cube.zoom*view_cube.zoom_user)
    y1 = (*roi).tempybox/(view_cube.zoom*view_cube.zoom_user)
endelse


(*roi).roix1 = x1 
(*roi).roiy1 = y1 
(*roi).roix2 = x2
(*roi).roiy2 = y2

jwst_cube.x1 = x1
jwst_cube.x2 = x2
jwst_cube.y1 = y1
jwst_cube.y2 = y2

jwst_extract_spectrum_from_cube,x1,x2,y1,y2,jwst_cube,spectrum,status




end
