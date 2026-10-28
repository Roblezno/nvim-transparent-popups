-- Options fragment for blink.cmp: menu padding, and borders that match every other float.
-- The user merges it into blink.cmp's own setup(), so this plugin never depends on blink's internals.
-- Colors are not set here: blink.cmp's highlight groups are handled in highlights.lua
-- HELP: :help blink-cmp-config

local config = require("transparent-popups.config")

local M = {}

--- blink.cmp options built from the current config
---@return table
function M.opts()
  local options = config.options
  -- Without a border option blink.cmp falls back to 'winborder' by itself
  local border = options.border or nil
  return {
    completion = {
      menu = {
        border = border,
        draw = { padding = options.blink.padding },
      },
      documentation = { window = { border = border } },
    },
    signature = { window = { border = border } },
  }
end

return M
