return {
    {
        'goolord/alpha-nvim',
        event = "VimEnter",
        config = function()
            local dashboard = require('alpha.themes.dashboard')

            dashboard.section.buttons.val = {
                dashboard.button("e",       "  New file",             "<cmd>ene <CR>"),
                dashboard.button("SPC f f", "󰈞  Find files",           "<cmd>Telescope find_files<cr>"),
                dashboard.button("SPC f g", "󰈬  Live grep",            "<cmd>Telescope live_grep<cr>"),
                dashboard.button("r",       "  Recent files",         "<cmd>Telescope oldfiles<cr>"),
                dashboard.button("SPC f b", "  File browser",         "<cmd>Telescope file_browser<cr>"),
                dashboard.button("SPC f t", "  Todos",                "<cmd>TodoTelescope<cr>"),
                dashboard.button("SPC q s", "  Restore session",      "<cmd>lua require('persistence').load()<cr>"),
                dashboard.button("SPC s l", "  Restore last session", "<cmd>lua require('persistence').load({ last = true })<cr>"),
                dashboard.button("L",       "󰒲  Lazy",                  "<cmd>Lazy<cr>"),
                dashboard.button("M",       "  Mason",                 "<cmd>Mason<cr>"),
                dashboard.button("q",       "  Quit",                  "<cmd>qa<cr>"),
            }

            local function top_padding()
                return math.max(2, math.floor(vim.o.lines / 6))
            end

            dashboard.config.layout = {
                { type = "padding", val = top_padding() },
                dashboard.section.header,
                { type = "padding", val = 2 },
                dashboard.section.buttons,
                dashboard.section.footer,
            }

            vim.api.nvim_create_autocmd("VimResized", {
                group = vim.api.nvim_create_augroup("alpha_recenter", { clear = true }),
                callback = function()
                    if vim.bo.filetype == "alpha" then
                        dashboard.config.layout[1].val = top_padding()
                        vim.schedule(function() require("alpha").redraw() end)
                    end
                end,
            })

            require('alpha').setup(dashboard.config)
        end,
    },
}
