pro jwst_dqflags,info
  

  data_id ='ID flag '+ strcompress(string(info.jwst_dqflag.donotuse),/remove_all) +' = '+ info.jwst_dqflag.Sdonotuse + string(10b) + $
           'ID flag '+ strcompress(string(info.jwst_dqflag.Saturated),/remove_all) +  ' = ' + info.jwst_dqflag.SSaturated + string(10b) + $
           'ID flag '+ strcompress(string(info.jwst_dqflag.Jump),/remove_all) +  ' = ' + info.jwst_dqflag.Sjump + string(10b) + $
           'ID flag '+ strcompress(string(info.jwst_dqflag.UnrelError),/remove_all) +  ' = ' + info.jwst_dqflag.Sunrelerror + string(10b) + $
           'ID flag '+ strcompress(string(info.jwst_dqflag.nonscience),/remove_all) +  ' = ' + info.jwst_dqflag.SNonscience + string(10b) + $
           'ID flag '+ strcompress(string(info.jwst_dqflag.dead),/remove_all) +  ' = ' + info.jwst_dqflag.Sdead + string(10b) + $
           'ID flag '+ strcompress(string(info.jwst_dqflag.hot),/remove_all) +  ' = ' + info.jwst_dqflag.Shot + string(10b) + $
           'ID flag '+ strcompress(string(info.jwst_dqflag.warm),/remove_all) +  ' = ' + info.jwst_dqflag.Swarm + string(10b) + $
           'ID flag '+ strcompress(string(info.jwst_dqflag.lowqe),/remove_all) +  ' = ' + info.jwst_dqflag.Slowqe + string(10b) + $
           'ID flag '+ strcompress(string(info.jwst_dqflag.rc),/remove_all) +  ' = ' + info.jwst_dqflag.Src + string(10b) + $
           'ID flag '+ strcompress(string(long(info.jwst_dqflag.nonlinear)),/remove_all) +  ' = ' + info.jwst_dqflag.Snonlinear +  string(10b) +$
           'ID flag '+ strcompress(string(long(info.jwst_dqflag.bad_refpixel)),/remove_all) +  ' = ' + info.jwst_dqflag.sbad_refpixel +  string(10b) + $ 
           'ID flag '+ strcompress(string(info.jwst_dqflag.no_flatfield),/remove_all) +  ' = ' + info.jwst_dqflag.sno_flatfield + string(10b) + $
           'ID flag '+ strcompress(string(info.jwst_dqflag.unrel_dark),/remove_all) +  ' = ' + info.jwst_dqflag.sunrel_dark + string(10b) + $
           'ID flag '+ strcompress(string(info.jwst_dqflag.unrel_slope),/remove_all) +  ' = ' + info.jwst_dqflag.sunrel_slope + string(10b) + $
           'ID flag '+ strcompress(string(info.jwst_dqflag.unrel_flat),/remove_all) +  ' = ' + info.jwst_dqflag.sunrel_flat + string(10b) + $
           'ID flag '+ strcompress(string(info.jwst_dqflag.unrel_reset),/remove_all) +  ' = ' + info.jwst_dqflag.sunrel_reset + string(10b) + $
           'ID flag '+ strcompress(string(info.jwst_dqflag.ref_pixel),/remove_all) +  ' = ' + info.jwst_dqflag.sref_pixel + string(10b) 

        result = dialog_message(data_id,/information)

end
