pro get_this_frame_stat, info


i = info.image.integrationNO
j = info.image.rampNO


if(info.data.read_all eq 0) then begin
    i = 0
    if(info.data.num_frames ne info.data.nramps) then begin 
        j = info.image.rampNO- info.control.frame_start
    endif
endif


info.image.stat = (*info.image.pstat)[i,j,*]
info.image.range = (*info.image.prange)[i,j,*]

; information filled in in read_multi_frames


end
