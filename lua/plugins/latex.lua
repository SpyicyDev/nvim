return {
    -- LaTeX yay!
    {
        "lervag/vimtex",
        ft = { "tex", "latex" },
        init = function()
            vim.g.vimtex_view_method = 'skim'
            vim.opt.conceallevel = 2
            vim.g.vimtex_quickfix_open_on_warning = 0
        end
    },
}
