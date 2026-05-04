return {
    {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        event = "InsertEnter",
        opts = {
            suggestion = { enabled = false },
            panel = { enabled = false },
        },
    },

    {
        "AndreM222/copilot-lualine",
        dependencies = { "zbirenbaum/copilot.lua" },
    },
}
