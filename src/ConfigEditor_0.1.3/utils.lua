
function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

function string.ends(String,End)
   return End=='' or string.sub(String,-string.len(End))==End
end

function string.explode(d,p)
  local t, ll
  t={}
  ll=0
  if(#p == 1) then return {p} end
    while true do
      l=string.find(p,d,ll,true) -- find the next d in the string
      if l~=nil then -- if "not not" found then..
        table.insert(t, string.sub(p,ll,l-1)) -- Save it in our array.
        ll=l+#d -- save just after where we found it for searching next time.
      else
        table.insert(t, string.sub(p,ll)) -- Save what's left in our array.
        break -- Break at end, as it should be, according to the lua manual.
      end
    end
  return t
end

function table.merge(t1, t2)
    for k,v in pairs(t2) do
    	if type(v) == "table" then
    		if type(t1[k] or false) == "table" then
    			table.merge(t1[k] or {}, t2[k] or {})
    		else
    			t1[k] = v
    		end
    	else
    		t1[k] = v
    	end
    end
    return t1
end

function table.count(tbl)
	local i = 0
	
	for k, v in pairs(tbl) do
		i = i + 1
	end
	
	return i	
end


function _def_value(dataType)

	if dataType == "string" then
		return ""
	elseif dataType == "number" then
		return 0
	elseif dataType == "boolean" then
		return false
	elseif dataType == "table" then
		return {}
	else
		return nil
	end
end


function _tostring(data)
	
	local str = ""
	
	local t = type(data)
	
	if t == "table" then
		str = str .. " {"
		
		for k, v in pairs(data) do
			str = str .. k .. " => " .. _tostring(v) .. ","
		end
		
		str = str .. "}"
	
	else
		str = str .. tostring(data) .. ","
	end
	
	return str
end

function gPrint(text)
	for _, player in pairs(game.players) do
		player.print(text)
	end
end