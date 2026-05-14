return {
    {
        "catgoose/nvim-colorizer.lua",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            filetypes = { "*" },
            user_default_options = {
                names = false,
                RRGGBBAA = true,
                AARRGGBB = true,
                rgb_fn = true,
                hsl_fn = true,
                css = false,
                css_fn = false,
                tailwind = true,
                mode = "background",
            },
        },
    },
}
