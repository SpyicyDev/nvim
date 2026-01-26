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

            ---@type opencode.Opts
            vim.g.opencode_opts = {
                provider = {
                    enabled = "snacks",
                    cmd = "opencode --port --model openai/gpt-5.2-low",
                    snacks = {
                        win = opencode_float_win(),
                    },
                    terminal = {
                        width = math.floor(vim.o.columns * 0.30),
                    },
                },
            }

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
