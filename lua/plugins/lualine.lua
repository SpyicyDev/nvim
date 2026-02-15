return {
    -- statusline
    {
        "nvim-lualine/lualine.nvim",
        config = function()
            local v = _G[string.char(118, 105, 109)]
            local uv = v.uv or v.loop

            local oc_cache = {
                mode = "inactive",
                port = nil,
            }

            local function oc_set_state(mode, port)
                local changed = false
                if oc_cache.mode ~= mode then
                    oc_cache.mode = mode
                    changed = true
                end

                if oc_cache.port ~= port then
                    oc_cache.port = port
                    changed = true
                end

                if not changed then
                    return
                end

                local ok, lualine = pcall(require, "lualine")
                if ok then
                    v.schedule(function()
                        lualine.refresh({ place = { "statusline" } })
                    end)
                else
                    v.cmd("redrawstatus")
                end
            end

            local oc_probe_timer
            local oc_update_inflight = false
            local OC_FAST_DELAY_MS = 25
            local OC_ACTIVITY_DELAY_MS = 120

            local function oc_is_windows()
                return v.fn.has("win32") == 1
            end

            local function oc_is_descendant_of_nvim(pid, cb)
                if oc_is_windows() then
                    cb(false)
                    return
                end

                local neovim_pid = v.fn.getpid()
                local current_pid = pid
                local steps = 0

                local function step()
                    steps = steps + 1
                    if steps > 10 then
                        cb(false)
                        return
                    end

                    v.system({ "ps", "-o", "ppid=", "-p", tostring(current_pid) }, { text = true }, function(res)
                        if res.code ~= 0 then
                            cb(false)
                            return
                        end

                        local parent_pid = tonumber((res.stdout or ""):match("%d+"))
                        if not parent_pid or parent_pid == 1 then
                            cb(false)
                            return
                        end
                        if parent_pid == neovim_pid then
                            cb(true)
                            return
                        end

                        current_pid = parent_pid
                        step()
                    end)
                end

                step()
            end

            local function oc_update_async()
                if oc_update_inflight then
                    return
                end
                oc_update_inflight = true

                if oc_is_windows() then
                    oc_set_state("inactive", nil)
                    oc_update_inflight = false
                    return
                end

                v.system({ "pgrep", "-f", "opencode.*--port" }, { text = true }, function(res)
                    if res.code ~= 0 then
                        oc_set_state("inactive", nil)
                        oc_update_inflight = false
                        return
                    end

                    local pids = {}
                    for line in (res.stdout or ""):gmatch("[^\r\n]+") do
                        local pid = tonumber(line)
                        if pid then
                            table.insert(pids, pid)
                        end
                    end

                    if #pids == 0 then
                        oc_set_state("inactive", nil)
                        oc_update_inflight = false
                        return
                    end

                    local idx = 1
                    local function check_next_pid()
                        local pid = pids[idx]
                        if not pid then
                            oc_set_state("external", nil)
                            oc_update_inflight = false
                            return
                        end

                        oc_is_descendant_of_nvim(pid, function(is_internal)
                            if is_internal then
                                oc_set_state("internal", nil)
                                oc_update_inflight = false
                                return
                            end

                            idx = idx + 1
                            check_next_pid()
                        end)
                    end

                    check_next_pid()
                end)
            end

            local function oc_schedule_update(delay_ms)
                if #v.api.nvim_list_uis() == 0 then
                    return
                end

                delay_ms = delay_ms or 0
                if oc_update_inflight and delay_ms == 0 then
                    return
                end

                oc_probe_timer = oc_probe_timer or uv.new_timer()
                if not oc_probe_timer then
                    oc_update_async()
                    return
                end

                oc_probe_timer:stop()
                oc_probe_timer:start(
                    delay_ms,
                    0,
                    v.schedule_wrap(function()
                        oc_update_async()
                    end)
                )
            end

            local function oc_teardown()
                if not oc_probe_timer then
                    return
                end

                if not oc_probe_timer:is_closing() then
                    oc_probe_timer:stop()
                    oc_probe_timer:close()
                end

                oc_probe_timer = nil
            end

            local oc_component = {
                function()
                    local icon = "󰅛"
                    if oc_cache.mode == "internal" then
                        icon = "󰒮"
                    elseif oc_cache.mode == "external" then
                        icon = "󰈀"
                    end

                    return "oc: " .. icon
                end,
                color = function()
                    if oc_cache.mode == "internal" then
                        return { fg = "#89b4fa" }
                    elseif oc_cache.mode == "external" then
                        return { fg = "#a6e3a1" }
                    end
                    return { fg = "#7f849c" }
                end,
            }

            require('lualine').setup({
                options = {
                    icons_enabled = true,
                    theme = 'catppuccin',
                    component_separators = { left = '', right = '' },
                    section_separators = { left = '', right = '' },
                    disabled_filetypes = {
                        statusline = {},
                        winbar = {},
                    },
                    ignore_focus = {},
                    always_divide_middle = true,
                    globalstatus = true,
                    refresh = {
                        statusline = 1000,
                        tabline = 1000,
                        winbar = 1000,
                    }
                },
                sections = {
                    lualine_a = { 'mode' },
                    lualine_b = { 'branch', 'diff', 'diagnostics' },
                    lualine_c = { 'filename' },
                    lualine_x = {
                        oc_component,
                        {
                            'copilot',
                            symbols = {
                                status = {
                                    icons = {
                                        enabled = " ",
                                        disabled = " ",
                                        warning = " ",
                                        unknown = " "
                                    }
                                }
                            }
                        },
                        'encoding',
                        'fileformat',
                        'filetype'
                    },
                    lualine_y = { 'progress' },
                    lualine_z = { 'location' }
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { 'filename' },
                    lualine_x = { 'location' },
                    lualine_y = {},
                    lualine_z = {}
                },
                tabline = {},
                winbar = {
                },
                inactive_winbar = {},
                extensions = {}
            })

            local oc_group = v.api.nvim_create_augroup("LualineOpencodeStatus", { clear = true })

            v.api.nvim_create_autocmd({ "VimEnter", "FocusGained", "DirChanged" }, {
                group = oc_group,
                callback = function()
                    oc_schedule_update(OC_FAST_DELAY_MS)
                end,
            })

            v.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "InsertLeave", "CmdlineLeave", "CursorHold", "CursorHoldI" }, {
                group = oc_group,
                callback = function()
                    oc_schedule_update(OC_ACTIVITY_DELAY_MS)
                end,
            })

            v.api.nvim_create_autocmd("User", {
                group = oc_group,
                pattern = {
                    "OpencodeEvent:server.connected",
                    "OpencodeEvent:server.disconnected",
                    "OpencodeEvent:session.idle",
                    "OpencodeEvent:session.error",
                    "OpencodeEvent:permission.asked",
                    "OpencodeEvent:permission.replied",
                },
                callback = function()
                    oc_schedule_update(OC_FAST_DELAY_MS)
                end,
            })

            v.api.nvim_create_autocmd("VimLeavePre", {
                group = oc_group,
                callback = oc_teardown,
            })

            oc_schedule_update(0)
        end
    },
}
