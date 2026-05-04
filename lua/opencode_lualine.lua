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

local v = vim
local uv = v.uv or v.loop

local DEFAULTS = {
    debug = false,
}

local ICON_BY_MODE = {
    inactive = "󰅛",
    internal = "󰒮",
    external = "󰈀",
}

local COLOR_BY_MODE = {
    inactive = "#7f849c",
    internal = "#89b4fa",
    external = "#a6e3a1",
}

local config = vim.deepcopy(DEFAULTS)
local augroup_id
local is_setup = false

local state = {
    mode = "inactive",
    recompute_count = 0,
    redraw_count = 0,
    last_recompute_at_ms = 0,
    last_mode_change_at_ms = 0,
    last_refresh_at_ms = 0,
    last_urgent_event_at_ms = 0,
    last_error = "",
    refresh_scheduled = false,
}

local function now_ms_or_zero()
    if uv and uv.now then
        return uv.now()
    end
    return 0
end

local function reset_config()
    config = vim.deepcopy(DEFAULTS)
end

local function reset_runtime_state()
    state.mode = "inactive"
    state.recompute_count = 0
    state.redraw_count = 0
    state.last_recompute_at_ms = 0
    state.last_mode_change_at_ms = 0
    state.last_refresh_at_ms = 0
    state.last_urgent_event_at_ms = 0
    state.last_error = ""
    state.refresh_scheduled = false
end

local function get_autocmd_count()
    if not augroup_id then
        return 0
    end

    local ok, autocmds = pcall(v.api.nvim_get_autocmds, { group = augroup_id })
    if not ok then
        return 0
    end

    return #autocmds
end

local function has_opencode_terminal_buf()
    for _, bufnr in ipairs(v.api.nvim_list_bufs()) do
        if v.api.nvim_buf_is_loaded(bufnr) then
            local ok_ft, filetype = pcall(v.api.nvim_get_option_value, "filetype", { buf = bufnr })
            if ok_ft and filetype == "opencode_terminal" then
                return true
            end
        end
    end

    return false
end

local function get_connected_server()
    local ok, events = pcall(require, "opencode.events")
    if not ok or type(events) ~= "table" then
        return nil
    end

    return events.connected_server
end

local function determine_mode()
    if has_opencode_terminal_buf() then
        return "internal"
    end

    if get_connected_server() ~= nil then
        return "external"
    end

    return "inactive"
end

local function recompute_state()
    state.recompute_count = state.recompute_count + 1
    state.last_recompute_at_ms = now_ms_or_zero()

    local ok, mode_or_err = pcall(determine_mode)
    if not ok then
        state.last_error = tostring(mode_or_err)
        return
    end

    state.last_error = ""
    if state.mode ~= mode_or_err then
        state.mode = mode_or_err
        state.last_mode_change_at_ms = now_ms_or_zero()
    end
end

local function schedule_refresh()
    if state.refresh_scheduled then
        return
    end

    state.refresh_scheduled = true
    v.schedule(function()
        state.refresh_scheduled = false
        if not is_setup then
            return
        end

        state.redraw_count = state.redraw_count + 1
        state.last_refresh_at_ms = now_ms_or_zero()

        local ok, lualine = pcall(require, "lualine")
        if ok and type(lualine) == "table" and type(lualine.refresh) == "function" then
            local refreshed = pcall(lualine.refresh, { place = { "statusline" } })
            if not refreshed then
                pcall(v.cmd, "redrawstatus")
            end
            return
        end

        pcall(v.cmd, "redrawstatus")
    end)
end

local function recompute_and_refresh()
    if not is_setup then
        return
    end

    recompute_state()
    schedule_refresh()
end

local function on_opencode_event()
    state.last_urgent_event_at_ms = now_ms_or_zero()
    recompute_and_refresh()
end

local function on_buffer_or_filetype_event()
    recompute_and_refresh()
end

function M.teardown()
    is_setup = false

    if augroup_id then
        pcall(v.api.nvim_del_augroup_by_id, augroup_id)
        augroup_id = nil
    end

    reset_runtime_state()
    reset_config()
end

function M.setup(opts)
    M.teardown()
    config = v.tbl_deep_extend("force", v.deepcopy(DEFAULTS), opts or {})

    is_setup = true
    recompute_state()

    augroup_id = v.api.nvim_create_augroup("opencode_lualine", { clear = true })

    v.api.nvim_create_autocmd("VimLeavePre", {
        group = augroup_id,
        callback = function()
            M.teardown()
        end,
    })

    v.api.nvim_create_autocmd("User", {
        group = augroup_id,
        pattern = "OpencodeEvent:*",
        callback = function()
            v.schedule(on_opencode_event)
        end,
    })

    v.api.nvim_create_autocmd("FileType", {
        group = augroup_id,
        pattern = "opencode_terminal",
        callback = function()
            v.schedule(on_buffer_or_filetype_event)
        end,
    })

    v.api.nvim_create_autocmd({ "BufUnload", "BufWipeout", "BufDelete" }, {
        group = augroup_id,
        callback = function()
            v.schedule(on_buffer_or_filetype_event)
        end,
    })

    return M
end

function M.debug_state()
    return {
        mode = state.mode,
        probe_count = state.recompute_count,
        redraw_count = state.redraw_count,
        last_probe_at_ms = state.last_recompute_at_ms,
        last_probe_duration_ms = 0,
        last_shellout_cmd = "",
        last_urgent_event_at_ms = state.last_urgent_event_at_ms,
        last_mode_change_at_ms = state.last_mode_change_at_ms,
        autocmd_count = get_autocmd_count(),
        timers_open = 0,
        last_error = state.last_error,
        debug = config.debug,
        fallback_poll_enabled = false,
        refresh_scheduled = state.refresh_scheduled,
    }
end

M.component = {
    function()
        local icon = ICON_BY_MODE[state.mode] or ICON_BY_MODE.inactive
        return "oc: " .. icon
    end,
    color = function()
        return { fg = COLOR_BY_MODE[state.mode] or COLOR_BY_MODE.inactive }
    end,
}

return M
