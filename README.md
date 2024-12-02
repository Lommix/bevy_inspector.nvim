# bevy_inspector.nvim

A simple remote entity & component inspector inside neovim
using the telescope API.

## Installation

```lua
return {
	"lommix/bevy_inspector.nvim",
	dir = "~/Projects/nvim_plugins/bevy_inspector.nvim",
	dependencies = {
		"MunifTanjim/nui.nvim",
		"nvim-lua/plenary.nvim",
	},
	config = function()
		require("bevy_inspector").setup()
		vim.keymap.set("n", "<leader>zz", ":BevyInspect<Cr>", {silent=true})
		vim.keymap.set("n", "<leader>uu", ":BevyInspectNamed<Cr>", {silent=true})
	end,
}
```
