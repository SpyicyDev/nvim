require("lazy").setup({

    -- fuzzy finder
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.1',
        dependencies = { 'nvim-lua/plenary.nvim' }
    },
    "nvim-telescope/telescope-file-browser.nvim",
    -- native fzf for telescope
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },

    -- devicons
    "nvim-tree/nvim-web-devicons",

    -- colorscheme
    { "catppuccin/nvim",                          name = "catppuccin" },

    -- treesitter
    { "nvim-treesitter/nvim-treesitter",          build = ":TSUpdate" },

    -- harpoon, BLAZINGLY FAST
    "theprimeagen/harpoon",

    -- obsession for session management
    "tpope/vim-obsession",

    -- undo visualizer
    "mbbill/undotree",

    -- git
    "tpope/vim-fugitive",

    -- LSP
    {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v2.x',
        dependencies = {
            -- LSP Support
            { 'neovim/nvim-lspconfig' }, -- Required
            {
                -- Optional
                'williamboman/mason.nvim',
                build = ":MasonUpdate",
            },
            { 'williamboman/mason-lspconfig.nvim' }, -- Optional

            -- Autocompletion
            { 'hrsh7th/nvim-cmp' },     -- Required
            { 'hrsh7th/cmp-nvim-lsp' }, -- Required
            { 'hrsh7th/cmp-nvim-lua' },
            { 'L3MON4D3/LuaSnip' },     -- Required

        }
    },
    "lukas-reineke/lsp-format.nvim",

    -- tmux vim integration
    "christoomey/vim-tmux-navigator",

    -- statusline
    "nvim-lualine/lualine.nvim",

    -- make netrw look nicer
    "prichrd/netrw.nvim",

    -- markdown renderer
    { "toppair/peek.nvim",        build = "deno task --quiet build:fast" },

    -- Github Copilot setup
    "zbirenbaum/copilot.lua",
    "zbirenbaum/copilot-cmp",

    -- icons for LSP
    "onsails/lspkind.nvim",

    -- Trouble!
    "folke/trouble.nvim",

    -- Arduino support
    "stevearc/vim-arduino",

    -- Neo-Tree fileviewer(using as better netrw)
    {
        "nvim-neo-tree/neo-tree.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
            "MunifTanjim/nui.nvim",
        }
    },
    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
        }
    },
    {
        'stevearc/dressing.nvim',
        opts = {},
    },
    "tpope/vim-dadbod",
    'kristijanhusak/vim-dadbod-ui',
    {
        "Olical/conjure",
        ft = { "clojure" }, -- etc
        -- [Optional] cmp-conjure for cmp
        dependencies = {
            {
                "PaterJason/cmp-conjure",
            },
        },
        config = function(_, opts)
            require("conjure.main").main()
            require("conjure.mapping")["on-filetype"]()
        end,
        init = function()
            -- Set configuration options here
        end,
    },
    "LunarWatcher/auto-pairs",
    "tpope/vim-surround",

    "guns/vim-sexp",
    "tpope/vim-sexp-mappings-for-regular-people",

    "tpope/vim-repeat",

    { "CRAG666/code_runner.nvim", config = true },
    "klen/nvim-config-local",

    "jbyuki/instant.nvim",
}, {

})
