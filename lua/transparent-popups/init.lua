-- nvim-transparent-popups: theme-aware borders and transparency for floating windows,
-- plus padding for the LSP hover and the blink.cmp menu.
-- HELP: :help lua-plugin

local M = {}

--- Configure the plugin and apply it. Safe to call more than once.
---@param opts? transparent-popups.Opts
function M.setup(opts)
  require("transparent-popups.config").setup(opts)
  -- Next: highlights (Step 3), hover (Step 4)
end

return M
