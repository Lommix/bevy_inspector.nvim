# bevy_inspector.nvim

A simple remote entity & component inspector inside Neovim
using the telescope API with the new BRP-API introduced in bevy 0.15

https://github.com/user-attachments/assets/0d48ded3-31da-49bf-ae5b-4ba5aa6fd6e1

## Installation

```lua
return {
	"lommix/bevy_inspector.nvim",
	dependencies = {
		"nvim-telescope/telescope.nvim",
	},
	config = function()

        -- only required when using custom URL
		-- require("bevy_inspector").setup({
	        -- url = "http://127.0.0.1:15702",
        -- })

        -- lists all entities
		vim.keymap.set("n", "<leader>z", ":BevyInspect<Cr>", { silent = true })

        -- lists all named entities
		vim.keymap.set("n", "<leader>u", ":BevyInspectNamed<Cr>", { silent = true })

        -- query a single component, continues to list all matching entities
		vim.keymap.set("n", "<leader>i", ":BevyInspectQuery<Cr>", { silent = true })
	end,
}
```

## In Bevy

Make sure you have `bevy_remote` feature enabled and added the necessary remote plugins.

```rust
app.add_plugins((
    RemotePlugin::default(),
    RemoteHttpPlugin::default(),
));
```
