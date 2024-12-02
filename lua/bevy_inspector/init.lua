---@class BevyRemoteConfig
---@field url string
local defaults = {
	url = "http://127.0.0.1:15702",
}

--- @class BevyRemote
--- @field opts BevyRemoteConfig
local M = {
	opts = vim.deepcopy(defaults),
}

--- @param opts ?BevyRemoteConfig
M.setup = function(opts)
	M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})
end

vim.api.nvim_create_user_command("BevyInspect", function()
	require("bevy_inspector.inspector"):new():open()
end, {})

vim.api.nvim_create_user_command("BevyInspectNamed", function()
	require("bevy_inspector.inspector"):new():open_named()
end, {})

return M
