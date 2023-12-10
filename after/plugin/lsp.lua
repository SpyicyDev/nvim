local lsp = require('lsp-zero').preset({
    float_border = 'rounded',
    call_servers = 'local',
    configure_diagnostics = true,
    setup_servers_on_start = true,
    set_lsp_keymaps = {
        preserve_mappings = false,
        omit = {},
    },
    manage_nvim_cmp = {
        set_sources = 'recommended',
        set_basic_mappings = true,
        set_extra_mappings = true,
        use_luasnip = true,
        set_format = true,
        documentation_window = true,
    },
})

lsp.on_attach(function(client, bufnr)
    lsp.default_keymaps({ buffer = bufnr })
    client.server_capabilities.semanticTokensProvider = nil

    vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', { buffer = bufnr })
    vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', { buffer = bufnr })
    vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', { buffer = bufnr })
    vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', { buffer = bufnr })
    vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', { buffer = bufnr })
    vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', { buffer = bufnr })
    vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', { buffer = bufnr })

    vim.keymap.set('n', 'gn', '<cmd>lua vim.lsp.buf.rename()<cr>', { buffer = bufnr })
    vim.keymap.set({ 'n', 'x' }, 'gf', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', { buffer = bufnr })
    vim.keymap.set('n', 'gc', '<cmd>lua vim.lsp.buf.code_action()<cr>', { buffer = bufnr })

    if client.supports_method('textDocument/formatting') then
        require('lsp-format').on_attach(client)
    end
end)

-- (Optional) Configure lua language server for neovim
require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())

require 'lspconfig'.julials.setup {
    on_new_config = function(new_config, _)
        local julia = vim.fn.expand("~/.julia/environments/nvim-lspconfig/bin/julia")
        if require 'lspconfig'.util.path.is_file(julia) then
            new_config.cmd[1] = julia
        end
    end
}

lsp.ensure_installed({
    'bashls',
    'clangd',
    'clojure_lsp',
    'elixirls',
    'gopls',
    'lua_ls',
    'ocamllsp',
    'rust_analyzer',
    'tsserver',
})

lsp.setup()

-- Make sure you setup `cmp` after lsp-zero

require("luasnip.loaders.from_vscode").lazy_load()



local cmp = require('cmp')
local luasnip = require('luasnip')

local has_words_before = function()
    unpack = unpack or table.unpack
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end


cmp.setup({
    sources = {
        { name = 'path' },
        { name = 'copilot' },
        { name = 'nvim_lsp' },
        { name = 'nvim_lua' },
        { name = 'conjure' },
        { name = 'nvlime' },
        { name = 'buffer',  keyword_length = 3 },
        { name = 'luasnip', keyword_length = 2 },
    },
    formatting = {
        fields = { 'abbr', 'kind', 'menu' },
        format = require('lspkind').cmp_format({
            menu = {
                nvim_lsp = "[LSP]",
                conjure = "[Conjure]",
            },
            mode = 'symbol_text',
            maxwidth = 50,         -- prevent the popup from showing more than provided characters
            ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead
            symbol_map = { Copilot = "" },
        })
    },
    mapping = {
        ['<CR>'] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.replace,
            select = false }),
        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            elseif has_words_before() then
                cmp.complete()
            else
                fallback()
            end
        end, { "i", "s" }),


        ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { "i", "s" }),

        --[[
        ['<Down>'] = cmp.mapping(function(fallback)
            cmp.close()
            fallback()
        end, { "i" }),
        ['<Up>'] = cmp.mapping(function(fallback)
            cmp.close()
            fallback()
        end, { "i" }),
        --]]

    },
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },
})
