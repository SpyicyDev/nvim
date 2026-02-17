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
local probe_timer
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
    pending_reason = "",
    pending_urgent = false,
    scheduled_reason = "",
    scheduled_due_at_ms = 0,
    last_probe_ended_at_ms = 0,
    probe_id = 0,
    active_probe_id = 0,
    last_completed_probe_id = 0,
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

local function now_ms_or_zero()
    return now_ms() or 0
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
    state.pending_reason = ""
    state.pending_urgent = false
    state.scheduled_reason = ""
    state.scheduled_due_at_ms = 0
    state.last_probe_ended_at_ms = 0
    state.probe_id = 0
    state.active_probe_id = 0
    state.last_completed_probe_id = 0
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

local function clear_scheduled_probe()
    state.scheduled_reason = ""
    state.scheduled_due_at_ms = 0

    if probe_timer and not probe_timer:is_closing() then
        probe_timer:stop()
    end
end

local function count_open_timers()
    local open_count = 0
    if probe_timer and not probe_timer:is_closing() then
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
    state.last_mode_change_at_ms = now_ms_or_zero()
    refresh_statusline()
end

local function is_current_probe(probe_id)
    return probe_id == state.active_probe_id
end

local function apply_probe_result(probe_id, mode)
    if not is_current_probe(probe_id) then
        return false
    end

    set_mode(mode)
    return true
end

local schedule_probe

local function run_probe(reason, opts)
    opts = opts or {}

    if state.inflight then
        state.pending = true
        state.pending_reason = reason or state.pending_reason
        if opts.urgent then
            state.pending_urgent = true
        end
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
    clear_scheduled_probe()

    local started_at = now_ms_or_zero()
    state.probe_count = state.probe_count + 1
    state.last_probe_at_ms = started_at
    state.last_shellout_cmd = ""

    state.probe_id = state.probe_id + 1
    local probe_id = state.probe_id
    state.active_probe_id = probe_id

    -- Placeholder probe for task 2: real opencode discovery comes in a later task.
    apply_probe_result(probe_id, "inactive")

    local ended_at = now_ms_or_zero()
    state.last_probe_ended_at_ms = ended_at
    if started_at > 0 and ended_at > 0 then
        state.last_probe_duration_ms = ended_at - started_at
    else
        state.last_probe_duration_ms = 0
    end

    if is_current_probe(probe_id) then
        state.last_completed_probe_id = probe_id
    end

    state.inflight = false

    if state.pending then
        local pending_reason = state.pending_reason ~= "" and state.pending_reason or (reason or "pending")
        local pending_urgent = state.pending_urgent
        state.pending = false
        state.pending_reason = ""
        state.pending_urgent = false
        schedule_probe(pending_reason, { urgent = pending_urgent })
    end
end

schedule_probe = function(reason, opts)
    opts = opts or {}

    if state.inflight then
        state.pending = true
        state.pending_reason = reason or state.pending_reason
        if opts.urgent then
            state.pending_urgent = true
        end
        return
    end

    if is_headless() then
        return
    end

    if is_windows() then
        set_mode("inactive")
        return
    end

    local urgent = opts.urgent == true
    local now = now_ms_or_zero()

    local target_due_at_ms = now
    if not urgent then
        local extra_delay_ms = tonumber(opts.delay_ms) or 0
        if extra_delay_ms < 0 then
            extra_delay_ms = 0
        end
        target_due_at_ms = now + extra_delay_ms

        local min_probe_ms = tonumber(config.min_probe_ms) or DEFAULTS.min_probe_ms
        if min_probe_ms < 0 then
            min_probe_ms = 0
        end

        if state.last_probe_at_ms > 0 then
            local throttle_due_at_ms = state.last_probe_at_ms + min_probe_ms
            if throttle_due_at_ms > target_due_at_ms then
                target_due_at_ms = throttle_due_at_ms
            end
        end
    end

    if target_due_at_ms <= now then
        clear_scheduled_probe()
        run_probe(reason or "event", { urgent = urgent })
        return
    end

    if not uv or not uv.new_timer then
        run_probe(reason or "timer-fallback")
        return
    end

    probe_timer = probe_timer or uv.new_timer()
    if not probe_timer then
        run_probe(reason or "timer-fallback")
        return
    end

    state.scheduled_reason = reason or "scheduled"
    state.scheduled_due_at_ms = target_due_at_ms

    local delay_ms = target_due_at_ms - now
    if delay_ms < 0 then
        delay_ms = 0
    end

    probe_timer:stop()
    probe_timer:start(
        delay_ms,
        0,
        v.schedule_wrap(function()
            local scheduled_reason = state.scheduled_reason ~= "" and state.scheduled_reason or "scheduled"
            state.scheduled_reason = ""
            state.scheduled_due_at_ms = 0
            run_probe(scheduled_reason)
        end)
    )
end

local function schedule_initial_probe()
    schedule_probe("initial", { delay_ms = INITIAL_PROBE_DELAY_MS })
end

function M.teardown()
    probe_timer = close_timer(probe_timer)
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

    v.api.nvim_create_autocmd({ "VimEnter", "FocusGained", "DirChanged" }, {
        group = augroup_id,
        callback = function(args)
            local trigger = (args and args.event) or "ui-event"
            schedule_probe(trigger)
        end,
    })

    v.api.nvim_create_autocmd("User", {
        group = augroup_id,
        pattern = "OpencodeEvent:*",
        callback = function(args)
            local event_name = (args and args.match) or "OpencodeEvent:*"

            if event_name == "OpencodeEvent:server.connected" or event_name == "OpencodeEvent:server.disconnected" then
                state.last_urgent_event_at_ms = now_ms_or_zero()
                schedule_probe(event_name, { urgent = true })
                return
            end

            schedule_probe(event_name)
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
