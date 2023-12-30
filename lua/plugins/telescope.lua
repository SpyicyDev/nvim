return {
    -- fuzzy finder
    {
        'nvim-telescope/telescope.nvim',
        config = function()
            local builtin = require('telescope.builtin')
            vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
            vim.keymap.set('n', '<leader>fg', builtin.git_files, {})
            vim.keymap.set('n', '<leader>fl', builtin.live_grep, {})
            vim.keymap.set('n', '<leader>ft', "<cmd>TodoTelescope<CR>")
            vim.keymap.set('n', '<leader>fc', builtin.git_commits, {})
            vim.keymap.set('n', '<leader>fh', builtin.command_history, {})
            vim.keymap.set('n', '<leader>fk', builtin.keymaps, {})

            vim.keymap.set('n', '<leader>fb', require('telescope').extensions.file_browser.file_browser)

            require('telescope').load_extension('fzf')
            require("telescope").load_extension "file_browser"
        end,

        dependencies = {
            "nvim-telescope/telescope-file-browser.nvim",
            -- native fzf for telescope
            { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
        },
    },

}
