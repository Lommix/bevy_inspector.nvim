local bevy_api = require("bevy_inspector.api")
local bevy_util = require("bevy_inspector.util")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local previewers = require("telescope.previewers")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_states = require("telescope.actions.state")

--- @class BevyInspector
--- @field api BevyApi
local Inspector = {}

---@return BevyInspector
function Inspector:new()
	local inspector = {
		api = bevy_api:new(),
	}

	setmetatable(inspector, self)
	self.__index = self
	return inspector
end

--- Opens a picker for all entities
function Inspector:show_all_entities()
	local query_result = self.api:get_all_entites()

	if query_result == nil then
		return
	end

	bevy_util.spawn_picker(query_result, {
		title = "select entity",
		format = bevy_util.entity_formatter,
		picker = bevy_util.entity_previewer,
		callback = function(entry)
			self:show_entity_comps(entry)
		end,
	})
end

--- Opens a picker for all named entities
function Inspector:show_named_entities()
	local query_result = self.api:get_named_entites()

	if query_result == nil then
		return
	end

	bevy_util.spawn_picker(query_result, {
		title = "select named entity",
		format = bevy_util.entity_formatter,
		picker = bevy_util.entity_previewer,
		callback = function(entry)
			self:show_entity_comps(entry)
		end,
	})
end

--- Opens a picker for all components with live value preview
---@param entity number
function Inspector:show_entity_comps(entity)
	local comps = self.api:list_components(entity)

	if comps == nil then
		return
	end

	bevy_util.spawn_picker(comps, {
		title = "[Entity:" .. tostring(entity) .. "] select component to watch",
		format = bevy_util.component_formatter,
		picker = bevy_util.component_previewer(entity),
		callback = function(entry)
			self:watch_component(entity, entry)
		end,
	})
end

--- List all components
function Inspector:query_component()
	local comps = self.api:list_all_components()

	if comps == nil then
		return
	end

	bevy_util.spawn_picker(comps, {
		title = "select component to query",
		format = bevy_util.component_formatter,
		callback = function(entry)
			local entities = self.api:get_entites_with_component(entry)

			if entities == nil then
				return
			end

			bevy_util.spawn_picker(entities, {
				title = "select named entity",
				format = bevy_util.entity_formatter,
				picker = bevy_util.entity_previewer,
				callback = function(entry)
					self:show_entity_comps(entry)
				end,
			})
		end,
	})
end

---@param entity number
---@param component string
function Inspector:watch_component(entity, component)
	local Popup = require("nui.popup")
	local event = require("nui.utils.autocmd").event
	-- Create NUI popup
	local popup = Popup({
		enter = true,
		focusable = true,
		border = {
			style = "single",
			text = {
				top = "[ Component Watcher ]",
				top_align = "center",
			},
		},
		position = "50%",
		size = {
			width = 60,
			height = 20,
		},
	})

	popup:mount()
	local function update_popup_content()
		local res = self.api:get_component_detail(entity, component)
		local formatted = bevy_util.pretty_table_str(res)
		vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, vim.split(formatted, "\n"))
	end

	local interval = 50
	local timer = vim.loop.new_timer()
	timer:start(0, interval, vim.schedule_wrap(update_popup_content))

	popup:on(event.BufLeave, function()
		timer:stop()
		timer:close()
		popup:unmount()
	end)
end

return Inspector
