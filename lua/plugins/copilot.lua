return {
    {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        event = "InsertEnter",
        opts = {
            suggestion = {
                enabled = true,
                auto_trigger = true,
                keymap = {
                    next = "<M-]>",
                    prev = "<M-[>",
                    accept = "<Tab>",
                },
            },
        },
    },

    {
        "zbirenbaum/copilot-cmp",
        cond = false,
        opts = {},
    },

    {
        "gptlang/CopilotChat.nvim",
    },

    {
        'AndreM222/copilot-lualine',
    }
}
