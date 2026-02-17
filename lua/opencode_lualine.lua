-- opencode_lualine indicator contract (exact UX parity with current lualine setup)
--
-- Prefix (all modes): "oc: "
--
-- Exact output per mode:
-- - inactive: text "oc: 󰅛", color { fg = "#7f849c" }
-- - internal: text "oc: 󰒮", color { fg = "#89b4fa" }
-- - external: text "oc: 󰈀", color { fg = "#a6e3a1" }
--
-- This module is intentionally not wired into lualine yet.
-- Keep it safe to require accidentally.
local M = {}

return M
