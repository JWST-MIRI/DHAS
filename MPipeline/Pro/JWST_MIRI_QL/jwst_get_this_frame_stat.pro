pro jwst_get_this_frame_stat, info


i = info.jwst_image.integrationNO
j = info.jwst_image.rampNO


if(info.jwst_data.read_all eq 0) then begin
    i = 0
    if(info.jwst_data.num_frames ne info.jwst_data.ngroups) then begin 
        j = info.jwst_image.rampNO- info.jwst_control.frame_start
    endif
endif


info.jwst_image.stat = (*info.jwst_image.pstat)[i,j,*]
info.jwst_image.range = (*info.jwst_image.prange)[i,j,*]


end
