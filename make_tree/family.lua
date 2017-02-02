

local person = require "make_tree.person"
local aux = require "make_tree.auxiliary"
local tags = require "make_tree.tags"

local EXT = '.tree'
local TEMPLATE = 'make_tree/template.html'
local INDEX = 'family.html'
-- template tags
local TITLE = 'title'
local HEAD = 'head'
local SIDE = 'side'
local CONTENT = 'content'
local CSS = 'css'
-- image height
local IMG_HEIGHT = 112

local family = {}

-- create family database
function family.new(src)
   local files = aux.listdir(src)
   local ends = EXT .. '$'
   --print(#files)
   local f = {src=src, id={}}
   for i = 1, #files do
      --print(files[i].type, files[i].name)   
      if files[i].type == aux.FILE and aux.endswith(files[i].name, EXT) then         
         local p = person.new(aux.path(src .. '/' .. files[i].name))
         p.file = p.file:gsub(ends, '.html')
         p.shortfile = files[i].name:gsub(ends, '.html')		 
	 table.insert(f.id, p.name)
	 f[p.name] = p
      end
   end
   table.sort(f.id)   
   return f
end

-- save family tree as local site
function family.tohtml(tbl)
   local template = aux.load(aux.path(TEMPLATE))   
   for i = 1, #tbl.id do 
      local pid = tbl.id[i]      
      local p = tbl[pid]    -- get person data
      local text = template:gsub('{(.-)}', 
         function (x)
	    if x == TITLE then return family.str_title(p)
            elseif x == CSS then return 'panels.css'
            elseif x == HEAD then return family.str_name(p)
            elseif x == SIDE then return family.str_side(p)
            elseif x == CONTENT then return family.str_content(tbl, pid)
	    end
	 end)	  
      local f = io.open(family.str_fname(p), "w")
      f:write(text)
      f:close()
   end
   -- create index file
   local text = template:gsub('{(.-)}',
      function (x)
         if x == TITLE then return 'Генеалогия'
         elseif x == CSS then return tbl.src .. '/panels.css'
         elseif x == HEAD then return 'Моя Семья'
         elseif x == SIDE then return ''
         elseif x == CONTENT then return family.str_index(tbl)
         end
      end)
   local f = io.open(INDEX, 'w')
   f:write(text)
   f:close()
end

-- get file name
function family.str_fname(p)   
   return p.file
end

-- get page title
function family.str_title(p)
   return p.name
end

-- get main header
function family.str_name(p)
   return p.name
end

-- get local header
function family.str_header(tag)
   return string.format("<h3 align=\"center\"><a name=\"%s\">%s</a></h3>", tags.eng[tag], tag)
end

-- get panel content
function family.str_side(p)
   local s = {}
   local templ = "<a href=\"#%s\">%s</a>"
   table.insert(s, string.format(templ, tags.eng[tags.bio], tags.bio))
   if p.parent_id or p.married then
      table.insert(s, string.format(templ, tags.eng[tags.family], tags.family))
   end
   for i = 2, #p do
      if tags.heads[p[i].tag] then
         table.insert(s, string.format(templ, tags.eng[p[i].tag], p[i].tag))
      end
   end
   table.insert(s, string.format("<br><a href=\"%s\">%s</a>", '../' .. INDEX, tags.index))
   return table.concat(s, '<br>\n')
end

-- convert table to html-text
-- {{title,image,name},{title,image,name}...}
function family.str_table(tbl, fam)
   local s = {}
   -- check span
   local span = {1}
   local last = tbl[1].title
   local i = 2
   while i <= #tbl do
      if tbl[i].title == last then span[#span]=span[#span]+1 else
         span[#span+1] = 1
         last = tbl[i].title
      end
      i = i + 1
   end
   s[#s+1] = '<table><tr>'
   -- title
   i = 0
   for j = 1, #span do
      i = i + span[j]
      s[#s+1] = string.format("  <th colspan=\"%d\">%s</th>",span[j],tbl[i].title)
   end
   s[#s+1] = ' </tr>'
   -- image
   s[#s+1] = ' <tr>'
   for j = 1, #tbl do
      local img = (tbl[j].img == '::') and '::' 
         or string.format("<img src=\"%s\" height=\"%d\">", tbl[j].img, IMG_HEIGHT)
      s[#s+1] = string.format("  <th>%s</th>", img)
   end
   s[#s+1] = ' </tr>'
   -- names
   s[#s+1] = ' <tr>'
   for j = 1, #tbl do
      -- add link here
      local pid = tbl[j].name
      local pname = string.gsub(pid, ' ', '<br>', 1)
      if fam[pid] then 
         pname = string.format("<a href=\"%s\">%s</a>",fam[pid].shortfile, pname)
      end
      s[#s+1] = string.format("  <td align=\"center\">%s</td>", pname)
   end
   s[#s+1] = '</tr></table>'
   return table.concat(s, '\n')
end

function family.str_comment(txt)
   return string.format("<small>* %s</small>", txt)
end

-- get representation of family
function family.str_family(t, id)
   local p = t[id]
   if not (p.parents or p.married) then return "" end
   local s = {family.str_header(tags.family)}
   -- parents
   if p.parents then
      local parent = {}
      for i = 1, #p.parents do
         local pid = p.parents[i]
         parent[#parent+1] = {
            title=tags.parents,
            img  =t[pid] and t[pid].portrait or person.NO_PORTRAIT,
            name =pid
         }
      end
      s[#s+1] = family.str_table(parent, t)
      if p.parents_comment then s[#s+1] = family.str_comment(p.parents_comment) end
   end
   -- married
   if p.married then
      for i = 1, #p.married do
         local mid = p.married[i].id
         local fam = {{
            title=tags.married,
            img  =t[mid] and t[mid].portrait or person.NO_PORTRAIT,
            name =mid
         }}
         -- children
         if p.married[i].children then
            fam[#fam+1] = {title="", img="::", name=""}
            local children = p.married[i].children
            for j = 1, #children do
               local cid = children[j]
               fam[#fam+1] = {
                  title=tags.children,
                  img  =t[cid] and t[cid].portrait or person.NO_PORTRAIT,
                  name =cid
               }
            end
         end
         s[#s+1] = family.str_table(fam, t)
         if p.married[i].comments then s[#s+1] = family.str_comment(p.married[i].comments) end
      end
   end
   return table.concat(s, '\n')
end

-- get additional person description
function family.biography(p)
   if not p.heads then return "" end
   local bio = {}
   for i = 1,#p.heads do
      local hd = p.heads[i]
      bio[#bio+1] = family.str_header(hd)
      bio[#bio+1] = '<p>'
      local _, pos = person.text(p, hd)      
      for t in person.desc(p, pos) do
         bio[#bio+1] = family.str_desc(t)
      end
      bio[#bio+1] = '</p>'
   end
   return table.concat(bio, '\n')
end

-- description tags
function family.str_desc(t)
   if t.tag == tags.where then
      return string.format(" <b>%s</b><br>", t.text)
   elseif t.tag == tags.when then
      return string.format(" <i>%s</i><br>", t.text)
   elseif t.tag == tags.photo then
      return string.format(" <img src=\"%s\">", aux.path(person.IMG_DIR .. '/' .. t.text)) 
   elseif t.tag == tags.link then
      return string.format(" <a href=\"%s\">%s</a><br>", t.text, t.text)
   else
      return t.text:gsub('\r?\n', '<br>') .. "<br><br>"
   end
end

-- get string with main info
function family.main(p)
   local s = {'<table><tr>'}
   s[#s+1] = '<td>'
   s[#s+1] = string.format("<img src=\"%s\" height=\"%d\">", p.portrait, IMG_HEIGHT+30)
   s[#s+1] = '</td><td>'
   if p.maindesc then 
      s[#s+1] = p.maindesc:gsub('\r?\n', '<br>')
   end
   if p.mainlnk then
      s[#s+1] = string.format("<br><a href=\"%s\">%s</a>", p.mainlnk, p.mainlnk)
   end
   s[#s+1] = '</td></tr></table>'
   return table.concat(s, '\n' )  
end

-- get all information about person
function family.str_content(t, id)
   local p = t[id]
   local content = {string.format("<a name=\"%s\"></a>",tags.eng[tags.bio])}
   table.insert(content, family.main(p))
   local s = family.str_family(t, id)
   if s:len() > 0 then table.insert(content, s) end
   s = family.biography(p)
   if s:len() > 0 then table.insert(content, s) end
   return table.concat(content, '\n')   
end

-- create index list
function family.str_index(t)
   local s = {'<div>'}
   local first = ''
   for i = 1, #t.id do
      local name = t.id[i]
      -- add letter to list
      local ch = name:match("(.[\128-\191]*)")
      if ch ~= first then
         s[#s+1] = string.format("<h4>%s</h4>", ch)
         first = ch
      end
      s[#s+1] = string.format("<a href=\"%s\">%s</a><br>", family.str_fname(t[name]), name)
   end
   s[#s+1] = '</div>'
   return table.concat(s, '\n')
end

return family

