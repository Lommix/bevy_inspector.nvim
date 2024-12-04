local bevy_api = require("bevy_inspector.api")
local bevy_util = require("bevy_inspector.util")

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
		mappings = bevy_util.enter_action(function(entry)
			self:show_entity_comps(entry)
		end),
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
		mappings = bevy_util.enter_action(function(entry)
			self:show_entity_comps(entry)
		end),
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
		title = "[Entity:" .. tostring(entity) .. "]",
		format = bevy_util.component_formatter,
		picker = bevy_util.component_previewer(entity),
		mappings = bevy_util.do_nothing(),
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
		mappings = bevy_util.enter_action(function(entry)
			local entities = self.api:get_entites_with_component(entry)

			if entities == nil then
				return
			end

			bevy_util.spawn_picker(entities, {
				title = "select named entity",
				format = bevy_util.entity_formatter,
				picker = bevy_util.entity_previewer,
				mappings = bevy_util.enter_action(function(entry)
					self:show_entity_comps(entry)
				end),
			})
		end),
	})
end

return Inspector
