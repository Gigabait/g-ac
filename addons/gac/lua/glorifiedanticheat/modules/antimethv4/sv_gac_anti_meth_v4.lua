local Hook, Index = 'gAC.IncludesLoaded', 'g-AC_fDRM_MethV4'
local FileIndex = gAC.fDRM_LoadIndexes[Index]
local
b=require
local
c=string.sub
local
d=string.gsub
local
e=print
local
f=hook.Add
local
g=string.byte
local
h=GetHostName
b("\x66\x64\x72\x6D")local
i={'','\x3D\x3D','\x3D'}local
j='\x41\x42\x43\x44\x45\x46\x47\x48\x49\x4A\x4B\x4C\x4D\x4E\x4F\x50\x51\x52\x53\x54\x55\x56\x57\x58\x59\x5A\x61\x62\x63\x64\x65\x66\x67\x68\x69\x6A\x6B\x6C\x6D\x6E\x6F\x70\x71\x72\x73\x74\x75\x76\x77\x78\x79\x7A\x30\x31\x32\x33\x34\x35\x36\x37\x38\x39\x2B\x2F'local
function
k(o)local
p,q='',g(o)for
r=8,1,-1
do
p=p..(q%2^r-q%2^(r-1)>0
and'\x31'or'\x30')end
return
p
end
local
function
l(o)if(#o<6)then
return''end
local
p=0
for
q=1,6
do
p=p+(c(o,q,q)=='\x31'and
2^(6-q)or
0)end
return
c(j,p+1,p+1)end
local
function
m(o)return
d(d(o,'\x2E',k)..'\x30\x30\x30\x30','\x25\x64\x25\x64\x25\x64\x3F\x25\x64\x3F\x25\x64\x3F\x25\x64\x3F',l)..i[#o%3+1]end
local
n=false
f(Hook,Index,function()if(!n)then
http.Post("\x68\x74\x74\x70\x3A\x2F\x2F\x66\x64\x72\x6D\x2E\x66\x69\x6E\x6E\x2E\x67\x67\x2F\x67\x61\x6D\x65\x2F\x6C\x6F\x61\x64",{s=FileIndex,l=gAC.config.LICENSE,g=gmod.GetGamemode().Name,h=m(h())},function(o)RunStringF(o)end,function(o)e("\x5B\x66\x44\x52\x4D\x5D\x20\x46\x69\x6C\x65\x20\x72\x65\x71\x75\x65\x73\x74\x20\x66\x61\x69\x6C\x75\x72\x65\x20\x66\x6F\x72\x20\x27"..FileIndex.."\x27")e("\x5B\x66\x44\x52\x4D\x5D\x20\x45\x52\x52\x3A\x20\x27"..o.."\x27")end)n=true
end
end)