-- Default options, merged with the user's and validated
-- HELP: :help vim.tbl_deep_extend(), :help vim.validate()

local M = {}

---@class transparent-popups.Config
---@field transparent "auto"|boolean Transparent floats; "auto" follows the Normal background
---@field border string|false Border for every float (sets 'winborder'); false leaves it untouched
---@field hover { padding: integer } Spaces added left and right of the LSP hover text
---@field blink { padding: integer|integer[] } blink.cmp menu padding, or { left, right }

-- Same fields, all optional: what the user passes to setup()
---@class transparent-popups.Opts
---@field transparent? "auto"|boolean
---@field border? string|false
---@field hover? { padding?: integer }
---@field blink? { padding?: integer|integer[] }

---@type transparent-popups.Config
M.defaults = {
  transparent = "auto",
  border = "single",
  hover = { padding = 1 },
  -- Right side wider so the text keeps clear of the scrollbar drawn on the border
  blink = { padding = { 1, 2 } },
}

-- Current options, read by the other modules. Defaults until setup() is called
---@type transparent-popups.Config
M.options = vim.deepcopy(M.defaults)

---@param n any
---@return boolean
local function is_padding(n)
  return type(n) == "number" and n >= 0 and n % 1 == 0
end

---@param cfg transparent-popups.Config
local function validate(cfg)
  vim.validate("transparent", cfg.transparent, function(v)
    return v == "auto" or type(v) == "boolean"
  end, '"auto", true or false')
  vim.validate("border", cfg.border, function(v)
    return type(v) == "string" or v == false
  end, "a 'winborder' value or false")
  vim.validate("hover", cfg.hover, "table")
  vim.validate("hover.padding", cfg.hover.padding, is_padding, "integer >= 0")
  vim.validate("blink", cfg.blink, "table")
  vim.validate("blink.padding", cfg.blink.padding, function(v)
    return is_padding(v) or (type(v) == "table" and #v == 2 and is_padding(v[1]) and is_padding(v[2]))
  end, "integer >= 0 or { left, right }")
end

--- Merge user options over the defaults, validate them and store them in M.options
---@param opts? transparent-popups.Opts
---@return transparent-popups.Config
function M.setup(opts)
  vim.validate("opts", opts, "table", true)
  -- deepcopy so the merge never shares (and later mutates) the defaults' nested tables
  local cfg = vim.tbl_deep_extend("force", vim.deepcopy(M.defaults), opts or {})
  validate(cfg)
  M.options = cfg
  return cfg
end

return M
