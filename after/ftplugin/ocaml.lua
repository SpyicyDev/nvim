vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

local TMUX_TARGET = "{right-of}"
local TMUX_BUFFER = "nvim_send"

local function notify(msg, level)
  vim.schedule(function()
    vim.notify(msg, level or vim.log.levels.INFO, { title = "OCaml REPL Send" })
  end)
end

local function has_tmux()
  if vim.fn.executable("tmux") ~= 1 then
    return false
  end
  if vim.env.TMUX == nil or vim.env.TMUX == "" then
    return false
  end
  return true
end

local function sys(argv, opts)
  opts = opts or {}
  local obj = vim.system(argv, opts):wait()
  return obj
end

local function resolve_tmux_target(target)
  local res = sys({ "tmux", "display-message", "-p", "-t", target, "#{pane_id}" }, { text = true })
  if res.code == 0 and res.stdout and res.stdout ~= "" then
    return vim.trim(res.stdout)
  end
  return target
end

local function tmux_send_text(text)
  if not has_tmux() then
    notify("tmux not available (outside tmux or tmux not installed)", vim.log.levels.WARN)
    return
  end

  local target = resolve_tmux_target(TMUX_TARGET)

  local load = sys({ "tmux", "load-buffer", "-b", TMUX_BUFFER, "-" }, { stdin = text })
  if load.code ~= 0 then
    notify("tmux load-buffer failed", vim.log.levels.ERROR)
    return
  end

  local paste = sys({ "tmux", "paste-buffer", "-t", target, "-b", TMUX_BUFFER, "-d", "-p" }, { text = true })
  if paste.code ~= 0 then
    if target ~= TMUX_TARGET then
      paste = sys({ "tmux", "paste-buffer", "-t", TMUX_TARGET, "-b", TMUX_BUFFER, "-d", "-p" }, { text = true })
    end
    if paste.code ~= 0 then
      notify("tmux paste-buffer failed", vim.log.levels.ERROR)
    end
  end
end

local function node_text_under_cursor(bufnr)
  bufnr = bufnr or 0

  local ok_node, node = pcall(vim.treesitter.get_node, { bufnr = bufnr })
  if not ok_node or not node then
    return nil
  end

  if vim.treesitter.get_node_text then
    local ok_text, txt = pcall(vim.treesitter.get_node_text, node, bufnr)
    if ok_text and txt and txt ~= "" then
      return txt
    end
  end

  local sr, sc, er, ec = node:range()
  local lines = vim.api.nvim_buf_get_text(bufnr, sr, sc, er, ec, {})
  return table.concat(lines, "\n")
end

vim.keymap.set("n", "<A-e>", function()
  local txt = node_text_under_cursor(0)
  if not txt or txt == "" then
    notify("No Treesitter node under cursor", vim.log.levels.WARN)
    return
  end
  tmux_send_text(txt .. ";;\n")
end, { buffer = true, desc = "OCaml REPL Send" })
