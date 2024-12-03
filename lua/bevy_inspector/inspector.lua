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
function Inspector:open()
	local query_result = self.api:get_all_entites()

	if query_result == nil then
		print("no named entities")
		return
	end

	local picker = pickers:new({
		prompt_title = "search entity",
		finder = finders.new_table({
			results = query_result,
			entry_maker = function(entry)
				return {
					value = entry.entity,
					display = tostring(entry.entity),
					ordinal = tostring(entry.entity),
				}
			end,
		}),
		layout_config = {
			horizontal = {
				preview_width = 0.7,
				results_width = 0.3,
			},
		},
		previewer = previewers.new_buffer_previewer({
			title = "entity components",
			define_preview = function(buf, entry)
				local comps = self.api:list_components(entry.value)

				if comps == nil then
					return
				end

				vim.api.nvim_buf_set_lines(buf.state.bufnr, 0, -1, false, comps)
			end,
		}),
		sorter = conf.generic_sorter(),
		attach_mappings = function(prompt_bufnr)
			actions.select_default:replace(function()
				local selection = action_states.get_selected_entry()
				actions.close(prompt_bufnr)
				self:open_comps(selection.value)
			end)
			return true
		end,
	})
	picker:find()
end

--- Opens a picker for all named entities
function Inspector:open_named()
	local query_result = self.api:get_named_entites()

	if query_result == nil then
		print("no entities")
		return
	end

	local picker = pickers:new({
		prompt_title = "search named entity",
		finder = finders.new_table({
			results = query_result,
			entry_maker = function(entry)
				local _, comp = next(entry.components)
				local name = comp.name
				return {
					value = entry.entity,
					display = name .. ":" .. tostring(entry.entity),
					ordinal = name .. ":" .. tostring(entry.entity),
				}
			end,
		}),
		layout_config = {
			horizontal = {
				preview_width = 0.5,
				results_width = 0.5,
			},
		},
		previewer = previewers.new_buffer_previewer({
			title = "entity components",
			define_preview = function(buf, entry)
				local comps = self.api:list_components(entry.value)

				if comps == nil then
					return
				end

				vim.api.nvim_buf_set_lines(buf.state.bufnr, 0, -1, false, comps)
			end,
		}),
		sorter = conf.generic_sorter(),
		attach_mappings = function(prompt_bufnr)
			actions.select_default:replace(function()
				local selection = action_states.get_selected_entry()
				actions.close(prompt_bufnr)
				self:open_comps(selection.value)
			end)
			return true
		end,
	})
	picker:find()
end

--- Opens a picker for all components with live value preview
---@param entity number
function Inspector:open_comps(entity)
	local comps = self.api:list_components(entity)

	local picker = pickers:new({
		prompt_title = "search components of " .. entity,
		finder = finders.new_table({
			results = comps,
		}),
		layout_config = {
			horizontal = {
				preview_width = 0.5,
				results_width = 0.5,
			},
		},
		previewer = previewers.new_buffer_previewer({
			title = "components detail",
			define_preview = function(buf, entry)
				local detail = self.api:get_component_detail(entity, entry.value)

				if detail == nil then
					return
				end

				local formatted = bevy_util.pretty_table_str(detail)
				vim.api.nvim_buf_set_lines(buf.state.bufnr, 0, -1, false, vim.split(formatted, "\n"))
			end,
		}),
		sorter = conf.generic_sorter(),
		attach_mappings = function()
			actions.select_default:replace(function() end)
			return true
		end,
	})

	picker:find()
end

return Inspector
