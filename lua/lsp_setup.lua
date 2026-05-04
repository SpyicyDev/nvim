local M = {}

function M.setup()
-- diagnostic keybinds
vim.keymap.set('n', 'gl', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', function() vim.diagnostic.jump({ count = -1 }) end)
vim.keymap.set('n', ']d', function() vim.diagnostic.jump({ count = 1 }) end)

-- diagnostic signs
vim.diagnostic.config({
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN]  = " ",
            [vim.diagnostic.severity.INFO]  = " ",
            [vim.diagnostic.severity.HINT]  = "",
        },
    },
})

-- LSP keybinds, sets when LSP attaches
vim.api.nvim_create_autocmd('LspAttach', {
    desc = 'LSP actions',
    callback = function(event)
        local opts = { buffer = event.buf }

        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', 'go', vim.lsp.buf.type_definition, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', 'gh', vim.lsp.buf.signature_help, opts)

        vim.keymap.set('n', 'gn', ':IncRename ', opts)
        vim.keymap.set({ 'n', 'x' }, 'gw', function() vim.lsp.buf.format({ async = true }) end, opts)
        vim.keymap.set('n', 'gc', require("actions-preview").code_actions, opts)

        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client:supports_method('textDocument/inlayHint') then
            vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
        end
    end
})

-- setup each LSP in mason
local lsp_capabilities = require('blink.cmp').get_lsp_capabilities()
lsp_capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true
}
-- enable codelens capability
lsp_capabilities.textDocument.codeLens = { dynamicRegistration = true }

local on_attach = function(_client, _bufnr)
end

local default_setup = function(server)
    vim.lsp.config(server, {
        capabilities = lsp_capabilities,
        on_attach = on_attach,
    })
end

local noop = function() end


require('mason-lspconfig').setup({
    ensure_installed = { 'basedpyright' },
    handlers = {
        default_setup,
        ['jdtls'] = noop,
        ['basedpyright'] = function(server)
            vim.lsp.config(server, {
                capabilities = lsp_capabilities,
                on_attach = on_attach,
                settings = {
                    basedpyright = {
                        analysis = {
                            autoSearchPaths = true,
                            useLibraryCodeForTypes = true,
                            diagnosticMode = "openFilesOnly",
                        },
                    },
                },
            })
        end,
    },
})

-- ocamllsp installed by opam, this sets it up
vim.lsp.config('ocamllsp', {
    capabilities = lsp_capabilities,
    on_attach = on_attach,
})
vim.lsp.enable({"ocamllsp"})


-- null-ls setup
require("mason-null-ls").setup({
    ensure_installed = {},
    automatic_installation = false,
    handlers = {},
})
local null_ls = require("null-ls")
null_ls.setup({
    sources = {
        null_ls.builtins.formatting.ocamlformat,
    }
})

end

return M
