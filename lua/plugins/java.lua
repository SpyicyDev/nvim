return {
    {
        'mfussenegger/nvim-jdtls',
        ft = { "java" },
        config = function()
            local jdtls_bin = vim.fn.stdpath("data") .. "/mason/bin/jdtls"
            local cwd = vim.fn.getcwd()
            local project_path = cwd:match("/projects/(.*)")
            local project_name = project_path or vim.fn.fnamemodify(cwd, ":t")
            local workspace_dir = "/Users/mackhaymond/projects/" .. project_name
            local dir = vim.fs.root(0, { ".git", "mvnw", "gradlew" })

            local config = {
                -- The command that starts the language server
                -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
                cmd = { jdtls_bin, "-configuration", "~/.cache/jdtls", "-data", workspace_dir, },

                -- 💀
                -- This is the default if not provided, you can remove it. Or adjust as needed.
                -- One dedicated LSP server & client will be started per unique root_dir
                -- root_dir = dir,
                -- Here you can configure eclipse.jdt.ls specific settings
                -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
                -- for a list of options
                root_dir = dir,
                settings = {
                    java = {},
                },

            }
            -- This starts a new client & server,
            -- or attaches to an existing client & server depending on the `root_dir`.
            require("jdtls").start_or_attach(config)

            vim.api.nvim_set_keymap('n', '<A-o>', "<Cmd>lua require'jdtls'.organize_imports()<CR>",
                { noremap = true, silent = true })
            vim.api.nvim_set_keymap('n', 'crv', "<Cmd>lua require('jdtls').extract_variable()<CR>",
                { noremap = true, silent = true })
            vim.api.nvim_set_keymap('v', 'crv', "<Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>",
                { noremap = true, silent = true })
            vim.api.nvim_set_keymap('n', 'crc', "<Cmd>lua require('jdtls').extract_constant()<CR>",
                { noremap = true, silent = true })
            vim.api.nvim_set_keymap('v', 'crc', "<Esc><Cmd>lua require('jdtls').extract_constant(true)<CR>",
                { noremap = true, silent = true })
            vim.api.nvim_set_keymap('v', 'crm', "<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>",
                { noremap = true, silent = true })
        end,
    }
}
