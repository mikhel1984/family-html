
local aux = require "make_tree.auxiliary"
local tags = require "make_tree.tags"

local person = {}

person.PORTRAIT = 'none.png'
person.IMG_DIR = 'img'
person.NO_PORTRAIT = aux.path(person.IMG_DIR .. '/' .. person.PORTRAIT)

-- get tags and text from file
function person.parse(fname)   
   local str = aux.load(fname)   
   str = str:gsub('%-%-.-\n','\n')    -- remove string comments
   local res = {}
   for t in str:gmatch('{.-}[^{]*') do
      local tag, text = t:match('{(.-)}%s*(.-)%s*$')      
      if text:len() > 0 or tags.heads[tag] then
         res[#res+1] = {tag=tag, text=text}
      end
   end       
   res.file = fname  
   return res
end

-- create iterator for descriptional elements
function person.desc(tbl, pos)
   local i = pos
   return function()
             i = i + 1
	     return (tbl[i] and tags.description[tbl[i].tag]) and tbl[i] or nil
	  end
end

-- return text and position for given tag
function person.text(tbl, tag, pos)
   pos = pos or 2        -- start position
   for i = pos, #tbl do
      if tbl[i].tag == tag then return tbl[i].text, i end
   end
   return nil
end

-- get persone data
function person.new(fname)
   local p = person.parse(fname)
   person.analize(p)
   return p
end

-- find main elements of persone description
function person.analize(tbl)
   assert(tbl[1].tag==tags.main, "First must be 'ФИО' tag")   
   tbl.name = tbl[1].text
   -- get portrait and description
   tbl.portrait = person.PORTRAIT
   for t in person.desc(tbl, 1) do
      if t.tag == tags.photo then
         tbl.portrait = t.text
      elseif t.tag == tags.maindesc then
         tbl.maindesc = t.text	 
      elseif t.tag == tags.link then
         tbl.mainlnk = t.text
      end
   end
   tbl.portrait = aux.path(person.IMG_DIR .. '/' .. tbl.portrait)
   -- get parents
   local parents_txt, parents_pos = person.text(tbl, tags.parents)
   if parents_txt then 
      tbl.parents = aux.lines(parents_txt)  -- split into lines
      if tbl[parents_pos+1] and tbl[parents_pos+1].tag == tags.maindesc then
         tbl.parents_comment = tbl[parents_pos+1].text
      end		 
   end
   -- get children
   tbl.married = {}
   local married_txt, married_pos = person.text(tbl, tags.married)
   while married_txt do
      local m = { id = married_txt }      
      while tbl[married_pos+1] do
         married_pos = married_pos+1
         if tbl[married_pos].tag == tags.children then
            m.children = aux.lines(tbl[married_pos].text)         -- get list of children
         elseif tbl[married_pos].tag == tags.maindesc then
            m.comments = tbl[married_pos].text                    -- get comments
         else
            break
         end
      end
      tbl.married[#tbl.married+1] = m
      married_txt, married_pos = person.text(tbl, tags.married, married_pos)
   end
   if #tbl.married == 0 then tbl.married = nil end
   -- get heads
   local heads = {}
   for i = 2, #tbl do
      if tags.heads[tbl[i].tag] then heads[#heads+1] = tbl[i].tag end	
   end
   if #heads > 0 then tbl.heads = heads end
end

return person
