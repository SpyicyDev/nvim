return {
    -- highlighted todo comments, looks nice
    {
        "folke/todo-comments.nvim",
        event = { "BufReadPost", "BufNewFile" },
        cmd = { "TodoTrouble", "TodoTelescope", "TodoQuickFix", "TodoLocList" },
        keys = {
            { "<leader>tt", "<cmd>TodoTrouble<cr>", desc = "Todo (Trouble)" },
        },
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {},
    },
}
