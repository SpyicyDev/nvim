-- import keymaps and general settings
require('keymaps')
require('set')

-- bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local uv = vim.uv or vim.loop
if not uv.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup("plugins", {
    dev = {
        path = "~/projects/nvim_dev",
    },
})

vim.loader.enable()

-- set colorscheme
local ok = pcall(vim.cmd.colorscheme, "catppuccin-mocha")
if not ok then
    vim.cmd.colorscheme("habamax")
end

vim.filetype.add({
    extension = {
        r = 'r',
        R = 'r',
    },
})
