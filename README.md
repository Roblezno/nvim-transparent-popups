# nvim-transparent-popups

Theme-aware floating windows for Neovim 0.12+.

- Borders and transparency follow the active colorscheme, for every float (LSP hover, blink.cmp, Mason, ...)
- Works with transparent and opaque backgrounds
- Left/right padding for the LSP hover and the blink.cmp menu
- blink.cmp scrollbar in the same color as the borders

> Work in progress.

## Install (local development)

```lua
vim.opt.runtimepath:prepend(vim.fn.expand("~/Documents/proyectos/nvim-plugins/nvim-transparent-popups"))
require("transparent-popups").setup()
```
