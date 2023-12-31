return {
    -- git
    {
        "tpope/vim-fugitive",
        init = function()
            vim.keymap.set("n", "<leader>g", vim.cmd.Git)
        end
    },
    {
        "lewis6991/gitsigns.nvim",
        opts = {},
    }
}
