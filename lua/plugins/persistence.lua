return {
    -- Lua
    {
        "folke/persistence.nvim",
        event = "BufReadPre", -- this will only start session saving when an actual file was opened
        opts = {
            -- add any custom options here
        },
        init = function()
            -- restore the session for the current directory
            vim.keymap.set("n", "<leader>qs", function()
                require("persistence").load()
            end, { desc = "Session: restore current directory" })
            vim.keymap.set("n", "<leader>sl", function()
                require("persistence").load({ last = true })
            end, { desc = "Session: restore last" })
        end
    }
}
