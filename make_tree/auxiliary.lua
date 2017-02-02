
local OS = 'Win'
--local OS = 'Linux'

local cmd = {}
cmd['Win'] = {ls='dir /b ', cp='copy /y ', mv='move /y ', mkdir='mkdir ', dirtempl='^%[.*%]$', dirname='%[(.*)%]', d='\\'}
cmd['Linux'] = {ls='ls -F ', cp='cp ', mv='mv ', mkdir='mkdir ', dirtempl='.-/$', dirname='(.-)/$', d='/'}

local auxiliary = {}

auxiliary.FILE = 'file'
auxiliary.DIR = 'dir'

function auxiliary.filetype(str)
   local tp = auxiliary.FILE
   local name = str
   if str:find(cmd[OS].dirtempl) then
      tp = auxiliary.DIR
      name = str:match(cmd[OS].dirname)
   end
   return {name=name, type=tp}
end

function auxiliary.listdir(path)
   path = path or '.'
   local lst = {}
   local f = io.popen(cmd[OS].ls .. path)
   for line in f:lines() do
      lst[#lst+1] = auxiliary.filetype(tostring(line))
   end
   f:close()
   return lst
end

function auxiliary.endswith(s, w)
   local res = s:find(w .. '$')
   return res ~= nil
end

--[[
function auxiliary.split(str, delim)
   local res = {}
   local i,j,k = 1,1,0
   while true do
      j,k = str:find(delim, k+1)
      if j == nil then break end
      res[#res+1] = str:sub(i,j-1)
      i = k+1
   end
   if i < str:len() then res[#res+1]=str:sub(i) end
   return res
end]]

function auxiliary.split(str, delim)
   local fields = {}
   local pattern = string.format("([^%s]+)", delim)
   str:gsub(pattern, function (c) fields[#fields+1]=c end)
   return fields
end

function auxiliary.lines(str)
   return auxiliary.split(str, "\r?\n")
end
--[[
function auxiliary.map(fn, ...)
   local args = {...}
   local res = {}
   if #args == 1 then
      local t = args[1]
      assert(type(t) == 'table', 'Expected table as single argument')
      for i = 1, #t do res[#res+1] = fn(t[i]) end
   else 
      return auxiliary.map(fn, args)
   end
   return res
end]]

function auxiliary.path(p)
   if OS=='Linux' then return p:gsub('\\','/')
   elseif OS=='Win' then return p:gsub('/','\\') end
   return p
end

function auxiliary.load(fname)
   fname = auxiliary.path(fname)
   local file = io.open(fname)
   local str = file:read("*a")
   file:close()
   return str
end

return auxiliary
