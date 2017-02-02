--[[
serialize a table

allowed key type   : number/string/boolean
allowed value type : number/string/boolean/table
does not handle    : metatables

cycles/references are allowed

syntax 
======

   string = table.serialize(table,norefs,dontsort)
   loadstring(string)()

parameters      value       desc
==========      =====       ====
norefs          boolean     don't save references (faster)
dontsort        boolean     don't prettify/arrange alphabetically (faster)
--]]

local format  = string.format
local concat  = table.concat
local type    = type
local tostring= tostring
local sort    = table.sort

local allowed_key_type = {
   number  = true,
   string  = true,
   boolean = true,
}

local allowed_value_type = {
   number = true,
   string = true,
   boolean= true,
   table  = true,
}

local varname = 't'

local serialformat = [[
local %s = 
{%s
}
%s
return %s
]]

function table.serialize(t,norefs,dontsort)
   local stack         = {len = 0}
   local references    = {[t]= varname}
   local assign_refs   = {len = 0}
   local dorefs        = not norefs
   local dosort        = not dontsort
   
   local lastkey,chunks
   while true do
      t,chunks,lastkey = t,chunks or {len = 0},lastkey or nil
      local indent     = string.rep('\t',stack.len+1)
      
      local dosubtable
      for k,v in next,t,lastkey do
         local ktype = type(k)
         local vtype = type(v)
         if allowed_key_type[ktype] and allowed_value_type[vtype] then
            
            
            local formattedv = v
            if vtype == 'boolean' then
               formattedv = tostring(v)
            elseif vtype == 'string' then
               formattedv = format('%q',v)
            end
            
            
            
            local formattedk
            if ktype ~= 'string' then
               formattedk = '['..tostring(k)..']'
            else
               formattedk = format('[%q]',k)
            end
            
            
            if vtype ~= 'table' then
               chunks.len = chunks.len+1
               chunks[chunks.len] = format('\n%s%s = %s,',indent,formattedk,formattedv)
            else
            
               local fullindices
               if dorefs then
                  local formattedi = {len = 0}
                  local refkey
                  for i = 1,stack.len do
                     local s                   = stack[i]
                     formattedi.len            = formattedi.len+1
                     formattedi[formattedi.len]= s.formattedk
                  end
                  formattedi.len            = formattedi.len+1
                  formattedi[formattedi.len]= formattedk
                  fullindices               = concat(formattedi)
               end
            
            
               if not references[v] then
                  chunks.len = chunks.len+1
                  stack.len = stack.len + 1
                  stack[stack.len] = {
                     t         = t,
                     chunks    = chunks,
                     lastkey   = k,
                     keytype   = ktype,
                     formattedk= formattedk,
                     }
                  
                  chunks[chunks.len]= format('\n%s%s = ',indent,formattedk)
                  
                  t,chunks,lastkey  = v,{len= 0},nil
                  
                  dosubtable        = true
               
                  references[v]     = dorefs and format('%s%s',varname,fullindices or '') or true
               
                  break
               elseif dorefs then
                  assign_refs.len             = assign_refs.len+1
                  assign_refs[assign_refs.len]= format('%s%s = %s',varname,fullindices,references[v])
               end
            end
            
            
         end
      end
      
      if not dosubtable then
         local prevchunks = stack[stack.len] and stack[stack.len].chunks
         if dosort then sort(chunks) end
         local stringpairs = concat(chunks)
         if prevchunks then
         
         
            local indent              = string.rep('\t',stack.len)
            local prevchunk           = prevchunks[prevchunks.len]
            prevchunks[prevchunks.len]= prevchunk .. format('\n%s{%s\n%s},',indent,stringpairs,indent)
            
            local s                   = stack[stack.len]
            
            t,chunks,lastkey          = s.t,s.chunks,s.lastkey
            stack.len                 = stack.len - 1
            
            
            
         else
            if dosort then sort(assign_refs) end
            local fullrefs  = concat(assign_refs,'\n')
            return format(serialformat,varname,stringpairs,fullrefs,varname)
         end
      end
   end
end