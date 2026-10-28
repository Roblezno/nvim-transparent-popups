-- nvim-transparent-popups: theme-aware borders and transparency for floating windows,
-- plus padding for the LSP hover and the blink.cmp menu.
-- HELP: :help lua-plugin

local M = {}

--- Configure the plugin and apply it. Safe to call more than once.
---@param opts? transparent-popups.Opts
function M.setup(opts)
  local options = require("transparent-popups.config").setup(opts)
  -- Border for every float that follows 'winborder' (LSP hover, blink.cmp, Mason, ...)
  if options.border then
    vim.o.winborder = options.border
  end
  require("transparent-popups.highlights").setup()
  require("transparent-popups.hover").setup()
end

return M
