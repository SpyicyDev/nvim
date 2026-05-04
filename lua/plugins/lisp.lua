return {
    {
        "Olical/conjure",
        -- [Optional] cmp-conjure for cmp
        ft = { "fennel" },
        dependencies = {
            {
                "PaterJason/cmp-conjure",
            },
        },
        config = function(_, opts)
            require("conjure.main").main()
            require("conjure.mapping")["on-filetype"]()
        end,
        init = function()
            vim.g['conjure#filetypes'] = {"fennel"}

            vim.g['conjure#client#fennel#aniseed#mapping#reset_repl'] = "rs"
        end,
    },
    "gpanders/nvim-parinfer",
}
