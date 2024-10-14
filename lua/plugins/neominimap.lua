return {
    {
        "Isrothy/neominimap.nvim",
        version = "v3.*.*",
        enabled = true,
        lazy = false, -- NOTE: NO NEED to Lazy load
        -- Optional
        keys = {
            -- Global Minimap Controls
            { "<leader>nt",  "<cmd>Neominimap toggle<cr>",      desc = "Toggle global minimap" },
            { "<leader>nr",  "<cmd>Neominimap refresh<cr>",     desc = "Refresh global minimap" },

            -- Buffer-Specific Minimap Controls
            { "<leader>nbt", "<cmd>Neominimap bufToggle<cr>",   desc = "Toggle minimap for current buffer" },
            { "<leader>nbr", "<cmd>Neominimap bufRefresh<cr>",  desc = "Refresh minimap for current buffer" },

            ---Focus Controls
            { "<leader>nf",  "<cmd>Neominimap toggleFocus<cr>", desc = "Switch focus on minimap" },
        },
        init = function()
            -- The following options are recommended when layout == "float"
            vim.opt.wrap = false
            vim.opt.sidescrolloff = 36 -- Set a large value

            --- Put your configuration here
            vim.g.neominimap = {
                auto_enable = false,
            }
        end,
    }
}
