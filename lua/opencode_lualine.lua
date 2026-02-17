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
    min_probe_ms = 1500,
    urgent_event_max_latency_ms = 250,
    fallback_poll_enabled = true,
    fallback_poll_s = 20,
    debug = false,
}

local INITIAL_PROBE_DELAY_MS = 25

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

local function reset_config()
    config = vim.deepcopy(DEFAULTS)
end
local augroup_id
local initial_probe_timer
local fallback_poll_timer

local state = {
    mode = "inactive",
    probe_count = 0,
    redraw_count = 0,
    last_probe_at_ms = 0,
    last_probe_duration_ms = 0,
    last_shellout_cmd = "",
    last_urgent_event_at_ms = 0,
    last_mode_change_at_ms = 0,
    last_error = "",
    inflight = false,
    pending = false,
    last_probe_ended_at_ms = 0,
}

local function now_ms()
    if uv and uv.now then
        return uv.now()
    end
    return nil
end

local function is_headless()
    return #v.api.nvim_list_uis() == 0
end

local function is_windows()
    return v.fn.has("win32") == 1
end

local function reset_runtime_state()
    state.mode = "inactive"
    state.probe_count = 0
    state.redraw_count = 0
    state.last_probe_at_ms = 0
    state.last_probe_duration_ms = 0
    state.last_shellout_cmd = ""
    state.last_urgent_event_at_ms = 0
    state.last_mode_change_at_ms = 0
    state.last_error = ""
    state.inflight = false
    state.pending = false
    state.last_probe_ended_at_ms = 0
end

local function close_timer(timer)
    if not timer then
        return nil
    end

    if not timer:is_closing() then
        timer:stop()
        timer:close()
    end

    return nil
end

local function count_open_timers()
    local open_count = 0
    if initial_probe_timer and not initial_probe_timer:is_closing() then
        open_count = open_count + 1
    end
    if fallback_poll_timer and not fallback_poll_timer:is_closing() then
        open_count = open_count + 1
    end
    return open_count
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

local function refresh_statusline()
    state.redraw_count = state.redraw_count + 1

    local ok, lualine = pcall(require, "lualine")
    if ok and lualine and lualine.refresh then
        v.schedule(function()
            pcall(lualine.refresh, { place = { "statusline" } })
        end)
        return
    end

    v.cmd("redrawstatus")
end

local function set_mode(mode)
    if state.mode == mode then
        return
    end

    state.mode = mode
    state.last_mode_change_at_ms = now_ms() or 0
    refresh_statusline()
end

local function run_probe(reason)
    if state.inflight then
        state.pending = true
        return
    end

    if is_headless() then
        return
    end

    if is_windows() then
        set_mode("inactive")
        return
    end

    state.inflight = true
    local started_at = now_ms()
    state.probe_count = state.probe_count + 1
    state.last_probe_at_ms = started_at or 0
    state.last_shellout_cmd = ""

    -- Placeholder probe for task 2: real opencode discovery comes in a later task.
    set_mode("inactive")

    local ended_at = now_ms()
    state.last_probe_ended_at_ms = ended_at or 0
    if started_at and ended_at then
        state.last_probe_duration_ms = ended_at - started_at
    else
        state.last_probe_duration_ms = 0
    end

    state.inflight = false

    if state.pending then
        state.pending = false
        run_probe(reason or "pending")
    end
end

local function schedule_initial_probe()
    if is_headless() or is_windows() then
        return
    end

    if not uv or not uv.new_timer then
        run_probe("initial")
        return
    end

    initial_probe_timer = initial_probe_timer or uv.new_timer()
    if not initial_probe_timer then
        run_probe("initial")
        return
    end

    initial_probe_timer:stop()
    initial_probe_timer:start(
        INITIAL_PROBE_DELAY_MS,
        0,
        v.schedule_wrap(function()
            run_probe("initial")
        end)
    )
end

function M.teardown()
    initial_probe_timer = close_timer(initial_probe_timer)
    fallback_poll_timer = close_timer(fallback_poll_timer)

    if augroup_id then
        pcall(v.api.nvim_del_augroup_by_id, augroup_id)
        augroup_id = nil
    end

    reset_runtime_state()
    reset_config()
end

function M.setup(opts)
    M.teardown()
    config = vim.tbl_deep_extend("force", vim.deepcopy(config), opts or {})

    augroup_id = v.api.nvim_create_augroup("opencode_lualine", { clear = true })
    v.api.nvim_create_autocmd("VimLeavePre", {
        group = augroup_id,
        callback = function()
            M.teardown()
        end,
    })

    schedule_initial_probe()

    return M
end

function M.debug_state()
    return {
        mode = state.mode,
        probe_count = state.probe_count,
        redraw_count = state.redraw_count,
        last_probe_at_ms = state.last_probe_at_ms,
        last_probe_duration_ms = state.last_probe_duration_ms,
        last_shellout_cmd = state.last_shellout_cmd,
        last_urgent_event_at_ms = state.last_urgent_event_at_ms,
        last_mode_change_at_ms = state.last_mode_change_at_ms,
        autocmd_count = get_autocmd_count(),
        timers_open = count_open_timers(),
        last_error = state.last_error,
        debug = config.debug,
        fallback_poll_enabled = config.fallback_poll_enabled,
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
