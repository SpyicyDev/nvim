return {
    --[[
    {
        "Olical/conjure",
        -- [Optional] cmp-conjure for cmp
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
            -- Set configuration options here
        end,
    }, ]]
    "gpanders/nvim-parinfer",
    "tpope/vim-surround",
    --"guns/vim-sexp",
    --"tpope/vim-sexp-mappings-for-regular-people",
}
