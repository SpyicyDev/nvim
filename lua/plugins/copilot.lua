return {
    {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        cond = false,
        event = "InsertEnter",
        opts = {
            suggestion = {
                enabled = true,
                auto_trigger = true,
                keymap = {
                    next = "<M-]>",
                    prev = "<M-[>",
                    accept = false,
                },
            },
        },
        init = function()
                vim.keymap.set("i", '<Tab>', function()
                    if require("copilot.suggestion").is_visible() then
                        require("copilot.suggestion").accept()
                    else
                        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "n", false)
                    end
                end, { silent = true })

                -- Mapping for Shift-Tab to accept the current line from suggestions
                vim.keymap.set("i", '<S-Tab>', function()
                    if require("copilot.suggestion").is_visible() then
                        require("copilot.suggestion").accept_line()
                    else
                        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<S-Tab>", true, false, true), "n", false)
                    end
                end, { silent = true })
            end
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
        cond = false,
    }
}
