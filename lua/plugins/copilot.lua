return {
    --[[
    {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        event = "InsertEnter",
        opts = {
            suggestion = {
                enabled = true,
                auto_trigger = false,
                keymap = {
                    next = "<M-x>",
                    prev = "<M-z>",
                    accept = "<M-c>",
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
    ]]
}
