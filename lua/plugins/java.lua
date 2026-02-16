return {
    {
        'mfussenegger/nvim-jdtls',
        ft = { "java" },
        config = function()
            local jdtls_bin = vim.fn.stdpath("data") .. "/mason/bin/jdtls"
            local cwd = vim.fn.getcwd()
            local dir = vim.fs.root(0, { ".git", "mvnw", "gradlew" }) or cwd
            local project_name = vim.fn.fnamemodify(dir, ":t")
            local workspace_base = vim.fn.stdpath("data") .. "/jdtls-workspaces"
            local workspace_dir = workspace_base .. "/" .. project_name
            local jdtls_config_dir = vim.fn.expand("~/.cache/jdtls")

            local config = {
                -- The command that starts the language server
                -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
                cmd = { jdtls_bin, "-configuration", jdtls_config_dir, "-data", workspace_dir, },

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

            local opts = { buffer = true, silent = true }
            vim.keymap.set('n', '<A-o>', function() require('jdtls').organize_imports() end,
                vim.tbl_extend('force', opts, { desc = 'Java: Organize imports' }))
            vim.keymap.set('n', 'crv', function() require('jdtls').extract_variable() end,
                vim.tbl_extend('force', opts, { desc = 'Java: Extract variable' }))
            vim.keymap.set('v', 'crv', function() require('jdtls').extract_variable(true) end,
                vim.tbl_extend('force', opts, { desc = 'Java: Extract variable (selection)' }))
            vim.keymap.set('n', 'crc', function() require('jdtls').extract_constant() end,
                vim.tbl_extend('force', opts, { desc = 'Java: Extract constant' }))
            vim.keymap.set('v', 'crc', function() require('jdtls').extract_constant(true) end,
                vim.tbl_extend('force', opts, { desc = 'Java: Extract constant (selection)' }))
            vim.keymap.set('v', 'crm', function() require('jdtls').extract_method(true) end,
                vim.tbl_extend('force', opts, { desc = 'Java: Extract method (selection)' }))
        end,
    }
}
