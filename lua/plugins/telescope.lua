return {
    -- fuzzy finder
    {
        'nvim-telescope/telescope.nvim',
        cmd = "Telescope",
        keys = {
            { "<leader>ff", "<cmd>Telescope find_files<cr>",   desc = "Find files" },
            { "<leader>fg", "<cmd>Telescope live_grep<cr>",    desc = "Live grep" },
            { "<leader>fm", "<cmd>Telescope grapple tags<cr>", desc = "Grapple tags" },
            { "<leader>ft", "<cmd>TodoTelescope<cr>",          desc = "Todo" },
            { "<leader>fk", "<cmd>Telescope keymaps<cr>",      desc = "Keymaps" },
            { "<leader>fl", "<cmd>Telescope help_tags<cr>",    desc = "Help" },
            { "<leader>fb", "<cmd>Telescope file_browser<cr>", desc = "File browser" },
        },
        config = function()
            require('telescope').load_extension('fzf')
            require('telescope').load_extension('grapple')
            require('telescope').load_extension('file_browser')
        end,

        dependencies = {
            "nvim-telescope/telescope-file-browser.nvim",
            -- native fzf for telescope
            { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
        },
    },
}
