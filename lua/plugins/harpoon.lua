return {
    -- harpoon, BLAZINGLY FAST
    {
        "theprimeagen/harpoon",
        opts = {
            tabline = true,
        },
        init = function()
            vim.keymap.set("n", "<leader>hg", require("harpoon.mark").add_file)
            vim.keymap.set("n", "<leader>hh", require("harpoon.ui").toggle_quick_menu)

            for i = 1, 5 do
                vim.keymap.set("n", "<leader>" .. i, function() require("harpoon.ui").nav_file(i) end)
            end

            local function get_visual_selection()
                local s_start = vim.fn.getpos("'<")
                local s_end = vim.fn.getpos("'>")
                local n_lines = math.abs(s_end[2] - s_start[2]) + 1
                local lines = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)
                lines[1] = string.sub(lines[1], s_start[3], -1)
                if n_lines == 1 then
                    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3] - s_start[3] + 1)
                else
                    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3])
                end
                return table.concat(lines, '\n') .. ";;\n"
            end

            -- OCaml filetype buffer keymap, <leader>ee in lua
            vim.api.nvim_create_autocmd("BufReadPre", {
                pattern = { "*.ml", "*.mli" },
                callback = function()
                    vim.keymap.set("n", "<A-e>", function()
                        local node = require("nvim-treesitter.ts_utils").get_node_at_cursor()
                        local node_table = require("nvim-treesitter.ts_utils").get_node_text(node, 0)
                        local node_text = table.concat(node_table, "\n") .. ";;\n"

                        require("harpoon.tmux").sendCommand("{right-of}", node_text)
                    end, { buffer = true, desc = "OCaml REPL Send" })
                end
            })
        end,
    },
}
