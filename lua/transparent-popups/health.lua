-- Report for :checkhealth transparent-popups. Found automatically: lua/<plugin>/health.lua with a check()
-- HELP: :help health-dev, :help vim.health

local M = {}

---@param color? integer
---@return string
local function hex(color)
  return color and ("#%06x"):format(color) or "NONE"
end

---@param name string
---@return vim.api.keyset.get_hl_info
local function get(name)
  return vim.api.nvim_get_hl(0, { name = name, link = false })
end

function M.check()
  local options = require("transparent-popups.config").options

  vim.health.start("transparent-popups: setup")
  if vim.fn.has("nvim-0.11") == 1 then
    local v = vim.version()
    vim.health.ok(("Neovim %d.%d.%d"):format(v.major, v.minor, v.patch))
  else
    vim.health.error("Neovim 0.11+ is required ('winborder', vim.validate)")
  end
  local ok, autocmds = pcall(vim.api.nvim_get_autocmds, { group = "TransparentPopups", event = "ColorScheme" })
  if not ok or #autocmds == 0 then
    vim.health.warn("setup() not called", { 'Call require("transparent-popups").setup() after your colorscheme' })
    return
  end
  vim.health.ok("setup() called, highlights re-applied on every colorscheme change")

  vim.health.start("transparent-popups: highlights")
  local transparent = require("transparent-popups.highlights").is_transparent()
  vim.health.info(("Colorscheme %s, %s mode (%s)"):format(
    vim.g.colors_name or "none",
    transparent and "transparent" or "opaque",
    options.transparent == "auto" and "auto-detected" or "forced by the transparent option"
  ))
  local float, border, thumb = get("NormalFloat"), get("FloatBorder"), get("BlinkCmpScrollBarThumb")
  local advice = { "Something changed it after transparent-popups: run :colorscheme again or check other plugins" }
  if transparent and float.bg then
    vim.health.warn("NormalFloat has a background (" .. hex(float.bg) .. ") in transparent mode", advice)
  elseif not transparent and border.bg ~= float.bg then
    vim.health.warn(("FloatBorder bg %s differs from NormalFloat bg %s"):format(hex(border.bg), hex(float.bg)), advice)
  else
    vim.health.ok("Float backgrounds follow the mode")
  end
  if thumb.bg == border.fg then
    vim.health.ok("blink.cmp scrollbar thumb matches the border color (" .. hex(border.fg) .. ")")
  else
    vim.health.warn(
      ("Scrollbar thumb %s differs from the border color %s"):format(hex(thumb.bg), hex(border.fg)),
      advice
    )
  end

  vim.health.start("transparent-popups: border and hover")
  if not options.border then
    vim.health.info("border = false: 'winborder' left as " .. vim.inspect(vim.o.winborder))
  elseif vim.o.winborder == options.border then
    vim.health.ok("'winborder' is " .. vim.inspect(options.border))
  else
    vim.health.warn(
      ("'winborder' is %s, expected %s"):format(vim.inspect(vim.o.winborder), vim.inspect(options.border)),
      { "Something set 'winborder' after setup()" }
    )
  end
  local hover = require("transparent-popups.hover").status()
  if hover == "active" then
    vim.health.ok(("LSP hover padded by %d space(s) on each side"):format(options.hover.padding))
  elseif hover == "replaced" then
    vim.health.info("vim.lsp.util.open_floating_preview was replaced by another plugin after setup()", {
      "The hover is only padded if that plugin still calls the previous function",
    })
  else
    vim.health.warn("LSP hover padding is not installed")
  end

  vim.health.start("transparent-popups: blink.cmp")
  -- blink.cmp's config module holds the options merged by its setup(); read here only, never changed
  local has_blink, blink_config = pcall(require, "blink.cmp.config")
  if not has_blink then
    vim.health.info("blink.cmp not installed, blink_opts() unused")
    return
  end
  -- tbl_get: nil instead of an error if a blink.cmp release moves this option
  local padding = vim.tbl_get(blink_config, "completion", "menu", "draw", "padding")
  if vim.deep_equal(padding, options.blink.padding) then
    vim.health.ok("blink_opts() merged into blink.cmp (menu padding " .. vim.inspect(padding) .. ")")
  else
    vim.health.warn(
      ("blink.cmp menu padding is %s, expected %s"):format(vim.inspect(padding), vim.inspect(options.blink.padding)),
      {
        'Merge require("transparent-popups").blink_opts() into require("blink.cmp").setup()',
        "Ignore this if you set the padding in blink.cmp's setup() on purpose",
      }
    )
  end
end

return M
