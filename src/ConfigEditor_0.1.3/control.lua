require("utils")
require("inspect")

function on_player_joined_game(event)
	local player = game.players[event.player_index]
	
	if player.admin then
		create_gui_button(player)
	end
end

function on_init()
	if global.modConfigs == nil then
		global.modConfigs = {}
	end
	
	if global.playerData == nil then
		global.playerData = {}
	end
	
	global.config_changed_event = script.generate_event_name()
end

function on_configuration_changed()
	if global.modConfigs == nil then
		global.modConfigs = {}
	end
	
	if global.playerData == nil then
		global.playerData = {}
	end
	
	global.config_changed_event = script.generate_event_name()
end

--[[ REMOTE FUNCTIONS ]]--

--[[
	Get the generated ID for the config_changed event.
	
	@return uid
]]--
function get_config_changed_event()
	return global.config_changed_event
end

--[[
	Set a field on a mod configuration
	
	@param	string		modName			The name of the mod.
	@param	string		field			The field to set_field.
	@param	*			value			The default value of the field.
	@param	string|nil	dataType		The type of the field. If nil, will be determined by the value.
	@param	string|nil	description		The description of the field. Will be added to the tooltip.
	@param	boolean|nil	readonly		Is this field readonly? Defaults to false.
	
	@return void
]]--
function set_field(modName, field, value, dataType, title, description, readonly)
	if global.modConfigs[modName] == nil then
		global.modConfigs[modName] = {}
	end
	
	dataType = dataType or type(value)
	
	global.modConfigs[modName][field] = {
		type = dataType,
		title = title or field,
		value = value or _def_value(dataType),
		description = description or "",
		readonly = readonly or false
	}
	
	_Raise_Event(modName)
end

--[[
	Set all fields of a mod configuration
	
	@param	string		modName			The name of the mod.
	@param	table		data			The new configuration of the mod, see below for format.
	@param	boolean		overwrite		True to overwrite the mod configuration. This will delete any field that is not present in the data parameter. Defaults to false.
	
	data format:
	data = {
		Field1 = {				-- The name of the field.
			type = "dataType", 	-- The type of the value (string, number, boolean and table is currently supported).
			title = "",			-- The human-readable name of this field. (OPTIONAL).
			description = "",	-- The description of this field. (OPTIONAL).
			value = "",			-- The default value of this field. (OPTIONAL).
			readonly = false	-- Is this field readonly? Defaults to false (OPTIONAL).
			
		}
	}
	
	@return true|false, string			Returns true if the mod was changed, false and a string is returns if an error occurred.
]]--
function set_fields(modName, data, overwrite)
	overwrite = overwrite or false
	
	if type(data) ~= "table" then
		return false, "Parameter 'data' is not a table"
	end
	
	local mData = {}
	
	for k, v in pairs(data) do
		if type(v) ~= "table" then
			return false, "Field '" .. k .. "' in parameter 'data' is not a table"
		end
		
		local dataType = v["type"]
		if dataType == nil and v["value"] == nil then
			return false, "Field '" .. k .. "' in parameter 'data' is missing 'type'"
		elseif dataType == nil then
			dataType = type(v["value"])
		end
		
		mData[k] = {
			type = dataType,
			title = v["title"] or k,
			value = v["value"] or _def_value(v["type"]),
			description = v["description"] or "",
			readonly = v["readonly"] or false
		}
	end
	
	if overwrite then
		global.modConfigs[modName] = mData
	else
		if global.modConfigs[modName] == nil then
			global.modConfigs[modName] = {}
		end
	
		for k, v in pairs(mData) do
			global.modConfigs[modName][k] = v
		end
	end
	
	_Raise_Event(modName)
	return true
end

--[[
	Returns the value of a mod configurations field
	
	@param	string	modName		The name of the mod.
	@param	string	field		The name of the field.
	
	@return	nil|*		Returns nil if the field doesn't exist. Otherwise the value of the field.
]]--
function get_value(modName, field)
	
	if global.modConfigs[modName] == nil or global.modConfigs[modName][field] == nil then
		return nil
	end
	
	return global.modConfigs[modName][field]["value"]
end

--[[
	Return the whole field of a mod's configurations field
	
	@param	string	modName		The name of the mod.
	@param	string	field		The name of the field.
	
	@return nil|table	Returns nil if the field doesn't exist. Otherwise the field itself.
]]--
function get_field(modName, field)
	if global.modConfigs[modName] == nil or global.modConfigs[modName][field] == nil then
		return nil
	end
	
	return global.modConfigs[modName][field]
end

--[[
	Return a table of all fields in a mod's configuration
	
	@param	string	modName		The name of the mod.
	
	@return nil|table Returns nil if the mod doesn't exist. Otherwise all the fields.
]]--
function get_fields(modName)
	if global.modConfigs[modName] == nil then
		return nil
	end
	
	return global.modConfigs[modName]
end

--[[
	Check to see if a mod has added any configuration fields
	
	@param	string	modName		The name of the mod.
	
	@return boolean
]]--
function mod_exists(modName)
	return global.modConfigs[modName] ~= nil
end


function _generate_compatible_output(data, tbl)
	tbl = tbl or {}
	
	for k, v in pairs(data) do
	
		local vType = type(v)
		
		local field = {
			title = k,
			description = k
		}
		
		if vType == "table" then
			field["type"] = "table"
			field["value"] = _generate_compatible_output(v, {})
		elseif vType == "number" then
			field["type"] = "number"
			field["value"] = v or _def_value("number")
		elseif vType == "string" then
			field["type"] = "string"
			field["value"] = v or _def_value("string")
		elseif vType == "boolean" then
			field["type"] = "boolean"
			field["value"] = v or _def_value("boolean")
		end
		
		tbl[k] = field
	end
	
	return tbl
end


--[[
	Convert a table to a compatible config table
	
	@param	table		data		The table to convert
	@param	boolean		writeFile	True if you want the table to be printed to an lua file in the 'script-output' folder. (Defaults to false)
	
	@return table The newly formatted table
]]--
function generate_compatible_output(data, writeFile)
	writeFile = writeFile or false

	local tbl = {}
	
	_generate_compatible_output(data, tbl)
	
	if writeFile then
		game.write_file("compatible_output.lua", inspect(tbl), false)
	end
	
	return tbl
end



--[[ REMOTE DECLARATION ]]--

remote.add_interface("Config Editor", {
	get_config_changed_event = get_config_changed_event,
	set_field = set_field,
	set_fields = set_fields,
	get_field = get_field,
	get_fields = get_fields,
	get_value = get_value,
	mod_exists = mod_exists,
	generate_compatible_output = generate_compatible_output
})


--[[ GUI CREATION ]]--

function create_x_frame(player, name, caption)
	
	local wnd = player.gui.center.add({
		type = "frame",
		name = name,
		caption = "",
		direction = "horizontal"
	})
	
	local leftSide = wnd.add({
		type = "flow",
		name = name .. "_left",
		direction = "vertical"
	})
	
	local rightSide = wnd.add({
		type = "flow",
		name = name .. "_right",
		direction = "vertical"
	})
	
	leftSide.add({
		type = "label",
		name = name .. "_titleflow_label",
		caption = caption,
		style = "frame_caption_label_style"
	})
	
	rightSide.add({
		type = "sprite-button",
		name = name .. "_title_close_btn",
		sprite = "close_sprite",
		style = "config_gui_button",
		tooltip = "Close Window"
	})
	
	local content = leftSide.add({
		type = "flow",
		name = name .. "_content",
		direction = "vertical"
	})
	
	return content, wnd
end

function create_gui_button(player)
	if player.gui.top.configEditorBtn ~= nil then
		player.gui.top.configEditorBtn.destroy()
	end
	
	player.gui.top.add({
		type = "sprite-button",
		name = "configEditorBtn",
		sprite = "config_sprite",
		style = "config_gui_button",
		tooltip = "Config Editor"
	})
end

function create_gui_main(player)
	if player.gui.center.configWindow ~= nil then
		player.gui.center.configWindow.destroy()
	end
	
	local wnd = create_x_frame(player, "configWindow", "Config Editor")
	
	wnd.add({
		type = "label",
		caption = "Choose mod to config:",
		style = "caption_label_style"
	})
	
	local mods = game.active_mods
	
	local cMods = math.floor(table.count(mods) / 4)
	
	local buttons = wnd.add({
		type = "table",
		name = "modButtonsTable",
		colspan = 4
	})
	
	for modName, version in pairs(mods) do
		if mod_exists(modName) then
			buttons.add({
				type = "button",
				name = "modConfigBtn_" .. modName,
				caption = modName
			})
		end
	end
end

function _create_gui_table_for(modPath, title, fields, parent)
	
	local tbl = parent.add({
		type = "table",
		name = modPath .. "|:|table",
		colspan = 2,
		style = "table_style"
	})
	
	for field, data in pairs(fields) do
		
		if data["type"] == "table" and type(data["value"]) == "table" then
		
			tbl.add({
				type = "label",
				caption = data["title"] or field,
				tooltip = data["description"] or ""
			})
			
			local flow = tbl.add({
				type = "flow",
				direction = "vertical",
				name = modPath .. "|:|flow",
				style = "flow_style"
			})
			
			_create_gui_table_for(modPath .. "|:|" .. field, data["title"] or field, data["value"], flow)
		
		else
			local label, row = _to_row(modPath, field, data, tbl)
		
			if row ~= nil then
				tbl.add(label)
				tbl.add(row)
			end
		end
	end
	
end

function create_gui_mod_config(player, modName)
	if player.gui.center.configWindow ~= nil then
		player.gui.center.configWindow.destroy()
	end
	
	if player.gui.center.modConfigWindow ~= nil then
		player.gui.center.modConfigWindow.destroy()
	end
	
	local wnd = create_x_frame(player, "modConfigWindow", modName .. " Configs")
	
	
	local fields = get_fields(modName)
	_create_gui_table_for("base", "Main", fields, wnd)
	
	
	local btnFlow = wnd.add({
		type = "flow",
		direction = "horizontal"
	})
	
	btnFlow.add({
		type = "button",
		name = "modConfigWindow_Save_Btn",
		caption = "Save Settings"
	})
end

function _to_row(modPath, field, data)

	if type(data) ~= "table" or data["type"] == nil then
		return nil, nil
	end

	local dataType = data["type"]
	local title = data["title"] or field
	
	local label = {type = "label", caption = title, tooltip = data["description"] or ""}
	
	
	if data["readonly"] == true then
		label["tooltip"] = label["tooltip"] .. " (READ ONLY)"
		return label, {type = "label", caption = data["value"] or "", tooltip = label["tooltip"]}
	end
	
	
	local element = nil
	
	if dataType == "string" then
		
		element = {
			type = "textfield",
			name = modPath .. "|:|" .. field,
			text = data["value"] or "",
			style = "textfield_style"
		}
		
	elseif dataType == "number" then
	
		element = {
			type = "textfield",
			name = modPath .. "|:|" .. field,
			text = data["value"] or "0",
			style = "number_textfield_style"
		}
		
	elseif dataType == "boolean" then
	
		element = {
			type = "checkbox",
			name = modPath .. "|:|" .. field,
			state = data["value"] or false,
			style = "checkbox_style"
		}
		
	else
		element = {
			type = "label",
			caption = "Unable to parse type " .. type(data)
		}
	end
	
	if element ~= nil then
		element["tooltip"] = data["description"] or ""
	end
	
	return label, element
end


--[[ GUI EVENTS ]]--

function on_gui_click(event)
	local player = game.players[event.player_index]
	local element = event.element
	
	if element.name == "configEditorBtn" then
		create_gui_main(player)
	elseif string.starts(element.name, "modConfigBtn_") then
		local modName = string.sub(element.name, 14)
		
		if mod_exists(modName) then
			if global.playerData[player.name .. "_" .. player.index] == nil then
				global.playerData[player.name .. "_" .. player.index] = {}
			end
		
			global.playerData[player.name .. "_" .. player.index]["config_mod_name"] = modName
		
			create_gui_mod_config(player, modName)
		end
	elseif element.name == "modConfigWindow_Save_Btn" then
		
		local modName = global.playerData[player.name .. "_" .. player.index]["config_mod_name"]
		
		local values = {}
		
		local saveMod = traverse_mod_path(player.gui.center.modConfigWindow.modConfigWindow_left.modConfigWindow_content, values, player)
		
		local nValues = {}
		
		for key, value in pairs(values) do
			local nKey = string.gsub(key, "base|:|", "")
			
			local path = string.explode("|:|", nKey)
			
			if #path == 1 then
				nValues[path[1]] = value
			else
				--@TODO: This really needs a rewrite
				local nPath = {}
				for i = 1, #path - 1 do
					table.insert(nPath, {})
				end
				
				table.insert(nPath, value)
			
				local p = nValues
				for i = 1, #nPath do
					if p[path[i]] == nil then
						p[path[i]] = nPath[i]
					end
					p = p[path[i]]				
				end
			end
			
		end
		
		if saveMod then
			save_mod_data(global.modConfigs[modName], nValues)
			
			_Raise_Event(modName)
			player.gui.center.modConfigWindow.destroy()
			player.print(modName .. "'s configuration saved")
		end
		
	elseif string.ends(element.name, "_title_close_btn") then
	
		local wndName = string.sub(element.name, 1, #element.name - 16)
		player.gui.center[wndName].destroy()
		
		if wndName == "modConfigWindow" then
			if global.playerData[player.name .. "_" .. player.index]["config_mod_name"] ~= nil then
				global.playerData[player.name .. "_" .. player.index]["config_mod_name"] = nil
			end
			create_gui_main(player)
		end
	end
end

--[[ MISC GUI FUNCTIONS]]--

function traverse_mod_path(elm, values, player)
	
	values = values or {}
	
	local children_names = elm.children_names
	
	for _, elementName in ipairs(children_names) do
		local element = elm[elementName]
		
		if element ~= nil then
			local path = string.explode("|:|", element.name)
			
			if element.style.name == "textfield_style" then
			
				values[element.name] = element.text
			
			elseif element.style.name == "number_textfield_style" then
				local numValue = tonumber(element.text)
					
				if numValue == nil then
					player.print("Field " .. fieldName .. " is not a number")
					return false
				end
				
				values[element.name] = numValue
				
			elseif element.style.name == "checkbox_style" then
			
				values[element.name] = element.state
			
			elseif element.style.name == "flow_style" then
				local tName = element.children_names[1]
				
				traverse_mod_path(element[tName], values, player)
			elseif element.style.name == "table_style" then
				traverse_mod_path(element, values, player)
			end
			
		end
		
	end
	
	return true
end

function save_mod_data(modGlobal, data)

	for field, value in pairs(data) do
		
		if modGlobal[field] ~= nil then
			if type(value) == "table" then
				save_mod_data(modGlobal[field].value, data[field])
			else
				modGlobal[field].value = value
			end
		end
	end
end

--[[ MISC FUNCTIONS ]]--

function _Raise_Event(modName)
	
	local modData = {}
	
	for field, data in pairs(global.modConfigs[modName]) do
		modData[field] = data.value
	end
	
	game.raise_event(global.config_changed_event, {mod = modName, data = modData})
end


script.on_init(on_init)
script.on_configuration_changed(on_configuration_changed)

script.on_event(defines.events.on_gui_click, on_gui_click)
script.on_event(defines.events.on_player_joined_game, on_player_joined_game)
