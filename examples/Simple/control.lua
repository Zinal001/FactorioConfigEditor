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
	
	--If we already have a reference to the event handler, just assign a handler to it (since we cannot change the global table in the on_load method)
	if global.CE_config_changed_event ~= nil then
		script.on_event(global.CE_config_changed_event, On_CE_Config_Changed)
	end
	
end
script.on_load(on_load)

--Whenever a config has changed...
function On_CE_Config_Changed(event)

	--And the mod is equal to this mod's name...
	if event.mod == "SimpleMod" then
		
		--Update the local config variable with the data provided
		global.config.ticksUntilAttack = event.data.ticksUntilAttack
		global.config.ticksBetweenAttacks = event.data.ticksBetweenAttacks
		
	end

end

--Setup the local config variable
function Setup_Default_Config()

	-- If the local config variable doesn't exist...
	if global.config == nil then
	
		-- Create it.
		global.config = {
			ticksUntilAttack = 60 * 60 * 30 -- 30 Minutes,
			ticksBetweenAttacks = 60 * 60 * 5 -- 10 Minutes
		}
	
	end

end

--Setup the config editor
function Setup_Config_Editor()

	-- If the Config Editor mod is active...
	if game.active_mods["ConfigEditor"] ~= nil then
	
		-- Check if a configuration for this mod exists.
		local modConfigExists = remote.call("Config Editor", "mod_exists", "SimpleMod")
		
		-- If it doesn't exist...
		if not modConfigExists then
			
			-- Add the configuration.
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
			
		-- Or if the configuration did exist...
		else
			-- Get the last values stored.
			global.config.ticksUntilAttack = remote.call("Config Editor", "get_value", "SimpleMod", "ticksUntilAttack")
			global.config.ticksBetweenAttacks = remote.call("Config Editor", "get_value", "SimpleMod", "ticksBetweenAttacks")
		end
		
		-- Get the ID of the config_changed event.
		global.CE_config_changed_event = remote.call("Config Editor", "get_config_changed_event")
	
		-- Attach an event handler to the config_changed event
		script.on_event(global.CE_config_changed_event, On_CE_Config_Changed)
	end

end