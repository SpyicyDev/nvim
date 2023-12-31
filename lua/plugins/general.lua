return {
    -- colorscheme

    -- general/library plugins
    "nvim-tree/nvim-web-devicons",
    'nvim-lua/plenary.nvim',
    "christoomey/vim-tmux-navigator",
    {
        'stevearc/dressing.nvim',
        opts = {},
    },

    -- databases
    "tpope/vim-dadbod",
    'kristijanhusak/vim-dadbod-ui',

    -- dot dot dot
    "tpope/vim-repeat",


    -- auto pairs you get it
    {
        'windwp/nvim-autopairs',
        event = "InsertEnter",
    },

    -- undo visualizer
    {
        "mbbill/undotree",
        init = function()
            vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
            vim.g.undotree_SetFocusWhenToggle = 1
            vim.g.undotree_WindowLayout = 2
        end
    },

    -- error corroborator
    {
        "folke/trouble.nvim",

        init = function()
            vim.keymap.set('n', "<leader>xx", "<cmd>TroubleToggle<cr>")
        end
    },

    -- highlighted todo comments, looks nice
    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {}
    },
}
