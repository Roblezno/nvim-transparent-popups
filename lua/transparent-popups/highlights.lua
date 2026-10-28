-- Theme-aware highlights for floating windows, re-applied on every colorscheme change.
-- A colorscheme resets all groups when it loads, so apply() always starts from the theme's own colors
-- HELP: :help nvim_get_hl(), :help nvim_set_hl(), :help ColorScheme

local config = require("transparent-popups.config")

local M = {}

-- Resolved definition of a group (links followed), in the format nvim_set_hl() accepts
---@param name string
---@return vim.api.keyset.highlight
local function get(name)
  local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
  -- A group defined with `default` would ignore our nvim_set_hl() call
  hl.default = nil
  return hl
end

-- Keep the theme's fg and attributes, only change the given fields
---@param name string
---@param changes table
local function update(name, changes)
  vim.api.nvim_set_hl(0, name, vim.tbl_extend("force", get(name), changes))
end

-- Same as update(), but removes the background (nil can't go through tbl_extend)
---@param name string
local function clear_bg(name)
  local hl = get(name)
  hl.bg, hl.ctermbg = nil, nil
  vim.api.nvim_set_hl(0, name, hl)
end

--- Whether floats should be transparent: forced by the option, or follows the Normal background
---@return boolean
function M.is_transparent()
  local transparent = config.options.transparent
  if transparent == "auto" then
    return get("Normal").bg == nil
  end
  return transparent --[[@as boolean]]
end

--- Apply the float highlights for the active colorscheme
function M.apply()
  local transparent = M.is_transparent()
  local float = get("NormalFloat")
  local border_fg = get("FloatBorder").fg or float.fg or get("Normal").fg
  -- Background shared by every float: none, or the theme's own float background
  local bg = not transparent and float.bg or nil

  -- Core float groups, used by every float (LSP hover, Mason, ...)
  if transparent then
    clear_bg("NormalFloat")
    clear_bg("Pmenu")
  end
  for _, name in ipairs({ "FloatBorder", "FloatTitle", "FloatFooter" }) do
    if bg then
      update(name, { bg = bg })
    else
      clear_bg(name)
    end
  end
  update("FloatBorder", { fg = border_fg })

  -- blink.cmp windows look like any other float
  for _, kind in ipairs({ "Menu", "Doc", "SignatureHelp" }) do
    vim.api.nvim_set_hl(0, "BlinkCmp" .. kind, { link = "NormalFloat" })
    vim.api.nvim_set_hl(0, "BlinkCmp" .. kind .. "Border", { link = "FloatBorder" })
  end
  -- The thumb is drawn on the border column with empty cells, so its bg is the visible color
  vim.api.nvim_set_hl(0, "BlinkCmpScrollBarThumb", { bg = border_fg })
  vim.api.nvim_set_hl(0, "BlinkCmpScrollBarGutter", { bg = bg })
end

--- Apply now and on every later colorscheme change. Safe to call more than once
function M.setup()
  local group = vim.api.nvim_create_augroup("TransparentPopups", { clear = true })
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = group,
    callback = function()
      M.apply()
    end,
    desc = "Re-apply transparent-popups highlights for the new colorscheme",
  })
  M.apply()
end

return M
