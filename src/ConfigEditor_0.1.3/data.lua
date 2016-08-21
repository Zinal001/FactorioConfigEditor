data.raw["gui-style"].default["config_gui_button"] =
{
	type = "button_style",
	parent = "button_style",
	width = 32,
	height = 32
}

data:extend({

	{
		type="sprite",
		name="config_sprite",
		filename = "__ConfigEditor__/graphics/icons/Gears_64_64.png",
		priority = "extra-high",
		width = 32,
		height = 32
	},
	
	{
		type = "sprite",
		name = "close_sprite",
		filename = "__ConfigEditor__/graphics/icons/Close_64_64.png",
		priority = "extra-high",
		width = 32,
		height = 32
	}

})
