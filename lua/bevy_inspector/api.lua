local Job = require("plenary.job")
local bevy = require("bevy_inspector")

--- @class BevyApi
--- @field config BevyRemoteConfig
--- @field private running boolean
local BevyApi = {}

--- @class Request
--- @field method string
--- @field id number
--- @field params table

--- @class Response
--- @field jsonrpc string
--- @field id string
--- @field result table

--- @return BevyApi
function BevyApi:new()
	local api = {
		config = bevy.opts,
	}

	setmetatable(api, self)
	self.__index = self

	return api
end

--- @param method string
--- @param params? table
--- @return table | nil
function BevyApi:call(method, params)
	local req = {
		id = 0,
		jsonrpc = "2.0",
		method = method,
	}

	if params then
		req.params = params
	end

	local success, request_string = pcall(function()
		return vim.fn.json_encode(req)
	end)

	if not success then
		print("failed to parse request")
		return nil
	end

	local args = {
		"--silent",
		"--no-buffer",
		"-X",
		"POST",
		"-H",
		"'Content-Type: application/json'",
		"-d",
		request_string,
		self.config.url,
	}

	local job = Job:new({
		command = "curl",
		args = args,
	})

	job:sync(3000)
	local ok, json_res = pcall(function()
		return vim.fn.json_decode(job:result())
	end)

	if not ok or json_res == nil then
		return nil
	end

	if json_res.result == nil then
		vim.print(json_res)
	else
		return json_res.result
	end
end

--- @class QueryItem
--- @field entity number
--- @field components table

--- gets all named entities
--- @return QueryItem[] | nil
function BevyApi:get_named_entites()
	return self:call("bevy/query", {
		data = {
			components = {
				"bevy_core::name::Name",
			},
		},
		filter = {},
	})
end

--- gets a list of all components in the world
--- @param components string[]
--- @param filter table?
--- @return table | nil
function BevyApi:query(components, filter)
	return self:call("bevy/query", {
		data = {
			components = components,
		},
		filter = filter,
	})
end

--- gets all entities
--- @return QueryItem[] | nil
function BevyApi:get_all_entites()
	return self:call("bevy/query", {
		data = {},
		filter = {},
	})
end

--- gets all entities
--- @return QueryItem[] | nil
--- @param component string
function BevyApi:get_entites_with_component(component)
	return self:call("bevy/query", {
		data = {},
		filter = {
			with = {
				component,
			},
		},
	})
end

--- gets a list of owned components
--- @param entity number
--- @return table | nil
function BevyApi:list_components(entity)
	return self:call("bevy/list", {
		entity = entity,
	})
end

--- gets a list of all components in the world
--- @return table | nil
function BevyApi:list_all_components()
	return self:call("bevy/list")
end

--- gets component details from a list of component names
--- @param entity number
--- @return table | nil
function BevyApi:list_components_detailed(entity)
	local components = self:list_components(entity)
	return self:call("bevy/get", {
		entity = entity,
		components = components,
	})
end

--- gets component details from a list of component names
--- @param entity number
--- @param component string
--- @return table | nil
function BevyApi:get_component_detail(entity, component)
	return self:call("bevy/get", {
		entity = entity,
		components = { component },
	})
end

--- gets component details from a list of component names
--- @param entity number
--- @param component string
--- @return table | nil
function BevyApi:watch_component(entity, component)
	return self:call("bevy/get+watch", {
		entity = entity,
		components = { component },
	})
end

return BevyApi
