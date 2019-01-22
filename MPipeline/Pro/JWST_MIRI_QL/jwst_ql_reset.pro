pro jwst_ql_reset,info
info.jwst_data.nints = 0
info.jwst_data.ngroups = 0
info.jwst_data.colstart = 0
info.jwst_data.nints = 0


info.jwst_data.num_frames = 0
info.jwst_data.coadd = 0
info.jwst_data.subarray = 0
info.jwst_data.mode = 0
info.jwst_data.naxis1 = 0
info.jwst_data.naxis2 = 0
info.jwst_data.naxis3 = 0
info.jwst_data.image_xsize = 0
info.jwst_data.image_ysize = 0
info.jwst_data.read_all =0
info.jwst_control.file_raw_exist = 0
info.jwst_control.file_slope_exist = 0
info.jwst_control.file_cal_exist = 0



info.jwst_control.frame_start = info.jwst_control.frame_start_save
info.jwst_control.frame_end = info.jwst_control.frame_start + info.jwst_control.read_limit -1
pixeldata  = 0
info.jwst_image.pixeldata = ptr_new(pixeldata)
info.jwst_image.pixeldata           = ptr_new(pixeldata)
info.jwst_image.ref_pixeldata       = ptr_new(pixeldata)
info.jwst_image.pslope_pixeldata    = ptr_new(pixeldata)
info.jwst_image.prefcorrected_pixeldata = ptr_new(pixeldata)
info.jwst_image.pid_pixeldata       = ptr_new(pixeldata)
info.jwst_image.plc_pixeldata       = ptr_new(pixeldata)


info.jwst_slope.pixeldata           = ptr_new(pixeldata)
info.jwst_slope.ref_pixeldata       = ptr_new(pixeldata)
info.jwst_slope.pslope_pixeldata    = ptr_new(pixeldata)
info.jwst_slope.prefcorrected_pixeldata = ptr_new(pixeldata)
info.jwst_slope.pid_pixeldata       = ptr_new(pixeldata)
info.jwst_slope.plc_pixeldata       = ptr_new(pixeldata)

end
