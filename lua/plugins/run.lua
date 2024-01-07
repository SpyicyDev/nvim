return {
    {
        "spyicydev/run.nvim",
        opts = {},
        dev = true,
        priority = 995,
        init = function()
            vim.keymap.set("n", "<leader>rr", function() require("run").run() end, { noremap = true, silent = false })
        end,
    }
}
