local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local previewers = require("telescope.previewers")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_states = require("telescope.actions.state")

local M = {}

--- @param node table
--- @return string
M.pretty_table_str = function(node)
	-- to make output beautiful
	local function tab(amt)
		local str = ""
		for i = 1, amt do
			str = str .. "\t"
		end
		return str
	end

	local cache, stack, output = {}, {}, {}
	local depth = 1
	local output_str = "{\n"

	while true do
		local size = 0
		for k, v in pairs(node) do
			size = size + 1
		end

		local cur_index = 1
		for k, v in pairs(node) do
			if (cache[node] == nil) or (cur_index >= cache[node]) then
				if string.find(output_str, "}", output_str:len()) then
					output_str = output_str .. ",\n"
				elseif not (string.find(output_str, "\n", output_str:len())) then
					output_str = output_str .. "\n"
				end

				-- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
				table.insert(output, output_str)
				output_str = ""

				local key
				if type(k) == "number" or type(k) == "boolean" then
					key = "[" .. tostring(k) .. "]"
				else
					key = "['" .. tostring(k) .. "']"
				end

				if type(v) == "number" or type(v) == "boolean" then
					output_str = output_str .. tab(depth) .. key .. " = " .. tostring(v)
				elseif type(v) == "table" then
					output_str = output_str .. tab(depth) .. key .. " = {\n"
					table.insert(stack, node)
					table.insert(stack, v)
					cache[node] = cur_index + 1
					break
				else
					output_str = output_str .. tab(depth) .. key .. " = '" .. tostring(v) .. "'"
				end

				if cur_index == size then
					output_str = output_str .. "\n" .. tab(depth - 1) .. "}"
				else
					output_str = output_str .. ","
				end
			else
				-- close the table
				if cur_index == size then
					output_str = output_str .. "\n" .. tab(depth - 1) .. "}"
				end
			end

			cur_index = cur_index + 1
		end

		if #stack > 0 then
			node = stack[#stack]
			stack[#stack] = nil
			depth = cache[node] == nil and depth + 1 or depth - 1
		else
			break
		end
	end

	table.insert(output, output_str)
	return table.concat(output)
end

---@class BevyPicker
---@field callback fun(entry: table)?
---@field title string?
---@field picker any?
---@field format fun(entry:any)?

---@param opts BevyPicker
---@param data table
M.spawn_picker = function(data, opts)
	local finder = {}

	if opts.format ~= nil then
		finder = finders.new_table({
			results = data,
			entry_maker = opts.format,
		})
	else
		finder = finders.new_table({
			results = data,
		})
	end

	local picker = pickers:new({
		prompt_title = opts.title,
		layout_config = {
			horizontal = {
				preview_width = 0.6,
				results_width = 0.4,
			},
		},
		finder = finder,
		sorter = conf.generic_sorter(),
		attach_mappings = function(prompt_bufnr)
			actions.select_default:replace(function()
				local selection = action_states.get_selected_entry()
				actions.close(prompt_bufnr)
				opts.callback(selection.value)
			end)
			return true
		end,
	})

	if opts.picker ~= nil then
		picker.previewer = opts.picker
	end

	picker:find()
end

M.entity_previewer = previewers.new_buffer_previewer({
	title = "entity components",
	define_preview = function(buf, entry)
		local api = require("bevy_inspector.api"):new()
		local comps = api:list_components(entry.value)
		if comps == nil then
			return
		end
		vim.api.nvim_buf_set_lines(buf.state.bufnr, 0, -1, false, comps)
	end,
})

M.entity_formatter = function(entry)
	local displayed = "[" .. tostring(entry.entity) .. "]"

	local _, comp = next(entry.components)

	if comp ~= nil and comp.name ~= nil then
		local name = comp.name
		displayed = displayed .. ":" .. name
	else
		displayed = displayed .. ":Entity"
	end

	return {
		value = entry.entity,
		display = displayed,
		ordinal = displayed,
	}
end

M.component_previewer = function(entity)
	return previewers.new_buffer_previewer({
		title = "components detail",
		define_preview = function(buf, entry)
			local api = require("bevy_inspector.api"):new()
			local detail = api:get_component_detail(entity, entry.value)

			if detail == nil then
				return
			end

			local formatted = M.pretty_table_str(detail)
			vim.api.nvim_buf_set_lines(buf.state.bufnr, 0, -1, false, vim.split(formatted, "\n"))
		end,
	})
end

M.component_formatter = function(entry)
	local display = string.match(entry, ".*::(.*)")
	return {
		value = entry,
		display = display,
		ordinal = entry,
	}
end

return M
