return {
    {
        "ggandor/leap.nvim",
        config = function()
            vim.keymap.set('n', 's', '<Plug>(leap)')
            vim.keymap.set({ 'x', 'o' }, 's', '<Plug>(leap-forward)')
            vim.keymap.set({ 'x', 'o' }, 'S', '<Plug>(leap-backward)')
            vim.keymap.set({ 'n', 'x', 'o' }, 'ga', function()
                require('leap.treesitter').select()
            end)
            vim.keymap.set({ 'n', 'o' }, 'gs', function()
                require('leap.remote').action()
            end)
        end,
        cond = false,
    },
    {
        "folke/flash.nvim",
        event = "VeryLazy",
        opts = {
            search = {
                mode = "search"
            },
            jump = {
                autojump = true
            },
            label = {
                uppercase = false
            }
        },
        keys = {
            { "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
            { "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
            { "r",     mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash" },
            { "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
            { "<M-s>", mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
        },
        cond = true
    }
}
