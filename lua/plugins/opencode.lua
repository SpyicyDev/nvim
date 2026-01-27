return {
    {
        "NickvanDyke/opencode.nvim",
        dependencies = {
            -- Recommended for `ask()` and `select()`.
            -- Required for `snacks` provider.
            ---@module 'snacks' <- Loads `snacks.nvim` types for configuration intellisense.
            { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
        },
        config = function()
            local function opencode_float_win()
                local right_margin = 2
                local outer_width = math.floor(vim.o.columns * 0.30)
                local outer_height = vim.o.lines - vim.o.cmdheight - 2

                local inner_width = math.max(1, outer_width - 2)
                local inner_height = math.max(1, outer_height - 2)

                return {
                    position = "float",
                    relative = "editor",
                    row = 0,
                    col = math.max(0, vim.o.columns - outer_width - right_margin),
                    width = inner_width,
                    height = inner_height,
                    border = "single",
                    backdrop = false,
                }
            end

            local opencode_opts = {
                provider = {
                    enabled = "snacks",
                    cmd = "opencode --port --model openai/gpt-5.2-low",
                    snacks = {
                        auto_close = false,
                        win = opencode_float_win(),
                    },
                    terminal = {
                        width = math.floor(vim.o.columns * 0.30),
                    },
                },
            }
            vim.g.opencode_opts = opencode_opts

            local target = (vim.g.opencode_target_mode == "external") and "external" or "internal"
            local internal_cmd = opencode_opts.provider and opencode_opts.provider.cmd or nil
            local external_port = tonumber(vim.g.opencode_external_port) or nil

            local function system_text(args)
                local ok, obj = pcall(vim.system, args, { text = true })
                if not ok or not obj then
                    return nil
                end

                local res = obj:wait()
                if not res or res.code ~= 0 then
                    return nil
                end

                return res.stdout or ""
            end

            local function get_processes_unix()
                local stdout = system_text({ "pgrep", "-f", "opencode.*--port" })
                if not stdout or stdout == "" then
                    return {}
                end

                local processes = {}
                for line in stdout:gmatch("[^\r\n]+") do
                    local pid = tonumber(line)
                    if pid then
                        table.insert(processes, { pid = pid })
                    end
                end

                return processes
            end

            local function get_listening_ports_for_pid(pid)
                local stdout = system_text({
                    "lsof",
                    "-w",
                    "-iTCP",
                    "-sTCP:LISTEN",
                    "-P",
                    "-n",
                    "-a",
                    "-p",
                    tostring(pid),
                })
                if not stdout or stdout == "" then
                    return {}
                end

                local ports = {}
                for line in stdout:gmatch("[^\r\n]+") do
                    if not line:match("^COMMAND%s") then
                        local port_str = line:match(":(%d+)%s*%(")
                        local port = port_str and tonumber(port_str) or nil
                        if port then
                            ports[port] = true
                        end
                    end
                end

                local out = {}
                for port, _ in pairs(ports) do
                    table.insert(out, port)
                end
                table.sort(out)
                return out
            end

            local function is_descendant_of_neovim(pid)
                local neovim_pid = vim.fn.getpid()
                local current_pid = pid

                for _ = 1, 10 do
                    local stdout = system_text({ "ps", "-o", "ppid=", "-p", tostring(current_pid) })
                    local parent_pid = stdout and tonumber(stdout) or nil
                    if not parent_pid then
                        return false
                    end
                    if parent_pid == 1 then
                        return false
                    elseif parent_pid == neovim_pid then
                        return true
                    end
                    current_pid = parent_pid
                end

                return false
            end

            local function is_inside_nvim_cwd(server_cwd)
                if type(server_cwd) ~= "string" or server_cwd == "" then
                    return false
                end

                local nvim_cwd = vim.fn.getcwd()
                return server_cwd:find(nvim_cwd, 1, true) == 1
            end

            local function probe_server_cwd(port)
                local ok, path = pcall(require("opencode.cli.client").get_path, port)
                if not ok or not path then
                    return nil
                end

                return path.directory or path.worktree
            end

            local function get_integrated_opencode_server_pid_unix()
                for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                    if vim.bo[buf].filetype == "opencode_terminal" then
                        local ok, job_id = pcall(function()
                            return vim.b[buf].terminal_job_id
                        end)
                        if ok and job_id then
                            local pid = vim.fn.jobpid(job_id)
                            if type(pid) == "number" and pid > 0 then
                                return pid
                            end
                        end
                    end
                end

                return nil
            end

            local function discover_external_servers_in_nvim_cwd_unix()
                local processes = get_processes_unix()
                if #processes == 0 then
                    return {}
                end

                -- Avoid "discovering" the integrated opencode server we started in this Neovim instance.
                local integrated_pid = get_integrated_opencode_server_pid_unix()

                local servers = {}
                local seen = {}

                for _, process in ipairs(processes) do
                    local pid = process.pid
                    if pid and pid ~= integrated_pid and not is_descendant_of_neovim(pid) then
                        for _, port in ipairs(get_listening_ports_for_pid(pid)) do
                            local key = tostring(pid) .. ":" .. tostring(port)
                            if not seen[key] then
                                local cwd = probe_server_cwd(port)
                                if cwd and is_inside_nvim_cwd(cwd) then
                                    servers[#servers + 1] = { pid = pid, port = port, cwd = cwd }
                                    seen[key] = true
                                end
                            end
                        end
                    end
                end

                table.sort(servers, function(a, b)
                    if a.cwd == b.cwd then
                        if a.port == b.port then
                            return a.pid < b.pid
                        end
                        return a.port < b.port
                    end
                    return a.cwd < b.cwd
                end)

                return servers
            end

            -- Keep these helpers in Lua space. vim.g values round-trip through vimscript vars,
            -- so mutating nested tables doesn't persist, and functions can't be stored there.
            _G.opencode_external_helpers = _G.opencode_external_helpers or {}
            local external_helpers = _G.opencode_external_helpers

            external_helpers.discover_external_servers_in_nvim_cwd = function()
                local ok, servers = pcall(discover_external_servers_in_nvim_cwd_unix)
                if not ok then
                    return {}
                end
                return servers or {}
            end

            external_helpers.pick_external_server = function(servers, opts, callback)
                opts = opts or {}
                callback = callback or function() end

                if type(servers) ~= "table" or vim.tbl_isempty(servers) then
                    callback(nil)
                    return
                end

                local items = {}
                for _, server in ipairs(servers) do
                    if server and server.port and server.cwd and server.pid then
                        items[#items + 1] = {
                            server = server,
                            label = string.format("%d  %s  (pid %d)", server.port, server.cwd, server.pid),
                        }
                    end
                end

                if vim.tbl_isempty(items) then
                    callback(nil)
                    return
                end

                local ok = pcall(vim.ui.select, items, {
                    prompt = opts.prompt or "Select external opencode server",
                    format_item = function(item)
                        return item.label
                    end,
                }, function(choice)
                    if not choice then
                        callback(nil)
                        return
                    end
                    callback(choice.server)
                end)

                if not ok then
                    callback(nil)
                end
            end

            vim.g.opencode_target_mode = vim.g.opencode_target_mode or target
            vim.g.opencode_internal_cmd = vim.g.opencode_internal_cmd or internal_cmd
            vim.g.opencode_external_port = vim.g.opencode_external_port or external_port

            vim.api.nvim_create_autocmd("VimResized", {
                callback = function()
                    local ok, cfg = pcall(require, "opencode.config")
                    if not ok then
                        return
                    end

                    local win = opencode_float_win()
                    cfg.opts.provider.snacks.win = vim.tbl_deep_extend("force", cfg.opts.provider.snacks.win or {}, win)
                end,
            })

            -- Required for `opts.events.reload`.
            vim.o.autoread = true

            local opencode = require("opencode")

            local last_non_opencode_win

            local function get_opencode_win()
                for _, win in ipairs(vim.api.nvim_list_wins()) do
                    local buf = vim.api.nvim_win_get_buf(win)
                    if vim.bo[buf].filetype == "opencode_terminal" then
                        return win
                    end
                end
                return nil
            end

            vim.keymap.set({ "n", "x" }, "<leader>oa", function() opencode.ask("@this: ", { submit = true }) end,
                { desc = "opencode: ask" })
            vim.keymap.set({ "n", "x" }, "<leader>os", function() opencode.select() end,
                { desc = "opencode: select action" })
            vim.keymap.set({ "n", "t" }, "<leader>oo", function() opencode.toggle() end,
                { desc = "opencode: toggle" })

            local function is_port_responsive(port)
                if not port then
                    return false
                end
                local ok, _ = pcall(require("opencode.cli.client").get_path, port)
                return ok
            end

            local function apply_target_mode(new_mode, new_external_port)
                local ok, cfg = pcall(require, "opencode.config")
                if not ok or not cfg or not cfg.opts then
                    vim.notify("opencode: failed to load config", vim.log.levels.WARN)
                    return false
                end

                local was_visible = get_opencode_win() ~= nil

                local function close_current_provider_terminal()
                    local ok_win, win = pcall(function()
                        return cfg.provider and cfg.provider.get and cfg.provider:get() or nil
                    end)
                    if ok_win and win and win.close then
                        pcall(win.close, win)
                    end
                end

                close_current_provider_terminal()

                if new_mode == "external" then
                    local port = tonumber(new_external_port)
                    if not port then
                        vim.notify("opencode: invalid external port", vim.log.levels.WARN)
                        return false
                    end

                    cfg.opts.port = port
                    cfg.opts.provider.cmd = string.format("opencode attach http://127.0.0.1:%d", port)
                    if cfg.provider and cfg.provider.cmd ~= nil then
                        cfg.provider.cmd = cfg.opts.provider.cmd
                    end
                    vim.g.opencode_target_mode = "external"
                    vim.g.opencode_external_port = port
                else
                    cfg.opts.port = nil
                    cfg.opts.provider.cmd = vim.g.opencode_internal_cmd
                    if cfg.provider and cfg.provider.cmd ~= nil then
                        cfg.provider.cmd = cfg.opts.provider.cmd
                    end
                    vim.g.opencode_target_mode = "internal"
                end

                if was_visible then
                    pcall(opencode.toggle)
                end

                return true
            end

            vim.keymap.set({ "n", "t" }, "<leader>ot", function()
                local current = (vim.g.opencode_target_mode == "external") and "external" or "internal"

                if current == "external" then
                    apply_target_mode("internal")
                    return
                end

                local port = tonumber(vim.g.opencode_external_port)
                if port and is_port_responsive(port) then
                    apply_target_mode("external", port)
                    return
                end

                local helpers = _G.opencode_external_helpers
                if type(helpers) ~= "table" or type(helpers.discover_external_servers_in_nvim_cwd) ~= "function" then
                    vim.notify("opencode: external discovery helper missing", vim.log.levels.WARN)
                    return
                end

                local function continue_with_internal_port(internal_port)
                    local ok, servers = pcall(helpers.discover_external_servers_in_nvim_cwd)
                    if not ok or type(servers) ~= "table" or vim.tbl_isempty(servers) then
                        vim.notify("opencode: no external servers found", vim.log.levels.INFO)
                        return
                    end

                    if internal_port then
                        servers = vim.tbl_filter(function(server)
                            return server and server.port ~= internal_port
                        end, servers)
                    end

                    if vim.tbl_isempty(servers) then
                        vim.notify("opencode: no external servers found", vim.log.levels.INFO)
                        return
                    end

                    if #servers == 1 then
                        apply_target_mode("external", servers[1].port)
                        return
                    end

                    if type(helpers.pick_external_server) ~= "function" then
                        vim.notify("opencode: external picker helper missing", vim.log.levels.WARN)
                        return
                    end

                    helpers.pick_external_server(servers, { prompt = "Select external opencode target" }, function(server)
                        if not server or not server.port then
                            return
                        end
                        apply_target_mode("external", server.port)
                    end)
                end

                local panel_open = get_opencode_win() ~= nil
                require("opencode.cli.server").get_port(false):next(function(internal_port)
                    continue_with_internal_port(tonumber(internal_port))
                end, function(_)
                    if panel_open then
                        vim.notify("opencode: internal server not ready yet; try again", vim.log.levels.WARN)
                        return
                    end
                    continue_with_internal_port(nil)
                end)
            end, { desc = "opencode: toggle internal/external" })
            vim.keymap.set({ "n", "t" }, "<leader>O", function()
                local ow = get_opencode_win()
                if not ow then
                    return
                end

                local cw = vim.api.nvim_get_current_win()
                if cw == ow then
                    if last_non_opencode_win and vim.api.nvim_win_is_valid(last_non_opencode_win) then
                        vim.api.nvim_set_current_win(last_non_opencode_win)
                    end
                    return
                end

                last_non_opencode_win = cw
                vim.api.nvim_set_current_win(ow)
            end, { desc = "opencode: focus toggle" })

            vim.keymap.set({ "n", "x" }, "<leader>or", function() return opencode.operator("@this ") end,
                { desc = "opencode: add range", expr = true })
            vim.keymap.set("n", "<leader>ol", function() return opencode.operator("@this ") .. "_" end,
                { desc = "opencode: add line", expr = true })

            vim.keymap.set({ "n", "t" }, "<leader>ok", function() opencode.command("session.half.page.up") end,
                { desc = "opencode: scroll up" })
            vim.keymap.set({ "n", "t" }, "<leader>oj", function() opencode.command("session.half.page.down") end,
                { desc = "opencode: scroll down" })
        end,
    }
}
