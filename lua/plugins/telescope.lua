return {
    -- fuzzy finder
    {
        'nvim-telescope/telescope.nvim',
        config = function()
            local builtin = require('telescope.builtin')
            vim.keymap.set('n', '<leader>fh', builtin.find_files, {})
            vim.keymap.set("n", "<leader>ff", function()
                require("telescope").extensions.smart_open.smart_open()
            end, { noremap = true, silent = true })
            vim.keymap.set('n', '<leader>fr', '<Cmd>Telescope frecency<CR>', {})
            vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
            vim.keymap.set('n', '<leader>fm', '<cmd>Telescope harpoon marks<cr>', {})
            vim.keymap.set('n', '<leader>ft', "<cmd>TodoTelescope<CR>")
            vim.keymap.set('n', '<leader>fk', builtin.keymaps, {})
            vim.keymap.set('n', '<leader>fl', builtin.help_tags, {})

            vim.keymap.set('n', '<leader>fb', require('telescope').extensions.file_browser.file_browser)

            require('telescope').load_extension('fzf')
            require("telescope").load_extension('harpoon')
            require("telescope").load_extension "file_browser"
        end,

        dependencies = {
            "nvim-telescope/telescope-file-browser.nvim",
            -- native fzf for telescope
            { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
        },
    },
    -- {
    --     "nvim-telescope/telescope-frecency.nvim",
    --     config = function()
    --         require("telescope").load_extension "frecency"
    --     end,
    -- },
    {
        "danielfalk/smart-open.nvim",
        branch = "0.2.x",
        config = function()
            require("telescope").load_extension("smart_open")
        end,
        dependencies = {
            "kkharji/sqlite.lua",
            -- Only required if using match_algorithm fzf
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
            -- Optional.  If installed, native fzy will be used when match_algorithm is fzy
            { "nvim-telescope/telescope-fzy-native.nvim" },
        },
    },
}
