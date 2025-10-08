return {
    {
        "spyicydev/run.nvim",
        dependencies = {
            "numToStr/FTerm.nvim",
        },
        opts = {
            filetype = {
                scala = function()
                    vim.notify("Execute 'sbt run' in a separate tmux window!")
                end,
                python = function()
                    if vim.fn.findfile("pyproject.toml", ".;") ~= "" then
                        return "poetry run python3 %f"
                    else
                        return "python3 %f"
                    end
                end,
                cpp = ":CMakeRun",
                rust = "cargo run",
                lua = "lua %f",
                markdown = ":MarkdownPreview",
                java = function()
                    if vim.fn.findfile("build.gradle", ".;") ~= "" then
                        return "./gradlew run"
                    else
                        return "java %f"
                    end
                end,
                r = "rscript %f",
                ocaml = function()
                    local fn        = vim.fn
                    local path      = fn.expand('%:p') -- full path of current buffer
                    local dir       = fn.fnamemodify(path, ':h') -- directory that holds it
                    local base      = fn.expand('%:t:r') -- file name stem

                    -- ── figure-out executable name from dune ────────────────────────────────
                    local exe, dune = nil, dir .. '/dune'
                    if fn.filereadable(dune) == 1 then
                        for _, line in ipairs(fn.readfile(dune)) do
                            exe = exe or line:match('%(name%s+([%w%-%_]+)%)')
                            if not exe then
                                local list = line:match('%(names%s+([%w%-%s_]+)%)')
                                if list then
                                    for n in list:gmatch('([%w_%-%d]+)') do
                                        if n == base then
                                            exe = n
                                            break
                                        end
                                    end
                                end
                            end
                            if exe then break end
                        end
                    end
                    exe = exe or base -- fallback to file name

                    -- ── climb to the dune project/workspace root ────────────────────────────
                    local root = dir
                    while root ~= '/' and root ~= '' do
                        if fn.filereadable(root .. '/dune-project') == 1
                            or fn.filereadable(root .. '/dune-workspace') == 1 then
                            break
                        end
                        root = fn.fnamemodify(root, ':h')
                    end

                    -- ── derive relative path from root to dir (no relpath() needed) ─────────
                    local rel
                    if dir:sub(1, #root) == root then -- same hierarchy
                        rel = (#dir == #root) and '.' -- file is in the root itself
                            or dir:sub(#root + 2) -- chop “root/” prefix
                    else
                        rel = dir       -- fallback: absolute
                    end

                    local exe_path = (rel == '.' and ('./' .. exe .. '.exe'))
                        or ('./' .. rel .. '/' .. exe .. '.exe')

                    return 'dune exec ' .. exe_path .. ' --'
                end,
            },
        },
    }
}
