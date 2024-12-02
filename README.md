# bevy_inspector.nvim

A simple remote entity & component inspector inside Neovim
using the telescope API with the new BRP-API introduced in bevy 0.15

## Installation

```lua
return {
	"lommix/bevy_inspector.nvim",
	dependencies = {
		"nvim-telescope/telescope.nvim",
	},
	config = function()
		require("bevy_inspector").setup()
		vim.keymap.set("n", "<leader>zz", ":BevyInspect<Cr>", {silent=true})
		vim.keymap.set("n", "<leader>uu", ":BevyInspectNamed<Cr>", {silent=true})
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
