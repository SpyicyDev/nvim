return {
    --[[
    {
        "tpope/vim-fugitive",
        init = function()
            vim.keymap.set("n", "<leader>g", vim.cmd.Git)
        end
    }, ]]
    {
        "NeogitOrg/neogit",
        dependencies = {
            "nvim-lua/plenary.nvim",  -- required
            "sindrets/diffview.nvim", -- optional - Diff integration

            -- Only one of these is needed, not both.
            "nvim-telescope/telescope.nvim", -- optional
        },
        config = true,
        init = function()
            vim.keymap.set("n", "<leader>g", vim.cmd.Neogit)
        end
    },

    {
        "lewis6991/gitsigns.nvim",
        opts = {},
    }
}
