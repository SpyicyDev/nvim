local runtime_matches = vim.api.nvim_get_runtime_file("lsp/opencode.lua", false)
local runtime_file = runtime_matches and runtime_matches[1]

if not runtime_file then
  error("lsp.opencode shim could not find runtime file 'lsp/opencode.lua' from opencode.nvim", 0)
end

return dofile(runtime_file)
