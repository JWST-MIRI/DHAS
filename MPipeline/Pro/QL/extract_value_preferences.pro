pro extract_value,line,value,flag
flag = 0   
len = strlen(line) 
eqstring = '='
eqs= strpos(line,eqstring,/reverse_search)
subline = strmid(line,eqs,len)
value = strtrim(subline)
ln = strlen(value)
if(ln le 1) then flag = 0
if(ln gt 1) then begin
    
    value = strmid(value,1,ln)
    newvalue = strtrim(value)
    value = newvalue
    flag = 1
endif
end


pro extract_key,line,key,value
flag = 0   
len = strlen(line) 
eqstring = '='
eqs= strpos(line,eqstring)

cstring = ':'
cc= strpos(line,cstring)
key = strmid(line,0,eqs)
key = strcompress(key,/remove_all)

len = cc - eqs -1
subline = strmid(line,eqs+1,len)

value = strcompress(subline,/remove_all)
;print,'key',key,strlen(key)
;print,'value',value,strlen(value)

end

