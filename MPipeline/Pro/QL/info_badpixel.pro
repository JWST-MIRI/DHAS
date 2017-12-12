pro info_badpixel,event

data_id =' The option to apply the bad_pixel mask must be set in miri_sloper ' + string(10b) + $
         ' (miri_sloper +b) for the bad_pixel counting statistic to be correct on reduced data.' + $
         string(10b) + $
         '  If it is not set, then the number given ais just the # of saturated pixels'

result = dialog_message(data_id,/information)
end
