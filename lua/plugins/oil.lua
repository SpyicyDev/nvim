return {
    -- better netrw
    {
        'stevearc/oil.nvim',
        cmd = "Oil",
        keys = {
            { "<leader>pv", "<cmd>Oil --float .<cr>", desc = "Oil (float)" },
        },
        opts = {
            keymaps = {
                ["<C-a>"] = "actions.select_vsplit"
            }
        },
        -- Optional dependencies
        dependencies = { "nvim-tree/nvim-web-devicons" },
    },
}
