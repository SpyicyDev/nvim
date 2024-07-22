return {
    {
        "Exafunction/codeium.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "hrsh7th/nvim-cmp",
        },
        cond = false,
        config = function()
            require("codeium").setup({
                enable_chat = true,
            })
        end
    },
}
