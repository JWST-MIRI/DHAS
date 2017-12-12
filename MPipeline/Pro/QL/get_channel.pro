pro get_channel, x, ch
; given an x value - this routine will figure out what channel the
; data is for: Channel 1,2,3 or 4. 

temp = x/4.0
itemp = fix(x/4)
remain = temp - itemp
remain2 = fix(remain*4)


if(remain2 eq 0 ) then remain2 = 4
ch = remain2 

if(ch gt 4) then print, ' Channel returned a value gt 4',ch
end
