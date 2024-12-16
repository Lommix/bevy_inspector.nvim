# bevy_inspector.nvim

A simple remote entity & component inspector inside Neovim
using the telescope API with the new BRP-API introduced in bevy 0.15

https://github.com/user-attachments/assets/266c6cee-c9fc-4a38-aeeb-75e46b41a3b2

## Installation with [`lazy.nvim`](https://github.com/folke/lazy.nvim)

```lua
return {
	"lommix/bevy_inspector.nvim",
	dependencies = {
		"nvim-telescope/telescope.nvim",
		"nvim-lua/plenary.nvim",
	},
	config = function()
		require("bevy_inspector").setup({
            -- optional custom url
	        -- url = "http://127.0.0.1:15702",
        })
	end,
	cmd = { "BevyInspect", "BevyInspectNamed", "BevyInspectQuery" },
	keys = {
		{  "<leader>bia", ":BevyInspect<Cr>", desc = "Lists all entities" },
		{  "<leader>bin", ":BevyInspectNamed<Cr>", desc = "List all named entities" },
		{  "<leader>biq", ":BevyInspectQuery<Cr>", desc = "Query a single component, continues to list all matching entities", },
	},
}

```

## Control flow

Mostly boils down to this:

`entitie list` -> `show entity components` -> `live preview component`

## In Bevy

Make sure you have `bevy_remote` feature enabled and added the necessary remote plugins.

```rust
app.add_plugins((
    RemotePlugin::default(),
    RemoteHttpPlugin::default(),
));
```
