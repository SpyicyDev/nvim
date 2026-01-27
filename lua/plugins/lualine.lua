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
                    lualine.refresh({ place = { "statusline" } })
                else
                    v.cmd("redrawstatus")
                end
            end

            local oc_timer_started = false
            local oc_timer

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
                local ok, server = pcall(require, "opencode.cli.server")
                if not ok or type(server) ~= "table" or type(server.get_port) ~= "function" then
                    oc_set_state("inactive", nil)
                    return
                end

                local promise = server.get_port(false)
                if type(promise) ~= "table" or type(promise.next) ~= "function" then
                    oc_set_state("inactive", nil)
                    return
                end

                promise
                    :next(function(port)
                        local n = tonumber(port)
                        if not n then
                            oc_set_state("inactive", nil)
                            return
                        end

                        if oc_is_windows() then
                            oc_set_state("external", n)
                            return
                        end

                        v.system({ "lsof", "-n", "-P", "-iTCP:" .. tostring(n), "-sTCP:LISTEN", "-t" }, { text = true }, function(res)
                            if res.code ~= 0 then
                                oc_set_state("inactive", nil)
                                return
                            end

                            local pid = tonumber((res.stdout or ""):match("%d+"))
                            if not pid then
                                oc_set_state("inactive", nil)
                                return
                            end

                            oc_is_descendant_of_nvim(pid, function(is_internal)
                                oc_set_state(is_internal and "internal" or "external", n)
                            end)
                        end)
                    end)
                    :catch(function()
                        oc_set_state("inactive", nil)
                    end)
            end

            local function oc_ensure_timer()
                if oc_timer_started then
                    return
                end
                oc_timer_started = true

                oc_timer = oc_timer or uv.new_timer()
                if not oc_timer then
                    return
                end

                oc_timer:start(
                    0,
                    1500,
                    v.schedule_wrap(function()
                        oc_update_async()
                    end)
                )
            end

            local oc_component = {
                function()
                    oc_ensure_timer()

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
        end
    },
}
