-- import keymaps
require('keymaps')

require('set')

-- bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
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


vim.g.nvlime_config = {
    implementation = "ros",
    cmp = {
        enabled = true,
    },
}
vim.api.nvim_exec([[
let g:nvlime_cl_impl = "ros"
function! NvlimeBuildServerCommandFor_ros(nvlime_loader, nvlime_eval)
    return ["ros", "run",
                \ "--load", a:nvlime_loader,
                \ "--eval", a:nvlime_eval]
endfunction

]], false)

-- import plugins
require('plugins')

-- set colorscheme
vim.cmd.colorscheme "catppuccin-mocha"
