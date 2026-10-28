-- Left/right padding for the LSP hover float.
-- Neovim has no padding option for LSP floats, so the function that opens them is wrapped to add spaces
-- around the hover text only. Signature help and diagnostic floats are left untouched: they highlight
-- text by column, and padding would shift it
-- HELP: :help vim.lsp.util.open_floating_preview(), :help vim.lsp.buf.hover()

local config = require("transparent-popups.config")

local M = {}

-- The function being wrapped, saved on the first setup(). Also the guard against wrapping twice
local original
-- Our replacement, kept to tell whether another plugin replaced it later (used by :checkhealth)
local wrapper

--- Wrap vim.lsp.util.open_floating_preview once. Safe to call more than once
function M.setup()
  if original then
    return
  end
  original = vim.lsp.util.open_floating_preview

  ---@param contents string[]
  ---@param syntax string
  ---@param opts? vim.lsp.util.open_floating_preview.Opts
  wrapper = function(contents, syntax, opts)
    -- Read on every call, so a later setup() changes the padding without wrapping again
    local padding = config.options.hover.padding
    if padding > 0 and opts and opts.focus_id == "textDocument/hover" then
      local pad = string.rep(" ", padding)
      contents = vim.tbl_map(function(line)
        -- Blank lines stay blank, so Neovim can still trim the empty ones at the end of the hover
        return line == "" and line or pad .. line .. pad
      end, contents)
    end
    return original(contents, syntax, opts)
  end
  vim.lsp.util.open_floating_preview = wrapper
end

--- State of the hover wrapper (used by :checkhealth)
---@return "missing"|"active"|"replaced"
function M.status()
  if not original then
    return "missing"
  end
  return vim.lsp.util.open_floating_preview == wrapper and "active" or "replaced"
end

return M
