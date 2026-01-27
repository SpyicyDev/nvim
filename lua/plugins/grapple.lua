return {
    -- grapple, BLAZINGLY FAST
    {
        "cbochs/grapple.nvim",
        cmd = "Grapple",
        config = function()
            require("grapple").setup({
                scope = "git",
            })
        end,
        keys = {
            { "<leader>hg", "<cmd>Grapple toggle<cr>", desc = "Grapple toggle tag" },
            { "<leader>hh", "<cmd>Grapple toggle_tags<cr>", desc = "Grapple toggle tags window" },

            { "<leader>1", "<cmd>Grapple select index=1<cr>", desc = "Grapple select tag 1" },
            { "<leader>2", "<cmd>Grapple select index=2<cr>", desc = "Grapple select tag 2" },
            { "<leader>3", "<cmd>Grapple select index=3<cr>", desc = "Grapple select tag 3" },
            { "<leader>4", "<cmd>Grapple select index=4<cr>", desc = "Grapple select tag 4" },
            { "<leader>5", "<cmd>Grapple select index=5<cr>", desc = "Grapple select tag 5" },
        },
    },
}
