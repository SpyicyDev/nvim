return {
    {
        "numToStr/FTerm.nvim",
        keys = {
            {
                "<A-g>",
                function()
                    local fterm = require("FTerm")
                    if not fterm._lazygit then
                        fterm._lazygit = fterm:new({
                            ft = 'fterm_lazygit',
                            cmd = "lazygit",
                            dimensions = {
                                height = 0.9,
                                width = 0.9
                            }
                        })
                    end
                    fterm._lazygit:toggle()
                end,
                mode = { "n", "t" },
                desc = "Toggle lazygit"
            },
        },
    }
}
