return {
    -- better netrw
    {
        'stevearc/oil.nvim',
        opts = {},
        init = function()
            vim.keymap.set("n", "<leader>pv", "<cmd>Oil --float .<cr>")
        end,
        -- Optional dependencies
        dependencies = { "nvim-tree/nvim-web-devicons" },
    },
}
