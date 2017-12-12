pro find_date,time,yr,mn,month,day,hour,min,sec

JD_2000 = 2451544.5d0

JD = double(time)/86400.0d0 ; number of seconds in a day


JD_i = fix(JD)
JD_date = double(JD_2000) + double(JD_i) 
daycnv,JD_date,yr,mn,day,hour

JD_hms = double(JD) - double(JD_i)

JD_hours = JD_hms* 24.0d0
hour = fix(JD_hours)
JD_min = (JD_hours - hour) * 60.0d0
min = fix(JD_min)
JD_sec = (JD_min - min) * 60.0d0
sec = fix(JD_sec)

month = 'null'
if(mn eq 1) then month = 'Jan'
if(mn eq 2) then month = 'Feb'
if(mn eq 3) then month = 'March'
if(mn eq 4) then month = 'April'
if(mn eq 5) then month = 'May'
if(mn eq 6) then month = 'June'
if(mn eq 7) then month = 'July'
if(mn eq 8) then month = 'Aug'
if(mn eq 9) then month = 'Sept'
if(mn eq 10) then month = 'Oct'
if(mn eq 11) then month = 'Nov'
if(mn eq 12) then month = 'Dec'
;print,yr,mn,day,hour,min,sec
end
