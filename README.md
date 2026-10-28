# nvim-transparent-popups

A custom nvim plugin for my oak-nvim config. It stylizes popup windows to match theme colors, have a border and some padding (for LSP hover and blink cmp menus). Basically a visual upgrade to my liking

Theme-aware floating windows for Neovim.

## Features

- Borders and transparency for every float (LSP hover, blink.cmp, Mason, ...) that follow the active colorscheme,
  transparent or opaque, re-applied on every `:colorscheme`
- Left/right padding for the LSP hover (`K`) and the blink.cmp menu
- blink.cmp scrollbar in the same color as the borders

## Requirements

- Neovim 0.11+ (uses `'winborder'`)
- Optional: [blink.cmp](https://github.com/saghen/blink.cmp) 1.x

## Installation

With `vim.pack` (built into Neovim 0.12+):

```lua
vim.pack.add({ "https://github.com/Roblezno/nvim-transparent-popups" })

vim.cmd("colorscheme kanagawa") -- any colorscheme, loaded before setup()
require("transparent-popups").setup()
```

With any other plugin manager, use the same repository URL and call `setup()` after your colorscheme.

## Configuration

`setup()` accepts these options, shown with their defaults:

```lua
require("transparent-popups").setup({
  transparent = "auto",           -- "auto" (Normal has no background) | true | false
  border = "single",              -- sets 'winborder' for every float; false leaves it untouched
  hover = { padding = 1 },        -- spaces left and right of the LSP hover text (0 to 3)
  blink = { padding = { 1, 2 } }, -- blink.cmp menu padding: number or { left, right }
})
```

The right blink padding is wider so the text keeps clear of the scrollbar, which is drawn on the border.

### blink.cmp

Merge the plugin's options into blink.cmp's own setup. Options you set yourself are on the right and win:

```lua
require("blink.cmp").setup(vim.tbl_deep_extend("force", require("transparent-popups").blink_opts(), {
  -- your blink.cmp options
}))
```

## What it changes

| Target | Change |
|--------|--------|
| `'winborder'` | Set to `border` |
| `NormalFloat`, `Pmenu` | Transparent mode: background removed. Opaque: theme colors kept |
| `FloatBorder`, `FloatTitle`, `FloatFooter` | Background removed (transparent) or set to the `NormalFloat` background (opaque) |
| `BlinkCmpMenu`, `BlinkCmpDoc`, `BlinkCmpSignatureHelp` (+ `Border`) | Linked to `NormalFloat` / `FloatBorder`, so blink.cmp looks like any other float |
| `BlinkCmpKind`, `BlinkCmpLabelDetail`, `BlinkCmpLabelDescription`, `BlinkCmpLabelDeprecated`, `BlinkCmpSource` | Text colors kept, background set to the float background, so the menu is a single color |
| `BlinkCmpScrollBarThumb` | Background set to the border color |
| `BlinkCmpScrollBarGutter` | Background set to the float background (only shown when there is no border) |
| `vim.lsp.util.open_floating_preview` | Wrapped to pad the hover float only. Signature help and diagnostic floats are untouched |

The blink.cmp selection highlight is left to the colorscheme and blink.cmp.

## Health

```vim
:checkhealth transparent-popups
```

## Known limitations

- Changing `transparent` at runtime with a second `setup()` call can't bring back backgrounds that were already
  removed: run `:colorscheme <name>` afterwards
