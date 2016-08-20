function on_init(event)

	Setup_Default_Config()
	Setup_Config_Editor()

end

script.on_init(on_init)

function on_configuration_changed(event)
	
	Setup_Default_Config()
	Setup_Config_Editor()
	
end

script.on_configuration_changed(on_configuration_changed)

function on_load(event)
	
	--If we already have a reference to the event handler, just assign it (since we cannot change the global table in the on_load method)
	if global.CE_config_changed_event ~= nil then
		script.on_event(global.CE_config_changed_event, On_CE_Config_Changed)
	end
	
end
script.on_load(on_load)

--Whenever a config has changed...
function On_CE_Config_Changed(event)

	--And the mod is equal to this mod name
	if event.mod == "SimpleMod" then
		
		--Update the local config variable with the data provided
		global.config.ticksUntilAttack = event.data.ticksUntilAttack
		global.config.ticksBetweenAttacks = event.data.ticksBetweenAttacks
		
	end

end

--Setup the local config variable
function Setup_Default_Config()

	if global.config == nil then
	
		global.config = {
			ticksUntilAttack = 60 * 60 * 30 -- 30 Minutes,
			ticksBetweenAttacks = 60 * 60 * 5 -- 10 Minutes
		}
	
	end

end

--Setup the config editor
function Setup_Config_Editor()

	if game.active_mods["ConfigEditor"] ~= nil then
	
		local modConfigExists = remote.call("Config Editor", "mod_exists", "SimpleMod")
		
		if not modConfigExists then
			
			remote.call("Config Editor", "set_fields", "SimpleMod", {
				ticksUntilAttack = {
					type = "number",
					title = "Ticks Until Attack",
					description = "Number of ticks before first attack",
					value = global.config.ticksUntilAttack
				},
				ticksBetweenAttacks = {
					type = "number",
					title = "Ticks Between Attacks",
					description = "Number of ticks between each attack wave",
					value = global.config.ticksBetweenAttacks
				}
			})
			
		else
			global.config.ticksUntilAttack = remote.call("Config Editor", "get_value", "SimpleMod", "ticksUntilAttack")
			global.config.ticksBetweenAttacks = remote.call("Config Editor", "get_value", "SimpleMod", "ticksBetweenAttacks")
		end
		
		global.CE_config_changed_event = remote.call("Config Editor", "get_config_changed_event")
	
		script.on_event(global.CE_config_changed_event, On_CE_Config_Changed)
	end

end