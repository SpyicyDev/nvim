return {
    {
        "numToStr/FTerm.nvim",
        init = function()
            vim.keymap.set({ "n", "t" }, "<A-d>", function() require("FTerm").toggle() end)
        end
    }
}
