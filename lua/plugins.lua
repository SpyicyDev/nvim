require("lazy").setup({

    -- fuzzy finder
    {
        'nvim-telescope/telescope.nvim',
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

        }
    },
    {
        "L3MON4D3/LuaSnip",
        -- follow latest release.
        version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
        -- install jsregexp (optional!).
        build = "make install_jsregexp",

        dependencies = {
            "rafamadriz/friendly-snippets",
            "saadparwaiz1/cmp_luasnip",
        },
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
    {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        event = "InsertEnter",
    },

    {
        "zbirenbaum/copilot-cmp",
        config = function()
            require("copilot_cmp").setup()
        end
    },
    -- Use your favorite package manager to install, for example in lazy.nvim
    {
        "sourcegraph/sg.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },

        -- If you have a recent version of lazy.nvim, you don't need to add this!
        build = "nvim -l build/init.lua",
    },

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


    -- BEGIN LISP PLUGINS
    --[[
    {
        "Olical/conjure",
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
    --]]
    "gpanders/nvim-parinfer",
    "tpope/vim-surround",

    --"guns/vim-sexp",
    --"tpope/vim-sexp-mappings-for-regular-people",

    "p00f/nvim-ts-rainbow",
    -- END LISP PLUGINS


    "tpope/vim-repeat",
    "cohama/lexima.vim",

    { "CRAG666/code_runner.nvim", config = true },
    "klen/nvim-config-local",

    {
        'kevinhwang91/nvim-ufo',
        dependencies = {
            'kevinhwang91/promise-async',
        },
    },
    {
        "andrewferrier/wrapping.nvim",
        config = function()
            require("wrapping").setup()
        end
    },
    {
        'stevearc/oil.nvim',
        opts = {},
        -- Optional dependencies
        dependencies = { "nvim-tree/nvim-web-devicons" },
    },

    "lervag/vimtex",
}, {

})
