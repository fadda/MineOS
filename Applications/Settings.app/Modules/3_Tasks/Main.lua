
local GUI = require("GUI")
local paths = require("Paths")
local system = require("System")

local module = {}

local workspace, window, localization = table.unpack({...})

--------------------------------------------------------------------------------

module.name = localization.tasks
module.margin = 0
module.onTouch = function()
	local filesystemChooser = window.contentLayout:addChild(GUI.filesystemChooser(1, 1, 36, 3, 0xE1E1E1, 0x696969, 0xD2D2D2, 0xA5A5A5, nil, localization.open, localization.cancel, localization.tasksPath, "/"))
	filesystemChooser:setMode(GUI.IO_MODE_OPEN, GUI.IO_MODE_FILE)

	local container = window.contentLayout:addChild(GUI.container(1, 1, 36, 3))
	local tasksComboBox = container:addChild(GUI.comboBox(1, 1, 30, 3, 0xE1E1E1, 0x696969, 0xD2D2D2, 0xA5A5A5))
	local removeButton = container:addChild(GUI.button(container.width - 4, 1, 5, 3, 0xE1E1E1, 0x696969, 0x696969, 0xE1E1E1, "-"))

	local modeComboBox = window.contentLayout:addChild(GUI.comboBox(1, 1, 36, 3, 0xE1E1E1, 0x696969, 0xD2D2D2, 0xA5A5A5))
	modeComboBox:addItem(localization.tasksAfter)
	modeComboBox:addItem(localization.tasksBefore)

	local switchAndLabel = window.contentLayout:addChild(GUI.switchAndLabel(1, 1, 36, 8, 0x66DB80, 0xE1E1E1, 0xFFFFFF, 0xA5A5A5, localization.tasksEnabled .. ":", true))
	
	local function update()
		switchAndLabel.hidden = #system.properties.tasks == 0
		modeComboBox.hidden = switchAndLabel.hidden
		container.hidden = switchAndLabel.hidden

		if not switchAndLabel.hidden then
			modeComboBox.selectedItem = system.properties.tasks[tasksComboBox.selectedItem].mode
			switchAndLabel.switch:setState(system.properties.tasks[tasksComboBox.selectedItem].enabled)
		end
	end

	local function fill()
		tasksComboBox:clear()

		for i = 1, #system.properties.tasks do
			tasksComboBox:addItem(system.properties.tasks[i].path)
		end
		tasksComboBox.selectedItem = tasksComboBox:count()

		update()
	end

	tasksComboBox.onItemSelected = update

	filesystemChooser.onSubmit = function(path)
		table.insert(system.properties.tasks, {
			path = filesystemChooser.path,
			enabled = switchAndLabel.switch.state,
			mode = modeComboBox.selectedItem,
		})

		filesystemChooser.path = nil
		fill()

		system.saveProperties()
	end

	removeButton.onTouch = function()
		table.remove(system.properties.tasks, tasksComboBox.selectedItem)
		fill()

		system.saveProperties()
	end

	modeComboBox.onItemSelected = function()
		if #system.properties.tasks > 0 then
			system.properties.tasks[tasksComboBox.selectedItem].mode = modeComboBox.selectedItem
			system.saveProperties()
		end
	end

	switchAndLabel.switch.onStateChanged = function()
		if #system.properties.tasks > 0 then
			system.properties.tasks[tasksComboBox.selectedItem].enabled = switchAndLabel.switch.state
			system.saveProperties()
		end
	end

	window.contentLayout:addChild(GUI.textBox(1, 1, 36, 1, nil, 0xA5A5A5, {localization.tasksInfo}, 1, 0, 0, true, true))

	fill()
end

--------------------------------------------------------------------------------

return module

