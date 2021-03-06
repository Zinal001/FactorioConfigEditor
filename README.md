# ConfigEditor
An In-Game Configuration Editor for mods

Config Editor is a Remote Interface mod for Factorio which creates an in-game configuration editor for other mods.

Making a config.lua file to store a mods configuration options is not ideal for your clients, since they have to have the exact same config.lua file in their mod (Any changes to that config.lua file will have to be uploaded to your clients).

Instead, use this mod to store and sync your mod's configuration options between clients!


The mod/interface can be found in the [src folder](src/).

---
## Interface

#####Interface name:
Config Editor

### Methods
These methods are called from anywhere within a mod by using the _remote.call()_ method.
See [examples/simple](examples/Simple/control.lua#L66) for an example.

#### get_config_changed_event()
###### Get the generated ID for the config_changed event. This event is triggered whenever a mod makes changes to an option.

#### set_field(modName,  field, value, dataType, description, readonly)
###### Set a field on a mod's configuration
* modName     {string}      - The name of the mod which you want to add this field to.
* field       {string}      - The name of the field.
* value       {*}           - The default value of the field. (Optional)
* dataType    {string|nil}  - The type of the field. If nil, will be determined by the type of the value. (Optional)
* description {string|nil}  - The description of this field. Will be added to the tooltip on the configuration screen. (Optional)
* readonly    {boolean|nil} - Is this field read-only? Defaults to false. (Optional)

#### set_fields(modName, data, overwrite)
###### Set all fields of a mod configuration
* modName     {string}      - The name of the mod which you want to add/replace these fields to.
* data        {table}       - The new configuration options for this mod, see below for format.
* overwrite   {boolean}     - True to overwrite the mod configuration. This will delete any field that is not present in the data parameter. Default to false.

*Returns true if the mod was changed. false and a string will be returned if an error occurred.*
 
Data parameter format:
```lua
data = {
  Field1 = { -- The name of the field.
    type = "dataType", -- The type of the value (string, number & boolean is currently supported).
    title = "", -- The human-readable name of this field. (OPTIONAL).
    description = "", -- The description of this field. (OPTIONAL).
    value = "", -- The default value of this field. (OPTIONAL).
    readonly = false -- Is this field readonly? Defaults to false (OPTIONAL).
  }
}
```

#### get_field(modName, field)
###### Return the whole field of a mod's configurations option
* modName   {string} - The name of the mod.
* field     {string} - The name of the field.

*Returns nil if the mod/field doesn't exist or a table. See the data parameter format on set_fields for the table format*

#### get_fields(modName)
###### Return a table of all fields in a mod's configuration
* modName   {string} - The name of the mod.

*Returns nil if the mod doesn't exist or a table. See the data parameter format on set_fields for the table format*

#### get_value(modName, field)
###### Returns the value of a mod configurations option
* modName   {string} - The name of the mod.
* field     {string} - The name of the field.

*Returns nil if the field or mod doesn't exist. Otherwise the value of the field.*

#### mod_exists(modName)
###### Check to see if a mod has added any configuration options
* modName   {string} - The name of the mod.

*Returns true if a mod has added any configuration options, false if not*

#### generate_compatible_output(data, writeFile)
##### Convert a table to a compatible config table
* data			{table}		- The table to convert.
* writeFile		{boolean}	- True if you want the table to be printed to a lua file (compatible_output.lua) in the 'script-output' folder. (Defaults to false)

*Returns the newly formatted table*
*Not that fields such as title and description is the same as is filled-in with the fields name*

### Events
#### config_changed
###### This event is triggered whenever a mod makes changes to an option.
###### *The id of this event can only be obtained by calling the get_config_changed_event*
* mod  {string} - The name of the mod that has been changed.
* data {table}  - A table of all the configuration options in the mod.

------
## Screenshots

**Config Editor adds a small button to the gui**
![](media/GUIButton.jpg "Config Editor adds a small button to the gui")

**The main menu - Lists all mods that currently have configuration options**
![](media/EditorMenu.jpg "The main menu - Lists all mods that currently have configuration options")

**The mod configuration menu - Lists all options that you can change on a mod**
![](media/ConfigMenu.jpg "The mod configuration menu - Lists all options that you can change")
